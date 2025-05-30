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
    local puppet_info status version version_status hostname
    puppet_info=$(get_puppet_info)
    status=$(echo "${puppet_info}" | cut -d'|' -f1)
    version=$(echo "${puppet_info}" | cut -d'|' -f2)
    version_status=$(echo "${puppet_info}" | cut -d'|' -f3)

    # Format the status string with proper padding before adding color
    if [[ "${status}" == "Not installed" ]]; then
        status=$(printf "%-16s" "Not installed")
        formatted_status="${RED}${status}${WHITE}"
    else
        status=$(printf "%-16s" "${status}")
        formatted_status="${GREEN}${status}${WHITE}"
    fi

    # Format the version string with proper padding before adding color
    if [[ "${status}" == "Both installed" ]]; then
        # Split version and status for server and agent
        server_ver=$(echo "${version}" | cut -d'|' -f1)
        agent_ver=$(echo "${version}" | cut -d'|' -f2)
        server_status=$(echo "${version_status}" | cut -d'|' -f1)
        agent_status=$(echo "${version_status}" | cut -d'|' -f2)

        # Format server version
        server_ver=$(printf "%-8s" "${server_ver}")
        case "${server_status}" in
            "current")
                formatted_server="${GREEN}${server_ver}${WHITE}"
                ;;
            "outdated")
                formatted_server="${RED}${server_ver}${WHITE}"
                ;;
            "unknown")
                formatted_server="${YELLOW}${server_ver}${WHITE}"
                ;;
        esac

        # Format agent version
        agent_ver=$(printf "%-8s" "${agent_ver}")
        case "${agent_status}" in
            "current")
                formatted_agent="${GREEN}${agent_ver}${WHITE}"
                ;;
            "outdated")
                formatted_agent="${RED}${agent_ver}${WHITE}"
                ;;
            "unknown")
                formatted_agent="${YELLOW}${agent_ver}${WHITE}"
                ;;
        esac

        formatted_version="${formatted_server}/${formatted_agent}"
    else
        version=$(printf "%-16s" "${version}")
        case "${version_status}" in
            "current")
                formatted_version="${GREEN}${version}${WHITE}"
                ;;
            "outdated")
                formatted_version="${RED}${version}${WHITE}"
                ;;
            "unknown")
                formatted_version="${YELLOW}${version}${WHITE}"
                ;;
            "none")
                formatted_version="${RED}${version}${WHITE}"
                ;;
        esac
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
    local has_server has_agent status server_ver agent_ver server_status agent_status

    has_server=$(dpkg -l | grep -q puppetserver && echo true || echo false)
    has_agent=$(dpkg -l | grep -q puppet-agent && echo true || echo false)

    if [[ "${has_server}" == "true" && "${has_agent}" == "true" ]]; then
        status="Both installed"
        server_ver=$(dpkg -l puppetserver | awk '/puppetserver/ {print $3}' | cut -d'-' -f1)
        agent_ver=$(dpkg -l puppet-agent | awk '/puppet-agent/ {print $3}' | cut -d'-' -f1)

        # Check server version status
        if [[ "${LATEST_SERVER_VER}" == "unknown" ]]; then
            server_status="unknown"
        elif [[ "${server_ver}" == "${LATEST_SERVER_VER}" ]]; then
            server_status="current"
        else
            server_status="outdated"
        fi

        # Check agent version status
        if [[ "${LATEST_AGENT_VER}" == "unknown" ]]; then
            agent_status="unknown"
        elif [[ "${agent_ver}" == "${LATEST_AGENT_VER}" ]]; then
            agent_status="current"
        else
            agent_status="outdated"
        fi

        version="${server_ver}|${agent_ver}"
        version_status="${server_status}|${agent_status}"
    elif [[ "${has_server}" == "true" ]]; then
        status="Server only"
        server_ver=$(dpkg -l puppetserver | awk '/puppetserver/ {print $3}' | cut -d'-' -f1)
        version="${server_ver}"

        if [[ "${LATEST_SERVER_VER}" == "unknown" ]]; then
            version_status="unknown"
        elif [[ "${server_ver}" == "${LATEST_SERVER_VER}" ]]; then
            version_status="current"
        else
            version_status="outdated"
        fi
    elif [[ "${has_agent}" == "true" ]]; then
        status="Agent only"
        agent_ver=$(dpkg -l puppet-agent | awk '/puppet-agent/ {print $3}' | cut -d'-' -f1)
        version="${agent_ver}"

        if [[ "${LATEST_AGENT_VER}" == "unknown" ]]; then
            version_status="unknown"
        elif [[ "${agent_ver}" == "${LATEST_AGENT_VER}" ]]; then
            version_status="current"
        else
            version_status="outdated"
        fi
    else
        status="Not installed"
        version="N/A"
        version_status="none"
    fi

    echo "${status}|${version}|${version_status}"
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
    main_menu_header
    print_puppet_info
    er
    hr-dashed
    er
    print_main_menu
    bottom_bar
    main_menu_input
}
