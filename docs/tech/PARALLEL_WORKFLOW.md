# Gatherly — Parallel task workflow (worktrees + QA)

Goal: run multiple Linear tasks in parallel with isolation and high confidence.

## Defaults
- Concurrency target: **up to 3 tasks in flight** (recommended). Increase only when CI/deploy is stable and tasks are cleanly separated.
- Isolation mechanism: **git worktree** per task.
- Every task uses `tech/TASK_TEMPLATE.md` (success criteria + tests + rollout).

## Roles

### Worker (per task)
- Implements the task in its own worktree/branch.
- Keeps changes scoped.

### QA (per task, separate)
- Does not implement.
- Runs checks/tests, reviews diff vs success criteria.
- Produces a short QA report + questions.

### Human (Qingbo)
- Manual review + merge gate.

## Worktree layout

- Main repo: `~/Projects/personal/gatherly`
- Task worktrees: `~/Projects/personal/gatherly/.worktrees/<TASK_ID>`

Example:
- `.worktrees/GAT-55`
- branch `task/GAT-55-health-home`

## Commands

Create worktree:
```bash
scripts/worktree-new.sh GAT-55 task/GAT-55-health-home
cd .worktrees/GAT-55
```

Run QA locally:
```bash
../../scripts/qa.sh .
```

Remove worktree:
```bash
cd ~/Projects/personal/gatherly
scripts/worktree-rm.sh GAT-55 --delete-branch task/GAT-55-health-home
```

## Standard operating procedure

1) Pick tasks for the current iteration.
2) For each task:
   - create worktree + branch
   - execute task work
   - run QA
3) If QA passes:
   - open PR or prepare merge
   - pause for human review
4) Merge one-by-one to reduce conflicts.

## Merge hygiene
- Keep tasks small.
- Avoid editing the same files across worktrees.
- Prefer merging infra/CI changes first before feature work.
