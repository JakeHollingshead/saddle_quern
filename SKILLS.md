# Saddle quern skills

Read [AGENTS.md](AGENTS.md) first. Its rules apply to every mode. Choose Standard when no mode is given. Combine modes only when the review needs them. These files are local review instructions; this catalog does not install them globally.

| Mode | Focus | Skill |
|---|---|---|
| Quick | Review a small change for obvious defects and regressions with saddle_quern. | [quern-quick](skills/quern-quick/SKILL.md) |
| Standard | Perform the default saddle_quern review of correctness, dependencies, edge cases, and test coverage. | [quern-standard](skills/quern-standard/SKILL.md) |
| Deep | Review cross-component behavior, architecture, concurrency, and recovery with saddle_quern. | [quern-deep](skills/quern-deep/SKILL.md) |
| Sec | Review trust boundaries, access control, input validation, and sensitive data with saddle_quern. | [quern-sec](skills/quern-sec/SKILL.md) |
| Perform | Review algorithms, queries, resource usage, caching, and bottlenecks with saddle_quern. | [quern-perform](skills/quern-perform/SKILL.md) |
| Test | Review test quality and regression coverage with saddle_quern. | [quern-test](skills/quern-test/SKILL.md) |
| Deps | Review dependency, license, and supply-chain risk with saddle_quern. | [quern-deps](skills/quern-deps/SKILL.md) |

All seven modes build a [regression-testing record](regression_testing.md) while reading. Mode selection changes depth and focus. It does not waive the seven baselines or required reports.
