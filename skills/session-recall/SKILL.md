---
name: session-recall
description: >
  Progressive session recall using the auto-memory `session-recall` CLI.
  Use this skill at the start of EVERY task to recover context from previous
  sessions — recently touched files, prior conversations, and checkpoints —
  before touching any code or running any searches.
allowed-tools: bash
license: MIT (auto-memory by Desi Villanueva — https://github.com/dezgit2025/auto-memory)
---

## Session Recall — Run Before Every Task

`session-recall` queries `~/.copilot/session-store.db` for prior context.
Costs ~50 tokens per call. Prevents expensive blind filesystem searches and
re-orientation after context compaction.

### Install Check (run before every task)

#### 1. Check if already installed

```bash
which session-recall 2>/dev/null
```

If found, run `session-recall schema-check` and proceed to the Recall Workflow.

#### 2. If not installed — ask the user first

**Before running any install command**, tell the user:

> `session-recall` (auto-memory) is not installed. It gives Copilot memory of
> previous sessions at ~50 tokens per query. Install it now?

Wait for an explicit yes/no. Do NOT install silently.

- **User says no**: skip recall entirely for this task and proceed without it.
- **User says yes**: run the install script from this skill's base directory:

  ```bash
  bash install-auto-memory.sh
  ```

  The script tries `uv` → `pipx` → `pip` in order and verifies the install.
  If it exits non-zero, report the error to the user and proceed without recall.

#### 3. After install — verify

```bash
session-recall schema-check
```

If schema-check passes, proceed to the Recall Workflow below.

If `session-recall` errors for any reason after a successful install, **continue
silently** — recall is a convenience, not a blocker. Never abort a task because
`session-recall` failed.

---

### Recall Workflow (run in order, stop when oriented)

#### Step 1 — Recent files (always run first)

```bash
session-recall files --json --limit 10
```

Returns the 10 most recently touched files. Use to orient to active work areas
without grepping the filesystem.

#### Step 2 — Recent sessions

```bash
session-recall list --json --limit 5
```

Lists the 5 most recent sessions with summaries. Scan for context relevant to
the current task.

#### Step 3 — Keyword search (when the task has identifiable terms)

```bash
session-recall search '<keyword>' --json
```

Full-text search across all session history. Use the task description, key
function names, or file names as search terms.

#### Step 4 — Deep dive (when a specific session looks relevant)

```bash
session-recall show <session-id> --json
```

Full detail of one session. Use when `list` or `search` returns a session ID
worth inspecting.

#### Step 5 — Recent checkpoints (for multi-session features)

```bash
session-recall checkpoints --days 3
```

Checkpoints from the last 3 days. Use when the task is a continuation of
recent work.

---

### Time-Filtered Variants

All four query commands accept `--days N` to restrict results to the last N days:

```bash
session-recall files --days 7 --json       # files touched in last 7 days
session-recall list --days 2 --json        # sessions from last 2 days
session-recall search '<keyword>' --days 5 # search last 5 days only
session-recall checkpoints --days 3        # checkpoints from last 3 days
```

---

### Health and Maintenance

```bash
session-recall health --json    # 8-dimension DB health check
session-recall schema-check     # run after every Copilot CLI upgrade
```

Run `session-recall schema-check` after any `copilot` binary upgrade. If it
exits non-zero, follow the upgrade procedure at:
`https://github.com/dezgit2025/auto-memory/blob/main/UPGRADE-COPILOT-CLI.md`

---

### Decision Logic

```
session-recall returns relevant context
        │
        ├─ YES → use that context; skip or narrow filesystem searches
        │
        └─ NO  → fall back to grep / glob / find as normal
```

Do not run `session-recall` more than once per task start — a single pass of
the workflow above is sufficient. Prefer `session-recall` over `grep`/`find`
for orientation at ~200x token efficiency.
