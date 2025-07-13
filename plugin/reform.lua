-- ======================================================================
--
-- reform.lua - Prettify current line on Enter for NeoVim !!
--
-- Modular Lua implementation for NeoVim with extensible formatter support
--
-- ======================================================================

-- Load the main RTFormat module
local reform = require('reform')

-- Plugin is automatically initialized by the reform module
-- Users can customize behavior with:
--
-- require('reform').setup({
--   ctrl_enter = false,
--   on_insert_leave = true,
--   auto_enable = false,
--   supported_filetypes = { 'python', 'lua', 'c', 'cpp', 'javascript' }
-- })

-- The module provides these main functions:
-- reform.enable()     - Enable for current buffer
-- reform.disable()    - Disable for current buffer
-- reform.status()     - Get current status
-- reform.add_filetype(ft, formatter) - Add support for new filetype

return reform
