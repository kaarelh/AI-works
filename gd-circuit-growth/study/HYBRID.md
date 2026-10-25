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

- **Diagnosis: the gap is in the sample-noise part of the fit, and it is kernel-shaped** (section 1).
  - On the partial cells (95 cells, mostly $n\le256$), about 45% of a network's output variance depends on the
    particular training sample and not on the target's relevant variables.
  - The race, the kernel and other networks all match the remaining *signal* part (correlation 0.92–0.98).
  - The network's sample-noise part correlates 0.81 with the NNGP kernel's and only 0.48 with the race's. On the
    irrelevant coordinates, its degree-1 noise points along the kernel interpolant's direction (cosine 0.92), not along
    the raw Hebbian direction that the race's units use (0.72–0.73).
  - Swapping only the noise patterns moves the race's per-example agreement from 0.50 to 0.63, and the kernel's from
    0.69 to 0.53.
  - The race's noise comes from about 20 dense memorising gates per partial cell.
- **Part of the 0.71 reference is shared initialisation.** Networks retrained with Adam on the same training sets from
  new initial weights agree 0.62 with the originals. The deterministic NNGP kernel agrees more than that (0.69): it acts
  like the network averaged over initialisations. The average of three new-initialisation networks
  agrees 0.68, the kernel's level. *(Corrected in verification: 0.62 is the agreement between two single networks and
  is not a ceiling. A learner that never sees the initialisation can reach at least 0.68, the three-network average.
  Extrapolating in the number of averaged networks gives about 0.71–0.73, the level of the SGD reference. The kernel agrees
  0.78 with a three-network average, more than a fourth network does (0.68).)*
- **The model** ([`models/hybrid.py`](models/hybrid.py)): the race, unchanged, plus an NNGP-kernel background in a
  joint ridge readout.
  - The background fits by kernel gradient flow on the race clock (ridge $c_{\rm bg}n/t$).
  - Gates grow until the joint training square loss is below `stop_mse`.
  - After that the background interpolates the residual.
  - Two new constants, calibrated on CALIB: $c_{\rm bg}=0.003$, `stop_mse` $=0.03$.
- **Result on HELDOUT** (section 3):

  | | $n^*$ error | $n^*$ Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
  |---|---|---|---|---|---|---|
  | race | 0.33 | 1.00 | 0.95 | 0.01 | 0.50 | 0.83 |
  | **hybrid** | **0.35** | 0.93 | 0.96 | 0.01 | **0.65** | 0.81 |
  | NNGP kernel | 2.58 | 0.73 | 0.85 | 0.04 | 0.69 | 0.22 |
  | network, Adam, new initialisation | – | – | – | 0.01 | 0.62 | – |
  | network, SGD, same initialisation | 0.43 | 0.95 | 0.94 | 0.01 | 0.71 | 0.83 |

  - The hybrid keeps the race's $n^*$ match and raises per-example agreement from 0.50 to 0.65. That is above a
    re-initialised network, though below the kernel and the shared-initialisation reference.
    *(Corrected in verification: the race row is its worst of six internal random streams for $n^*$. Averaged over
    streams, HELDOUT $n^*$ error is 0.35 (0.30–0.38, 3 streams) for the hybrid and 0.28 (0.23–0.33, 6 streams) for
    the race. The hybrid therefore costs about 0.07 in $n^*$ error. Its agreement gain, 0.66 against 0.51, does not
    depend on the stream.)*
  - It fires about 2 gates per partial cell instead of 20.
  - CALIB: $n^*$ error 0.37 (race 0.24), per-example agreement 0.65 (race 0.51).
  - At other input dimensions, with the constants unchanged:
    - $d=15$: the hybrid beats the race on $n^*$ (0.39 against 0.45) and reaches the kernel's agreement (0.66; race
      0.42).
    - $d=60$: agreement improves less (0.55 against 0.42), and the $n^*$ match is worse than the race's (0.66 against
      0.43). *(Corrected in verification: most of this $n^*$ loss is the rank-512 random-feature background used above
      $n=2048$. With the exact kernel up to $n=8192$ on the 4-bit parity and the staircase, the $d=60$ $n^*$ error is
      0.47, against the race's 0.43.)*
- **Negative results** (section 2.2):
  - A background of fixed strength trades $n^*$ for agreement almost one for one.
  - The race's stop-at-sign-error-0 rule makes the background pre-empt real features. With that rule (one constant),
    HELDOUT $n^*$ error is 0.55 and Spearman 0.70.
  - The choice of kernel (NNGP or NTK) does not matter.
  - The hybrid is not better on these summary numbers than simply adding the race's and the kernel's standardised
    scores ([HYBRID-QUICK.md](HYBRID-QUICK.md), $\gamma=1$: HELDOUT $n^*$ error 0.29, agreement 0.62). Its advantage is
    mechanistic: one learner, about 2 gates instead of 20, and a background that memorises in their place.
- **Remaining discrepancies.**
  - On easy targets at small $n$, the networks are 1.1–2.2× less sample-efficient than their own kernel, and the
    hybrid inherits the kernel's efficiency there. This is the main cost in its $n^*$ match. It is not an Adam effect:
    the SGD networks are less efficient still.
  - The networks form their mistakes in a fixed order (section 1.8). They interpolate with kernel-like mistakes
    within 100–1000 steps, and near $n^*$ they grow the generalising features *afterwards*, during the remaining
    ~19000 steps. The hybrid's end state matches, but on large training sets its path runs in the opposite order.
- **Reading** (Heuristic, section 4): trained networks memorise like a kernel and generalise like a feature learner.
  - A random-feature background, flowing along its spectrum, absorbs the sample noise. That takes a time that grows
    at least in proportion to $n$.
  - Features grow for the structure the kernel cannot fit quickly, and they set $n^*$.
  - In the race's terms, roughly nine in ten of its gates on small training sets are memorisation that the networks
    do with their background instead.

## 1. Diagnosis

Script: [`hybrid_diagnose.py`](hybrid_diagnose.py) (per-cell numbers in [`hybrid_diagnose.json`](hybrid_diagnose.json)).

### 1.1 The cells

The per-example statistic of [`common.compare`](common.py) uses the *partial cells*: $(f,n)$ where the networks'
seed-mean test error is in $[0.05,0.45]$. There are 95 of them (44 HELDOUT, 51 CALIB), each with 3 seeds. 57 of the 95 are
at $n\le128$ (corrected in verification from 52; 71 are at $n\le256$) and all are at $n\le2048$, so the statistic mostly measures the small-sample regime, in which every
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
| networks trained with Adam from a new initialisation | training set | **0.62** (three draws: 0.616, 0.623, 0.628) |
| average of those three networks (sign of the mean output) | training set | **0.68** |
| NNGP kernel regression | training set | 0.69 |
| race | training set | 0.50 |
| hybrid (section 2) | training set | 0.65 |

The first re-initialisation (fold 271828 of the initial key, `nn-reinit` below) is the one used in the other tables; two
more (folds 314159 and 161803) give 0.623 and 0.628. **The average of the three agrees 0.684 with the original
networks, the kernel's 0.690.** Averaging over initialisations moves a network's agreement with the original from
0.62 to the kernel's level after only three draws.

Without the shared initial weights the reference drops from 0.71 to 0.62: 0.09 of the race's 0.21 gap to it is
shared initialisation, which no model of the learning rule can reproduce. The deterministic kernel agrees *more* than
another network on the same data does (0.69 against 0.62): it behaves like the network averaged over initialisations.
The race's gap to an honest ceiling is therefore 0.50 against about 0.62–0.69, not 0.50 against 0.71.

*(Corrected in verification.)* The conclusion of the last two paragraphs does not follow. A single re-initialised
network carries its own initialisation noise. A learner that never sees the initialisation can do better than it, and
the kernel does (0.69 against 0.62). The largest agreement any learner can reach without the initialisation is that
of the network averaged over initialisations, which is at least the measured 0.684. Agreement with a held-out network
rises with the number $k$ of averaged networks: 0.623, 0.667 and 0.684 for $k=1,2,3$, over the four networks
(original plus three re-initialisations). Extrapolated to $k\to\infty$ that gives about 0.71 under a $1/k$ fit, and
0.73 under the best power fit. The honest ceiling is therefore about 0.71–0.73, not 0.62–0.69. It is the level of
the shared-initialisation SGD reference, and none of the race's 0.21 gap is shown to be due to shared initialisation. The
kernel ≈ init-average reading survives in a stronger form. Against the same $k$-averages the kernel scores
0.691 / 0.751 / 0.778, always 0.07–0.09 above a held-out network, so it is closer to the init-averaged network than any
single network is. It is not equal to it: the same extrapolation puts the kernel's agreement with the init average at
about 0.81.

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
  $n\le64$, 0.23 at $n=2048$). Every learner has about as much of it (0.41–0.51), and every learner matches the
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

  The race's noise departs further from the network's as $n$ grows (that is where it fires the most dense gates, often up to its cap of 48); the
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

- **Conditional error rates** (HELDOUT, rates per cell and seed, averaged; *corrected in verification from "points,
  pooled over cells"*): the network is wrong on 63% of the points where the
  kernel is wrong and the race right, and on 23% of the points where the race is wrong and the kernel right. Where
  both are right, the network is wrong on 5%; where both are wrong, on 81%. (CALIB: 64%, 23%, 6%, 83%. Pooled over
  points instead: HELDOUT 61%, 22%, 5%, 85%; CALIB 57%, 24%, 5%, 86%.)
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

### 1.7 Width (a small check)

If the networks' mistakes come from a random-feature background, the infinite-width kernel should agree more with wider
networks, whose background is closer to it. [`hybrid_width.py`](hybrid_width.py) uses the width sweeps run in this
session: widths 32 and 128 on MAJ$_9$, multiplexer, $x_1x_2x_3$, $x_1x_2x_3x_4$ and the staircase, with 2 seeds at
width 32. Widths 64 and 256 exist only for the two parities, with 2 partial cells, which is too few to read.

| width | partial cells | race | NNGP kernel | hybrid |
|---|---|---|---|---|
| 32 | 17 | 0.35 | 0.48 | 0.45 |
| 128 | 18 | 0.43 | 0.63 | 0.58 |

Every learner agrees less with the narrow networks, but the kernel gains most from 32 to 128: +0.15, against +0.08 for
the race. This is consistent with a background that approaches the infinite-width kernel as the width grows, but it is
a single pair of widths on five targets. (The two parity cells give kernel 0.32 / 0.37 / 0.40 at widths 64 / 128 /
256, in the same direction.)

### 1.8 When the networks' mistakes form: memorisation first, features later

`hybrid_diagnose.py timecourse` → [`hybrid_timecourse.json`](hybrid_timecourse.json) scores the networks at each
training checkpoint against the *final* predictions of the other learners (all 95 partial cells).

| step | 50 | 100 | 200 | 500 | 1000 | 5000 | 20000 |
|---|---|---|---|---|---|---|---|
| **$n\le128$:** training error | 0.049 | 0.003 | 0 | 0 | 0 | 0 | 0 |
| test error | 0.309 | 0.284 | 0.282 | 0.282 | 0.282 | 0.281 | 0.276 |
| agreement with the kernel / the race | 0.57 / 0.54 | 0.70 / 0.56 | 0.71 / 0.55 | 0.71 / 0.54 | 0.71 / 0.54 | 0.71 / 0.55 | 0.72 / 0.56 |
| agreement with the final network | 0.70 | 0.91 | 0.96 | 0.96 | 0.96 | 0.96 | 1 |
| **$256\le n\le2048$:** training error | 0.215 | 0.132 | 0.042 | 0.008 | 0 | 0 | 0 |
| test error | 0.307 | 0.256 | 0.223 | 0.216 | 0.214 | 0.206 | 0.175 |
| agreement with the kernel / the race | 0.29 / 0.24 | 0.42 / 0.32 | 0.54 / 0.36 | 0.61 / 0.37 | 0.61 / 0.36 | 0.61 / 0.37 | 0.60 / 0.40 |
| agreement with the final network | 0.31 | 0.44 | 0.63 | 0.76 | 0.78 | 0.83 | 1 |

- **Small training sets.** The networks interpolate by step 100–200. Their mistakes are kernel-like (0.70) as soon as
  they interpolate, and then frozen: 96% of the final excess agreement is in place at step 200.
- **Larger training sets** (most cells near $n^*$). The networks also interpolate first, by step 500–1000, with
  kernel-like mistakes (0.61). Then, *after* interpolation, the test error keeps falling from 0.214 to 0.175 over the
  next 19000 steps, and the mistakes drift slightly towards the race's (0.36 to 0.40). This is the delayed
  generalisation of Part 2 (README §2.1): the features grow on the tiny residual that remains after the kernel-like fit.
- **So the order is memorisation first, features second, at every $n$.** The hybrid's flow puts the features first on
  large training sets. Its end state matches (section 3), but its path does not. A "memorise first" variant was
  spot-checked on 8 cells (`models/scratch_hybrid/test_memo.log`) and was not better:
  - the variant: a static background present from $t=0$ (ridge 0.01), scale-free (Adam-like) utilities, and growth
    for a fixed race time;
  - on MAJ$_3$ at $n=512$ the test error stays at 0.045 (networks 0.008), because the background keeps the degree-1
    part that the MAJ$_3$ gate would have to replace;
  - not pursued further.

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
   scales follow. The target's low-degree part sits on eigenvalues $\propto n$ (the constant mode at $\approx n/2$, the
   30 degree-1 modes at $\approx n/80$) and is fitted at $t\sim c_{\rm bg}/\mu_k$, independent of $n$. The
   training-sample noise sits in the bulk of the spectrum, whose eigenvalues do not grow with $n$ (median 0.26 at
   $n=64$, 0.07 at $n=2048$), and is memorised only at $t\gtrsim c_{\rm bg}n/\kappa_{\rm bulk}$: before the race's
   dense memorising gates can fire on small training sets, after the real features have fired on large ones.
3. **Growth stops at a square-loss level, and training then continues.** Gates are grown while the joint fit's
   training mean squared residual is $\ge$ `stop_mse` (new constant 2), checked continuously in time (if the
   background gets there before the next gate would fire, growth stops at that time). Afterwards the gate weights are
   kept and the background interpolates what is left (kernel ridge on $y-c-Fa$ with the kernel baseline's ridge
   $10^{-4}$), because the networks keep training for 20000 steps after their circuit stops growing.

For $n>2048$ the background is a rank-512 random-feature approximation of the same kernel (features of a fresh
two-hidden-layer ReLU network, seeded from the data so that the race's random stream is unchanged). The full grid
(21 targets × 11 sizes × 3 seeds) takes 9.5 minutes single-threaded on the shared machine. With the background
switched off (mode `none`) the code reproduces the race: the same gates and clock on 18 checked fits, and the same test
predictions up to floating-point rounding in the readout (99.997% of points).

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
- **The flowing background breaks the trade-off.** At equal agreement (0.67) the flow's $n^*$ error is 0.40 against the
  static background's 0.74–0.81. Scaling the ridge as $n/t$ (the mean-loss gradient-flow scaling) is better than
  $\sqrt n/t$ or $1/t$. *(Verification: the static rows also lack the end-of-training interpolation, which the code
  applies only in mode `flow`, so this comparison changes two things. With the hybrid's own MSE stop and final
  interpolation, a static background at $\rho=10^{-4}/10^{-3}/10^{-2}/10^{-1}$ scores CALIB $n^*$ error
  0.61/0.48/0.42/0.35 and agreement 0.67/0.58/0.51/0.52. That is a combined score of at most 0.17, against the flow's
  0.28, so the conclusion stands. The $\sqrt n/t$ and $1/t$ schedules were scored at a single $c_{\rm bg}$ each.)*
- **The race's stopping rule is wrong once a background is present.** With "stop at training sign error 0", small
  $c_{\rm bg}$ stops growth as soon as the background's degree-1 fit classifies the training set. On MAJ$_3$ at $n=512$
  that happens before any gate fires, and the test error stays at the kernel's 0.057 (networks 0.008). With the MSE
  rule the MAJ$_3$ gate fires and the error is 0.001.
- **The networks' mistakes are those of an interpolating background, not an early-stopped one.** With the sign rule at
  $c_{\rm bg}=0.01$, growth stops while the background is still strongly regularised. On the partial cells this scores
  0.55 (CALIB) without the end-of-training interpolation and 0.67 with it, at the same gates. With the MSE rule the
  background has nearly interpolated when growth stops, and dropping the final step changes little (full grid,
  section 3: per-example agreement 0.65 either way, CALIB $n^*$ error 0.42 without it against 0.37).
- **The kernel's identity barely matters.** Kernel ridge regression with the infinite-width NTK of the same
  architecture scores the same per-example agreement as the NNGP kernel (0.672 against 0.671 on CALIB, 0.692 against
  0.690 on HELDOUT). The first-layer NTK term alone (0.62) or a one-hidden-layer NNGP kernel (0.62) are worse.

## 3. Scoreboard

Full grid (21 targets × $n=16$–16384 × 3 seeds), the metrics of [MODEL-SCOREBOARD.md](MODEL-SCOREBOARD.md)
(`common.compare` against the Adam networks); generated by [`hybrid_report.py`](hybrid_report.py) →
[`hybrid_scoreboard.json`](hybrid_scoreboard.json). Evaluations saved in `<scratchpad>/model_evals/{hybrid, hybrid-nofinal,
hybrid-sign, hybrid-static}.npz`. Ablations: `hybrid-nofinal` without the end-of-training interpolation;
`hybrid-sign` with the race's sign-error stop and its own best CALIB constant ($c_{\rm bg}=0.01$, one constant);
`hybrid-static` with a background of constant strength ($\rho=0.003$, its best CALIB setting by the same criterion).

**HELDOUT (primary)**

| model | $n^*$ error (mean $\lvert\log_2\rvert$ ratio) | $n^*$ Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
|---|---|---|---|---|---|---|
| race | **0.33** | **1.00** | 0.95 | 0.01 | 0.50 | **0.83** |
| **hybrid** | 0.35 | 0.93 | **0.96** | 0.01 | **0.65** | 0.81 |
| hybrid-nofinal | 0.34 | 0.93 | 0.94 | 0.01 | 0.65 | 0.82 |
| hybrid-sign | 0.55 | 0.70 | 0.95 | 0.01 | 0.66 | 0.81 |
| hybrid-static | 0.38 | 0.90 | 0.94 | 0.01 | 0.58 | 0.80 |
| NNGP kernel | 2.58 | 0.73 | 0.85 | 0.04 | 0.69 | 0.22 |
| score mixing, race + kernel, $\gamma=1$ ([HYBRID-QUICK.md](HYBRID-QUICK.md)) | 0.29 | 0.95 | 0.97 | 0.01 | 0.62 | 0.83 |
| *networks, μP-SGD, same training sets and initialisations* | *0.43* | *0.95* | *0.94* | *0.01* | *0.71* | *0.83* |
| *networks, Adam, same training sets, new initialisations ($n\le2048$ only)* | *0.12* | *1.00* | *1.00* | *0.01* | *0.62* | *0.93* |

**CALIB**

| model | $n^*$ error | $n^*$ Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
|---|---|---|---|---|---|---|
| race | **0.24** | 0.96 | **0.98** | 0.01 | 0.51 | **0.89** |
| **hybrid** | 0.37 | 0.98 | 0.97 | 0.01 | 0.65 | 0.85 |
| hybrid-nofinal | 0.42 | 0.97 | 0.96 | 0.01 | 0.64 | 0.84 |
| hybrid-sign | 0.40 | 0.99 | 0.96 | 0.02 | 0.67 | 0.86 |
| hybrid-static | 0.52 | 0.93 | 0.95 | 0.02 | 0.59 | 0.83 |
| NNGP kernel | 1.83 | 0.96 | 0.87 | 0.04 | 0.67 | 0.35 |
| score mixing, $\gamma=1$ | 0.32 | 0.97 | 0.98 | 0.01 | 0.62 | 0.89 |

The re-initialised networks' $n^*$ statistics use only $n\le2048$ and are not comparable with the other rows.

**$n^*$ per target** (training-set size at which the seed-mean test error reaches 0.1):

| target | split | networks | race | hybrid | hybrid-sign | hybrid-static | NNGP kernel |
|---|---|---|---|---|---|---|---|
| $x_1$ | calib | 47 | 54 | 29 | 29 | 31 | 29 |
| AND$_3$ | held-out | 94 | 108 | 65 | 65 | 139 | 64 |
| MAJ$_3$ | calib | 112 | 102 | 70 | 73 | 70 | 73 |
| MAJ$_9$ | held-out | 263 | 248 | 174 | 1470 | 124 | 1470 |
| thr10 | calib | 563 | 578 | 618 | 769 | 244 | 1701 |
| $x_1x_2$ | calib | 200 | 180 | 200 | 218 | 180 | 406 |
| $x_1x_2x_3$ | held-out | 843 | 572 | 848 | 828 | 727 | never |
| $x_1x_2x_3x_4$ | calib | 2728 | 1980 | 2949 | 1899 | 1802 | never |
| stair5 | calib | 1514 | 1766 | 1814 | 1748 | 1794 | never |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | held-out | 1380 | 1632 | 1038 | 1123 | 1125 | 1129 |
| MAJ$_3$ XOR MAJ$_3$ | calib | 743 | 700 | 835 | 855 | 603 | never |
| multiplexer | held-out | 1156 | 1423 | 1318 | 1418 | 1193 | never |
| 3-term DNF | calib | 505 | 564 | 499 | 507 | 625 | 564 |
| decision list | held-out | 110 | 163 | 98 | 96 | 121 | 96 |
| recursive MAJ | calib | 2027 | 1895 | 2379 | 2095 | 1700 | 3346 |
| AND$(x_1x_2,x_3x_4)$ | calib | 376 | 802 | 671 | 656 | 705 | 967 |
| sign$(2x_1+x_2x_3+x_4x_5x_6)$ | held-out | 2205 | 1761 | 1601 | 1652 | 1641 | never |
| rand0 | calib | 222 | 194 | 200 | 222 | 229 | 465 |
| rand1 | held-out | 463 | 558 | 584 | 594 | 646 | 730 |
| rand2 | calib | 91 | 85 | 41 | 41 | 46 | 41 |
| rand3 | held-out | 1016 | 1393 | 1416 | 1329 | 1127 | never |

**Other input dimensions, constants unchanged** ([`hybrid_dscale.py`](hybrid_dscale.py); the $d$-scaling networks of
[DSCALE.md](DSCALE.md): 7 targets, 2 seeds, $n$ up to 16384 at $d=15$ and 65536 at $d=60$):

| $d$ | model | $n^*$ error | $n^*$ Spearman | success agreement | curve MAE | per-example agreement |
|---|---|---|---|---|---|---|
| 15 | race | 0.45 | 0.93 | 0.95 | 0.02 | 0.42 |
| 15 | **hybrid** | **0.39** | **0.96** | **0.96** | 0.02 | **0.66** |
| 15 | NNGP kernel | 1.43 | 0.89 | 0.83 | 0.05 | 0.67 |
| 60 | race | **0.43** | 0.89 | **0.99** | 0.02 | 0.42 |
| 60 | **hybrid** | 0.66 | 0.89 | 0.96 | 0.02 | **0.55** |
| 60 | NNGP kernel | 2.68 | 0.57 | 0.86 | 0.04 | 0.64 |

- **$d=15$: everything transfers.** The hybrid matches $n^*$ better than the race (0.39 against 0.45) and its
  per-example agreement is the kernel's (0.66 against 0.67).
- **$d=60$: only part transfers.** Agreement improves less (0.42 to 0.55, kernel 0.64) and the $n^*$ match degrades
  (0.66 against the race's 0.43). The largest misses:
  - MAJ$_9$ comes at the kernel's 382 (kernel 393, networks 625): the background pre-empts the majority gate;
  - the 4-bit parity comes early (7291 against 14255);
  - the staircase comes late (5536 against 3487).

  The background's two clocks depend on $d$ through the kernel's spectrum (degree-$k$ eigenvalues scale as
  $d^{-k}$), so a single $c_{\rm bg}$ calibrated at $d=30$ need not carry over.

  *(Corrected in verification: the last two misses are artifacts of the large-$n$ approximation. Both crossings lie
  above $n=2048$, where the background is the rank-512 random-feature kernel. There the hybrid runs into its gate cap
  (48 gates at $n=4096$ and 8192). With the exact kernel up to $n=8192$ (`n_exact=8192`, 2 seeds) it fires 14–29 gates,
  the 4-bit parity comes at 12832 (networks 14255), the staircase at 3888 (networks 3487), and the $d=60$ $n^*$ error
  is 0.47 against the race's 0.43. Agreement is unchanged at 0.55. MAJ$_9$, in the exact-kernel regime, is the one
  genuine $d=60$ miss.)*

Reading:
- **Per-example agreement.** On HELDOUT the hybrid closes 0.15 of the 0.19 gap between the race (0.50) and the kernel
  (0.69). It is above a re-initialised network (0.62), so it reaches what another network trained on the same data
  reaches. It is still 0.06 short of the shared-initialisation reference (0.71). *(Verification: a single
  re-initialised network is not the bar for a deterministic learner. The init-free ceiling is about 0.71–0.73, as
  section 1.2 now says, so the hybrid is 0.06–0.08 below it and the kernel 0.02–0.04.)*
- **$n^*$.** The hybrid keeps the race's HELDOUT $n^*$ error (0.35 against 0.33), but its ranking is less perfect
  (Spearman 0.93: AND$_3$, MAJ$_9$ and the MAJ of pair parities come too early). *(Corrected in verification. Averaged
  over internal random streams the comparison is 0.35 against 0.28 (race 0.23–0.33 over 6 streams, hybrid 0.30–0.38
  over 3). MAJ$_9$ comes too early (174 against 263) but keeps its rank. The rank errors are AND$_3$ before the decision
  list, and the MAJ of pair parities before the multiplexer and rand3.)* It fixes the race's worst HELDOUT
  misses, the 3-bit parity (848 against 572; networks 843) and the decision list (98 against 163; networks 110).
- **Gate counts.** On the partial cells the hybrid fires 2.2 gates per HELDOUT cell and seed (race 22.2) and 1.6 per
  CALIB one (race 18.4).
- **Ablations.**
  - The sign-stop version agrees as much (0.66) but fails MAJ$_9$: the background's linear fit sign-classifies the
    training set and growth stops, so $n^*$ is the kernel's 1470.
  - The static background loses 0.07 in agreement at a similar $n^*$. *(Verification: `hybrid-static` differs from
    the hybrid in three things: a static schedule, the sign stop, and no end-of-training interpolation. With the
    interpolation added (`verify-hybrid-static-final`) it scores HELDOUT 0.54 / 0.61 and CALIB 0.44 / 0.61 ($n^*$ error
    / agreement). The missing step accounts for only 0.02–0.03 of the agreement loss.)*
  - The end-of-training interpolation is nearly neutral once growth stops at a square-loss level.
- **A simpler competitor does as well on these summary numbers.** [HYBRID-QUICK.md](HYBRID-QUICK.md) adds the
  standardised scores of the race and of kernel regression, each fitted separately to the same data:
  $\operatorname{sign}(f_{\rm race}/\sigma+\gamma f_K/\sigma)$.
  - At $\gamma=1$ it scores HELDOUT 0.29 / 0.62 ($n^*$ error / agreement) and CALIB 0.32 / 0.62. On the combined
    criterion that is 0.30–0.33, against the hybrid's 0.28–0.30.
  - It works because the race's score is large where its features are right and small where it is guessing, so the
    kernel's noise pattern decides only the uncertain points.
  - It is not a model of one learner, though: two separate fits of the same data are added, and the race's 20
    memorising gates per partial cell are kept.
  - The hybrid is the mechanistic version. One readout, one residual, and a background that does the memorising in
    place of those gates. Both say the same thing: the networks' mistakes on uncertain points are the kernel's.

## 4. What this says about how trained networks combine kernel-like and feature-growth behaviour

The labels are Heuristic unless stated otherwise: these readings are what the measurements above suggest, at one
architecture.

1. **Two channels with separate jobs.** On partially learned cells, a trained network's output is a signal part,
   shared with every reasonable learner (correlation 0.92–0.98), plus a sample-noise part (45% of the variance). The
   test error, and hence $n^*$, is set by which features exist: the feature-growth channel, which the race models. The
   identity of the mistakes is set by the sample-noise part, and that part has the shape of minimum-norm interpolation
   of the training sample by the network's kernel at initialisation: correlation 0.81 with NNGP kernel regression,
   degree-1 noise direction 0.92. The networks memorise like a kernel and generalise like a feature learner.
2. **Two clocks, and their order.** A kernel fits by gradient flow along its spectrum: the target's low-degree part
   early, the sample's noise (the bulk of the spectrum) late. Feature growth runs on its own clock. In the networks the
   kernel-like fit comes first at every $n$. They interpolate within 100–1000 steps with kernel-like mistakes, and on
   larger training sets the features that set $n^*$ grow afterwards, on the residual of that fit, over the remaining
   ~19000 steps (section 1.8). The hybrid gets the end state right with the opposite order on large training sets: a
   slow background, so that real features can fire before the background has memorised. A background whose strength
   is fixed in time cannot reproduce both regimes (section 2.2); one that flows on the race clock can, with one rate
   constant. A model with the networks' order would need features that keep growing on an interpolated residual,
   i.e. scale-free (Adam-like) utilities and no loss-based stop. The one variant tried did not work (section 1.8).
3. **The networks do not memorise with grown units.** The race, which has nothing else to fit the sample noise with,
   fires about 20 dense, noisy gates per partial cell. The hybrid fires about 2 and matches $n^*$ as well (HELDOUT
   0.35 against 0.33; *verification: nearly as well, 0.35 against 0.28 averaged over internal random streams*). In the race's own terms, roughly nine in ten of its gates on these cells are memorisation the
   networks do with their random-feature background instead. This bears on the generalisation bounds of Part 2 of
   the README:
   - the "circuit" a network grows on a small training set is a few gates, not tens;
   - the rest is a kernel component with an RKHS norm;
   - so a bound that pays Occam for the few gates and a kernel-norm (Rademacher) term for the background is the natural
     a-priori candidate (not attempted here).
4. **How much is init, how much is data.** Two networks trained on the same data from different initialisations agree
   on their mistakes less (0.62) than either agrees with the init-free kernel (0.69). The average of three
   re-initialised networks reaches 0.68: the kernel behaves like the init-averaged network. The SGD and Adam
   networks' 0.71 includes their shared initial weights (without them: 0.62), so it is not a ceiling for a learning
   rule that does not see the network's initialisation. *(Corrected in verification: the init-free ceiling, the
   init-averaged network, extrapolates to about 0.71–0.73, not 0.62. The kernel agrees 0.78 with a three-network
   average, while a fourth network agrees 0.68; the kernel is closer to the init average than any single network.)*
5. **What the kernel picture misses: the networks are worse than their own kernel at small $n$ on easy targets.** The
   networks' $n^*$ exceeds the NNGP kernel's by 1.1–2.2× on the five targets where the kernel is good: $x_1$ 47 vs 29,
   AND$_3$ 94 vs 64, MAJ$_3$ 112 vs 73, decision list 110 vs 96, rand2 91 vs 41. The race reproduces this (54, 108,
   102, 163, 85), because its first gate is a noisy Hebbian unit. The hybrid does not (29, 65, 70, 98, 41), because at
   the calibrated $c_{\rm bg}$ its background pre-empts that gate. The networks' small-sample inefficiency is therefore
   a feature-channel effect, a grown unit that adds sample noise, but its noise points along the kernel's direction
   (section 1.4). It is not an Adam effect: the μP-SGD networks are less sample-efficient still (AND$_3$ 135,
   decision list 160, MAJ$_9$ 529). This is the hybrid's main remaining discrepancy in $n^*$, and the reason its CALIB
   $n^*$ error (0.37) is above the race's (0.24).

## 5. Caveats and open items

- **Scope.** One architecture, one width, one optimizer setting. The hybrid's two constants were calibrated on 12
  targets at $d=30$ and checked on 9, and at $d=15$ and $d=60$ on 7. The width check (section 1.7) is on a few targets
  only.
- **No gain over a post-hoc mixture.** Adding the race's and the kernel's scores does as well or slightly better on
  $n^*$ and agreement together (section 3). The hybrid's case rests on being a single mechanistic learner that
  reproduces the diagnosis (few gates, kernel-shaped memorisation), not on a better scoreboard.
- **The trade-off is reduced, not removed.** On CALIB the hybrid's combined score (agreement minus $n^*$ error, 0.28)
  is barely above the race's (0.27). On HELDOUT it is clearly above (0.30 against 0.17). *(Verification, averaged
  over internal random streams: CALIB 0.28 against 0.24, HELDOUT 0.31 against 0.23.)* In both splits the hybrid stays
  below the kernel's per-example agreement (0.65 against 0.69 on HELDOUT). Lower $c_{\rm bg}$ reaches the kernel's
  agreement but loses $n^*$ (section 2.2).
- **The order of events is wrong on large training sets** (section 1.8): the networks memorise first and grow
  features afterwards, while the calibrated hybrid grows real features first.
- **The time scale is the background's weak point.** The correlation of the hybrid's sample noise with the network's
  falls from 0.84 at $n\le64$ to 0.46 at $n=2048$ (kernel 0.59): at larger $n$, gates still fire before the background
  has memorised, and they bring race-like noise. A background that memorises faster at large $n$ than $c_{\rm bg}n/t$
  allows, or gates that stop competing with it, might close this.
- **Random features above $n=2048$.** The rank-512 random-feature background cannot interpolate there. It affects no
  partial cell, but it makes the hybrid fire more gates at $n\ge4096$ than the race (22 against 15 on average), with no
  visible effect on the learning curves. *(Corrected in verification: 22 against 15 is the HELDOUT average; over all
  21 targets it is 22 against 16.5. The count jumps at the switch, from 6 gates per fit at $n=2048$ to 26 at
  $n=4096$. The effect on $n^*$ is not invisible: at $d=60$ it accounts for most of the hybrid's $n^*$ loss
  (section 3).)*
- **The init-averaged network.** The claim that the kernel behaves like the network averaged over initialisations rests
  on three re-initialisations, on HELDOUT only (section 1.2: ensemble 0.68, kernel 0.69). It fits the mean-field /
  NNGP picture of the networks' response to the sample noise, but it is evidence, not a proof.
- **Other $d$.** The hybrid's constants transfer to $d=15$ but only partly to $d=60$ (section 3), where its $n^*$ match
  is worse than the race's. *(Verification: with the exact kernel above $n=2048$ the $d=60$ $n^*$ error is 0.47,
  against the race's 0.43; see section 3.)*
- **Not done.** The random-formula suite was not re-run with the hybrid. The networks' noisy small-$n$ feature
  (point 5 of section 4) is not modelled.

## Files

| file | contents |
|---|---|
| [`models/hybrid.py`](models/hybrid.py) | the hybrid model (race gates + NNGP-kernel background flowing on the race clock); modes `flow` (the model), `static` and `none` (= the race; same gates as `models/race.py`, predictions equal up to rounding) |
| [`models/run_hybrid_eval.py`](models/run_hybrid_eval.py) | full-grid evaluation of the hybrid and its ablations |
| [`hybrid_diagnose.py`](hybrid_diagnose.py) → [`hybrid_diagnose.json`](hybrid_diagnose.json) | the diagnosis of section 1 (signal / sample-noise decomposition, degree-1 noise direction, error location, swaps), the network-vs-network ceilings (`ceiling` mode → [`hybrid_ceiling.json`](hybrid_ceiling.json)) and the time course (`timecourse` mode → [`hybrid_timecourse.json`](hybrid_timecourse.json)) |
| [`hybrid_reinit.py`](hybrid_reinit.py) | networks retrained on the same training sets from new initialisations |
| [`hybrid_width.py`](hybrid_width.py) | the width check of section 1.7 |
| [`hybrid_report.py`](hybrid_report.py) → [`hybrid_scoreboard.json`](hybrid_scoreboard.json) | the scoreboard of section 3 |
| [`hybrid_dscale.py`](hybrid_dscale.py) | the hybrid at $d=15$ and $d=60$ (section 3) |
| `models/scratch_hybrid/` | calibration scripts and logs (kept for the record) |

Raw outputs (re-initialised networks, model evaluations) are in the session scratchpad, like the rest of the study's raw data.

## Verification

Added on 24 October 2026 by an adversarial check of this write-up. Corrections are made in place and marked
*corrected in verification*. Notes that do not change a number are marked *verification*.

- Scripts are in `<scratchpad>/verify_hybrid/`: `board.py`, `nstar.py`, `dscale.py`, `ceil.py`, `ceil2.py`,
  `ceil3.py`, `robust.py`, `streams.py`, `width.py`, `none_check.py`, `d30cmp.py`, `d60cmp.py`, `scoremix.py`.
- `run_variant.py` runs a copy, `hybrid_v.py`, identical to `models/hybrid.py` except that the flag `final_static=1`
  turns on the end-of-training interpolation in mode `static`.
- New full-grid evaluations are in `model_evals/`: `verify-hybrid-reseed1`, `verify-hybrid-reseed2`,
  `verify-hybrid-static-final`, `verify-scoremix-g0.25`, `verify-scoremix-g1.0`. Partial-grid runs are in
  `verify_hybrid/evals/`.

### Confirmed

- **Every headline number.** I recomputed them from the saved evaluations with `C.load_eval` + `C.compare`, and they
  agree to the printed precision:
  - all scoreboard rows of section 3 on both splits;
  - the re-initialised networks (0.616 / 0.623 / 0.628) and their three-network average (0.684);
  - all 21 rows of the per-target $n^*$ table;
  - the $d=15$ and $d=60$ tables;
  - the gate counts on the partial cells (HELDOUT 2.20 against 22.24, CALIB 1.61 against 18.41);
  - the diagnosis tables of sections 1.3–1.6 (`hybrid_diagnose.py summary`), the time course of section 1.8 and the
    width table of section 1.7;
  - the score mixing of [HYBRID-QUICK.md](HYBRID-QUICK.md), re-run with saved evaluations: $\gamma=1$ gives HELDOUT
    0.29 / 0.62 and CALIB 0.32 / 0.62.

  The full grid's fits take 495 s. Two fresh full-grid runs took 545 s and 561 s, prediction included, so the
  9.5-minute figure holds.
- **Reproducibility.** `models/hybrid.py` reproduces `hybrid.npz` exactly on the cells re-run. Mode `none` reproduces
  the race on 21 more fits, up to $n=4096$: the same gates and clock, and identical test predictions.
- **Rules.**
  - `fit()` sees only $X$, $y$ and the random stream. The kernel table depends only on $d$, and the random-feature seed
    is a hash of $X$.
  - Nothing in the fit uses the target's identity, its relevant variables or any network result. The relevant
    variables enter only the diagnosis of section 1, which is labelled as such.
  - Two continuous constants are new. The discrete choices are discussed under the caveats.
- **The agreement gain is not a lucky seed.**
  - It holds on each of the three training-set seeds: HELDOUT 0.63 / 0.67 / 0.66, against the race's
    0.48 / 0.52 / 0.51.
  - It holds on every HELDOUT target. The smallest gain is AND$_3$ (0.82 → 0.88), the largest the 3-bit parity
    (0.08 → 0.29).
  - It holds under two more internal random streams: HELDOUT 0.658 and 0.660, CALIB 0.655 and 0.651.
  - A bootstrap over HELDOUT targets gives +0.15 [0.13, 0.17].
- **The MSE stop does not win only because the sign-stop grid was cut short.** The sign-stop family was best at the
  edge of its grid, $c_{\rm bg}=0.01$, with combined score (agreement minus $n^*$ error) 0.27. Extending the grid,
  $c_{\rm bg}=0.03$ and 0.1 score CALIB $n^*$ error / agreement 0.43 / 0.62 and 0.44 / 0.58. Their combined scores,
  0.19 and 0.14, are below both the sign stop at 0.01 and the selected setting (0.28).
- **The flowing background beats a static one with everything else equal** (note in section 2.2). A static background
  with the hybrid's MSE stop and end-of-training interpolation reaches at most 0.17 on the combined CALIB score
  ($\rho=10^{-4}$–$10^{-1}$). Adding only the interpolation to the reported `hybrid-static` gives HELDOUT 0.54 / 0.61
  and CALIB 0.44 / 0.61. Both negative results stand.
- **The kernel behaves like the init-averaged network, in a stronger form than stated** (note in section 1.2). A
  leave-one-out over the four networks on each training set (the original and three re-initialisations) gives:
  - the kernel agrees 0.691 / 0.751 / 0.778 with averages of 1 / 2 / 3 networks;
  - a held-out network agrees 0.623 / 0.667 / 0.684 with the same averages;
  - two disjoint two-network averages agree 0.721 with each other, less than the kernel agrees with either (0.751).
- **Width check on matched cells.** On the 16 cells that are partial at both widths, with seeds 0 and 1 at both:

  | learner | width 32 | width 128 | gain |
  |---|---|---|---|
  | NNGP kernel | 0.47 | 0.66 | +0.19 |
  | race | 0.34 | 0.46 | +0.12 |
  | hybrid | 0.44 | 0.62 | +0.18 |

  The kernel still gains more than the race. The difference in gains, 0.07, is the same as in section 1.7.
- **The large-$n$ approximation does not move the $d=30$ results.** With the exact kernel at $n=4096$ on the seven
  targets whose crossing involves that size, CALIB $n^*$ error goes from 0.369 to 0.364 and HELDOUT is unchanged.
  The gate count changes a lot. There the exact-kernel hybrid fires 3–18 gates per fit (mean 10). The race fires
  48, its cap, on six of the seven, and so does the random-feature hybrid on most. The "few gates" picture
  therefore also holds at $n=4096$ with the exact kernel. The excess gates at $n\ge4096$ in section 5 are an artifact
  of the random features.

### Corrected (in place)

1. **The ceiling for per-example agreement** (Summary, sections 1.2, 3 and 4.4).
   - 0.62 is the agreement between two single networks, each carrying its own initialisation noise. It is not a
     ceiling for a learner that never sees the initialisation: the kernel already exceeds it.
   - The best such learner is the init-averaged network. Its agreement with a single network is at least 0.684
     (measured with three networks) and extrapolates to about 0.71–0.73: 0.711 under a $1/k$ fit, 0.73 under a
     power fit.
   - So the honest ceiling is about the SGD reference's 0.71, not 0.62–0.69. The claim that 0.09 of the race's gap is
     unreachable shared initialisation is withdrawn.
   - Against that ceiling the hybrid is 0.06–0.08 short and the kernel 0.02–0.04.
2. **$n^*$ against the race** (Summary, sections 3, 4.3 and 5). The race row is its worst of six internal random
   streams on HELDOUT $n^*$ (0.23 / 0.26 / 0.27 / 0.27 / 0.32 / 0.33). Averaged over streams:

   | | race (6 streams) | hybrid (3 streams) |
   |---|---|---|
   | HELDOUT $n^*$ error | 0.28 [0.23, 0.33] | 0.35 [0.30, 0.38] |
   | CALIB $n^*$ error | 0.26 [0.23, 0.30] | 0.37 [0.36, 0.38] |
   | HELDOUT $n^*$ Spearman | 0.98 | 0.96 |
   | HELDOUT agreement | 0.51 | 0.66 |
   | combined score, HELDOUT / CALIB | 0.23 / 0.24 | 0.31 / 0.28 |

   - "Keeps the race's $n^*$ match" becomes: costs about 0.07 (HELDOUT) to 0.11 (CALIB) in $n^*$ error, for +0.15 in
     agreement.
   - Per HELDOUT target, averaged over streams, the hybrid is worse on AND$_3$, MAJ$_9$, the MAJ of pair parities and
     sign$(2x_1+x_2x_3+x_4x_5x_6)$. It is better on $x_1x_2x_3$, the decision list, the multiplexer, rand1 and rand3.
     A bootstrap over targets of the single-stream difference is +0.02 [−0.19, +0.22].
   - MAJ$_9$ comes too early in all three hybrid streams (174 / 127 / 154 against 263). So the background partly
     pre-empts the majority gate at $d=30$ as well, not only at $d=60$.
3. **$d=60$** (Summary, sections 3 and 5). Most of the hybrid's $d=60$ $n^*$ loss comes from the rank-512
   random-feature background above $n=2048$, where it runs into the 48-gate cap.
   - With the exact kernel up to $n=8192$ (2 seeds, `verify_hybrid/evals/d60_exact8192.npz`), the 4-bit parity
     comes at 12832 instead of 7291 (networks 14255).
   - The staircase comes at 3888 instead of 5536 (networks 3487).
   - The $d=60$ $n^*$ error is then 0.47, against the race's 0.43 and the reported 0.66.
   - MAJ$_9$ (382 against 625) is the one genuine $d=60$ miss. The explanation through $d$-dependent kernel clocks
     applies to it only.
4. **Smaller fixes.**
   - 57 of the 95 partial cells are at $n\le128$, not 52.
   - The conditional error rates of section 1.5 are averages of per-cell rates. Pooled over points they are
     61 / 22 / 5 / 85% (HELDOUT).
   - "22 against 15 gates" at $n\ge4096$ is the HELDOUT figure; over all targets it is 22 against 16.5.
   - The HELDOUT Spearman loss comes from AND$_3$ against the decision list and from the MAJ of pair parities
     against the multiplexer and rand3. MAJ$_9$ keeps its rank.

### Caveats that remain

- **More design choices than the two constants.**
  - Also selected on CALIB: the schedule exponent ($n/t$ against $\sqrt n/t$ and $1/t$, one $c_{\rm bg}$ each), the
    kind of stop rule, and the end-of-training interpolation.
  - Inherited without calibration: the final ridge $10^{-4}$ (the kernel baseline's), `n_exact` = 2048 and $M=512$
    (cost limits), and the race's gate cap of 48.
  - "Two new constants" is right for the continuous parameters, but it understates the design search.
- **HELDOUT agreement was visible while the designs were explored.**
  - The partial-cell scripts in `models/scratch_hybrid/` printed it next to CALIB, as that folder's README says. It
    moved with CALIB throughout: 0.565 / 0.545 → 0.658 / 0.669 (HELDOUT / CALIB) when the final interpolation was
    added.
  - HELDOUT $n^*$ was never computed before the final run.
  - So the risk is small. Still, "calibrated on CALIB" holds strictly for the constants, not for the design.
- **The selection was a near-tie on CALIB.**
  - The selected setting scores 0.28 on the combined criterion, against 0.27 for the sign-stop variant and for the
    race's base stream.
  - On HELDOUT the two hybrid variants differ by 0.20 in $n^*$ error, all of it from MAJ$_9$.
  - The choice is supported by a CALIB mechanism (MAJ$_3$ at $n=512$) and by the extended sign-stop grid above. Even
    so, the HELDOUT $n^*$ result rests on this one choice.
- **The agreement gain is mostly the kernel's.**
  - On the partial cells the hybrid is about two gates plus an interpolating NNGP background. Its agreement is
    therefore close to the kernel's and below it.
  - What it adds over the kernel is $n^*$, and there it is somewhat worse than the race.
  - The post-hoc score mixture does at least as well on the summary numbers. The write-up says this; its case is
    mechanistic.
- **Large $n$ is a different model.** Above `n_exact` the background is a low-rank approximation, with gate counts at
  the cap. Gate counts and $n^*$ there should be read with the exact-kernel checks above. At $d=60$ the exact kernel
  was checked on two targets and two seeds, up to $n=8192$; $n=16384$ still uses random features.
- **The ceiling is extrapolated.** It comes from three ensemble sizes over four networks, on HELDOUT only. 0.684 is
  the measured lower bound; 0.71–0.73 is an extrapolation.
- **Minor points.**
  - The width check is still one pair of widths on five targets, with two seeds.
  - For targets with 9–10 relevant variables, $f_R$ is estimated from 16–32 probe points per relevant pattern. A few
    per cent of the $f_\perp$ variance leaks into it, which is not material for the correlations quoted.
  - The "memorise first" spot check (section 1.8) is qualitative. Its log has no matched numbers for the hybrid.

### Verdict

- **Confirmed.** Every reported number reproduces from the saved evaluations, and the model follows the rules. The
  main positive result is robust to training-set seeds, model streams and targets: per-example agreement goes from
  0.50 to 0.65 with about two gates per partial cell. So is the mechanistic diagnosis: the sample-noise part of the
  networks' fit is kernel-shaped, and the swap test, the conditional error rates and the degree-1 direction all
  check out. The negative results (static background, sign stop) survive de-confounded re-runs.
- **Corrected, three substantive points.**
  1. The "fair ceiling 0.62–0.69" is wrong. A learner that does not see the initialisation can reach about
     0.71–0.73, the init-averaged network. The kernel is closer to that average than any single network, which
     strengthens the kernel-as-init-average reading.
  2. "$n^*$ stays at the race's level" compared against the race's worst stream. Averaged over streams the hybrid
     costs about 0.07 (HELDOUT) to 0.11 (CALIB) in $n^*$ error, and it pre-empts MAJ$_9$ in every stream.
  3. The $d=60$ $n^*$ degradation is mostly an artifact of the random-feature background. With the exact kernel it is
     0.47 against the race's 0.43.
- **Overall.** The hybrid trades a modest $n^*$ cost for most of the agreement gap. Its edge over post-hoc score mixing
  is mechanistic, not numerical.
