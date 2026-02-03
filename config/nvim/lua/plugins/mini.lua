return {
    {
        "nvim-mini/mini.pairs",
        opts = {
            markdown = true,
            skip_ts = { "string" },
            skip_unbalanced = true,
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            modes = { insert = true, command = true, terminal = false },
            mappings = {
                ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
                ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
                ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
                [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
                ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
                ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
                ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
                ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
                ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
            },
        },
    },
    {
        "nvim-mini/mini.bracketed",
        opts = {
            buffer = { suffix = "b", options = {} },
            comment = { suffix = "c", options = {} },
            conflict = { suffix = "x", options = {} },
            diagnostic = { suffix = "d", options = {} },
            file = { suffix = "f", options = {} },
            indent = { suffix = "i", options = {} },
            jump = { suffix = "j", options = {} },
            location = { suffix = "l", options = {} },
            oldfile = { suffix = "r", options = {} },
            quickfix = { suffix = "q", options = {} },
            treesitter = { suffix = "n", options = {} },
            undo = { suffix = "u", options = {} },
            window = { suffix = "w", options = {} },
            yank = { suffix = "y", options = {} },
        },
    },
    {
        "nvim-mini/mini.nvim",
        config = function()
            require("mini.diff").setup()
            require("mini.ai").setup { n_lines = 500 }
            require("mini.surround").setup()
            require("mini.git").setup()
            require("mini.colors").setup()
            require("mini.cursorword").setup()
            require("mini.map").setup()
            require("mini.hipatterns").setup()
            require("mini.bufremove").setup()
            require("mini.files").setup { windows = { preview = true } }
            vim.keymap.set("n", "<leader>g=", function()
                require("mini.diff").toggle_overlay(0)
            end, { desc = "Git diff" })
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    local mini_files = require "mini.files"
                    local setArgs = function(desc)
                        return { buffer = buf_id, noremap = true, silent = true, desc = desc }
                    end
                    vim.keymap.set("n", "q", function()
                        mini_files.close()
                    end, setArgs "[q]uit minifiles")
                    vim.keymap.set("n", "<C-s>", function()
                        mini_files.synchronize()
                    end, setArgs "Sync")
                    vim.keymap.set("n", "l", function()
                        mini_files.go_in { close_on_file = true }
                    end, setArgs "Open file + close mini")
                    vim.keymap.set("n", "<CR>", function()
                        mini_files.synchronize()
                        mini_files.go_in { close_on_file = true }
                    end, setArgs "Open file + close mini")
                    vim.keymap.set("n", "<leader>p", function()
                        if not mini_files then
                            vim.notify("mini.files module not loaded.", vim.log.levels.ERROR)
                            return
                        end
                        local curr_entry = mini_files.get_fs_entry()
                        if not curr_entry then
                            vim.notify("Failed to retrieve current entry in mini.files.", vim.log.levels.ERROR)
                            return
                        end
                        local curr_dir = curr_entry.fs_type == "directory" and curr_entry.path or vim.fn.fnamemodify(curr_entry.path, ":h")
                        local script = [[
            tell application "System Events"
              try
                set theFile to the clipboard as alias
                set posixPath to POSIX path of theFile
                return posixPath
              on error
                return "error"
              end try
            end tell
          ]]
                        local output = vim.fn.system("osascript -e " .. vim.fn.shellescape(script)) -- Execute AppleScript command
                        if vim.v.shell_error ~= 0 or output:find "error" then
                            vim.notify("Clipboard does not contain a valid file or directory.", vim.log.levels.WARN)
                            return
                        end
                        local source_path = output:gsub("%s+$", "") -- Trim whitespace from clipboard output
                        if source_path == "" then
                            vim.notify("Clipboard is empty or invalid.", vim.log.levels.WARN)
                            return
                        end
                        local dest_path = curr_dir .. "/" .. vim.fn.fnamemodify(source_path, ":t") -- Destination path in current directory
                        local copy_cmd = vim.fn.isdirectory(source_path) == 1 and { "cp", "-R", source_path, dest_path } or { "cp", source_path, dest_path } -- Construct copy command
                        local result = vim.fn.system(copy_cmd) -- Execute the copy command
                        if vim.v.shell_error ~= 0 then
                            vim.notify("Paste operation failed: " .. result, vim.log.levels.ERROR)
                            return
                        end
                        mini_files.synchronize()
                        vim.notify("Pasted successfully.", vim.log.levels.INFO)
                    end, setArgs "[P]Paste from clipboard")
                    vim.keymap.set("n", "<leader>y", function()
                        -- Get the current entry (file or directory)
                        local curr_entry = mini_files.get_fs_entry()
                        if curr_entry then
                            local path = curr_entry.path
                            local cmd = string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], path)
                            local result = vim.fn.system(cmd)
                            if vim.v.shell_error ~= 0 then
                                vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
                            else
                                vim.notify(vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
                                vim.notify("Copied to system clipboard", vim.log.levels.INFO)
                            end
                        else
                            vim.notify("No file or directory selected", vim.log.levels.WARN)
                        end
                    end, setArgs "[P]Copy file/directory to clipboard")
                end,
            })
        end,
    },
}
