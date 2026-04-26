# Workstreams — Creation Phase

You are provisioning a Notion database to track workstreams. This skill creates the database, schema, views, populates workstreams, and wires dependency relations.

## Prerequisites

- A plan must exist (from `/workstreams plan` or from an existing document like EXECUTION-PLAN.md)
- The user must have confirmed the capability categories and workstream list
- Notion MCP tools must be available (search, create-database, create-pages, create-view, update-page, update-data-source, fetch)

## Step 1: Find the parent page

Search Notion for the project's page:
```
notion-search: query="[project name]", content_search_mode="workspace_search"
```

If multiple results, ask the user which page to use. If none found, ask for the page URL or create at workspace root.

## Step 2: Create the database

Use `notion-create-database` with this schema (adapt capability options to the project):

```sql
CREATE TABLE (
  "Name" TITLE,
  "Capability" SELECT([project-specific options with colors]),
  "Horizon" SELECT('v1':green, 'post-v1':blue, 'end-state':gray),
  "Status" SELECT(
    'inbox':default,
    'refining':gray,
    'refined':brown,
    'in-progress':blue,
    'built':purple,
    'tested':orange,
    'shipped':green,
    'blocked':red
  ),
  "Source" SELECT(
    'founder':blue,
    'board':purple,
    'client-feedback':green,
    'session-discovery':orange,
    'technical-debt':red
  ),
  "Client impact" MULTI_SELECT([project-specific impact tags]),
  "Acceptance criteria" RICH_TEXT,
  "Session log" RICH_TEXT,
  "Severity" SELECT('blocker':red, 'major':orange, 'minor':yellow, 'cosmetic':gray),
  "Verified" CHECKBOX,
  "Board-visible" CHECKBOX,
  "ID" UNIQUE_ID PREFIX 'WS'
)
```

**Adapt for the project:**
- Capability options: use the categories from the planning phase
- Client impact tags: derive from project stakeholders (e.g., "end-user", "admin", "API consumer", "infrastructure")
- Horizon labels: use the project's milestone names if they exist

## Step 3: Add the self-relation

After creation, use `notion-update-data-source` to add:
```sql
ADD COLUMN "Blocked by" RELATION('<data_source_id>', DUAL 'Blocks' 'blocks_rel')
```

This creates both "Blocked by" and "Blocks" as a linked pair.

## Step 4: Create 6 views

All views use the same `database_id` and `data_source_id`:

1. **Sprint** (board) — kanban grouped by Status, filtered to v1 horizon
   ```
   GROUP BY "Status"
   FILTER "Horizon" = "v1"
   SHOW "Name", "Capability", "Severity", "Blocked by", "Client impact", "Verified"
   ```

2. **Backlog** (table) — grouped by Capability, sorted by Severity
   ```
   GROUP BY "Capability"
   SORT BY "Severity" ASC
   SHOW "Name", "Capability", "Horizon", "Status", "Severity", "Source", "Blocked by", "Client impact", "Acceptance criteria"
   ```

3. **Blocked** (table) — filtered to blocked status
   ```
   FILTER "Status" = "blocked"
   SHOW "Name", "Capability", "Blocked by", "Severity", "Client impact", "Session log"
   ```

4. **V1 Gap** (table) — v1 items not yet shipped, grouped by Capability
   ```
   FILTER "Horizon" = "v1" AND "Status" != "shipped"
   GROUP BY "Capability"
   SHOW "Name", "Capability", "Status", "Severity", "Blocked by", "Verified", "Acceptance criteria"
   ```

5. **Board Report** (table) — board-visible items only
   ```
   FILTER "Board-visible" = "__YES__"
   SHOW "Name", "Capability", "Horizon", "Status", "Severity", "Client impact"
   ```

6. **My Actions** (table) — actionable items (inbox + refining + built + blocked)
   ```
   FILTER "Status" = "inbox" OR "Status" = "refining" OR "Status" = "built" OR "Status" = "blocked"
   SORT BY "Severity" ASC
   SHOW "Name", "Capability", "Status", "Severity", "Blocked by", "Session log"
   ```

## Step 5: Populate workstreams

Use `notion-create-pages` in batches of up to 30 pages per call. For each workstream:

```json
{
  "Name": "X.Y Workstream name",
  "Capability": "Category name",
  "Horizon": "v1",
  "Status": "refined|shipped|built|inbox",
  "Source": "founder|session-discovery|...",
  "Client impact": "[\"tag1\", \"tag2\"]",
  "Acceptance criteria": "What done looks like",
  "Severity": "blocker|major|minor|cosmetic",
  "Board-visible": "__YES__|__NO__",
  "Verified": "__YES__|__NO__"
}
```

**Status mapping from existing plans:**
- `done` / `complete` / `shipped` → "shipped"
- `in progress` / `started` → "built" (if code exists) or "in-progress"
- `planned` / `scoped` / `ready` → "refined"
- `idea` / `raw` / `deferred` → "inbox"
- `blocked` → "blocked"

## Step 6: Wire dependency relations

After all pages are created, update each workstream that has prerequisites:

```json
{
  "Blocked by": "[\"https://www.notion.so/<prerequisite-page-id>\", ...]"
}
```

Use `notion-update-page` with command `update_properties`. Fire all updates in parallel since they're independent.

**Important:** Save all page IDs from Step 5 so you can reference them here. Map workstream names/IDs to Notion page URLs.

## Step 7: Save a reference memory

Write a memory file with:
- Database ID and data source ID
- Database URL
- Capability → select option mapping
- Workstream count and status breakdown
- Date created

This allows future sessions (and `/workstreams triage`) to find and update the database.

## Step 8: Report

Output the final state:
```
Database: [URL]
Workstreams: N total
  - Shipped: N (X%)
  - Built: N (X%)
  - Refined: N (X%)
  - Inbox: N (X%)
Relations: N dependency links wired
Views: Sprint, Backlog, Blocked, V1 Gap, Board Report, My Actions
```
