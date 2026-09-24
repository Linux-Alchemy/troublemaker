# Troublemaker

A troubleshooting lab you build yourself, plus an AI agent that breaks it on purpose.

You build a small office network in virtual machines: a Linux router, servers, and workstations. An agent then breaks one plausible thing and hands you a support ticket written the way a user would describe the problem. It coaches you while you find and fix it from the shell, but it never gives you the answer. Afterwards you write it up the way real support work gets written up.

It's for people trying to get into support, sysadmin, or network roles who need practice on broken systems and have nothing broken to practise on. It also lines up with CCNA-level networking.

## How it works

1. **Build the lab** in stages, coached by the `troublemaker-lab` skill. The build is training too: subnetting, NAT, DHCP/DNS, a firewall, and later a VPN, all from the CLI.
2. **Run engagements.** Name a target VM and a difficulty from 1 to 10. The saboteur breaks something where you can't see it. Then you get a ticket, investigate, fix, report, and revert the snapshot.
3. **Grow the lab** a couple of machines at a time, with runs in between.

| Stage | You build | Before moving on |
|---|---|---|
| **Pre-v1** | Nothing yet. Draw the full network topology and give every planned machine an address | Diagram and IP table done |
| **v1** | Router (two NICs) + one server + one workstation | Two engagements completed |
| **v2** | A second server + a second workstation, from another distro family | Two more engagements |
| **v3** | *Optional:* a physical laptop joins as a remote worker over a WireGuard VPN | — |

## Prerequisites

- **You:** comfortable in a Linux terminal, and you've installed a Linux distro before. You don't need QEMU or virtual-network experience; the build coaches you through both.
- **Host:** Linux with KVM (Intel VT-x or AMD-V enabled). About 10 GB of RAM to spare for v1 and 20 GB for the full lab, plus about 200 GB of free disk.
- **Software:** QEMU/KVM, libvirt (`virsh`, `virt-install`, `virt-viewer`), `jq`, and an agent that loads `SKILL.md` skills and can dispatch subagents. Written for Claude Code; other skill-aware agents should work but are untested.
- **Diagram:** Cisco Packet Tracer, free with a Cisco Networking Academy account. It can run on any machine you have.
- **Installers:** Ubuntu Server and Desktop, Fedora Workstation, and RHEL (free developer subscription). See [docs/installation-media.md](docs/installation-media.md).

## Start

1. Work through [docs/getting-started.md](docs/getting-started.md): check the host, make storage, get the ISOs, install the skills, and describe your host in `local/host.md`.
2. Open your agent in the repo and say **"let's work on the lab: pre-v1"**.
3. Once v1 is handed over, say **"break something on tm-srv-files, difficulty 2"**.

## What's in the repo

```
skills/
  troublemaker/            engagements: roles, rules, difficulty, the loop. Loaded first for runs
    scripts/gx.sh          runs a command inside a VM through the QEMU guest agent
  troublemaker-lab/        coaches the lab build stage by stage; the only skill that creates VMs
  troublemaker-saboteur/   hidden subagent: picks and applies a fault, seals the answer
    references/            fault catalogues: networking, security, systems
  troublemaker-ticket/     turns the sealed answer into a user-shaped ticket
  troublemaker-tutor/      coaches the investigation without giving the fault away
  troublemaker-reporting/  the write-up standard
docs/
  getting-started.md       host checks, storage, skill install
  installation-media.md    which ISOs, where to get them, checksums
  host-template.md         copy to local/host.md and fill in
  ticket-and-report-research.md   why tickets and reports are shaped the way they are
  lab-design.md, topology/, lab-build.md   your design and build guide, written as you go
runs/                      one directory per engagement, plus ENGAGEMENTS.md, the record of every run
local/                     your host's specifics; personal, not part of the course
```

The tutor, ticket, and reporting skills are deliberately thin until real runs show what they need. Each carries an interim version you can use now.

## Rules everything depends on

- **Lab only.** The agents touch nothing except VMs named `tm-*`. The host, your home network, and your other machines are protected by rules enforced on the host, where nothing inside a VM can undo them.
- **Out-of-band access.** The agent reaches VMs through the QEMU guest agent, never the network. That means any network fault is fair game, and the agent can still check your fix.
- **The tutor withholds the fault, not knowledge.** Ask it how a command works or how to read a log. It won't tell you what's broken.
- **Three times by hand before scripting anything.**
