local function createMapper(wk)
    wk = wk or { add = function() end }
    local M = {}
    M.DEFAULT_OPTS = { noremap = true, silent = true }

    M.keymap = function(mode, from, to, opts)
        opts = opts or {}
        opts.silent = opts.silent ~= true
        opts.noremap = opts.noremap ~= true
        vim.keymap.set(mode, from, to, opts)
    end

    local function bind(modes)
        local fn = function(from, action, opts)
            local o = opts or {}
            local desc = o.desc or ""
            M.keymap(modes, from, action, { desc = desc })
            wk.add({ from, action, desc = desc or "", mode = modes, icon = o.icon })
        end
        return fn
    end

    M.bind = {
        normal = bind({ "n" }),
        x = bind({ "x" }),
        cmd = bind({ "c" }),
        insert = bind({ "i" }),
        visual = bind({ "v" }),
        nx = bind({ "n", "v" }),
    }

    return M
end

return createMapper
