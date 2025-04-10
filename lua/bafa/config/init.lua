local M = {}

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
}

M.options = M.defaults

function M.setup(config)
  M.options = vim.tbl_deep_extend("force", M.defaults, config or {})
end

function M.set(config)
  M.options = vim.tbl_deep_extend("force", M.options, config or {})
end

function M.get()
  return M.options
end

return M
