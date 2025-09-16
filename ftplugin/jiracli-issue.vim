" Filetype plugin for jiracli issue detail buffer
" Sets up key mappings and buffer behavior for the issue detail view

if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

" Buffer settings
setlocal buftype=nofile
setlocal noswapfile
setlocal readonly
setlocal nomodifiable
setlocal wrap
setlocal linebreak

" Key mappings are set in the Lua code for better integration
" This file just ensures consistent buffer settings

" Help text
let b:jiracli_help = [
      \ 'Key mappings for jiracli issue buffer:',
      \ '  c - Add comment to this issue',
      \ '  q - Close window',
      \ '',
      \ 'Commands:',
      \ '  :Jcomment - Add comment to this issue',
      \ '  :Jcomment PROJ-123 - Comment on specific issue'
      \ ]

" Command to show help
command! -buffer JiracliHelp echo join(b:jiracli_help, "\n")
