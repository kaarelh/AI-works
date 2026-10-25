# DFG: a discrete learner that matches or beats gradient descent on the toy Boolean suite

Part 6 of the study (25 October 2026). All tables: [`RESULTS.md`](RESULTS.md), generated from `results/*.json`.

**Question (from the user).** Use the picture of what gradient descent does (Parts 1–5 of this study) to build a *more
discrete* learner. It should get test performance at least as good as gradient descent's with similar compute and data,
at least on the toy problems where gradient descent does well.

**Proposal.** *Discrete feature growth*, DFG (`dfg.py`), keeps the networks' strategy and replaces their search.

What it keeps:
- It grows features greedily, cheapest first.
- Each feature is tested against the noise of the current residual.
- A feature on inputs it already uses is cheaper.
- It fits a linear background.
- It predicts with the sign of a fitted readout on what it has grown.

What it replaces: it finds features by exhaustive enumeration of Fourier characters, with union-bound tests, instead of
by noisy local search in weight space. Each search runs on a subsample whose size is set by the compute budget, so a fit
stays within a fixed fraction of one network run.

**Result** (Numerical; details below). Against the study's networks (μP MLP d-128-128-1, Adam, 20000 steps, the same
training sets and test set):
- [HEADLINE]

**What this says about gradient descent** (Heuristic). On these targets the networks' extra data cost is the price of
*searching in weight space*. Part 3 found that gradient descent pays for search in samples, n* ≈ c·N(k)/ρ² with
N(k) = d·max(1, d/a)^{k−2}, which is about d^{k−1} for a k-parity. DFG pays for search in compute, N candidates per
class, and only about ln N in samples. That is roughly 2k ln d for a k-parity, the Occam rate. Under the networks' own
FLOP budget, exhaustive search is affordable up to degree 4 on all the data at d = 30, and up to degree 6 on a
subsample. So on this suite data, not compute, is what limits a learner, and gradient descent spends data where an
exhaustive search spends FLOPs.

## 1. The learner, and where each piece comes from

| what the networks were seen to do (Parts 1–5) | DFG's discrete counterpart |
|---|---|
| Features are grown greedily, one bundle at a time, in order of detectability (plateaus and drops; Part 5) | rounds of exhaustive search; everything that passes the test this round is added |
| A feature's cost is set by its correlation with the **residual** against the noise of the competing directions ("noise-limited greedy growth", Part 2) | test \|mean(r χ_S)\| > c·s·sqrt(2 ln(4KN/δ)/n), with s = rms(residual) and N the size of the candidate class (c = 1, δ = 0.1, K = 4). s falls as features are fit, so weaker features become detectable later |
| Composition: features on a term's own inputs make it cheaper (the user's x1x2, x3x4 → x1x2x3x4 prediction, confirmed in Part 4) | small candidate classes, hence low thresholds: *extensions* S ∪ {j}, S ∪ {j, l} of current features; *local* search over every subset of the inputs in use (Walsh transform on V, up to junta completion) |
| A kernel background plus a few grown features (Part 3) | a *linear block* (all d inputs at once, when a χ²_d test says the linear part has signal) and a final Hebbian step on the residual |
| Dense targets: one direction grown from many weak correlations; spiked-estimation shrinkage 1 − N/(nρ²) | a *spectral block*: eigen-directions of the residual pair matrix above the noise edge 2s·sqrt(d/n) (spiked-eigenvalue shrinkage), features (u·x)² |
| On every plateau the network computes the sign of a truncated Fourier expansion of the target (Part 5) | readout: sign of the fit on the grown features; least squares (v1), refined by logistic regression (v1.1) |

The search classes are:
- global: degrees 1–4 on all the data, and degrees 5–6 in the first round on a subsample sized by the budget;
- extension;
- local;
- the two blocks.

Engineering:
- *Stopping.* Stop when nothing passes, or when every training sign is right.
- *Least squares.* Kept to p ≤ n/2 features, so it never sits at its interpolation peak.
- *Small n.* With few points the union bound passes nothing: at n = 16 even a perfect one-input target fails it. For
  n ≤ 512, a "forced" variant takes the best-scoring character anyway, at most twice. Cross-validation chooses it over
  the default only if it wins a paired (McNemar) test.
- *Compute budget.* Each search runs on the first m training points, with m chosen to keep it within a fixed share of
  one network run:
  - degree 4: 15% (25% in v1);
  - degree 3 and extensions: 3% per round each;
  - degrees 5 and 6: 3% each.

  A search whose m would fall below 32 is skipped. The cross-validation folds share half the budget (v1.1). A new round
  starts only below 75% of the budget. At d = 30 the budget binds only for degrees 5–6; at d = 60 and 120 it binds for
  degree 4 too.

**What is discrete.** The hypothesis is a set of Boolean features — parities χ_S and, for dense targets, a few quadratic
forms — found by enumeration and admitted by explicit tests. The only continuous parameters are the readout weights.

**v1 and v1.1.**
- *v1* (`dfg_frozen_359a6b61.py`, frozen at commit 359a6b61) is the version run blind on held-out suite 1.
- *v1.1* (`dfg.py` with `readout="logit"`, commit 0220cf04) was made after that run, and fixes two problems it showed:
  - *Readout.* On a dense halfspace (thr30) v1's least-squares readout plateaued at 5–6% error, where the networks reach
    1%. Square loss is the wrong readout for a halfspace: sign(LS) of a threshold function stays a few percent off. 15
    Newton steps of L2-regularized logistic regression on the same features (λ = 1e-4, when n ≥ 8p) take a dense dev
    halfspace from 0.056 to 0.007 at n = 16384.
  - *Budget.* An independent compute audit found that v1's small-n cross-validation gave every fold the whole budget,
    which at d = 120 cost up to 2.7 network runs per fit.

  Held-out suite 2 was written after v1.1 was committed (commit 70c604eb), so it is blind for v1.1.

## 2. Protocol

- **Same data as the networks.** An audit checked `harness.train_data` against `nn_train.make_data` row for row, for
  every n and seed, across the suites and d values. The networks' saved weights reproduce their recorded training error
  on these sets. The test set is the same 4096 points, and DFG sees only (X, y) and an rng.
- **Network reference.** The networks' final test error at each (n, seed). The step count is 20000, or 40000 at d = 120,
  where the study trained longer.
- **Compute.** FLOPs (multiply-add = 2), counting everything DFG does in a fit, including the cross-validation fits. An
  audit's independent ufunc-level count agrees with DFG's counter to within 0.98–1.00. Prediction is counted for
  neither side. The budget unit is one network run, 6P·64·T + 10P·T with T the step count (1.62·10¹¹ FLOPs at d = 30),
  which is what each (n, seed) network costs; vmap shares no computation between networks.
  - *CPU time is a different matter.* DFG's FLOPs run at about 7 GFLOP/s (float64 numpy, driven from Python), against
    32–50 GFLOP/s for the networks (float32 under XLA). So at n = 16384 a DFG fit takes roughly 0.6–1.7× a network's
    CPU time. The claim is about FLOPs.
- **What is in-sample.**
  - *Designed suite.* DFG's settings — notably the small-n rules and the n ≥ 4d gate on the spectral block — were chosen
    by looking at its test error here, so these results are in-sample.
  - *Random-formula suite.* It was run twice with intermediate versions and read, so it is a development check, not
    out-of-sample.
  - *Held-out suite 1* (12 targets, `make_dl_heldout_suite`, commit 805bff0e). Its networks were trained, and their
    curves inspected, before DFG v1 was frozen; DFG was run on it only after the freeze. One exception: the degree-5/6
    search was added knowing that par5 was in the suite, and par5's result depends on it entirely. The table therefore
    also shows v1 *without* that search (K_hi = 4), which is fully blind.
  - *Held-out suite 2* (7 targets, `make_dl_heldout2_suite`) is blind for v1.1.

## 3. Results

[RESULTS]

## 4. Ablations: which ingredient carries the gain

[ABLATIONS]

## 5. Where DFG is worse, and its limits

- **The cells where DFG is worse.** These are listed per suite in `RESULTS.md`, and there are three kinds.
  - *Tiny n (16–64).* Both learners are near chance there. DFG's union-bound tests pass nothing, so it relies on the
    Hebbian background and the forced guess, and these are sometimes a few points worse than what the networks
    interpolate to.
  - *The dense halfspace thr30 at large n (v1 only).* That was the least-squares readout; v1.1 fixes it.
  - *MAJ5 ⊕ MAJ5 at n = 64–256.* The networks are partly there (0.36 at n = 256) while DFG is at chance. Its only route
    is the spectral block, which waits for n ≥ 4d and for an eigenvalue above the noise edge, and the networks start
    using the weak pair correlations sooner. DFG overtakes them by n = 1024 (0.03 against 0.16).
- **The inductive bias is narrow.** DFG's dictionary is characters on the Boolean cube (plus a few quadratic forms), and
  its tests rely on the characters being orthogonal under the uniform distribution. It is not a general-purpose learner:
  other input distributions, real-valued inputs and images would all need a different dictionary. The networks are
  generic. The claim is only the user's: as good or better on the toy problems where gradient descent does well.
- **Compute grows as d^K.** An exhaustive degree-k search costs about n·d^k. Under a fixed budget DFG subsamples, so a
  high-degree feature must have a large coefficient to be found: at d = 30 the degree-6 search sees about 150 points.
  Degrees 5–6 are skipped at d ≥ 60 (m < 64), and degree 4 is subsampled there (m ≈ 2200 at d = 60, m ≈ 360 at d = 120, in v1.1). A
  sparse degree-7 parity at d = 30 is out of reach for DFG under this budget; at n ≤ 16384 it is out of reach for the
  networks too.
- **One network configuration.** The reference is the study's fixed configuration: width 128, Adam lr 1e-3, 20000 steps,
  square loss. Earlier parts found its n* moves by tens of percent with width and optimizer, not by the factors seen
  here.
- **CPU time.** In wall-clock on this machine DFG is not faster: see the compute paragraph in Section 2.

## Reproduce

```
cd study/discrete_learner
python run_eval.py dfg_frozen_359a6b61:DFG designed       # frozen v1; also random, dlheld
python run_eval.py 'dfg:DFG:{"readout": "logit"}' dlheld2  # v1.1; also designed, dlheld, designed_d15/_d60/_d120
./run_ablations.sh
python make_tables.py                                     # RESULTS.md
```
The network reference files are the study's `fixed_adam_<fn>.npz` (Part 1; held-out suites from
`SUITE=dlheld[2] python nn_train.py --fns all --out <dir>`).
