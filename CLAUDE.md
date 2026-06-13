# Sabil Life — Mobile (Flutter, mock-data frontend)

Build guides at repo root:
- `SABIL_LIFE_IMPLEMENTATION.md` — base family directory app.
- `SABIL_PROVIDER_FRONTEND.md` — auth, just-in-time login, and the tutor / masterclass provider surface.

This repo uses **fvm** — always run Flutter/Dart via `fvm flutter ...` / `fvm dart ...`.

## Agent Operating Rules

1. **Mock-first, contract-aligned.** No real network calls (only OSM tiles + placeholder images). `AuthRepository`, `ProviderRepository` and `InquiryRepository` method names / params / return shapes must mirror the planned backend so the HTTP swap is a one-file change per repo.
2. **Never gate browsing.** Families reach all directory / map / detail / category screens with no login. Auth is requested only at the point of action (Request CTA, /provider area, /my-requests).
3. **Role decides the shell.** After login: `family` → existing 4-tab family shell; `tutor` / `masterclass` → 5-tab provider shell. Logged-out users see the family shell in anonymous mode.
4. **Build only interactable components.** Do not produce static placeholder screens. If you render a card, its tap, its heart/save, and any control on it must do something against mock state.
5. **Design fidelity to Airbnb.** Use the tokens exactly. Coral `#FF385C` is the only accent. White surfaces, `#222222` text, generous rounding, large photos. No gradients, no heavy shadows (one soft shadow token only).
6. **Localize every user-facing string** through the ARB files (`lib/core/l10n/`). Never hardcode a UI string in a widget. Mock *content* (school names, tutor names, etc.) may stay as-is — only UI chrome is translated. Keep all three ARB files (`en`, `ru`, `kk`) in sync.
7. **After every phase run:** `fvm flutter analyze` (must be 0 errors) and `fvm dart format .`. The app must `fvm flutter run` without crashing at the end of each phase that touches UI.
8. **No TODOs left in interactive paths.** A button with `onPressed: () {}` is a failure. Wire it to real mock behaviour or remove it.
9. **Keep widgets small.** One widget per file for anything reused. Screens compose from `features/<x>/widgets/`.

## Demo accounts

Mock auth validates against in-memory accounts (password: `demo1234`):

| Email          | Role          | Verified | Owns                                      |
|----------------|---------------|----------|-------------------------------------------|
| `family@demo`  | family        | yes      | —                                         |
| `tutor@demo`   | tutor         | yes      | MathCraft / Arabic Roots / Summit centres |
| `mc@demo`      | masterclass   | **no**   | Canvas / Clay House / Little Chefs        |

`mc@demo` is intentionally unverified so the dashboard verification banner has a real account to demo against.
