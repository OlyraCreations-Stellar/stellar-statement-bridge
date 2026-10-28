# Stellar opportunity discovery

**Research date:** 2026-10-28. Ideas below are hypotheses informed by the approved-repository catalog and official network/program materials. No customer interviews or market sizing have been performed.

## 1. SDP-to-ERPNext Bank Reconciliation Connector (working direction)

- **Audience:** Finance and ERPNext implementers at organizations that use Stellar Disbursement Platform (SDP) for payouts.
- **Problem:** A team may have to transform SDP payment records into ERPNext statement lines before it can use ERPNext's native bank reconciliation. Whether this manual work occurs often enough to matter is not validated.
- **Alternatives:** SDP exposes paginated payment records and payment CSV export; ERPNext imports bank transactions through its native statement workflow and offers matching/reconciliation. Stellopay covers Soroban payroll; PaymentFlow covers school-fee reconciliation; Concord reconciles securities records. These projects show related capabilities in distinct domains; they are references for product quality and scope, not automatic blockers.
- **Difference:** A Frappe app that fetches SDP's completed Stellar payments, checks payment UUID, external reference, transaction ID, exact asset issuer, and account mapping, then creates deduplicated ERPNext Bank Transaction records. ERPNext users perform voucher matching in the native workflow. A generic dashboard or CSV converter would not be enough.
- **Why Stellar:** The imported source evidence is a Stellar payment and transaction ID from SDP. If users do not need that ledger-specific proof or already handle it with a CSV, the integration has little value.
- **Dependencies:** An SDP instance with read-only API key; ERPNext/Frappe install access; configured Company Bank Account/ledger and exact asset mapping; authorized sanitized sample data; verified Bank Transaction schema for supported ERPNext versions. No Horizon/RPC or Soroban contract is needed for the MVP.
- **Risks:** No validated buyer pain; ERPNext may be uncommon among SDP operators; SDP's CSV and ERPNext's native importer may already suffice; asset/account/precision mismatch; unauthorized API key scope; duplicate imports; accidental creation of accounting vouchers if boundaries are not enforced.
- **MVP:** User previews paginated SDP payment records and explicitly imports eligible `SUCCESS` Stellar payments into Bank Transactions. Sync records enforce exactly-once document creation across retries. Failed, pending, canceled, non-Stellar, unsupported asset, and unrepresentable-precision rows are excluded with reasons. The app creates no Payment Entry or Journal Entry and never initiates a payout.
- **Complexity:** Medium. API paging, Frappe data model, exact amount handling, security and idempotency matter more than blockchain code.
- **Program fit:** Stellar is materially relevant if actual customer flows use Stellar; a read-only OSS tool may fit the ecosystem. Wave approval is discretionary and no active/upcoming Wave was displayed on 2026-10-28. SDF grant fit remains unassessed beyond broad financial-service alignment.
- **Non-blockchain comparison:** A bank feed and CSV matching tool is simpler if the customer does not already settle payments on Stellar. Chain integration is justified only where transaction identity/finality and cross-border asset settlement improve operations.

## 2. SEP Anchor Conformance and Webhook Replay Kit

- **Audience:** Wallet, anchor, and payment-app developers integrating SEP-1/10/24/31 flows.
- **Problem:** Developers need to validate discovery/auth/transfer lifecycle handling and callback signatures, reproduce edge cases, and test retry/idempotency without repeatedly using live or fragile test services.
- **Alternatives:** Stellar SEP documentation, Anchor Platform event services, BasicPay sample app, test anchors, Stellar SDKs, custom mocks.
- **Difference:** Deterministic local fixtures/replay for signed callbacks and transaction lifecycle sequences, with clear conformance diagnostics.
- **Why Stellar:** SEP interoperability is Stellar-specific; stellar.toml discovery, SEP authentication, anchors, and Stellar transactions are core input formats.
- **Dependencies:** SEP specifications and reference fixtures, network-specific transaction parsing, representative anchor behavior, secure handling of test keys, compatibility maintenance as standards evolve.
- **Risks:** Existing docs/platform may be sufficient; mock behavior can diverge from real anchors; standards and implementation versions change; small reachable buyer/contributor pool; overlaps crowded developer tooling.
- **MVP:** CLI/library that validates a configured SEP-1 document and replays a curated SEP-24 status/webhook lifecycle with signature and duplicate-delivery cases.
- **Complexity:** Medium to high depending on protocol coverage.
- **Program fit:** Strong ecosystem relevance if maintainers adopt it, but approval and contributor demand are unknown.
- **Non-blockchain comparison:** Protocol-level testing does not need a blockchain node for most cases, though network transaction fixtures are Stellar-specific. The tool could be a conventional CLI.

## 3. Stellar Treasury Payment Control and Reconciliation

- **Audience:** Small organizations holding USDC/XLM treasury balances and making recurring vendor payments.
- **Problem:** Treasury operators need limits, approvals, scheduled batches, and reconciliation across multiple signers and vendors.
- **Alternatives:** Stellar native multisig, wallet interfaces, payment products, Agent Guard spending controls, payroll tools such as Stellopay, internal approval systems.
- **Difference:** A role-based operational console with policy simulation and reconciliation, potentially using existing native authorization rather than custom custody.
- **Why Stellar:** Network native multisig, sponsored reserves, and path payments can matter where a treasury already holds assets on Stellar.
- **Dependencies:** Wallet signer integration, auth model, data indexer, asset allowlist/issuer data, deployment/security review; smart-contract policy only if existing account controls are insufficient.
- **Risks:** High financial-security bar, user custody/signing risk, competition from wallets and Agent Guard, complex approval policies, enterprise adoption cycle.
- **MVP:** Read-only treasury visibility plus transaction proposal/approval flow through an existing wallet; no key custody or automated signing.
- **Complexity:** High for safe signing and authorization; medium for read-only reporting.
- **Program fit:** Relevant but very competitive and security-sensitive.
- **Non-blockchain comparison:** Existing ERP/treasury software is simpler unless the organization already holds and spends Stellar assets.

## 4. Soroban Contract Change and Operations Evidence Pack

- **Audience:** Soroban contract teams preparing releases and operating deployed contracts.
- **Problem:** Teams need reproducible evidence about contract version, simulation/resource behavior, event changes, and monitoring rules across releases.
- **Alternatives:** Soroban Cost Estimator, Hintents, StellarLens, TxWatch, SoroTrail, Soroban State Lens, security scanners, CI scripts.
- **Difference:** A release-focused workflow that links a contract artifact and source revision to resource simulation, ABI/event compatibility and post-deploy monitoring config.
- **Why Stellar:** Soroban WASM artifacts, RPC simulation, contract specs, and event data are Stellar-specific inputs.
- **Dependencies:** Soroban RPC, WASM build artifacts, contract spec decoding, existing indexers/monitors, CI support.
- **Risks:** Heavy overlap across tools; expansive scope; RPC/provider drift; false assurance if presented as audit/security certification.
- **MVP:** CI command that compares contract spec and simulated resource profile against a checked-in baseline and emits an evidence report; no “secure” verdict.
- **Complexity:** Medium/high.
- **Program fit:** Developer infrastructure is relevant but duplicate risk is high; must first collaborate with existing tools or find an explicit unserved workflow.
- **Non-blockchain comparison:** CI/report framework is conventional, while Soroban artifact/RPC analysis is platform-specific.

## 5. Agricultural Supplier Payout and Proof Workflow

- **Audience:** Agricultural cooperatives, produce buyers, and suppliers in one validated Stellar corridor.
- **Problem:** Small suppliers can face delayed payments and opaque fulfillment/payout status; buyers need evidence for milestones and settlement.
- **Alternatives:** Mercado supply-chain finance, crowdfunding/escrow apps, mobile money, bank transfers, paper/WhatsApp processes.
- **Difference:** Narrow workflow tying a verified delivery receipt to buyer-approved payout status, with simple ledger proof and clear off-chain dispute process.
- **Why Stellar:** Could help if stablecoin settlement reduces friction across a real corridor and both sides can access reliable on/off-ramps.
- **Dependencies:** Cooperative/buyer pilot, mobile-first UX, reliable oracle/evidence source or human confirmation, local anchor/mobile money partner, legal and tax review.
- **Risks:** Physical delivery disputes cannot be solved by a contract; high operational and regulatory burden; users may prefer mobile money; Mercado and other supply-chain products overlap.
- **MVP:** No custody or token issuance; a buyer/cooperative pilot dashboard records delivery status and links to manual Stellar payment evidence.
- **Complexity:** High overall due to field operations, even if software scope is small.
- **Program fit:** Potentially aligned to everyday financial services, but feasibility depends on a real partner.
- **Non-blockchain comparison:** A shared database plus mobile money likely wins unless both parties already benefit from shared, cross-border public settlement.

## 6. Stellar Recipient Payment History and Notifications

- **Audience:** Wallets and merchants needing recipient-oriented token payment history and alerts.
- **Problem:** Users want a reliable incoming payment feed across token assets/contracts and actionable notifications.
- **Alternatives:** Wraith explicitly describes recipient-focused SAC/SEP-41 transfer indexing; StellarLens, SoroTrail and TxWatch cover parts of event indexing/alerts; wallet providers show account history.
- **Difference:** Could focus on an embeddable API with stable deduplication/retention guarantees and merchant-specific matching semantics.
- **Why Stellar:** It directly indexes Stellar ledger events.
- **Dependencies:** Continuous ledger ingestion, data storage, checkpointing/replay, asset metadata, service reliability, rate limiting.
- **Risks:** Strong direct duplication; operator burden; substantial infrastructure; hard to differentiate without comparative reliability benchmarks.
- **MVP:** Only pursue as a contribution to an existing indexer unless a measured gap is established.
- **Complexity:** High for production reliability.
- **Program fit:** Relevant but duplication risk makes a new repo weak.
- **Non-blockchain comparison:** Standard webhook/accounting feed can solve the same need if payment rails are centralized; chain indexer is necessary only for direct Stellar account event data.

## Cross-idea assessment

| Idea | User problem signal | Differentiation | Stellar necessity | Feasibility | Main risk | Initial verdict |
|---|---|---|---|---|---|---|
| SDP-to-ERPNext Bank Reconciliation Connector | Plausible, unvalidated | Narrow, testable workflow improvement; still must beat native CSV import | Stellar payment ID, asset identity, and transaction evidence are source records | Medium | No validated ERPNext users or manual-import pain; native tools may suffice | **CONDITIONAL**; validate before claiming a gap |
| SEP Conformance/Replay Kit | Plausible developer pain | Moderate | High for SEP fixtures | Medium | Anchor Platform/docs may already solve enough | **CONDITIONAL** |
| Treasury Control/Reconciliation | Real category, specific need unknown | Low to moderate | Conditional | Low/medium | Custody/security and wallet competition | **WEAK** |
| Contract Release Evidence Pack | Developer pain likely, scope needs proof | Low | High for Soroban | Medium | Many direct tooling peers | **WEAK** |
| Agricultural Supplier Workflow | Important but corridor-specific | Moderate | Conditional on access/on-off ramps | Low | Partner, regulatory, and field execution | **CONDITIONAL** |
| Recipient History/Notifications | Clear technical use case | Low | High | High operational burden | Wraith/StellarLens/SoroTrail overlap | **REJECT as new product**; contribute to an existing project instead |
