# Sabil Life — Mobile
#
# Thin wrappers over `fvm flutter` so nobody has to remember the
# --dart-define-from-file flag. The API base URL is compiled in from the
# matching config/<env>.json (see config/local.example.json).
#
# Requires fvm (https://fvm.app). Install: `dart pub global activate fvm`.
#
# Usage:
#   make run           # run against your machine's backend (config/local.json)
#   make run-dev       # run against the shared dev backend
#   make build-staging # build a TestFlight/staging IPA
#   make build-prod    # build a release IPA for the App Store

FLUTTER := fvm flutter
DEFINE  := --dart-define-from-file=config

.PHONY: run run-dev run-staging build-staging build-prod \
        apk-dev appbundle-prod analyze format check

# --- run (debug) ---------------------------------------------------------
run: config/local.json
	$(FLUTTER) run $(DEFINE)/local.json

# Bootstrap the per-developer config on first run.
config/local.json:
	@echo "config/local.json not found — creating it from local.example.json."
	@echo "Edit it to point at YOUR machine's backend, then re-run 'make run'."
	@cp config/local.example.json config/local.json
	@false

run-dev:      ; $(FLUTTER) run $(DEFINE)/dev.json
run-staging:  ; $(FLUTTER) run $(DEFINE)/staging.json

# --- build ---------------------------------------------------------------
build-staging:   ; $(FLUTTER) build ipa $(DEFINE)/staging.json
build-prod:      ; $(FLUTTER) build ipa $(DEFINE)/prod.json
apk-dev:         ; $(FLUTTER) build apk $(DEFINE)/dev.json
appbundle-prod:  ; $(FLUTTER) build appbundle $(DEFINE)/prod.json

# --- housekeeping (per CLAUDE.md: 0 analyze errors + format) -------------
analyze: ; $(FLUTTER) analyze
format:  ; fvm dart format .
check: analyze format
