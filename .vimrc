set nu
set ic
set smartcase
set nowrap
set ruler
set tabstop=2
set shiftwidth=2
set expandtab
set list listchars=tab:»·,trail:·

filetype off
filetype plugin indent off

set runtimepath+=$GOROOT/misc/vim

set nocompatible

filetype on

filetype plugin indent on
syntax on
execute pathogen#infect()

colorscheme murphy
