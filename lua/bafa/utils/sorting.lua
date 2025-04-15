--- @alias bafa.utils.sorting.AlgorithmName
--- | '"last_used"'
--- | '"name"'
--- | '"number"'

--- @class bafa.utils.sorting.AlgorithmEnum
--- @field LAST_USED '"last_used"' # Sort by last used
--- @field NAME '"name"' # Sort by name
--- @field NUMBER '"number"' # Sort by number

local M = {}

--- @type bafa.utils.sorting.AlgorithmEnum
M.Algorithm = {
  LAST_USED = "last_used",
  NAME = "name",
  NUMBER = "number",
}

--- Get sorting algorithm names
---
--- @return table<bafa.utils.sorting.AlgorithmName> # The sorting algorithm names
function M.get_sorting_algorithm_names()
  return {
    M.Algorithm.LAST_USED,
    M.Algorithm.NAME,
    M.Algorithm.NUMBER,
  }
end

--- Get the sorting algorithm index based on the given algorithm
---
--- @param algorithm bafa.utils.sorting.AlgorithmName The sorting algorithm
--- @return integer | nil # The sorting algorithm index
function M.get_sort_algorithm_index(algorithm)
  local algorithm_index = nil

  if algorithm == M.Algorithm.LAST_USED then
    algorithm_index = 1
  elseif algorithm == M.Algorithm.NAME then
    algorithm_index = 2
  elseif algorithm == M.Algorithm.NUMBER then
    algorithm_index = 3
  end

  return algorithm_index
end

--- Sort the buffers by last used
---
--- @param a bafa.utils.buffer_info The first buffer
--- @param b bafa.utils.buffer_info The second buffer
--- @return boolean
function M.sort_by_last_used(a, b)
  return a.last_used > b.last_used
end

--- Sort the buffers by name
---
--- @param a bafa.utils.buffer_info The first buffer
--- @param b bafa.utils.buffer_info The second buffer
--- @return boolean
function M.sort_by_name(a, b)
  return a.name < b.name
end

--- Sort the buffers by number
---
--- @param a bafa.utils.buffer_info The first buffer
--- @param b bafa.utils.buffer_info The second buffer
--- @return boolean
function M.sort_by_number(a, b)
  return a.number < b.number
end

--- Get the sorting algorithm based on the given algorithm
---
--- @param algorithm bafa.utils.sorting.AlgorithmEnum The sorting algorithm
--- @return function | nil # The sorting algorithm function
function M.get_sorting_algorithm(algorithm)
  local sorting_algorithm = nil

  if algorithm == M.Algorithm.NAME then
    sorting_algorithm = M.sort_by_name
  elseif algorithm == M.Algorithm.NUMBER then
    sorting_algorithm = M.sort_by_number
  elseif algorithm == M.Algorithm.LAST_USED then
    sorting_algorithm = M.sort_by_last_used
  end

  return sorting_algorithm
end

return M
