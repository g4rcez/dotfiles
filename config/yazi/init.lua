require("git"):setup()

require("mime-ext"):setup({
    with_files = { makefile = "text/makefile" },
    with_exts = { mk = "text/makefile" },
})
