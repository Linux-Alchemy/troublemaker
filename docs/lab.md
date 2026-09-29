# The lab

One isolated libvirt network, no router VM. Roughly mirrors the CJCA exam shape.
All names start `tm-`. Build what the next run needs, not the whole table.

| VM | OS | Role | RAM | Build |
|---|---|---|---|---|
| `tm-dc01` | Windows Server 2025 Standard (Desktop Experience), 180-day eval | Domain controller + DNS | 4–6 GB | first |
| `tm-win01` | Windows 11 Enterprise, 90-day eval | Domain-joined client | 4–6 GB | first |
| `tm-nix01` | Linux server | App / dev services | 1–2 GB | second |
| `tm-nix02` | Linux server | Mail / file / DB | 1–2 GB | later |
| `tm-web01` | Linux | Web server | 1–2 GB | later |
| `tm-kali` | Kali (prebuilt QEMU image) | Attacker; 2 NICs: NAT + lab | 4 GB | when needed |
| `tm-elk01` | Elastic + Kibana | Logs | 6–8 GB | only if HTB's SIEM labs feel thin |

## Media

- Windows 11 Enterprise eval: https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
- Windows Server 2025 eval: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025
- virtio-win drivers (try `latest` if `stable` gives trouble on Server 2025 / Win11 24H2+):
  https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
- Windows 11 on KVM walkthrough: https://sysguides.com/install-windows-11-on-kvm
  (use the hardware setup; skip most of its "optimise" section; drop `evmcs` on AMD)
- Linux ISOs and checksums used so far: `archive/docs/installation-media.md`

Check every download's SHA256 against the vendor's published value.

## Build checklist

- [ ] Isolated network `tm-lab` (no `<forward>`; decide whether the host gets an IP on it)
- [ ] Every VM: guest-agent channel (`--channel unix,target.type=virtio,name=org.qemu.guest_agent.0`) and the agent installed in the guest (Windows: virtio-win guest tools)
- [ ] Windows: Q35 + UEFI; Win11 also TPM 2.0 (CRB); virtio disk and NIC with the virtio ISO as a second CD-ROM (fall back to SATA + e1000e if it fights)
- [ ] Install and patch everything while on NAT, then move to `tm-lab`
- [ ] Prove a snapshot round trip on the first Windows VM (UEFI can complicate internal snapshots) before copying the pattern
- [ ] `gx.sh <vm> 'hostname'` answers on every VM
- [ ] Take a `clean` snapshot of each VM
- [ ] Kali: IP forwarding off (`net.ipv4.ip_forward=0`); the HTB VPN runs only on Kali
- [ ] Add each finished VM to `local/host.md`

## Open item

`gx.sh` runs `/bin/sh`. Before the first Windows run, have it call `guest-get-osinfo`
and use `powershell.exe -NoProfile -Command` on Windows guests. Test on a real VM.
