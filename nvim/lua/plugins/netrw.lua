local M = { "prichrd/netrw.nvim", lazy = false }

function M.config()
    vim.cmd([[autocmd FileType netrw nmap <buffer> a %]])
    require("netrw").setup({
        use_devicons = true,
        icons = { symlink = " ", directory = " ", file = " " },
        mappings = {
            ["l"] = function(payload)
                vim.cmd("edit " .. payload.dir .. "/" .. payload.node)
            end,
            ["h"] = function(_)
                vim.api.nvim_input("-")
            end,
            ["K"] = function(payload)
                print(vim.inspect(payload))
            end,
        },
    })
end

return M
