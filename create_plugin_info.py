import toml
from pathlib import Path
import argparse
import logging
import shutil
from datetime import datetime

logging.basicConfig(level=logging.INFO)


def main():
    parser = argparse.ArgumentParser(
        description="Generate plugin information from dein.toml files")
    parser.add_argument("-c", "--config", default="config.toml",
                        help="Path to the configuration file")
    args = parser.parse_args()

    config_file = Path(args.config)

    if not config_file.exists():
        logging.error(f"Config file not found: {config_file.absolute()}")
        return

    with config_file.open("r") as f:
        config = toml.load(f)

    input_files = [Path(p) for p in config.get("input_files")]
    output_file = Path(config.get("output_file"))
    archive_base = Path(config.get("archive_base"))

    if not input_files or not output_file:
        logging.error(
            "Input files or output file not specified in the config file")
        return

    temp_output_file = output_file.with_suffix(".tmp")
    if temp_output_file.exists():
        temp_output_file.unlink()

    for input_file in input_files:
        logging.info(f"Processing {Path(input_file).absolute()}")

        try:
            with input_file.open("r") as f:
                dein_toml = toml.load(f)

            with temp_output_file.open(mode="a") as f:
                f.write("="*80 + "\n")
                f.write(f"# {Path(input_file)}\n")
                f.write(f"{Path(input_file).absolute()}\n\n")

                for plugin in dein_toml.get("plugins", []):
                    plugin_info = plugin.copy()
                    plugin_info["name"] = plugin.get("repo", "").split("/")[-1]

                    f.write(
                        f"## [{plugin_info['name']}](https://github.com/{plugin_info['repo']})\n")
                    for key, value in plugin_info.items():
                        if key not in ["name", "repo"]:
                            if "\n" in value:
                                f.write(f"* {key}: \n```\n{value}\n```\n")
                            else:
                                f.write(f"* {key}: {value}\n")
                    f.write("\n")

        except FileNotFoundError:
            logging.error(f"File not found: {input_file}")
        except toml.TomlDecodeError:
            logging.error(f"Invalid TOML format in file: {input_file}")

    current_time = datetime.now().strftime("%Y%m%d%H%M%S")
    bk_output_file = archive_base / \
        f"{output_file.stem}_{current_time}{output_file.suffix}"
    shutil.copy(temp_output_file, output_file)
    shutil.copy(temp_output_file, bk_output_file)
    logging.info(
        f"Generated plugin information saved to {output_file.absolute()}")

    temp_output_file.unlink()


if __name__ == "__main__":
    main()
