# Workstreams — Sync (End of Session)

You are closing out a work session by syncing what was built to the Notion workstreams database. This is the "git → Notion" step.

## Step 1: Find the database

Check memory files for the workstreams database reference (database ID, data source ID). If not found, search Notion for "Workstreams".

## Step 2: Scan git history

```bash
git log --oneline -20
```

Look for:
- Commits since the last sync (check memory for last triage/sync date)
- Commit messages referencing workstream names, IDs, or Refs
- Wave/batch commits listing completed workstreams
- Feature commits that map to known workstreams

## Step 3: Verify on disk

For any workstream that git suggests is done, verify code exists:
```bash
find . -name "relevant-file" | grep -v node_modules
```

Don't trust commit messages alone — confirm the code is there.

## Step 4: Determine status updates

| Evidence | Status |
|---|---|
| Code merged to main, acceptance criteria met | **shipped** |
| Code merged, acceptance criteria partially met | **built** |
| Code on branch, not merged | **in-progress** |
| Prerequisites all shipped, was blocked | **refined** (unblocked) |

**Rules:**
- If it's merged, it's at least "built". Don't be conservative.
- If a commit explicitly says a workstream is completed, mark shipped.
- Always add a session log explaining what changed.

## Step 5: Apply updates

Use `notion-update-page` for each changed workstream:
```json
{
  "Status": "shipped",
  "Session log": "Sync [date]: [evidence]. [commit ref]."
}
```

Fire independent updates in parallel.

### Discover new work

If commits include work not tracked in Notion:
- Foundation/infrastructure → create as shipped
- Bug fixes → create as shipped, source: session-discovery
- New planned items mentioned in commits → create as inbox

## Step 6: Check unblocks

After promoting items to shipped, check if any blocked/refined workstreams now have all their "Blocked by" items shipped. If so, call them out:

```
## Newly unblocked
- [Name] — all prereqs now shipped, ready to build
```

## Step 7: Report

```
## Sync complete — [date]

### What changed
- [Name]: refined → shipped ([evidence])
- [Name]: refined → built ([what's left])
- [Name]: new, added as shipped ([description])

### Current state
| Status | Count | % |
|---|---|---|
| shipped | N | X% |
| built | N | X% |
| refined | N | X% |
| inbox | N | X% |

### Ready to build next
- [Name] — [Capability] — [Severity]
```

## Step 8: Update memory

Update the reference memory file with:
- New counts and status breakdown
- Date of this sync
- Any structural changes

## Report-only mode

If invoked as `/workstreams report`, run Steps 1-3 only. Don't update Notion. Output the status report and recommendations without making changes.
