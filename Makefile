# tcldocs::config Makefile
#
# Targets:
#   install       -- systemweit (sudo) nach $(PREFIX_SYS)
#   install-user  -- nutzer-lokal nach $(PREFIX_USER)
#   uninstall     -- alle installierten Files entfernen
#   pkgindex      -- pkgIndex.tcl neu generieren (no-op hier, manuell)
#   test          -- Test-Suite laufen lassen
#   help          -- Hilfe

PREFIX_USER ?= $(HOME)/lib/tcltk
PREFIX_SYS  ?= /usr/local/lib/tcltk

# Modul-Verzeichnis im Ziel: $(PREFIX)/tcldocs/
MOD_DIR     = tcldocs

.PHONY: help install install-user uninstall pkgindex test

help:
	@echo "tcldocs::config -- shared config library for the Tcl/Tk Docu-Stack"
	@echo ""
	@echo "Targets:"
	@echo "  make install         -- systemweit (sudo) nach $(PREFIX_SYS)/$(MOD_DIR)/"
	@echo "  make install-user    -- nutzer-lokal nach $(PREFIX_USER)/$(MOD_DIR)/"
	@echo "  make uninstall       -- entfernt installierte Files"
	@echo "  make test            -- laufende Tests"
	@echo ""
	@echo "Overrides:"
	@echo "  PREFIX_USER=$(PREFIX_USER)"
	@echo "  PREFIX_SYS=$(PREFIX_SYS)"

install:
	@echo "Installing tcldocs::config -> $(PREFIX_SYS)/$(MOD_DIR)/"
	@install -d $(PREFIX_SYS)/$(MOD_DIR)
	@install -m 0644 lib/tm/tcldocs/config-0.1.tm $(PREFIX_SYS)/$(MOD_DIR)/
	@install -m 0644 lib/tm/pkgIndex.tcl $(PREFIX_SYS)/$(MOD_DIR)/../pkgIndex.tcl 2>/dev/null || \
	    install -m 0644 lib/tm/pkgIndex.tcl $(PREFIX_SYS)/pkgIndex.tcl
	@echo "Done. Test with: tclsh -c 'package require tcldocs::config; puts ok'"

install-user:
	@echo "Installing tcldocs::config -> $(PREFIX_USER)/$(MOD_DIR)/"
	@install -d $(PREFIX_USER)/$(MOD_DIR)
	@install -m 0644 lib/tm/tcldocs/config-0.1.tm $(PREFIX_USER)/$(MOD_DIR)/
	@install -m 0644 lib/tm/pkgIndex.tcl $(PREFIX_USER)/pkgIndex.tcl
	@echo "Done."
	@echo ""
	@echo "Add to your ~/.tclshrc or ~/.wishrc if not already there:"
	@echo "  lappend ::tcl::tm::path $(PREFIX_USER)"

uninstall:
	@echo "Uninstalling tcldocs::config"
	@rm -f $(PREFIX_SYS)/$(MOD_DIR)/config-0.1.tm 2>/dev/null || true
	@rm -f $(PREFIX_USER)/$(MOD_DIR)/config-0.1.tm 2>/dev/null || true
	@rmdir $(PREFIX_SYS)/$(MOD_DIR) 2>/dev/null || true
	@rmdir $(PREFIX_USER)/$(MOD_DIR) 2>/dev/null || true
	@echo "Done."

pkgindex:
	@echo "pkgIndex.tcl ist statisch gepflegt (siehe lib/tm/pkgIndex.tcl)"

test:
	@tclsh tests/test-config.tcl
