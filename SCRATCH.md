# Troublemaker — Scratch

> **Outline written 2026-09-16** → `OUTLINE.md`

## Log
### 2026-09-16
- [raw] "design/build a new skill set for a new workflow" — opened with idea-forge on
- [raw] Comes from two things: (1) the OmaFix outline (~/github/OmaFix, agreed 13 Sep), (2) job application targets — mainly tech support roles
- [raw] "meant to assist me in developing skills in troubleshooting"
- [raw] "I'd give the agent a target, and the agent will connect to the target, poke around, and create a small problem that needs to be fixed. Network issue, permissions issue or whatever. Then the agent will help guide me through the troubleshooting process, find the issue, repair it, and generate a report."
- [raw] Report: "unique to this workflow, but should be based on some common standards typically seen with this type of work". Can't be an 'exact' report — every company/ticketing system differs.
- [raw] Targets: QEMU VM (most likely Linux) or a real machine in the office on the network. Macbook on the desk is the other potential target.
- [raw] Scope: Linux and Mac issues for now. Windows later, not planned.
- [raw] Name: "troublemaker" — "skill bundle/workflow"
- [raw] "I'm the designer and 'end user' on this project. You'll be assisting me with the skill creation and workflow"
- [source] OmaFix OUTLINE.md — steal: skills-in-a-repo shape, placeholders-until-run-one, runs/ dir with template, QEMU guest + snapshots on Shadowvault / avoid: (tbc). Note: OmaFix outline says "No PLAN.md: the build is skills, not code" — toolchain gap
- [mode] Reads as solo (skills are markdown; he designs, agent assists) — confirm in playback
- [raw] "You are gonna write the skills, I'll review them so we get the specs just right" — by the toolchain's definitions that's orchestrated (agent writes, Matt is architect). Executor would be skill-creator not vitruvius. Put to him.
- [decision] Multiple skills, not one: "cramming everything into one bloody skill gets messy, performance degrades" + a bank of small skills referenced by a main one is easier to tune — his reason, from experience
- [raw] Shape as he sees it: small MAIN skill (what the job is, what the other files are, when to use them) + SABOTEUR + TUTOR, "possibly three besides the main"
- [raw] Saboteur: needs target system + IP, Matt provides. SSH/Tailscale from Shadowvault to target(s). Possibly multiple targets — e.g. a small QEMU network.
- [decision] Tutor KNOWS what the saboteur did and where it is. Its job: guide Matt to find it, resolve it, write the report. (Corrects my assumption that the tutor had to be blind — it's a coach with the answer key, not a co-investigator.)
- [decision] Lab-only. Own secure environment, no outside machines.
- [open] Problem catalogue (what the saboteur breaks) — parked until workflow shape is agreed
- [open] The blind: saboteur and tutor are the same agent — how does Matt avoid watching the sabotage happen? Session separation? Sealed answer file in runs/?
- [open] Reset: VMs have snapshots, the Mac doesn't. Saboteur has to leave an undo trail.
- [decision] mode: orchestrated — agent writes the skills, Matt is architect/reviewer. Executor is skill-creator, not vitruvius (no PRs/gates). Logged with the toolchain-gap note.
- [decision] Saboteur writes an answer .md into the run; agent then switches hats to Tutor and reads it. Same session, not a fresh one (he overruled fresh session). Still needs the actual breaking hidden — subagent for the break is the compatible mechanism.
- [decision] Tutor generates a 'ticket-shaped' thing from the answer file — what a support worker would see in the wild. Symptom/user-report, not the cause.
- [decision] No ticketing-system integration (Jira/Zendesk/etc) — "a whole other path we don't need to spend time on". Ticket shape borrows from what's out there, generic.
- [decision] Blind mechanics: saboteur runs as a subagent (Matt sees only "done, answer sealed"), main session reads answer.md and becomes tutor. One session, one hat-switch.
- [decision] Networking is the first category — aligns with CCNA prep course just started, exam planned December 2026. College networking background a couple of years back.
- [decision] QEMU lab setup (small VM network) is a SEPARATE agent/concern, not a troublemaker skill — "let's not conflate the skills here". His call.
- [later] Mac target — parked for v1. Reason it exists: macOS re-acquaintance, job ads ask for it. Comes back once the loop has worked on a snapshot-able VM.
- [decision] Permissions/security-shaped faults are IN scope alongside networking — he has security training, wants both. Overrules "one category". Position to hold: stage it (networking walked first), not cut.
- [raw] Difficulty: Matt specifies 1–10 with the target, 10 hardest. "Universal difficulty rating scale."
- [open] 1–10 needs defined semantics or it's vibes — dimensions (fault count, ticket vagueness, depth) rather than 10 hand-written tiers
- [open] Ugly part: networking faults can sever the SSH channel the saboteur itself uses. Needs a rule (never break the mgmt path / use a second NIC / serial console via QEMU).
- [open] Third skill — reporting? (mirrors OmaFix)
- [decision] Difficulty 1–10 kept as input; levels defined by dimensions (fault count, ticket vagueness, depth, red herrings), not ten hand-written tiers. "Otherwise what the hell does 5/10 even mean."
- [decision] Third skill = reporting, its own small skill (mirrors OmaFix). Tutor coaches the investigation; reporting owns the write-up standard.
- [raw] Guardrail: "we don't want the saboteur to shoot us in the foot". Wants ONE standard, decided once, never revisited per engagement. Open to mgmt NIC or other. Asked for suggestions.
- [fact] Options for out-of-band host→guest on QEMU: (a) second mgmt NIC + rule (rule-based, agent can forget; firewall faults need per-iface scoping); (b) qemu-guest-agent guest-exec over virtio-serial (physics-based, no NIC to protect, works with networking fully destroyed, clunky JSON/base64, per-VM from host so multi-VM is free); (c) serial console (rescue hatch / trainee's walk-to-the-machine, awkward for agents as primary).
- [position] Standard = out-of-band via qemu-guest-agent for saboteur+tutor; lab NIC fully fair game; serial console is the trainee's fallback. Fallback standard if ergonomics bite: mgmt NIC + rule. Ergonomics = ten-minute throwaway.
- [decision] Guardrail standard = Option B: qemu-guest-agent (virtio-serial) for saboteur/tutor access. VM network fully fair game. `virsh console` is the trainee's fallback. Mac (later) will need the rule-based mgmt-path variant.
- [open] needs a throwaway: is guest-exec tolerable to drive? Ten minutes. Fallback = mgmt NIC + rule.
- [decision] Trainee works CLI-first — "I'm a back end guy". Tutor coaching and faults should assume shell + outputs, not GUI. Desktop env via remote-viewer only when it makes sense (already installed).
- [note] Feedback: I got verbose. Keep options short, numbered, one question.
- [decision] Principles for rejecting drafts, agreed: (1) one skill one job; (2) tutor coaches, never reveals the FAULT — but answers straight questions ("what's the cmd for X", "help me read this log/output") freely, that's real-world practice; (3) ticket speaks user, report speaks engineer; (4) no fault the saboteur can't verify out-of-band.
- [raw] "That doesn't preclude me from understanding and knowing commands, but I'll not know it all right out of the gate. That's the whole point."
- [decision] Cut round: 1 multi-VM network KEEP in v1 ("rather trivial to set up a handful"); also 1–2 standalone guests for individual targets. 2 security STAGED but close behind — no VM setup needed, purely agent choice. 3 keep. 4 keep. 5 keep (manual revert). 6 agreed — faults authored in saboteur skill.
- [decision] Engagement record: each run logged (subject, result). Once 3 records exist the agent may start choosing security faults; target ratio 70/30 network/security thereafter. The record is what the saboteur reads to pick a category.

### 2026-09-16 (skill authoring)
- [decision] Moved to ~/github/troublemaker, git init. skill-creator started.
- [fact] SV inspected 2026-09-16 over `tailscale ssh` (SV runs no sshd; plain ssh fails, so `qemu+ssh://` is out). libvirt 12.7.0, libvirtd active, reaper in `libvirt` group. `virsh` alone = empty user session; must be `-c qemu:///system`. System has: domain `BlackArch` (off, has guest_agent channel by default), net `default` virbr0 192.168.122.0/24, pools `default` + `iso-files` (/home/reaper/matrix/iso-files). jq present. **No lab guests exist yet** — lab agent's prerequisite before run one.
- [decision] Skills run ON SV (Matt's plan anyway). Legion is a `tailscale ssh` hop, nothing more.
- [decision] Skill names prefixed: troublemaker, troublemaker-saboteur, troublemaker-tutor, troublemaker-reporting — bare "tutor"/"reporting" collide and trigger badly. Mirrors omafix-*.
- [decision] Saboteur returns the answer in its subagent final message (invisible to Matt); answer.md is the durable copy. Parent avoids `cat answer.md` so nothing expandable holds the fault.
- [decision] Matt names libvirt DOMAINS, not IPs — with the guest agent the agent side never needs an IP. IP/hostname goes in the ticket for the trainee.
- [decision] guest-exec wrapper is a paste-in shell function in references/guest-agent.md, not a script — respects the 3× rule.
- [open] Starter catalogues (10 networking, 10 security shapes) drafted for review — this is the parked catalogue conversation.
- [decision] No PLAN.md — not a coding project.
- [decision] Ticket is its own skill (troublemaker-ticket), same reason as tutor/reporting: tuned independently. Placeholder created.
- [decision] Tutor built on obie-wan's assistance ladder.
- [open] Research: common ticket shape across real platforms; common report/resolution-note shape. Inform ticket + reporting skills.
- [decision] Research done → docs/ticket-and-report-research.md. Ticket: priority left blank (derived, tech's job); reporter-only channel. Report: five movements + root-cause tag + permanent/workaround + requester confirmation + reuse tag. Interim shapes in the two placeholders updated.
- [decision] Calls 1,2,3,5 ratified (prefixed names; domains not IPs; answer via subagent return; run on SV). #4 (gx as paste-in vs script) under discussion.
- [decision] #4: gx ships as scripts/gx.sh. Carve-out recorded: the 3x rule is for workflow steps; the transport isn't one. Script also enforces "never SSH" better than a paste.
- [decision] One NIC per VM — end users don't run mgmt NICs. Guest agent + virsh console = the lab's iDRAC/OOB.
- [decision] NIC-killing faults are difficulty 5+ — trainee has to use the console, which is its own skill. Floor written into catalogue (N1, N6) and main skill.
- [later] "User as remote hands" variant: tutor plays the end user reading the screen while Matt talks them through it. Real help-desk mode; revisit after a few runs.
- [decision] Catalogues reviewed, all 20 shapes kept; expected to evolve with runs.
