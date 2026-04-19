---
name: adversarial-review
description: You MUST use after ANY code change — The only exemptions are test only changes, documentation only changes, comment-only changes, single-line changes, and non-code related tasks.
---

# Adversarial Review

## Overview

After ANY code change, YOU (the main agent) run a dual-model adversarial review loop directly in the current session. Do NOT delegate this skill to a sub-agent — the orchestration MUST happen in your session so the user can see live progress.

Two independent reviewer sub-agents (GPT-5.4 and Claude Opus 4.6) are dispatched in parallel for each round. You gather their findings, de-duplicate, fix every issue reported, narrate progress throughout, then repeat — until **both reviewers return zero issues in the same round OR the max number of loops is reached**.

**Core principle:** Violating the letter of this process is violating the spirit of it.

## What Counts as  Code Change?

**REQUIRES adversarial review (all code logic changes):**
- Bug fixes
- Refactors
- New features
- Performance changes
- Security patches
- Configuration logic changes

**EXEMPT (skip the review):**
- Test-only changes (`test_*.py`, `*_test.*`, `*.test.*`)
- Documentation-only changes (`.md`, `.rst`, docstrings)
- Comment-only changes
- Single-line changes
- Non code related tasks

**If in doubt: it's a code change. Run the review.**

## The Loop

At each step, narrate what you are doing so the user can follow progress.

```
MAX_ROUNDS = <from Step 0>
current_round = 0

WHILE issues > 0 AND current_round < MAX_ROUNDS:

  current_round += 1
  Announce: "🔍 Adversarial review — round current_round/MAX_ROUNDS starting. Dispatching GPT-5.4 and Claude Opus 4.6..."

  1. Dispatch BOTH reviewer sub-agents in parallel (background mode):
     - Reviewer A: gpt-5.4 model
     - Reviewer B: claude-opus-4.6 model
     Each receives: the full diff + relevant file context

  2. Announce: "⏳ Waiting for both reviewers..."
     Read both results as they complete.

  3. Announce findings as each reviewer returns, e.g.:
     "GPT-5.4 found 3 issues: [brief list]"
     "Claude Opus found 2 issues: [brief list]"

  4. De-duplicate and announce:
     "📋 De-duplicated: N unique issues to fix — [list]"

  5. Fix ALL issues — no exceptions.
     Announce each fix: "🔧 Fixing: [issue description]"

  6. Announce: "✅ Round current_round complete. Starting round current_round+1..."

IF current_round == MAX_ROUNDS AND issues > 0:
  Announce: "⚠️ Max rounds (MAX_ROUNDS) reached. N issues remain: [list]. Manual user review required before proceeding."
ELSE:
  Announce: "✅ Adversarial review complete — both models returned clean."
```

## Step 0: Determine Maximum Rounds

**Before doing anything else**, ask the user how many review-fix-review iterations to allow at most.

**Interactive mode** — use the `ask_user` tool with a single integer field:
- Title: "Maximum adversarial review rounds"
- Description: "The loop stops after this many rounds even if issues remain."
- Type: integer, minimum 1, **default 3**

**Autopilot / non-interactive mode** (when `ask_user` is unavailable): set `MAX_ROUNDS = 3` automatically and announce it.

Announce: `"🔢 Maximum rounds set to MAX_ROUNDS."`

## Step 1: Get the Diff

Before dispatching agents, determine which state the change is in and obtain the diff accordingly.

**State 1 — Uncommitted (staged or unstaged changes):**
```bash
git diff HEAD          # all working-tree changes vs last commit
# or, if changes are staged:
git diff --cached      # staged changes only
```

**State 2 — Committed but not yet pushed:**
```bash
git diff origin/$(git rev-parse --abbrev-ref HEAD)..HEAD
# e.g. git diff origin/dev..HEAD
```

Pass the full diff text to both review sub-agents. If the diff is large, also include the relevant file contents for context.

## Dispatching Reviewer Sub-Agents

The two REVIEWERS are sub-agents. YOU (main agent) are the orchestrator — you dispatch them, read their results, and narrate findings to the user. Never delegate the orchestration itself.

Use the `task` tool with `mode: "background"` and `agent_type: "code-review"` for both reviewers simultaneously:

```
Reviewer A prompt:
  "Review this diff for bugs, logic errors, security issues, and
   correctness problems. Be adversarial — assume the code is wrong
   until proven otherwise. List every issue you find with file:line
   references."
  model: gpt-5.4

Reviewer B prompt: (identical prompt)
  model: claude-opus-4.6
```

Wait for both to complete (`read_agent`), then immediately report their findings to the user before proceeding to de-duplicate.

## Stopping Condition

The loop stops on whichever condition is met first:

**Clean pass (ideal):** both agents return zero issues in the same round.

```
Round N:  Agent A = 0 issues, Agent B = 0 issues  →  DONE ✅
Round N:  Agent A = 1 issue,  Agent B = 0 issues  →  Fix and continue 🔄
Round N:  Agent A = 0 issues, Agent B = 1 issue   →  Fix and continue 🔄
```

**Max rounds reached:** `current_round == MAX_ROUNDS` and issues still remain.
→ Report every remaining issue clearly and require manual user review before proceeding.
→ Do NOT silently drop issues. Do NOT resume the loop without re-invoking the skill.

**"Minor" is not a stopping condition.** Style, naming, and preference findings must be fixed before declaring done. If both agents agree an issue is truly trivial AND you fix it, it will disappear from the next round — that is when you stop.

## The Iron Law

```
DO NOT STOP THE LOOP WHILE ANY AGENT REPORTS ANY ISSUE
— unless the user-set MAX_ROUNDS cap has been reached.
```

**No exceptions:**
- Not for "it's just a style issue"
- Not for "it's only a variable name"
- Not for "it's noise, not signal"
- Not for "we're running behind"
- Not for "senior engineer already approved it"
- Not for "I feel like I've done enough rounds" (the cap was set by the user, not by your fatigue)

**The one legitimate exit with issues remaining:** `current_round == MAX_ROUNDS`. This is the user's explicit instruction — honour it by reporting every remaining issue, then stop. Do NOT use this as a loophole to exit early when the cap hasn't been reached.

The loop is not optional. It exists **for** the moments when you are tired and tempted to skip it.

## Red Flags — Stop and Re-read This Skill

- "Other reviews cover it, I do not need to run Adversarial Review"
- "I ran spec compliance + code quality reviews via subagent-driven-development — that's enough"
- "The final code reviewer in subagent-driven-development already approved it"
- "This issue is minor, I'll skip it"
- "I feel like enough rounds have run" (check: has MAX_ROUNDS actually been reached?)
- "This is just a bug fix, not a code change"
- "The first model came back clean so the second is redundant"
- "Noise, not signal"
- "Being pragmatic"
- "I've used Rubber Duck, I don't need to perform an Adversarial Review"

**All of these mean: you are about to violate the loop. RUN ADVERSARIAL REVIEW.**

### The Subagent-Driven-Development Bypass Trap

When following `subagent-driven-development`, each task gets a spec review, a code quality review, and a final code review. This feels thorough — and it is, for those concerns. **But it is NOT a substitute for adversarial review.**

The `finishing-a-development-branch` skill (which subagent-driven-development calls at the end) now enforces adversarial review as Step 0. If you reach that skill without having run adversarial review, it will stop you. But do not wait for that stop — invoke adversarial review proactively after implementation is complete, before finishing the branch.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's just a style issue" | Fix it. It clears in one round. Loop ends faster than arguing about it. |
| "N rounds is enough" (cap not reached) | The stopping condition is zero issues or MAX_ROUNDS — not your fatigue. |
| "Bug fix isn't a code change" | Bug fixes change logic. Logic changes require review. |
| "First model was clean" | Two models catch different failure classes. One clean ≠ done. |
| "Senior engineer approved" | Informal review ≠ adversarial diff review. Both are needed. |
| "We're behind schedule" | The loop takes minutes. Shipping unreviewed code costs hours. |
| "I already manually tested it" | Manual testing and adversarial review catch different things. Both required. |
