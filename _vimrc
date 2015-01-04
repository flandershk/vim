source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/mswin.vim
"behave mswin

"===================================================
" regular configuration
"===================================================
filetype plugin indent on
set fileformats=unix,dos
set nobackup
set nowritebackup
"set noswapfile
"set columns=90
set nocompatible
set autochdir
set t_Co=256
set background=dark

if has('gui_running')
    "set guioptions-=M
    "set guioptions-=r
    "set guioptions-=L
    set guioptions-=T
    set guioptions-=m
    " default font and size.
    "set guifont=Monaco:h12:cANSI
    "set guifont=Monospace:h12:cANSI
    "set guifont=Inconsolata:h14:cANSI
    "set guifont=Microsoft_YaHei_Mono:b:h12
    "set guifont=Lucida_Console:h12:b:cANSI
    "set guifont=Lucida_Sans_Typewriter:h12:cANSI
    set guifont=Consolas:h12:b:cANSI
    "set guifont=Consolas:h12:cANSI
    "set guifont=Bitstream_Vera_Sans_Mono:h12:cANSI
    "set guifont=Droid_Sans_Mono:h12:cANSI
    set guifontwide=Microsoft_YaHei_Mono:h12:cGB2312
    " fullscreen shortcut key.
    map <F11> <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR> 

    " default colorscheme.
    "colorschem calmar256-dark
    "colorschem greenvision
    "colorschem reloaded
    "colorschem grb256
    colorschem solarized 

    " auto maximize.
    au GUIENTER * simalt ~x
    " for solarized
    "let g:solarized_contrast = "high"
    "let g:solarized_bold = 1
    call togglebg#map("<F7>")
endif

if has("multi_byte") 
    " UTF-8 encoding
    set encoding=gbk
    set termencoding=gbk
    set langmenu=zh_CN.UTF-8
    set fileencoding=gbk
    set fileencodings=utf-8,gbk,ucs-bom,chinese
    "set formatoptions+=mM 
    if has("win32") 
        source $VIMRUNTIME/delmenu.vim 
        source $VIMRUNTIME/menu.vim 
        language messages zh_CN.utf-8 
    endif 
    if v:lang =~ '^\(zh\)\|\(ja\)\|\(ko\)' 
        set ambiwidth=double 
    endif 
else 
    echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte" 
endif

"set selectmode=cmd
"set selection=inclusive

" Markers are used to specify folds.
set foldmethod=marker
"set foldnestmax=3

set undofile
set undodir=~/undofiles

" If on Vim will wrap long lines at a character in 'breakat' rather
" than at the last character that fits on the screen.
set wrap
set linebreak
" support chinese.
set fo+=mB

" Indent related.
set shiftwidth=4
set sts=4
set tabstop=4
set expandtab
set cin
set ai
set cino=:0g0t0(susj1
set ignorecase smartcase
set number
set directory=.,$TEMP

"===================================================
"custom functions
"===================================================
"Only do this part when compiled with support for autocommands.
"autocmd Filetype java,javascript,jsp inoremap <buffer>  .  .<C-X><C-O><C-P>
if has("autocmd")
    autocmd Filetype java setlocal omnifunc=javacomplete#Complete
    autocmd FilterWritePre * if &diff | setlocal wrap< | endif
endif

map <F5> :call CompileRun()<CR> 
map <C-F5> :call Debug()<CR>

func! CompileRun() 
    exec "w" 
    "C program
    if &filetype == 'c' 
        exec "!gcc % -g -o %<" 
        exec "!%<" 
    elseif &filetype == 'cpp'
        exec "!g++ % -g -o %<"
        exec "!%<"
    endif 
endfunc 

" define Debug function.
func! Debug() 
    exec "w" 
    "C program
    if &filetype == 'c' 
        exec "!gcc % -g -o %<" 
        exec "!gdb %<" 
    elseif &filetype == 'cpp'
        exec "!g++ % -g -o %<"
        exec "!gdb %<"
    endif 
endfunc 

" for svn.
nnoremap <silent> <F9> :call SvnCommit()<CR>
func! SvnCommit()
    let svn_directory = 0
    if isdirectory(expand("%"))
        let svn_directory = 1
    endif

    let file_name = expand("%")
    if svn_directory
        let cmd = "svn update ."
    else
        let cmd = "svn update " . file_name
    endif
    echo cmd
    let cmd_output = system(cmd)
    echo cmd_output
    if cmd_output == ""
        echo "svn update return null!"
        return
    endif
    if match(cmd_output, '\cconflict') != -1 ||
                \ match(cmd_output, '\cinvalid option') != -1 ||
                \ match(cmd_output, '\cerror') != -1 ||
                \ match(cmd_output, '\cexception') != -1 ||
                \ match(cmd_output, '\cskipped') != -1
        return
    elseif match(cmd_output, "155007") != -1
        echo file_name . " is not a working copy!"
        return
    endif

    if svn_directory
        let cmd = "svn status ."
        echo cmd
        let cmd_output = system(cmd)
        echo cmd_output
        if match(cmd_output, "M ") == -1 &&
                    \ match(cmd_output, "A ") == -1 &&
                    \ match(cmd_output, "D ") == -1
            echo "Directory " . file_name . " already in newest version!"
            return
        endif
    else
        let cmd = "svn status " . file_name
        let cmd_output = system(cmd)
        if match(cmd_output, "? ") != -1
            || match(cmd_output, "A ") != -1
            let cmd = "svn add " . file_name
            echo cmd
            let cmd_output = system(cmd)
        endif
        if cmd_output == ""
            echo "File " . file_name . " already in newest version!"
            return
        else
            echo cmd_output
        endif
    endif

    let user_name = system("echo %USERNAME%")
    let log_msg = input("Input svn log message: ", user_name, "menu")
    if log_msg == ""
        return
    endif
    echo "\n"
    let cmd = "svn commit -m \"" . log_msg . "\" "
    if svn_directory
        let cmd = cmd . "."
    else
        let cmd = cmd . file_name
    endif
    echo cmd
    let cmd_output = system(cmd)
    echo cmd_output
endfunc

nnoremap <silent> <F10> :call SvnDiff()<CR>
func! SvnDiff()
    let file_name = expand("%")
    let diff_file_name = escape(expand("#"), " ")
    if file_name == ""
        return
    elseif match(file_name, " Revision") != -1
        let diff_buffer = file_name
        let file_name = diff_file_name
    elseif match(diff_file_name, " Revision") != -1
        let diff_buffer = diff_file_name
    else
        let diff_buffer = ""
    endif
    let winbufnum = bufwinnr(diff_buffer)
    if winbufnum != -1 && diff_buffer != ""
        exec "bd " . diff_buffer
        call cursor(g:svn_save_line, g:svn_save_col)
        return
    else
        let g:svn_save_line = line('.')
        let g:svn_save_col = col('.')
    endif

    let bufmodified = getbufvar(bufnr(file_name), "&mod")
    if bufmodified
        exec "w " . file_name
    endif
    let cmd = "svn status \"" . file_name . "\""
    let cmd_output = system(cmd)
    if match(cmd_output, "M ") != -1 
        let cmd_argument = "HEAD"
    elseif match(cmd_output, "? ") != -1
        echo "File " . file_name . " is nonversioned!"
        return
    elseif match(cmd_output, "W155007") != -1
        echo file_name . " is not a working copy!"
        return
    else
        let cmd_argument = "PREV"
    endif

    let cmd_output = system("svn cat -r " . cmd_argument . " \"" . file_name . "\"")
    if match(cmd_output, "E195012") != -1
        let cmd_argument = "HEAD"
        let cmd_output = system("svn cat -r " . cmd_argument . " \"" . file_name . "\"")
    endif
    if diff_buffer == ""
        let diff_buffer = escape(file_name . ": " . cmd_argument . " Revision", ' ')
    endif
    exec "view " . diff_buffer
    setlocal noreadonly
    silent! setlocal buftype=nofile
    silent! setlocal bufhidden=hide
    silent! setlocal modifiable
    silent! setlocal noswapfile
    silent! put! =cmd_output
    let buf_ft = getbufvar(bufnr(file_name), '&filetype')
    exec "setlocal filetype=" . buf_ft
    let buf_ff = getbufvar(bufnr(file_name), '&fileformat')
    exec "setlocal fileformat=" . buf_ff
    normal! Gddgg
    silent! setlocal nomodifiable
    exec "b " . file_name
    exec "vert diffsp " . diff_buffer
    wincmd w
    setlocal wrap
    normal! gg
endfunc

"===================================================
"for plugins
"===================================================
"--- ctags --- 
set tags=tags;/
"set tags+=F:/work/cpp_src/stl_tags
"map <F4> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q . <CR>
map <F4> :!ctags -f tags --languages=c++ -R --sort=yes --c++-kinds=+p+l --fields=+iaS --extra=+q . <CR> <CR>
"set tags=C:/Users/wnq/.indexer_files_tags/openaudit_tmp
"map <F4> :!ctags -f "C:\Users\wnq\.indexer_files_tags\openaudit_tmp" --languages=c++ -R -a --sort=yes --c++-kinds=+p+l --fields=+iaS --extra=+q "F:\work\openaudit\datamgnt" <CR>
"let Tlist_Ctags_Cmd = 'c:\Windows\system32\ctags.exe'

"--- for taglist ---
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Inc_Winwidth = 0
nnoremap <silent> <F8> :TlistToggle<CR>

"--- for supertab ---
"auto complete
let g:SuperTabRetainCompletionType=2
"let g:SuperTabDefaultCompletionType="<C-X><C-O>"

"--- for doxgen ---
map fg : Dox<cr>
map fl : DoxLic<cr>
map fa : DoxAuthor<cr>
let g:DoxygenToolkit_authorName="huangkun, huangkun@asiainfo.com\<enter>* @copyright(c) 2013-2030, Asiainfo HangZhou. All rights reserved."
let s:licenseTag = "Copyright (c) 2013-2030, Asiainfo HangZhou. All rights reserved.\<enter>"
let s:licenseTag = s:licenseTag . "For free\<enter>"
let s:licenseTag = s:licenseTag . "All right reserved\<enter>"
let g:DoxygenToolkit_licenseTag = s:licenseTag
"let g:DoxygenToolkit_licenseTag="My own license\<enter>"
let g:DoxygenToolkit_undocTag="DOXIGEN_SKIP_BLOCK"
let g:DoxygenToolkit_briefTag_pre = "@brief  "
let g:DoxygenToolkit_paramTag_pre = "@param  "
let g:DoxygenToolkit_returnTag = "@return  "
let g:DoxygenToolkit_briefTag_funcName = "yes"
let g:DoxygenToolkit_maxFunctionProtoLines = 30

let g:alternateExtensions_h = "cpp,cxx,cc,CC"
let g:alternateExtensions_H = "CPP,CXX,CC"
let g:alternateExtensions_cpp = "h,hpp"
let g:alternateExtensions_CPP = "H,HPP"
let g:alternateExtensions_c = "h"
let g:alternateExtensions_C = "H"
let g:alternateExtensions_cxx = "h"

"--- for netrw ---
"list files, it's the key setting, if you haven't set, you will get blank buffer
let g:netrw_maxfilenamelen = 100
let g:netrw_list_cmd = "dir"
" if you haven't add putty directory in system path, you should specify scp/sftp command
"let g:netrw_sftp_cmd = "C:\\Users\\wnq\\putty\\PSFTP.exe"
"let g:netrw_scp_cmd = "C:\\Users\\wnq\\putty\\PSCP.exe"
"set dir="C:\\Users\\wnq\\vim-temp"
"
"let g:netrw_silent = 1
"let g:netrw_cygwin = 0
"let g:netrw_ssh_cmd  = 'ssh'
"let g:netrw_scp_cmd  = 'PSCP.EXE -q -scp'
"let g:netrw_sftp_cmd = 'sftp'

"--- for Grep ---
nnoremap <silent> <F3> :Grep<CR>
nnoremap <silent> <C-Tab> :tabnext<CR>
nnoremap <silent> <C-S-Tab> :tabprevious<CR>
let Grep_Default_Options = '-iR'
"let Grep_Default_Filelist = '*.c *.cpp *.h *.hpp'

"--- OmniCppComplete ---
set completeopt=longest,menu
let OmniCpp_MayCompleteDot = 1 " autocomplete with .
let OmniCpp_MayCompleteArrow = 1 " autocomplete with ->
let OmniCpp_MayCompleteScope = 1 " autocomplete with ::
let OmniCpp_SelectFirstItem = 2 " select first item (but don't insert)
let OmniCpp_NamespaceSearch = 2 " search namespaces in this and included files
let OmniCpp_ShowPrototypeInAbbr = 1 " show function prototype (i.e. parameters) in popup window

"--- Tabular ---
"let mapleader=','
"if exists(":Tab")
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>
nmap <Leader>a: :Tabularize /:\zs<CR>
vmap <Leader>a: :Tabularize /:\zs<CR>
nmap <Leader>a<space> :Tabularize /\s<CR>
vmap <Leader>a<space> :Tabularize /\s<CR>
"endif

"--- ctrlp ---
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:50'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/](obsystem|boost|ob_rel)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
    \ }

"--- echofunc config ---
"let g:EchoFuncMaxBalloonDeclarations = 80


"--- for jump ---
"map <C-]> :tselect <C-R>=expand("<cword>")<CR><CR>
"map <C-]> g<C-]>

"Open and close all the three plugins on the same time 
"nmap <F8>   :TrinityToggleAll<CR> 

"Open and close the srcexpl.vim separately 
"nmap <F9>   :TrinityToggleSourceExplorer<CR> 

"Open and close the taglist.vim separately 
"nmap <F10>  :TrinityToggleTagList<CR> 

"Open and close the NERD_tree.vim separately 
"nmap <F11>  :TrinityToggleNERDTree<CR> 

