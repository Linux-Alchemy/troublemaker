# Troublemaker — Outline

> **Status:** outline agreed 2026-09-16 · **Next:** author `troublemaker` (main) and `saboteur` via skill-creator; `tutor` and `reporting` are placeholders until run one. No PLAN.md: the build is skills, not code (decided 2026-09-16).
> **Build mode:** `orchestrated` — agent writes the skills, Matt reviews against the principles below. Executor is skill-creator, not vitruvius (no PRs, no code gates).
> **Working notes:** `SCRATCH.md` · **Repo:** `~/github/troublemaker` (assumed, mirrors OmaFix)
> **Lineage:** OmaFix's bones (skills-in-a-repo, QEMU guests with snapshots, `runs/`, placeholders-until-run-one) pointed the other way: OmaFix hunts bugs someone else caused; troublemaker causes them on purpose.

## In one sentence

A skill set where an agent breaks one thing on a lab VM, hands Matt a user-shaped ticket, coaches him to find and fix it from the shell, and helps him write it up the way real support work gets written up.

## The itch

Matt is applying for tech support roles and sitting the CCNA in December 2026. The muscle those jobs and interviews test — methodical troubleshooting, then a write-up someone else can act on — can't be built by reading. It needs broken things, and nothing on his desk is broken. Today: the CCNA prep course, and nothing to practise on.

## Who it's for

Matt, on Shadowvault, as designer and sole trainee. Nobody else uses it; the lab is his own, no outside machines, ever.

## Shape

**Claude skills in a shareable repo**, five of them, the main one loaded first and pointing at the rest:

1. **troublemaker** — the job, the roster, when each skill is used, the out-of-band standard, difficulty dimensions, the engagement record.
2. **saboteur** — given target(s), IP(s) and a difficulty 1–10, runs *as a subagent*, breaks one plausible thing, seals `answer.md` in the run directory. Owns the fault catalogue. Matt sees only "done".
3. **ticket** — turns the answer into what the help desk would see: symptom, user-language, never the cause. Its own skill because it'll be tuned on its own. **Placeholder until the ticketing research is in.**
4. **tutor** — same session, hat switched, holds the answer and coaches the investigation on obie-wan's assistance ladder. **Placeholder until run one.**
5. **reporting** — the write-up standard, generic-ticket-shaped (borrows from Jira/Zendesk-style fields, integrates with nothing). **Placeholder until run one.**

Not one skill: cramming everything in degrades performance and can't be tuned piecemeal — Matt's own experience. Small skills referenced by a main one.

**The out-of-band standard (decided once, never revisited):** saboteur and tutor reach the guest through the QEMU guest agent (`qemu-guest-agent`, virtio-serial), never the network. The guest's network stack is therefore 100% fair game, including "it's fallen off the network entirely". `virsh console` is the trainee's crash cart — the lab's iDRAC — and because a NIC-down fault forces him onto it, those faults are difficulty 5+. The rejected alternative — a management NIC the agent is told not to touch — is a rule, and rules get forgotten at difficulty 8.

**Targets:** a handful of QEMU Linux guests on Shadowvault (trivial to stand up), one NIC each, some networked as a small lab, one or two standalone for individual targets. Lab construction is a separate agent's job, not a troublemaker skill.

**Difficulty 1–10** is defined by dimensions the saboteur turns, not ten hand-written tiers: number of faults stacked, ticket vagueness, depth in the stack, red herrings. A 2 is one fault, precise ticket, obvious place; an 8 is two interacting faults, "it's slow sometimes", plus a misconfiguration that isn't the cause.

**Categories:** networking first (CCNA-aligned). Permissions/security-shaped faults are staged in: after three engagement records exist, the saboteur may choose them, aiming for 70/30 network/security thereafter. The engagement record (subject, result per run) is what it reads to decide.

**How Matt works:** CLI-first — commands and outputs, not GUIs. Tutor coaches in shell. Remote-viewer for the desktop only when it genuinely makes sense.

## Smallest useful version

One Linux guest, one networking fault at difficulty 2–3, walked end to end: sealed answer → ticket → CLI investigation with the tutor → fix verified through the guest agent → report → `virsh snapshot-revert` by hand. Tutor and reporting skills then written from what that run actually needed. Matt would use this version: it *is* the exercise.

## Explicitly not doing

- **Windows targets.** Not planned; Linux and (later) Mac only.
- **The Mac in v1.** No snapshots, no virtio channel — needs a rule-based standard of its own. Parked, not cut.
- **Ticketing-system integration** (Jira, Zendesk, anything). A whole other path; the ticket is *shaped* like the real thing and stops there.
- **Lab-building tooling.** Standing up the QEMU network is another agent's job.
- **Scripts of our own** before something's been done by hand three times. OmaFix rule. One recorded exception: `gx.sh`, the guest-agent transport wrapper — the rule is about workflow steps, and the transport isn't one.

## Later pile

- **Mac target** — exists specifically for macOS re-acquaintance because job ads keep asking; returns once the loop has worked on a snapshot-able guest, with its own (rule-based) out-of-band standard.
- **Snapshot revert / run-dir setup as scripts** — after three manual runs.
- **Windows** — never say never, but not planned.

## Riskiest assumption

That the tutor can hold the answer in context and coach without leaking it. Models with the answer in front of them are bad at withholding, and if the tutor leaks, the whole exercise is an elaborate way of reading yourself the answer. Cheapest test: run one, which is why the tutor is written *after* it. Second, smaller: that the saboteur's faults are realistic rather than telegraphed at a given difficulty — also run one.

## Source material

| Source | Steal | Avoid |
|---|---|---|
| OmaFix OUTLINE.md (`~/github/OmaFix`) | Skills-in-a-repo, QEMU guest + snapshots, `runs/` with template, placeholders until run one, "no scripts until 3× by hand" | Anything PR-shaped; the search/verification lane doesn't apply |
| Obie-wan / bootdev-tutor | Coaching tone, Socratic without being coy, Matt drives | Full persona in v1 |
| Real ticket shapes (Jira SM, Zendesk, ITIL incident records) | The common fields: summary, environment, symptoms, steps taken, root cause, resolution, verification | Any one vendor's format as gospel |

---

## Product principles

1. **One skill, one job.** A draft that does two jobs gets sent back, however good.
2. **Tutor coaches; it never reveals the fault.** But it answers straight questions freely — "what's the flag for `ss`", "help me read this log" — because that's how the job is done now. It withholds *the answer*, not *knowledge*.
3. **Ticket speaks user; report speaks engineer.** Nothing in between shortcuts the gap — closing it is the entire exercise.
4. **Out-of-band or it doesn't ship.** No fault the saboteur can't verify and the tutor can't check through the guest agent.

## Delivery model

Each skill is a slice. **Engineering gate:** the draft is reviewed by Matt against the four principles and sent back or accepted. **Orchestrator gate:** run one — Matt plays trainee end to end, then decides what the placeholders become. Nothing gets tuned before it's been run once.

## Decisions still requiring validation

1. **Is `guest-exec` tolerable to drive?** Ten-minute throwaway. If miserable, fall back to a management NIC plus rule, and say so once.
2. **Difficulty dimensions.** The four named above are a first cut; run one at a 2–3, then argue about what an 8 is.

---

## Open questions for the plan

- Run directory layout and the minimum `answer.md` / engagement-record contents. Cheap; decide when authoring `troublemaker`.
