return {
    "iurysza/nice-mermaid.nvim",
    ft = { "markdown" },
    cmd = { "Mermaid" },
    build = function(plugin)
        local result = vim.system({ "npm", "ci", "--omit=dev" }, {
            cwd = plugin.dir .. "/bridge",
            text = true,
        }):wait()
        if result.code ~= 0 then
            error(result.stderr)
        end
    end,
    opts = {
        node = "node",
        auto_render = false,
        filetypes = { "markdown", "markdown.mdx" },
    },
    keys = {
        { "<leader>mm", "<cmd>Mermaid toggle<cr>", desc = "Toggle Mermaid source" },
    },
}
