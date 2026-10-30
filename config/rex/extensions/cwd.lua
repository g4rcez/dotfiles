-- Working directory of a terminal block, as a plain path.
-- The terminal reports pwd as a file://host/path URL, percent-encoded, when the shell sends OSC 7.
---@param block_id string
---@return string|nil
return function(block_id)
  local pwd = rex.block.call("com.superlogical.terminal", "pwd", { block_id = block_id })
  if not (pwd and pwd.pwd) then return nil end
  return (pwd.pwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end
