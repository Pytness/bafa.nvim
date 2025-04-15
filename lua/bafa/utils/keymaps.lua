local M = {}

local noop_keys = {
  "i",
  "I",
  "a",
  "A",
  "o",
  "O",
  "s",
  "S",
  "c",
  "C",
  "r",
  "u",
  "U",
  "v",
}

local default_keymaps = {
  { "n", "q", "<Cmd>lua require('bafa.ui').toggle()<CR>", { silent = true } },
  { "n", "<ESC>", "<Cmd>lua require('bafa.ui').toggle()<CR>", { silent = true } },
  { "n", "<CR>", "<Cmd>lua require('bafa.ui').select_menu_item()<CR>", {} },
  { "n", "dd", "<Cmd>lua require('bafa.ui').delete_menu_item()<CR>", {} },
  { "n", "D", "<Cmd>lua require('bafa.ui').delete_menu_item()<CR>", {} },
  { "v", "d", "<Cmd>lua require('bafa.ui').delete_multiple_menu_items()<CR>", {} },
  { "n", "s", "<Cmd>lua require('bafa.ui').cycle_sort()<CR>", {} },
}

--- Set the keymaps for a buffer as a noop
---
--- @param buffer_number integer The buffer number
--- @param keys table | nil The keys to set as noop
function M.set_noop_keys(buffer_number, keys)
  keys = keys or noop_keys

  for _, key in ipairs(noop_keys) do
    vim.api.nvim_buf_set_keymap(buffer_number, "n", key, "", { silent = true })
  end
end

--- Set the keymaps for a buffer
---
--- @param buffer_number integer The buffer number
--- @param keymaps table | nil The keymaps to set
function M.set_keymaps(buffer_number, keymaps)
  keymaps = keymaps or default_keymaps

  for _, keymap in ipairs(keymaps) do
    local mode = keymap[1]
    local key = keymap[2]
    local action = keymap[3]
    local options = keymap[4] or {}

    options.buffer = buffer_number

    vim.keymap.set(mode, key, action, options)
  end
end

return M
