# Ablations of the race model: which ingredients make it match the networks

The race model ([`models/race.py`](models/race.py), evaluated as `Race(theta=1.5, Q=3, gate="relu")`) matches the
networks' sample complexity on the held-out targets very closely ([`MODEL-SCOREBOARD.md`](MODEL-SCOREBOARD.md)). This
file takes it apart. Each ingredient is switched off in turn
([`models/race_ablations.py`](models/race_ablations.py)). Each variant is evaluated on the full grid
(21 targets × 11 values of n × 3 seeds, on exactly the networks' training sets) at the calibrated constants, with no
recalibration, and scored with the scoreboard metrics.

**Status: Numerical** throughout. There is one network architecture, one optimizer, d = 30, and d = 15 for a few
variants. Statements about mechanism are **Heuristic** readings of these numbers, and are labelled where they appear.

## Summary

1. **The race dynamics are not what makes the model match.** Each of the following leaves every scoreboard metric
   inside the spread that the calibrated model shows across its own random streams:
   - removing the alignment cost (`free`, `flat`);
   - removing persistence of partial growth (`reset-clock`, `reset-all`);
   - removing the race altogether (`greedy`: add the gate of largest utility, stagewise);
   - changing θ by a factor of 12, the number of power-iteration steps by a factor of 32, or the pool size.

   On held-out targets, mean |log₂ n\*ratio| is 0.25–0.34 for these variants, against 0.27–0.33 for the
   calibrated model under three random streams. The n\* Spearman is ≥ 0.93 and the curve MAE ≤ 0.02 for all of them.
2. **n\* is set by sampling noise in the direction search.**
   - **Noise-free search:** the search statistics (the target directions v\* and their order-k utilities) come from a
     large fresh sample (`oracle-align`). Then n\* collapses to 16–80 on every target. On held-out targets |log₂ ratio|
     is 4.6, as far from the networks as the junta Occam learner (4.61).
   - **Independent sample of the same size n** (`indep-search`): the networks' n\* comes back (held-out 0.31).
   - **So it is the noise *level* at sample size n that matters.** Reuse of the training labels by the search does
     not. Everything else is downstream of that.
3. **A one-constant noise-floor rule predicts the parity sample complexities of the networks at d = 15, 30 and 60.**
   - **The rule:** n\*\_k is the n at which the order-k utility of the true direction exceeds 1.5 times the largest
     spurious order-k utility found on random labels.
   - **Prediction vs network,** for x₁x₂, x₁x₂x₃, x₁…x₄:
     - d = 15: 121 / 249 / 498 against 100 / 241 / 508;
     - d = 30: 277 / 765 / 2026 against 200 / 843 / 2728;
     - d = 60: see §4.2.
   - **Dense leap-1 targets:** the one-shot Hebbian classifier sign(E_S[y x]·x) gives n\* = 53, 116 and 346 for x₁,
     MAJ₃ and MAJ₉, against the networks' 47, 112 and 263.
4. **The gate library matters, the race does not.**
   - **Orders up to the target's leap are needed.**
     - Without orders 3–4 (`K2`), parities of 3 and 4 bits, the sparse polynomial and recursive majority are never
       learned (held-out 1.43).
     - Without order 4 (`K3`), only x₁…x₄ is lost.
   - **ReLU vs threshold gates:** ReLU gates beat threshold gates (`thr`: held-out 0.60, n\* of MAJ₉ and the DNF
     doubled).
   - **Coarser weights:** ternary weights (`Q1`) lower n\* on most targets by about 1.5× and break the match (0.81).
     Q = 2, 3 and 5 are equivalent.
   - **Depth-2 composition** matters little (held-out 0.35). It helps the staircase-like targets by about 0.4 log₂.
5. **Per-example agreement (0.50) comes from sharing the training sample.**
   - With an independent search sample of the same size, it halves: 0.26 for `indep-search`, 0.23 for `indep-align`.
   - The halving is uniform across target families.
   - No ablation raises it above 0.53. The NNGP kernel has 0.69 and SGD-vs-Adam networks 0.71.
6. **Time to generalise is set by the true features' utilities, not by noise or the race.**
   - **The ordering of cells by time survives every ablation,** including noise-free search: time Spearman 0.75–0.88.
   - **Magnitudes:** the alignment law's leap factor makes high-order parities too slow.
     - Far above n\*, at n = 16384, relative to x₁x₂: x₁x₂x₃ takes 4.4× and x₁…x₄ 64× in the calibrated model, against
       2.5× and 5× in the networks.
     - The plain stagewise clock Σ θ/U_g (`greedy`) fits the networks' time profile best. Its rms log₂ deviation over
       13 targets is 0.72, against 1.35 for the calibrated model.
7. **Negative: the race has no delayed generalisation.**
   - **Networks:** in 121 of 693 cells the test error is still above 0.1 when the training error reaches 0.1, and drops
     to 0.1 or below only later, after up to 100–150× as many steps.
   - **Race:** run past interpolation (`nostop`), the test error never improves later. The longest delay in the race is
     9× in clock time.
   - **The networks' n\* is still falling at the end of training,** by about 0.2 log₂ per doubling between 10⁴ and
     2·10⁴ steps. The race model has no counterpart of that.
   - **So the match at 20000 steps is partly a match at a particular training budget.**

## 1. The ablations

| group | name | what is changed (everything else as in the calibrated model) |
|---|---|---|
| control | `base` | the calibrated race model: θ = 1.5, Q = 3, ReLU gates, λ = 10⁻³, K = 4, P = 8, 8 power-iteration steps per firing, ≤ 48 gates, depth ≤ 2. It reproduces `race.npz` bit for bit |
| control | `reseed1`, `reseed2` | the same model with another internal random stream (initial unit directions): measures the metrics' own noise |
| race dynamics | `free` | no alignment cost: every unit is at its target direction v\* at once, for all orders |
| race dynamics | `free3` | no alignment cost for orders ≥ 3 only |
| race dynamics | `flat` | order-independent alignment law: every order k ≥ 2 aligns like k = 2, T = log(1/m)/(2U_k). This removes the D^((k−2)/2) leap factor but keeps a search cost |
| race dynamics | `reset-clock` | all growth clocks reset to 0 after every firing; partial alignment is kept |
| race dynamics | `reset-all` | clocks reset, and every dormant unit restarts from a fresh random direction, after every firing: no persistence at all |
| race dynamics | `greedy` | no race: each step adds the candidate gate of largest utility U_g. The clock advances t += θ/U_g per gate (stagewise saddle-to-saddle time) |
| search noise (oracle) | `oracle-align` | v\* and U_k come from a fresh labelled sample of 16384 points instead of the training set; the threshold and U_g still come from the training set |
| search noise (oracle) | `oracle-search` | v\*, U_k, the threshold and U_g all come from the fresh 16384-point sample; only the readout and the stopping rule see the training set |
| search noise (oracle) | `indep-align`, `indep-search` | as the two above, but the fresh sample has the same size n as the training set: same noise level, but the noise is independent of the training labels |
| search noise (oracle) | `indep-resample` | as `indep-search`, but a new size-n search sample is drawn before every firing |
| library | `K2`, `K3` | proto-units of orders ≤ 2 (resp. ≤ 3) only |
| library | `depth1` | gates may not read earlier gates (one hidden layer of gates) |
| library | `thr` | threshold gates 1[w·u > b] instead of discrete ReLUs relu(w·u − b) |
| library | `Q1`, `Q2`, `Q5` | integer weights in {−Q..Q} with Q = 1, 2, 5 (calibrated: 3) |
| constants | `theta0.5`, `theta3`, `theta6` | firing threshold θ = log(1/α) = 0.5, 3, 6 (calibrated: 1.5) |
| constants | `P1`, `P32` | 1 or 32 dormant units per order (default 8) |
| constants | `iters1`, `iters32` | 1 or 32 power-iteration steps per firing (default 8) |
| constants | `gmax96` | at most 96 gates (default 48) |
| stopping | `nostop` | no stop at zero training error: always run to 48 gates |

**Which constants keep their meaning.**
- `greedy` makes θ a pure time unit: it rescales the clock and changes no decision.
- `free` removes the meaning of the alignment law but not of θ.
- `oracle-*` and `indep-*` use the target inside `fit()`. **They are diagnostics, not learning algorithms.** The
  oracle samples are drawn with their own random stream.
- No ablation was recalibrated.

## 2. Scoreboard

Metrics are as in [`MODEL-SCOREBOARD.md`](MODEL-SCOREBOARD.md). Each is computed against the Adam networks; "never"
is counted as 2 × 16384.

The reference rows are:
- **NN-SGD vs NN-Adam:** a ceiling for how alike two gradient-descent learners are;
- **NNGP kernel:** the lazy baseline.

@@SCOREBOARD@@

**How to read it.**
- **Noise band.** `base`, `reseed1` and `reseed2` differ only in the model's own random stream. Their spread (held-out
  |log₂ ratio| 0.27–0.33, time Spearman 0.83–0.85) is the noise band for every "no change" statement.
- **Within the band:** every race-dynamics ablation (`free`, `flat`, `reset-*`, `greedy`), every constant change (θ,
  P, iterations, gmax) and `depth1` lie within or at the edge of that band.
- **Outside the band:** only the noise-free search (`oracle-*`), the library changes (`K2`, `thr`, `Q1`), and to a
  lesser degree `free3`, `nostop` and `K3` (on ALL, through x₁…x₄) leave it.

## 3. Sample complexity per target and per family

n\* per target. The *base range* column is the minimum to maximum over the calibrated model's three random streams;
for the parities it spans up to 0.6 log₂. A star marks the held-out targets.

@@PERFN@@

Mean signed log₂(n\*_model / n\*_NN) per family (+ means the model needs more data). The families are:
- parity: x₁x₂, x₁x₂x₃, x₁…x₄;
- staircase/sparse polynomial: the staircase, sign(2x₁+x₂x₃+x₄x₅x₆) and the multiplexer;
- dense: MAJ₉, the 10-bit halfspace and recursive majority;
- compositions: MAJ(x₁x₂,x₃x₄,x₅x₆), MAJ₃⊕MAJ₃ and AND(x₁x₂,x₃x₄).

@@FAMILY@@

## 4. What sets n\*: sampling noise in the direction search

### 4.1 Removing the noise, and decorrelating it

**Noise-free search (`oracle-align`, `oracle-search`).** The model keeps everything else:
- the same race;
- the same alignment costs (now computed from population utilities);
- the same readout fitted on the n training points;
- the same stop at zero training error.

It then reaches test error ≤ 0.1 at n = 16 on 15 of 21 targets, and by n ≤ 81 on all of them.

Below the networks' n\*, its circuits are made of true features: 13% spurious gates, against 99% for the calibrated
model. So nothing in the race's *timing* produces a sample complexity by itself. Given the true features, the race
finds them in the right order, and the readout interpolates with them.

One artifact needs flagging. When the fresh sample is the same size as the training set, its own noise is never
"consumed": a spurious direction of that sample keeps its utility after it fires. The run can then fire it again and
again; this happens at n = 16384 on x₁…x₄ for one seed.

**Independent sample of the same size n (`indep-align`, `indep-search`).** The noise level of the search is restored,
but the noise is independent of the training labels. The networks' n\* comes back:
- held-out |log₂ ratio| 0.31 (`indep-search`) and 0.41 (`indep-align`);
- n\* Spearman 0.97 and 0.92.

So n\* is a **noise-level** effect: what matters is how noisy the empirical moments are at n samples. It is not an
effect of the search *overfitting the training labels*.

The families respond differently:
- **Parity and staircase** get slightly *harder* with an independent sample: x₁…x₄ 3207 vs 1980. Part of this is the
  persistence artifact above (see `indep-resample`).
- **Dense targets** get *easier:* the halfspace 326 vs 578, MAJ₉ 182 vs 248. With the training labels, spurious gates
  memorize the training set after the first good feature, and that memorization costs generalisation.

@@RESAMPLE@@

### 4.2 The parity noise floor (Numerical, Heuristic rule)

For x₁…x_k the true direction is v = (1,…,1,0,…)/√k, with utility U_k(v) = k^(−k/2)·E_S[r χ] ≈ k^(−k/2). On the
training set (r = y − ȳ) we compare it with the largest U_k that power iteration finds on *random labels* with the same
inputs (32 starts × 40 steps; 3 seeds). The table gives the n at which the ratio crosses 1, 1.5 and 2, interpolated
on a √2-spaced grid
([`../study/models/race_ablations.py`](models/race_ablations.py) helpers; script in the session scratchpad,
`parity_floor2.py`).

@@FLOOR@@

**The rule.**
- n\* ≈ (ratio-1.5 crossing) predicts the networks' parity n\* within a factor of 1.4 at every d and k tested.
- It also predicts how the n\* grows with d: the ratio-1.5 crossing grows ×2.3, ×3.1 and ×4.1 from d = 15 to 30, against
  ×2.0, ×3.5 and ×5.4 for the networks.
- The race itself sits at the same place by construction: its parity gates are found exactly when the true direction
  wins the power iteration.
- **One-constant fit:** the constant 1.5 was read off d = 30 and d = 15 together.

**Mechanism (Heuristic).** The order-k noise maximum falls slower than n^(−1/2) at these sizes (about n^(−0.6) for
k = 4 at d = 30). The number of order-k directions, C(d,k), is comparable to or larger than n here. So the empirical
order-k tensor can be "fit" by spurious directions much as a regression with more features than samples can.

### 4.3 Dense leap-1 targets: the noise in one Hebbian direction (Numerical)

For x₁, MAJ₃ and MAJ₉ the first gate is the rounded Hebbian direction E_S[y u], and the first gate already reaches
training error ≤ 0.1. Their n\* is that of the one-shot correlation classifier sign(c + a·h·x), up to rounding:

| target | network n\* | race n\* | sign(h·x), h = E_S[y x] | h rounded to {−3..3} | h rounded to {−1,0,1} |
|---|---|---|---|---|---|
| x₁ | 47 | 54 | 53 | 74 | 28 |
| MAJ₃ | 112 | 102 | 116 | 142 | 55 |
| MAJ₉ | 263 | 248 | 346 | 503 | 196 |
| 10-bit halfspace | 563 | 578 | 322 | 468 | never |
| 3-term DNF, recursive MAJ₉ | 505, 2027 | 564, 1895 | never | never | never |

**The 10-bit halfspace.** Network and race agree with each other (563 and 578), but *both* are 1.8× worse than the
plain Hebbian classifier (322).
- In the race the cause is visible: after the first gate, about 47 further gates are fitted to interpolate the
  training set. Most are spurious (§4.4), and they cost about 0.06 of test error near n\*.
- The race reproduces the network's suboptimality, not only its successes.

**Coarser weights denoise.** Rounding h to {−1,0,1} zeroes the noisy small coordinates. That is why `Q1` lowers n\*
almost everywhere (by 1.5× on average) and breaks the match. The calibrated Q = 3 (and Q = 2, 5) keeps about the
right amount of noise in each gate.

### 4.4 What the circuits look like

A gate counts as *spurious* if it depends, through its depth-1 inputs, on any irrelevant coordinate. This uses the
target's relevant set after `fit()` has returned.

@@DIAG@@

- **Below the networks' n\*:** essentially every gate is spurious (99–100% for every non-oracle variant). The model
  interpolates the training set with memorising gates before the true feature wins the search.
- **At n ≥ 2n\*:** the true features are present in 70–79% of cells. The remaining spurious gates are refinements of
  dense targets; their stray coordinates carry small weights.
- **Order mix:** the race and the greedy learner differ only in it. The race's alignment costs shift selection
  slightly toward orders 3–4: 15% order-4 gates, against 6% for `greedy`.

## 5. What sets the time to generalise

**Ordering (Numerical).** The Spearman correlation between the networks' steps to generalise and the model's clock is
0.75–0.88 on held-out targets for *every* variant.
- That includes the noise-free search (0.80) and the greedy clock Σ θ/U_g (0.86).
- Far above n\* (n ≥ 4096) it is 0.82–0.94 everywhere.

So the ordering is a property of the targets' feature structure under the gate library. It reflects how many stages
are needed and how small their utilities are. It is not specific to the race mechanics.

**Magnitudes far above n\*.** The median time to generalise at n = 16384 is given relative to x₁x₂, so that one unit
conversion is free.

@@TPROFILE@@

**The alignment law.** The homogeneous law dm/dt = kU_k m^(k−1), with its D^((k−2)/2) leap factor, makes x₁x₂x₃ and
x₁…x₄ 4–64× slower than x₁x₂. The networks take 2.5× and 5×.
- Removing the leap factor (`free`, `flat`) or the race (`greedy`) brings the parities into line.
- Each of those then mis-times other targets: `free` makes the staircase and the sparse polynomial too fast,
  `greedy` makes MAJ(x₁x₂,…) and recursive majority too slow.
- The best single description here is the stagewise clock Σ θ/U_g (rms log₂ deviation 0.72).

The time measure itself was also tried both ways, as the clock at training error ≤ 0.1 and as the clock at test
error ≤ 0.1 along the trajectory. This changes the calibrated model's held-out time Spearman only from 0.83 to 0.78.

@@DSCALE@@

**No delayed generalisation (negative, Numerical).** For each cell we compare the test error at the moment the
training error first reaches 0.1 with the final test error.

| | networks (Adam) | race `base` | race `nostop` |
|---|---|---|---|
| cells fitted (of 693) | 690 | 690 | 690 |
| test error > 0.1 at fit, ≤ 0.1 at the end | 121 | 51 | 50 |
| time-to-generalise / time-to-fit, 90th percentile | 2.5 | 1.10 | 1.08 |
| … maximum | 100–150 | 9 | 9 |

- **Race in the networks' delayed cells.** Of the networks' 121 delayed cells, the race generalises in 106, and in 75
  of those it already generalises at the moment it fits. Where a network first memorizes and later generalises, the
  race either finds the feature first or not at all.
- **Continuing to run does not help.** Running the race on past interpolation, to 48 gates or (in spot checks) to 160,
  never improves its test error afterwards. It drifts slowly upward instead.
- **The networks' n\* is still decreasing at 20000 steps.**

| target | n\* at 2000 steps | 5000 | 10000 | 20000 |
|---|---|---|---|---|
| MAJ₉ | 561 | 534 | 350 | 263 |
| 10-bit halfspace | 888 | 837 | 697 | 563 |
| x₁x₂ | 326 | 286 | 226 | 200 |
| x₁x₂x₃ | 979 | 977 | 878 | 843 |
| x₁…x₄ | 3302 | 3258 | 3109 | 2728 |
| multiplexer | 1517 | 1498 | 1396 | 1156 |
| rand3 | 1342 | 1312 | 1182 | 1016 |

  The drop between 10⁴ and 2·10⁴ steps averages about 0.2 log₂ over the targets. The race model is calibrated to the
  20000-step budget and has no knob that would follow a longer one.

## 6. Per-example agreement

The scoreboard's per-example agreement is 0.49–0.53 for every variant that searches on the training set. It falls to
0.23–0.26 for every variant that searches on an independent sample of the same size, and the fall is uniform across
families:

| model | parity | staircase/sparse poly | dense | compositions | other |
|---|---|---|---|---|---|
| race `base` | 0.12 | 0.51 | 0.53 | 0.45 | 0.54 |
| `indep-search` | 0.05 | 0.33 | 0.26 | 0.21 | 0.25 |
| `greedy` | 0.12 | 0.53 | 0.56 | 0.47 | 0.57 |
| `thr` | 0.08 | 0.43 | 0.44 | 0.37 | 0.46 |
| NNGP kernel | 0.44 | 0.70 | 0.68 | 0.69 | 0.69 |

Partial cells per family: 3, 18, 21, 13 and 40.

**Reading (Heuristic).** Where a network is partially right, half of the race's excess agreement with it comes from
the two being misled by the *same spurious correlations of the same training sample*.
- **The kernel.** The kernel is a smooth deterministic function of the training sample, and agrees more (0.69). The
  networks' individual mistakes near n\* therefore look more kernel-like than circuit-like, even though their learning
  curves are circuit-like.
- **No ablation closes that gap.** ReLU gates (vs `thr`) and ternary-or-finer weights (vs `Q1`, 0.42) help a little.

## 7. Family by family

- **Parities.**
  - n\* is the noise floor of the order-k utility (§4.2). Orders up to k are indispensable: `K2` never learns
    x₁x₂x₃, and `K3` never learns x₁…x₄.
  - The search's computational side matters slightly: one power-iteration step per firing (`iters1`) raises
    x₁…x₄ to 3738, parity family +0.21 log₂ against −0.39. Which race clock is used does not matter.
  - Time: the leap factor of the alignment law overprices high orders (§5).
- **Staircase, sparse polynomial, multiplexer.**
  - These are learned through low-order steps. Depth-2 composition helps a little (`depth1`: family +0.43 against
    +0.07 log₂; the staircase 2416 vs 1766, the sparse polynomial 2419 vs 1761).
  - With orders ≤ 2 only, the staircase is still learned, but at 14340 (`K2`). The sparse polynomial, whose top term
    x₄x₅x₆ has no lower-order foothold, is never learned.
  - Their plateaus, such as the 1/8 plateau of the sparse polynomial, are a noise-floor effect on the top term alone.
    The low-order terms are found early.
- **Dense majorities and the halfspace.**
  - n\* is the noise in one Hebbian direction, plus the memorization damage of the later gates (§4.3). ReLU gates
    matter here: their linear regime approximates a majority in one gate, and threshold gates double the n\* of MAJ₉
    (527).
  - Recursive majority needs order-3 units: `K2` never learns it.
  - This family is also where the networks' n\* drifts most with training length (MAJ₉: 350 → 263 from 10⁴ to 2·10⁴
    steps).
- **Compositions** (MAJ(x₁x₂,…), MAJ₃⊕MAJ₃, AND(x₁x₂,x₃x₄)).
  - Insensitive to everything but the library. AND(x₁x₂,x₃x₄) is the one target the race misses badly in every
    variant except `Q1` (802 vs 376).

## 8. Caveats

- **Single setting.** One architecture, one optimizer, one width, and d = 30 (d = 15 for a few variants). "No change"
  means no change beyond the calibrated model's own seed spread, which is up to 0.6 log₂ on single parity targets.
- **The oracle variants are diagnostics.** They see the target, and with a fixed fresh sample they can loop on that
  sample's unconsumed noise (§4.1).
- **The noise-floor rule is empirical.** Its constant 1.5 was read off the same networks it is compared with. Its
  "noise maximum" is what 32 power-iteration starts find, a lower bound on the true maximum. It applies as stated only
  to sparse parities.
- **Spurious-gate counting is strict.** A gate with one small stray weight counts as spurious.

## Files

| file | contents |
|---|---|
| [`models/race_ablations.py`](models/race_ablations.py) | `RaceAblation`: `Race.fit` with switches for every ablation; defaults reproduce `Race` exactly |
| [`models/run_ablations.py`](models/run_ablations.py) | full-grid driver: `python models/run_ablations.py NAME…` (`DIM=15` for the d = 15 variants); saves `race-abl-NAME.npz` (common.save_eval format) and per-cell circuit and trajectory diagnostics |
| [`models/ablation_report.py`](models/ablation_report.py) | the tables of §2–§5 |
| [`models/ablation_dscale.py`](models/ablation_dscale.py) | d = 15 vs d = 30 |
| [`models/ablation_figure.py`](models/ablation_figure.py) → [`figures/ablation_curves.png`](figures/ablation_curves.png) | learning curves of the network and the main ablations |

Evaluations are in the session scratchpad (`model_evals/race-abl-*.npz`, `ablation_diag/race-abl-*.json`). Every full
grid takes 1.5–12 minutes single-threaded.
