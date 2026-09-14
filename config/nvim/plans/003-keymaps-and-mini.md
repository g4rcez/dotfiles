# Plan 003: Make keymap ownership explicit and consolidate Mini

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report — do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 9e0ca10..HEAD -- lua/config/keymaps.lua lua/config/lsp.lua lua/plugins/snacks.lua lua/plugins/yanky.lua lua/plugins/codeactions.lua lua/plugins/treesitter.lua lua/plugins/mini.lua lua/plugins/whichkey.lua`

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: dx
- **Status**: Complete
- **Planned at**: commit `9e0ca10`, 2026-09-14

## Why this matters

Several mappings have multiple owners, so the final behavior depends on plugin load order and buffer type. The most important examples are project palette versus Yanky on `<leader>p`, generic code actions versus tiny-code-action on `<leader>ca`, and two separate implementations of `<leader>bd`. Mini is also installed both as the full `mini.nvim` distribution and as separate `mini.pairs` and `mini.bracketed` distributions, which puts duplicate Lua modules on runtimepath.

## Current state

- `lua/plugins/snacks.lua:403` maps `<leader>p` to the project palette; `lua/plugins/yanky.lua:9` maps the same key to Yanky.
- `lua/config/lsp.lua:117` maps `<leader>ca` to `vim.lsp.buf.code_action`; `lua/plugins/codeactions.lua:8` maps it to `tiny-code-action`.
- `lua/config/keymaps.lua:108` maps `<leader>bd`; `lua/plugins/snacks.lua:897` maps it again.
- `lua/config/keymaps.lua:121` and `lua/plugins/mini.lua:71` both map `<leader>g=`.
- `lua/plugins/snacks.lua:947-955` maps `[[` and `]]`; `lua/plugins/treesitter.lua:269,294` maps them again.
- `lua/plugins/treesitter.lua:307-310` maps `[d` and `]d`, while Mini bracketed and LSP diagnostics also use those keys.
- `lua/plugins/mini.lua:3` declares `nvim-mini/mini.pairs`, `lua/plugins/mini.lua:27` declares `nvim-mini/mini.bracketed`, and `lua/plugins/mini.lua:43` loads `nvim-mini/mini.nvim`.
- Runtime inspection currently shows duplicate module paths for both `lua/mini/pairs.lua` and `lua/mini/bracketed.lua`.

## Commands you will need

| Purpose | Command | Expected on success |
| --- | --- | --- |
| Syntax | `nvim --headless -u NONE -c 'lua local n=0; for _,f in ipairs(vim.fn.glob("lua/**/*.lua",false,true)) do local c,e=loadfile(f); if not c then print(f,e); n=n+1 end end; if n>0 then vim.cmd("cquit 1") end' -c 'qa!'` | Exit 0 |
| Runtime paths | `nvim --headless -u init.lua '+lua assert(#vim.api.nvim_get_runtime_file("lua/mini/pairs.lua",true)==1); assert(#vim.api.nvim_get_runtime_file("lua/mini/bracketed.lua",true)==1)' '+qa!'` | Exit 0 |
| Existing test | `nvim --headless -u NONE -l tests/contextual_completion.lua` | Prints `contextual_completion: PASS` |

## Scope

**In scope**:

- `lua/config/keymaps.lua` (only conflicting native mappings; preserve unrelated user edits)
- `lua/config/lsp.lua` (only the duplicate code-action mapping)
- `lua/plugins/snacks.lua`
- `lua/plugins/yanky.lua`
- `lua/plugins/codeactions.lua`
- `lua/plugins/treesitter.lua`
- `lua/plugins/mini.lua`
- `lua/plugins/whichkey.lua`
- `lua/plugins/vscode.lua` (remove stale Mini spec reference)

**Out of scope**:

- The explicit clipboard security finding in `lua/plugins/mini.lua`; do not change the AppleScript clipboard commands.
- VS Code-specific mappings in the `if vscode.isVscode()` block.
- Intentional buffer-local mappings inside Oil, Mini Files, terminals, and Gitsigns.
- `lua/config/diagnostics.lua` and the `<leader>xd` implementation; Plan 004 owns those changes.
- Existing modified or untracked files not listed above.

## Git workflow

- Run `git diff --cached --quiet --` before implementation; stop if staged changes exist.
- Preserve all unstaged and untracked work. Do not reset, clean, stage, or commit.

## Target ownership table

The implementation must produce this ownership table. Context-specific mappings are listed once and must not be duplicated globally.

| Mapping | Owner | Context | Result |
| --- | --- | --- | --- |
| `<leader>p` | Snacks project palette | Native Neovim | Keep |
| `<leader>py` | Yanky | Native Neovim | Move from `<leader>p` |
| `<leader>bd` | Snacks buffer delete | Native Neovim | Keep one owner |
| `<leader>ca` | tiny-code-action | LSP buffers | Remove generic competing map |
| `<leader>g=` | Mini diff | Native Neovim | Keep one owner |
| `[[` / `]]` | Treesitter textobject movement | Code buffers | Remove Snacks words mappings |
| `[d` / `]d` | Mini/LSP diagnostic navigation | All/LSP buffers | Remove Treesitter conditional mappings |
| `<C-j>` / `<C-k>` | Blink completion in insert mode; multicursor in normal/visual mode | Different modes | Keep; not a conflict |

## Steps

### Step 1: Remove exact duplicate owners

Move Yanky's picker mapping from `<leader>p` to `<leader>py`. Remove the generic `<leader>ca` mapping from the LSP attach handler so the tiny-code-action plugin owns it. Remove the duplicate `<leader>bd` mapping from the base keymap or the Snacks key list, keeping the Snacks buffer-delete behavior. Keep `<leader>g=` in the Mini plugin and remove the other copy.

Do not alter descriptions or mappings outside these exact conflicts.

**Verify**: start Neovim with a TypeScript fixture and run `:verbose nmap <Space>p`, `:verbose nmap <Space>py`, `:verbose nmap <Space>ca`, `:verbose nmap <Space>bd`, and `:verbose nmap <Space>g=`; each must show the owner in the target table.

### Step 2: Resolve navigation conflicts

Remove Snacks `[[` and `]]` key specs so Treesitter textobject movement owns them. Remove Treesitter's `[d` and `]d` conditional movement mappings so Mini bracketed or the LSP buffer-local maps own diagnostic navigation. Remove the duplicate `<leader>a` group declaration in `lua/plugins/whichkey.lua`.

Do not move the conditional textobject feature to another key in this plan; removing the shadowed mapping is safer than introducing another collision.

**Verify**: `nvim --headless -u init.lua '+verbose nmap [[ ' '+verbose nmap ]]' '+verbose nmap [d' '+verbose nmap ]d' '+qa!'` → each mapping has one effective owner and exits 0.

### Step 3: Keep only the full Mini distribution

Remove the standalone `nvim-mini/mini.pairs` and `nvim-mini/mini.bracketed` plugin specs from `lua/plugins/mini.lua`. Move their `opts` into the `nvim-mini/mini.nvim` config and call `mini.pairs.setup(...)` and `mini.bracketed.setup(...)` from the same configuration that already initializes other Mini modules. Preserve the existing Mini pairs and bracketed options exactly.

Do not remove `mini.nvim`; it supplies the configured `mini.ai`, `mini.surround`, `mini.diff`, `mini.git`, `mini.files`, and other modules.

**Verify**: run the runtime-path command above → both duplicate-module assertions pass; inspect `require("lazy").plugins()` and confirm no `mini.pairs` or `mini.bracketed` plugin specs remain.

### Step 4: Verify the final ownership table

Run the syntax and existing-test commands. Then use `:verbose nmap` in a normal TypeScript project and compare every changed mapping with the table above. Record the final table in the implementation response.

**Verify**: all commands exit 0 and no changed mapping has a second effective global owner.

## Test plan

- Test each exact duplicate with `:verbose nmap` in a TypeScript buffer and a normal buffer where relevant.
- Assert only one runtime path exists for `mini.pairs` and `mini.bracketed`.
- Run `tests/contextual_completion.lua` unchanged.

## Done criteria

- [x] The target ownership table matches runtime `:verbose nmap` output.
- [x] Yanky is available on `<leader>py` and project palette remains on `<leader>p`.
- [x] Tiny-code-action owns `<leader>ca` on LSP buffers.
- [x] Only one mapping owns each of `<leader>bd` and `<leader>g=`.
- [x] Snacks no longer shadows Treesitter `[[`/`]]`.
- [x] Treesitter no longer shadows diagnostic `[d`/`]d`.
- [x] Only `mini.nvim` supplies Mini modules.
- [x] No out-of-scope mapping or clipboard command changes are made.

## STOP conditions

Stop and report if:

- A target key is intentionally buffer-local in the live configuration and removing the global mapping would break that intended context.
- Tiny-code-action cannot register `<leader>ca` without restoring the generic mapping.
- Removing standalone Mini specs changes a module API or makes an existing Mini setup fail.
- The drift check shows current user edits in a conflicting block; preserve them and report instead of overwriting.

## Maintenance notes

- New plugin mappings must be checked with `:verbose nmap` before using an existing key.
- Keep plugin-owned mappings in the plugin spec when they are lazy-load triggers; keep generic mappings in `config/keymaps.lua` only when no plugin owns the key.
- If the Mini distribution changes again, verify runtimepath does not contain duplicate `lua/mini/*.lua` providers.
