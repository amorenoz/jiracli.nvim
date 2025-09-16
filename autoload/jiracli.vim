" jiracli.vim - Autoload functions for jiracli.nvim
" Provides bridge between Vim and Lua functionality

function! jiracli#list() abort
    lua require('jiracli').list()
endfunction

function! jiracli#splitlist() abort
    lua require('jiracli').splitlist()
endfunction

function! jiracli#vsplitlist() abort
    lua require('jiracli').vsplitlist()
endfunction

function! jiracli#tablist() abort
    lua require('jiracli').tablist()
endfunction

function! jiracli#show(issue) abort
    if empty(a:issue)
        lua require('jiracli').show_issue_current(nil)
    else
        lua require('jiracli').show_issue_current(vim.fn.eval('a:issue'))
    endif
endfunction

function! jiracli#splitshow(issue) abort
    if empty(a:issue)
        lua require('jiracli').show_issue_split(nil)
    else
        lua require('jiracli').show_issue_split(vim.fn.eval('a:issue'))
    endif
endfunction

function! jiracli#vsplitshow(issue) abort
    if empty(a:issue)
        lua print("no issue")
        lua require('jiracli').show_issue_vsplit(nil)
    else
        lua print("has issue")
        lua require('jiracli').show_issue_vsplit(vim.fn.eval('a:issue'))
    endif
endfunction

function! jiracli#tabshow(issue) abort
    if empty(a:issue)
        lua require('jiracli').show_issue_tab(nil)
    else
        lua require('jiracli').show_issue_tab(vim.fn.eval('a:issue'))
    endif
endfunction

function! jiracli#comment(issue) abort
    if empty(a:issue)
        lua require('jiracli').comment_issue(nil)
    else
        lua require('jiracli').comment_issue(vim.fn.eval('a:issue'))
    endif
endfunction

function! jiracli#setup(...) abort
    if a:0 > 0
        lua require('jiracli').setup(vim.fn.eval('a:1'))
    else
        lua require('jiracli').setup()
    endif
endfunction
