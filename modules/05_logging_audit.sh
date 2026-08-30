#!/usr/bin/env bash
# ==============================================================================
# File        : modules/05_logging_audit.sh
# Description : Audits system logging services (auditd, rsyslog) and log file security.
# ==============================================================================

audit_logging() {
    # --------------------------------------------------------------------------
    # 1.Check auditd activation
    # --------------------------------------------------------------------------
    if systemctl is-active --quiet auditd 2>/dev/null; then
        log_running "LOG-01"
        log_pass "LOG-01" "auditd service is active and running."
    else
        log_running "LOG-01"
        log_fail "LOG-01" "auditd service is NOT running! Kernel security event auditing is disabled."
    fi

    # --------------------------------------------------------------------------
    # 2.Check syslog activation (journalctl or rsyslog)
    # --------------------------------------------------------------------------
    if systemctl is-active --quiet rsyslog 2>/dev/null || systemctl is-active --quiet systemd-journald 2>/dev/null; then
        log_running "LOG-02"
        log_pass "LOG-02" "System syslog daemon (rsyslog/journald) is active."
    else
        log_running "LOG-02"
        log_warn "LOG-02" "No active syslog daemon detected (rsyslog and journald are inactive)."
    fi

    # --------------------------------------------------------------------------
    # 3.Check permissions of /var/log/*
    # --------------------------------------------------------------------------
    local critical_log_files=("/var/log/syslog" "/var/log/messages" "/var/log/auth.log" "/var/log/secure")
    local insecure_log_count=0

    for logfile in "${critical_log_files[@]}"; do
        if [[ -f "$logfile" ]]; then
            local log_perm
            log_perm=$(stat -c "%a" "$log_file")

            local others_perm="${log_perm: -1}"
            if [[ "$others_perm" -eq 0 || "$others_perm" -eq 4 ]]; then
                log_running "LOG-03"
                log_pass "LOG-03" "Permissions for ${logfile} are secure (${log_perm})."
            else
                log_running "LOG-03"
                log_fail "LOG-03" "Insecure permissions on ${logfile} (${log_perm}). World-writable or overly open!"
                (( ++insecure_log_count ))
            fi
        fi
    done

    # --------------------------------------------------------------------------
    # 4.Check config of failed sudo's commands
    # --------------------------------------------------------------------------
    if grep -qs -E '^[[:space:]]*Defaults[[:space:]]+logfile=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        log_running "LOG-04"
        log_pass "LOG-04" "Dedicated sudo execution logfile is configured."
    else
        log_running "LOG-04"
        log_warn "LOG-04" "Custom sudo logfile not defined (relying on default syslog)."
    fi
}
