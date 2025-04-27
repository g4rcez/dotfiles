return {
    {
        "jake-stewart/multicursor.nvim",
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()
            local set = vim.keymap.set
            -- Add or skip cursor above/below the main cursor.
            set({ "n", "x" }, "<C-k>", function() mc.lineAddCursor(-1) end)
            set({ "n", "x" }, "<C-j>", function() mc.lineAddCursor(1) end)
            set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end)
            set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end)
            -- Add or skip adding a new cursor by matching word/selection
            set({ "n", "x" }, "<leader>nn", function() mc.matchAddCursor(1) end, { desc = "[n]ew match" })
            set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "[n]ew match" })
            set({ "n", "x" }, "<leader>ns", function() mc.matchSkipCursor(1) end, { desc = "[s]kip match" })
            set({ "n", "x" }, "<leader>nN", function() mc.matchAddCursor(-1) end, { desc = "[N]ew prev match" })
            set({ "n", "x" }, "<leader>nS", function() mc.matchSkipCursor(-1) end, { desc = "[S]kip prev match" })
            -- Add and remove cursors with control + left click.
            set("n", "<c-leftmouse>", mc.handleMouse)
            set("n", "<c-leftdrag>", mc.handleMouseDrag)
            set("n", "<c-leftrelease>", mc.handleMouseRelease)
            -- Mappings defined in a keymap layer only apply when there are
            -- multiple cursors. This lets you have overlapping mappings.
            mc.addKeymapLayer(function(layerSet)
                -- Select a different cursor as the main one.
                layerSet({ "n", "x" }, "<left>", mc.prevCursor)
                layerSet({ "n", "x" }, "<right>", mc.nextCursor)

                -- Delete the main cursor.
                layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

                -- Enable and clear cursors using escape.
                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end)
            end)
            -- Customize how cursors look.
            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { link = "Cursor" })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn" })
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end
    }
}
