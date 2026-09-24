# saddle_quern

<img src="sadie-saddle-quern.png" alt="Sadie, the saddle_quern mascot, grinding a codebase into data" width="220" align="right">

A Markdown-based code review agent. It grinds a codebase into classes, functions, calls, state changes, and failure paths. It produces evidence and a quality assessment. It is not a standalone application or model service. Sadie, pictured, is the mascot.

[MIT licensed](LICENSE). See [CONTRIBUTING.md](CONTRIBUTING.md) to add a review mode. See [examples/](examples/) for a worked sample review.

## Start

1. Open this folder with an AI agent that can read local Markdown instructions.
2. Ask it to read [AGENTS.md](AGENTS.md) and choose a mode from [SKILLS.md](SKILLS.md).
3. Supply the product name and the codebase path. Choose an output directory outside the reviewed source tree.

Example: "Read AGENTS.md. Run a standard review of the product named Example at the source path I provide. Save reports outside that source directory."

The agent asks for a missing product name. It does not invent one. Standard is the default mode. These local skill files are not automatically installed into an agent's global skill registry.

## Review modes

| Mode | Focus |
|---|---|
| [quern-quick](skills/quern-quick/SKILL.md) | Obvious defects in a small change. |
| [quern-standard](skills/quern-standard/SKILL.md) | Correctness, callers, edge cases, and coverage. |
| [quern-deep](skills/quern-deep/SKILL.md) | Cross-component state, concurrency, and recovery. |
| [quern-sec](skills/quern-sec/SKILL.md) | Trust boundaries, access, and sensitive data. |
| [quern-perform](skills/quern-perform/SKILL.md) | Growth, queries, resource use, and bottlenecks. |
| [quern-test](skills/quern-test/SKILL.md) | Test quality and regression coverage. |
| [quern-deps](skills/quern-deps/SKILL.md) | Dependency, license, and supply-chain risk. |

## Reports

The main report is recursive.md. Linked Markdown files hold the SHA-256 snapshot, function measurements, loop ceilings, error handling, call inventory, product assessment, and user story. Each run also builds a regression record from [regression_testing.md](regression_testing.md) while reading the code.

Regression records distinguish planned checks from executed results. Historical passes are not current passes. Tests that cannot run within the agent's boundaries stay unverified.

## Boundaries

The reviewed code stays read-only. The agent creates only Markdown files and updates only its own Markdown files. Checks must be read-only or in memory. Findings do not authorize source fixes, live service actions, or publication.

The seven code baselines and the full process live in AGENTS.md. Review modes change the focus, not those rules.

## Repository contents

- AGENTS.md: shared rules, workflow, and the rule index.
- SKILLS.md: review-mode index.
- regression_testing.md: reusable regression template.
- skills/: seven short review skills, each in its own SKILL.md.
- examples/: a worked sample review against a small fixture repo.
- CONTRIBUTING.md: how to add a review mode.
- LICENSE: MIT license.
- sadie-saddle-quern.png: the mascot, referenced in this README.
- scripts/ and .github/: repository self-checks (link and installer-name consistency). Not part of a code review run and not installed by the scripts below.

Keep product-specific reports, private source, credentials, and customer data outside this instruction repository.

## Install

Two agent targets are supported: Codex and Claude Code. Publish these files to GitHub before running the installers. Git is required. All scripts fetch the current default branch from https://github.com/JakeHollingshead/saddle_quern.git by default; pass a different repository URL (`-RepoUrl` in PowerShell, `QUERN_REPO_URL` in Bash) to install from a fork or branch under test.

Clone the repository, enter its folder, then run:

| Target | PowerShell | Bash |
|---|---|---|
| Codex | `./Install.ps1` | `bash install.sh` |
| Claude Code | `./Install-Claude.ps1` | `bash install-claude.sh` |

The default destination is `$CODEX_HOME/skills` (`~/.codex/skills` when unset) for Codex, and `~/.claude/skills` for Claude Code. Use `-SkillsDirectory <path>` in PowerShell or a path argument in Bash to override it. Install never overwrites an existing skill directory. If copying fails midway, inspect the partial installation before retrying.

To pull rule or skill updates into an existing install, run the matching `Update.ps1` / `bash update.sh` against that same skills directory: it overwrites only the files this project ships (`SKILL.md` and the `references/` copies) and reports which skills changed. To remove an install, run `Uninstall.ps1` / `bash uninstall.sh` against that directory; it refuses to delete anything that doesn't look like a saddle_quern skill (missing `SKILL.md`, or a `name:` in its frontmatter that doesn't match the directory).

Start a new session and invoke a mode: `$quern-quick` (Codex) or `/quern-quick` (Claude Code), and likewise for `quern-standard`, `quern-deep`, `quern-sec`, `quern-perform`, `quern-test`, and `quern-deps`.

These setup scripts do not change the Markdown-only boundary for code reviews.
