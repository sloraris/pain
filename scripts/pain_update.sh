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
#================= UPDATE CHECKING =================#
#===================================================#

function check_pain_update() {
  # Set the current version first
  set_pain_version

  status_msg "Checking for updates..."

  # Fetch updates quietly
  git -C "${PAIN_DIR}" fetch -q origin main 2>/dev/null

  # Get latest version from remote, using only direct tag references
  local latest_ver
  if [[ "${PAIN_VERSION}" == *"-dev"* ]]; then
    # If current version is dev, look for latest dev version
    latest_ver=$(git -C "${PAIN_DIR}" ls-remote --refs --tags origin | grep -- "-dev$" | cut -d'/' -f3 | sort -V | tail -n1)
  else
    # If current version is release, look for latest release version
    latest_ver=$(git -C "${PAIN_DIR}" ls-remote --refs --tags origin | grep -v -- "-dev" | cut -d'/' -f3 | sort -V | tail -n1)
  fi

  # If versions are different and latest is not empty, prompt for update
  if [[ -n "${latest_ver}" && "${PAIN_VERSION}" != "${latest_ver}" ]]; then
    pain_update_prompt "${PAIN_VERSION}" "${latest_ver}"
  fi

  # If no new version is available, notify and continue
  if [[ "${PAIN_VERSION}" == "${latest_ver}" ]]; then
    success_msg "You are running the latest version of PAIN."
    PAIN_VERSION_FORMATTED="${GREEN}${PAIN_VERSION_FORMATTED}${NC}"
  fi
}

function pain_update_prompt() {
  local current_ver="$1"
  local latest_ver="$2"

  info_msg "There is a new version of PAIN available."
  info_msg "Current version: ${current_ver}"
  info_msg "Latest version:  ${latest_ver}"
  read -p "Would you like to update PAIN? [y/N] " -n 1 -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    update_pain
  else
    echo
    warning_msg "PAIN will not be updated. You may be missing out on new features and bug fixes."
    PAIN_VERSION_FORMATTED="${YELLOW}${PAIN_VERSION_FORMATTED}${NC}"
  fi
}

function update_pain() {
  cd "${PAIN_DIR}" || return

  status_msg "Updating PAIN..."

  # Check if we're on the default branch
  local current_branch
  current_branch=$(git branch --show-current)
  if [[ "${current_branch}" != "main" ]]; then
    warning_msg "Cannot update - You are on branch '${current_branch}' instead of 'main'"
    return 1
  fi

  # Fetch all updates including tags
  if ! git fetch --tags origin main; then
    error_msg "Failed to fetch updates."
    return 1
  fi

  # Quietly pull updates (only occurs if on default branch)
  if git pull -q origin main; then
  # Get the latest matching tag type (dev or release)
    local new_tag
    if [[ "${PAIN_VERSION}" == *"-dev"* ]]; then
      new_tag=$(git tag -l | grep -- "-dev$" | sort -V | tail -n1)
    else
      new_tag=$(git tag -l | grep -v -- "-dev" | sort -V | tail -n1)
    fi

    # Checkout the new tag if found
    if [[ -n "${new_tag}" ]]; then
      git checkout -q "${new_tag}"
      success_msg "Updated to version ${new_tag}"
    fi

    status_msg "Relaunching..."
    sleep 1  # Give user a chance to see the message
    # Get the absolute path of the main script
    local main_script
    main_script="${PAIN_DIR}/pain.sh"
    cd "${PAIN_DIR}" || exit 1
    exec "${main_script}" "$@"
  else
    error_msg "Failed to update PAIN."
    return 1
  fi
}
