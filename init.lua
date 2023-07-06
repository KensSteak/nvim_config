vim.cmd('filetype off')
vim.cmd('filetype plugin indent off')

vim.g.mapleader = " "

local opt = vim.opt
local keymap = require('vim.keymap')

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

if vim.fn.exists('+termguicolors') == 1 and vim.env.TERM_PROGRAM ~= "Apple_Terminal" then
  opt.termguicolors = true
end
opt.laststatus = 2

keymap.set('n', 'Y', 'y$', { noremap = true })
keymap.set('n', '<esc><esc>', ':<C-u>nohlsearch<CR>', { noremap = true, silent = true })

-- use clipboard <Leader> + ~
keymap.set({ 'n', 'v' }, '<Leader>y', '"+y', { noremap = true })
keymap.set('n', '<Leader>Y', '"+y$', { noremap = true })
keymap.set({ 'n', 'v' }, '<Leader>p', '"+p', { noremap = true })
keymap.set('n', '<Leader>P', '"+P', { noremap = true })

-- use clipboard <Leader> + ~
keymap.set('n', '<Leader>k', ':<C-u>bd<CR>', { noremap = true, silent = true })

-- split window
keymap.set('n', '<Leader>ss', ':split<Return><C-w>w')
keymap.set('n', '<Leader>sv', ':vsplit<Return><C-w>w')

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
    'lewis6991/impatient.nvim',
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1010, -- make sure to load this before all the other start plugins
    config = function()
      require('impatient')
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  {
    "github/copilot.vim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    config = function()
      -- Acceptの引数は、補完候補がないときのキーコード
      vim.cmd("imap <silent><script><expr> <C-k> copilot#Accept(\"\")")
      vim.g.copilot_no_tab_map = true

      keymap.set('i', '<C-f>', '<Plug>(copilot-next)', { silent = true })
      keymap.set('i', '<C-b>', '<Plug>(copilot-previous)', { silent = true })
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
          disable = function(lang, buf)
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

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            keymap.set(mode, l, r, opts)
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
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line { full = true } end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
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
          theme = 'dracula',
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {},
          always_divide_middle = true,
          colored = false,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = {
            {
              'filename',
              path = 1,
              file_status = true,
              shorting_target = 40,
              symbols = {
                modified = ' [+]',
                readonly = ' [RO]',
                unnamed = 'Untitled',
              }
            }
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
    'kyazdani42/nvim-web-devicons',
    lazy = false,
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
    "nvim-telescope/telescope-frecency.nvim",
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
      keymap.set('n', '<leader>ff', builtin.find_files, {})
      keymap.set('n', '<leader>fg', builtin.live_grep, {})
      keymap.set('n', '<leader>fb', builtin.buffers, {})
      keymap.set('n', '<leader>fh', builtin.help_tags, {})

      local actions = require("telescope.actions")
      require("telescope").setup {
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close
            },
          },
        },
      }

      local previewers = require("telescope.previewers")
      local Job = require("plenary.job")
      local new_maker = function(filepath, bufnr, opts)
        filepath = vim.fn.expand(filepath)
        Job:new({
          command = "file",
          args = { "--mime-type", "-b", filepath },
          on_exit = function(j)
            local mime_type = vim.split(j:result()[1], "/")[1]
            if mime_type == "text" then
              previewers.buffer_previewer_maker(filepath, bufnr, opts)
            else
              vim.schedule(function()
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
              end)
            end
          end
        }):sync()
      end

      require("telescope").setup {
        defaults = {
          buffer_previewer_maker = new_maker,
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
        ":Telescope file_browser<CR>",
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
      require('hlslens').setup()
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
    event = 'InsertEnter, CmdlineEnter',
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      vim.g.vsnip_snippet_dirs = { os.getenv("HOME") .. "/.config/nvim/snippets" }

      local cmp = require('cmp')
      local lspkind = require('lspkind')

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
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
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
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
            { name = 'nvim_lsp' },
            { name = 'vsnip' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'calc' },
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

      vim.cmd('let g:vsnip_filetypes = {}')
    end
  }, -- 以下、nvim-cmp
  { 'hrsh7th/cmp-nvim-lsp',                 event = 'InsertEnter', dependencies = { "neovim/nvim-lspconfig" } },
  { 'hrsh7th/cmp-buffer',                   event = 'InsertEnter' },
  { 'hrsh7th/cmp-path',                     event = 'InsertEnter' },
  { 'hrsh7th/cmp-vsnip',                    event = 'InsertEnter' },
  { 'hrsh7th/cmp-cmdline',                  event = 'ModeChanged' },
  { 'hrsh7th/cmp-nvim-lsp-signature-help',  event = 'InsertEnter', dependencies = { "neovim/nvim-lspconfig" } },
  { 'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'InsertEnter', dependencies = { "neovim/nvim-lspconfig" } },
  { 'hrsh7th/cmp-calc',                     event = 'InsertEnter' },
  { 'onsails/lspkind.nvim',                 event = 'InsertEnter' },
  {
    'hrsh7th/vim-vsnip',
    event = 'InsertEnter',
    config = function()
      keymap.set('i', '<C-l>', '<Plug>(vsnip-expand-or-jump)', { noremap = true })
      keymap.set('s', '<C-l>', '<Plug>(vsnip-expand-or-jump)', { noremap = true })
    end
  },
  { 'hrsh7th/vim-vsnip-integ',      event = 'InsertEnter' },
  { 'rafamadriz/friendly-snippets', event = 'InsertEnter' },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- The following example advertise capabilities to `clangd`.
      local lspconfig = require('lspconfig')
      -- rust -------------------------------------------------------
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
      -- python -----------------------------------------------------
      lspconfig.pyright.setup {
        capabilities = capabilities
      }
      -- lua --------------------------------------------------------
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
      }

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      keymap.set('n', '<space>e', vim.diagnostic.open_float)
      keymap.set('n', '[d', vim.diagnostic.goto_prev)
      keymap.set('n', ']d', vim.diagnostic.goto_next)
      keymap.set('n', '<space>q', vim.diagnostic.setloclist)

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
          keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          -- keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
          keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
          keymap.set('n', '<Leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
          keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
          keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
          keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          keymap.set('n', '<F3>', function()
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
