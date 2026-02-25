# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
