# Installation media

Verified on 2026-09-21. All four images are stored in
`~/Storage/virtualization/isos` and match their publishers' SHA-256 values.

| Image | Role |
|---|---|
| Ubuntu Server 26.04.1 LTS (AMD64) | Router and Ubuntu server; reuse one ISO |
| Ubuntu Desktop 26.04.1 LTS (AMD64) | Ubuntu workstation |
| Fedora Workstation 44 (x86_64) | Fedora workstation |
| RHEL 10.2 DVD (x86_64) | RHEL server |

## Verified hashes

```text
601e30fbf5d97759367c632e2c33630665039b7e2158fd068403da3ccf1bda1f  ubuntu-26.04.1-desktop-amd64.iso
cc8a95cde20f6ced61a322420de00f10cc3c90ced545daa46cb9c1a117f1d927  ubuntu-26.04.1-live-server-amd64.iso
1620295f6a00c27c3208f0c00b8ece4eab1ec69b9002152d97488bf26a426ddf  Fedora-Workstation-Live-44-1.7.x86_64.iso
e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5  rhel-10.2-x86_64-dvd.iso
```

Publisher references:

- [Ubuntu SHA256SUMS](https://releases.ubuntu.com/26.04.1/SHA256SUMS)
- [Fedora Workstation download and checksum](https://www.fedoraproject.org/workstation/download/)
- [Red Hat downloads and checksums](https://developers.redhat.com/products/rhel/download)

Verification compared local file hashes to publisher values obtained over HTTPS.
OpenPGP signature verification and installer boot tests have not been performed.
The files remain outside this repository.
