# Phase 4: Optimization Report

**Team:** T0108 | **Sections:** A,B and E

**Measurement context:** PROVISIONAL workspace comparison, PostgreSQL 17.12 single-user backend on AMD EPYC 7763; both phases measured in this task

**Provisional workspace evidence — not the MacBook submission result.** Both sides were measured during this Phase 4 task on the same current workspace host, PostgreSQL 17.12 single-user backend. The older Phase 3 workspace measurements used a different CPU and are not used in this comparison. Single-user mode lacks normal-server parallel workers and background processes. A new backend is opened per query, with three consecutive runs within it; shared buffers reset across queries while OS caching may persist. Rerun both baseline and optimized phases on the team laptop.

## Method

Each unchanged original query was measured three times before tuning, and each optimized query three times after tuning, with EXPLAIN (ANALYZE, BUFFERS). Writes ran inside separate BEGIN/ROLLBACK transactions. Averages include every run. The Phase 4 example in README uses five runs, but the stated common method and large-data targets use three; this report uses three consistently for both sides. Confirm a different instructor requirement before changing the run count.

Only 11 added indexes, the pg_trgm extension, four query edits, and VACUUM/ANALYZE were applied. No server tuning, scan disabling, external result cache, data deletion, or summary cache was used. VACUUM improves visibility maps and is part of the measured optimization package, so improvements cannot be attributed to indexes alone.

Before evidence: `benchmarks/results/phase4_before/`. After evidence: `benchmarks/results/optimized/`. Raw per-query files contain all three plans; summary.csv records mean, median, min, max and final-run scan nodes.

## Per-query comparison

| Query | Before (ms) | Baseline problem | Optimization | After (ms) | Improvement | Same result? |
|---|---:|---|---|---:|---:|---|
| R01 | 77.074 | Baseline stream and credit scans for one artist. | Artist/track lookup and track/time stream indexes. | 5.144 | 93.33% | SQL unchanged; see tie caveat |
| R02 | 0.298 | Already selective via constraint index. | No rewrite or new index needed; existing album/disc/track UNIQUE index. | 0.103 | 65.44% | SQL unchanged; see tie caveat |
| R03 | 108.711 | Leading-wildcard title search scans tracks. | GIN trigram title index for substring ILIKE. | 17.614 | 83.80% | SQL unchanged; see tie caveat |
| R04 | 51.589 | User filter without user/time access path. | User/time covering stream index. | 1.034 | 98.00% | SQL unchanged; see tie caveat |
| R05 | 2.315 | Small indexed playlist lookup; limited tuning need. | Unchanged; existing playlist, track and artist keys. | 1.110 | 52.07% | SQL unchanged; see tie caveat |
| R06 | 0.768 | Liked-at sort after user-key lookup. | User/liked_at covering index. | 0.072 | 90.67% | SQL unchanged; see tie caveat |
| R07 | 99.955 | Stream filtering and artist aggregation. | Time-leading covering stream index; no rewrite. | 59.413 | 40.56% | SQL unchanged; see tie caveat |
| R08 | 110.253 | Stream/credit scans before per-track aggregation. | Artist/track and track/time indexes. | 2.378 | 97.84% | SQL unchanged; see tie caveat |
| R09 | 56.704 | EXTRACT on timestamp plus user filtering. | Half-open year range; user/time covering index. | 0.537 | 99.05% | EXCEPT ALL + order-key checks |
| R10 | 64.259 | Timestamp-to-date cast in filter. | Half-open month range; time-leading covering index. | 14.414 | 77.57% | EXCEPT ALL + order-key checks |
| R11 | 3.112 | Albums lack artist-leading lookup. | Artist/release-date album index. | 0.134 | 95.69% | SQL unchanged; see tie caveat |
| R12 | 174.892 | Age and explicit checks across joins. | No rewrite; planner may use the global timestamp index to serve newest-first limit. | 47.557 | 72.81% | SQL unchanged; see tie caveat |
| R13 | 166.036 | NULL-sensitive NOT IN gives wrong empty result. | NOT EXISTS correctness fix; partial playlist-reference index. | 14.092 | 91.51% | Intentional correction |
| R14 | 63.217 | Join and distinct contributor aggregation. | Unchanged; broad aggregation still required. | 33.806 | 46.52% | SQL unchanged; see tie caveat |
| R15 | 17.324 | Follows PK leads with user rather than artist. | Artist/user reverse lookup index. | 3.120 | 81.99% | SQL unchanged; see tie caveat |
| R16 | 97.907 | Distinct-listener aggregation. | Time-leading stream index and artist/track index available. | 42.714 | 56.37% | SQL unchanged; see tie caveat |
| R17 | 40.955 | Date filter and user aggregation. | Time-leading stream index available; unchanged aggregation. | 13.123 | 67.96% | SQL unchanged; see tie caveat |
| R18 | 102.702 | Full-stream aggregate. | Unchanged; all streams contribute to offline-share totals. | 109.708 | -6.82% | SQL unchanged; see tie caveat |
| R19 | 39349.515 | Two correlated subqueries repeat per verified artist. | Aggregate artist stream statistics once and LEFT JOIN to artists. | 261.468 | 99.34% | EXCEPT ALL + order-key checks |
| R20 | 600.215 | Full-stream join and hour extraction. | Unchanged; all streams must contribute to country/hour totals. | 494.412 | 17.63% | SQL unchanged; see tie caveat |
| R21 | 0.320 | Already selective using ISRC UNIQUE index. | Unchanged; existing unique ISRC and album PK indexes. | 0.035 | 88.97% | SQL unchanged; see tie caveat |
| R22 | 88.043 | Playlist/track grouping differs from PK order. | No added index retained; planner favors full scan and hash aggregation. | 87.856 | 0.21% | SQL unchanged; see tie caveat |
| R23 | 180.939 | Sort and skip 200,000 rows. | Timestamp covering index; retain OFFSET and original ordering semantics. | 40.310 | 77.72% | SQL unchanged; see tie caveat |
| R24 | 52.061 | Full-track join/aggregate. | Unchanged; full catalogue aggregation remains necessary. | 43.909 | 15.66% | SQL unchanged; see tie caveat |
| R25 | 86.818 | Recent-album filtering and stream counting. | Release-date and track/time indexes; retain LEFT JOIN and zero-stream tracks. | 2.789 | 96.79% | SQL unchanged; see tie caveat |
| W01 | 1.719 | Insert integrity and index-maintenance cost. | Maintain four added stream indexes (partial playlist index only for applicable rows). | 1.200 | 30.21% | SQL unchanged; see tie caveat |
| W02 | 0.868 | Unique-conflict handling; may be a no-op. | Maintain added user/liked_at index when a like is actually inserted. | 0.925 | -6.57% | SQL unchanged; see tie caveat |
| W03 | 1.654 | Append lookup and index maintenance. | Maintain the added track-leading playlist-entry index on insert. | 0.697 | 57.86% | SQL unchanged; see tie caveat |
| W04 | 255.717 | Full artist-count refresh. | Artist/track and track/time indexes available; batch update unchanged. | 154.614 | 39.54% | SQL unchanged; see tie caveat |
| W05 | 33.507 | Playlist entries lack track-leading lookup. | Track-leading playlist-entry index and existing album track key. | 0.359 | 98.93% | SQL unchanged; see tie caveat |
| **Total** | **41889.449** | | | **1454.649** | **96.53%** | Includes corrected R13 |

Improvement = (before − after) / before × 100. Negative means slower. Percentages use unrounded means; displayed values have three decimals. The total includes the deliberate R13 result change and is a descriptive workload sum, not an entirely equivalent-work speedup.

## Correctness and ordering

R09 replaces EXTRACT(YEAR) with a half-open timestamp range; R10 replaces the date cast in the filter with a half-open month range. Boundaries use the same session timezone as the original expressions. Benchmarking and checks explicitly use Asia/Kolkata. R19 aggregates the same track-credit/stream join once, then LEFT JOINs it to verified artists; COALESCE preserves zero counts and MAX remains NULL when an artist has no streams.

Run `sql/07_correctness_checks.sql` in a repeatable-read transaction. It compares counts and bidirectional EXCEPT ALL differences for R09/R10/R19, then compares the ordered sequence of ORDER BY key values. Raw output is saved in the optimized folder as correctness.txt. A zero difference proves matching row multiplicities on this dataset, not universal equivalence. The report’s semantic reasoning supplies the general justification.

**Tie caveat:** several original ORDER BY clauses do not fully break ties, including LIMIT queries. Neither the original SQL nor an index guarantees a particular order within a tied group. The checks preserve declared sort-key order; arbitrary order among equal keys is not claimed. Rows at a LIMIT boundary can vary when tied; assess such a failure explicitly rather than weakening an equality check. No extra tie-breakers were silently added. R23 retains OFFSET 200000, so it still requests the same fixed page; keyset pagination would need an explicit cursor/API change.

### R13: intentional result correction

Non-playlist streams have NULL playlist_id values. For an unplayed playlist, NOT IN over a set containing NULL evaluates to UNKNOWN, which WHERE rejects. NOT EXISTS checks for a matching playlist reference and ignores unrelated NULLs. This is intentionally not equivalent to the broken original. The correctness script independently checks the corrected result against a LEFT JOIN anti-join.

### Measured correctness results (workspace seed data)

| Query | Original rows | Optimized rows | EXCEPT ALL differences | Sort-key sequence |
|---|---:|---:|---:|---|
| R09 | 4 | 4 | 0 | Match |
| R10 | 180 | 180 | 0 | Match |
| R19 | 334 | 334 | 0 | Match |

R13: original **0** rows; corrected **1891** rows. The stream subquery contains **137386** NULL playlist IDs. Corrected NOT EXISTS and independent LEFT JOIN anti-join have **0** differing rows. This is the documented exception to unchanged results.

Data preservation: all 10 tables have matching row counts and ordered full-row MD5 fingerprints before tuning and after benchmark rollbacks. Raw checksums are in data_before.txt and data_after.txt. These checks concern logical rows; index/VACUUM operations and rolled-back writes can change physical storage.


## Write overhead

| Write | Before (ms) | After (ms) | Change (ms) | Change (%) |
|---|---:|---:|---:|---:|
| W01 | 1.719 | 1.200 | -0.519 | -30.21% |
| W02 | 0.868 | 0.925 | +0.057 | +6.57% |
| W03 | 1.654 | 0.697 | -0.957 | -57.86% |
| W04 | 255.717 | 154.614 | -101.103 | -39.54% |
| W05 | 33.507 | 0.359 | -33.148 | -98.93% |

W01 may maintain three additional stream indexes even for a non-playlist insert; playlist-source inserts also maintain the partial index. W02 updates its extra index only if a row is inserted; inspect Conflicting Tuples before interpreting a no-op. W03 adds one index update per playlist entry. W05 can benefit from targeted entry lookup but must remove entries from every applicable index. W04 does not change indexed artist columns but still performs a batch update.

These three-run measurements are noisy, especially for sub-millisecond operations and first-run cache effects. A faster observed write does not mean indexes have no maintenance cost. Acceptability is provisional: judge the added latency and storage against real read/write frequency and Phase 5 targets on the team laptop; this report does not establish large-data SLA compliance.

## Index storage

Each added index is justified in sql/05_indexes.sql. `sql/09_index_storage.sql` records exact index bytes, heap bytes and percentage of heap for each index. Heap size excludes other indexes and TOAST; percentages are not percentages of total database size.

W02 inserted one row with zero conflicts in each of the three runs (then rolled back), so these runs exercised the new index maintenance rather than a conflict no-op. Its small observed increase is provisionally acceptable for this seed workload, but must be reassessed under realistic write volume and on the large dataset.

R20 retains the same broad join, disk-spilling sort and aggregate plan in these workspace measurements. Its measured improvement is not evidence of a targeted algorithmic gain; cache state and host variability can affect even unchanged plans.

| Table | Added index | Index bytes | Heap bytes | % of heap |
|---|---|---:|---:|---:|
| albums | albums_artist_release_idx | 286720 | 1245184 | 23.03 |
| albums | albums_release_idx | 286720 | 1245184 | 23.03 |
| artist_follows | artist_follows_artist_user_idx | 1581056 | 3096576 | 51.06 |
| liked_tracks | liked_tracks_user_liked_idx | 2400256 | 2596864 | 92.43 |
| playlist_tracks | playlist_tracks_track_idx | 2220032 | 6266880 | 35.42 |
| streams | streams_playlist_idx | 950272 | 21102592 | 4.50 |
| streams | streams_started_idx | 13811712 | 21102592 | 65.45 |
| streams | streams_track_started_idx | 12419072 | 21102592 | 58.85 |
| streams | streams_user_started_idx | 12427264 | 21102592 | 58.89 |
| track_artists | track_artists_artist_track_idx | 2555904 | 3514368 | 72.73 |
| tracks | tracks_title_trgm_idx | 2260992 | 5898240 | 38.33 |

Total added-index bytes: **51,200,000** across **11** indexes. Index/storage measurements were captured after the optimized workload, including its rolled-back writes.

## Limits, regressions and next steps

- **R18** was slower by **7.007 ms**. Unchanged; all streams contribute to offline-share totals. Inspect the saved plans and repeat on the laptop before attributing this solely to tuning.
- **W02** was slower by **0.057 ms**. Maintain added user/liked_at index when a like is actually inserted. Inspect the saved plans and repeat on the laptop before attributing this solely to tuning.

R18, R20 and R24 still read broad portions of the data because every relevant row contributes to their aggregates. R14 and W04 also retain substantial aggregation work. Indexes cannot eliminate that work without introducing refreshed summary data, which this implementation does not use. R23 still pays for walking past 200,000 entries even when sorting/heap reads are reduced. Do not add more indexes merely to make every query appear tuned.

The top five improvements by absolute mean milliseconds saved (excluding the deliberate R13 correction) have complete run-3 before/after plans in [`04_plan_comparisons.md`](04_plan_comparisons.md). All three runs remain in raw files; run 3 is shown consistently rather than selecting each query’s fastest plan.
