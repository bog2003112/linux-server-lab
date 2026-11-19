# Linux Basics

A short command reference for the Linux Server Lab.

## Identify the system

```bash
cat /etc/os-release
uname -a
hostnamectl
uptime
```

- /etc/os-release describes the distribution and release.
- uname -a prints kernel and architecture information.
- hostnamectl shows host identity and virtualization details.
- uptime shows how long the system has been running and the load averages.

## Inspect resources

```bash
lscpu
nproc
free -h
df -hT
lsblk
```

- lscpu displays CPU topology and model information.
- nproc reports the number of available processing units.
- free -h summarizes memory and swap usage.
- df -hT reports filesystem capacity and types.
- lsblk lists block devices.

## Processes and services

```bash
ps aux
top
systemctl --type=service --state=running
systemctl status SERVICE_NAME
```

Use systemctl status to inspect a service before changing or restarting it. Administrative actions may require sudo.

## Files and permissions

```bash
pwd
ls -lah
stat FILE
chmod u+x SCRIPT
chown USER:GROUP FILE
```

- chmod changes permission bits.
- chown changes file ownership and normally requires elevated privileges for system files.
- Avoid recursive permission or ownership changes unless the target and consequences are understood.

## Safe troubleshooting workflow

1. Reproduce the issue and note the exact error.
2. Inspect the relevant service, process, file, or resource.
3. Check logs and configuration before making changes.
4. Make one controlled change at a time.
5. Verify the result and document what changed.

Prefer read-only inspection commands before commands that modify the system.
