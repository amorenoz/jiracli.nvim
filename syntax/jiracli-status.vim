" Syntax highlighting for jiracli status buffer
" Highlights JIRA ticket identifiers and table formatting

if exists("b:current_syntax")
  finish
endif

" JIRA ticket patterns (e.g., PROJ-123, ABC-1234) - highlight them anywhere in the table
syntax match jiracliIssueKey '\v[A-Z]+-[0-9]+'

" Issue key in first column of table rows
syntax match jiracliIssueKeyColumn '^\s*|\s*[A-Z]+-[0-9]\+\s*|' contains=jiracliIssueKey,jiracliTableSep

" Table separators and borders
syntax match jiracliTableSep '|'
syntax match jiracliTableBorder '^[+\-|]\+$'

" Table header line (key | project | priority | summary | status | assignee)
syntax match jiracliTableHeader '^|\s*key\s*|\s*project.*|$'

" Column separator lines (with dashes)
syntax match jiracliColumnSeparator '^|[-\s|]\+|$'

" Status indicators
syntax keyword jiracliStatusNew New Open
syntax keyword jiracliStatusInProgress "In Progress" Started Active
syntax keyword jiracliStatusReview Review "Code Review" "In Review"
syntax keyword jiracliStatusDone Done Closed Resolved Fixed

" Priority indicators
syntax keyword jiracliPriorityHigh High Critical Blocker Major
syntax keyword jiracliPriorityMedium Medium Normal
syntax keyword jiracliPriorityLow Low Minor Trivial

" Project names (typically uppercase)
syntax match jiracliProject '\v[A-Z]{2,}' contained

" Define highlight groups
highlight default link jiracliIssueKey Identifier
highlight default link jiracliIssueKeyColumn Special
highlight default link jiracliTableSep Comment
highlight default link jiracliTableBorder Comment
highlight default link jiracliTableHeader Title
highlight default link jiracliColumnSeparator Comment

highlight default link jiracliStatusNew String
highlight default link jiracliStatusInProgress WarningMsg
highlight default link jiracliStatusReview Number
highlight default link jiracliStatusDone DiffAdd

highlight default link jiracliPriorityHigh ErrorMsg
highlight default link jiracliPriorityMedium WarningMsg
highlight default link jiracliPriorityLow Comment

highlight default link jiracliProject Type

let b:current_syntax = "jiracli-status"
