# Design areas

| Area | When it's settled |
|---|---|
| 1. Network design | **Pre-v1, for the whole lab**, including the v3 laptop |
| 2. Protection and support access | v1 (host protection and the router); extended in v3 for the VPN inbound |
| 3. Machine specs and roles | Per increment, only for the machines being added |
| 4. Recovery design | v1 (VM snapshot pattern); v3 (the laptop) |

For each area: the questions `docs/lab-design.md` has to answer, the facts that limit the answers, and the agent's **starting recommendation**. The recommendation is there so the agent has an opinion when asked. It isn't the answer. The trainee writes the decision and the reason. Host-specific facts come from `local/host.md`.

---

## 1. Network design

**Answer these questions:**
- What's the office LAN subnet and prefix, and why that size?
- What's the router's LAN address? Where do servers, workstations, and the DHCP pool sit in the range?
- Static addresses or DHCP reservations, and which for which machines?
- How does the router reach upstream?
- Who runs DHCP and DNS on the LAN? Is there an internal domain name?
- What's the VPN subnet, and the laptop's tunnel address?

**Constraints:** avoid every range in the "in use" table in `local/host.md`. Libvirt must not run DHCP on the office LAN; the router does, as it would in a real office.

**Starting recommendation:**

| Segment | libvirt network | Suggested range | Notes |
|---|---|---|---|
| Upstream ("ISP") | `tm-wan`, NAT, its own bridge | `192.168.100.0/24`, libvirt `.1` | Dedicated to the lab, so other VMs on the host's `default` network aren't involved. The router gets one fixed address here |
| Office LAN | `tm-lan`, **isolated**: no `<forward>`, **no `<ip>`** | `10.20.30.0/24`, router `.1` | With no host address on the bridge, the host isn't a peer on the LAN at all. The router's LAN NIC is the only way out |
| VPN (v3) | `wg0` on the router | `10.20.99.0/24`, router `.1`, laptop `.10` | Separate from the LAN, so firewall rules can tell "remote staff" from "on-site" |

LAN layout: `.1` router · `.10–.19` servers (static) · `.50–.59` reserved · `.100–.199` DHCP pool for workstations · `.200+` spare. The router runs **dnsmasq** for DHCP, DNS forwarding, and local names (e.g. `*.office.lan`). It's the smallest thing a real small office would plausibly run, and it gives the saboteur a DHCP/DNS layer to break.

A `/24` is oversized for five machines on purpose. The trainee should be able to say why that's normal in a small office (simplicity, room to grow) and what a `/28` would look like instead. That makes a good CCNA check.

---

## 2. Protection and support access

**Answer these questions:**
- What must the lab never reach? (The home LAN, the host itself, any VPN/tailnet)
- Where is each boundary enforced, and can the saboteur remove it?
- What's the only inbound path from outside? (The laptop's WireGuard port, from v3)
- When lab networking is broken, how do the trainee and the agent still get in?
- What's the boundary test?

**The key principle:** the saboteur runs as root inside guests, including the router. **Any boundary enforced inside a guest can be broken, so it counts as lab content, not protection.** Real protection lives on the host, where the guest agent can't reach.

**Constraints:**
- A libvirt NAT network lets guests go **anywhere the host can route, including the home LAN**. NAT doesn't isolate anything.
- Guests can reach the host at their bridge's gateway address. If the host's `sshd`, or anything else, listens on all addresses, a guest on `tm-wan` can reach it at `192.168.100.1`.
- Host VPN clients and firewalls (see `local/host.md`) can conflict with the lab's rules. Check before relying on them.

**Starting recommendation, by layer:**

| Boundary | Enforced by | Removable by the saboteur? |
|---|---|---|
| Office LAN only leaves through the router | `tm-lan` has no `<forward>` and no host IP | No (host config) |
| Router WAN can't reach the home LAN or host services | A libvirt **nwfilter** (e.g. `tm-wan-guard`) on the router's WAN NIC: allow DHCP/DNS to `.1`; drop traffic to the home LAN, VPN/tailnet ranges (Tailscale: `100.64.0.0/10`), and the host's other addresses; allow the rest out. Defined through `virsh`, no sudo needed | No (outside the guest) |
| Only udp/51820 comes in (v3) | A host DNAT rule (sudo, trainee) | No |
| What the laptop can reach once connected | The router's nftables | **Yes, on purpose.** It's lab content |
| The laptop's own out-of-band path | Off limits in the saboteur's rules (`remote-worker-vpn.md`) | Only by rule. Record this as the laptop's weak point |

**Support access when networking breaks:**
- **Agent:** the QEMU guest agent (VMs); an out-of-band SSH path for the v3 laptop.
- **Trainee:** `virsh console <dom>`. That needs a serial console in each guest (`console=ttyS0` on the kernel command line, or a serial getty), so enable one during the build. Otherwise use `virt-viewer`.
- Snapshot revert is the last resort.

**Boundary test (must pass before every handover):** from the router and one LAN host, prove the lab's internet access works (`curl -sI https://example.com`). Then prove the home-LAN gateway, the host's own services (e.g. SSH), and any tailnet address **can't** be reached. Take the exact addresses from `local/host.md`. From v3, also reach one lab service from the laptop over the tunnel. Record the commands and outputs in `lab-design.md`.

---

## 3. Machine specs and roles

**Answer these questions:**
- Each machine's name, role, and OS (from the ISOs on hand)
- vCPU, RAM, and disk for each
- What services the two office servers provide, and what each workstation *uses* them for. A service nobody uses gives the saboteur nothing realistic to break

**Constraints:** the host's threads and RAM are in `local/host.md`. If it's also a daily-use machine, keep the whole lab running at once to ≤ 50% of RAM.

**Starting recommendation** (the full roster goes on the diagram in pre-v1; specs are only fixed for the increment being built):

| Stage | Domain | OS | Role | vCPU | RAM | Disk |
|---|---|---|---|---|---|---|
| v1 | `tm-router` | Ubuntu Server | Two NICs: gateway, NAT, firewall (nftables), dnsmasq; WireGuard in v3 | 2 | 2 GiB | 20 GiB |
| v1 | `tm-srv-files` | Ubuntu Server | File server (Samba or NFS) plus an internal web page | 2 | 4 GiB | 40 GiB |
| v1 | `tm-ws-ubuntu` | Ubuntu Desktop | Staff workstation: mounts the share, uses the intranet | 2 | 4 GiB | 40 GiB |
| v2 | `tm-srv-apps` | RHEL | The internal app/database server (e.g. PostgreSQL behind a small web app), SELinux enforcing | 2 | 4 GiB | 40 GiB |
| v2 | `tm-ws-fedora` | Fedora Workstation | Second staff workstation (NetworkManager/firewalld) | 2 | 4 GiB | 40 GiB |

v1 stays in the Ubuntu family: one ISO family and one network stack (netplan), so the only new skill is libvirt from the CLI, not a new distro as well. v2 brings in the Red Hat family, whose networking, firewall, and SELinux differences become new fault territory; support roles meet both families. v1 needs 10 GiB of RAM; the full lab needs 18 GiB and 180 GiB of thin-provisioned qcow2. The services are the most open question, so choose them from what the jobs you're applying for mention.

---

## 4. Recovery design

**Answer these questions:**
- Firmware: BIOS or UEFI?
- Disk format and snapshot type
- What `clean` and `pre-<run>` capture: disk only, or disk plus memory
- A backup separate from snapshots? (Snapshots on the same disk don't count as a backup.)
- The laptop's recovery approach (v3)

**Constraints:** the troublemaker loop depends on `virsh snapshot-create-as` / `snapshot-revert` working quickly and reliably on **running** guests. libvirt's internal snapshots are simple and reliable for **BIOS, single-qcow2** VMs. UEFI VMs keep firmware variables in a separate NVRAM file that internal snapshots don't capture, so they need a different workflow.

**Starting recommendation:** **BIOS (SeaBIOS) with a single qcow2 disk on `virtio`** for every lab VM, and **internal snapshots that include memory state**. Reverting then brings the guest back running with no reboot, so `pre-<run>` just works. `virt-install` defaults to BIOS unless given `--boot uefi`; confirm there's no `<loader>` in `virsh dumpxml`. None of the lab's roles need UEFI or Secure Boot. If UEFI is wanted later (it's a realistic fault area), make it a deliberate single-VM experiment, not the default. The first VM's snapshot round trip in v1 proves the pattern on this host before it's copied.

Backups: optional for a lab that can be rebuilt. If wanted, cold-export the `clean` qcow2 files and the XML to a different disk after handover.

The laptop (v3): see `remote-worker-vpn.md`. There's no snapshot, so recovery means a recorded undo, lab-scoped faults only, a pre-engagement copy of the WireGuard config, and the out-of-band SSH path as the way in.
