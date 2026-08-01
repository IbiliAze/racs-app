---
name: feedback-pagination-approach
description: User prefers SQL-level pagination (offset/limit in the query) over client-side pagination (load all, slice in memory)
metadata:
  type: feedback
---

Prefer SQL-level pagination: pass page/size to the repository so the DB query uses LIMIT/OFFSET, rather than loading all rows and slicing in Dart.

**Why:** Avoids loading the entire dataset into memory; scales with data size.

**How to apply:** When adding pagination to a list screen, add a count query to the repository, track page state in the view model, and have the VM call the repo with `CardParams(page: ..., size: ...)` — not load-all then skip/take.