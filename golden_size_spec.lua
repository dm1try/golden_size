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
end)
