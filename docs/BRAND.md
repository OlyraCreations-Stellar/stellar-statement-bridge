# Brand identity

**Working name:** Stellar Statement Bridge
**Status:** Provisional identity for an early prototype. The name and product direction may change after operator discovery.

## Idea

The mark depicts an interrupted ledger row joined by a raised bridge and a single transaction point. It describes the intended job: carry payment evidence into an accounting system's review workflow. It does not depict a coin, wallet, chain, or official Stellar symbol.

The bridge is the identifying shape. Keep the rest of the system quiet so it remains legible in a repository header, a small icon, and a monochrome printout.

## Assets

- [`brand/mark.svg`](../brand/mark.svg): compact mark for avatars and small placements.
- [`brand/wordmark.svg`](../brand/wordmark.svg): horizontal name lockup for the README and project materials.
- [`brand/social-card.svg`](../brand/social-card.svg): vector social-card source. GitHub's repository social-preview uploader may require a raster export; this SVG is not claimed to be installed as the GitHub preview image.
- [`brand/social-card.png`](../brand/social-card.png): 1200×630 raster preview candidate rendered from the SVG source for GitHub's social-preview settings.

All assets are original project artwork licensed with this repository under Apache-2.0.

## Color tokens

| Name | Hex | Use |
| --- | --- | --- |
| Ledger Ink | `#18262E` | Primary text and dark surfaces |
| Warm Paper | `#F3EFE4` | Light background |
| Bridge Teal | `#1F7068` | Primary mark and links |
| Copper Point | `#B7783E` | The single transaction accent |
| Rule Stone | `#D9D3C5` | Ledger rules and separators |
| Slate Copy | `#34454A` | Secondary text |

The mark has no gradient. Keep Copper Point to a small transaction detail rather than using it for large text. Check foreground/background contrast in the actual interface before using these tokens for small text or controls.

## Typography

- Display and headings: Space Grotesk, with a system sans-serif fallback.
- Body copy: IBM Plex Sans, with Arial or a system sans-serif fallback.
- Transaction IDs, dates, and technical labels: IBM Plex Mono, with Consolas or a system monospace fallback.

Repository Markdown cannot guarantee that web fonts are installed. SVG assets include fallback font stacks and the identity must remain readable without downloaded fonts.

## Voice

- Describe records, reconciliation, and review directly.
- Say “working prototype” or “proposed integration” until actual operator validation and ERPNext site-level checks exist.
- Do not claim faster settlement, lower costs, automatic accounting, production readiness, or Drips approval.
- Say “Stellar” as ecosystem context. Do not imply endorsement or official affiliation with Stellar Development Foundation, Drips, ERPNext, or Frappe.

## Usage

- Use the horizontal wordmark on light backgrounds; use the mark alone at small sizes.
- Preserve the logo proportions and clear space of at least half the mark's height.
- Do not redraw the bridge as a star, add a coin or chain, add a glow/gradient, or place the teal mark on a low-contrast background.
- Keep the project status visible wherever the product is presented publicly.
