# tcldocs::config — Changelog

## 2026-05-14 — Makefile fix: pkgIndex.tcl is merged, not overwritten

### Fixed

- **`Makefile`** — `install` and `install-user` previously overwrote
  `~/lib/tcltk/pkgIndex.tcl`, dropping entries from other modules
  installed at the same prefix. Now: the `pkgIndex.tcl` entry for
  `tcldocs::config` is generated inline and appended only if not
  already present (idempotent). `uninstall` surgically removes only
  its own line via `sed`, preserving entries from other modules.

## 2026-05-13 — 0.1 initial release

Extracted from mdhelp's `app/shared_config.tcl` as a standalone
mini-repository. Identical API, now usable via `package require`
instead of `source`.

### Added

- **Module** `lib/tm/tcldocs/config-0.1.tm` — public API:
  `path`, `loadShared`, `saveShared`, `getShared`, `setShared`.
- **`lib/tm/pkgIndex.tcl`** — maintained statically (one module, no
  generator needed).
- **`tests/test-config.tcl`** — 12 tests, headless, no external
  dependencies. Uses `/tmp/tcldocs-config-test.<pid>/` as a sandbox.
- **`Makefile`** with standard targets (`install`, `install-user`,
  `uninstall`, `test`, `help`).
- **`README.md`** with API examples, standardized keys, and a
  migration note for mdhelp.

### Consumers

Planned: `mdhelp` (migration from `app/shared_config.tcl`),
`tcltk-glossary`, `man-viewer`. Apps can now embed the module
without maintaining their own settings-persistence code.

### Shared convention

Standardized keys (all optional, with sensible app-internal defaults):

| Key | Values |
|-----|--------|
| `theme` | `light` / `dark` / `auto` |
| `fontSize` | 9..24 |
| `fontFamily` | font name |
| `lang` | `de` / `en` |
| `deeplApiKey`, `deeplUsePro` | DeepL helper settings |
