# Claude Code Skills

Personal collection of reusable Claude Code slash commands.

## Skills

| Command | Description |
|---|---|
| `/workstreams` | Orchestrator for project management via Notion |
| `/workstreams-plan` | Analyze codebase, extract capabilities, map dependency DAG |
| `/workstreams-create` | Provision Notion database with schema, views, populate workstreams |
| `/workstreams-triage` | Sync git history with Notion, update statuses, surface blockers |
| `/visual-audit` | Agentic website testing via Playwright MCP |

## Install

```bash
git clone https://github.com/jrodbueno/claude-skills.git ~/Projects/claude-skills
cd ~/Projects/claude-skills
chmod +x install.sh
./install.sh
```

Symlinks all skills to `~/.claude/commands/` so `git pull` keeps them updated.

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- Notion MCP connected (for workstreams skills)
- Playwright MCP connected (for visual-audit)

## Adding a new skill

1. Create `commands/my-skill.md` with a `# Title` header
2. Run `./install.sh` to symlink
3. Use `/my-skill` in any Claude Code session
