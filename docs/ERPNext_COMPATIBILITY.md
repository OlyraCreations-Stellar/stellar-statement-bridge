# ERPNext compatibility check

Research and sandbox check performed on 2026-11-01.

## Result

The product app installs on a disposable local ERPNext site using the checked-out Frappe v16 and ERPNext v16 code. A synthetic Bank Transaction passed the Pending-to-Unreconciled-to-Cancelled lifecycle. No Payment Entry or Journal Entry was created. This validates basic site installation and statement-side document lifecycle on this version pair. It does not validate the product's SDP import path: the app currently contains normalization scaffolding, not a Bank Transaction importer.

## Exact environment

| Component | Observed version or revision |
| --- | --- |
| Frappe | 16.54.0, `2fcb9397a1f1da353b21e53d2f97ec56653acd02` |
| ERPNext | 16.53.0, `9cd11b19575bfc34f092a24f6c8b368c4dd69481` |
| Olyra app | Bench checkout revision `8216126` |
| Bench | 5.31.1 |
| Python | 3.14.4 |
| MariaDB | 11.8.6 |
| Redis | 8.0.5 in the bench environment; isolated Redis processes were used for this site install |

The site `validation2.localhost` was created under the WSL bench at `/home/edvance/frappe-bench/sites` and connected to a separate MariaDB data directory at `/home/edvance/.local/share/wave10-erpnext-validation-20261101`. That database used a private Unix socket and `skip-networking`; the host MariaDB service and its authentication settings were not changed. Generated local credentials were not recorded here. The site contains no real payment or recipient data.

The install command was run from the bench directory:

```sh
bench new-site validation2.localhost --db-type mariadb \
  --db-root-username root --db-root-password '<generated local password>' \
  --db-socket /home/edvance/.local/share/wave10-erpnext-validation-20261101/run.sock \
  --admin-password '<generated local password>' --install-app erpnext
bench --site validation2.localhost install-app stellar_statement_bridge
bench --site validation2.localhost list-apps
```

The initial site creation reached Frappe and ERPNext DocType setup, then reported Redis Queue unavailable at `127.0.0.1:11000` during cleanup. The app list subsequently confirmed both `erpnext 16.53.0` and `stellar_statement_bridge` installed. After starting isolated Redis queue/cache processes on the configured local ports, the product app install command exited 0. This initial cleanup warning is retained as environment evidence; the successful app list and app installation are the final state checks.

## Bank Transaction behavior verified

At the pinned ERPNext revision, `erpnext/accounts/doctype/bank_transaction/bank_transaction.json` marks `naming_series` as its only required field and defaults it to `ACC-BTN-.YYYY.-`. The document has optional `date`, `bank_account`, `company`, `currency`, `description`, `reference_number`, `transaction_id`, `deposit`, and `withdrawal` fields, among others. The DocType JSON does not declare a fixed precision on its Currency fields; Frappe resolves precision using site/field currency settings. The synthetic check used USD 12.34 and confirmed that amount was retained as the unallocated amount on this site. This is one observed precision case, not a test of alternate currency settings or rounding boundaries.

The same DocType JSON grants create/read/write/submit to Accounts User, Accounts Manager, and System Manager. Cancel is granted to Accounts Manager and System Manager. The smoke command ran as the site Administrator, so role-level enforcement was inspected in metadata, not separately exercised under each role.

Synthetic check performed through the installed site:

1. Insert Bank Transaction with date `2026-01-15`, deposit `12.34`, currency `USD`, and a synthetic description. Observed `docstatus=0`, `status=Pending`, `unallocated_amount=12.34`.
2. Submit it. Observed `docstatus=1`, `status=Unreconciled`, `unallocated_amount=12.34`.
3. Cancel it. Observed `docstatus=2`, `status=Cancelled`.
4. Payment Entry count remained `0 to 0`; Journal Entry count remained `0 to 0`.

This smoke check intentionally did not create or link a Bank Account, Payment Entry, or Journal Entry. It tests ERPNext's statement-side document lifecycle only. Production import still needs to map the transaction to the intended Bank Account and validate that account's company and currency.

## Native statement import route

The pinned ERPNext source provides a Bank Statement Import path:

1. Configure the column mapping on the Bank record (`bank_transaction_mapping`).
2. Upload a supported statement/template or provide a Google Sheets URL through Bank Statement Import.
3. The import validates that the mapped columns include `Bank Account`.
4. The importer constructs a Frappe Data Import for `Bank Transaction` with import type `Insert New Records`; it can submit imported records when `submit_after_import` is enabled.
5. The MT940 parser emits Date, Deposit, Withdrawal, Description, Reference Number, Bank Account, and Currency columns.

Source references at the exact ERPNext revision used:

- [Bank Transaction DocType fields and permissions](https://github.com/frappe/erpnext/blob/9cd11b19575bfc34f092a24f6c8b368c4dd69481/erpnext/accounts/doctype/bank_transaction/bank_transaction.json)
- [Bank Transaction lifecycle and validation](https://github.com/frappe/erpnext/blob/9cd11b19575bfc34f092a24f6c8b368c4dd69481/erpnext/accounts/doctype/bank_transaction/bank_transaction.py)
- [Bank Statement Import implementation](https://github.com/frappe/erpnext/blob/9cd11b19575bfc34f092a24f6c8b368c4dd69481/erpnext/accounts/doctype/bank_statement_import/bank_statement_import.py)
- [ERPNext Bank Transaction user guide](https://docs.frappe.io/erpnext/bank-transaction)
- [ERPNext Bank Reconciliation user guide](https://docs.frappe.io/erpnext/bank-reconciliation)

The source path was inspected; a native CSV or MT940 import was not run on the disposable site. Issue #3 remains open to compare that native route with an SDP-shaped workflow and establish whether a real gap exists. There is no evidence yet that an Olyra connector improves on the native import.

## Verification boundary and next step

Verified: app installation on a disposable site, app presence, the synthetic single-document lifecycle, status values, the observed USD amount, and unchanged Payment Entry/Journal Entry counts.

Not verified: native statement import execution, Bank Account mapping, import duplicate/rejection behavior, alternate currencies or precision settings, role-based permissions in a live session, actual SDP exports, recurring user pain, or end-to-end connector functionality.

Next: run the same synthetic SDP-shaped CSV through ERPNext's native importer and document the result before implementing an ERPNext write path. Keep customer discovery open; this technical check does not validate demand.
