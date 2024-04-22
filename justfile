#!/usr/bin/env just --justfile

install:
    stow -S fish -t ~/.config/fish
    stow -S git -t ~/
    stow -S keepassxc -t ~/.config/keepassxc
    stow -S vscodium -t ~/.config/VSCodium
