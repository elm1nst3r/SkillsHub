#!/usr/bin/env bash
# Refresh vendored plugins from their upstream repos, as described in UPSTREAM.json:
#   "<plugin>": { "repo": "owner/name", "ref": "branch-or-tag or null", "commit": "...",
#                 "copy": [["path/in/upstream", "path/in/plugins/<plugin>"], ...] }
# Usage: scripts/sync-upstream.sh [plugin ...]   (default: all)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
if [ $# -eq 0 ]; then mapfile -t names < <(jq -r 'keys[]' "$ROOT/UPSTREAM.json"); else names=("$@"); fi

for n in "${names[@]}"; do
  entry=$(jq -c --arg n "$n" '.[$n] // empty' "$ROOT/UPSTREAM.json")
  [ -z "$entry" ] && { echo "unknown plugin: $n" >&2; exit 1; }
  repo=$(jq -r .repo <<<"$entry"); ref=$(jq -r '.ref // empty' <<<"$entry")
  git clone -q --depth 1 ${ref:+--branch "$ref"} "https://github.com/$repo.git" "$TMP/$n"
  sha=$(git -C "$TMP/$n" rev-parse HEAD)
  dst="$ROOT/plugins/$n"
  while IFS=$'\t' read -r from to; do
    [ -e "$TMP/$n/$from" ] || { echo "$n: $from not found upstream" >&2; exit 1; }
    rm -rf "${dst:?}/$to"; mkdir -p "$(dirname "$dst/$to")"
    cp -r "$TMP/$n/$from" "$dst/$to"
  done < <(jq -r '.copy[] | @tsv' <<<"$entry")
  find "$dst" -name .DS_Store -delete
  tmpj=$(mktemp); jq --arg n "$n" --arg s "$sha" '.[$n].commit=$s' "$ROOT/UPSTREAM.json" > "$tmpj" && mv "$tmpj" "$ROOT/UPSTREAM.json"
  echo "$n -> $sha"
done
echo "Rebuilding catalog..."; node "$ROOT/scripts/build-catalog.mjs"
echo "Review with 'git diff --stat', then commit."
