# Awesome Shell

This is a repository with all dotfiles to making a power and awesome Shell

![My Shell](shell.png)

## Requirements

-   [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh)
-   [Nerd-Fonts](https://github.com/ryanoasis/nerd-fonts)
-   [MyCli](https://github.com/dbcli/mycli)
-   [PgCli](https://www.pgcli.com/)

## Making your Awesome Shell

First, you need install all requirements to build it. Starting with "Oh-My-Zsh":

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
curl -fsSl "https://raw.githubusercontent.com/vandalvnl/dotfiles/master/zsh/vandal.zsh-theme" > ~/.oh-my-zsh/themes/vandal.zsh-theme
curl -fsSl "https://raw.githubusercontent.com/vandalvnl/dotfiles/master/zsh/vandal.zsh-theme" > ~/.zshrc
```

## Warning

I use [`nvm`](https://github.com/creationix/nvm) and [`rbenv`](https://github.com/rbenv/rbenv) for control my development env.
