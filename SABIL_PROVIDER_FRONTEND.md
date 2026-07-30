# Sabil Life — Provider Interface & Auth Implementation Instruction (Flutter)

> **For use with Claude Code (CLI) as an agentic build guide.**
> This **extends the existing Sabil Life Flutter app** (see `SABIL_LIFE_IMPLEMENTATION.md`). It adds authentication and the tutor / masterclass-provider surface.
> Companion file: `SABIL_BACKEND_DJANGO.md` defines the real API. **This build stays mock-first** but every data call goes through a repository whose method signatures match that API contract (Section 9 there), so the mock→HTTP swap is mechanical.
> Build **one phase at a time**, verify, then continue.

---

## 0. Summary

The consumer (family) app is done. Now we add:
1. **Auth** — login/register, role-aware routing, token handling (mocked now).
2. **Just-in-time auth** — families browse anonymously; logging in is only required at the moment they act (request a tutor).
3. **Provider surface** — tutors and masterclass providers log in to manage their profile, manage listings, handle student inquiries, and see commission/earnings.

**Why auth now:** the platform takes commission for connecting a provider with a student. That requires an identified provider, a tracked inquiry, and a recorded match — none of which works anonymously.

| Attribute | Value |
|-----------|-------|
| Adds to | existing Flutter app, same packages |
| New packages | `shared_preferences` (token/session persistence) |
| State | extend `flutter_riverpod` with `authProvider` |
| Auth mode | **mock** — predefined demo accounts; fake tokens; no real validation |
| Roles handled | `family`, `tutor`, `masterclass` (provider roles share one surface) |
| Pattern to mirror | Airbnb — full anonymous browsing, login only at point of action |

---

## 1. Agent Operating Rules (append to CLAUDE.md)

1. **Mock-first, contract-aligned.** No real network calls. But `AuthRepository` and `ProviderRepository` method names, params, and returned model shapes must match `SABIL_BACKEND_DJANGO.md` Section 9 so swapping to HTTP later is a one-file change.
2. **Never gate browsing.** Families reach all directory/map/detail screens with no login. Auth is requested only when calling an action that needs identity (request tutor, save-to-server, open provider area).
3. **Role decides the shell.** After login: `family` → existing 4-tab shell; `tutor`/`masterclass` → provider shell. Logged-out users see the family shell in anonymous mode.
4. **Every string localized** (en/ru/kk) via ARB — add new keys to all three files. No hardcoded UI text.
5. **Airbnb design tokens** from the base instruction apply unchanged — coral accent, rounded, white surfaces, Manrope.
6. **No dead controls** — every button does real mock work.
7. **After each phase:** `flutter analyze` (0 errors), `dart format .`, `flutter run` smoke test, then report.

---

## 2. New Dependencies

```yaml
shared_preferences: ^2.2.0
```
`flutter pub get` must succeed. Nothing else is added.

---

## 3. New / Changed Structure

```
lib/
  core/
    state/
      auth_provider.dart          # NEW: StateNotifier<AuthState> (user, role, token, status)
    router/
      app_router.dart             # CHANGED: add auth routes + role-based redirect
  data/
    models/
      auth_user.dart              # NEW: id, email, fullName, role (enum), isVerified
      inquiry.dart                # NEW: id, listingId, providerId, status, message, createdAt
      commission.dart             # NEW: id, inquiryId, amountQar, status
    repositories/
      auth_repository.dart        # NEW: interface + MockAuthRepository
      provider_repository.dart    # NEW: interface + MockProviderRepository
      inquiry_repository.dart     # NEW: interface + MockInquiryRepository
    mock/
      mock_users.dart             # NEW: demo family + tutor + masterclass accounts
      mock_inquiries.dart         # NEW: sample inquiries for the demo provider
  features/
    auth/
      login_screen.dart           # NEW
      register_screen.dart        # NEW
      widgets/
        auth_sheet.dart           # NEW: JIT bottom-sheet (login or register inline)
        role_segmented.dart       # NEW: family / provider toggle on register
    provider/
      provider_shell.dart         # NEW: provider bottom nav (Dashboard/Listings/Inquiries/Earnings/Settings)
      dashboard_screen.dart       # NEW: summary tiles
      my_listings_screen.dart     # NEW: provider's own listings + status chips
      listing_editor_screen.dart  # NEW: create/edit form
      inquiries_screen.dart       # NEW: incoming student requests, accept/decline
      earnings_screen.dart        # NEW: commission summary
      widgets/...
  features/
    detail/
      listing_detail_screen.dart  # CHANGED: "Request"/"Contact" CTA triggers JIT auth → inquiry
```

---

## 4. Auth State & Models (Phase 0)

### 4.1 Models — `data/models/auth_user.dart`
```
enum UserRole { family, tutor, masterclass }
class AuthUser { String id; String email; String fullName; UserRole role; bool isVerified; }
bool get isProvider => role == tutor || role == masterclass;
```
`inquiry.dart` and `commission.dart` mirror the backend shapes (Section 9 of backend file).

### 4.2 `core/state/auth_provider.dart`
`AuthState { status (unauthenticated/authenticating/authenticated), AuthUser? user, String? token }`.
`AuthNotifier` exposes: `login(email, password)`, `register(...)`, `logout()`, `restore()` (reads token from `shared_preferences` on launch). On success it persists a fake token + user id and sets state. All calls delegate to `AuthRepository` — the notifier holds **no** mock logic itself.

### 4.3 `data/repositories/auth_repository.dart`
Abstract `AuthRepository` with methods matching the backend contract:
```
Future<AuthSession> login(String email, String password);
Future<AuthSession> register({required String email, required String password, required String fullName, UserRole role = UserRole.family});
Future<AuthUser> me();
Future<void> logout();
```
`MockAuthRepository` validates against `mock_users.dart` (e.g. `family@demo` / `tutor@demo` / `mc@demo`, password `demo1234`), returns a fake `AuthSession(user, token: "mock-<id>")`, simulates a ~400 ms delay. Unknown credentials throw an `AuthException` the UI shows inline.

**Verification:** unit-free smoke — calling mock login with demo creds returns the right role; bad creds throw.

---

## 5. Login / Register + Role Routing (Phase 1)

### 5.1 Screens
- **LoginScreen**: email + password fields (Airbnb-style filled inputs, radius 12), coral primary `AppButton`, inline error text, link to register. Loading state on the button while `authenticating`.
- **RegisterScreen**: full name, email, password, and a `RoleSegmented` control (Family / Provider). Choosing Provider reveals a tutor-vs-masterclass choice. Submit calls `register`.

### 5.2 Router changes — `app_router.dart`
- Add `/login`, `/register`.
- `redirect`: read `authProvider`. Logged-out users may freely access family browse routes (`/`, `/map`, `/listing/:id`, `/category/:type`). Routes under `/provider/...` redirect to `/login` if unauthenticated **or** if `role == family`.
- After login: if `isProvider` → go `/provider`; else return to where they were (or `/`).
- `restore()` runs at startup; show a tiny splash while `status == authenticating`.

**Verification:** logging in as `tutor@demo` lands on the provider shell; as `family@demo` returns to the family home; logging out returns to anonymous family home.

---

## 6. Just-in-Time Auth + Inquiry Creation (Phase 2)

This is the family-side touchpoint that justifies auth.

- On **ListingDetailScreen**, the primary CTA for `TUTORING`/`MASTERCLASSES` listings becomes **"Request"** (other categories keep "Save"/"View on map").
- Tapping **Request**:
  - if unauthenticated → present **`auth_sheet.dart`** (a modal bottom sheet with inline login + a register link). On success, continue the action.
  - if authenticated as family → open a short inquiry composer (prefilled message + edit) → submit via `InquiryRepository.create(listingId, message)` (mock appends to in-memory list) → success confirmation ("Request sent — the tutor will be in touch").
- A family can view their sent requests (optional small list on the family Settings/Profile area).

`MockInquiryRepository` stores created inquiries in memory and also seeds the demo provider's incoming list so the provider side has data to act on.

**Verification:** as a logged-out user, Request → auth sheet → login → composer → success; the new inquiry appears in the provider's Inquiries screen (Phase 5).

---

## 7. Provider Shell + Dashboard (Phase 3)

- **`provider_shell.dart`**: a separate `StatefulShellRoute` with tabs: Dashboard, Listings, Inquiries, Earnings, Settings (icons in Airbnb outline style, coral selected).
- **DashboardScreen**: greeting with `fullName`, a verification banner if `!isVerified` ("Your account is under review — listings stay in draft until approved"), and metric cards (mock): active listings, new inquiries, pending commission QAR. Cards tap through to the relevant tab.

**Verification:** provider login shows dashboard with correct name + metric tiles; unverified banner appears for an unverified demo account.

---

## 8. My Listings + Listing Editor (Phase 4)

- **MyListingsScreen**: list of the provider's own listings (filter mock data by `owner == currentUser`), each row showing a status chip (Draft / Pending / Active / Rejected, color-coded) and edit affordance. A "+ New listing" `AppButton`.
- **ListingEditorScreen**: form to create/edit — title, subtitle, neighborhood (Doha presets), price (QAR), age-group chips, description, highlights (add/remove rows), image URLs (mock add). Category is **locked** to the provider's role (tutor→Tutoring, masterclass→Masterclasses). Saving as draft keeps `DRAFT`; "Submit for review" sets `PENDING` (disabled if `!isVerified`). Persists to `MockProviderRepository`.

**Verification:** create a listing → appears in My Listings as Pending; edit it; category cannot be changed.

---

## 9. Inquiries — Accept / Decline (Phase 5)

- **InquiriesScreen**: incoming student requests for the provider (mock), each card: family name, listing requested, message preview, status, time. Actions **Accept** / **Decline**.
- **Accept** → calls `ProviderRepository.acceptInquiry(id)` (mock): sets status `ACCEPTED`, reveals the family's (mock) contact, and creates a mock `Commission` record. Show a sheet: "Student accepted — a 50 QAR commission applies" (amount from a mock rule constant).
- **Decline** → status `DECLINED`, no commission.

**Verification:** accepting an inquiry flips its status, surfaces contact, and the new commission shows up on Earnings (Phase 6).

---

## 10. Earnings / Commission Summary (Phase 6)

- **EarningsScreen**: summary metric cards — accepted students, pending commission QAR, paid QAR — plus a list of `Commission` records (from accepted inquiries) with status chips. All mock; matches the backend `/provider/earnings/` shape so it swaps cleanly.

**Verification:** earnings totals equal the sum of commissions from accepted inquiries.

---

## 11. Localization additions

Add to all three ARB files (en/ru/kk) — at minimum:
`login, register, email, password, fullName, signIn, createAccount, roleFamily, roleProvider, tutor, masterclass, logout, request, requestSent, inquiryComposerHint, dashboard, myListings, inquiries, earnings, newListing, submitForReview, draft, pending, active, rejected, accept, decline, accepted, declined, commissionApplies, pendingCommission, paidCommission, acceptedStudents, underReviewBanner, authSheetTitle`.

**Verification:** switch to ru and kk — every new provider/auth screen is fully translated, no English leaks.

---

## 12. Phase Plan

| Phase | Deliverable | Verify |
|-------|-------------|--------|
| 0 | auth models, `authProvider`, mock repos, `mock_users`, token persistence | mock login returns right role |
| 1 | Login/Register screens + role-based router redirect + restore-on-launch | tutor→provider shell, family→home |
| 2 | JIT auth sheet + family inquiry creation | logged-out Request → login → inquiry created |
| 3 | Provider shell + dashboard (metrics, verification banner) | provider dashboard renders |
| 4 | My Listings + Listing editor (category-locked, status flow) | new listing lands Pending |
| 5 | Inquiries accept/decline (+ mock commission on accept) | accept flips status + makes commission |
| 6 | Earnings summary | totals match accepted commissions |
| 7 | Localization sweep + DoD | all three languages clean |

Per phase: `flutter analyze` → `dart format .` → `flutter run`, then report.

---

## 13. Definition of Done

- [ ] Anonymous users browse the entire family directory with no login wall.
- [ ] Login/Register work against mock accounts; bad creds show inline errors.
- [ ] Session persists across app restarts (shared_preferences); logout clears it.
- [ ] Role routing: provider → provider shell, family → family shell, automatically.
- [ ] Family "Request" on a tutor triggers JIT auth then creates an inquiry.
- [ ] Provider can create/edit own listings (category-locked), submit for review (gated by verification).
- [ ] Provider sees incoming inquiries and can accept/decline; accept creates a commission.
- [ ] Earnings screen reflects accepted-inquiry commissions.
- [ ] All new UI fully localized in en/ru/kk.
- [ ] Every repository method name + shape matches `SABIL_BACKEND_DJANGO.md` Section 9.
- [ ] `flutter analyze` = 0; `dart format`-clean.

---

## 14. Non-Goals (do not build)

- No real auth/token validation, no password reset, no email verification (mock only).
- No real network calls or payment — commissions are mock records.
- No admin/moderation UI in the app (that lives in Django admin).
- No social login.
- Do not refactor the existing family screens beyond the detail-screen CTA change and router redirect.

---

## 15. The mock→real swap (later, documented now)

When the backend is live, the only changes are:
1. Add `http`/`dio` and write `HttpAuthRepository`, `HttpProviderRepository`, `HttpInquiryRepository` implementing the same interfaces.
2. Swap the repository providers in one place (a single Riverpod override).
3. Replace the fake token with the real JWT; send `Authorization: Bearer`.
No screen or widget code should need to change — that is the test of whether this phase was built correctly.
