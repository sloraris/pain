#!/usr/bin/env bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ Copyright (C) 2025 Parker Owings <sloraris@sloraris.dev>              ┃
# ┃                                                                       ┃
# ┃ This file is part of PAIN - Puppet Assisted Installation Navigator    ┃
# ┃ https://github.com/sloraris/pain                                      ┃
# ┃                                                                       ┃
# ┃ UI heavily inspired by Dominik Willner's KIAUH <th33xitus@gmail.com>  ┃
# ┃ https://github.com/dw-0/kiauh                                         ┃
# ┃                                                                       ┃
# ┃ This file may be distributed under the terms of the GNU GPLv3 license ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

# make sure we have the correct permissions while running the script
umask 027

### sourcing all additional scripts
PAIN_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
for script in "${PAIN_DIR}/scripts/"*.sh; do . "${script}"; done
for script in "${PAIN_DIR}/scripts/ui/"*.sh; do . "${script}"; done

#===================================================#
#================= SUDO MANAGEMENT ==================#
#===================================================#

function check_euid() {
    if [[ $EUID -eq 0 ]]; then
        error_msg "This script should not be run directly as root. Please run as a normal user with sudo privileges instead." >&2
        exit 1
    fi
}

function ensure_sudo() {
    warning_msg "This script requires sudo privileges to continue."

    # Clear any existing sudo tokens/cached credentials
    sudo -k

    # Request sudo credentials
    if ! sudo -v; then
        error_msg "Failed to obtain sudo privileges." >&2
        exit 1
    fi

    # Verify we actually got sudo access with a real test
    if ! sudo test -w /etc/sudoers.d/; then
        error_msg "Failed to verify sudo access after password entry." >&2
        exit 1
    fi

    success_msg "Sudo access verified."

    # Keep sudo alive in the background
    (while true; do
        sudo -n true
        sleep 50
        kill -0 "$$" 2>/dev/null || exit
    done) &

    # Store the background process ID so we can kill it on exit
    SUDO_KEEPER_PID=$!
    trap 'kill $SUDO_KEEPER_PID >/dev/null 2>&1' EXIT
}

#===================================================#
#================= VERSION CHECKING ================#
#===================================================#

function check_latest_versions() {
    # Try to update apt cache, but handle errors
    if ! sudo apt-get update -qq 2>/dev/null; then
        warning_msg "Failed to update apt cache. Version checks may be inaccurate." >&2
        # Set fallback values
        LATEST_SERVER_VER="unknown"
        LATEST_AGENT_VER="unknown"
        export LATEST_SERVER_VER LATEST_AGENT_VER
        return 1
    fi

    # Get latest available versions with error checking
    LATEST_SERVER_VER=$(sudo apt-cache policy puppetserver 2>/dev/null | awk '/Candidate:/ {print $2}' | cut -d'-' -f1)
    if [[ -z "${LATEST_SERVER_VER}" ]]; then
        LATEST_SERVER_VER="unknown"
        warning_msg "Could not determine latest Puppet Server version" >&2
    fi

    LATEST_AGENT_VER=$(sudo apt-cache policy puppet-agent 2>/dev/null | awk '/Candidate:/ {print $2}' | cut -d'-' -f1)
    if [[ -z "${LATEST_AGENT_VER}" ]]; then
        LATEST_AGENT_VER="unknown"
        warning_msg "Could not determine latest Puppet Agent version" >&2
    fi

    # Export these for use in other scripts
    export LATEST_SERVER_VER
    export LATEST_AGENT_VER

    # Return success only if we got both versions
    if [[ "${LATEST_SERVER_VER}" != "unknown" && "${LATEST_AGENT_VER}" != "unknown" ]]; then
        return 0
    else
        return 1
    fi
}

#===================================================#
#=================== UPDATE PAIN ===================#
#===================================================#

function update_pain() {
  cd "${PAIN_DIR}" || return

  # Check if we're on the default branch
  local current_branch
  current_branch=$(git branch --show-current)
  if [[ "${current_branch}" != "main" ]]; then
    warning_msg "Cannot update - You are on branch '${current_branch}' instead of 'main'"
    return 1
  fi

  # Quietly pull updates (only occurs if on default branch)
  if git pull -q origin main; then
    success_msg "PAIN updated successfully. Please relaunch."
    exit 0
  else
    error_msg "Failed to update PAIN."
    return 1
  fi
}

function get_pain_version() {
  local version padding_left padding_right
  version="v. unknown"

  if [[ -d "${REPO_PATH}/.git" ]]; then
    cd "${REPO_PATH}" || return

    if git rev-parse --git-dir > /dev/null 2>&1; then
      version=$(git describe --always --tags 2>/dev/null | cut -d "-" -f 1,2)
    fi
  fi

  # If version is already 16 chars, use it as-is
  if [[ ${#version} -eq 16 ]]; then
    PAIN_VERSION_FORMATTED="${version}"
  else
    # Calculate padding for centering (16 is the target width)
    padding_left=$(( (14 - ${#version}) / 2 ))
    padding_right=$(( 14 - ${#version} - padding_left ))

    # Create the padding strings
    padding_left=$(printf "%${padding_left}s" "")
    padding_right=$(printf "%${padding_right}s" "")

    # Set the global formatted version
    PAIN_VERSION_FORMATTED="${padding_left}${version}${padding_right}"
  fi
}

#===================================================#
#=================== MAIN SCRIPT ===================#
#===================================================#
# Check EUID to prevent running as root
check_euid

# Show splash screen first so user sees what they're running
splash_screen

# Ensure sudo access
ensure_sudo

# Continue with the rest of initialization
check_latest_versions
get_pain_version

# Enter main menu
main_menu
