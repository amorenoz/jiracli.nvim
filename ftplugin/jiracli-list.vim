" Filetype plugin for jiracli list buffer
" Sets up key mappings and buffer behavior for the list view

if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

" Buffer settings
setlocal buftype=nofile
setlocal noswapfile
setlocal readonly
setlocal nomodifiable
setlocal nowrap
setlocal cursorline

" Key mappings are set in the Lua code for better integration
" This file just ensures consistent buffer settings

" Help text
let b:jiracli_help = [
      \ 'Key mappings for jiracli list buffer:',
      \ '  <CR> - Open issue in current window',
      \ '  o - Open issue details in split window',
      \ '  O - Open issue in new tab',
      \ '  gO - Open issue in vertical split',
      \ '  c - Add comment to issue under cursor',
      \ '  r - Refresh list view',
      \ '  q - Close window',
      \ '',
      \ 'Commands that work with issue under cursor:',
      \ '  :Jshow - Show issue details',
      \ '  :Jcomment - Add comment to issue',
      \ '',
      \ 'Commands that work with specific issues:',
      \ '  :Jshow PROJ-123 - Show specific issue',
      \ '  :Jcomment PROJ-123 - Comment on specific issue'
      \ ]

" Command to show help
command! -buffer JiracliHelp echo join(b:jiracli_help, "\n")
