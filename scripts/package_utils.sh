#!/usr/bin/env bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ Copyright (C) 2025 Parker Owings <sloraris@sloraris.dev>              ┃
# ┃                                                                       ┃
# ┃ This file is part of PAIN - Puppet Assisted Installation Navigator    ┃
# ┃ https://github.com/sloraris/pain                                      ┃
# ┃                                                                       ┃
# ┃ This file may be distributed under the terms of the GNU GPLv3 license ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

# ╠═════════════════════════╣ APT CACHE MANAGEMENT ╠══════════════════════╣
# Check if apt cache needs updating (older than 1 hour)
function needs_apt_update() {
    local apt_cache_age
    local current_time
    local cache_file="/var/cache/apt/pkgcache.bin"

    # If cache doesn't exist, definitely needs update
    if [[ ! -f "${cache_file}" ]]; then
        return 0
    fi

    # Get current time and cache file modification time in seconds since epoch
    current_time=$(date +%s)
    apt_cache_age=$(stat -c %Y "${cache_file}")

    # If cache is older than 1 hour (3600 seconds), needs update
    if (( current_time - apt_cache_age > 3600 )); then
        return 0
    else
        return 1
    fi
}

# Update apt cache if needed
function update_apt_cache() {
    if needs_apt_update; then
        status_msg "Updating apt cache..."
        if ! sudo apt-get update -qq 2>/dev/null; then
            warning_msg "Failed to update apt cache. Package version checks may be inaccurate." >&2
            return 1
        fi
        success_msg "Apt cache updated successfully."
    else
        status_msg "Apt cache is up to date."
    fi
    return 0
}

# ╠═══════════════════════════╣ PACKAGE CHECKS ╠══════════════════════════╣
# Check if packages are installed and set associated puppet mode
function check_packages_installed() {
    local has_server has_agent status

    # Check if puppet is installed and available
    if command -v puppet >/dev/null 2>&1; then
        has_server=$(dpkg -l | grep -q puppetserver && echo true || echo false)
        has_agent=$(dpkg -l | grep -q puppet-agent && echo true || echo false)

        if [[ "${has_server}" == "true" && "${has_agent}" == "true" ]]; then # Server and Agent installed
            info_msg "Server and Agent packages detected. Device will operate in 'Server/Agent' mode."
            status="Server/Agent"
            PUPPET_SERVER_VER=$(dpkg -l puppetserver | awk '/^ii/ {print $3}' | cut -d'-' -f1)
            PUPPET_AGENT_VER=$(dpkg -l puppet-agent | awk '/^ii/ {print $3}' | cut -d'-' -f1)
        elif [[ "${has_server}" == "true" && "${has_agent}" == "false" ]]; then # Server only installed
            info_msg "Server package detected. Device will operate in 'Server only' mode."
            status="Server only"
            PUPPET_SERVER_VER=$(dpkg -l puppetserver | awk '/^ii/ {print $3}' | cut -d'-' -f1)
            PUPPET_AGENT_VER="N/A"
            PUPPET_AGENT_VER_STATUS="none"
        elif [[ "${has_server}" == "false" && "${has_agent}" == "true" ]]; then # Agent only installed
            info_msg "Agent package detected. Device will operate in 'Agent only' mode."
            status="Agent only"
            PUPPET_AGENT_VER=$(dpkg -l puppet-agent | awk '/^ii/ {print $3}' | cut -d'-' -f1)
            PUPPET_SERVER_VER="N/A"
            PUPPET_SERVER_VER_STATUS="none"
        fi
    else
        status_msg "Puppet is not installed or not available. It can be installed from the 'Install' menu."
        status="Not installed"
        PUPPET_SERVER_VER="N/A"
        PUPPET_AGENT_VER="N/A"
        PUPPET_SERVER_VER_STATUS="none"
        PUPPET_AGENT_VER_STATUS="none"
    fi

    # Set puppet mode variable for use in menu_main.sh
    PUPPET_MODE="${status}"
}

# Get package versions and check for updates
function check_package_versions() {
    local server_ver agent_ver
    local -A versions=()

    # Get installed versions and determine device mode
    check_packages_installed

    # Update apt cache first if needed
    update_apt_cache

    # Get latest available versions if they are installed
    if [[ "${PUPPET_SERVER_VER}" != "N/A" ]]; then
        LATEST_SERVER_VER=$(sudo apt-cache policy puppetserver 2>/dev/null | awk '/Candidate:/ {print $2}' | cut -d'-' -f1 || echo "")
    fi

    if [[ "${PUPPET_AGENT_VER}" != "N/A" ]]; then
        LATEST_AGENT_VER=$(sudo apt-cache policy puppet-agent 2>/dev/null | awk '/Candidate:/ {print $2}' | cut -d'-' -f1 || echo "")
    fi


    # Set update status variables for use in menu_main.sh
    if [[ "${LATEST_SERVER_VER}" == "${PUPPET_SERVER_VER}" ]]; then
        PUPPET_SERVER_VER_STATUS="current"
    elif [[ "${LATEST_SERVER_VER}" > "${PUPPET_SERVER_VER}" ]]; then
        PUPPET_SERVER_VER_STATUS="outdated"
    else
        PUPPET_SERVER_VER_STATUS="unknown"
        warning_msg "Could not determine latest Puppet Server version. Version status may be inaccurate." >&2
    fi

    if [[ "${LATEST_AGENT_VER}" == "${PUPPET_AGENT_VER}" ]]; then
        PUPPET_AGENT_VER_STATUS="current"
    elif [[ "${LATEST_AGENT_VER}" > "${PUPPET_AGENT_VER}" ]]; then
        PUPPET_AGENT_VER_STATUS="outdated"
    else
        PUPPET_AGENT_VER_STATUS="unknown"
        warning_msg "Could not determine latest Puppet Agent version. Version status may be inaccurate." >&2
    fi
}
