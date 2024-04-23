#!/usr/bin/env just --justfile

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]

[linux]
install:
    stow -S fish -t ~/.config/fish
    stow -S git -t ~/
    stow -S keepassxc -t ~/.config/keepassxc
    stow -S vscodium -t ~/.config/VSCodium

[windows]
install:
    Start-Process -Verb RunAs powershell.exe -Args "-NoExit -executionpolicy bypass -command Set-Location \`"$PWD\`"; Install-DotFiles -Path \`"./\`" -AutoDetect"
