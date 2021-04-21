local GOLDEN_RATIO = 1.618
local ignore_callbacks = {}

local function set_ignore_callbacks(callbacks)
  ignore_callbacks = callbacks
end

local function add_window_check_callback(callback_name, params)
   table.insert(ignore_callbacks, {callback_name, params})
end

local function ignore_float_windows()
  local current_config = vim.api.nvim_win_get_config(0)
  if current_config['relative'] ~= '' then
    return 1
  end
end

local function ignore_by_window_flag()
  local ignore_golden_size = 0

  local status, result = pcall(vim.api.nvim_win_get_var, 0, 'ignore_golden_size')
  if status then
    ignore_golden_size = result
  end

  if ignore_golden_size == 1 then
    return 1
  else
    return 0
  end
end

local DEFAULT_IGNORE_CALLBACKS = {{ignore_float_windows}, {ignore_by_window_flag}}
ignore_callbacks = DEFAULT_IGNORE_CALLBACKS

local function on_win_enter()
  for current_callback_index = 1, #ignore_callbacks do
    local callback = ignore_callbacks[current_callback_index][1]
    local callback_args = ignore_callbacks[current_callback_index][2]

    if callback(callback_args) == 1 then
      return
    end
  end

  local columns = vim.api.nvim_get_option("columns")
  local rows = vim.api.nvim_get_option("lines")
  local current_height = vim.api.nvim_win_get_height(0)
  local current_width = vim.api.nvim_win_get_width(0)
  local golden_width = math.floor(columns/GOLDEN_RATIO)

  if current_width < golden_width then
    vim.api.nvim_win_set_width(0, golden_width)
  end

  local golden_height = math.floor(rows/GOLDEN_RATIO)
  if current_height < golden_height then
    vim.api.nvim_win_set_height(0, golden_height)
  end
end

return {
  on_win_enter = on_win_enter,
  set_ignore_callbacks = set_ignore_callbacks,
  add_window_check_callback = add_window_check_callback,
  ignore_by_window_flag = ignore_by_window_flag,
  ignore_float_windows = ignore_float_windows,
  DEFAULT_IGNORE_CALLBACKS = DEFAULT_IGNORE_CALLBACKS,
  IGNORE_RESIZING = 1
}
