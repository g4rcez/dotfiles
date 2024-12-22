local function configure(mode, from, to, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= true
  vim.keymap.set(mode, from, to, opts)
end

local key = {
  normal = function(from, to, desc)
    configure("n", from, to, desc)
  end,
  x = function(from, to, desc)
    configure("x", from, to, desc)
  end,
  cmd = function(from, to, desc)
    configure("c", from, to, desc)
  end,
  insert = function(from, to, desc)
    configure("i", from, to, desc)
  end,
  visual = function(from, to, desc)
    configure("v", from, to, desc)
  end,
}

local commonKeymaps = function()
  return {}
end

local function buffersAndBookmarks()
  local harpoon = require("harpoon")

  -- harpoon
  key.normal("<leader>br", function()
    harpoon:list():remove()
  end, { desc = "Remove harpoon hook" })
  key.normal("<leader>ba", function()
    harpoon:list():add()
  end, { desc = "Hook using harpoon" })

  -- bookmarks
  vim.keymap.set(
    { "n", "v" },
    "<leader>mm",
    "<cmd>BookmarksMark<cr>",
    { desc = "Mark current line into active BookmarkList." }
  )
  vim.keymap.set(
    { "n", "v" },
    "<leader>mo",
    "<cmd>BookmarksGoto<cr>",
    { desc = "Go to bookmark at current active BookmarkList" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<leader>ma",
    "<cmd>BookmarksCommands<cr>",
    { desc = "Find and trigger a bookmark command." }
  )
  vim.keymap.set(
    { "n", "v" },
    "<leader>mg",
    "<cmd>BookmarksGotoRecent<cr>",
    { desc = "Go to latest visited/created Bookmark" }
  )

  vim.keymap.set({ "v", "n" }, "<C-n>", "<cmd>MCstart<cr>", { desc = "Multicursor" })
end

local function codeKeymap()
  key.normal("<leader>cd", vim.diagnostic.setloclist, { desc = "Quickfix list" })
  key.normal("<leader>cr", vim.lsp.buf.rename, { desc = "Rename variable" })
  key.normal("g1", function()
    require("treesitter-context").go_to_context(vim.v.count1)
  end, { silent = true })
  key.normal("<leader>cf", vim.lsp.buf.format, { desc = "[c]ode format" })
end

local function transformKeymap()
  key.normal("<leader>tl", "<cmd>set wrap<cr>", { desc = "Set wrap mode" })
  key.normal("<leader>tz", "<cmd>ZenMode<cr>", { desc = "ZenMode" })
  key.normal("<leader>tw", "<cmd>Twilight<cr>", { desc = "Twilight" })
  key.visual("<leader>tm", function()
    vim.cmd("SnipRun")
  end, { desc = "Run markdown snippet" })
  key.insert("<c-u>", "<Esc>viwUea", { desc = "To upper case" })
  key.insert("<c-t>", "<Esc>b~lea", { desc = "To lower case" })
end

local function errorsKeymap()
  key.normal("]x", vim.diagnostic.goto_next, { desc = "Next Error" })
  key.normal("[x", vim.diagnostic.goto_prev, { desc = "Previous Error" })
  key.normal("]d", vim.diagnostic.goto_next, { desc = "Next Error" })
  key.normal("[d", vim.diagnostic.goto_prev, { desc = "Previous Error" })
  key.normal("gR", function()
    require("trouble").toggle("lsp_references")
  end, { desc = "Trouble references" })
  return {}
end

local function sessionKeymap()
  key.normal("\\", "<CMD>Oil --float<CR>", { desc = "oil.nvim" })
  key.normal("<leader>sf", "<CMD>Oil --float<CR>", { desc = "oil.nvim" })
  key.normal("<leader>so", "<CMD>Oil --float<CR>", { desc = "[o]il.nvim" })
  key.normal("<leader>sr", require("persistence").load, { desc = "[r]estore session" })
end

local addKeymaps = function()
  local list = { commonKeymaps, buffersAndBookmarks, codeKeymap, transformKeymap, errorsKeymap, sessionKeymap }
  for _, fn in pairs(list) do
    fn()
  end
end

local M = {}

local vscodeKeymaps = function()
  local vscode = require("vscode")
  vim.notify = vscode.notify
  key.normal("J", "mzJ`z", { desc = "Join lines as ThePrimeagen" })
  key.normal("<leader>cf", function()
    vscode.action("editor.action.formatDocument")
  end, { desc = "Vscode format" })
  vim.keymap.set({ "n", "x", "i" }, "<C-d>", function()
    vscode.with_insert(function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
    end)
  end)
  vim.keymap.set({ "n", "x" }, "<leader>r", function()
    vscode.with_insert(function()
      vscode.action("editor.action.refactor")
    end)
  end)
end

if vim.g.vscode then
  vscodeKeymaps()
  return M
end

table.insert(M, {
  "folke/which-key.nvim",
  event = "VimEnter",
  config = function()
    local wh = require("which-key")
    local icon = require("nvim-web-devicons").get_icon
    addKeymaps()
    wh.setup({
      preset = "helix",
      plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 10 },
      },
    })
    wh.add({
      { "<leader>b", group = "[b]uffers", icon = icon("tmux") },
      { "<leader>c", group = "[c]ode", icon = icon("gcode") },
      { "<leader>d", group = "[d]ebug", icon = icon("debug") },
      { "<leader>r", group = "[r]ename", icon = "desktop" },
      { "<leader>m", group = "[m]ark" },
      { "<leader>R", group = "[R]equest HTTP" },
      { "<leader>s", group = "[s]ession", icon = icon("nix") },
      { "<leader>f", group = "[f]ind", icon = icon("desktop") },
      { "<leader>w", group = "[w]orkspace", icon = icon("workspace") },
      { "<leader>t", group = "[t]oggle", icon = icon("workspace") },
      { "<leader>x", group = "[x]trouble/errors" },
      { "<leader>h", group = "git [h]unk", mode = { "n", "v" }, icon = icon("git") },
    }, {
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename variable", icon = icon("gcode") },
      { "<leader>cd", vim.diagnostic.setloclist, desc = "Quickfix list", icon = icon("linux") },
    })
  end,
})

return M
