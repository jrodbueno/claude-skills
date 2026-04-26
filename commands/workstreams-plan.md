# Workstreams — Planning Phase

You are analyzing a codebase to extract, structure, and plan workstreams. Your output is a structured plan that can feed into `/workstreams-create` for Notion database provisioning.

## Step 1: Understand the project

Read these files (in order of priority, skip if missing):
1. `CLAUDE.md` — project instructions, stack, constraints
2. `EXECUTION-PLAN.md` or `ROADMAP.md` or `TODO.md` — existing plans
3. `README.md` — project overview
4. `package.json` / `pyproject.toml` / `Cargo.toml` — dependencies and scripts
5. `.github/` or CI config — deployment and testing setup

Extract:
- **What the project does** (1-2 sentences)
- **Stack** (languages, frameworks, infrastructure)
- **Non-negotiables** (constraints that override local decisions)
- **Existing work structure** (if any plan/roadmap exists)

## Step 2: Identify capabilities

A **capability** is a clustered set of workstreams that together unlock a demo-able product feature. Capabilities form a DAG (directed acyclic graph) — some depend on others.

From the project context, identify 3-8 capabilities. Name them as nouns that describe what they unlock, not what they do. Examples:
- "Inventory Pipeline" not "Build inventory sync"
- "Lead Attribution" not "Wire tracking events"
- "Tenant Onboarding" not "Write provisioning script"

For each capability, determine:
- Prerequisites (other capabilities that must be done first)
- Exit gate (what demo-able artifact proves it's done)

## Step 3: Extract workstreams

A **workstream** is a unit of work sized for 1-3 focused coding sessions. For each:
- **Name**: `X.Y Description` (track number . sequence)
- **Capability**: which capability it belongs to
- **Prerequisites**: other workstreams it's blocked by (within or across capabilities)
- **Acceptance criteria**: what "done" looks like (specific, testable)
- **Severity**: blocker (blocks other work), major (important but not blocking), minor (nice to have), cosmetic (polish)

Sources for workstreams:
1. Existing plan documents (migrate as-is, preserving IDs)
2. Git history (`git log --oneline`) — find TODO comments, incomplete features
3. Issue tracker (if accessible via gh CLI)
4. Code inspection — find stubs, mocks, `// TODO`, `// FIXME`, unimplemented interfaces

## Step 4: Map the dependency graph

Draw the DAG:
- Which workstreams have no prerequisites? (these are ready to start)
- What's the critical path? (longest chain from start to "done")
- Which workstreams can run in parallel? (no shared files/schema/types)

## Step 5: Assess current state

Audit git history and code on disk to determine what's already done:
- Check commit messages for explicit workstream references
- Verify code exists on disk (don't trust commit messages alone)
- Mark statuses: shipped (deployed), built (code exists, needs verification), refined (planned), inbox (raw idea)

## Step 6: Present the plan

Output a structured summary:
```
## Capabilities (DAG)
[capability] → [capability] → ...

## Workstreams by capability
### [Capability name]
- X.Y Name — status — severity — blocked by: [list]
  Accept: [criteria]

## Current state
- Shipped: N (X%)
- Built: N (X%)
- Remaining: N (X%)

## Highest-leverage next move
[The workstream that, when done, unblocks the most other workstreams]
```

Ask the user to confirm or adjust before proceeding to `/workstreams create`.

## Choosing capability categories

Suggest 4-6 capability categories based on the project's domain. Default to these if nothing better fits:
- **Core Pipeline** — the main data/content flow
- **User Operations** — what end-users do in the product
- **Admin Operations** — what operators/admins do
- **Integrations** — third-party connections
- **Production Readiness** — hardening, monitoring, performance
- **Platform Infrastructure** — foundational work (build, auth, deploy)

## Choosing horizons

- **v1** — must ship for the first usable release
- **post-v1** — planned but not blocking first release
- **end-state** — vision items, no timeline

## Choosing sources

- **founder** — original product vision
- **board** — stakeholder/investor requirement
- **client-feedback** — user/customer request
- **session-discovery** — discovered during a coding session
- **technical-debt** — cleanup/refactoring need
