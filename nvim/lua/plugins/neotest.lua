return {
  { "nvim-neotest/neotest-plenary" },
  { "nvim-neotest/nvim-nio" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-plenary" } },
    dependencies = { { "nvim-neotest/nvim-nio" } },
  },
}
