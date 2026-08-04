# Shared, shell-neutral values for standalone dotfiles scripts.
# Callers may provide DOTFILES_DIR; otherwise derive it from this helper's path.
if [ -z "${DOTFILES_DIR:-}" ] || [ ! -d "$DOTFILES_DIR/bin" ]; then
    if [ -n "${BASH_SOURCE:-}" ]; then
        _dotfiles_lib_dir="$(CDPATH= cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || return 1
        DOTFILES_DIR="$(CDPATH= cd -P -- "$_dotfiles_lib_dir/../.." && pwd)" || return 1
        unset _dotfiles_lib_dir
    elif [ -n "${DOTFILES:-}" ] && [ -d "$DOTFILES/bin" ]; then
        DOTFILES_DIR="$DOTFILES"
    fi
fi

if [ -z "${DOTFILES_DIR:-}" ] || [ ! -d "$DOTFILES_DIR/bin" ]; then
    printf '%s\n' 'dotfiles-shell: DOTFILES_DIR is not set' >&2
    return 1
fi

export DOTFILES_DIR
if [ -z "${DOTFILES:-}" ] || [ ! -d "$DOTFILES/bin" ]; then
    DOTFILES="$DOTFILES_DIR"
fi
export DOTFILES
export FZF_COLORS="${FZF_COLORS:---color=dark,bg+:#2d353d,border:#1E1E2E,bg:#1A1B26,spinner:#f6c177,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --separator='─' --scrollbar=\| --info=right}"
