# Customer discovery: SDP payments into ERPNext bank reconciliation

**Status:** Proposed validation protocol; no interviews have been conducted.
**Research date:** 2026-10-28

## Hypothesis under test

Finance/operations teams that use both Stellar's Disbursement Platform (SDP) and ERPNext may need to move completed payout evidence into ERPNext's Bank Transaction/reconciliation workflow. Existing SDP exports and ERPNext statement import may already be sufficient. A connector could reduce conversion and duplicate-control work without initiating payments or posting accounting vouchers.

This hypothesis may be false. SDP already offers bulk payouts, payment status tracking, analytics, permission controls, and accounting-compatible CSV exports. The goal is to find a concrete gap, not to persuade people that one exists.

## Who to interview

Prioritize people who personally operate payments rather than general blockchain enthusiasts. The initial product hypothesis targets ERPNext; if interviews show no relevant operators, change the target ERP rather than force the fit:

1. Finance or operations staff at an organization that has used SDP for vendor payments in the last 90 days.
2. Engineers or operations staff who integrate SDP with ERPNext or an accounting product.
3. SDP service providers or implementation partners who support reconciliation workflows.

Record role and system context. Do not collect names, recipient identities, account secrets, private keys, or confidential payment records in this document.

## Interview questions

Ask for the most recent real workflow. Avoid pitching the proposed product before understanding current behavior.

1. Walk me through the last vendor-payment batch you reconciled, from the ERPNext payable/payment voucher to final status.
2. Which systems and files did you use? What was copied or matched manually?
3. How do you currently connect each expected payment with its SDP result or Stellar transaction?
4. Tell me about the last payment that was missing, late, failed, partial, duplicated, or difficult to identify. What happened next?
5. How often do those cases occur, and how much staff time does one case typically take?
6. What does SDP's export or existing accounting integration handle well? What still needs manual work?
7. Do you populate SDP's custom `paymentID` field? If so, how is it generated, carried into the ERP/AP record, and used for search or export?
8. What happens if a payment status changes after the accounting record was closed?
9. Which identifiers are available on both sides (batch ID, recipient ID, reference, memo, amount, asset, transaction hash)? Which are unreliable?
10. What controls, audit evidence, or approval rules must reconciliation preserve?
11. Do you use ERPNext? How do you bring statement rows into Bank Transactions, and what mapping or conversion does SDP require?
12. What ERP/accounting connector or API exists today? Has your team checked for an existing SDP integration or tried to build one?
13. What would prevent you from using an integration that creates statement-side Bank Transactions but never creates or submits vouchers? Who would approve and maintain it?
14. If this remains manual, what is the consequence? Can you quantify the last incident rather than estimate a hypothetical benefit?
15. Would you share sanitized SDP payment data and test it against a sandbox ERPNext account? Who can authorize that?

## Evidence to request

Request a sanitized sample of one completed batch and its source payable export, plus a separate sample containing known exceptions if available. Ask the participant to remove names, emails, wallet labels, invoice text, internal account IDs, access tokens, and any sensitive data. Public transaction hashes can link to counterparties and should be included only with explicit permission.

Minimum fields to investigate (not a committed schema):

- Source system's payable/batch identifier and expected status.
- Expected amount and currency/asset.
- Non-identifying recipient key or pseudonym.
- SDP disbursement identifier/status and relevant timestamps.
- Stellar transaction hash and ledger/time when applicable.
- A reference/memo field only if the participant confirms it is safe to share.
- Operator resolution and reason for exceptions.

## Proposed continue / stop criteria

These are proposed decision thresholds, not market statistics or program requirements.

Proceed from the planning scaffold to a user-facing pilot build only if all are true:

- At least five qualified operators/integrators are interviewed.
- At least three independently describe the same recurring manual step converting completed SDP payments into ERPNext Bank Transactions that is not adequately served by native CSV import.
- At least one operator can provide sanitized SDP records and an ERPNext sandbox or agrees to pilot a reviewed import.
- A representative dataset can verify exact asset mapping, amount precision, duplicate protection, and traceability without exposing unnecessary personal data.
- The workflow uses existing SDP/ERPNext interfaces and does not duplicate payment execution, custody, or a general reconciliation engine.

Stop or redirect if SDP/ERPNext native import already covers the use case, the pain occurs rarely, no operator can provide data/pilot access, or the solution requires custody/signing or regulated financial activity to deliver the claimed benefit.

## Current evidence and limits

- SDF's public SDP page describes vendor payouts, batch payments, recipient onboarding, tracking, analytics, permissions, and accounting-compatible exports: [Stellar Disbursement Platform](https://stellar.org/products-and-tools/disbursement-platform).
- The official API reference documents CSV export of disbursement records with status and date filters: [Export Disbursements API](https://developers.stellar.org/docs/platforms/stellar-disbursement-platform/api-reference/export-disbursements).
- SDP's [List All Payments API](https://developers.stellar.org/docs/platforms/stellar-disbursement-platform/api-reference/list-all-payments) documents pagination, status/date/type filters, payment UUID, optional external payment ID, Stellar transaction ID, amount, and asset code/issuer.
- ERPNext documents [Bank Transactions](https://docs.frappe.io/erpnext/bank-transaction) as statement evidence that users match to accounting vouchers; its [Bank Reconciliation workflow](https://docs.frappe.io/erpnext/bank-reconciliation) leaves voucher and accounting decisions in ERPNext.
- These public docs establish a feasible integration surface, not a customer problem or market gap. No interview, pilot, market sizing, workflow observation, or private-system access has taken place.

## Interview log

| Date | Role (no personal name) | Uses SDP? | Current matching flow | Observed exception | Time/cost evidence | Follow-up |
|---|---|---|---|---|---|---|
| | | | | | | |
