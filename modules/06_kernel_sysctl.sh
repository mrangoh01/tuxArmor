#!/usr/bin/env bash

# ==============================================================================
# File        : modules/06_kernel_sysctl.sh
# Description : Audits Linux Kernel security parameters via sysctl and procfs.
# ==============================================================================

audit_kernel_sysctl() {
    log_info "Starting Linux Kernel Hardening Audit..."

    # --------------------------------------------------------------------------
    # 1. ASLR Status Check (Address Space Layout Randomization)
    # --------------------------------------------------------------------------
    if [[ -f /proc/sys/kernel/randomize_va_space ]]; then
        local aslr_val
        aslr_val=$(sysctl -n kernel.randomize_va_space 2>/dev/null || cat /proc/sys/kernel/randomize_va_space)

        if [[ "$aslr_val" -eq 2 ]]; then
            log_running "SYSCTL-01"
            log_pass "SYSCTL-01" "ASLR is fully enabled (kernel.randomize_va_space = 2)."
        elif [[ "$aslr_val" -eq 1 ]]; then
            log_running "SYSCTL-01"
            log_warn "SYSCTL-01" "ASLR is only partially enabled (value: 1). Recommended: 2."
        else
            log_running "SYSCTL-01"
            log_fail "SYSCTL-01" "ASLR is DISABLED! System is highly vulnerable to memory exploits."
        fi
    fi

    # --------------------------------------------------------------------------
    # 2. ICMP Redirects deActivation Check
    # --------------------------------------------------------------------------
    if [[ -f /proc/sys/net/ipv4/conf/all/accept_redirects ]]; then
        local accept_redir
        accept_redir=$(sysctl -n net.ipv4.conf.all.accept_redirects 2>/dev/null || cat /proc/sys/net/ipv4/conf/all/accept_redirects)

        if [[ "$accept_redir" -eq 0 ]]; then
            log_running "SYSCTL-02"
            log_pass "SYSCTL-02" "ICMP Redirect acceptance is disabled (net.ipv4.conf.all.accept_redirects = 0)."
        else
            log_running "SYSCTL-02"
            log_fail "SYSCTL-02" "ICMP Redirect acceptance is ENABLED! Risk of MITM routing attacks."
        fi
    fi

    # --------------------------------------------------------------------------
    # 3. Reverse Path Filtering Activation Check
    # --------------------------------------------------------------------------
    if [[ -f /proc/sys/net/ipv4/conf/all/rp_filter ]]; then
        local rp_filter
        rp_filter=$(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null || cat /proc/sys/net/ipv4/conf/all/rp_filter)

        if [[ "$rp_filter" -eq 1 ]]; then
            log_running "SYSCTL-03"
            log_pass "SYSCTL-03" "Strict Reverse Path Filtering is enabled (rp_filter = 1)."
        else
            log_running "SYSCTL-03"
            log_warn "SYSCTL-03" "Strict RP Filtering is not enforced (rp_filter = ${rp_filter:-0})."
        fi
    fi

    # --------------------------------------------------------------------------
    # 4. dmesg Restriction Check
    # --------------------------------------------------------------------------
    if [[ -f /proc/sys/kernel/dmesg_restrict ]]; then
        local dmesg_res
        dmesg_res=$(sysctl -n kernel.dmesg_restrict 2>/dev/null || cat /proc/sys/kernel/dmesg_restrict)

        if [[ "$dmesg_res" -eq 1 ]]; then
           log_running "SYSCTL-04"
           log_pass "SYSCTL-04" "dmesg access is restricted to privileged users (dmesg_restrict = 1)."
        else
            log_running "SYSCTL-04"
            log_warn "SYSCTL-04" "dmesg log buffer is readable by unprivileged users (dmesg_restrict = 0)."
        fi
    fi 
}
