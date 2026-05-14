#!/usr/bin/env tclsh
# tests/test-config.tcl -- Tests fuer tcldocs::config
#
# Self-skipping: keine externen Deps benoetigt. Nutzt /tmp als Sandbox.

set scriptDir [file dirname [file normalize [info script]]]
tcl::tm::path add [file join $scriptDir ../lib/tm]
package require tcldocs::config

# Sandbox-Pfad statt $HOME setzen
set sandbox [file join /tmp tcldocs-config-test.[pid]]
file mkdir $sandbox
set ::tcldocs::filePath [file join $sandbox .tcldocs.rc]
set ::tcldocs::cache {}
set ::tcldocs::cacheValid 0

set passed 0
set failed 0
proc check {name body expected} {
    global passed failed
    if {[catch {uplevel 1 $body} got]} {
        puts "  FAIL $name: $got"
        incr failed
        return
    }
    if {$got eq $expected} {
        puts "  OK   $name"
        incr passed
    } else {
        puts "  FAIL $name: got '$got', expected '$expected'"
        incr failed
    }
}

puts "tcldocs::config tests"
puts ""

# 1. Path-Helper liefert sinnvollen Pfad
check "path returns string" {
    tcldocs::path
} [file join $sandbox .tcldocs.rc]

# 2. loadShared auf nicht-existenter Datei -> leerer dict
check "loadShared on missing file" {
    tcldocs::loadShared
} {}

# 3. getShared mit Default
check "getShared with default" {
    tcldocs::getShared theme dark
} dark

# 4. setShared persistiert
check "setShared single value" {
    tcldocs::setShared theme light
} 1

# 5. getShared liest geschriebenen Wert
check "getShared after setShared" {
    tcldocs::getShared theme ""
} light

# 6. Mehrere Werte
tcldocs::setShared fontSize 12
tcldocs::setShared lang de
check "getShared fontSize" { tcldocs::getShared fontSize } 12
check "getShared lang"     { tcldocs::getShared lang }     de
check "getShared theme noch da" { tcldocs::getShared theme } light

# 7. Datei wirklich geschrieben
check "file exists" {
    file exists [tcldocs::path]
} 1

# 8. Datei wieder einlesen (Cache invalidieren)
set ::tcldocs::cacheValid 0
set ::tcldocs::cache {}
check "reload after invalidate" {
    set d [tcldocs::loadShared]
    dict get $d theme
} light

# 9. Werte mit Leerzeichen
tcldocs::setShared fontFamily "DejaVu Sans"
set ::tcldocs::cacheValid 0
set ::tcldocs::cache {}
check "value with whitespace" {
    tcldocs::getShared fontFamily
} "DejaVu Sans"

# 10. Kommentar-Zeilen werden gefiltert (manuell hinzufuegen)
set fh [open [tcldocs::path] r]
set content [read $fh]
close $fh
set fh [open [tcldocs::path] w]
puts $fh "# this is a comment"
puts $fh $content
puts $fh "# trailing comment"
close $fh
set ::tcldocs::cacheValid 0
set ::tcldocs::cache {}
check "comments ignored" {
    tcldocs::getShared theme
} light

# Cleanup
file delete -force $sandbox

puts ""
puts "Total: [expr {$passed + $failed}]  Passed: $passed  Failed: $failed"
if {$failed > 0} { exit 1 }
exit 0
