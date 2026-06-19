# Contributing — Sabil Life Mobile

Read `CLAUDE.md` first. The agent rules there are the source of truth — this doc just
covers the day-to-day collaboration mechanics.

## Toolchain

This repo uses **[fvm](https://fvm.app)** to pin the Flutter SDK. Always invoke Flutter
and Dart through fvm:

```bash
fvm flutter <cmd>
fvm dart <cmd>
```

The pinned channel/version lives in `.fvmrc`. Run `fvm install` once after cloning.

## Environment

```bash
cp .env.example .env
```

`.env` is gitignored. Pick the right `API_BASE_URL` for your runtime:

| Runtime                          | URL                                         |
| -------------------------------- | ------------------------------------------- |
| iOS simulator / web / desktop    | `http://localhost:8000/api/v1`              |
| Android emulator                 | `http://10.0.2.2:8000/api/v1`               |
| Physical device on the same LAN  | `http://<your-host-LAN-IP>:8000/api/v1`     |

The app falls back to `http://localhost:8000/api/v1` when `.env` is missing, so it boots
even without one — but you'll only be able to call the backend from runtimes that can
actually reach `localhost`.

## Branching & commits

- Branch off `main`: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`.
- Keep commits focused. Don't mix unrelated changes.
- Never commit:
  - `.env`
  - `android/key.properties`, keystores
  - `.flutter-plugins-dependencies` (generated, gitignored)
  - editor / agent caches (`.idea/`, `.vscode/`, `.claude/`, `.omc/`, `.codex/`)

## Before you push

```bash
fvm dart format .
fvm flutter analyze       # must be 0 errors
fvm flutter test          # if you touched tested code
fvm flutter run           # smoke the golden path on the touched flow
```

A local pre-commit hook can run the first two for you — see below.

## Pre-commit hook (one-time setup)

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

After that, every `git commit` runs `fvm dart format` and `fvm flutter analyze` on the
staged Dart files and blocks the commit if either fails. To bypass for a WIP commit:
`git commit --no-verify`.

## Pull requests

- Open against `main`. Fill in the PR template.
- CI must be green (analyze + format + tests).
- One reviewer minimum. Squash-merge is fine; preserve the merge commit only when the
  branch history is meaningfully reviewable.

## Code conventions

- One widget per file for anything reused. Screens compose from `features/<x>/widgets/`.
- All user-facing strings go through the ARB files in `lib/core/l10n/`. Keep `en`, `ru`,
  `kk` in sync.
- Tokens from `lib/core/theme/` only — no ad-hoc colors, spacings, or text styles.
- Mock repos mirror the planned backend signatures so the real HTTP swap is one file.
