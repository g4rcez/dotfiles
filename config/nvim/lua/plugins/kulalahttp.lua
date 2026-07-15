return {
    {
        "mistweaverco/kulala.nvim",
        ft = { "http", "rest", "javascript", "lua", "typescript" },
        event = { "SessionLoadPost", "VimLeavePre" },
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
            { "<leader>Rb", desc = "Open scratchpad" },
        },
        opts = {
            environment_scope = "b",
            session = { restore = true },
            treesitter = { enable = true },
            vscode_rest_client_environmentvars = true,
            response_format = {
                indent = 4,
                sort_keys = true,
                expand_tabs = true,
            },
            ui = {
                -- display mode: possible values: "split", "float"
                display_mode = "split",
                -- split direction: possible values: "above", "right", "below", "left", fun(): "above"|"right"|"below"|"left"
                split_direction = "right",
                -- window options to override win_config: width/height/split/vertical.., buffer/window options
                win_opts = { bo = {}, wo = {} }, ---@type kulala.ui.win_config
                -- default view: "body" or "headers" or "headers_body" or "verbose" or fun(response: Response)
                default_view = "headers_body", ---@type "body"|"headers"|"headers_body"|"verbose"|fun(response: Response)
                -- enable winbar
                winbar = true,
                -- Specify the panes to be displayed by default
                -- Available panes are { "body", "headers", "headers_body", "script_output", "stats", "verbose", "report", "help" },
                default_winbar_panes = { "body", "headers", "verbose", "script_output", "report" },
                -- Winbar labels
                winbar_labels = {
                    body = "Body",
                    headers = "Headers",
                    headers_body = "All",
                    verbose = "Verbose",
                    script_output = "Script Output",
                    stats = "Stats",
                    report = "Report",
                    help = "Help",
                },
                -- show/hide winbar keymaps in labels
                winbar_labels_keymaps = true,
                -- enable/disable variable info text
                -- this will show the variable name and value as float
                -- possible values: false, "float"
                show_variable_info_text = false,
                -- icons position: "signcolumn"|"on_request"|"above_request"|"below_request" or nil to disable
                show_icons = "on_request",
                -- default icons
                icons = {
                    inlay = { loading = "", done = "", error = "" },
                    lualine = "🐼",
                    textHighlight = "WarningMsg", -- highlight group for request elapsed time
                    loadingHighlight = "Normal",
                    doneHighlight = "String",
                    errorHighlight = "ErrorMsg",
                },
                show_request_summary = true,
                max_response_size = 32768,
                max_request_size = 2048,
                report = {
                    -- possible values: true | false | "on_error"
                    show_script_output = true,
                    -- possible values: true | false | "on_error" | "failed_only"
                    show_asserts_output = true,
                    -- possible values: true | false | "on_error"
                    show_summary = true,
                    headersHighlight = "Special",
                    successHighlight = "String",
                    errorHighlight = "Error",
                },

                -- scratchpad default contents
                scratchpad_default_contents = {
                    "@MY_TOKEN_NAME=my_token_value",
                    "",
                    "# @name scratchpad",
                    "POST https://echo.kulala.app/post HTTP/1.1",
                    "accept: application/json",
                    "content-type: application/json",
                    "",
                    "{",
                    '  "foo": "bar"',
                    "}",
                },

                -- Settings for pickers used for Environment, Authentication and Requests Managers
                pickers = {
                    snacks = {
                        layout = function()
                            local has_snacks, snacks_picker = pcall(require, "snacks.picker")
                            return not has_snacks and {}
                                or vim.tbl_deep_extend("force", snacks_picker.config.layout "telescope", {
                                    reverse = true,
                                    layout = {
                                        { { win = "list" }, { height = 1, win = "input" }, box = "vertical" },
                                        { win = "preview", width = 0.6 },
                                        box = "horizontal",
                                        width = 0.8,
                                    },
                                })
                        end,
                    },
                },
            },

            lsp = {
                ---enable/disable built-in LSP server
                ---@type boolean
                enable = true,

                ---filetypes to attach Kulala LSP to
                ---@type string[]
                filetypes = {
                    "http",
                    "rest",
                    "javascript",
                    "typescript",
                    "lua",
                },

                ---Only scripts ending in *.http.js, *.http.ts and *.http.lua will be treated as HTTP scripts and
                ---have LSP capabilities, unless `enforce_external_script_naming_convention` is set to false.
                ---This allows users to have non-HTTP scripts with the same filetypes without LSP interference.
                ---@type boolean
                enforce_external_script_naming_convention = true,

                --enable/disable/customize  LSP keymaps
                ---@type boolean|table
                keymaps = false, -- disabled by default, as Kulala relies on default Neovim LSP keymaps

                on_attach = nil, -- function called when Kulala LSP attaches to the buffer
            },

            -- enable/disable debug mode
            debug = 3,
            -- enable/disable bug reports on all errors
            generate_bug_report = false,

            -- set to true to enable default keymaps
            -- (see docs or lua/kulala/config/keymaps.lua)
            -- or override default keymaps as shown in the example below.
            ---@type boolean|table
            global_keymaps = false,
            --[[
        {
          ["Send request"] = { -- sets global mapping
            "<leader>Rs",
            function() require("kulala").run() end,
            mode = { "n", "v" }, -- optional mode, default is n
            desc = "Send request" -- optional description, otherwise inferred from the key
          },
          ["Send all requests"] = {
            "<leader>Ra",
            function() require("kulala").run_all() end,
            mode = { "n", "v" },
            ft = "http", -- sets mapping for *.http files only
          },
          ["Replay the last request"] = {
            "<leader>Rr",
            function() require("kulala").replay() end,
            ft = { "http", "rest" }, -- sets mapping for specified file types
          },
        ["Find request"] = false -- set to false to disable
        },
      ]]

            -- Prefix for global keymaps
            global_keymaps_prefix = "<leader>R",

            -- Kulala UI keymaps; override with custom keymaps as required
            -- (see docs or lua/kulala/config/keymaps.lua)
            ---@type boolean|table
            kulala_keymaps = true,
            --[[
        {
          ["Show headers"] = { "H", function() require("kulala.ui").show_headers() end, },
        }
      ]]
            kulala_keymaps_prefix = "",
        },
    },
}
