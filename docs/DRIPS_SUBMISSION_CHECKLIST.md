# Drips Wave readiness and issue policy

**Checked:** 2026-10-30
**Repository:** `OlyraCreations-Stellar/stellar-statement-bridge`

## Current verified state

- The public Stellar Wave page currently lists no active or upcoming cycle. Its latest listed cycle is Wave 10, Oct. 15–22, 2026. Recheck before applying because cycle information changes.
- The GitHub organization and public repository exist. GitHub API returned zero installations for `OlyraCreations-Stellar`; therefore, the Drips Wave GitHub App is not currently installed according to that endpoint.
- The repository has 20 open project issues. Issues #2 and #3 are being refined against Drips' published meaningful-issue guidance. They have project workflow labels only. No `Stellar Wave` program label has been applied and no issue has been added to a Drips Program.
- Branch `feat/initial-app-scaffold` is pushed. At the time checked, `main` was at `4c75249`; the feature branch was at `c304e49`; there were no open pull requests. The latest project work is not yet on the default branch.
- Repository application status cannot be read from the public Wave page or GitHub API. It must be checked in Drips Wave's maintainer dashboard.

## Verified maintainer workflow

Drips' current maintainer guide says to sign in to the Drips Wave app, onboard the GitHub organization, install the Drips Wave GitHub App, sync/select public repositories, apply each repository to the relevant Program, and wait for organizer approval. After repository approval, maintainers select which issues to add and set each issue's complexity in the app.

Applying the Program label (for example, `Stellar Wave`) on GitHub is an alternate add-to-Program workflow and only works once the repository is approved. Issues added by this label route default to Trivial complexity (100 points); the app permits explicit complexity selection. Therefore, this project will not use the program label before repository approval and explicit issue selection.

## Issue quality standard

For each issue intended for a future Wave:

1. Explain the user/product impact and why the work matters.
2. Give enough project and technical context for an unfamiliar contributor.
3. Keep the deliverable completable within one Wave; split work with independent acceptance criteria.
4. Point to relevant modules, constraints, edge cases, and validation without prescribing every implementation detail.
5. State review evidence and completion criteria.
6. Price complexity honestly in the Drips app after repo approval: Trivial (100), Medium (150), High (200). The repository's `complexity:*` labels are internal workflow metadata, not Drips Program tags or confirmed point assignments.

Do not create issues to inflate a count. The existing 20-issue backlog is reviewed for overlap before adding work. Issues #2 and #3 were refined rather than duplicated.

## Remaining submission checks

- In Drips dashboard: verify current organization onboarding, app installation, repository application status, and any current per-cycle application limits.
- Recheck current Wave timing and program eligibility immediately before applying.
- Move reviewed work onto the default branch through the normal repository workflow before asking organizers to assess it.
- Continue product gates documented in `PLAN.md`: validate the operator problem; verify site-level installation and ERPNext compatibility; build and test the real MVP; prepare accurate docs and a working demonstration before claiming those artifacts exist.
- Confirm that each issue offered to contributors is unblocked, independently actionable, appropriately scoped, and has a maintainer available to review during the cycle.
- Do not apply `Stellar Wave` or another Drips Program label until the repo is approved and the specific issues are intentionally selected.

## Sources

- [Creating Meaningful Issues](https://www.drips.network/blog/posts/creating-meaningful-issues)
- [Stellar Wave status](https://www.drips.network/wave/stellar)
- [Participating in a Wave](https://docs.drips.network/wave/maintainers/participating-in-a-wave/)
- [Maintainer FAQ](https://docs.drips.network/wave/maintainers/faq/)
- [Repo application limits](https://docs.drips.network/wave/maintainers/repo-application-limits/)
