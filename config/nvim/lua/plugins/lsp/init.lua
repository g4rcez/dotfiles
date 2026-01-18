local severity = vim.diagnostic.severity
local severityIcons = {
  [severity.ERROR] = " ",
  [severity.WARN] = " ",
  [severity.HINT] = "󰠠 ",
  [severity.INFO] = " ",
}

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = severityIcons,
          },
        },
        inlay_hints = { enabled = true, exclude = { "vue" }, },
        codelens = { enabled = true },
        folds = { enabled = true, },
        format = { formatting_options = nil, timeout_ms = nil, },
        ---@alias lazyvim.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean, keys?:LazyKeysLspSpec[]}
        ---@type table<string, lazyvim.lsp.Config|boolean>
        servers = {
          vtsls = {},
          ["*"] = {
            capabilities = {
              workspace = {
                fileOperations = {
                  didRename = true,
                  willRename = true,
                },
              },
            },
            keys = {
              { "<leader>cl", function() Snacks.picker.lsp_config() end,          desc = "Lsp Info" },
              { "gd",         vim.lsp.buf.definition,                             desc = "Goto Definition",            has = "definition" },
              { "gr",         vim.lsp.buf.references,                             desc = "References",                 nowait = true },
              { "gI",         vim.lsp.buf.implementation,                         desc = "Goto Implementation" },
              { "gy",         vim.lsp.buf.type_definition,                        desc = "Goto T[y]pe Definition" },
              { "gD",         vim.lsp.buf.declaration,                            desc = "Goto Declaration" },
              { "K",          function() return vim.lsp.buf.hover() end,          desc = "Hover" },
              { "gK",         function() return vim.lsp.buf.signature_help() end, desc = "Signature Help",             has = "signatureHelp" },
              { "<c-k>",      function() return vim.lsp.buf.signature_help() end, mode = "i",                          desc = "Signature Help", has = "signatureHelp" },
              { "<leader>ca", vim.lsp.buf.code_action,                            desc = "Code Action",                mode = { "n", "x" },     has = "codeAction" },
              { "<leader>cc", vim.lsp.codelens.run,                               desc = "Run Codelens",               mode = { "n", "x" },     has = "codeLens" },
              { "<leader>cC", vim.lsp.codelens.refresh,                           desc = "Refresh & Display Codelens", mode = { "n" },          has = "codeLens" },
              { "<leader>cR", function() Snacks.rename.rename_file() end,         desc = "Rename File",                mode = { "n" },          has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
              { "<leader>cr", vim.lsp.buf.rename,                                 desc = "Rename",                     has = "rename" },
              -- { "<leader>cA", LazyVim.lsp.action.source,                          desc = "Source Action",              has = "codeAction" },
              {
                "]]",
                function() Snacks.words.jump(vim.v.count1) end,
                has = "documentHighlight",
                desc = "Next Reference",
                enabled = function() return Snacks.words.is_enabled() end
              },
              {
                "[[",
                function() Snacks.words.jump(-vim.v.count1) end,
                has = "documentHighlight",
                desc = "Prev Reference",
                enabled = function() return Snacks.words.is_enabled() end
              },
              {
                "<a-n>",
                function() Snacks.words.jump(vim.v.count1, true) end,
                has = "documentHighlight",
                desc = "Next Reference",
                enabled = function() return Snacks.words.is_enabled() end
              },
              {
                "<a-p>",
                function() Snacks.words.jump(-vim.v.count1, true) end,
                has = "documentHighlight",
                desc = "Prev Reference",
                enabled = function() return Snacks.words.is_enabled() end
              },
            },
          },
          stylua = { enabled = false },
          lua_ls = {
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                codeLens = { enable = true },
                completion = { callSnippet = "Replace" },
                doc = { privateName = { "^_" } },
                hint = {
                  enable = true,
                  setType = true,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
        ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
        setup = {},
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = vim.schedule_wrap(function(_, opts)
      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
          if
              vim.api.nvim_buf_is_valid(buffer)
              and vim.bo[buffer].buftype == ""
              and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      -- diagnostics
      if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
        opts.diagnostics.virtual_text.prefix = function(diagnostic)
          local icons = severityIcons
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return "●"
        end
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
      if opts.servers["*"] then
        vim.lsp.config("*", opts.servers["*"])
      end
      local mason_all = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
      local mason_exclude = {} ---@type string[]
      ---@return boolean? exclude automatic setup
      local function configure(server)
        if server == "*" then
          return false
        end
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts --[[@as lazyvim.lsp.Config]]
        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end
        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts) -- configure the server
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
        require("mason-lspconfig").setup({
          ensure_installed = vim.list_extend(install, require('config.ensure-installed').lsp),
          automatic_enable = { exclude = mason_exclude },
        })
    end),
  },
}
