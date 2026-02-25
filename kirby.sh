#!/bin/bash
# Kirby - Autonomous AI agent loop for Kiro CLI
# Based on the Ralph pattern by Geoffrey Huntley, adapted for Kiro by design.
# Usage: ./kirby.sh [--tool kiro|amp|claude] [max_iterations]

set -e

# --- Usage ---
usage() {
  cat << 'EOF'
Usage: ./kirby.sh [OPTIONS] [max_iterations]

Options:
  --tool kiro|amp|claude   AI tool to use (default: kiro)
  --autopilot [direction]  Sage mode: research, plan, and build from scratch
  --help                   Show this help message

Arguments:
  max_iterations           Maximum loop iterations (default: 10)

Examples:
  ./kirby.sh               # Kiro, 10 iterations
  ./kirby.sh 20            # Kiro, 20 iterations
  ./kirby.sh --tool amp 5  # Amp, 5 iterations
  ./kirby.sh --autopilot "build a task management app with Next.js"
  ./kirby.sh --autopilot   # Pure sage mode, AI decides everything
EOF
  exit 0
}

# --- Parse arguments ---
TOOL="kiro"
MAX_ITERATIONS=10
AUTOPILOT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      usage
      ;;
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --tool=*)
      TOOL="${1#*=}"
      shift
      ;;
    --autopilot)
      if [[ -n "$2" && ! "$2" =~ ^-- && ! "$2" =~ ^[0-9]+$ ]]; then
        AUTOPILOT="$2"
        shift 2
      else
        AUTOPILOT="__SAGE__"
        shift
      fi
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

if [[ "$TOOL" != "kiro" && "$TOOL" != "amp" && "$TOOL" != "claude" ]]; then
  echo "Error: Invalid tool '$TOOL'. Must be 'kiro', 'amp', or 'claude'."
  exit 1
fi

# --- Check dependencies ---
check_dep() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: '$1' is not installed or not in PATH."
    echo "  $2"
    exit 1
  fi
}

check_dep jq "Install with: brew install jq (macOS) or apt install jq (Ubuntu)"

case "$TOOL" in
  kiro)   check_dep kiro-cli "Install with: curl -fsSL https://cli.kiro.dev/install | bash" ;;
  amp)    check_dep amp      "See: https://ampcode.com" ;;
  claude) check_dep claude   "Install with: npm install -g @anthropic-ai/claude-code" ;;
esac

# --- Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"

# --- Check prd.json exists ---
if [ -n "$AUTOPILOT" ] && [ ! -f "$PRD_FILE" ]; then
  echo ""
  echo "==============================================================="
  echo "  Kirby Autopilot — Sage Mode"
  echo "==============================================================="

  mkdir -p "$SCRIPT_DIR/tasks"

  AUTOPILOT_PROMPT_FILE=$(mktemp)
  if [ "$AUTOPILOT" = "__SAGE__" ]; then
    cat > "$AUTOPILOT_PROMPT_FILE" << 'AUTOPILOT_EOF'
You are in Kirby Autopilot (Sage Mode). No user requirements were given.

Your mission:
1. Scan the current project directory thoroughly — read every file, understand what exists
2. Based on what you find (or if the project is empty), DECIDE what this project should become
3. Search the web extensively (at least 5 searches) to research:
   - Best practices for this type of project
   - Top 3-5 reference projects on GitHub in this domain
   - Recommended tech stack for 2025-2026
   - Common pitfalls to avoid
   - UI/UX patterns if applicable
4. Save your research to tasks/research.md (with source URLs)
5. Design the architecture and save to tasks/architecture.md
6. Write a full PRD and save to tasks/prd-[project-name].md
7. Convert to prd.json in the project root with 8-20 atomic user stories
8. Validate: run jq . prd.json to ensure valid JSON

CRITICAL: prd.json MUST follow this exact structure with keys: project, branchName, description, userStories (array). Each story needs: id (US-001 format), title, description, acceptanceCriteria (array of strings), priority (number), passes (false), notes (empty string). Stories must be ordered by dependency (setup then schema then backend then frontend then polish). Target 8-20 stories.

Be bold. Be thorough. Make every decision yourself. Do NOT ask the user anything.
AUTOPILOT_EOF
  else
    cat > "$AUTOPILOT_PROMPT_FILE" << AUTOPILOT_EOF
You are in Kirby Autopilot mode. The user direction:

$AUTOPILOT

Your mission:
1. Scan the current project directory — understand what exists
2. Search the web extensively (at least 5 searches) to research:
   - Best practices for building this type of project
   - Top 3-5 reference projects on GitHub in this domain
   - Recommended tech stack for 2025-2026
   - Common pitfalls to avoid
   - UI/UX patterns if applicable
3. Save your research to tasks/research.md (with source URLs)
4. Design the architecture and save to tasks/architecture.md
5. Write a full PRD and save to tasks/prd-[project-name].md
6. Convert to prd.json in the project root with 8-20 atomic user stories
7. Validate: run jq . prd.json to ensure valid JSON

CRITICAL: prd.json MUST follow this exact structure with keys: project, branchName, description, userStories (array). Each story needs: id (US-001 format), title, description, acceptanceCriteria (array of strings), priority (number), passes (false), notes (empty string). Stories must be ordered by dependency (setup then schema then backend then frontend then polish). Target 8-20 stories.

Be thorough in research. Make decisions confidently. Do NOT ask the user anything.
AUTOPILOT_EOF
  fi
  AUTOPILOT_PROMPT=$(cat "$AUTOPILOT_PROMPT_FILE")
  rm -f "$AUTOPILOT_PROMPT_FILE"

  set +e
  echo "Running autopilot research & planning phase..."

  if [[ "$TOOL" == "kiro" ]]; then
    AGENT_FLAG=""
    if [ -f ".kiro/agents/kirby.json" ] || [ -f "$HOME/.kiro/agents/kirby.json" ]; then
      AGENT_FLAG="--agent kirby"
    fi
    kiro-cli chat --no-interactive --trust-all-tools --wrap=never $AGENT_FLAG "$AUTOPILOT_PROMPT" 2>&1 || true
  elif [[ "$TOOL" == "amp" ]]; then
    echo "$AUTOPILOT_PROMPT" | amp --dangerously-allow-all 2>&1 | tee /dev/stderr > /dev/null || true
  else
    claude --dangerously-skip-permissions --print <<< "$AUTOPILOT_PROMPT" 2>&1 | tee /dev/stderr > /dev/null || true
  fi

  set -e
  if [ ! -f "$PRD_FILE" ]; then
    echo "Error: Autopilot failed to generate prd.json"
    echo "Check tasks/ directory for partial output."
    exit 1
  fi

  echo ""
  echo "==============================================================="
  echo "  Autopilot complete! PRD generated with $(jq '.userStories | length' "$PRD_FILE" 2>/dev/null || echo '?') stories"
  echo "  Research: tasks/research.md"
  echo "  Architecture: tasks/architecture.md"
  echo "  PRD: tasks/prd-*.md"
  echo "  Executable: prd.json"
  echo "==============================================================="
  echo ""
  echo "Starting implementation phase..."
  sleep 2
fi

if [ ! -f "$PRD_FILE" ]; then
  echo "Error: prd.json not found at $PRD_FILE"
  echo "Create one from prd.json.example or use the kirby skill to generate it."
  exit 1
fi

# --- Archive previous run if branch changed ---
if [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    DATE=$(date +%Y-%m-%d)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^kirby/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"

    echo "# Kirby Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Track current branch
CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
if [ -n "$CURRENT_BRANCH" ]; then
  echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
fi

# Initialize progress file
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Kirby Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# --- Strip ANSI escape codes ---
strip_ansi() {
  sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' | sed $'s/\x1b\[[?0-9;]*[a-zA-Z]//g' | sed $'s/\x1b(B//g'
}

# --- Main loop ---
echo "Starting Kirby - Tool: $TOOL - Max iterations: $MAX_ITERATIONS"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Kirby Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "==============================================================="

  PROMPT_CONTENT=$(cat "$SCRIPT_DIR/prompt.md")

  if [[ "$TOOL" == "kiro" ]]; then
    # Kiro looks for agents in CWD/.kiro/agents/ or ~/.kiro/agents/
    # Use --agent only if kirby agent is discoverable
    AGENT_FLAG=""
    if [ -f ".kiro/agents/kirby.json" ] || [ -f "$HOME/.kiro/agents/kirby.json" ]; then
      AGENT_FLAG="--agent kirby"
    fi
    OUTPUT=$(kiro-cli chat --no-interactive --trust-all-tools --wrap=never $AGENT_FLAG "$PROMPT_CONTENT" 2>&1 | tee /dev/stderr | strip_ansi) || true
  elif [[ "$TOOL" == "amp" ]]; then
    OUTPUT=$(echo "$PROMPT_CONTENT" | amp --dangerously-allow-all 2>&1 | tee /dev/stderr) || true
  else
    OUTPUT=$(claude --dangerously-skip-permissions --print <<< "$PROMPT_CONTENT" 2>&1 | tee /dev/stderr) || true
  fi

  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "==============================================================="
    echo "  Kirby completed all tasks!"
    echo "  Finished at iteration $i of $MAX_ITERATIONS"
    echo "==============================================================="
    exit 0
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "==============================================================="
echo "  Kirby reached max iterations ($MAX_ITERATIONS)."
echo "  Check progress: cat $PROGRESS_FILE"
echo "  Check PRD:      cat $PRD_FILE | jq '.userStories[] | {id, passes}'"
echo "==============================================================="
exit 1
