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

# ┻ ┳ ┗ ┛ ┏ ┓ ┫ ╋ ┣ ━ █
# ╩ ╦ ╚ ╝ ╔ ╗ ╣ ╬ ╠ ═

set -e

function center_text() {
    local text="$1"              # The text to center
    local text_color="${2:-$WHITE}" # Color for the centered text (default: WHITE)
    local filler="${3:-━}"       # Character to use for padding (default: ━)
    local left_edge="${4:-┃}"    # Left edge character (default: ┃)
    local right_edge="${5:-┃}"   # Right edge character (default: ┃)
    local add_spaces="${6:-true}" # Whether to add spaces around the text

    local total_width=71         # Fixed width for all menu items (excluding edges)
    local text_length=${#text}
    local space_padding=""

    if [[ "$add_spaces" == "true" ]]; then
        text=" ${text} "
        text_length=$((text_length + 2))
    fi

    local padding_each_side=$(( (total_width - text_length) / 2 ))
    local left_padding=$(printf '%*s' "$padding_each_side" '' | sed "s/ /${filler}/g")
    local right_padding=$(printf '%*s' "$padding_each_side" '' | sed "s/ /${filler}/g")

    # Add an extra filler character to the right side if the text length plus padding is odd
    if (( (text_length + padding_each_side * 2) < total_width )); then
        right_padding+="${filler}"
    fi

    echo -e "${WHITE}${left_edge}${left_padding}${text_color}${text}${NC}${right_padding}${WHITE}${right_edge}${NC}"
}

function menu_header() {
    local menu_name="$1"
    center_text "$menu_name" "${PURPLE}" "━" "┏" "┓"
    er
}

function top_bar() {
    echo -e "${WHITE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    er
}

function bottom_bar() {
    er
    echo -e "${WHITE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

function hr() {
    echo -e "${WHITE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
}

function hr-dashed() {
    echo -e "${WHITE}┃    ═══════════════════════════════════════════════════════════════    ┃${NC}"
}

function er() {
    echo -e "${WHITE}┃                                                                       ┃${NC}"
}

function logo() {

    echo -e  "${WHITE}┃                ${PURPLE}██████╗     █████╗    ██╗   ███╗   ██╗${WHITE}                 ┃${NC}"
    echo -e  "${WHITE}┃                ${PURPLE}██╔══██╗   ██╔══██╗   ██║   ████╗  ██║${WHITE}                 ┃${NC}"
    echo -e  "${WHITE}┃                ${PURPLE}██████╔╝   ███████║   ██║   ██╔██╗ ██║${WHITE}                 ┃${NC}"
    echo -e  "${WHITE}┃                ${PURPLE}██╔═══╝    ██╔══██║   ██║   ██║╚██╗██║${WHITE}                 ┃${NC}"
    echo -e  "${WHITE}┃                ${PURPLE}██║        ██║  ██║   ██║   ██║ ╚████║${WHITE}                 ┃${NC}"
    echo -e  "${WHITE}┃                ${PURPLE}╚═╝        ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝${WHITE}                 ┃${NC}"
    echo -e  "${WHITE}┃                Puppet Assisted Installation Navigator                 ┃${NC}"
}

function credits() {
    echo -e  "${WHITE}┃                           ${PURPLE}a tool by sloraris${WHITE}                          ┃${NC}"
}

function version() {
    if [[ "${PAIN_VERSION_STATUS}" == "current" ]]; then
        center_text "${PAIN_VERSION}" "${GREEN}" " "
    else
        center_text "${PAIN_VERSION}" "${YELLOW}" " "
    fi
}

function title() {
    # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ # top_bar
    # ┃                                                                       ┃ #
    # ┃                ██████╗     █████╗    ██╗   ███╗   ██╗                 ┃ # logo
    # ┃                ██╔══██╗   ██╔══██╗   ██║   ████╗  ██║                 ┃ #
    # ┃                ██████╔╝   ███████║   ██║   ██╔██╗ ██║                 ┃ #
    # ┃                ██╔═══╝    ██╔══██║   ██║   ██║╚██╗██║                 ┃ #
    # ┃                ██║        ██║  ██║   ██║   ██║ ╚████║                 ┃ #
    # ┃                ╚═╝        ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝                 ┃ #
    # ┃                Puppet Assisted Installation Navigator                 ┃ # logo
    # ┃                             v*************                            ┃ # version
    # ┃                           a tool by sloraris                          ┃ # credits
    # ┃                                                                       ┃ #
    # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ # bottom_bar

    top_bar
    logo
    version
    credits
    bottom_bar
    echo -e "${CLEAR_LINE}"
}
