-- TokyoNight, ported from dotfiles/config/ghostty/config (theme = TokyoNight).
-- Rex has no global theme setting: a theme belongs to each terminal block.
local M = {}

M.theme = {
  foreground = "#c0caf5",
  background = "#1a1b26",
  cursor = "#c0caf5",
  scheme = "dark",
  palette = {
    "0=#15161e", "1=#f7768e", "2=#9ece6a", "3=#e0af68",
    "4=#7aa2f7", "5=#bb9af7", "6=#7dcfff", "7=#a9b1d6",
    "8=#414868", "9=#f7768e", "10=#9ece6a", "11=#e0af68",
    "12=#7aa2f7", "13=#bb9af7", "14=#7dcfff", "15=#c0caf5",
  },
}

function M.apply(block_id)
  local args = { block_id = block_id }
  for k, v in pairs(M.theme) do args[k] = v end
  local _, err = rex.block.call("com.superlogical.terminal", "set_theme", args)
  return err
end

return M
