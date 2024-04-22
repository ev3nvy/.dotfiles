# Personal dotfiles
This directory contains the dotfiles for my system.

## Prerequisites
[Git][git] is required to clone the project and [Stow][stow] is used for symlinking files into the
home directory.

Additionally, [just][just] is used for running the required stow commands.

## Installation
1\. Check out the dotfiles repo in your home directory using git.
```console
git clone https://github.com/ev3nvy/.dotfiles.git
cd .dotfiles
```

2\. Use [just][just] to create symlinks.
```console
$ just # or just install
```

> [!NOTE]
> If you don't wish to install [just][just], you can just run the `install` commands listed in
> `justfile` manually.


[git]: https://git-scm.com
[stow]: https://www.gnu.org/software/stow
[just]: https://github.com/casey/just
