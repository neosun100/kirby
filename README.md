# Kirby

Kirby is an autonomous AI agent loop that runs [Kiro CLI](https://kiro.dev/cli/) repeatedly until all PRD items are complete. Each iteration is a fresh instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Also supports [Amp](https://ampcode.com) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code) as alternative backends.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/), redesigned for Kiro CLI with native Custom Agent, Hooks, and Steering integration.

## Prerequisites

- [Kiro CLI](https://kiro.dev/cli/) installed and authenticated (default)
  ```bash
  curl -fsSL https://cli.kiro.dev/install | bash
  ```
- `jq` installed (`brew install jq` on macOS, `apt install jq` on Ubuntu)
- A git repository for your project

Optional alternative backends:
- [Amp CLI](https://ampcode.com) (`--tool amp`)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`--tool claude`)

## Quick Start

```bash
# 1. Copy kirby files to your project
cp kirby.sh prompt.md AGENTS.md /path/to/your-project/
cp -r .kiro /path/to/your-project/
chmod +x /path/to/your-project/kirby.sh

# 2. Create prd.json (copy and edit the example, or use the kirby skill)
cp prd.json.example /path/to/your-project/prd.json

# 3. Run
cd /path/to/your-project
./kirby.sh
```

## Usage

```
./kirby.sh [OPTIONS] [max_iterations]

Options:
  --tool kiro|amp|claude   AI tool to use (default: kiro)
  --help                   Show help message

Arguments:
  max_iterations           Maximum loop iterations (default: 10)

Examples:
  ./kirby.sh               # Kiro, 10 iterations
  ./kirby.sh 20            # Kiro, 20 iterations
  ./kirby.sh --tool amp 5  # Amp, 5 iterations
```

## Setup

### Option 1: Copy to your project

```bash
mkdir -p scripts/kirby
cp kirby.sh prompt.md scripts/kirby/
cp -r .kiro .kiro
cp AGENTS.md AGENTS.md
chmod +x scripts/kirby/kirby.sh
```

### Option 2: Install Kiro agent globally

```bash
cp .kiro/agents/kirby.json ~/.kiro/agents/
```

The agent will be available in all projects via `kiro-cli --agent kirby`.

### Option 3: Install skills globally

```bash
mkdir -p ~/.kiro/skills
cp -r skills/prd ~/.kiro/skills/
cp -r skills/kirby ~/.kiro/skills/
```

## Workflow

### 1. Create a PRD

Use the PRD skill to generate a detailed requirements document:

```
Load the prd skill and create a PRD for [your feature description]
```

The skill saves output to `tasks/prd-[feature-name].md`.

### 2. Convert PRD to Kirby format

```
Load the kirby skill and convert tasks/prd-[feature-name].md to prd.json
```

This creates `prd.json` with user stories structured for autonomous execution.

### 3. Run Kirby

```bash
./kirby.sh
```

Kirby will:
1. Create a feature branch (from PRD `branchName`)
2. Pick the highest priority story where `passes: false`
3. Implement that single story
4. Run quality checks (typecheck, tests)
5. Commit if checks pass
6. Update `prd.json` to mark story as `passes: true`
7. Append learnings to `progress.txt`
8. Repeat until all stories pass or max iterations reached

## How Kiro Integration Works

Kirby leverages Kiro CLI features that go beyond simple prompt piping:

### Custom Agent (`.kiro/agents/kirby.json`)

- **Allowed Tools**: `read`, `write`, `shell` pre-trusted — no confirmation prompts
- **Resources**: Automatically loads `AGENTS.md` and `.kiro/steering/` files
- **agentSpawn Hook**: Injects git status, PRD progress, and recent learnings into context at startup — the AI doesn't need to manually read these

### Steering Files

Place project-specific conventions in `.kiro/steering/`:
```
.kiro/steering/
├── project.md      # Your project conventions
├── tech-stack.md   # Framework/library preferences
└── testing.md      # Testing patterns
```

Kiro automatically loads these into every iteration.

### AGENTS.md

Kiro natively supports the [AGENTS.md standard](https://agents.md/). Kirby updates these files with discovered patterns, and Kiro automatically reads them in future iterations.

## Key Files

| File | Purpose |
|------|---------|
| `kirby.sh` | The bash loop that spawns fresh AI instances |
| `prompt.md` | Instructions given to each iteration |
| `.kiro/agents/kirby.json` | Kiro custom agent configuration |
| `prd.json` | User stories with `passes` status |
| `prd.json.example` | Example PRD format |
| `progress.txt` | Append-only learnings for future iterations |
| `AGENTS.md` | Project-level agent instructions (Kiro auto-loads) |
| `skills/prd/` | Skill for generating PRDs |
| `skills/kirby/` | Skill for converting PRDs to JSON |

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new AI instance** with clean context. The only memory between iterations is:
- Git history (commits from previous iterations)
- `progress.txt` (learnings and context)
- `prd.json` (which stories are done)
- `AGENTS.md` (discovered patterns, auto-loaded by Kiro)

### Small Tasks

Each PRD item should be small enough to complete in one context window.

Right-sized:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic

Too big (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### Feedback Loops

Kirby only works if there are feedback loops:
- Typecheck catches type errors
- Tests verify behavior
- CI must stay green

### Stop Condition

When all stories have `passes: true`, Kirby outputs `<promise>COMPLETE</promise>` and the loop exits.

## Debugging

```bash
# See which stories are done
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings from previous iterations
cat progress.txt

# Check git history
git log --oneline -10
```

## Customizing

- Edit `prompt.md` to add project-specific quality check commands
- Edit `.kiro/agents/kirby.json` to adjust hooks or add MCP servers
- Add `.kiro/steering/*.md` files for project conventions
- Update `AGENTS.md` with codebase-specific patterns

## Archiving

Kirby automatically archives previous runs when you start a new feature (different `branchName`). Archives are saved to `archive/YYYY-MM-DD-feature-name/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE)

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Kiro CLI documentation](https://kiro.dev/docs/cli/)
- [Kiro Custom Agents](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)
- [Kiro Steering](https://kiro.dev/docs/cli/steering/)
- [Kiro Hooks](https://kiro.dev/docs/cli/hooks/)
