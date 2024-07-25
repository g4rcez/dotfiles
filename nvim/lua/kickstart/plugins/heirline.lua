return {
  {
    'rebelot/heirline.nvim',
    event = "UiEnter",
    config = function()
      require('heirline').setup {}
    end,
  },
}
