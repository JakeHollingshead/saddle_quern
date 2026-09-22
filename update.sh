#!/usr/bin/env bash
set -euo pipefail
(( $# == 1 || $# == 2 )) || { echo 'Usage: bash update.sh <skills-directory> [repo-url]' >&2; exit 2; }
dest="$1"
repo_url="${2:-${QUERN_REPO_URL:-https://github.com/JakeHollingshead/saddle_quern.git}}"
[[ -d "$dest" ]] || { echo "Not a directory: $dest" >&2; exit 1; }
command -v git >/dev/null || { echo 'Git is required.' >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 "$repo_url" "$work/repo"
names=(quern-quick quern-standard quern-deep quern-sec quern-perform quern-test quern-deps)
updated=() unchanged=() skipped=()
for n in "${names[@]}"; do
  target="$dest/$n"
  skill="$target/SKILL.md"
  if [[ ! -d "$target" || ! -f "$skill" ]]; then
    skipped+=("$n (not installed)")
    continue
  fi
  if ! grep -q "^name: $n\$" "$skill"; then
    skipped+=("$n (SKILL.md present but does not identify itself as $n; left untouched)")
    continue
  fi
  refs="$target/references"
  mkdir -p "$refs"
  new_body=$(sed -e 's|../../AGENTS.md|references/AGENTS.md|g' -e 's|../../regression_testing.md|references/regression_testing.md|g' "$work/repo/skills/$n/SKILL.md")
  changed=0
  if [[ ! -f "$skill" ]] || [[ "$new_body" != "$(cat "$skill")" ]]; then changed=1; fi
  if ! cmp -s "$work/repo/AGENTS.md" "$refs/AGENTS.md" 2>/dev/null; then changed=1; fi
  if ! cmp -s "$work/repo/regression_testing.md" "$refs/regression_testing.md" 2>/dev/null; then changed=1; fi
  printf '%s\n' "$new_body" > "$skill"
  cp "$work/repo/AGENTS.md" "$work/repo/regression_testing.md" "$refs/"
  if [[ $changed -eq 1 ]]; then updated+=("$n"); else unchanged+=("$n"); fi
done
echo "Updated: ${updated[*]:-none}"
echo "Unchanged: ${unchanged[*]:-none}"
if (( ${#skipped[@]} )); then printf 'Skipped: %s\n' "${skipped[@]}"; fi
