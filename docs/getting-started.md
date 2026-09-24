# Getting started

Do this once, before the first build session. Commands run on the **host**, the machine that will run the VMs. Anything marked *(sudo)* needs root.

## 1. Check the host can run KVM

```sh
grep -Ec '(vmx|svm)' /proc/cpuinfo    # more than 0 means the CPU supports it
ls -l /dev/kvm                         # must exist; if not, enable virtualisation in the firmware
nproc; free -g; df -h                  # threads, RAM, disk
```

Budget: about 10 GB of RAM for v1 and 20 GB for the full lab, on top of what the host needs, plus about 200 GB of disk. VM disks are thin-provisioned, so they only use what they fill.

## 2. Install the tools *(sudo)*

Package names vary by distro. You need QEMU with KVM, libvirt, `virt-install`, `virt-viewer`, `virt-manager` (optional GUI), `jq`, and `dnsmasq` (libvirt uses it for its NAT network).

```sh
# Arch:          pacman -S qemu-full libvirt virt-install virt-viewer virt-manager dnsmasq jq
# Debian/Ubuntu: apt install qemu-system-x86 libvirt-daemon-system virtinst virt-viewer virt-manager jq
# Fedora:        dnf install @virtualization jq
systemctl enable --now libvirtd
usermod -aG libvirt "$USER"            # then log out and back in
```

Check it:

```sh
virsh -c qemu:///system list --all     # works without sudo, even if the list is empty
```

**The connection trap:** a plain `virsh` connects to `qemu:///session`, a separate per-user list. The lab lives in `qemu:///system`. Use `-c qemu:///system` every time, or put `export LIBVIRT_DEFAULT_URI=qemu:///system` in your shell profile.

## 3. Make storage

Keep the lab's disks and ISOs in two libvirt pools, on whichever disk has the room:

```sh
export LIBVIRT_DEFAULT_URI=qemu:///system
LAB=/path/to/storage/virtualization          # choose this
mkdir -p "$LAB/isos"                          # owned by you; downloads go here
sudo mkdir -p "$LAB/vms"                      # (sudo) libvirt manages this one
virsh pool-define-as iso-files dir --target "$LAB/isos"
virsh pool-define-as lab-vms   dir --target "$LAB/vms"
for p in iso-files lab-vms; do virsh pool-start $p; virsh pool-autostart $p; done
virsh pool-list --all --details
```

The system QEMU process has to be able to read the ISO directory and every directory above it. Don't make your home directory world-writable to get there.

## 4. Get the installers

Download them into `$LAB/isos` and verify the checksums: [installation-media.md](installation-media.md). You only need the v1 images (Ubuntu Server and Desktop) to begin.

```sh
virsh pool-refresh iso-files && virsh vol-list iso-files
```

## 5. Install the skills

From the repo root, link each skill into your agent's skills directory. For Claude Code:

```sh
mkdir -p ~/.claude/skills
for s in skills/*/; do ln -sfn "$(pwd)/$s" ~/.claude/skills/"$(basename "$s")"; done
ls -l ~/.claude/skills | grep troublemaker    # six links pointing into the repo
```

Links rather than copies mean a `git pull` updates the skills in place. If you already have older copies of these skills, move them aside first.

## 6. Describe your host

```sh
mkdir -p local && cp docs/host-template.md local/host.md
```

Fill it in: addresses already in use, pools, and anything else the lab must avoid. `troublemaker-lab` reads it before choosing subnets, and your agent uses it as its facts about the machine. `local/` is yours; keep it out of anything you publish.

## 7. Start

Open your agent in the repo and say **"let's work on the lab: pre-v1"**.

If you're new to libvirt, keep these open:

| Task | Command |
|---|---|
| List all VMs | `virsh list --all` |
| Start / clean shutdown | `virsh start VM` / `virsh shutdown VM` |
| Check state | `virsh domstate VM` |
| Graphical console | `virt-viewer --connect qemu:///system VM` |
| Text console (leave: `Ctrl+]`) | `virsh console VM` |
| NICs / disks | `virsh domiflist VM` / `virsh domblklist VM` |
| Networks | `virsh net-list --all`, `virsh net-dumpxml NET` |
| Snapshots | `virsh snapshot-list VM`, `snapshot-create-as VM NAME`, `snapshot-revert VM NAME` |
| Pull the plug (last resort) | `virsh destroy VM`. It doesn't delete anything, but unsaved data is lost |

Upstream references: [virsh](https://www.libvirt.org/manpages/virsh.html), [virt-install](https://github.com/virt-manager/virt-manager/blob/main/man/virt-install.rst), [libvirt networks](https://libvirt.org/formatnetwork.html), [libvirt nwfilter](https://libvirt.org/formatnwfilter.html).
