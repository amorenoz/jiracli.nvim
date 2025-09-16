" jiracli.nvim - JIRA CLI integration for Neovim

if exists('g:loaded_jiracli') || !executable('jcli')
    finish
endif
let g:loaded_jiracli = 1

" User commands
command! -nargs=0 Jlist call jiracli#list()
command! -nargs=0 Jsplitlist call jiracli#splitlist()
command! -nargs=0 Jvsplitlist call jiracli#vsplitlist()
command! -nargs=0 Jtablist call jiracli#tablist()
command! -nargs=? Jshow call jiracli#show(<q-args>)
command! -nargs=? Jsplitshow call jiracli#splitshow(<q-args>)
command! -nargs=? Jvsplitshow call jiracli#vsplitshow(<q-args>)
command! -nargs=? Jtabshow call jiracli#tabshow(<q-args>)
command! -nargs=? Jcomment call jiracli#comment(<q-args>)

" Default key mappings (can be disabled by setting g:jiracli_no_maps)
if !exists('g:jiracli_no_maps') || !g:jiracli_no_maps
    " Add any global mappings here if needed
endif
