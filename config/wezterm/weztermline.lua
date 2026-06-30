local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

local function pane_cwd(pane)
    local cwd = pane:get_current_working_dir()
    if not cwd then
        return nil
    end
    if type(cwd) == "userdata" then
        return cwd.file_path
    end

    local path = cwd:match("^file://[^/]*(/.*)$")
    if not path then
        return nil
    end
    return path:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

package.preload["tabline.components.window.github_branch"] = function()
    return {
        update = function(window)
            local cwd = pane_cwd(window:active_pane())
            if not cwd then
                return nil
            end

            local ok, branch = wezterm.run_child_process({
                "bash",
                "-lc",
                [[
if ! git -C "$1" remote -v 2>/dev/null | grep -qi 'github\.com'; then exit 0; fi
branch=$(git -C "$1" branch --show-current 2>/dev/null)
[ -n "$branch" ] || branch=$(git -C "$1" rev-parse --short HEAD 2>/dev/null)
printf '%s' "$branch"
]],
                "wezterm-git-branch",
                cwd,
            })

            branch = ok and branch:gsub("%s+$", "") or ""
            if branch == "" then
                return nil
            end
            return branch
        end,
    }
end

local function apply(config)
    config.use_fancy_tab_bar = false
    config.show_new_tab_button_in_tab_bar = false
    config.tab_max_width = 32
    config.status_update_interval = 1000

    tabline.setup({
        options = {
            icons_enabled = true,
            tabs_enabled = true,
            section_separators = {
                left = wezterm.nerdfonts.pl_left_hard_divider,
                right = wezterm.nerdfonts.pl_right_hard_divider,
            },
            component_separators = {
                left = wezterm.nerdfonts.pl_left_soft_divider,
                right = wezterm.nerdfonts.pl_right_soft_divider,
            },
            tab_separators = {
                left = wezterm.nerdfonts.pl_left_hard_divider,
                right = wezterm.nerdfonts.pl_right_hard_divider,
            },
        },
        sections = {
            tabline_a = { "" },
            tabline_b = { "" },
            tabline_c = { "" },
            tab_active = {
                "index",
                { "parent", padding = 0 },
                "/",
                { "cwd", padding = { left = 0, right = 1 } },
                { "zoomed", padding = 0 },
            },
            tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
            tabline_x = {
                { "github_branch", icon = wezterm.nerdfonts.dev_git_branch },
            },
            tabline_y = {},
            tabline_z = {},
        },
    })
end

return { apply = apply }
