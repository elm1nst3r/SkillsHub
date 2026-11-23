# SkillsHub

My private Claude Code plugin marketplace of favorite agent skills.

## Install

```
/plugin marketplace add elm1nst3r/SkillsHub
/plugin install hairline@skillshub
/plugin install archify@skillshub
/plugin install diagram-design@skillshub
```

Private repo: make sure `gh auth login` (or a `GITHUB_TOKEN`) works in the environment so Claude Code can clone it.

## Plugins

| Plugin | Skills | Upstream | License |
|---|---|---|---|
| `hairline` | `hairline-create`, `hairline-adopt` | [lucasmarkes/hairline](https://github.com/lucasmarkes/hairline) | MIT |
| `archify` | `archify`, `archify-pr` | [tt-a1i/archify](https://github.com/tt-a1i/archify) | Apache-2.0 |
| `diagram-design` | `diagram-design` (+ import/export commands) | [cathrynlavery/diagram-design](https://github.com/cathrynlavery/diagram-design) | MIT |

Skills are vendored (copied) so they keep working if upstream changes or disappears. Pinned commits are in `UPSTREAM.json`; each plugin folder keeps its upstream license.

## Update from upstream

```
scripts/sync-upstream.sh            # all
scripts/sync-upstream.sh archify    # one
```

## Browse and search

Open `site/index.html` in a browser (no server needed), or the [SkillsHub artifact](https://claude.ai/artifact/SfR4xrQcGHQMMuurbGQLvJ) on claude.ai. `node scripts/build-catalog.mjs` also writes `site/artifact.html`, the artifact's copy of the page. Search by name, summary, tags or full description, and filter by plugin and tag.

Short descriptions, categories and tags live in `catalog/skills.json` (kept separate so upstream syncs never overwrite them). After editing it, rebuild the page data:

```
node scripts/build-catalog.mjs
```

CI runs `node scripts/build-catalog.mjs --check`, which fails if a skill has no summary/tags, uses a tag outside `tagGroups`, or `site/catalog.js` is stale.

## Submit a skill

Use **Submit a skill** in the [SkillsHub artifact](https://claude.ai/artifact/SfR4xrQcGHQMMuurbGQLvJ): paste a GitHub link, optionally with a plugin name, category, description and tags. Submissions are saved in the artifact. A scheduled Claude task processes them once a day following [`catalog/PROCESSING.md`](catalog/PROCESSING.md): it copies the skill in, updates `UPSTREAM.json`, the marketplace and the catalog, pushes to `main`, republishes the artifact and marks each submission added or rejected. To process sooner, ask Claude to "process SkillsHub submissions".

## Add a new skill by hand

1. Create `plugins/<name>/.claude-plugin/plugin.json` and `plugins/<name>/skills/<skill>/SKILL.md`.
2. Add an entry to `.claude-plugin/marketplace.json`.
3. Add the skill's `category`, `summary` and `tags` to `catalog/skills.json` (add new tags to a `tagGroups` group), then run `node scripts/build-catalog.mjs`.
