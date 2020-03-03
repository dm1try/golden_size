# Golden Size

This is a Neovim plugin for automatically resizing the active window to the ["golden"](https://en.wikipedia.org/wiki/Golden_ratio) size.

![demo](demo.gif)

## Installation

Add plugin to the runtime path.

### Vim-Plug 

```VimL
Plug 'dm1try/golden_size'

```

## Tips and tricks
### Disable automatic resizing for specific windows

```viml
lua << EOF
local function ignore_by_buftype(types)
  local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
  for _, type in pairs(types) do
    if type == buftype then
      return 1
    end
  end
end

local golden_size = require("golden_size")
-- set the callbacks, preserve the defaults
golden_size.set_ignore_callbacks({
  { ignore_by_buftype, {'terminal','quickfix', 'nerdtree'} },
  { golden_size.ignore_float_windows }, -- default one, ignore float windows
  { golden_size.ignore_by_window_flag }, -- default one, ignore windows with w:ignore_gold_size=1
})
EOF
``` 
### Global Toggle 
```lua
lua << EOF

vim.api.nvim_set_var("golden_size_off", 0)

function GoldenSizeToggle()
  local current_value = vim.api.nvim_get_var("golden_size_off")
  vim.api.nvim_set_var("golden_size_off", current_value == 1 and 0 or 1)
end

local function golden_size_ignore()
  return vim.api.nvim_get_var("golden_size_off")
end

local golden_size = require("golden_size")
-- set the callbacks, preserve the defaults
golden_size.set_ignore_callbacks({
  { golden_size_ignore },
  ...
})
EOF
``` 
## Inspiration

https://github.com/roman/golden-ratio
