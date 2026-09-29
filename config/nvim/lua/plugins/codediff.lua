return {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
        highlights = {
            line_insert = "DiffAdd", -- Line-level insertions
            line_delete = "DiffDelete", -- Line-level deletions
            char_insert = nil, -- Character-level insertions (nil = auto-derive)
            char_delete = nil, -- Character-level deletions (nil = auto-derive)
            char_brightness = nil, -- Auto-adjust based on your colorscheme
            conflict_sign = nil,    -- Unresolved: DiagnosticSignWarn -> #f0883e
            conflict_sign_resolved = nil, -- Resolved: Comment -> #6e7681
            conflict_sign_accepted = nil, -- Accepted: GitSignsAdd -> DiagnosticSignOk -> #3fb950
            conflict_sign_rejected = nil, -- Rejected: GitSignsDelete -> DiagnosticSignError -> #f85149
        },
        diff = {
            layout = "side-by-side", -- Diff layout: "side-by-side" (two panes) or "inline" (single pane with virtual lines)
            filler_text = "╱", -- Repeated filler pattern; use "" for blank alignment rows
            disable_inlay_hints = true, -- Disable inlay hints in diff windows for cleaner view
            max_computation_time_ms = 5000, -- Maximum time for diff computation (VSCode default)
            ignore_trim_whitespace = false, -- Ignore leading and trailing whitespace changes
            hide_merge_artifacts = false, -- Hide merge tool temp files (*.orig, *.BACKUP.*, *.BASE.*, *.LOCAL.*, *.REMOTE.*)
            original_position = "left", -- Position of original (old) content: "left" or "right"
            conflict_ours_position = "right", -- Position of ours (:2) in conflict view: "left" or "right"
            conflict_result_position = "bottom", -- "bottom" (default): result below diff panes or "center": result between diff panes (three columns)
            conflict_result_height = 30, -- Height of result pane in bottom layout (% of total height)
            conflict_result_width_ratio = { 1, 1, 1 }, -- Width ratio for center layout panes {left, center, right} (e.g., {1, 2, 1} for wider result)
            cycle_next_hunk = true, -- Wrap around when navigating hunks (]c/[c): false to stop at first/last
            cycle_next_file = true, -- Wrap around when navigating files (]f/[f): false to stop at first/last
            cycle_hunks_across_files = false, -- ]c/[c at file boundary hops to first/last hunk of next/prev file (explorer/history)
            jump_to_first_change = true, -- Auto-scroll to first change when opening a diff: false to stay at same line
            highlight_added_deleted_files = false, -- Tint full contents of added, untracked, and deleted files
            highlight_priority = 100, -- Priority for line-level diff highlights (increase to override LSP highlights)
            gutter_signs = false, -- Gutter +/- signs; see Gutter signs below
            compute_moves = true, -- Detect moved code blocks (opt-in, matches VSCode experimental.showMoves)
            compact_context_lines = 3, -- Number of context lines around hunks in compact mode
            compact_sync_folds = true, -- Sync fold open/close across panes (mirrors Vim diff mode behavior)
            compact = false, -- Default compact preference for each CodeDiff session; toggle with gc
        },
        explorer = {
            position = "left", -- "left" or "bottom"
            hidden = false, -- Initial visibility state
            width = 40, -- Width when position is "left" (columns)
            height = 15, -- Height when position is "bottom" (lines)
            auto_refresh = true, -- Native file watching with polling fallback (R still refreshes manually)
            indent_markers = true, -- Show indent markers in tree view (│, ├, └)
            initial_focus = "explorer", -- Initial focus: "explorer", "original", or "modified"
            icons = {
                folder_closed = "\u{e5ff}", -- Nerd Font folder icon
                folder_open = "\u{e5fe}", -- Nerd Font open-folder icon
            },
            view_mode = "list", -- "list" or "tree"
            flatten_dirs = true, -- Flatten single-child directory chains in tree view
            file_filter = {
                ignore = { ".git/**", ".jj/**" }, -- Glob patterns to hide (e.g., {"*.lock", "dist/*"})
            },
            untracked = "all", -- Untracked scan: "all", "normal" (collapse dirs), or "no" (skip; use for huge work trees like GIT_WORK_TREE=$HOME that hang, #389)
            focus_on_select = false, -- Jump to modified pane after selecting a file (default: stay in explorer)
            auto_open_on_cursor = false, -- Rebind j/k/Down/Up in the explorer to also open the file under the cursor
            status_right_margin = 1, -- Trailing cells between status symbol (M/A/D) and right edge; increase if Nerd Font icons clip it
            line_stats = {
                enabled = true, -- Fetch and show Git line statistics
                count_untracked = true, -- Count untracked file lines as insertions
                max_untracked_bytes = 1024 * 1024, -- Skip larger untracked files
            },
            ellipsis = "…", -- Text appended to truncated Explorer regions
            formatters = { -- Optional function(ctx) -> line layout callbacks; omit to use the built-ins
                file = nil, -- File rows
                folder = nil, -- Directory rows in tree view
                group = nil, -- Section headers such as Changes and Staged Changes
            },
            visible_groups = { -- Which groups to show (can be toggled at runtime)
                staged = true,
                unstaged = true,
                conflicts = true,
            },
        },
        history = {
            position = "bottom", -- "left" or "bottom" (default: bottom)
            width = 40,          -- Width when position is "left" (columns)
            height = 15,         -- Height when position is "bottom" (lines)
            initial_focus = "history", -- Initial focus: "history", "original", or "modified"
            view_mode = "list",  -- "list" or "tree" for files under commits
            date_format = "%ar", -- Commit date rendering: "%ar" (default, relative), "%ai" (ISO), "%ad" (git default), or any strftime string (e.g. "%Y/%m/%d %H:%M:%S")
        },
        keymaps = {
            view = {
                quit = "q",                -- Close diff tab
                toggle_explorer = "<leader>b", -- Toggle explorer visibility (explorer mode only)
                focus_explorer = "<leader>e", -- Focus explorer panel (explorer mode only)
                next_hunk = "]c",          -- Jump to next change
                prev_hunk = "[c",          -- Jump to previous change
                next_file = "]f",          -- Next file in explorer/history mode
                prev_file = "[f",          -- Previous file in explorer/history mode
                diff_get = "do",           -- Get change from other buffer (like vimdiff)
                diff_put = "dp",           -- Put change to other buffer (like vimdiff)
                open_in_prev_tab = "gf",   -- Open current buffer in previous tab (or create one before)
                close_on_open_in_prev_tab = false, -- Close codediff tab after gf opens file in previous tab
                toggle_stage = "-",        -- Stage/unstage current file (works in explorer and diff buffers)
                toggle_staged_view = "gS", -- Swap between staged/unstaged view of current file (#352)
                stage_hunk = "<leader>hs", -- Stage hunk under cursor to git index
                unstage_hunk = "<leader>hu", -- Unstage hunk under cursor from git index
                discard_hunk = "<leader>hr", -- Discard hunk under cursor (working tree only)
                hunk_textobject = "ih",    -- Textobject for hunk (vih to select, yih to yank, etc.)
                show_help = "g?",          -- Show floating window with available keymaps
                align_move = "gm",         -- Temporarily align moved code blocks across panes
                toggle_layout = "t",       -- Toggle between side-by-side and inline layout
                toggle_compact = "gc",     -- Toggle compact mode (fold unchanged regions)
            },
            explorer = {
                select = "<CR>",      -- Open diff for selected file
                hover = "K",          -- Show full path
                refresh = "R",        -- Refresh git status
                toggle_view_mode = "i", -- Toggle between 'list' and 'tree' views
                stage_all = "S",      -- Stage all files
                unstage_all = "U",    -- Unstage all files
                restore = "X",        -- Discard changes (restore file)
                toggle_changes = "gu", -- Toggle Changes (unstaged) group visibility
                toggle_staged = "gs", -- Toggle Staged Changes group visibility
                fold_open = "zo",     -- Open fold (expand current node)
                fold_open_recursive = "zO", -- Open fold recursively (expand all descendants)
                fold_close = "zc",    -- Close fold (collapse current node)
                fold_close_recursive = "zC", -- Close fold recursively (collapse all descendants)
                fold_toggle = "za",   -- Toggle fold (expand/collapse current node)
                fold_toggle_recursive = "zA", -- Toggle fold recursively
                fold_open_all = "zR", -- Open all folds in tree
                fold_close_all = "zM", -- Close all folds in tree
            },
            history = {
                select = "<CR>",      -- Select commit/file or toggle expand
                toggle_view_mode = "i", -- Toggle between 'list' and 'tree' views
                refresh = "R",        -- Refresh history (re-fetch commits)
                -- Fold keymaps (Vim-style, apply to directory nodes only)
                fold_open = "zo",     -- Open fold (expand current node)
                fold_open_recursive = "zO", -- Open fold recursively (expand all descendants)
                fold_close = "zc",    -- Close fold (collapse current node)
                fold_close_recursive = "zC", -- Close fold recursively (collapse all descendants)
                fold_toggle = "za",   -- Toggle fold (expand/collapse current node)
                fold_toggle_recursive = "zA", -- Toggle fold recursively
                fold_open_all = "zR", -- Open all folds in tree
                fold_close_all = "zM", -- Close all folds in tree
            },
            conflict = {
                accept_incoming = "<leader>ct", -- Accept incoming (theirs/left) change
                accept_current = "<leader>co", -- Accept current (ours/right) change
                accept_both = "<leader>cb", -- Accept both changes
                discard = "<leader>cx",     -- Discard both, keep base
                accept_all_incoming = "<leader>cT", -- Accept ALL incoming changes
                accept_all_current = "<leader>cO", -- Accept ALL current changes
                accept_all_both = "<leader>cB", -- Accept ALL both changes
                discard_all = "<leader>cX", -- Discard ALL, reset to base
                next_conflict = "]x",       -- Jump to next conflict
                prev_conflict = "[x",       -- Jump to previous conflict
                diffget_incoming = "2do",   -- Get hunk from incoming (left/theirs) buffer
                diffget_current = "3do",    -- Get hunk from current (right/ours) buffer
            },
        },
    },
}
