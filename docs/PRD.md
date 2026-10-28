# Product Requirements Document: SDP–ERPNext Bank Reconciliation Connector

**Status:** Approved direction; MVP and integration remain hypotheses pending operator validation.
**Working name:** Stellar Statement Bridge (not a final product or organization name).
**Research date:** 2026-10-28.

## Problem

Teams that use Stellar's Disbursement Platform (SDP) and ERPNext may need to transfer completed payout evidence into ERPNext's bank reconciliation workflow. SDP already provides payment records and exports; ERPNext already supports Bank Transactions and reconciliation. The proposed product connects those existing systems, preserves stable payment references, prevents duplicate imports, and leaves accounting decisions to the operator.

**Evidence boundary:** Public documentation verifies the APIs and ERPNext workflow. It does not verify that SDP operators use ERPNext, that manual conversion is a costly problem, or that a direct integration is absent. No customer interviews or pilot have been conducted. The project must validate these points before claiming demand.

## Users

- Finance or operations staff who reconcile SDP payouts with ERPNext payment vouchers.
- ERPNext implementers who configure that integration for organizations using SDP.

## Alternatives

- SDP's paginated payment API, individual payment export, and CSV exports.
- ERPNext's Bank Statement Import, Data Import/API, and manual Bank Transaction entry.
- A manually maintained converter or an organization-specific integration.
- Existing bank/payment reconciliation products where they already support the actual rails.

## Value proposition

Import completed Stellar payout evidence from SDP into ERPNext Bank Transactions with explicit asset/account mapping, stable source identifiers, duplicate protection, and a reviewable result. Reconciliation and accounting entries remain under the organization's existing ERPNext controls.

## Goals and measures

- Import an eligible SDP payment at most once, including after a retry or interrupted sync.
- Preserve the SDP payment ID, external payment ID when present, Stellar transaction ID, amount, asset identity, and source timestamps needed for traceability.
- Reject or queue records with unsupported status, missing Stellar transaction evidence, unknown asset/account mapping, invalid amount precision, or ambiguous mappings.
- Never create, submit, cancel, or alter Payment Entries, Journal Entries, or on-chain transactions.
- Measure import success, duplicate prevention, rejected records, and manual reconciliation time in a pilot. Numerical improvement targets are **unverified** until a baseline is collected.

## MVP scope

### In scope

1. One integration: an ERPNext Frappe app connecting to one configured SDP tenant.
2. Read-only SDP API credentials and paginated retrieval of payments.
3. A preview of eligible and excluded payments before import.
4. Explicit mapping from an SDP distribution wallet and exact Stellar asset identity (code + issuer) to a configured ERPNext Company Bank Account/ledger.
5. Import only successful payments with a Stellar transaction ID as ERPNext Bank Transaction records; keep source data linked through an app-owned sync record.
6. Stable idempotency using the SDP payment ID, including safe retry behavior.
7. A reviewable import result and exception list for pending, failed, canceled, missing-ID, unsupported-asset, precision, and ERPNext validation cases.
8. User-triggered import and bounded pagination/rate-aware retry. No automatic recurring sync in the first slice.
9. Documentation for setup, permissions, mapping, privacy, recovery, and supported version matrix.

### Out of scope

- Sending, retrying, pausing, or canceling payouts through SDP.
- Stellar key custody, transaction signing, Soroban contracts, or an on-chain indexer.
- Creating/submitting/modifying accounting vouchers or deciding journal treatment.
- Automatic invoice allocation, supplier identity resolution, FX conversion, fee treatment, tax handling, or multi-line settlement allocation.
- Other ERPs (including Odoo, QuickBooks, and SAP), anchors, cash-out services, or Circle-only payments.
- Cloud-hosted multi-tenant SaaS, analytics claims, or AI-based matching.

## Primary user journey

1. ERPNext administrator installs the app and creates a least-privilege, read-only SDP API key.
2. Administrator configures the SDP base URL, optional wallet scope, Company, Bank Account, and exact asset mapping.
3. Finance user requests a sync preview for a bounded date/status range.
4. The app fetches all pages, validates records, and displays eligible, already-imported, and blocked rows with reasons.
5. User confirms import. The app creates Bank Transactions only for eligible successful Stellar payments, recording a unique source mapping atomically.
6. User reviews the imported transactions and uses ERPNext's native Bank Reconciliation workflow to match existing vouchers.
7. User resolves blocked cases in the source or configuration and repeats the sync safely.

## Functional requirements and acceptance criteria

| ID | Requirement | Verifiable acceptance criterion | Priority |
|---|---|---|---|
| FR-1 | Configure SDP connection securely | SDP secret is stored as a protected Frappe password field; UI/API responses and logs never return it. | P0 |
| FR-2 | Fetch payment pages | Client follows SDP pagination to completion, respects configured wallet/date filters, times out safely, and reports partial failure without marking incomplete data complete. | P0 |
| FR-3 | Preview and validate | Each payment is classified eligible, already imported, or blocked with a specific reason before writes begin. | P0 |
| FR-4 | Validate Stellar and asset identity | Only `SUCCESS` payments with a non-empty Stellar transaction ID and exact configured asset code + issuer can be imported. | P0 |
| FR-5 | Import Bank Transactions | A confirmed eligible payment creates one ERPNext Bank Transaction with correct deposit/withdrawal direction, exact decimal amount, date, mapped account, and traceable description/reference. | P0 |
| FR-6 | Prevent duplicate imports | Repeating or concurrently submitting an import for the same SDP payment does not create another Bank Transaction; database constraints and transaction boundaries enforce this. | P0 |
| FR-7 | Preserve source linkage | Each created Bank Transaction has one app-owned sync record containing the SDP payment UUID, external ID, Stellar transaction ID, source update time, and target document reference. | P0 |
| FR-8 | Do not post accounting | Tests confirm the app never creates/submits/cancels Payment Entry or Journal Entry and never calls write-capable SDP endpoints. | P0 |
| FR-9 | Recover from partial errors | Failed row writes remain retryable; successful rows remain deduplicated; the run report identifies each outcome. | P0 |
| FR-10 | Enforce permissions | Only an authorized ERPNext role can edit connection/mapping or run imports; ordinary users cannot read secrets. | P0 |
| FR-11 | Document operations | Setup, least-privilege key creation, mapping, backup/retention, and safe recovery instructions match the implemented behavior. | P1 |

## Non-functional requirements

- Never use binary floating-point for token amounts; parse decimal strings and enforce the target account's configured precision.
- Keep recipient PII and secrets out of logs, issue examples, and public docs. Store only the minimum payment evidence needed for ERP traceability.
- All network calls use TLS, bounded timeouts, pagination limits, and retry rules that do not duplicate writes.
- ERPNext writes are scoped to Bank Transaction and the app's own sync records.
- The prototype targets the current Frappe/ERPNext v16 line. Exact minimum patch releases and supported pairings remain pending an install smoke test in a clean bench. The initial pure normalizer tests run on Python 3.14 without Frappe.
- The product is an integration aid, not an accounting, compliance, custody, or payment execution service.

## Dependencies and risks

- SDP API key access, payment endpoint pagination and response schema; verify against the selected SDP deployment before production use.
- ERPNext app installation, Bank Transaction document validation, exact permissions and API behavior for the supported release.
- User must configure matching ERPNext currency/account treatment for each Stellar asset. An asset code alone is insufficient; issuer identity matters.
- A completed SDP payment may lack a usable on-chain transaction ID in non-Stellar settlement configurations; such records must be excluded or handled as unsupported.
- ERPNext account currency precision and accounting policy can make a chain amount unsuitable for direct import; reject rather than round silently.
- Duplicate protection across retries and concurrent workers is a critical correctness boundary.
- Customer demand and Drips Wave eligibility remain unverified; no approval is implied.

## Pilot gate

Before describing the integration as solving a real customer problem, validate with at least five qualified SDP/ERPNext operators or implementers. At least three should independently report the same recurring manual task, one should supply sanitized records and agree to pilot, and a small sample must demonstrate correct asset/account mapping and deduplication. If the ERP's native importer or an existing connector already solves the task, contribute there or stop.
