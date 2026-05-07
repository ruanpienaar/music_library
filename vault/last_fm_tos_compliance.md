# Last.fm API — ToS Compliance Review

**Reviewed:** 2026-04-30
**Source:** https://www.last.fm/api/tos

---

## Status Summary

| Requirement | Status | Notes |
|---|---|---|
| Identifiable User-Agent header | ✅ Pass | `music_library/0.1 (ruan800@gmail.com)` |
| Rate limiting respected | ✅ Pass | 250 ms between requests (~4 req/sec, limit is 5/sec) |
| Non-commercial use only | ✅ Pass | Personal music library, no revenue generated |
| Registered Last.fm user | ✅ Pass | `ruan800` account used |
| No sub-licensing of data | ✅ Pass | Data stays local, not exposed publicly |
| No personal identification of other users | ✅ Pass | Only fetching own scrobble history |
| HTTP caching headers respected | ⚠️ Not yet | ToS §4.3.4 requires honouring cache headers from responses |
| Attribution / links back to Last.fm | ⚠️ Not yet | Required when displaying artist/album/track data in any UI (ToS §2.7) |
| 100 MB stored data cap | ⚠️ Monitor | ToS §4.3.4 — must not exceed without prior written consent |
| No publicity without written consent | ✅ Pass | No press releases or public statements planned |

---

## Outstanding Items

### 1. HTTP Response Caching (ToS §4.3.4)
> "implement suitable caching in accordance with the HTTP headers sent with web service responses"

`Req` supports caching via `cache: true` but we are not using it. Before making repeated calls (e.g. re-syncing the same page range), we should honour `Cache-Control` / `ETag` headers.

**Action:** Enable `cache: true` in `MusicLibrary.LastFm.Client.get/2`, or at minimum avoid re-fetching pages we already have stored locally.

### 2. Attribution in UI (ToS §2.7)
> "credit Last.fm and include links to the Last.fm site when You use the Last.fm Data"
> Artist/album/track pages must link to the corresponding Last.fm catalogue pages.

The `url` field is stored on every track row (`track.url`). Any LiveView or controller that renders track data must render it as a link.

**Action:** When building UI, always render `track.url` as a clickable link labelled with the track/artist name.

### 3. 100 MB Data Cap (ToS §4.3.4)
Storing full scrobble history could grow large over time. The cap applies to data retrieved and stored from the API.

**Action:** Periodically audit database size. If approaching the cap, contact `partners@last.fm` for written consent before continuing to grow the dataset.

---

## Key ToS Points to Remember

- **Commercial use is prohibited** without a separate commercial agreement — contact `partners@last.fm`.
- **No audio, images, or artwork** are licensed under this agreement (ToS §5.1.8) — album art URLs stored in the API response must not be redistributed or cached locally.
- **Termination:** If access is revoked, all stored Last.fm data must be deleted promptly (ToS §9.3).
- **Jurisdiction:** English law governs the agreement.
