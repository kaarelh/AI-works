# Deductive bounds for nets trained to output 1

Experiments for `code/rareprob/nets_verify.py`: sound intervals for
p = Pr_x[f(x) < t] (x uniform on {-1,+1}^d) for ReLU MLPs, by input branch and
bound with neural-network-verification bounds (CROWN, optimised slopes, ReLU
phase splitting), exact enumeration of small subcubes, and optional sampling
inside the undecided subcubes (envelope estimator). Test bed: the nets of
`experiments/nets/` (built by `experiments/make_net_suite.py`) and nets trained
here with `rareprob.nets.train_constant`.

Costs are in forward-pass equivalents (fpe): floating-point operations divided
by those of one evaluation of the net. Monte Carlo needs 3 ln(2/delta) /
(eps^2 p) samples (1 fpe each) for ratio 1 + eps; we use eps = 0.1,
delta = 0.05. "MITM enumeration" is the meet-in-the-middle enumeration of the
whole cube used by `rareprob.nets.exact_failure_count`.

## Main findings (tables: `python3 summarize.py`)

* **Soundness on every net.** Every interval is a deterministic statement
  about the exact real-arithmetic net (and about any float64 evaluation of
  it): valid linear relaxations, rounding margins that dominate the
  float error of every computed bound, and a partition of the cube into
  subcubes counted with Python integers (module docstring of
  `nets_verify.py`). Checked against exact rational counting: 12,000 bound
  checks and 232 branch-and-bound runs (weight scales 1e-6 ... 1e6, exact
  ties f = t), no violation. Every 3-CNF is a net of this architecture
  (`check_cnf_encoding.py`), so no method is efficient on all nets unless
  NP is in BPP; efficiency can only be a property of trained nets.
* **p = 0 is common and is what deduction does best.** Of 107 one-hidden-
  layer nets trained for >= 1000 (squared loss) or >= 300 (logistic) steps,
  98 have p = 0, certified exactly, 5 have p > 0 (counted exactly) and 4
  (d = 40 ... 64) stay open. Nets trained long enough are certified at or
  near the root (5 ... 5e3 forward-pass equivalents) up to d = 40, and at
  d = 48 and 64 after 16,000 steps in 1.6e7 and 3.7e7 fpe; over the family
  the median cost grows about 3x per 4 extra inputs (d = 20 ... 32),
  against 13x for enumeration. Monte Carlo can never
  certify p = 0 (with 1e7 samples its upper bound is 3.7e-7).
* **p > 0: exact counts at about the cost of enumeration.** One hidden
  layer, d = 24 and 28: the exact count costs 0.7 ... 4x the meet-in-the-
  middle enumeration of the whole cube for squared loss and 0.008 ... 0.5x
  for logistic loss; it beats Monte Carlo (eps = 0.1) by 24x ... 2e5x when
  there are at most a few thousand failing points and loses (by up to
  1.3e3x) when there are 1e4 or more. Two hidden layers: only 9 ... 22 % of
  the cube is certified in 940 ... 2600 s. For squared loss (width 32) the tree has
  about 2^(d - 6.5) nodes whatever p is (1e3, 1.4e4, 1-2e5, 1.6-3e6 nodes
  at d = 16, 20, 24, 28 for p from 6e-8 to 2e-2), so the cost doubles with
  every input.
* **Why.** CROWN's looseness on a subcube grows like r^1.5 ... r^2 in its
  number r of free inputs (more unstable units, each looser), the optimised
  slopes (the LP relaxation) remove only 20 ... 55 % of it, and the margin
  min f - t shrinks with r: certification stops near
  r* ~ sqrt(margin / (kappa iota)), kappa = 0.006 ... 0.02 (fitted), iota
  the mean per-input influence sum_j |a_j||W_ji| (0.7 ... 1.4 for the
  suite nets with p > 0, 0.04 for a net certified at d = 64). With a PERFECT
  engine (a subcube decided as soon as it is pure) the tree would have
  about F (d - log2 F) nodes, 10 ... 5000x fewer (the more so the rarer
  the event): the failing set is not the obstacle (failing points are ~d/2
  apart on average, greedily grown failing subcubes have dimension <= 4);
  the bounds are. Even the exact box minimum (the limit of every box
  relaxation, by MILP) certifies only r = 8 ... 20 on six of the ten nets
  of `exp_barrier.py` (>= 26 on the others), against >= 16 for the cube.
* **Large d.** For every d = 64 and 128 suite net the deterministic
  interval stays [0, 1] (CROWN r* = 4 ... 24, so 2^40 or more nodes);
  two-sided intervals there come only from sampling. Sampling inside the
  undecided subcubes (envelope estimator) gives valid two-sided intervals
  at cost K / eps^2 with K = undecided mass / p, which stays near 1/p until
  the tree is almost complete: no gain over Monte Carlo on the suite.
* **A stronger, unsound engine.** HiGHS branch and cut on the cube claims
  min f >= t (p = 0) for the d <= 32 nets in 30 ... 100 s (the sound
  branch and bound certifies the same nets in 0.0 ... 39 s, and the d = 64
  net certified at the root, on which the solver fails), and finds
  failing inputs (re-checked: sound witnesses p >= 2^-d) that Monte Carlo
  with 1e7 samples and the branch and bound miss, at d = 48 and on the
  d = 64 suite net bce_d64_w64_s100; it fails on the d = 64 squared-loss
  nets and on two hidden layers within 180 s.

## Scripts

| script | what it measures | output |
|---|---|---|
| `check_soundness.py` | randomised soundness checks of every bound and of branch and bound, against brute force and exact rational counting (random nets with weight scales 1e-6 ... 1e6, integer-weight nets with exact ties f = t), and coverage of the sampling stage | `results/check_soundness.json` |
| `check_cnf_encoding.py` | every 3-CNF is a one-hidden-layer ReLU net of the test-bed form (event f < 1/2 = satisfying assignments, f(0) = 0); checked against direct counting | `results/check_cnf_encoding.json` |
| `exp_suite.py` | exact counts of the suite nets with known p by branch and bound, cost against MITM enumeration and Monte Carlo; anytime intervals after cost budgets, with and without sampling in the undecided subcubes | `results/suite.json` |
| `exp_variants.py` | cost of the deductive engines (CROWN with several enumeration thresholds and branching rules, optimised slopes, phase splitting) on three d = 24 nets | `results/variants.json` |
| `exp_barrier.py` | the largest subcube dimension certifiable by CROWN, by optimised slopes, by ANY method that bounds f over the subcube's box (MILP witnesses), and by the cube itself, for d = 16 ... 64 | `results/barrier.json`, nets `results/own_*.npz` |
| `exp_gap.py` | why only small subcubes are certified: CROWN's and the optimised slopes' looseness (cube minimum minus bound) against the margin (cube minimum minus t), as a function of the subcube dimension r; a lower bound on the looseness of any box-valid bound (the box centre) | `results/gap.json` |
| `exp_isolation.py` | where the failing points are: pairwise Hamming distances, failing neighbours, clusters, largest failing subcubes; the tree a PERFECT engine would need (pure subcubes decided) against the CROWN tree | `results/isolation.json` |
| `exp_zero.py` | how often trained nets have p = 0, and the cost of certifying it, as a function of d and training length; with short training (p > 0), how the exact count's tree grows with d | `results/zero.json` |
| `exp_large.py` | d = 32 ... 128 (no exact p): certification rates, the interval after 1e7 fpe, Monte Carlo with the same budget | `results/large.json` |
| `exp_milp.py` | a stronger but UNSOUND engine for comparison: min f over the cube by HiGHS MILP (branch and cut); failing points it returns are re-checked (sound witnesses), its "p = 0" claims are not certificates | `results/milp.json` |
| `summarize.py` | prints the tables of all results as markdown | stdout |

Reproduce (Python 3 with numpy and scipy; from this folder):

```sh
python3 check_soundness.py && python3 check_cnf_encoding.py
python3 exp_suite.py mse_d24 mse_d28_w64 bce_d28_w32_
python3 exp_suite.py --out=suite_deep.json --time=900 mse_d28_w32x32_s100 mse_d28_w32x32_s500 bce_d28_w64x64_s60 bce_d28_w64x64_s100
for e in exp_variants exp_barrier exp_gap exp_isolation exp_zero exp_large exp_milp; do python3 $e.py; done
python3 summarize.py
```

`exp_barrier.py` uses scipy's MILP solver (HiGHS) only to find real points of a
box at which f < t; every such point is re-evaluated, and the solver is never
used to certify anything. `exp_milp.py` runs the same solver on the cube
itself, as a reference for what a branch-and-cut engine achieves; it too
certifies nothing (only its re-checked failing points are used, as witnesses).
`exp_barrier.py` must run before `exp_gap.py`, `exp_milp.py` and
`exp_variants.py`, which use the nets it trains (`results/own_*.npz`). Times in the results are wall-clock on a shared
4-core machine under heavy load and indicate orders of magnitude only; the fpe
counts are the cost measure.
