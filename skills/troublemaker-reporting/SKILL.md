---
name: troublemaker-reporting
description: Placeholder. The write-up half of Troublemaker — the standard a troubleshooting report is held to once Matt has fixed the fault, shaped like real ticket resolution notes without copying any one vendor's format. Not yet written; it will be built from real ticketing conventions and the first engagement's report. Until then, when an engagement reaches the Report step, use the field list in this file and review Matt's report against it.
---

# Troublemaker reporting (placeholder)

Deliberately thin until one engagement has produced a report. The research is in: `docs/ticket-and-report-research.md` — ITIL closure data plus the five movements every current practitioner guide agrees on (symptom, investigation, cause, fix, confirm). The intent, agreed 2026-09-16:

- The report speaks engineer; the ticket spoke user. The report's job is that the next tech — or the same one in six months — can act on it without re-investigating.
- Generic-ticket-shaped, borrowing the fields every real system (Jira SM, Zendesk, ITIL incident records) has in common, integrating with none of them.
- Reviewed against the standard, not rewritten by the agent. Matt writes it.

Interim standard, from the research, so run one has something to be judged against:

```
# Report — TM-<run id>

**Subject:** <from the ticket>   **Priority (assessed):** <P1–P4, from impact × urgency, one line why>
**Category (as it turned out):** <networking | permissions | …>   **Root-cause tag:** <configuration | permissions | user education | defect | vendor | outage>
**Time to resolve:** <n>   **Outcome:** <permanent fix | workaround — root cause still open>

## Symptom
Restated objectively: exact errors, exact commands that failed, what still worked.

## Investigation
Chronological. Each check, what it showed, what it ruled out. Dead ends stay in — they're what save the next tech time.

## Root cause
One or two sentences. What was wrong, and why it produced that symptom.

## Fix
Exactly what changed: commands, file diffs. Permanent or workaround, stated.

## Verification
How it was confirmed fixed from the user's side, and the requester-confirmation line ("Dave confirmed…"). Unconfirmed closes reopen.

## Follow-up / prevention
What would stop it recurring, or "none".

**Reuse tag:** <a plain-language phrase the next person would search for>
```

The named anti-pattern in every source is "restarted, working now" — *what* fixed it, not *that* it was fixed.

Until the skill is written, review reports against that list and record in `NOTES.md`'s Lessons what the standard should actually say.
