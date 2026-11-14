set nocompatible
let mapleader = " "
syntax on
filetype plugin indent on
set laststatus=2
set number relativenumber
set scrolloff=999 sidescrolloff=20
setglobal fileencoding=utf-8
set wildmenu wildignore=*.o,*.a,*.la,*.lo,*.swp,.svn,.git
set showcmd
set hlsearch ignorecase smartcase
set backspace=indent,eol,start whichwrap=b,s,<,>
set shiftwidth=8 softtabstop=8 expandtab autoindent
set confirm
set mouse=a
set spelllang=de,en
set notimeout ttimeout ttimeoutlen=5

exec system("mkdir -p ~/.vim/swapfiles ~/.vim/backupfiles ~/.vim/undofiles ~/.vim/spell")
set dir=~/.vim/swapfiles
set bdir=~/.vim/backupfiles
set udir=~/.vim/undofiles

set noshowmode
let g:lightline = {
\       'colorscheme': 'powerlineish',
\       'active': {
\               'left': [ [ 'mode', 'paste' ],
\                       [ 'readonly', 'filename', 'modified' ] ],
\       },
\}

colorscheme pitch_black

let g:rainbow#max_level = 256
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
autocmd FileType * RainbowParentheses

" better indent/dedent bindings
vnoremap < <gv
vnoremap > >gv

map <Leader>f :Neoformat<CR>
" TODO: config neoformat
let g:neoformat_enabled_markdown = ['denofmt']
let g:neoformat_enabled_typescript = ['prettierd']

autocmd BufEnter *.adn setfiletype clojure

let g:vmt_fence_text = "toc"
let g:vmt_fence_closing_text = "toc"
let g:vmt_list_item_char = "-"

map <Leader>c "+y
map <Leader>v "+P

" disables search highlighting until the next search is issued
map <Leader>s :nohl<CR><C-L>

" TODO: go up the dir hierarchy

" TODO: some asking maybe
map <Leader>t :w<CR>:make test<CR>
map <Leader>x :w<CR>:make<CR>
map <Leader>r :w<CR>:make run<CR>
map <Leader>i :w<CR>:make install<CR>

if(filereadable("Smfile"))
        set makeprg=sm
endif

if(filereadable("Justfile"))
        set makeprg=just
endif

if(filereadable("pack.toml"))
        autocmd BufWritePost * !packwiz refresh
endif

autocmd BufEnter *.rs set makeprg=cargo
autocmd BufEnter *.rs map <Leader>x :w<CR>:!cargo build<CR>

autocmd BufEnter *.swift let &makeprg = 'PATH=/usr/bin swift'
autocmd BufEnter *.swift map <Leader>x :w<CR>:!PATH=/usr/bin swift build<CR>

autocmd BufEnter *.hs set makeprg=cabal
autocmd BufEnter *.hs map <Leader>x :w<CR>:!cabal build<CR>

autocmd BufEnter *.roc set makeprg=roc
autocmd BufEnter *.roc map <Leader>x :w<CR>:!roc build<CR>

autocmd BufEnter *.js map <Leader>x :w<CR>:!npm run build<CR>
autocmd BufEnter *.js map <Leader>t :w<CR>:!npm run test<CR>
autocmd BufEnter *.js map <Leader>i :w<CR>:!npm install 
autocmd BufEnter *.ts map <Leader>x :w<CR>:!npm run build<CR>
autocmd BufEnter *.ts map <Leader>t :w<CR>:!npm run test<CR>
autocmd BufEnter *.ts map <Leader>i :w<CR>:!npm install 

autocmd BufEnter *.md map <Leader>t :w<CR>:!pandoc '%' -o `echo '%' \| sed 's/\.md$/.pdf/'` && `type xdg-open >/dev/null && echo xdg-open \|\| echo open` `echo '%' \| sed 's/\.md$/.pdf/'`<CR>

autocmd BufEnter *.tex map <Leader>t :w<CR>:!pdflatex '%' && `type xdg-open >/dev/null && echo xdg-open \|\| echo open` `echo '%' \| sed 's/\.tex$/.pdf/'`<CR>

autocmd BufEnter *.scad map <Leader>t :w<CR>:!OPENSCADPATH=lib openscad '%' -o `echo '%' \| sed 's/\.scad$/.stl/'` && `type xdg-open >/dev/null && echo xdg-open \|\| echo open` `echo '%' \| sed 's/\.scad$/.stl/'`<CR>

autocmd BufEnter *.svg map <Leader>t :w<CR>:!`type xdg-open >/dev/null && echo xdg-open \|\| echo open` '%'<CR>

map <Leader>z :set spell<CR><C-L>
map <Leader>Z :set nospell<CR><C-L>

autocmd FileType gitcommit :set spell
autocmd FileType markdown :set spell

map <Leader>bn :bnext<CR><C-L>
map <Leader>bp :bprevious<CR><C-L>
map <Leader>bk :bdelete<CR><C-L>

imap <C-k> <Esc>lC

vmap J :m >+1<CR>gv=gv
vmap K :m <-2<CR>gv=gv
