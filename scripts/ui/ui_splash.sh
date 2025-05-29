#!/usr/bin/env bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ Copyright (C) 2025 Parker Owings <sloraris@sloraris.dev>              ┃
# ┃                                                                       ┃
# ┃ UI heavily inspired by Dominik Willner's KIAUH <th33xitus@gmail.com>  ┃
# ┃ https://github.com/dw-0/kiauh                                         ┃
# ┃                                                                       ┃
# ┃ This file is part of PAIN - Puppet Assisted Installation Navigator    ┃
# ┃ https://github.com/sloraris/pain                                      ┃
# ┃                                                                       ┃
# ┃ This file may be distributed under the terms of the GNU GPLv3 license ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

# hide cursor
tput civis

function splash_screen() {
    local colors=("\033[1;31m" "\033[1;33m" "\033[1;32m" "\033[1;36m" "\033[1;34m" "\033[1;35m")
    local logo=(
        "                ██████╗     █████╗    ██╗   ███╗   ██╗"
        "                ██╔══██╗   ██╔══██╗   ██║   ████╗  ██║"
        "                ██████╔╝   ███████║   ██║   ██╔██╗ ██║"
        "                ██╔═══╝    ██╔══██║   ██║   ██║╚██╗██║"
        "                ██║        ██║  ██║   ██║   ██║ ╚████║"
        "                ╚═╝        ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝"
    )

    clear

    # Animate each line of the logo
    for i in {1..3}; do  # Number of color cycles
        for ((j=0; j<${#colors[@]}; j++)); do
            local color="${colors[j]}"
            echo
            top_bar
            for line in "${logo[@]}"; do
                echo -e "${WHITE}┃${color}${line}${WHITE}                 ┃${NC}"
            done
            er
            echo -e "${WHITE}┃                Puppet Assisted Installation Navigator                 ┃${NC}"
            er
            credits
            bottom_bar
            echo -en "\033[15A"
            sleep 0.1
        done
    done

    sleep 0.5

    # show cursor
    tput cnorm
}
