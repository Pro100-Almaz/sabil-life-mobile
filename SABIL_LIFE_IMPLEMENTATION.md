# Sabil Life — Mobile App Implementation Instruction (Frontend / Mock Data)

> **For use with Claude Code (CLI) as an agentic build guide.**
> Save this file at the repo root. Drop the **Agent Operating Rules** section into your `CLAUDE.md` so it stays in context for every session. Then run the build **one phase at a time**: e.g. `implement Phase 1 from SABIL_LIFE_IMPLEMENTATION.md`, verify, then proceed.

---

## 0. Project Summary

**Product:** Sabil Life — a family-life directory app helping families discover schools, nurseries, children's activities, entertainment, tutors, masterclasses, and partner offers **near their home**.

**This build is FRONTEND ONLY.** No backend, no real API, no auth server. Every screen is wired to **in-memory mock data**. Every component must be **interactable** — taps, filters, search, toggles, navigation, and map interactions all work against mock data.

| Attribute | Value |
|-----------|-------|
| Framework | Flutter (stable channel, ≥ 3.22), Dart ≥ 3.4 |
| Target users | Expat families living in Qatar (Doha-centric mock data) |
| Languages | Russian (`ru`), Kazakh (`kk`), English (`en`) — full UI localization, live switch |
| Design language | **Airbnb** — warm coral accent, photography-driven, card-first, rounded, location-first |
| Currency in mock data | QAR |
| State management | `flutter_riverpod` (light usage: favorites, locale, filters) |
| Navigation | `go_router` with a `StatefulShellRoute` bottom-nav shell |
| Map | `flutter_map` (OpenStreetMap tiles — no API key needed for mock build) |

---

## 1. Agent Operating Rules (put these in CLAUDE.md)

1. **Mock data only.** Never add `http`, `dio`, Firebase, or any network/data-fetching package except map tiles. All data lives in `lib/data/mock/`.
2. **Build only interactable components.** Do not produce static placeholder screens. If you render a card, its tap, its heart/save, and any control on it must do something against mock state.
3. **Design fidelity to Airbnb.** Use the tokens in Section 4 exactly. Coral `#FF385C` is the only accent. White surfaces, `#222222` text, generous rounding, large photos. No gradients, no heavy shadows (one soft shadow token only).
4. **Localize every user-facing string** through the ARB files. Never hardcode a UI string in a widget. Mock *content* (school names, etc.) may stay as-is — only UI chrome is translated.
5. **One phase per turn.** Complete a phase fully, run the phase's verification commands, fix all `flutter analyze` issues, then stop and report. Do not jump ahead.
6. **After every phase run:** `flutter analyze` (must be 0 errors) and `dart format .`. The app must `flutter run` without crashing at the end of each phase that touches UI.
7. **No TODOs left in interactive paths.** A button with `onPressed: () {}` is a failure. Wire it to real mock behaviour or remove it.
8. **Keep widgets small.** One widget per file for anything reused. Screens compose from `features/<x>/widgets/`.

---

## 2. Dependencies

Add to `pubspec.yaml` (pin to latest compatible stable at build time):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  flutter_map: ^7.0.0
  latlong2: ^0.9.0
  cached_network_image: ^3.3.0
  google_fonts: ^6.2.0

flutter:
  uses-material-design: true
  generate: true   # enables gen-l10n
```

Create `l10n.yaml` at repo root:

```yaml
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

**Verification:** `flutter pub get` succeeds.

---

## 3. Folder Structure (create exactly this)

```
lib/
  main.dart
  app.dart                         # MaterialApp.router + theme + localization wiring
  core/
    theme/
      app_colors.dart
      app_typography.dart
      app_spacing.dart             # spacing + radius + one shadow token
      app_theme.dart               # builds ThemeData from the above
    router/
      app_router.dart              # go_router + StatefulShellRoute bottom nav
    l10n/
      app_en.arb
      app_ru.arb
      app_kk.arb
    state/
      locale_provider.dart         # Riverpod: current Locale, switchable
      favorites_provider.dart      # Riverpod: Set<String> of saved listing ids
      filter_provider.dart         # Riverpod: active filters + search query
    util/
      distance.dart                # haversine km from mock home location
  data/
    models/
      listing.dart                 # immutable model + enum CategoryType
      review.dart
    mock/
      mock_home.dart               # the family's mock home coordinate (Doha)
      mock_listings.dart           # ~24 listings across all categories
  features/
    shell/
      shell_screen.dart            # bottom nav scaffold (4 tabs)
    home/
      home_screen.dart
      widgets/
        search_pill.dart
        category_strip.dart        # horizontal selectable chips
        section_header.dart
        listing_card.dart          # the reusable card (image, heart, meta)
        listing_card_wide.dart     # optional horizontal variant
    category/
      category_list_screen.dart
      widgets/
        filter_sheet.dart          # modal bottom sheet: distance/price/age
        sort_menu.dart
    detail/
      listing_detail_screen.dart
      widgets/
        image_carousel.dart
        rating_row.dart
        info_tile.dart
    map/
      map_screen.dart
      widgets/
        map_listing_preview.dart   # mini card shown when a marker is tapped
    favorites/
      favorites_screen.dart
    settings/
      settings_screen.dart         # language switcher (live), about
  shared/
    widgets/
      app_button.dart              # filled + outlined variants
      heart_button.dart            # animated save toggle
      pill_chip.dart
      star_rating.dart
```

---

## 4. Design System — Airbnb Tokens (`core/theme/`)

### 4.1 Colors — `app_colors.dart`
```
primary           #FF385C   // Airbnb "Rausch" accent — the ONLY accent color
primaryPressed    #E00B41
textPrimary       #222222
textSecondary     #717171
textTertiary      #B0B0B0
border            #DDDDDD
divider           #EBEBEB
surface           #FFFFFF
surfaceAlt        #F7F7F7   // section backgrounds, chips at rest
star              #222222   // ratings use dark star, not gold
success           #008A05   // "Verified" / open badges
overlayScrim      0x66000000
```

### 4.2 Typography — `app_typography.dart`
Use `google_fonts` **Manrope** as the Airbnb-Cereal substitute (geometric, friendly). Two weights only where possible: 400 and 700; 600 for buttons/labels.

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| display | 26 | 700 | screen titles |
| h2 | 22 | 700 | section headers |
| h3 | 18 | 600 | card titles, detail subheads |
| body | 16 | 400 | primary text |
| label | 14 | 600 | buttons, chips, meta emphasis |
| caption | 14 | 400 | secondary meta |
| small | 12 | 400 | distance, fine print |

### 4.3 Spacing / Radius / Shadow — `app_spacing.dart`
```
space:  4 / 8 / 12 / 16 / 20 / 24 / 32
radius: button 10, card 12, image 12, chip 999 (pill), sheet 16
shadow: ONE soft token — offset(0,2), blur 12, color 0x14000000   // ~8% black
```

### 4.4 Theme — `app_theme.dart`
Build a single light `ThemeData`:
- `scaffoldBackgroundColor: surface`
- `colorScheme.primary: primary`
- Pill-shaped `FilledButton`/`OutlinedButton` themes (radius 10, height 48)
- `BottomNavigationBar`/`NavigationBar`: selected = primary, unselected = textSecondary, background white, no elevation tint
- Card theme: white, radius 12, the single soft shadow
- Input theme for search/filters: filled `surfaceAlt`, radius 12, no visible border at rest

> Dark mode is out of scope for this MVP. Ship light only.

**Verification:** A throwaway `flutter run` shows the themed colors/fonts on a placeholder. Remove the placeholder before finishing the phase.

---

## 5. Localization (`core/l10n/`)

Generate via `flutter gen-l10n`. Provide all three ARB files with the same keys. Below is the **required starter key set** — add keys as new strings appear; never hardcode.

`app_en.arb`
```json
{
  "appName": "Sabil Life",
  "navHome": "Home",
  "navMap": "Map",
  "navFavorites": "Saved",
  "navSettings": "Settings",
  "searchHint": "Search schools, activities…",
  "nearYou": "Near you",
  "featured": "Featured",
  "popularInDoha": "Popular in Doha",
  "catSchools": "Schools",
  "catNurseries": "Nurseries",
  "catActivities": "Activities",
  "catEntertainment": "Entertainment",
  "catTutoring": "Tutoring",
  "catMasterclasses": "Masterclasses",
  "catPartnerships": "Partners",
  "distanceAway": "{km} km away",
  "@distanceAway": { "placeholders": { "km": { "type": "String" } } },
  "fromPrice": "from {price} QAR",
  "@fromPrice": { "placeholders": { "price": { "type": "String" } } },
  "filters": "Filters",
  "sort": "Sort",
  "maxDistance": "Max distance",
  "priceRange": "Price range",
  "ageGroup": "Age group",
  "apply": "Apply",
  "reset": "Reset",
  "sortDistance": "Nearest first",
  "sortRating": "Top rated",
  "sortPriceLow": "Price: low to high",
  "save": "Save",
  "saved": "Saved",
  "noFavorites": "Nothing saved yet",
  "viewOnMap": "View on map",
  "reviews": "{count} reviews",
  "@reviews": { "placeholders": { "count": { "type": "int" } } },
  "about": "About",
  "details": "Details",
  "language": "Language",
  "selectLanguage": "Select language",
  "resultsCount": "{count} results",
  "@resultsCount": { "placeholders": { "count": { "type": "int" } } }
}
```

`app_ru.arb`
```json
{
  "appName": "Sabil Life",
  "navHome": "Главная",
  "navMap": "Карта",
  "navFavorites": "Избранное",
  "navSettings": "Настройки",
  "searchHint": "Поиск школ, занятий…",
  "nearYou": "Рядом с вами",
  "featured": "Рекомендуемые",
  "popularInDoha": "Популярное в Дохе",
  "catSchools": "Школы",
  "catNurseries": "Детские сады",
  "catActivities": "Занятия",
  "catEntertainment": "Развлечения",
  "catTutoring": "Репетиторы",
  "catMasterclasses": "Мастер-классы",
  "catPartnerships": "Партнёры",
  "distanceAway": "{km} км от вас",
  "fromPrice": "от {price} QAR",
  "filters": "Фильтры",
  "sort": "Сортировка",
  "maxDistance": "Макс. расстояние",
  "priceRange": "Диапазон цен",
  "ageGroup": "Возраст",
  "apply": "Применить",
  "reset": "Сбросить",
  "sortDistance": "Сначала ближайшие",
  "sortRating": "С высоким рейтингом",
  "sortPriceLow": "Цена: по возрастанию",
  "save": "Сохранить",
  "saved": "Сохранено",
  "noFavorites": "Пока ничего не сохранено",
  "viewOnMap": "Показать на карте",
  "reviews": "{count} отзывов",
  "about": "О нас",
  "details": "Подробности",
  "language": "Язык",
  "selectLanguage": "Выберите язык",
  "resultsCount": "{count} результатов"
}
```

`app_kk.arb`
```json
{
  "appName": "Sabil Life",
  "navHome": "Басты бет",
  "navMap": "Карта",
  "navFavorites": "Таңдаулылар",
  "navSettings": "Баптаулар",
  "searchHint": "Мектептер, сабақтар іздеу…",
  "nearYou": "Жақын маңда",
  "featured": "Ұсынылған",
  "popularInDoha": "Дохада танымал",
  "catSchools": "Мектептер",
  "catNurseries": "Балабақшалар",
  "catActivities": "Сабақтар",
  "catEntertainment": "Ойын-сауық",
  "catTutoring": "Репетиторлар",
  "catMasterclasses": "Шеберлік сыныптары",
  "catPartnerships": "Серіктестер",
  "distanceAway": "{km} км қашықтықта",
  "fromPrice": "{price} QAR-дан",
  "filters": "Сүзгілер",
  "sort": "Сұрыптау",
  "maxDistance": "Макс. қашықтық",
  "priceRange": "Баға аралығы",
  "ageGroup": "Жас",
  "apply": "Қолдану",
  "reset": "Тазалау",
  "sortDistance": "Алдымен жақындары",
  "sortRating": "Жоғары рейтингті",
  "sortPriceLow": "Баға: өсу бойынша",
  "save": "Сақтау",
  "saved": "Сақталды",
  "noFavorites": "Әзірге ештеңе сақталмаған",
  "viewOnMap": "Картадан көру",
  "reviews": "{count} пікір",
  "about": "Біз туралы",
  "details": "Толығырақ",
  "language": "Тіл",
  "selectLanguage": "Тілді таңдаңыз",
  "resultsCount": "{count} нәтиже"
}
```

> Translations are a working starting point; flag them for a native review later. The agent must keep all three files in sync — adding a key to one means adding it to all three.

**Verification:** `flutter gen-l10n` produces `AppLocalizations`; switching locale in Settings changes every visible string with no English left behind.

---

## 6. Data Layer

### 6.1 Model — `data/models/listing.dart`
Immutable class with `final` fields and a `copyWith`. Fields:

```
String   id
String   title
CategoryType category          // enum below
String   subtitle              // e.g. "British curriculum · Ages 3–11"
String   neighborhood          // e.g. "West Bay, Doha"
double   lat, lng
double   rating                // 0–5, one decimal
int      reviewCount
int      priceFromQar          // 0 = free / N/A
List<String> imageUrls         // use stable placeholder photo URLs
List<String> ageGroups         // e.g. ["3-5","6-11"]
bool     isFeatured
String   description           // 1–2 paragraphs of mock copy
List<String> highlights        // 3–5 bullet strings
```

```dart
enum CategoryType { schools, nurseries, activities, entertainment, tutoring, masterclasses, partnerships }
```

`data/models/review.dart`: `author`, `rating`, `text`, `monthsAgo`.

### 6.2 Mock home — `data/mock/mock_home.dart`
A single const family home location to compute distance from. Use **The Pearl, Doha**: `lat 25.3690, lng 51.5510`.

### 6.3 Distance util — `core/util/distance.dart`
Haversine returning km, formatted to 1 decimal. The card/detail "X km away" comes from this against `mockHome`.

### 6.4 Mock listings — `data/mock/mock_listings.dart`
Provide **~24 listings** spread across all 7 categories, all located in real Doha neighborhoods (West Bay, The Pearl, Lusail, Al Sadd, Education City, Al Waab, Aspire Zone, Msheireb, Al Wakrah). Use **fictional but plausible** business names (avoid real trademarks). Vary rating, price, age groups, and set ~6 as `isFeatured`. Use stable photo placeholders, e.g. `https://picsum.photos/seed/<id>/800/600` so images differ per listing and load offline-tolerantly.

Cover at least: 4 schools, 3 nurseries, 6 activities (swimming, football, basketball, dance, gymnastics, fencing — matching the category doc), 3 entertainment, 3 tutoring (Arabic, Math, exam prep), 3 masterclasses (painting, pottery, +1), 2 partners (a tourism partner, a heritage/education partner).

**Verification:** A unit-free sanity check — a temporary `print(mockListings.length)` ≥ 24, every `CategoryType` has ≥ 2 entries. Remove the print after.

---

## 7. State (`core/state/`, Riverpod)

- `localeProvider` — `StateProvider<Locale>` defaulting to `en`; Settings updates it; `app.dart` reads it for `MaterialApp.locale`.
- `favoritesProvider` — `StateNotifierProvider<FavoritesNotifier, Set<String>>` with `toggle(id)` / `isSaved(id)`. Drives every heart button and the Favorites tab.
- `filterProvider` — `StateNotifierProvider` holding: `query`, `selectedCategory`, `maxDistanceKm`, `priceMax`, `ageGroup`, `sortMode`. Expose a derived `filteredListings` computed provider that applies query + category + filters + sort over `mockListings`.

> All filtering/sorting happens **synchronously in-memory** in the computed provider. No futures, no loading spinners needed (but a list may animate).

---

## 8. Navigation (`core/router/app_router.dart`)

`go_router` with a `StatefulShellRoute.indexedStack` for the 4-tab bottom nav:

```
/            -> Home        (tab 0)
/map         -> Map         (tab 1)
/favorites   -> Favorites   (tab 2)
/settings    -> Settings    (tab 3)
/category/:type   -> CategoryListScreen (pushed above shell)
/listing/:id      -> ListingDetailScreen (pushed above shell)
```

Bottom nav items use Airbnb-style outline icons (`Icons.search`/`home_outlined`, `map_outlined`, `favorite_outline`, `person_outline`) with the localized labels and primary-color selected state.

---

## 9. Screen & Component Specs (the interactive build)

Build in this order. Each item lists the **interactions that must work**.

### Phase 5 — Home (`features/home/`)
- **SearchPill**: tap focuses an inline text field; typing updates `filterProvider.query` → the lists below filter live. A clear (✕) button resets the query.
- **CategoryStrip**: horizontal scroll of selectable pill chips (one per `CategoryType` + an "All"). Tapping sets `selectedCategory` and either filters the home lists or navigates to `/category/:type` (choose navigate-to-category for a single category tap; "All" stays on home). Selected chip uses primary fill, others `surfaceAlt`.
- **Sections**: "Featured" (horizontal carousel of `listing_card`), "Near you" (vertical list sorted by distance asc), each with a `SectionHeader` (title + optional "See all" → category screen).
- **ListingCard**: large rounded image (16:10), a **HeartButton** overlaid top-right (toggles `favoritesProvider` with a scale animation), title, subtitle, `★ rating · reviewCount`, `distanceAway`, `fromPrice`. Tapping the card → `/listing/:id`.

### Phase 6 — Category list (`features/category/`)
- Header shows category name + localized `resultsCount`.
- **Filter button** opens **FilterSheet** (modal bottom sheet, radius 16): a **distance slider** (1–30 km), a **price range** control, an **age-group** selectable chip row. "Apply" commits to `filterProvider` and closes; "Reset" clears. Closing re-renders the filtered list.
- **Sort button** opens **SortMenu** (distance / rating / price-low) → updates `sortMode`.
- Body: vertical list of `listing_card` from the `filteredListings` provider. Empty state when filters exclude everything.

### Phase 7 — Detail (`features/detail/`)
- **ImageCarousel**: swipeable `PageView` of `imageUrls` with page dots; HeartButton overlay (same provider).
- Title, neighborhood, **RatingRow** (★ rating · localized reviews), `distanceAway`, `fromPrice`.
- **Highlights** as `InfoTile`s; description paragraph.
- A mini map preview (static `flutter_map` centered on the listing) with a **"View on map"** button → `/map` focused on this listing.
- A primary **AppButton** ("Save"/"Saved" reflecting favorite state) and a secondary action. Reviews list from mock `review` data.

### Phase 8 — Map (`features/map/`)
- `flutter_map` (OSM tiles) centered on `mockHome`, a distinct home marker, and a coral marker per visible listing (respect the active category/filters).
- Tapping a marker shows **MapListingPreview** (a small bottom card: image, title, distance, rating) → tap card opens `/listing/:id`.
- A category chip strip at top filters which markers show.

### Phase 9 — Favorites + Settings
- **Favorites**: list of saved listings from `favoritesProvider`; un-hearting removes it live; localized empty state when none.
- **Settings**: **language switcher** — three options (English / Русский / Қазақша) as a selectable list; selecting one updates `localeProvider` and the whole app re-localizes immediately. Plus a static "About" tile.

### Shared atoms (build in Phase 1/as-needed)
- `AppButton` (filled coral + outlined), `HeartButton` (animated), `PillChip` (selectable), `StarRating` (read-only ★ + number).

---

## 10. Phase Plan (run these in order with Claude Code)

| Phase | Deliverable | Verify with |
|-------|-------------|-------------|
| 0 | `pubspec.yaml`, `l10n.yaml`, folder skeleton, `flutter pub get` | builds, empty app runs |
| 1 | Theme + shared atoms (`AppButton`, `HeartButton`, `PillChip`, `StarRating`) | `flutter analyze` clean; atoms render in a temp gallery |
| 2 | Localization (3 ARB files, gen-l10n) | locale switch flips all strings |
| 3 | Models + mock data + distance util + Riverpod providers | listing count + per-category sanity check |
| 4 | Router + bottom-nav shell (4 empty-but-real tabs) | tabs switch, deep routes resolve |
| 5 | Home screen (search, categories, cards, hearts) | search filters live; heart toggles; card → detail route |
| 6 | Category list (filter sheet, sort, empty state) | filters/sort change the list synchronously |
| 7 | Detail screen (carousel, save, mini-map, reviews) | carousel swipes; save reflects in Favorites |
| 8 | Map screen (markers, preview, category filter) | marker tap → preview → detail |
| 9 | Favorites + Settings language switch | unsave updates live; language switch re-localizes app |
| 10 | Polish pass + DoD checklist | full manual run-through in all 3 languages |

**Per-phase command sequence for the agent:**
```bash
flutter analyze            # must report no errors
dart format .
flutter run                # smoke-test the phase's screens, then report
```

---

## 11. Definition of Done

- [ ] App launches and navigates across all 4 tabs without crashes.
- [ ] Every category has ≥ 2 mock listings; all 7 categories reachable.
- [ ] Search filters results live as you type.
- [ ] Category chips filter / navigate correctly.
- [ ] Filter sheet (distance, price, age) and sort menu visibly change the list.
- [ ] Heart/save works everywhere and is reflected in the Favorites tab in real time.
- [ ] Detail screen carousel swipes; "View on map" focuses the map on that listing.
- [ ] Map markers are tappable and open the right detail screen.
- [ ] Language switch (en/ru/kk) re-localizes the entire UI instantly — no hardcoded strings remain.
- [ ] "X km away" reflects haversine distance from the mock home for every listing.
- [ ] `flutter analyze` = 0 issues; code is `dart format`-clean.
- [ ] No network calls except OSM map tiles and placeholder images. No backend, no auth.

---

## 12. Explicit Non-Goals (do not build)

- No real authentication, accounts, or backend/API integration.
- No payments, booking, or messaging.
- No push notifications or offline cache layer.
- No dark mode.
- No user-submitted-listing flow (Phase 2 of the wider project).
- No analytics SDKs.

> When the mock frontend is approved, the next instruction will swap `data/mock/` for a real `data/remote/` repository layer talking to the Python/FastAPI backend — so keep all data access behind the providers in Section 7 to make that swap clean.
