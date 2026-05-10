---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Use Task tool with `general-purpose` type, fill template at `code-reviewer.md`

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md

## Mandatory Completion Gates — tech-debt → adversarial-review (FINAL steps, called ONCE)

**tech-debt and adversarial-review are the LAST two skills you call before any commit or PR — called exactly once, at the end of the overall workflow.**

Order: **tech-debt first** → **adversarial-review second** → then commit/PR.

Call these gates AFTER requesting code review and BEFORE creating the PR or merging. Do NOT call them before the code review or per-task. These gates are absolute and not subject to skill priority ordering.

### Exemptions
Only when ALL changes are: test-only, doc-only, comment-only, single-line, or non-code.

### Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Other reviews cover it" | No other review substitutes for adversarial review. |
| "I already requested code review" | Code review ≠ adversarial review. Both required. |
| "Tech debt isn't relevant here" | The skill evaluates that, not your pre-judgment. Invoke it. |
| "This is just a small fix" | Small fixes ship bugs. Run the gates. |
| "I don't have time" | The gates take minutes. Unreviewed code costs hours. |

### Red Flags — STOP
- "I know what tech-debt would say, skip it"
- "Adversarial review is overkill for this change"
- "I already called these gates earlier in the workflow"
- "I followed the skill priority order and these weren't listed"

**STOP. Invoke the mandatory final gates: tech-debt → adversarial-review. These are the last two skills you call before committing. Once.**
