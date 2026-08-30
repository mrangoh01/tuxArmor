#!/usr/bin/env bash

# ==================================================================================================
# File        : modules/03_network_sec.sh
# Description : Check Firewall Status, Audits listening ports and Linux Kernel network parameters.
# ==================================================================================================

audit_network_services() {
    # --------------------------------------------------------------------------
    # 3.1 Firewall Status Check
    # --------------------------------------------------------------------------
    if command -v ufw &>/dev/null && ufw status | grep -qs "active"; then
        log_running "NET-01"
        log_pass "NET-01" "Firewall (UFW) is installed and active."
    elif command -v nft &>/dev/null && nft list ruleset | grep -qs "table"; then
        log_running "NET-01"
        log_pass "NET-01" "Firewall (NFTables) is active."
    elif command -v iptables &>/dev/null && iptables -L -n | grep -qs "Chain INPUT"; then
        log_running "NET-01"
        log_pass "NET-01" "Firewall (IPTables) rules are loaded."
    else
        log_running "NET-01"
        log_fail "NET-01" "No active host-based firewall detected!"
    fi

    # --------------------------------------------------------------------------
    # 3.2 Insecure Legacy Services
    # --------------------------------------------------------------------------
    local legacy_services=("telnet" "rsh" "tftp" "nis" "ftp")
    for srv in "${legacy_services[@]}"; do
        if systemctl is-active --quiet "$srv" 2>/dev/null; then
            log_running "NET-02"
            log_fail "NET-02" "Insecure legacy service is running: $srv"
        else
            log_running "NET-02"
            log_pass "NET-02" "Legacy service '$srv' is not running."
        fi
    done

    # --------------------------------------------------------------------------
    # 3.3 Publicly Listening Services
    # --------------------------------------------------------------------------
    local open_ports
    open_ports=$(ss -tulpn 2>/dev/null | grep LISTEN | grep "0.0.0.0:")
    if [[ -n "${open_ports}" ]]; then
        log_running "NET-03"
        log_warn "NET-03" "Services listening on all IPv4 interfaces (0.0.0.0) detected."
    else
        log_running "NET-03"
        log_pass "NET-03" "No unconstrained services listening on 0.0.0.0."
    fi

    # --------------------------------------------------------------------------
    # 3.4 Check ipv4 Forwarding
    # --------------------------------------------------------------------------
    if [[ -f /proc/sys/net/ipv4/ip_forward ]]; then
    local ip_fwd=$(sysctl -n net.ipv4.ip_forward 2>/dev/null || cat /proc/sys/net/ipv4/ip_forward)

        if [[ "$ip_fwd" -eq 0 ]]; then
            log_running "NET-04"
            log_pass "NET-04" "IPv4 Forwarding is disabled (net.ipv4.ip_forward = 0)."
        else
            log_running "NET-04"
            log_warn "NET-04" "IPv4 Forwarding is ENABLED (net.ipv4.ip_forward = ${ip_fwd})."
        fi
    fi

    # --------------------------------------------------------------------------
    # 3.5 Check TCP SYN Cookies
    # --------------------------------------------------------------------------
    if [[ -f /proc/sys/net/ipv4/tcp_syncookies ]]; then
        local syn_cookies
        syn_cookies=$(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null || cat /proc/sys/net/ipv4/tcp_syncookies)

        if [[ "$syn_cookies" -eq 1 ]]; then
            log_running "NET-05"
            log_pass "NET-05" "TCP SYN Cookies protection is enabled."
        else
            log_running "NET-05"
            log_fail "NET-05" "TCP SYN Cookies protection is DISABLED! Vulnerable to SYN Flood."
        fi
    fi
}
