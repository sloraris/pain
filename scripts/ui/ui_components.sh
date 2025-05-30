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

#===================================================#
#================== FRAMEWORK PARTS ================#
#===================================================#
function menu_header() {
    local menu_name="$1"
    local total_width=71  # Total width of the header line without the corners
    local name_length=${#menu_name}
    local padding_each_side=$(( (total_width - name_length - 2) / 2 ))  # -2 for the spaces around menu name

    local left_padding=$(printf '%*s' "$padding_each_side" '' | sed 's/ /━/g')
    local right_padding=$(printf '%*s' "$padding_each_side" '' | sed 's/ /━/g')

    # Add an extra ━ to the right side if the name length plus padding is odd
    if (( (name_length + 2 + padding_each_side * 2) < total_width )); then
        right_padding+="━"
    fi

    echo -e "${WHITE}┏${left_padding} ${PURPLE}${menu_name}${WHITE} ${right_padding}┓${NC}"
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

#===================================================#
#============= TITLE, CREDITS, & VERSION ===========#
#===================================================#
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
    # right padding should be less than left due to floor division (variable padding will justify to the left on uneven numbers)
    echo -e "${WHITE}┃                            ${PAIN_VERSION_FORMATTED}                           ┃${NC}"
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
