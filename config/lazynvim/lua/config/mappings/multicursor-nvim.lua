local M = {}

M.setup = function(bind)
    local mc = require("multicursor-nvim")
    mc.setup({})
    bind.nx("<C-k>", function()
        mc.lineAddCursor(-1)
    end, { desc = "Multicursor above", noremap = true })
    bind.nx("<C-j>", function()
        mc.lineAddCursor(1)
    end, { desc = "Multicursor bellow", noremap = true })

    bind.nx("<leader>nn", function()
        mc.matchAddCursor(1)
    end, { desc = "[n]ew match" })
    bind.nx("<C-n>", function()
        mc.matchAddCursor(1)
    end, { desc = "[n]ew match" })
    bind.nx("<leader>ns", function()
        mc.matchSkipCursor(1)
    end, { desc = "[s]kip match" })
    bind.nx("<leader>nN", function()
        mc.matchAddCursor(-1)
    end, { desc = "[N]ew prev match" })
    bind.nx("<leader>nS", function()
        mc.matchSkipCursor(-1)
    end, { desc = "[S]kip prev match" })
    bind.normal("<c-leftmouse>", mc.handleMouse)
    bind.normal("<c-leftdrag>", mc.handleMouseDrag)
    bind.normal( "<c-leftrelease>", mc.handleMouseRelease)
    mc.addKeymapLayer(function(layer)
        layer({ "n", "x" }, "<left>", mc.prevCursor)
        layer({ "n", "x" }, "<right>", mc.nextCursor)
        layer({ "n", "x" }, "<leader>x", mc.deleteCursor)
        layer("n", "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            else
                mc.clearCursors()
            end
        end)
    end)
end

return M
