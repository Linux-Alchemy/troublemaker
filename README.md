# Troublemaker

A designed workflow, not a tool: an agent breaks one thing on a lab VM on Shadowvault, hands Matt a support-ticket-shaped symptom, coaches him to find and fix it from the shell, and helps him write it up the way real support work gets written up. Training for tech support roles and the CCNA. Lab only; no outside machines, ever.

- `OUTLINE.md` — what this is and why, one page.
- `SCRATCH.md` — the working log behind the outline. Decisions with reasons.
- `skills/` — five skills. `troublemaker` is loaded first and points at the rest.
  - `troublemaker` — purpose, roles, the out-of-band standard, difficulty dials, the loop, run layout. `references/guest-agent.md` is the channel.
  - `troublemaker-saboteur` — dispatched as a subagent; picks and applies a fault, verifies it, seals `answer.md`. `references/catalogue-*.md` are the starter fault banks.
  - `troublemaker-ticket` — placeholder; turns the sealed answer into a help-desk-shaped ticket.
  - `troublemaker-tutor` — placeholder until run one; the coaching half.
  - `troublemaker-reporting` — placeholder until run one; the write-up standard.
- `runs/` — one directory per engagement from `runs/TEMPLATE.md`; `runs/ENGAGEMENTS.md` is the record the saboteur reads.

To use the skills from Claude Code, symlink them into `~/.claude/skills/`:

```bash
for s in skills/*/; do ln -sfn "$(pwd)/$s" ~/.claude/skills/$(basename "$s"); done
```

Anything done by hand three times gets a script; nothing gets one sooner.
