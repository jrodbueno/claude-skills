# Workstreams — Triaging Phase

You are syncing the state of a codebase with its Notion workstreams database. Your job is to reconcile what the code says (git history, files on disk) with what Notion says (workstream statuses), update Notion to reflect reality, and surface what's actionable.

## Step 1: Find the database

Check memory files for a workstreams database reference. You need:
- Database ID or URL
- Data source ID (for querying and updating)

If not found in memory, search Notion:
```
notion-search: query="Workstreams", content_search_mode="workspace_search"
```

Fetch the database to get the current schema and data source ID.

## Step 2: Read current Notion state

Query each view to understand current state:
- Query the Sprint or Backlog view to get all workstreams with their statuses
- Note which items are "refined" (not started), "in-progress", "built", "shipped"

## Step 3: Audit the codebase

Compare Notion state against reality:

### 3a. Git history scan
```bash
git log --oneline --all | head -80
```

Look for:
- Commit messages referencing workstream IDs (e.g., "workstream 5.2", "WS-42")
- Feature commits that map to known workstreams
- Wave/batch commits that list completed workstreams
- Merge commits from feature branches

### 3b. Code verification
For any workstream that git suggests is done, verify code exists on disk:
```bash
find . -name "relevant-file" | grep -v node_modules
wc -l path/to/file  # Not empty/stub
```

### 3c. New work detection
Look for work done that isn't tracked:
- Files/features that don't map to any existing workstream
- Foundation work (scaffolding, configs, tooling) not captured
- Bug fixes or improvements that represent real progress

## Step 4: Determine updates

For each workstream, determine the correct status:

| Evidence | Status |
|---|---|
| Code merged to main, deployed, acceptance criteria met | **shipped** |
| Code merged, deployed, but acceptance criteria partially met | **built** |
| Code exists on a branch, not merged | **in-progress** |
| Planned with clear acceptance criteria | **refined** |
| Blocked by unfinished prerequisite | **blocked** (check "Blocked by" relation) |
| Raw idea, no scope | **inbox** |

**Key rules:**
- If it's merged and deployed, it's at least "built". Don't be conservative.
- If a commit explicitly says "workstream X.Y completed", trust it — mark shipped.
- If prerequisites are all shipped, the workstream is unblocked (remove "blocked" status).
- Always add a session log entry explaining what changed and why.

## Step 5: Apply updates

Use `notion-update-page` with `update_properties` to update statuses and session logs. Fire independent updates in parallel.

For each update:
```json
{
  "Status": "shipped",
  "Session log": "Triage 2026-04-25: [evidence]. [commit ref if applicable]."
}
```

### Add new workstreams
If you found work not tracked in Notion, create new pages with `notion-create-pages`:
- Foundation items (scaffolding, configs) → status "shipped", source "founder"
- Bug fixes discovered → status "shipped", source "session-discovery"
- New planned work → status "refined" or "inbox"

### Update dependency relations
If a blocked workstream's prerequisites are now all shipped, consider:
1. Updating its status from "blocked" to "refined" (ready to start)
2. Checking if the "Blocked by" items are all actually shipped

## Step 6: Generate the status report

Output a clear summary:

```
## Workstreams Status — [date]

### Progress
| Status | Count | % | Change |
|---|---|---|---|
| shipped | N | X% | +N |
| built | N | X% | +N |
| refined | N | X% | -N |
| blocked | N | X% | -N |
| inbox | N | X% | — |

### What changed this triage
- [workstream]: refined → shipped (evidence)
- [workstream]: new, added as shipped (foundation work)

### What's ready now
Workstreams whose prerequisites are all shipped:
- [workstream] — [capability] — [severity]

### What's blocked
- [workstream] — blocked by: [list of unfinished prereqs]

### Highest-leverage next move
[The workstream that unblocks the most other work]

### Risks
- [Any workstream marked blocker that has no progress]
```

## Step 7: Update memory

Update the reference memory file with:
- New workstream count and status breakdown
- Date of last triage
- Any structural changes (new capabilities, new workstreams added)

## Triage modes

### Full triage (default)
Run all steps. Update Notion. Generate report.

### Report only (`/workstreams report`)
Run Steps 1-4 only. Don't update Notion. Just output the status report and recommendations.

### Quick sync (`/workstreams triage quick`)
Only check git log since last triage date (from memory). Update changed items only. Faster for daily use.

## Recurring triage

After completing a triage, suggest scheduling a recurring triage:
> "Want me to `/schedule` a weekly triage agent to keep this database in sync?"

This is especially valuable for active projects where multiple people (or agents) are shipping code.
