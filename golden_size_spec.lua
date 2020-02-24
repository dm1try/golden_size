local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local nvim =  helpers.nvim
local clear, command = helpers.clear, helpers.command
local alter_slashes = helpers.alter_slashes
local eq = helpers.eq

describe('golden size', function()
 local screen
 local screen_width = 80

 before_each(function()
   clear()
   screen = Screen.new(screen_width, 20)
   screen:attach()

   -- TODO: do not hardcode path to the plugin source
   command('set rtp+=' .. alter_slashes('../golden_size/'))
   command('source ' .. alter_slashes('../golden_size/plugin/golden_size.vim'))
 end)

 after_each(function()
   screen:detach()
 end)

 it('resizes the active window to "golden" size', function()
   local expected_width = math.floor(screen_width / 1.618)

   eq(nvim('win_get_width', 0), screen_width)

   command('vsp')
   eq(nvim('win_get_width', 0), expected_width)
 end)

 function open_float_win(opts)
   local buf = nvim('create_buf', false, true)
   nvim('buf_set_lines', buf, 0, -1, true, {"test"})
   local opts = {relative='win', width=opts['width'], height=10, col=0, row=1}
   local win = nvim('open_win', buf, 0, opts)
   return win
 end

 it('does not resize float windows', function()
   local expected_width = 10
   local float_win = open_float_win({width = expected_width})
   nvim('set_current_win', float_win)
   eq(nvim('win_get_width', 0), expected_width)
 end)

 it('allows to set custom ignore callbacks', function()
   command('lua function ignore_all() return 1 end')
   command('lua golden_size.set_ignore_callbacks({ignore_all})')

   command('vsp')

   local default_width_after_split = screen_width / 2
   eq(nvim('win_get_width', 0), default_width_after_split)
 end)
end)
