# tcldocs::config -- Changelog

## 2026-05-13 -- 0.1 Initial

Extrahiert aus mdhelp4's `app/shared_config.tcl` als eigenstaendiges
Mini-Repo. Identische API, jetzt mit `package require` einbindbar
statt per `source`.

### Added

- **Modul** `lib/tm/tcldocs/config-0.1.tm` -- Public API:
  `path`, `loadShared`, `saveShared`, `getShared`, `setShared`.
- **`lib/tm/pkgIndex.tcl`** -- statisch gepflegt (1 Modul, kein
  generator noetig).
- **`tests/test-config.tcl`** -- 12 Tests, headless, ohne externe
  Dependencies. Nutzt `/tmp/tcldocs-config-test.<pid>/` als Sandbox.
- **`Makefile`** mit Standard-Targets (`install`, `install-user`,
  `uninstall`, `test`, `help`).
- **`README.md`** mit API-Beispielen, standardisierten Keys und
  Migrations-Hinweis fuer mdhelp4.

### Konsumenten

Geplant: `mdhelp4` (Migration aus `app/shared_config.tcl`),
`tcltk-glossary`, `man-viewer`. Apps koennen das Modul jetzt einbauen
ohne ihre eigene Settings-Persistenz pflegen zu muessen.

### Geteilte Convention

Standardisierte Keys (alle optional, mit sinnvollen App-internen Defaults):

| Key | Werte |
|---|---|
| `theme` | `light` / `dark` / `auto` |
| `fontSize` | 9..24 |
| `fontFamily` | font name |
| `lang` | `de` / `en` |
| `deeplApiKey`, `deeplUsePro` | DeepL-Helper Settings |
