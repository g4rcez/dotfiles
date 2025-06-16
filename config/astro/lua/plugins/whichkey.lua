return {
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function(_, defaultOpts)
      defaultOpts.preset = "helix"
      local wk = require "which-key"
      local createKeyMap = require "config.keymap"
      local keymap = createKeyMap(wk)
      local bind = keymap.bind

      local function groups()
        wk.add { "<leader>b", group = "[b]uffer", icon = "󱦞" }
        wk.add { "<leader>c", group = "[c]ode", mode = { "n", "x" }, icon = "" }
        wk.add { "<leader>f", group = "[f]ind", icon = "󱡴" }
        wk.add { "<leader>g", group = "[g]it", icon = "" }
        wk.add { "<leader>h", group = "[h]arpoon", icon = "" }
        wk.add { "<leader>q", group = "[q]uit", icon = "󰿅" }
        wk.add { "<leader>s", group = "[s]earch", icon = "󱡴" }
        wk.add { "<leader>u", group = "[u]i", mode = { "n" }, icon = "󱣴" }
        wk.add { "<leader>r", group = "[r]eplace", mode = { "n" }, icon = "" }
        wk.add { "<leader>x", group = "[x]errors", mode = { "n" }, icon = "" }
        wk.add { "<leader>n", group = "[n]ew cursor", mode = { "n" }, icon = "" }
      end

      local function harpoonConfig()
        local h = require "harpoon"
        local Snacks = require "snacks"
        h.setup {}
        local function generate_harpoon_picker()
          local file_paths = {}
          for _, item in ipairs(h:list().items) do
            table.insert(file_paths, { text = item.value, file = item.value })
          end
          return file_paths
        end
        bind.normal("<leader>hh", function() h.ui:toggle_quick_menu(h:list()) end, { desc = "Quick harpoon" })

        bind.normal("<C-e>", function() h.ui:toggle_quick_menu(h:list()) end, { desc = "Quick harpoon" })

        bind.normal("<leader>ha", function() h:list():add() end, { desc = "Harpoon add" })

        bind.normal("<leader>hf", function()
          Snacks.picker {
            finder = generate_harpoon_picker,
            win = {
              input = {
                keys = {
                  ["dd"] = { "harpoon_delete", mode = { "n", "x" } },
                },
              },
              list = {
                keys = {
                  ["dd"] = { "harpoon_delete", mode = { "n", "x" } },
                },
              },
            },
            actions = {
              harpoon_delete = function(picker, item)
                local to_remove = item or picker:selected()
                Snacks.debug.log(to_remove)
                h:list():remove(to_remove)
              end,
            },
          }
        end, { desc = "harpoon find" })
      end

      local function rename_once()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        local client_id_to_use = nil
        for _, client in ipairs(clients) do
          if client.supports_method "textDocument/rename" then
            client_id_to_use = client.id
            break
          end
        end

        if client_id_to_use then
          local params = vim.lsp.util.make_position_params()
          vim.ui.input({ prompt = "New Name: ", default = vim.fn.expand "<cword>" }, function(new_name)
            if not new_name or new_name == "" then return end
            params.newName = new_name

            vim.lsp.buf_request(0, "textDocument/rename", params, function(err, result, ctx)
              if err then return end
              if not result then return end
              if ctx.client_id == client_id_to_use then vim.lsp.util.apply_workspace_edit(result, "utf-8") end
            end)
          end)
        end
      end

      local function code()
        bind.normal(
          "<leader>rr",
          function() require("grug-far").open { engine = "astgrep" } end,
          { desc = "Replace with grug-far astgrep" }
        )
        bind.normal("]g", function() vim.diagnostic.goto_next {} end, { desc = "Goto next error" })
        bind.normal("[g", function() vim.diagnostic.goto_prev {} end, { desc = "Goto previous error" })

        bind.normal("<leader>cr", rename_once, { desc = "[c]ode [r]ename" })
        bind.normal("<leader>cf", function() vim.lsp.buf.format() end, { desc = "[c]ode [f]ormat" })
      end
      local createMotions = require "config.motions"
      require("config.switch").setup()
      local motions = createMotions(keymap)
      require("config.window-mode").setup {
        timeout = 30000,
      }
      local keymaps = { groups, defaults = motions.defaults(), buffers = motions.buffers(), code, harpoonConfig }
      for _, func in ipairs(keymaps) do
        func()
      end

      return defaultOpts
    end,
  },
}
