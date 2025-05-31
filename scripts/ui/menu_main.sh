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
    local puppet_info status hostname
    puppet_info=$(get_puppet_info)
    status=$(echo "${puppet_info}" | cut -d'|' -f1)

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
        # Format server version
        case "${PUPPET_SERVER_VER_STATUS}" in
            "current")
                formatted_server="${GREEN}${PUPPET_SERVER_VER}${WHITE}"
                ;;
            "unknown")
                formatted_server="${YELLOW}${PUPPET_SERVER_VER}${WHITE}"
                ;;
            *)
                formatted_server="${RED}${PUPPET_SERVER_VER}${WHITE}"
                ;;
        esac

        # Format agent version
        case "${PUPPET_AGENT_VER_STATUS}" in
            "current")
                formatted_agent="${GREEN}${PUPPET_AGENT_VER}${WHITE}"
                ;;
            "unknown")
                formatted_agent="${YELLOW}${PUPPET_AGENT_VER}${WHITE}"
                ;;
            *)
                formatted_agent="${RED}${PUPPET_AGENT_VER}${WHITE}"
                ;;
        esac

        # Combine the formatted versions with proper padding
        formatted_version=$(printf "%-16s" "${formatted_server}/${formatted_agent}")
    else
        local version_to_show
        local version_status

        if [[ "${status}" == "Server only" ]]; then
            version_to_show="${PUPPET_SERVER_VER}"
            version_status="${PUPPET_SERVER_VER_STATUS}"
        else
            version_to_show="${PUPPET_AGENT_VER}"
            version_status="${PUPPET_AGENT_VER_STATUS}"
        fi

        version_to_show=$(printf "%-16s" "${version_to_show}")
        case "${version_status}" in
            "current")
                formatted_version="${GREEN}${version_to_show}${WHITE}"
                ;;
            "unknown")
                formatted_version="${YELLOW}${version_to_show}${WHITE}"
                ;;
            *)
                formatted_version="${RED}${version_to_show}${WHITE}"
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

# ╠═════════════════════════════╣ MENU LOGIC ╠════════════════════════════╣
function get_puppet_info() {
    local has_server has_agent status

    has_server=$(dpkg -l | grep -q puppetserver && echo true || echo false)
    has_agent=$(dpkg -l | grep -q puppet-agent && echo true || echo false)

    if [[ "${has_server}" == "true" && "${has_agent}" == "true" ]]; then # Server and Agent installed
        status="Server/Agent"
        PUPPET_SERVER_VER=$(dpkg -l puppetserver | awk '/^ii/ {print $3}' | cut -d'-' -f1)
        PUPPET_AGENT_VER=$(dpkg -l puppet-agent | awk '/^ii/ {print $3}' | cut -d'-' -f1)

        # Check server version status
        if [[ "${LATEST_SERVER_VER}" == "unknown" ]]; then
            PUPPET_SERVER_VER_STATUS="unknown"
        elif [[ "${PUPPET_SERVER_VER}" == "${LATEST_SERVER_VER}" ]]; then
            PUPPET_SERVER_VER_STATUS="current"
        else
            PUPPET_SERVER_VER_STATUS="outdated"
        fi

        # Check agent version status
        if [[ "${LATEST_AGENT_VER}" == "unknown" ]]; then
            PUPPET_AGENT_VER_STATUS="unknown"
        elif [[ "${PUPPET_AGENT_VER}" == "${LATEST_AGENT_VER}" ]]; then
            PUPPET_AGENT_VER_STATUS="current"
        else
            PUPPET_AGENT_VER_STATUS="outdated"
        fi
    elif [[ "${has_server}" == "true" ]]; then # Server only installed
        status="Server only"
        PUPPET_SERVER_VER=$(dpkg -l puppetserver | awk '/^ii/ {print $3}' | cut -d'-' -f1)
        PUPPET_AGENT_VER="N/A"

        if [[ "${LATEST_SERVER_VER}" == "unknown" ]]; then
            PUPPET_SERVER_VER_STATUS="unknown"
        elif [[ "${PUPPET_SERVER_VER}" == "${LATEST_SERVER_VER}" ]]; then
            PUPPET_SERVER_VER_STATUS="current"
        else
            PUPPET_SERVER_VER_STATUS="outdated"
        fi
        PUPPET_AGENT_VER_STATUS="none"
    elif [[ "${has_agent}" == "true" ]]; then # Agent only installed
        status="Agent only"
        PUPPET_SERVER_VER="N/A"
        PUPPET_AGENT_VER=$(dpkg -l puppet-agent | awk '/^ii/ {print $3}' | cut -d'-' -f1)

        PUPPET_SERVER_VER_STATUS="none"
        if [[ "${LATEST_AGENT_VER}" == "unknown" ]]; then
            PUPPET_AGENT_VER_STATUS="unknown"
        elif [[ "${PUPPET_AGENT_VER}" == "${LATEST_AGENT_VER}" ]]; then
            PUPPET_AGENT_VER_STATUS="current"
        else
            PUPPET_AGENT_VER_STATUS="outdated"
        fi
    else
        status="Not installed"
        PUPPET_SERVER_VER="N/A"
        PUPPET_AGENT_VER="N/A"
        PUPPET_SERVER_VER_STATUS="none"
        PUPPET_AGENT_VER_STATUS="none"
    fi

    echo "${status}"
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
