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

#===================================================#
#================== MENU UI COMPONENTS =============#
#===================================================#

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
    if [[ "${status}" == "Server/Agent" ]]; then
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
    echo -e "${WHITE}┃     ${GREEN}[3] Update                               ${NC}[Q] Quit${WHITE}                 ┃${NC}"
}

#===================================================#
#=================== MENU LOGIC ====================#
#===================================================#
function get_puppet_info() {
    local has_server has_agent status server_ver agent_ver server_status agent_status

    has_server=$(dpkg -l | grep -q puppetserver && echo true || echo false)
    has_agent=$(dpkg -l | grep -q puppet-agent && echo true || echo false)

    if [[ "${has_server}" == "true" && "${has_agent}" == "true" ]]; then
        status="Server/Agent"
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

#===================================================#
#=================== MAIN MENU ====================#
#===================================================#
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
