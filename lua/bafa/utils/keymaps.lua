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
}

local default_keymaps = {
  { "n", "q", "<Cmd>lua require('bafa.ui').toggle()<CR>", { silent = true } },
  { "n", "<ESC>", "<Cmd>lua require('bafa.ui').toggle()<CR>", { silent = true } },
  { "n", "<CR>", "<Cmd>lua require('bafa.ui').select_menu_item()<CR>", {} },
  { "n", "dd", "<Cmd>lua require('bafa.ui').delete_menu_item()<CR>", {} },
  { "n", "D", "<Cmd>lua require('bafa.ui').delete_menu_item()<CR>", {} },
  { "v", "d", "<Cmd>lua require('bafa.ui').delete_multiple_menu_items()<CR>", {} },
}
function M.noop(bufnr, keys)
  keys = keys or noop_keys

  for _, key in ipairs(noop_keys) do
    vim.api.nvim_buf_set_keymap(bufnr, "n", key, "", { silent = true })
  end
end

function M.defaults(bufnr, keymaps)
  keymaps = keymaps or default_keymaps

  for _, keymap in ipairs(keymaps) do
    local mode = keymap[1]
    local key = keymap[2]
    local action = keymap[3]
    local options = keymap[4] or {}

    options.buffer = bufnr

    vim.keymap.set(mode, key, action, options)
  end
end

return M
