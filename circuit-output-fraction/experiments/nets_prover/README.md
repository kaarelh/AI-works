# Prover-assisted certificates for nets trained to output 1

Code: [`code/rareprob/nets_prover.py`](../../code/rareprob/nets_prover.py). Question: for a
ReLU MLP `f` trained to output 1 on uniform `x` in `{-1,+1}^d`, with rare event `E = [f(x) < t]`
(`t = 1/2` for squared loss, `t = 0` for the logit), what argument can an unbounded prover
send so that a polynomial-time verifier gets a **sound** two-sided interval for
`p = |E| / 2^d` cheaply (Part 2 of the paper, proof-carrying importance sampling)?

Costs are in forward-pass equivalents (fpe = flops / flops of one evaluation of the net).
Monte Carlo (MC) costs `3 ln(2/delta) / (eps^2 p)` fpe for ratio `1 + eps`; here `eps = 0.1`,
`delta = 0.05`. "Enum" is the verifier enumerating the whole cube itself (meet in the middle
on the first layer: about `4 m_1` flops per point, i.e. `~2/d` fpe per point for one hidden layer).
All numbers below are from `results/*.json` (tables: `python3 summarize.py`).

## The argument

A **certified partition**: a binary decision tree over input coordinates (so its leaves
partition the cube into subcubes), with leaves

* `SAFE(cert)`: `cert` proves `f >= t` on the subcube; `FAIL(cert)`: proves `f < t` on it;
* `ENUM`: the verifier enumerates the subcube (meet in the middle, exact tie handling);
* `OPEN`: the subcube joins an envelope (union of subcubes, exact mass, exact sampler) that
  the verifier samples (`N` samples, KL interval).

Leaf certificates (the prover's free parameters; the verifier recomputes everything else):

* `lin`: linear bound propagation (CROWN/DeepPoly type) with prover-chosen slopes
  `alpha in [0,1]` for every unstable unit relaxed from below, chords from above; the verifier
  recomputes intervals (and, for two hidden layers, the intermediate bounds). For one hidden
  layer the best slopes give the LP (triangle) relaxation over the subcube's box.
* `quad`: a degree-2 Shor / S-lemma certificate that uses `x_i^2 = 1` (so it is **not**
  bounded by the box relaxation): per first-layer unit a valid quadratic minorant / majorant of
  `relu` on its interval (two prover parameters per unit), giving `f(y) >= Y^T M Y` on the
  subcube; the prover sends `mu` and a shift `s` with `M - diag(mu) - s I` PSD, checked by one
  Cholesky factorisation; then `f >= sum(mu) + (r+1) s`.

Verifier output: `p in [(F + Z l)/2^d, (F + Z u)/2^d]`, `F` the exact count in ENUM/FAIL leaves,
`Z` the open mass, `[l, u]` the KL interval of the sampled failure fraction. With no open leaf
the output is **exactly `p`**, deterministically.

**Soundness on every net and every argument** (module docstring has the details): the
verifier parses the tree itself (malformed trees give `[0,1]`); a leaf certificate that is
missing, malformed or fails its check is *demoted* to an open (sampled) leaf, so it can only
cost time; all bounds carry rigorous floating-point error terms (absolute-value shadow
computation, `2^-30` relative budget for chains `< 2^20` operations, chord slopes inflated and
re-checked, units of uncertain sign dropped and charged); the PSD check uses Higham's Cholesky
backward-error bound (`lambda_min(A_f) >= -gamma tr(A_f)/(1-gamma)` when Cholesky of `A_f`
runs to completion); points within `2^-30 |f|_abs` of `t` are re-evaluated in rational
arithmetic, so counts are exact for the exact-arithmetic net; sampling is exact uniform on the
open union. The verifier's work is polynomial in the argument (ENUM leaves above 30 free
inputs are demoted; samples capped). Lower bounds need no deduction: `witness_lower_bound`
checks a list of failing points.

The prover (`prove`) builds the tree breadth first: `lin` with default slopes, then slopes
optimised by projected supergradient ascent (exact LP optimum to within 1e-3 on the tested
subcubes), `FAIL` checks, optionally `quad` (Adam on a smoothed eigenvalue objective), strong
branching (top-4 coordinates by influence on unstable units, pick the one with the best worse
child), `ENUM` at `r <= r_leaf`, and a final pass that replaces every subtree by `ENUM` when
that is cheaper to verify; `open_policy="auto"` turns failure-containing subtrees into sampled
leaves when sampling is cheaper (sample count sized for ratio `1 + eps`).
`knuth_estimate` estimates the uncollapsed tree size and verifier cost from random
root-to-leaf probes (Knuth 1975); it matched the two uncollapsed suite trees built for this check
within 5%, and the collapsed certificates of 48 trained nets within a factor 1.45.

## Results

### 1. Suite nets with exact p (d <= 28)

Exact certificates (`lin`, `r_leaf = 5`, collapsed), checked by `verify`; every count equals
the suite's `fail_count`. MC/cert > 1 means the certificate is cheaper than Monte Carlo.

| net | p | F | certificate: verifier fpe | nodes | MC fpe | enum fpe | MC / cert | enum / cert |
|---|---|---|---|---|---|---|---|---|
| mse_d24_w32_s300 | 7.1e-2 | 1193958 | 1.1e6 | 3.6e5 | 1.6e4 | 1.35e6 | 0.014 | 1.2 |
| mse_d24_w32_s600 | 8.3e-3 | 138936 | 7.5e5 | 5.7e5 | 1.3e5 | 1.35e6 | 0.18 | 1.8 |
| mse_d24_w32_s1000 | 3.6e-4 | 6012 | 3.5e5 | 4.5e5 | 3.1e6 | 1.35e6 | 9 | 3.9 |
| mse_d24_w32_s1500 | 9.7e-6 | 163 | 1.8e5 | 2.9e5 | 1.1e8 | 1.35e6 | 640 | 7.5 |
| mse_d24_w32_s2000 | 6.0e-8 | 1 | 1.1e5 | 1.7e5 | 1.9e10 | 1.35e6 | 1.8e5 | 13 |
| bce_d28_w32_s30 | 1.9e-3 | 507779 | 3.2e6 (budget hit) | 8.3e5 | 5.9e5 | 1.85e7 | 0.18 | 5.8 |
| bce_d28_w32_s60 | 1.3e-5 | 3543 | 1.7e5 | 2.6e5 | 8.4e7 | 1.85e7 | 500 | 110 |
| bce_d28_w32_s100 | 7.5e-9 | 2 | **1.6e4** | 2.2e4 | 1.5e11 | 1.85e7 | **9.5e6** | 1200 |
| bce_d28_w32_s150 | 0 | 0 | **2.0e3** | 2.3e3 | (MC cannot certify 0) | 1.85e7 | - | 9400 |
| mse_d28_w64_s1000 (Knuth) | 3.3e-7 | 89 | 4.6e6 | 9.0e6 | 3.3e9 | 1.85e7 | 720 | 4.0 |
| mse_d28_w64_s1500 (Knuth) | 0 | 0 | 2.7e6 | 5.4e6 | - | 1.85e7 | - | 6.9 |

Argument sizes (deductive part, 8 bytes per number): 0.29 MB for bce_d28_w32_s150, 2.5 MB for
bce_d28_w32_s100, 12 to 50 MB for the others, almost all of it the slopes of the SAFE leaves (any
value in [0, 1] is valid, so 8-bit slopes would cut this by 8). Each verification took at most
36 s of numpy on the shared machine.

Two hidden layers (`mse_d28_w32x32_*`, `bce_d28_w64x64_*`, Knuth estimates in `results/knuth_suite.json`):
the verifier's intermediate bounds are so loose (gap 2 to 12 at r = 10 to 16, table 2) that
the uncollapsed tree costs 1 to 5 times the enumeration of the cube (1.5e8 to 1.9e8 fpe), so
the best certificate is plain enumeration; for these nets (p >= 1.9e-5) Monte Carlo is cheaper
except for `bce_d28_w64x64_s100`, where p = 0 and enumeration (1.9e8 fpe) is the only exact answer.

Hybrid arguments (failure-containing subtrees sampled, sized for ratio 1.1): they help only when
the failures are many (`F` above ~1e3) and then Monte Carlo is cheaper still, because sampling an
open leaf costs a full evaluation while enumerating it costs ~2/d of one. Measured (every
interval contained p, ratios 1.08 to 1.10): 5.0e4 fpe for mse_d24_w32_s300 (exact certificate
1.1e6, MC 1.6e4), 4.3e5 for s600 (7.5e5, MC 1.3e5), 1.9e6 for bce_d28_w32_s30 (3.2e6, MC
5.9e5); with fewer failures the hybrid argument is the exact certificate. (A first version sized
the sample by a Gaussian approximation and returned a valid but loose interval, ratio 4.7, when
an open subtree held a single failing point; the count now includes the no-hit term
3 ln(2/delta) Z / (eps F).)
`quad` (degree-2) certificates, Knuth estimates over the 17 one-hidden-layer suite nets: they
shrink the tree by 1.1-4.1x (e.g. 2.6e5 -> 1.5e5 nodes for mse_d24_w32_s1500, 3.7e13 -> 9.0e12
for bce_d64_w64_s100) but raise the verifier's cost by 1.1-6.6x, because one quad check (forming
the (r+1)x(r+1) matrix, ~4 m_1 r^2 flops, and one Cholesky factorisation) costs 10-30 lin
checks. `quad` gives the smallest arguments, `lin` the cheapest verification.

### 2. Why: the relaxation gap against the margin

`gap_scan.py`: random subcubes of dimension r; margin = exact min f - t, gap = exact min minus the
certified bound (medians of 12; `centre >= t` held for every r <= 16).

| net | r = 6: margin / gap lin / gap quad | r = 8 | r = 10 | r = 12 | r = 16 |
|---|---|---|---|---|---|
| mse_d24_w32_s1500 | 0.22 / 0.26 / 0.16 | 0.21 / 0.68 / 0.43 | 0.18 / 1.02 / 0.63 | 0.12 / 1.23 / 0.75 | 0.03 / 1.96 / 1.18 |
| mse_d28_w64_s1500 | 0.35 / 0.35 / 0.22 | 0.34 / 0.47 / 0.33 | 0.27 / 0.75 / 0.47 | 0.24 / 1.13 / 0.68 | 0.16 / 1.65 / 1.04 |
| bce_d28_w32_s100 | 2.05 / 0.13 / 0.07 | 1.87 / 0.28 / 0.20 | 1.48 / 0.41 / 0.28 | 1.21 / 0.52 / 0.40 | 0.76 / 0.71 / 0.53 |
| mse_d28_w32x32_s500 | 0.23 / 0.63 / 0.60 | 0.20 / 1.31 / 1.31 | 0.10 / 1.97 / 1.97 | 0.04 / 2.41 / 2.39 | 0.00 / 4.14 / 4.14 |
| bce_d28_w64x64_s100 | 2.21 / 2.10 / 1.96 | 1.84 / 3.67 / 3.47 | 1.95 / 5.39 / 5.18 | 1.52 / 7.40 / 7.10 | 1.16 / 11.9 / 11.4 |
| mse_d64_w64_s1000 | 0.34 / 0.13 / 0.09 | 0.35 / 0.21 / 0.16 | 0.25 / 0.34 / 0.23 | 0.24 / 0.54 / 0.36 | 0.07 / 0.85 / 0.57 |
| mse_d64_w64_s3000 | 0.41 / 0.07 / 0.06 | 0.42 / 0.10 / 0.09 | 0.38 / 0.15 / 0.13 | 0.38 / 0.22 / 0.16 | 0.33 / 0.40 / 0.31 |
| bce_d64_w64_s1000 | 6.62 / 0.13 / 0.10 | 6.22 / 0.25 / 0.21 | 6.14 / 0.43 / 0.34 | 5.66 / 0.47 / 0.37 | 5.50 / 0.87 / 0.70 |

* **Squared loss.** Training kills the linear part of f (level-1 Fourier weight 0.3 to 1.8% of
  Var f on the one-hidden-layer squared-loss nets, against 37 to 62% on the logistic nets
  trained for <= 100 steps), so the variation is in the even part `(1/2) sum_j a_j |z_j|`, and
  failures are small-ball events of the hidden pre-activations. The cube's centre is a point of
  every box relaxation where all `|z_j|` are small at once: f(0) < t on all nine one-hidden-layer
  squared-loss nets with d <= 28 (f(0) - t from -0.02 to -0.33) and on mse_d64_w64_s300/s1000,
  so **no relaxation over the box (LP, CROWN, MILP over the box, any convex relaxation) can
  certify the root** of these nets, whatever their p. Below
  the root the box centre is fine but the gap grows like r^1.5 to r^1.9 (r = 4 to 16) while the margin
  shrinks: certified leaves have r* ~ 6-7 free inputs at d = 24-28 and ~10 at d = 64, so the
  tree has ~2^(d - r*) leaves. The degree-2 certificate uses `x_i^2 = 1` and removes 35-40% of
  the gap at every r (one or two more free inputs per leaf, 1.7-4x fewer nodes), but degree-2
  reasoning about `|z|` is `|z| >= z^2 / U` with U the L1 range of z, which loses a factor
  ~ ||v||_1 / ||v||_2 ~ sqrt(r) on exactly the small-ball term.
* **Logistic loss (one hidden layer).** Margins are 3 to 15 times the gap at r = 10 (the
  logit's mean grows with training much faster than its fluctuations, and up to half of Var f is
  linear, which linear relaxations handle exactly), leaves have 10 to 23 free inputs, and trees
  are small. This is the regime with short certificates.
* **Two hidden layers.** The gap is dominated by the second layer's intermediate intervals
  (computed by the verifier with default slopes): 2 to 12 at r = 10 to 16.
* **Near-failure accounting.** A SAFE leaf of dimension r needs its subcube's minimum above
  t + G(r). With G(r) the measured gap, `nearfail.py` estimates Pr[f < t + G(r)]: for
  mse_d24_w32_s1500 it is 2.7e-4, 1.7e-3, 0.27, 1.0 at r = 4, 6, 8, 10 (so no leaf with 10 free
  inputs is certifiable, as observed: 99.9% of its certified leaves have r <= 9), for
  mse_d64_w64_s1000 it is 0.08 at r = 10 and 0.6 at r = 12, for bce_d64_w64_s1000 none of
  4e6 samples is below t + G(r) for any r <= 16. The certificate pays for every point within the gap of the threshold,
  not only for the failing ones: that is why it is exponential in d unless the margin exceeds
  the gap at large r.

### 3. Scaling with d

`scaling.py`: one hidden layer of width 32 trained by `train_constant` (three seeds per point;
medians of the Knuth estimate of the uncollapsed `lin` tree; where the real collapsed
certificate was also built (d <= 24, 48 nets) the ratio Knuth / real is between 0.72 and 1.43).

| family (p at the shown d) | d = 12 | 16 | 20 | 24 | 28 | 32 | 40 | 48 | 64 | log2(cost) per input |
|---|---|---|---|---|---|---|---|---|---|---|
| squared loss, 1500 steps (z = 6-9, p = 0 by MC up to d = 64) | 2.0e2 | 5.8e2 | 7.4e3 | 1.8e4 | 2.9e5 | 2.2e6 | 3.0e8 | 1.5e9 | 4.7e12 | 0.68 |
| squared loss, 600 steps (p = 1e-5 to 1e-3) | 6.3e2 | 2.2e3 | 2.5e4 | 1.3e5 | 1.9e6 | 2.7e7 | | | | 0.78 |
| logistic, 100 steps (p = 0 to 1e-2) | 2.1e2 | 3.0e3 | 2.1e4 | 8.9e4 | 9.2e4 | 1.8e5 | 2.5e9 | 4.7e10 | 7.3e15 | 0.85 |
| logistic, 60 steps (p = 1e-6 to 0.15) | 5.1e2 | 9.2e3 | 6.6e4 | 5.3e5 | 1.5e6 | 3.1e6 | | | | 0.63 |
| enumeration of the cube | 6.9e2 | 8.0e3 | 1.0e5 | 1.35e6 | 1.85e7 | 2.6e8 | 5.4e10 | 1.2e13 | 5.7e17 | 1.0 |

(p for d >= 28 is a Monte Carlo estimate from 10^6 samples; the per-seed values are in
`results/summary.md`.) The certificate grows like 2^(0.6 to 0.9 d) at a fixed training recipe (and depends strongly on
the margin: at d = 40 the three squared-loss seeds with z = 8.5, 5.3, 4.7 need 1.5e6, 3e8 and
1.4e9 fpe). Monte Carlo's cost 1100/p does not grow with d. For the 600-step squared-loss family
(p ~ 1e-4) the certificate beats Monte Carlo up to d ~ 28 (1.9e6 against ~5e6) and loses from
d ~ 32 on (2.7e7 against ~1e7); for p ~ 1e-6 (d = 40, seed 0: one hit in 10^6 samples) the two
are about equal (1.4e9 against ~1e9). Rule of thumb from these runs: the deductive certificate beats sampling only when
p < ~2^-(0.75 d) * 1e3.

### 4. d = 64 and d = 128

No exact p. Three kinds of evidence (one hidden layer unless noted):

* **Knuth estimates of the whole certificate** (`lin`, `results/knuth_suite.json`):

  | net | z | estimated nodes | verifier fpe | enumeration fpe | what MC can say with as many fpe |
  |---|---|---|---|---|---|
  | mse_d64_w64_s300 | 1.7 | 4.8e17 | 2.2e17 | 5.7e17 | p ~ 4% (MC is the method) |
  | mse_d64_w64_s1000 | 4.4 | 4.1e16 | 1.0e16 | 5.7e17 | p ~ 1.5e-5 (3 hits in 2e5 samples); MC needs ~1e8 |
  | mse_d64_w64_s3000 | 10.0 | 1.3e14 | 5.0e13 | 5.7e17 | p <= 7e-14 |
  | bce_d64_w64_s100 | 4.5 | 3.7e13 | 1.5e13 | 5.7e17 | p <= 2.5e-13 |
  | bce_d64_w64_s300 | 7.1 | 1.5e10 | 9.0e9 | 5.7e17 | p <= 4e-10 |
  | bce_d64_w64_s1000 | 8.8 | 2.9e7 | 2.1e7 | 5.7e17 | p <= 1.8e-7 |
  | bce_d128_w128x128_s1000 (two layers; 8 probes, default slopes) | 7.8 | 1.2e33 | 1.8e35 | 1.7e38 | - |
  | bce_d128_w128x128_s300 (same) | 6.5 | 1.2e34 | 1.8e36 | 1.7e38 | - |
  | bce_d128_w128x128_s100 (same) | 5.3 | 5.5e34 | 8.0e36 | 1.7e38 | - |
* **Verified pieces** (`subtree_d64.py`): follow the prover's own splits along a random path for
  k steps, build and verify the complete certificate of the subcube reached.
  Every piece below was certified exactly (no open leaf) and contains no failing point.

  | net | k | pieces (free inputs, nodes, verifier fpe, verify seconds) | whole-cube estimate (fpe) |
  |---|---|---|---|
  | bce_d64_w64_s1000 | 8 | 4 pieces of r = 56: 1.9e5 to 2.7e5 nodes, 1.3e5 to 1.9e5 fpe, 24 to 35 s | 3.9e7 |
  | bce_d64_w64_s300 | 17 | 2 pieces of r = 47: 2.2e5 and 4.3e5 nodes, 1.3e5 and 2.4e5 fpe | 2.4e10 |
  | bce_d64_w64_s100 | 29 | 2 pieces of r = 35: 5.5e3 and 9.0e3 nodes | 1.8e12 |
  | mse_d64_w64_s3000 | 31 | 2 pieces of r = 33: 2.7e4 and 3.0e4 nodes | 2.6e13 |
  | mse_d64_w64_s1000 | 40 | 2 pieces of r = 24: 3.7e4 and 4.7e4 nodes | 1.2e16 |

  The estimates agree with the Knuth estimates within a factor 1.2 to 8 (few paths, so these are rough).
* **Budgeted whole-cube runs** (`large_d.py`): with 2e5 nodes the breadth-first prover reaches
  depth ~17, where no subcube (47 free inputs) of mse_d64_w64_s300/s1000/s3000 or
  bce_d64_w64_s100 is certifiable, so the open part is the whole cube and the interval is Monte
  Carlo's (e.g. [1.8e-6, 5.2e-5] for mse_d64_w64_s1000 from 2e5 samples). Partial certificates
  give nothing until the tree reaches the depth of its leaves (22 to 57 here).

So at d = 64 a short certificate exists, in practice, for the logistic net trained longest
(bce_d64_w64_s1000: the exact p, 0 on every piece checked, provable with ~5e7 nodes, about the
work of 4e7 Monte Carlo samples, which could only show p <= 1e-7), is large but finite for bce_d64_w64_s300 (~1e10), and is out
of reach for the squared-loss nets and for bce_d64_w64_s100 (1e13 to 1e17), where p > 0 or the
margin is small; there two-sided sound intervals come from sampling only.

### 5. Soundness checks (`check_soundness.py`, `results/soundness.json`)

24 nets (16 with random weights at scales 1e-6 to 1e6 and one or two hidden layers, 4 with
small-integer weights and 10-13 exact ties f = t each, one where float64 evaluates a failing point
to exactly t (f = 1/2 - 2^-60), 3 trained), d = 6 to 10, all checked against exact rational counts:

* 15,084 bound checks (`lin` with default, optimised and random slopes, for f and -f; `quad` from
  the optimiser, with random parameters, and with the optimiser's shift increased by 1e-12 to
  1e-3): **0** certified bounds above the exact minimum;
* 120 honest exact certificates (48 of the whole cube, 72 of random subcubes via `root`):
  **0** counts different from the exact one;
* 528 dishonest or malformed arguments (21 kinds per net: forged SAFE/FAIL leaves with garbage,
  NaN, wrong-shape or huge parameters, missing or unknown certificates, splits on fixed,
  out-of-range, float or boolean coordinates, truncated / extended / empty trees, unknown node
  kinds, bad sample budgets, ENUM above the verifier's cap): **0** intervals missing p (192
  rejected as malformed, 8,621 leaves demoted to sampling);
* 600 sampled (hybrid) runs at delta = 0.1: 7 misses (1.2%);
* 24 witness lists with duplicates, non-failing and malformed points: 0 errors.

## Relation to the paper's barriers; for which nets do short certificates exist?

* **coNP in MA.** One hidden layer of ReLUs can encode any 3-CNF with the event "no clause
  violated" (one unit per clause), so `p = 0` for this architecture is coNP-hard to decide, and
  by the paper's Theorem (no complete upper-bound arguments) no sound argument system has short
  upper-bound certificates for all nets of the architecture unless coNP is in MA. Our verifier is
  sound on every net (adversarial weights, exact ties, extreme scales included); completeness can
  only be a property of the trained nets, and the experiments say which.
* **Black-box barrier.** Inside OPEN leaves the verifier only evaluates f, so there it pays
  Z_open / p samples (surprise accounting); every bit of upper bound below the sampling scale
  comes from the deductive (SAFE/FAIL/ENUM) part, which must exclude all non-failing mass to
  within eps p.
* **Short certificates plausibly exist exactly when the margin min f - t exceeds the deductive
  gap at large subcube dimension**, i.e. for nets trained well past the point where p becomes 0,
  with a large linear component (logistic loss): `bce_d28_w32_s150` (p = 0, 2.3e3 nodes),
  `bce_d28_w32_s100` (p = 7.5e-9, 2.2e4 nodes), `bce_d64_w64_s1000` (p = 0 on every piece we
  certified, ~5e7 nodes for the whole cube, see 4). For squared-loss nets the even (small-ball) structure puts every point
  within the gap of t into the certificate, the root is blocked by the box barrier, and the size
  grows like 2^(0.7 to 0.8 d) (certified leaves have r* ~ 6 free inputs at d = 24, ~10 at d = 64); for two hidden layers the gap of
  bound propagation itself is the obstacle. For p > 0 at d = 64 the only practical sound
  two-sided method we found is Monte Carlo (equivalently, the envelope estimator with the trivial
  envelope); the prover helps with lower bounds (witness lists, proposals) but not with upper
  bounds at that scale.
* What would change this: certificates whose gap does not grow with r on small-ball events
  (e.g. degree-4 sum-of-squares, which can capture E|z| >~ sqrt(E z^2)/3 through
  hypercontractivity, or MILP-style phase splitting with Boolean cuts beyond the box); we did not
  build them.

## Files

* `knuth_suite.py`: Knuth estimates for every suite net (`results/knuth_suite.json`).
* `run_suite.py`: real prover + verifier on the suite nets with exact p (`results/suite_lin.json`;
  `results/suite_lin_rerun.json` holds the four nets rerun after the fix of the hybrid sample
  count, and supersedes their entries).
* `gap_scan.py`, `nearfail.py`: relaxation gap vs margin, near-failure counts.
* `scaling.py`: certificate cost vs d on nets trained here (`results/scaling.json`).
* `subtree_d64.py`: verified certificates of random pieces of the d = 64 nets
  (`results/subtree_d64.json`, `results/subtree_d64_b.json`); `knuth_d128.py`: rough Knuth
  estimates for the d = 128 nets (`results/knuth_d128.json`).
* `large_d.py`: budgeted certificates + sampling at d = 64 (`results/large_d.json`).
* `check_soundness.py`: soundness tests (`results/soundness.json`).
* `summarize.py`: all tables (`results/summary.md`).

Reproduce: `cd experiments/nets_prover && python3 check_soundness.py && python3 knuth_suite.py &&
python3 run_suite.py lin 5 1e6 && python3 gap_scan.py && python3 nearfail.py && python3 scaling.py
&& python3 subtree_d64.py && python3 summarize.py` (pure numpy/scipy; hours on a shared 4-core machine).
