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
clear -x

# make sure we have the correct permissions while running the script
umask 022

### sourcing all additional scripts
PAIN_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
for script in "${PAIN_DIR}/scripts/"*.sh; do . "${script}"; done
for script in "${PAIN_DIR}/scripts/ui/"*.sh; do . "${script}"; done

#===================================================#
#=================== UPDATE PAIN ===================#
#===================================================#

function update_pain() {
  cd "${PAIN_DIR}" || return

  # Check if we're on the default branch
  local current_branch
  current_branch=$(git branch --show-current)
  if [[ "${current_branch}" != "main" ]]; then
    status_msg "Cannot update: You are on branch '${current_branch}' instead of 'main'"
    return 1
  fi

  # Quietly pull updates (only occurs if on default branch)
  if git pull -q origin main; then
    ok_msg "PAIN updated successfully. Please relaunch."
    exit 0
  else
    error_msg "Failed to update PAIN"
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
# check_if_ratos
# check_euid
# init_logfile
get_pain_version
splash_screen
main_menu
