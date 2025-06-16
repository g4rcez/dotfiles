local function createMotions(mapper)
  local M = {}
  local DEFAULT_OPTS = mapper.DEFAULT_OPTS

  M.defaults = function()
    mapper.bind.normal("J", "mzJ`z", { desc = "Primeagen join lines" })
    mapper.bind.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
    mapper.bind.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
    mapper.bind.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
    mapper.bind.normal("<C-s>", "<cmd>:w<CR>", { desc = "Save" })
    mapper.bind.insert("<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
    mapper.bind.insert("<C-z>", "<Esc>ua", { desc = "Go to end in insert" })
    mapper.bind.normal("#", "#zz", { desc = "Center previous pattern" })
    mapper.bind.normal("*", "*zz", { desc = "Center next pattern" })
    mapper.bind.normal("+", "<C-a>", { desc = "Increment" })
    mapper.bind.normal("-", "<C-x>", { desc = "Decrement" })
    mapper.bind.normal("0", "^", { desc = "Goto first non-whitespace" })
    mapper.bind.visual("0", "^", { desc = "Goto first non-whitespace" })
    mapper.bind.normal("<BS>", '"_', { desc = "BlackHole register" })
    mapper.bind.visual("<BS>", '"_', { desc = "BlackHole register" })
    mapper.bind.normal(">", ">>", { desc = "Indent" })
    mapper.bind.normal("<", "<<", { desc = "Deindent" })
    mapper.bind.normal("vv", "V", { desc = "Select line" })
    mapper.bind.normal("j", "gj", DEFAULT_OPTS)
    mapper.bind.normal("k", "gk", DEFAULT_OPTS)
    mapper.bind.visual("<", "<gv", DEFAULT_OPTS)
    mapper.bind.visual("<leader>sr", "<cmd>!tail -r<CR>", { desc = "Reverse sort lines" })
    mapper.bind.visual("<leader>ss", "<cmd>sort<CR>", { desc = "Sort lines" })
    mapper.bind.visual(">", ">gv", DEFAULT_OPTS)
    mapper.bind.x("p", [["_dP]], DEFAULT_OPTS)
    mapper.bind.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
    mapper.bind.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })
    mapper.bind.normal("<leader>cq", vim.diagnostic.setloclist, { desc = "Open diagnostic [c]ode [q]uickfix list" })
  end

  local function navigate(n)
    local current = vim.api.nvim_get_current_buf()
    for i, v in ipairs(vim.t.bufs) do
      if current == v then
        local new_buf = vim.t.bufs[(i + n - 1) % #vim.t.bufs + 1]
        if new_buf ~= current then vim.api.nvim_set_current_buf(new_buf) end
        return
      end
    end
  end

  M.buffers = function()
    mapper.bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
    mapper.bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
    mapper.bind.normal("<C-h>", function() navigate(-1) end, DEFAULT_OPTS)
    mapper.bind.normal("<C-l>", function() navigate(1) end, DEFAULT_OPTS)
    mapper.bind.normal(
      "<leader>bo",
      require("snacks.bufdelete").other,
      { desc = "Close all except current", icon = "" }
    )
    mapper.bind.normal(
      "<leader>bh",
      function() require("treesitter-context").go_to_context(vim.v.count1) end,
      { silent = true, desc = "[h]eader of context" }
    )
  end
  return M
end

return createMotions
