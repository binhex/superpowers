# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer built what was requested (nothing more, nothing less)

## Dispatch

```typescript
task({
  agent: "reviewer",
  tasks: [{
    id: "ReviewSpecCompliance",
    description: "Review spec compliance for Task N",
    assignment: `Review spec compliance for Task N: [task name]

[paste the full prompt text from the Copilot section above, starting from
"You are reviewing whether an implementation matches its specification"
through to the end of the Report block]`
  }],
  context: "fresh"
})
```
