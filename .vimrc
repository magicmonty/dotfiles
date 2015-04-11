
set nocompatible
set shortmess+=I        " Don't show the Vim welcome screen.
set clipboard=unnamedplus " use system clipboard with * register

set autoindent          " Copy indent from current line for new line.
set nosmartindent       " 'smartindent' breaks right-shifting of # lines.

set hidden              " Keep changed buffers without requiring saves.

set history=5000        " Remember this many command lines.

set ruler               " Always show the cursor position.
set showcmd             " Display incomplete commands.
set incsearch           " Do incremental searching.
set hlsearch            " Highlight latest search pattern.
set number              " Display line numbers.
set numberwidth=4       " Minimum number of columns to show for line numbers.
set laststatus=2        " Always show a status line.
set visualbell t_vb=    " Use null visual bell (no beeps or flashes).

set scrolloff=3         " Context lines at top and bottom of display.
set sidescrolloff=5     " Context columns at left and right.
set sidescroll=1        " Number of chars to scroll when scrolling sideways.

set nowrap              " Don't wrap the display of long lines.
set linebreak           " Wrap at 'breakat' char vs display edge if 'wrap' on.
set display=lastline    " Display as much of a window's last line as possible.

set splitright          " Split new vertical windows right of current window.
set splitbelow          " Split new horizontal windows under current window.

set winminheight=0      " Allow windows to shrink to status line.
set winminwidth=0       " Allow windows to shrink to vertical separator.

set expandtab           " Insert spaces for <Tab> press; use spaces to indent.
set smarttab            " Tab respects 'shiftwidth', 'tabstop', 'softtabstop'.
set tabstop=2           " Set the visible width of tabs.
set softtabstop=2       " Edit as if tabs are 2 characters wide.
set shiftwidth=2        " Number of spaces to use for indent and unindent.
set shiftround          " Round indent to a multiple of 'shiftwidth'.

set ignorecase          " Ignore case for pattern matches (\C overrides).
set smartcase           " Override 'ignorecase' if pattern contains uppercase.
set nowrapscan          " Don't allow searches to wrap around EOF.

set nocursorline        " Don't highlight the current screen line...
set nocursorcolumn      " ...or screen column...
set colorcolumn=        " ...or margins (but see toggle_highlights.vim).

set virtualedit=block   " Allow virtual editing when in Visual Block mode.

set foldcolumn=3        " Number of columns to show at left for folds.
set foldnestmax=3       " Only allow 3 levels of folding.
set foldlevelstart=99   " Start with all folds open.

set whichwrap+=<,>,[,]  " Allow left/right arrows to move across lines.

set nomodeline          " Ignore modelines.
set nojoinspaces        " Don't get fancy with the spaces when joining lines.
set textwidth=0         " Don't auto-wrap lines except for specific filetypes.

set background=dark     " Try to use colors suitable for a dark background.

" Turn 'list' off by default, since it interferes with 'linebreak' and
" 'breakat' formatting (and it's ugly and noisy), but define characters to use
" when it's turned on.

set nolist
set listchars =tab:>-           " Start and body of tabs
set listchars +=trail:.          " Trailing spaces
set listchars +=extends:>        " Last column when line extends off right
set listchars +=precedes:<       " First column when line extends off left
set listchars +=eol:$            " End of line

set backspace=indent,eol,start  " Backspace over everything in Insert mode

set noshowmatch                 " Don't jump to matching characters
set matchpairs=(:),[:],{:},<:>  " Character pairs for use with %, 'showmatch'
set matchtime=1                 " In tenths of seconds, when showmatch is on

set wildmenu                    " Use menu for completions
set wildmode=full

if has("win32")
  set grepprg=internal        " Windows findstr.exe just isn't good enough.
endif

" Enable mouse support if it's available.
"
if has('mouse')
  set mouse=a
endif

if has("unix") " (including OS X)
  set backup

  " Remove the current directory from the backup directory list.
  "
  set backupdir-=.

  " Save backup files in the current user's ~/tmp directory, or in the
  " system /tmp directory if that's not possible.
  "
  set backupdir^=~/tmp,/tmp

  " Try to put swap files in ~/tmp (using the munged full pathname of
  " the file to ensure uniqueness). Use the same directory as the
  " current file if ~/tmp isn't available.
  "
  set directory=~/tmp//,.
endif

" Update the swap file every 20 characters. I don't like to lose stuff.
"
set updatecount=20

" Switch on syntax highlighting when the terminal has colors, or when running
" in the GUI. Set the do_syntax_sel_menu flag to tell $VIMRUNTIME/menu.vim
" to expand the syntax menu.
"
" Note: This happens before the 'Autocommands' section below to give the syntax
" command a chance to trigger loading the menus (vs. letting the filetype
" command do it). If do_syntax_sel_menu isn't set beforehand, the syntax menu
" won't get populated.
"
if &t_Co > 2 || has("gui_running")
    let do_syntax_sel_menu=1
    syntax on
endif

" Use pathogen for better plugin management.
"
call pathogen#incubate()
execute pathogen#infect()

if has("autocmd") && !exists("autocommands_loaded")

  " Set a flag to indicate that autocommands have already been loaded,
  " so we only do this once. I use this flag instead of just blindly
  " running `autocmd!` (which removes all autocommands from the
  " current group) because `autocmd!` breaks the syntax highlighting /
  " syntax menu expansion logic.
  "
  let autocommands_loaded = 1

  " Enable filetype detection, so language-dependent plugins, indentation
  " files, syntax highlighting, etc., are loaded for specific filetypes.
  "
  " Note: See $HOME/.vim/ftplugin and $HOME/.vim/after/ftplugin for
  " most local filetype autocommands and customizations.
  "
  filetype off
  filetype plugin indent off

  set runtimepath+=$GOROOT/misc/vim

  filetype on
  syntax on
  filetype plugin indent on

  " When editing a file, always jump to the last known cursor
  " position. Don't do it when the position is invalid or when inside
  " an event handler (happens when dropping a file on gvim).
  "
  autocmd BufReadPost *
      \   if line("'\"") > 0 && line("'\"") <= line("$") |
      \       exe "normal g`\"" |
      \   endif

  " Create the hook for the per-window configuration. Both WinEnter
  " and VimEnter are used, since WinEnter doesn't fire for the first
  " window.
  "
  " Based on ideas from here:
  " http://vim.wikia.com/wiki/Detect_window_creation_with_WinEnter
  "
  autocmd WinEnter,VimEnter * call s:ConfigureWindow()

  " Resize Vim windows to equal heights and widths when Vim itself
  " is resized.
  "
  autocmd VimResized * wincmd =

  " Open quickfix and fugitive's git commit windows at full horizontal
  " width. Via http://nosubstance.me/articles/2013-09-21-my-vim-gems/
  "
  autocmd FileType qf,gitcommit wincmd J

  " Treat buffers from stdin (e.g.: echo foo | vim -) as scratch buffers.
  "
  autocmd StdinReadPost * :set buftype=nofile

  " Experiment to force a script to run as late as possible. This is close,
  " but a few scripts still run after it.
  "
  autocmd VimEnter * :source ~/.vim/run-last.vim

endif " has("autocmd")


"""
""" Key mappings
"""

" Set 'selection', 'selectmode', 'mousemodel' and 'keymodel' to make
" both keyboard- and mouse-based highlighting behave more like Windows
" and OS X. (These are the same settings you get with `:behave mswin`.)
"
" Note: 'selectmode', 'keymodel', and 'selection' are also set within
" map_movement_keys.vim, since they're critical to the behavior of those
" mappings (although they should be set to the same values there as here.)
"
" Note: Under MacVim, `:let macvim_hig_shift_movement = 1` will cause MacVim
" to set selectmode and keymodel. See `:help macvim-shift-movement` for
" details.
"
set selectmode=mouse,key
set keymodel=startsel,stopsel
set selection=exclusive
set mousemodel=popup

" Backspace in Visual mode deletes selection.
"
vnoremap <BS> d

" Control+A is Select All.
"
noremap  <C-A>  gggH<C-O>G
inoremap <C-A>  <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A>  <C-C>gggH<C-O>G
onoremap <C-A>  <C-C>gggH<C-O>G
snoremap <C-A>  <C-C>gggH<C-O>G
xnoremap <C-A>  <C-C>ggVG

" Control+S saves the current file (if it's been changed).
"
noremap  <C-S>  :update<CR>
vnoremap <C-S>  <C-C>:update<CR>
inoremap <C-S>  <C-O>:update<CR>

" Control+Z is Undo, in Normal and Insert mode.
"
noremap  <C-Z>  u
inoremap <C-Z>  <C-O>u

" F2 inserts the date and time at the cursor.
"
inoremap <F2>   <C-R>=strftime("%c")<CR>
nmap     <F2>   a<F2><Esc>

" F7 formats the current/highlighted paragraph.
"
" XXX: Consider changing this to gwap to maintain logical cursor position.
"
nnoremap <F7>   gqap
inoremap <F7>   <C-O>gqap
vnoremap <F7>   gq

" Q does the same thing as <F7> (except in Insert mode, of course). I'm
" retraining myself to use Q instead of a function key, since it's kind
" of a de facto standard keystroke.
"
nnoremap Q  gqap
xnoremap Q  gq

" Tab/Shift+Tab indent/unindent the highlighted block (and maintain the
" highlight after changing the indentation). Works for both Visual and Select
" modes.
"
vnoremap <Tab>    >gv
vnoremap <S-Tab>  <gv

" Map Control+Up/Down to move lines and selections up and down.
"
runtime map_line_block_mover_keys.vim

" Disable paste-on-middle-click.
"
map  <MiddleMouse>    <Nop>
map  <2-MiddleMouse>  <Nop>
map  <3-MiddleMouse>  <Nop>
map  <4-MiddleMouse>  <Nop>
imap <MiddleMouse>    <Nop>
imap <2-MiddleMouse>  <Nop>
imap <3-MiddleMouse>  <Nop>
imap <4-MiddleMouse>  <Nop>

" Control+Backslash toggles a lot of useful, but visually-noisy, features
" (like search/match highlighting, 'list', and 'cursorline', etc.). Note the
" :execute (vs. :call); see ToggleHighlight() for details.
"
runtime toggle_highlights.vim
nnoremap <silent> <C-Bslash>  :execute ToggleHighlights()<CR>
imap     <silent> <C-BSlash>  <Esc><C-BSlash>a
vmap     <silent> <C-BSlash>  <Esc><C-BSlash>gv

" Control+Hyphen (yes, I know it says underscore) repeats the character above
" the cursor.
"
inoremap <C-_>  <C-Y>

" Center the display line after searches. (This makes it *much* easier to see
" the matched line.)
"
" More info: http://www.vim.org/tips/tip.php?tip_id=528
"
nnoremap n   nzz
nnoremap N   Nzz
nnoremap *   *zz
nnoremap #   #zz
nnoremap g*  g*zz
nnoremap g#  g#zz

" Draw lines of dashes or equal signs based on the length of the line
" immediately above.
"
"   k       Move up 1 line
"   yy      Yank whole line
"   p       Put line below current line
"   ^       Move to beginning of line
"   v$      Visually highlight to end of line
"   r-      Replace highlighted portion with dashes / equal signs
"   j       Move down one line
"   a       Return to Insert mode
"
" XXX: Convert this to a function and make the symbol a parameter.
" XXX: Consider making abbreviations/mappings for ---<CR> and ===<CR>
"
inoremap <C-U>- <Esc>kyyp^v$r-ja
inoremap <C-U>= <Esc>kyyp^v$r=ja

" Edit user's vimrc and gvimrc in new tabs.
"
nnoremap ,ev  :tabedit $MYGVIMRC<CR>:tabedit $MYVIMRC<CR>

" Make page-forward and page-backward work in insert mode.
"
inoremap <C-F>  <C-O><C-F>
inoremap <C-B>  <C-O><C-B>

" Make Option+Up/Down work as PageUp and PageDown
"
nnoremap    <M-Up>      <PageUp>
inoremap    <M-Up>      <PageUp>
vnoremap    <M-Up>      <PageUp>
nnoremap    <M-Down>    <PageDown>
inoremap    <M-Down>    <PageDown>
vnoremap    <M-Down>    <PageDown>

" Overload Control+L to clear the search highlight as it's redrawing the screen.
"
nnoremap <C-L>  :nohlsearch<CR><C-L>
inoremap <C-L>  <Esc>:nohlsearch<CR><C-L>a
vnoremap <C-L>  <Esc>:nohlsearch<CR><C-L>gv


" Insert spaces to match spacing on first previous non-blank line.
"
runtime insert_matching_spaces.vim
inoremap <expr> <S-Tab>  InsertMatchingSpaces()

" Keep the working line in the center of the window. This is a toggle, so you
" can bounce between centered-working-line scrolling and normal scrolling by
" issuing the keystroke again.
"
" From this message on the MacVim mailing list:
" http://groups.google.com/group/vim_mac/browse_thread/thread/31876ef48063e487/133e06134425bda1?hl=en¿e06134425bda1
"
nnoremap \zz  :let &scrolloff=999-&scrolloff<CR>

" Toggle wrapping the display of long lines (and display the current 'wrap'
" state once it's been toggled).
"
nnoremap \w  :set invwrap<BAR>set wrap?<CR>

" Toggle the NERD Tree window
"
nnoremap ,.  :NERDTreeToggle<CR>

" Make it easy to :Tabularize
"
nnoremap \<Tab> <Esc>:Tabularize /

" Make the dot command operate over a Visual range.
" (Excellent tip from Drew Neil's Vim Masterclass.)
"
xnoremap .  :normal .<CR>

" Shortcuts to commonly-used fugitive.vim features
"
nnoremap \gs  :Gstatus<CR>
nnoremap \gd  :Gdiff<CR>


"""
""" Abbreviations
"""

runtime set_abbreviations.vim


au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

colorscheme solarized

"""
""" Local Functions
"""

function! s:ConfigureWindow()

    " Only do this once per window.
    "
    if exists('w:windowConfigured')
        return
    endif

    let w:windowConfigured = 1

    " Highlight trailing whitespace, except when typing at the end of a line.
    " More info: http://vim.wikia.com/wiki/Highlight_unwanted_spaces
    "
    " XXX: Disabled for now, since it's distracting during demos and classes.
    "
    "call matchadd('NonText', '\s\+\%#\@<!$')

    " Highlight the usual to-do markers (including my initials and Michele's
    " initials), even if the current syntax highlighting doesn't include them.
    "
    call matchadd('Todo', 'XXX')
    call matchadd('Todo', 'BUG')
    call matchadd('Todo', 'HACK')
    call matchadd('Todo', 'FIXME')
    call matchadd('Todo', 'TODO')
    call matchadd('Todo', 'WNO:')
    call matchadd('Todo', 'MRB:')

endfunction
