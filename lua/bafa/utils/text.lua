local M = {}

--- Get the base path from a file path
---
--- @param file_path string The file path to extract the base path from
--- @return string The base path of the file
function M.get_base_path_from_file_path(file_path)
  local base_path = file_path:match("(.*/)")
  return base_path
end

--- Get the file name from a file path
---
--- @param file_path string The file path to extract the file name from
--- @return string The file name of the file
function M.get_file_name_from_file_path(file_path)
  local file_name = file_path:match("([^/]+)$")
  return file_name
end

--- Get the file path relative to the current working directory
---
--- @param file_path string The file path to extract the file name from
--- @return string The file path relative to the current working directory
function M.get_normalized_path(file_path)
  local relative_path = vim.fn.fnamemodify(file_path, ":.")
  return relative_path
end

return M
