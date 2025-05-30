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


# ╠════════════════════════╣ SCRIPT PERMISSIONS ╠═════════════════════════╣
function ensure_script_permissions() {
    local main_script="${PAIN_DIR}/pain.sh"
    local update_script="${PAIN_DIR}/scripts/pain_update.sh"

    # Check if scripts are executable
    if [[ ! -x "${main_script}" ]] || [[ ! -x "${update_script}" ]]; then
        warning_msg "Script permissions are not set correctly. Attempting to fix..."
        chmod +x "${main_script}" "${update_script}" 2>/dev/null || {
            error_msg "Failed to set executable permissions on scripts." >&2
            info_msg "Please run the following command to fix the permissions:"
            info_msg "chmod +x pain.sh"
            exit 1
        }
        success_msg "Script permissions have been corrected."
    fi
}

# ╠══════════════════════════╣ SUDO MANAGEMENT ╠══════════════════════════╣
function check_euid() {
    if [[ $EUID -eq 0 ]]; then
        error_msg "This script should not be run directly as root. Please run as a normal user with sudo privileges instead." >&2
        exit 1
    fi
}

function ensure_sudo() {
    warning_msg "This script requires sudo privileges."
    info_header_msg "Sudo will be used to perform the following puppet-related tasks:"
    info_msg "- install/remove packages"
    info_msg "- manage services"
    info_msg "- handle system files (install/remove modules, manifests, etc.)"
    warning_msg "Please enter your sudo password to continue."

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

# ╠════════════════════════════╣ PAIN VERSION ╠═══════════════════════════╣

function set_pain_version() {
  local version="unknown"

  if [[ -d "${PAIN_DIR}/.git" ]]; then
    cd "${PAIN_DIR}" || return

    if git rev-parse --git-dir > /dev/null 2>&1; then
      # Get the most recent tag directly
      version=$(git describe --tags --abbrev=0 2>/dev/null)

      # Ensure version doesn't exceed 16 chars
      if [[ ${#version} -gt 16 ]]; then
        version="${version:0:16}"
      fi
    fi
  fi

  # Export the raw version for other functions to use
  PAIN_VERSION="${version}"
}

# ╠════════════════════════════╣ MAIN SCRIPT ╠════════════════════════════╣

# Check EUID to prevent running as root
check_euid

# Check script permissions before anything else
ensure_script_permissions

# Show splash screen first so user sees what they're running
splash_screen

# Check for updates (this will also set the version)
check_pain_update

# Ensure sudo access
ensure_sudo

# Continue with the rest of initialization
check_package_versions

# Enter main menu
clear -x
main_menu
