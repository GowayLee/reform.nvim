# Reform.nvim Mason Integration Plan

## Overview

This document outlines the planned integration between reform.nvim and Mason to leverage Mason's package management capabilities for formatters while maintaining the existing lightweight, real-time formatting architecture.

## Problem Statement
The current reform.nvim uses built-in formatters (autopep8 for Python, clang-format for C/C++) that require manual installation. Mason provides a robust package management system for Neovim that could automate formatter installation and management.

## Architecture Design

### 1. Mason Formatter Bridge

A new `MasonFormatter` class will wrap Mason-installed formatters while maintaining compatibility with the existing BaseFormatter interface.

**Key Features:**
- Wraps Mason-installed formatters (stylua, prettier, black, etc.)
- Uses Mason's registry to discover available formatters
- Provides unified interface with existing BaseFormatter system
- Supports both Mason and built-in formatters seamlessly

### 2. Configuration Enhancement

The configuration system will be extended to support:
- Mason formatter mapping per filetype
- Auto-install formatters via Mason
- Fallback to built-in formatters when Mason unavailable
- User-configurable formatter preferences

### 3. Integration Points

#### A. Mason Registry Integration
- Use `require("mason-registry")` to query available formatters
- Implement formatter discovery and availability checking
- Support Mason package installation triggers

#### B. Formatter Resolution Strategy
1. **Priority Order:**
   - Check Mason-installed formatters first
   - Fall back to built-in formatters (python, clang)
   - Provide clear error messages for missing formatters

2. **Availability Checking:**
   - Query Mason registry for installed packages
   - Verify executable availability in Mason's bin directory
   - Graceful degradation when packages unavailable

#### C. Auto-installation Support
- Add Mason package installation for missing formatters
- Provide user prompts for formatter installation
- Track installation status and retry mechanisms

## Implementation Phases

### Phase 1: Core Mason Integration

#### 1.1 Create Mason Formatter Class
**File:** `lua/reform/formatters/mason.lua`

```lua
---@class MasonFormatter : BaseFormatter
---@field package_name string Mason package name
---@field executable string Executable name
---@field args string[] Command-line arguments
local MasonFormatter = setmetatable({}, { __index = BaseFormatter })
```

**Responsibilities:**
- Implement BaseFormatter interface
- Handle Mason package discovery
- Execute formatter commands using Mason binaries
- Provide proper error handling

#### 1.2 Update Formatters Registry
**File:** `lua/reform/formatters.lua`

**Changes:**
- Add Mason formatter registration
- Modify formatter resolution to include Mason formatters
- Update availability checking
- Support dynamic formatter loading

#### 1.3 Configuration Extension
**File:** `lua/reform/config.lua`

**New Configuration Options:**
```lua
mason_integration = {
  enabled = true,           -- Enable Mason integration
  auto_install = true,      -- Auto-install missing formatters
  formatters = {            -- Mason formatter mapping
    lua = 'stylua',
    javascript = 'prettier',
    typescript = 'prettier',
    python = 'black',
    c = 'clang-format',
    cpp = 'clang-format'
  }
}
```

### Phase 2: Enhanced User Experience

#### 2.1 Auto-installation Commands
- `:ReformInstallFormatter` - Install formatter for current filetype
- `:ReformInstallAll` - Install all configured formatters
- Integration with Mason's UI for installation progress

#### 2.2 Status and Diagnostics
- Enhanced `reform.status()` to show Mason integration
- Clear error messages for missing formatters
- Installation status tracking
- Debug information for troubleshooting

### Phase 3: Advanced Features

#### 3.1 Smart Formatter Selection
- Priority-based formatter selection
- User-configurable formatter preferences
- Language-specific formatter chains
- Override mechanism for specific projects

#### 3.2 Mason Registry Caching
- Cache Mason registry queries for performance
- Background registry refresh
- Offline mode support
- Registry update notifications

## File Structure Changes

```
lua/reform/
├── formatters/
│   ├── mason.lua          # NEW: Mason formatter wrapper
│   ├── base.lua          # Existing: Base class
│   ├── python.lua        # Existing: Python formatter
│   └── clang.lua         # Existing: C/C++ formatter
├── mason_integration.lua  # NEW: Mason registry integration
├── config.lua            # Updated: Configuration with Mason support
└── ...
```

## Configuration Examples

### Basic Configuration
```lua
require('reform').setup({
  mason_integration = {
    enabled = true,
    auto_install = true,
    formatters = {
      lua = 'stylua',
      javascript = 'prettier',
      typescript = 'prettier',
      python = 'black',
      c = 'clang-format',
      cpp = 'clang-format'
    }
  }
})
```

### Advanced Configuration
```lua
require('reform').setup({
  mason_integration = {
    enabled = true,
    auto_install = false,  -- Manual installation
    formatters = {
      lua = {
        package = 'stylua',
        args = { '--indent-type', 'Spaces', '--indent-width', '2' }
      },
      python = {
        package = 'black',
        args = { '--line-length', '88' }
      }
    }
  },
  -- Built-in formatters as fallback
  formatters = {
    cpp = 'clang-format'  -- Uses built-in when Mason unavailable
  }
})
```

## Backward Compatibility

- **All existing formatters remain functional**
- **Mason integration is optional** (opt-in via configuration)
- **Graceful degradation** when Mason unavailable
- **Existing configuration preserved**
- **No breaking changes** to public API

## Migration Path

### Phase 1: Optional Integration
- Mason integration available as optional feature
- Users can gradually adopt Mason formatters
- Built-in formatters remain default

### Phase 2: Migration Guide
- Documentation for migrating from built-in to Mason formatters
- Configuration examples for common use cases
- Troubleshooting guide for migration issues

### Phase 3: Future Considerations
- Potential default to Mason formatters in major version updates
- Deprecation timeline for built-in formatters
- Migration tools and automation

## API Reference

### New Public Functions

#### `reform.get_formatter_status(filetype)`
Returns detailed status including Mason integration information.

#### `reform.install_formatter(filetype)`
Installs formatter for specified filetype via Mason.

#### `reform.get_mason_formatters()`
Returns list of available Mason formatters.

### Configuration Schema

```typescript
interface MasonIntegrationConfig {
  enabled: boolean;
  auto_install: boolean;
  formatters: Record<string, string | FormatterConfig>;
}

interface FormatterConfig {
  package: string;
  executable?: string;
  args?: string[];
  version?: string;
}
```

## Testing Strategy

### Unit Tests
- MasonFormatter class functionality
- Configuration parsing and validation
- Formatter resolution logic
- Error handling scenarios

### Integration Tests
- Mason registry interaction
- Package installation workflow
- Formatter execution with Mason binaries
- Configuration reload scenarios

### Backward Compatibility Tests
- Existing configuration compatibility
- Built-in formatter fallback
- Mason unavailable scenarios
- Mixed formatter usage

## Error Handling

### Mason Integration Errors
- Registry unavailable
- Package installation failures
- Executable not found
- Version conflicts

### User Feedback
- Clear error messages
- Installation progress notifications
- Troubleshooting guidance
- Debug logging

## Security Considerations

- **Package verification** using Mason's built-in security
- **Path sanitization** for executable commands
- **Configuration validation** to prevent command injection
- **Sandboxing** formatter execution

## Performance Considerations

- **Registry caching** to reduce Mason API calls
- **Lazy loading** of formatter information
- **Background installation** without blocking editor
- **Minimal overhead** for existing functionality

## Dependencies

### Required
- Mason.nvim (williamboman/mason.nvim)
- Neovim 0.7+ (existing requirement)

### Optional
- mason-lspconfig.nvim (for enhanced integration)
- nvim-lspconfig (for language server integration)

## Conclusion

This integration plan provides a comprehensive roadmap for adding Mason support to reform.nvim while maintaining backward compatibility and enhancing the user experience. The phased approach ensures stability and allows for gradual adoption by users.
