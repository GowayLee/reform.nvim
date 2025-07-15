# Formatter Configuration Plan

## Overview

Allow users to configure:
1. **Formatter executable paths** (empty = disabled, "PATH" = system PATH, Mason path = Mason installation)
2. **Language-to-formatter mapping** (which formatter to use for each language)

## Supported Formatters Enum

```lua
local SUPPORTED_FORMATTERS = {
  -- Python
  PYTHON_AUTOPEP8 = "autopep8",
  PYTHON_BLACK = "black", 
  PYTHON_RUFF = "ruff",
  
  -- C/C++
  CPP_CLANG_FORMAT = "clang-format",
  
  -- JavaScript/TypeScript
  JS_PRETTIER = "prettier",
  JS_ESLINT = "eslint",
  
  -- Lua
  LUA_STYLUA = "stylua"
}
```

## Configuration Design

### Simple Configuration Schema

```lua
require('reform').setup({
  formatters = {
    -- Path configuration: path to executable
    -- "" = disable formatter
    -- "PATH" = use system PATH
    -- "/custom/path" = use specific path
    paths = {
      ["autopep8"] = "PATH",        -- System installed
      ["black"] = "",               -- Disabled  
      ["ruff"] = "/home/user/.local/bin/ruff",
      ["clang-format"] = "PATH",
      ["prettier"] = "/home/user/.local/share/nvim/mason/bin/prettier",
      ["eslint"] = "",
      ["stylua"] = "/home/user/.local/share/nvim/mason/bin/stylua"
    },
    
    -- Language to formatter mapping
    languages = {
      python = "ruff",              -- Use ruff for Python
      c = "clang-format",           -- Use clang-format for C
      cpp = "clang-format",         -- Use clang-format for C++
      javascript = "prettier",      -- Use prettier for JS
      typescript = "prettier",      -- Use prettier for TS
      lua = "stylua"                -- Use stylua for Lua
    }
  }
})
```

### Minimal Configuration

```lua
-- Use all defaults (system PATH)
require('reform').setup({})

-- Or with Mason paths
require('reform').setup({
  formatters = {
    paths = {
      ["ruff"] = vim.fn.stdpath("data") .. "/mason/bin/ruff",
      ["clang-format"] = vim.fn.stdpath("data") .. "/mason/bin/clang-format"
    },
    languages = {
      python = "ruff",
      c = "clang-format",
      cpp = "clang-format"
    }
  }
})
```

## Implementation Plan

### Phase 1: Configuration Extension
**File:** `lua/reform/config.lua`

Add new configuration:
```lua
local defaults = {
  formatters = {
    paths = {
      -- Default: use system PATH for all
      ["autopep8"] = "PATH",
      ["black"] = "PATH", 
      ["ruff"] = "PATH",
      ["clang-format"] = "PATH",
      ["prettier"] = "PATH",
      ["eslint"] = "PATH",
      ["stylua"] = "PATH"
    },
    languages = {
      python = "autopep8",
      c = "clang-format",
      cpp = "clang-format",
      lua = "stylua",
      javascript = "prettier",
      typescript = "prettier"
    }
  }
}
```

### Phase 2: Formatter Updates

#### Update `lua/reform/formatters/base.lua`
```lua
---@class BaseFormatter
---@field executable_path string
---@field is_available fun(self): boolean, string|nil
```

#### Update `lua/reform/formatters/python.lua` 
```lua
-- Support multiple Python formatters with path configuration
local PythonFormatter = {
  formatters = {
    autopep8 = PythonAutopep8Formatter,
    black = PythonBlackFormatter, 
    ruff = PythonRuffFormatter
  }
}
```

#### Update `lua/reform/formatters/clang.lua`
```lua
-- Use configurable clang-format path
local ClangFormatter = {
  executable_path = "clang-format",
  format = function(self, text, filetype, line_range)
    -- Use self.executable_path instead of hard-coded
  end
}
```

### Phase 3: Path Resolution

**File:** `lua/reform/utils.lua`
```lua
local function resolve_formatter_path(name, config_path)
  if config_path == "" then return nil end  -- Disabled
  if config_path == "PATH" then return name end  -- System PATH
  return config_path  -- Custom path
end

local function check_formatter_available(path)
  if path == nil then return false end
  return vim.fn.executable(path) == 1
end
```

## Configuration Examples

### System PATH Only
```lua
require('reform').setup({})
-- Uses: autopep8, clang-format from system PATH
```

### Mason Integration
```lua
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
require('reform').setup({
  formatters = {
    paths = {
      ["ruff"] = mason_bin .. "/ruff",
      ["black"] = mason_bin .. "/black", 
      ["clang-format"] = mason_bin .. "/clang-format",
      ["prettier"] = mason_bin .. "/prettier",
      ["stylua"] = mason_bin .. "/stylua"
    },
    languages = {
      python = "ruff",
      c = "clang-format", 
      cpp = "clang-format",
      lua = "stylua",
      javascript = "prettier"
    }
  }
})
```

### Disable Specific Formatters
```lua
require('reform').setup({
  formatters = {
    paths = {
      ["black"] = "",  -- Disable black
      ["eslint"] = ""  -- Disable eslint
    }
  }
})
```

### Custom Paths
```lua
require('reform').setup({
  formatters = {
    paths = {
      ["clang-format"] = "/opt/llvm/bin/clang-format",
      ["ruff"] = "~/bin/ruff"
    }
  }
})
```

## Validation

### Configuration Validation
- Ensure formatter names are in SUPPORTED_FORMATTERS
- Ensure language mappings are valid
- Warn about unavailable formatters

### Runtime Validation  
- Check executable availability
- Provide clear error messages
- Graceful fallback behavior

## API Additions

```lua
-- Get current formatter for language
reform.get_formatter(language) -- returns formatter name

-- Get formatter path
reform.get_formatter_path(formatter_name) -- returns path

-- Set formatter path
reform.set_formatter_path(formatter_name, path) -- path can be "", "PATH", or custom

-- List available formatters
reform.list_formatters() -- returns table of formatters and availability
```

## Backward Compatibility

- Default configuration uses system PATH
- Existing behavior preserved
- No breaking changes
- Gradual migration possible