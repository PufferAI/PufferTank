filetype plugin indent on
set nocompatible

set tabstop=4
set shiftwidth=4
set expandtab

syntax enable
filetype plugin on

" Search down into subfolders
set path+=**

" Display all matching files when we tab complete
set wildmenu

" Create the tags file (may need to install ctags first)
command! MakeTags !ctags -R .

" Tweaks for browsing
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',(^|\s\s)\zs.\S+'