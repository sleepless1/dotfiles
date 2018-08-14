""  Pathogen plugin manager
set nocp
execute pathogen#infect()
syntax on
filetype plugin indent on

"" Styling
colorscheme minimalist

"" Vim behavior

" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Wrap text to 120 chars
set textwidth=120

" Enable the mouse
set mouse=a

" Format the status line
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

" Ensure staff users .vim directory is always used
let s:configdir = '$CONST_HOME/.vim'
"let &runtimepath = printf('%s/vimfiles,%s,%s/vimfiles/after,%s,%s/after', $VIM, $VIMRUNTIME, $VIM, s:configdir, s:configdir)

"" Keybindings

" pastetoggle fixes overzealous indentation when pasting code-blocks
set pastetoggle=<F10>
" Toggle taglist
map <F3> :TlistToggle<CR>
" Toggle line numbers
map <F5> :set number!<CR><Esc>

"" File operations

" Load templates
autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template

" Automatic compilation check for perl files.
autocmd BufWritePost *.pm,*.t,*.pl,*.PL echom system("perl -I/usr/pair/perl/lib -c " . expand('%:p'))

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Set some language specific options

" Tabspacing of 2 for HTML or Mason templates
autocmd FileType html  setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType mason setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
