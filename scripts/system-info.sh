#!/usr/bin/env bash

set -Eeuo pipefail

print_section() {
    printf '\n========================================\n'
    printf '  %s\n' "$1"
    printf '========================================\n'
}

print_section "OPERATING SYSTEM"
if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf 'OS: %s\n' "${PRETTY_NAME:-Unknown}"
else
    printf 'OS: information unavailable\n'
fi
printf 'Hostname: %s\n' "$(hostname)"
printf 'Kernel: %s\n' "$(uname -r)"
printf 'Architecture: %s\n' "$(uname -m)"

print_section "UPTIME"
uptime

print_section "CPU"
if command -v lscpu >/dev/null 2>&1; then
    lscpu | awk -F: '
        /^(Architecture|CPU\(s\)|Model name):/ {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
            printf "%s: %s\n", $1, $2
        }
    '
else
    printf 'Logical CPU cores: %s\n' "$(nproc)"
fi

print_section "MEMORY"
free -h

print_section "ROOT FILESYSTEM"
df -hT /

printf '\nSystem information collection completed.\n'
