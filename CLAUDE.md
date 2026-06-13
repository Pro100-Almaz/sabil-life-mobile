# Sabil Life — Mobile (Flutter, mock-data frontend)

Build guide: `SABIL_LIFE_IMPLEMENTATION.md` (repo root). This repo uses **fvm** — always run Flutter/Dart via `fvm flutter ...` / `fvm dart ...`.

## Agent Operating Rules

1. **Mock data only.** Never add `http`, `dio`, Firebase, or any network/data-fetching package except map tiles. All data lives in `lib/data/mock/`.
2. **Build only interactable components.** Do not produce static placeholder screens. If you render a card, its tap, its heart/save, and any control on it must do something against mock state.
3. **Design fidelity to Airbnb.** Use the tokens in Section 4 of the build guide exactly. Coral `#FF385C` is the only accent. White surfaces, `#222222` text, generous rounding, large photos. No gradients, no heavy shadows (one soft shadow token only).
4. **Localize every user-facing string** through the ARB files (`lib/core/l10n/`). Never hardcode a UI string in a widget. Mock *content* (school names, etc.) may stay as-is — only UI chrome is translated. Keep all three ARB files (`en`, `ru`, `kk`) in sync.
5. **One phase per turn.** Complete a phase fully, run the phase's verification commands, fix all `flutter analyze` issues, then stop and report. Do not jump ahead.
6. **After every phase run:** `fvm flutter analyze` (must be 0 errors) and `fvm dart format .`. The app must `fvm flutter run` without crashing at the end of each phase that touches UI.
7. **No TODOs left in interactive paths.** A button with `onPressed: () {}` is a failure. Wire it to real mock behaviour or remove it.
8. **Keep widgets small.** One widget per file for anything reused. Screens compose from `features/<x>/widgets/`.
