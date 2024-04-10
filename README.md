# Personal dotfiles
This directory contains the dotfiles for my system.

## Prerequisites
[Git][git] is required to clone the project and [Stow][stow] is used for symlinking files into the
home directory.

## Installation
1\. Check out the dotfiles repo in your home directory using git.
```console
git clone https://github.com/ev3nvy/.dotfiles.git
cd .dotfiles
```

2\. Use the installation script to create symlinks.
```console
./install.sh
```

> [!NOTE]
> The command might need to be prefixed with `bash`.


[git]: https://git-scm.com
[stow]: https://www.gnu.org/software/stow
