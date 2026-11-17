# Phase 1: Problem Understanding

**Team:** T0108 | **Sections:** A,B and E

Spotify India's database has no documented schema; only data exports remain. Our goal is to understand the business needs, rebuild a reliable schema, measure the supplied workload, and improve performance without losing correctness as stream volume grows 20×.

| Problem | Business need and affected stakeholders | Classification | Queries |
|---|---|---|---|
| P1 | Listeners need artist, album, and playlist pages to open quickly, including popular content. | Customer-facing / real-time | R01, R02, R05 |
| P2 | Free and Premium listeners need responsive search, listening history, and Liked Songs, with prompt stream logging and saving of likes. | Customer-facing / real-time | R03, R04, R06, W01, W02 |
| P3 | Artists need timely skip rates, audience overlap, and listener counts to understand engagement. The nightly listener-count refresh supports these tools. | Real-time artist tools; reporting / batch refresh | R08, R15, R16, W04 |
| P4 | Finance and labels need accurate royalty-eligible stream counts and catalogue reports. Rights holders also need quick ISRC lookups and playlist removal of withdrawn content. | Reporting / analytics; interactive rights operations | R07, R21, R24, W05 |
| P5 | Curators need a trustworthy list of public playlists with no plays. The consistently empty report must be investigated for correctness. | Reporting / analytics | R13 |
| P6 | Listeners need timely Wrapped summaries, releases from followed artists, and discovery rankings; the personalization team needs efficient supporting jobs. | Customer-facing / interactive delivery; reporting / analytics for preparation | R09, R11, R25 |
| P7 | Compliance staff need to identify explicit recordings streamed by listeners who were under 18 when playback occurred. | Reporting / analytics | R12 |
| P8 | Playlist owners and collaborators need fast track additions. The playlist team needs contributor statistics and duplicate detection for maintenance. | Real-time additions; reporting / analytics for statistics and hygiene | R14, R22, W03 |
| P9 | Growth, analytics, and support teams need usable upsell lists, platform and artist reports, listening patterns, and stream-history access despite 20× growth. | Reporting / analytics | R10, R17, R18, R19, R20, R23 |

## Assumptions

- A stream is royalty-eligible at **30,000 ms or more**; calculating monetary payouts is outside this workload.
- A minor is a listener under 18 **at the time of the stream**, not at report execution time. Timestamp interpretation must be consistent.
- Performance matters for both free and paying listeners; subscription-specific filtering applies only where the workload requires it.
- Mixed problem groups contain interactive actions and background reports, so performance targets will follow each query's use rather than one target for the whole group.
- An empty report is not proof that no matching data exists. Correctness will be checked before accepting results; any required bug fix will be documented separately from equivalent optimizations.
- The supplied data and queries define this project's scope. Baseline queries remain unchanged, and performance claims will use measured execution plans.