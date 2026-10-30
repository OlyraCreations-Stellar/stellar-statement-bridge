# Stellar Statement Bridge

**Project status: early prototype.** The repository contains a Frappe app scaffold and a pure SDP payment normalizer. No network integration, ERPNext writes, pilot, or deployment exists. This is a working product name. The public repository is hosted by the `OlyraCreations-Stellar` GitHub organization.

Stellar Statement Bridge is a proposed Frappe app that would import completed Stellar Disbursement Platform (SDP) payment evidence into ERPNext Bank Transactions. Finance users could then use ERPNext's native reconciliation workflow to match statement records to existing accounting vouchers.

The app is deliberately scoped to statement evidence. It is not a payout sender, wallet, accounting engine, or payment processor. It would not create or submit Payment Entries or Journal Entries, hold keys, or send funds.

## Why this is only a proposal

Public documentation confirms that SDP exposes paginated payment records and ERPNext supports Bank Transactions and bank reconciliation. It does not establish that SDP operators use ERPNext or that their current CSV workflow is painful. Customer discovery is still required. See [the evaluation](docs/IDEA_EVALUATION.md), [competitive analysis](docs/COMPETITIVE_ANALYSIS.md), and [customer discovery plan](docs/CUSTOMER_DISCOVERY.md).

## Repository map

- [`docs/ECOSYSTEM_RESEARCH.md`](docs/ECOSYSTEM_RESEARCH.md): Drips/Stellar research and source links.
- [`docs/COMPETITIVE_ANALYSIS.md`](docs/COMPETITIVE_ANALYSIS.md): overlap classifications and alternatives.
- [`docs/OPPORTUNITY_DISCOVERY.md`](docs/OPPORTUNITY_DISCOVERY.md): candidate directions.
- [`docs/IDEA_EVALUATION.md`](docs/IDEA_EVALUATION.md): skeptical review and conditional recommendation.
- [`docs/PRD.md`](docs/PRD.md): proposed requirements and validation gate.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): proposed data flow and security boundaries.
- [`docs/CUSTOMER_DISCOVERY.md`](docs/CUSTOMER_DISCOVERY.md): interview and pilot protocol; no interviews have occurred.
- [`docs/ISSUE_BACKLOG_DRAFT.md`](docs/ISSUE_BACKLOG_DRAFT.md): scope and acceptance criteria for 20 published GitHub issues.
- [`docs/PLAN.md`](docs/PLAN.md): milestone and session state.
- [Contributor roadmap issues](https://github.com/OlyraCreations-Stellar/stellar-statement-bridge/issues): 20 issues are published. Issues 1–3 cover discovery; issue 4 (scaffold) and issue 9 (normalization) cover the authorized prototype slice; remaining integration work is blocked pending customer and compatibility validation.

## Current verification

- Verified in official documentation: SDP's payment API includes payment status, identifiers, Stellar transaction ID, amount, and asset identity; ERPNext uses Bank Transactions as statement evidence and has a native reconciliation workflow.
- Not verified: user demand, ERPNext adoption among SDP operators, current native connector availability, supported app versions, sandbox behavior, Wave acceptance, or production readiness.
- Eight synthetic normalizer tests pass under Python 3.14.4 in WSL; package metadata and Python compilation checks also pass.
- The product app is installed in a local Frappe 16.54.0 / ERPNext 16.53.0 bench. Frappe, ERPNext (including Banking assets), and `stellar_statement_bridge` asset builds pass. No site exists, so the product app has not been installed on a site and end-to-end behavior remains unverified. ERPNext's native Bank Statement Import supports bank-mapped CSV and MT940 paths; the specific suitability of SDP exports remains unverified. Asset builds emitted Redis cache warnings because the separate bench `redis_cache` process was not running; the builds still exited successfully.

## License

This repository is licensed under the Apache License 2.0. The license does not imply Drips Wave approval.

## Intended first product boundary

1. Read SDP payment records using a least-privilege read-only API key.
2. Preview eligible and blocked rows with reasons.
3. After an operator confirms, create deduplicated ERPNext Bank Transactions only for successful Stellar payments with a valid asset/account mapping.
4. Leave voucher creation and reconciliation to ERPNext's own controls.

See [PRD](docs/PRD.md) and [Architecture](docs/ARCHITECTURE.md) for the full proposed criteria. Do not use this prototype to connect production accounts or financial data.

## Local pure-Python checks

With Python 3.14 available, run the isolated normalizer tests from the repository root:

```sh
python -m unittest discover -s stellar_statement_bridge/stellar_statement_bridge/tests -v
```

The first slice makes no network calls and does not import Frappe at test time.
