set rtp+=.
set rtp+=../plenary.nvim/

runtime! plugin/plenary.vim
runtime! plugin/renamer.vim

nnoremap ,,x :luafile %<CR>
