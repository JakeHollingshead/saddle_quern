#!/usr/bin/env bash
# Repository self-check: not part of a code review run, and not installed
# by any Install/Update script. Verifies internal Markdown links resolve
# and that every installer/update/uninstall script's hardcoded skill list
# matches the directories under skills/.
set -uo pipefail
cd "$(dirname "$0")/.."

log=$(mktemp)
trap 'rm -f "$log"' EXIT
exec > >(tee "$log") 2>&1

echo '## Skill frontmatter check'
for d in skills/*/; do
  n=$(basename "$d")
  skill="$d/SKILL.md"
  if [[ ! -f "$skill" ]]; then
    echo "FAIL: $skill missing"
    continue
  fi
  fm=$(sed -n 's/^name: *//p' "$skill" | head -n1)
  if [[ "$fm" != "$n" ]]; then
    echo "FAIL: $skill frontmatter name '$fm' does not match directory '$n'"
  else
    echo "OK: $skill"
  fi
done

expected=$(for d in skills/*/; do basename "$d"; done | sort)

compare() {
  local label="$1" actual="$2" actual_sorted
  actual_sorted=$(printf '%s\n' $actual | sort)
  if [[ "$actual_sorted" == "$expected" ]]; then
    echo "OK: $label lists the same skills as skills/"
  else
    echo "FAIL: $label skill list does not match skills/"
    echo "  expected: $(printf '%s ' $expected)"
    echo "  actual:   $(printf '%s ' $actual_sorted)"
  fi
}

get_bash_array() {
  grep -oE "^$2=\([^)]*\)" "$1" | head -n1 | sed -E "s/^$2=\(//; s/\)\$//"
}

get_ps_array() {
  grep -oE "\\\$$2 = @\([^)]*\)" "$1" | head -n1 | sed -E 's/.*@\(//; s/\)$//' | tr -d "'" | tr ',' ' '
}

echo
echo '## Installer / update / uninstall skill-list check'
compare 'install.sh'         "$(get_bash_array install.sh names)"
compare 'install-claude.sh'  "$(get_bash_array install-claude.sh names)"
compare 'update.sh'          "$(get_bash_array update.sh names)"
compare 'uninstall.sh'       "$(get_bash_array uninstall.sh all_names)"
compare 'Install.ps1'        "$(get_ps_array Install.ps1 names)"
compare 'Install-Claude.ps1' "$(get_ps_array Install-Claude.ps1 names)"
compare 'Update.ps1'         "$(get_ps_array Update.ps1 names)"
compare 'Uninstall.ps1'      "$(get_ps_array Uninstall.ps1 allNames)"

echo
echo '## Markdown link check'
while IFS= read -r -d '' f; do
  dir=$(dirname "$f")
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    case "$target" in
      http://*|https://*|mailto:*) continue ;;
    esac
    target_noanchor="${target%%#*}"
    [[ -z "$target_noanchor" ]] && continue
    resolved="$dir/$target_noanchor"
    if [[ ! -e "$resolved" ]]; then
      echo "FAIL: $f links to '$target' (resolved to $resolved, not found)"
    fi
  done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done < <(find . -name '*.md' -not -path './.git/*' -print0)
echo 'OK: link check complete'

echo
if grep -q '^FAIL:' "$log"; then
  echo 'check_repo.sh: FAILURES ABOVE'
  exit 1
fi
echo 'check_repo.sh: all checks passed'
