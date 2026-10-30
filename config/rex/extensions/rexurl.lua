-- Copy a URL or an existing file/directory path from the current tab's terminal output.
-- Idea from shaheislam/rex-opener.
-- Rex has no native picker API, so any match opens fzf (no preview) in a floating layer.
local TERMINAL = "com.superlogical.terminal"

local function trim_url(url)
  -- Drop punctuation that belongs to the prose or Markdown around the link.
  url = url:gsub("[%.,;:!%?'\"%)%]}>]+$", "")
  return url
end

-- Paths follow shell rules: a leading "~" or "~/" is $HOME, $VAR and ${VAR} come from the
-- environment, and a relative path is tried against the working directory of each pane in the tab.
-- "~user" is not expanded. A path is listed only if it exists, which drops "and/or" noise.
-- The list and the clipboard get the path as typed in the output. Expansion only checks existence.
local function expand_path(tok, cwd)
  local home = os.getenv("HOME")
  if tok == "~" or tok:sub(1, 2) == "~/" then tok = home .. tok:sub(2) end
  tok = tok:gsub("%${([%a_][%w_]*)}", function(n) return os.getenv(n) or "\0" end)
  tok = tok:gsub("%$([%a_][%w_]*)", function(n) return os.getenv(n) or "\0" end)
  if tok:find("\0", 1, true) then return nil end
  if tok:sub(1, 1) ~= "/" then
    if not cwd then return nil end
    tok = cwd .. "/" .. tok
  end
  tok = tok:gsub("/%./", "/"):gsub("//+", "/")
  if #tok > 1 then tok = tok:gsub("/%.?$", "") end
  return tok
end

local function path_token(tok)
  -- "--dir=/x" and "KEY=/x": keep what follows the "=".
  if not tok:find("^[~/.$]") then tok = tok:match("^[%w_%-]*=(.+)$") or tok end
  if tok:find("://", 1, true) or not tok:find("/", 1, true) then return nil end
  -- grep and compiler output: "/a/b.lua:12:3".
  tok = tok:gsub(":%d+:?%d*$", ""):gsub("[%.,;:!%?]+$", "")
  if #tok < 2 then return nil end
  return tok
end

-- Ordered { kind = "url" | "path", text = string } entries found in one pane's text.
local function scan(text, out)
  for raw in text:gmatch("[^%s<>\"'`|;()]+") do
    if raw:find("^https?://") then
      local url = trim_url(raw)
      if #url > 8 then out[#out + 1] = { kind = "url", text = url } end
    else
      local tok = path_token(raw)
      if tok then out[#out + 1] = { kind = "path", text = tok } end
    end
  end
end

-- Keep the paths that exist. One shell call checks them all; arguments never become shell code.
local function existing(paths)
  if #paths == 0 then return {} end
  local argv = { "/bin/sh", "-c", 'for p; do [ -e "$p" ] && printf "%s\\n" "$p"; done; exit 0', "rexurl" }
  for _, p in ipairs(paths) do argv[#argv + 1] = p end
  local r = rex.exec(argv)
  local ok = {}
  for line in ((r and r.stdout) or ""):gmatch("[^\n]+") do ok[line] = true end
  return ok
end

-- { display, target } items from every terminal pane in the tab, newest first.
-- display is what the output showed and what gets copied; target is the resolved path, used to check
-- that the path exists and to drop duplicates.
local function tab_items(ctx)
  local me, merr = rex.session.describe_block{ block_id = ctx.block_id }
  if not me then error(merr, 0) end
  local window_id = me.block.window_id
  local list, lerr = rex.session.list_blocks{}
  if not list then error(lerr, 0) end

  local entries, cwds, seen_cwd = {}, {}, {}
  local function add_cwd(dir)
    if dir and not seen_cwd[dir] then
      seen_cwd[dir] = true
      cwds[#cwds + 1] = dir
    end
  end
  local panes = {}
  for _, b in ipairs(list.blocks or {}) do
    if b.window_id == window_id and b.flavor == "com.superlogical.terminal.shell" then
      panes[#panes + 1] = b.block_id
      -- The focused pane first, so its directory wins when two panes have the same file.
      if b.block_id == ctx.block_id then table.insert(panes, 1, table.remove(panes)) end
    end
  end
  for _, id in ipairs(panes) do
    local pwd = rex.block.call(TERMINAL, "pwd", { block_id = id })
    -- The terminal reports pwd as a URL: file://host/Users/me/dir, percent-encoded.
    local dir = pwd and pwd.pwd and pwd.pwd:gsub("^file://[^/]*", ""):gsub("%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end)
    add_cwd(dir)
  end
  for _, id in ipairs(panes) do
    local r = rex.block.call(TERMINAL, "format",
      { block_id = id, format = "text", unwrap = true, max_bytes = 983040 })
    if r and r.content then
      local pane = {}
      scan(r.content, pane)
      for i = #pane, 1, -1 do entries[#entries + 1] = pane[i] end
    end
  end

  -- Expand every path candidate. A relative path gets one candidate per pane directory.
  local candidates = {}
  for _, e in ipairs(entries) do
    if e.kind == "path" then
      e.targets = {}
      if e.text:find("^[~/$]") then
        e.targets[1] = expand_path(e.text)
      else
        for _, dir in ipairs(cwds) do e.targets[#e.targets + 1] = expand_path(e.text, dir) end
      end
      for _, t in ipairs(e.targets) do candidates[#candidates + 1] = t end
    end
  end
  local exists = existing(candidates)

  local found, seen = {}, {}
  for _, e in ipairs(entries) do
    local target
    if e.kind == "url" then
      target = e.text
    else
      for _, t in ipairs(e.targets) do
        if exists[t] then target = t; break end
      end
    end
    if target and not seen[target] then
      seen[target] = true
      found[#found + 1] = { display = e.text, target = target }
    end
  end
  return found
end

-- mode "copy" puts the text on the clipboard; mode "open" hands the resolved target to macOS `open`.
local function pick(ctx, mode)
    if not ctx.block_id then error("rexurl: no focused pane", 0) end
    local items = tab_items(ctx)
    if #items == 0 then
      rex.log("info", "rexurl: no URL or path in the current tab")
      return
    end
    local path = os.tmpname()
    local f = assert(io.open(path, "w"))
    for _, it in ipairs(items) do f:write(it.display, "\t", it.target, "\n") end
    f:close()

    -- Same fzf look as the shell: fzf.sh sets FZF_DEFAULT_OPTS and needs FZF_COLORS from utils.sh.
    local dotfiles = os.getenv("DOTFILES") or (os.getenv("HOME") .. "/dotfiles")
    local script = [[trap 'rm -f "$1"' EXIT; DOTFILES=$2; source "$2/config/zsh/utils.sh"; source "$2/config/zsh/fzf.sh"; ]]
      .. [[sel=$(fzf --prompt="$3> " --delimiter=$'\t' --with-nth=1 --no-preview --preview-window=hidden < "$1") || exit 0; ]]
      .. [[if test "$3" = open; then open "${sel#*$'\t'}"; else printf %s "${sel%%$'\t'*}" | pbcopy; fi]]
    local _, err = rex.session.new_layer{
      bounds = { 0.1, 0.15, 0.8, 0.7 },
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = {
          command = { "zsh", "-c", script, "rexurl", path, dotfiles, mode },
          exit = { on_completion = true },
        },
      },
    }
    if err ~= nil then
      os.remove(path)
      error(err, 0)
    end
end

rex.action{
  name = "rexurl_open",
  title = "Copy URL or Path from Tab",
  description = "Find URLs and existing paths in the current tab's terminal output and copy one to the clipboard.",
  run = function(ctx) pick(ctx, "copy") end,
}

rex.action{
  name = "rexurl_browse",
  title = "Open URL or Path from Tab",
  description = "Find URLs and existing paths in the current tab's terminal output and open one with macOS open.",
  run = function(ctx) pick(ctx, "open") end,
}
