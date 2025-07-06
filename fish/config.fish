if status is-interactive

    # Fish Greetings
    set fish_greeting ""

    # Starship Promt
    set -gx STARSHIP_CONFIG ~/.config/starship/fish.toml
    starship init fish | source

    # Zoxide
    eval "$(zoxide init --cmd cd fish)"

    # Alias

    alias m='mousepad'
    alias h='helix'
    alias linutil='curl -fsSL https://christitus.com/linux | sh'
    alias off='shutdown now'
    alias c='clear'
    alias ls="eza -a --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
    alias gc='git clone'
    alias ins='sudo pacman -S'
    alias uins='sudo pacman -Rns'
    alias updt="sudo pacman -Syu"
    alias .='cd ..'
    alias ..='cd .. && cd ..'
    alias ...='cd .. && cd .. && cd ..'
    alias reset_fish_history='cd /home/i/.local/share/fish && sudo rm fish_history'
    alias qq='tgpt'
    alias cfish='helix .config/fish/config.fish '
    alias del="bash /home/i/.local/scripts/clipboard_delete.sh del"
    alias dfe="bash /home/i/.local/scripts/clipboard_delete.sh dfe"

    # DWM Alias
    alias s='clear && startx'
    alias cdwm='cd Suckless/dwm && helix config.def.h'
    alias redwm='cd Suckless/dwm && sudo rm config.h && sudo make clean install && cd .. && cd ..'
    alias iii='sudo make clean install'
    alias cdmenu='cd Suckless/dmenu && nvim config.def.h'
    alias redmenu='cd Suckless/dmenu && sudo rm config.h && sudo make clean install && cd .. && cd ..'

end

# Functions Starship Transient Promt

function starship_transient_prompt_func
    starship module character
end
starship init fish | source
enable_transience

# Customize fzf.fish keybindings
fzf_configure_bindings --history=\ew --directory=\eq

# Auto start
if status --is-login
    if test -z "$DISPLAY" -a (tty) = /dev/tty1
        exec startx
    end
end

# Clipboard Sourching
source ~/.config/fish/functions/clipboard.fish
