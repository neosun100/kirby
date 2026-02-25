---
name: autopilot
description: "Autonomous project bootstrapper — researches the web, designs architecture, generates PRD, and produces prd.json. Use when starting from scratch or a vague idea. Triggers on: autopilot, sage mode, bootstrap this project, figure out what to build, research and plan, 自驱模式, 圣人模式."
user-invocable: true
---

# Kirby Autopilot — Self-Driven Research & Planning

Turn a vague idea (or an empty project) into a fully researched, production-ready PRD with user stories — without asking the user a single question.

---

## When to Activate

- User says "autopilot", "sage mode", "圣人模式", "自驱", or similar
- User gives only a direction like "build me a todo app" with no details
- Project directory is empty or has only boilerplate
- User explicitly skips clarifying questions

---

## The Job

### Phase 1 — Understand the Landscape

1. **Scan the project directory** — read README, package.json, existing code, config files. Understand what exists.
2. **Identify the domain** — what kind of project is this? (web app, CLI tool, API, library, etc.)
3. **Search the web extensively** for:
   - Best practices and architecture patterns for this type of project
   - Popular open-source references (find 3-5 top GitHub repos in this domain)
   - Current tech stack trends and recommendations (2025-2026)
   - Common pitfalls and anti-patterns to avoid
   - UI/UX patterns if it's a user-facing app
4. **Analyze reference projects** — read their READMEs, understand their feature sets, note what makes them good
5. **Save research** to `tasks/research.md` with sources and key findings

### Phase 2 — Design the Architecture

Based on research, decide:

1. **Tech stack** — framework, database, styling, testing, deployment
2. **Project structure** — directory layout, module organization
3. **Core features** — what the MVP must have vs nice-to-have
4. **Data model** — entities, relationships, key schemas
5. **API design** — endpoints or server actions needed
6. **Save architecture** to `tasks/architecture.md`

### Phase 3 — Generate the PRD

Create a comprehensive PRD following the standard format:

1. Introduction/Overview
2. Goals (specific, measurable)
3. User Stories (small, atomic, dependency-ordered)
4. Functional Requirements
5. Non-Goals
6. Technical Considerations (from research)
7. Success Metrics

**Save to** `tasks/prd-[project-name].md`

### Phase 4 — Convert to prd.json

Convert the PRD into Kirby's executable format:

```json
{
  "project": "[Project Name]",
  "branchName": "kirby/[feature-kebab]",
  "description": "[from research]",
  "userStories": [...]
}
```

**Critical rules for stories:**
- Each story completable in ONE iteration (one context window)
- Ordered by dependency: project setup → schema → backend → frontend → polish
- Every story has "Typecheck passes" or equivalent quality check
- UI stories include "Verify in browser if browser tools available"

**Save to** `prd.json` in project root.

---

## Research Quality Standards

When searching the web:

- **Minimum 5 searches** covering different aspects (architecture, best practices, UI patterns, similar projects, common issues)
- **Read actual documentation**, not just summaries
- **Compare at least 3 reference projects** in the same domain
- **Note specific versions** of frameworks/libraries (don't recommend outdated tech)
- **Include source URLs** in research.md for traceability

---

## Story Sizing Guide for Autopilot

Since autopilot generates ALL stories from scratch, be extra careful about sizing:

**Phase 1 stories (setup):**
- US-001: Initialize project with chosen framework + config
- US-002: Set up database schema / data model
- US-003: Set up project structure and base components

**Phase 2 stories (core backend):**
- One story per CRUD operation or server action
- One story per API endpoint group

**Phase 3 stories (core frontend):**
- One story per page/route
- One story per complex component

**Phase 4 stories (integration & polish):**
- One story per cross-cutting concern (auth, error handling, etc.)
- One story for responsive design
- One story for final quality pass

**Target: 8-20 stories total.** More than 20 means stories are too granular. Fewer than 8 means they're too big.

---

## Output Files

| File | Purpose |
|------|---------|
| `tasks/research.md` | Web research findings with sources |
| `tasks/architecture.md` | Tech stack and design decisions |
| `tasks/prd-[name].md` | Full PRD document |
| `prd.json` | Kirby-executable user stories |

---

## Autopilot Prompt Template

When activated, use this internal reasoning flow (do NOT show to user):

```
1. What does the project directory tell me?
2. What domain is this? What are users expecting?
3. [SEARCH] What are the best projects in this space?
4. [SEARCH] What tech stack is recommended in 2025-2026?
5. [SEARCH] What are common mistakes to avoid?
6. [SEARCH] What UI/UX patterns work best here?
7. [SEARCH] What's the ideal project structure?
8. Based on all research, what's the optimal architecture?
9. What are the MVP features? What can wait?
10. Break into atomic, dependency-ordered stories
11. Generate prd.json
```

---

## Checklist Before Finishing

- [ ] Searched the web for at least 5 different aspects
- [ ] Analyzed 3+ reference projects
- [ ] Saved research.md with sources
- [ ] Saved architecture.md with tech decisions
- [ ] Generated full PRD with all sections
- [ ] Converted to prd.json with properly sized stories
- [ ] Stories ordered by dependency
- [ ] Every story has quality check criteria
- [ ] Total story count is 8-20
- [ ] prd.json is valid JSON (test with `jq . prd.json`)
