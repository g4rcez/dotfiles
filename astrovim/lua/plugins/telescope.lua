return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function(_, opts)
    opts.defaults.layout_config = {
      height = 70,
      width = 120,
      prompt_position = "top",
      horizontal = {
        mirror = false,
        preview_width = 0.6,
        size = {
          width = "90%",
          height = "80%",
        },
      },
      vertical = {
        mirror = false,
        size = {
          width = "90%",
          height = "80%",
        },
      },
    }
  end,
}
