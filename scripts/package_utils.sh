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

# ╠═══════════════════════╣ PACKAGE VERSION CHECKS ╠══════════════════════╣

# Get package versions and check for updates
function check_package_versions() {
    local server_ver agent_ver
    local -A versions=()

    # Update apt cache first if needed
    update_apt_cache

    # Get latest available versions with proper error handling
    versions["server_latest"]=$(sudo apt-cache policy puppetserver 2>/dev/null | awk '/Candidate:/ {print $2}' | cut -d'-' -f1 || echo "")
    versions["agent_latest"]=$(sudo apt-cache policy puppet-agent 2>/dev/null | awk '/Candidate:/ {print $2}' | cut -d'-' -f1 || echo "")

    # Get installed versions with proper error handling
    versions["server_installed"]=$(dpkg -l puppetserver 2>/dev/null | awk '/^ii/ {print $3}' | cut -d'-' -f1 || echo "")
    versions["agent_installed"]=$(dpkg -l puppet-agent 2>/dev/null | awk '/^ii/ {print $3}' | cut -d'-' -f1 || echo "")

    # Export variables for use in menu_main.sh
    if [[ -z "${versions[server_latest]}" ]]; then
        export LATEST_SERVER_VER="unknown"
        warning_msg "Could not determine latest Puppet Server version" >&2
    else
        export LATEST_SERVER_VER="${versions[server_latest]}"
    fi

    if [[ -z "${versions[agent_latest]}" ]]; then
        export LATEST_AGENT_VER="unknown"
        warning_msg "Could not determine latest Puppet Agent version" >&2
    else
        export LATEST_AGENT_VER="${versions[agent_latest]}"
    fi

    # Export installed versions for menu_main.sh
    if [[ -n "${versions[server_installed]}" ]]; then
        export INSTALLED_SERVER_VER="${versions[server_installed]}"
    else
        export INSTALLED_SERVER_VER="N/A"
    fi

    if [[ -n "${versions[agent_installed]}" ]]; then
        export INSTALLED_AGENT_VER="${versions[agent_installed]}"
    else
        export INSTALLED_AGENT_VER="N/A"
    fi

    # Return success only if we got both latest versions
    if [[ "${LATEST_SERVER_VER}" != "unknown" && "${LATEST_AGENT_VER}" != "unknown" ]]; then
        return 0
    else
        warning_msg "Could not determine latest Puppet Server or Agent version" >&2
        return 1
    fi
}
