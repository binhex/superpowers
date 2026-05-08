# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent.

## Dispatch

```typescript
task({
  agent: "task",
  tasks: [{
    id: "ImplementTaskN",
    description: "Implement Task N: [task name]",
    assignment: `Implement Task N: [task name]

[paste the full prompt text from the Copilot section above, starting from
"You are implementing Task N" through to the end of the Report Format block]`
  }],
  context: "fresh"
})
```
