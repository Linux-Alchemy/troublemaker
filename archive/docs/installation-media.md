# Installation media

| Image | Lab role | Stage | Get it |
|---|---|---|---|
| Ubuntu Server LTS (amd64) | Router and first server: one ISO for both | v1 | [ubuntu.com/download/server](https://ubuntu.com/download/server) |
| Ubuntu Desktop LTS (amd64) | First workstation | v1 | [ubuntu.com/download/desktop](https://ubuntu.com/download/desktop) |
| RHEL DVD (x86_64) | Second server | v2 | [developers.redhat.com](https://developers.redhat.com/products/rhel/download). The free Developer Subscription for Individuals covers lab use; register the VM after install |
| Fedora Workstation (x86_64) | Second workstation | v2 | [fedoraproject.org/workstation](https://fedoraproject.org/workstation/download) |

Later point releases are fine. Record the exact versions you used in `docs/lab-design.md`. v1 is all Ubuntu, so you only learn one network stack while you're also learning libvirt. v2 brings in the Red Hat family, with different network, firewall, and SELinux tooling to troubleshoot.

## Verify every download

Compare the local hash with the publisher's value, fetched over HTTPS:

```sh
cd /path/to/isos
sha256sum ubuntu-*-live-server-amd64.iso
# Ubuntu: https://releases.ubuntu.com/<version>/SHA256SUMS
# Fedora and Red Hat publish checksums beside each download
```

Checking the publisher's GPG signature on the checksum file as well is stronger. Each distro's download page explains how. Keep the ISOs outside the repo.

## Versions used when this lab was first built (verified 2026-09-21)

```text
cc8a95cde20f6ced61a322420de00f10cc3c90ced545daa46cb9c1a117f1d927  ubuntu-26.04.1-live-server-amd64.iso
601e30fbf5d97759367c632e2c33630665039b7e2158fd068403da3ccf1bda1f  ubuntu-26.04.1-desktop-amd64.iso
e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5  rhel-10.2-x86_64-dvd.iso
1620295f6a00c27c3208f0c00b8ece4eab1ec69b9002152d97488bf26a426ddf  Fedora-Workstation-Live-44-1.7.x86_64.iso
```

All four matched their publishers' SHA-256 values over HTTPS. Signatures and installer boot tests weren't done.
