return {
    "echasnovski/mini.hipatterns",
    event = "LazyFile",
    opts = function()
        local hi = require("mini.hipatterns")
        return {
            -- custom LazyVim option to enable the tailwind integration
            tailwind = {
                enabled = true,
                ft = { "typescriptreact", "javascriptreact", "css", "javascript", "typescript", "html" },
                -- full: the whole css class will be highlighted
                -- compact: only the color will be highlighted
                style = "full",
            },
            highlighters = { hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }), }
        }
    end,
    config = function(_, opts)
        -- backward compatibility
        if opts.tailwind == true then
            opts.tailwind = {
                enabled = true,
                ft = { "typescriptreact", "javascriptreact", "css", "javascript", "typescript", "html" },
                style = "full",
            }
        end
        if type(opts.tailwind) == "table" and opts.tailwind.enabled then
            -- reset hl groups when colorscheme changes
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    M.hl = {}
                end,
            })
            opts.highlighters.tailwind = {
                pattern = function()
                    if not vim.tbl_contains(opts.tailwind.ft, vim.bo.filetype) then
                        return
                    end
                    if opts.tailwind.style == "full" then
                        return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
                    elseif opts.tailwind.style == "compact" then
                        return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
                    end
                end,
                extmark_opts = { priority = 2000 },
            }
        end
        require("mini.hipatterns").setup(opts)
    end,
}
