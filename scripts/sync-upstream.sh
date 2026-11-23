#!/usr/bin/env bash
# Refresh vendored skills from their upstream repos and record the new commits.
# Usage: scripts/sync-upstream.sh [hairline|archify|diagram-design ...]   (default: all)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
names=("$@"); [ ${#names[@]} -eq 0 ] && names=(hairline archify diagram-design)

for n in "${names[@]}"; do
  repo=$(jq -r --arg n "$n" '.[$n].repo' "$ROOT/UPSTREAM.json")
  git clone -q --depth 1 "https://github.com/$repo.git" "$TMP/$n"
  sha=$(git -C "$TMP/$n" rev-parse HEAD)
  dst="$ROOT/plugins/$n"
  case "$n" in
    hairline)
      rm -rf "$dst/skills"; mkdir -p "$dst/skills"
      cp -r "$TMP/$n/skills/hairline-create" "$TMP/$n/skills/hairline-adopt" "$dst/skills/"
      cp "$TMP/$n/LICENSE" "$dst/" ;;
    archify)
      rm -rf "$dst/skills"; mkdir -p "$dst/skills"
      cp -r "$TMP/$n/archify" "$TMP/$n/archify-pr" "$dst/skills/"
      cp "$TMP/$n/LICENSE" "$TMP/$n/LICENSE-MIT" "$TMP/$n/NOTICE" "$dst/" ;;
    diagram-design)
      rm -rf "$dst/skills" "$dst/commands"
      cp -r "$TMP/$n/skills" "$TMP/$n/commands" "$dst/"
      cp "$TMP/$n/.claude-plugin/plugin.json" "$dst/.claude-plugin/plugin.json"
      cp "$TMP/$n/LICENSE" "$TMP/$n/THIRD_PARTY_LICENSES.md" "$dst/" ;;
    *) echo "unknown plugin: $n" >&2; exit 1 ;;
  esac
  tmpj=$(mktemp); jq --arg n "$n" --arg s "$sha" '.[$n].commit=$s' "$ROOT/UPSTREAM.json" > "$tmpj" && mv "$tmpj" "$ROOT/UPSTREAM.json"
  echo "$n -> $sha"
done
echo "Rebuilding catalog..."; node "$ROOT/scripts/build-catalog.mjs"
echo "Review with 'git diff --stat', then commit."
