# Linux Networking

A practical reference for inspecting interfaces, routes, DNS, and connectivity.

## Network interfaces and addresses

```bash
ip -br link
ip -br address
ip address show
```

- ip -br link gives a compact interface and link-state view.
- ip -br address displays assigned IPv4 and IPv6 addresses.
- UP indicates the interface is administratively enabled; it does not by itself prove end-to-end connectivity.

## Routing

```bash
ip route
ip route show default
ip route get 1.1.1.1
```

The default route is normally used when no more specific route matches a destination. The via field identifies the next-hop gateway and dev identifies the outgoing interface.

## DNS

```bash
resolvectl status
resolvectl dns
cat /etc/resolv.conf
getent ahosts github.com
```

resolvectl is available on systems using systemd-resolved. /etc/resolv.conf may be a generated file or a stub resolver configuration, depending on the distribution and network manager.

getent ahosts tests name resolution through the host's configured name-service mechanisms.

## Connectivity checks

```bash
ping -c 2 -W 2 1.1.1.1
ping -c 2 -W 2 github.com
```

A ping to an IP address checks ICMP reachability without requiring DNS. A ping to a hostname also depends on name resolution. ICMP may be blocked by a firewall, so a failed ping alone is not conclusive proof that an application or the internet is unavailable.

## Docker networking

Docker commonly creates bridge interfaces and private address ranges. Inspect them with:

```bash
ip -br address
ip route
docker network ls
docker network inspect bridge
```

Container networks may add interfaces and routes to the host. Do not delete or reconfigure Docker bridges as part of basic diagnostics.

## Troubleshooting order

1. Confirm the interface exists and has the expected link state.
2. Check whether an IP address is assigned.
3. Inspect the routing table and default gateway.
4. Test reachability to a known IP address.
5. Test DNS resolution separately.
6. Compare host networking with container networking if Docker is involved.
