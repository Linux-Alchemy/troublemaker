# How the remote laptop joins the office (v3)

**This is v3 material, and v3 is optional.** Nothing here is built until v1 and v2 are running and have had their engagements. Assign the VPN range and the laptop's tunnel address in pre-v1 anyway, so the diagram and address table are complete. The original build used a MacBook. Any laptop you're willing to troubleshoot will do; only the WireGuard client differs.

The laptop is a physical machine on the home LAN. The office LAN is an isolated libvirt bridge inside the host, so the laptop can't plug into it. It joins the way a remote worker would: **over a VPN to the office router.**

## The path, hop by hop

```
Laptop (home LAN)
  │  WireGuard UDP to the host's home-LAN address, port 51820
  ▼
Host
  │  port-forward: udp/51820 → router's WAN address        ← host rule, sudo, trainee
  ▼
tm-router WAN NIC (on tm-wan)
  │  WireGuard terminates here; the laptop gets a tunnel address
  ▼
tm-router forwards between the tunnel and the LAN          ← router firewall decides what the laptop reaches
  ▼
Office LAN (tm-lan): servers, workstations
```

Replies take the same path back. The router knows the tunnel subnet because it owns `wg0`, and lab hosts need no extra route because the router is already their default gateway.

## Why this design

| Option | Verdict |
|---|---|
| Bridge the router's WAN straight onto the home LAN (macvtap) | No. It puts a machine the saboteur may edit directly on your home network, and no rule can close a hole that size |
| Make the router a node on your tailnet (subnet router) | No. It mixes the lab into your real VPN, so the tailnet's ACLs become part of the lab's safety. It's also not what a small office runs |
| **WireGuard to the router, port-forwarded through the host** | **Chosen.** One UDP port, fixed on the host, is the only way in. What the laptop can reach is decided by the router, so it's fair game for faults. It's also a real pattern: staff VPN into the office |

## Setting it up

1. **Router:** install `wireguard-tools` and generate the server keypair *on the router*. Give `wg0` an address from the VPN range, set `ListenPort = 51820`, and add a peer for the laptop with its public key and a `/32` in AllowedIPs.
2. **Router firewall:** accept udp/51820 on the WAN, and forward `wg0` → LAN, either all of it or only the services the laptop should see (a design choice).
3. **Host (sudo, trainee):** DNAT udp/51820 arriving on the host's LAN interface to the router's WAN address. libvirt's NAT only handles outbound traffic, so inbound needs its own rule. It has to survive reboots and libvirt restarts, and any host VPN/firewall software mustn't drop it. The usual ways to do it are a libvirt network hook or a small nftables table owned by the lab; choose in v3's design step.
4. **Laptop:** use the official WireGuard app, or `wireguard-tools` for the CLI. Generate the key on the laptop. The tunnel config needs `Endpoint = <host's home-LAN address>:51820` and `AllowedIPs = <LAN range>, <VPN range>`. That makes it a **split tunnel, not `0.0.0.0/0`**, so the laptop's normal internet and any other VPN keep working. Add `DNS =` the router's address if the lab uses internal names.
5. **Checks:** `wg show` on both ends shows a recent handshake. The laptop can ping the router's LAN address and reach a server's service. Its route to a lab host goes through the WireGuard interface, not another VPN (`ip route get <addr>` on Linux, `route -n get <addr>` on macOS).

The endpoint only works while the laptop is on the home LAN. That's fine for a lab. Reaching it from elsewhere would mean exposing another inbound path; don't unless you actually need it.

## The laptop's out-of-band channel

The laptop has no QEMU guest agent, so it needs its own equivalent of the out-of-band standard:

- **Agent → laptop: SSH over a path that doesn't use the lab VPN**, such as a tailnet or the home LAN. Breaking WireGuard on the laptop then still leaves the agent a way in. Record the path in `local/host.md`.
- That path and everything it depends on (the SSH server or Remote Login, the tailnet client, the laptop's own network settings, anything not scoped to the lab) are **permanently off limits to faults**, the same way `qemu-guest-agent` is for VMs.
- Faults on the laptop must be lab-scoped and have a clean, recorded undo, because there's no snapshot to fall back on. Back up the WireGuard config before each engagement.
- If the laptop has another job (e.g. it's your study machine), no engagement ends with it broken.

The saboteur may not target the laptop until v3's design has written this channel down and its build has tested it.
