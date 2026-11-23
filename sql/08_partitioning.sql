-- Non-destructive RANGE-partitioned prototype, separate from spotify.streams.
-- Run once after loading the large database. Does not replace the workload table.
\set ON_ERROR_STOP on
BEGIN;
SET TIME ZONE 'Asia/Kolkata';
CREATE SCHEMA spotify_scale;
CREATE TABLE spotify_scale.streams (
    LIKE spotify.streams INCLUDING DEFAULTS INCLUDING CONSTRAINTS,
    PRIMARY KEY (stream_id, started_at),
    FOREIGN KEY (user_id) REFERENCES spotify.users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (track_id) REFERENCES spotify.tracks(track_id) ON DELETE RESTRICT,
    FOREIGN KEY (playlist_id) REFERENCES spotify.playlists(playlist_id) ON DELETE RESTRICT
) PARTITION BY RANGE (started_at);
-- PK includes the partition key. This does NOT enforce global stream_id uniqueness.
-- A production migration must retain an unpartitioned stream-ID registry, use a
-- globally unique ID allocator with documented guarantees, or change references
-- to (stream_id, started_at). This prototype is not a transparent PK replacement.
DO $$
DECLARE
    month_start timestamptz;
    stop_month timestamptz;
    next_month timestamptz;
    partition_name text;
BEGIN
    SELECT date_trunc('month', min(started_at)),
           date_trunc('month', max(started_at)) + interval '2 months'
      INTO month_start, stop_month FROM spotify.streams;
    IF month_start IS NULL THEN
        RAISE EXCEPTION 'Load source streams before creating the partition prototype';
    END IF;
    WHILE month_start < stop_month LOOP
        next_month := month_start + interval '1 month';
        partition_name := 'streams_' || to_char(month_start, 'YYYY_MM');
        EXECUTE format('CREATE TABLE spotify_scale.%I PARTITION OF spotify_scale.streams FOR VALUES FROM (%L) TO (%L)',
                       partition_name, month_start, next_month);
        month_start := next_month;
    END LOOP;
END
$$;
COMMIT;
