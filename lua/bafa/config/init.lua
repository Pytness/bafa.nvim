--- @class bafa.config.config
--- The title of the Bafa menu
---
--- Allows multiple formatting options:
--- %count: The number of items in the menu
--- %sort: The current sorting algorithm used
---
--- Example: "Bafa (%count items, sorted by %sort)"
--- @field title string
--- @field title_pos string The position of the title
--- @field relative string The relative position of the Bafa menu
--- @field border string The border style of the Bafa menu
--- @field style string The style of the Bafa menu
--- @field width number | nil The width of the Bafa menu
--- @field height number | nil The height of the Bafa menu
--- @field diagnostics boolean Whether to show diagnostics
--- @field icons boolean Whether to show icons
--- @field keymaps table<string> | nil The keymaps for the Bafa menu
--- @field noop_keys table<string> | nil The keys to ignore in the Bafa menu
--- @field sorting_algorithm bafa.utils.sorting.AlgorithmName The sorting algorithm for the Bafa menu
--- @field show_sorting_algorithm boolean Whether to show the sorting algorithm in the Bafa menu
--- @field current_buffer_sign false | string False to disable, or a string to use as a sign for the buffer

local SortingAlgorithm = require("bafa.utils.sorting").Algorithm

local M = {}

--- @type bafa.config.config
M.defaults = {
  title = "Bafa",
  title_pos = "center",
  relative = "editor",
  border = "rounded",
  style = "minimal",

  diagnostics = true,
  icons = true,

  keymaps = nil,
  noop_keys = nil,

  sorting_algorithm = SortingAlgorithm.LAST_USED,
  show_sorting_algorithm = false,
  current_buffer_sign = '>',
}

M.options = M.defaults

--- Setup the configuration
---
--- @param config bafa.config.config The configuration table
--- @return nil
function M.setup(config)
  M.options = vim.tbl_deep_extend("force", M.defaults, config or {})
end

--- Set the configuration
---
--- @param config bafa.config.config The configuration table
--- @return nil
function M.set(config)
  M.options = vim.tbl_deep_extend("force", M.options, config or {})
end

--- Get the current configuration
---
--- @return bafa.config.config # The configuration table
function M.get()
  return M.options
end

return M
