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

## Step 4: Test

After building, verify the work meets acceptance criteria:

1. **Type check**: `pnpm type-check` or equivalent
2. **Lint**: `pnpm lint` or equivalent
3. **Tests**: `pnpm test` or run relevant test suites
4. **Acceptance criteria**: go through each criterion from Notion and verify
5. **UI verification**: if frontend changes, start dev server and check in browser

Report results:
```
## Verification

### [Workstream name]
- [ ] Type check: pass/fail
- [ ] Lint: pass/fail
- [ ] Tests: pass/fail (N passing, N failing)
- [ ] Acceptance criteria:
  - [criterion 1]: verified / not met / partial
  - [criterion 2]: verified / not met / partial
```

If anything fails, fix it before proceeding. If acceptance criteria can't be fully met, explain what's left and whether to mark as "built" (partial) or "shipped" (complete).

## Step 5: Wrap up

After all items pass verification:

1. **Commit** with conventional commit messages referencing the workstream name
2. **Push** to the current branch
3. **Report discoveries**: list any new work found during build for `/workstreams-add`
4. **Suggest sync**: "Run `/workstreams-sync` to update Notion with what was shipped."

```
## Build complete

### Shipped
- [Name]: [one-line summary of what was built]
- [Name]: [one-line summary of what was built]

### Discovered during build (add to backlog)
- [description of new work found]

### Next step
Run `/workstreams-sync` to update Notion.
```

## Picking strategy

When multiple items are ready, prefer:
1. **Blockers first** — they unblock other work
2. **Same-capability batches** — context stays warm
3. **High-parallelism batches** — more throughput per session
4. **Quick wins alongside big items** — a minor + a blocker in parallel

Never pick more parallel items than can reasonably be verified in one session.
