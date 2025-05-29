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

clear -x
set -e

#===================================================#
#================== MENU UI COMPONENTS =============#
#===================================================#
function main_menu_header() {
    echo -e "${WHITE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ${PURPLE}MAIN MENU${WHITE} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    er
}

function print_puppet_info() {
    local puppet_info status version hostname
    puppet_info=$(get_puppet_info)
    status=$(echo "${puppet_info}" | cut -d'|' -f1)
    version=$(echo "${puppet_info}" | cut -d'|' -f2)

    # Format the status string with proper padding before adding color
    if [[ "${status}" == "Not installed" ]]; then
        status=$(printf "%-16s" "Not installed")
        formatted_status="${RED}${status}${WHITE}"
    else
        status=$(printf "%-16s" "${status}")
        formatted_status="${GREEN}${status}${WHITE}"
    fi

    # Format the version string with proper padding before adding color
    if [[ "${version}" == "N/A" ]]; then
        version=$(printf "%-16s" "N/A")
        formatted_version="${RED}${version}${WHITE}"
    else
        version=$(printf "%-16s" "${version}")
        formatted_version="${GREEN}${version}${WHITE}"
    fi

    hostname=$(hostname)
    hostname=$(printf "%-16s" "${hostname}")
    hostname="${BLUE}${hostname}${WHITE}"

    echo -e "${WHITE}┃        Host: ${hostname}                                         ┃${NC}"
    echo -e "${WHITE}┃      Status: ${formatted_status}                                         ┃${NC}"
    echo -e "${WHITE}┃     Version: ${formatted_version}                                         ┃${NC}"
}

function print_main_menu() {
    echo -e "${WHITE}┃     ${GREEN}[1] Install                              ${RED}[R] Remove${WHITE}               ┃${NC}"
    echo -e "${WHITE}┃     ${GREEN}[2] Setup${WHITE}                                                         ┃${NC}"
    echo -e "${WHITE}┃     ${GREEN}[3] Update                               ${BLACK}[Q] Quit${WHITE}                 ┃${NC}"
}

function print_prompt() {
    echo -en "${PURPLE}Enter option: ${NC}"
}

#===================================================#
#=================== MENU LOGIC ====================#
#===================================================#
function get_puppet_info() {
    local has_server has_agent status version
    has_server=$(dpkg -l | grep -q puppet-server && echo true || echo false)
    has_agent=$(dpkg -l | grep -q puppet-agent && echo true || echo false)

    if [[ "${has_server}" == "true" && "${has_agent}" == "true" ]]; then
        status="Both installed"
        server_ver=$(dpkg -l puppet-server | awk '/puppet-server/ {print $3}')
        agent_ver=$(dpkg -l puppet-agent | awk '/puppet-agent/ {print $3}')
        version="${server_ver} / ${agent_ver}"
    elif [[ "${has_server}" == "true" ]]; then
        status="Server only"
        version=$(dpkg -l puppet-server | awk '/puppet-server/ {print $3}')
    elif [[ "${has_agent}" == "true" ]]; then
        status="Agent only"
        version=$(dpkg -l puppet-agent | awk '/puppet-agent/ {print $3}')
    else
        status="Not installed"
        version="N/A"
    fi

    echo "${status}|${version}"
}

function main_menu_input() {
    print_prompt
    read -r main_menu_option
    case "${main_menu_option}" in
        1) install_menu ;;
        2) setup_menu ;;
        3) update_menu ;;
        R|r) remove_menu ;;
        Q|q) exit 0 ;;
        *)
            echo -e "${CURSOR_UP}${CLEAR_LINE}${RED}Invalid option${NC}"
            sleep 1
            echo -e "${CURSOR_UP}${CLEAR_LINE}"
            main_menu_input
            ;;
    esac
}

#===================================================#
#=================== MAIN MENU ====================#
#===================================================#
function main_menu() {

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ MAIN MENU ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ main_menu_header
# ┃                                                                       ┃ er
# ┃        Host: ****************                                         ┃ print_puppet_info
# ┃      Status: ****************                                         ┃
# ┃     Version: ****************                                         ┃ print_puppet_info
# ┃                                                                       ┃
# ┃    ═══════════════════════════════════════════════════════════════    ┃ hr-dashed
# ┃                                                                       ┃
# ┃     [1] Install                              [R] Remove               ┃ print_main_menu
# ┃     [2] Setup                                                         ┃
# ┃     [3] Update                               [Q] Quit                 ┃ print_main_menu
# ┃                                                                       ┃ er
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ bottom_bar
# Enter option: ****************

    title
    main_menu_header
    print_puppet_info
    er
    hr-dashed
    er
    print_main_menu
    er
    bottom_bar
    main_menu_input
}
