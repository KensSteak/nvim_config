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
    -- Capture + 実行したいvimコマンド で実行結果を別のバッファに出力(cmd1 | cmd2 ..で連結, !付きでcliコマンドも実行可能)
    'tyru/capture.vim',
    cmd = 'Capture',
  },
  {
    -- registerの内容を引き継ぐ
    'yutkat/save-clipboard-on-exit.nvim',
    lazy = false,
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
    -- mode毎に背景色を変更
    'mvllow/modes.nvim',
    tag = 'v0.2.0',
    config = function()
      require('modes').setup()
    end
  },

  {
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
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
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
  }
})
