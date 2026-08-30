#!/usr/bin/env bash

# ==============================================================================
# File        : lib/utils.sh
# Description : OS detection, helper utilities.
# ==============================================================================

# This script needs to run as root( not toor:D )
check_root() {
    if [[ $EUID -ne 0 ]] ; then
        echo -e "\033[0;31m[CRITICAL] $APP_NAME must be run as root (or sudo).\033[0m" >&2
        exit 1
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=${VERSION_ID:-"Unknown version"}
    else
        OS_NAME=$(uname -s)
        OS_VERSION=$(uname -r)
    fi
}

# Create log files path(defined in config/audit.conf)
prepare_environment() {
    mkdir -p "$LOG_DIR"
    chmod 700 "$LOG_DIR"
}