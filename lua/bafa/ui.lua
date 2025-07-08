--- @class bafa.ui.BufferWindow
--- @field bufnr number The buffer number
--- @field win_id number The window ID

local DIAGNOSTICS_LABELS = { "Error", "Warn", "Info", "Hint" }
local DIAGNOSTICS_SIGNS = { " ", " ", " ", " " }

local Config = require("bafa.config")
local BufferUtils = require("bafa.utils.buffers")
local Keymaps = require("bafa.utils.keymaps")
local Autocmds = require("bafa.utils.autocmds")
local _, Devicons = pcall(require, "nvim-web-devicons")
local Sorting = require("bafa.utils.sorting")

local BAFA_NAMESPACE_ID = vim.api.nvim_create_namespace("bafa.nvim")

local BAFA_WINDOW_ID = nil --- @type integer | nil
local BAFA_BUFFER_ID = nil --- @type integer | nil

--- Check if the window id is valid
---
--- @return boolean
local function is_valid_window_id()
  return BAFA_WINDOW_ID ~= nil and vim.api.nvim_win_is_valid(BAFA_WINDOW_ID)
end

--- Check if the buffer id is valid
---
--- @return boolean
local function is_valid_buffer_id()
  return BAFA_BUFFER_ID ~= nil and vim.api.nvim_buf_is_valid(BAFA_BUFFER_ID)
end

--- Get the diagnostics for a buffer
---
---@param buffer_number number
---@return table<string, string>
local function get_diagnostics(buffer_number)
  local count = vim.diagnostic.count(buffer_number)
  local diagnostics = {}

  for key, value in pairs(count) do
    local defined_sign = vim.fn.sign_getdefined("DiagnosticSign" .. DIAGNOSTICS_LABELS[key])
    local sign_icon = #defined_sign ~= 0 and defined_sign[1].text or DIAGNOSTICS_SIGNS[key]

    table.insert(diagnostics, { tostring(value) .. sign_icon, "DiagnosticSign" .. DIAGNOSTICS_LABELS[key] })
  end

  return diagnostics
end

--- Get the icon and highlight group for a buffer
---
---@param buffer table
---@return string, string
local function get_buffer_icon(buffer)
  if Devicons == nil then
    return "", "Normal" -- fallback to default icon, when devicons is not available
  end

  local icon, icon_hl = Devicons.get_icon(buffer.name, buffer.extension, { default = true })

  return icon, icon_hl
end

local function close_window()
  if not is_valid_window_id() then
    return
  end

  --- @cast BAFA_WINDOW_ID -nil

  vim.api.nvim_win_close(BAFA_WINDOW_ID, true)

  BAFA_WINDOW_ID = nil
  BAFA_BUFFER_ID = nil
end

--- Create a new window for the buffer menu
---
--- @return bafa.ui.BufferWindow
local function create_window()
  local bafa_config = Config.get()
  local buffer_number = vim.api.nvim_create_buf(false, false)

  local max_width = vim.api.nvim_win_get_width(0)
  local max_height = vim.api.nvim_win_get_height(0)

  local buffer_longest_name_width = BufferUtils.get_width_longest_buffer_name()
  local buffer_lines = BufferUtils.get_lines_buffer_names()

  -- preserve space for the icons
  local width = math.min(max_width, buffer_longest_name_width + 10)
  local height = math.min(max_height, buffer_lines + 2)

  local row_position = math.floor(((vim.o.lines - (bafa_config.height or height)) / 2) - 1)
  local col_position = math.floor((vim.o.columns - (bafa_config.width or width)) / 2)

  BAFA_WINDOW_ID = vim.api.nvim_open_win(buffer_number, true, {
    title = bafa_config.title,
    title_pos = bafa_config.title_pos,
    relative = bafa_config.relative,
    border = bafa_config.border,
    width = bafa_config.width or width,
    height = bafa_config.height or height,
    row = row_position,
    col = col_position,
    style = bafa_config.style,
  })

  vim.wo[BAFA_WINDOW_ID].winhighlight = "NormalFloat:BafaBorder"

  return {
    bufnr = buffer_number,
    win_id = BAFA_WINDOW_ID,
  }
end

local M = {}

--- Select the menu item based on the cursor position
function M.select_menu_item()
  local selected_line_number = vim.api.nvim_win_get_cursor(0)[1]
  local selected_buffer = BufferUtils.get_buffer_by_index(selected_line_number)

  if selected_buffer == nil then
    return
  end

  close_window()
  vim.api.nvim_set_current_buf(selected_buffer.number)
end

--- Delete the selected buffer
function M.delete_menu_item()
  local choice = 1

  if not is_valid_buffer_id() then
    return
  end

  --- @cast BAFA_BUFFER_ID -nil

  local selected_line_number = vim.api.nvim_win_get_cursor(0)[1]
  local selected_buffer = BufferUtils.get_buffer_by_index(selected_line_number)

  if selected_buffer == nil then
    return
  end

  if vim.bo[selected_buffer.number].modified then
    choice = vim.fn.inputlist({ "Yes", "No" })
  end

  if choice ~= 1 then
    return
  end

  if selected_line_number == 1 then
    close_window()
    vim.api.nvim_buf_delete(selected_buffer.number, { force = true })

    M.toggle()

    return
  end

  vim.api.nvim_buf_delete(selected_buffer.number, { force = true })
  vim.api.nvim_buf_set_lines(BAFA_BUFFER_ID, selected_line_number - 1, selected_line_number, false, {})

  M.draw_window()
end

function M.delete_multiple_menu_items()
  local choice = 1

  if not is_valid_buffer_id() then
    return
  end

  --- @cast BAFA_BUFFER_ID -nil

  local start = vim.fn.getpos("v")[2]
  local end_ = vim.fn.getpos(".")[2]

  if start > end_ then
    start, end_ = end_, start
  end

  local deleted_self = start == 1

  local buffers = BufferUtils.get_buffers_as_table()

  for line_number = start, end_ do
    local selected_buffer = buffers[line_number]

    if selected_buffer == nil then
      return
    end

    if vim.bo[selected_buffer.number].modified then
      choice = vim.fn.inputlist({ "Yes", "No" })
    end

    if choice == 1 then
      vim.api.nvim_buf_delete(selected_buffer.number, { force = true })
    end
  end

  vim.api.nvim_buf_set_lines(BAFA_BUFFER_ID, start - 1, end_, false, {})

  M.draw_window()

  if deleted_self then
    close_window()
    M.toggle()
  end

  vim.api.nvim_input("<esc>")
end

function M.cycle_sort()
  local config = Config.get()

  local sort_algorithm = config.sorting_algorithm
  local sort_algorithm_index = Sorting.get_sort_algorithm_index(sort_algorithm)

  print(sort_algorithm_index)

  if sort_algorithm_index == nil then
    return
  end

  local algorithms = Sorting.get_sorting_algorithm_names()
  print("algorithms", vim.inspect(algorithms))

  local next_algorithm_index = (sort_algorithm_index + 1)

  if next_algorithm_index > #algorithms then
    next_algorithm_index = 1
  end

  local next_algorithm = algorithms[next_algorithm_index]
  print(next_algorithm)

  config.sorting_algorithm = next_algorithm
  Config.set(config)

  M.draw_window()
end

--- Function to handle the menu save action
function M.on_menu_save()
  print(vim.inspect("on_menu_save"))
end

--- Add highlight to the buffer icon
---@param index number
---@param buffer table
---@return nil
local function add_ft_icon_highlight(index, buffer)
  if BAFA_BUFFER_ID == nil then
    return
  end
  local _, icon_hl_group = get_buffer_icon(buffer)
  local icon_hl = vim.api.nvim_get_hl(0, { name = icon_hl_group }).fg
  local hl_group = "BafaIcon" .. tostring(index)

  local line = index - 1
  local start = { line, 2 }
  local end_ = { line, 3 }

  vim.api.nvim_set_hl(0, hl_group, { fg = string.format("#%06x", icon_hl) })
  vim.hl.range(BAFA_BUFFER_ID, BAFA_NAMESPACE_ID, hl_group, start, end_)
end

--- Colors the buffer name if it is modified
---@param index number
---@param buffer table
local function add_modified_highlight(index, buffer)
  if BAFA_BUFFER_ID == nil then
    return
  end

  if not buffer.is_modified then
    return
  end

  local hl_name = "BafaModified"
  local hl = vim.api.nvim_get_hl(0, { name = hl_name, create = false })
  local fg = "#ffff00"

  if #hl ~= 0 then
    fg = string.format("#%06x", hl.fg)
  end

  local line = index - 1
  local start = { line, 0 }
  local end_ = { line, -1 }

  vim.api.nvim_set_hl(0, hl_name, { fg = fg })
  vim.hl.range(BAFA_BUFFER_ID, BAFA_NAMESPACE_ID, hl_name, start, end_)
end

--- Add diagnostics icons to the buffer menu
---
---@param index number
---@param buffer table
---@return boolean
local function add_diagnostics_icons(index, buffer)
  if BAFA_BUFFER_ID == nil then
    return false
  end

  local has_diagnostics = false

  local diagnostics = get_diagnostics(buffer.number)

  for _, diagnostic in ipairs(diagnostics) do
    vim.api.nvim_buf_set_extmark(BAFA_BUFFER_ID, BAFA_NAMESPACE_ID, index - 1, 0, {
      virt_text = { { diagnostic[1], diagnostic[2] } },
    })
    has_diagnostics = true
  end

  return has_diagnostics
end

--- Toggle the buffer menu
function M.toggle()
  local config = Config.get()

  if is_valid_window_id() then
    close_window()
    return
  end

  local win_info = create_window()

  BAFA_WINDOW_ID = win_info.win_id
  BAFA_BUFFER_ID = win_info.bufnr

  M.draw_window()

  Keymaps.set_noop_keys(BAFA_BUFFER_ID, config.noop_keys)
  Keymaps.set_keymaps(BAFA_BUFFER_ID, config.keymaps)

  Autocmds.set_defaults(BAFA_BUFFER_ID)
end

function M.draw_window()
  if not is_valid_window_id() or not is_valid_buffer_id() then
    return
  end

  --- @cast BAFA_BUFFER_ID -nil
  --- @cast BAFA_WINDOW_ID -nil

  local config = Config.get()

  local contents = {}
  local valid_buffers = BufferUtils.get_buffers_as_table()

  local current_buffer_index = nil
  for index, buffer in ipairs(valid_buffers) do
    local icon, _ = get_buffer_icon(buffer)

    if config.icons then
      contents[index] = string.format("%s %s", icon, buffer.name)
    else
      contents[index] = buffer.name
    end

    if buffer.current then
      current_buffer_index = index
    end
  end

  vim.wo[BAFA_WINDOW_ID].number = true
  vim.api.nvim_buf_set_name(BAFA_BUFFER_ID, "bafa-menu")
  vim.api.nvim_buf_set_lines(BAFA_BUFFER_ID, 0, #contents, false, contents)
  vim.bo[BAFA_BUFFER_ID].buftype = "nofile"
  vim.bo[BAFA_BUFFER_ID].bufhidden = "delete"

  local has_diagnostics = false

  for index, buffer in ipairs(valid_buffers) do
    if config.icons then
      add_ft_icon_highlight(index, buffer)
    end

    add_modified_highlight(index, buffer)

    if config.diagnostics then
      if add_diagnostics_icons(index, buffer) == true then
        has_diagnostics = true
      end
    end
  end

  if has_diagnostics then
    -- increase the width of the window to accommodate the diagnostics icons
    vim.api.nvim_win_set_width(BAFA_WINDOW_ID, vim.api.nvim_win_get_width(BAFA_WINDOW_ID) + 4)
  end

  if config.current_buffer_sign ~= false then
    -- Show '>' in the sign column for the current buffer
    if current_buffer_index ~= nil then
      vim.api.nvim_buf_set_extmark(BAFA_BUFFER_ID, BAFA_NAMESPACE_ID, current_buffer_index - 1, 0, {
        sign_text = config.current_buffer_sign,
        sign_hl_group = "BafaCurrentBuffer",
      })
    end
  end


  local title = config.title

  title = string.gsub(title, "%%count", tostring(#valid_buffers))
  title = string.gsub(title, "%%sort", config.sorting_algorithm)


  vim.api.nvim_win_set_config(BAFA_WINDOW_ID, { title = title })
end

return M
