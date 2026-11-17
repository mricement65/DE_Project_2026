# Phase 3: Baseline Query Timings

**Team:** T0108 | **Sections:** A,B and E

**Measurement context:** PROVISIONAL: workspace Linux x86_64, PostgreSQL 17.12 single-user backend; not measured on the team MacBook

## Method and scope

The original R01–R25 and W01–W05 queries were retained. Each query was executed three times using EXPLAIN (ANALYZE, BUFFERS); each write was enclosed in its own BEGIN/ROLLBACK. Values below are PostgreSQL Execution Time in milliseconds, not client wall-clock time or planning time. All runs are included, including slower first runs. The baseline uses only the Phase 2 primary-key and UNIQUE indexes. No Phase 4 tuning was applied.

Raw plans: `benchmarks/results/baseline/R01.txt` through `W05.txt`. Summary: `benchmarks/results/baseline/summary.csv`. Scan details in the CSV come from run 3; the table below lists scan types seen across all runs.

## Environment and submission status

**These results are provisional workspace measurements, not the team laptop submission baseline.** The workspace uses PostgreSQL 17.12 in single-user backend; no server connections or parallel workers. Hardware: AMD EPYC 9V74 80-Core Processor (9 logical CPUs exposed). Timezone: Asia/Kolkata. Measured at: 2026-11-17T16:57:36.857498+00:00.

A fresh single-user backend was opened per query, with three consecutive runs inside that backend. Shared buffers therefore do not persist between queries; OS caches may persist. Normal-server parallel workers, background activity and caching differ. These measurements cannot establish MacBook performance and must not be compared directly with a Phase 4 run on another machine or mode. `team.json` identifies a MacBook Pro (Apple M4) and PostgreSQL 18.6; these measurements do not validate those settings.

Rerun with the provided benchmark helper on the same team laptop and PostgreSQL installation that will be used for Phase 4. Follow `docs/03_baseline_run_instructions.md`, then regenerate this report. Do not submit provisional numbers as laptop measurements.

Full environment and input hashes are in `environment.json`; `.backend.txt` files preserve original single-user output.

## Timings

| SQL query | Type | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) |
|---|---|---:|---:|---:|---:|
| R01: Artist page: artist 33's 10 most-streamed tracks in the last 28 days | READ | 206.909 | 22.175 | 21.219 | 83.434 |
| R02: Album page: tracklist of album 1469 | READ | 0.452 | 0.035 | 0.008 | 0.165 |
| R03: Search: tracks whose title contains "love", most popular first | READ | 50.554 | 15.720 | 16.238 | 27.504 |
| R04: "Recently played": user 1038's last 50 streams | READ | 83.907 | 14.253 | 14.067 | 37.409 |
| R05: Playlist page: playlist 501 in order, with every artist on each track | READ | 3.655 | 0.114 | 0.080 | 1.283 |
| R06: "Liked Songs": user 1038's liked tracks, newest first | READ | 1.854 | 0.177 | 0.018 | 0.683 |
| R07: Royalties: streams of 30 seconds or more ("royalty-eligible") per artist in June 2026, top 20 | READ | 81.411 | 37.659 | 34.198 | 51.089 |
| R08: Spotify for Artists: skip rate of each of artist 33's tracks | READ | 57.298 | 38.240 | 36.569 | 44.036 |
| R09: Wrapped 2025: user 1038's top 5 artists by minutes listened | READ | 58.359 | 15.321 | 15.623 | 29.768 |
| R10: Platform analytics: daily streams per platform in June 2026 | READ | 48.110 | 39.669 | 38.407 | 42.062 |
| R11: "Release Radar": 2026 releases by artists user 1038 follows | READ | 2.514 | 0.771 | 0.689 | 1.325 |
| R12: Compliance: explicit tracks streamed by users who were under 18 at the time | READ | 190.771 | 70.990 | 70.119 | 110.627 |
| R13: Curation team: public playlists that have never been played | READ | 141.079 | 61.046 | 56.671 | 86.265 |
| R14: Collaborative playlists: number of different people who added tracks | READ | 34.763 | 19.944 | 19.797 | 24.835 |
| R15: "Fans also like": artists most followed by the followers of artist 33 | READ | 14.058 | 3.698 | 3.608 | 7.121 |
| R16: Artist profiles: distinct listeners of every artist in the last 28 days ("monthly listeners") | READ | 56.223 | 44.583 | 44.651 | 48.486 |
| R17: Growth: free users with 4+ streams in June 2026 (Premium upsell list) | READ | 68.880 | 22.754 | 22.176 | 37.937 |
| R18: Platform analytics: share of offline listening per platform | READ | 66.738 | 59.336 | 62.756 | 62.943 |
| R19: Verified artists report: total streams and the latest stream of every verified artist | READ | 25334.066 | 25115.388 | 24596.035 | 25015.163 |
| R20: Listening patterns: streams per hour of the day per country | READ | 366.833 | 282.438 | 265.273 | 304.848 |
| R21: Rights management: look up a recording by its ISRC code | READ | 0.405 | 0.206 | 0.013 | 0.208 |
| R22: Playlist hygiene: playlists that contain the same track more than once | READ | 57.612 | 50.769 | 59.371 | 55.917 |
| R23: Support console: all streams, newest first, page 8,001 (25 per page) | READ | 131.387 | 96.450 | 91.667 | 106.501 |
| R24: Label report: average track length and explicit share per album type | READ | 32.363 | 29.745 | 29.133 | 30.414 |
| R25: Discovery: tracks released in the last 30 days, ranked by streams | READ | 59.897 | 51.060 | 36.528 | 49.162 |
| W01: Player: log a stream of track 1389 by user 1038 | WRITE | 3.856 | 0.387 | 0.334 | 1.526 |
| W02: Heart button: user 1038 likes track 1389 | WRITE | 2.106 | 0.074 | 0.046 | 0.742 |
| W03: "Add to playlist": append track 1389 to the end of playlist 501 | WRITE | 2.871 | 0.222 | 0.078 | 1.057 |
| W04: Nightly job: recompute every artist's monthly listeners (last 28 days) | WRITE | 209.798 | 105.887 | 93.654 | 136.446 |
| W05: Takedown: the label withdrew the whole album of track 1389, so remove its tracks from every playlist | WRITE | 22.523 | 14.782 | 14.963 | 17.423 |
| **Total (sum of 30 queries)** | | 27391.252 | 26213.893 | 25643.989 | 26416.378 |

Averages use unrounded execution times and are displayed to three decimals; the total is computed before rounding. The sum describes this workload, not a user request’s latency.

## Scan types and interpretation

| Query | Observed scan types | Explanation |
|---|---|---|
| R01 | Seq Scan, Index Scan | Artist filtering, stream-date filtering, joins and top-10 aggregation contribute to the cost. |
| R02 | Index Scan | The constraint index on (album_id, disc_no, track_no) supports album filtering and track ordering. |
| R03 | Seq Scan | Substring ILIKE needs title inspection; ranking matching tracks adds a top-N sort. |
| R04 | Seq Scan, Index Scan | Without a user/date index, finding one user’s recent streams requires scanning and then sorting matching rows. |
| R05 | Index Scan | The playlist-position primary key narrows entries; track and artist key lookups support the joins and artist aggregation. |
| R06 | Index Scan | The liked_tracks key begins with user_id; matching likes can be located before sorting by liked_at. |
| R07 | Seq Scan | Date/duration filtering and grouping artist credits require reading and joining qualifying streams. |
| R08 | Seq Scan, Index Scan | Artist credits and stream records must be joined before computing each track’s play and skip counts. |
| R09 | Seq Scan, Index Scan | User/year filtering precedes artist aggregation; EXTRACT is applied to timestamps and no user/date tuning index exists. |
| R10 | Seq Scan | Casting timestamps to dates requires per-row evaluation before daily/platform aggregation. |
| R11 | Seq Scan, Index Only Scan, Index Scan | The follows key starts with user_id, but albums have no separate artist/release-date index. |
| R12 | Seq Scan | The joins must test explicit status and age at playback, then sort qualifying streams. |
| R13 | Seq Scan | The NOT IN subquery inspects playlist references. NULLs make the original query return no qualifying rows; its runtime is not evidence of correctness. |
| R14 | Seq Scan | Playlist and entry joins plus DISTINCT contributor counts require grouping work. |
| R15 | Seq Scan, Index Only Scan, Index Scan | The follows key begins with user_id, so filtering the first relation by artist_id lacks a matching leading index column. |
| R16 | Seq Scan | Recent streams are joined to credits and DISTINCT users counted per artist; deduplication adds work. |
| R17 | Seq Scan | Stream filtering, free-user joins and per-user aggregation precede the HAVING filter. |
| R18 | Seq Scan | All streams contribute to per-platform totals and offline counts; a broad scan is expected. |
| R19 | Seq Scan | Two correlated subqueries execute for each verified artist, repeatedly reading and joining stream/credit data; inspect their loops counts. |
| R20 | Seq Scan | All streams join users, evaluate the hour and aggregate by country/hour. The last plan records an external merge sort (disk spill). |
| R21 | Index Scan | The unique ISRC constraint index identifies a recording, followed by an album primary-key lookup. |
| R22 | Seq Scan | All playlist entries must be grouped by playlist/track to find repeated tracks; the primary key is playlist/position. |
| R23 | Seq Scan | The query orders streams and discards 200,000 rows before returning 25; inspect the sort and disk-spill details. The last plan records an external merge sort (disk spill). |
| R24 | Seq Scan | All tracks join albums and contribute to per-album-type averages and counts. |
| R25 | Seq Scan, Index Scan | Filtering recent albums, joining their tracks and counting streams requires aggregation; the LEFT JOIN retains tracks with no streams. |
| W01 | No scan node | A one-row insert maintains the primary key and validates foreign keys/checks. A Result node can appear without a scan; trigger timings are part of execution cost. |
| W02 | No scan node | The composite primary key resolves ON CONFLICT. An existing like can make this a no-op; inspect Conflicting Tuples and Tuples Inserted. |
| W03 | Index Scan, Index Only Scan | The playlist-position key supports locating the final position; owner lookup and integrity checks add work. |
| W04 | Index Scan, Seq Scan | This batch update joins the artist/credit/stream tables, counts distinct users, and updates every artist. |
| W05 | Index Scan, Seq Scan | Finding album tracks is supported by the tracks constraint index, but playlist entries have no track_id-leading index. |

## Highest measured costs

- R19: **25015.163 ms** average.
- R20: **304.848 ms** average.
- W04: **136.446 ms** average.
- R12: **110.627 ms** average.
- R23: **106.501 ms** average.

R13 is intentionally unchanged in the baseline despite its NULL-related correctness problem. Its correction and result-difference explanation belong in Phase 4. Rollback preserves logical data, but write execution can still dirty buffers and create physical work; that is part of the measurement context. No results were discarded as outliers.
