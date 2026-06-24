# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A private single-page app for the DTC program where members share prompting "tips," rate them, and leave notes. Plain HTML/CSS/vanilla JS with Supabase (auth + Postgres + RLS) as the backend. **No build step, no framework, no package.json, no tests.**

## Running

```
npx serve .          # or: python -m http.server
```

Open via `http://localhost…`, never `file://` — the "How AI works" page `fetch`es `concepts.md`, which browsers block over `file://`.

There is nothing to build, lint, or test. Changes to `.js`/`.css`/`.html` take effect on reload.

## Two runtime modes (the central design fact)

The app decides its mode at load from `config.js`:

- **Live** — `config.js` has a Supabase `url` + `anonKey` → uses Supabase for auth and data.
- **Demo** — those fields empty → in-memory `SAMPLE` data in `data.js`, sign-in disabled, ratings persisted to `localStorage` (`aitips_demo_ratings`), tip/group creation throws.

`data.js` is the only file that knows which mode is active. Every method on the `DB` object branches on `sb` (the Supabase client, null in demo). **When you add or change a data operation, you must update both branches** and keep their return shapes identical, because `app.js` consumes a single normalized shape and never knows the mode.

## Architecture

Four globals on `window`, loaded in order by `index.html`, each an IIFE:

- `config.js` → `window.SUPABASE_CONFIG`
- `data.js` → `window.DB` — the entire data layer. Public async API: `init`, `onAuth`, `signIn`, `signOut`, `catalogue`, `tip`, `saveRating`, `deleteRating`, `groups`, `createGroup`, `createTip`, `updateTip`, `leaderboard`. Normalizes Supabase rows and demo data into the same objects (e.g. `{avg, count, you, blurb, author}`). A tip exposes `examples` (array of prompt strings, normalized via `examplesOf` from the legacy single `example` column) and `canEdit` (author-only); each comment carries `mine`. `onAuth` only fires its callback when the signed-in identity changes, so Supabase token refreshes on tab focus don't reset the current view. Aggregation (`agg`), blurb extraction, and the leaderboard are all computed client-side here.
- `app.js` → view controller. Single `#main` element, a `view` string for current screen, and `cat` as the cached catalogue used by both the sidebar and the catalogue grid. Rendering is hand-rolled template strings; **all interpolated user data must go through `esc()`** (the local HTML-escaper) — there is no templating library doing this for you. Navigation is `data-nav` / `data-tip` attributes wired up after each render via `go()` and `openTip()`.

Third-party libs (`@supabase/supabase-js`, `marked`) load from CDN in `index.html` — there is no local dependency install.

## Data model & security (schema.sql)

Tables: `profiles`, `groups`, `tips`, `ratings`, plus allowlists `approved_domains` / `approved_emails`.

- **The anon key is public by design.** Security is enforced entirely by Postgres **RLS**, not the client. Never put the `service_role` key anywhere in the frontend.
- Access is gated by `is_approved()` (a `security definer` SQL function): the signed-in email's domain must be in `approved_domains` or the email in `approved_emails`. Every RLS policy is `using (is_approved())`.
- Writes are author-scoped: a user can only update/delete `groups`/`tips` where `author_id = auth.uid()`, and only their own `ratings` (`unique (tip_id, user_id)`; `saveRating` upserts on that conflict).
- A trigger (`handle_new_user`) auto-creates a `profiles` row on signup, with `display_name` defaulting to the email's local part.
- Sign-up is expected to be disabled in the Supabase dashboard; the allowlist + RLS is the real gate.

`seed.sql` loads the default groups/tips authored by `nicholas.snogren@sprezzmc.com` and must run **after** he has signed in once (so his profile row exists). Both `.sql` files are idempotent and run in the Supabase SQL editor.

## When editing

- Keep `data.js`'s demo and live branches in lockstep (see "Two runtime modes").
- Schema changes live in `schema.sql` and must be applied manually in the Supabase SQL editor — there are no migrations.
- Changing who has access = edit the `approved_domains` / `approved_emails` rows (or the seed list in `schema.sql`), not the app code.
