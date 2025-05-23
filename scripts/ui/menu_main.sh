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
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ MAIN MENU ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                                                                       ┃
# ┃                   Puppet Info for ****************                    ┃
# ┃                                                                       ┃
# ┃      Status: ****************                                         ┃
# ┃     Version: ****************                                         ┃
# ┃                                                                       ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

function main_menu_header() {
    echo -e "${WHITE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ${PURPLE}MAIN MENU${WHITE} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
}

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

    status=$(printf "%-16s" "${status}")
    version=$(printf "%-16s" "${version}")
    echo "${status}|${version}"
}

function print_puppet_info() {
    local puppet_info status version
    puppet_info=$(get_puppet_info)
    status=$(echo "${puppet_info}" | cut -d'|' -f1)
    version=$(echo "${puppet_info}" | cut -d'|' -f2)

    echo -e "${WHITE}┃      Status: ${PURPLE}${status}${WHITE}                                  ┃${NC}"
    echo -e "${WHITE}┃     Version: ${PURPLE}${version}${WHITE}                                  ┃${NC}"
}

function main_menu() {
    header
    main_menu_header
    print_pain_version
    print_puppet_info
}
