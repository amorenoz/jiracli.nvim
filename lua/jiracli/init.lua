local M = {}

-- Configuration
M.config = {
    jcli_cmd = 'jcli',
    split_size = 15,
}

-- Execute jcli commands
local function execute_jcli(args)
    local cmd = M.config.jcli_cmd .. ' ' .. table.concat(args, ' ')
    local handle = io.popen(cmd .. ' 2>&1')
    if not handle then
        return nil, "Failed to execute command: " .. cmd
    end

    local result = handle:read("*a")
    local ok, exit_type, exit_code = handle:close()

    if not ok or exit_code ~= 0 then
        return nil, "Command failed: " .. result
    end

    return result, nil
end

-- Create a new buffer with specific filetype and content
local function create_buffer(content, filetype, buffer_name)
    local existing_buf = vim.fn.bufnr(buffer_name)
    if existing_buf ~= -1 then
        pcall(vim.api.nvim_buf_delete, existing_buf, { force = true })
    end

    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer name and options
    vim.api.nvim_buf_set_name(buf, buffer_name)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    -- Set content
    local lines = vim.split(content, '\n', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set filetype for syntax highlighting (must be after content is set)
    if filetype then
        vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
    end

    -- Make buffer non-modifiable
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    return buf
end

-- Function to update buffer content
local function update_buffer_content(buf, content, filetype)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    local lines = vim.split(content, '\n', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    if filetype then
        vim.api.nvim_buf_set_option(buf, 'filetype', filetype)
    end
end

local function open_split(buf)
    local size = M.config.split_size
    vim.cmd(size .. 'split')
    vim.api.nvim_win_set_buf(0, buf)
end

local function open_current(buf)
    vim.api.nvim_win_set_buf(0, buf)
end

local function open_tab(buf)
    vim.cmd('tabnew')
    vim.api.nvim_win_set_buf(0, buf)
end

local function open_vsplit(buf)
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, buf)
end

local function calculate_optimal_width()
    -- Use 80% of current window width to account for UI elements and provide better formatting
    return math.floor(vim.api.nvim_win_get_width(0) * 0.8)
end

-- Generic function to show issue list with different open methods
local function show_list_with_opener(opener_func)
    -- Execute jcli list command (note: list doesn't have --width, only show does)
    local result, err = execute_jcli({'issues', 'list'})

    if err then
        vim.api.nvim_err_writeln("Error running jcli: " .. err)
        return
    end

    local buf = create_buffer(result, 'jiracli-status', 'jiracli://list')
    opener_func(buf)

    -- Set up buffer-local key mappings
    local opts = { noremap = true, silent = true, buffer = buf }

    -- 'o' to open issue details in split
    vim.keymap.set('n', 'o', function()
        M.show_issue_split(nil)
    end, opts)

    -- '<CR>' to open issue in current window
    vim.keymap.set('n', '<CR>', function()
        M.show_issue_current(nil)
    end, opts)

    -- 'O' to open issue in new tab
    vim.keymap.set('n', 'O', function()
        M.show_issue_tab(nil)
    end, opts)

    -- 'gO' to open issue in vertical split
    vim.keymap.set('n', 'gO', function()
        M.show_issue_vsplit(nil)
    end, opts)

    -- 'c' to add comment to issue
    vim.keymap.set('n', 'c', function()
        M.comment_issue(nil)
    end, opts)

    -- 'q' to close the window
    vim.keymap.set('n', 'q', function()
        local win_count = #vim.api.nvim_list_wins()
        if win_count > 1 then
            vim.cmd('close')
        else
            vim.cmd('bdelete')
        end
    end, opts)

    -- 'r' to refresh the list
    vim.keymap.set('n', 'r', function()
        show_list_with_opener(opener_func)
    end, opts)
end

-- Main list function (equivalent to :Git in fugitive) - shows in current window
function M.list()
    show_list_with_opener(open_current)
end

-- Split list function - shows in horizontal split
function M.splitlist()
    show_list_with_opener(open_split)
end

-- Vertical split list function - shows in vertical split
function M.vsplitlist()
    show_list_with_opener(open_vsplit)
end

-- Tab list function - shows in new tab
function M.tablist()
    show_list_with_opener(open_tab)
end

-- Function to extract JIRA issue key from current line
local function get_issue_key_from_line()
    local line = vim.api.nvim_get_current_line()
    -- Match JIRA issue pattern (e.g., PROJ-123, ABC-1234)
    local issue_key = string.match(line, '([A-Z]+-[0-9]+)')
    return issue_key
end

-- Function to open issue details in a split
function M.open_issue_under_cursor()
    local issue_key = get_issue_key_from_line()

    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end

    M.show_issue(issue_key)
end

-- Generic function to show issue with different open methods
local function show_issue_with_opener(issue_key, opener_func)
    -- Create buffer with loading message first
    local buf = create_buffer("Loading " .. issue_key .. "...", 'jiracli-issue', 'jiracli://issue/' .. issue_key)

    -- Open the buffer in target window
    opener_func(buf)

    -- Now measure the actual window width
    local win_width = calculate_optimal_width()

    -- Execute jcli with the proper width (only if width > 79, as jcli enforces minimum 79)
    local jcli_args = {'issues', 'show'}
    if win_width > 79 then
        table.insert(jcli_args, '--width')
        table.insert(jcli_args, tostring(win_width))
    end
    table.insert(jcli_args, issue_key)

    local result, err = execute_jcli(jcli_args)

    if err then
        -- Update buffer with error message
        update_buffer_content(buf, "Error showing issue " .. issue_key .. ":\n" .. err, 'jiracli-issue')
        return
    end

    -- Update the buffer with real content
    update_buffer_content(buf, result, 'jiracli-issue')

    -- Set up buffer-local key mappings for issue view
    local opts = { noremap = true, silent = true, buffer = buf }

    vim.keymap.set('n', 'q', function()
        local win_count = #vim.api.nvim_list_wins()
        if win_count > 1 then
            vim.cmd('close')
        else
            vim.cmd('bdelete')
        end
    end, opts)

    vim.keymap.set('n', 'c', function()
        M.comment_issue(issue_key)
    end, opts)
end

function M.show_issue_current(issue_key)
    local issue_key = issue_key or get_issue_key_from_line()
    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end
    show_issue_with_opener(issue_key, open_current)
end

function M.show_issue_split(issue_key)
    local issue_key = issue_key or get_issue_key_from_line()
    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end
    show_issue_with_opener(issue_key, open_split)
end

function M.show_issue_vsplit(issue_key)
    local issue_key = issue_key or get_issue_key_from_line()
    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end
    show_issue_with_opener(issue_key, open_vsplit)
end

function M.show_issue_tab(issue_key)
    local issue_key = issue_key or get_issue_key_from_line()
    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end
    show_issue_with_opener(issue_key, open_tab)
end

-- Function to add comment to issue under cursor
function M.add_comment_to_issue()
    local issue_key = get_issue_key_from_line()

    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end

    M.add_comment(issue_key)
end

-- Function to comment on a specific issue (used by :Jcomment command)
function M.comment_issue(issue_key)
    local issue_key = issue_key or get_issue_key_from_line()
    if not issue_key then
        vim.api.nvim_err_writeln("No JIRA issue found under cursor")
        return
    end
    M._comment_issue(issue_key)
end

-- Function to add comment to a specific issue using jcli directly
function M._comment_issue(issue_key)
    -- Create a unique temp directory for this comment session
    local temp_dir = vim.fn.tempname() .. '_jiracli'
    vim.fn.mkdir(temp_dir)

    -- File paths
    local marker_file = temp_dir .. '/nvim_ready'
    local comment_file = temp_dir .. '/comment.tmp'

    local script_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h") .. '/bin/nvim-editor-wrapper.sh'
    if vim.fn.executable(script_path) == 0 then
        vim.api.nvim_err_writeln("jiracli.nvim: wrapper script not found at " .. script_path)
        return
    end

    -- Start the jcli command in the background with our static wrapper as EDITOR
    local editor_cmd = string.format('%s --tmp-dir %s', script_path, temp_dir)
    local jcli_cmd = string.format('cd %s && EDITOR="%s" %s issues add-comment %s',
                                                                 temp_dir, editor_cmd, M.config.jcli_cmd, issue_key)

    local job_id = vim.fn.jobstart(jcli_cmd, {
        on_exit = function(_, exit_code)
            -- Clean up temp directory
            vim.fn.system({'rm', '-r', temp_dir})

            if exit_code == 0 then
                vim.api.nvim_echo({{"Comment added to " .. issue_key, "Normal"}}, false, {})
            else
                vim.api.nvim_err_writeln("Failed to add comment to " .. issue_key)
            end
        end
    })

    if job_id <= 0 then
        vim.api.nvim_err_writeln("Failed to start jcli command")
        vim.fn.system({'rm', '-rf', temp_dir})
        return
    end

    -- Start monitoring for the marker file
    M.wait_for_jcli_editor(marker_file, comment_file, issue_key)
end

-- Function to wait for jcli to be ready and open the comment file
function M.wait_for_jcli_editor(marker_file, comment_file, issue_key)
    local timer = vim.loop.new_timer()

    timer:start(100, 100, vim.schedule_wrap(function()
        -- Check if marker file exists (jcli is waiting for us)
        if vim.fn.filereadable(marker_file) == 1 then
            timer:stop()
            timer:close()

            -- Open the comment file for editing
            M.open_comment_file_for_editing(marker_file, comment_file, issue_key)
        end
    end))
end

-- Function to open and edit the comment file
function M.open_comment_file_for_editing(marker_file, comment_file, issue_key)
    -- Create buffer and load the file content
    local comment_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(comment_buf, 'jiracli://comment/' .. issue_key)
    vim.api.nvim_buf_set_option(comment_buf, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(comment_buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(comment_buf, 'filetype', 'markdown')

    -- Load existing content from the temp file (jcli may have pre-populated it)
    local content = {}
    if vim.fn.filereadable(comment_file) == 1 then
        content = vim.fn.readfile(comment_file)
    end

    -- If file is empty, add helpful comments
    if #content == 0 or (#content == 1 and content[1] == '') then
        content = {
            "# Add comment for " .. issue_key,
            "# Lines starting with # are ignored",
            "",
            ""
        }
    end

    vim.api.nvim_buf_set_lines(comment_buf, 0, -1, false, content)

    -- Open in a split
    open_split(comment_buf)

    -- Set up autocommand to handle saving
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = comment_buf,
        callback = function()
            M.save_jcli_comment(marker_file, comment_file, comment_buf)
        end,
    })

    -- Set up buffer-local key mappings
    local opts = { noremap = true, silent = true, buffer = comment_buf }

    vim.keymap.set('n', 'q', function()
        -- Cancel the comment by removing marker file and closing
        vim.fn.delete(marker_file)
        vim.cmd('close')
    end, opts)
end

-- Function to save the comment back to jcli
function M.save_jcli_comment(marker_file, comment_file, buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- Filter out comment lines (starting with #) and empty lines at the beginning/end
    local comment_lines = {}
    for _, line in ipairs(lines) do
        if not string.match(line, '^%s*#') then
            table.insert(comment_lines, line)
        end
    end

    -- Remove leading and trailing empty lines
    while #comment_lines > 0 and string.match(comment_lines[1], '^%s*$') do
        table.remove(comment_lines, 1)
    end
    while #comment_lines > 0 and string.match(comment_lines[#comment_lines], '^%s*$') do
        table.remove(comment_lines, #comment_lines)
    end

    if #comment_lines == 0 then
        vim.api.nvim_err_writeln("Comment is empty, cancelling")
        vim.fn.delete(marker_file)
        vim.cmd('close')
        return
    end

    -- Write the content to the comment file
    vim.fn.writefile(comment_lines, comment_file)

    -- Remove the marker file to signal jcli we're done
    vim.fn.delete(marker_file)

    -- Close the buffer
    vim.cmd('close')
end


-- Setup function for user configuration
function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend('force', M.config, opts)

    -- Verify wrapper script is available and executable
    local script_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h") .. '/bin/nvim-editor-wrapper.sh'
    if vim.fn.executable(script_path) == 0 then
        vim.api.nvim_echo({
            {"Warning: jiracli.nvim wrapper script not found or not executable at " .. script_path, "WarningMsg"},
            {"\nComment functionality may not work properly.", "WarningMsg"}
        }, true, {})
    end
end

return M
