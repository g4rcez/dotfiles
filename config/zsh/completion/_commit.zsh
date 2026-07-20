_commit() {
    local -a cmds=(
        'commit.lockfile:chore: sync lockfile'
        'commit.deps:chore: update dependencies'
        'commit.format:style: format source files'
        'commit.merge:chore: resolve merge conflicts'
        'commit.cleanup:chore: clean up unused files'
        'commit.remove:chore: remove obsolete files'
        'commit.rename:refactor: rename files and symbols'
        'commit.docs:docs: update documentation'
        'commit.test:test: update tests'
        'commit.ci:ci: update CI configuration'
        'commit.release:build: prepare release'
        'commit.rebase:chore: resolve rebase conflicts'
        'commit.wip:wip: create a timestamped work-in-progress commit'
        'commit.write:write a commit message with the configured AI helper'
        'commit.ai:generate a commit message with AI'
    )

    _describe 'commit command' cmds
    _compskip=all
}

compdef -p _commit 'commit.*'
