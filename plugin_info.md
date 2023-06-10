================================================================================
# dein.toml
/Users/kentaro/.config/nvim/dein.toml

## [dein.vim](https://github.com/Shougo/dein.vim)
* description: Dark powered Vim/Neovim plugin manager

## [fzf](https://github.com/junegunn/fzf)
* description: fzf.vim用
* purpose: fzf.vim用
* build: ./install

## [fzf.vim](https://github.com/junegunn/fzf.vim)
* description: A command-line fuzzy finder
* hook_add: 
```
  nnoremap <silent> <Leader>f :Files<CR>
  nnoremap <silent> <Leader>b :Buffers<CR>
  nnoremap <silent> <Leader>/ :Lines<CR>
  nnoremap <silent> <Leader>c :Commits<CR>
  nnoremap <silent> <Leader>r :History<CR>
  nnoremap <silent> <Leader>m :Maps<CR>
  nnoremap <silent> <Leader>h :Helptags<CR>

  if has('mac')
    nnoremap <silent> <Leader>g :Rg<CR>
    " dotファイルを含める&プレビュー
    command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'source': 'fd -HI""'}), <bang>0)
  endif

```

## [copilot.vim](https://github.com/github/copilot.vim)
* description: copilotをvimで使う

## [fern.vim](https://github.com/lambdalisue/fern.vim)
* description: 
```
Fern (furn) is a general purpose asynchronous tree viewer written in pure Vim script.
map:
  <C-n>: toggle fern
  -- in fern-window --
  r: reload
  ?: show shortcuts

```
* hook_add: 
```
  nnoremap <silent> <C-n> :Fern . -drawer -toggle -reveal=%<CR>
  function s:init_fern_mapping()
    nmap <buffer> r <Plug>(fern-action-reload:all)
  endfunction
  augroup my-fern-mapping
    autocmd! *
    autocmd FileType fern call s:init_fern_mapping()
  augroup END

```

## [nerdfont.vim](https://github.com/lambdalisue/nerdfont.vim)
* description: It is a fundemental plugin to handle Nerd Fonts from Vim.

## [fern-renderer-nerdfont.vim](https://github.com/lambdalisue/fern-renderer-nerdfont.vim)
* description: fern.vim plugin which add file type icons through lambdalisue/nerdfont.vim.
* depends: ['nerdfont']
* hook_add: 
```
  let g:fern#renderer = "nerdfont"

```

## [fern-git-status.vim](https://github.com/lambdalisue/fern-git-status.vim)
* description: fern-git-status is a fern.vim plugin to add git status on node's badge asynchronously
* depends: ['fern.vim']
* hook_add: 
```
  " Disable listing ignored files/directories
  " let g:fern_git_status#disable_ignored = 1

  " Disable listing untracked files
  " let g:fern_git_status#disable_untracked = 1

  " Disable listing status of submodules
  " let g:fern_git_status#disable_submodules = 1

  " Disable listing status of directories
  " let g:fern_git_status#disable_directories = 1

```

## [fern-mapping-git.vim](https://github.com/lambdalisue/fern-mapping-git.vim)
* description: 
```
fern.vim plugin which add Git related mappings on file:// scheme.
map:
  -- in fern-window --
  >> : stage
  << : unstage

```
* depends: ['fern.vim']

## [fern-mapping-fzf.vim](https://github.com/LumaKernel/fern-mapping-fzf.vim)
* description: 
```
Mapping	Action	Description
ff	fzf-files	Fzf for files
fd	fzf-dirs	Fzf for directories
fa	fzf-both	Fzf for both files and directories
frf	fzf-root-files	Fzf for files from root
frd	fzf-root-dirs	Fzf for directories from root
fra	fzf-root-both	Fzf for both files and directories from root

```
* depends: ['fern.vim', 'fzf.vim']

## [vim-floaterm](https://github.com/voldikss/vim-floaterm)
* description: Use (neo)vim terminal in the floating/popup window.

## [vim-fugitive](https://github.com/tpope/vim-fugitive)
* description: 
```
Fugitive is the premier Vim plugin for Git. Or maybe it's the premier Git plugin for Vim? Either way, it's "so awesome, it should be illegal". That's why it's called Fugitive.
The crown jewel of Fugitive is :Git (or just :G), which calls any arbitrary Git command. If you know how to use Git at the command line, you know how to use :Git. It's vaguely akin to :!git but with numerous improvements:

The default behavior is to directly echo the command's output. Quiet commands like :Git add avoid the dreaded "Press ENTER or type command to continue" prompt.
:Git commit, :Git rebase -i, and other commands that invoke an editor do their editing in the current Vim instance.
:Git diff, :Git log, and other verbose, paginated commands have their output loaded into a temporary buffer. Force this behavior for any command with :Git --paginate or :Git -p.
:Git blame uses a temporary buffer with maps for additional triage. Press enter on a line to view the commit where the line changed, or g? to see other available maps. Omit the filename argument and the currently edited file will be blamed in a vertical, scroll-bound split.
:Git mergetool and :Git difftool load their changesets into the quickfix list.
Called with no arguments, :Git opens a summary window with dirty files and unpushed and unpulled commits. Press g? to bring up a list of maps for numerous operations including diffing, staging, committing, rebasing, and stashing. (This is the successor to the old :Gstatus.)
This command (along with all other commands) always uses the current buffer's repository, so you don't need to worry about the current working directory.
Additional commands are provided for higher level operations:

View any blob, tree, commit, or tag in the repository with :Gedit (and :Gsplit, etc.). For example, :Gedit HEAD~3:% loads the current file as it existed 3 commits ago.
:Gdiffsplit (or :Gvdiffsplit) brings up the staged version of the file side by side with the working tree version. Use Vim's diff handling capabilities to apply changes to the staged version, and write that buffer to stage the changes. You can also give an arbitrary :Gedit argument to diff against older versions of the file.
:Gread is a variant of git checkout -- filename that operates on the buffer rather than the file itself. This means you can use u to undo it and you never get any warnings about the file changing outside Vim.
:Gwrite writes to both the work tree and index versions of a file, making it like git add when called from a work tree file and like git checkout when called from the index or a blob in history.
:Ggrep is :grep for git grep. :Glgrep is :lgrep for the same.
:GMove does a git mv on the current file and changes the buffer name to match. :GRename does the same with a destination filename relative to the current file's directory.
:GDelete does a git rm on the current file and simultaneously deletes the buffer. :GRemove does the same but leaves the (now empty) buffer open.
:GBrowse to open the current file on the web front-end of your favorite hosting provider, with optional line range (try it in visual mode). Plugins are available for popular providers such as GitHub, GitLab, Bitbucket, Gitee, Pagure, Phabricator, Azure DevOps, and sourcehut.

```

## [vim-rhubarb](https://github.com/tpope/vim-rhubarb)
* description: Enables :GBrowse from fugitive.vim to open GitHub URLs.
* depends: ['vim-fugitive']

## [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
* description: A Vim plugin which shows a git diff in the sign column. It shows which lines have been added, modified, or removed. You can also preview, stage, and undo individual hunks; and stage partial hunks. The plugin also provides a hunk text object.

## [vim-sneak](https://github.com/justinmk/vim-sneak)
* description: Jump to any location specified by two characters.
* hook_add: 
```
  map f <Plug>Sneak_f
  map F <Plug>Sneak_F
  map t <Plug>Sneak_t
  map T <Plug>Sneak_T
  map s <Plug>Sneak_s

```

## [vim-highlightedyank](https://github.com/machakann/vim-highlightedyank)
* hook_add: 
```
  let g:highlightedyank_highlight_duration = 350

```

## [vim-sleuth](https://github.com/tpope/vim-sleuth)
* description: ファイル(フォルダ)毎にインデント種を自動判別

## [vim-indent-object](https://github.com/michaeljsmith/vim-indent-object)
* description: 
```
This plugin defines two new text objects. These are very similar - they differ only in whether they include the line below the block or not.

Key bindings	Description
<count>ai	An Indentation level and line above.
<count>ii	Inner Indentation level (no line above).
<count>aI	An Indentation level and lines above/below.
<count>iI	Inner Indentation level (no lines above/below).

```

## [lightline.vim](https://github.com/itchyny/lightline.vim)

================================================================================
# dein_lazy.toml
/Users/kentaro/.config/nvim/dein_lazy.toml

## [async.vim](https://github.com/prabirshrestha/async.vim)
* on_event: BufRead

## [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)
* depends: ['async.vim']
* on_event: BufRead

## [asyncomplete-file.vim](https://github.com/prabirshrestha/asyncomplete-file.vim)
* depends: ['asyncomplete.vim']
* on_event: BufRead

## [asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim)
* depends: ['asyncomplete.vim', 'vim-lsp']
* on_event: BufRead

## [asyncomplete-neosnippet.vim](https://github.com/prabirshrestha/asyncomplete-neosnippet.vim)
* depends: ['asyncomplete.vim', 'neosnippet']
* hook_source: 
```
  call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
      \ 'name': 'neosnippet',
      \ 'allowlist': ['*'],
      \ 'completor': function('asyncomplete                                
      \ }))

```
* on_event: BufRead

## [vim-lsp](https://github.com/prabirshrestha/vim-lsp)
* depends: ['async.vim']
* hook_source: 
```
  let g:lsp_signs_enabled = 1         " enable signs
  let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_diagnostics_virtual_text_enabled = 0
  let g:lsp_diagnostics_float_delay = 400 " default 500
  let g:lsp_signs_error = {'text': '✗'}
  let g:lsp_signs_warning = {'text': '‼'}
  let g:asyncomplete_completion_delay=5

```
* on_event: BufRead

## [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings)
* depends: ['async.vim', 'vim-lsp']
* hook_source: 
```
  nmap <F12> <Plug>(lsp-definition)
  "nmap <silent> <Leader>lj <plug>(lsp-next-diagnostics)
  "nmap <silent> <Leader>lk <plug>(lsp-previous-diagnostics)
  nmap <silent> gs <plug>(lsp-document-diagnostics)
  nmap <silent> g] <plug>(lsp-next-error)
  nmap <silent> g[ <plug>(lsp-previous-error)
  nmap <silent> gd <plug>(lsp-hover)
  nmap <F2> <plug>(lsp-rename)
  nmap <F3> <plug>(lsp-document-format)

```
* on_event: BufRead

## [julia-syntax.vim](https://github.com/ajpaulson/julia-syntax.vim)
* on_ft: julia

## [vim-toml](https://github.com/cespare/vim-toml)
* on_ft: toml

## [neosnippet](https://github.com/Shougo/neosnippet)
* depends: ['neosnippet-snippets']
* hook_source: 
```
  if has('mac')
    let g:neosnippet#snippets_directory="~/.config/nvim/snippets"
  endif
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <C-k> <Plug>(neosnippet_expand_target)
  if has('conceal')
    set conceallevel=0 concealcursor=niv
  endif

```
* on_event: BufRead

## [neosnippet-snippets](https://github.com/Shougo/neosnippet-snippets)
* on_event: BufRead

## [vim-lsp-snippets](https://github.com/thomasfaingnaert/vim-lsp-snippets)
* on_event: BufRead

## [vim-lsp-neosnippet](https://github.com/thomasfaingnaert/vim-lsp-neosnippet)
* on_event: BufRead

## [vim-sonictemplate](https://github.com/mattn/vim-sonictemplate)
* depends: ['neosnippet']
* hook_source: 
```
  if has('mac')
    let g:sonictemplate_vim_template_dir = '~/.config/nvim/sonictemplate'
  endif

```
* on_event: BufRead

## [lexima.vim](https://github.com/cohama/lexima.vim)
* hook_source: 
```
  inoremap <C-l> <C-g>U<Right>

```
* on_event: BufRead

## [vim-commentary](https://github.com/tpope/vim-commentary)
* description: toggle comment with gc
* on_event: BufRead

## [vim-surround](https://github.com/tpope/vim-surround)
* on_event: BufRead

## [vim-speeddating](https://github.com/tpope/vim-speeddating)
* on_event: BufRead

## [vim-repeat](https://github.com/tpope/vim-repeat)
* on_event: BufRead

