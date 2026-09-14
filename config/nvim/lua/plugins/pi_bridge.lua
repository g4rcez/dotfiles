local commit = "7ed6b667c2fa43e0ffd1f2939ba82ce6791f2140"

local function apply_patch(plugin, filename)
    local patch = vim.fn.stdpath "config" .. "/patches/" .. filename
    local args = { "git", "-C", plugin.dir, "apply", "--whitespace=nowarn", patch }
    local check = vim.system(vim.list_extend(vim.deepcopy(args), { "--check" })):wait()

    if check.code == 0 then
        local result = vim.system(args):wait()
        if result.code ~= 0 then
            error("Failed to apply " .. filename .. ": " .. (result.stderr or "unknown error"))
        end
        return
    end

    local reverse = vim.system(vim.list_extend(vim.deepcopy(args), { "--reverse", "--check" })):wait()
    if reverse.code ~= 0 then
        error(filename .. " is incompatible with pi-nvim-bridge commit " .. commit)
    end
end

local function apply_local_patches(plugin)
    apply_patch(plugin, "pi-nvim-bridge-no-debug.patch")
    apply_patch(plugin, "pi-nvim-bridge-blink.patch")
end

return {
    "dabstractor/pi-nvim-bridge",
    commit = commit,
    lazy = false,
    build = apply_local_patches,
    config = function()
        require("pi-bridge").setup { engine = "blink" }
    end,
}
