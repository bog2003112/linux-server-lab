# Linux Server Lab

A hands-on Linux system administration project built on **Ubuntu 24.04 LTS**. The lab focuses on Bash automation, system monitoring, and network diagnostics.

The repository contains small, readable scripts that inspect a Linux host and report useful operational information. It is an educational portfolio project and does not make configuration changes to the host.

## Project contents

| Path | Purpose |
| --- | --- |
| scripts/system-info.sh | Displays operating system, kernel, uptime, CPU, memory, and root filesystem information. |
| scripts/network-info.sh | Reports network interfaces, routes, DNS configuration, and basic connectivity checks. |
| scripts/health-check.sh | Checks disk and memory usage, internet connectivity, and DNS resolution. |
| docs/linux-basics.md | Notes on basic Linux administration commands. |
| docs/networking.md | Notes on Linux networking diagnostics. |
| docs/ssh.md | Notes on SSH access and key handling. |

## Requirements

- Ubuntu 24.04 LTS or another recent Linux distribution.
- Bash.
- Standard Linux utilities: ip, uptime, free, df, uname, awk.
- ping and getent for connectivity and DNS checks.
- resolvectl is optional; the network script falls back to /etc/resolv.conf.

On Ubuntu, the required utilities are normally available by default. If the ip or ping command is missing, install the relevant packages:

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping
```

## Quick start

Clone the repository and enter the project directory:

```bash
git clone https://github.com/bog2003112/linux-server-lab.git
cd linux-server-lab
```

Make the scripts executable:

```bash
chmod +x scripts/*.sh
```

Run an individual script:

```bash
./scripts/system-info.sh
./scripts/network-info.sh
./scripts/health-check.sh
```

The scripts are read-only: they collect and display information but do not modify network, service, or system configuration.

## Health-check exit codes

health-check.sh uses monitoring-friendly exit codes:

| Code | Meaning |
| --- | --- |
| 0 | OK — all checks passed. |
| 1 | WARNING — at least one resource crossed its warning threshold. |
| 2 | CRITICAL — a critical threshold or connectivity check failed. |
| 3 | UNKNOWN — a metric could not be read or configuration is invalid. |

Default resource thresholds:

- Disk warning: 80%; critical: 90%.
- Memory warning: 80%; critical: 90%.

Thresholds and check targets can be overridden with environment variables:

```bash
DISK_WARN_THRESHOLD=75 DISK_CRIT_THRESHOLD=90 ./scripts/health-check.sh
MEMORY_WARN_THRESHOLD=70 MEMORY_CRIT_THRESHOLD=85 ./scripts/health-check.sh
PING_TARGET=1.1.1.1 DNS_TARGET=github.com ./scripts/health-check.sh
```

A failed ICMP test does not always prove that the internet is unavailable: some networks block ping traffic. Interpret the connectivity result in the context of the environment.

## Basic validation

Check Bash syntax before running the scripts:

```bash
bash -n scripts/system-info.sh
bash -n scripts/network-info.sh
bash -n scripts/health-check.sh
```

If ShellCheck is installed, run:

```bash
shellcheck scripts/*.sh
```

## Learning goals

This project is intended to demonstrate practical familiarity with:

- Linux command-line tools and filesystem information.
- Bash scripting, functions, variables, conditionals, and exit codes.
- IP addressing, routing tables, DNS, and connectivity checks.
- Basic server health monitoring and configurable thresholds.
- Git and GitHub project documentation.

## Project status

The lab is being developed incrementally. Containerization, web-server deployment, and CI/CD automation are planned as separate future milestones and are not claimed as implemented features yet.
