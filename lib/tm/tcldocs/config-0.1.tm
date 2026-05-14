# tcldocs::config-0.1.tm
# ============================================================
# Cross-App-Settings fuer den Tcl/Tk Docu-Stack
#
# Speicherort:  ~/.tcldocs.rc
# Format:       Tcl-Liste { shared { key1 value1  key2 value2 ... } }
#
# Wird von mehreren Apps (mdhelp4, tcltk-glossary, man-viewer, ...)
# gelesen/geschrieben. Persistierte App-uebergreifende Werte:
#
#   theme         hell | dunkel | auto       UI-Theme
#   fontSize      9 .. 24                    Schriftgroesse in pt
#   fontFamily    "Helvetica"                Font-Familie
#   lang          de | en                    UI-Sprache
#   deeplApiKey   <opaque-string>            DeepL API-Key (vom mdhelp4-Helper)
#   deeplUsePro   0 | 1                      DeepL Pro-Modus
#
# Apps koennen eigene Keys hinzufuegen. Konvention: zur Vermeidung
# von Kollisionen sollte ein App-spezifischer Key mit dem App-
# Praefix beginnen (z.B. mdhelpRecent, glossaryLastQuery).
#
# Public API (alle returnen vernuenftige Defaults wenn ~/.tcldocs.rc
# noch nicht existiert oder unlesbar ist):
#
#   tcldocs::path                    -> string  (Dateipfad)
#   tcldocs::loadShared              -> dict    (komplette gemeinsame Config)
#   tcldocs::saveShared dictData     -> 1       (atomarer Write via tmp+rename)
#   tcldocs::getShared key ?default? -> value
#   tcldocs::setShared key value     -> 1       (lade-merge-speichere)
#
# Atomare Writes: erst nach ${filePath}.tmp, dann rename. So bleibt
# bei einem Crash mitten beim Schreiben die alte Datei intakt.
#
# Multi-App-Safety: keine, das ist best-effort. Wenn zwei Apps
# gleichzeitig schreiben, kann der letzte gewinnen. In der Praxis
# kein Problem (Schreiben passiert beim Save-Knopf, selten parallel).

package provide tcldocs::config 0.1

namespace eval ::tcldocs {
    namespace export path loadShared saveShared getShared setShared

    variable filePath
    if {[info exists ::env(HOME)]} {
        set filePath [file join $::env(HOME) .tcldocs.rc]
    } else {
        set filePath ".tcldocs.rc"
    }

    # In-Memory-Cache der gerade geladenen shared-Werte
    variable cache {}
    variable cacheValid 0
}

proc ::tcldocs::path {} {
    variable filePath
    return $filePath
}

proc ::tcldocs::loadShared {} {
    variable filePath
    variable cache
    variable cacheValid

    set cache {}
    if {![file exists $filePath]} {
        set cacheValid 1
        return $cache
    }

    if {[catch {
        set fh [open $filePath r]
        fconfigure $fh -encoding utf-8
        set content [read $fh]
        close $fh
    } err]} {
        catch {close $fh}
        return $cache
    }

    # Kommentar-Zeilen rausfiltern (Tcl behandelt # in Listen NICHT als
    # Kommentar -- das tut nur der Parser auf Befehlsebene)
    set cleaned {}
    foreach line [split $content "\n"] {
        set trimmed [string trimleft $line]
        if {[string index $trimmed 0] eq "#"} continue
        append cleaned "$line\n"
    }
    set content $cleaned

    # Format: shared { key value  key value ... }
    foreach {section data} $content {
        if {$section ne "shared"} continue
        foreach {k v} $data {
            dict set cache $k $v
        }
        break
    }
    set cacheValid 1
    return $cache
}

proc ::tcldocs::saveShared {dictData} {
    variable filePath
    variable cache
    variable cacheValid

    set cache $dictData
    set cacheValid 1

    # Atomar schreiben: erst tmp, dann rename
    set tmpPath "${filePath}.tmp"
    if {[catch {
        set fh [open $tmpPath w]
        fconfigure $fh -encoding utf-8
        puts $fh "# tcldocs shared config -- auto-generated"
        puts $fh "# App-uebergreifende Settings fuer mdhelp4, tcltk-glossary, man-viewer, ..."
        puts $fh "# Manuelles Editieren erlaubt; Format: shared { key value ... }"
        puts $fh ""
        puts $fh "shared \{"
        dict for {k v} $dictData {
            # Wert quoten falls noetig
            set qv [list $v]
            puts $fh "    $k $qv"
        }
        puts $fh "\}"
        close $fh
        file rename -force $tmpPath $filePath
    } err]} {
        catch {close $fh}
        catch {file delete -force $tmpPath}
        return -code error "tcldocs::saveShared failed: $err"
    }
    return 1
}

proc ::tcldocs::getShared {key {default ""}} {
    variable cache
    variable cacheValid
    if {!$cacheValid} { ::tcldocs::loadShared }
    if {[dict exists $cache $key]} {
        return [dict get $cache $key]
    }
    return $default
}

proc ::tcldocs::setShared {key value} {
    variable cache
    variable cacheValid
    if {!$cacheValid} { ::tcldocs::loadShared }
    dict set cache $key $value
    return [::tcldocs::saveShared $cache]
}
