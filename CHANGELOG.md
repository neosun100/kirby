# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.4.0] - 2026-02-25

### Added
- `--version` flag to display Kirby version
- Signal handling (trap) — clean up temp files on Ctrl+C / exit
- `.kiro/steering/example.md` — sample steering file for users
- `tasks/.gitkeep` — ensure tasks directory exists for autopilot
- `.editorconfig` — consistent formatting across editors

### Fixed
- **Security**: Autopilot heredoc injection — user direction now safely escaped instead of shell-expanded
- **Robustness**: `strip_ansi` now applied to all tool outputs (amp, claude), not just kiro — fixes COMPLETE signal detection
- **Robustness**: `printf '%s\n'` replaces `echo` for variable content — prevents escape sequence issues
- **Robustness**: `agentSpawn` hook command uses proper subshell grouping — all sections now execute regardless of individual failures
- **Robustness**: `seq` replaced with bash `for (( ))` loop
- **Robustness**: `$AGENT_FLAG` properly quoted with `${AGENT_FLAG:+"$AGENT_FLAG"}`
- Max iteration exit code changed from 1 to 2 (distinguishes from errors)
- `kirby.json` model reset to `claude-sonnet-4` (accessible to all users)
- LICENSE now includes author name (neosun100)
- CONTRIBUTING.md updated: Bash 4+ requirement (not POSIX), code guidelines added
- Chinese docs (README_CN.md) synced: `--autopilot` in usage, autopilot skill in project tree, contributing links

## [1.3.0] - 2026-02-25

### Added
- **Autopilot (Sage Mode)** — fully autonomous project bootstrapper
  - `--autopilot "direction"`: researches the web, designs architecture, generates PRD, produces prd.json, then implements
  - `--autopilot` (no args): pure sage mode — AI scans the project and decides everything itself
  - Generates `tasks/research.md` (web research with sources), `tasks/architecture.md` (tech stack & design), full PRD, and executable `prd.json`
  - Minimum 5 web searches, analyzes 3-5 reference projects, targets 8-20 atomic stories
- `skills/autopilot/SKILL.md` — Kiro skill for autonomous research & planning
- Heredoc-based prompt construction for reliable shell escaping

### Fixed
- `set -e` causing premature exit during autopilot phase when piped through `tee`
- JSON format in prompts breaking bash variable assignment (quotes/braces interpreted as shell syntax)
- Simplified kiro-cli output handling in autopilot (removed problematic `tee /dev/stderr | strip_ansi` pipeline)

### Tested
- End-to-end autopilot test: "Pomodoro Timer with Next.js 14"
  - Autopilot researched, planned, and generated 18 user stories in ~3 minutes
  - All 18 stories implemented autonomously in ~50 minutes (23 git commits)
  - 42 source files, 7 test suites (14 tests), all passing
  - TypeScript ✅, ESLint ✅, Build ✅, Jest ✅

## [1.2.0] - 2026-02-25

### Added
- GitHub badges: license, stars, forks, issues, last commit, tool support, PRs welcome
- Star History chart at bottom of README
- Collapsible `<details>` sections for examples and prd.json format
- Third real-world example: Next.js team invitation system (4 stories)
- Emoji section headers throughout both docs
- Centered header with badge grid layout
- Project structure tree in both docs

### Changed
- README.md fully redesigned to GitHub open-source best practices
- docs/README_CN.md fully redesigned to match English version

## [1.1.0] - 2026-02-24

### Added
- Chinese documentation (`docs/README_CN.md`)
- Architecture diagram (ASCII flowchart)
- Real-world examples: REST API endpoint, database migration + UI
- Tips & best practices: story sizing, steering files, failure recovery
- Kirby vs Ralph comparison table
- Quick Start section

## [1.0.0] - 2026-02-24

### Added
- `kirby.sh` — Main autonomous loop script (`--tool kiro|amp|claude`)
- `.kiro/agents/kirby.json` — Kiro custom agent with agentSpawn hooks
- `prompt.md` — Core iteration instructions
- `AGENTS.md` — Project-level agent instructions (Kiro auto-loads)
- `prd.json.example` — Example PRD format
- `skills/prd/SKILL.md` — PRD generation skill
- `skills/kirby/SKILL.md` — PRD → JSON conversion skill
- Dependency checking, `--help`, prd.json existence check
- Automatic archiving, ANSI stripping, COMPLETE signal detection

[1.4.0]: https://github.com/neosun100/kirby/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/neosun100/kirby/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/neosun100/kirby/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/neosun100/kirby/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/neosun100/kirby/releases/tag/v1.0.0
