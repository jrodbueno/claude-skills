# Visual Audit — Agentic Website Testing via Playwright MCP

You are a lead designer and solution architect performing a functional + visual audit of deployed web applications. Use the Playwright MCP tools to navigate, screenshot, and evaluate every page systematically.

## Inputs

The user provides one or more URLs (or Vercel project names to resolve). If credentials are needed, the user provides them.

## Execution Strategy — Parallel Agents

Split work across parallel agents for speed. Each agent handles an independent scope:

### Agent 1: Web App Audit (public site)
- Navigate every page: home, inventory grid, vehicle detail (pick 2-3 vehicles), contact, any other routes
- For each page: take a full-page screenshot, capture accessibility snapshot, check console errors
- Evaluate: hero content, images loading, colors/theme consistency, responsive layout, CTA buttons, forms, footer, nav links
- Check SEO endpoints: /robots.txt, /sitemap.xml, structured data
- Report issues with severity (blocker / major / minor / cosmetic)

### Agent 2: Admin App Audit (authenticated)
- Log in with provided credentials
- Navigate every sidebar page: Dashboard, Inventario, Reportes, Modulos AI, Marca, Sitio, Integraciones, Invocaciones AI, Acciones, Tenants, Onboarding
- For each page: take screenshot, check for errors (SQL errors, blank sections, broken UI)
- Test key interactions: tenant switcher, save buttons, filters
- Report issues with severity

### Agent 3: Data Integrity Check
- Compare admin data vs public site rendering (does the hero match site_configs? do vehicle counts match? are prices consistent?)
- Check that tenant isolation works (wrong domain → 404, not another tenant's data)
- Verify console errors on every page
- Check network requests for failed API calls

## Output Format

Each agent reports back a structured findings table:

| Page | Issue | Severity | Details |
|------|-------|----------|---------|

After all agents complete, synthesize into a single prioritized punch list:
1. **Blockers** — must fix before showing to anyone
2. **Major** — functional gaps visible to users
3. **Minor** — polish items
4. **Cosmetic** — nice-to-have

Then propose fixes for each blocker and major issue, with file paths where the fix should go.

## Playwright MCP Tools to Use

- `mcp__playwright__browser_navigate` — go to URL
- `mcp__playwright__browser_take_screenshot` — visual capture (use fullPage: true)
- `mcp__playwright__browser_snapshot` — accessibility tree (better for finding interactive elements)
- `mcp__playwright__browser_click` — interact with elements
- `mcp__playwright__browser_fill_form` — fill login forms, test inputs
- `mcp__playwright__browser_wait_for` — wait for content to load
- `mcp__playwright__browser_console_messages` — check for JS errors
- `mcp__playwright__browser_network_requests` — check for failed API calls

## Important

- Load Playwright tool schemas via ToolSearch before first use
- Take screenshots with descriptive filenames (e.g., `admin-marca.png`, `web-vdp-civic.png`)
- Don't just screenshot — read the snapshot and evaluate what you see
- Flag any hardcoded placeholder text ("Lorem ipsum", "Hero", "subheadline", "TODO")
- Flag any raw error messages shown to users (SQL, stack traces, 500s)
- Flag missing images where images are expected
- Check that the brand color theme is consistent across all pages
