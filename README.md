# MusicLibrary

## Applicaiton layers

This application is specifically built with abstraction layers making it possible to interact in various ways.

Web -> Api -> Backend -> Schema

### Web layer

Phoenix/LiveView interaction to the app

### Api layer

External/other parties attempting to read/write into the app

### Backend layer

Other bits of code that needs to interact with other bits of the code

## Ecto/Schema layer

the lowest level implementation with ecto code

## Web

[http://localhost:4000/](http://localhost:4000/)

Enter arist name

Click "Add Artist"

## API

### RESTful

| Method | Purpose |
| ------ | ------- |
| GET | Retrieve a resource |
| POST | Create a new resource |
| PUT | Replace a resource entirely |
| PATCH | Partially update a resource |
| DELETE | Remove a resource |
| HEAD | Like GET, but returns headers only (no body) |
| OPTIONS | Describe what methods the server supports for a resource |

### Get Artist

`curl -XGET -vvv http://localhost:4000/api/1/artist/Ladytron`

### Create Artist

`curl -XPOST -H "Content-Type: application/json" -vvv http://localhost:4000/api/1/artist -d "{\"name\":\"Ladytron\"}"`

### Delete Artist

`curl -XDELETE -H "Content-Type: application/json" -vvv http://localhost:4000/api/1/delete -d "{\"type\":\"artist\", \"name\":\"Ladytron\"}"`

## Backend

```Elixir
MusicLibrary.Api.Artist.post(%{"name" => "Ladytron"})
```

## Ecto/Schema

```Elixir
MusicLibrary.Query.Artist.insert(params)
```




use the medium image ( 64 x 64 ) from the json

example entry of listened to:
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
        {
            "size": "small",
            "#text": "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png"
        },
        {
            "size": "medium",
            "#text": "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png"
        },
        {
            "size": "large",
            "#text": "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png"
        },
        {
            "size": "extralarge",
            "#text": "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"
        }
    ],
    "artist": {
        "mbid": "",
        "#text": "Groove Armada"
    },
    "streamable": "0"
}




Find gap days

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