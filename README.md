# tcldocs::config

Cross-application settings for the Tcl/Tk Docu-Stack
(`mdhelp`, `tcltk-glossary`, `man-viewer`, …).

**Version:** 0.1

## What it is

A single Tcl module (`tcldocs::config 0.1`) providing a small
persistence layer over `~/.tcldocs.rc`. Apps read and write shared
settings (theme, font size, language, …) through four public API
functions.

Purpose: avoid each app maintaining its own settings file with its
own format. A dark/light switch made in the glossary app applies
to the next mdhelp launch automatically.

## Public API

```tcl
package require tcldocs::config

tcldocs::path                       ;# path to config file (~/.tcldocs.rc)
tcldocs::loadShared                 ;# return full config as a dict
tcldocs::saveShared $dict           ;# atomic write
tcldocs::getShared key ?default?    ;# read one value (with default fallback)
tcldocs::setShared key value        ;# write one value (load + merge + save)
```

Example use in an app:

```tcl
package require tcldocs::config

# Load setting with a fallback if not yet set
set theme [tcldocs::getShared theme "light"]
applyTheme $theme

# Persist on user change
proc onThemeChanged {newTheme} {
    tcldocs::setShared theme $newTheme
}
```

## Standardized Keys

These keys form a convention shared between apps:

| Key | Values | Meaning |
|-----|--------|---------|
| `theme` | `light` / `dark` / `auto` | UI theme |
| `fontSize` | `9..24` | Font size in pt |
| `fontFamily` | `Helvetica`, `DejaVu Sans`, … | Font family |
| `lang` | `de` / `en` | UI language |
| `deeplApiKey` | opaque string | DeepL API key (mdhelp) |
| `deeplUsePro` | `0` / `1` | DeepL Pro mode |

Apps may add their own keys. Convention: app-specific keys carry an
app prefix, e.g. `mdhelpRecentFiles`, `glossaryLastQuery`.

## Format of `~/.tcldocs.rc`

```tcl
# tcldocs shared config -- auto-generated
# Manual editing is allowed; format: shared { key value ... }

shared {
    theme       light
    fontSize    12
    fontFamily  {DejaVu Sans}
    lang        en
}
```

Atomic write: writes to `~/.tcldocs.rc.tmp` first, then renames. A
crash during writing leaves the previous file intact.

## Installation

```bash
make install         # system-wide (sudo)
make install-user    # ~/lib/tcltk/tcldocs/
make uninstall
make test
```

## Migration from mdhelp

mdhelp previously carried a local `app/shared_config.tcl` with an
identical API. Migration:

```tcl
# Before:
source [file join $scriptDir shared_config.tcl]

# After:
package require tcldocs::config
```

API calls (`::tcldocs::setShared`, `::tcldocs::getShared`, …) stay
unchanged. The local `app/shared_config.tcl` can be removed
afterwards.

## Tests

```bash
tclsh tests/test-config.tcl
```

12 tests, no external dependencies, runs headless. Uses
`/tmp/tcldocs-config-test.<pid>/` as a sandbox.

## License

Same as the other repositories in the Tcl/Tk Docu-Stack — MIT for
code. See the `LICENSE` file in this repository.
