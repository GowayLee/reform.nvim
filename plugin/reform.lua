-- ======================================================================
--
-- reform.lua - Prettify current line on Enter for NeoVim !!
--
-- Simplified Lua implementation for NeoVim with built-in formatter support
--
-- ======================================================================

-- Load the main Reform module
local reform = require("reform")

-- Plugin is automatically initialized by the reform module
-- Users can customize behavior with:
--
-- require('reform').setup({
--   on_insert_leave = true,           -- Enable formatting when leaving insert mode
--   auto_enable = {
--     enabled = false,                -- Master switch for auto-enable
--     filetypes = {                   -- Filetypes to auto-enable
--       'python', 'lua', 'java', 'javascript', 'json', 'actionscript', 'ruby', 'c', 'cpp'
--     },
--     exclude_filetypes = {}          -- Filetypes to exclude from auto-enable
--   },
--   formatters = {                    -- Formatters for each language
--     python = 'autopep8',
--     c = 'clang-format',
--     cpp = 'clang-format'
--   },
--   debug = false                     -- Enable debug info
-- })

-- The module provides these main functions:
-- reform.setup(config)     - Initialize with custom configuration
-- reform.enable()          - Enable for current buffer
-- reform.disable()         - Disable for current buffer
-- reform.check_formatter() - Check if formatter is available for filetype
-- reform.status()          - Get current status

return reform
