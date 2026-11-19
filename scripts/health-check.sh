#!/usr/bin/env bash

set -u
status=0

echo "======================================"
echo "       SERVER HEALTH CHECK"
echo "======================================"

echo ""
disk_usage=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

echo "[DISK]"

if (( disk_usage >=90 )); then
    echo "CRITICAL: Disk usage ${disk_usage}%"
    status=1
elif (( disk_usage >=80 )); then
    echo "WARNING: Disk usage ${disk_usage}%"
else
    echo "OK: Disk usage ${disk_usage}%"
fi

echo ""

memory_usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

echo "[MEMORY]"

if (( memory_usage >=90 )); then
    echo "CRITICAL: RAM usage ${memory_usage}%"
    status=1
elif (( memory_usage >=80 )); then
    echo "WARNING:  RAM usage ${memory_usage}%"
else
   echo "OK: RAM usage ${memory_usage}%"
fi

echo "[NETWORK]"

if ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "OK: Internet available"

else
    echo "CRITICAL: Internet unavailable"
    status=1
fi

echo ""

echo "[DNS]"

if getent hosts google.com >/dev/null 2>&1; then
    echo "OK: DNS resolution works"
else
    echo "CRITICAL: DNS resolution failed"
    status=1
fi

echo ""
echo "====================================="
echo "      HEALTH CHECK FINISHED"
echo "====================================="

exit "$status"
