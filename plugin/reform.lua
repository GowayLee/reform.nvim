-- ======================================================================
--
-- reform.lua - Prettify current line on Enter for NeoVim !!
--
-- Modular Lua implementation for NeoVim with extensible formatter support
--
-- ======================================================================

-- Load the main RTFormat module
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
-- reform.enable()     - Enable for current buffer
-- reform.disable()    - Disable for current buffer
-- reform.status()     - Get current status
-- reform.add_filetype(ft, formatter) - Add support for new filetype

return reform
