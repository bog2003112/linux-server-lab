#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
script="$root_dir/scripts/health-check.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/no-ping" "$test_dir/no-getent"

cat > "$test_dir/bin/df" <<'EOF'
#!/usr/bin/env bash
printf 'Filesystem 1024-blocks Used Available Capacity Mounted on\n/dev/root 100 50 50 %s%% /\n' "${DISK_USAGE:-50}"
EOF

cat > "$test_dir/bin/free" <<'EOF'
#!/usr/bin/env bash
printf 'Mem: 100 %s 50 0 0 50\nSwap: 0 0 0\n' "${MEMORY_USAGE:-50}"
EOF

cat > "$test_dir/bin/ping" <<'EOF'
#!/usr/bin/env bash
exit "${PING_EXIT:-0}"
EOF

cat > "$test_dir/bin/getent" <<'EOF'
#!/usr/bin/env bash
exit "${DNS_EXIT:-0}"
EOF

chmod +x "$test_dir/bin/"*
ln -s "$(command -v awk)" "$test_dir/bin/awk"

for command in df free getent awk; do
    ln -s "$test_dir/bin/$command" "$test_dir/no-ping/$command"
done

for command in df free ping awk; do
    ln -s "$test_dir/bin/$command" "$test_dir/no-getent/$command"
done

run_case() {
    local name="$1"
    local expected_status="$2"
    local expected_text="$3"
    local path="$4"
    shift 4

    local output actual_status
    if output="$(env PATH="$path" "$@" /bin/bash "$script" 2>&1)"; then
        actual_status=0
    else
        actual_status=$?
    fi

    if [[ "$actual_status" -ne "$expected_status" ]]; then
        printf 'FAIL: %s returned %s, expected %s\n%s\n' \
            "$name" "$actual_status" "$expected_status" "$output" >&2
        return 1
    fi

    if ! grep -Fq -- "$expected_text" <<<"$output"; then
        printf 'FAIL: %s did not print: %s\n%s\n' \
            "$name" "$expected_text" "$output" >&2
        return 1
    fi

    printf 'PASS: %s\n' "$name"
}

run_case "healthy server" 0 "OVERALL STATUS: OK" "$test_dir/bin"
run_case "leading zero thresholds" 1 "WARNING: root filesystem usage is 8%" "$test_dir/bin" \
    DISK_USAGE=8 DISK_WARN_THRESHOLD=08 DISK_CRIT_THRESHOLD=09
run_case "invalid thresholds" 3 "warning threshold must be lower than critical" "$test_dir/bin" \
    DISK_WARN_THRESHOLD=90 DISK_CRIT_THRESHOLD=80
run_case "failed ping" 2 "CRITICAL: connectivity check" "$test_dir/bin" PING_EXIT=1
run_case "failed DNS lookup" 2 "CRITICAL: DNS resolution failed" "$test_dir/bin" DNS_EXIT=1
run_case "missing ping" 3 "UNKNOWN: ping command not found" "$test_dir/no-ping"
run_case "missing getent" 3 "UNKNOWN: getent command not found" "$test_dir/no-getent"

printf 'All health-check tests passed.\n'
