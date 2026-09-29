# Troublemaker

Support-desk troubleshooting practice on a home VM lab. An agent secretly breaks one
thing on a lab VM and hands you a ticket written the way a user would describe it.
You find and fix it, write it up, and the agent tutors you throughout without
giving the fault away.

The lab loosely mirrors a small company network: a Windows domain (server + client),
a few Linux servers, and Kali, on one isolated network. See [docs/lab.md](docs/lab.md).

## Start a run

1. The lab is built, and `local/host.md` describes the host.
2. Open an agent with the skills in `skills/` loaded, in this repo, on the lab host.
3. Say: **"troublemaker run on tm-dc01, medium"**.

## What's here

```
skills/troublemaker/            the desk + tutor: jobs, rules, the loop
skills/troublemaker/scripts/    gx.sh: run a command in a guest via the QEMU guest agent
skills/troublemaker-saboteur/   the hidden breaker + fault catalogue
docs/lab.md                     the VMs and the build checklist
runs/                           one folder per run; ENGAGEMENTS.md is the record
local/                          host specifics (gitignored)
archive/                        the earlier, larger design, kept for reference
```

Rule of thumb: do anything three times by hand before scripting it.
