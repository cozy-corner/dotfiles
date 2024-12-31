set number
set clipboard+=unnamedplus
set hlsearch
set incsearch

augroup reload_init
  autocmd!
  autocmd BufWritePost init.vim source %
augroup END
