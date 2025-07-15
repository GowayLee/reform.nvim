# CLAUDE.md for reform.nvim

This document provides an overview of the `reform.nvim` project, its structure, and guidelines for AI assistance.

## 1. Overview

`reform.nvim` is a simple and lightweight Neovim plugin written in Lua for real-time code formatting. It automatically formats code on pressing `Enter` (newline) and can also format when leaving insert mode. It supports different languages and integrates with external formatters like `autopep8` for Python and `clang-format` for C/C++.

## 2. Project Structure

```
reform.nvim/
├── .gitignore
├── CLAUDE.md
├── GEMINI.md
├── LICENSE
├── README.md
├── docs/
│   └── formatter-configuration.md
├── lua/
│   └── reform/
│       ├── config.lua
│       ├── core.lua
│       ├── formatters.lua
│       ├── formatters/
│       │   ├── base.lua
│       │   ├── clang.lua
│       │   └── python.lua
│       ├── init.lua
│       ├── utils.lua
│       └── utils/
│           ├── autocmd.lua
│           ├── buffer.lua
│           ├── init.lua
│           ├── log.lua
│           ├── state.lua
│           ├── system.lua
│           ├── text.lua
│           └── validation.lua
└── plugin/
    └── reform.lua
```

-   `.gitignore`: Specifies intentionally untracked files to ignore.
-   `CLAUDE.md`: Project instructions and guidelines for AI assistance.
-   `GEMINI.md`: Legacy project overview document.
-   `LICENSE`: The license under which the project is distributed.
-   `README.md`: General information about the project, features, requirements, and installation instructions.
-   `docs/`: Documentation files for configuration and usage.
-   `lua/reform/`: Contains the core Lua modules for the plugin.
-   `formatters/`: Directory containing individual formatter implementations.
-   `utils/`: Modularized utility functions for better code organization.
-   `plugin/reform.lua`: The main entry point for the Neovim plugin, which loads the `reform` module.

## 3. Lua Modules

-   `lua/reform/init.lua`:
    -   **Purpose**: The main entry point for the `reform` plugin's Lua functionality. It orchestrates the setup and provides the public API for the plugin.
    -   **Key Functions**: `setup` (initializes configuration and core), `enable`, `disable`, `add_filetype`, `register_formatter`, `get_config`, `is_supported`, `check_formatter`, `format_text`, `status`, `print_status`.
    -   **Dependencies**: `reform.config`, `reform.core`, `reform.formatters`, `reform.utils`.

-   `lua/reform/config.lua`:
    -   **Purpose**: Manages the plugin's configuration, including default settings, user overrides, and global Vim variable integration.
    -   **Key Functions**: `setup` (merges user config with defaults), `get`, `set`, `is_supported_filetype`, `add_filetype`, `get_formatter`.
    -   **Dependencies**: `vim` (Neovim API).

-   `lua/reform/core.lua`:
    -   **Purpose**: Contains the core logic for real-time formatting, including handling `Enter` key presses and `InsertLeave` events.
    -   **Key Functions**: `format_line`, `real_time_format_code` (main formatting trigger), `on_insert_leave`, `check_enable`, `enable`, `disable`, `setup` (for user commands and autocommands), `get_state`.
    -   **Dependencies**: `reform.config`, `reform.formatters`, `reform.utils`.

-   `lua/reform/formatters.lua`:
    -   **Purpose**: Defines and manages different code formatters (e.g., `autopep8`, `clang-format`) and provides an interface for formatting text.
    -   **Key Functions**: `get_formatter`, `register_formatter`, `format`, `is_available`.
    -   **Dependencies**: `reform.config`, `reform.utils`, individual formatter modules.

-   `lua/reform/formatters/base.lua`:
    -   **Purpose**: Abstract base class for all formatters providing common interface and utilities.

-   `lua/reform/formatters/python.lua`:
    -   **Purpose**: Python formatter implementation using `autopep8`.

-   `lua/reform/formatters/clang.lua`:
    -   **Purpose**: C/C++ formatter implementation using `clang-format`.

-   `lua/reform/utils.lua`:
    -   **Purpose**: Legacy utilities module (being refactored into modular components).
    -   **Dependencies**: `vim` (Neovim API).

-   `lua/reform/utils/`:
    -   **Purpose**: Modularized utility functions organized by functionality.
    -   **Key modules**:
        -   `autocmd.lua`: Autocommand management utilities
        -   `buffer.lua`: Buffer manipulation and state management
        -   `init.lua`: Main utilities entry point
        -   `log.lua`: Logging and debugging utilities
        -   `state.lua`: Plugin state management
        -   `system.lua`: System-level utilities and commands
        -   `text.lua`: Text processing and manipulation
        -   `validation.lua`: Input validation and type checking

## 4. Development Guidelines

- When working with lua, Claude needs to maintain well-defined type annotations
- Follow existing code style and conventions.
- Use descriptive variable names and function names.
- Add appropriate error handling and user feedback.
- Ensure all public API functions are documented.
