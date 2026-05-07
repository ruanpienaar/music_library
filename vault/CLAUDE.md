# music_library — Claude Context

## Project
Phoenix 1.7 app (Elixir) backed by PostgreSQL. Personal music library that syncs scrobble history from Last.fm and stores it locally.

## Stack
- **HTTP:** `Req` (all outbound requests)
- **JSON:** `Jason`
- **Time:** `Timex`
- **DB:** Ecto + Postgrex (PostgreSQL)

## Module Conventions
| Layer | Path | Purpose |
|---|---|---|
| Schema | `lib/music_library/schema/` | Ecto schemas + changesets |
| Query | `lib/music_library/query/` | Ecto query functions |
| API | `lib/music_library/api/` | Internal API surface (request params → query calls) |
| Last.fm | `lib/music_library/last_fm/` | External Last.fm integration |

- Table names are **singular** (`artist`, `track`)
- Commented-out code blocks must be preserved — do not remove them

## Last.fm Integration
- Credentials live in `config/config.exs` under `:last_fm` (api_key, username)
- `MusicLibrary.LastFm.Client` — rate-limited HTTP client (250 ms / request, User-Agent set)
- `MusicLibrary.LastFm.RecentTracks` — paginated fetch of full scrobble history
- Typical sync: `RecentTracks.fetch_all/0` → `Query.Track.upsert_all/1`

## Database
- Run migrations: `mix ecto.migrate`
- `track` table has a unique index on `(listened_at, artist, name)` — safe to upsert repeatedly

## Last.fm ToS Notes
See `vault/last_fm_tos_compliance.md` for full compliance review. Key constraints:
- Non-commercial use only
- Must display attribution links (`track.url`) in any UI
- Do not cache or redistribute album art images locally
- 100 MB stored data cap — monitor DB size

## Vault
Project notes and compliance docs live in `vault/` (Obsidian). Relevant files:
- `vault/last_fm_tos_compliance.md` — ToS compliance review and outstanding actions
- `vault/CLAUDE.md` — copy of this file
