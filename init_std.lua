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

-- move right(undo keep)
map('i', '<C-l>', '<C-g>U<Right>', { silent = true })

-- Enter insert mode when switching to terminal
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '',
  command = 'setlocal listchars= nonumber norelativenumber nocursorline',
})
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '',
  command = 'startinsert'
})

