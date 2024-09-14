if status is-interactive
    # Commands to run in interactive sessions can go here
    if command -q pyenv
        pyenv init - | source
    end
end
rtx activate fish | source
