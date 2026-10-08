# NanoGPT speedrun comparability audit

Audit date: 2026-10-02. Scope: the pinned `README.upstream.md`, source manifest and tree at upstream commit `4ea6b937337a4889b8cfe3f38a93d120048d8f71`, plus primary GitHub PR discussions. This is a source/method audit, not an independent GPU reproduction. No fitted curves were changed by this audit.

The defensible outcome is **time for a specified training task on nominally fixed hardware**, not research-input FLOPs, model quality in general, or a measured universal efficiency multiplier. Recent same-node candidate/baseline runs strengthen the local efficiency claim. They do not identify the research effort that generated it or its extrapolation to a cosmic tail.

## Date and version audit

| Record | Frozen leaderboard date | Public chronology checked | Interpretation |
|---|---|---|---|
| 90 / PR 344 | 2026-08-03 | PR opened July 21; revised during August; maintainer changed step count and merged September 18 | The final roughly 68-second result is supported by September evidence, not established by the table date. |
| 91 / PR 350 | 2026-08-06 | Proposal August 6; maintainer revised timing and step count, then merged September 18 | August 6 does not timestamp the final accepted 67.6-second configuration. |
| 92 / PR 360 | 2026-08-30 | Initial PR August 31; merged September 28 | Preserve the table date as a source-reported vintage, and separately test acceptance-date chronology. |

For record 90, the PR body reports four candidate runs averaging 70.094 seconds versus 73.897 seconds on the same node, with 1,315 steps. On September 18 the maintainer removed 20 additional steps and reported 68.0 seconds. The leaderboard's 1.13 minutes converts to 67.8 seconds because that entry is rounded. Treat neither number as millisecond-precision measurement. Provisional H200 results and older cross-node comparisons are not H100 record observations. [PR 344](https://github.com/KellerJordan/modded-nanogpt/pull/344)

Record 91 changes validation/inference by masking token continuations incompatible with the tokenizer. Its proposal tested one H100, estimated savings, and built the mask before timed training. On September 18 the maintainer moved that work into the timed region, removed five extension steps, and reported 68.0 → 67.6 seconds. Removing ten steps did not reach sufficiently low loss in that check. This is a legitimate change under the benchmark's probability-model definition, but it is not evidence that unchanged training alone became faster. [PR 350](https://github.com/KellerJordan/modded-nanogpt/pull/350)

Record 92 reports 18 candidate runs averaging 39.914 seconds (SD 0.120), interleaved with nine record-89 baseline runs averaging 73.889 seconds (SD 0.137). The 1.85× comparison is with **record 89**, not record 91. One leg's raw logs were lost, although its recorded results remain in the pooled statistics. The merge preserves the measured trainer and omits record 91's canonical masking. Retain this as a benchmark result with an explicitly incomplete raw-log archive. Its roughly 65-billion-parameter sparse embedding table also changes the resource mix substantially. [PR 360](https://github.com/KellerJordan/modded-nanogpt/pull/360)

On September 28 the maintainer's refactor reruns averaged 40.60 seconds for the record-92 trainer (n=4, mean loss 3.2769) and 40.90 seconds for the refactor (n=3, mean loss 3.2756). The refactor reintroduced canonical masking and changed implementation and initialization details. Thus the current pinned HEAD is not exactly the submitted 39.914-second trainer. Use archived record code for reproduction; 40.60/40.90 seconds are useful endpoint sensitivity values, not additional independent record gains. [PR 373](https://github.com/KellerJordan/modded-nanogpt/pull/373)

These findings motivate a chronology sensitivity using actual PR merge timestamps wherever available. Merge date measures acceptance, not discovery or first public availability; it must not silently replace all source dates. If merge-date order differs from record-number order, form the accepted running frontier rather than treating every merge as an improvement. A chronological holdout on retrospectively edited submission dates is not a strict real-time forecast test.

## Timing regime and units

The frozen README says the post-record-21 rules removed ten untimed training steps, replacing them with dummy-data warmup; that added about 0.85 seconds. Banning coordinate-descent compiler tuning added about three seconds of timed runtime while saving about 25 minutes of untimed compilation. The source records the same record 21 three times: 2.933 minutes originally, 2.997 minutes after the timing change, and 3.014 minutes after a later PyTorch retiming. These are **retimings, not three innovations**. The 2025-05-24 3.014-minute / 180.84-second anchor avoids splicing the old regime directly into later records. For the full history, an explicit regime break or sensitivity is preferable to a speculative constant correction. [Pinned README, timing section](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/README.md#timing-change-after-record-21)

Eight H100s fix the nominal GPU count and family; the rule requires a new candidate to beat its baseline on the same hardware. That is stronger than uncontrolled vintage comparisons, but it does not make every historical time an identical physical instrument. Software versions, node performance, memory traffic, precision, architecture, token count and timing exclusions differ. `8 × elapsed_seconds` has units of GPU-seconds; it is **not actual FLOPs**. Multiplying it by a peak FLOP/s specification would yield a capacity proxy, not an operation count, particularly with FP8 and sparse lookup changes. Compiler warmup/setup and final evaluation are not generally included in the training-section headline. The pinned README itself warns of approximately seven minutes of first-run compilation. [Pinned README, task, running instructions and rules](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/README.md)

## Selection, uncertainty and a failed check

The series consists of record setters. Failed trials, all research labor, agent compute, and most exploratory runs are unobserved. Record count and calendar time are not measured research input. Successive points share code and data; treating record residuals as independent measurement noise would exaggerate effective sample size. Run-level SD describes repeatability of one configuration, not uncertainty in long-term progress or reproducibility across machines. Repeated tuning against a public fixed validation set also leaves transfer to new evaluation data unidentified.

The record-90 maintainer comment lists three post-step-cut losses: 3.2769, 3.2794 and 3.2785. Their mean is 3.2782667 and sample SD 0.00126623. A one-sided Student-t test against 3.28 gives t=2.370996 with two degrees of freedom, p=0.070585, so **those three printed observations alone do not reproduce the nominal p<0.01 acceptance gate**. This does not establish that the accepted record fails: additional runs may exist. The earlier, different 1,315-step four-run configuration does have a reported p=0.001585. Preserve the incomplete check rather than transferring that p-value to the shorter configuration. [PR 344, September 18 comment](https://github.com/KellerJordan/modded-nanogpt/pull/344)

Arithmetic for that limited check requires only the Python standard library:

```python
import math, statistics
losses = [3.2769, 3.2794, 3.2785]
t = (3.28 - statistics.mean(losses)) / (statistics.stdev(losses) / math.sqrt(3))
p = 0.5 - t / (2 * math.sqrt(2 + t*t))  # exact upper tail, Student t with df=2
print(t, p)
```

Recommended sensitivity set (analyst judgments): distinguish source and acceptance dates; exclude or explicitly flag record 91; omit record 92 to see how the abrupt endpoint change alters extrapolation; replace its endpoint with the maintainer rerun; and retain the post-rule-change anchor. These diagnose dependence on choices; they cannot turn this frontier into a causal estimate of research productivity. Evidence of substantial local software headroom is compatible with many finite ceilings and many unbounded tails. It neither establishes a human-brain ceiling nor estimates the forecast's tail mass or stopping exponent.

Access note: GitHub pages were successfully inspected with the web tool. A direct Python `urllib` query of the GitHub API failed DNS resolution in this worker; no API timestamps are claimed from that failed query. Freeze structured PR metadata separately if used by the fit.
