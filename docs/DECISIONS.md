# Engineering decisions log

## ADR-001: Focus on an SDP-to-ERPNext reconciliation connector

- **Status:** Proposed; product direction approved for research and planning.
- **Date:** 2026-10-28.
- **Context:** SDP already offers payout creation, status tracking, payment identifiers, exports, and API access. ERPNext already supports Bank Transactions and reconciliation. A generic sender/dashboard or generic matcher would add little.
- **Options:** Build a new payout app; build a generic ERP adapter; build a focused SDP-to-ERPNext app; contribute to SDP/ERPNext or an existing project; stop if native CSV import is sufficient.
- **Decision:** Continue with a single ERPNext integration hypothesis, pending operator validation. Import only completed Stellar payment evidence into ERPNext statement-side Bank Transactions.
- **Consequences:** The scope can be small and uses verified public interfaces, but may be irrelevant if few SDP operators use ERPNext or native import already solves the workflow. Re-evaluate before a pilot if either condition is true.

## ADR-002: No Soroban contract or standalone backend in the MVP

- **Status:** Proposed.
- **Date:** 2026-10-28.
- **Context:** The MVP reads SDP payment results and writes records into ERPNext. It does not need shared on-chain state, custody, transaction signing, or a separate public indexer.
- **Options:** Soroban contract, web service/indexer, ERPNext/Frappe app.
- **Decision:** Use one installable Frappe app if operator discovery supports the product. Add no contract, indexer, or hosted backend without a demonstrated requirement.
- **Consequences:** Fewer components and security boundaries; distribution and maintenance follow the customer's ERPNext install process.

## ADR-003: Import statement evidence only; never post vouchers

- **Status:** Proposed and reflected in the PRD/architecture acceptance criteria.
- **Date:** 2026-10-28.
- **Context:** ERPNext Payment Entries and Journal Entries can create General Ledger entries. Automatically choosing and posting accounting treatment can create incorrect books or duplicate liability settlement.
- **Options:** Auto-create/submit accounting vouchers; create drafts; create only Bank Transactions for operator reconciliation.
- **Decision:** Create only Bank Transaction statement records after explicit user confirmation. Let ERPNext users match existing vouchers through native reconciliation. Never submit or alter a Payment Entry or Journal Entry.
- **Consequences:** Keeps accounting decisions with the operator but does not eliminate the need to validate mapping, currency, amount precision, and audit trail.

## ADR-004: One repository; one ERP integration

- **Status:** Proposed.
- **Date:** 2026-10-28.
- **Context:** There is no Soroban contract and no independently deployed API. Splitting an app and a contract would add no justified boundary.
- **Options:** App+contract repos; app+backend repos; one Frappe app repository.
- **Decision:** Plan one repository for the Frappe app and documentation. ERPNext version support and exact structure remain to be selected after compatibility research.
- **Consequences:** Simpler contributor setup; a future second ERP integration should be evidence-led and may remain a separate package only if maintenance or release needs justify it.

## ADR-005: Organization/repository naming remains provisional

- **Status:** Blocked on organization creation in GitHub web UI; no external organization or repository exists.
- **Date:** 2026-10-28.
- **Context:** The authenticated `OlyraCreations` identity is a personal account with no current organization memberships. The name `OlyraLabs` belongs to an unrelated public organization. GitHub CLI in this environment lists organizations and creates repositories but has no organization-create command; the documented REST organization endpoints also do not expose creation.
- **Options:** Publish under the personal account; create a new organization through GitHub's web interface; choose another existing organization (not authorized).
- **Decision:** Prepare local files under the provisional folder `OlyraCreations-Stellar/stellar-statement-bridge`; do not publish or use an unrelated organization. The provisional organization handle is not confirmed or created.
- **Consequences:** The local draft is ready for transfer/rename once the user creates or selects the organization. The public repo and 20 issues cannot be created under the requested new organization until that web-only step is complete.
