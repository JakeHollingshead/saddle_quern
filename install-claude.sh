#!/usr/bin/env bash
set -euo pipefail
(( $# <= 1 )) || { echo 'Usage: bash install-claude.sh [skills-directory]' >&2; exit 2; }
dest="${1:-$HOME/.claude/skills}"
repo_url="${QUERN_REPO_URL:-https://github.com/JakeHollingshead/saddle_quern.git}"
command -v git >/dev/null || { echo 'Git is required.' >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 "$repo_url" "$work/repo"
names=(quern-quick quern-standard quern-deep quern-sec quern-perform quern-test quern-deps)
for n in "${names[@]}"; do
  [[ -f "$work/repo/skills/$n/SKILL.md" ]] || { echo "Missing skill: $n" >&2; exit 1; }
  [[ ! -e "$dest/$n" && ! -L "$dest/$n" ]] || { echo "Already exists: $dest/$n; nothing installed." >&2; exit 1; }
done
for f in AGENTS.md regression_testing.md; do
  [[ -f "$work/repo/$f" ]] || { echo "Missing $f" >&2; exit 1; }
done
mkdir -p "$dest"
for n in "${names[@]}"; do
  mkdir "$dest/$n"
  mkdir "$dest/$n/references"
  cp "$work/repo/AGENTS.md" "$work/repo/regression_testing.md" "$dest/$n/references/"
  sed -e 's|../../AGENTS.md|references/AGENTS.md|g' -e 's|../../regression_testing.md|references/regression_testing.md|g' "$work/repo/skills/$n/SKILL.md" > "$dest/$n/SKILL.md"
  echo "Installed $dest/$n"
done
echo 'Start a new Claude Code session to discover the skills.'
