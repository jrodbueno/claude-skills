# Workstreams — Build

You are the engineering lead. Your job is to pick what to build, plan how to build it (ideally in parallel), execute, and verify.

## Step 1: Pick

Query the workstreams database for items that are **refined** with all "Blocked by" items **shipped**.

Present the ready list grouped by capability:
```
## Ready to build (N items)

### [Capability]
- [Name] — [Severity] — touches: [likely files/packages]
- [Name] — [Severity] — touches: [likely files/packages]

### [Capability]
- ...
```

### Parallelization analysis

For each pair of ready items, assess whether they can run in parallel:
- **Parallel-safe**: different packages, different schema, different API surfaces
- **Must be serial**: shared schema, shared types, overlapping files

Recommend a batch:
```
## Recommended batch
These N items can run in parallel (no shared surfaces):
1. [Name] — [package/area]
2. [Name] — [package/area]

These must be serial (shared [reason]):
- [Name] then [Name]
```

Wait for the user to confirm or adjust the batch.

## Step 2: Plan

For each item in the batch, read its acceptance criteria from Notion, then:

### Single item
Use `/plan` to expand into concrete file edits. Present the plan for approval.

### Multiple parallel items
Create a plan per item, then propose an agent strategy:
```
## Parallel execution plan

Agent 1 (worktree): [Name]
  - Files: [list]
  - Steps: [summary]

Agent 2 (worktree): [Name]
  - Files: [list]
  - Steps: [summary]

Main thread: [Name] (if any serial item)
```

Wait for approval before executing.

## Step 3: Build

Execute the approved plan:

### Single item
Code it directly. Follow the project's non-negotiables (from CLAUDE.md).

### Parallel items
Spawn agents with `isolation: "worktree"` for independent items. Each agent gets:
- The workstream name and acceptance criteria
- The specific files to touch
- The project's non-negotiables
- Instructions to commit when done

Monitor agents. When all complete, merge worktrees.

### During build
- If you discover a new issue or prerequisite → note it for `/workstreams-add` at the end
- If scope grows beyond acceptance criteria → flag it, don't silently expand
- If a dependency you thought was shipped is actually broken → stop and report

## Step 4: Test (red-green for boundary work)

### For boundary-layer work (RLS, APIs, webhooks, integrations, data transforms):
1. **Red**: Write tests FROM the acceptance criteria BEFORE writing implementation code. Run them. They must fail.
2. **Green**: Write the minimum code to make tests pass.
3. **Refactor**: Clean up with tests protecting you.

### For all work:
1. **Type check**: `pnpm type-check` or equivalent
2. **Lint**: `pnpm lint` or equivalent
3. **Tests**: `pnpm test` or run relevant test suites
4. **Acceptance criteria**: go through each criterion from Notion and verify
5. **UI verification**: if frontend changes, start dev server and check in browser

### What does NOT need TDD:
- React components and page layouts (verify visually)
- Design tokens and styling (visual output)
- Payload collection configs (declarative)

If anything fails, fix it before proceeding. If acceptance criteria can't be fully met, explain what's left and whether to mark as "built" (partial) or "shipped" (complete).

## Step 5: Wrap up

After all items pass verification:

1. **Commit** with conventional commit messages referencing the workstream name
2. **Push** to the current branch

## Step 6: Micro-sync to Notion

Update Notion immediately — don't wait for `/workstreams-sync`. This captures context while it's fresh, especially when multiple build sessions happen before a full sync.

For each workstream touched in this session, use `notion-update-page`.

**The session log is written for someone who will never read code.** It must answer: what was done, does it work, and what's left. No file paths or function names — describe behavior and outcomes.

```json
{
  "Status": "shipped|built",
  "Verified": "__YES__|__NO__",
  "Session log": "[date]: [what was built in plain language]. [test outcome — e.g., '4/4 acceptance tests passing' or 'filters work but URL state not persisting yet']. [if boundary work: 'TDD: N tests written, all green']. Commit: [hash]."
}
```

**Status + Verified rules:**
- All acceptance criteria verified + tests pass → **shipped** + **Verified = YES**
- Partially met, code merged → **built** + **Verified = NO** (session log explains what's left)
- Boundary work without tests → **built** at most, never shipped (tests are required for boundary layers)

**Session log examples (good):**
- "2026-04-25: Inventory sync now runs every 15 min via pg_cron. Handles insert/update/mark_sold with per-tenant error isolation. TDD: 36 tests written, all green. Commit: c01bd56."
- "2026-04-25: Meta CAPI destination wired. Events map to ViewContent/Lead/Purchase. Access token read from tenant config. Needs real test events to verify match rate — can't fully verify without Meta credentials. Commit: c01bd56."

**Session log examples (bad — too technical):**
- "Updated sync.ts to add diffInventory() function, modified packages/integrations/inventory/src/providers/mock.ts"

**Also in micro-sync:**
- Add any discovered work as new inbox items via `notion-create-pages`
- Check if any blocked workstreams are now unblocked (all "Blocked by" items shipped) and flag them

## Step 7: Report

```
## Build complete

### Shipped (updated in Notion, verified)
- [Name]: [what it does now, in plain language]

### Built (needs more work)
- [Name]: [what works, what's left]

### Discovered (added to inbox)
- [Name]: [description]

### Newly unblocked
- [Name]: all prereqs shipped, ready to build next
```

`/workstreams-sync` still runs as a full reconciliation — it catches anything the micro-sync missed, handles multi-session drift, and generates the aggregate report. Micro-sync is the "save your work" step; full sync is the "audit everything" step.

## Picking strategy

When multiple items are ready, prefer:
1. **Blockers first** — they unblock other work
2. **Same-capability batches** — context stays warm
3. **High-parallelism batches** — more throughput per session
4. **Quick wins alongside big items** — a minor + a blocker in parallel

Never pick more parallel items than can reasonably be verified in one session.
