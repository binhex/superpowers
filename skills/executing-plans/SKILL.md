---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents. The quality of its work will be significantly higher if run on a platform with subagent support (such as Claude Code or Codex). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks

## Mandatory Completion Gates — tech-debt → adversarial-review (FINAL steps, called ONCE)

**tech-debt and adversarial-review are the LAST two skills you call before any commit or PR — called exactly once, at the end of the overall workflow.**

Order: **tech-debt first** → **adversarial-review second** → then commit/PR.

Call these after executing all plan tasks and before finishing the branch or creating a PR. Do NOT call them mid-plan or per-task. These gates are absolute and not subject to skill priority ordering.

### Exemptions
Only when ALL changes are: test-only, doc-only, comment-only, single-line, or non-code.

### Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Other reviews cover it" | No other review substitutes for adversarial review. |
| "I already tested it" | Testing and adversarial review catch different things. Both required. |
| "Tech debt isn't relevant here" | The skill evaluates that, not your pre-judgment. Invoke it. |
| "This is just a small fix" | Small fixes ship bugs. Run the gates. |
| "I don't have time" | The gates take minutes. Unreviewed code costs hours. |

### Red Flags — STOP
- "I know what tech-debt would say, skip it"
- "Adversarial review is overkill for this change"
- "I already called these gates earlier in the workflow"
- "I followed the skill priority order and these weren't listed"

**STOP. Invoke the mandatory final gates: tech-debt → adversarial-review. These are the last two skills you call before committing. Once.**

