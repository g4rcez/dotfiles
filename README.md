# dotfiles

Hi. This is my dotfiles project. Here you will find all my configurations to create an awesome shell.

# Know the dotfiles

| File                                                                                                    | Purpose                                                                                                          |
| ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [zsh/zshrc](https://github.com/g4rcez/dotfiles/blob/master/zsh/zshrc)                                   | Entrypoint of all my ZShell configs                                                                              |
| [git/gitconfig](https://github.com/g4rcez/dotfiles/blob/master/git/gitconfig)                           | Gitconfig settings. Alias, core, diff style                                                                      |
| [starship.toml](https://github.com/g4rcez/dotfiles/blob/master/config/starship.toml)                    | Configure of [starship.rs](https://starship.rs)                                                                  |
| [karabiner.config.ts](https://github.com/g4rcez/dotfiles/blob/master/src/karabiner/karabiner.config.ts) | Typescript bindings to configure Karabiner - Inspired by [mxstbr/karabiner](https://github.com/mxstbr/karabiner) |
| [espanso.config.ts](https://github.com/g4rcez/dotfiles/blob/master/src/espanso/espanso.config.ts)       | Typescript bindings to configure espanso mappers                                                                 |

# CLI softwares

- [bat](https://github.com/sharkdp/bat)
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)
- [fzf](https://github.com/junegunn/fzf)
- [lazyvim](https://lazyvim.org/)
- [lsd](https://github.com/lsd-rs/lsd)
- [starship.rs](https://starship.rs)
- [zellij](https://zellij.dev/)

# GUI softwares

- [espanso](https://espanso.org/)
- [karabiner](https://karabiner-elements.pqrs.org/index.html) - replace CapsLock to Esc
- [karabiner keybind - mxstbr](https://github.com/mxstbr/karabiner) - with some modifications
- [raycast](https://www.raycast.com/)

![my shell](./assets/shell.png)

# How to install?

First, check the requirements:

- zsh > v4
- git > v2

```bash
git clone https://github.com/g4rcez/dotfiles $HOME/dotfiles
cd $HOME/dotfiles
bash install
zsh
```

# Karabiner

My karabiner config was very inspired by [karabiner keybind - mxstbr](https://github.com/mxstbr/karabiner). You can
check the Youtube videos below:

- [Max Stoiber Owns His Workflow with Raycast](https://www.youtube.com/watch?v=m5MDv9qwhU8)
- [How I Programed the Most Productive MacOS Keyboard Setup Ever: Karabiner Elements](https://www.youtube.com/watch?v=j4b_uQX3Vu0)

With these videos I have the idea to implement keybindings like Tmux, with a prefix + key. My karabiner config have two
modes:

- `single`: that just press one time the prefix + key
- `hold`: you need to hold the prefix until the karabiner notification and press the other key. With this mode you can
  repeat all keys at layer. Hold again to exit from this mode

Inspired by [which-key.nvim](https://github.com/folke/which-key.nvim), I created the local extension of
[https://www.raycast.com/](https://www.raycast.com/) to check all my karabiner shortcuts.

# Espanso

[Espanso](https://espanso.org/) it's an amazing tool to expand your texts to other utilities. I work in frontend and I
need a lots of texts like lorem ipsum or random brazilian documents (CPF/CNPJ) to test some accounts. Since I have some
personal informations at my espanso config, this file will not be able to check at this repo. But you can generate using
the `make` or check this sample.

The espanso command key is `;`, since I use the `:` for emojis in most of applications.

```yaml
matches:
    - trigger: ";cnpj"
      replace: "{{cnpj}}"
      vars:
          - name: "cnpj"
            type: "shell"
            params:
                shell: "bash"
                cmd: "env node ~/dotfiles/bin/cnpj"
    - trigger: ";date"
      replace: "{{date}}"
      vars:
          - name: "date"
            type: "date"
            params:
                format: "%d/%m/%Y"
    - trigger: ";time"
      replace: "{{time}}"
      vars:
          - name: "time"
            type: "date"
            params:
                format: "%H:%M"
    - trigger: ";youtube"
      replace: "https://www.youtube.com/@allangarcez"
```

# My Keyboard

![my keyboard](./assets/keyboard.jpg)

