local M = {}

function M.image_dir()
    local filename = vim.api.nvim_buf_get_name(0)
    local directory = filename == "" and vim.fn.getcwd() or vim.fn.fnamemodify(filename, ":p:h")
    local image_dir = vim.fs.joinpath(directory, "images")

    vim.fn.mkdir(image_dir, "p")
    return image_dir
end

return M
