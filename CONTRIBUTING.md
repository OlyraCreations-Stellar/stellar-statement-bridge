# Contributing

This repository is in discovery and has no runnable app yet. Check the issue tracker and the draft plan before starting work. The draft list in `docs/ISSUE_BACKLOG_DRAFT.md` is not a public task assignment; issues will be created after the repository owner and project scope are established.

## Before opening an issue or pull request

- Search existing issues and discussions first.
- For feature work, describe the operator problem and how it differs from SDP or ERPNext's built-in import/reconciliation tools.
- Do not include private payment data, recipient details, API keys, wallet secrets, or live transaction screenshots.
- Confirm dependencies and acceptance criteria with maintainers before starting a cross-component change.

## Pull requests

- Keep changes focused and reference the issue they solve.
- Include `Closes #<issue>` when the PR fully completes an issue.
- Add tests for implemented behavior once the app and test harness exist.
- Update documentation when behavior, permissions, or supported versions change.
- Never add a write-capable SDP call, a key custody path, or automatic accounting voucher submission without a separately reviewed product and security decision.

The supported Python, Frappe, and ERPNext versions will be documented after compatibility research. Until then, do not assume a version matrix.
