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

#===================================================#
#================== FRAMEWORK PARTS ================#
#===================================================#
function top_bar() {
    echo -e "${WHITE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
}

function bottom_bar() {
    echo -e "${WHITE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

function hr() {
    echo -e "${WHITE}┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃${NC}"
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

    echo -e "${WHITE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃ ${CYAN}${PAIN_VERSION_FORMATTED}${WHITE} ┃━━┛${NC}"
}

function title() {
    # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ # top_bar
    # ┃                                                                       ┃ # er
    # ┃                ██████╗     █████╗    ██╗   ███╗   ██╗                 ┃ # logo
    # ┃                ██╔══██╗   ██╔══██╗   ██║   ████╗  ██║                 ┃ #
    # ┃                ██████╔╝   ███████║   ██║   ██╔██╗ ██║                 ┃ #
    # ┃                ██╔═══╝    ██╔══██║   ██║   ██║╚██╗██║                 ┃ #
    # ┃                ██║        ██║  ██║   ██║   ██║ ╚████║                 ┃ #
    # ┃                ╚═╝        ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝                 ┃ #
    # ┃                Puppet Assisted Installation Navigator                 ┃ # logo
    # ┃                                                                       ┃ # er
    # ┃                           a tool by sloraris                          ┃ # credits
    # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┃ v************* ┃━━┛ # version

    top_bar
    er
    logo
    er
    credits
    version
}
