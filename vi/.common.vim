" Logging {{{
command! LogStart redir! > $HOME/vimlog.txt
command! LogContinue redir! >> $HOME/vimlog.txt
command! LogStop redir END
function! IsFileInBuffers(filename) abort
   " Iterate over all buffers
   for buf in range(1, bufnr('$'))
      if bufloaded(buf)
         " Get full path of buffer's file
         let bufname = bufname(buf)
         " Compare with target filename (full path recommended)
         if fnamemodify(bufname, ':p') ==# fnamemodify(a:filename, ':p')
            return 1  " Found the file in a buffer
         endif
      endif
   endfor
   return 0  " File not found in any loaded buffer
endfunction
function! s:MaybeStartLog()
   "if expand('%:p') !=# expand('$HOME/vimlog.txt')
   if !IsFileInBuffers('$HOME/vimlog.txt')
      LogStart
   endif
endfunction
function! s:MaybeContinue()
   if expand('%:p') ==# expand('$HOME/vimlog.txt')
      LogContinue
   endif
endfunction
augroup log_settings
   autocmd!
   autocmd VimEnter * call s:MaybeStartLog()
   autocmd BufReadPre,BufNewFile $HOME/vimlog.txt LogStop
   autocmd WinClosed * call s:MaybeContinue()
   autocmd VimLeave * LogStop
augroup END
"  }}}
"  System settings {{{
:if filereadable( "/etc/vimrc" )
   source /etc/vimrc
:endif
"   }}}   
"  Arista-specific settings {{{
:if filereadable( $VIM . "/vimfiles/arista.vim" )
   source $VIM/vimfiles/arista.vim
:elseif filereadable( $HOME . "/.vim/vimfiles/arista.vim" )
   source $HOME/.vim/vimfiles/arista.vim
:endif
"  }}}
" Plugins {{{
" Initialize vim-plug
call plug#begin('~/.vim/plugged')
" Add your plugins here, for example:
" Plug 'wannesm/wmgraphviz.vim'
Plug 'morhetz/gruvbox'
" Plug 'tpope/vim-fugitive'
if has( 'nvim' )
   Plug 'nvim-lualine/lualine.nvim'
   Plug 'nvim-tree/nvim-web-devicons'
   Plug 'neovim/nvim-lspconfig'
   Plug 'hrsh7th/nvim-cmp'
   Plug 'hrsh7th/cmp-nvim-lsp'
   Plug 'hrsh7th/cmp-buffer'
   Plug 'hrsh7th/cmp-path'
   Plug 'onsails/ls'
   Plug 'onsails/lspkind.nvim'
   Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif
call plug#end()
"  }}}
" Global personalized settings {{{
" Default fallback for all buffers {{{
augroup default_fallback_settings
   autocmd!
   autocmd BufReadPre,BufNewFile,VimEnter * call s:setup_default_fallback_settings()
   "autocmd BufReadPre,BufNewFile * call s:setup_default_fallback_settings()
augroup END
function! s:insert_fold_marker()
   if stridx(&l:formatoptions, 'o') == -1 | let b:line_continue_edit = b:comment | else | let b:line_continue_edit='' | endif 
   let l:to_print = b:comment . '  ' . b:marker_start . "\n" . b:line_continue_edit . b:marker_end
   call feedkeys( l:to_print, 'in' )
endfunction
function! s:setup_default_fallback_settings() abort
   if !exists('b:comment') | let b:comment = '#' | endif
   if !exists('b:marker_start') | let b:marker_start = '{{{' | endif
   if !exists('b:marker_end') | let b:marker_end = '}}}' | endif
   let l:sid = matchstr(expand('<sfile>'), '<SNR>\d\+_')
   " Build the mapping string with proper escaping
   let l:map = '<C-o>:setlocal foldmethod=manual<CR>'
   let l:map .= '<C-o>:call ' . l:sid . 'insert_fold_marker()<CR>'
   let l:map .= "\<Esc>ki"
   let l:map .= '<C-o>:setlocal foldmethod=marker<CR>'
   let l:map .= "\<Esc>za0f{hi"
   " Define the buffer-local insert-mode mapping
   execute 'inoremap <buffer> <localleader>mf ' . l:map
   setlocal foldenable foldmethod=marker
endfunction
" }}}
" Other {{{
" Remap <Space> to <C-w>
nnoremap <Space> <C-w>
"" Remap 'o' to modify behavior based on whether we're inside a fold
"nnoremap o :<C-U>call FoldCheck()<CR>i
"function! FoldCheck()
"    let l:inside_fold = foldclosed(line('.')) != -1
"    normal! o
"    if l:inside_fold            " There'll be parenthesis. Delete.
"        normal! cc
"    endif
"endfunction
syntax on
set scrolloff=999 " so that redraws scrolling in middle of buffer
set cursorline
set mouse= " don't use mouse for highlighting etc.
set background=dark
filetype plugin indent on
augroup common_shellfile_syntax
   autocmd!
   autocmd BufRead,BufNewFile ~/.common_rc set filetype=sh
augroup END
let mapleader="," | let maplocalleader="\\"
set number colorcolumn=85
colorscheme gruvbox
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" Copy selected lines or complete file to Arista pb (http://pb/)
command! -range=% Pb :<line1>,<line2>w !curl -F c=@- pb
"

" Remap jk to <Esc>
inoremap jk <Esc>
vnoremap jk <Esc>
"  }}}
"  }}}
" .dot settings {{{
augroup dot_settings
   autocmd!
   autocmd BufRead,BufNewFile *.dot call s:setup_dot()
augroup END
function! s:setup_dot() abort
   " Folds
   let b:comment="//"
   set filetype=dot
endfunction "  }}}
" .md settings {{{
augroup markdown_settings
   autocmd!
   autocmd FileType markdown call s:setup_markdown()
augroup END
function! s:setup_markdown() abort
   " Folds
   let b:comment="<!--  -->"
   inoremap <buffer> <localleader>mf <!-- {{{  --><CR><!-- }}} --><Esc>k$F{la
   " Insert image (figure)
   inoremap <buffer> <localleader>f ![]()<Esc>F[a
   " Insert bold/italic
   inoremap <buffer> <localleader>b ****<Esc>hi
   inoremap <buffer> <localleader>i __<Esc>i
   " Blockquote and horizontal rule
   inoremap <buffer> <localleader>bq > <Space>
   inoremap <buffer> <localleader>hr ---<CR><CR>
   " Headings
   inoremap <buffer> <localleader>h1 # <Esc>A
   inoremap <buffer> <localleader>h2 ## <Esc>A
   inoremap <buffer> <localleader>h3 ### <Esc>A
   inoremap <buffer> <localleader>h4 #### <Esc>A
   inoremap <buffer> <localleader>h5 ##### <Esc>A
   inoremap <buffer> <localleader>h6 ###### <Esc>A
   " Code (inline and block)
   inoremap <buffer> <localleader>ci ``<Left>
   inoremap <buffer> <localleader>cb ```<CR>```<Esc>kA
   " Links
   inoremap <buffer> <localleader>l []()<Esc>F[ci[
   inoremap <buffer> <localleader>bb <Esc>ciwBUG[<Esc>pa](https://bb/<Esc>pa)
   inoremap <buffer> <localleader>cl <Esc>ciwcl[<Esc>pa](https://cl/<Esc>pa)
   "inoremap <buffer> <localleader>og <Esc>ciw[`<Esc>pa`](https://opengrok.infra.corp.arista.io/source/xref/eos-trunk/src/<Esc>pa)
   inoremap <buffer> <localleader>og <Esc>v?[a-zA-Z\./]\+<CR>c[`<Esc>pa`](https://opengrok.infra.corp.arista.io/source/xref/eos-trunk/src/<Esc>pa)<Esc>:nohlsearch<CR>a
endfunction "  }}}
" .py settings {{{
let g:python_recommended_style = 0 " Override default settings for .py files
augroup py_settings
   autocmd!
   autocmd FileType python nnoremap <buffer> <localleader>c $i# 
   autocmd FileType python inoremap <buffer> <localleader>c # 
augroup END "  }}}
" .tex settings {{{
" Set ,b to do go to the colorcolumn and then go on a new line with indentation
function! SplitAtLastWordAndMove()
    "let col = empty(&colorcolumn) ? 80 : split(&colorcolumn, ',')[0]
    let col = split(&colorcolumn, ',')[0]
    if col < strlen(getline('.'))
        " Step 1: Move to colorcolumn, then to start of last space
        execute 'normal! ' . col . "\<Bar>F "
        " Step 2: Simulate pressing i<CR> to split the line and enter insert mode, then
        " align
        call feedkeys("i\<CR>\<ESC>kyypj^d$k^hpld$jddk", 'n')
    else
        echo "Line shorter than colorcolumn (" . col . ") — nothing done."
    endif
endfunction

augroup tex_remaps
    autocmd!
    autocmd BufNewFile *.tex 0r ~/.vim/templates/skeleton.tex
    autocmd FileType tex setlocal textwidth=85
    autocmd FileType tex setlocal omnifunc=vimtex#omnifunc
    "autocmd FileType tex inoremap <buffer> <expr> $ "\$$\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> $ "\$$\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \( "\\( \\)\<Esc>F(a "
    "autocmd FileType tex inoremap <buffer> <expr> \addcon "\\addcontentsline{toc}{section}{}\<Esc>k$F{yi{j$F{p"
    "autocmd FileType tex inoremap <buffer> <expr> \coordin "\\coordinate () at ();\<Esc>^f(a"
    "autocmd FileType tex inoremap <buffer> <expr> \doc "\\documentclass{}\<Esc>F{a"
    "autocmd FileType tex inoremap <buffer> <expr> \frac "\\frac{}{}\<Esc>ba"
    "autocmd FileType tex inoremap <buffer> <expr> \href "\\href{}{}\<Esc>F{F{a"
    "autocmd FileType tex inoremap <buffer> <expr> \lab "\\label{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \left( "\\left( \\right)\<Esc>F(a "
    "autocmd FileType tex inoremap <buffer> <expr> \sec* "\\section\*{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \sect "\\section{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \subsec* "\\subsection\*{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \subsect "\\subsection{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \subsubsec* "\\subsubsection\*{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \subsubsect "\\subsubsection{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> \textsub "\\textsubscript{}{}<Esc>ba"
    "autocmd FileType tex inoremap <buffer> <expr> \textsuper "\\textsuperscript{}{}<Esc>ba"
    "autocmd FileType tex inoremap <buffer> <expr> \tikzm "\\tikzmath{\<CR>}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> \tikzs "\\tikzset{\<CR>}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> \usep "\\usepackage{}\<Esc>F{a"
    "autocmd FileType tex inoremap <buffer> <expr> \verb "\\verb\|\|\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> ^ "^{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> eqref "eqref{}\<Esc>i"
    "autocmd FileType tex inoremap <buffer> <expr> newp "newpage\<CR>"
    "autocmd FileType tex inoremap <buffer> <expr> {Bm "{Bmatrix}\<CR>\\end{Bmatrix}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {Vm "{Vmatrix}\<CR>\\end{Vmatrix}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {al* "{align*}\<CR>\\end{align*}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {ali "{align}\<CR>\\end{align}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {bm "{bmatrix}\<CR>\\end{bmatrix}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {cen "{center}\<CR>\\end{center}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {desc "{description}\<CR>\\end{description}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {do "{document}\<CR>\\end{document}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {eq "{equation}\<CR>\\end{equation}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {iv keystemh "{iv keystemize}\<CR>\\end{iv keystemize}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {ma "{matrix}\<CR>\\end{matrix}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {pm "{pmatrix}\<CR>\\end{pmatrix}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {smallm "{smallmatrix}\<CR>\\end{smallmatrix}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {sube "{subequations}\<CR>\\end{subequations}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {tabu "{tabular}\<CR>\\end{tabular}\<Esc>==kyypd$a\<TAB>"
    "autocmd FileType tex inoremap <buffer> <expr> {vm "{vmatrix}\<CR>\\end{vmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> \be \begin
    autocmd FileType tex nnoremap ,b :call SplitAtLastWordAndMove()<CR>
    autocmd FileType tex let b:comment="\%"
augroup END
"}}}
" .vimrc settings {{{
augroup vimrc_settings
   autocmd!
   autocmd BufRead,BufNewFile *.vim* call s:setup_vimrc()
augroup END
function! s:setup_vimrc() abort
   " Folds
   let b:comment = '"'
   inoremap <buffer> <localleader>tr echomsg ""<Esc>i
endfunction " }}}
