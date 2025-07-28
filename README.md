# reform.nvim

A simple and lightweight Neovim plugin for formatting your code.

This project is inspired by [vim-rt-format](https://github.com/skywind3000/vim-rt-format).

## Features

- Automatically format on (pressing) enter (the newline).
- Supports different languages and formatters.
- Configurable and easy to set up.
- Written in Lua.
- Support both locally installed and [Mason](https://github.com/mason-org/mason.nvim) installed formatters

## Requirements

- Nvim with "python3" feature
- Python module "autopep8"
- `clang-format` executable for C family formatting
- `stylua` executable for Lua formatting

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
- **formatters** (table): Mapping of formatters respect to their executable path.
- **debug** (boolean, default: `false`): Enable debug information for troubleshooting.

### Configuration Example

```lua
require("reform").setup({
  on_insert_leave = true, -- Enable formatting when leaving insert mode
  auto_enable = {
    enabled = false, -- Master switch for auto-enable
    filetypes = { -- Filetypes to auto-enable
      "python",
      "lua",
      "java",
      "javascript",
      "json",
      "actionscript",
      "ruby",
      "c",
      "cpp",
    },
    exclude_filetypes = {}, -- Filetypes to exclude from auto-enable
  },
  -- Executable paths for formatters (empty = Mason if mason or PATH, DISABLE = disabled)
  formatters = {
    stylua = "", -- Lua formatter
    clang_format = "", -- C/C++ formatter
  },
  mason = true, -- Enable Mason.nvim integration
  debug = false, -- Enable debug info
)
```

Currently, reform supports `stylua` and `clang-format` for language specific formatting. For other languages, such as Python, Java, JavaScript, reform will use `autopep8` module in `Python3` to perform formatting as a fallback.

You do not need to explicitly configure `autopep8`, since it has already been fully implemented by reform. The only thing you needs to do is to ensure your NVim has installed Python3 and Pip has installed autopep8 module.

## Supported Formatters

`reform.nvim` currently supports the following formatters:

- `autopep8` from Python3, for Python, Java, JavaScript, JSON, ActionScript, Ruby.
- `clang-format` for C family (C, C++).
- `stylua` for Lua files.

### Formatter Configuration

Stylua and clang-format automatically detect configuration files in your project:

- **`stylua.toml`**
- **`.clang-format`**

Configuration files are searched for in:

- Current working directory (buffer file directory)
- Parent directories up to the project root
- User home directory as fallback

**This project is still under development, please use with caution**
**Report any bugs or ideas you found in Issue :)**
