# reform.nvim

A simple and lightweight Neovim plugin for formatting your code.

This project is inspired by [vim-rt-format](https://github.com/skywind3000/vim-rt-format). 

## Features

- Automatically format on (pressing) enter (the newline).
- Supports different languages and formatters.
- Configurable and easy to set up.
- Written in Lua.
- **Ultra-fast startup** with lazy loading optimization (<1ms startup time).

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

## Performance

Reform.nvim is optimized for **lightning-fast startup** using advanced lazy loading techniques:

- **<1ms startup time** - Formatter availability checks and utility loading are deferred until needed
- **Lazy formatter instantiation** - Formatters are only loaded when you actually use them
- **Cached availability checks** - System command checks are cached to avoid repeated overhead
- **Minimal initial dependencies** - Only essential modules are loaded at startup

This makes reform.nvim ideal for lazy loading configurations with plugin managers like [lazy.nvim](https://github.com/folke/lazy.nvim).

## Supported Formatters

`reform.nvim` currently supports the following formatters:

- `autopep8` from Python3, for Python, Lua, Java, JavaScript, JSON, ActionScript, Ruby.
- `clang-format` for C family (C, C++).

**This project is still under development, please use with caution**
**Report any bugs or ideas you found in Issue :)**

## Todo - Coming Soon ✨

### 🚀 Configurable Formatter Paths - Use Any Formatter
**Use formatters from Mason, system PATH, or custom locations!** Soon you'll be able to:

```lua
-- Configure formatter paths and language mappings
require("reform").setup({
  formatters = {
    paths = {
      -- "" = disabled, "PATH" = system PATH, "/path" = custom
      ["ruff"] = vim.fn.stdpath("data") .. "/mason/bin/ruff",
      ["black"] = "PATH",
      ["clang-format"] = "/opt/llvm/bin/clang-format",
      ["prettier"] = "",
      ["stylua"] = vim.fn.stdpath("data") .. "/mason/bin/stylua"
    },
    languages = {
      python = "ruff",        -- Use ruff for Python
      c = "clang-format",     -- Use clang-format for C/C++
      javascript = "prettier" -- Use prettier for JS
    }
  }
})
```

**What this means for you:**
- **Use Mason formatters** - Just point to Mason's bin directory
- **Use system formatters** - Works with PATH automatically
- **Use custom builds** - Point to any executable path
- **Disable unwanted formatters** - Set path to empty string
- **Zero breaking changes** - Existing setup continues working

**Supported formatters coming:**
- Python: `ruff`, `black`, `autopep8`
- C/C++: `clang-format`
- JavaScript/TypeScript: `prettier`
- Lua: `stylua`

**Usage preview:**
```lua
-- Check formatter availability
:ReformStatus

-- Auto-detect Mason installations
:ReformDetectFormatters
```

See [docs/formatter-configuration.md](docs/formatter-configuration.md) for complete configuration guide.
