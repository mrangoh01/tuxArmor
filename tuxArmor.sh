#!/usr/bin/env bash

# ==============================================================================
# File        : tuxArmor.sh
# Description : Main entry point for TuxArmor.
# ==============================================================================

set -euo pipefail

error_handler() {
    local exit_code=$?
    local line_number=$1
    echo -e "\033[0;31m[CRITICAL] Script crashed at line ${line_number} with exit code ${exit_code}!\033[0m" >&2
}
trap 'error_handler $LINENO' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export APP_NAME="TuxArmor"
export APP_VERSION="1.0.0"
export LOG_DIR="${SCRIPT_DIR}/logs"
export REPORT_JSON="${LOG_DIR}/audit_report.json"

export COLOR_RED="\033[0;31m"
export COLOR_GREEN="\033[0;32m"
export COLOR_YELLOW="\033[0;33m"
export COLOR_BLUE="\033[0;34m"
export COLOR_CYAN='\033[1;36m'
export NC="\033[0m"

# Import libraries
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/logger.sh"
source "${SCRIPT_DIR}/lib/reporter.sh"

# Modules Check
source "${SCRIPT_DIR}/modules/01_user_auth.sh"
source "${SCRIPT_DIR}/modules/02_file_permissions.sh"
source "${SCRIPT_DIR}/modules/03_network_services.sh"
source "${SCRIPT_DIR}/modules/04_ssh_services.sh"
source "${SCRIPT_DIR}/modules/05_logging_audit.sh"
source "${SCRIPT_DIR}/modules/06_kernel_sysctl.sh"

# ==============================================================================
# MAIN PIPLINE
# ==============================================================================

main() {
    #prerequests
    check_root
    detect_os
    prepare_environment

    log_info "Initiating ${APP_NAME} v${APP_VERSION} System Audit..."

    #execution
    echo -e "${COLOR_CYAN}=====STARTING USER-AUDIT MODULE=====${NC}"
    audit_user_auth
    echo -e "\n${COLOR_CYAN}=====STARTING FILE-PERMS MODULE=====${NC}"
    sleep 1;
    audit_file_permissions
    echo -e "\n${COLOR_CYAN}=====STARTING NETWORK-AUDIT MODULE=====${NC}"
    sleep 1;
    audit_network_services
    echo -e "\n${COLOR_CYAN}=====STARTING SSH-AUDIT MODULE=====${NC}"
    sleep 1;
    audit_ssh_services
    echo -e "\n${COLOR_CYAN}=====STARTING LOGGING-AUDIT MODULE=====${NC}"
    sleep 1;
    audit_logging
    echo -e "\n${COLOR_CYAN}=====STARTING KERNEL-AUDIT MODULE=====${NC}"
    sleep 1;
    audit_kernel_sysctl

    #report summary, json export, score calculation
    generate_summary
    export_json
}

echo -e "${COLOR_YELLOW}"
cat << 'EOF'
 _____               _                              
|_   _|   ___  __   / \   _ __ _ __ ___   ___  _ __ 
  | || | | \ \/ /  / _ \ | '__| '_ ` _ \ / _ \| '__|
  | || |_| |>  <  / ___ \| |  | | | | | | (_) | |   
  |_| \__,_/_/\_\/_/   \_\_|  |_| |_| |_|\___/|_|  V 1.0.0

Written By : https://github.com/mrangoh01
EOF
echo -e "${NC}\n"

main "$@"












