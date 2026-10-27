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

| script | what it measures | output |
|---|---|---|
| `check_soundness.py` | randomised soundness checks of every bound and of branch and bound, against brute force and exact rational counting (random nets with weight scales 1e-6 ... 1e6, integer-weight nets with exact ties f = t), and coverage of the sampling stage | `results/check_soundness.json` |
| `check_cnf_encoding.py` | every 3-CNF is a one-hidden-layer ReLU net of the test-bed form (event f < 1/2 = satisfying assignments, f(0) = 0); checked against direct counting | `results/check_cnf_encoding.json` |
| `exp_suite.py` | exact counts of the suite nets with known p by branch and bound, cost against MITM enumeration and Monte Carlo; anytime intervals after cost budgets, with and without sampling in the undecided subcubes | `results/suite.json` |
| `exp_variants.py` | cost of the deductive engines (CROWN with several enumeration thresholds and branching rules, optimised slopes, phase splitting) on three d = 24 nets | `results/variants.json` |
| `exp_barrier.py` | the largest subcube dimension certifiable by CROWN, by optimised slopes, by ANY method that bounds f over the subcube's box (MILP witnesses), and by the cube itself, for d = 16 ... 64 | `results/barrier.json`, nets `results/own_*.npz` |
| `exp_isolation.py` | where the failing points are: pairwise Hamming distances, failing neighbours, clusters, largest failing subcubes | `results/isolation.json` |
| `exp_zero.py` | how often trained nets have p = 0, and the cost of certifying it, as a function of d and training length | `results/zero.json` |
| `exp_large.py` | d = 32 ... 128 (no exact p): certification rates, the interval after 1e7 fpe, Monte Carlo with the same budget | `results/large.json` |
| `summarize.py` | prints the tables of all results as markdown | stdout |

Reproduce (Python 3 with numpy and scipy; from this folder):

```sh
python3 check_soundness.py && python3 check_cnf_encoding.py
for e in exp_suite exp_variants exp_barrier exp_isolation exp_zero exp_large; do python3 $e.py; done
python3 summarize.py
```

`exp_barrier.py` uses scipy's MILP solver (HiGHS) only to find real points of a
box at which f < t; every such point is re-evaluated, and the solver is never
used to certify anything. Times in the results are wall-clock on a shared
4-core machine under heavy load and indicate orders of magnitude only; the fpe
counts are the cost measure.
