# Host: <name>

Copy this file to `local/host.md` and fill it in. The lab skills read it for facts about your machine, so keep it current. Re-run the commands at the bottom before each build session.

## Machine

| Item | Value |
|---|---|
| Threads / RAM / free disk | |
| QEMU / libvirt versions | `virsh version` |
| In `libvirt` group (virsh without sudo)? | |
| Can the agent use sudo? | Normally **no**: host-level steps are yours |
| Host firewall or VPN software that might interfere | (e.g. a VPN client's firewall) |

## Addresses already in use (the lab must avoid these)

| Range | What |
|---|---|
| | Home LAN, host address, gateway |
| `192.168.122.0/24` | libvirt `default` NAT network, if present |
| | VPN / tailnet ranges (Tailscale uses `100.64.0.0/10`) |
| | Container networks (Docker uses `172.17.0.0/16` by default) |

## Libvirt objects

| Object | Notes |
|---|---|
| Pool `lab-vms` | path: |
| Pool `iso-files` | path: |
| Existing VMs / networks that are **not** part of the lab | list them; the agents never touch them |

## Access

- How you (and your agent) reach this host:
- *(v3 only)* How the agent reaches the remote laptop out-of-band (e.g. SSH over a tailnet):

## Recheck commands

```sh
export LIBVIRT_DEFAULT_URI=qemu:///system
virsh list --all; virsh net-list --all; virsh pool-list --all --details
ip -br addr; ip -4 route
df -h
```
