# Workstreams — Add to Backlog

You are capturing new workstreams into the Notion backlog. Optimize for speed — capture first, refine later.

## Find the database

Check memory files for the workstreams database reference (database ID, data source ID). If not found, search Notion for "Workstreams".

## Parse the user's input

The user describes one or more items in natural language. For each, extract:

- **Name**: short, descriptive (no ID prefix — the Ref field and auto-increment handle that)
- **Capability**: best-fit from existing options. If unsure, ask.
- **Source**: default to `session-discovery` unless the user says otherwise
- **Severity**: infer from context. Default to `major` if unclear.

## Create as inbox (default)

Set these defaults for quick capture:
```json
{
  "Status": "inbox",
  "Horizon": "v1-paid",
  "Source": "session-discovery",
  "Severity": "major",
  "Board-visible": "__NO__",
  "Verified": "__NO__"
}
```

Override any field the user explicitly provides (severity, capability, acceptance criteria, etc.).

## Create as refined (if user says so)

If the user says "as refined" or provides acceptance criteria, set:
- `Status`: "refined"
- `Acceptance criteria`: what the user provided
- Fill in `Capability`, `Severity`, `Client impact`, and `Blocked by` if the user provided them

## After creation

Report what was added:
```
Added to inbox:
- WS-73: Upload route hardening (Platform Infrastructure, major)
- WS-74: Retry on 429 from Intelimotor (Inventory Pipeline, minor)

Run /workstreams-refine to scope these for execution.
```

## Batch mode

If the user provides multiple items, create them all in one `notion-create-pages` call.
