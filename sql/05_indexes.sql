-- Phase 4 tuning. Run after the Phase 3 baseline on the same database.
\set ON_ERROR_STOP on
BEGIN;
SET search_path TO spotify, public;
-- R03: pg_trgm GIN supports leading-wildcard ILIKE; a normal title B-tree does not.
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;
CREATE INDEX tracks_title_trgm_idx ON tracks USING gin (title public.gin_trgm_ops);
-- R01/R08/R16/R19/W04: artist equality first, then track join; role available in index.
CREATE INDEX track_artists_artist_track_idx ON track_artists (artist_id, track_id) INCLUDE (role);
-- R04/R09: user equality followed by timestamp range/order; cover playback columns.
CREATE INDEX streams_user_started_idx ON streams (user_id, started_at DESC) INCLUDE (track_id, ms_played, platform);
-- R01/R08/R19/R25/W04: per-track stream lookups, with date as second key.
CREATE INDEX streams_track_started_idx ON streams (track_id, started_at DESC) INCLUDE (user_id, ms_played, skipped);
-- R07/R10/R16/R17/R23: timestamp ranges and global newest-first traversal.
-- R23 retains OFFSET semantics; covering avoids heap fetches when visibility allows.
CREATE INDEX streams_started_idx ON streams (started_at DESC) INCLUDE (stream_id, user_id, track_id, ms_played, platform);
-- R13: only playlist-linked streams are useful; equality anti-join probes use a small B-tree.
CREATE INDEX streams_playlist_idx ON streams (playlist_id) WHERE playlist_id IS NOT NULL;
-- R06: user equality then newest likes; covering track id supports the track join.
CREATE INDEX liked_tracks_user_liked_idx ON liked_tracks (user_id, liked_at DESC) INCLUDE (track_id);
-- R11: artist equality then release-date range/order; do not duplicate the album PK.
CREATE INDEX albums_artist_release_idx ON albums (artist_id, release_date DESC);
-- R25: recent-release filtering across all artists needs release_date as leading key.
CREATE INDEX albums_release_idx ON albums (release_date DESC, album_id);
-- R15: reverse lookup of followers by artist; existing PK supports the other join direction.
CREATE INDEX artist_follows_artist_user_idx ON artist_follows (artist_id, user_id);
-- W05: takedown finds playlist entries by track; existing PK starts with playlist_id.
CREATE INDEX playlist_tracks_track_idx ON playlist_tracks (track_id);
COMMIT;
-- VACUUM is deliberately outside the transaction; visibility maps enable index-only scans.
VACUUM (ANALYZE) spotify.streams;
VACUUM (ANALYZE) spotify.track_artists;
VACUUM (ANALYZE) spotify.liked_tracks;
VACUUM (ANALYZE) spotify.artist_follows;
VACUUM (ANALYZE) spotify.playlist_tracks;
ANALYZE;
