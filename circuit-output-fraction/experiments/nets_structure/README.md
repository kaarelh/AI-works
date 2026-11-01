# Structure of the failure set of nets trained to output 1

Analysis scripts (no library code) for the question: what does the rare event
[f(x) < t] look like for ReLU MLPs trained to output 1 on uniform {-1,+1}^d
inputs (`code/rareprob/nets.py`, suite in `experiments/nets/`), how does p
scale with training, how well do heuristic (not sound) estimators predict p,
and what must a sound method do. Everything is measured against exact p
(exhaustive enumeration of the cube, d <= 28).

| script | what it does | output |
|---|---|---|
| `enumerate.py` | exhaustive pass over the cube for the suite nets: exact count, exact moments, exact lower-tail quantile function (k-th smallest f for a geometric grid of k), cache of the 100k lowest inputs and of (a subsample of) the failures | `results/enum/<net>.json`, `cache/<net>.npz` |
| `structure.py` | failure-set statistics: first/second moment directions, max-margin halfspace looseness, antipodal symmetry, even/odd parts, Hamming geometry, pair correlation g(1), g(2), local minima and basins, relation to the first-layer weights (positive/negative output-weight units, null space of W+), even-form decomposition f = c' + L + E+ - E- | `results/structure.json` (suite), `results/structure_own.json` (`structure.py own <config>`) |
| `walsh.py` | exact Walsh spectrum (d = 24): weight by degree, odd share, participation ratio, correlation function | `results/walsh.json` |
| `scaling.py` | trains nets (d = 12...24, one/two hidden layers, both losses, widths 8...128, several seeds, snapshots) and records exact p, min f, moments, tail curve, Walsh statistics | `results/scaling_<config>.json`, `cache/own/` |
| `analyze_scaling.py` | p and z by step, sd decay exponent, p = 0 versus the Gaussian expected count 2^d Phi(-z), Walsh trends | `results/scaling_summary.json` |
| `heuristics.py` | heuristic estimators of Pr[f < s] (output Gaussian, Edgeworth, tail fit from 1e5 samples, linear part + Gaussian rest, Gaussian-input and sphere-input surrogates, presumption of independence over hidden units and in the Walsh basis) at the threshold and at levels with exact P = k/2^d | `results/heuristics_<suite or config>.json` |
| `summarize_heuristics.py` | accuracy tables (log10 estimate/exact) | `results/heuristics_summary.json` |
| `geometry.py` | witnesses that relaxations of the input domain cannot certify: minima of f over the box and the sphere found by local search, f(0), null space of W+ | `results/geometry.json` |
| `subcube.py` | exact largest failure-free subcube through sampled points (d <= 20) and the resulting lower bound on any subcube-partition argument, against a random set of the same size | `results/subcube.json` |
| `adversarial.py` | nets of the same architecture on which the heuristics are wrong by exponential factors (lattice small ball; planted subcube unit) | `results/adversarial.json` |
| `large_d.py` | heuristic predictions and a Monte Carlo reference for the d = 64, 128 suite nets | `results/large_d.json` |
| `heuristics_ref.py` | the heuristics at d = 32...128 against the SMC reference values of `experiments/nets_lower` (unbiased estimates, not exact; read only) | `results/heuristics_ref.json` |
| `depth2.py` | two hidden layers: which second-layer unit carries each failure, its activation probability ("dying" units) | `results/depth2.json` |
| `summarize_structure.py` | compact tables of all of the above | `results/structure_summary.txt` |

Printed summaries: `results/heuristics_summary.txt`, `results/scaling_summary.txt`,
`results/structure_summary.txt` (regenerated from the results files by
`summarize_heuristics.py`, `analyze_scaling.py`, `summarize_structure.py`;
re-running them reproduces the published files byte for byte).
`results/depth2.json` has no printed summary; its main rows are in the
findings below.

## Main findings (all against exact p unless stated)

* **Squared loss, one hidden layer: the output is nearly even and the
  failures are a joint small-ball event of the positive-weight units.**
  corr(f(x), f(-x)) = 0.82 ... 0.99; the linear part carries about none of
  the drop of f at failures, E+ = (1/2) sum_{a_j > 0} a_j |z_j| carries
  54 ... 140 %; on the nets with p < 1e-4, at a failure 8 ... 15 positive
  units sit within one coordinate flip of zero, against 4 ... 7.5 at typical
  inputs (`structure.json`: n_small_pos_S, n_small_pos_R).
  0 lies in the convex hull of every squared-loss failure set examined, so
  every halfspace containing all failures has mass >= 1/2 (K >= 1/(2p):
  5e4 for mse_d24_w32_s1500, 1.5e6 for mse_d28_w64_s1000).
* **Many modes, clumped locally.** F failures sit in about F/4 ... F/2
  single-flip local minima (163 in 90, 6012 in 1600, 16155 in 5684);
  pairwise distance about d/2, nearest failing neighbour at 1.1 ... 3.
  Failure-free subcubes are 1 ... 9 dimensions larger than for a random set
  of the same size (`subcube.json`, d <= 20), so the failure set is cheap
  to isolate combinatorially; proving each piece failure-free is the hard
  part.
* **Logistic loss is different:** not even (corr -0.5 ... +0.25), the
  linear part carries 32 ... 72 % of the drop, a halfspace holds 25 % of the
  failures at K = 3 ... 38, few dominant basins.
* **Two hidden layers** (`depth2.json`): on own_mse_d24_w32x32 (seed 0) the
  last failures are the shrinking activation region of one second-layer
  unit: its activation probability falls from 25 % (100 steps) to 0.8 %
  (1000 steps), it carries 81 ... 97 % of the drop of f, and deviates up to
  54 sd from its typical value at a failure (p = 1.2e-7 at z = 9.35, where
  the output Gaussian gives 4.5e-21). On the suite's d = 28 two-layer nets
  the top unit carries at most 41 % of the drop.
* **p = 0 is the usual end state** (`scaling_summary.txt`): squared loss,
  p = 0 in 97 % of nets with Gaussian expected count 2^d Phi(-z) < 0.01 and
  in none with count > 100; steps until half the seeds reach p = 0 grow from
  500 (d = 12) to 1000 (d = 24) for width 32.
* **Relaxations are blind** (`geometry.json`): local search finds box points
  with f < t on 29 of 30 suite nets and sphere points on 30 of 30;
  f(0) < t on all 13 squared-loss nets with d <= 28.
* **Heuristic estimators** (not sound; `heuristics_summary.txt`, 3075
  (net, level) points on 547 nets): the best single one (mcfit, a quadratic
  fit to the lower tail of 1e5 samples) has median error x1.5 and 93 %
  within x10; 'select' (mcfit for one-layer squared loss, the sphere
  surrogate otherwise) has median x1.5, 95 % within x10, worst 3.3 orders,
  and predicts p = 0 correctly on 98 % of nets. Presumption of independence
  over hidden units overestimates p by a median 10^2.65. Same-architecture
  adversarial nets (`adversarial.json`) break every heuristic: the output
  Gaussian is off by 10^15.7 on a lattice small ball at d = 400.
* **d = 32 ... 128** (`heuristics_ref.json`, re-run on 28 October against
  the current SMC references of `experiments/nets_lower`, which are unbiased
  estimates, not exact): the nets are the SMC lane's own nets (`smc_*`,
  `smc2_*`; earlier names without the prefix collided with suite nets).
  The output Gaussian and mcfit are within 0.6 orders for p_ref >= 1e-5
  and overestimate by 0.6 ... 3.2 orders for p_ref between 2e-18 and 8e-13;
  on the logistic two-layer net (p_ref = 7e-16) the output Gaussian
  overestimates by 8 orders, while the sphere surrogate is within 0.3.
  The earlier comparison at p_ref = 2e-30 (d = 128, z = 8.9) is gone: the
  SMC lane's reference for that net is now 0 (no failure found), so it
  gives no reference value there.

## Published and unpublished paths

`cache/` (enumeration caches, about 30 MB) and `logs/` (stdout of the runs)
are regenerable working files: they stay on the working branch. Everything
else in this folder is published.

Order: `enumerate.py <nets>`, `scaling.py`, then the others in any order
(`structure.py`, `heuristics.py suite`, `heuristics.py own <config>` need the
caches). All scripts are deterministic given their seeds.
