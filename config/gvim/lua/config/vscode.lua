local createKeyMap = require "config.keymap"
local keymap = createKeyMap()

local createMotions = require "config.motions"
local motions = createMotions(keymap)
local keymaps = { defaults = motions.defaults(), buffers = motions.buffers() }
for _, func in ipairs(keymaps) do
    func()
end

return {}
