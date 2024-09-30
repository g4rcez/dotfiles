local layoutConfig = { mirror = false, preview_width = 0.65, size = { width = 1, height = 0.9 } }

-- Credits to telescope buffer builtin, some code taken from it
-- Src: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/internal.lua

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

local conf = require("telescope.config").values
local actions = require("telescope.actions")
local make_entry = require("telescope.make_entry")
local action_state = require("telescope.actions.state")

local function wrapper()
  local term_bufs = vim.g.nvchad_terms or {}
  local buffers = {}

  for buf, _ in pairs(term_bufs) do
    buf = tonumber(buf)
    local element = { bufnr = buf, flag = "", info = vim.fn.getbufinfo(buf)[1] }
    table.insert(buffers, element)
  end

  local bufnrs = vim.tbl_keys(term_bufs)

  if #bufnrs == 0 then
    print("no terminal buffers are opened/hidden!")
    return
  end

  local opts = { bufnr_width = math.max(unpack(bufnrs)) }

  local picker = pickers.new({
    prompt_title = " Pick Term",
    previewer = conf.grep_previewer(opts),
    finder = finders.new_table({
      results = buffers,
      entry_maker = make_entry.gen_from_buffer(opts),
    }),
    sorter = conf.generic_sorter(),

    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- open term only if its window isnt opened
        if vim.fn.bufwinid(entry.bufnr) == -1 then
          local termopts = vim.g.nvchad_terms[tostring(entry.bufnr)]
          require("nvchad.term").display(termopts)
        end
      end)
      return true
    end,
  })

  picker:find()
end

return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
  },
  {
    "piersolenski/telescope-import.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("import")
    end,
  },
  {
    -- Lazy
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      { "debugloop/telescope-undo.nvim" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-file-browser.nvim" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = true },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local previewers = require("telescope.previewers")
      local insertMapping = {
        ["<C-b>"] = actions.results_scrolling_up,
        ["<C-c>"] = actions.close,
        ["<C-f>"] = actions.results_scrolling_down,
        ["<C-h>"] = actions.which_key,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-l>"] = actions.complete_tag,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-t>"] = actions.select_tab,
        ["<C-v>"] = actions.select_vertical,
        ["<CR>"] = actions.select_default,
        ["<Down>"] = actions.move_selection_next,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<S-Tab>"] = actions.close,
        ["<Tab>"] = actions.select_default,
        ["<Up>"] = actions.move_selection_previous,
        ["<c-d>"] = actions.delete_buffer,
        ["<esc>"] = actions.close,
      }
      local mappings = { n = { ["q"] = actions.close }, i = insertMapping }

      telescope.setup({
        defaults = {
          border = {},
          use_less = false,
          mappings = mappings,
          buffer_previewer_maker = previewers.buffer_previewer_maker,
          layout_strategy = "horizontal",
          color_devicons = true,
          initial_mode = "insert",
          path_display = { "truncate" },
          selection_strategy = "reset",
          set_env = { ["COLORTERM"] = "truecolor" },
          sorting_strategy = "ascending",
          pickers = {
            buffers = { show_all_buffers = true },
            git_status = {
              theme = "ivy",
              git_icons = {
                added = "+",
                changed = "~",
                copied = "",
                deleted = "-",
                renamed = ">",
                unmerged = "^",
                untracked = "?",
              },
            },
            find_files = {
              find_command = {
                "rg",
                "--color=never",
                "--with-filename",
                "--files",
                "--iglob",
                "'!.git'",
                "--iglob",
                "'!pnpm-lock.yaml'",
                "--iglob",
                "'yarn.lock'",
                "--iglob",
                "'package-lock.json'",
                "--hidden",
                "--line-number",
                "--column",
                "--smart-case",
                "--trim",
              },
            },
          },
          layout_config = {
            height = 0.9,
            width = 0.9,
            prompt_position = "top",
            horizontal = layoutConfig,
            vertical = layoutConfig,
          },
          windblend = 20,
          borderchars = {
            prompt = { "▀", "▐", "▄", "▌", "▛", "▜", "▟", "▙" },
            results = { " ", "▐", "▄", "▌", "▌", "▐", "▟", "▙" },
            preview = { "▀", "▐", "▄", "▌", "▛", "▜", "▟", "▙" },
          },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
          fzf = {
            fuzzy = true,
            case_mode = "smart_case",
            override_file_sorter = true,
            override_generic_sorter = true,
          },
          import = {
            insert_at_top = true,
            custom_languages = {
              {
                extensions = { "js", "ts" },
                filetypes = { "vue" },
                insert_at_line = 2,
                regex = [[^(?:import(?:[\"'\s]*([\w*{}\n, ]+)from\s*)?[\"'\s](.*?)[\"'\s].*)]],
              },
            },
          },
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "file_browser")
      pcall(telescope.load_extension, "ui-select")
      pcall(telescope.load_extension, "import")
      telescope.register_extension({ exports = { terms = wrapper } })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "[ ] Find files" })
      vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[f]ind recent files ("." for repeat)' })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind [b]uffers" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[f]ind [d]iagnostics" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind by [g]rep" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[f]ind [k]eymaps" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[f]ind [r]esume" })
      vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[f]ind [s]elect telescope" })
      vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "[f]ind with [t]reesitter" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[f]ind current [w]ord" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          previewer = false,
          layout_config = {
            height = 0.9,
            width = 0.9,
            prompt_position = "top",
            horizontal = layoutConfig,
            vertical = layoutConfig,
          },
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>f/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch [/] in Open Files" })

      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })

      vim.keymap.set("n", "<leader>f\\", function()
        telescope.extensions.file_browser.file_browser({
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = true,
        })
      end, { desc = "Telescope file browser" })
    end,
  },
}
