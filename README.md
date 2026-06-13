# Sabil Life — Mobile

A family-life directory app helping expat families in Doha discover schools,
nurseries, children's activities, entertainment, tutors, masterclasses and
partner offers **near their home**.

This repository is the **Flutter frontend** of the project. It runs entirely
on **in-memory mock data** — no backend, no authentication, no real network
calls beyond OpenStreetMap tiles and placeholder images. Every screen and
control is interactable against mock state so the experience can be evaluated
end-to-end before the backend is wired in.

## Stack

| | |
|---|---|
| Framework | Flutter (stable, ≥ 3.22) · Dart ≥ 3.4 |
| State | `flutter_riverpod` (favorites, locale, filters) |
| Navigation | `go_router` with a `StatefulShellRoute` bottom-nav shell |
| Map | `flutter_map` (OpenStreetMap tiles) |
| Design | Airbnb-inspired tokens · coral `#FF385C` · Manrope |
| Languages | English · Русский · Қазақша (live switch) |

The full build specification lives in [`SABIL_LIFE_IMPLEMENTATION.md`](./SABIL_LIFE_IMPLEMENTATION.md).

## What's in the app

- **Home** — search, category strip, Featured / Popular / Near you sections.
- **Map** — OSM map with a home marker plus a coral marker per visible
  listing; category chips filter what's shown; tapping a marker opens a
  preview card that links to the detail screen.
- **Listing detail** — photo carousel, highlights, mini-map, "View on map",
  Save and Share, reviews.
- **Tutoring** *(dedicated page)* — person-forward tutor cards with subject
  rail and format filters (1-on-1 / small group / at centre / online); a
  tutor profile sheet links back to the centre listing.
- **Masterclasses** *(dedicated page)* — event-shaped cards with a date chip
  overlay, seats-left scarcity badge and a date-window filter (this weekend /
  next week); detail screen carries a "Pick a date" session picker.
- **Saved** — favorites with live un-hearting.
- **Settings** — instant en/ru/kk language switch.

## Getting started

This repository uses [**fvm**](https://fvm.app/) to pin the Flutter SDK
(see `.fvmrc`). All commands are run via `fvm`:

```bash
# Install dependencies
fvm flutter pub get

# Regenerate localizations (only if you edit lib/core/l10n/*.arb)
fvm flutter gen-l10n

# Static analysis (must report 0 issues)
fvm flutter analyze

# Run the mock-data sanity tests
fvm flutter test

# Format the code
fvm dart format .
```

### Run on the iOS Simulator

```bash
open -a Simulator                  # boot a simulator
fvm flutter run                    # picks the running simulator
# or target a specific device
fvm flutter run -d "iPhone 17 Pro"
```

`fvm flutter devices` lists everything available. Hot reload with `r`,
hot restart with `R`, quit with `q`.

## Project layout

```
lib/
  main.dart
  app.dart
  core/
    theme/           # design tokens (colors, typography, spacing, theme)
    router/          # go_router shell + routes
    l10n/            # ARB files + generated AppLocalizations
    state/           # Riverpod providers (locale, favorites, filters,
                     # tutor filter, masterclass schedule)
    util/            # haversine distance + label helpers
  data/
    models/          # Listing, Review, Tutor, MasterclassInfo
    mock/            # mock_listings, mock_tutors, mock_masterclasses,
                     # mock_reviews, mock_home
  features/
    shell/           # bottom-nav scaffold
    home/            # search, category strip, sections
    category/        # generic category list with filter + sort
    detail/          # listing detail with conditional sections
    map/             # OSM map with markers + preview
    tutoring/        # dedicated tutoring page
    masterclasses/   # dedicated masterclasses page
    favorites/
    settings/
  shared/widgets/    # AppButton, HeartButton, PillChip, StarRating
```

## Mock data

All data is in `lib/data/mock/`:

- **`mock_home.dart`** — the family's home coordinate (The Pearl, Doha).
- **`mock_listings.dart`** — ~24 venues across all 7 categories, all within
  ~30 km of the mock home.
- **`mock_tutors.dart`** — individual tutors affiliated with the tutoring
  centres.
- **`mock_masterclasses.dart`** — per-class session schedules generated
  relative to "today" so the feed always shows believable upcoming dates.
- **`mock_reviews.dart`** — deterministic per-listing review slices.

Distances rendered on cards and detail screens are real haversine distances
between each listing and the mock home — see `lib/core/util/distance.dart`.

## Localization

Every user-facing string lives in `lib/core/l10n/app_en.arb`,
`app_ru.arb` and `app_kk.arb`. The Russian and Kazakh values are a working
starting point and should get a native review. Adding a key to one file
**must** be matched in the other two.

## Non-goals (intentionally not built)

Authentication · payments · booking · messaging · push notifications ·
offline cache · dark mode · analytics SDKs · any HTTP client beyond the
map tile layer.

Data access goes exclusively through Riverpod providers in
`lib/core/state/`, so swapping `data/mock/` for a real `data/remote/`
repository (against the future Python/FastAPI backend) stays clean.

## License

MIT — see [`LICENSE`](./LICENSE).
