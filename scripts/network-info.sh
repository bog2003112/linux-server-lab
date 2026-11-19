#!/usr/bin/env bash

set -uo pipefail

status=0

print_section() {
    printf '\n========================================\n'
    printf '  %s\n' "$1"
    printf '========================================\n'
}

print_section "NETWORK INTERFACES"
if command -v ip >/dev/null 2>&1; then
    ip -brief address || status=1
else
    printf 'ERROR: ip command is not installed.\n'
    status=1
fi

print_section "ROUTING TABLE"
if command -v ip >/dev/null 2>&1; then
    ip route show || status=1

    printf '\nDefault gateway:\n'
    default_route="$(ip route show default 2>/dev/null || true)"
    if [[ -n "$default_route" ]]; then
        printf '%s\n' "$default_route"
    else
        printf 'No default route found.\n'
        status=1
    fi
else
    printf 'Routing information unavailable: ip command not found.\n'
    status=1
fi

print_section "DNS CONFIGURATION"
if command -v resolvectl >/dev/null 2>&1; then
    resolvectl dns || {
        printf 'Could not read DNS configuration with resolvectl.\n'
        status=1
    }
elif [[ -r /etc/resolv.conf ]]; then
    awk '/^[[:space:]]*nameserver[[:space:]]+/ { print }' /etc/resolv.conf
else
    printf 'DNS configuration file is unavailable.\n'
    status=1
fi

print_section "CONNECTIVITY"
if command -v ping >/dev/null 2>&1; then
    if ping -c 2 -W 2 1.1.1.1 >/dev/null 2>&1; then
        printf 'Internet connectivity: AVAILABLE (1.1.1.1 responds to ICMP)\n'
    else
        printf 'Internet connectivity: CHECK FAILED (ICMP test to 1.1.1.1 failed)\n'
        status=1
    fi
else
    printf 'Internet connectivity: NOT CHECKED (ping command not found)\n'
    status=1
fi

if command -v getent >/dev/null 2>&1; then
    if getent ahosts github.com >/dev/null 2>&1; then
        printf 'DNS resolution: OK (github.com)\n'
    else
        printf 'DNS resolution: FAILED (github.com)\n'
        status=1
    fi
else
    printf 'DNS resolution: NOT CHECKED (getent command not found)\n'
    status=1
fi

printf '\n========================================\n'
if (( status == 0 )); then
    printf '  NETWORK DIAGNOSTICS COMPLETED: OK\n'
else
    printf '  NETWORK DIAGNOSTICS COMPLETED: ISSUES FOUND\n'
fi
printf '========================================\n'

exit "$status"
