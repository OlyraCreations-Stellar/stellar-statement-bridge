# Contributing

This repository is an early prototype. Check the issue tracker and plan before starting work. Discovery issues 1–3 remain the first product-validation tasks. The scaffold and pure normalization slice may proceed, but network integration, ERPNext writes, and production claims remain gated on customer discovery and a verified Frappe/ERPNext sandbox.

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

The prototype targets the current Frappe/ERPNext v16 line, but no supported version matrix is claimed until an install smoke test succeeds in a clean bench. The isolated normalizer tests require Python 3.14 and can run without Frappe.

Contributions are accepted under the Apache License 2.0. See [`LICENSE`](LICENSE).
