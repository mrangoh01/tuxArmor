#!/usr/bin/env bash

# ==============================================================================
# File        : modules/01_user_auth.sh
# Description : Security checks for Users and Auth mechanisms.
# ==============================================================================

audit_user_auth () {
    # --------------------------------------------------------------------------
    # 1. UID!=0 Cehck for users
    # --------------------------------------------------------------------------
    local non_root_zero_uid
    non_root_zero_uid=$(awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd)

    if [[ -z "$non_root_zero_uid" ]]; then
        log_running "AUTH-01"
        sleep 0.5
        log_pass "AUTH-01" "Only 'root' has UID 0."
    else
        log_running "AUTH-01"
        sleep 0.5
        log_fail "AUTH-01" "Unauthorized UID 0 accounts found: ${non_root_zero_uid}"
    fi

    # --------------------------------------------------------------------------
    # 2. Psswordless accounts in /etc/shadow
    # --------------------------------------------------------------------------
    local empty_pass_users
    empty_pass_users=$(awk -F: '($2 == "" || $2 == "!") { next } $2 == "" { print $1 }' /etc/shadow 2>/dev/null)

    if [[ -z "$empty_pass_users" ]]; then
        log_running "AUTH-02"
        sleep 0.5
        log_pass "AUTH-02" "No accounts with empty passwords found."
    else
        log_running "AUTH-02"
        sleep 0.5
        log_fail "AUTH-02" "Accounts with empty passwords detected: ${empty_pass_users}"
    fi

    # --------------------------------------------------------------------------
    # 3./etc/shadow & /etc/passwd
    # --------------------------------------------------------------------------

    if [[ -f /etc/shadow ]]; then
        local shadow_perms
        shadow_perms=$(stat -c "%a" /etc/shadow)
        if [[ "$shadow_perms" == "0000" || "$shadow_perms" == "000" || "$shadow_perms" == "600" || "$shadow_perms" == "0600" ]]; then
            log_running "AUTH-03.1"
            sleep 0.5
            log_pass "AUTH-03.1" "/etc/shadow permissions are secure (${shadow_perms})."
        else
            log_running "AUTH-03.1"
            sleep 0.5
            log_fail "AUTH-03.1" "/etc/shadow permissions are overly permissive (${shadow_perms})."
        fi
    else
        log_running "AUTH-03.1"
        sleep 0.5
        log_warn "AUTH-03.1" "/etc/shadow file not found on this system."
    fi

   if [[ -f /etc/passwd ]]; then
       local passwd_perms
       passwd_perms=$(stat -c "%a" /etc/passwd)
       if [[ "$passwd_perms" == "0000" || "$passwd_perms" == "000" || "$passwd_perms" == "600" || "$passwd_perms" == "0600" ]]; then
           log_running "AUTH-03.2"
           sleep 0.5
           log_pass "AUTH-03.2" "/etc/passwd permissions are secure (${passwd_perms})."
       else
           log_running "AUTH-03.2"
           sleep 0.5
           log_fail "AUTH-03.2" "/etc/passwd permissions are overly permissive (${passwd_perms})."
       fi
    else
       log_running "AUTH-03.2"
       sleep 0.5
       log_warn "AUTH-03.2" "/etc/passwd file not found on this system."
    fi
    
    # --------------------------------------------------------------------------
    # 4.PASS_MAX_DAYS
    # --------------------------------------------------------------------------

    if [[ -f /etc/login.defs ]]; then
        local max_days
        max_days=$(grep -E '^PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}')

        if [[ -n "$max_days" && "$max_days" -le 90 ]]; then
            log_running "AUTH-04"
            sleep 0.5
            log_pass "AUTH-04" "PASS_MAX_DAYS is properly configured (${max_days} days)."
        else
            log_running "AUTH-04"
            sleep 0.5
            log_warn "AUTH-04" "PASS_MAX_DAYS is high or unconfigured (${max_days:-Not set} days). Recommended <= 90."
        fi
    fi
}
