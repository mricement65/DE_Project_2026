# Phase 5: Scalability Report

**Team:** T0108 | **Sections:** A,B and E

**Status:** Provisional workspace measurements. Rerun seed and large workloads on the same team laptop before submission.

**Environment:** Isolated workspace; AMD EPYC 7763; PostgreSQL 17.12 single-user mode; Asia/Kolkata; provisional, not a team-laptop server run

## Dataset and method

The faculty release at https://github.com/edusatyaki/DBMS-Spotify-Music-Streaming/releases/tag/large-data supplied the actual large_data.zip. SHA-256: `04159f37b0276fdf5d63c2781f90f8d339be1ad0f1ad6bbafb9c0caa11b02dbd`. No synthetic expansion or estimated query times were substituted. The large schema was loaded in a separate database using the same Phase 2 schema, followed by the Phase 4 indexes and ANALYZE. Only optimized queries were benchmarked on large data.

Each query has three EXPLAIN (ANALYZE, BUFFERS) executions. Writes run in individual rolled-back transactions. Times below are Execution Time, not client time. All runs, including slow first runs, are retained. Session timezone is Asia/Kolkata. The final seed and final large columns use the same final query versions and scale fixes; initial-large plans preserve the Phase 4 query versions before scale fixes.

The workspace uses a single-user backend, one fresh backend per query with three consecutive runs. It has no normal-server parallel workers/autovacuum and differs from the team MacBook. Cache state, background activity and planner behavior may differ. Results are diagnostic evidence, not production SLA guarantees.

## Results: all 30 queries

| Query | Final seed (ms) | Final large (ms) | Growth | Target (ms, strict <) | Meets target? | Scale change / explanation |
|---|---:|---:|---:|---:|---|---|
| R01 | 3.757 | 1.973 | 0.53× | 250 | Yes | Phase 4 SQL retained. |
| R02 | 0.054 | 0.039 | 0.72× | 5 | Yes | Phase 4 SQL retained. |
| R03 | 10.808 | 188.066 | 17.40× | 250 | Yes | Phase 4 SQL retained. |
| R04 | 0.122 | 0.118 | 0.97× | 5 | Yes | Phase 4 SQL retained. |
| R05 | 0.370 | 0.435 | 1.18× | 5 | Yes | Phase 4 SQL retained. |
| R06 | 0.082 | 0.121 | 1.47× | 5 | Yes | Phase 4 SQL retained. |
| R07 | 30.103 | 862.266 | 28.64× | 5000 | Yes | Phase 4 SQL retained. |
| R08 | 1.722 | 4.243 | 2.46× | 250 | Yes | Phase 4 SQL retained. |
| R09 | 0.162 | 0.264 | 1.62× | 250 | Yes | Phase 4 SQL retained. |
| R10 | 10.616 | 196.059 | 18.47× | 5000 | Yes | Phase 4 SQL retained. |
| R11 | 0.453 | 0.386 | 0.85× | 5 | Yes | Phase 4 SQL retained. |
| R12 | 31.464 | 93.719 | 2.98× | 5000 | Yes | Phase 4 SQL retained. |
| R13 | 0.212 | 4.474 | 21.10× | 250 | Yes | Database materialized unplayed-public-playlist report; refresh after stream/playlist changes. Matches corrected NOT EXISTS at refresh time. |
| R14 | 30.253 | 550.266 | 18.19× | 5000 | Yes | Phase 4 SQL retained. |
| R15 | 2.194 | 17.176 | 7.83× | 250 | Yes | Phase 4 SQL retained. |
| R16 | 35.219 | 912.117 | 25.90× | 5000 | Yes | Phase 4 SQL retained. |
| R17 | 10.650 | 395.878 | 37.17× | 5000 | Yes | Phase 4 SQL retained. |
| R18 | 77.559 | 1550.449 | 19.99× | 5000 | Yes | Phase 4 SQL retained. |
| R19 | 65.471 | 860.525 | 13.14× | 5000 | Yes | Filter verified artists before aggregation, preserving zero counts and NULL latest-stream values. |
| R20 | 0.084 | 0.121 | 1.44× | 5000 | Yes | Database materialized hourly-country report; freshness is limited to the last refresh. Refresh cost reported separately. |
| R21 | 0.141 | 0.047 | 0.33× | 5 | Yes | Phase 4 SQL retained. |
| R22 | 0.958 | 11.539 | 12.05× | 250 | Yes | Database materialized duplicate-playlist report; refresh after playlist changes. Refresh cost reported separately. |
| R23 | 49.537 | 36.671 | 0.74× | 5000 | Yes | Phase 4 SQL retained. |
| R24 | 55.291 | 1001.725 | 18.12× | 5000 | Yes | Phase 4 SQL retained. |
| R25 | 3.457 | 106.254 | 30.74× | 250 | Yes | Phase 4 SQL retained. |
| W01 | 0.920 | 0.636 | 0.69× | 5 | Yes | Phase 4 SQL retained. |
| W02 | 0.743 | 0.507 | 0.68× | 5 | Yes | Phase 4 SQL retained. |
| W03 | 0.488 | 0.543 | 1.11× | 5 | Yes | Phase 4 SQL retained. |
| W04 | 71.895 | 1745.131 | 24.27× | 3000 | Yes | Aggregate recent stream listeners first, then update every artist including zero-listener artists. |
| W05 | 0.101 | 0.610 | 6.06× | 250 | Yes | Phase 4 SQL retained. |

**30/30** final queries meet their stated target in this run. Exactly equal to a target is a miss because the brief says “under”. CSV averages are rounded to three decimals; target checks use unrounded means.

## Growth analysis

Streams grew exactly 20×. Other table ratios are recorded in counts.csv. Categories below describe observed final-query averages, not predicted complexity:

- **Approximately constant (≤2×):** R01 (0.5×), R02 (0.7×), R04 (1.0×), R05 (1.2×), R06 (1.5×), R09 (1.6×), R11 (0.9×), R20 (1.4×), R21 (0.3×), R23 (0.7×), W01 (0.7×), W02 (0.7×), W03 (1.1×).
- **Sublinear relative to 20× data (>2×, <10×):** R08 (2.5×), R12 (3.0×), R15 (7.8×), W05 (6.1×).
- **Near linear or somewhat sublinear (10×–20×):** R03 (17.4×), R10 (18.5×), R14 (18.2×), R18 (20.0×), R19 (13.1×), R22 (12.0×), R24 (18.1×).
- **More than 20×:** R07 (28.6×), R13 (21.1×), R16 (25.9×), R17 (37.2×), R25 (30.7×), W04 (24.3×).

Selective key lookups can remain nearly constant when they return a fixed number of rows. Whole-table aggregates and joins grow with rows visited and may spill as working sets exceed memory. The large dataset is not uniform duplication, so selectivity, number of returned groups and skew also change. Tiny seed timings and first-run cache effects can inflate ratios; raw buffers, rows, loops and sort methods must support any causal claim. Refreshed materialized views shift computation to refresh time; low query growth does not imply low refresh growth.

## What changed at scale

| Changed query | Initial large (ms) | Final large (ms) | Action |
|---|---:|---:|---|
| R13 | 387.876 | 4.474 | Database materialized unplayed-public-playlist report; refresh after stream/playlist changes. Matches corrected NOT EXISTS at refresh time. |
| R19 | 6866.800 | 860.525 | Filter verified artists before aggregation, preserving zero counts and NULL latest-stream values. |
| R20 | 10564.045 | 0.121 | Database materialized hourly-country report; freshness is limited to the last refresh. Refresh cost reported separately. |
| R22 | 1696.415 | 11.539 | Database materialized duplicate-playlist report; refresh after playlist changes. Refresh cost reported separately. |
| W04 | 3195.427 | 1745.131 | Aggregate recent stream listeners first, then update every artist including zero-listener artists. |

Complete run-3 initial/final plans for each changed query appear in [`05_scale_plan_comparisons.md`](05_scale_plan_comparisons.md); all three raw plans are retained. The original Phase 4 file is preserved as `sql/06_optimized_queries.sql`; scale-specific versions are in `sql/06_large_optimized_queries.sql`.

R23 still uses OFFSET 200000 and therefore needs no cursor selection. It keeps the same requested page on each dataset and still pays to skip entries. A future keyset interface must use the previous page’s last timestamp plus a unique tie-breaker, not an invented seed-data cursor.

## Correctness and refresh evidence

Comparisons were run after refreshing reports and with no concurrent source writes. Each result comparison used row counts and bidirectional EXCEPT ALL; declared sort-key sequences were checked where applicable. Tied rows retain the original SQL’s unspecified tie order.

| Dataset | Query | Phase 4 rows | Final rows | Differing rows | Order keys |
|---|---|---:|---:|---:|---|
| seed_final | R13 | 1891 | 1891 | 0 | Not specified / update |
| seed_final | R19 | 334 | 334 | 0 | Match |
| seed_final | R20 | 96 | 96 | 0 | Match |
| seed_final | R22 | 1800 | 1800 | 0 | Match |
| seed_final | W04 | 3000 | 3000 | 0 | Not specified / update |
| large | R13 | 37933 | 37933 | 0 | Not specified / update |
| large | R19 | 3249 | 3249 | 0 | Match |
| large | R20 | 96 | 96 | 0 | Match |
| large | R22 | 36000 | 36000 | 0 | Match |
| large | W04 | 60000 | 60000 | 0 | Not specified / update |

For W04, the final UPDATE ran in a rolled-back transaction; RETURNING values were compared to the original monthly-listener calculation for every artist. These checks prove equality on the tested datasets at the captured snapshot, not perpetual equivalence of materialized views after later writes.

### Refresh cost (excluded from timed report SELECTs)

| Dataset | View | Refresh elapsed (ms) | Refresh completed |
|---|---|---:|---|
| seed_final | report_country_hour | 325.506 | 2026-11-23 20:42:18.147843+05:30 |
| seed_final | report_playlist_duplicates | 245.993 | 2026-11-23 20:42:18.397472+05:30 |
| seed_final | report_unplayed_playlists | 47.255 | 2026-11-23 20:42:17.815839+05:30 |
| large | report_country_hour | 5218.726 | 2026-11-23 20:42:29.693892+05:30 |
| large | report_playlist_duplicates | 1621.406 | 2026-11-23 20:42:31.31854+05:30 |
| large | report_unplayed_playlists | 377.380 | 2026-11-23 20:42:24.416762+05:30 |

Refresh timings are measured inside PostgreSQL with clock_timestamp around REFRESH MATERIALIZED VIEW. They are one refresh per view, not three-run query averages. The reported initial refresh populates an empty view and includes its index maintenance. Subsequent refreshes may differ. Standard refresh blocks readers; a unique index exists to permit evaluation of concurrent refresh later. No external result cache is used.

R13/R20/R22 now have a reporting-snapshot freshness contract. They are not suitable for a caller requiring immediate visibility of every new stream or playlist edit unless refreshed first. If that freshness tradeoff is unacceptable, keep the direct Phase 4 queries and report their target misses.


## Storage and actual row counts

Sizes were measured after final benchmarks and before creating the extra partitioned streams copy. Database bytes include catalogs/free space; table_bytes includes TOAST and auxiliary forks, and index_bytes is reported separately. Materialized views and their indexes are included. Rolled-back writes can leave physical work even though source rows are unchanged.

| Table | Seed rows | Large rows | Row growth |
|---|---:|---:|---:|
| artists | 3,000 | 60,000 | 20.000× |
| albums | 12,000 | 240,000 | 20.000× |
| tracks | 67,808 | 1,360,381 | 20.062× |
| track_artists | 77,489 | 1,554,720 | 20.064× |
| users | 30,000 | 600,000 | 20.000× |
| playlists | 10,000 | 200,000 | 20.000× |
| playlist_tracks | 120,004 | 2,400,008 | 19.999× |
| streams | 250,000 | 5,000,000 | 20.000× |
| liked_tracks | 58,533 | 1,171,457 | 20.014× |
| artist_follows | 69,901 | 1,399,801 | 20.025× |

| Dataset | Database bytes | Application table bytes | Application index bytes |
|---|---:|---:|---:|
| seed_final | 134,332,943 | 50,692,096 | 75,218,944 |
| large | 2,467,643,919 | 977,657,856 | 1,481,580,544 |

| Relation | Seed table bytes | Large table bytes | Seed index bytes | Large index bytes |
|---|---:|---:|---:|---:|
| albums | 1,277,952 | 22,249,472 | 1,253,376 | 23,830,528 |
| artist_follows | 3,129,344 | 62,169,088 | 3,170,304 | 62,947,328 |
| artists | 2,007,040 | 39,985,152 | 172,032 | 3,096,576 |
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

Observed large streams heap+auxiliary+indexes: **1,321,377,792 bytes** for 5,000,000 streams, or approximately **264.3 bytes/stream**. A simple 5× extrapolation to 25,000,000 streams is **6,606,888,960 bytes** for this relation and its indexes alone. Budget separately for other relations, WAL, backups, temporary sort/hash files, replicas, maintenance headroom and the temporary duplicate during a partition migration. This linear byte estimate is not a latency forecast.


## Partition pruning demonstration

The separate prototype contains all **5,000,000** source streams across **19** monthly leaf partitions (including future coverage). The June aggregate has **0** differing result rows between the unpartitioned and partitioned layouts. The bounded partitioned plan references only **streams_2026_06**; the remaining **18** partitions are absent from the plan. The unbounded EXPLAIN in the raw evidence visits multiple partitions, as expected.

These are single-run pruning demonstrations, not three-run workload averages. Main large benchmarks still use the unpartitioned spotify.streams. The prototype’s duplicate storage is excluded from the main storage comparison above.

### Unpartitioned June aggregate

```text
GroupAggregate  (cost=43621.68..49873.87 rows=277875 width=18) (actual time=179.888..228.685 rows=180 loops=1)
  Group Key: ((started_at)::date), platform
  Buffers: shared hit=8 read=1843, temp read=690 written=693
  ->  Sort  (cost=43621.68..44316.37 rows=277875 width=10) (actual time=179.344..201.937 rows=274725 loops=1)
        Sort Key: ((started_at)::date), platform
        Sort Method: external merge  Disk: 5520kB
        Buffers: shared hit=8 read=1843, temp read=690 written=693
        ->  Index Only Scan using streams_started_idx on streams  (cost=0.43..13746.62 rows=277875 width=10) (actual time=0.015..90.255 rows=274725 loops=1)
              Index Cond: ((started_at >= '2026-06-01 00:00:00+05:30'::timestamp with time zone) AND (started_at < '2026-07-01 00:00:00+05:30'::timestamp with time zone))
              Heap Fetches: 67
              Buffers: shared hit=5 read=1843
Planning:
  Buffers: shared hit=15 read=13
Planning Time: 1.669 ms
Execution Time: 229.301 ms
```

### Partitioned June aggregate

```text
GroupAggregate  (cost=37128.83..43310.15 rows=274725 width=18) (actual time=125.245..175.364 rows=180 loops=1)
  Group Key: ((streams.started_at)::date), streams.platform
  Buffers: shared hit=2806, temp read=690 written=693
  ->  Sort  (cost=37128.83..37815.65 rows=274725 width=10) (actual time=124.616..146.277 rows=274725 loops=1)
        Sort Key: ((streams.started_at)::date), streams.platform
        Sort Method: external merge  Disk: 5520kB
        Buffers: shared hit=2806, temp read=690 written=693
        ->  Seq Scan on streams_2026_06 streams  (cost=0.00..7613.69 rows=274725 width=10) (actual time=0.010..58.663 rows=274725 loops=1)
              Filter: ((started_at >= '2026-06-01 00:00:00+05:30'::timestamp with time zone) AND (started_at < '2026-07-01 00:00:00+05:30'::timestamp with time zone))
              Buffers: shared hit=2806
Planning:
  Buffers: shared hit=26 read=12 dirtied=2
Planning Time: 0.449 ms
Execution Time: 175.834 ms
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

The implementation is tested against the real 5-million-stream release, but readiness is not unconditional: 0 query target(s) remain unmet in this workspace run, and laptop/server verification is still required. Preserve correctness proofs, refresh freshness guarantees, partition-key uniqueness decisions, and complete before/after evidence. Sharding and replicas are design proposals, not deployed or measured systems.
