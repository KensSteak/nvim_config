vim.opt.filetype = "off"
vim.opt.filetype = "plugin", "indent", "off"

vim.g.mapleader = " "

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
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------------
-- config -------------------------------------------------------
-----------------------------------------------------------------
vim.opt.swapfile = false
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.showmatch = true
vim.opt.matchtime = 1
vim.opt.wrap = true
vim.opt.whichwrap = 'h','l'
vim.opt.wrapscan = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hidden = true
vim.opt.autoindent = true
vim.opt.history = 10000
vim.opt.helplang = 'ja', 'en'

vim.keymap.set('n', 'Y', 'y$', {noremap=true})
vim.keymap.set('n', '<esc><esc>', ':<C-u>nohlsearch<CR>', {noremap=true, silent = true}) 

-- use clipboard <Leader> + ~
vim.keymap.set({'n', 'v'}, '<Leader>y', '"+y', {noremap=true})
vim.keymap.set('n', '<Leader>Y', '"+y$', {noremap=true})
vim.keymap.set({'n', 'v'}, '<Leader>p', '"+p', {noremap=true})
vim.keymap.set('n', '<Leader>P', '"+P', {noremap=true})

-- use clipboard <Leader> + ~
vim.keymap.set('n', '<Leader>k', ':<C-u>bd<CR>', {noremap=true, silent=true}) 


-----------------------------------------------------------------
-- Lazy load plugins --------------------------------------------
-----------------------------------------------------------------
require('lazy').setup({
{
  "folke/tokyonight.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- load the colorscheme here
    vim.cmd([[colorscheme tokyonight]])
  end,
},

{
  'lewis6991/gitsigns.nvim',
  lazy = false,
  config = function()
    require('gitsigns').setup()
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
  'nvim-lualine/lualine.nvim',
  lazy = false,
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '|', right = '|'},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {},
        always_divide_middle = true,
        colored = false,
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff'},
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
        lualine_x = {'filetype', 'encoding'},
        lualine_y = {
          {
            'diagnostics',
            source = {'nvim-lsp'},
          }
        },
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
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
  "nvim-telescope/telescope-frecency.nvim",
  config = function()
    require"telescope".load_extension("frecency")
  end,
  dependencies = {"kkharji/sqlite.lua"}
},

{
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

    local actions = require("telescope.actions")
    require("telescope").setup{
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

    vim.api.nvim_set_keymap('n', '<Leader>,', "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>", {noremap = true, silent = true})
  end
},

{
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      -- open file_browser with the path of the current buffer
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
    vim.opt.list = true
    vim.opt.listchars:append "eol:↴"
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
  config = function()
    require("fidget").setup()
  end
}, 

{
  'kevinhwang91/nvim-hlslens',
  event = 'BufEnter',
  config = function()
    require('hlslens').setup()
    local kopts = {noremap = true, silent = true}

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

    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    vim.cmd('let g:vsnip_filetypes = {}')
  end
}, -- 以下、nvim-cmp
{'hrsh7th/cmp-nvim-lsp', event = 'InsertEnter', dependencies = { "neovim/nvim-lspconfig"}}, 
{'hrsh7th/cmp-buffer', event = 'InsertEnter'},
{'hrsh7th/cmp-path', event = 'InsertEnter'},
{'hrsh7th/cmp-vsnip', event = 'InsertEnter'},
{'hrsh7th/cmp-cmdline', event = 'ModeChanged'},
{'hrsh7th/cmp-nvim-lsp-signature-help', event = 'InsertEnter', dependencies = { "neovim/nvim-lspconfig"}},
{'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'InsertEnter', dependencies = { "neovim/nvim-lspconfig"}},
{'hrsh7th/cmp-calc', event = 'InsertEnter'},
{'onsails/lspkind.nvim', event = 'InsertEnter'},
{
  'hrsh7th/vim-vsnip',
  event = 'InsertEnter',
  config = function()
    vim.g.vsnip_snippet_dirs = {os.getenv("HOME") .. "/.config/nvim/snippets"}

    vim.keymap.set('i', '<C-l>', '<Plug>(vsnip-expand-or-jump)', {noremap=true})
    vim.keymap.set('s', '<C-l>', '<Plug>(vsnip-expand-or-jump)', {noremap=true})
  end
},
{'hrsh7th/vim-vsnip-integ', event = 'InsertEnter'},
{'rafamadriz/friendly-snippets', event = 'InsertEnter'},
{
  'neovim/nvim-lspconfig',
  config = function()
    -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- The following example advertise capabilities to `clangd`.
    local lspconfig = require('lspconfig')
    lspconfig.rust_analyzer.setup {
      settings = {
          ["rust-analyzer"] = {
            -- enable clippy on save
            check = {
              command = "clippy"
            }
          }
      },
      capabilities=capabilities
    }

    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

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
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<Leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<F3>', function()
          vim.lsp.buf.format { async = true }
        end, opts)
      end,
    })
  end
},
})

-----------------------------------------------------------------
-- color scheme
-----------------------------------------------------------------
if vim.fn.exists('+termguicolors') == 1 and vim.env.TERM_PROGRAM ~= "Apple_Terminal" then
    vim.opt.termguicolors = true
end
vim.opt.laststatus = 2

vim.opt.filetype = "plugin", "indent","on"
