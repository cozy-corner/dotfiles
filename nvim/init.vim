set number
set clipboard+=unnamedplus
set hlsearch
set incsearch

colorscheme slate

augroup reload_init
  autocmd!
  autocmd BufWritePost init.vim source %
augroup END

" Markdown設定（大文字小文字区別なし）
autocmd BufRead,BufNewFile *.[mM][dD] set filetype=markdown
syntax enable
