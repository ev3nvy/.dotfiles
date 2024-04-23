# Personal dotfiles
This directory contains the dotfiles for my system.

## Prerequisites
[Git][git] is required to clone the project and [just][just] is used for running the required
commands.

[Stow][stow] is used for symlinking files on Linux and [PSDotFiles][PSDotFiles] for symlinking on
Windows.

## Installation
1\. Check out the dotfiles repo in your home directory using git.
```console
git clone https://github.com/ev3nvy/.dotfiles.git
cd .dotfiles
```

2\. Use [just][just] to create symlinks.
```console
$ just # or "just install"
```

> [!NOTE]
> If you don't wish to install [just][just], you can just run the `install` commands listed in
> `justfile` manually.


[git]: https://git-scm.com
[just]: https://github.com/casey/just
[stow]: https://www.gnu.org/software/stow
[PSDotFiles]: https://github.com/ralish/PSDotFiles
