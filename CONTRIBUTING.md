# Contributing

saddle_quern is a Markdown instruction set, not code. Changes here edit what a review agent is told to do, so read a change the way you'd read a diff to a spec: precisely, and for what it removes as much as what it adds.

## Ground rules

- Everything an installed agent reads must stay in Markdown: `AGENTS.md`, `SKILLS.md`, `regression_testing.md`, and `skills/*/SKILL.md`. Tooling that supports the repo itself (installers, CI, `examples/`) is not bound by that, since it never ships into an agent's skill directory.
- Rule IDs (`FS-01`, `CODE-0x`, `PROC-0x`, `REVIEW-0x`) are stable identifiers, not sequence numbers. Don't renumber or reuse one for a different rule. Adding a new rule gets the next unused number in its family; removing one leaves a gap rather than a renumbering, and gets a line in the pull request description explaining why. Keep the [rule index](AGENTS.md#rule-index) in sync with any rule you add, remove, or reword.
- Every mode file (`skills/*/SKILL.md`) must keep linking back to `../../AGENTS.md` and `../../regression_testing.md` with those exact relative paths — the installers rewrite them to `references/...` on copy, and a different path silently breaks that rewrite.

## Adding a review mode

The six original modes (now seven with `quern-deps`) all follow one shape. To add another:

1. Create `skills/<name>/SKILL.md` with YAML frontmatter (`name`, one-line `description`) and a short body that: reads AGENTS.md, restates the FS-01/read-only boundary, states the mode's specific focus in 2-4 sentences, and closes with the standard regression-record paragraph (copy it verbatim from an existing mode — it should not vary between modes).
2. Add a row to the table in [SKILLS.md](SKILLS.md) and to the table in [README.md](README.md), and update the "all N modes" count in SKILLS.md.
3. Add `<name>` to the `names` array/list in all four installers: [install.sh](install.sh), [Install.ps1](Install.ps1), [install-claude.sh](install-claude.sh), [Install-Claude.ps1](Install-Claude.ps1) — and to [update.sh](update.sh) / [Update.ps1](Update.ps1) and [uninstall.sh](uninstall.sh) / [Uninstall.ps1](Uninstall.ps1).
4. Run `bash scripts/check_repo.sh` (also run in CI) to confirm the new mode's links resolve and every installer/update/uninstall script's name list agrees with `skills/`.

A mode file should stay thin. If a check applies to every review regardless of mode, it belongs in AGENTS.md, not duplicated across `skills/*/SKILL.md`.

## Changing AGENTS.md

Prefer tightening or clarifying an existing rule over adding a new one. If you do add a rule, say in the pull request which existing report section is supposed to cover it, since REVIEW-14/REVIEW-16 require every rule to land somewhere in the fixed report structure. Update the rule index table at the bottom of AGENTS.md in the same change.

## Testing a change

There's no interpreter to run against Markdown instructions, so verification is closer to a spec review than a test suite:

- `bash scripts/check_repo.sh` catches broken relative links and installer/skills drift mechanically.
- For a substantive rewording of AGENTS.md or a mode file, run the affected mode against the fixture in [examples/toy_repo](examples/toy_repo) with the agent you're targeting, and compare the output shape to [examples/sample_review](examples/sample_review). It won't match line for line, but the section structure, the evidence files, and the planned/executed distinction in the regression record should still hold.
- If you're changing an installer, test it against a fork: `QUERN_REPO_URL=<your fork> bash install.sh /tmp/quern-test` (or `-RepoUrl` in PowerShell) so you're not depending on a merge to main to find a bug.

## Pull requests

Describe the change in terms of what an installed agent will now do differently — that's the actual behavior change, even though the diff is Markdown.
