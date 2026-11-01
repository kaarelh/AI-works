# Prover-assisted certificates for nets trained to output 1

Code: [`code/rareprob/nets_prover.py`](../../code/rareprob/nets_prover.py), tests:
[`code/tests/test_nets_prover.py`](../../code/tests/test_nets_prover.py). Question: for a ReLU MLP `f`
trained to output 1 on uniform `x` in `{-1,+1}^d`, with rare event `E = [f(x) < t]` (`t = 1/2` for
squared loss, `t = 0` for the logit), what argument can an unbounded prover send so that a
polynomial-time verifier gets a **sound** two-sided interval for `p = |E| / 2^d` cheaply (Part 2 of the
paper, proof-carrying importance sampling)?

**Costs** are reported twice:

* in forward-pass equivalents (fpe): the flops the verifier *as implemented* performs (its matrix
  products; every leaf recomputes its first-layer offsets) divided by the flops of one forward pass,
  `2 sum_k m_k m_(k-1)`. Monte Carlo (MC) costs `3 ln(2/delta) / (eps^2 p)` fpe for ratio `1 + eps`;
  here `eps = 0.1`, `delta = 0.05`. "Enum" is the verifier enumerating the whole cube (meet in the middle
  on the first layer);
* in wall-clock seconds, for the prover and the verifier separately, and for MC (measured time per sample
  of a batched numpy forward pass, times the sample count) and enumeration (measured). **All times are on
  a shared 4-core machine with other jobs running concurrently** (numpy, one BLAS thread per process), so
  they indicate orders of magnitude only.

The previous version of this verifier counted the flops of an incremental verifier that was never
implemented (2 to 4 times fewer per leaf) and reported no prover time; both are fixed here.

## The argument

A **certified partition**: a binary decision tree over input coordinates (its leaves partition the cube
into subcubes), with leaves

* `SAFE(cert)`: `cert` proves `f >= t` on the subcube; `FAIL(cert)`: proves `f < t` on it;
* `ENUM`: the verifier enumerates the subcube (meet in the middle, exact tie handling);
* `OPEN`: the subcube joins an envelope (union of subcubes, exact mass, exact sampler) that the verifier
  samples (`N` samples, KL interval).

Leaf certificates (the prover's free parameters; the verifier recomputes everything else):

* `lin`: linear bound propagation (CROWN/DeepPoly type) with prover-chosen slopes `alpha in [0,1]` for
  every unstable unit relaxed from below, chords from above; the verifier recomputes the intervals (and,
  for two hidden layers, the intermediate bounds). For one hidden layer the best slopes give the LP
  (triangle) relaxation over the subcube's box.
* `quad`: a degree-2 Shor / S-lemma certificate that uses `x_i^2 = 1` (so it is **not** bounded by the box
  relaxation): per first-layer unit a valid quadratic minorant / majorant of `relu` on its interval (two
  prover parameters per unit), giving `f(y) >= Y^T M Y` on the subcube; the prover sends `mu` and a shift
  `s` with `M - diag(mu) - s I` PSD, checked by one Cholesky factorisation; then `f >= sum(mu) + (r+1) s`.

Verifier output: `p in [(F + Z l)/2^d, (F + Z u)/2^d]`, `F` the exact count in ENUM/FAIL leaves, `Z` the
open mass, `[l, u]` the KL interval of the sampled failure fraction. With no open leaf the output is
**exactly `p`**, deterministically. Lower bounds need no deduction: `witness_lower_bound` checks a list
of failing points.

## Soundness on every net, every argument, every float64 input

The verifier parses the tree itself (malformed trees give `[0,1]`); a leaf certificate that is missing,
malformed, non-finite or fails its check is *demoted* to an open (sampled) leaf, so it can only cost time;
ENUM leaves above 30 free inputs are demoted, and samples are capped, so its work is polynomial in the
argument. What changed in this version is the arithmetic of the SAFE/FAIL checks.

**The red team broke the previous version** (deterministic, "exact" wrong answers `[0, 0]` at `p = 1/2`):

1. *underflow in `lin`*: a subnormal product `G lambda` (e.g. output weight `-2^-1074`, first-layer
   weights `~4e289`) rounded to zero and was then multiplied by huge first-layer quantities, while the
   rounding budget had only an absolute `2^-1000` term; exact power-of-two ReLU rescalings of ordinary
   nets (which leave `p` unchanged) gave a wrong exact count;
2. *underflow in `quad`*: `G kap` rounded to zero dropped the majorant term that makes `q >= relu` valid;
   a malicious `theta` at output scale `2^-53` made it round up and certified `0.5475 S` against a true
   minimum `0.3 S`;
3. *the drop rule*: a unit whose backward coefficient `G` had uncertain sign was dropped and charged
   `5 REL |G|_abs U`, which left out `G`'s own rounding (two hidden layers, O(1) weights, crafted
   cancellation; 9e-18 below `t`);
4. (cost only) the point tolerance had an absolute floor `2^-30`, so at output scale `2^-40` every point
   went to exact rational evaluation; the prover crashed (NaN in `eigh`) on nets with huge first-layer
   weights; nets whose bounds exceeded `1e290` were refused.

**Fix: outward-rounded interval arithmetic.** Every quantity in a SAFE/FAIL check is now a pair of floats
enclosing the exact real number that the certificate's mathematics refers to. Soundness rests on two
elementary facts about IEEE binary64 with rounding to nearest, gradual underflow included:

* (R1) one operation `+ - * / sqrt` with computed result `r` (not NaN) has its exact value in
  `[nextafter(r, -inf), nextafter(r, +inf)]`, also when `r` overflowed and in the subnormal range;
* (R2) a matrix product `C = fl(A B)` with inner dimension `n`, in any summation order, with or without
  FMA, satisfies `|C - A B| <= gamma_n |A||B| + n 2^-1074` entrywise (Higham, Lemma 3.5, with the
  underflow model `fl(x op y) = (x op y)(1 + d) + e`, `|e| <= 2^-1075`), and `fl(|A| |B|)` bounds
  `|A||B|` from above after a factor `1 + 2 gamma_n` and `2 n 2^-1074`.

Concretely: the error of every matrix product is enclosed where it happens and then propagated through
the later products (so a subnormal coefficient multiplied by `1e289` carries its uncertainty with it);
the side on which an unstable ReLU is relaxed is chosen from the *enclosure* of `G_j` (below if
`G_j >= 0` surely, above if `G_j <= 0` surely, otherwise the unit is dropped and charged `G_lo,j U_j`,
valid because `0 <= h_j <= U_j`); chord slopes are `U / dn(U - L)` rounded up (valid by construction,
no re-check); the quadratic pieces of `quad` are validated by interval evaluation of their defining
inequalities, with the constant term chosen by the verifier as the best value the proof allows; `M` is
enclosed entrywise and the PSD test covers every symmetric matrix in the enclosure (exact power-of-two
scaling, Cholesky of `mid - c I`, Higham's Theorem 10.3 with the underflow of products and divisions
added, and a final check that `c` exceeds the backward error, the rounding of the shift and the
Frobenius norm of the radius); a bound that is not finite rejects the certificate. Points are classified
with a forward error bound `tau` computed layer by layer (gamma terms plus the underflow of every
product, propagated through `|W|`), with no absolute floor, so `tau` scales with the net; points within
`tau` of `t`, and points whose float value is not finite, are re-evaluated in rational arithmetic. Any
finite float64 weights are accepted (non-finite weights or threshold raise `ValueError`).

**Prover side** (completeness, not soundness). Both the prover's and the verifier's checks are rigorous,
but they compute the same enclosures in differently batched matrix products, which round differently in
the last bits; the soundness campaign found one `quad` leaf that the prover accepted and the verifier
then demoted (a sound, but not exact, answer). The prover now checks `quad` certificates exactly as the
verifier will and accepts a leaf only if its bound clears `t` by `2^-30 |f|_abs`.

**Tests** (`code/tests/test_nets_prover.py`, 44 tests, ~30 s): every red-team counterexample is a
regression test (the hand-built `lin` and `quad` underflow nets, the malicious-`theta` net at scale
`2^-53`, the drop-rule net and 40 ulp-neighbours of it with `t` at the certified bound, the random
subnormal rescalings `lin_sub` / `quad_sub`, the scale-invariance of `tau`, the prover on huge weights);
run against the previous verifier through a compatibility shim, 13 of them fail, and all pass now. Further
tests: the interval primitives against exact rational products and sums (entries down to `2^-1100` and up
to `2^600`), the PSD test on boxes that contain an indefinite matrix (scales `2^-1000` to `2^900`), every
quadratic piece checked to be a minorant / majorant in exact arithmetic, exact ties, a failing point that
float64 evaluates to exactly `t`, overflowing bounds and points, a small soundness campaign, dishonest and
malformed arguments, subcube arguments, hybrid coverage, witness lists, and the agreement of the
prover's checks with the verifier's (a regression test from the soundness campaign, see section 5).

## Results

All tables are generated by `summarize.py` from `results/*.json` (also `results/summary.md`, and the
rows of the headline tables in `results/tables.json`).

### 1. Suite nets with exact p (d <= 28): exact certificates

`run_suite.py`: the prover first plans with a Knuth estimate of its tree (64 probes, about a second): if
the tree fits in memory it builds a `lin` argument (`r_leaf = 5`, subtrees replaced by ENUM wherever
that is cheaper to verify) and the verifier checks it; if the estimate is not below 0.7 times the cost of
enumeration, the prover sends the trivial argument `[ENUM]` (an exact certificate by enumeration);
in between, the argument is built and checked in pieces. **Every count is exact and equals the suite's
`fail_count`.** Costs: verifier fpe, then wall-clock seconds of verifier / prover (with its plan); MC at
`eps = 0.1`, `delta = 0.05`; enumeration measured. Shared 4-core machine, other jobs running.

| net | p | argument | nodes | verifier fpe | verifier s | prover s | MC fpe | MC s | enum fpe | enum s |
|---|---|---|---|---|---|---|---|---|---|---|
| mse_d24_w32_s300 | 0.071 | certificate | 42227 | 1.3e+06 | 7.2 | 1.1e+02 | 1.6e+04 | 0.0069 | 1.3e+06 | 5.4 |
| mse_d24_w32_s600 | 0.0083 | certificate | 177329 | 1.2e+06 | 7.5 | 76 | 1.3e+05 | 0.065 | 1.3e+06 | 5.1 |
| mse_d24_w32_s1000 | 0.00036 | certificate | 305973 | 8.7e+05 | 8 | 49 | 3.1e+06 | 1.1 | 1.3e+06 | 5.2 |
| mse_d24_w32_s1500 | 9.7e-06 | certificate | 253127 | 5.4e+05 | 5 | 29 | 1.1e+08 | 48 | 1.3e+06 | 5.8 |
| mse_d24_w32_s2000 | 6e-08 | certificate | 160647 | 3.2e+05 | 2.4 | 16 | 1.9e+10 | 7.1e+03 | 1.3e+06 | 5.2 |
| mse_d28_w64_s300 | 0.013 | [ENUM] | 1 | 1.9e+07 | 1.5e+02 | 1.3 | 8.6e+04 | 0.07 | 1.9e+07 | 1.5e+02 |
| mse_d28_w64_s600 | 6e-05 | [ENUM] | 1 | 1.9e+07 | 1.5e+02 | 1.1 | 1.8e+07 | 13 | 1.9e+07 | 1.5e+02 |
| mse_d28_w64_s1000 | 3.3e-07 | [ENUM] | 1 | 1.9e+07 | 1.5e+02 | 1.5 | 3.3e+09 | 2.6e+03 | 1.9e+07 | 1.5e+02 |
| mse_d28_w64_s1500 | 0 | certificate (32 pieces) | 4983651 | 1e+07 | 1.3e+02 | 8e+02 | - | - | 1.9e+07 | 1.4e+02 |
| mse_d28_w32x32_s100 | 0.06 | [ENUM] | 1 | 1.5e+08 | 2e+02 | 6.8 | 1.8e+04 | 0.016 | 1.5e+08 | 2e+02 |
| mse_d28_w32x32_s200 | 0.015 | [ENUM] | 1 | 1.5e+08 | 2e+02 | 7.1 | 7.5e+04 | 0.062 | 1.5e+08 | 2e+02 |
| mse_d28_w32x32_s300 | 0.0036 | [ENUM] | 1 | 1.5e+08 | 1.9e+02 | 6.5 | 3.1e+05 | 0.28 | 1.5e+08 | 1.9e+02 |
| mse_d28_w32x32_s500 | 0.00013 | [ENUM] | 1 | 1.5e+08 | 2e+02 | 7.2 | 8.2e+06 | 7 | 1.5e+08 | 2e+02 |
| bce_d28_w32_s30 | 0.0019 | certificate | 1201597 | 3.4e+06 | 39 | 2.1e+02 | 5.9e+05 | 0.23 | 1.9e+07 | 71 |
| bce_d28_w32_s60 | 1.3e-05 | certificate | 237621 | 5e+05 | 5.9 | 31 | 8.4e+07 | 32 | 1.9e+07 | 65 |
| bce_d28_w32_s100 | 7.5e-09 | certificate | 20789 | 4.1e+04 | 0.31 | 3.9 | 1.5e+11 | 6.7e+04 | 1.9e+07 | 69 |
| bce_d28_w32_s150 | 0 | certificate | 2061 | 4.1e+03 | 0.032 | 1.4 | - | - | 1.9e+07 | 74 |
| bce_d28_w64x64_s20 | 0.093 | [ENUM] | 1 | 1.9e+08 | 5e+02 | 24 | 1.2e+04 | 0.02 | 1.9e+08 | 5e+02 |
| bce_d28_w64x64_s40 | 0.0023 | [ENUM] | 1 | 1.9e+08 | 4.7e+02 | 24 | 4.8e+05 | 0.79 | 1.9e+08 | 4.7e+02 |
| bce_d28_w64x64_s60 | 1.9e-05 | [ENUM] | 1 | 1.9e+08 | 4.6e+02 | 22 | 5.9e+07 | 1e+02 | 1.9e+08 | 4.6e+02 |
| bce_d28_w64x64_s100 | 0 | [ENUM] | 1 | 1.9e+08 | 4.9e+02 | 21 | - | - | 1.9e+08 | 4.9e+02 |

* **Against Monte Carlo.** In fpe the certificate wins for `p <= 4e-4` (3.5x at 3.6e-4, 210x at
  9.7e-6, 5.8e4x at 6e-8 for squared loss; 170x at 1.3e-5 and 3.6e6x at 7.5e-9 for logistic loss) and
  loses for `p >= 2e-3`. End to end in wall-clock (prover + verifier against MC's measured time) it wins
  only for `p <~ 1e-5`: 1.4x at 9.7e-6, 390x at 6e-8, 1.6e4x at 7.5e-9 (4.2 s against 18.6 hours), and
  it loses (0.86x) at 1.3e-5. `p = 0` (bce_d28_w32_s150) is certified in 1.4 s; MC cannot certify 0.
  Where the plan is enumeration, enumeration itself beats MC for `p <~ 1e-5` (mse_d28_w64_s1000,
  p = 3.3e-7: 150 s against 2,600 s).
* **Against enumeration.** For squared loss at d = 24 the certificate is only 1.0 to 4.2 times cheaper
  than enumerating the cube in fpe; in wall-clock enumeration (5 to 6 s) beats prover + verifier (18 to
  113 s) on every net, and the verifier alone is faster than enumeration only for p <= 9.7e-6 (1.15x and
  2.1x). At d = 28, width 64 (squared loss), the plan puts the certificate at 0.9 to 1.6 times
  enumeration, so the argument is enumeration (about 150 s), except for the p = 0 net, certified in 32
  pieces: 0.55 times enumeration in fpe, but 128 s against 145 s in wall-clock, after 800 s of proving.
  For logistic loss at d = 28 the certificate is 5 to 4500 times cheaper in fpe, and end to end 1.8x
  (p = 1.3e-5), 16x (p = 7.5e-9) and 51x (p = 0) faster than enumeration (but 0.29x at p = 1.9e-3).
* **Wall-clock per fpe.** The numpy verifier costs 5 to 13 us per fpe on certificate leaves, against
  0.34 to 2.1 us per MC sample (batched numpy forward pass), so fpe flatters the verifier by a factor of
  roughly 5 to 30; enumeration costs about 8 us per fpe (0.55 us per point) for one hidden layer and 1.3
  to 2.6 us per fpe for two. The prover costs 5 to 15 times the verifier (44 for the 2,061-node p = 0
  certificate, where fixed costs dominate); it was 10 to 30 times, and 2 to 10 times slower per node, in
  the previous version.
* **Two hidden layers.** The Knuth plan puts the certificate at 1.2 to 2.3 times enumeration on every
  two-hidden-layer net (the gap of bound propagation is 2 to 12 at r = 10 to 16, section 4), so the
  argument is enumeration (200 to 500 s); MC is cheaper (0.02 to 100 s) except at p = 0
  (bce_d28_w64x64_s100, enumerated in 490 s).
* **`quad` leaves** (`SUITE_KINDS=lin+quad`, four nets, `results/suite_cert_lin+quad.json`): exact on
  all four, and the fixed `quad` check works end to end (265 to 38,605 accepted `quad` leaves per net, 0
  demoted). Trees are 2.0 to 2.1 times smaller than with `lin` alone, but verification costs 1.5 to 3.4
  times more fpe and 10 to 17 times more wall-clock, and proving 30 to 50 times more: `quad` gives the
  smallest arguments, `lin` the cheapest verification.
* **Hybrid arguments** (failure-containing subtrees sampled, sized for ratio 1.1): every interval
  contained p (ratios 1.088 to 1.114), but they pay off only when failures are many, and then MC is
  cheaper still: 5.0e4 fpe for mse_d24_w32_s300 (MC 1.6e4), 4.3e5 for s600 (MC 1.3e5), 1.9e6 for
  bce_d28_w32_s30 (MC 5.9e5).
* Argument sizes: 0.25 MB (bce_d28_w32_s150) to 74 MB (bce_d28_w32_s30), and 674 MB over the 32 pieces
  of mse_d28_w64_s1500, almost all of it slopes of SAFE leaves (any value in [0, 1] is valid, so 8-bit
  slopes would cut this by 8). No point needed exact rational evaluation on these nets.

### 2. d = 64: certifying p = 0 for bce_d64_w64_s1000 (two-hour attempt)

`full_d64.py bce_d64_w64_s1000 10 110 4`: the top 10 levels of the tree follow the prover's own splits
(1024 pieces of 54 free inputs; the top tree is checked by `verify` as a partition of the cube), then
each piece is proved (`prove(root=piece)`: `lin`, strong branching over 2 coordinates, up to 100 slope
steps with early stopping) and checked (`verify(root=piece)`) in a worker process and discarded (the
whole argument would be ~10 GB, mostly 8-byte slopes). Pieces run in a uniformly random order, so the
pieces done are a uniform sample. Budget: 110 minutes of wall-clock (no piece started after it), 4
worker processes on the shared 4-core machine, which ran 3 to 4 other CPU-bound jobs throughout.

| | result |
|---|---|
| pieces certified | **691 of 1024, every one exactly, with 0 failing points** (0 leaves demoted, 0 exact re-evaluations) |
| part of the cube with an exact failure count of 0 | 67.5% (1.25e19 points) |
| nodes / SAFE leaves | 2.99e7 / 1.50e7 (`lin`; no FAIL, ENUM or open leaf) |
| verifier cost | 5.96e7 fpe (2.0 fpe per node) |
| time | 111 min wall-clock; summed in-worker elapsed time 24,491 s prover, 2,008 s verifier (0.82 and 0.067 ms per node under contention; about 0.3 and 0.02 ms in a single-process test) |
| per piece | 2.4e3 to 2.1e5 nodes (median 3.7e4); median 29 s to prove, 2.4 s to verify |
| whole cube, extrapolated from the uniform sample | 4.4e7 +- 0.1e7 nodes, 8.8e7 +- 0.2e7 verifier fpe, 3.6e4 worker-seconds of proving, 3.0e3 of verifying |

So **p = 0 is not yet certified for the whole cube**; the remaining 333 pieces need about 1.2e4 more
worker-seconds of proving (about an hour on 4 idle cores). What the run does establish exactly, with no
sampling: no input in the certified 67.5% of the cube fails, and every piece examined had a short
certificate (at most 2.1e5 nodes for 2^54 points). The whole certificate costs about 8.8e7 fpe to verify,
the work of 8.8e7 Monte Carlo samples, which can only show p <= 4.2e-8 (delta = 0.05) and never p = 0;
the Knuth estimate of section 3 (5.7e7 +- 1.7e7 fpe, 64 probes) is 1.5 times lower. The run used the prover
before its certification margin (section "Soundness"); with the margin the trees differ only at leaves
whose bound is within 2^-30 |f|_abs of t, and no leaf of this run was demoted.

### 3. d = 64: estimated size of the whole certificate (Knuth, current prover and cost model)

`knuth_d64.py`, 64 probes (`results/knuth_d64.json`); enumeration of the cube costs 5.7e17 fpe.

| net | z | estimated nodes | verifier fpe | prover CPU at ~0.3 ms/node | what MC says with as many fpe |
|---|---|---|---|---|---|
| bce_d64_w64_s1000 | 8.8 | 2.8e7 +- 0.9e7 (measured, section 2: 4.4e7 +- 0.1e7) | 5.7e7 (measured: 8.8e7) | ~2.4 h (measured: 3.6e4 worker-s under contention) | p <= 6.5e-8 |
| bce_d64_w64_s300 | 7.1 | 2.1e10 +- 0.9e10 | 4.3e10 | ~74 days | p <= 9e-11 |
| bce_d64_w64_s100 | 4.5 | 2.8e13 +- 1.0e13 | 5.7e13 | ~270 years | p <= 6.5e-14 |
| mse_d64_w64_s3000 | 10.0 | 1.5e14 +- 0.4e14 | 3.0e14 | - | p <= 1.2e-14 |
| mse_d64_w64_s1000 | 4.4 | 3.4e16 +- 0.6e16 | 6.9e16 | - | (p ~ 1.5e-5: MC is the method) |
| mse_d64_w64_s300 | 1.7 | 5.8e17 +- 0.6e17 | 9.5e17 | - | (p ~ 4%: MC is the method) |

So at d = 64 a certificate is within reach for the logistic net trained longest (section 2: 67.5% done in
two hours, about 3 more hours of worker time for the rest), is
large but finite for bce_d64_w64_s300, and is out of reach for the others, where p > 0 or the margin is
small; there sound two-sided intervals come from sampling only (or, for lower bounds, from
witnesses and the splitting lower bound of `nets_lower`).

### 4. Analysis of why (previous version of the verifier)

The results in this section were computed with the previous version of the verifier
(`gap_scan.json`, `nearfail.json`, `scaling.json`, `knuth_suite.json`, `knuth_d128.json`,
`subtree_d64*.json`, `large_d.json`; their scripts run with the current code). The bounds it
certified are the same relaxations; on random subcubes of four suite nets the new verifier's `lin`
bounds differ from the old ones by at most 3e-9 |f|_abs (the old fixed 2^-30 rounding budget was a
little looser than the new enclosures), far below the gaps of 0.07 to 12, so the gaps below stand. Its costs (fpe) used an incremental cost
model, 2 to 4 times fewer flops per leaf than the implementation.

**Relaxation gap against the margin** (`gap_scan.py`).

Random subcubes of dimension r; margin = exact min f - t, gap = exact min minus the
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
  Var f on the one-hidden-layer squared-loss nets, against 37 to 62% on the d = 28 logistic nets;
  at d = 64 the logistic nets have 12% (bce_d64_w64_s300) and 1.7% (bce_d64_w64_s1000), so the
  certifiable d = 64 net is nearly even and certifies because of its margin, f(0) - t = 1.52), so the variation is in the even part `(1/2) sum_j a_j |z_j|`, and
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
* **Two hidden layers.** The gap is 2 to 12 at r = 10 to 16. It is not mainly due to the
  verifier's default-slope intermediate bounds: the red team replaced them by LP-optimal ones (HiGHS)
  and the gap shrank only 22 to 25% (e.g. 5.08 to 3.91 at r = 10 against a margin of 1.73 for
  bce_d28_w64x64_s100); no subcube with r >= 10 became certifiable.
* **Near-failure accounting.** A SAFE leaf of dimension r needs its subcube's minimum above
  t + G(r). With G(r) the measured gap, `nearfail.py` estimates Pr[f < t + G(r)]: for
  mse_d24_w32_s1500 it is 2.7e-4, 1.7e-3, 0.27, 1.0 at r = 4, 6, 8, 10 (so no leaf with 10 free
  inputs is certifiable, as observed: 99.9% of its certified leaves have r <= 9), for
  mse_d64_w64_s1000 it is 0.08 at r = 10 and 0.6 at r = 12, for bce_d64_w64_s1000 none of
  4e6 samples is below t + G(r) for any r <= 16. The certificate pays for every point within the gap of the threshold,
  not only for the failing ones: that is why it is exponential in d unless the margin exceeds
  the gap at large r.

**Scaling with d** (`scaling.py`; fpe in the previous cost model).

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
p < ~2^-(0.75 d) * 1e3. (These fpe are in the previous, incremental cost model; the implemented verifier
costs 2 to 4 times more per leaf, and 5 to 30 times more per fpe in wall-clock than MC per sample
(section 1), so in practice the crossovers lie at smaller p.)

**d = 128, two hidden layers** (`knuth_d128.py`, 8 probes, default slopes; previous cost model):

| net | z | estimated nodes | verifier fpe | enumeration fpe | what MC can say with as many fpe |
|---|---|---|---|---|---|
| bce_d128_w128x128_s1000 (two layers; 8 probes, default slopes) | 7.8 | 1.2e33 | 1.8e35 | 1.7e38 | - |
| bce_d128_w128x128_s300 (same) | 6.5 | 1.2e34 | 1.8e36 | 1.7e38 | - |
| bce_d128_w128x128_s100 (same) | 5.3 | 5.5e34 | 8.0e36 | 1.7e38 | - |

**Verified pieces at d = 64** (`subtree_d64.py`): follow the prover's own splits along a random path for k steps,
build and verify the complete certificate of the subcube reached. Every piece below was certified exactly (no open leaf) and contains no failing point.

| net | k | pieces (free inputs, nodes, verifier fpe, verify seconds) | whole-cube estimate (fpe) |
|---|---|---|---|
| bce_d64_w64_s1000 | 8 | 4 pieces of r = 56: 1.9e5 to 2.7e5 nodes, 1.3e5 to 1.9e5 fpe, 24 to 35 s | 3.9e7 |
| bce_d64_w64_s300 | 17 | 2 pieces of r = 47: 2.2e5 and 4.3e5 nodes, 1.3e5 and 2.4e5 fpe | 2.4e10 |
| bce_d64_w64_s100 | 29 | 2 pieces of r = 35: 5.5e3 and 9.0e3 nodes | 1.8e12 |
| mse_d64_w64_s3000 | 31 | 2 pieces of r = 33: 2.7e4 and 3.0e4 nodes | 2.6e13 |
| mse_d64_w64_s1000 | 40 | 2 pieces of r = 24: 3.7e4 and 4.7e4 nodes | 1.2e16 |

The estimates agree with the Knuth estimates within a factor 1.2 to 8 (few paths, so these are rough).

**Budgeted whole-cube runs** (`large_d.py`): with 2e5 nodes the breadth-first prover reaches
depth ~17, where no subcube (47 free inputs) of mse_d64_w64_s300/s1000/s3000 or
bce_d64_w64_s100 is certifiable, so the open part is the whole cube and the interval is Monte
Carlo's (e.g. [1.8e-6, 5.2e-5] for mse_d64_w64_s1000 from 2e5 samples). Partial certificates
give nothing until the tree reaches the depth of its leaves (22 to 57 here).

### 5. Soundness checks (`check_soundness.py`, `results/soundness.json`)

52 nets, d = 1 to 10, 32 with one and 20 with two hidden layers, all checked against exact rational
values of f on every point: 16 with random weights at scales 1e-6 to 1e6; 4 with small-integer weights
and many exact ties f = t; one whose failing point float64 evaluates to exactly t (f = 1/2 - 2^-60);
3 trained; and 28 from the red team's families (4 each): exact power-of-two rescalings of hidden units
by up to 2^+-450, output and threshold scaled by 2^-900 to 2^1000, hidden layer x 2^(200..960) with tiny
output weights, `lin_sub` (hidden x 2^(900..960), output weights subnormal), `quad_sub` (G kap near
2^-1074), first-layer weights near 1e308, and two-hidden-layer nets whose coefficient G on h_1 cancels
to ~1e-8 of its size with t set to the certified bound (the drop-rule attack).

* 37,553 bound checks (`lin` with default, optimised, random, subnormal (5e-324) slopes, for f and -f;
  `quad` from the optimiser, with random parameters, with the optimiser's shift bumped by up to 1e-3,
  and with the **largest shift the verifier accepts**, found by bisection, for random and extreme
  theta): **0** certified bounds above the exact minimum;
* 260 honest exact certificates (104 of the whole cube with `lin` and `lin+quad`, 156 of random
  subcubes via `root`): **0** counts different from the exact one, **0** leaves demoted (the run before
  the prover fix of section "Soundness" had 1 demoted `quad` leaf, see the regression test
  `test_prover_certificates_are_accepted_as_checked`);
* 1,144 dishonest or malformed arguments (21 kinds per net plus the enumeration cap): **0** intervals
  missing p (416 rejected as malformed, 10,459 leaves demoted to sampling);
* 1,300 sampled (hybrid) runs at delta = 0.1: 13 misses (1.0%);
* 52 witness lists with duplicates, non-failing and malformed points: 0 errors.

Re-run on the final code (after the fixes for outputs that overflow to +inf, for roots
that are not in {-1, 0, +1}^d, and for thresholds near the largest float): the same
counts, in 427 s of wall-clock on a shared 4-core machine. The counterexamples behind
those fixes are regression tests in `code/tests/test_nets_prover.py`
(`test_regression_overflow_to_inf_is_not_surely_safe`,
`test_regression_non_integer_roots_are_rejected`, `test_threshold_at_the_largest_float`).

The same campaign on the previous verifier is what the red team ran (with these families scaled up):
there it found the wrong exact answers listed above.

## Relation to the paper's barriers; for which nets do short certificates exist?

* **coNP in MA.** One hidden layer of ReLUs can encode any 3-CNF with the event "no clause
  violated" (one unit per clause), so `p = 0` for this architecture is coNP-hard to decide, and
  by the paper's Theorem (no complete upper-bound arguments) no sound argument system has short
  upper-bound certificates for all nets of the architecture unless coNP is in MA. Our verifier is
  sound on every net (adversarial weights, exact ties, extreme scales, subnormal and overflowing
  intermediate values included); completeness can only be a property of the trained nets, and the
  experiments say which.
* **Black-box barrier.** Inside OPEN leaves the verifier only evaluates f, so there it pays
  Z_open / p samples (surprise accounting); every bit of upper bound below the sampling scale
  comes from the deductive (SAFE/FAIL/ENUM) part, which must exclude all non-failing mass to
  within eps p.
* **Short certificates plausibly exist exactly when the margin min f - t exceeds the deductive
  gap at large subcube dimension**, i.e. for nets trained well past the point where p becomes 0,
  with a large margin (logistic loss): `bce_d28_w32_s150` (p = 0, 2.1e3 nodes), `bce_d28_w32_s100`
  (p = 7.5e-9, 2.1e4 nodes), `bce_d64_w64_s1000` (section 2). For squared-loss nets the even
  (small-ball) structure puts every point within the gap of t into the certificate, the root is
  blocked by the box barrier, and the size grows like 2^(0.6 to 0.9 d) (certified leaves have
  r* ~ 6 to 10 free inputs at d = 24, ~10 at d = 64); for two hidden layers the gap of bound
  propagation itself is the obstacle. For p > 0 at d = 64 the only practical sound two-sided method we
  found is Monte Carlo (equivalently, the envelope estimator with the trivial envelope); the prover
  helps with lower bounds (witness lists) but not with upper bounds at that scale.
* What would change this: certificates whose gap does not grow with r on small-ball events
  (e.g. degree-4 sum-of-squares, which can capture E|z| >~ sqrt(E z^2)/3 through
  hypercontractivity, or MILP-style phase splitting with Boolean cuts beyond the box); we did not
  build them.

## Files

* `run_suite.py`: plan + certificate + verification for every suite net with exact p, with MC and
  enumeration costs measured (`results/suite_cert.json`; `SUITE_KINDS=lin+quad` for `quad` leaves,
  `results/suite_cert_lin+quad.json`).
* `full_d64.py`: the d = 64 certificate, built and verified piece by piece within a wall-clock budget
  (`results/full_d64_<net>.json`).
* `knuth_d64.py`: Knuth estimates for the d = 64 nets with the current prover (`results/knuth_d64.json`).
* `check_soundness.py`: soundness campaign (`results/soundness.json`).
* `summarize.py`: all tables (`results/summary.md`, `results/tables.json`).
* Previous version (section 4): `knuth_suite.py`, `knuth_d128.py`, `gap_scan.py`, `nearfail.py`,
  `scaling.py`, `subtree_d64.py`, `large_d.py`.
* `results/*_log*.txt`: console logs of the runs.

Reproduce: `cd experiments/nets_prover && python3 check_soundness.py && python3 run_suite.py &&
python3 knuth_d64.py && python3 full_d64.py bce_d64_w64_s1000 10 110 4 && python3 summarize.py`
(pure numpy; hours on a shared 4-core machine). Tests: `cd code && python3 -m pytest -q tests/test_nets_prover.py`.
