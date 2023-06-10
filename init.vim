filetype off
filetype plugin indent off

let mapleader = "\<Space>"

set runtimepath+=~/workspace/my_date_plugin
lua require('my_date_plugin')
command! InsertDateTime lua require('my_date_plugin').insert_date_time()

" ---------------------------------------------------------------
" dein setting
" ---------------------------------------------------------------
if &compatible
  set nocompatible
endif

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  let s:toml_dir = expand('~/.config/nvim')

  call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/dein_lazy.toml', {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
" ---------------------------------------------------------------
" default setting
" ---------------------------------------------------------------
set noswapfile
set nowrap
set number
set cursorline
set incsearch
set hlsearch
set wrap
set showmatch
set matchtime=1
set whichwrap=h,l
set nowrapscan
set ignorecase
set smartcase
set hidden
set autoindent
set history=2000
set helplang=en

nnoremap Y y$
nnoremap <silent> <esc><esc> :nohlsearch<CR>
" move window

imap <C-d> <Del>

" use clipboard <Leader> + ~
nmap <Leader>y "+y
nmap <Leader>Y "+y$
nmap <Leader>p "+p
vmap <Leader>y "+y
vmap <Leader>p "+p

" function! YankLine(with_file_name, excel) abort
"     if a:excel == 1
"       if a:with_file_name == 1
"         let @+ = buffer_name() . ":,\n,L" . line(".")
"       else
"         let @+ = ",L" . line(".")
"       endif
"     else
"       if a:with_file_name == 1
"         let @+ = buffer_name() . " L" . line(".")
"       else
"         let @+ = "L" . line(".")
"       endif
"     endif
" endfunction
" function! YankRange(with_file_name, excel) abort range
"     if a:excel == 1
"       if a:with_file_name == 1
"         let @+ = buffer_name() . ":,\n,L" . a:firstline . "-L" . a:lastline
"       else
"         let @+ = ",L" . a:firstline . "-L" . a:lastline
"       endif
"     else
"       if a:with_file_name == 1
"         let @+ = buffer_name() . " L" . a:firstline . "-L" . a:lastline
"       else
"         let @+ = "L" . a:firstline . "-L" . a:lastline
"       endif
"     endif
" endfunction
" command! -range YankRange <line1>,<line2>call YankRange()
" nnoremap <silent> <Leader>l :call YankLine(1, 0)<CR>
" nnoremap <silent> <Leader>ef :call YankLine(1, 1)<CR>
" nnoremap <silent> <Leader>el :call YankLine(0, 1)<CR>
" vnoremap <silent> <Leader>l :call YankRange(1, 0)<CR>
" vnoremap <silent> <Leader>ef :call YankRange(1, 1)<CR>
" vnoremap <silent> <Leader>el :call YankRange(0, 1)<CR>

" kill buffer
nnoremap <silent> <Leader>k :bd<CR>

" ---------------------------------------------------------------
" color scheme (and lightline)
" ---------------------------------------------------------------
set termguicolors
set laststatus=2

colorscheme hybrid

" ---------------------------------------------------------------
syntax on
filetype plugin indent on

