vim.opt.runtimepath:prepend(vim.fn.getcwd())

local mention = require "mention_ls"
local failures = 0

local function check(actual, expected, label)
    if actual == expected then
        return
    end
    failures = failures + 1
    io.stderr:write(string.format("FAIL %s: expected %q, got %q\n", label, expected, actual))
end

local function show(ctx)
    return ctx and (ctx.trigger .. ":" .. ctx.query .. ":" .. ctx.start_col) or "nil"
end

check(show(mention.context("@", 1)), "@::0", "bare @")
check(show(mention.context("see @src/fo", 11)), "@:src/fo:4", "@ with path")
check(show(mention.context("run $co", 7)), "$:co:4", "$ with query")
check(show(mention.context("(@foo", 5)), "@:foo:1", "@ after parenthesis")
check(show(mention.context("mail a@b.com", 12)), "nil", "@ inside a word")
check(show(mention.context("cost x$y", 8)), "nil", "$ inside a word")
check(show(mention.context("@foo bar", 8)), "nil", "cursor after the mention")

local root = vim.fn.tempname()
local project, home = root .. "/project", root .. "/home"

local function write(path, lines)
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.fn.writefile(lines, path)
end

local function skill(base, dir, name, description)
    write(("%s/%s/SKILL.md"):format(base, dir), { "---", "name: " .. name, "description: " .. description, "---", "body" })
end

write(project .. "/a/b/c/deep.lua", { "return" })
write(project .. "/ignored.log", { "x" })
write(project .. "/.gitignore", { "*.log" })
skill(project .. "/.claude/skills", "review", "review", "Project review")
skill(project .. "/.claude/skills", ".trash/old", "old", "Trashed")
write(project .. "/.claude/skills/synced/notes.txt", { "no skill file" })
skill(home .. "/.agents/skills", "review", "review", "Home review")
skill(home .. "/.agents/skills", "deploy", "deploy", "Deploy it")
vim.fn.mkdir(home .. "/.claude/skills", "p")
vim.uv.fs_symlink(home .. "/.agents/skills/deploy", home .. "/.claude/skills/deploy")

vim.env.HOME = home
vim.cmd.cd(project)

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_name(buf, project .. "/prompt.md")
local client_id = vim.lsp.start({ name = "mention_ls", cmd = mention.cmd, root_dir = project }, { bufnr = buf })
local client = vim.lsp.get_client_by_id(client_id)

local function complete(line)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
    local response = client:request_sync("textDocument/completion", {
        textDocument = { uri = vim.uri_from_bufnr(buf) },
        position = { line = 0, character = #line },
    }, 5000, buf)
    return response and response.result and response.result.items or {}
end

local function labels(items)
    return table.concat(
        vim.tbl_map(function(i)
            return i.label
        end, items),
        ","
    )
end

local files = complete "see @deep"
check(labels(files), "a/b/c/deep.lua", "deep file found")
check(files[1].textEdit.newText, "@a/b/c/deep.lua", "file edit text")
check(files[1].textEdit.range.start.character, 4, "file edit starts at @")
check(files[1].textEdit.range["end"].character, 9, "file edit ends at cursor")
check(labels(complete "@ignored"), "", "gitignored file hidden without a git repo")

check(labels(complete "$"), "deploy,review", "skills deduplicated, trash and non-skill dirs skipped")
local review = complete "use $rev"
check(labels(review), "review", "skill filtered by query")
check(review[1].textEdit.newText, "/review", "skill edit text")
check(review[1].textEdit.range.start.character, 4, "skill edit starts at $")
check(review[1].documentation.value:find("Project review", 1, true) ~= nil, true, "project skill wins over home skill")
check(labels(complete "plain text"), "", "no completion without a trigger")

client:stop(true)

if failures > 0 then
    vim.cmd "cquit 1"
end
print "mention_ls: PASS"
vim.cmd "qa!"
