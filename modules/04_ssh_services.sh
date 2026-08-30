#!/usr/bin/env bash
# ==============================================================================
# File        : modules/04_ssh_services.sh
# Description : Audits OpenSSH daemon security configurations (sshd_config).
# ==============================================================================

audit_ssh_services() {

    local sshd_config="/etc/ssh/sshd_config"

    if [[ ! -f "$sshd_config" ]]; then
        log_running "SSH-00"
        log_warn "SSH-00" "OpenSSH server config (${sshd_config}) not found on this system."
        return 0
    fi

    # --------------------------------------------------------------------------
    # 1.Check PermitRootLogin
    # --------------------------------------------------------------------------
    local root_login
    root_login=$(grep -iE '^[[:space:]]*PermitRootLogin' "$sshd_config" /etc/ssh/sshd_confg.d/*.conf 2>/dev/null | awk '{print $2}' | tail -n1 || true)

    if [[ "${root_login,,}" == "no" ]]; then
        log_running "SSH-01"
        log_pass "SSH-01" "Direct Root SSH login is explicitly disabled (PermitRootLogin no)."
    else
        log_running "SSH-01"
        log_fail "SSH-01" "Direct Root SSH login is ENABLED or insecurely set (${root_login:-default yes})."
    fi

    # --------------------------------------------------------------------------
    # 2.Check PasswordAuthentication
    # --------------------------------------------------------------------------
    local pass_auth
    pass_auth=$(grep -iE '^[[:space:]]*PasswordAuthentication' "$sshd_config" /etc/ssh/sshd_config.d/*.conf 2>/dev/null | awk '{print $2}' | tail -n1 || true)
    
    if [[ "${pass_auth,,}" == "no" ]]; then
        log_running "SSH-02"
        log_pass "SSH-02" "Password authentication is disabled (Keys enforced)."
    else
        log_running "SSH-02"
        log_warn "SSH-02" "Password authentication is enabled (${pass_auth:-default yes}). SSH keys recommended."
    fi

    # --------------------------------------------------------------------------
    # 3.Check the MaxAuthTries
    # --------------------------------------------------------------------------
    local max_tries
    max_tries=$(grep -iE '^[[:space:]]*MaxAuthTries' "$sshd_config" /etc/ssh/sshd_config.d/*.conf 2>/dev/null | awk '{print $2}' | tail -n1 || true)

    if [[ -n "$max_tries" && "$max_tries" -le 4 ]]; then
        log_running "SSH-03"
        log_pass "SSH-03" "MaxAuthTries is securely configured (${max_tries})."
    else
        log_running "SSH-03"
        log_warn "SSH-03" "MaxAuthTries is high or unconfigured (${max_tries:-default 6}). Recommended <= 4."
    fi

    # --------------------------------------------------------------------------
    # 4.Check X11Forwarding
    # --------------------------------------------------------------------------
    local x11_fwd
    x11_fwd=$(grep -iE '^[[:space:]]*X11Forwarding' "$sshd_config" /etc/ssh/sshd_config.d/*.conf 2>/dev/null | awk '{print $2}' | tail -n1 || true)

    if [[ "${x11_fwd,,}" == "no" ]]; then
        log_running "SSH-04"
        log_pass "SSH-04" "X11Forwarding is disabled."
    else
        log_running "SSH-04"
        log_warn "SSH-04" "X11Forwarding is enabled (${x11_fwd:-default yes}). Disable if GUI is not needed."
    fi
}
