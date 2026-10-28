# Idea evaluation and recommendation

**Evaluation date:** 2026-10-28
**Evidence level:** Ecosystem and repository metadata review completed; direct customer discovery, full code-level competitor audits, and corridor validation remain outstanding.

## Weighted decision rubric

Scores are qualitative (1 = weak, 5 = strong), not measured market facts. The categories are problem significance, differentiation, Stellar relevance, feasibility, adoption path, security/regulatory manageability, MVP scope, and Wave/ecosystem fit.

| Candidate | Problem | Differentiate | Stellar fit | Feasible | Adoption path | Risk manageability | MVP | Program fit | Verdict |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Generic outbound Stellar vendor payout app | 3 | 1 | 4* | 4 | 2 | 2 | 4 | 2 | **REJECT as standalone** |
| SDP-to-ERPNext Bank Reconciliation Connector | 2 | 3 | 4* | 3 | 2 | 3 | 3 | 3 | **CONDITIONAL pending demand evidence** |
| SEP Conformance and Webhook Replay Kit | 3 | 3 | 5 | 3 | 2 | 4 | 3 | 3 | **CONDITIONAL** |
| Treasury Payment Control | 3 | 2 | 3* | 2 | 2 | 1 | 2 | 3 | **WEAK** |
| Soroban Release Evidence Pack | 3 | 2 | 5 | 3 | 2 | 3 | 3 | 3 | **WEAK** |
| Agricultural Supplier Payout Workflow | 4 | 3 | 3* | 2 | 1 | 1 | 2 | 3 | **CONDITIONAL** |
| Recipient Payment History/Notifications | 3 | 1 | 5 | 2 | 2 | 3 | 3 | 3 | **REJECT as a new standalone project** |

`*` Stellar fit only if the target users already use Stellar rails and benefit from them. Scores do not establish demand or program eligibility.

## Critical review by idea

### 1. SDP-to-ERPNext Bank Reconciliation Connector — CONDITIONAL; generic payout app is rejected

**Similarity classification:** Close functional overlap with SDP's status, search, payment IDs, exports, and accounting handoff. Close workflow similarity to PaymentFlow's reconciliation in school payments, but serving a different operating context. Adjacent to Concord's securities-register reconciliation and DeenBridge's payment verification. Stellopay is a close neighbor for payroll disbursement; TrustBridge is distinct in recipient payout readiness. Similarity is acceptable only if the proposed connector materially improves an observed user workflow.

**New high-priority competitor:** SDF's official [Stellar Disbursement Platform](https://stellar.org/products-and-tools/disbursement-platform) already targets bulk payouts including vendor payouts. Its public product page lists batches up to 10,000 recipients, wallet onboarding, real-time tracking, analytics, user permissions, and CSV exports designed for accounting software. The official [disbursement export API](https://developers.stellar.org/docs/platforms/stellar-disbursement-platform/api-reference/export-disbursements) confirms CSV export of disbursement records and status filtering. Building another payout sender/dashboard would add little value.

**Adjacent competitors:** [Stellopay](https://github.com/Stellopay/stellopay-core) covers Soroban payroll, scheduled and recurring disbursements, retries, splits, and payment history. Mercado handles supplier financing and milestone payments. Accensa covers incoming x402 merchant receipts and disputes. These products further reduce the value of another broad payout/merchant dashboard.

**Potential improvement:** A Frappe app could import completed Stellar SDP payment evidence into ERPNext's native Bank Transaction/reconciliation workflow. SDP's paginated payment API includes payment ID, optional external payment ID, Stellar transaction ID, status, amount, and asset code/issuer. ERPNext represents imported bank activity as Bank Transactions, which users match to accounting vouchers. This supports a concrete connector, but does not prove demand or that a manual CSV workflow is inadequate. PaymentFlow and Concord show related reconciliation approaches in other domains; their existence makes comparison and learning necessary, not automatic rejection.

**Accounting boundary:** ERPNext's Payment Entry posts General Ledger records. A failed or duplicate integration could misstate books, so the MVP only creates statement-side Bank Transactions. It must not create/submit Payment Entries or Journal Entries. The operator reviews and matches records through the ERP's normal reconciliation controls.

**Security/regulatory:** Keep it read-only, never collect signing keys, keep sensitive invoice/counterparty data off-chain, encrypt stored data, restrict access, and define retention. Do not initiate fiat conversion or custody. If later scope includes payments, legal/KYC/AML and operational responsibilities increase sharply.

**Minimum validation gate:** Interview at least five finance/operations users of SDP or other Stellar disbursement operations. Obtain de-identified examples of at least 20 payable-to-disbursement matching cases. Ask specifically how they use SDP exports and accounting integrations today. Proceed only if users independently identify a recurring reconciliation task not covered by SDP or their ERP/accounting tool, and one agrees to pilot an adapter.

### 2. SEP Conformance and Webhook Replay Kit — CONDITIONAL

**Why it could work:** SEP interoperability bugs can be integration-specific, and deterministic replay of signed callbacks/idempotency cases may help wallet/anchor teams.

**Why it might fail:** Official documentation, sample apps, Anchor Platform event support, and test anchors may already be adequate. If maintainers do not adopt fixtures into CI, the product becomes another lightly used toolkit. This would be better validated with anchor developers before any implementation.

**Gate:** Ask 5 wallet/anchor teams which SEP lifecycle regressions have cost them time and whether they would integrate a conformance/replay test into CI. Identify existing official or community harnesses before scoping.

### 3. Treasury Payment Control — WEAK

**Why it could work:** Organizations managing stablecoin balances may want policy, approval, and reporting controls.

**Why it is weak:** Wallets, native multisig, payroll, and agent spending controls already cover adjacent capabilities. A product that signs or controls funds has a high security bar and would require wallet integrations, audit/recovery procedures, and institutional trust. A read-only dashboard alone is easy to copy and hard to sell.

**Gate:** Only reconsider with a treasury customer who names a policy gap not served by current wallets and accepts a pilot with no custody.

### 4. Soroban Release Evidence Pack — WEAK

**Why it could work:** A repeatable release report combining simulation and compatibility evidence could help maintainers.

**Why it is weak:** Cost estimation, failed transaction debugging, event indexing, monitoring, state exploration, and security scanning already appear in approved repos. It risks becoming a bundle of existing tools or implying a security guarantee it cannot provide.

**Gate:** Find a Soroban team with a painful release regression and prove the existing tools cannot be composed to solve it; otherwise contribute to an existing tool.

### 5. Agricultural Supplier Payout Workflow — CONDITIONAL, high execution risk

**Why it could work:** Faster, more transparent supplier payments could support financial inclusion and working capital in a specific corridor.

**Why it is conditional:** Existing supply-chain finance projects include Mercado, and successful software depends on physical delivery evidence, dispute handling, a buyer/cooperative, reliable off-ramp, and local rules. No software-only MVP solves these coordination dependencies.

**Gate:** Secure one buyer/cooperative and one compatible payout provider before design. Compare mobile money and bank transfer against Stellar for net cost, time, reliability, and user experience. Do not build a blockchain flow if ordinary rails win.

### 6. Recipient Payment History/Notifications — REJECT as a new repo

Wraith explicitly describes recipient-oriented Stellar token event indexing, and StellarLens/SoroTrail/TxWatch cover adjacent indexing or monitoring. A new generic indexer would have little apparent value. If interested, inspect these projects' issues and offer a focused contribution or a measured interoperability/reliability improvement.

## Revised recommendation

Reject a standalone vendor payout sender/dashboard: Stellar's official SDP already provides this. Continue discovery only for a narrowly scoped **ERP/AP-to-SDP reconciliation adapter**, and only if actual operators confirm a specific gap after their existing exports and accounting integrations. Keep any pilot read-only. Exclude incoming x402 receipts, payment execution, wallet/key custody, and generic indexing.

No greenfield direction earns a STRONG verdict yet. The account-specific audit did not make the outbound scope an exact duplicate, but it raised the bar for distinction. The next step is targeted customer discovery and an agreed product name, not public repo creation.

## Program and funding fit

- Drips repo acceptance is discretionary. The public list of approved repos is not evidence that a new repository would be accepted. On Oct. 28, 2026, the Stellar Wave page showed no active/upcoming Wave; the most recent displayed cycle had ended Oct. 22.
- The SCF Build Awards page displayed SCF #46 submission with a Nov. 8, 2026 deadline and up to $150,000 in XLM for eligible Build Award projects. This is a mutable program snapshot. A concept alone is unlikely to establish product validation or program eligibility; read the selected track's current criteria before applying.
- SDF's broad priorities include everyday financial services and trustworthy infrastructure, but alignment is not an award promise.
- Do not build primarily to qualify for Drips or a grant. A usable pilot and honest evidence are prerequisites for a credible application.

## Remaining assumptions / selection gate

1. At least one reachable business or payout provider runs recurring Stellar payments and owns the reconciliation problem.
2. They can share anonymized examples and test a read-only MVP.
3. Existing products cannot already resolve the same exceptions without a new tool.
4. Stellar integration produces an observable improvement over non-blockchain alternatives.
5. Founder/team capacity exists to support secure data imports and integrations.

**Next decision:** Continue discovery of the **SDP-to-ERPNext Bank Reconciliation Connector** hypothesis, including whether native CSV import already solves the task and whether upstream contribution is better. Similarity is acceptable if user evidence supports a meaningful improvement. Do not claim market demand until operators validate it. The product has no Soroban contract requirement; one Frappe app repository is sufficient. The working name is not final.
