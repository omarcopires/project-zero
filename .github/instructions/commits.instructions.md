---
description: "Use when preparing, reviewing, or making commits: English Conventional Commits, a project title limit of 72 characters, a detailed body, and owner authorization before committing."
---

# Commit policy

## When to commit

- Commit **only** after an explicit owner request or confirmation that the feature is complete and approved. Do not commit automatically when a task appears finished.
- Do not commit partial or unverified changes, or changes with known blockers, without explicit authorization. If the owner requests a diff review first, wait for that review.
- A commit does not bypass prohibitions on builds, compiled tests, running the client/server, or changing the original frontend.
- Do not push, force-push, rebase public history, tag, or publish without a specific request.

## English Conventional Commits

- Required type: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, or `revert`.
- Optional lowercase English scope: `feat(protocol):`, `fix(session):`.
- Mark breaking changes with `!` after the type/scope and explain them in the body.
- Write subject and body in English. Use an imperative subject without a final period: `add session state machine`.
- Project subject limit: **72 characters**, preferably **50**. This is a project rule, not a universal GitHub limit.

## Body

Separate the subject and body with a blank line. Explain what changed, why, and what limitations remain rather than narrating the diff. Wrap lines at 72 characters. Include relevant context, technical decisions, frontend impact, checks actually performed, pending builds/tests, and references. Use standard footers such as `BREAKING CHANGE:`, `Refs:`, or `Closes:` when appropriate. Never include credentials, tokens, sensitive data, or personal paths.

```text
feat(protocol): add 15.25 message framing decoder

Implement incremental decoding for the 15.25 wire contract:
- preserve boundaries across partial TCP reads
- reject oversized frames with explicit protocol errors
- cover valid, truncated, and concatenated inputs in unit tests

Build and integration tests remain pending for the owner/CI.
Refs: docs/project-plan-2026-09-17.md (phase 1)
```

Before committing, confirm authorization, review the diff and protected paths, exclude generated files and secrets, and accurately state validation limits.
