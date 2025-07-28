local BaseFormatter = require("reform.formatters.base")

--- PEP8 rules for Python formatting
local pep8_rules = {
  "E101",
  "E11",
  "E121",
  "E122",
  "E123",
  "E124",
  "E125",
  "E126",
  "E127",
  "E128",
  "E129",
  "E131",
  "E133",
  "E20",
  "E211",
  "E22",
  "E224",
  "E225",
  "E226",
  "E227",
  "E228",
  "E231",
  "E241",
  "E242",
  "E251",
  "E252",
  "E27",
}

local pep8_python = vim.tbl_extend("force", {}, pep8_rules)
vim.list_extend(pep8_python, { "E26", "E265", "E266", "E", "W" })

---@class PythonFormatter : BaseFormatter
---@field py_version boolean|nil
---@field _availability_cache table|nil
local PythonFormatter = setmetatable({}, { __index = BaseFormatter })
PythonFormatter.__index = PythonFormatter

--- Create a new PythonFormatter instance
---@return PythonFormatter
function PythonFormatter:new()
  local instance = setmetatable({}, self)
  instance._availability_cache = nil
  if vim.fn.has("python3") == 1 then
    instance.py_version = true
  end
  return instance
end

--- Get formatter name
---@return string
function PythonFormatter:get_name()
  return "py-autopep8"
end

--- Check if the Python formatter is available (with caching)
---@return boolean
---@return string|nil error_message
function PythonFormatter:is_available()
  -- Return cached result if available
  if self._availability_cache ~= nil then
    return self._availability_cache.result, self._availability_cache.error
  end

  -- Cache the result
  self._availability_cache = {}

  if not self.py_version then
    self._availability_cache.result = false
    self._availability_cache.error = "require +python3 feature"
    return self._availability_cache.result, self._availability_cache.error
  end

  local code = [[
__i = 100
try:
    import autopep8
    __i = 1
except ImportError:
    __i = 0
]]

  local success, result = pcall(vim.fn.py3eval, 'exec("""' .. code .. '""") or __i')
  if not success or result == 0 then
    self._availability_cache.result = false
    self._availability_cache.error = "require python module autopep8"
    return self._availability_cache.result, self._availability_cache.error
  end

  self._availability_cache.result = true
  self._availability_cache.error = nil
  return self._availability_cache.result, self._availability_cache.error
end

--- Format Python code using autopep8
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function PythonFormatter:format(text, filetype)
  if text == "" then
    return text
  end

  local rules = (filetype == "python") and pep8_python or pep8_rules
  local rules_str = '["' .. table.concat(rules, '", "') .. '"]'

  local python_code = string.format(
    [[
import autopep8
__t = %q
__o = {'select': %s}
__result = autopep8.fix_code(__t, options=__o).strip()
]],
    text,
    rules_str
  )

  local success, result = pcall(vim.fn.py3eval, 'exec("""' .. python_code .. '""") or __result')
  if success and result then
    return result
  end

  return text
end

return PythonFormatter
