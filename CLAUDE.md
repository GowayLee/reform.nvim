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
│       └── utils.lua
├── plugin/
│   └── reform.lua
├── test.cpp
└── test.py
```

-   `.gitignore`: Specifies intentionally untracked files to ignore.
-   `CLAUDE.md`: Project instructions and guidelines for AI assistance.
-   `GEMINI.md`: Legacy project overview document.
-   `LICENSE`: The license under which the project is distributed.
-   `README.md`: General information about the project, features, requirements, and installation instructions.
-   `lua/reform/`: Contains the core Lua modules for the plugin.
-   `formatters/`: Directory containing individual formatter implementations.
-   `plugin/reform.lua`: The main entry point for the Neovim plugin, which loads the `reform` module.
-   `test.cpp`: Test file for C++ formatting.
-   `test.py`: Test file for Python formatting.

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
    -   **Purpose**: Provides a collection of utility functions used across the plugin for common tasks like message display, string manipulation, Neovim API interactions, and debugging.
    -   **Key Functions**: `error_msg`, `info_msg`, `parse_line`, `at_line_end`, `execute_keys`, `insert_multiline`, `completion_visible`, `get_mode`, `get_buf_var`, `set_buf_var`, `get_global_var`, `validate_filetype`, `create_augroup`, `safe_keymap_del`, `debug_log`, `time_function`, `deep_copy`, `trim`, `is_whitespace`.
    -   **Dependencies**: `vim` (Neovim API).

## 4. Development Guidelines

- When working with lua, Claude needs to maintain well-defined type annotations of lua.
- Follow existing code style and conventions.
- Use descriptive variable names and function names.
- Add appropriate error handling and user feedback.
- Test changes with both Python and C++ formatters.
- Ensure all public API functions are documented.
- Remember to include explicit type annotations for lua programming.