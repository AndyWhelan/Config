" Basic Settings {{{
set number "                                                  Line numbers at side
set colorcolumn=90 "                                          Neatness purposes
set tabstop=4 shiftwidth=4 smarttab expandtab shiftround "    Indentation
set incsearch hlsearch "                                      Search options
inoremap jk <Esc>"                                            Remap nav keys
"}}}
" .tex {{{
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
    autocmd FileType tex inoremap <buffer> <expr> $ "\$$\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> $ "\$$\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \( "\\( \\)\<Esc>F(a "
    autocmd FileType tex inoremap <buffer> <expr> \addcon "\\addcontentsline{toc}{section}{}\<Esc>k$F{yi{j$F{p"
    autocmd FileType tex inoremap <buffer> <expr> \coordin "\\coordinate () at ();\<Esc>^f(a"
    autocmd FileType tex inoremap <buffer> <expr> \doc "\\documentclass{}\<Esc>F{a"
    autocmd FileType tex inoremap <buffer> <expr> \frac "\\frac{}{}\<Esc>ba"
    autocmd FileType tex inoremap <buffer> <expr> \href "\\href{}{}\<Esc>F{F{a"
    autocmd FileType tex inoremap <buffer> <expr> \lab "\\label{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \left( "\\left( \\right)\<Esc>F(a "
    autocmd FileType tex inoremap <buffer> <expr> \sec* "\\section\*{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \sect "\\section{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \subsec* "\\subsection\*{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \subsect "\\subsection{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \subsubsec* "\\subsubsection\*{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \subsubsect "\\subsubsection{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> \textsub "\\textsubscript{}{}<Esc>ba"
    autocmd FileType tex inoremap <buffer> <expr> \textsuper "\\textsuperscript{}{}<Esc>ba"
    autocmd FileType tex inoremap <buffer> <expr> \tikzm "\\tikzmath{\<CR>}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> \tikzs "\\tikzset{\<CR>}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> \usep "\\usepackage{}\<Esc>F{a"
    autocmd FileType tex inoremap <buffer> <expr> \verb "\\verb\|\|\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> ^ "^{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> eqref "eqref{}\<Esc>i"
    autocmd FileType tex inoremap <buffer> <expr> newp "newpage\<CR>"
    autocmd FileType tex inoremap <buffer> <expr> {Bm "{Bmatrix}\<CR>\\end{Bmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {Vm "{Vmatrix}\<CR>\\end{Vmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {al* "{align*}\<CR>\\end{align*}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {ali "{align}\<CR>\\end{align}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {bm "{bmatrix}\<CR>\\end{bmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {cen "{center}\<CR>\\end{center}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {desc "{description}\<CR>\\end{description}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {do "{document}\<CR>\\end{document}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {eq "{equation}\<CR>\\end{equation}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {iv keystemh "{iv keystemize}\<CR>\\end{iv keystemize}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {ma "{matrix}\<CR>\\end{matrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {pm "{pmatrix}\<CR>\\end{pmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {smallm "{smallmatrix}\<CR>\\end{smallmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {sube "{subequations}\<CR>\\end{subequations}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {tabu "{tabular}\<CR>\\end{tabular}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> <expr> {vm "{vmatrix}\<CR>\\end{vmatrix}\<Esc>==kyypd$a\<TAB>"
    autocmd FileType tex inoremap <buffer> \be \begin
    autocmd FileType tex nnoremap ,b :call SplitAtLastWordAndMove()<CR>
    autocmd FileType tex setlocal foldmethod=marker
    autocmd FileType tex setlocal foldmarker=%<,%>
augroup END
"}}}
" .vim {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
"}}}
