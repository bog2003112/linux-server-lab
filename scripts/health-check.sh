#!/usr/bin/env bash

set -uo pipefail

DISK_WARN_THRESHOLD="${DISK_WARN_THRESHOLD:-80}"
DISK_CRIT_THRESHOLD="${DISK_CRIT_THRESHOLD:-90}"
MEMORY_WARN_THRESHOLD="${MEMORY_WARN_THRESHOLD:-80}"
MEMORY_CRIT_THRESHOLD="${MEMORY_CRIT_THRESHOLD:-90}"
PING_TARGET="${PING_TARGET:-1.1.1.1}"
DNS_TARGET="${DNS_TARGET:-github.com}"

status=0

print_section() {
    printf '\n========================================\n'
    printf '  %s\n' "$1"
    printf '========================================\n'
}

record_status() {
    local new_status="$1"
    if (( new_status > status )); then
        status="$new_status"
    fi
}

validate_thresholds() {
    local name value

    for name in \
        DISK_WARN_THRESHOLD DISK_CRIT_THRESHOLD \
        MEMORY_WARN_THRESHOLD MEMORY_CRIT_THRESHOLD; do
        value="${!name}"

        if [[ ! "$value" =~ ^[0-9]+$ ]]; then
            printf 'ERROR: %s must be an integer between 1 and 100.\n' "$name" >&2
            return 1
        fi

        value="${value#"${value%%[!0]*}"}"
        value="${value:-0}"

        if (( ${#value} > 3 )); then
            printf 'ERROR: %s must be an integer between 1 and 100.\n' "$name" >&2
            return 1
        fi

        value=$((10#$value))

        if (( value < 1 || value > 100 )); then
            printf 'ERROR: %s must be an integer between 1 and 100.\n' "$name" >&2
            return 1
        fi

        printf -v "$name" '%s' "$value"
    done

    if (( DISK_WARN_THRESHOLD >= DISK_CRIT_THRESHOLD )); then
        printf 'ERROR: disk warning threshold must be lower than critical threshold.\n' >&2
        return 1
    fi

    if (( MEMORY_WARN_THRESHOLD >= MEMORY_CRIT_THRESHOLD )); then
        printf 'ERROR: memory warning threshold must be lower than critical threshold.\n' >&2
        return 1
    fi

    return 0
}

print_section "SERVER HEALTH CHECK"

if ! validate_thresholds; then
    exit 3
fi

print_section "DISK USAGE"
disk_usage="$(df -P / 2>/dev/null | awk 'NR == 2 { gsub(/%/, "", $5); print $5 }')"

if [[ "$disk_usage" =~ ^[0-9]+$ ]]; then
    if (( disk_usage >= DISK_CRIT_THRESHOLD )); then
        printf 'CRITICAL: root filesystem usage is %s%% (threshold: %s%%).\n' \
            "$disk_usage" "$DISK_CRIT_THRESHOLD"
        record_status 2
    elif (( disk_usage >= DISK_WARN_THRESHOLD )); then
        printf 'WARNING: root filesystem usage is %s%% (threshold: %s%%).\n' \
            "$disk_usage" "$DISK_WARN_THRESHOLD"
        record_status 1
    else
        printf 'OK: root filesystem usage is %s%%.\n' "$disk_usage"
    fi
else
    printf 'UNKNOWN: could not determine root filesystem usage.\n'
    record_status 3
fi

print_section "MEMORY USAGE"
if command -v free >/dev/null 2>&1; then
    memory_usage="$(free | awk '/^Mem:/ { if ($2 > 0) printf "%.0f", ($3 / $2) * 100 }')"
else
    memory_usage=""
fi

if [[ "$memory_usage" =~ ^[0-9]+$ ]]; then
    if (( memory_usage >= MEMORY_CRIT_THRESHOLD )); then
        printf 'CRITICAL: RAM usage is %s%% (threshold: %s%%).\n' \
            "$memory_usage" "$MEMORY_CRIT_THRESHOLD"
        record_status 2
    elif (( memory_usage >= MEMORY_WARN_THRESHOLD )); then
        printf 'WARNING: RAM usage is %s%% (threshold: %s%%).\n' \
            "$memory_usage" "$MEMORY_WARN_THRESHOLD"
        record_status 1
    else
        printf 'OK: RAM usage is %s%%.\n' "$memory_usage"
    fi
else
    printf 'UNKNOWN: could not determine memory usage.\n'
    record_status 3
fi

print_section "NETWORK CONNECTIVITY"
if ! command -v ping >/dev/null 2>&1; then
    printf 'UNKNOWN: ping command not found.\n'
    record_status 3
elif ping -c 2 -W 2 "$PING_TARGET" >/dev/null 2>&1; then
    printf 'OK: %s responds to ICMP.\n' "$PING_TARGET"
else
    printf 'CRITICAL: connectivity check to %s failed.\n' "$PING_TARGET"
    record_status 2
fi

print_section "DNS RESOLUTION"
if ! command -v getent >/dev/null 2>&1; then
    printf 'UNKNOWN: getent command not found.\n'
    record_status 3
elif getent ahosts "$DNS_TARGET" >/dev/null 2>&1; then
    printf 'OK: DNS resolution works for %s.\n' "$DNS_TARGET"
else
    printf 'CRITICAL: DNS resolution failed for %s.\n' "$DNS_TARGET"
    record_status 2
fi

print_section "FINAL RESULT"
case "$status" in
    0) printf 'OVERALL STATUS: OK\n' ;;
    1) printf 'OVERALL STATUS: WARNING\n' ;;
    2) printf 'OVERALL STATUS: CRITICAL\n' ;;
    *) printf 'OVERALL STATUS: UNKNOWN\n' ;;
esac
printf 'Exit code: %s\n' "$status"

exit "$status"
