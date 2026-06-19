## Summary

<!-- One or two sentences. What changed and why. -->

## Scope

- [ ] Touches family directory / map / detail / category screens
- [ ] Touches auth / login / register
- [ ] Touches provider (tutor / masterclass) surface
- [ ] Touches mock repositories or API contracts
- [ ] Touches l10n (ARB files)
- [ ] Other:

## Mock-first contract check

<!-- Per CLAUDE.md: repos must mirror the planned backend so the HTTP swap is a one-file change. -->

- [ ] No real network calls added (OSM tiles + placeholder images excepted)
- [ ] Repository method names / params / return shapes match the planned backend
- [ ] No `onPressed: () {}` placeholders left in interactive paths
- [ ] All three ARB files (`en`, `ru`, `kk`) kept in sync — or N/A

## Verification

- [ ] `fvm flutter analyze` → 0 errors
- [ ] `fvm dart format .` → no diff
- [ ] `fvm flutter run` boots without crashing on the touched flows
- [ ] Tested the golden path + at least one edge case

## Screenshots / clips

<!-- For any UI change. -->

## Notes for reviewer

<!-- Anything tricky, follow-ups, or known gaps. -->
