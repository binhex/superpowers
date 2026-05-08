# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

## Copilot / opencode harness

```
Task tool (superpowers:code-reviewer):
  Use template at requesting-code-review/code-reviewer.md

  WHAT_WAS_IMPLEMENTED: [from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
  DESCRIPTION: [task summary]
```


**In addition to standard code quality concerns, the reviewer should check:**
- Does each file have one clear responsibility with a well-defined interface?
- Are units decomposed so they can be understood and tested independently?
- Is the implementation following the file structure from the plan?
- Did this implementation create new files that are already large, or significantly grow existing files? (Don't flag pre-existing file sizes — focus on what this change contributed.)

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment

## OMP harness

```typescript
task({
  agent: "reviewer",
  tasks: [{
    id: "ReviewCodeQuality",
    description: "Review code quality for Task N",
    assignment: `Review code quality for Task N: [task name]

What was implemented: [from implementer's report]
Plan/requirements: Task N from [plan-file]
Base SHA: [commit before task]
Head SHA: [current commit]

Review the diff (git diff BASE_SHA..HEAD_SHA) and the changed files for:
- Code cleanliness and maintainability
- Test coverage and quality
- File structure and separation of concerns
- Naming clarity and accuracy
- YAGNI / over-engineering
- Established codebase patterns

Return: Strengths, Issues (Critical/Important/Minor), Assessment (approved or not).`
  }],
  context: "fresh"
})
```
