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

  resize_layout()
--  local columns = vim.api.nvim_get_option("columns")
--  local rows = vim.api.nvim_get_option("lines")
--  local current_height = vim.api.nvim_win_get_height(0)
--  local current_width = vim.api.nvim_win_get_width(0)
--  local golden_width = math.floor(columns/GOLDEN_RATIO)
--
--  if current_width < golden_width then
--    vim.api.nvim_win_set_width(0, golden_width)
--  end
--
--  local golden_height = math.floor(rows/GOLDEN_RATIO)
--  if current_height < golden_height then
--    vim.api.nvim_win_set_height(0, golden_height)
--  end
end

function resize_layout()
  local layout = vim.api.nvim_call_function("winlayout", {})
  local active_window_id = vim.api.nvim_call_function("win_getid", {})

  local max_width = vim.api.nvim_get_option("columns")
  local max_height = vim.api.nvim_get_option("lines")

  local golden_width = math.floor(max_width/GOLDEN_RATIO)
  local golden_height = math.floor(max_height/GOLDEN_RATIO)

  local remaining_total_width = max_width - golden_width
  local remaining_total_height = max_height - golden_height

  local horizontal_win_count, vertical_win_count = unpack(count_window_splits(active_window_id))

  local remaining_width_for_window = remaining_total_width
  local remaining_height_for_window = remaining_total_height

  if horizontal_win_count > 1  then
	  remaining_height_for_window = math.floor(remaining_total_height / horizontal_win_count)
  end

  if vertical_win_count > 1 then
	  remaining_width_for_window = math.floor(remaining_total_width / vertical_win_count)
  end

  if layout[1] == "row" then
    process_windows_row(layout[2], active_window_id, remaining_width_for_window - 1, remaining_height_for_window - 1)
  elseif layout[1] == "col" then
    process_windows_col(layout[2], active_window_id, remaining_width_for_window - 1, remaining_height_for_window - 1)
  end
end

function count_window_splits(active_window_id)
  local layout = vim.api.nvim_call_function("winlayout", {})

  local result = {0, 0}
  if layout[1] == "row" then
    count_row(layout[2], result, active_window_id)
  elseif layout[1] == "col" then
    count_col(layout[2], result, active_window_id)
  end
  return result
end

function count_col(blocks, result, active_window_id)
  for k,v in ipairs(blocks) do
    local block_key = v[1]

    if block_key == "leaf" then
      local window_id = v[2]
      if window_id == active_window_id then
        --ignore
      else
        result[1] = result[1] + 1
      end
    elseif block_key == "row" then
      local blocks = v[2]
      count_row(blocks, result, active_window_id)
    end
  end
end

function count_row(blocks, result, active_window_id)
  for k,v in ipairs(blocks) do
    local block_key = v[1]

    if block_key == "leaf" then
      local window_id = v[2]
      if window_id == active_window_id then
        --ignore
      else
        result[2] = result[2] + 1
      end
    elseif block_key == "col" then
      local blocks = v[2]
      count_col(blocks, result, active_window_id)
    end
  end
end

function process_windows_col(blocks, active_window_id, remaining_width_for_window, remaining_height_for_window)
  local first_not_active_leaf_set_width = false
  for k,v in ipairs(blocks) do
    local block_key = v[1]

    if block_key == "leaf" then
      local window_id = v[2]
      if window_id == active_window_id then
        local max_height = vim.api.nvim_get_option("lines")
        local golden_height = math.floor(max_height/GOLDEN_RATIO)
        vim.api.nvim_win_set_height(window_id, golden_height)
        first_not_active_leaf_set_width = true
      else
        --	      if first_not_active_leaf_set_width ~= true then
        --		      vim.api.nvim_win_set_width(window_id, remaining_width_for_window)
        --		      first_not_active_leaf_set_width = true
        --	      end
        vim.api.nvim_win_set_height(window_id, remaining_height_for_window)
      end
    elseif block_key == "row" then
      local blocks = v[2]
      process_windows_row(blocks, active_window_id, remaining_width_for_window, remaining_height_for_window)
    end
  end
end

function process_windows_row(blocks, active_window_id,remaining_width_for_window,remaining_height_for_window)
  local first_not_active_leaf_set_height = false

  for k,v in ipairs(blocks) do
    local block_key = v[1]
    if block_key == "leaf" then
      local window_id = v[2]
      if window_id == active_window_id then
        local max_width = vim.api.nvim_get_option("columns")

        local golden_width = math.floor(max_width/GOLDEN_RATIO)
        vim.api.nvim_win_set_width(active_window_id, golden_width)
        first_not_active_leaf_set_height = true

      else
        --	      if first_not_active_leaf_set_height ~= true then
        --		      vim.api.nvim_win_set_height(window_id, remaining_height_for_window)
        --		      first_not_active_leaf_set_height = true
        --	      end
        vim.api.nvim_win_set_width(window_id, remaining_width_for_window)
      end
    elseif block_key == "col" then
      local blocks = v[2]
      process_windows_col(blocks, active_window_id, remaining_width_for_window,remaining_height_for_window)
    end
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
