# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
