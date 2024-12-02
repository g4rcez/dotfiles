return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
        local ls = require("luasnip")
        local types = require("luasnip.util.types")
        ls.config.set_config({
            update_events = { "TextChanged", "TextChangedI" },
            delete_check_events = { "InsertLeave" },
            region_check_events = { "InsertEnter" },
            enable_autosnippets = true,
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { "●", "LuasnipChoice" } },
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { "●", "LuasnipInsert" } },
                    },
                },
            },
        })

        -- Mappings
        vim.keymap.set({ "i", "s" }, "<s-tab>", function()
            if ls.jumpable(-1) then
                return "<Plug>luasnip-jump-prev"
            else
                return "<s-tab>"
            end
        end, { expr = true })
        vim.keymap.set({ "i", "s" }, "<c-k>", function()
            if ls.choice_active() then
                ls.change_choice(1)
            end
        end, { silent = true })

        -- Snippets
        require("plugins.snippets.lua")
        require("plugins.snippets.typescript")
        require("plugins.snippets.typescriptreact")
        require("plugins.snippets.vue")
    end,
}
