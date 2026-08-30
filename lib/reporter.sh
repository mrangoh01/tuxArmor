#!/usr/bin/env bash

# ==============================================================================
# File        : lib/reporter.sh
# Description : Score calculation, console summary, and JSON report generator.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Calculate Compliance Score
# ------------------------------------------------------------------------------
calculate_score() {
    COMPLIANCE_SCORE=0
    local valid_tests=$(( TOTAL_TESTS - WARN_TESTS ))

    if [[ $valid_tests -gt 0 ]]; then
        COMPLIANCE_SCORE=$(( (PASSED_TESTS * 100) / valid_tests ))
    fi
}

# ------------------------------------------------------------------------------
# 2. Display Console Summary
# ------------------------------------------------------------------------------
generate_summary() {
    calculate_score
    
    echo -e "\n=================================================="
    echo -e "       ${APP_NAME} v${APP_VERSION} - Audit Summary"
    echo -e "=================================================="
    echo -e " Target OS       : ${OS_NAME} ${OS_VERSION}"
    echo -e " Total Checks    : ${TOTAL_TESTS}"
    echo -e " Passed Checks   : ${COLOR_GREEN}${PASSED_TESTS}${NC}"
    echo -e " Failed Checks   : ${COLOR_RED}${FAILED_TESTS}${NC}"
    echo -e " Warnings        : ${COLOR_YELLOW}${WARN_TESTS}${NC}"
    echo -e " Compliance Score: ${COLOR_BLUE}${COMPLIANCE_SCORE}%${NC}"
    echo -e "==================================================\n"
}

# ------------------------------------------------------------------------------
# 3. Export JSON Report
# ------------------------------------------------------------------------------
export_json() {
    calculate_score

    #Json report generation
    cat <<EOF >> "$REPORT_JSON"
{
  "app": "$APP_NAME",
  "version": "$APP_VERSION",
  "timestamp": "$(date +"%Y-%m-%dT%H:%M:%SZ")",
  "target_os": "$OS_NAME $OS_VERSION",
  "metrics": {
    "total": $TOTAL_TESTS,
    "passed": $PASSED_TESTS,
    "warnings": $WARN_TESTS,
    "failed": $FAILED_TESTS,
    "score_percentage": $COMPLIANCE_SCORE
  },
  "results": [
EOF
    # AUDIT_RESULTS defined in lib/logger.sh
    local count=${#AUDIT_RESULTS[@]}
    for (( i=0; i<count; i++ )); do
        if [[ $i -eq $((count - 1)) ]]; then
            echo "    ${AUDIT_RESULTS[$i]}" >> "$REPORT_JSON"
        else
            echo "    ${AUDIT_RESULTS[$i]}," >> "$REPORT_JSON"
        fi
    done

    cat <<EOF >> "$REPORT_JSON"
  ]
}
EOF

    echo -e "${COLOR_CYAN}JSON report successfully exported to: ${REPORT_JSON}"
}