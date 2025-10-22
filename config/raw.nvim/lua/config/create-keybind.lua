local noop = {
    add = function() end,
}

local function createKeybind(wk)
    wk = wk or noop
    local M = {}
    M.DEFAULT_OPTS = { noremap = true, silent = true }

    M.keymap = function(mode, from, to, opts)
        opts = opts or {}
        opts.silent = opts.silent ~= true
        opts.noremap = opts.noremap ~= true
        vim.keymap.set(mode, from, to, opts)
    end
    vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
            if event.data.actions.type == "move" then
                local snacks = require "snacks"
                snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
            end
        end,
    })

    M.bind = {
        normal = function(from, action, opts)
            local o = opts or {}
            local desc = o.desc or ""
            M.keymap("n", from, action, { desc = desc })
            wk.add { from, action, desc = desc or "", mode = { "n" }, icon = o.icon }
        end,
        x = function(from, to, opts)
            M.keymap("x", from, to, opts)
            wk.add { from, to, desc = opts.desc or "", mode = { "x" }, icon = opts.icon }
        end,
        cmd = function(from, to, opts)
            M.keymap("c", from, to, opts)
            wk.add { from, to, desc = opts.desc or "", mode = { "c" }, icon = opts.icon }
        end,
        insert = function(from, to, opts)
            M.keymap("i", from, to, opts)
            wk.add { from, to, desc = opts.desc or "", mode = { "i" }, icon = opts.icon }
        end,
        visual = function(from, to, opts)
            M.keymap("v", from, to, opts)
            wk.add { from, to, desc = opts.desc or "", mode = { "v" }, icon = opts.icon }
        end,
    }

    return M
end

return createKeybind
