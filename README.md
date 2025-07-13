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

## Supported Formatters

`reform.nvim` currently supports the following formatters:

- `sutopep8` from Python3, for Python, Lua, Java, JavaScrip, Json, actionscript, Ruby.
- `clang-format` for C family.


**This project is still under development, please use with caution**
**Report any bugs or ideas you found in Issue :)**
