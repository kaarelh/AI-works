# dfg_dirs: DFG with a dictionary of data-derived directions

Learner `dfg_dirs.learner.Learner()` (name `dfg_dirs-v2`; frozen file md5 `2e8540e3…`), developed on the five dev
datasets only (optdigits, magic, kr_vs_kp, satimage, spambase). numpy and scipy only: no sklearn, no trees, kNN or
SVMs, and no gradient descent on any feature parameter. No held-out dataset was loaded.

## The idea

An MLP's hidden unit is a thresholded linear direction, ReLU(w·x + b). This adaptation keeps DFG's discrete
enumerate-and-test loop. The candidate units are gates [u·z > t], hinges [u·z > t](u·z − t) and squares (u·z)².
Here u ranges over a **finite set of axes that the data supplies**, and t over 16 quantile cuts of u·z. Every
candidate is tested against the current least-squares residual with a union-bound threshold. Whatever passes is
accepted in rounds. The readout weights are the only continuous parameters. A hinge is a gate times an accepted linear
feature, so it is a composition of accepted features, not a new continuous unit: its direction and threshold are
picked from a finite list.

## Algorithm

1. **Encoding.** z = `harness.encode_standard` (continuous standardized, binary ±1, categorical one-hot over the codes
   seen in training), constant columns dropped, clipped to [−6, 6].
2. **Linear block** (DFG's linear block and kernel background). The intercept and all D coordinates. The ridge on these
   coordinates is chosen by GCV from one eigendecomposition of the centered Gram matrix. A χ² test (statistic
   ‖P_Z R_w‖²_F against the χ²_{D·C′} tail at level δ) decides whether the block counts as signal. If it fails, the
   block stays in as a 10× more heavily ridged background.
3. **Rounds** (up to 40). Each round does the following.
   - Fit the one-hot labels Y by least squares (ridge 1e-3·n on the grown features) and take R = Y − fit.
   - Whiten R over classes: R_w = R V Λ^{-1/2} from the eigendecomposition of RᵀR/n, keeping C′ = C − 1 columns.
   - Score candidates. The score of a feature f is T(f) = ‖R_wᵀ f_⊥‖² / ‖f_⊥‖², which is ≈ χ²_{C′} under the null.
     This is DFG's |mean(r χ_S)| / (s/√n) test, made multi-class with a χ² statistic summed over the whitened class
     residuals.
   - Candidate classes. Each class has its own size N and threshold τ(N) = c² · χ²_{C′}.isf(δ / (K N)), with
     c = 0.8, δ = 0.1, K = 4.

     | class | candidates | DFG element |
     |---|---|---|
     | `coord` | gates and hinges (both sides) on every non-binary coordinate, at 16 quantile cuts | global degree-1 search |
     | `dir` | gates, hinges and squares on the direction axes derived this round (below) | spectral block / new directions |
     | `prod` | f_a · g for the top 24 accepted non-linear features f_a (by readout weight × std) and any gate or hinge g on any active axis, coordinate or direction, not already in f_a; one union bound over all bases × all cuts | composition: extensions of current features |

   - Direction axes are derived anew each round. A new axis is kept only if its cosine with every existing direction
     axis is below 0.98. The axes are:
     - *discriminant directions* (round 0): the linear block's per-class weight vectors in the current fit;
     - *spectral directions*: the top 2 eigenvectors of each M_c = Zᵀ diag(r_w,c) Z / n. Each must clear the noise edge
       2σ√(D/n)(1 + √(2 ln(1/δ)/D)), with σ² = mean(r_w² (‖z‖²/D)²). This is DFG's spectral block with its Wigner-edge
       gate. It applies only when n ≥ 2D;
     - *local directions* (composition): for the top 8 bases f_a, the leading left singular vector of
       Zᵀ(R_w ⊙ f_a)/n, which is the residual's class-mean difference inside the region where the gate f_a is on;
     - *prototype directions* (multi-class tasks only): the 32 centered training points with the largest whitened
       residual. A gate on u·z is then a halfspace through a misfit example.

     A direction axis that no accepted feature uses drops out of the scan after the round in which it was derived.
   - *Minimum support.* A gate, hinge or product needs at least 30 rows on its smaller side. On a handful of rows the
     χ² tail is not valid, and products then memorize single training points.
   - The scan computes the marginal scores of all cuts of all active axes at once. It bins every (row, axis) pair by its
     cut interval and runs one `bincount` per whitened class column (plus f², f²p and f²p² for the hinges). Cumulative
     sums over the ≤ 17 bins then give every cut's score. The denominator projects out the base f_a. No pass over the
     data is made per candidate.
   - Acceptance. The top 512 marginal passers are materialized and orthogonalized against the current features. They
     are then accepted greedily in Gram space while each one's *orthogonalized* score still clears its own class
     threshold, at most 64 per round. This is DFG's "accept everything that passes", made safe for correlated
     candidates: neighbouring cuts of one axis do not all get in.
   - Stop when any of these holds:
     - nothing passes;
     - p·√C′ ≥ n/3 (p ≤ 800); the LS readout has p·C′ weights;
     - after 40 rounds;
     - the FLOPs spent plus the reserved cost of the readout at the next round's size would pass 0.75 of the budget.
4. **Readout.** Multinomial logistic regression (softmax) on the standardized grown features, with an L2 penalty,
   fitted by L-BFGS (scipy). λ ∈ {1e-1 (only at n ≤ 1000), 1e-2, 1e-3, 1e-4} is chosen by cross-validation on the
   training set: 5-fold at n ≤ 1000, 3-fold above, warm-started from the largest λ, with ties going to the larger λ.
   The L-BFGS iteration cap (at most 120) is set so that the readout fits in what is left of the budget. This is DFG
   v1.1's logistic refinement generalized to C classes; least squares is the readout during growth.
5. **Compute.** FLOPs are counted for every matrix product, solve, eigendecomposition, SVD, sort, bincount, cumulative
   sum, and every L-BFGS function and gradient evaluation (multiply-add = 2), including the CV fits. The count is
   compared with `harness.mlp_flops` (one MLP training run at that n).
   - *Audit.* A copy of the learner adds the terms the counter leaves out: the LU in the orthogonalization solve, the
     per-round training-error diagnostics, the score arithmetic and the readout standardization. On optdigits at
     n = 4215, satimage at 4826, magic at 14265 and spambase at 3000, it changes the total by less than 0.1%.

## Mapping to DFG

| DFG (Boolean, ±1 uniform, binary labels) | dfg_dirs |
|---|---|
| characters χ_S, enumerated by degree | gates and hinges on axes × quantile cuts; squares on directions |
| test \|mean(r χ_S)\| > c s √(2 ln(4KN/δ)/n) | ‖R_wᵀ f_⊥‖²/‖f_⊥‖² > c² χ²_{C′}.isf(δ/(KN)), with whitened multi-class residuals |
| extensions S ∪ {j}, S ∪ {j, l} | products f_a · g with any gate or hinge g (one union bound per round over bases × cuts) |
| local search on the inputs in use | local directions: residual class-mean difference inside an accepted gate's region |
| linear block (χ²_d test) | linear block on all encoded coordinates (χ²_{D·C′} test), GCV ridge |
| spectral block, (u·x)², Wigner edge | spectral directions above the edge, with squares, gates and hinges on them |
| readout: LS, refined by logistic regression (v1.1) | LS during growth; softmax with L2, λ by CV, at the end |
| budget: subsampled searches inside a share of one network run | marginal scans are cheap (bincount), so they run on all rows; growth stops so that growth plus a reserved readout cost stays within 0.75 of one MLP run |

## Development history and choices (all on dev data)

Single-seed runs at n ∈ {300, 1000, 3000} (seed 0, sometimes seed 1). The test-set s.e. is about 0.004–0.006 at these
error levels, so small differences are noise.

- **v1** (c = 0.8, ≤ 20 rounds, ≤ 48 accepted per round, top 256, feature cap p ≤ n/3, no minimum support). Kept as
  `learner_v1.py` and run once on the full dev grid (`results/dfg_dirs-v1__*.json`): mean log2(err/MLP) = +0.15; better than the MLP by > 10% in 3 of
  24 cells, worse in 9. The full grid showed two problems:
  - On optdigits at n = 4215 it was worse than at n = 3000, and the LS training error was still 3%: it underfits. Too
    few rounds, and too few accepted per round.
  - It was worse than linear logistic regression at n = 100 on satimage.
- **v2** (frozen) was made after reading those dev results.
  - *More growth.* Up to 40 rounds, 64 accepted per round, top 512. Unused direction axes are pruned from the scan.
  - *Budget reservation for the readout.* An intermediate version went over the budget (1.3–1.4× at optdigits
    n = 3000–4215) because the CV readout on several hundred features is expensive. Growth now stops when the spent
    FLOPs plus the reserved readout cost would pass 0.75 of the budget, and the L-BFGS iteration cap is set from what
    is left.
  - *Readout CV.* λ = 0.1 is added at n ≤ 1000, the CV is 5-fold at n ≤ 1000, and ties go to the larger λ.
  - *Minimum support of 30 rows* per candidate. With more rounds, optdigits at n = 1000 went from 0.046 to 0.055–0.063
    (training error 0, CV error 2%). The readout CV cannot see the overfitting, because the features were selected on
    the whole training set. The minimum support is what took kr_vs_kp at n = 2397 to 0.005 / 0.004 (seeds 0 / 1).
  - *Feature cap p·√C′ ≤ n/3* (it was p ≤ n/3). Without it, the minimum support alone left optdigits at n = 1000 at
    0.063 / 0.055 (p = 333). With it, p = 111 and the error is 0.040 / 0.041.
  - A first full-grid run of an intermediate v2 (without the last two changes) was stopped after 8 optdigits fits
    because of that n = 1000 regression. It wrote no results file.
- **Choices kept from v1 development.**
  - *Prototype directions.* The largest single gain on optdigits (n = 3000: 0.0335 → 0.024–0.027). They hurt or did
    not help on the binary tasks (magic n = 3000: 0.134 → 0.146; spambase n = 1000: 0.071 → 0.081), so they are used
    only when C > 2. That rule is a dev-data choice, not a derived one.
  - *c = 0.8* rather than DFG's 1.0: slightly better on 6 of 10 dev cells.
  - *Hinges* and *discriminant directions* kept. Dropping either gave mixed single-seed changes.

## Dev results (3 seeds, full grid, frozen v2)

Test error, mean of seeds 0–2 (`results/dfg_dirs-v2__*.json`; MLP from `results/mlp__*.json`; `linear` is the
multinomial logistic reference). Ratio = dfg_dirs / MLP. FLOPs: the largest of the 3 seeds, over `harness.mlp_flops`
at that n. CPU: seconds per fit, float64 numpy on one shared core.

| dataset | n | dfg_dirs err | MLP err | linear err | ratio | dfg_dirs FLOPs / MLP run | cpu s |
|---|---|---|---|---|---|---|---|
| optdigits | 100 | 0.1172 | 0.1310 | 0.1098 | 0.89 | 0.004 | 0.4 |
| optdigits | 300 | 0.0716 | 0.0600 | 0.0657 | 1.19 | 0.016 | 0.7 |
| optdigits | 1000 | 0.0422 | 0.0306 | 0.0403 | 1.38 | 0.080 | 1.7 |
| optdigits | 3000 | 0.0301 | 0.0230 | 0.0318 | 1.31 | 0.411 | 10.2 |
| optdigits | 4215 | 0.0301 | 0.0159 | 0.0313 | 1.90 | 0.837 | 23.3 |
| magic | 100 | 0.2351 | 0.2071 | 0.2303 | 1.14 | 0.000 | 0.1 |
| magic | 300 | 0.1913 | 0.1786 | 0.2196 | 1.07 | 0.000 | 0.1 |
| magic | 1000 | 0.1485 | 0.1553 | 0.2089 | 0.96 | 0.002 | 0.2 |
| magic | 3000 | 0.1417 | 0.1384 | 0.2051 | 1.02 | 0.032 | 1.0 |
| magic | 10000 | 0.1308 | 0.1369 | 0.2031 | 0.96 | 0.108 | 5.9 |
| magic | 14265 | 0.1264 | 0.1288 | 0.2034 | 0.98 | 0.152 | 12.6 |
| kr_vs_kp | 100 | 0.0859 | 0.0930 | 0.0847 | 0.92 | 0.000 | 0.2 |
| kr_vs_kp | 300 | 0.0638 | 0.0613 | 0.0580 | 1.04 | 0.001 | 0.2 |
| kr_vs_kp | 1000 | 0.0292 | 0.0313 | 0.0409 | 0.93 | 0.016 | 0.8 |
| kr_vs_kp | 2397 | 0.0046 | 0.0050 | 0.0300 | 0.92 | 0.150 | 2.5 |
| satimage | 100 | 0.1842 | 0.1566 | 0.1759 | 1.18 | 0.002 | 0.2 |
| satimage | 300 | 0.1500 | 0.1413 | 0.1603 | 1.06 | 0.008 | 0.5 |
| satimage | 1000 | 0.1131 | 0.1146 | 0.1421 | 0.99 | 0.098 | 2.5 |
| satimage | 3000 | 0.0901 | 0.0880 | 0.1342 | 1.02 | 0.264 | 6.5 |
| satimage | 4826 | 0.0839 | 0.0874 | 0.1367 | 0.96 | 0.376 | 10.4 |
| spambase | 100 | 0.1290 | 0.1467 | 0.1504 | 0.88 | 0.000 | 0.1 |
| spambase | 300 | 0.0916 | 0.0986 | 0.1078 | 0.93 | 0.003 | 0.2 |
| spambase | 1000 | 0.0687 | 0.0788 | 0.0852 | 0.87 | 0.126 | 2.3 |
| spambase | 3000 | 0.0490 | 0.0571 | 0.0800 | 0.86 | 0.185 | 4.8 |

**Summary over the 24 dev (dataset, n) cells.**

| | v1 (first full run) | v2 (frozen) |
|---|---|---|
| mean log2(err / MLP err), errors floored at 0.002 | +0.151 | **+0.055** |
| cells better by > 10% relative | 3 | **4** (spambase n = 100, 1000, 3000; optdigits n = 100) |
| cells worse by > 10% relative | 9 | **6** (optdigits n = 300, 1000, 3000, 4215; magic n = 100; satimage n = 100) |
| max FLOPs per fit / one MLP run | 0.90 | **0.84** |

Reading:
- *Ties with or beats the MLP on the tabular sets.* On magic, kr_vs_kp, satimage and spambase at n ≥ 1000, every cell
  is within 4% of the MLP or better. Spambase is 13–14% better at n = 1000–3000. The MLP-like regime is matched, at
  0.0–0.4 of one MLP run's FLOPs.
- *Worse on optdigits at n ≥ 300*, by 1.2–1.9×. At full n (0.030) it is no better than linear logistic regression
  (0.031), while the MLP reaches 0.016. The dictionary of data-derived directions (discriminant, spectral, local,
  prototype) plus products does not produce the distributed smooth features the MLP learns on digit images. Growth
  there is limited by the feature cap and by selection overfitting.
- *Small n.* At n = 100 the union bound passes almost nothing, so the fit is the linear block plus the softmax readout.
  That is better than the MLP on spambase and optdigits, but worse on magic and satimage, where the MLP at n = 100
  beats linear logistic regression too. On satimage at n = 100 it is also worse than the sklearn linear reference
  (0.184 against 0.176); the λ cross-validation on 100 points is noisy.
- At the full pool (magic 14265, satimage 4826, and kr_vs_kp 2397 apart from the CV folds) the training set is the
  same for every seed, and the learner is nearly deterministic, so the three seeds agree. Those cells carry no
  seed spread.

These dev numbers are in-sample for the design. Every rule above (c = 0.8, prototypes only when C > 2, the minimum
support, the class-scaled feature cap, the v2 growth limits) was chosen on these five datasets. Some were chosen after
seeing the v1 full-grid results.
