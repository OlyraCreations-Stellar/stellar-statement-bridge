# Contributor issue backlog (20 issues)

**Repository:** Proposed single Frappe/ERPNext app.
**Status:** Published as 20 GitHub issues in `OlyraCreations-Stellar/stellar-statement-bridge`. Supported ERPNext versions and a pilot are not yet established.
**Wave status:** These issues are not submitted to Drips Wave. Repository acceptance and issue selection are separate review steps.

Issues 1–3 validate integration assumptions before contributors build against them. Issues 4–20 are labeled `status: blocked` until a maintainer records a go decision based on customer discovery. Labels are project workflow labels, not a claim about mandatory Drips labels.

## 1. `docs(discovery): document the supported SDP payment fields`

**Type/complexity:** research / trivial
**Summary:** Compare the current SDP API response with a sanitized sandbox response. Record fields, version/deployment differences, pagination behavior, and what identifies a completed Stellar payment.
**Acceptance Criteria:**
- [ ] Doc links to current official API reference and records the checked date.
- [ ] Sanitized sample has no recipient PII, API keys, or live account secrets.
- [ ] Required and optional fields for the MVP are listed; undocumented assumptions are explicit.
**Tech Stack:** Markdown, official Stellar SDP docs, authorized sandbox only.

## 2. `docs(discovery): verify ERPNext bank transaction import behavior`

**Type/complexity:** research / trivial
**Summary:** Verify supported ERPNext/Frappe releases, Bank Transaction fields, import paths, and permissions in a disposable sandbox.
**Acceptance Criteria:**
- [ ] Supported versions are named with evidence from maintained release/docs and an install smoke check.
- [ ] Required Bank Transaction fields and currency/date constraints are recorded.
- [ ] No live financial records are used.
**Tech Stack:** ERPNext, Frappe Framework, Markdown.

## 3. `docs(discovery): compare native CSV import with SDP connector workflow`

**Type/complexity:** research / trivial
**Summary:** Measure the steps and errors for native CSV conversion/import versus the proposed connector using the same sanitized sample.
**Acceptance Criteria:**
- [ ] Same test dataset and explicit comparison steps are documented.
- [ ] Time, manual edits, duplicate handling, and rejected rows are reported without fabricated performance claims.
- [ ] A stop recommendation is recorded if native import is already sufficient.
**Tech Stack:** SDP CSV/API export, ERPNext sandbox, Markdown.

## 4. `feat(app): scaffold installable Frappe application`

**Type/complexity:** feature / medium
**Summary:** Create the minimal custom app structure and install it on the supported ERPNext/Frappe matrix.
**Acceptance Criteria:**
- [ ] App installs and uninstalls on each declared supported version.
- [ ] No sample secrets or production endpoints are committed.
- [ ] Basic CI can import the app and run its test command.
**Tech Stack:** Python, Frappe Framework, ERPNext.

## 5. `feat(config): add protected SDP connection settings`

**Type/complexity:** feature / medium
**Summary:** Add an administrator-managed SDP connection with validated HTTPS base URL, protected API key, optional wallet scope, and enabled state.
**Acceptance Criteria:**
- [ ] Secret uses protected Frappe storage and never appears in read responses or logs.
- [ ] URL validation rejects embedded credentials and unsafe schemes.
- [ ] Settings writes require the administrator role.
**Tech Stack:** Frappe DocTypes, Python, ERPNext permissions.

## 6. `feat(config): map Stellar assets to ERPNext bank accounts`

**Type/complexity:** feature / medium
**Summary:** Configure an exact asset `(code, issuer)` and wallet mapping to Company and Bank Account.
**Acceptance Criteria:**
- [ ] Mapping rejects code-only matches and invalid Company/Bank Account relationships.
- [ ] Unsupported currency precision is rejected with a clear reason.
- [ ] Duplicate or overlapping mappings are blocked or made unambiguous.
**Tech Stack:** Frappe DocTypes, ERPNext Company/Bank Account/Currency.

## 7. `feat(sdp-client): implement read-only authenticated API client`

**Type/complexity:** feature / medium
**Summary:** Implement a bounded HTTP client for the documented SDP payment-read API.
**Acceptance Criteria:**
- [ ] Requests use the configured credential over TLS.
- [ ] Client has explicit timeout, response-size, and error handling.
- [ ] Tests prove it never invokes SDP write endpoints and never logs authorization data.
**Tech Stack:** Python standard/approved HTTP client, Frappe.

## 8. `feat(sdp-client): fetch every payment page safely`

**Type/complexity:** feature / medium
**Summary:** Retrieve all pages within a configured date/status scope and detect incomplete pagination.
**Acceptance Criteria:**
- [ ] Next-page links/metadata are followed without skipping or duplicating rows.
- [ ] Empty final page, API failure, and malformed pagination are handled explicitly.
- [ ] An incomplete fetch cannot be reported as a complete run.
**Tech Stack:** Python, SDP API, mocked HTTP tests.

## 9. `feat(normalization): validate payment status and Stellar evidence`

**Type/complexity:** feature / medium
**Summary:** Normalize payment responses and classify unsupported or non-Stellar settlement rows before import.
**Acceptance Criteria:**
- [ ] Only configured successful payments with a Stellar transaction ID can be eligible.
- [ ] Pending, failed, canceled, unknown, and missing-transaction-ID records receive stable exclusion reasons.
- [ ] Unknown response fields do not crash the whole sync.
**Tech Stack:** Python, typed validation, unit tests.

## 10. `feat(preview): show eligible and blocked payment rows`

**Type/complexity:** feature / medium
**Summary:** Add a preview that displays eligible, already-imported, and blocked rows with safe evidence and reasons.
**Acceptance Criteria:**
- [ ] User can review asset, amount, status, references, and target account before writes.
- [ ] Recipient PII and secret values are omitted or masked.
- [ ] Preview does not create ERPNext documents.
**Tech Stack:** Frappe UI, Python services.

## 11. `feat(sync): add unique SDP payment sync record`

**Type/complexity:** feature / medium
**Summary:** Store a minimal unique mapping from SDP payment identity to the imported ERPNext document.
**Acceptance Criteria:**
- [ ] Source identity is unique per configured SDP connection.
- [ ] Sync record stores only fields required for audit, deduplication, and retry.
- [ ] Permission tests prevent unauthorized viewing/editing.
**Tech Stack:** Frappe DocType, database unique constraint.

## 12. `feat(import): create ERPNext Bank Transactions atomically`

**Type/complexity:** feature / high
**Summary:** Import eligible payment rows as statement-side Bank Transactions with linked sync records.
**Acceptance Criteria:**
- [ ] Correct amount, withdrawal direction, configured Bank Account, date, and references are mapped.
- [ ] Bank Transaction and sync record commit or roll back together for each payment.
- [ ] No Payment Entry or Journal Entry is created, submitted, canceled, or modified.
**Tech Stack:** Python, Frappe ORM/transactions, ERPNext Bank Transaction.

## 13. `feat(sync): make imports safe under retries and concurrency`

**Type/complexity:** feature / high
**Summary:** Ensure repeated and concurrent imports cannot create duplicate Bank Transactions.
**Acceptance Criteria:**
- [ ] Re-import reports already imported without another target document.
- [ ] Concurrent attempts are resolved by database uniqueness and safe reload.
- [ ] Fault injection after a failed row proves prior successful rows remain deduplicated.
**Tech Stack:** Frappe database transactions, integration tests.

## 14. `feat(import): report row outcomes and resumable failures`

**Type/complexity:** feature / medium
**Summary:** Provide per-row imported, already imported, excluded, or retryable failure outcomes.
**Acceptance Criteria:**
- [ ] Run totals match row-level outcomes.
- [ ] Retry processes only eligible rows without a committed sync record.
- [ ] Watermark advances only after complete page retrieval and handling.
**Tech Stack:** Frappe DocTypes, Python, ERPNext UI.

## 15. `feat(permissions): restrict config and import actions by role`

**Type/complexity:** security / medium
**Summary:** Define roles for integration configuration, import execution, and read-only review.
**Acceptance Criteria:**
- [ ] Unauthorized users cannot configure connections, read secrets, or run imports.
- [ ] API methods enforce permissions server-side, not only in UI controls.
- [ ] Role matrix and manual verification steps are documented.
**Tech Stack:** Frappe role permissions, Python tests.

## 16. `feat(validation): reject amount precision and asset mismatches`

**Type/complexity:** security / medium
**Summary:** Validate exact decimal amounts and asset/account mapping before any Bank Transaction write.
**Acceptance Criteria:**
- [ ] Monetary values use decimal arithmetic, not binary floats.
- [ ] Issuer mismatch, unsupported precision, zero/negative/invalid values are rejected.
- [ ] Rejected rows include an actionable reason and create no accounting record.
**Tech Stack:** Python Decimal, ERPNext currency metadata, unit tests.

## 17. `feat(audit): add sanitized integration run history`

**Type/complexity:** feature / medium
**Summary:** Record who requested each preview/import and the sanitized per-row result.
**Acceptance Criteria:**
- [ ] Audit entry identifies actor, time, scope, and counts.
- [ ] Logs contain no API keys, raw recipient details, or unbounded source payloads.
- [ ] Retention and deletion behavior are documented.
**Tech Stack:** Frappe audit fields/DocTypes, Python logging.

## 18. `test(integration): cover SDP and ERPNext import failure cases`

**Type/complexity:** testing / high
**Summary:** Add integration coverage for API failures, partial imports, duplicate IDs, permissions, and unsupported records.
**Acceptance Criteria:**
- [ ] Tests cover 401/403, throttling, timeout, malformed pages, and recovery.
- [ ] Tests prove duplicate prevention and no voucher writes.
- [ ] Tests use synthetic or sanitized fixtures only.
**Tech Stack:** Frappe test runner, Python test fixtures, mocked HTTP.

## 19. `ci(app): add supported-version test matrix`

**Type/complexity:** maintenance / medium
**Summary:** Run lint and app tests on every declared supported Frappe/ERPNext release.
**Acceptance Criteria:**
- [ ] Matrix matches the documented support policy.
- [ ] CI uses no production credentials or live payment endpoint.
- [ ] Failure status is required for merge once branch protections are configured.
**Tech Stack:** GitHub Actions, Python, Frappe test environment.

## 20. `docs(app): document setup, permissions, mapping, and recovery`

**Type/complexity:** documentation / medium
**Summary:** Publish operator and developer guides that match implemented behavior.
**Acceptance Criteria:**
- [ ] Setup covers supported versions, read-only SDP key, mapping, preview, import, and ERPNext reconciliation.
- [ ] Recovery guide covers duplicate detection and partial failures.
- [ ] Docs state that the app does not provide accounting, compliance, custody, or payout guarantees.
**Tech Stack:** Markdown, Frappe/ERPNext and Stellar docs.
