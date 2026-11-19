#!/usr/bin/env bash

set -uo pipefail

echo "=========================================="
echo "         NETWORK DIAGNOSTICS"
echo "=========================================="

echo ""
echo "[NETWORK INTERFACES]"
ip -br addr

echo ""
echo "[ROUTING TABLE]"
ip route

echo ""
echo "[DEFAULT GATEWAY]"
ip route | grep default || echo "Gateway not found"


echo ""
echo "[DNS CONFIGURATION]"
if command -v resolvectl >/dev/null 2>&1; then
    resolvectl status
else
   cat /etc/resolc.conf
fi

echo ""
echo "[INTERNET CONNECTIVITY]"
if ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "Internet connection: AVAILABLE"
else
    echo "Internet connection: UNAVAILABLE"
fi

echo ""
echo "============================================"
echo "            CHECK COMPLETED "
echo "============================================"
