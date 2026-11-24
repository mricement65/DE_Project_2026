# Phase 5: Scalability Report

**Team:** T0108 | **Sections:** A,B and E

**Status:** Provisional workspace measurements. Rerun seed and large workloads on the same team laptop before submission.

**Environment:** Uploaded CSV run on 24 November 2026; AMD EPYC 7763; PostgreSQL 17.12 single-user mode; Asia/Kolkata; provisional workspace measurements

## Dataset and method

The ten CSV files uploaded by the user on 24 November 2026 are the sole large-data input for this run. Their names, SHA-256 fingerprints, byte sizes, headers and parsed row counts are recorded in benchmarks/results/large/input_manifest.json. No replacement CSVs were downloaded and no source rows were synthesized for this run. They contain 5,000,000 streams. The uploads were loaded into a new database using the current Phase 2 schema, followed by the Phase 4 indexes and ANALYZE. All PK, FK, UNIQUE, NOT NULL and CHECK constraints remained enabled. Only optimized queries were benchmarked on large data.

Each query has three EXPLAIN (ANALYZE, BUFFERS) executions. Writes run in individual rolled-back transactions. Times below are Execution Time, not client time. All runs, including slow first runs, are retained. Session timezone is Asia/Kolkata. The final seed and final large columns use the same final query versions and scale fixes; initial-large plans preserve the Phase 4 query versions before scale fixes.

The workspace uses a single-user backend, one fresh backend per query with three consecutive runs. It has no normal-server parallel workers/autovacuum and differs from a normal PostgreSQL server on the team laptop. Cache state, background activity and planner behavior may differ. Results are diagnostic evidence, not production SLA guarantees.

## Results: all 30 queries

| Query | Final seed (ms) | Final large (ms) | Growth | Target (ms, strict <) | Meets target? | Scale change / explanation |
|---|---:|---:|---:|---:|---|---|
| R01 | 3.300 | 2.276 | 0.69× | 250 | Yes | Phase 4 SQL retained. |
| R02 | 0.040 | 0.055 | 1.38× | 5 | Yes | Phase 4 SQL retained. |
| R03 | 10.889 | 168.144 | 15.44× | 250 | Yes | Phase 4 SQL retained. |
| R04 | 0.156 | 0.106 | 0.68× | 5 | Yes | Phase 4 SQL retained. |
| R05 | 0.413 | 0.547 | 1.32× | 5 | Yes | Phase 4 SQL retained. |
| R06 | 0.065 | 0.086 | 1.31× | 5 | Yes | Phase 4 SQL retained. |
| R07 | 25.136 | 704.446 | 28.03× | 5000 | Yes | Phase 4 SQL retained. |
| R08 | 1.529 | 4.288 | 2.80× | 250 | Yes | Phase 4 SQL retained. |
| R09 | 0.147 | 0.202 | 1.37× | 250 | Yes | Phase 4 SQL retained. |
| R10 | 8.899 | 183.806 | 20.65× | 5000 | Yes | Phase 4 SQL retained. |
| R11 | 0.102 | 0.332 | 3.27× | 5 | Yes | Phase 4 SQL retained. |
| R12 | 30.026 | 80.695 | 2.69× | 5000 | Yes | Phase 4 SQL retained. |
| R13 | 0.239 | 4.039 | 16.88× | 250 | Yes | Database materialized unplayed-public-playlist report; refresh after stream/playlist changes. Matches corrected NOT EXISTS at refresh time. |
| R14 | 36.592 | 601.011 | 16.42× | 5000 | Yes | Phase 4 SQL retained. |
| R15 | 1.303 | 11.318 | 8.68× | 250 | Yes | Phase 4 SQL retained. |
| R16 | 35.500 | 796.694 | 22.44× | 5000 | Yes | Phase 4 SQL retained. |
| R17 | 12.960 | 310.520 | 23.96× | 5000 | Yes | Phase 4 SQL retained. |
| R18 | 91.599 | 1439.593 | 15.72× | 5000 | Yes | Phase 4 SQL retained. |
| R19 | 77.571 | 790.271 | 10.19× | 5000 | Yes | Filter verified artists before aggregation, preserving zero counts and NULL latest-stream values. |
| R20 | 0.092 | 0.089 | 0.96× | 5000 | Yes | Database materialized hourly-country report; freshness is limited to the last refresh. Refresh cost reported separately. |
| R21 | 0.106 | 0.028 | 0.27× | 5 | Yes | Phase 4 SQL retained. |
| R22 | 0.863 | 8.964 | 10.38× | 250 | Yes | Database materialized duplicate-playlist report; refresh after playlist changes. Refresh cost reported separately. |
| R23 | 34.494 | 36.028 | 1.04× | 5000 | Yes | Phase 4 SQL retained. |
| R24 | 34.290 | 855.022 | 24.94× | 5000 | Yes | Phase 4 SQL retained. |
| R25 | 4.065 | 89.295 | 21.97× | 250 | Yes | Phase 4 SQL retained. |
| W01 | 0.622 | 1.182 | 1.90× | 5 | Yes | Phase 4 SQL retained. |
| W02 | 0.548 | 0.621 | 1.13× | 5 | Yes | Phase 4 SQL retained. |
| W03 | 0.419 | 0.708 | 1.69× | 5 | Yes | Phase 4 SQL retained. |
| W04 | 112.760 | 2800.761 | 24.84× | 3000 | Yes | Phase 4 SQL retained. |
| W05 | 0.085 | 0.331 | 3.91× | 250 | Yes | Phase 4 SQL retained. |

**30/30** final query averages are below their stated target in this run. For materialized reports, this counts snapshot SELECT latency only, not live recomputation; see the freshness qualification and refresh costs below. Exactly equal to a target is a miss because the brief says “under”. CSV averages are rounded to three decimals; target checks use unrounded means.

## Growth analysis

Streams grew exactly 20×. Other table ratios are recorded in counts.csv. Categories below describe observed final-query averages, not predicted complexity:

- **Approximately constant (≤2×):** R01 (0.7×), R02 (1.4×), R04 (0.7×), R05 (1.3×), R06 (1.3×), R09 (1.4×), R20 (1.0×), R21 (0.3×), R23 (1.0×), W01 (1.9×), W02 (1.1×), W03 (1.7×).
- **Sublinear relative to 20× data (>2×, <10×):** R08 (2.8×), R11 (3.3×), R12 (2.7×), R15 (8.7×), W05 (3.9×).
- **Near linear or somewhat sublinear (10×–20×):** R03 (15.4×), R13 (16.9×), R14 (16.4×), R18 (15.7×), R19 (10.2×), R22 (10.4×).
- **More than 20×:** R07 (28.0×), R10 (20.7×), R16 (22.4×), R17 (24.0×), R24 (24.9×), R25 (22.0×), W04 (24.8×).

Selective key lookups can remain nearly constant when they return a fixed number of rows. Whole-table aggregates and joins grow with rows visited and may spill as working sets exceed memory. The large dataset is not uniform duplication, so selectivity, number of returned groups and skew also change. Tiny seed timings and first-run cache effects can inflate ratios; raw buffers, rows, loops and sort methods must support any causal claim. Refreshed materialized views shift computation to refresh time; low query growth does not imply low refresh growth.

## What changed at scale

| Changed query | Initial large (ms) | Final large (ms) | Action |
|---|---:|---:|---|
| R13 | 401.238 | 4.039 | Database materialized unplayed-public-playlist report; refresh after stream/playlist changes. Matches corrected NOT EXISTS at refresh time. |
| R19 | 6553.352 | 790.271 | Filter verified artists before aggregation, preserving zero counts and NULL latest-stream values. |
| R20 | 10096.489 | 0.089 | Database materialized hourly-country report; freshness is limited to the last refresh. Refresh cost reported separately. |
| R22 | 1462.526 | 8.964 | Database materialized duplicate-playlist report; refresh after playlist changes. Refresh cost reported separately. |

Complete run-3 initial/final plans for each changed query appear in [`05_scale_plan_comparisons.md`](05_scale_plan_comparisons.md); all three raw plans are retained. The original Phase 4 file is preserved as `sql/06_optimized_queries.sql`; scale-specific versions are in `sql/06_large_optimized_queries.sql`.

R23 still uses OFFSET 200000 and therefore needs no cursor selection. It keeps the same requested page on each dataset and still pays to skip entries. A future keyset interface must use the previous page’s last timestamp plus a unique tie-breaker, not an invented seed-data cursor.


## Phase 4 SQL on seed versus uploaded large data

This additional table holds the query definitions and Phase 4 indexes constant. Both datasets were freshly measured on the same workspace host. It is the direct scale comparison before the Phase 5 fixes; it does not mix older-host Phase 4 timings with these new measurements.

| Query | Seed, Phase 4 SQL (ms) | Large, Phase 4 SQL (ms) | Growth | Initial target met? |
|---|---:|---:|---:|---|
| R01 | 3.517 | 2.011 | 0.57× | Yes |
| R02 | 0.048 | 0.068 | 1.43× | Yes |
| R03 | 7.952 | 205.660 | 25.86× | Yes |
| R04 | 0.478 | 0.225 | 0.47× | Yes |
| R05 | 0.349 | 0.415 | 1.19× | Yes |
| R06 | 0.075 | 0.085 | 1.13× | Yes |
| R07 | 32.005 | 783.345 | 24.48× | Yes |
| R08 | 1.384 | 4.520 | 3.27× | Yes |
| R09 | 0.374 | 0.891 | 2.39× | Yes |
| R10 | 8.414 | 181.013 | 21.51× | Yes |
| R11 | 0.121 | 0.271 | 2.24× | Yes |
| R12 | 29.754 | 121.592 | 4.09× | Yes |
| R13 | 6.905 | 401.238 | 58.11× | No |
| R14 | 27.811 | 581.149 | 20.90× | Yes |
| R15 | 1.454 | 10.425 | 7.17× | Yes |
| R16 | 38.136 | 1006.341 | 26.39× | Yes |
| R17 | 18.761 | 376.218 | 20.05× | Yes |
| R18 | 85.611 | 1578.288 | 18.44× | Yes |
| R19 | 232.790 | 6553.352 | 28.15× | No |
| R20 | 428.592 | 10096.489 | 23.56× | No |
| R21 | 0.139 | 0.064 | 0.46× | Yes |
| R22 | 83.833 | 1462.526 | 17.45× | No |
| R23 | 43.870 | 34.930 | 0.80× | Yes |
| R24 | 56.902 | 863.179 | 15.17× | Yes |
| R25 | 7.931 | 88.284 | 11.13× | Yes |
| W01 | 0.815 | 0.905 | 1.11× | Yes |
| W02 | 0.830 | 0.674 | 0.81× | Yes |
| W03 | 0.634 | 0.641 | 1.01× | Yes |
| W04 | 137.608 | 2603.297 | 18.92× | Yes |
| W05 | 0.306 | 0.395 | 1.29× | Yes |
## What the measured plans show

The observations below use initial-large run 3 consistently; the raw files retain all three runs. These are measured row counts and plan operations, not assumed complexity.

| Query | Observed scale problem | Tested change and its limit |
|---|---|---|
| R13 | The merge anti-join returns 37,933 playlists, but visits 126,153 public playlists and 2,248,413 entries in the partial stream index. An index-only scan avoids heap fetches yet still performs substantial work. | Materialize the corrected NOT EXISTS report. Reads scan the stored result; refresh pays for the anti-join. A newly played playlist is reflected only after refresh. |
| R19 | The original aggregate reads 5,000,000 streams and 1,554,720 artist credits, forms 5,714,457 joined rows and aggregates all 60,000 artists, although the final report contains only 3,249 verified artists. The artist-credit hash uses 16 batches, with temporary I/O. | Filter verified artists before the stream aggregation. Keep the outer LEFT JOIN and COALESCE so verified artists with no streams still return zero and a NULL last-stream timestamp. This is a live, result-preserving rewrite. |
| R20 | All 5,000,000 streams are joined with 600,000 users. The plan sorts 5,000,000 rows with an external merge using 87,760 kB of disk, then produces only 96 country/hour groups. The join hash also uses four batches. | Materialize the country/hour aggregate. Reads visit 96 stored groups; the large join and grouping move to refresh time. Use a fixed Asia/Kolkata timezone at refresh and a documented freshness policy. |
| R22 | The plan scans 2,400,008 playlist entries and incrementally sorts them by playlist and track. It discards 2,328,008 singleton groups and returns 36,000 duplicate groups. The existing primary-key order is playlist/position, not playlist/track. | Materialize the duplicate-group report. The report retains the requested copies-descending, playlist-ascending order; refresh is required after playlist changes. |

The refresh-based changes are proposals for reporting endpoints with an accepted snapshot policy. They are not equivalent to live recomputation under concurrent writes. For an always-current contract, the initial-large direct-query results remain the applicable measurements and their target misses remain unresolved by these snapshots. Alternatives to evaluate on the team server include expression statistics/hash aggregation for R20, a playlist/track covering index for R22, and different anti-join strategies for R13; no performance is claimed for those untested alternatives.

W04 was below its 3,000 ms target in the initial upload run and was deliberately left unchanged. R23 keeps OFFSET 200000; no fabricated large-data cursor or result-changing LIMIT was introduced. No source-table indexes or server settings were added after the initial Phase 4 setup; the scale DDL adds only reporting relations and their indexes.

The final W04 mean is 2,800.761 ms, leaving only about 6.6% below its 3,000 ms average target; its first run took 3,135.983 ms. Passing the specified three-run mean is not a tail-latency guarantee. Cache state, concurrent load and dead tuples left by rolled-back updates remain reasons to rerun on the actual server.


## Result equivalence and refresh cost

Every changed query was checked against the Phase 4 version on both datasets. Bidirectional EXCEPT ALL compares multiplicities, not just distinct rows. W04 was not rewritten in this upload run; all measured writes used individual BEGIN/ROLLBACK transactions. Ordered-key checks respect unspecified ordering among ties.

| Dataset | Query | Phase 4 rows | Final rows | Differing rows |
|---|---|---:|---:|---:|
| seed_final | R13 | 1891 | 1891 | 0 |
| seed_final | R19 | 334 | 334 | 0 |
| seed_final | R20 | 96 | 96 | 0 |
| seed_final | R22 | 1800 | 1800 | 0 |
| large | R13 | 37933 | 37933 | 0 |
| large | R19 | 3249 | 3249 | 0 |
| large | R20 | 96 | 96 | 0 |
| large | R22 | 36000 | 36000 | 0 |

### Reporting snapshots are a conditional optimization

For selected materialized-report queries, equality holds at the refresh snapshot. The measured SELECT latency excludes refresh work. This does **not** demonstrate the same latency for an always-current report after source writes. If the application requires immediate freshness, retain the direct Phase 4 query and its measured initial-large target result. Do not silently substitute a stale report. No application cache is used.

The following are single observed refresh durations, not three-run averages. Refresh timestamps mark completion; with concurrent source writes they are not guarantees that every write before that timestamp is represented. This isolated run had no concurrent writer. The script uses ordinary blocking REFRESH; schedule it according to the accepted freshness policy and prevent overlaps.

| Dataset | View | Refresh duration (ms) | Refresh completed at |
|---|---|---:|---|
| seed_final | report_country_hour | 233.044 | 2026-11-24 20:49:35.160981+05:30 |
| seed_final | report_playlist_duplicates | 87.450 | 2026-11-24 20:49:35.251117+05:30 |
| seed_final | report_unplayed_playlists | 15.118 | 2026-11-24 20:49:34.922805+05:30 |
| large | report_country_hour | 5296.647 | 2026-11-24 20:49:46.018635+05:30 |
| large | report_playlist_duplicates | 1315.282 | 2026-11-24 20:49:47.338676+05:30 |
| large | report_unplayed_playlists | 389.999 | 2026-11-24 20:49:40.669768+05:30 |


## Storage and loaded row counts

Storage was measured after final benchmarks and before the extra partition prototype. Database size includes catalogs and free space. Table bytes include auxiliary forks and TOAST; index bytes are separate. Materialized reports and their indexes are included. Rolled-back updates leave physical work/bloat even though source values are unchanged.

| Table | Seed rows | Uploaded large rows | Growth |
|---|---:|---:|---:|
| albums | 12,000 | 240,000 | 20.000× |
| artist_follows | 69,901 | 1,399,801 | 20.025× |
| artists | 3,000 | 60,000 | 20.000× |
| liked_tracks | 58,533 | 1,171,457 | 20.014× |
| playlist_tracks | 120,004 | 2,400,008 | 19.999× |
| playlists | 10,000 | 200,000 | 20.000× |
| streams | 250,000 | 5,000,000 | 20.000× |
| track_artists | 77,489 | 1,554,720 | 20.064× |
| tracks | 67,808 | 1,360,381 | 20.062× |
| users | 30,000 | 600,000 | 20.000× |

All ten database counts match the parsed uploaded CSV counts exactly. Loading completed with all constraints enabled.

| Dataset | Database bytes | Application table bytes | Application index bytes |
|---|---:|---:|---:|
| seed_final | 134,062,607 | 50,446,336 | 75,218,944 |
| large | 2,462,499,343 | 972,668,928 | 1,481,449,472 |

| Relation | Seed table bytes | Large table bytes | Seed index bytes | Large index bytes |
|---|---:|---:|---:|---:|
| albums | 1,277,952 | 22,249,472 | 1,253,376 | 23,830,528 |
| artist_follows | 3,129,344 | 62,169,088 | 3,170,304 | 62,947,328 |
| artists | 1,761,280 | 34,996,224 | 172,032 | 2,965,504 |
| liked_tracks | 2,629,632 | 52,207,616 | 3,727,360 | 73,842,688 |
| playlist_tracks | 6,299,648 | 125,755,392 | 4,915,200 | 98,222,080 |
| playlists | 1,146,880 | 13,729,792 | 245,760 | 4,513,792 |
| report_country_hour | 24,576 | 24,576 | 16,384 | 16,384 |
| report_playlist_duplicates | 139,264 | 2,105,344 | 57,344 | 827,392 |
| report_refresh_state | 16,384 | 16,384 | 16,384 | 16,384 |
| report_unplayed_playlists | 147,456 | 2,637,824 | 65,536 | 868,352 |
| streams | 21,143,552 | 418,660,352 | 45,236,224 | 902,717,440 |
| track_artists | 3,555,328 | 70,574,080 | 4,308,992 | 85,655,552 |
| tracks | 5,931,008 | 109,764,608 | 9,076,736 | 161,923,072 |
| users | 3,244,032 | 57,778,176 | 2,957,312 | 63,102,976 |

At 5,000,000 streams, the streams heap plus indexes occupies **1,321,377,792 bytes**, or **264.28 bytes per stream**. A simple 25-million-stream projection is **6.15 GiB** for streams alone. Scaling the entire measured large database fivefold gives about **11.47 GiB**. These are capacity estimates, not measured 100× results. They exclude extra backups, WAL retention, replicas and operational headroom; skew, retention and report cardinality can change the ratios.


## Partition pruning demonstration

The separate prototype contains all **5,000,000** uploaded streams across **19** monthly leaf partitions, including future coverage. The June aggregate produced **0** differing rows between the original and partitioned layouts. The bounded plan visits only **streams_2026_06**; the other **18** partitions do not appear. The unbounded plan visits multiple partitions.

These are single-run plan demonstrations, not three-run workload averages. Main query measurements still use the original unpartitioned spotify.streams. The duplicate prototype storage is excluded from the main storage comparison. The different buffer hit/read profiles also mean the timing difference alone is not a controlled partitioning speedup claim.

### Unpartitioned June aggregate

```text
GroupAggregate  (cost=43210.79..49406.80 rows=275378 width=18) (actual time=134.827..184.255 rows=180 loops=1)
  Group Key: ((started_at)::date), platform
  Buffers: shared hit=8 read=1843, temp read=690 written=693
  ->  Sort  (cost=43210.79..43899.24 rows=275378 width=10) (actual time=134.201..156.356 rows=274725 loops=1)
        Sort Key: ((started_at)::date), platform
        Sort Method: external merge  Disk: 5520kB
        Buffers: shared hit=8 read=1843, temp read=690 written=693
        ->  Index Only Scan using streams_started_idx on streams  (cost=0.43..13621.44 rows=275378 width=10) (actual time=0.021..68.252 rows=274725 loops=1)
              Index Cond: ((started_at >= '2026-06-01 00:00:00+05:30'::timestamp with time zone) AND (started_at < '2026-07-01 00:00:00+05:30'::timestamp with time zone))
              Heap Fetches: 67
              Buffers: shared hit=5 read=1843
Planning:
  Buffers: shared hit=15 read=13
Planning Time: 1.163 ms
Execution Time: 185.278 ms
```

### Partitioned June aggregate

```text
GroupAggregate  (cost=37128.83..43310.15 rows=274725 width=18) (actual time=117.162..171.732 rows=180 loops=1)
  Group Key: ((streams.started_at)::date), streams.platform
  Buffers: shared hit=2806, temp read=690 written=693
  ->  Sort  (cost=37128.83..37815.65 rows=274725 width=10) (actual time=116.428..140.115 rows=274725 loops=1)
        Sort Key: ((streams.started_at)::date), streams.platform
        Sort Method: external merge  Disk: 5520kB
        Buffers: shared hit=2806, temp read=690 written=693
        ->  Seq Scan on streams_2026_06 streams  (cost=0.00..7613.69 rows=274725 width=10) (actual time=0.009..54.559 rows=274725 loops=1)
              Filter: ((started_at >= '2026-06-01 00:00:00+05:30'::timestamp with time zone) AND (started_at < '2026-07-01 00:00:00+05:30'::timestamp with time zone))
              Buffers: shared hit=2806
Planning:
  Buffers: shared hit=25 read=11 dirtied=2
Planning Time: 0.717 ms
Execution Time: 172.548 ms
```

### Unbounded query: no time pruning

```text
HashAggregate  (cost=151060.01..151060.07 rows=6 width=14)
  Group Key: streams.platform
  ->  Append  (cost=0.00..126060.01 rows=5000001 width=6)
        ->  Seq Scan on streams_2025_01 streams_1  (cost=0.00..5737.83 rows=283883 width=6)
        ->  Seq Scan on streams_2025_02 streams_2  (cost=0.00..5182.11 rows=256411 width=6)
        ->  Seq Scan on streams_2025_03 streams_3  (cost=0.00..5737.82 rows=283882 width=6)
        ->  Seq Scan on streams_2025_04 streams_4  (cost=0.00..5552.26 rows=274726 width=6)
        ->  Seq Scan on streams_2025_05 streams_5  (cost=0.00..5737.82 rows=283882 width=6)
        ->  Seq Scan on streams_2025_06 streams_6  (cost=0.00..5553.26 rows=274726 width=6)
        ->  Seq Scan on streams_2025_07 streams_7  (cost=0.00..5737.82 rows=283882 width=6)
        ->  Seq Scan on streams_2025_08 streams_8  (cost=0.00..5737.83 rows=283883 width=6)
        ->  Seq Scan on streams_2025_09 streams_9  (cost=0.00..5552.25 rows=274725 width=6)
        ->  Seq Scan on streams_2025_10 streams_10  (cost=0.00..5737.83 rows=283883 width=6)
        ->  Seq Scan on streams_2025_11 streams_11  (cost=0.00..5553.26 rows=274726 width=6)
        ->  Seq Scan on streams_2025_12 streams_12  (cost=0.00..5737.82 rows=283882 width=6)
        ->  Seq Scan on streams_2026_01 streams_13  (cost=0.00..5737.83 rows=283883 width=6)
        ->  Seq Scan on streams_2026_02 streams_14  (cost=0.00..5183.10 rows=256410 width=6)
        ->  Seq Scan on streams_2026_03 streams_15  (cost=0.00..5737.83 rows=283883 width=6)
        ->  Seq Scan on streams_2026_04 streams_16  (cost=0.00..5552.25 rows=274725 width=6)
        ->  Seq Scan on streams_2026_05 streams_17  (cost=0.00..5737.83 rows=283883 width=6)
        ->  Seq Scan on streams_2026_06 streams_18  (cost=0.00..5553.25 rows=274725 width=6)
        ->  Seq Scan on streams_2026_07 streams_19  (cost=0.00..0.00 rows=1 width=32)
JIT:
  Functions: 40
  Options: Inlining false, Optimization false, Expressions true, Deforming true
```


## Architecture for 100× seed volume

The design horizon is roughly 25 million streams (100 × 250,000), not 100 × the large dataset. Storage estimates below extrapolate measured bytes and are capacity-planning estimates, not latency predictions. Index height, skew, cache capacity and hash/sort spills make runtime nonlinear.

### Partitioning

Use monthly RANGE partitions on `streams.started_at`. R07/R10/R16 and other bounded recent-period queries can prune old months; retention can detach an old partition. R18/R20 and all-time artist reports still need all months, and a user-only history lookup without a date bound may probe every partition. Partitioning is therefore a management and time-filtering tool, not a universal speedup.

`sql/08_partitioning.sql` creates a separate `spotify_scale.streams` prototype with the source columns, row checks, defaults and foreign keys. It creates monthly partitions for the observed data range plus the next month. `sql/12_partition_demo.sql` copies all source streams, runs the same June aggregate on both layouts, checks aggregate equality and shows pruning. The main 30-query results use `spotify.streams`, not this prototype. Prototype timings are demonstrations, not three-run workload averages.

A partitioned PRIMARY KEY/UNIQUE constraint must include every partition-key column. The prototype uses `(stream_id, started_at)` and consequently does **not** enforce global uniqueness of `stream_id` alone. Before a production migration, preserve a separate global ID registry or a rigorously specified global ID allocator, and review foreign-key references and API identifiers. A composite key is not a transparent replacement for the original global key. The current workload has no foreign key referencing streams, but that does not remove the business uniqueness requirement.

The partition DDL intentionally has no DEFAULT partition: unexpected dates fail rather than silently accumulating in an unpruned catch-all. Create upcoming partitions ahead of time, monitor coverage, and use explicit Asia/Kolkata timestamp boundaries. The sample creates only one future month; production scheduling must continue extending it. Detach/archive only after the agreed retention window and any royalty/compliance holds have expired.

### Sharding

If a single tuned server eventually cannot support the measured ingestion/storage load, prefer hashing streams by user_id for evenly distributed ingestion and local Recently Played/Wrapped access. Keep user-related rows colocated where possible. Replicate small catalogue/reference dimensions with controlled versioning; large playlist/like/follow ownership data needs a separate placement decision.

R04 and R09 then target one user's shard. Artist fan statistics (R01/R08/R16/R19), royalties (R07), platform reports (R10/R18/R20), and discovery (R25) require cross-shard partial aggregates or a separately maintained analytical store. Combine SUM/count/max carefully; exact distinct listener counts need globally disjoint user ownership or proper distinct merging. Do not sum arbitrary overlapping distinct counts. Global R23 pagination requires a distributed merge with stable ordering and an explicit cursor contract; it is not solved by local OFFSET.

Sharding by track/artist helps artist reports but scatters one listener's history, and multi-artist tracks complicate ownership. Sharding only by time concentrates current writes and forces all-time user queries across shards. Monthly time partitioning inside user shards can combine local history access with retention. These are future design choices; no distributed system is deployed or benchmarked here.

### Primary, replicas and caches

| Work | Routing / freshness policy |
|---|---|
| W01–W05 | Primary; acknowledge committed writes there. |
| R04/R06 and playlist views immediately after a write | Primary or a replica known to have replayed that commit; preserve read-your-writes. |
| R02/R03/R05/R11/R25 catalogue and discovery views | Replica/cache when the product tolerates brief staleness; invalidate catalogue/takedown changes. |
| R01/R08/R15/R16/R19 artist tools | Replica only with a visible freshness watermark and an agreed lag budget. |
| R07/R12/R21 financial, compliance and rights checks | Primary consistent snapshot by default; a replica is acceptable only when its replay position and reporting cutoff are verified. |
| R10/R13/R14/R17/R18/R20/R22/R24 analytical reports | Replica or database materialized view with an explicit refresh policy. |
| R09 Wrapped | Versioned historical snapshot after the reporting period is finalized. |
| R23 support history | Primary for newest events; replica only if support accepts and sees the lag. |

TTL values should be set by product requirements, not inferred from query execution time. A possible reporting-view cadence is every five minutes, subject to the measured refresh cost and acceptable staleness. A report should display the last successful refresh timestamp. Refreshing a view shifts computation into a scheduled database operation; it does not make that computation free.

### Maintenance and retention

Use normal autovacuum in production; single-user measurements do not model its concurrent resource use. For a 5-million-row mutable table, an illustrative `autovacuum_vacuum_threshold=1000` plus `autovacuum_vacuum_scale_factor=0.01` triggers around 51,000 dead tuples, while `autovacuum_analyze_threshold=500` plus `autovacuum_analyze_scale_factor=0.005` triggers around 25,500 changed tuples. These are starting hypotheses to validate under ingestion/update load, not applied benchmark tuning. Partition-local row counts change these thresholds. Monitor insert-triggered vacuum, transaction age, dead tuples, WAL volume and replica lag as well.

Keep visibility maps healthy for index-only scans and refresh statistics after bulk loads. Explicitly ANALYZE the partitioned parent when its overall distribution changes; leaf autovacuum alone is not a complete parent-statistics policy. Avoid blanket VACUUM FULL on a live ingestion table. Retention should use validated archival exports and partition detach/drop procedures only after the business/legal policy permits removal. This submission deletes no source data.

If report materialized views are introduced, refresh them on a documented schedule, capture refresh duration, and prevent overlapping refresh jobs. Standard REFRESH blocks reads of the view; concurrent refresh requires a suitable unique index and must be evaluated for its extra work. Refresh after batch ingestion and before timing a fresh snapshot; do not compare a stale answer with a current-query answer.


## Conclusion

The implementation is tested against the uploaded 5-million-stream dataset, but readiness is not unconditional: 0 query target(s) remain unmet in this workspace run, and laptop/server verification is still required. Accepting snapshot freshness is a prerequisite for using materialized-report target passes; otherwise the direct-query misses still apply. Preserve correctness proofs, explicit refresh policies, partition-key uniqueness decisions, and complete before/after evidence. Sharding and replicas are design proposals, not deployed or measured systems.
