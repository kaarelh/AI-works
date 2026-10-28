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
`results/structure_summary.txt`.

`cache/` and `logs/` are regenerable working files (they stay on the working branch).

Order: `enumerate.py <nets>`, `scaling.py`, then the others in any order
(`structure.py`, `heuristics.py suite`, `heuristics.py own <config>` need the
caches). All scripts are deterministic given their seeds.
