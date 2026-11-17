# Sign-GP numerics

This package reproduces the small-dimensional sign-posterior illustrations in Section 7 of the [note](../../README.md), at input dimensions $d=10,12$. It simulates the limiting $\gamma<0$ learner of the [subcritical paper](../../../../main-results/subcritical-exponential/paper.pdf); these runs do not determine asymptotic sample exponents.

The learner is a Gaussian process $G\sim N(0,K)$ on the Boolean cube, conditioned on the observed training signs. At depth $L$, its kernel is $K(x,y)=\Psi^{\circ(L-1)}((1+x\cdot y)/(d+1))$, where $\Psi(t)=2\arcsin(t)/\pi$. The function $f$ below is the target label function.

## Method

- **Sampling.** `hmc_orthant.c` implements exact Hamiltonian Monte Carlo for the orthant-truncated Gaussian on the distinct training inputs (Pakman and Paninski, 2014), using wall reflections.
- **Predictions.** `signgp.py` computes $q(x)=\Pr\lbrace f(x)G(x)>0\mid\text{signs}\rbrace$ at every cube input, by averaging $\Phi(f(x)\mu(x)/s(x))$ over draws of the training values. Here $\mu(x)$ and $s(x)$ are the conditional Gaussian mean and standard deviation, and $\Phi$ is the standard normal cumulative distribution function. Averaging this conditional probability Rao–Blackwellizes the prediction at $x$.
- **Reported quantities.**
  - $F=\Pr_x\lbrace q\le2/3\rbrace$, with observed inputs counted as successes;
  - $F$ restricted to unseen inputs;
  - Gibbs error and majority-vote error;
  - the same quantities for ridgeless kernel regression on the $\pm1$ labels.
- **Runs.** Two chains of 1500 draws each, after 300 burn-in steps.
- **Training inputs.** $n$ iid uniform draws per seed, shared by all targets.

## Validation

`validate_sampler.py` compares the sampler at $n=8$ with quasi-exact orthant-probability ratios, with maximum error in $q$ of $1.1\times10^{-3}$. At $`n=150`$–$`300`$ it compares with an independent coordinatewise Gibbs sampler, with maximum difference 0.014 in $q$ and 0.005 in $F$. Results are in `validate_sampler.json`. Across all runs the two chains differ in $F$ by at most 0.009.

## Targets

All targets are juntas on the first coordinates (`targets.py`, profiles in `targets.json`). Exact distances from low-degree threshold functions, computed by mixed-integer programming, are in `ptf_disagreement.json`.

- `leap1_td3` is $x_1x_2x_3x_4$ with its sign flipped where $x_1=x_2=x_3=1$. It was chosen from a census of four-bit functions (`search_leap1.py`, `pick_leap1.py`).
- `cond_par3_maj3` is $x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$. It was added after the main sweep and run only at $d=12$, $L=2$.

The diagnostics for the original ten targets are `energy_diag.py` (Gaussian energy used per sample), `min_energy.py` (minimum margin-one energy), and `stair4_cells.py` (per-cell confidence of `stair4`).

## Files

- `summary.txt` and `summary.csv`: all aggregated tables.
- `results.jsonl.gz`: one raw row per run.
- `run_all.sh`: reruns everything, in about an hour on four CPUs. Delete `results.jsonl.gz` and any `results.jsonl` first for a clean rerun. Afterwards `summarize.py` regenerates the summaries from the new `results.jsonl`.

## Reproduction requirements

Requirements: Python 3 with NumPy and SciPy, and a C compiler.

These scripts were written by AI agents for this note and checked as described in the [review record](../review.md); they are research code, not a library.
