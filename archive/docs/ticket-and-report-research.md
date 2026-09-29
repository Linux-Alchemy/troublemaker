# Ticket and report shapes — research notes (2026-09-16)

What real help-desk platforms and ITIL practice have in common. Gathered to inform `troublemaker-ticket` and `troublemaker-reporting`; not a template from any one vendor.

## Platforms looked at

Jira Service Management (Atlassian docs), Zendesk (help centre + API docs), Freshservice/Freshdesk (support docs), ServiceNow (community guide to incident text fields, 2017 but still the canonical four-field model), ITIL incident record checklist (IT Process Wiki, updated Dec 2023), plus two current practitioner guides on resolution notes (Giva, Aug 2026; ITU Online, May 2026).

## The ticket: what every platform shows a tech

Confirmed across all of them. Names vary; the fields don't.

| Common field | Zendesk | Freshservice | JSM | ServiceNow | ITIL record |
|---|---|---|---|---|---|
| **ID** | Ticket ID | Ticket # | Key (`IT-123`) | Number (`INC0010042`) | Unique ID |
| **Requester** | Requester | Requester (email) | Reporter | Caller | Caller/user data |
| **Subject** (one line) | Subject | Subject | Summary | Short description (80 chars, "like a good email subject") | Description of symptoms |
| **Description** | Description | Description | Description | Additional comments / Description | Description of symptoms |
| **Status** | Status | Status | Status | State | Status |
| **Priority** | Priority | Priority (from Urgency × Impact) | Priority | Priority (Impact × Urgency) | Priority (Urgency, Impact) |
| **Category** | Type / tags | Category | Category / Component | Category, Subcategory | Incident category |
| **Assignee / group** | Assignee, Group | Agent, Group | Assignee | Assigned to, Assignment group | Service Desk agent |
| **Affected thing** | — (custom) | Asset | Affected services / CI | Configuration item | Relationships to CIs |
| **Timestamps** | Created, Updated | Created, Due by | Created | Opened, Updated | Date/time of recording |
| **Channel** | Via | Source | Request channel | Contact type | Method of notification |

Two things a practice ticket should borrow beyond the field list:

- **Priority is derived**, not declared. ITIL, Freshservice and ServiceNow all compute it from *Impact* (how many / how much is affected) × *Urgency* (how fast it hurts). A reporter says "I can't work"; the desk decides P2. The ticket skill should record impact and urgency as the reporter would state them and leave priority as the desk's call — a small realism win, and a thing a tech is expected to judge.
- **The reporter's text and the tech's text are separate channels.** ServiceNow's four-field model is the clearest: *Short description* and *Additional comments* are the reporter's and visible to them; *Work notes* are the tech's and hidden from the reporter; *Close notes* are the resolution, visible to all. Zendesk has the same split as public replies versus internal notes. A practice ticket therefore only ever contains the reporter's side; everything the tech learns goes in work notes, i.e. the report.

## The report: what a resolution record contains

Two layers agree, one from ITIL and one from current practitioner guidance.

**ITIL closure data** (IT Process Wiki, Dec 2023): protocol of actions with person, time and description; status change history; documentation of applied workarounds; documentation of the root cause; documentation of the applied resolution; resolution date; closure date; closure category / resolution type; customer feedback/confirmation.

**Practitioner shape** — the same four movements turn up everywhere, sometimes as five:

| Movement | Giva (Aug 2026) | ITU Online (May 2026) | ServiceNow |
|---|---|---|---|
| **Symptom** — in the user's words, not jargon | Symptom | Problem description: symptoms in objective terms, exact error messages | Short description + Additional comments |
| **Investigation** — chronological, each step and what it showed, *including dead ends* | (implicit in Fix) | Troubleshooting: actions in order, tools used, outcome of each, decision points | Work notes |
| **Cause** — one clear statement so nobody re-diagnoses | Cause | Root cause | Close notes |
| **Fix** — the exact change: config line, command, error code | Fix | Resolution: specific changes, permanent vs temporary vs preventive | Close notes |
| **Confirm** — verified with the requester, not just "works for me" | Confirm & Reuse (required, "not optional") | Validation results | Close notes copied to Additional comments so the caller sees it |

Recurring emphases across the guides:

- **Chronological order** in the investigation, because it shows cause and effect and is how the next tech reads it.
- **"What fixed it, not that it was fixed."** Vague resolutions ("restarted, working now") are the named anti-pattern in every source.
- **Root-cause category** as a tag: user education / configuration / permissions / defect / vendor / known outage. Cheap, and it's what makes trend analysis possible later.
- **Permanent vs workaround** must be stated. ITIL separates "workaround applied" from "root cause eliminated"; Giva and ITU both call it out.
- **Confirmation from the requester** is a required step, not a courtesy; unconfirmed closes are what reopen.
- **Reusability**: a plain-language tag or phrase so the note can be found by the next person with the same symptom.

## What this means for the two skills

**Ticket** = ID · Reporter (by role) · Channel · Opened · Subject (one line, reporter's words, ≤80 chars) · Description (reporter's words; what they tried, when it started, what still works) · Impact and Urgency as the reporter states them · Category as the reporter guesses it · Affected host as they know it · Status `Open`. Nothing from the tech's side. Priority left for Matt to assign — it's part of the exercise.

**Report** = the ticket's ID and subject · Priority as assessed (Impact × Urgency) · Category as it turned out · Symptom (restated objectively, exact errors) · Investigation (chronological, each check and its result, dead ends kept) · Root cause (one or two sentences, plus a root-cause category tag) · Fix (exact commands / diffs; permanent or workaround) · Verification (from the user's side, and the requester-confirmation line) · Follow-up / prevention · Time to resolve · a reuse tag.

## Gaps and confidence

- Field lists for Zendesk, Freshservice and ITIL confirmed from primary docs. JSM's incident default-fields page wouldn't render through the fetcher; its field set is taken from the search summary and the JSM product guide, medium confidence but consistent with the rest.
- osTicket, Spiceworks, HaloITSM not fetched individually; their public docs show the same field set and nothing distinctive, so not pursued. Low risk.
- No source gives a *standard* report format — that's the point. The five movements are the consensus, and the wording is ours.
