# Workstreams — Refine Inbox

You are refining raw workstream ideas (status: inbox) into scoped, actionable work (status: refined). This is the bridge between "I noticed something" and "I can start coding."

## Step 1: Find the database and pull inbox items

Check memory files for the workstreams database reference. Fetch the database, then query the "My Actions" view or filter for `Status = inbox`.

List all inbox items for the user:
```
## Inbox (N items)
1. [Name] — [Capability] — [Severity] — added [date]
2. ...
```

Ask: "Which items should we refine? Or all of them?"

## Step 2: Refine each item

For each item the user wants to refine, work through this checklist:

### Required for refined status
- **Acceptance criteria**: specific, testable. What does "done" look like? Write 1-3 bullet points.
- **Capability**: confirm or reassign (Inventory Pipeline / Lead Pipeline / Tenant Onboarding / Dealer Operations / Production Readiness / Platform Infrastructure — or project-specific options)
- **Severity**: blocker (blocks other work), major (important), minor (nice to have), cosmetic (polish)
- **Horizon**: v1-paid / post-v1 / end-state

### Optional but valuable
- **Blocked by**: check if this depends on any existing workstream. Search the database by name if needed.
- **Client impact**: who does this affect? (tags from the multi-select)
- **Board-visible**: should stakeholders see this?
- **Ref**: assign a track.sequence ID if it fits an existing track, or leave blank for new work

## Step 3: Apply updates

For each refined item, update via `notion-update-page`:
```json
{
  "Status": "refined",
  "Acceptance criteria": "...",
  "Capability": "...",
  "Severity": "...",
  "Horizon": "...",
  "Client impact": "[...]",
  "Session log": "Refined [date]: [one-line summary of scoping decisions]"
}
```

Wire "Blocked by" relations if dependencies were identified.

## Step 4: Triage decisions

Not everything in inbox deserves to be refined. For each item, the user might decide:

- **Refine** → move to refined with full scoping
- **Merge** → this is a sub-task of an existing workstream. Update the existing workstream's acceptance criteria instead, then delete this one.
- **Defer** → set Horizon to post-v1, keep as inbox
- **Drop** → delete from the database (confirm with user first)

## Step 5: Report

```
## Refined this session
- [Name]: [one-line acceptance criteria summary]
- [Name]: [one-line acceptance criteria summary]

## Deferred
- [Name] → post-v1

## Merged into existing
- [Name] → merged into [existing workstream name]

## Ready to build
These refined items have all prerequisites shipped:
- [Name] — [Capability] — [Severity]
```

## Collaborative mode

If the user wants to refine interactively (one at a time), present each item and ask:
1. "What does done look like for this?"
2. "Is this blocked by anything?"
3. "Severity — blocker, major, minor, or cosmetic?"

Then apply and move to the next. This is the default if there are 5 or fewer inbox items.

For larger batches (6+), offer: "Want to go one-by-one, or should I draft all the acceptance criteria and you review?"
