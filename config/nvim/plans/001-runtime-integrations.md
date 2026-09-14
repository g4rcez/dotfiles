# Plan 001: Make Markdown image paste and DAP UI functional

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report — do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 9e0ca10..HEAD -- lua/config/markdown_viewer.lua lua/plugins/markdown.lua lua/plugins/debug.lua init.lua tests`
> If any in-scope file changed since this plan was written, compare the current-state excerpts with the live code before proceeding.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: bug
- **Status**: Complete
- **Planned at**: commit `9e0ca10`, 2026-09-14

## Why this matters

Markdown image paste currently defers a missing local-module error until the first image is pasted. The DAP stack installs `nvim-dap-ui`, but does not call its setup function or connect it to DAP lifecycle events; `dapui.toggle()` currently fails. This plan makes both advertised workflows usable without adding dependencies or changing the plugin lockfile.

## Current state

- `lua/plugins/markdown.lua:7-11` sets `img-clip.nvim`'s `dir_path` to `require("config.markdown_viewer").image_dir()`, but `lua/config/markdown_viewer.lua` does not exist.
- `lua/plugins/debug.lua:4` declares `rcarriga/nvim-dap-ui` as a lazy dependency.
- `lua/plugins/debug.lua:142-150` configures DAP and Mason only; there is no `require("dapui").setup()`, DAP listener, or DAP UI keymap.
- `nvim --headless -u init.lua '+lua require("lazy").load({plugins={"nvim-dap"}}); local ok,err=pcall(require("dapui").toggle); print(ok,err)' '+qa!'` currently reports `ok=false` and an error from `dapui/controls.lua`.

Use the existing plugin style in `lua/plugins/markdown.lua` and `lua/plugins/debug.lua`. Do not update `lazy-lock.json` or add packages.

## Commands you will need

| Purpose | Command | Expected on success |
| --- | --- | --- |
| Syntax | `nvim --headless -u NONE -c 'lua local n=0; for _,f in ipairs(vim.fn.glob("lua/**/*.lua",false,true)) do local c,e=loadfile(f); if not c then print(f,e); n=n+1 end end; if n>0 then vim.cmd("cquit 1") end' -c 'qa!'` | Exit 0 and no syntax errors |
| Startup | `nvim --headless -u init.lua '+qa!'` | Exit 0 |
| DAP smoke | `nvim --headless -u init.lua '+lua require("lazy").load({plugins={"nvim-dap"}}); assert(pcall(require("dapui").toggle)); require("dapui").close()' '+qa!'` | Exit 0 |

## Scope

**In scope**:

- `lua/config/markdown_viewer.lua` (create)
- `lua/plugins/markdown.lua`
- `lua/plugins/debug.lua`

**Out of scope**:

- Clipboard handling in `lua/plugins/mini.lua`; the user explicitly chose to skip that security finding.
- DAP adapter definitions and language-specific launch configurations; only configure the declared UI.
- `lazy-lock.json` and dependency versions.
- Existing modified or untracked files not listed above.

## Git workflow

- Work in the current branch. Do not create branches or worktrees.
- Run `git diff --cached --quiet --` before implementation. If it fails, stop and list staged paths.
- Preserve all pre-existing unstaged and untracked work. Do not reset, delete, stage, or commit.

## Steps

### Step 1: Add the Markdown image-directory helper

Create `lua/config/markdown_viewer.lua` returning a module with `image_dir()`. Resolve the current buffer's absolute file directory; for an unnamed buffer, use the current working directory. Return an `images` child directory and create it with `vim.fn.mkdir(dir, "p")`. Keep the returned path absolute; `img-clip.nvim` already has `use_absolute_path = false` for generated Markdown links.

Do not change the existing `img-clip` filetype list or template.

**Verify**: `nvim --headless -u NONE --cmd 'set rtp+=.' '+lua local m=require("config.markdown_viewer"); assert(type(m.image_dir()) == "string"); print("markdown image dir: PASS")' '+qa!'` → prints `markdown image dir: PASS` and exits 0.

### Step 2: Configure DAP UI lifecycle and a unique toggle key

In the existing `mfussenegger/nvim-dap` config function, require DAP and DAP UI, call `dapui.setup()`, and register stable listener keys for `event_initialized`, `event_terminated`, and `event_exited`. Open the UI on initialization and close it on termination or exit. Add `<leader>du` to the DAP key list for `dapui.toggle()` with description `Toggle DAP UI`.

Keep the existing DAP controls, Mason call, JSONC decoder, and key choices unchanged. Do not configure adapters in this plan.

**Verify**: run the DAP smoke command above → exit 0; `dapui.toggle()` must not raise an error.

### Step 3: Run the integration checks

Run the syntax and startup commands above. Do not treat a clean startup alone as proof of the Markdown path because the missing module is lazy; retain the direct module assertion from Step 1.

**Verify**: all three commands exit 0.

## Test plan

- Directly require `config.markdown_viewer` and assert `image_dir()` returns a string.
- Force-load DAP and assert `dapui.toggle()` succeeds.
- Use the existing `tests/contextual_completion.lua` unchanged as the repository's standalone test pattern.

## Done criteria

- [x] `lua/config/markdown_viewer.lua` exists and returns an absolute, created `images` directory.
- [x] Image paste configuration no longer references a missing module.
- [x] `dapui.setup()` and lifecycle listeners exist exactly once.
- [x] `<leader>du` is the DAP UI toggle.
- [x] Syntax, startup, and DAP smoke commands exit 0.
- [x] No files outside the in-scope list are modified.

## STOP conditions

Stop and report if:

- The intended image directory is documented elsewhere and is not `images` beside the current Markdown file.
- The installed `nvim-dap-ui` API cannot toggle after `setup()` without changing a dependency.
- The drift check shows a listed file changed after this plan was written.
- A verification command fails twice after a reasonable fix attempt.

## Maintenance notes

- If the Markdown storage policy changes, update `image_dir()` and its direct assertion together.
- DAP adapters remain a separate concern; do not silently add Mason adapters or launch configurations here.
- Review listener keys for duplicate registration after `:Lazy reload`.
