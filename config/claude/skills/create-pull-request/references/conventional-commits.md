# Conventional Commits Reference

Source: https://www.conventionalcommits.org/en/v1.0.0/

## Commit Message Format

```
[JIRA-TICKET] <type>[optional scope]: <description>
```

Everything fits on **one line**. No body, no footers, no multi-line summaries.

### Examples

```
[PROJ-123] feat(auth): add JWT token validation
[PROJ-456] fix: correct null pointer in user lookup
[PROJ-789] refactor(api): extract payment service
[PROJ-101] chore: update dependencies
[PROJ-202] feat!: redesign authentication flow
```

---

## Jira Ticket Extraction

The Jira ticket number appears first in square brackets.

**Extract from branch name** — branch names start with the ticket number:
- `PROJ-123-add-auth` → `[PROJ-123]`
- `feat/PROJ-456-fix-login` → `[PROJ-456]`
- Pattern: find the first `[A-Z]+-\d+` segment in the branch name

**If the branch name has no ticket number**, ask the user: "What's the Jira ticket number for this branch? (e.g. PROJ-123)"

---

## Type Reference

| Type | When to use | SemVer impact |
|------|-------------|---------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | — |
| `style` | Formatting, no logic change | — |
| `refactor` | Code restructure, no feature/fix | — |
| `perf` | Performance improvement | PATCH |
| `test` | Adding or updating tests | — |
| `build` | Build system or dependency changes | — |
| `ci` | CI/CD configuration changes | — |
| `chore` | Other maintenance tasks | — |

---

## Breaking Changes

Indicate a breaking change with `!` before the colon:

```
[PROJ-123] feat!: redesign user authentication API
[PROJ-456] fix(auth)!: remove legacy token support
```

---

## Formal Specification (v1.0.0)

1. Commits MUST be prefixed with a type (noun: `feat`, `fix`, etc.), followed by an optional scope, an optional `!`, then a colon and space.
2. `feat` MUST be used for commits introducing a new feature.
3. `fix` MUST be used for commits patching a bug.
4. A scope MAY be provided in parentheses after the type: `feat(parser):`.
5. A description MUST immediately follow the type/scope colon and space — a short summary in present tense.
6. A body and footers are part of the spec but in this project we use **single-line messages only** — omit them.
7. Breaking changes MUST be indicated by appending `!` after the type/scope, before the colon.
8. Types other than `feat` and `fix` MAY be used (see table above).
9. Units of information are NOT case-sensitive, except `BREAKING CHANGE` which MUST be uppercase (but we use `!` notation instead).

---

## Validation Checklist

Before creating a PR, verify each unpushed commit on the branch:

- [ ] Starts with `[JIRA-XXX]` ticket prefix
- [ ] Has a valid type (`feat`, `fix`, `docs`, etc.)
- [ ] Has a colon and space after type/scope
- [ ] Description is present and concise
- [ ] Single line — no multi-line body
- [ ] Breaking change uses `!` if applicable
