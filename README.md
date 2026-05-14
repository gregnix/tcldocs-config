# tcldocs::config

App-übergreifende Settings für den Tcl/Tk Docu-Stack
(`mdhelp4`, `tcltk-glossary`, `man-viewer`, …).

**Version:** 0.1

## Was es ist

Ein einzelnes Tcl-Modul (`tcldocs::config 0.1`) das eine kleine
Persistenz-Schicht über `~/.tcldocs.rc` legt. Apps lesen und
schreiben gemeinsame Einstellungen (Theme, Schriftgröße, Sprache,
…) über vier Public-API-Funktionen.

Wert dieses Mini-Repos: vermeidet dass jede App eine eigene
Settings-Datei mit eigenem Format pflegt. Ein dark/light-Wechsel
in der Glossary-App soll beim nächsten Start von mdhelp4
übernommen werden.

## Public API

```tcl
package require tcldocs::config

tcldocs::path                       ;# Pfad zur Config-Datei (~/.tcldocs.rc)
tcldocs::loadShared                 ;# komplette Config als dict
tcldocs::saveShared $dict           ;# atomarer Write
tcldocs::getShared key ?default?    ;# Einzelwert lesen (mit Default-Fallback)
tcldocs::setShared key value        ;# Einzelwert schreiben (lade + merge + speichere)
```

Beispiel aus einer App:

```tcl
package require tcldocs::config

# Setting laden mit Fallback wenn noch nicht gesetzt
set theme [tcldocs::getShared theme "light"]
applyTheme $theme

# Bei User-Wechsel persistieren
proc onThemeChanged {newTheme} {
    tcldocs::setShared theme $newTheme
}
```

## Standardisierte Keys

Diese Keys sind Convention zwischen den Apps:

| Key | Werte | Bedeutung |
|---|---|---|
| `theme` | `light` / `dark` / `auto` | UI-Theme |
| `fontSize` | `9..24` | Schriftgröße in pt |
| `fontFamily` | `Helvetica`, `DejaVu Sans`, … | Font-Familie |
| `lang` | `de` / `en` | UI-Sprache |
| `deeplApiKey` | opaque string | DeepL-API-Key (mdhelp4) |
| `deeplUsePro` | `0` / `1` | DeepL Pro-Modus |

Apps dürfen eigene Keys hinzufügen. Konvention: app-spezifische Keys
mit App-Präfix, z.B. `mdhelpRecentFiles`, `glossaryLastQuery`.

## Format `~/.tcldocs.rc`

```tcl
# tcldocs shared config -- auto-generated
# Manuelles Editieren erlaubt; Format: shared { key value ... }

shared {
    theme       light
    fontSize    12
    fontFamily  {DejaVu Sans}
    lang        de
}
```

Atomares Schreiben: erst nach `~/.tcldocs.rc.tmp`, dann `rename`.
Crash beim Schreiben → alte Datei bleibt intakt.

## Installation

```bash
make install         # systemweit (sudo)
make install-user    # ~/lib/tcltk/tcldocs/
make uninstall
make test
```

## Migration aus mdhelp4

mdhelp4 hatte einen lokalen `app/shared_config.tcl` mit identischer
API. Migration für mdhelp4:

```tcl
# Statt:
source [file join $scriptDir shared_config.tcl]

# Jetzt:
package require tcldocs::config
```

API-Aufrufe (`::tcldocs::setShared`, `::tcldocs::getShared`, …) bleiben
unverändert. Anschließend kann `app/shared_config.tcl` aus dem
mdhelp4-Repo entfernt werden.

## Tests

```bash
tclsh tests/test-config.tcl
```

12 Tests, keine externen Dependencies, läuft headless. Nutzt
`/tmp/tcldocs-config-test.<pid>/` als Sandbox.

## Lizenz

Identisch mit den anderen Repos im Tcl/Tk Docu-Stack.
