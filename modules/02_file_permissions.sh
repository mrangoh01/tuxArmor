#!/usr/bin/env bash

# ==============================================================================
# File: modules/02_file_permissions.sh
# Description : Audits critical system files, SUID binaries, and /etc/fstab.
# ==============================================================================

audit_file_permissions() {
    # --------------------------------------------------------------------------
    # 1. Evaluation of perms for critical system files
    # --------------------------------------------------------------------------
    for filepath in "${!FILE_PERMS_BASELINE[@]}"; do    #FILE_PERMS_BASELINE defined in audit.conf
        if [[ -f "$filepath" ]]; then
            local expected_data=(${FILE_PERMS_BASELINE[$filepath]})
            local expected_perm="${expected_data[0]}"
            local expected_owner="${expected_data[1]}:${expected_data[2]}"

            local current_perm
            current_perm=$(stat -c "%a" "$filepath")
            local current_owner
            current_owner=$(stat -c "%U:%G" "$filepath")

            if [[ "$current_perm" -le "$expected_perm" && "$current_owner" == "$expected_owner" ]]; then
                log_running "PERM-01"
                log_pass "PERM-01" "Permissions for ${filepath} are secure (${current_perm}, ${current_owner})."
            else
                log_running "PERM-01"
                log_fail "PERM-01" "Insecure perms on ${filepath} (Got: ${current_perm} ${current_owner}, Expected: <=${expected_perm} ${expected_owner})."
            fi
        fi
    done

    # --------------------------------------------------------------------------
    # 2. SUID Check (except whitelist)
    # --------------------------------------------------------------------------
    log_info "Scanning system for non-whitelisted SUID binaries..."

    local suid_files
    suid_files=$(find /bin /usr/bin /sbin /usr/sbin -type f -perm -4000 2>/dev/null || true)
    local unknown_suid_count=0

    for file in $suid_files; do
        if [[ ! " ${SUID_WHITELIST[*]} " =~ " ${file} " ]]; then
            log_running "SUID-01"
            log_warn "SUID-01" "Non-whitelisted SUID binary detected: ${file}"
            (( ++unknown_suid_count ))
        fi
    done

    if [[ "$unknown_suid_count" -eq 0 ]]; then
        log_running "SUID-01"
        log_pass "SUID-01" "All detected SUID binaries match the baseline whitelist."
    fi

    # --------------------------------------------------------------------------
    # 3. Mountpoints in /etc/fstab
    # --------------------------------------------------------------------------
    log_info "Checking filesystem mount options in /etc/fstab..."
    local target_mounts=("/tmp" "/var/tmp" "/dev/shm")

    for mp in "${target_mounts[@]}"; do
        if grep -qs "[[:space:]]${mp}[[:space:]]" /etc/fstab; then
            log_running "FSTAB-01"
            log_pass "FSTAB-01" "Separate entry configured in /etc/fstab for ${mp}."
        
            #Option Checks(nodev, nosuid, noexec)
            for opt in "nodev" "nosuid" "noexec"; do
                if grep -E "[[:space:]]${mp}[[:space:]]" /etc/fstab | grep -qs "$opt"; then
                    log_running "FSTAB-02"
                    log_pass "FSTAB-02" "Option '$opt' is set in fstab for ${mp}."
                else
                    log_running "FSTAB-02"
                    log_warn "FSTAB-02" "Option '$opt' is MISSING in fstab for ${mp}!"
                fi
            done
        else
            log_running "FSTAB-01"
            log_warn "FSTAB-01" "No separate mount point entry found in /etc/fstab for ${mp}."
        fi
    done
}
