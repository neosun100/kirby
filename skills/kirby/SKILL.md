---
name: kirby
description: "Convert PRDs to prd.json format for the Kirby autonomous agent system. Use when you have an existing PRD and need to convert it to Kirby's JSON format. Triggers on: convert this prd, turn this into kirby format, create prd.json from this, kirby json."
user-invocable: true
---

# Kirby PRD Converter

Converts existing PRDs to the prd.json format that Kirby uses for autonomous execution.

---

## The Job

Take a PRD (markdown file or text) and convert it to `prd.json` in your kirby directory.

---

## Output Format

```json
{
  "project": "[Project Name]",
  "branchName": "kirby/[feature-name-kebab-case]",
  "description": "[Feature description from PRD title/intro]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[Story title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

---

## Story Size: The Number One Rule

**Each story must be completable in ONE Kirby iteration (one context window).**

Kirby spawns a fresh Kiro CLI instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):
- "Build the entire dashboard" → Split into: schema, queries, UI components, filters
- "Add authentication" → Split into: schema, middleware, login UI, session handling

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

---

## Acceptance Criteria: Must Be Verifiable

### Good criteria (verifiable):
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Typecheck passes"

### Bad criteria (vague):
- "Works correctly"
- "Good UX"

### Always include as final criterion:
```
"Typecheck passes"
```

### For stories that change UI, also include:
```
"Verify in browser if browser tools available"
```

---

## Conversion Rules

1. **Each user story becomes one JSON entry**
2. **IDs**: Sequential (US-001, US-002, etc.)
3. **Priority**: Based on dependency order, then document order
4. **All stories**: `passes: false` and empty `notes`
5. **branchName**: Derive from feature name, kebab-case, prefixed with `kirby/`
6. **Always add**: "Typecheck passes" to every story's acceptance criteria

---

## Archiving Previous Runs

**Before writing a new prd.json, check if there is an existing one from a different feature:**

1. Read the current `prd.json` if it exists
2. Check if `branchName` differs from the new feature's branch name
3. If different AND `progress.txt` has content beyond the header:
   - Create archive folder: `archive/YYYY-MM-DD-feature-name/`
   - Copy current `prd.json` and `progress.txt` to archive
   - Reset `progress.txt` with fresh header

**The kirby.sh script handles this automatically** when you run it.

---

## Checklist Before Saving

- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories are ordered by dependency (schema → backend → UI)
- [ ] Every story has "Typecheck passes" as criterion
- [ ] UI stories have "Verify in browser if browser tools available" as criterion
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No story depends on a later story
