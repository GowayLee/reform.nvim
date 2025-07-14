# reform.nvim

A simple and lightweight Neovim plugin for formatting your code.

This project is inspired by [vim-rt-format](https://github.com/skywind3000/vim-rt-format). 

## Features

- Automatically format on (pressing) enter (the newline).
- Supports different languages and formatters.
- Configurable and easy to set up.
- Written in Lua.

## Requirements

- Nvim with "+python3" feature
- Python module "autopep8"
- A `clang-format` executable installed

## Installation

You can install `reform.nvim` using your favorite plugin manager.

### vim-plug

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('gowaylee/reform.nvim')

vim.call('plug#end')
```

### lazy.nvim

```lua
{
  "gowaylee/reform.nvim",
  config = function()
    require("reform").setup({
      -- Your configuration goes here
    })
  end,
}
```

## Configuration

The plugin can be configured by passing a table to the `setup` function. Here are the available configuration options:

### Core Configuration Options

- **on_insert_leave** (boolean, default: `true`): Enable formatting when leaving insert mode.
- **auto_enable** (table): Configuration for auto-enabling formatting on specific file types.
  - **enabled** (boolean, default: `false`): Master switch for auto-enabling formatting.
  - **filetypes** (table): List of file types to auto-enable formatting for.
  - **exclude_filetypes** (table): List of file types to exclude from auto-enable.
- **formatters** (table): Mapping of file types to their respective formatters.
- **debug** (boolean, default: `false`): Enable debug information for troubleshooting.

### Configuration Example

```lua
require("reform").setup({
  on_insert_leave = true,
  auto_enable = {
    enabled = false,
    filetypes = {
      'python',
      'lua',
      'java',
      'javascript',
      'json',
      'actionscript',
      'ruby',
      'c',
      'cpp'
    },
    exclude_filetypes = {}
  },
  formatters = {
    python = 'autopep8',
    c = 'clang-format',
    cpp = 'clang-format'
  },
  debug = false
})
```

## Supported Formatters

`reform.nvim` currently supports the following formatters:

- `autopep8` from Python3, for Python, Lua, Java, JavaScript, JSON, ActionScript, Ruby.
- `clang-format` for C family (C, C++).

**This project is still under development, please use with caution**
**Report any bugs or ideas you found in Issue :)**
