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
    local install="[1] Install"
    local setup="[2] Setup"
    local update="[3] Update"

    # Format install menu option
    if [[ "${PUPPET_MODE}" == "Not installed" ]]; then
        install_menu_option="${RED}${install}${WHITE}"
    else
        install_menu_option="${GREEN}${install}${WHITE}"
    fi

    # Format setup menu option
    if [[ -f /etc/puppet/puppet.conf ]]; then
        setup_menu_option="${GREEN}${setup}${WHITE}"
    else
        setup_menu_option="${RED}${setup}${WHITE}"
    fi

    # Format update menu option
    if [[ "${PUPPET_SERVER_VER_STATUS}" == "current" && "${PUPPET_AGENT_VER_STATUS}" == "current" ]]; then
        update_menu_option="${GREEN}${update}${WHITE}"
    elif [[ "${PUPPET_SERVER_VER_STATUS}" == "outdated" && "${PUPPET_AGENT_VER_STATUS}" == "outdated" ]]; then
        update_menu_option="${YELLOW}${update}${WHITE}"
    else
        update_menu_option="${RED}${update}${WHITE}"
    fi

    echo -e "${WHITE}┃     ${install_menu_option}                              ${NC}[R] Remove${WHITE}               ┃${NC}"
    echo -e "${WHITE}┃     ${setup_menu_option}                                                         ┃${NC}"
    echo -e "${WHITE}┃     ${update_menu_option}                               ${NC}[Q] Quit${WHITE}                 ┃${NC}"
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
