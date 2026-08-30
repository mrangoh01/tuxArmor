#!/usr/bin/env bash

# ==============================================================================
# File        : lib/logger.sh
# Description : Logging handlers (pass, warn, fail, info) with async spinner
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Test Counters & Config
# ------------------------------------------------------------------------------
TOTAL_TESTS=0
PASSED_TESTS=0
WARN_TESTS=0
FAILED_TESTS=0

# Array for JSON report
declare -a AUDIT_RESULTS

SPINNER_PID=""
STEP_DELAY=0.4

# ------------------------------------------------------------------------------
# 2. Functions
# ------------------------------------------------------------------------------
log_running() {
    local id="$1"
    #local msg="Scanning"

    stop_spinner

    tput civis 2>/dev/null || true

    (
        local spinner_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
        local i=0
        while true; do
            printf "\r\033[K${COLOR_CYAN}[RUNNING]${NC} [${id}] %s" "${spinner_chars[i]}"
            i=$(( (i + 1) % ${#spinner_chars[@]} ))
            sleep 0.08
        done
    ) &
    
    SPINNER_PID=$!
}

stop_spinner() {
    if [[ -n "$SPINNER_PID" ]] && kill -0 "$SPINNER_PID" 2>/dev/null; then
        kill -9 "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
        printf "\r\033[K"
    fi
}

log_pass() {
    local id="$1"
    local msg="$2"
    
    sleep "$STEP_DELAY"
    stop_spinner

    printf "\r\033[K${COLOR_GREEN}[ PASS ]${NC}  [${id}] ${msg}\n"
    tput cnorm 2>/dev/null || true

    (( ++TOTAL_TESTS ))
    (( ++PASSED_TESTS ))

    AUDIT_RESULTS+=("{\"id\":\"$id\",\"status\":\"PASS\",\"msg\":\"$msg\"}")
}

log_warn() {
    local id="$1"
    local msg="$2"

    sleep "$STEP_DELAY"
    stop_spinner

    printf "\r\033[K${COLOR_YELLOW}[ WARN ]${NC}  [${id}] ${msg}\n"
    tput cnorm 2>/dev/null || true

    (( ++TOTAL_TESTS ))
    (( ++WARN_TESTS ))

    AUDIT_RESULTS+=("{\"id\":\"$id\",\"status\":\"WARN\",\"msg\":\"$msg\"}")
}

log_fail() {
    local id="$1"
    local msg="$2"

    sleep "$STEP_DELAY"
    stop_spinner

    printf "\r\033[K${COLOR_RED}[ FAIL ]${NC}  [${id}] ${msg}\n"
    tput cnorm 2>/dev/null || true
    
    (( ++TOTAL_TESTS ))
    (( ++FAILED_TESTS ))
    
    AUDIT_RESULTS+=("{\"id\":\"$id\",\"status\":\"FAIL\",\"msg\":\"$msg\"}")
}

log_info() {
    stop_spinner
    # اصلاح ۳: تصحیح tput cnorm
    tput cnorm 2>/dev/null || true
    local msg="$1"
    printf "${COLOR_BLUE}[ INFO ]${NC}  %s\n" "$msg"
}