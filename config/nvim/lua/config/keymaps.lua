local vscode = require "config.vscode"

local function createMapper()
    local M = {}
    M.DEFAULT_OPTS = { noremap = true, silent = true }

    M.keymap = function(mode, from, to, opts)
        opts = vim.tbl_extend("keep", opts or {}, M.DEFAULT_OPTS)

        local ok, err = pcall(vim.keymap.set, mode, from, to, opts)
        if ok or opts.icon == nil then
            if not ok then
                error(err)
            end
            return
        end

        if not tostring(err):match "invalid key: icon" then
            error(err)
        end

        -- ponytail: keep icon metadata out of vim.keymap.set on Neovim builds that do not support it yet.
        local fallback = vim.deepcopy(opts)
        fallback.icon = nil
        vim.keymap.set(mode, from, to, fallback)
    end

    local function set(modes)
        return function(from, action, opts)
            M.keymap(modes, from, action, opts)
        end
    end

    return {
        DEFAULT_OPTS = M.DEFAULT_OPTS,
        normal = set { "n" },
        x = set { "x" },
        cmd = set { "c" },
        insert = set { "i" },
        visual = set { "v" },
        nx = set { "n", "v" },
        term = set { "t" },
    }
end

local bind = createMapper()
bind.term("<esc><esc>", [[<C-\><C-n>]], { desc = "Exit terminal-insert mode" })
bind.term("<C-[>", [[<C-\><C-n>]], { desc = "Exit terminal-insert mode" })
bind.x("p", [["_dP]], bind.DEFAULT_OPTS)

bind.cmd("<C-A>", "<HOME>", { desc = "Go to HOME in command" })
bind.normal("J", "mzJ`z", { desc = "Primeagen join lines" })
bind.normal("j", "gj", bind.DEFAULT_OPTS)
bind.normal("k", "gk", bind.DEFAULT_OPTS)
bind.normal("g;", "g;", { desc = "Older change" })
bind.normal("g,", "g,", { desc = "Newer change" })
bind.normal("vv", "V", { desc = "Select line" })

bind.normal("0", "^", { desc = "Goto first non-whitespace" })
bind.normal("<", "<<", { desc = "Deindent" })
bind.normal(">", ">>", { desc = "Indent" })
bind.insert("<C-A>", "<HOME>", { desc = "Go to home in insert" })
bind.insert("<C-E>", "<END>", { desc = "Go to end in insert" })
bind.insert("<C-s>", "<Esc>:w<CR>a", { desc = "Save" })
bind.insert("<C-z>", "<Esc>ua", { desc = "Go to end in insert" })
bind.insert("<Esc>", "<C-c>", { desc = "normal mode", noremap = true, silent = true })
bind.normal("#", "#zz", { desc = "Center previous pattern" })
bind.normal("*", "*zz", { desc = "Center next pattern" })
bind.normal("+", "<C-a>", { desc = "Increment" })
bind.normal("-", "<C-x>", { desc = "Decrement" })
bind.normal("<BS>", '"_', { desc = "BlackHole register" })
bind.normal("dd", function()
    return vim.api.nvim_get_current_line() == "" and '"_dd' or "dd"
end, { expr = true, desc = "Delete line" })
bind.normal("<C-s>", "<cmd>:w<CR>", { desc = "Save" })
bind.normal("<Esc>", "<cmd>nohlsearch<CR>", { desc = "No hlsearch" })
bind.normal("<leader>uA", "<cmd>CodeActionsOnSaveToggle<CR>", { desc = "Toggle code actions on save" })
bind.normal("<leader>J", "v%J", { desc = "Join next match" })
bind.normal("<leader>cq", vim.diagnostic.setloclist, { desc = "Open diagnostic [c]ode [q]uickfix list" })

bind.visual("0", "^", { desc = "Goto first non-whitespace" })
bind.visual("<BS>", '"_', { desc = "BlackHole register" })
bind.visual("<", "<gv", bind.DEFAULT_OPTS)
bind.visual(">", ">gv", bind.DEFAULT_OPTS)
bind.visual("<leader>sa", ":sort<CR>", { desc = "[s]ort ascii" })
bind.visual("<leader>su", ":sort u<CR>", { desc = "[s]ort unique" })
bind.visual("<leader>sn", ":sort n<CR>", { desc = "[s]ort numbers" })
bind.visual("<leader>sr", ":!tail -r<CR>", { desc = "[s]ort reverse" })
bind.visual("<leader>ss", ":<C-u>'<,'>! awk '{ print length(), $0 | \"sort -n | cut -d\\\\  -f2-\" }'<CR>", { desc = "[s]ort size" })
bind.visual("J", ":m '>+1<CR>gv=gv", { desc = "" })
bind.visual("K", ":m '<-2<CR>gv=gv", { desc = "" })

bind.normal("<leader>co", function()
    vim.lsp.buf.code_action {
        apply = true,
        context = { only = { "source.organizeImports" } },
    }
end, { desc = "[c]ode [o]rganizeImports" })

if not vscode.isVscode() then
    bind.normal("<leader>tm", function()
        require("mini.map").toggle()
    end, { desc = "[t]oggle [m]inimap", icon = "" })
end

bind.normal("<leader>qf", "<cmd>q!<cr>", { desc = "[q]uit force", icon = "󰅛" })
bind.normal("<leader>qq", "<cmd>bdelete<CR>", { desc = "[q]uit tab", icon = "󰅛" })
bind.normal("<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete current buffer", icon = "󰅛" })
bind.normal("<C-h>", "<cmd>bprevious<cr>", bind.DEFAULT_OPTS)
bind.normal("<C-l>", "<cmd>bnext<cr>", bind.DEFAULT_OPTS)
bind.normal("<leader>br", "<CMD>e#<CR>", { desc = "Buffer reopen last", icon = "" })
if not vscode.isVscode() then
    bind.normal("<leader>bp", "<CMD>BufferLineTogglePin<CR>", { desc = "[b]uffer [p]in", icon = "" })
    bind.normal("<leader>bo", function()
        require("snacks.bufdelete").other()
    end, { desc = "Close all except current", icon = "" })
    bind.normal("<leader>bh", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true, desc = "[h]eader of context" })

    bind.normal("<leader>g=", function()
        require("mini.diff").toggle_overlay(0)
    end, { desc = "Git diff" })

    bind.normal("<leader>gD", "<CMD>CodeDiff<CR>", { desc = "Vscode diff" })
    bind.normal("<leader>rm", "<CMD>Nvumi<CR>", { desc = "[R]epl [M]aths" })
    bind.normal("<leader>so", "<CMD>Oil --float --preview<CR>", { desc = "Oil" })
    bind.normal("<leader>se", function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0))
    end, { desc = "Mini files" })
    bind.normal("<leader>on", "<CMD>Nvumi<CR>", { desc = "[O]pen [N]vumi" })
end
bind.normal("<leader>xd", vim.diagnostic.open_float, { desc = "Open diagnostics" })

local function buf_abs()
    return vim.api.nvim_buf_get_name(0)
end

if not vscode.isVscode() then
    bind.normal("<leader>um", function()
        Snacks.dim.disable()
    end, { desc = "Disable dim" })

    bind.normal("<leader>uf", function()
        Snacks.dim.enable()
    end, { desc = "Enable dim" })
end

bind.normal("<leader>cy", function()
    local rel = vim.fn.fnamemodify(buf_abs(), ":.")
    vim.fn.setreg("+", rel)
    vim.notify("Yanked (relative): " .. rel)
end, { desc = "[c]ode [y]ank path" })

bind.normal("<leader>cd", function()
    local function dirname(str)
        return str:match "(.*[/\\])"
    end
    local rel = dirname(vim.fn.fnamemodify(buf_abs(), ":."))
    vim.fn.setreg("+", rel)
    vim.notify("Yanked (relative): " .. rel)
end, { desc = "[c]ode yank [d]ir" })

bind.normal("<leader>xc", function()
    local loc = vim.fn.fnamemodify(buf_abs(), ":.") .. ":" .. vim.fn.line "."
    vim.fn.setreg("+", loc)
    vim.notify("Yanked: " .. loc)
end, { desc = "Copy path:line" })

bind.normal("<leader>xo", function()
    local loc = vim.fn.getreg("+"):match "^%s*(.-)%s*$"
    if loc == "" then
        vim.notify("Clipboard is empty", vim.log.levels.WARN)
        return
    end

    vim.cmd.edit(vim.fn.fnameescape(loc))
end, { desc = "Open copied path:line" })

if not vscode.isVscode() then
    bind.normal("zR", function()
        require("ufo").openAllFolds()
    end)

    bind.normal("zM", function()
        require("ufo").closeAllFolds()
    end)

    bind.normal("zm", function()
        require("ufo").closeFoldsWith()
    end)
end

bind.normal("zo", function()
    local line = vim.fn.line "."
    if vim.fn.foldclosed(line) == -1 then
        vim.cmd "normal! zc"
    else
        vim.cmd "normal! zo"
    end
end, { desc = "Fold" })

bind.normal("<leader>fr", function()
    require("grug-far").open { engine = "astgrep" }
end, { desc = "Structural find and replace" })

bind.visual("<leader>fr", function()
    require("grug-far").with_visual_selection { engine = "astgrep" }
end, { desc = "Structural replace selection" })

if vscode.isVscode() then
    local function vscode_action(command, opts)
        return function()
            require("vscode").action(command, opts)
        end
    end

    local function vscode_word_action(command)
        return function()
            require("vscode").action(command, { args = { query = vim.fn.expand "<cword>" } })
        end
    end

    -- Keep the leader layout useful when Neovim plugins are disabled in VS Code.
    bind.normal("<C-h>", vscode_action "workbench.action.previousEditor", { desc = "Previous editor" })
    bind.normal("<C-l>", vscode_action "workbench.action.nextEditor", { desc = "Next editor" })
    bind.normal("<leader><space>", vscode_action "workbench.action.quickOpen", { desc = "Find files" })
    bind.normal("<leader>ff", vscode_action "workbench.action.quickOpen", { desc = "Find files" })
    bind.normal("<leader>fR", vscode_action "workbench.action.openRecent", { desc = "Recent files" })
    bind.normal("<leader>fc", vscode_action "workbench.action.showCommands", { desc = "Command history" })
    bind.normal("<leader>fj", vscode_action "workbench.action.navigateBack", { desc = "Recent locations" })
    bind.normal("<leader>ft", vscode_action "workbench.action.gotoSymbol", { desc = "Document symbols" })
    bind.normal("<leader>fs", vscode_action "workbench.action.gotoSymbol", { desc = "Document symbols" })
    bind.normal("<leader>fg", vscode_action "workbench.action.findInFiles", { desc = "Find in files" })
    bind.normal("<leader>sg", vscode_action "workbench.action.findInFiles", { desc = "Grep project" })
    bind.normal("<leader>sw", vscode_word_action "workbench.action.findInFiles", { desc = "Grep word" })
    bind.normal("<leader>fe", vscode_action "workbench.view.explorer", { desc = "File explorer" })
    bind.normal("<leader>fo", vscode_action "workbench.action.openRecent", { desc = "Open recent" })
    bind.normal("<leader>fb", vscode_action "workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup", { desc = "Buffers" })
    bind.normal("<leader>sb", vscode_action "workbench.action.gotoLine", { desc = "Buffer lines" })
    bind.normal("<leader>ss", vscode_action "workbench.action.gotoSymbol", { desc = "Document symbols" })
    bind.normal("<leader>sS", vscode_action "workbench.action.showAllSymbols", { desc = "Workspace symbols" })
    bind.normal("<leader>sB", vscode_action "workbench.action.quickOpenPreviousRecentlyUsedEditorInGroup", { desc = "Open buffers" })
    bind.normal("<leader>sd", vscode_action "workbench.actions.view.problems", { desc = "Workspace diagnostics" })
    bind.normal("<leader>sD", vscode_action "workbench.actions.view.problems", { desc = "Buffer diagnostics" })
    bind.normal("<leader>sl", vscode_action "workbench.actions.view.problems", { desc = "Location list" })
    bind.normal("<leader>fq", vscode_action "workbench.actions.view.problems", { desc = "Quickfix list" })
    bind.normal("<leader>sk", vscode_action "workbench.action.openGlobalKeybindings", { desc = "Keymaps" })
    bind.normal("<leader>sh", vscode_action "workbench.action.showCommands", { desc = "Commands" })
    bind.normal("<leader>nh", vscode_action "workbench.action.openNotifications", { desc = "Notifications" })

    bind.normal("gR", vscode_action "editor.action.referenceSearch.trigger", { desc = "References" })
    bind.normal("gi", vscode_action "editor.action.goToImplementation", { desc = "Implementation" })
    bind.normal("gt", vscode_action "editor.action.goToTypeDefinition", { desc = "Type definition" })
    bind.normal("[d", vscode_action "editor.action.marker.prevInFiles", { desc = "Previous diagnostic" })
    bind.normal("]d", vscode_action "editor.action.marker.nextInFiles", { desc = "Next diagnostic" })
    bind.normal("<leader>ca", vscode_action "editor.action.quickFix", { desc = "Code actions" })
    bind.visual("<leader>ca", vscode_action "editor.action.quickFix", { desc = "Code actions" })
    bind.normal("<leader>cf", vscode_action "editor.action.formatDocument", { desc = "Format buffer" })
    bind.visual("<leader>cf", vscode_action "editor.action.formatSelection", { desc = "Format selection" })
    bind.normal("<leader>co", vscode_action "editor.action.organizeImport", { desc = "Organize imports" })
    bind.normal("<leader>cr", vscode_action "editor.action.rename", { desc = "Rename symbol" })
    bind.normal("<leader>cx", vscode_action "editor.action.refactor", { desc = "Refactor" })
    bind.visual("<leader>cx", vscode_action "editor.action.refactor", { desc = "Refactor" })
    bind.normal("<leader>th", vscode_action "editor.action.inlayHints.toggle", { desc = "Toggle inlay hints" })
    bind.normal("<leader>dd", vscode_action "editor.action.showHover", { desc = "Cursor diagnostics" })
    bind.normal("<leader>cq", vscode_action "workbench.actions.view.problems", { desc = "Diagnostics" })
    bind.normal("<leader>xd", vscode_action "editor.action.showHover", { desc = "Show diagnostics" })
    bind.normal("<leader>xx", vscode_action "workbench.actions.view.problems", { desc = "Workspace diagnostics" })
    bind.normal("<leader>xX", vscode_action "workbench.actions.view.problems", { desc = "Buffer diagnostics" })

    bind.normal("<leader>bd", vscode_action "workbench.action.closeActiveEditor", { desc = "Close buffer" })
    bind.normal("<leader>qq", vscode_action "workbench.action.closeActiveEditor", { desc = "Close buffer" })
    bind.normal("<leader>qf", vscode_action "workbench.action.closeActiveEditor", { desc = "Close buffer" })
    bind.normal("<leader>br", vscode_action "workbench.action.openPreviousRecentlyUsedEditorInGroup", { desc = "Previous buffer" })
    bind.normal("<leader>so", vscode_action "workbench.view.explorer", { desc = "File explorer" })
    bind.normal("<leader>se", vscode_action "workbench.view.explorer", { desc = "File explorer" })
    bind.normal("<leader>Z", vscode_action "workbench.action.toggleMaximizeEditorGroup", { desc = "Maximize editor" })
    bind.normal("<C-`>", vscode_action "workbench.action.terminal.toggleTerminal", { desc = "Toggle terminal" })

    bind.normal("<leader>gs", vscode_action "workbench.view.scm", { desc = "Git status" })
    bind.normal("<leader>gb", vscode_action "git.branch", { desc = "Git branches" })
    bind.normal("<leader>gl", vscode_action "gitlens.showQuickRepoHistory", { desc = "Git log" })
    bind.normal("<leader>gL", vscode_action "gitlens.showQuickLineHistory", { desc = "Git log line" })
    bind.normal("<leader>gf", vscode_action "gitlens.showQuickFileHistory", { desc = "Git log file" })
    bind.normal("<leader>gB", vscode_action "gitlens.openFileInRemote", { desc = "Git browse" })
    bind.normal("<leader>gS", vscode_action "git.viewStagedChanges", { desc = "Staged changes" })
    bind.normal("<leader>gg", vscode_action "workbench.action.terminal.toggleTerminal", { desc = "Git terminal" })
    bind.normal("<leader>gd", vscode_action "git.openChange", { desc = "Git diff" })
    bind.normal("<leader>gD", vscode_action "git.openChange", { desc = "Git diff" })
    bind.normal("<leader>g=", vscode_action "git.openChange", { desc = "Git diff" })
    bind.normal("<leader>tb", vscode_action "gitlens.toggleFileBlame", { desc = "Toggle git blame" })

    bind.normal("<leader>db", vscode_action "editor.debug.action.toggleInlineBreakpoint", { desc = "Toggle breakpoint" })
    bind.normal("<leader>dc", vscode_action "workbench.action.debug.continue", { desc = "Continue" })
    bind.normal("<leader>dC", vscode_action "editor.debug.action.runToCursor", { desc = "Run to cursor" })
    bind.normal("<leader>di", vscode_action "workbench.action.debug.stepInto", { desc = "Step into" })
    bind.normal("<leader>do", vscode_action "workbench.action.debug.stepOut", { desc = "Step out" })
    bind.normal("<leader>dO", vscode_action "workbench.action.debug.stepOver", { desc = "Step over" })
    bind.normal("<leader>dP", vscode_action "workbench.action.debug.pause", { desc = "Pause" })
    bind.normal("<leader>dr", vscode_action "workbench.debug.action.toggleRepl", { desc = "Toggle debug console" })
    bind.normal("<leader>dt", vscode_action "workbench.action.debug.stop", { desc = "Terminate" })

    bind.normal("<leader>Tn", vscode_action "testing.runAtCursor", { desc = "Test nearest" })
    bind.normal("<leader>Tf", vscode_action "testing.runCurrentFile", { desc = "Test file" })
    bind.normal("<leader>Tl", vscode_action "testing.runLast", { desc = "Test last" })
    bind.normal("<leader>Ts", vscode_action "workbench.view.testing", { desc = "Test summary" })
    bind.normal("<leader>To", vscode_action "testing.showMostRecentOutput", { desc = "Test output" })
    bind.normal("<leader>TS", vscode_action "testing.cancelRun", { desc = "Stop tests" })

    bind.normal("zR", vscode_action "editor.unfoldAll", { desc = "Open all folds" })
    bind.normal("zM", vscode_action "editor.foldAll", { desc = "Close all folds" })
    bind.normal("zm", vscode_action "editor.fold", { desc = "Close fold" })
    bind.normal("zo", vscode_action "editor.unfold", { desc = "Open fold" })
end

bind.x(".", ":norm .<CR>", nosilent)
bind.x("@", ":norm @q<CR>", nosilent)

