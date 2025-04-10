local text_utils = require("bafa.utils.text")

local M = {}

--- Checks if a buffer is valid
---
--- @param buffer_number integer The number of the buffer
--- @return boolean # True if the buffer is valid, false otherwise
function M.is_valid_buffer(buffer_number)
  local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
  local is_listed = vim.bo[buffer_number].buflisted == true
  local is_not_bafa_buffer = buffer_name ~= "bafa-menu"

  return buffer_name ~= "" and is_not_bafa_buffer and is_listed
end

--- Get the length of the longest buffer name
---
--- @return integer # The length of the longest buffer name
function M.get_width_longest_buffer_name()
  local buffers = M.get_buffers_as_table()
  local longest_buffer_name = 0

  for _, buffer in ipairs(buffers) do
    local buffer_name = buffer.name

    local buffer_name_length = string.len(buffer_name)

    if buffer_name_length > longest_buffer_name then
      longest_buffer_name = buffer_name_length
    end
  end

  return longest_buffer_name
end

--- Get the number of buffers
---
--- @return integer The number of buffers
function M.get_lines_buffer_names()
  local buffers = M.get_buffers_as_table()
  return #buffers
end

--- Get the buffer name by index
---
--- @param buffer_index integer The index of the buffer
--- @return table | nil # The buffer name or nil if not found
function M.get_buffer_by_index(buffer_index)
  local buffer_numbers = M.get_buffers_as_table()
  local buffer = buffer_numbers[buffer_index]

  if buffer == nil then
    return nil
  end

  local buffer_number = buffer.number

  if buffer_number == nil then
    return nil
  end

  return buffer
end

--- Get the buffer name by number
---
--- @return table # A table of buffers information
function M.get_buffers_as_table()
  local buffers = {}
  local buffer_numbers = vim.api.nvim_list_bufs()

  for _, buffer_number in ipairs(buffer_numbers) do
    local is_valid_buffer = M.is_valid_buffer(buffer_number)

    if not is_valid_buffer then
      goto continue
    end

    local last_used = vim.fn.getbufinfo(buffer_number)[1].lastused
    local buffer_name = vim.api.nvim_buf_get_name(buffer_number)
    local buffer_file_name = text_utils.get_normalized_path(buffer_name) or "untitled"
    local is_modified = vim.bo[buffer_number].modified == true

    local buffer = {
      name = buffer_file_name,
      path = buffer_name,
      number = buffer_number,
      last_used = last_used,
      is_modified = is_modified,
    }

    table.insert(buffers, buffer)
    table.sort(buffers, function(a, b)
      return a.last_used > b.last_used
    end)

    ::continue::
  end

  return buffers
end

return M
