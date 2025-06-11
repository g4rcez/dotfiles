local M = {}

M.in_window_mode = false
M.timeout = 5000
M.timer = nil
M.original_mappings = {}

function M.get_status()
    return M.in_window_mode
end

function M.enter_window_mode()
    if M.in_window_mode then
        return
    end
    M.in_window_mode = true
    M.notification_id = vim.notify("Window mode - Press ESC or Q to exit", vim.log.levels.INFO, {
        icon = "󰘖",
        timeout = false,
        title = "Window Mode",
    })
    M.create_window_mappings()
    M.reset_timer()
end

function M.exit_window_mode()
    if not M.in_window_mode then
        return -- Not in window mode
    end
    M.in_window_mode = false
    M.restore_original_mappings()

    if M.timer ~= nil then
        M.timer:stop()
        M.timer = nil
    end
end

function M.reset_timer()
    if M.timer then
        M.timer:stop()
    end

    M.timer = vim.defer_fn(function()
        M.exit_window_mode()
    end, M.timeout)
end

function M.create_window_mappings()
    local window_commands = {
        h = { cmd = "h", desc = "Window left" },
        j = { cmd = "j", desc = "Window down" },
        k = { cmd = "k", desc = "Window up" },
        l = { cmd = "l", desc = "Window right" },
        w = { cmd = "w", desc = "Next window" },
        p = { cmd = "p", desc = "Previous window" },
        v = { cmd = "v", desc = "Vertical split" },
        s = { cmd = "s", desc = "Horizontal split" },
        ["+"] = { cmd = "+", desc = "Increase height" },
        ["-"] = { cmd = "-", desc = "Decrease height" },
        ["<"] = { cmd = "<", desc = "Decrease width" },
        [">"] = { cmd = ">", desc = "Increase width" },
        ["="] = { cmd = "=", desc = "Equal windows" },
        H = { cmd = "H", desc = "Move window left" },
        J = { cmd = "J", desc = "Move window down" },
        K = { cmd = "K", desc = "Move window up" },
        L = { cmd = "L", desc = "Move window right" },
        r = { cmd = "r", desc = "Rotate windows" },
        R = { cmd = "R", desc = "Rotate windows reverse" },
        x = { cmd = "x", desc = "Exchange windows" },
        T = { cmd = "T", desc = "Move to new tab" },
    }

    local exit_commands = {
        c = { cmd = "c", desc = "Close window", exit = true },
        q = { cmd = "q", desc = "Quit window", exit = true },
        o = { cmd = "o", desc = "Only window", exit = true },
    }

    for key, value in pairs(exit_commands) do
        window_commands[key] = value
    end
    for key, config in pairs(window_commands) do
        local original_map = vim.fn.maparg(key, "n", false, true)
        if original_map and original_map.lhs then
            M.original_mappings[key] = original_map
        end

        vim.keymap.set("n", key, function()
            if not M.in_window_mode then
                -- If not in window mode, execute original mapping or the key itself
                if M.original_mappings[key] and M.original_mappings[key].rhs then
                    vim.api.nvim_feedkeys(M.original_mappings[key].rhs, "n", false)
                else
                    vim.api.nvim_feedkeys(key, "n", false)
                end
                return
            end

            -- Execute window command
            M.reset_timer()
            vim.cmd("wincmd " .. config.cmd)

            -- Exit window mode if this is an exit command
            if config.exit then
                M.exit_window_mode()
            end
        end, { desc = config.desc, buffer = false })
    end

    local exit_keys = { "<Esc>", "Q" }
    for _, key in ipairs(exit_keys) do
        local original_map = vim.fn.maparg(key, "n", false, true)
        if original_map and original_map.lhs then
            M.original_mappings[key] = original_map
        end

        vim.keymap.set("n", key, function()
            if M.in_window_mode then
                M.exit_window_mode()
            else
                if M.original_mappings[key] and M.original_mappings[key].rhs then
                    vim.api.nvim_feedkeys(M.original_mappings[key].rhs, "n", false)
                else
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
                end
            end
        end, { desc = "Exit window mode or original action" })
    end
end

function M.restore_original_mappings()
    local all_keys = {
        "h",
        "j",
        "k",
        "l",
        "w",
        "p",
        "v",
        "s",
        "+",
        "-",
        "<",
        ">",
        "=",
        "H",
        "J",
        "K",
        "L",
        "r",
        "R",
        "x",
        "T",
        "c",
        "q",
        "o",
        "<Esc>",
        "Q",
    }

    for _, key in ipairs(all_keys) do
        pcall(vim.keymap.del, "n", key)
        if M.original_mappings[key] and M.original_mappings[key].rhs then
            local original = M.original_mappings[key]
            vim.keymap.set("n", key, original.rhs, {
                silent = original.silent == 1,
                noremap = original.noremap == 1,
                expr = original.expr == 1,
                desc = original.desc or nil,
            })
        end
    end
    M.original_mappings = {}
end

function M.setup(opts)
    opts = opts or {}
    M.timeout = opts.timeout or 5000

    vim.keymap.set("n", "<leader>w", function()
        if M.in_window_mode then
            vim.cmd "wincmd w"
            M.reset_timer()
        else
            M.enter_window_mode()
            vim.cmd "wincmd w"
        end
    end, { desc = "Window mode" })

    vim.api.nvim_create_user_command("WindowModeStatus", function()
        print("Window mode: " .. (M.in_window_mode and "ON" or "OFF"))
    end, {})

    vim.api.nvim_create_user_command("WindowModeExit", function()
        M.exit_window_mode()
    end, {})
end

return M
