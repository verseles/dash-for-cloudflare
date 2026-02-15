# Contributing to Dash for CF

Thanks for contributing. This project keeps changes small, testable, and releasable.

## Workflow

1. Create a branch from `main`.
2. Run local validation:
   - `make check` during development
   - `make precommit` before committing
3. Open a PR with:
   - Problem statement or feature description
   - Change summary
   - Test evidence (`make test` output, screenshots, or logs)

## Commit Convention

Use Conventional Commits:

- `feat:` new behavior
- `fix:` bug fix
- `docs:` documentation only
- `refactor:` non-behavioral code change
- `test:` test-only changes
- `chore:` maintenance

## Quality Gates

- Keep generated code committed (`*.g.dart`, `*.freezed.dart`).
- Do not introduce new analyzer debt beyond the current budget (see `make analyze`).
- Keep coverage above the repository threshold (see `make coverage`).
- All tests must pass before committing.

## Coding Guidelines

- Avoid `print()`; use `LogService` (`log.info()`, `log.error()`, etc.).
- Prefer small focused PRs over large multi-topic changes.
- Follow existing patterns: Riverpod for state, Freezed for models, Retrofit for API.

## Reporting Issues

Include:

- Platform and OS version
- Flutter and Dart versions (`flutter --version`)
- Reproducible steps
- Expected vs actual behavior
- Logs or screenshots when available
