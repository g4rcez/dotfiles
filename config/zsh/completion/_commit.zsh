_commit() {
    _arguments -s \
        '(-s --skip --no-verify)'{-s,--skip,--no-verify}'[skip pre-commit and commit-msg hooks]' \
        '(-b --branch)'{-b,--branch}'[prefix commit message with current branch name]' \
        '(-h --help -s --skip --no-verify -b --branch)'{-h,--help}'[show help]' \
        '::commit message:'
}
compdef _commit commit
