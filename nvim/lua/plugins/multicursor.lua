return {
    "jake-stewart/multicursor.nvim",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()
        -- use MultiCursorCursor and MultiCursorVisual to customize
        -- additional cursors appearance
        vim.cmd.hi("link", "MultiCursorCursor", "Cursor")
        vim.cmd.hi("link", "MultiCursorVisual", "Visual")
        vim.keymap.set("n", "<ESC>", function()
            if mc.hasCursors() then
                mc.clearCursors()
            end
        end)

        -- add cursors above/below the main cursor
        vim.keymap.set({"n", "v"}, "<up>", function() mc.addCursor("k") end)
        vim.keymap.set({"n", "v"}, "<down>", function() mc.addCursor("j") end)

        -- add a cursor and jump to the next word under cursor
        vim.keymap.set({"n", "v"}, "<C-n>", function() mc.addCursor("*") end)

        -- jump to the next word under cursor but do not add a cursor
        vim.keymap.set({"n", "v"}, "<C-s>", function() mc.skipCursor("*") end)

        -- rotate the main cursor
        vim.keymap.set({"n", "v"}, "<left>", mc.nextCursor)
        vim.keymap.set({"n", "v"}, "<right>", mc.prevCursor)

        -- delete the main cursor
        vim.keymap.set({"n", "v"}, "<leader>x", mc.deleteCursor)

        -- add and remove cursors with control + left click
        vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)
    end,
}
