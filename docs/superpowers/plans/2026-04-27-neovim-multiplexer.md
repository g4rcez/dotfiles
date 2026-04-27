# Neovim as Terminal Multiplexer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace tmux with a single Neovim instance that manages multiple simultaneous projects using tab pages as workspaces, resession.nvim for session persistence, Snacks terminal for terminals, and nvr for git editor integration.

**Architecture:** Neovim tab pages act as workspaces — each has a tab-local cwd (`tcd`), its own bufferline view, and a named session. `resession.nvim` replaces `persistence.nvim` and saves a `"last"` session on exit covering all workspaces; individual project sessions are saved/restored per-path. `nvr` (neovim-remote) is installed via mise and set as `$GIT_EDITOR` inside Neovim terminals so git opens files in the running instance.

**Tech Stack:** Neovim (lazy.nvim), `stevearc/resession.nvim`, `akinsho/bufferline.nvim`, `folke/snacks.nvim` (terminal + dashboard), `neovim-remote` (mise tool), zsh

---

### Task 1: Install nvr via mise

**Files:**
- Modify: `config/mise/config.toml`

- [ ] **Step 1: Add neovim-remote to mise tools**

Open `config/mise/config.toml`. Under `[tools]`, add this line after the last existing tool:

```toml
neovim-remote = "latest"
```

The `[tools]` block should look like:
```toml
[tools]
usage = "1.3.4"
node = "24.14.0"
bun = "1.1.38"
deno = "2.4.5"
java = "corretto-23.0.1.8.1"
python = "3.13.0"
dotnet = "10.0.100"
uv = "0.8.18"
neovim-remote = "latest"
```

- [ ] **Step 2: Install the tool**

```bash
mise install
```

Expected output: lines mentioning `neovim-remote` being installed.

- [ ] **Step 3: Verify nvr is available**

```bash
nvr --version
```

Expected output: something like `2.5.1` (version number). If `command not found`, run `mise reshim` and retry.

- [ ] **Step 4: Commit**

```bash
git add config/mise/config.toml
git commit -m "feat(mise): add neovim-remote for nvim-as-multiplexer git integration"
```

---

### Task 2: Replace persistence.nvim with resession.nvim

**Files:**
- Modify: `config/nvim/lua/plugins/session.lua` (full replacement)

`resession.nvim` saves named sessions (files under `~/.local/share/nvim/sessions/`). We configure it to:
- Auto-save a `"last"` session on `VimLeavePre` (captures all workspaces)
- Track which tab page each buffer is entered in via a `BufEnter` autocmd — this powers the bufferline tab-scoping in Task 3
- Expose a `workspace_session_name(dir)` helper used by the keymaps in Task 4

- [ ] **Step 1: Replace session.lua entirely**

Write the following to `config/nvim/lua/plugins/session.lua`:

```lua
return {
    {
        "stevearc/resession.nvim",
        lazy = false,
        opts = {},
        config = function(_, opts)
            local resession = require("resession")
            resession.setup(opts)

            -- Tag each buffer with the tabpage(s) it was entered in.
            -- bufferline reads vim.b[buf].workspace_tabs to filter per-tab.
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function(ev)
                    local tab = tostring(vim.api.nvim_get_current_tabpage())
                    local tags = vim.b[ev.buf].workspace_tabs or {}
                    tags[tab] = true
                    vim.b[ev.buf].workspace_tabs = tags
                end,
            })

            -- Auto-save all workspaces on exit
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function()
                    resession.save("last", { notify = false })
                end,
            })
        end,
    },
}
```

- [ ] **Step 2: Open Neovim and verify it loads without errors**

```bash
nvim --headless -c "lua require('resession')" -c "qa"
```

Expected: exits with no error output. If you see an error, check that lazy.nvim can find `stevearc/resession.nvim` (it will auto-install on first open).

- [ ] **Step 3: Open Neovim normally and run `:Lazy` to confirm resession installed**

Open a terminal and run `nvim`. Press `<leader>` to open which-key or just run `:Lazy`. Verify `resession.nvim` appears in the plugin list as installed (not errored).

- [ ] **Step 4: Verify a session saves on exit**

Open `nvim`, edit any file, then quit. Check:

```bash
ls ~/.local/share/nvim/sessions/
```

Expected: a file named `last.json` (or similar) appears.

- [ ] **Step 5: Commit**

```bash
git add config/nvim/lua/plugins/session.lua
git commit -m "feat(nvim): replace persistence.nvim with resession.nvim for workspace sessions"
```

---

### Task 3: Add S key to Snacks dashboard

**Files:**
- Modify: `config/nvim/lua/plugins/snacks.lua`

The current dashboard config is just `dashboard = { enabled = true }` which uses Snacks defaults. We extend it with an explicit `keys` list that includes `S` for session restore alongside the standard defaults.

- [ ] **Step 1: Find the dashboard entry in snacks.lua**

In `config/nvim/lua/plugins/snacks.lua`, find this line (around line 40):

```lua
                dashboard = { enabled = true },
```

- [ ] **Step 2: Replace with extended dashboard config**

Replace:
```lua
                dashboard = { enabled = true },
```

With:
```lua
                dashboard = {
                    enabled = true,
                    keys = {
                        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
                        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
                        {
                            icon = " ",
                            key = "S",
                            desc = "Restore Session",
                            action = function()
                                require("resession").load("last", { silence_errors = true })
                            end,
                        },
                        { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
```

- [ ] **Step 3: Verify dashboard shows S key**

Open `nvim` without arguments. The Snacks dashboard should appear. Confirm `S` is listed as "Restore Session". Press `S` — it should silently load or do nothing if no session exists yet (no error).

- [ ] **Step 4: Commit**

```bash
git add config/nvim/lua/plugins/snacks.lua
git commit -m "feat(nvim): add S key to dashboard for session restore"
```

---

### Task 4: Add bufferline tab-scoping

**Files:**
- Modify: `config/nvim/lua/plugins/bufferline.lua`

Bufferline's `custom_filter` receives each buffer's number and returns `true` to show it. We read `vim.b[buf].workspace_tabs` (set by the `BufEnter` autocmd in Task 2) and only show buffers tagged for the current tabpage handle.

- [ ] **Step 1: Update bufferline.lua**

Replace the full content of `config/nvim/lua/plugins/bufferline.lua` with:

```lua
return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = function()
            return {
                options = {
                    mode = "buffers",
                    diagnostics = "nvim_lsp",
                    indicator = { style = "none" },
                    highlights = require("catppuccin.special.bufferline").get_theme(),
                    custom_filter = function(buf_id, _buf_ids)
                        local tab = tostring(vim.api.nvim_get_current_tabpage())
                        local tags = vim.b[buf_id].workspace_tabs or {}
                        return tags[tab] == true
                    end,
                },
            }
        end,
    },
}
```

- [ ] **Step 2: Verify bufferline filters correctly**

Open `nvim`. Open two files — both should appear in bufferline. Run `:tabnew` then open a third file. The third file should appear in the new tab's bufferline but NOT in the first tab's bufferline when you switch back with `:tabprev`. Check by pressing `gt` to toggle between tabs.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/bufferline.lua
git commit -m "feat(nvim): scope bufferline to current workspace tab"
```

---

### Task 5: Add workspace keymaps

**Files:**
- Modify: `config/nvim/lua/config/keymaps.lua`

Add all workspace keymaps at the end of the file. The `WorkspaceSessionName` global is defined in Task 2's `session.lua`.

- [ ] **Step 1: Append workspace keymaps to keymaps.lua**

Add the following block at the very end of `config/nvim/lua/config/keymaps.lua`:

```lua
-- Workspace (tab page) management — replaces tmux sessions
local function workspace_session_name(dir)
    dir = dir or vim.fn.getcwd(-1, vim.fn.tabpagenr())
    return vim.fn.fnamemodify(dir, ":~"):gsub("[/\\: ]", "_")
end

local function workspace_open()
    local dir = vim.fn.input("Workspace path: ", vim.fn.expand("~") .. "/", "dir")
    if dir == "" then return end
    dir = vim.fn.fnamemodify(dir, ":p")
    if vim.fn.isdirectory(dir) == 0 then
        vim.notify("Not a directory: " .. dir, vim.log.levels.ERROR)
        return
    end
    vim.cmd("tabnew")
    vim.cmd("tcd " .. vim.fn.fnameescape(dir))
    local name = workspace_session_name(dir)
    pcall(require("resession").load, name, { silence_errors = true })
end

local function workspace_close()
    local dir = vim.fn.getcwd(-1, vim.fn.tabpagenr())
    local name = workspace_session_name(dir)
    pcall(require("resession").save, name, { notify = false })
    if vim.fn.tabpagenr("$") > 1 then
        vim.cmd("tabclose")
    else
        vim.cmd("%bd")
        vim.notify("Last workspace — buffers cleared")
    end
end

local function workspace_save()
    local dir = vim.fn.getcwd(-1, vim.fn.tabpagenr())
    local name = workspace_session_name(dir)
    require("resession").save(name)
end

bind.normal("<leader>wo", workspace_open, { desc = "[w]orkspace [o]pen" })
bind.normal("<leader>wc", workspace_close, { desc = "[w]orkspace [c]lose" })
bind.normal("<leader>ws", workspace_save, { desc = "[w]orkspace [s]ave session" })
bind.normal("<leader>wt", function()
    Snacks.terminal.toggle(nil, { cwd = vim.fn.getcwd(-1, vim.fn.tabpagenr()) })
end, { desc = "[w]orkspace [t]erminal" })

for i = 1, 9 do
    bind.normal("<leader>" .. i, function()
        local ok, err = pcall(vim.cmd, "tabnext " .. i)
        if not ok then
            vim.notify("No workspace " .. i, vim.log.levels.WARN)
        end
    end, { desc = "Workspace " .. i })
end
```

- [ ] **Step 2: Verify keymaps work — open a workspace**

Open `nvim`. Press `<leader>wo`. A prompt `Workspace path: ~/` should appear. Type a valid directory path (e.g. `~/dotfiles`) and press Enter. A new tab should open with that directory as cwd. Confirm with `:pwd` — it should show the path you entered.

- [ ] **Step 3: Verify workspace switching**

With two workspaces open (two tabs), press `<leader>1` — should jump to workspace 1. Press `<leader>2` — should jump to workspace 2. Press `<leader>9` — should show a "No workspace 9" notification.

- [ ] **Step 4: Verify workspace close**

Press `<leader>wc` while in workspace 2. It should close that tab and return to workspace 1. Run `:lua vim.print(require("resession").list())` — the closed workspace's session name should appear in the list.

- [ ] **Step 5: Verify terminal opens in workspace cwd**

Open a workspace pointing to `~/dotfiles` (via `<leader>wo`). Press `<leader>wt`. A terminal should open. Inside the terminal, run `pwd` — it should print the dotfiles path, not `~`.

- [ ] **Step 6: Commit**

```bash
git add config/nvim/lua/config/keymaps.lua
git commit -m "feat(nvim): add workspace keymaps for multiplexer-style session management"
```

---

### Task 6: Set GIT_EDITOR to nvr inside Neovim terminals

**Files:**
- Modify: `config/zsh/git.sh`

`$NVIM` is set automatically by Neovim when you open a terminal inside it — it contains the socket path. We use this to conditionally set `GIT_EDITOR` to `nvr --remote-tab-wait` only when inside a Neovim terminal. Outside Neovim, git uses the default editor (`nvim` from `$EDITOR`).

`nvr --remote-tab-wait` opens the file in a new tab in the running Neovim and waits (blocks the git process) until that buffer is deleted (`:bd`), which signals git that the message/rebase is done.

- [ ] **Step 1: Add GIT_EDITOR conditional to git.sh**

Open `config/zsh/git.sh`. After the `autoload -Uz is-at-least` line at the top (line 2), add:

```zsh
# When inside a Neovim terminal, use nvr so git opens files in the running instance
if [[ -n "$NVIM" ]] && command -v nvr &>/dev/null; then
    export GIT_EDITOR="nvr --remote-tab-wait"
fi
```

- [ ] **Step 2: Reload zsh and verify outside Neovim**

```bash
source ~/dotfiles/config/zsh/git.sh
echo $GIT_EDITOR
```

Expected: empty output (or whatever your default was). `$NVIM` is not set in a regular terminal, so the block should not execute.

- [ ] **Step 3: Verify inside Neovim**

Open `nvim`. Press `<leader>wt` to open a terminal. Inside the terminal run:

```bash
echo $GIT_EDITOR
```

Expected: `nvr --remote-tab-wait`

- [ ] **Step 4: Verify git commit opens in Neovim**

Inside the Neovim terminal, navigate to any git repo and run:

```bash
git commit --allow-empty
```

Expected: a new buffer opens in the running Neovim (not a nested nvim). Write the commit message and run `:bd` — git should proceed and complete the commit.

- [ ] **Step 5: Commit**

```bash
git add config/zsh/git.sh
git commit -m "feat(zsh): use nvr as GIT_EDITOR inside Neovim terminals"
```

---

### Task 7: Smoke test the full flow

No file changes. This task verifies everything works end-to-end.

- [ ] **Step 1: Start fresh — open Neovim**

```bash
nvim
```

Dashboard should appear with the `S` key visible.

- [ ] **Step 2: Open two workspaces**

Press `<leader>wo` → enter `~/dotfiles` → confirm it opens a new tab with that cwd.
Press `<leader>wo` again → enter another directory → confirm second workspace opens.

- [ ] **Step 3: Open buffers in each workspace and verify bufferline isolation**

In workspace 1: open a file with `<leader><space>`. It should appear in bufferline.
Switch to workspace 2 with `<leader>2`. The workspace-1 file should NOT appear in bufferline.
Open a different file in workspace 2. It should appear in bufferline.
Switch back to workspace 1 with `<leader>1`. Only workspace-1's files should appear.

- [ ] **Step 4: Save, quit, and restore**

Press `<leader>ws` to save each workspace session.
Quit nvim: `:qa`
Reopen `nvim`. Dashboard appears.
Press `S`. Both workspaces should restore (two tab pages, each with their buffers).

- [ ] **Step 5: Verify git integration in terminal**

Open a terminal with `<leader>wt`. Navigate to a git repo. Run `git commit --allow-empty`. Confirm it opens in Neovim, not a nested editor. Write message, `:bd` to finish.
