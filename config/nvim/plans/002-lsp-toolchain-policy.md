# Plan 002: Make LSP and formatter tooling project-aware

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report — do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 9e0ca10..HEAD -- lua/config/lsp.lua lua/config/ensure-installed.lua lua/config/javascript_tools.lua lua/plugins/format.lua lua/plugins/mason.lua`

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: migration
- **Status**: Complete
- **Planned at**: commit `9e0ca10`, 2026-09-14

## Why this matters

JavaScript projects can attach both ESLint and Oxlint when both configuration files exist, producing duplicate diagnostics. The current tool list also omits configured linters and Python formatters, so linting fails with missing executable errors. Mason currently has both `mason-tool-installer.nvim` and a second manual installation loop; one installer and one shared tool list will make fresh machines predictable.

## Current state

- `lua/config/ensure-installed.lua:26` installs `prettier`, `shfmt`, `stylua`, `eslint_d`, `rustywind`, and `oxfmt`.
- `lua/plugins/format.lua:42-45` uses unsupported direct `trailingComma` fields instead of formatter arguments.
- `lua/plugins/format.lua:67` uses `isort` and `black`; `lua/plugins/format.lua:75-79` uses `stylelint`, `yamllint`, and `hadolint`.
- `lua/config/lsp.lua:430` enables both `eslint` and `oxlint` from `ensure-installed.lua`.
- `lua/config/lsp.lua:263` configures Oxlint markers, but ESLint relies on the upstream default root detector.
- `lua/plugins/mason.lua:4-17` declares Mason installers, while `lua/plugins/mason.lua:31-40` refreshes the registry and manually installs the same tool list.
- A TypeScript fixture with both `oxlint.json` and `eslint.config.js` currently attaches `harper_ls`, `eslint`, `oxlint`, and `tsgo`; the ESLint process also reports that its library is unavailable.

## Commands you will need

| Purpose | Command | Expected on success |
| --- | --- | --- |
| Syntax | `nvim --headless -u NONE -c 'lua local n=0; for _,f in ipairs(vim.fn.glob("lua/**/*.lua",false,true)) do local c,e=loadfile(f); if not c then print(f,e); n=n+1 end end; if n>0 then vim.cmd("cquit 1") end' -c 'qa!'` | Exit 0 |
| Formatter config | `nvim --headless -u init.lua '+lua require("lazy").load({plugins={"conform.nvim"}}); local c=require("conform").get_formatter_config("prettier",0); assert(c.append_args and #c.append_args == 2)' '+qa!'` | Exit 0 |
| Existing test | `nvim --headless -u NONE -l tests/contextual_completion.lua` | Prints `contextual_completion: PASS` |

## Scope

**In scope**:

- `lua/config/javascript_tools.lua` (create)
- `lua/config/lsp.lua`
- `lua/config/ensure-installed.lua`
- `lua/plugins/format.lua`
- `lua/plugins/mason.lua`

**Out of scope**:

- Changes to project ESLint or Oxlint configuration files.
- Removing either LSP from the global list; both remain available, but Oxlint takes precedence when both configs exist.
- Adding dependencies or updating `lazy-lock.json`.
- Formatter behavior unrelated to the currently configured filetypes.
- Existing modified or untracked files not listed above.

## Git workflow

- Run `git diff --cached --quiet --` before implementation; stop if staged changes exist.
- Preserve all unstaged and untracked work. Do not reset, clean, stage, or commit.

## Steps

### Step 1: Centralize JavaScript tool markers and precedence

Create `lua/config/javascript_tools.lua` with shared marker lists:

- Oxlint: `oxlint.json`, `.oxlintrc.json`, `oxlint.config.js`, `oxlint.config.ts`, `oxlint.config.mjs`, `oxlint.config.cjs`.
- ESLint: `.eslintrc`, `.eslintrc.json`, `.eslintrc.js`, `.eslintrc.cjs`, `.eslintrc.mjs`, `.eslintrc.yml`, `.eslintrc.yaml`, `eslint.config.js`, `eslint.config.cjs`, `eslint.config.mjs`, `eslint.config.ts`, `eslint.config.cts`, `eslint.config.mts`.

Expose helpers that find the nearest config directory. `eslint_root(bufnr)` must return nil when an Oxlint root exists. `oxlint_root(bufnr)` must return nil when no Oxlint marker exists. Keep helpers pure apart from filesystem reads.

**Verify**: `nvim --headless -u NONE --cmd 'set rtp+=.' '+lua local t=require("config.javascript_tools"); assert(#t.oxlint_markers > 0 and #t.eslint_markers > 0); print("tool markers: PASS")' '+qa!'` → prints `tool markers: PASS`.

### Step 2: Apply the policy to LSP startup and formatter selection

In `lua/config/lsp.lua`, configure both servers with the shared helpers. ESLint must call `on_dir` only for `eslint_root(bufnr)`; Oxlint must call `on_dir` only for `oxlint_root(bufnr)`. This ensures neither server starts without its own config and prevents duplicate JS lint diagnostics when both configs are present.

In `lua/plugins/format.lua`, use `config.javascript_tools.oxlint_root(bufnr)` for the Oxc formatter decision instead of maintaining a second marker list.

Replace the `trailingComma` formatter fields with `append_args = { "--trailing-comma", "none" }` for Prettier and Oxfmt. Remove the unused `prettierd` override unless a current formatter mapping is added for it.

**Verify**: run the formatter-config command above → `append_args` exists; run the syntax command → exit 0.

### Step 3: Align Mason with configured tools

Change `lua/config/ensure-installed.lua` to expose one tool list containing every configured external formatter and linter: `prettier`, `shfmt`, `stylua`, `oxfmt`, `isort`, `black`, `stylelint`, `yamllint`, and `hadolint`. Remove `eslint_d` and `rustywind` from the managed list because no current Conform or nvim-lint mapping invokes them.

Keep `mason-lspconfig.nvim` for LSP installation and `mason-tool-installer.nvim` for tools. Remove the manual registry refresh/install loop from `lua/plugins/mason.lua`; do not configure the same list through core Mason options and the tool installer. Preserve `MasonUpdate` and the existing LSP exclusion for `kulala_ls`.

**Verify**: `nvim --headless -u NONE --cmd 'set rtp+=.' '+lua local e=require("config.ensure-installed"); local wanted={prettier=true,shfmt=true,stylua=true,oxfmt=true,isort=true,black=true,stylelint=true,yamllint=true,hadolint=true}; for _,x in ipairs(e.tools) do wanted[x]=nil end; for x in pairs(wanted) do error("missing tool "..x) end; print("managed tools: PASS")' '+qa!'` → prints `managed tools: PASS`.

### Step 4: Verify project behavior

Create temporary projects outside the repository and open a TypeScript file with the normal configuration:

1. package.json only: neither ESLint nor Oxlint should attach.
2. package.json plus `eslint.config.js`: only ESLint should attach.
3. package.json plus `oxlint.json`: only Oxlint should attach.
4. both config files: only Oxlint should attach.

Use a headless Lua assertion over `vim.lsp.get_clients({ bufnr = 0 })`; ignore `harper_ls` and `tsgo` when checking the linter set. Do not install tools during this verification.

**Verify**: each fixture exits 0 and reports the expected linter set.

## Test plan

- Test marker helper behavior for no config, ESLint only, Oxlint only, and both.
- Test formatter config contains CLI arguments rather than an unused `trailingComma` field.
- Run `tests/contextual_completion.lua` unchanged.

## Done criteria

- [x] ESLint and Oxlint only start when their configuration exists.
- [x] Oxlint wins when both configurations exist.
- [x] All configured formatter/linter executables appear in the one managed Mason tool list.
- [x] No manual duplicate Mason installation loop remains.
- [x] Conform passes trailing-comma arguments through `append_args`.
- [x] All listed verification commands pass.

## STOP conditions

Stop and report if:

- The installed Neovim API rejects the planned `root_dir(bufnr, on_dir)` callback shape.
- A project uses an ESLint configuration format not represented by the marker list; do not broaden markers silently.
- Mason does not recognize one of the configured package names; report the package name instead of installing an alternative.
- Both-linter fixture behavior cannot be made deterministic without changing project files.

## Maintenance notes

- Add new ESLint or Oxlint config filenames only in `config/javascript_tools.lua`; formatter and LSP behavior must consume the same lists.
- Keep the Oxlint precedence rule documented in code and in the README.
- A future formatter change must update both `ensure-installed.lua` and `format.lua` in one change.
