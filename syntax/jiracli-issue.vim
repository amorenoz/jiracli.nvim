" Syntax highlighting for jiracli issue detail buffer
" Highlights JIRA ticket details and formatting

if exists("b:current_syntax")
  finish
endif

" JIRA ticket patterns (at start of lines in headers)
syntax match jiracliIssueKey '\v[A-Z]+-[0-9]+'

" URLs (complete JIRA URLs)
syntax match jiracliURL 'https\?://[^\s|]\+'

" Table borders and separators
syntax match jiracliTableBorder '^[+\-]\+$'
syntax match jiracliTableSep '|'

" Issue header line (contains issue key, project, assignee)
syntax match jiracliIssueHeader '^|.*[A-Z]+-[0-9]\+.*|$'

" Priority and status line
syntax match jiracliMetadataLine '^|.*priority:.*status:.*|$'

" Section headers inside the table
syntax match jiracliSectionHeader '^\| \(summary\|Description\|Comments\|Attachments\|Reporter\|URL\|EZ Agile\):'

" Reporter line
syntax match jiracliReporter '^| Reporter:.*|$'

" URL line
syntax match jiracliURLLine '^| URL:.*|$'

" Comment metadata
syntax match jiracliCommentAuthor 'Author:.*|' contained
syntax match jiracliCommentDate '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9:+.-]\+' contained
syntax region jiracliCommentHeader start='^|.*Author:' end='|$' contains=jiracliCommentAuthor,jiracliCommentDate,jiracliTableSep keepend

" Status and priority
syntax keyword jiracliStatus New Open "In Progress" Review Done Closed Resolved Fixed contained
syntax keyword jiracliPriority High Critical Blocker Medium Normal Low Minor Trivial contained

" Issue metadata lines
syntax region jiracliMetadataLine start='^|.*\(priority\|status\):' end='|$' contains=jiracliStatus,jiracliPriority,jiracliTableSep keepend

" Code blocks (if any JIRA formatting is present)
syntax region jiracliCodeBlock start='{code[^}]*}' end='{code}' contains=jiracliCodeDelimiter
syntax match jiracliCodeDelimiter '{code[^}]*}' contained
syntax match jiracliCodeDelimiter '{code}' contained

" Quote blocks
syntax region jiracliQuoteBlock start='{quote}' end='{quote}' contains=jiracliQuoteDelimiter
syntax match jiracliQuoteDelimiter '{quote}' contained

" No format blocks
syntax region jiracliNoFormatBlock start='{noformat}' end='{noformat}' contains=jiracliNoFormatDelimiter
syntax match jiracliNoFormatDelimiter '{noformat}' contained

" Define highlight groups
highlight default link jiracliIssueKey Identifier
highlight default link jiracliIssueHeader Title
highlight default link jiracliURL Underlined
highlight default link jiracliURLLine Special
highlight default link jiracliTableBorder Comment
highlight default link jiracliTableSep Comment

highlight default link jiracliSectionHeader Function
highlight default link jiracliMetadataLine Number
highlight default link jiracliReporter Special
highlight default link jiracliCommentAuthor Special
highlight default link jiracliCommentDate Number

highlight default link jiracliStatus Function
highlight default link jiracliPriority WarningMsg

highlight default link jiracliCodeBlock String
highlight default link jiracliCodeDelimiter Delimiter
highlight default link jiracliQuoteBlock Comment
highlight default link jiracliQuoteDelimiter Delimiter
highlight default link jiracliNoFormatBlock PreProc
highlight default link jiracliNoFormatDelimiter Delimiter

let b:current_syntax = "jiracli-issue"
