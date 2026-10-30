# Architecture: SDP–ERPNext Bank Reconciliation Connector

**Status:** Prototype scope; compatibility and real operator workflow still require validation. The initial scaffold and pure normalizer exist; no network or ERP write integration exists.
**Topology:** One installable Frappe/ERPNext app. No Soroban contract, standalone backend, indexer, or hosted database.

## Context and data flow

```text
Finance user
  -> ERPNext connector UI
      -> SDP API (read-only API key; paginated payment records)
      -> preview + validation
      -> ERPNext database transaction
           -> Bank Transaction (statement evidence only)
           -> SDP Sync Record (unique source identity and import state)
  -> ERPNext native Bank Reconciliation (human matches existing vouchers)
```

The app runs inside the customer's ERPNext/Frappe deployment. It retrieves SDP payment records and creates statement-side Bank Transaction records only after an explicit user confirmation. ERPNext's native workflow remains responsible for matching these records to existing accounting vouchers. No on-chain interaction is needed because SDP exposes payment status and Stellar transaction identifiers.

## Components

| Component | Responsibility | Interface | Dependency |
|---|---|---|---|
| SDP Connection settings | Tenant base URL, optional distribution wallet, protected API secret, enabled state | Frappe Single DocType/form | Frappe permissions/password field |
| Asset/account mapping | Exact Stellar asset `(code, issuer)` and wallet scope to Company + ERPNext Bank Account | Child DocType rows with validation | ERPNext Company/Bank Account/Currency |
| SDP client | Read-only HTTPS requests, filters, pagination, response validation, bounded retry | Internal Python service | SDP `GET /payments`; verified current API docs |
| Preview service | Normalize records and classify eligible/already imported/blocked | Internal service + preview response | SDP client, mapping, sync records |
| Import service | Atomically create Bank Transaction and source sync record; no accounting voucher writes | Explicit ERPNext action | Bank Transaction DocType; Frappe database |
| Sync record | Durable idempotency key and source/target link; no unnecessary recipient PII | App-owned DocType with unique source payment key | ERPNext database transaction/unique constraint |
| Run report | Per-payment outcomes and sanitized errors for review/retry | Frappe UI/list view | Frappe logging and permissions |

## External SDP interface

Verified current docs describe `GET /payments` as paginated, with filters including payment status, date, type, and receiver; result fields include payment `id`, `external_payment_id`, `stellar_transaction_id`, amount, status, asset code/issuer, and source wallet. `q` can search IDs/external IDs. API-key docs describe granular read/write scope and optional IP restrictions. The implementation must request only read access and must not call write endpoints.

Relevant references:

- [List All Payments](https://developers.stellar.org/docs/platforms/stellar-disbursement-platform/api-reference/list-all-payments)
- [API Keys](https://developers.stellar.org/docs/platforms/stellar-disbursement-platform/api-reference/api-keys)
- [Export Payments](https://developers.stellar.org/docs/platforms/stellar-disbursement-platform/api-reference/export-payments-csv)
- [ERPNext Bank Transaction](https://docs.frappe.io/erpnext/bank-transaction)
- [ERPNext Bank Reconciliation](https://docs.frappe.io/erpnext/bank-reconciliation)
- [Frappe REST API](https://docs.frappe.io/framework/user/en/guides/integration/rest_api)

No API base path, hosted tenant URL, retry-after behavior, or specific production tenant configuration is hard-coded until confirmed for the chosen SDP instance.

## Data model

### SDP Connection (single configuration)

- `sdp_base_url`: HTTPS origin/base URL; validate allowed scheme and reject embedded credentials/fragments.
- `api_key`: protected Frappe password field; never returned to client code.
- `wallet_id`: optional SDP distribution wallet scope.
- `enabled`: explicit connection state.
- `last_successful_sync_at`: timestamp, updated only after all requested pages are fetched and processed.

### Asset mapping

- `wallet_id` (optional if connection-level scope is used).
- `asset_code` and `asset_issuer` as an exact pair.
- `company` and `bank_account`.
- Validate the account belongs to the Company and currency/precision can represent imported values. Never infer issuer from code alone.

### SDP Sync Record

- `source_payment_id`: SDP payment UUID; unique together with connection identity.
- `external_payment_id`: optional upstream business reference.
- `stellar_transaction_id`: required for imported records.
- `sdp_updated_at`, `sdp_status`, `asset_code`, `asset_issuer`, `amount`, `source_wallet_id`.
- `bank_transaction`: link to the created ERPNext Bank Transaction.
- `state`: imported, already imported, blocked, or retryable error.
- `error_code`: sanitized stable error category; no API key or raw personal data.

Only retain fields needed for duplicate prevention, matching, audit and recovery. Avoid persisting recipient contact details or addresses unless pilot requirements prove they are necessary.

## Import and state rules

1. Fetch a bounded set of pages and validate the response shape before permitting import. An incomplete fetch cannot be represented as a complete run.
2. Only `SUCCESS` payments with `stellar_transaction_id`, a supported direct/disbursement type, exact configured asset mapping, and a representable decimal amount are eligible.
3. `PENDING`, `FAILED`, `CANCELED`, unknown states, non-Stellar settlement records, unknown issuers, missing transaction IDs, and precision mismatches are visible as blocked/excluded rows. They do not create Bank Transactions.
4. User confirms selected eligible rows after preview.
5. For each selected row, create the Bank Transaction and unique sync record in one database transaction. Use the configured Stellar wallet ledger/account, represent outgoing payout as a withdrawal, preserve amount as exact decimal, set payment date based on verified source semantics, and store stable source reference fields.
6. If an ID already exists, report it as already imported. If unique-key insertion loses a concurrency race, roll back that row and reload the existing sync record.
7. A partially failed import reports row-level outcomes. Successful rows remain linked and will not duplicate on retry. A cursor/sync watermark advances only when all source pages have been fetched successfully.
8. The app never creates or submits Payment Entry or Journal Entry, never changes ERPNext account balances directly, and never sends an SDP or Stellar payment.

Exact Bank Transaction field names, date choice (payment-created vs ledger timestamp), reference mapping, and permission behavior must be verified against the chosen ERPNext release and a sandbox instance before implementation is considered complete.

## Authentication and authorization

- SDP credential is read-only, restricted to the minimum payment-read permissions and source IP where the SDP supports it.
- Frappe roles: an administrator manages connection and mapping; a configured finance role can preview/import; viewers can review outcomes. Never expose decrypted secrets to browser/client requests.
- Use Frappe's request/session authorization and document permission checks for every write action.
- Reject non-HTTPS SDP endpoints except an explicit local development configuration.
- No wallet secret, signing key, Stellar transaction-building key, or custody function exists.

## Failure handling and observability

- Explicit connection, authentication, authorization, rate limit, timeout, schema mismatch, pagination, mapping, validation, and ERP write error categories.
- Bounded request timeouts and retries only for transient read failures. Do not retry a write without checking the unique source key.
- Do not log full SDP payment payloads, recipient identifiers, Authorization headers, API keys, or raw customer data.
- Provide operator-visible per-run counts: fetched, eligible, imported, already imported, excluded, and failed.
- Use an audit trail for configuration changes and explicit import confirmation.
- Recovery uses the sync record to resume only unimported eligible payment IDs; never resubmit money.

## Deployment and versioning

- Install as a custom Frappe app into a customer's existing ERPNext deployment; no external hosted service is required.
- Initial target is the current v16 line. The local bench uses Frappe v16.54.0 and ERPNext v16.53.0 from the `version-16` branch as of 2026-10-30. Do not claim a supported matrix until the app installs and runs on a verified ERPNext site.
- Frappe's v16 installation guide requires Python 3.14 and Node 24. The WSL bench now has Python 3.14.4, Node 24.22.2, Yarn 1.22.22, Bench 5.31.1, Frappe v16.54.0, ERPNext v16.53.0, and the product app at commit `8216126`. Frappe, ERPNext, and product-app asset builds pass. No site exists, so site-level installation and Bank Transaction compatibility remain unverified.
- ERPNext v16.53.0 source at commit `9cd11b19575bfc34f092a24f6c8b368c4dd69481` contains a Bank Statement Import workflow for mapped CSV/MT940 statements and a Bank Transaction import path that inserts and submits mapped rows. The exact fit with SDP exports, and whether SDP-specific deduplication and account mapping justify a separate app, require operator validation.
- SDP deployments may differ; test against an official local SDP sandbox/fixture and a real authorized sandbox tenant before production claims.
- No production URLs, keys, tenant IDs, deployment IDs, or contract addresses are included in source control.

Current compatibility sources:

- [Frappe releases](https://github.com/frappe/frappe/releases)
- [ERPNext v16 tags](https://github.com/frappe/erpnext/tags)
- [Frappe installation requirements](https://docs.frappe.io/framework/user/en/installation)

## Testing strategy

- Unit tests: response schema parsing, pagination completion, decimal precision, asset issuer mapping, status classification, and idempotency key construction.
- Frappe integration tests: Bank Transaction creation, unique source linkage, row-level rollback, role enforcement, and forbidden voucher writes.
- Mock HTTP tests: pagination, empty pages, 401/403, throttling, timeouts, malformed payloads, and interrupted imports.
- Sandbox acceptance: import a sanitized sample, compare every source row and amount, retry twice, and verify exactly one Bank Transaction per eligible SDP payment; confirm no Payment Entry/Journal Entry was created.
- No production deployment until customer-specific asset-account mapping and finance review are documented.

## Open decisions

1. Confirm with operators whether ERPNext is used by the target SDP teams; otherwise select the ERP from evidence and re-scope.
2. Validate that importing Bank Transactions is more useful than the native CSV flow and that manual ERP reconciliation remains costly.
3. Install a clean Frappe/ERPNext v16 bench and verify exact Bank Transaction fields and app compatibility.
4. Decide date/reference field semantics from current SDP response behavior and the pilot's accounting policy.
5. Confirm the final product name; `Stellar Statement Bridge` remains a working label.
