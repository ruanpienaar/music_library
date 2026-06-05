# MusicLibrary

A personal music library app built with Phoenix/LiveView and PostgreSQL. Syncs scrobble history from Last.fm and provides a local interface to browse and manage your listening data.

## Stack

- **Phoenix 1.7 / LiveView** — web UI
- **PostgreSQL / Ecto** — data persistence
- **Last.fm API** — scrobble sync

## Running Locally

Web UI: [http://localhost:4000](http://localhost:4000)

## Architecture

The app is built in distinct layers:

| Layer | Path | Purpose |
| --- | --- | --- |
| Web | LiveView / controllers | UI and HTTP endpoints |
| API | `lib/music_library/api/` | Internal API surface |
| Query | `lib/music_library/query/` | Ecto query functions |
| Schema | `lib/music_library/schema/` | Ecto schemas + changesets |

Request flow: **Web → API → Query → Schema**

---

## API Reference

### RESTful Methods

| Method | Purpose |
| ------ | ------- |
| GET | Retrieve a resource |
| POST | Create a new resource |
| PUT | Replace a resource entirely |
| PATCH | Partially update a resource |
| DELETE | Remove a resource |
| HEAD | Like GET, but returns headers only (no body) |
| OPTIONS | Describe what methods the server supports for a resource |

### Examples

```bash
# Get artist
curl -XGET -vvv http://localhost:4000/api/1/artist/Ladytron

# Create artist
curl -XPOST -H "Content-Type: application/json" -vvv http://localhost:4000/api/1/artist -d "{\"name\":\"Ladytron\"}"

# Delete artist
curl -XDELETE -H "Content-Type: application/json" -vvv http://localhost:4000/api/1/delete -d "{\"type\":\"artist\", \"name\":\"Ladytron\"}"
```

### Internal (IEx / backend)

```elixir
MusicLibrary.Api.Artist.post(%{"name" => "Ladytron"})
MusicLibrary.Query.Artist.insert(params)
```

## Last.Fm notes

### When songs get scrobbled

According to Last.fm's own API documentation, there are two conditions for a scrobble to count:

The track must be longer than 30 seconds. Last.fm
You need to have listened to either 4 minutes or 50% of the track's duration, whichever comes first. This is the standard scrobbling rule that's been in place for years (it's in the API spec, just not shown verbatim in those results, but well-established in the community).

The Spotify scrobbler saves the scrobble to your listening history once enough percentage of the song has been played. Spotify Community
So in short — no, skipping a song early won't scrobble it. You need to hit that 50% mark (or 4 minutes, for longer tracks). If you skip after, say, 10 seconds of a 3-minute song, it won't count.

---

## Notes

### Last.fm Track Payload

Use the `medium` image (64×64) from the `image` array. Example scrobble entry:

```json
{
    "url": "https://www.last.fm/music/Groove+Armada/_/Get+Down+-+Elite+Force+Remix",
    "date": {
        "uts": "1212168414",
        "#text": "30 May 2008, 17:26"
    },
    "mbid": "",
    "name": "Get Down - Elite Force Remix",
    "album": {
        "mbid": "",
        "#text": "Get Down Mixes"
    },
    "image": [
        { "size": "small",      "#text": "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png" },
        { "size": "medium",     "#text": "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png" },
        { "size": "large",      "#text": "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png" },
        { "size": "extralarge", "#text": "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png" }
    ],
    "artist": {
        "mbid": "",
        "#text": "Groove Armada"
    },
    "streamable": "0"
}
```

### Find Gap Days (SQL)

Identifies days in the listening history where there are gaps — useful for spotting missing scrobble data.

```sql
WITH data_days AS (
  SELECT DISTINCT listened_at::date AS day
  FROM track
),
gaps AS (
  SELECT
    day,
    COALESCE(day - LAG(day) OVER (ORDER BY day) - 1, 0) AS gap_days
  FROM data_days
)
SELECT * FROM gaps
WHERE gap_days > 0
ORDER BY day;
```

### Find Artist count

```sql
select name, ( select count(*) from track as t where art.id = t.artist_id ) as trkc from artist as art ORDER BY trkc DESC;
```


