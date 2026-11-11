# Subcommand dispatcher for bin/ family scripts (zsh).
# The caller sets COMMANDS=('name:description' ...) and defines cmd_<name> (dashes become underscores).
# A COMMANDS entry without a cmd_ function goes to family_default, when the caller defines it.
# `--commands` prints COMMANDS for completion (config/zsh/completion/_family.zsh).

family_list() {
    local entry
    for entry in "${COMMANDS[@]}"; do
        printf '  %-16s %s\n' "${entry%%:*}" "${entry#*:}"
    done
}

family_help() {
    print -r -- "Usage: ${ZSH_ARGZERO:t} <command> [args]"
    print
    family_list
}

family_main() {
    local sub="${1-}"
    if [[ "$sub" == --commands ]]; then
        print -rl -- "${COMMANDS[@]}"
        return 0
    fi
    if [[ -n "$sub" ]] && (($+functions[(e)cmd_${sub//-/_}])); then
        shift
        "cmd_${sub//-/_}" "$@"
        return
    fi
    if (($+functions[family_default])); then
        family_default "$@"
        return
    fi
    case "$sub" in
    '' | help | -h | --help)
        family_help
        return 0
        ;;
    esac
    print -u2 -r -- "${ZSH_ARGZERO:t}: unknown command: $sub"
    return 2
}
