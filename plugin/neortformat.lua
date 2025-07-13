-- ======================================================================
--
-- neortformat.lua - Prettify current line on Enter for NeoVim !!
--
-- Modular Lua implementation for NeoVim with extensible formatter support
--
-- ======================================================================

-- Load the main RTFormat module
local rtformat = require('rtformat')

-- Plugin is automatically initialized by the rtformat module
-- Users can customize behavior with:
--
-- require('rtformat').setup({
--   ctrl_enter = false,
--   on_insert_leave = true,
--   auto_enable = false,
--   supported_filetypes = { 'python', 'lua', 'c', 'cpp', 'javascript' }
-- })

-- The module provides these main functions:
-- rtformat.enable()     - Enable for current buffer
-- rtformat.disable()    - Disable for current buffer
-- rtformat.status()     - Get current status
-- rtformat.add_filetype(ft, formatter) - Add support for new filetype

return rtformat
