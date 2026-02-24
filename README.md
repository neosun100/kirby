# Kirby

> Autonomous AI agent loop for [Kiro CLI](https://kiro.dev/cli/) — iteratively implements PRD stories until complete.

[中文文档](docs/README_CN.md)

Kirby spawns a fresh AI instance per iteration, picks the next incomplete user story from `prd.json`, implements it, runs quality checks, commits, and moves on. Memory persists across iterations via git history, `progress.txt`, and `prd.json`.

Also supports [Amp](https://ampcode.com) and [Claude Code](https://docs.anthropic.com/en/docs/claude-code) as alternative backends.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/), redesigned for Kiro CLI with native Custom Agent, Hooks, and Steering integration.

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                    kirby.sh loop                     │
│                                                      │
│  Iteration 1          Iteration 2          ...       │
│  ┌──────────┐        ┌──────────┐                    │
│  │ Fresh AI  │        │ Fresh AI  │                   │
│  │ instance  │        │ instance  │                   │
│  │           │        │           │                   │
│  │ Read PRD  │        │ Read PRD  │                   │
│  │ Pick US-1 │        │ Pick US-2 │                   │
│  │ Implement │        │ Implement │                   │
│  │ Test      │        │ Test      │                   │
│  │ Commit    │        │ Commit    │                   │
│  │ Update    │        │ Update    │                   │
│  └──────────┘        └──────────┘                    │
│       │                    │                          │
│       ▼                    ▼                          │
│  ┌─────────────────────────────────────┐             │
│  │  Shared Memory (files on disk)      │             │
│  │  • prd.json    (story status)       │             │
│  │  • progress.txt (learnings)         │             │
│  │  • git history  (code changes)      │             │
│  │  • AGENTS.md    (patterns)          │             │
│  └─────────────────────────────────────┘             │
│                                                      │
│  All stories passes:true? ──yes──▶ EXIT SUCCESS      │
└─────────────────────────────────────────────────────┘
```

## Prerequisites

- [Kiro CLI](https://kiro.dev/cli/) installed and authenticated
  ```bash
  curl -fsSL https://cli.kiro.dev/install | bash
  ```
- `jq` installed (`brew install jq` on macOS, `apt install jq` on Ubuntu)
- A git repository for your project

Optional alternative backends:
- [Amp CLI](https://ampcode.com) (`--tool amp`)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`--tool claude`)

## Quick Start (5 minutes)

```bash
# 1. Clone kirby
git clone https://github.com/neosun100/kirby.git

# 2. Copy to your project
cd your-project
cp /path/to/kirby/kirby.sh .
cp /path/to/kirby/prompt.md .
cp /path/to/kirby/AGENTS.md .
cp -r /path/to/kirby/.kiro .kiro
chmod +x kirby.sh

# 3. Create your prd.json (see examples below, or use the skill)
cp /path/to/kirby/prd.json.example prd.json
# Edit prd.json with your actual stories...

# 4. Run
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
```

**Examples:**
```bash
./kirby.sh                 # Kiro CLI, 10 iterations
./kirby.sh 20              # Kiro CLI, 20 iterations
./kirby.sh --tool amp 5    # Amp, 5 iterations
./kirby.sh --tool claude   # Claude Code, 10 iterations
```

## Complete Workflow

### Step 1: Write a PRD

You can write `prd.json` manually, or use the Kiro skill:

```
> Load the prd skill and create a PRD for adding a dark mode toggle to my React app
```

The skill asks clarifying questions, then saves a structured PRD to `tasks/prd-dark-mode.md`.

### Step 2: Convert to prd.json

```
> Load the kirby skill and convert tasks/prd-dark-mode.md to prd.json
```

Or write it manually — here's the format:

```json
{
  "project": "MyApp",
  "branchName": "kirby/dark-mode",
  "description": "Add dark mode toggle",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add theme context",
      "description": "As a developer, I need a React context for theme state.",
      "acceptanceCriteria": [
        "ThemeContext provides 'light' and 'dark' values",
        "ThemeProvider wraps the app in _app.tsx",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Add toggle button to header",
      "description": "As a user, I want a button to switch between light and dark mode.",
      "acceptanceCriteria": [
        "Toggle button visible in header",
        "Clicking toggles between light/dark",
        "Preference persists in localStorage",
        "Typecheck passes"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### Step 3: Run Kirby

```bash
./kirby.sh
```

Watch as Kirby autonomously implements each story, one per iteration.

### Step 4: Review & Push

```bash
# Check what Kirby did
git log --oneline
cat prd.json | jq '.userStories[] | {id, title, passes}'
cat progress.txt

# Push when satisfied
git push origin kirby/dark-mode
```

## Real-World Examples

### Example 1: Add a REST API endpoint

```json
{
  "project": "ExpressAPI",
  "branchName": "kirby/user-search",
  "description": "Add user search endpoint",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add search query to user repository",
      "description": "Add a findByName method to the user repository.",
      "acceptanceCriteria": [
        "UserRepository has findByName(query: string) method",
        "Returns users where name contains query (case-insensitive)",
        "Typecheck passes",
        "Tests pass"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Add GET /api/users/search endpoint",
      "description": "Expose user search via REST API.",
      "acceptanceCriteria": [
        "GET /api/users/search?q=john returns matching users",
        "Returns 400 if q param is missing",
        "Returns empty array if no matches",
        "Typecheck passes",
        "Tests pass"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### Example 2: Database migration + UI

```json
{
  "project": "TaskApp",
  "branchName": "kirby/task-tags",
  "description": "Add tagging system to tasks",
  "userStories": [
    {
      "id": "US-001",
      "title": "Create tags table and junction table",
      "description": "Database schema for many-to-many task-tag relationship.",
      "acceptanceCriteria": [
        "tags table with id, name, color columns",
        "task_tags junction table with task_id, tag_id",
        "Migration runs successfully",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Add tag CRUD server actions",
      "description": "Backend logic for creating, reading, deleting tags.",
      "acceptanceCriteria": [
        "createTag(name, color) action works",
        "getTags() returns all tags",
        "deleteTag(id) removes tag and junction entries",
        "Typecheck passes"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-003",
      "title": "Display tags on task cards",
      "description": "Show assigned tags as colored badges on each task card.",
      "acceptanceCriteria": [
        "Tags display as colored badges on task cards",
        "Maximum 3 tags shown, +N for overflow",
        "Typecheck passes"
      ],
      "priority": 3,
      "passes": false,
      "notes": ""
    }
  ]
}
```

## Tips & Best Practices

### Writing Good Stories

| Do | Don't |
|----|-------|
| "Add `status` column with default 'pending'" | "Make the database better" |
| "Button shows confirmation dialog before delete" | "Good UX for deletion" |
| One focused change per story | Multiple unrelated changes |
| Include "Typecheck passes" in every story | Forget quality checks |
| Order by dependency (schema → backend → UI) | Put UI before its backend |

### Sizing Stories Right

**Rule of thumb:** If you can't describe the change in 2-3 sentences, split it.

```
❌ "Build the user dashboard"

✅ Split into:
   US-001: Add dashboard route and empty page component
   US-002: Add stats query (total users, active today, new this week)
   US-003: Add stats cards to dashboard page
   US-004: Add recent activity list component
   US-005: Add activity list to dashboard page
```

### Using Steering Files

Create `.kiro/steering/` files to give Kirby project-specific knowledge:

```markdown
<!-- .kiro/steering/tech-stack.md -->
# Tech Stack
- Framework: Next.js 14 with App Router
- Database: PostgreSQL with Drizzle ORM
- Styling: Tailwind CSS
- Testing: Vitest + React Testing Library
- Always use server actions, not API routes
```

```markdown
<!-- .kiro/steering/conventions.md -->
# Conventions
- Components in src/components/ with PascalCase filenames
- Server actions in src/actions/ with camelCase filenames
- Use `cn()` utility for conditional classnames
- All database queries go through repository pattern in src/db/
```

### Recovering from Failures

If Kirby gets stuck on a story:

```bash
# Check what happened
cat progress.txt | tail -30
cat prd.json | jq '.userStories[] | select(.passes == false) | {id, title}'

# Option 1: Fix manually and mark as done
# Edit prd.json, set passes: true for the stuck story

# Option 2: Add hints to the story notes
# Edit prd.json, add guidance to the "notes" field:
jq '.userStories[0].notes = "Use the existing Button component from src/components/ui"' prd.json > tmp && mv tmp prd.json

# Option 3: Split the story into smaller pieces
# Edit prd.json to break the stuck story into 2-3 smaller ones

# Then re-run
./kirby.sh
```

### Maximizing Iteration Efficiency

1. **Start with good AGENTS.md** — Add your project's key patterns before the first run
2. **Use steering files** — Tell Kirby about your tech stack and conventions
3. **Keep stories atomic** — One change, one test, one commit
4. **Review after each feature** — Check progress.txt for learnings, promote good ones to AGENTS.md

## How Kiro Integration Works

### Custom Agent (`.kiro/agents/kirby.json`)

The Kirby agent configuration provides:
- **Allowed Tools**: `read`, `write`, `shell` pre-trusted for autonomous operation
- **Resources**: Automatically loads `AGENTS.md` and `.kiro/steering/` files
- **agentSpawn Hook**: Injects git status, PRD progress, and recent learnings into context at startup

### vs. Ralph (Amp/Claude Code)

| Feature | Ralph | Kirby |
|---------|-------|-------|
| AI Tool | Amp or Claude Code | Kiro CLI (+ Amp, Claude) |
| Prompt delivery | Pipe to stdin | Positional argument + agent config |
| Tool permissions | `--dangerously-skip-permissions` | `--trust-all-tools` (granular) |
| Context injection | Manual (AI reads files) | agentSpawn hook (automatic) |
| Project knowledge | CLAUDE.md / prompt.md only | Steering files + AGENTS.md + hooks |
| MCP support | Limited | Native |

## Key Files

| File | Purpose |
|------|---------|
| `kirby.sh` | Main loop script |
| `prompt.md` | Per-iteration AI instructions |
| `.kiro/agents/kirby.json` | Kiro custom agent config |
| `prd.json` | User stories with pass/fail status |
| `prd.json.example` | Example PRD format |
| `progress.txt` | Append-only learnings log |
| `AGENTS.md` | Project patterns (Kiro auto-loads) |
| `skills/prd/SKILL.md` | PRD generation skill |
| `skills/kirby/SKILL.md` | PRD → JSON conversion skill |

## Debugging

```bash
# Story status
cat prd.json | jq '.userStories[] | {id, title, passes}'

# What Kirby learned
cat progress.txt

# Git history
git log --oneline -10

# Re-run with more iterations
./kirby.sh 20
```

## Archiving

Kirby automatically archives previous runs when `branchName` changes in prd.json. Archives go to `archive/YYYY-MM-DD-feature-name/`.

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
