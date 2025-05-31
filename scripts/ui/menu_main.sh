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
clear -x

# ╠════════════════════════╣ MAIN MENU COMPONENTS ╠═══════════════════════╣
function print_puppet_info() {
    local mode hostname

    mode="${PUPPET_MODE}"

    # Format the status string
    if [[ "${mode}" == "Server/Agent" ]]; then
        formatted_mode="${GREEN}$(printf "%-16s" "Server/Agent")${WHITE}"
    elif [[ "${mode}" == "Server only" ]]; then
        formatted_mode="${GREEN}$(printf "%-16s" "Server only")${WHITE}"
    elif [[ "${mode}" == "Agent only" ]]; then
        formatted_mode="${GREEN}$(printf "%-16s" "Agent only")${WHITE}"
    else
        formatted_mode="${RED}$(printf "%-16s" "Not installed")${WHITE}"
    fi

    hostname=$(hostname)
    hostname=$(printf "%-16s" "${hostname}")
    hostname="${BLUE}${hostname}${WHITE}"

    echo -e "${WHITE}┃        Host: ${hostname}                                         ┃${NC}"
    echo -e "${WHITE}┃        Mode: ${formatted_mode}                                         ┃${NC}"
}

function print_main_menu() {
    echo -e "${WHITE}┃     ${GREEN}[1] Install                              ${NC}[R] Remove${WHITE}               ┃${NC}"
    echo -e "${WHITE}┃     ${GREEN}[2] Setup${WHITE}                                                         ┃${NC}"
    echo -e "${WHITE}┃     ${GREEN}[3] Update                               ${NC}[Q] Quit${WHITE}                 ┃${NC}"
}

# ╠═════════════════════════════╣ MENU LOGIC ╠════════════════════════════╣
function main_menu_input() {
    local prompt="Enter option:"
    while true; do
        # Move cursor to start of line and clear it
        echo -en "\r${CLEAR_LINE}${prompt}"
        # Read a single character without requiring Enter
        read -n 1 -t 1 main_menu_option
        case "${main_menu_option}" in
            1) install_menu; break;;
            2) setup_menu; break;;
            3) update_menu; break;;
            [Rr]) remove_menu; break;;
            [Qq]) exit 0;;
            *)
                # Clear input buffer
                read -t 0.1 -n 100 discard
                # Show error briefly without creating new lines
                echo -en "\r${CLEAR_LINE}${RED}Invalid option${NC}"
                sleep 0.5
                ;;
        esac
    done
}

# ╠═════════════════════════════╣ MAIN MENU ╠═════════════════════════════╣
function main_menu() {
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ MAIN MENU ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ menu_header
# ┃                                                                       ┃
# ┃        Host: ****************                                         ┃ print_puppet_info
# ┃      Status: ****************                                         ┃
# ┃     Version: ****************                                         ┃ print_puppet_info
# ┃                                                                       ┃
# ┃    ═══════════════════════════════════════════════════════════════    ┃ hr-dashed
# ┃                                                                       ┃
# ┃     [1] Install                              [R] Remove               ┃ print_main_menu
# ┃     [2] Setup                                                         ┃
# ┃     [3] Update                               [Q] Quit                 ┃ print_main_menu
# ┃                                                                       ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ bottom_bar
# Enter option: ****************

    title
    menu_header "MAIN MENU"
    print_puppet_info
    er
    hr-dashed
    er
    print_main_menu
    bottom_bar
    main_menu_input
}
