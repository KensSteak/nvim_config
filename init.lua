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
opt.signcolumn = 'yes' --行数表示の横にLSP用の余白を常時表示

-- 相対行番号のtoggle
opt.relativenumber = true
vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  callback = function()
    opt.relativenumber = false
  end
})
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
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
map('n', 'Y', 'y$', { noremap = true })
map('n', '<Leader><Leader>', ':<C-u>nohlsearch<CR>', { noremap = true, silent = true })

-- use clipboard <Leader> + ~
map({ 'n', 'v' }, '<Leader>y', '"+y', { noremap = true })
map('n', '<Leader>Y', '"+y$', { noremap = true })
map({ 'n', 'v' }, '<Leader>p', '"+p', { noremap = true })
map('n', '<Leader>P', '"+P', { noremap = true })
map({ 'n', 'v' }, '<Leader>d', '"+d', { noremap = true })

-- split window
map('n', '<Leader>ss', ':split<Return><C-w>w')
map('n', '<Leader>sv', ':vsplit<Return><C-w>w')

map('n', '<Leader>gg', ':LazyGit<CR>', { noremap = true, silent = true })


-- neovim terminal mapping
map("t", "<ESC>", "<C-\\><C-n>", { noremap = true })
vim.api.nvim_create_user_command("T", ":split | wincmd j | resize 20 | terminal <args>", { nargs = "*" })

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
    -- 起動時にファイル名の引数なしで起動した場合に表示するスタートアップ画面を設定できる。
    'goolord/alpha-nvim',
    event = "VimEnter",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require 'alpha'.setup(require 'alpha.themes.startify'.opts)
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
    'lewis6991/impatient.nvim',
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1010, -- make sure to load this before all the other start plugins
    config = function()
      require('impatient')
    end,
  },

  {
    "folke/tokyonight.nvim",
    config = function()
      -- load the colorscheme here
      -- vim.cmd([[colorscheme tokyonight]])
    end,
  },

  {
    'olivercederborg/poimandres.nvim',
    config = function()
      require('poimandres').setup {
        -- leave this setup function empty for default config
        -- or refer to the configuration section
        -- for configuration options
        vim.cmd([[colorscheme poimandres]])
      }
    end
  },

  {
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
    'mvllow/modes.nvim',
    tag = 'v0.2.0',
    config = function()
      require('modes').setup()
    end
  },

  {
    't9md/vim-quickhl',
    config = function()
      map({ 'n', 'x' }, '<Leader>m', '<Plug>(quickhl-manual-this)')
      map({ 'n', 'x' }, '<Leader>M', '<Plug>(quickhl-manual-reset)')
    end
  },

  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end
  },

  {
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

  -- {
  --   "github/copilot.vim",
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   config = function()
  --     -- Acceptの引数は、補完候補がないときのキーコード
  --     vim.cmd("imap <silent><script><expr> <C-k> copilot#Accept(\"\")")
  --     vim.g.copilot_no_tab_map = true
  --
  --     map('i', '<C-f>', '<Plug>(copilot-next)', { silent = true })
  --     map('i', '<C-b>', '<Plug>(copilot-previous)', { silent = true })
  --   end,
  -- },
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

  {
    'nvim-treesitter/nvim-treesitter-context',
    lazy = false,
    config = function()
      require 'treesitter-context'.setup {
        enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
        trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20,     -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    end
  },

  {
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
    'tversteeg/registers.nvim',
    lazy = false,
    config = function()
      require("registers").setup()
    end
  },

  {
    -- https://github.com/chrisgrieser/nvim-various-textobjs
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
          lualine_c = {
            'navic',
            color_correction = nil, -- "static" or "dynamic". モードによって背景色を帰る場合は "dynamic" を指定
            navic_opts = nil        -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
          },
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
    'ggandor/leap.nvim',
    lazy = false,
    config = function()
      require('leap').add_default_mappings()
    end
  },

  {
    'nvim-tree/nvim-web-devicons',
    lazy = false,
  },

  {
    'romgrk/barbar.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'lewis6991/gitsigns.nvim' },
    lazy = false,
    config = function()
      vim.g.barbar_auto_setup = false

      local opts = { noremap = true, silent = true }

      -- Move to previous/next
      map('n', '<A-k>', '<Cmd>BufferPrevious<CR>', opts)
      map('n', '<A-j>', '<Cmd>BufferNext<CR>', opts)
      -- Re-order to previous/next
      map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
      map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)
      -- Goto buffer in position...
      map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
      map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
      map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
      map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
      map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
      map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
      map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
      map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
      map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
      map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
      -- Pin/unpin buffer
      map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
      -- Close buffer
      map('n', '<Leader>k', '<Cmd>BufferClose<CR>', opts)
      -- Wipeout buffer
      --                 :BufferWipeout
      -- Close commands
      --                 :BufferCloseAllButCurrent
      --                 :BufferCloseAllButPinned
      --                 :BufferCloseAllButCurrentOrPinned
      --                 :BufferCloseBuffersLeft
      --                 :BufferCloseBuffersRight
      -- Magic buffer-picking mode
      map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
      -- Sort automatically by...
      -- map('n', '<Leader>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
      -- map('n', '<Leader>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
      -- map('n', '<Leader>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
      -- map('n', '<Leader>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

      -- Other:
      -- :BarbarEnable - enables barbar (enabled by default)
      -- :BarbarDisable - very bad command, should never be used
      --
      require("barbar").setup {
        -- -- Enable/disable animations
        -- animation = true,
        --
        -- -- Enable/disable auto-hiding the tab bar when there is a single buffer
        -- auto_hide = false,
        --
        -- -- Enable/disable current/total tabpages indicator (top right corner)
        -- tabpages = false,
        --
        -- -- Enables/disable clickable tabs
        -- --  - left-click: go to buffer
        -- --  - middle-click: delete buffer
        -- clickable = true,
        --
        -- -- Excludes buffers from the tabline
        -- exclude_ft = {},
        -- exclude_name = {},
        --
        -- -- A buffer to this direction will be focused (if it exists) when closing the current buffer.
        -- -- Valid options are 'left' (the default), 'previous', and 'right'
        -- focus_on_close = 'left',
        --
        -- -- Hide inactive buffers and file extensions. Other options are `alternate`, `current`, and `visible`.
        -- -- hide = {extensions = true, inactive = true},
        --
        -- -- Disable highlighting alternate buffers
        -- highlight_alternate = false,
        --
        -- -- Disable highlighting file icons in inactive buffers
        -- highlight_inactive_file_icons = false,
        --
        -- -- Enable highlighting visible buffers
        -- highlight_visible = true,
        --
        -- icons = {
        --   -- Configure the base icons on the bufferline.
        --   -- Valid options to display the buffer index and -number are `true`, 'superscript' and 'subscript'
        --   buffer_index = false,
        --   buffer_number = false,
        --   button = '',
        --   -- Enables / disables diagnostic symbols
        --   diagnostics = {
        --     [vim.diagnostic.severity.ERROR] = { enabled = true, icon = 'ﬀ' },
        --     [vim.diagnostic.severity.WARN] = { enabled = true },
        --     [vim.diagnostic.severity.INFO] = { enabled = false },
        --     [vim.diagnostic.severity.HINT] = { enabled = true },
        --   },
        --   gitsigns = {
        --     added = { enabled = true, icon = '+' },
        --     changed = { enabled = true, icon = '~' },
        --     deleted = { enabled = true, icon = '-' },
        --   },
        --   filetype = {
        --     -- Sets the icon's highlight group.
        --     -- If false, will use nvim-web-devicons colors
        --     custom_colors = false,
        --
        --     -- Requires `nvim-web-devicons` if `true`
        --     enabled = true,
        --   },
        --   separator = { left = '▎', right = '' },
        --
        --   -- If true, add an additional separator at the end of the buffer list
        --   separator_at_end = true,
        --
        --   -- Configure the icons on the bufferline when modified or pinned.
        --   -- Supports all the base icon options.
        --   modified = { button = '●' },
        --   pinned = { button = '', filename = true },
        --
        --   -- Use a preconfigured buffer appearance— can be 'default', 'powerline', or 'slanted'
        --   preset = 'default',
        --
        --   -- Configure the icons on the bufferline based on the visibility of a buffer.
        --   -- Supports all the base icon options, plus `modified` and `pinned`.
        --   alternate = { filetype = { enabled = false } },
        --   current = { buffer_index = false },
        --   inactive = { button = '×' },
        --   visible = { modified = { buffer_number = false } },
        -- },
        --
        -- -- If true, new buffers will be inserted at the start/end of the list.
        -- -- Default is to insert after current buffer.
        -- insert_at_end = false,
        -- insert_at_start = false,
        --
        -- -- Sets the maximum padding width with which to surround each tab
        -- maximum_padding = 1,
        --
        -- -- Sets the minimum padding width with which to surround each tab
        -- minimum_padding = 1,
        --
        -- -- Sets the maximum buffer name length.
        -- maximum_length = 30,
        --
        -- -- Sets the minimum buffer name length.
        -- minimum_length = 0,
        --
        -- -- If set, the letters for each buffer in buffer-pick mode will be
        -- -- assigned based on their name. Otherwise or in case all letters are
        -- -- already assigned, the behavior is to assign letters in order of
        -- -- usability (see order below)
        -- semantic_letters = true,
        --
        -- -- Set the filetypes which barbar will offset itself for
        -- sidebar_filetypes = {
        --   -- Use the default values: {event = 'BufWinLeave', text = nil}
        --   NvimTree = true,
        --   -- Or, specify the text used for the offset:
        --   undotree = { text = 'undotree' },
        --   -- Or, specify the event which the sidebar executes when leaving:
        --   ['neo-tree'] = { event = 'BufWipeout' },
        --   -- Or, specify both
        --   Outline = { event = 'BufWinLeave', text = 'symbols-outline' },
        -- },
        --
        -- -- New buffer letters are assigned in this order. This order is
        -- -- optimal for the qwerty keyboard layout but might need adjustment
        -- -- for other layouts.
        -- letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
        --
        -- -- Sets the name of unnamed buffers. By default format is "[Buffer X]"
        -- -- where X is the buffer number. But only a static string is accepted here.
        -- no_name_title = nil,
      }
    end
  },

  {
    'tpope/vim-sleuth',
    lazy = false,
  },

  {
    'nvim-lua/plenary.nvim',
    lazy = false,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "InsertEnter",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  {
    'anuvyklack/pretty-fold.nvim',
    config = function()
      require('pretty-fold').setup {
        matchup_patterns = {
          { '^%s*do$',       'end' }, -- do ... end blocks
          { '^%s*if',        'end' }, -- if ... end
          { '^%s*for',       'end' }, -- for
          { 'function%s*%(', 'end' }, -- 'function( or 'function (''
          { '{',             '}' },
          { '%(',            ')' },   -- % to escape lua pattern char
          { '%[',            ']' },   -- % to escape lua pattern char
        },
      }
    end
  },
  {
    'RRethy/vim-illuminate',
    lazy = false,
    config = function()
      -- default configuration
      require('illuminate').configure({
        -- providers: provider used to get references in the buffer, ordered by priority
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        -- delay: delay in milliseconds
        delay = 100,
        -- filetype_overrides: filetype specific overrides.
        -- The keys are strings to represent the filetype while the values are tables that
        -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
        -- filetype_overrides = {},
        -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
        -- filetypes_denylist = { },
        -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
        -- filetypes_allowlist = {},
        -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
        -- See `:help mode()` for possible values
        -- modes_denylist = {},
        -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
        -- See `:help mode()` for possible values
        -- modes_allowlist = {},
        -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
        -- Only applies to the 'regex' provider
        -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
        -- providers_regex_syntax_denylist = {},
        -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
        -- Only applies to the 'regex' provider
        -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
        -- providers_regex_syntax_allowlist = {},
        -- under_cursor: whether or not to illuminate under the cursor
        -- under_cursor = true,
        -- large_file_cutoff: number of lines at which to use large_file_config
        -- The `under_cursor` option is disabled when this cutoff is hit
        -- large_file_cutoff = nil,
        -- large_file_config: config to use for large files (based on large_file_cutoff).
        -- Supports the same keys passed to .configure
        -- If nil, vim-illuminate will be disabled for large files.
        -- large_file_overrides = nil,
        -- min_count_to_highlight: minimum number of matches required to perform highlighting
        -- min_count_to_highlight = 1,
      })
    end
  },


  {
    "nvim-telescope/telescope-frecency.nvim",
    cmd = 'Telescope',
    config = function()
      require "telescope".load_extension("frecency")
    end,
    dependencies = { "kkharji/sqlite.lua" }
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
      require("telescope").setup {
        defaults = {
          mappings = {
            i = {
              -- ["<esc>"] = actions.close
            },
            n = {
              ["q"] = actions.close
            }
          },
        },
      }

      require("telescope").setup {
        defaults = {
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        },
      }

      vim.api.nvim_set_keymap('n', '<Leader>,', "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
        { noremap = true, silent = true })
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
    'windwp/nvim-autopairs',
    event = 'BufEnter',
    config = function()
      require('nvim-autopairs').setup()
    end
  },

  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require("fidget").setup()
    end
  },

  {
    'kevinhwang91/nvim-hlslens',
    event = 'BufEnter',
    config = function()
      -- require('hlslens').setup()
      require("scrollbar.handlers.search").setup({
        -- hlslens config overrides
      })
      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap('n', 'n',
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
      vim.api.nvim_set_keymap('n', 'N',
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
      vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      vim.api.nvim_set_keymap('n', '<Leader>x', ':noh<CR>', kopts)
    end
  },

  {
    'hrsh7th/nvim-cmp',
    event  = 'InsertEnter, CmdlineEnter',
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
      map({ 'i', 's' }, '<C-l>', '<Plug>luasnip-expand-or-jump', { silent = true, noremap = false })
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
  { 'hrsh7th/cmp-calc',     event = 'InsertEnter' },
  { 'onsails/lspkind.nvim', event = 'InsertEnter' },
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
      position = "bottom",            -- position of the list can be: bottom, top, left, right
      height = 10,                    -- height of the trouble list when position is top or bottom
      width = 50,                     -- width of the list when position is left or right
      icons = true,                   -- use devicons for filenames
      mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
      severity = nil,                 -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
      fold_open = "",              -- icon used for open folds
      fold_closed = "",            -- icon used for closed folds
      group = true,                   -- group results by file
      padding = true,                 -- add an extra new line on top of the list
      cycle_results = true,           -- cycle item list when reaching beginning or end of list
      action_keys = {                 -- key mappings for actions in the trouble list
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
      map("n", "<C-t>", "<cmd>Trouble<cr>", { silent = true, noremap = true })
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
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require('nvim-navic').setup {
        icons = {
          File          = "󰈙 ",
          Module        = " ",
          Namespace     = "󰌗 ",
          Package       = " ",
          Class         = "󰌗 ",
          Method        = "󰆧 ",
          Property      = " ",
          Field         = " ",
          Constructor   = " ",
          Enum          = "󰕘",
          Interface     = "󰕘",
          Function      = "󰊕 ",
          Variable      = "󰆧 ",
          Constant      = "󰏿 ",
          String        = "󰀬 ",
          Number        = "󰎠 ",
          Boolean       = "◩ ",
          Array         = "󰅪 ",
          Object        = "󰅩 ",
          Key           = "󰌋 ",
          Null          = "󰟢 ",
          EnumMember    = " ",
          Struct        = "󰌗 ",
          Event         = " ",
          Operator      = "󰆕 ",
          TypeParameter = "󰊄 ",
        },
        lsp = {
          auto_attach = false,
          preference = nil,
        },
        highlight = false,
        separator = " > ",
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true,
        lazy_update_context = false,
        click = false
      }
    end
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- The following example advertise capabilities to `clangd`.
      local lspconfig = require('lspconfig')

      -- on attach
      local navic = require('nvim-navic')
      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end


      -- lsp setup --------------------------------------------------------------------
      lspconfig.tsserver.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }

      lspconfig.gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }

      lspconfig.sourcekit.setup {
        on_attach = on_attach,
        filetypes = { 'swift', 'objective-c', 'objective-cpp' },
        capabilities = capabilities
      }

      lspconfig.rust_analyzer.setup {
        on_attach = on_attach,
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
        on_attach = on_attach,
        capabilities = capabilities
      }

      lspconfig.lua_ls.setup {
        on_attach = on_attach,
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
      map('n', '<space>e', vim.diagnostic.open_float)
      map('n', '[d', vim.diagnostic.goto_prev)
      map('n', ']d', vim.diagnostic.goto_next)
      map('n', '<space>q', vim.diagnostic.setloclist)

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
          map('n', 'gD', vim.lsp.buf.declaration, opts)
          map('n', 'gd', vim.lsp.buf.definition, opts)
          map('n', 'K', vim.lsp.buf.hover, opts)
          map('n', 'gi', vim.lsp.buf.implementation, opts)
          map('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          map('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
          map('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
          map('n', '<Leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          map('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
          map('n', '<F2>', vim.lsp.buf.rename, opts)
          map({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
          map('n', 'gr', vim.lsp.buf.references, opts)
          map('n', '<F3>', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end
  },
})

------------------------------------------------------------------------------------
-- finnaly -------------------------------------------------------------------------
------------------------------------------------------------------------------------
vim.cmd('filetype plugin indent on')
