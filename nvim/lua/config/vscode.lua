if vim.g.vscode then
  local set = vim.keymap.set
  set({ "n" }, "z", vscode.action("editor.action.formatDocument"), { expr = true, desc = "Format document" })
else
end

return {}
