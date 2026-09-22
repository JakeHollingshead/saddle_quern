#!/usr/bin/env bash
set -euo pipefail
(( $# >= 1 )) || { echo 'Usage: bash uninstall.sh <skills-directory> [name...]' >&2; exit 2; }
dest="$1"; shift
[[ -d "$dest" ]] || { echo "Not a directory: $dest" >&2; exit 1; }
all_names=(quern-quick quern-standard quern-deep quern-sec quern-perform quern-test quern-deps)
if (( $# )); then names=("$@"); else names=("${all_names[@]}"); fi
removed=() skipped=()
for n in "${names[@]}"; do
  target="$dest/$n"
  skill="$target/SKILL.md"
  if [[ ! -e "$target" ]]; then
    skipped+=("$n (not present)")
    continue
  fi
  if [[ ! -f "$skill" ]] || ! grep -q "^name: $n\$" "$skill"; then
    skipped+=("$n (does not look like a saddle_quern skill; left in place)")
    continue
  fi
  rm -rf -- "$target"
  removed+=("$n")
done
echo "Removed: ${removed[*]:-none}"
if (( ${#skipped[@]} )); then printf 'Skipped: %s\n' "${skipped[@]}"; fi
