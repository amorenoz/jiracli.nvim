# jiracli.nvim

A Neovim plugin that integrates with [jiracli](https://github.com/apconole/jiracli) to provide a JIRA interface within your editor.
User experience is inspired by [vim-fugitive](https://github.com/tpope/vim-fugitive) by tpope.

## Features

- **`:Jlist`** - Display JIRA issues in the current window (equivalent to `:Git` in fugitive)
- **Multiple view options** - Open issues list in current window, splits, or new tabs
- **Syntax highlighting** - JIRA ticket patterns (e.g., PROJ-123) are highlighted
- **Interactive navigation** - Use key bindings to open issues and add comments
- **Comment editing** - Add comments to JIRA issues using Neovim as the editor

## Requirements

- Neovim 0.7+
- [jiracli](https://github.com/apconole/jiracli) installed and configured
- The `jcli` command must be available in your PATH

## Installation

First, ensure [jiracli](https://github.com/apconole/jiracli/tree/main) is installed and configured.

### Quick Setup for Lazy.nvim Users

1. **Add to your lazy.nvim configuration**:
   Add the configuration below to your `~/.config/nvim/lua/plugins/jiracli.lua` or wherever you manage your plugins.

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)


For GitHub installation:
```lua
{
  'amorenoz/jiracli.nvim',
  dependencies = {
  },
  config = function()
    require('jiracli').setup({
      -- Optional configuration
      jcli_cmd = 'jcli',  -- Command to run jiracli
      split_size = 15,  -- Size of the split window
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'amorenoz/jiracli.nvim',
  config = function()
    require('jiracli').setup()
  end,
}
```

## Configuration

The plugin can be configured by calling the setup function:

```lua
require('jiracli').setup({
  jcli_cmd = 'jcli',           -- Command to run jiracli (default: 'jcli')
  split_size = 15,             -- Size of the split window (default: 15)
})
```

## Usage

### Basic Commands

#### Issue List Commands
- **`:Jlist`** - Show JIRA issues in the current window
- **`:Jsplitlist`** - Show JIRA issues in a horizontal split
- **`:Jvsplitlist`** - Show JIRA issues in a vertical split
- **`:Jtablist`** - Show JIRA issues in a new tab

#### Issue Detail Commands
- **`:Jshow [issue]`** - Show issue details in the current window
  - If no issue provided, uses the issue under cursor
- **`:Jsplitshow [issue]`** - Show issue details in a split window
  - If no issue provided, uses the issue under cursor
- **`:Jvsplitshow [issue]`** - Show issue details in a vertical split window
  - If no issue provided, uses the issue under cursor
- **`:Jtabshow [issue]`** - Show issue details in a new tab
  - If no issue provided, uses the issue under cursor

#### Comment Commands
- **`:Jcomment [issue]`** - Add a comment to an issue
  - If no issue provided, uses the issue under cursor
  - Example: `:Jcomment PROJ-123` or just `:Jcomment` when cursor is on an issue

### Key Mappings in Status Window

- **`<CR>`** - Open the issue under cursor in the current window
- **`o`** - Open the issue under cursor in a split window
- **`O`** - Open the issue under cursor in a new tab
- **`gO`** - Open the issue under cursor in a vertical split
- **`c`** - Add a comment to the issue under cursor
- **`r`** - Refresh the list view
- **`q`** - Close the window

### Key Mappings in Issue Detail Window

- **`c`** - Add a comment to the current issue
- **`q`** - Close the window

## Inspiration

This plugin is heavily inspired by [vim-fugitive](https://github.com/tpope/vim-fugitive) by Tim Pope. The interface and key mappings follow similar patterns to provide a familiar experience for fugitive users.
