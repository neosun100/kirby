# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-02-24

### Added
- Chinese documentation (`docs/README_CN.md`)
- Architecture diagram in README (ASCII art flowchart)
- Real-world examples: REST API endpoint, database migration + UI
- Tips & best practices section: story sizing, steering files, failure recovery
- Comparison table: Kirby vs Ralph
- Quick Start section with step-by-step instructions

### Changed
- README.md rewritten with richer content, examples, and usage tips

## [1.0.0] - 2026-02-24

### Added
- `kirby.sh` — Main autonomous loop script with support for `--tool kiro` (default), `--tool amp`, and `--tool claude`
- `.kiro/agents/kirby.json` — Kiro CLI custom agent configuration with agentSpawn hooks for automatic context injection
- `prompt.md` — Core iteration instructions for the AI agent
- `AGENTS.md` — Project-level agent instructions (auto-loaded by Kiro)
- `prd.json.example` — Example PRD format for reference
- `skills/prd/SKILL.md` — Skill for generating Product Requirements Documents
- `skills/kirby/SKILL.md` — Skill for converting PRDs to prd.json format
- Dependency checking (jq, kiro-cli/amp/claude) before loop starts
- `--help` flag for usage information
- prd.json existence check before starting
- Automatic archiving of previous runs when branch changes
- ANSI escape code stripping for clean output parsing
- COMPLETE signal detection (`<promise>COMPLETE</promise>`) for loop termination
