--- @class bafa.config.sorting_algorithm_enum
--- @field LAST_USED string
--- @field NAME string
--- @field MODIFIED string

--- @class bafa.config.config
--- @field title string The title of the Bafa menu
--- @field title_pos string The position of the title
--- @field relative string The relative position of the Bafa menu
--- @field border string The border style of the Bafa menu
--- @field style string The style of the Bafa menu
--- @field diagnostics boolean Whether to show diagnostics
--- @field icons boolean Whether to show icons
--- @field keymaps table<string> | nil The keymaps for the Bafa menu
--- @field noop_keys table<string> | nil The keys to ignore in the Bafa menu
--- @field sorting_algorithm string The sorting algorithm for the Bafa menu

local M = {}

--- @type bafa.config.sorting_algorithm_enum
M.SortingAlgorithm = {
  LAST_USED = "last_used",
  NAME = "name",
  MODIFIED = "modified",
}

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

  sorting_algorithm = M.SortingAlgorithm.LAST_USED,
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
