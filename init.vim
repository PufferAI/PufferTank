call plug#begin('~/.config/nvim/plugged')

Plug 'github/copilot.vim'
Plug 'wookayin/semshi', { 'do': ':UpdateRemotePlugins' }

call plug#end()

"" Crazy things to make this all work: you need node (curl from website latest), manually pip update greenlet and pynvim, :UpdatePlugins :UpdateRemotePlugins

set nocompatible

" Not sure if I want line numbers
"set number
set signcolumn=yes

set clipboard=unnamedplus

set tabstop=4
set shiftwidth=4
set expandtab

set path+=**
set wildmenu
command! MakeTags !ctags -R .

let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3

""Colorscheme
set termguicolors

" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Maintainer:   Ron Aaron <ron@ronware.org>
" Last Change:  2003 May 02

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "elflord"
hi Normal                                               guifg=Cyan guibg=#061a1a
hi SignColumn                                                      guibg=#061a1a
hi Comment      term=bold       ctermfg=Cyan            guifg=White
hi Constant     term=underline  ctermfg=Cyan            guifg=White
hi Special      term=bold       ctermfg=Red             guifg=Blue
hi Identifier   term=underline  cterm=bold ctermfg=Cyan guifg=Blue
hi Statement    term=bold       ctermfg=Yellow gui=bold guifg=Red
hi PreProc      term=underline  ctermfg=LightBlue       guifg=Red
hi Type         term=underline  ctermfg=LightGreen      guifg=Red gui=bold
hi Function     term=bold       ctermfg=White           guifg=White
hi Repeat       term=underline  ctermfg=White           guifg=Red
hi Operator                     ctermfg=Red             guifg=Red
hi Ignore                       ctermfg=black           guifg=bg
hi Error        term=reverse ctermbg=Red ctermfg=White  guibg=Red guifg=#ff0000
hi Todo term=standout ctermbg=Yellow ctermfg=Black guifg=Black guibg=Yellow gui=bold
hi LineNr ctermfg=Blue guifg=Blue

hi ParenHighlight ctermfg=magenta guifg=Blue
match ParenHighlight /[\\\.\,\+\-\*\=(){}\[\]]/


" Common groups that link to default highlighting.
" You can specify other highlighting easily.
hi link String  Constant
hi link Character       Constant
hi link Number  Constant
hi link Boolean Constant
hi link Float           Number
hi link Conditional     Repeat
hi link Label           Statement
hi link Keyword Statement
hi link Exception       Statement
hi link Include PreProc
hi link Define  PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef Type
hi link Tag             Special
hi link SpecialChar     Special
hi link Delimiter       Special
hi link SpecialComment Special
hi link Debug           Special

syntax enable
filetype plugin on


let g:semshi#excluded_hl_groups = ['local', 'global', 'free', 'attribute']

function MyCustomHighlights()
    hi semshiImported        ctermfg=214 guifg=Gray cterm=bold gui=bold
    hi semshiParameter       ctermfg=75  guifg=DarkCyan
    hi semshiParameterUnused ctermfg=117 guifg=DarkCyan cterm=underline gui=underline
    hi semshiBuiltin         ctermfg=207 guifg=LightGray
    hi semshiSelf            ctermfg=249 guifg=DarkGreen
    hi semshiUnresolved      ctermfg=226 guifg=#ffff00 cterm=underline gui=underline
    hi semshiSelected        ctermfg=231 guifg=Green ctermbg=161 guibg=#061a1a gui=bold

    hi semshiErrorSign       ctermfg=231 guifg=Yellow ctermbg=160 guibg=#061a1a
    hi semshiErrorChar       ctermfg=231 guifg=Yellow ctermbg=160 guibg=#061a1a
    sign define semshiError text=E texthl=semshiErrorSign
endfunction
autocmd FileType python call MyCustomHighlights()
