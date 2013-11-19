set nocompatible " use vi improved!
set shell=/bin/bash
set t_Co=16

" config for vundle
filetype on
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Open bundle config file
if filereadable(expand("~/.vimrc.bundles"))
	source ~/.vimrc.bundles
endif

" use a dark background
set background=dark

filetype plugin indent on
"Automatically detect filetypes
syntax on
"syntax highlighting

set encoding=utf-8
scriptencoding utf-8

set clipboard=unnamedplus
"use + register for copy/paste

set shortmess+=filmnrxoOtT
"abbreviate messages (no 'hit enter')
set virtualedit=onemore
"allow for cursor beyond last character
set history=1000
"save lots of history!
set spell
"turn on spellcheck
set hidden
"allow buffer switching without saving

au Filetype gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
"put cursort at first line when editing a git commit message

function! ResCur()
	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction

augroup resCur
	autocmd!
	autocmd! BufWinEnter * call ResCur()
augroup END

"put cursor at old position when file is opened

set backup
if has('persistent_undo')
	set undofile
	set undolevels=1000
	" maximum number of changes that can be undone
	set undoreload=10000
	" maximum number lines to save for undo on a buffer reload
endif

let g:solarized_termcolors=16
let g:solarized_contrast="normal"
let g:solarized_visibility="normal"
let g:solarized_termtrans=1
color solarized

"set showmode
"display current mode

set cursorline
"highlight current line

"highlight clear SignColumn
"SignColumn should match background for things like vim-gitgutter

"highlight clear LineNr
"Current line number row will have same background color in relative mode. Things like vim-gitgutter with match linenr highlight

set ruler
"show ruler
set rulerformat="%30(%-\:b%n%y%m%r%w\ %l,%c%V\ %P%)

set laststatus=2

set statusline=%<%f\	
"filename
set statusline+=%w%h%m%r
"options
set statusline+=%{fugitive#statusline()}
"git info
set statusline+=\ [%{&ff}/%Y]
"filetype
set statusline+=\ [%{getcwd()}]
"current dir
set statusline+=%=%-14.(%l,%c%V%)\ %p%%
"right-aligned file nav info

set backspace=indent,eol,start
"backspace works for everything
set nu
"linenumbers
set showmatch
"show matching brackets
set incsearch
"show incremental search
set hlsearch
"highlight search terms
set ignorecase
"case insensitive search
set smartcase
"case sensitive when uppercase present
set wildmenu
"shows little menu for completion
set wildmode=list:longest,full
set scrolljump=5
"lines to scroll when cursor leaves screen
set scrolloff=3
"minimum lines to keep above and below cursor

set autoindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
" tabs are tabs, not space
set noexpandtab
"not quite sure what this does
set nojoinspaces
set splitright
" puts new windows below and to the right
set splitbelow

" remove trailing whitespace
autocmd FileType c,cpp,java,go,php,javascript,python,twig,xml,yml autocmd BufWritePre <buffer> call StripTrailingWhitespace()

let mapleader=',' "set leader key to ,

" move between windows with C-...
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

" Wrapped lines goes down/up to next row, rather than next line in file.
noremap j gj
noremap k gk

" Same for 0, home, end, etc
noremap $ g$
noremap <End> g<End>
noremap 0 g0
noremap <Home> g<Home>
noremap ^ g^

"remove search highlighting
nmap <leader>/ :set invhlsearch<CR>

"find merge conflict markers
map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

"visual shifting
vnoremap < <gv
vnoremap > >gv

"allows using the repeat operator in visual mode
vnoremap . :normal .<CR>

"For when you forgot to sudo... Write the file
cmap w!! w !sudo tee % >/dev/null

" Adjust viewports to the same size
map <Leader>= <C-w>=

let g:airline_theme='powerlineish'
let g:airline_powerline_fonts=1
let g:airline_theme='solarized'


" UnBundle {
function! UnBundle(arg, ...)
	let bundle = vundle#config#init_bundle(a:arg, a:000)
	call filter(g:bundles, 'v:val["name_spec"] != "' . a:arg . '"')
endfunction

com! -nargs=+		  UnBundle
\ call UnBundle(<args>)
" }

" Initialize directories {
function! InitializeDirectories()
	let parent = $HOME
	let prefix = 'vim'
	let dir_list = {
				\ 'backup': 'backupdir',
				\ 'views': 'viewdir',
				\ 'swap': 'directory' }

	if has('persistent_undo')
		let dir_list['undo'] = 'undodir'
	endif

	" To specify a different directory in which to place the vimbackup,
	" vimviews, vimundo, and vimswap files/directories, add the following to
	" your .vimrc.before.local file:
	"	let g:spf13_consolidated_directory = <full path to desired directory>
	"	eg: let g:spf13_consolidated_directory = $HOME . '/.vim/'
	if exists('g:spf13_consolidated_directory')
		let common_dir = g:spf13_consolidated_directory . prefix
	else
		let common_dir = parent . '/.' . prefix
	endif

	for [dirname, settingname] in items(dir_list)
		let directory = common_dir . dirname . '/'
		if exists("*mkdir")
			if !isdirectory(directory)
				call mkdir(directory)
			endif
		endif
		if !isdirectory(directory)
			echo "Warning: Unable to create backup directory: " . directory
			echo "Try: mkdir -p " . directory
		else
			let directory = substitute(directory, " ", "\\\\ ", "g")
			exec "set " . settingname . "=" . directory
		endif
	endfor
endfunction
call InitializeDirectories()
" }

" Initialize NERDTree as needed {
function! NERDTreeInitAsNeeded()
	redir => bufoutput
	buffers!
	redir END
	let idx = stridx(bufoutput, "NERD_tree")
	if idx > -1
		NERDTreeMirror
		NERDTreeFind
		wincmd l
	endif
endfunction
" }

" Strip whitespace {
function! StripTrailingWhitespace()
	" Preparation: save last search, and cursor position.
	let _s=@/
	let l = line(".")
	let c = col(".")
	" do the business:
	%s/\s\+$//e
	" clean up: restore previous search history, and cursor position
	let @/=_s
	call cursor(l, c)
endfunction
" }

" Shell command {
function! s:RunShellCommand(cmdline)
	botright new

	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal nobuflisted
	setlocal noswapfile
	setlocal nowrap
	setlocal filetype=shell
	setlocal syntax=shell

	call setline(1, a:cmdline)
	call setline(2, substitute(a:cmdline, '.', '=', 'g'))
	execute 'silent $read !' . escape(a:cmdline, '%#')
	setlocal nomodifiable
	1
endfunction

command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
" e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %

map <C-e> :NERDTreeToggle<CR>

