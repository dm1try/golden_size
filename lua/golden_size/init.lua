local GOLDEN_RATIO = 1.618

local function on_win_enter()
  local current_config = vim.api.nvim_win_get_config(0)
  if current_config['relative'] ~= '' then
    return
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
  on_win_enter = on_win_enter
}
