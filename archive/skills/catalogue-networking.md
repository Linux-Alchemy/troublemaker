# Networking fault catalogue — starter bank

**Reviewed 2026-09-16, all kept; expected to evolve.** These are shapes, not scripts. Each says what a human plausibly did, where it lives in the depth dial, what the user sees, and how it comes undone. Specifics (which interface, which address, which file) vary per run. Undo commands assume the manager noted in recon; adjust.

Depth tags: **D1** obvious place · **D2** one hop out · **D3** deep. Stack D1 with D2/D3 for 7+.

**Floor:** any fault that takes the guest's only NIC down or unaddressed (N1, N6 when it makes the address unusable) is **difficulty 5+** — Matt loses SSH and has to reach the box by console, which is a skill of its own and not what run one is testing.

| # | Shape | What a human did | Symptom the user reports | Depth | Undo shape |
|---|---|---|---|---|---|
| N1 | Interface down *(5+)* | "I was tidying up" — `ip link set <if> down`, or the manager's connection disabled | "No internet, and I can't even ping the printer" | D1 | `ip link set <if> up` / re-enable connection |
| N2 | Wrong gateway | Typo'd the default route in the manager config (`.1` → `.11`) | "Internal stuff works, nothing outside does" | D2 | Correct the route in config, reload manager |
| N3 | Dead resolver | `/etc/resolv.conf` (or the manager's DNS setting) points at a decommissioned server | "Websites don't load but the IP address works, someone told me" | D2 | Restore resolver address |
| N4 | Stale `/etc/hosts` | A hand-added entry for an internal name points at the old server | "The intranet site shows the wrong page / times out — only on my machine" | D1 | Remove the line |
| N5 | Firewall rule | A well-meaning `nft`/`iptables`/`ufw` rule drops outbound 443, or inbound 22 | "Secure sites don't load" / "IT can't remote in" | D2 | Delete the rule, persist |
| N6 | Duplicate IP / wrong subnet mask *(5+ if it breaks reachability)* | Static address set with `/16` instead of `/24`, or the same address as another lab guest | "It works sometimes, then drops" (great at 7+) | D3 | Fix the prefix / address |
| N7 | Service not enabled | `sshd` or `systemd-resolved` stopped and disabled "after the update" | "Can't SSH in" / "DNS broken" | D1 | `systemctl enable --now` |
| N8 | MTU mismatch | MTU set to 1300 on the lab interface | "Small pages load, big downloads hang" | D3 | Reset MTU to 1500 |
| N9 | Two managers fighting | Both `systemd-networkd` and NetworkManager enabled on the same interface | "It keeps changing its IP address" | D3 | Disable the one that shouldn't be there |
| N10 | Hostname / resolution mismatch | Hostname changed, `/etc/hosts` not updated; `sudo` slow, some services unhappy | "Everything's *slow* since yesterday" | D2 | Fix `/etc/hosts` |

**Good pairings for 7–8:** N2 + N3 (fix the route, DNS still dead); N5 + N7 (enable sshd, firewall still blocks 22); N9 + N6 (the fighting managers are *why* the address keeps changing).

**Red herrings that are safe:** a commented-out old gateway line in the config; a harmless unused bridge interface; an old `resolv.conf.bak`; a `dmesg` line about a USB device that isn't there.
