return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        spellcheck = {
          event = "FileType",
          pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
          callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
          end,
        },
        unlisted_man = {
          event = "FileType",
          pattern = { "man" },
          callback = function(event) vim.bo[event.buf].buflisted = false end,
        },
        yankLines = {
          { event = "TextYankPost", callback = vim.highlight.on_yank, desc = "Highlight when yanking (copying) text" },
        },
        createFileRecursive = {
          event = "BufWritePre",
          desc = "Create file when directory not exists",
          callback = function(event)
            if event.match:match "^%w%w+:[\\/][\\/]" then return end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end,
        },
      },
    },
  },
}
