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

Open `site/index.html` in a browser (no server needed). Search by name, summary, tags or full description, and filter by plugin and tag.

Short descriptions, categories and tags live in `catalog/skills.json` (kept separate so upstream syncs never overwrite them). After editing it, rebuild the page data:

```
node scripts/build-catalog.mjs
```

CI runs `node scripts/build-catalog.mjs --check`, which fails if a skill has no summary/tags, uses a tag outside `tagGroups`, or `site/catalog.js` is stale.

## Add a new skill

1. Create `plugins/<name>/.claude-plugin/plugin.json` and `plugins/<name>/skills/<skill>/SKILL.md`.
2. Add an entry to `.claude-plugin/marketplace.json`.
3. Add the skill's `category`, `summary` and `tags` to `catalog/skills.json` (add new tags to a `tagGroups` group), then run `node scripts/build-catalog.mjs`.
