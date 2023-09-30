---------------------------------------------------------------------------------
-- telescope config
local actions = require "telescope.actions"

require("telescope").load_extension("file_browser")
require("telescope").setup({
  pickers = {
    buffers = {
      mappings = {
        i = {
          ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
        }
      }
    }
  }
})
lvim.builtin.telescope.theme = "dropdown"
lvim.builtin.telescope.defaults = {
  theme = "",
  prompt_prefix = "   ",
  selection_caret = "  ",
  entry_prefix = "  ",
  initial_mode = "insert",
  selection_strategy = "reset",
  sorting_strategy = "ascending",
  layout_strategy = "horizontal",
  border = {},
  borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  color_devicons = true,
  file_ignore_patterns = { "node_modules" },
  file_sorter = require("telescope.sorters").get_fuzzy_file,
  generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
  path_display = { "truncate" },
  show_line = true,
  winblend = 0,
  layout_config = {
    height = 0.9,
    width = 0.9,
    prompt_position = "top",
    vertical = { mirror = true, },
    horizontal = { prompt_position = "top", },
  },
  pickers = {
    find_files = {
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
    },
  },
  vimgrep_arguments = {
    "rg",
    "-L",
    "--trim",
    "--no-heading",
    "--with-filename",
    --
    "--line-number",
    "--column",
    "--smart-case",
  },
}

lvim.builtin.telescope.on_config_done = function(telescope)
  pcall(telescope.load_extension, "frecency")
  pcall(telescope.load_extension, "neoclip")
end
