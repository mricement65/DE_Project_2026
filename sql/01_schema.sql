-- Phase 2: constraints only. Run once against an empty database with psql.
\set ON_ERROR_STOP on
BEGIN;
CREATE SCHEMA spotify;
SET search_path TO spotify;
SET TIME ZONE 'Asia/Kolkata';

CREATE TABLE artists (
    artist_id integer PRIMARY KEY CHECK (artist_id > 0),
    artist_name text NOT NULL CHECK (btrim(artist_name) <> ''),
    country_code varchar(2) NOT NULL CHECK (country_code ~ '^[A-Z]{2}$'),
    primary_genre text NOT NULL CHECK (btrim(primary_genre) <> ''),
    is_verified boolean NOT NULL DEFAULT false,
    monthly_listeners bigint NOT NULL DEFAULT 0 CHECK (monthly_listeners >= 0),
    created_at timestamptz NOT NULL
);
CREATE TABLE albums (
    album_id integer PRIMARY KEY CHECK (album_id > 0),
    artist_id integer NOT NULL REFERENCES artists ON DELETE RESTRICT,
    album_title text NOT NULL CHECK (btrim(album_title) <> ''),
    album_type text NOT NULL CHECK (album_type IN ('ALBUM','EP','SINGLE','COMPILATION')),
    release_date date NOT NULL,
    label text NOT NULL CHECK (btrim(label) <> ''),
    upc varchar(12) NOT NULL UNIQUE CHECK (upc ~ '^[0-9]{12}$')
);
CREATE TABLE tracks (
    track_id integer PRIMARY KEY CHECK (track_id > 0),
    album_id integer NOT NULL REFERENCES albums ON DELETE RESTRICT,
    disc_no smallint NOT NULL CHECK (disc_no > 0),
    track_no smallint NOT NULL CHECK (track_no > 0),
    title text NOT NULL CHECK (btrim(title) <> ''),
    duration_ms integer NOT NULL CHECK (duration_ms > 0),
    explicit boolean NOT NULL DEFAULT false,
    isrc varchar(12) NOT NULL UNIQUE CHECK (isrc ~ '^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$'),
    popularity smallint NOT NULL CHECK (popularity BETWEEN 0 AND 100),
    UNIQUE (album_id, disc_no, track_no)
);
CREATE TABLE track_artists (
    track_id integer NOT NULL REFERENCES tracks ON DELETE CASCADE,
    artist_id integer NOT NULL REFERENCES artists ON DELETE RESTRICT,
    role text NOT NULL CHECK (role IN ('PRIMARY','FEATURED')),
    PRIMARY KEY (track_id, artist_id)
);
CREATE TABLE users (
    user_id integer PRIMARY KEY CHECK (user_id > 0),
    email text NOT NULL UNIQUE CHECK (email ~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'),
    display_name text NOT NULL CHECK (btrim(display_name) <> ''),
    country_code varchar(2) NOT NULL CHECK (country_code ~ '^[A-Z]{2}$'),
    birth_date date NOT NULL,
    subscription text NOT NULL CHECK (subscription IN ('FREE','PREMIUM','DUO','STUDENT','FAMILY')),
    created_at timestamptz NOT NULL,
    CHECK (birth_date <= (created_at AT TIME ZONE 'Asia/Kolkata')::date)
);
CREATE TABLE playlists (
    playlist_id integer PRIMARY KEY CHECK (playlist_id > 0),
    owner_user_id integer NOT NULL REFERENCES users ON DELETE RESTRICT,
    name text NOT NULL CHECK (btrim(name) <> ''),
    is_public boolean NOT NULL DEFAULT false,
    is_collaborative boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL,
    CHECK (NOT (is_public AND is_collaborative))
);
CREATE TABLE playlist_tracks (
    playlist_id integer NOT NULL REFERENCES playlists ON DELETE CASCADE,
    position integer NOT NULL CHECK (position > 0),
    track_id integer NOT NULL REFERENCES tracks ON DELETE RESTRICT,
    added_by_user_id integer NOT NULL REFERENCES users ON DELETE RESTRICT,
    added_at timestamptz NOT NULL,
    PRIMARY KEY (playlist_id, position)
);
CREATE TABLE streams (
    stream_id bigint PRIMARY KEY CHECK (stream_id > 0),
    user_id integer NOT NULL REFERENCES users ON DELETE RESTRICT,
    track_id integer NOT NULL REFERENCES tracks ON DELETE RESTRICT,
    started_at timestamptz NOT NULL,
    ms_played integer NOT NULL CHECK (ms_played >= 0),
    platform text NOT NULL CHECK (platform IN ('ANDROID','IOS','WEB','DESKTOP','SPEAKER','CAR')),
    source_type text NOT NULL CHECK (source_type IN ('PLAYLIST','ALBUM','ARTIST','RADIO','SEARCH')),
    playlist_id integer REFERENCES playlists ON DELETE RESTRICT,
    skipped boolean NOT NULL,
    offline boolean NOT NULL DEFAULT false,
    CHECK ((source_type = 'PLAYLIST') = (playlist_id IS NOT NULL)),
    CHECK (skipped = (ms_played < 30000))
);
CREATE TABLE liked_tracks (
    user_id integer NOT NULL REFERENCES users ON DELETE CASCADE,
    track_id integer NOT NULL REFERENCES tracks ON DELETE CASCADE,
    liked_at timestamptz NOT NULL,
    PRIMARY KEY (user_id, track_id)
);
CREATE TABLE artist_follows (
    user_id integer NOT NULL REFERENCES users ON DELETE CASCADE,
    artist_id integer NOT NULL REFERENCES artists ON DELETE CASCADE,
    followed_at timestamptz NOT NULL,
    PRIMARY KEY (user_id, artist_id)
);
COMMIT;
