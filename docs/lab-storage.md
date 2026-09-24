# Storage on Shadowvault

Configured on 2026-09-21. The second SSD is general-purpose storage with a
dedicated virtualization directory.

| Purpose | Libvirt pool | Path |
|---|---|---|
| New lab VM disks | `lab-vms` | `/mnt/storage/virtualization/vms` |
| Installation ISOs | `iso-files` | `/mnt/storage/virtualization/isos` |
| Existing BlackArch disk | `lab-vms` | `/mnt/storage/virtualization/vms/BlackArch.qcow2` |

The WD Black SN850X 1 TB SSD has one GPT Linux partition, formatted as ext4,
labelled **Storage**, and mounted at `/mnt/storage` by filesystem UUID in
`/etc/fstab`. The old Ubuntu installation and its EFI partition were removed
at Matt's explicit request. Existing ISOs were preserved and restored.
Approximately 905 GiB is free after restoration. The filesystem reserves 0%
of blocks for root (`mkfs.ext4 -m 0`).

Mount options include `nosuid,nodev,nofail,x-systemd.automount` and a 10-second
device timeout. Systemd mounts the filesystem on access. The pool is persistent
and has libvirt autostart enabled.

When creating lab VMs, explicitly select `lab-vms` in virt-manager or use
`--disk pool=lab-vms,size=<GiB>,format=qcow2,bus=virtio` with virt-install.
Adding a pool does not change the default pool or relocate existing disks.

## Home-directory shortcuts

`/home/reaper/Storage` is a symlink to `/mnt/storage`:

```text
~/Storage/
└── virtualization/
    ├── isos/
    └── vms/
```

Save new installation images in `~/Storage/virtualization/isos`. The filesystem
root, virtualization directory, and ISO directory belong to `reaper`. Other
storage directories can be created normally. The VM directory is root-owned
and managed through libvirt. The root-owned `lost+found` directory is ext4's
normal recovery directory, not leftover Ubuntu content.

The three original ISOs were copied to the spare SSD and verified before
removing their original copies. The old `/home/reaper/matrix/iso-files` path
is a compatibility symlink to `/mnt/storage/virtualization/isos`. Libvirt's
two repointed pools retain their names, UUIDs, and autostart settings.
The former `~/lab` shortcut and `/mnt/lab-storage` mount point were removed.

## Verification

- Before formatting, verified the WD by stable hardware identifier, model,
  serial, and filesystem UUID. Traced `/`, `/home`, `/boot`, and the active
  firmware boot entry to the separate Lexar SSD. The format procedure refused
  any target that was an ancestor of a system mount.
- Preserved all three ISOs on the Lexar and checked SHA-256 hashes, including
  a final comparison with the old filesystem mounted read-only. All restored
  files matched the manifest. Temporary ISO staging copies were then removed.
- Confirmed the Lexar partition table was unchanged and Omarchy mounts remained
  on that drive. No partition or format operation targeted it.
- Verified normal-user create/read/delete access through `~/Storage`.
- Validated fstab with `findmnt --verify`: no errors or warnings.
- Stopped the new mount, started its automount, and accessed the VM directory:
  systemd mounted the expected ext4 partition successfully.
- Refreshed `lab-vms` through libvirt and confirmed it is empty and active.
- Confirmed `default` retains its original path; `iso-files` now lists all
  three migrated images at `/mnt/storage/virtualization/isos`.

## BlackArch migration

Later on 2026-09-21, BlackArch's disk was moved into the new VM directory.
The VM was shut off, with no managed save, snapshots, or backing image.
Its sparse qcow2 file was copied with permissions preserved, compared
byte-for-byte, and passed `qemu-img check` without errors. The persistent
domain definition passed validation and was compared against its backup:
only the disk source path changed. The original disk copy was then removed.

The VM remains shut off; no boot test was performed. Its UEFI variable file
remains in libvirt's normal `/var/lib/libvirt/qemu/nvram` location. Definition
and NVRAM backups are in `/var/backups/blackarch-storage-move`.

The separate, unused `arch-server.qcow2` was subsequently deleted at Matt's
request after confirming it was not attached to the only defined VM,
BlackArch. The old default pool is now empty.

All four new lab installer images are also present and checksum-verified;
see [installation-media.md](installation-media.md).

No new lab VM has yet been created, and no host reboot was performed.
VM snapshot/revert and backup arrangements remain to be designed and tested.
Snapshots on this SSD will not constitute a separate backup.

Useful inspection commands:

```sh
findmnt --target /mnt/storage/virtualization/vms
df -h /mnt/storage
virsh -c qemu:///system pool-info lab-vms
virsh -c qemu:///system vol-list lab-vms
```

Reference: [libvirt directory pools](https://libvirt.org/storage.html#directory-pool).
