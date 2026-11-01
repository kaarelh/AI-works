# Analytic upper bounds, envelopes and the barriers (nets trained to output 1)

Experiments for `code/rareprob/nets_analytic.py`: prover-free analytic upper
bounds (Chernoff-Hoelder with exact DP group laws, McDiarmid), envelopes with
exact mass and exact sampler (box-relaxed tilts, sign-pattern mixtures,
cube-certified tilts), perturb-and-MAP, and the diagnostics that explain why
they fail on the trained nets (box barrier, cube barrier, decoupling floor).
Test bed: the suite of `experiments/nets/` (exact p for d <= 28) and nets
trained here with `rareprob.nets.train_constant`. p is Pr[F(x) < t] for the
exact-real net F on its float64 weights; every bound also covers the float64
evaluation in any summation order.

Costs: wall-clock seconds on a shared 4-core machine (indicative only), and
forward-pass equivalents (fpe) where they are meaningful: one enumeration of
the cube is 2^d fpe (meet in the middle: about 2^d first-layer additions);
a MAP call answered by enumeration costs one such pass; Monte Carlo needs
3 ln(2/delta) / (eps^2 p) samples of 1 fpe each (eps = 0.1, delta = 0.05).

## Main findings (tables: `python3 summarize.py`, written to `results/summary.txt`)

* **The barriers, measured on all 30 suite nets** (`barrier_table.py`,
  Table N4 of `results/summary.txt`, re-run on the final code).
  - *Box barrier.* F(0) < t on all 13 squared-loss nets with d <= 28
    (F(0) - t = -0.02 ... -0.40) and on 2 of the 3 at d = 64. A point of the
    box [-1,1]^d with f < t (a re-evaluated witness; HiGHS reports the box
    minimum optimal on 14 nets, a floating-point claim, and hit the 120 s
    limit on the others) exists on 29 of 30 nets, so no bound valid on the
    box certifies their root. The exception is bce_d64_w64_s1000, whose box
    minimum is t + 0.114 by the solver's (uncertified) optimum. The best box-relaxed tilt has Z >= 1 on all 30 nets (the
    optimiser ends at theta -> 0) and the sign-pattern envelope on every
    one-hidden-layer net except bce_d64_w64_s1000 (Z = 4.9e-3).
  - *Cube barrier.* min_x (F(x) + F(-x))/2 - t < 0 on 11 of the 12
    squared-loss nets with d <= 28 and p > 0 (the exception is
    mse_d24_w32_s2000, +0.011), so no tilt from an affine minorant valid on
    the cube, however certified, has Z < 1 there. It is positive on the
    p = 0 nets and on the logistic nets trained for 60 steps or more.
  - *Decoupling floor* (one hidden layer, squared loss, d <= 28): 0.06 ...
    0.47 with singleton parts and 2e-6 ... 0.065 with greedy pairs, against
    p = 6e-8 ... 7e-2. The best certified Chernoff-Hoelder bound is 0.94 ...
    0.98 there (logistic loss: 0.32 ... 0.76 at d = 28, 0.22 ... 0.68 at
    d = 64), McDiarmid >= 0.99 on squared loss and >= 0.90 on every net.
  - *Relaxation gap.* On 8-dimensional subcubes CROWN's gap (cube minimum
    minus bound) is 0.69 ... 1.0 for one-hidden-layer squared loss at
    d <= 28, against a margin (cube minimum minus t) of -0.19 ... 0.32, so
    almost nothing is certified: CROWN r50 = 2 ... 4 for squared loss at
    d <= 28, 6 ... 12 for one-hidden-layer logistic loss, 4 ... 24 at d = 64
    and 12 ... 16 at d = 128.
  - *Level-1 Walsh weight.* 0.3 ... 0.8 % of Var f for one-hidden-layer
    squared loss at d <= 28 (exact; 0.6 ... 2 % estimated at d = 64, 0.6 ...
    7 % with two hidden layers) against 37 ... 62 % for logistic loss at
    d = 28: squared-loss training cancels the linear part, which is why the
    failures are small-ball events around the origin of the box.
  - *Cost.* One row takes 11 s (d = 24) to 8.5 min (d = 28 with two hidden
    layers of 64, where the enumeration of the 2^28 points dominates); the
    box MILP is capped at 120 s.

* **Decoupled analytic bounds are useless on the trained nets** (Monte
  Carlo certifies the same U with ln(1/delta)/U < 15 samples). The best
  certified Chernoff-Hoelder bound is >= 0.94 on every squared-loss net
  with d <= 28 and McDiarmid >= 0.99 there (Table A; at most 0.09 of the
  4 ... 24 bits of rarity).
  The decoupling floor explains it: every Hoelder / tree-reweighted /
  Brascamp-Lieb / Finner bound with these parts is at least the value the
  bound would have if the parts were independent, and the positive- and
  negative-weight units cancel on the squared-loss nets (their even parts
  are correlated -0.75 ... -0.84, `decompose.json`), so that floor is far
  above p. Bounding the positive units alone
  (Esseen / Halasz type, even with their exact law) cannot go below
  q+ = 0.98 ... 0.995 (`smallball.json`); the best exact-moment Markov
  bounds (exact moments from the full table, order up to 28) stay 13 ... 50x
  above p on the three rarest squared-loss nets (Table B).
* **Methods that use an exact optimisation over the cube escape the box
  barrier, at verification cost.** Perturb-and-MAP (Table C) certifies
  U = 4.8e-6 at p = 6.0e-8 and 1.6e-3 at p = 9.7e-6 (d = 24, 1720 MAP calls,
  about 6 to 9 minutes each), U = 5.5e-4 at p = 3.3e-7 and 1.8e-4 at
  p = 7.5e-9 (d = 28, 380 calls, 18 to 20 minutes): roughly half of the
  log-rarity. The cube-certified tilt (Table D) exists only when
  s* - t > 0: on mse_d24_w32_s2000 (p = 6.0e-8) it has Z = 1.3e-5,
  K = Z / p = 221, and 2.1e6 samples give [5.70e-8, 6.22e-8], against
  1.9e10 Monte Carlo samples; on bce_d28_w32_s100 (p = 7.5e-9) 1/Z = 146.
  Here each MAP call is an enumeration of the cube (2^24 ... 2^28 fpe), so
  the certificates cost far more than computing p exactly (405 calls, about
  7e9 fpe, for the cube tilt at d = 24). With HiGHS as the MAP oracle
  (Table G) a per-coordinate perturbed MAP call takes 1 ... 30 s for width
  32 up to d = 64 and leaves 22 ... 33-nat gaps after 300 s on the suite's
  d = 64 width-64 nets; these timed calls used per-coordinate perturbations,
  not the blocks of 6 ... 7 coordinates behind the certified bounds, and
  HiGHS's floating-point dual bound is not a certificate. The ideal Chernoff
  envelope exp(theta (t - f)) would have K = 2.1 ... 10.6 (`oracle.json`):
  the obstacle is computing its mass and sampling it, not information.
* **Large margin: the sign-pattern envelope works.** On bce_d64_w64_s1000
  (F(0) - t = 1.52) it has Z = 4.9e-3 (|N| = 12 negative units split);
  2e7 samples give p in [0, 2.4e-9], against a Monte Carlo upper bound of
  1.8e-7 with the same samples. The realised gain at an equal number of
  samples is about 80x (the sequential union bound costs about 2.6x), not
  1/Z = 205 (Table E). Not checked against an exact p: no d <= 30 net is in
  this regime.
* **Narrow nets.** With at most 3 hidden units, small_width_interval is a
  deterministic interval from the exact law of all quantised
  pre-activations, at most 40 s (Table H): exact on width 1 (and p = 0, 1
  wherever true), [0.163, 0.181] around 0.173 on width 2, loose on width 3.

## Changes in this round (adversarial review)

Fixed, each with a regression test in `code/tests/test_nets_analytic.py`:
- `mcdiarmid`: s * s overflowed while sum c_i^2 did not (certified U = 0 for
  p = 11/1024); now computed through s / ||c||_2 with a scaled norm, and
  NaN / overflow give the trivial bound.
- `small_width_interval`: cells whose value overflowed (inf - inf = NaN)
  were dropped from the upper end ([0, 0] for p = 1); now an undefined cell
  is always counted in hi and never in lo. For d > 53 the DP entries are
  rounded and the interval missed p by about 1 ulp in 92 of 161 cases; now
  it is widened by the proved relative error of the DP (d > 1000 refused).
  It also covers the float64 evaluation of the net (threshold t -+ tau).
- `fails_exact`: rows whose float value is NaN were neither rechecked nor
  counted (p = 0.75 reported for p = 1); now every row not decided by the
  float pass with margin tau, NaN included, is recomputed in rational
  arithmetic, and `forward_error_bound` returns inf on overflow.
- The box-barrier statement covered "every mixture of product measures"
  including group-DP tilts; on the small-ball net |sum x| a cell envelope
  has Z = 0.597 < 1 with F(0) - t = -1. It now covers positive mixtures of
  full-support exponential tilts proved on the box only.
- The hindsight "few-form ceiling" (K* >= 843 for envelopes in 1 ... 3
  quantised hidden forms) was an artifact of coarse grids and a search over
  the top units only (K* = 10 ... 44 at a 2^20 grid); the claim and
  `few_forms.py` are removed.
- The CROWN minorant of the deep tilt used a heuristic rounding allowance;
  it is now the backward pass of `nets_verify.Bounder.affine_lower` with its
  proved margin.
- Perturb-and-MAP now bounds Pr[F < t + tau] (float evaluations covered) and
  returns the trivial bound instead of NaN when theta F overflows; the MAP
  oracle refuses overflowing tables. The sign-pattern interval is widened
  by the total variation of the float coin probabilities; the tilt interval
  by the rounding of its log-weights (both negligible here).

Trimmed: the group-DP tilt envelope (its earlier measurements, log Z =
5e-6 ... 7e-5, i.e. no gain, on every one-hidden-layer suite net, are kept in
`results/group_dp_earlier.json`) together with the tilted variant of the DP
and the backward sampler that only it used; the independent-units heuristic;
and the oracle-only ceilings (best tilt on the cube, moment bounds), which
moved into `oracle.py`. `run_suite.py` and `results/suite.json`
are superseded by `barrier_table.py`.

## Scripts

| script | what it measures | output |
|---|---|---|
| `barrier_table.py` | per suite net: F(0) - t, the box minimum (HiGHS MILP over the box, re-evaluated witnesses), the cube minimum and min_x (F(x)+F(-x))/2 (enumeration, d <= 28), decoupling floors, the best certified Chernoff-Hoelder bound and McDiarmid, the masses of the box-relaxed tilt and sign-pattern envelopes, CROWN's gap and margin on 8-dimensional subcubes and r50, the level-1 Walsh weight; seconds per part | `results/barrier_table.json` |
| `check_soundness.py` | brute-force soundness of every method on 168 small adversarial nets (Gaussian, integer ties, 3-CNF, extreme and overflow scales, degenerate, trained, 2-3 hidden layers) against the exact failure set computed in exact integer arithmetic; coverage of the two-sided intervals | `results/soundness.json`, `results/soundness_log.txt` |
| `oracle.py` | exhaustive ceilings (d <= 28): best tilt on the cube, exact Chernoff value (K of the ideal envelope), exact-moment bounds, perturb-and-MAP estimates, variance inflation of Hoelder, Dobrushin coefficient, ellipsoidal caps | `results/oracle*.json` |
| `perturb_map.py` | certified perturb-and-MAP bounds with an enumeration MAP oracle | `results/perturb_map.json` |
| `cube_tilt.py` | cube-certified tilt envelopes and their two-sided intervals | `results/cube_tilt.json` |
| `signpattern.py` | sign-pattern envelopes on the suite, and a shifted-threshold variant at d = 24 | `results/signpattern*.json`, `results/own_*.npz` |
| `map_cost.py` | cost of one MAP call by HiGHS MILP (suite and own nets up to d = 64) | `results/map_cost*.json` |
| `smallball.py` | the best bound any small-ball inequality on the positive units alone can give | `results/smallball.json` |
| `decompose_failures.py` | which parts of f (linear, positive units, negative units) drop at the failures | `results/decompose.json` |
| `narrow.py` | small_width_interval on trained nets of width 1 ... 3 at d = 24 and 64 | `results/narrow.json` |
| `pmap_toy.py` | perturb-and-MAP on toy events (subcube, halfspace, small ball) | `results/pmap_toy.json` |
| `summarize.py` | all tables | `results/summary.txt` |

Re-run on the final code of this round: `barrier_table.py`,
`check_soundness.py`, `narrow.py`, `summarize.py`. The other results come
from the code before the fixes; on these nets (finite weights, |f| < 100)
the fixes change nothing they measure: no overflow branch is reached,
perturb-and-MAP's threshold moved by tau <= 1e-12 (log U moves by
theta tau <= 2e-10), and the sign-pattern and tilt intervals widen by about
d 2^-52 and 1e-14 relative.

Reproduce (from this folder; Python 3 with numpy, scipy):

```sh
python3 check_soundness.py
python3 barrier_table.py
python3 oracle.py && python3 perturb_map.py && python3 perturb_map.py mse_d28_w64_s600 mse_d28_w64_s1000 bce_d28_w32_s60 bce_d28_w32_s100 mse_d28_w32x32_s500 mse_d28_w64_s1500
python3 cube_tilt.py mse_d24_w32_s2000 mse_d24_w32_s1500 bce_d28_w32_s100 bce_d28_w32_s60
python3 signpattern.py && python3 signpattern.py --shifted
python3 map_cost.py && python3 map_cost.py --scaling && python3 map_cost.py --width
python3 smallball.py && python3 decompose_failures.py && python3 narrow.py && python3 pmap_toy.py
python3 summarize.py
```

Published and unpublished paths: everything in this folder is published
except `__pycache__/`.
