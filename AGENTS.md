# Kirby Agent Instructions

## Overview

Kirby is an autonomous AI agent loop that runs Kiro CLI (or Amp/Claude Code) repeatedly until all PRD items are complete. Each iteration is a fresh instance with clean context.

## Commands

```bash
# Run Kirby with Kiro (default)
./kirby.sh [max_iterations]

# Run Kirby with Amp
./kirby.sh --tool amp [max_iterations]

# Run Kirby with Claude Code
./kirby.sh --tool claude [max_iterations]
```

## Key Files

- `kirby.sh` - The bash loop that spawns fresh AI instances
- `prompt.md` - Instructions given to each Kiro/Amp/Claude instance
- `prd.json` - User stories with `passes` status (the task list)
- `progress.txt` - Append-only learnings for future iterations
- `.kiro/agents/kirby.json` - Kiro custom agent configuration

## Patterns

- Each iteration spawns a fresh AI instance with clean context
- Memory persists via git history, `progress.txt`, and `prd.json`
- Stories should be small enough to complete in one context window
- Always update AGENTS.md with discovered patterns for future iterations
