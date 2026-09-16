---
name: troublemaker-ticket
description: Placeholder. The ticket-writing step of Troublemaker — turns the saboteur's sealed answer into the kind of support ticket a help-desk tech would actually receive: symptom in the reporter's words, at the precision the difficulty dial sets, never the cause. Not yet written; it will be built from the common shape of real ticketing platforms (Jira SM, Zendesk, Freshdesk, ServiceNow and the like) without copying any one of them. Until then, when an engagement reaches the Ticket step, use the interim shape in this file.
---

# Troublemaker ticket (placeholder)

Deliberately thin until one engagement has used it. The research is in: `docs/ticket-and-report-research.md` — the common field set across Zendesk, Freshservice, JSM, ServiceNow and the ITIL incident record, and the two borrowings worth making (priority is *derived* from impact × urgency, and the reporter's text is a separate channel from the tech's). Split out from the tutor on 2026-09-16 for the same reason reporting is separate: it will need tweaking on its own, and a ticket that leaks or a ticket that's too kind is a ticket problem, not a coaching problem.

The intent:

- Input is `answer.md` (via the saboteur's return message, not by reading the file where Matt might see it). Output is `ticket.md`.
- The reporter is a plausible person by role, not a sysadmin. They describe what they *see*, not what's wrong. They may be wrong about the category at 7+, and at 9+ they've "tried something".
- Precision is set by the difficulty dial in the main skill: precise and hostnamed at 1–3; user-language single complaint at 4–6; vague or intermittent at 7–8; vague plus a self-inflicted complication at 9–10.
- Shape borrows the fields that every real platform shares and integrates with none of them.

Interim shape, from the research, until run one has used it:

```
# TM-<run id>                                    Status: Open

**Reporter:** <name, role — "Dave, accounts">   **Channel:** <email | phone | walk-up | portal>
**Opened:** <date time>   **Affected host:** <as the reporter knows it — "my desktop", "the file server">
**Category (reporter's guess):** <"internet", "login", "printer"… wrong at 7+>
**Impact (reporter's words):** <"just me" | "the whole team">   **Urgency (reporter's words):** <"whenever" | "I can't work">
**Priority:** <blank — the tech assigns it>

## Subject
<one line, ≤80 characters, the reporter's words>

## Description
<what they were doing, what happened, when it started, what they tried, what still works — detail set by the precision dial>
```

Priority is left blank on purpose: every real desk derives it from impact × urgency, and deciding it is part of the tech's job. Nothing from the tech's side ever appears here; that is the report's channel.

The reporter doesn't know what a default gateway is. Write it as they would.
