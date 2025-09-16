" Filetype detection for jiracli buffers

" Match jiracli buffer names
autocmd BufNewFile,BufRead jiracli://list setfiletype jiracli-list
autocmd BufNewFile,BufRead jiracli://issue/* setfiletype jiracli-issue
autocmd BufNewFile,BufRead jiracli://comment/* setfiletype markdown
