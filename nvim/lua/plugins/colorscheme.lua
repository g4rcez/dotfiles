vim.opt.background = "dark"
vim.opt.termguicolors = true

local flavour = "mocha"
local colors = require("catppuccin.palettes").get_palette(flavour)
local ucolors = require("catppuccin.utils.colors")
local telescope_prompt = ucolors.darken(colors.crust, 0.95, "#000000")
local telescope_results = ucolors.darken(colors.mantle, 1, "#ffffff")
local telescope_text = colors.text
local telescope_prompt_title = colors.sky
local telescope_preview_title = colors.teal

local catppuccin = {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
        term_colors = true,
        color_overrides = {
            mocha = {
                rosewater = "#ffc0b9",
                flamingo = "#f5aba3",
                pink = "#f592d6",
                mauve = "#c0afff",
                red = "#ea746c",
                maroon = "#ff8595",
                peach = "#fa9a6d",
                yellow = "#ffe081",
                green = "#99d783",
                teal = "#47deb4",
                sky = "#00d5ed",
                sapphire = "#00dfce",
                blue = "#00baee",
                lavender = "#abbff3",
                -- text = "#cccccc",
                -- subtext1 = "#bbbbbb",
                -- subtext0 = "#aaaaaa",
                -- overlay2 = "#999999",
                -- overlay1 = "#888888",
                -- overlay0 = "#777777",
                -- surface2 = "#666666",
                -- surface1 = "#555555",
                -- surface0 = "#444444",
                base = "#202020",
                mantle = "#212121",
                crust = "#292929",
            },
        },
        highlight_overrides = {
            all = {
                -- dims the text so that the hits are more visible
                TelescopeBorder = { bg = telescope_results, fg = telescope_results },
                TelescopePromptBorder = { bg = telescope_prompt, fg = telescope_prompt },
                TelescopePromptCounter = { fg = telescope_text },
                TelescopePromptNormal = { fg = telescope_text, bg = telescope_prompt },
                TelescopePromptPrefix = { fg = telescope_prompt_title, bg = telescope_prompt },
                TelescopePromptTitle = { fg = telescope_prompt, bg = telescope_prompt_title },
                TelescopePreviewTitle = { fg = telescope_results, bg = telescope_preview_title },
                TelescopePreviewBorder = {
                    bg = ucolors.darken(telescope_results, 0.95, "#000000"),
                    fg = ucolors.darken(telescope_results, 0.95, "#000000"),
                },
                TelescopePreviewNormal = {
                    bg = ucolors.darken(telescope_results, 0.95, "#000000"),
                    fg = telescope_results,
                },
                TelescopeResultsTitle = { fg = telescope_results, bg = telescope_preview_title },
                TelescopeMatching = { fg = telescope_prompt_title },
                TelescopeSelection = { bg = telescope_prompt },
                TelescopeSelectionCaret = { fg = telescope_text },
                TelescopeResultsNormal = { bg = telescope_results },
                TelescopeResultsBorder = { bg = telescope_results, fg = telescope_results },
            },
        },
        integrations = {
            mason = true,
            cmp = true,
            noice = true,
            which_key = { enabled = true },
            dropbar = { enabled = true, color_mode = true },
            telescope = { border = true, enabled = true, style = "nvchad" },
            leap = true,
            lsp_trouble = true,
            markdown = true,
            native_lsp = {
                enabled = true,
                virtual_text = { errors = { "italic" }, hints = { "italic" }, warnings = { "italic" }, information = { "italic" } },
                underlines = { errors = { "underline" }, hints = { "underline" }, warnings = { "underline" }, information = { "underline" } },
            },
        },
    },
}

local M = {
    catppuccin,
    "EdenEast/nightfox.nvim",
    "rebelot/kanagawa.nvim",
    "marko-cerovac/material.nvim",
    { "LunarVim/darkplus.nvim", priority = 1000 },
    { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-mocha" } },
}

return M
