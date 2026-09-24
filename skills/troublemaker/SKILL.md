---
name: troublemaker
description: The standing rules and environment for Troublemaker, Matt's troubleshooting-practice workflow — an agent breaks one thing on a lab VM on Shadowvault, hands Matt a support-ticket-shaped symptom, coaches him to find and fix it from the shell, and helps him write it up. Load this first, every session, whenever Matt mentions Troublemaker, a practice engagement, "break something for me", "give me a ticket", a difficulty like "make it a 4", the lab VMs, the saboteur or tutor, or writing up a troubleshooting report, even if he doesn't say the name. It carries the purpose, the roles, the out-of-band standard, difficulty, the loop, the run layout, and which troublemaker-* skill to load at each step.
---

# Troublemaker

Troublemaker is a training loop with two hats and one trainee. The **saboteur** breaks something small and plausible on a lab VM and seals the answer. The **tutor** — same agent, hat switched — turns the answer into the kind of ticket a support tech would actually receive, then coaches Matt through finding it, fixing it, and writing it up. Nobody outside the lab is involved, ever. This skill is the part that is the same every engagement; read it at the start of every session so the setup never has to be explained twice.

## Why this exists

Matt is going after tech support roles and sitting the CCNA in December 2026. The thing those jobs test — working a vague complaint down to a root cause, methodically, then writing it up so the next person can act on it — is a muscle, and it only grows on broken things. Nothing on his desk is broken. Troublemaker manufactures the broken things.

Two rules shape everything else. **The tutor holds the answer and never hands it over** — but it answers straight questions freely, because "what's the flag for `ss` again" and "help me read this log" are how the job is actually done now. What it withholds is the *fault*, not *knowledge*. And **the ticket speaks user, the report speaks engineer** — closing that gap is the whole exercise, so nothing in between is allowed to shortcut it.

## Roles

**Matt is the trainee.** He gives the target(s) and a difficulty, then works the ticket the way a tech would: from the shell, on the guest, reading outputs. He decides when he's found it, when it's fixed, and when the report is done. He asks the tutor anything he likes; the tutor decides what kind of question it is.

**The saboteur** runs as a *subagent* so Matt never sees the break happen. It picks a fault the catalogue and the difficulty allow, applies it through the out-of-band channel, verifies the symptom is real and the guest is still reachable, writes `answer.md`, and returns the answer to the parent session in its final message — which Matt does not see. It touches nothing but the named target(s).

**The tutor** is the parent session after the saboteur returns. It holds the answer, writes the ticket, and coaches. It checks Matt's fix from the outside through the same out-of-band channel, so "it works now" has evidence behind it.

**Ticket** turns the answer into what the help desk would see. **Reporting** owns the write-up standard. Neither has an opinion on the investigation.

## The environment

| Thing | Fact |
|---|---|
| VM host | One Linux host running QEMU/KVM via libvirt. **Its specifics (addresses, pools, access path, non-lab VMs and networks) live in `local/host.md`. Read it first.** If it's missing, stop and point to `docs/getting-started.md`. |
| Where the session runs | **On the host**, where the skills are installed. Every `virsh` call is `virsh -c qemu:///system …`; plain `virsh` talks to the per-user session and shows nothing. |
| Targets | `tm-*` libvirt domains, **one NIC each** (end users don't run management NICs, and the lab shouldn't either). The exception is `tm-router`, which has WAN and LAN NICs because routing is its job. The lab is a small office behind that router; the design is in `docs/lab-design.md`. It's built in stages (pre-v1 design; v1 router + one server + one workstation; v2 a second server and workstation; v3, optional, a physical laptop over the office VPN), and **only targets already handed over for the current stage are valid.** Matt names the **domain(s)** when he opens an engagement. `troublemaker-lab` builds the lab in separate sessions; the engagement roles (saboteur, tutor) never create or reconfigure VMs or networks. The v3 laptop has no guest agent. Its out-of-band channel is SSH over a path outside the lab (`troublemaker-lab/references/remote-worker-vpn.md`), and it isn't a valid target until that channel is tested. Every VM and network listed as non-lab in `local/host.md` is never touched. |
| Guest access, agent side | **QEMU guest agent only.** `qemu-guest-agent` inside the guest, `org.qemu.guest_agent.0` channel on the domain. `scripts/gx.sh <dom> '<cmd>'` is how commands run; `references/guest-agent.md` explains the channel. The agent never SSHes to a target. |
| Guest access, trainee side | Matt's choice: SSH over the lab network, `virsh console`, or `virt-viewer`. That's his crash cart; the tutor may remind him it exists. |
| Host libvirt facts | Lab disks in pool `lab-vms`, ISOs in pool `iso-files` (paths in `local/host.md`). Lab networks are `tm-*`; the `default` network isn't part of the lab. `jq` is required by `gx.sh`. The builder adds the `org.qemu.guest_agent.0` channel explicitly to every lab VM. |
| Snapshots | libvirt snapshots per domain. `clean` after `troublemaker-lab` hands the guest over. `pre-<run>` taken by the saboteur before it breaks anything. Reset is `virsh snapshot-revert <dom> pre-<run>`, by hand, until it has been done three times. |
| Repo | This repository. Skills in `skills/`, runs in `runs/`, host specifics in `local/`. |

**Host rule.** Nothing changes on the host except the named target domain, and only via the guest agent and domain-scoped `virsh` (snapshots, `qemu-agent-command`). No host networking, no host packages, no other domains, no `virsh destroy`.

## The out-of-band standard

Decided once, 2026-09-16, and not revisited per engagement: **the saboteur and the tutor reach the guest through the QEMU guest agent, never the network.** The guest's network stack is therefore entirely fair game — interface down, firewall lockout, "it has fallen off the network completely" are all legitimate faults — and the agent can still verify the break and check the fix. The rejected alternative was a management NIC the agent is told not to touch; that is a rule, and rules get forgotten at difficulty 8. A virtio-serial channel cannot be forgotten.

One consequence for the trainee: a fault that takes the guest's only NIC down means Matt can't SSH in either, and reaches the box through `virsh console` or remote-viewer instead — the lab's iDRAC. That is realistic, and it is also harder, so **NIC-killing faults are difficulty 5 and above.**

Corollaries the saboteur must respect: never stop, mask or uninstall `qemu-guest-agent`; never break the virtio-serial channel; never power the guest off; after every break, `guest-ping` must still answer. A fault that kills the channel kills the engagement.

## Difficulty

Matt gives a number, 1–10. The number sets four dials the saboteur turns; it is not an index into ten hand-written tiers.

| Dial | 1–3 | 4–6 | 7–8 | 9–10 |
|---|---|---|---|---|
| **Faults** | One | One | Two that interact | Two or three, cascading |
| **Ticket precision** | Precise symptom, named host | User-language, one clear complaint | Vague or intermittent; user's own diagnosis is wrong | Vague, plus the user "tried something" that made it worse |
| **Depth** | Obvious place: a service down, a config file | One hop away: a route, a resolver, a firewall rule | Deep: MTU, sysctl, rule ordering, two managers fighting | Deep and layered |
| **Red herrings** | None | One benign oddity at 5–6 | One that *looks* causal | One that looks causal, one benign |

Run one is pinned at 2–3: it is testing the loop, not the saboteur's imagination. What an 8 really means gets argued after that.

## Categories and the engagement record

Three categories, with equal weight: **networking** (lines up with the CCNA), **security** (permissions and access), and **systems** (services, storage, packages, scheduling: the everyday support ticket). The saboteur picks one **at random for each run**, using a real random draw, not its own judgement, so Matt can't predict it and no category gets favoured. Matt can name a category when he opens a run, and that overrides the draw. The category stays sealed with the answer; the ticket never names it. Decided 2026-09-24; this replaces the earlier networking-first 70/30 staging. `runs/ENGAGEMENTS.md` is how Matt sees what he has and hasn't practised.

## The loop

Load the named skill at each step. Each step's evidence is what the next one stands on.

1. **Open.** Matt names the target domain(s) and a difficulty, optionally a category. Create `runs/<YYYY-MM-DD>-<domain>-<nn>/` from `runs/TEMPLATE.md`. Check `guest-ping` answers on every named domain and that the `pre-<run>` snapshot can be taken. If either fails, stop; the lab isn't ready and that goes back to a `troublemaker-lab` build session, not this one.
2. **Break** → dispatch `troublemaker-saboteur` as a subagent with the run directory, domain(s), difficulty, and category. Wait for "sealed". The subagent's final message carries the answer to the parent; **do not `cat answer.md` in the parent session** unless context has been lost — the file is the durable copy, the return message is the working one. Matt could expand a tool result; he can't expand a subagent's report.
3. **Ticket** → `troublemaker-ticket`. Write `ticket.md` from the answer. Symptom, user-language, at the precision the difficulty dial says. Never the cause, never the file, never the command.
4. **Investigate** → `troublemaker-tutor`. Matt works the guest from the shell. The tutor coaches: questions, not answers; commands and log-reading on request; the fault never. When Matt says "found it", the tutor confirms or asks what evidence he has. When he says "fixed", the tutor checks from the outside via the guest agent and says what it saw.
5. **Report** → `troublemaker-reporting`. Matt writes `report.md`; reporting holds the standard and reviews against it.
6. **Close.** Append a line to `runs/ENGAGEMENTS.md`. Matt reverts to `pre-<run>` by hand. Tea.

## Run directory

```
runs/<run id>/
  NOTES.md      the run log: target, difficulty, timeline, what Matt tried, tutor observations, lessons
  answer.md     sealed by the saboteur: fault(s), exact commands applied, exact undo, expected symptom, verification output
  ticket.md     written by the ticket skill
  report.md     written by Matt
```

`runs/ENGAGEMENTS.md` is one table, one line per closed run: id, date, domain, category, difficulty, result (`solved` / `solved-with-hints` / `unsolved`), time, one note. The saboteur reads it to choose a category; Matt reads it to see his own record.

## When to stop and ask

Stop and ask Matt rather than guess when: a named domain doesn't answer `guest-ping`; the snapshot can't be taken; a step would touch anything on SV other than the named domain; the difficulty asks for a lab network and only one domain was named; or a break has left the guest agent unresponsive. That last one is a finding — capture what you can in `NOTES.md`, tell Matt, and let him revert. Do not keep prodding it.
