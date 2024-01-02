vim.cmd('filetype off')
vim.cmd('filetype plugin indent off')

vim.g.mapleader = " "

local opt = vim.opt
local map = require('vim.keymap').set


--------------------------------------------------------------------------------------
-- base config -----------------------------------------------------------------------
--------------------------------------------------------------------------------------

opt.swapfile = false
opt.number = true
opt.cursorline = true
opt.incsearch = true
opt.hlsearch = true
opt.showmatch = true
opt.matchtime = 1
opt.wrap = false
opt.wrapscan = false
opt.ignorecase = true
opt.smartcase = true
opt.hidden = true
opt.history = 10000
opt.helplang = 'ja,en'
opt.autoindent = true
opt.breakindent = true
opt.smarttab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.signcolumn = 'yes' -- 行数表示の横にLSP用の余白を常時表示

-- undo
if vim.fn.has('persistent_undo') == 1 then
  opt.undodir  = vim.fn.expand('$HOME/.local/share/nvim/undo')
  opt.undofile = true
end

-- 相対行番号のtoggle
opt.relativenumber = true
vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*.*',
  callback = function()
    opt.relativenumber = false
  end
})
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*.*',
  callback = function()
    opt.relativenumber = true
  end
})

-- yank hilighted
vim.api.nvim_create_autocmd(
  'TextYankPost',
  {
    pattern = '*',
    callback = function()
      vim.highlight.on_yank({ timeout = 150 })
    end
  }
)

if vim.fn.exists('+termguicolors') == 1 and vim.env.TERM_PROGRAM ~= "Apple_Terminal" then
  opt.termguicolors = true
end
opt.laststatus = 2

-- keymap
-- map('n', '/', '/\\v', { noremap = true }) -- //<Cr>をする時に使い勝手が悪い
-- map('n', 'Y', 'y$', { noremap = true })
map('n', '<C-l>', ':<C-u>nohlsearch<CR><C-l>', { noremap = true, silent = true }) -- 元々<C-l>は画面をリフレッシュするので、ハイライトのリセットをついでにしてもらう

-- use clipboard <Leader> + ~
map({ 'n', 'v' }, '<Leader>y', '"+y', { noremap = true })
map('n', '<Leader>Y', '"+Y', { noremap = true })
map({ 'n', 'v' }, '<Leader>p', '"+p', { noremap = true })
map('n', '<Leader>P', '"+P', { noremap = true })
map({ 'n', 'v' }, '<Leader>d', '"+d', { noremap = true })

-- split window
-- map('n', '<Leader>s|', ':split<Return><C-w>w')
-- map('n', '<Leader>s|', ':vsplit<Return><C-w>w')
map('n', '<Leader>gg', ':LazyGit<CR>', { noremap = true, silent = true })

-- move right(undo keep)
map('i', '<C-l>', '<C-g>U<Right>', { silent = true })

-- move window
-- map('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
-- map('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
-- map('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
-- map('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })

-- Enter insert mode when switching to terminal
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '',
  command = 'setlocal listchars= nonumber norelativenumber nocursorline',
})
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '',
  command = 'startinsert'
})

--------------------------------------------------------------------------------------
-- plugin config ---------------------------------------------------------------------
--------------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    -- TODO: キーマップの一覧を登録する
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    -- 複数ターミナルの切り替え
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require('toggleterm').setup({
        shade_terminals = false
      })
      vim.cmd('autocmd TermEnter term://*toggleterm#* tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>')
      map('n', '<A-t>', '<Cmd>exe v:count1 . "ToggleTerm"<CR>', { noremap = true, silent = true })
      map('i', '<A-t>', '<esc><Cmd>exe v:count1 . "ToggleTerm"<CR>', { noremap = true, silent = true })

      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end

      -- if you only want these mappings for toggle term use term://*toggleterm#* instead
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end
  },
  {
    -- Siliconコマンドで選択範囲を画像出力
    'segeljakt/vim-silicon',
    cmd = 'Silicon',
  },
  {
    -- Capture + 実行したいvimコマンド で実行結果を別のバッファに出力(cmd1 | cmd2 ..で連結, !付きでcliコマンドも実行可能)
    'tyru/capture.vim',
    cmd = 'Capture',
  },
  {
    -- 起動時にファイル名の引数なしで起動した場合に表示するスタートアップ画面を設定できる。
    'goolord/alpha-nvim',
    event = "VimEnter",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('alpha').setup(require 'alpha.themes.startify'.opts)
    end
  },
  {
    -- registerの内容を引き継ぐ
    'yutkat/save-clipboard-on-exit.nvim',
    lazy = false,
  },
  {
    -- :Translateコマンドで選択範囲を翻訳
    'voldikss/vim-translator',
    cmd = { 'Translate', 'TranslateW', 'TranslateR' },
    config = function()
      vim.g.translator_target_lang = 'en'
      vim.g.translator_source_lang = 'ja'
      vim.g.translator_window_type = 'preview'
    end
  },
  {
    -- scrollbarの表示、hslensで検索結果のハイライト
    'petertriho/nvim-scrollbar',
    lazy = false,
    dependencies = { 'kevinhwang91/nvim-hlslens' },
    config = function()
      require('scrollbar').setup()
    end
  },
  {
    -- registerの内容でoperatorを上書き
    "gbprod/substitute.nvim",
    config = function()
      require("substitute").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
      -- Lua
      map("n", "<leader>s", require('substitute').operator, { noremap = true })
      map("n", "<leader>ss", require('substitute').line, { noremap = true })
      map("n", "<leader>S", require('substitute').eol, { noremap = true })
      map("x", "<leader>s", require('substitute').visual, { noremap = true })
    end
  },
  {
    -- nvimの起動を高速化
    'lewis6991/impatient.nvim',
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1010, -- make sure to load this before all the other start plugins
    config = function()
      require('impatient')
    end,
  },
  {
    -- markを可視化
    'chentoast/marks.nvim',
    config = function()
      require 'marks'.setup({
        -- whether to map keybinds or not. default true
        default_mappings = true,
        -- which builtin marks to show. default {}
        builtin_marks = { ".", "<", ">", "^" },
        -- whether movements cycle back to the beginning/end of buffer. default true
        cyclic = true,
        -- whether the shada file is updated after modifying uppercase marks. default false
        force_write_shada = false,
        -- how often (in ms) to redraw signs/recompute mark positions.
        -- higher values will have better performance but may cause visual lag,
        -- while lower values may cause performance penalties. default 150.
        refresh_interval = 250,
        -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
        -- marks, and bookmarks.
        -- can be either a table with all/none of the keys, or a single number, in which case
        -- the priority applies to all marks.
        -- default 10.
        sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
        -- disables mark tracking for specific filetypes. default {}
        excluded_filetypes = {},
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = {
          sign = "⚑",
          virt_text = "hello world"
        },
        mappings = {}
      })
    end
  },
  {
    -- Linediffコマンドで２つの選択行を比較、編集
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff'
  },
  {
    -- *, ?で移動しないようにする
    'haya14busa/vim-asterisk',
    lazy = false,
    config = function()
      map('n', '*', '<Plug>(asterisk-z*)')
      map('n', '#', '<Plug>(asterisk-z#)')
      map('n', 'g*', '<Plug>(asterisk-gz*)')
      map('n', 'g#', '<Plug>(asterisk-gz#)')
    end
  },

  {
    -- colorscheme
    "folke/tokyonight.nvim",
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  {
    -- colorscheme
    'olivercederborg/poimandres.nvim',
    config = function()
      require('poimandres').setup {
        -- leave this setup function empty for default config
        -- or refer to the configuration section
        -- for configuration options
        -- vim.cmd([[colorscheme poimandres]])
      }
    end
  },

  {
    -- todoをハイライト
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    vim.keymap.set("n", "]t", function()
        require("todo-comments").jump_next()
      end, { desc = "Next todo comment" })

      vim.keymap.set("n", "[t", function()
        require("todo-comments").jump_prev()
      end, { desc = "Previous todo comment" })

      -- You can also specify a list of valid jump keywords

      vim.keymap.set("n", "]t", function()
        require("todo-comments").jump_next({ keywords = { "ERROR", "WARNING" } })
      end, { desc = "Next error/warning todo comment" })
    end,
  },

  {
    -- :CB(l,c,r,a)(l,c,r)box[num]でcommentをいい感じの四角で囲む
    "LudoPinelli/comment-box.nvim",
    event = 'InsertEnter'
  },

  {
    -- mode毎に背景色を変更
    'mvllow/modes.nvim',
    tag = 'v0.2.0',
    config = function()
      require('modes').setup()
    end
  },

  {
    -- 16進数の横に参考の色を表示
    "hek14/symbol-overlay.nvim",
    event = "VeryLazy",
    dependencies = { "neovim/nvim-lspconfig", 'nvim-telescope/telescope.nvim' },
    config = function()
      require('symbol-overlay').setup({
        keymap = {
          toggle = '<C-t>t',
          clear_all = '<C-t>c',
          next_highlight = '<C-t>j',
          prev_highlight = '<C-t>k',
          gen = '<C-t>g',
          list = '<C-t>l',
        }
      })
      require 'telescope'.load_extension('symbol_overlay') -- comment this if you don't have telescope installed
    end,
  },

  {
    -- 16進数の横に参考の色を表示
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end
  },

  {
    -- 日本語をローマ字検索
    'lambdalisue/kensaku.vim',
    dependencies = { 'vim-denops/denops.vim' },
    lazy = false
  },
  {
    -- kensaku-search
    -- /キーでの検索でkensaku.vimを使うためのプラグイン。
    'lambdalisue/kensaku-search.vim',
    lazy = false,
    config = function()
      if vim.fn.exepath('deno') ~= '' then
        map('c', '<CR>', '<Plug>(kensaku-search-replace)<CR>')
      end
    end
  },

  {
    -- lazygitをnvimから起動
    "kdheepak/lazygit.nvim",
    -- optional for floating window border decoration
    cmd = 'LazyGit',
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- map('n', '<Leader>gg', ':LazyGit<CR>', { noremap = true, silent = true })
    end
  },

  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = { 'zbirenbaum/copilot.lua' },
    config = function()
      require("copilot_cmp").setup(
      -- suggestion = { enabled = false },
      -- panel = { enabled = false },
      )
    end
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require('copilot').setup({
        -- panel = {
        --   enabled = true,
        --   auto_refresh = false,
        --   keymap = {
        --     jump_prev = "[[",
        --     jump_next = "]]",
        --     accept = "<CR>",
        --     refresh = "gr",
        --     open = "<M-CR>"
        --   },
        --   layout = {
        --     position = "bottom", -- | top | left | right
        --     ratio = 0.4
        --   },
        -- },
        -- suggestion = {
        --   enabled = true,
        --   auto_trigger = false,
        --   debounce = 75,
        --   keymap = {
        --     accept = "<M-l>",
        --     accept_word = false,
        --     accept_line = false,
        --     next = "<M-]>",
        --     prev = "<M-[>",
        --     dismiss = "<C-]>",
        --   },
        -- },
        -- filetypes = {
        --   yaml = false,
        --   markdown = false,
        --   help = false,
        --   gitcommit = false,
        --   gitrebase = false,
        --   hgcommit = false,
        --   svn = false,
        --   cvs = false,
        --   ["."] = false,
        -- },
        -- copilot_node_command = 'node', -- Node.js version must be > 16.x
        -- server_opts_overrides = {},
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    config = function()
      require 'nvim-treesitter.configs'.setup {
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        -- List of parsers to ignore installing (for "all")
        ignore_install = {},

        ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
        -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

        highlight = {
          enable = true,

          -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
          -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
          -- the name of the parser)
          -- use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      }
    end,
  },

  -- {
  --   -- 関数名等を上行に表示
  --   'nvim-treesitter/nvim-treesitter-context',
  --   lazy = false,
  --   config = function()
  --     require 'treesitter-context'.setup {
  --       enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
  --       max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
  --       min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  --       line_numbers = true,
  --       multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
  --       trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  --       mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
  --       -- Separator between context and content. Should be a single character string, like '-'.
  --       -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  --       separator = nil,
  --       zindex = 20,     -- The Z-index of the context window
  --       on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  --     }
  --   end
  -- },

  -- {
  --   -- 関数名等を閉じ括弧の後ろに表示(treesitter依存)
  --   'haringsrob/nvim_context_vt',
  --   lazy = false,
  --   config = function()
  --     require('nvim_context_vt').setup()
  --   end
  -- },

  {
    -- gitの情報を可視化、stage用の機能を追加
    'lewis6991/gitsigns.nvim',
    lazy = false,
    config = function()
      require('gitsigns').setup {
        signs                        = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir                 = {
          follow_files = true
        },
        attach_to_untracked          = true,
        current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts      = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,   -- Use default
        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
        preview_config               = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        yadm                         = {
          enable = false
        },
        on_attach                    = function(bufnr)
          local gs = package.loaded.gitsigns

          local function lmap(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            map(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          -- Actions
          lmap('n', '<leader>hs', gs.stage_hunk)
          lmap('n', '<leader>hr', gs.reset_hunk)
          lmap('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          lmap('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          lmap('n', '<leader>hS', gs.stage_buffer)
          lmap('n', '<leader>hu', gs.undo_stage_hunk)
          lmap('n', '<leader>hR', gs.reset_buffer)
          lmap('n', '<leader>hp', gs.preview_hunk)
          lmap('n', '<leader>hb', function() gs.blame_line { full = true } end)
          lmap('n', '<leader>tb', gs.toggle_current_line_blame)
          lmap('n', '<leader>hd', gs.diffthis)
          lmap('n', '<leader>hD', function() gs.diffthis('~') end)
          lmap('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
      require("scrollbar.handlers.gitsigns").setup()
    end
  },

  {
    -- comment outを簡単にする
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        ---Add a space b/w comment and the line
        padding = true,
        ---Whether the cursor should stay at its position
        sticky = true,
        ---Lines to be ignored while (un)comment
        ignore = nil,
        ---LHS of toggle mappings in NORMAL mode
        toggler = {
          ---Line-comment toggle keymap
          line = 'gcc',
          ---Block-comment toggle keymap
          block = 'gbc',
        },
        ---LHS of operator-pending mappings in NORMAL and VISUAL mode
        opleader = {
          ---Line-comment keymap
          line = 'gc',
          ---Block-comment keymap
          block = 'gb',
        },
        ---LHS of extra mappings
        extra = {
          ---Add comment on the line above
          above = 'gcO',
          ---Add comment on the line below
          below = 'gco',
          ---Add comment at the end of line
          eol = 'gcA',
        },
        ---Enable keybindings
        ---NOTE: If given `false` then the plugin won't create any mappings
        mappings = {
          ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
          basic = true,
          ---Extra mapping; `gco`, `gcO`, `gcA`
          extra = true,
        },
        ---Function to call before (un)comment
        pre_hook = nil,
        ---Function to call after (un)comment
        post_hook = nil,
      }
    end
  },

  {
    -- " でregistoryを表示
    'tversteeg/registers.nvim',
    lazy = false,
    config = function()
      require("registers").setup()
    end
  },

  {
    -- text-objetctを色々追加(以下、抜粋)
    --  indent(全体): ii,ai,aI, iI
    --  indent(後ろのみ): R
    --  subword(CamelCaseなどで区切る): iS, aS
    --  行(タブ、空白含まず): i_,a_
    --  バッファ全体: gG
    'chrisgrieser/nvim-various-textobjs',
    config = function()
      -- default config
      require("various-textobjs").setup {
        -- lines to seek forwards for "small" textobjs (mostly characterwise textobjs)
        -- set to 0 to only look in the current line
        lookForwardSmall = 5,

        -- lines to seek forwards for "big" textobjs (mostly linewise textobjs)
        lookForwardBig = 15,

        -- use suggested keymaps (see README)
        useDefaultKeymaps = true,

        -- disable some default keymaps, e.g. { "ai", "ii" }
        disabledKeymaps = {},
      }
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'poimandres',
          -- section_separators = { left = '', right = '' },
          -- component_separators = { left = '', right = '' },
          disabled_filetypes = {},
          always_divide_middle = true,
          colored = false,
        },
        sections = {
          -- lualine_a = { 'mode' },
          lualine_a = { 'branch', 'diff' },
          lualine_b = {
            {
              'filename',
              path = 1,
              file_status = true,
              newfile_status = true,
              shorting_target = 40,
              symbols = {
                modified = ' [+]',
                readonly = ' [RO]',
                unnamed = 'Untitled',
                newfile = ' [New]',
              },
            }
          },
          lualine_c = { {
            "aerial",
            -- The separator to be used to separate symbols in status line.
            sep = ' ) ',

            -- The number of symbols to render top-down. In order to render only 'N' last
            -- symbols, negative numbers may be supplied. For instance, 'depth = -1' can
            -- be used in order to render only current symbol.
            depth = nil,

            -- When 'dense' mode is on, icons are not rendered near their symbols. Only
            -- a single icon that represents the kind of current symbol is rendered at
            -- the beginning of status line.
            dense = false,

            -- The separator to be used to separate symbols in dense mode.
            dense_sep = '.',

            -- Color the symbol icons.
            colored = true,
          } },
          lualine_x = { 'filetype', 'encoding' },
          lualine_y = {
            {
              'diagnostics',
              source = { 'nvim-lsp' },
            }
          },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        extensions = {}
      }
    end
  },

  {
    -- quick motion
    'ggandor/leap.nvim',
    lazy = false,
    config = function()
      require('leap').add_default_mappings()
    end
  },

  {
    -- 色々依存している
    'nvim-tree/nvim-web-devicons',
    lazy = false,
  },

  {
    -- buffer表示用
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local bufferline = require('bufferline')
      bufferline.setup({
        options = {
          diagnostics = "nvim_lsp",
          ---@diagnostic disable-next-line: unused-local
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
              local sym = e == "error" and " "
                  or (e == "warning" and " " or "")
              s = s .. n .. ' ' .. sym
            end
            return s
          end
        }
      })
      map('n', '<Tab>', ':<C-u>BufferLineCycleNext<CR>', { noremap = true, silent = true })
      map('n', '<S-Tab>', ':<C-u>BufferLineCyclePrev<CR>', { noremap = true, silent = true })
      map('n', '<A-p>', ':<C-u>BufferLineTogglePin<CR>', { noremap = true, silent = true })
    end
  },

  {
    -- ファイルごとにインデントを自動判定
    'tpope/vim-sleuth',
    lazy = false,
  },

  {
    -- 色々依存している
    'nvim-lua/plenary.nvim',
    lazy = false,
  },

  {
    -- 括弧、タグ等の挿入・変更・削除
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
    -- * will denote the cursor position:
    --     Old text                    Command         New text
    -- --------------------------------------------------------------------------------
    --     surr*ound_words             ysiw)           (surround_words)
    --     *make strings               ys$"            "make strings"
    --     [delete ar*ound me!]        ds]             delete around me!
    --     remove <b>HTML t*ags</b>    dst             remove HTML tags
    --     'change quot*es'            cs'"            "change quotes"
    --     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
    --     delete(functi*on calls)     dsf             function calls
  },

  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "kkharji/sqlite.lua" },
    config = function()
      require "telescope".load_extension("frecency")
      map('n', '<Leader>,', function() require('telescope').extensions.frecency.frecency() end,
        { noremap = true, silent = true })
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      map('n', '<leader>ff', builtin.find_files, {})
      map('n', '<leader>fr', builtin.live_grep, {})
      map('n', '<leader>fg', builtin.git_status, {})
      map('n', '<leader>fb', builtin.buffers, {})
      map('n', '<leader>fh', builtin.help_tags, {})
      map('n', '<Leader>b', builtin.buffers, {})

      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              -- ["<esc>"] = actions.close
            },
            n = {
              ["q"] = actions.close
            }
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        },
        extensions = {
          aerial = {
            -- Display symbols as <root>.<parent>.<symbol>
            show_nesting = {
              ['_'] = false, -- This key will be the default
              json = true,   -- You can set the option for specific filetypes
              yaml = true,
            }
          }
        }
      })
    end
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      -- open file_browser with the path of the current buffer
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>fb",
        ":Telescope file_browser initial_mode=normal<CR>",
        { noremap = true }
      )

      vim.api.nvim_set_keymap(
        "n",
        "<C-n>",
        ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
        { noremap = true }
      )

      local actions = require("telescope.actions")

      -- You don't need to set any of these options.
      -- IMPORTANT!: this is only a showcase of how you can set default options!
      require("telescope").setup {
        extensions = {
          file_browser = {
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
              ["i"] = {
                ["<C-n>"] = actions.close,
                -- your custom insert mode mappings
              },
              ["n"] = {
                -- your custom normal mode mappings
              },
            },
          },
        },
      }
      -- To get telescope-file-browser loaded and working with telescope,
      -- you need to call load_extension, somewhere after setup function:
      require("telescope").load_extension "file_browser"
    end
  },

  {
    -- インデントガイド, 改行位置を視覚化
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufEnter',
    config = function()
      opt.list = true
      opt.listchars:append "eol:↴"
      require('indent_blankline').setup {
        show_end_of_line = true,
      }
    end
  },

  {
    -- 閉じ括弧を自動挿入
    'windwp/nvim-autopairs',
    event = 'BufEnter',
    config = function()
      require('nvim-autopairs').setup()
    end
  },

  {
    -- LSPのprogressを右下にふわっと表示
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require("fidget").setup()
    end
  },

  {
    -- 検索結果の表示を拡張
    'kevinhwang91/nvim-hlslens',
    event = 'BufEnter',
    config = function()
      -- require('hlslens').setup()
      require("scrollbar.handlers.search").setup({
        -- hlslens config overrides
      })
      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap('n', '<Leader>x', ':noh<CR>', kopts)
    end
  },

  {
    'hrsh7th/nvim-cmp',
    event  = {'InsertEnter', 'CmdlineEnter'},
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require('cmp')
      local lspkind = require('lspkind')
      local luasnip = require('luasnip')

      lspkind.init({
        symbol_map = {
          Copilot = "",
        },
      })

      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

      -- load snippets from path/of/your/nvim/config/my-cool-snippets
      -- luasnip.loaders.from_vscode.lazy_load({ paths = { os.getenv("HOME") .. "/Library/Application Support/Code/User/snippets" } })
      require('luasnip.loaders.from_vscode').lazy_load({ paths = { os.getenv('HOME') .. '/.config/nvim/snippets/' } })
      map({ 'i', 's' }, '<C-k>', '<Plug>luasnip-expand-or-jump', { silent = true, noremap = false })
      map({ 'i', 's' }, '<A-h>', function() luasnip.jump(-1) end, { expr = true, noremap = false })
      map({ 'i', 's' }, '<A-l>', function() luasnip.jump(1) end, { expr = true, noremap = false })

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end
        },

        window = {
          completion = cmp.config.window.bordered({
            border = 'single'
          }),
          documentation = cmp.config.window.bordered({
            border = 'single'
          }),
        },

        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
              -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
              -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),

        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol',
            maxwidth = 50,
            ellipsis_char = '...',
          })
        },

        sources = cmp.config.sources({
            { name = 'copilot' },
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'calc' },
            { name = 'treesitter' },
          },
          {
            { name = 'buffer', keyword_length = 2 },
          })
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'nvim_lsp_document_symbol' }
        }, {
          { name = 'buffer' }
        })
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline', keyword_length = 2 }
        })
      })
    end
  }, -- 以下、nvim-cmp
  {
    'hrsh7th/cmp-nvim-lsp',
    event = 'InsertEnter',
    dependencies = {
      "neovim/nvim-lspconfig" }
  },
  {
    'scalameta/nvim-metals',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt", "java" },
        callback = function()
          require("metals").initialize_or_attach({})
        end,
        group = nvim_metals_group,
      })
    end
  },
  { 'hrsh7th/cmp-buffer',       event = 'InsertEnter' },
  { 'hrsh7th/cmp-path',         event = 'InsertEnter' },
  { 'saadparwaiz1/cmp_luasnip', event = 'InsertEnter' },
  { 'ray-x/cmp-treesitter',     event = 'InsertEnter' },
  { 'hrsh7th/cmp-cmdline',      event = 'ModeChanged' },
  {
    'hrsh7th/cmp-nvim-lsp-signature-help',
    event = 'InsertEnter',
    dependencies = {
      "neovim/nvim-lspconfig" }
  },
  {
    'hrsh7th/cmp-nvim-lsp-document-symbol',
    event = 'InsertEnter',
    dependencies = {
      "neovim/nvim-lspconfig" }
  },
  { 'hrsh7th/cmp-calc', event = 'InsertEnter' },
  {
    -- adds vscode-like pictograms
    'onsails/lspkind.nvim',
    event = 'InsertEnter'
  },
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "1.*",
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    event = 'InsertEnter',
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  {
    -- LSP向けのdiagnosticへのJumpをサポートする
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      position = "bottom", -- position of the list can be: bottom, top, left, right
      height = 10, -- height of the trouble list when position is top or bottom
      width = 50, -- width of the list when position is left or right
      icons = true, -- use devicons for filenames
      mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
      severity = nil, -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
      fold_open = "", -- icon used for open folds
      fold_closed = "", -- icon used for closed folds
      group = true, -- group results by file
      padding = true, -- add an extra new line on top of the list
      cycle_results = true, -- cycle item list when reaching beginning or end of list
      action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q",                     -- close the list
        cancel = "<esc>",                -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r",                   -- manually refresh
        jump = { "<cr>", "<tab>" },      -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" },        -- open buffer in new split
        open_vsplit = { "<c-v>" },       -- open buffer in new vsplit
        open_tab = { "<c-t>" },          -- open buffer in new tab
        jump_close = { "o" },            -- jump to the diagnostic and close the list
        toggle_mode = "m",               -- toggle between "workspace" and "document" diagnostics mode
        switch_severity = "s",           -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
        toggle_preview = "P",            -- toggle auto_preview
        hover = "K",                     -- opens a small popup with the full multiline message
        preview = "p",                   -- preview the diagnostic location
        close_folds = { "zM", "zm" },    -- close all folds
        open_folds = { "zR", "zr" },     -- open all folds
        toggle_fold = { "zA", "za" },    -- toggle fold of current file
        previous = "k",                  -- previous item
        next = "j"                       -- next item
      },
      indent_lines = true,               -- add an indent guide below the fold icons
      auto_open = false,                 -- automatically open the list when you have diagnostics
      auto_close = false,                -- automatically close the list when you have no diagnostics
      auto_preview = true,               -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
      auto_fold = false,                 -- automatically fold a file trouble list at creation
      auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
      signs = {
        -- icons / text used for a diagnostic
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = "",
      },
      use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
    },
    config = function()
      map("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })
      map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true })
      map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true })
      map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
      map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
      map("n", "<leader>lr", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, noremap = true })
      map("n", "<leader>ld", "<cmd>TroubleToggle lsp_definitions<cr>", { silent = true, noremap = true })
      map("n", "<leader>lt", "<cmd>TroubleToggle lsp_type_definitions<cr>", { silent = true, noremap = true })
    end
  },
  {
    -- function/class等の構造表示、移動
    'stevearc/aerial.nvim',
    lazy = false,
    opts = {},
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require('aerial').setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
          vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
        end
      })
      -- You probably also want to set a keymap to toggle aerial
      vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')
      require('telescope').load_extension('aerial')
    end
  },

  {
    -- markdown
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown', 'pandoc.markdown', 'rmd' },
    build = 'sh -c "cd app && yarn install"'
  },

  {
    'neovim/nvim-lspconfig',
    config = function()
      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- The following example advertise capabilities to `clangd`.
      local lspconfig = require('lspconfig')

      -- on attach
      -- local on_attach = function(client, bufnr)
      -- end

      -- lsp setup --------------------------------------------------------------------
      lspconfig.tsserver.setup {
        capabilities = capabilities
      }

      lspconfig.gopls.setup {
        capabilities = capabilities
      }

      lspconfig.sourcekit.setup {
        filetypes = { 'swift', 'objective-c', 'objective-cpp' },
        capabilities = capabilities
      }

      lspconfig.rust_analyzer.setup {
        settings = {
          ["rust-analyzer"] = {
            -- enable clippy on save
            check = {
              command = "clippy"
            }
          }
        },
        capabilities = capabilities
      }

      lspconfig.pyright.setup {
        capabilities = capabilities
      }

      lspconfig.lua_ls.setup {
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              -- library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
        capabilities = capabilities
      }

      -- Global mappings. -------------------------------------------------------
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      map('n', '<space>q', vim.diagnostic.setloclist)
    end
  },
  {
    'nvimdev/lspsaga.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    },
    config = function()
      require('lspsaga').setup({
        ui = {
          border = "single",
        },
        symbol_in_winbar = {
          enable = true,
        },
        lightbulb = {
          enable = false,
        },
        show_outline = {
          auto_preview = false,
        },
        code_action = {
          extend_gitsigns = false,
        }
      })

      map('n', '<space>e', '<cmd>Lspsaga show_line_diagnostics<CR>')
      map('n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>')
      map('n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>')
      map({ 'n', 't' }, '<A-j>', '<cmd>Lspsaga term_toggle<CR>')
      map('n', 'go', '<cmd>Lspsaga outline<CR>')

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          map('n', 'gD', '<cmd>Lspsaga goto_definition<CR>', opts)
          map('n', 'gd', '<cmd>Lspsaga peek_definition<CR>', opts)
          map('n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)
          map('n', 'gr', '<cmd>Lspsaga finder<CR>', opts)
          map('n', 'gi', vim.lsp.buf.implementation, opts)
          map('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          map('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
          map('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
          map('n', '<Leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          map('n', '<Leader>D', '<cmd>Lspsaga goto_type_definition<CR>', opts)
          map('n', '<F2>', '<cmd>Lspsaga rename<CR>', opts)
          map({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
          map('n', '<F3>', function()
            vim.lsp.buf.format { async = true }
          end, opts)
          map('n', 'ga', '<cmd>Lspsaga code_action<CR>')
        end,
      })
    end,
  }
})

------------------------------------------------------------------------------------
-- finnaly -------------------------------------------------------------------------
------------------------------------------------------------------------------------
vim.cmd('filetype plugin indent on')
vim.cmd('filetype plugin indent on')
