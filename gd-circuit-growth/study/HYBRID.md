# Kernel background plus grown features: closing the per-example agreement gap

Added on 23 October 2026. Status labels as in the [project README](../README.md): **Numerical** (measured here),
**Heuristic** (argued, not proved), **Proved**. Everything below is Numerical unless labelled otherwise, at one input
dimension ($d=30$), one width (128) and one optimizer setting (Adam, learning rate $10^{-3}$), as in the rest of the study.

**Question.** The [race model](models/race.py) matches the networks' sample complexity on held-out targets
([MODEL-SCOREBOARD.md](MODEL-SCOREBOARD.md)), but agrees with their *individual* mistakes much less (per-example
agreement 0.50) than the NNGP kernel does (0.69), although the kernel's learning curves are far worse. Hypothesis: a
trained network is its random-feature (kernel) background plus a few grown features, and on partially learned cells the
background decides which test points are wrong. (1) Diagnose where the networks, the race and the kernel err; (2) build a
race + kernel-background model with at most two new constants, calibrated on CALIB; (3) score it on the full grid,
HELDOUT primary.

## Summary

__SUMMARY__

## 1. Diagnosis

Script: [`hybrid_diagnose.py`](hybrid_diagnose.py) (per-cell numbers in [`hybrid_diagnose.json`](hybrid_diagnose.json)).

### 1.1 The cells

The per-example statistic of [`common.compare`](common.py) uses the *partial cells*: $(f,n)$ where the networks'
seed-mean test error is in $[0.05,0.45]$. There are 95 of them (44 HELDOUT, 51 CALIB), each with 3 seeds. 52 of the 95 are
at $n\le128$ and all are at $n\le2048$, so the statistic mostly measures the small-sample regime, in which every
learner is still far from the target. On each cell, every learner below is trained on the same training set as the
network it is compared with. The statistic is the excess agreement over independent errors, as a fraction of its
maximum.

### 1.2 How much agreement is attainable: part of the reference is shared initialisation

In the main sweep the seed fixes both the training set and the initialisation, and the NN-SGD reference (0.71) shares
both with the Adam networks. [`hybrid_reinit.py`](hybrid_reinit.py) retrains the Adam networks on the same training
sets (same minibatch order) from fresh initial weights.

| learner, scored against the Adam networks (HELDOUT, 44 partial cells) | shares with them | per-example agreement |
|---|---|---|
| networks trained with μP-SGD | training set **and initialisation** | 0.71 |
| networks trained with Adam from a new initialisation | training set | **0.62** |
| NNGP kernel regression | training set | 0.69 |
| race | training set | 0.50 |
| hybrid (section 2) | training set | 0.65 |

__ENSEMBLE__

Without the shared initial weights the reference drops from 0.71 to 0.62: 0.09 of the race's 0.21 gap to it is
shared initialisation, which no model of the learning rule can reproduce. The deterministic kernel agrees *more* than
another network on the same data does (0.69 against 0.62): it behaves like the network averaged over initialisations.
The race's gap to an honest ceiling is therefore 0.50 against about 0.62–0.69, not 0.50 against 0.71.

### 1.3 Signal and sample noise: the race gets the signal, the kernel gets the noise

Each learner's real-valued output, standardised on 16384 fresh uniform points, is split into its relevant-coordinate
part $f_R(x)=\mathbb E[f\mid x_R]$ ($R$ = the target's relevant variables) and the rest $f_\perp=f-f_R$. The target has
$f_\perp=0$, so $f_\perp$ is the part of the fit that comes from the particular training sample. Correlations with the
network's own parts (HELDOUT partial cells, averages over cells and seeds):

| learner | test error | variance share of $f_\perp$ | corr. of $f_R$ | corr. of $f_\perp$ | corr. degree 1 | corr. degree 2 | corr. degree $\ge3$ | φ of the error indicators |
|---|---|---|---|---|---|---|---|---|
| network (Adam) | 0.230 | 0.45 | – | – | – | – | – | – |
| race | 0.233 | 0.48 | 0.92 | **0.48** | 0.86 | 0.52 | 0.37 | 0.50 |
| NNGP kernel | 0.238 | 0.44 | 0.96 | **0.81** | 0.95 | 0.78 | 0.67 | 0.69 |
| hybrid | 0.222 | 0.41 | 0.96 | 0.75 | 0.94 | 0.76 | 0.61 | 0.64 |
| network, SGD, same initialisation | 0.249 | 0.51 | 0.98 | 0.82 | 0.96 | 0.85 | 0.69 | 0.70 |
| network, Adam, new initialisation | 0.230 | 0.44 | 0.95 | 0.70 | 0.92 | 0.67 | 0.56 | 0.61 |

(CALIB: the same picture; race 0.92 / 0.49, kernel 0.96 / 0.81, hybrid 0.95 / 0.76 for $f_R$ / $f_\perp$.)

- **Almost half of the networks' output on these cells is sample noise** (share of $f_\perp$ 0.45; 0.59 at
  $n\le64$, 0.23 at $n\ge2048$). Every learner has about as much of it (0.41–0.51), and every learner matches the
  network's *signal* $f_R$ (0.92–0.98).
- **What separates them is the shape of the noise.** The network's $f_\perp$ correlates 0.81 with the kernel's and
  0.48 with the race's. The kernel's is closer to the network's than a re-initialised network's is (0.70).
- By $n$ (all partial cells), the correlation of $f_\perp$ with the network's:

  | $n$ | cell-seeds | network's share of $f_\perp$ | race | kernel | hybrid | network, new init | network, SGD, same init |
  |---|---|---|---|---|---|---|---|
  | 16–64 | 117 | 0.59 | 0.63 | 0.84 | 0.84 | 0.72 | 0.88 |
  | 128–256 | 96 | 0.42 | 0.45 | 0.84 | 0.76 | 0.76 | 0.83 |
  | 512–1024 | 60 | 0.27 | 0.32 | 0.74 | 0.63 | 0.62 | 0.76 |
  | 2048 | 12 | 0.23 | 0.21 | 0.59 | 0.46 | 0.46 | 0.58 |

  The race's noise departs further from the network's as $n$ grows (that is where it fires 20–48 dense gates); the
  kernel's stays close up to $n=1024$.

### 1.4 The fingerprint: the degree-1 noise points along the kernel's direction, not the Hebbian one

On the irrelevant coordinates, the cosine between the network's degree-1 Fourier coefficients and

| raw Hebbian vector $\mathbb E_S[(y-\bar y)x]$ | ridge least squares | race | NNGP kernel | hybrid | network, new init | network, SGD, same init |
|---|---|---|---|---|---|---|
| 0.72 | 0.76 | 0.73 | **0.92** | 0.89 | 0.87 | 0.93 |

(HELDOUT; CALIB 0.72 / 0.77 / 0.71 / 0.91 / 0.88.) All of them carry the same *amount* of degree-1 noise: noise
divided by total degree-1 norm is 0.57–0.61 for every row. The race's order-1 unit is the raw Hebbian direction
$\mathbb E_S[r\,u]$, and its noise is the Hebbian's (0.73 against 0.72). The network's noise is the kernel
interpolant's: for a dot-product kernel on the cube, the predictor $\sum_i\alpha_iK(x,x_i)$ has degree-1
coefficients $\mu_1X^\top\alpha$ with $\alpha=(K+\lambda)^{-1}y$, so each training point is weighted by its dual
coefficient instead of uniformly. This is a direct trace of minimum-norm (kernel) fitting of the training sample. A
gate grown on the residual of a fitted background inherits that direction: the residual of kernel ridge regression is
$\lambda\alpha$, so its Hebbian vector $X^\top\lambda\alpha$ is parallel to the kernel's degree-1 coefficients
(*Proved*: $\mathbb E_x[K(x,x')\chi_S(x)]=\mu_{|S|}\chi_S(x')$ for dot-product kernels on $\{-1,1\}^d$). The
hybrid exploits this (0.89).

### 1.5 Where the errors are

- **Conditional error rates** (HELDOUT points, pooled over cells): the network is wrong on 63% of the points where the
  kernel is wrong and the race right, and on 23% of the points where the race is wrong and the kernel right. Where
  both are right, the network is wrong on 5%; where both are wrong, on 81%. (CALIB: 64%, 23%, 6%, 83%.)
- **Relevant coordinates.** 96% of every learner's errors are on boundary points, where flipping one relevant
  coordinate changes the label. The error rates are 0.26–0.30 there and 0.05–0.07 on interior points, alike for
  network, race and kernel. *Which region* of the relevant cube is wrong is decided by the signal, which all learners
  share. *Which points within it* are wrong is decided by the noise.
- **Distance to the training set** does not discriminate. Every learner agrees with the label of the nearest training
  point on 69–72% of test points. At $d=30$ the nearest training point is a median 10 flips away at $n=16$ and 6 at
  $n=2048$, so there is little local memorisation to match.

### 1.6 Swap test

A diagnostic that uses the relevant variables. Take learner A's relevant part and threshold, add learner B's noise
pattern rescaled to A's noise variance, and score $\operatorname{sign}(c_A+f_{R,A}+f_{\perp,B})$ like a learner
(HELDOUT; CALIB in brackets).

| prediction | per-example agreement |
|---|---|
| race | 0.50 (0.51) |
| race's signal + kernel's noise | **0.63** (0.64) |
| race's signal + a re-initialised network's noise | 0.58 |
| kernel's signal + race's noise | **0.53** (0.52) |
| kernel | 0.69 (0.67) |

Swapping only the noise pattern moves the race from 0.50 to 0.63, and the kernel from 0.69 to 0.53. The gap is in the
noise, not in the signal.

__WIDTH__

## 2. The hybrid model

### 2.1 Design ([`models/hybrid.py`](models/hybrid.py))

The race is kept exactly (search, alignment, growth, firing; $\theta=1.5$, $\lambda=10^{-3}$, $Q=3$, ReLU gates). Three
things are added.

1. **A background in the readout.** At race time $t$ the readout is the joint ridge fit
   $$\min_{a,\,f_{\rm bg}}\ \lVert y-c-Fa-f_{\rm bg}\rVert^2+\lambda_g\lvert a\rvert^2+\lambda_{\rm bg}(t)\,\lVert f_{\rm bg}\rVert_K^2 ,$$
   with $F$ the race's standardised gate columns, $\lambda_g=10^{-3}n$ the race's own ridge, and $K$ the NNGP kernel of
   the networks' architecture at initialisation (the kernel baseline's, unit diagonal). Equivalently, kernel ridge
   regression with kernel $K+(\lambda_{\rm bg}/\lambda_g)FF^\top$. The race's units align to, and fire on, the
   residual of this joint fit, so the background competes with gate growth.
2. **The background flows on the race clock:** $\lambda_{\rm bg}(t)=c_{\rm bg}\,n/t$ (new constant 1).
   *Heuristic:* this is kernel gradient flow on the mean square loss. After time $t$, kernel GD has fitted the
   residual's components along kernel eigenvalues $\kappa\gtrsim n/(\eta t)$ (eigenvalues of the $n\times n$ Gram
   matrix), which is to first order ridge regression with $\lambda\approx n/(\eta t)$; $c_{\rm bg}=1/\eta$. Two time
   scales follow without further assumptions. The target's low-degree part sits on eigenvalues $\propto n$ and is
   fitted at $t\sim c_{\rm bg}/\mu_k$, independent of $n$. The training-sample noise sits on the flat bottom of the
   spectrum, $\kappa\approx0.3$–$0.5$ per training point whatever $n$, and is memorised only at
   $t\gtrsim c_{\rm bg}n/0.4$: before the race's dense memorising gates can fire on small training sets, after the real
   features have fired on large ones.
3. **Growth stops at a square-loss level, and training then continues.** Gates are grown while the joint fit's
   training mean squared residual is $\ge$ `stop_mse` (new constant 2), checked continuously in time (if the
   background gets there before the next gate would fire, growth stops at that time). Afterwards the gate weights are
   kept and the background interpolates what is left (kernel ridge on $y-c-Fa$ with the kernel baseline's ridge
   $10^{-4}$), because the networks keep training for 20000 steps after their circuit stops growing.

For $n>2048$ the background is a rank-512 random-feature approximation of the same kernel (features of a fresh
two-hidden-layer ReLU network, seeded from the data so that the race's random stream is unchanged). The full grid
(21 targets × 11 sizes × 3 seeds) takes 9.5 minutes single-threaded on the shared machine. With the background
switched off (mode `none`) the code reproduces the race's predictions exactly (checked on several cells).

### 2.2 Calibration on CALIB

Each design was scored on the 12 CALIB targets, $n\le4096$ (all CALIB partial cells and $n^*$ crossings lie there).
The constants were chosen by CALIB per-example agreement minus CALIB mean $\lvert\log_2 n^*\text{ ratio}\rvert$.
Calibration logs: [`models/scratch_hybrid/`](models/scratch_hybrid/).

| background | growth stops at | constants | CALIB $n^*$ error | CALIB per-example agreement | mean gates on the partial cells of all 21 targets |
|---|---|---|---|---|---|
| none (the race) | sign error 0 | – | **0.24** | 0.51 | 20 |
| static, $\lambda_{\rm bg}=\rho n$ | sign error 0 | $\rho=10^{-4}$ / $3\cdot10^{-4}$ / $10^{-3}$ / $3\cdot10^{-3}$ | 0.81 / 0.74 / 0.61 / 0.52 | 0.68 / 0.67 / 0.64 / 0.59 | 2 / 4 / 10 / – |
| flow, $c_{\rm bg}n/t$ | sign error 0 | $c_{\rm bg}=0.001$ / 0.003 / 0.01 | 0.81 / 0.66 / 0.40 | 0.67 / 0.67 / 0.67 | – / – / 2 |
| flow, $c_{\rm bg}\sqrt n/t$ ; $c_{\rm bg}/t$ | sign error 0 | 0.3 ; 3 | 0.40 ; 0.54 | 0.62 ; 0.62 | 3 ; 2 |
| flow, $c_{\rm bg}n/t$ | MSE < 0.01 | $c_{\rm bg}=0.003$ / 0.01 / 0.03 | 0.39 / 0.42 / 0.39 | 0.62 / 0.56 / 0.53 | – |
| flow, $c_{\rm bg}n/t$ | MSE < 0.03 | $c_{\rm bg}=0.001$ / **0.003** / 0.01 / 0.03 | 0.51 / **0.37** / 0.42 / 0.39 | 0.68 / **0.65** / 0.59 / 0.55 | – / 2 / – / – |
| flow, $c_{\rm bg}n/t$ | MSE < 0.1 | $c_{\rm bg}=0.001$ / 0.003 / 0.01 | 0.75 / 0.50 / 0.42 | 0.67 / 0.68 / 0.63 | – |
| NNGP kernel alone | – | – | 1.83 | 0.67 | 0 |

("–" = not recorded. The static rows used an earlier implementation with the exact kernel up to $n=4096$; the chosen
setting is in bold.) Selected: **$c_{\rm bg}=0.003$, `stop_mse` $=0.03$** (score 0.28, against 0.27 for flow with the
race's sign rule at $c_{\rm bg}=0.01$ and 0.27 for the race itself).

What the calibration shows:
- **A static background is a pure trade-off (negative result).** Every $\rho$ buys agreement only by suppressing
  growth: the background memorises the sample before the real features fire, and $n^*$ drifts towards the kernel's
  (par2: 449–546 against the networks' 200 for $\rho\le10^{-3}$).
- **The flowing background breaks the trade-off.** At equal agreement (0.67) the flow loses 0.40 in $n^*$ against the
  static background's 0.68–0.81. Scaling the ridge as $n/t$ (the mean-loss gradient-flow scaling) is better than
  $\sqrt n/t$ or $1/t$.
- **The race's stopping rule is wrong once a background is present.** With "stop at training sign error 0", small
  $c_{\rm bg}$ stops growth as soon as the background's degree-1 fit classifies the training set. On MAJ$_3$ at $n=512$
  that happens before any gate fires, and the test error stays at the kernel's 0.057 (networks 0.008). With the MSE
  rule the MAJ$_3$ gate fires and the error is 0.001.
- **The end-of-training interpolation matters for agreement.** On the partial cells, flow with the sign rule at
  $c_{\rm bg}=0.01$ scores 0.55 (CALIB) without it and 0.67 with it, at the same gates: the networks' mistakes are those
  of a background that has interpolated, not of an early-stopped one.
- **The kernel's identity barely matters.** Kernel ridge regression with the infinite-width NTK of the same
  architecture scores the same per-example agreement as the NNGP kernel (0.672 against 0.671 on CALIB, 0.692 against
  0.690 on HELDOUT). The first-layer NTK term alone (0.62) or a one-hidden-layer NNGP kernel (0.62) are worse.

## 3. Scoreboard

__SCOREBOARD__

## 4. What this says about how trained networks combine kernel-like and feature-growth behaviour

The labels are Heuristic unless stated otherwise: these readings are what the measurements above suggest, at one
architecture.

1. **Two channels with separate jobs.** On partially learned cells, a trained network's output is a signal part,
   shared with every reasonable learner (correlation 0.92–0.98), plus a sample-noise part (45% of the variance). The
   test error, and hence $n^*$, is set by which features exist: the feature-growth channel, which the race models. The
   identity of the mistakes is set by the sample-noise part, and that part has the shape of minimum-norm interpolation
   of the training sample by the network's kernel at initialisation: correlation 0.81 with NNGP kernel regression,
   degree-1 noise direction 0.92. The networks memorise like a kernel and generalise like a feature learner.
2. **Two clocks.** A kernel fits by gradient flow along its spectrum. The target's low-degree part sits on large
   eigenvalues and is fitted early. The training sample's noise sits on the flat bottom of the spectrum and takes a time
   proportional to $n$. Feature growth runs on its own clock, set by utility and alignment. On small training sets the
   background has memorised the sample before any memorising feature could grow; on large ones the real features
   arrive first and the background only interpolates their residual. A background whose strength is fixed in time
   cannot reproduce both regimes (section 2.2), and a background that flows on the race clock can, with one rate
   constant.
3. **The networks do not memorise with grown units.** The race, which has nothing else to fit the sample noise with,
   fires about 20 dense, noisy gates per partial cell. The hybrid fires about 2 and matches $n^*$ as well (HELDOUT
   0.35 against 0.33). In the race's own terms, roughly nine in ten of its gates on these cells are memorisation the
   networks do with their random-feature background instead. This bears on the generalisation bounds of Part 2 of
   the README:
   - the "circuit" a network grows on a small training set is a few gates, not tens;
   - the rest is a kernel component with an RKHS norm;
   - so a bound that pays Occam for the few gates and a kernel-norm (Rademacher) term for the background is the natural
     a-priori candidate (not attempted here).
4. **How much is init, how much is data.** Two networks trained on the same data from different initialisations agree
   on their mistakes less (0.62) than either agrees with the init-free kernel (0.69). The kernel behaves like the
   init-averaged network. The SGD and Adam networks' 0.71 includes their shared initial weights (without them: 0.62),
   so it is not a ceiling for a learning rule that does not see the network's initialisation.
5. **What the kernel picture misses: the networks are worse than their own kernel at small $n$ on easy targets.** The
   networks' $n^*$ exceeds the NNGP kernel's by 1.1–2.2× on the five targets where the kernel is good: $x_1$ 47 vs 29,
   AND$_3$ 94 vs 64, MAJ$_3$ 112 vs 73, decision list 110 vs 96, rand2 91 vs 41. The race reproduces this (54, 108,
   102, 163, 85), because its first gate is a noisy Hebbian unit. The hybrid does not (29, 65, 70, 98, 41), because at
   the calibrated $c_{\rm bg}$ its background pre-empts that gate. The networks' small-sample inefficiency is therefore
   a feature-channel effect, a grown unit that adds sample noise, but its noise points along the kernel's direction
   (section 1.4). This is the hybrid's main remaining discrepancy, and the reason its CALIB $n^*$ error (0.37) is
   above the race's (0.24).

## 5. Caveats and open items

- **Scope.** One architecture, one width, one optimizer setting, $d=30$; the hybrid's two constants were calibrated on
  12 targets and checked on 9. The width check (section 1.7) is on a few targets only.
- **The trade-off is reduced, not removed.** On CALIB the hybrid's combined score (agreement minus $n^*$ error, 0.28)
  is barely above the race's (0.27). On HELDOUT it is clearly above (0.30 against 0.17). In both splits the hybrid stays
  below the kernel's per-example agreement (0.65 against 0.69 on HELDOUT). Lower $c_{\rm bg}$ reaches the kernel's
  agreement but loses $n^*$ (section 2.2).
- **The time scale is the background's weak point.** The correlation of the hybrid's sample noise with the network's
  falls from 0.84 at $n\le64$ to 0.46 at $n=2048$ (kernel 0.59): at larger $n$, gates still fire before the background
  has memorised, and they bring race-like noise. A background that memorises faster at large $n$ than $c_{\rm bg}n/t$
  allows, or gates that stop competing with it, might close this.
- **Random features above $n=2048$.** The rank-512 random-feature background cannot interpolate there. It affects no
  partial cell, but it makes the hybrid fire more gates at $n\ge4096$ than the race (22 against 15 on average), with no
  visible effect on the learning curves.
- **The init-averaged network.** The claim that the kernel behaves like the network averaged over initialisations rests
  on one or three re-initialisations (section 1.2). It is consistent with, but not a proof of, the mean-field / NNGP
  picture of the networks' sample-noise response.
- **Not done.** The $d$-scaling study (DSCALE.md) and the random-formula suite were not re-run with the hybrid. The
  networks' noisy small-$n$ feature (point 5 of section 4) is not modelled.

## Files

| file | contents |
|---|---|
| [`models/hybrid.py`](models/hybrid.py) | the hybrid model (race gates + NNGP-kernel background flowing on the race clock); modes `flow` (the model), `static` and `none` (= the race, checked to reproduce `models/race.py` exactly) |
| [`models/run_hybrid_eval.py`](models/run_hybrid_eval.py) | full-grid evaluation of the hybrid and its ablations |
| [`hybrid_diagnose.py`](hybrid_diagnose.py) → [`hybrid_diagnose.json`](hybrid_diagnose.json) | the diagnosis of section 1 (signal / sample-noise decomposition, degree-1 noise direction, error location, swaps) and the network-vs-network ceilings (`ceiling` mode → [`hybrid_ceiling.json`](hybrid_ceiling.json)) |
| [`hybrid_reinit.py`](hybrid_reinit.py) | networks retrained on the same training sets from new initialisations |
| [`hybrid_width.py`](hybrid_width.py) | the width check of section 1.7 |
| [`hybrid_report.py`](hybrid_report.py) → [`hybrid_scoreboard.json`](hybrid_scoreboard.json) | the scoreboard of section 3 |
| `models/scratch_hybrid/` | calibration scripts and logs (kept for the record) |

Raw outputs (re-initialised networks, model evaluations) are in the session scratchpad, like the rest of the study's raw data.
