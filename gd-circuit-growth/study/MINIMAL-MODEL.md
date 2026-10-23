# A minimal discrete learner and an analytic sample-complexity predictor

Added on 23 October 2026. Status labels as in the [project README](../README.md): **Numerical** (measured here),
**Heuristic** (argued, not proved), **Proved**. Everything below is Numerical unless labelled otherwise.

Question: what is the *simplest* discrete learner that keeps most of the [race model](models/race.py)'s match to the
networks, so simple that its sample complexity can be written down from the target alone? And does that formula predict
how the networks' sample complexity changes with the input dimension $d$?

## Summary

- **The minimal model** ([`models/minimal.py`](models/minimal.py)) is greedy stagewise regression over a finite
  library of $\pm1$-weight ReLU gates of fan-in at most 4, plus a dense Hebbian linear unit and one spectral (order-2)
  unit. It has one acceptance rule: accept the best gate if $n\rho^2>c\,N(k)$, where $\rho$ is the gate's correlation
  with the residual and $k$ is the number of inputs it needs that are not yet in the circuit. It has two constants,
  $c=2.25$ and $a=18$, fitted on CALIB.
- **The noise law** (Heuristic, Section 2) is $N(0)=$ the size of the active pool and $N(k)=d\max(1,d/a)^{k-2}$ for
  $k\ge1$.
  - It comes from the race model's alignment law $\dot m=kUm^{k-1}$: a dormant unit with initial overlap $m(0)^2=a/d$
    escapes towards the target only if its order-$k$ signal beats the frozen sampling noise of the gradient,
    $kU\,m(0)^{k-1}\gtrsim1/\sqrt n$.
  - Its central claim: the sample cost grows polynomially in $d$ for every input that must be found at once, not
    logarithmically as an Occam (union-bound) threshold would give.
- **The analytic predictor** ([`minimal_predict.py`](minimal_predict.py)) is computed from the target alone, on its
  relevant variables. It is the closed form
  $$n^*=\max\Bigl(n_{\rm Hebb},\ c\max_i\frac{N(k_i)}{\rho_i^2}\Bigr)$$
  along the population greedy path. Here $n_{\rm Hebb}$, set by the Hebbian unit's sampling noise, contains no fitted
  constant. Examples: $n^*(x_1)=1.64\,d$, $n^*(\mathrm{MAJ}_9)=9.52\,d$, and $n^*(\chi_k)=c\,(2^k-1)\,d\,(d/a)^{k-2}$ for $d\ge a$.
- **At $d=30$, on the 9 held-out targets** (mean $|\log_2|$ ratio of $n^*$ to the networks'; Spearman of $n^*$):

  | | $n^*$ ratio | Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
  |---|---|---|---|---|---|---|
  | analytic predictor | **0.38** | **0.97** | 0.96 | 0.03 | – | – |
  | minimal model | 0.59 | 0.85 | 0.94 | 0.02 | 0.50 | 0.69 |
  | race model | 0.33 | 1.00 | 0.95 | 0.01 | 0.50 | 0.83 |
  | sswm | 1.36 | 0.60 | 0.86 | 0.06 | 0.26 | 0.72 |

  The predictor is at the race's level without a simulation. The minimal model keeps the race's success agreement,
  curves and per-example agreement, but on $n^*$ it is worse: it learns two held-out compositions 2.4–2.7× too early.
  On CALIB the minimal model scores 0.36 and the race 0.24.
- **$d$-dependence** (networks at $d=15,30,60$; constants unchanged):
  - the predictor gets the sparse-parity exponents for $k=2,3$: $1.00$ and $1.84$, against the networks' $1.04$ and
    $1.91$ (race $0.93$ and $0.94$), with values within 10% at every $d$; MAJ$_9$ is $\propto d$ (143/286/571 against 123/263/625);
  - it overpredicts the 4-sparse parity at $d=60$ by 1.6× (exponent 2.75 against 2.40);
  - it underpredicts compositions of low-leap moves (staircase, MAJ of pair parities, multiplexer), which scale as
    $d^{1.5}$–$d^{1.75}$ in the networks, by up to 2.1× at $d=60$;
  - mean $|\log_2|$ error over the 7 targets: predictor 0.30 / 0.30 / 0.52 at $d=15/30/60$, minimal model
    0.30 / 0.36 / 0.52, race 0.45 / 0.29 / 0.43.
- **The Occam law** $N(k)=\log M_k$ (the best-of-$M_k$ noise level) fits $d=30$ about as well (held-out 0.39). But it
  predicts $n^*$ almost independent of $d$ (exponents 0.16–0.31) and fails the $d$-scaling (mean error 1.50 at $d=60$).
  The networks' sample complexity is a **search cost**, not a description length.
- **Out of sample** (20 fresh random formulas, constants unchanged): predictor 0.42 / Spearman
  0.96, minimal model 0.47 / 0.96, race 0.20 / 0.99. Here the race model is clearly better;
  the predictor ranks the formulas well but underpredicts eight mid-sized ones by 1.4–1.7×.

## 1. The minimal model ([`models/minimal.py`](models/minimal.py))

It is greedy stagewise regression over an explicit finite library of gates, with one acceptance rule.

- **Wires.** The $d$ input literals and every accepted depth-1 gate (its firing pattern as a $\pm1$ wire).
- **Library.** $g=\mathrm{relu}\bigl(\sum_{j\in S}s_ju_j-b\bigr)$ with signs $s_j\in\{\pm1\}$ and integer thresholds
  $b\in\{f-1,f-3,\dots,1-f\}$ (AND-like to OR-like) or $b=-f-1$ (the signed sum itself), $f=|S|$:
  - depth 1: $S$ is a set of $f\le4$ literals;
  - depth 2: $S$ is a set of $f\le3$ wires from the *active pool* (active literals and depth-1 gates) containing at least one gate;
  - one dense candidate per stage, the **order-2 (spectral) unit**: the two extreme eigenvectors of the residual-weighted
    literal covariance $M_{ij}=\mathbb E_S[r\,x_ix_j]$ ($i\ne j$), rounded to $\{-1,0,1\}$ (keep $|v_i|\ge\max|v|/2$), any fan-in.
- **Readout.** Least squares (ridge $10^{-6}$) over the gates and one dense linear feature, the **order-1 (Hebbian)
  unit** $h(x)=\sum_i\hat h_ix_i$ with $\hat h=\mathbb E_S[(y-\bar y)x]$. It is the race's order-1 unit without
  rounding: the network's linear part, with its sampling noise. Prediction $\mathrm{sign}(f)$.
- **State.** The gates, and the set of *active* literals: those read by an accepted gate, and those whose own correlation
  with the label or the residual is significant at the order-1 level ($n\rho_i^2>c\,N(1)$).
- **Move types.** A candidate needs $k$ new inputs at once, where $k$ is the number of inactive literals it reads; the
  spectral unit counts as $k=2$ (it is an order-2 search).
- **Rule.** With $\rho_g$ the empirical correlation of the gate with the current residual,
  $$z_g^2=\frac{n\,\rho_g^2}{N(k)},\qquad N(0)=|\text{pool}|,\qquad N(k)=d\,\max\!\bigl(1,\tfrac da\bigr)^{(k-2)_+}\ (k\ge1).$$
  Accept the candidate with the largest $z^2$ if $z^2>c$; refit the readout; repeat. Stop when nothing is accepted, at
  training error 0, or after 48 gates.
- **Constants.** Two global constants, $c$ (the acceptance level) and $a$ (the initial-overlap scale of the search),
  calibrated on the 12 CALIB functions only. Fixed by design: fan-in $\le4$, $\pm1$ weights, 48 gates, ridge $10^{-6}$.
  There is no time constant. The model's clock (used only for the time-Spearman column) is derived, not fitted: an
  accepted move takes time $\sqrt{N(k)}/\rho$, the square root of its sample cost, as in the race's relation
  $t\sim\Theta\sqrt{n/\log M}$ between firing time and sample size ([`theory/A`](../theory/A-discrete-model.md), Proposition A2.6).

The gate library is explicit and finite, so Theorem A1's counting applies to the gates: a sparse gate costs at most
$\log\bigl(\binom{d+48}{4}2^4\cdot5\bigr)\approx 19$ nats at $d=30$, a spectral gate at most $d\log3+\log(d+2)\approx36$
nats. The Hebbian unit is not a library element: it has $d$ real weights, so a generalization bound for the whole
predictor must add a halfspace-in-$d$-dimensions (VC) term for it.

Compared with the race: no continuous direction search, no rounding of a learned direction (except the spectral unit),
no race clock and no time constant $\theta$, a library with $\pm1$ instead of $\{-3..3\}$ weights, and a significance
test in place of the race. What it keeps is the race's three ingredients that turned out to matter: a dense linear unit
with sampling noise, sparse gates whose cost depends on how many new inputs they need at once, and reuse of active wires.

## 2. The noise law (Heuristic)

A candidate is accepted when its correlation with the residual beats the noise level of the search that would find it:
$\rho^2>c\,N(k)/n$, with $\rho$ the correlation (not the covariance) with the current residual, because the sampling
noise of every gradient scales with the residual's size.

**$k=1$: the Hebbian unit.** Its weights $\hat h_i=h_i+\varepsilon_i$ carry independent sampling noise
$\varepsilon_i\sim\mathcal N(0,\mathrm{Var}(y)/n)$ on all $d$ coordinates, so the noise in the direction has squared norm
$d\,\mathrm{Var}(y)/n$. A direction is usable when its signal exceeds that: $N(1)=d$. In the readout this noise is
kept explicitly; it is what makes the networks' learning curves on dense targets gradual (Section 3). A sparse gate
that needs one new input (a staircase step such as $x_1x_2$ once $x_1$ is active) is found by the same kind of search
over $d$ candidates for that input, so it also has $N(1)=d$.

**$k=2$: the spectral unit.** The best order-2 direction is the top eigenvector of $\hat M=M+\Xi$, whose noise $\Xi$ has
entries of size $1/\sqrt n$ and spectral norm $\approx2\sqrt{d/n}$. A spike is detectable at the BBP-type threshold
$\rho\gtrsim\sqrt{d/n}$: again $N(2)=d$. The network does not enumerate pairs; its search is continuous in $\mathbb R^d$,
and the noise level of a continuous search over the unit sphere is $\sqrt{d/n}$, not the best-of-$M$ level
$\sqrt{2\log M/n}$.

**$k\ge3$: the alignment law.** In the race model a dormant unit of order $k$ aligns with the target direction at the rate
$\dot m=kU m^{k-1}$ from an initial overlap $m(0)$. On a fixed training set the empirical gradient also carries a frozen
sampling-noise component of size $\sigma_r/\sqrt n$ along the target direction. The unit moves towards the target only if
the signal wins at the start,
$$kU\,m(0)^{k-1}\gtrsim\frac{\sigma_r}{\sqrt n}\quad\Longleftrightarrow\quad n\gtrsim\frac{\sigma_r^2}{U^2}\,\frac{m(0)^{-2(k-1)}}{k^2}.$$
With $m(0)^2=\min(1,a/d)$, and absorbing $k^2$ and the order-$k$ normalisation into $a$, this is
$n\rho^2\gtrsim a\,(d/a)^{k-1}=d\,(d/a)^{k-2}$: every input beyond the second that must be found at once multiplies the
cost by $d/a$. The initial overlap $m(0)^2=a/d$ is that of the best of many random dormant units rather than of one
($m(0)^2=1/d$). The fitted $a\approx18$ (Section 4) means $m(0)^2\approx0.6$ at $d=30$. For comparison, the best of
$P=128$ random hidden units has $m(0)^2\approx2\ln P/d\approx0.32$, the same order once the absorbed $k^2$ is put back.
That reading is suggestive only, since the width was never varied. The cap at $m(0)=1$ matters only for $d<a$.

**$k=0$: reuse.** A gate on already-active wires is a search over the small pool only: $N(0)=|\text{pool}|$ (the active
literals for depth-1 gates, active literals plus depth-1 gates for depth-2 gates).

**What the law says.** The sample cost of a move is set by the number of inputs it needs *at once*, not by its fan-in,
and by $d$ polynomially, not logarithmically: $n\propto d^{\max(1,k-1)}$ for a move needing $k\ge1$ new inputs. The
alternative suggested by Occam's razor, $N(k)=\log M_k$ with $M_k$ the number of candidates of that type, predicts
$n\propto\log d$; it is kept as `law="occam"` for comparison.

## 3. The analytic predictor ([`minimal_predict.py`](minimal_predict.py))

The predictor is the minimal model's noiseless limit, computed exactly from the target on the cube of its relevant
variables (at most $2^{10}$ points); $d$ enters only through $N(k)$ and the Hebbian noise.

1. **Path.** At each $n$, run the model in population: literals are active once $n\rho(y,x_i)^2>c\,d$; at each stage the
   candidate with the largest $\rho^2/N(k)$ is accepted if $n\rho^2/N(k)>c$, with population correlations; the readout
   is the population least-squares fit.
2. **Error.** The fitted readout $F$ is perturbed by the Hebbian unit's noise, a Gaussian of variance
   $\sigma_n^2=a_h^2\,d\,\mathrm{Var}(y)/(n\lVert h\rVert^2)$ ($a_h$ is the readout weight of the standardised Hebbian
   feature), so the predicted test error is
   $$\mathrm{err}(n)=\mathbb E_x\,\Phi\!\bigl(-y(x)F(x)/\sigma_n\bigr).$$
3. **$n^*$** is where $\mathrm{err}(n)$ crosses 0.1.

**Closed form.** Along the path at $n^*$, with $i^*$ the shortest prefix whose readout reaches predicted error 0.1,
$$\boxed{\;n^*=\max\Bigl(n_{\rm Hebb},\ c\max_{i\le i^*}\frac{N(k_i)}{\rho_i^2}\Bigr)\;}$$
where $n_{\rm Hebb}$ solves $\mathbb E_x\Phi(-yF_{i^*}/\sigma_n)=0.1$. Each target's $n^*$ is therefore set by one binding
term, either the Hebbian noise or a single bottleneck move (Section 4.2). For simple targets this gives explicit formulas:

| target | binding term | $n^*$ |
|---|---|---|
| $x_1$ | Hebbian | $\Phi^{-1}(0.9)^2\,d=1.64\,d$ |
| MAJ$_m$ | Hebbian, Chow coefficient $\hat c_m=\binom{m-1}{(m-1)/2}2^{1-m}$ | $(z_m/\hat c_m)^2\,d$ with $\mathbb E\,\Phi(-z_m\lvert\sum_{i\le m}x_i\rvert)=0.1$: $4.94\,d$ ($m=3$), $9.52\,d$ ($m=9$) |
| $\chi_k=x_1\cdots x_k$, $k\ge2$ | the first gate, AND$_k$, with $\rho^2=1/(2^k-1)$; the remaining gates are cheap $k=0$ moves | $c\,(2^k-1)\,d\,\max(1,d/a)^{k-2}$ |

The first two rows contain no fitted constant at all.

## 4. Results at $d=30$

### 4.1 Scoreboard

Same metrics as [`MODEL-SCOREBOARD.md`](MODEL-SCOREBOARD.md) (networks: Adam, 3 seeds; "never" counted as $2\times16384$).
Constants were fitted on CALIB only, by grid search on the CALIB mean $|\log_2|$ ratio. The predictor's grid
($c\in[1.5,4]$, $a\in[8,\infty]$, 1 s per point) has its minimum at $c=2.25$, $a=18$ (0.367). The minimal model's grid
(about 3 min per point) also has its minimum at $c=2.25$, $a=18$ (0.364), so **one pair of constants serves both**:

| minimal model, CALIB mean abs log2 | $a=12$ | $a=16$ | $a=18$ | $a=20$ | $a=24$ |
|---|---|---|---|---|---|
| $c=1.5$ | 0.51 | 0.53 | | | |
| $c=2$ | 0.48 | 0.39 | | 0.41 | 0.43 |
| $c=2.25$ | | | **0.36** | | |
| $c=2.5$ | | 0.47 | | | |
| $c=3$ | | | | | 0.51 |

**Held-out functions (primary):**

| model | mean abs log2 n* ratio | n* Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
|---|---|---|---|---|---|---|
| **analytic predictor** (2 constants) | 0.38 | 0.97 | 0.96 | 0.03 | – | – |
| **minimal model** (2 constants) | 0.59 | 0.85 | 0.94 | 0.02 | 0.50 | 0.69 |
| race (3 constants) | 0.33 | 1.00 | 0.95 | 0.01 | 0.50 | 0.83 |
| sswm | 1.36 | 0.60 | 0.86 | 0.06 | 0.26 | 0.72 |
| NNGP kernel | 2.58 | 0.73 | 0.85 | 0.04 | 0.69 | 0.22 |
| Occam over juntas | 4.61 | 0.50 | 0.62 | 0.13 | 0.20 | -0.07 |
| *reference: networks trained with μP-SGD* | *0.43* | *0.95* | *0.94* | *0.01* | *0.71* | *0.83* |

**Calibration functions:**

| model | mean abs log2 n* ratio | n* Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
|---|---|---|---|---|---|---|
| **analytic predictor** (2 constants) | 0.37 | 0.94 | 0.95 | 0.03 | – | – |
| **minimal model** (2 constants) | 0.36 | 0.98 | 0.98 | 0.02 | 0.52 | 0.86 |
| race (3 constants) | 0.24 | 0.96 | 0.98 | 0.01 | 0.51 | 0.89 |
| sswm | 1.11 | 0.91 | 0.92 | 0.05 | 0.25 | 0.49 |
| NNGP kernel | 1.83 | 0.96 | 0.87 | 0.04 | 0.67 | 0.35 |
| Occam over juntas | 3.98 | 0.73 | 0.65 | 0.12 | 0.17 | 0.27 |

The predictor has no per-example predictions and no clock, so only its $n^*$ and curve columns are filled. Its
learning curve is the noiseless-path error with the Hebbian noise term (dashed in
[`figures/minimal_curves.png`](figures/minimal_curves.png)).

### 4.2 Per-function $n^*$ and the binding term

| target | split | network | analytic predictor | binding term at $n^*$ | minimal model | race | Occam-law predictor |
|---|---|---|---|---|---|---|---|
| dict | calib | 47 | 49 | Hebbian noise | 53 | 54 | 49 |
| and3 | held-out | 94 | 90 | Hebbian noise | 130 | 108 | 90 |
| maj3 | calib | 112 | 148 | Hebbian noise | 116 | 102 | 148 |
| maj9 | held-out | 263 | 286 | Hebbian noise | 346 | 248 | 286 |
| thr10 | calib | 563 | 390 | Hebbian noise | 322 | 578 | 390 |
| par2 | calib | 200 | 204 | gate f=2 k=2 ρ²=0.333 N=30.0 | 223 | 180 | 233 |
| par3 | held-out | 843 | 783 | gate f=3 k=3 ρ²=0.143 N=50.0 | 890 | 572 | 750 |
| par4 | calib | 2728 | 2871 | gate f=4 k=4 ρ²=0.067 N=83.3 | 3565 | 1980 | 2030 |
| stair5 | calib | 1514 | 1007 | gate f=4 k=2 ρ²=0.067 N=30.0 | 830 | 1766 | 963 |
| majpar | held-out | 1380 | 817 | gate f=2 k=2 ρ²=0.083 N=30.0 | 892 | 1632 | 931 |
| parmaj | calib | 743 | 465 | spectral f=6 k=2 ρ²=0.148 N=30.0 | 447 | 700 | 530 |
| mux | held-out | 1156 | 851 | spectral f=4 k=2 ρ²=0.082 N=30.0 | 1179 | 1423 | 686 |
| dnf3 | calib | 505 | 518 | spectral f=6 k=2 ρ²=0.128 N=30.0 | 446 | 564 | 502 |
| dlist5 | held-out | 110 | 175 | Hebbian noise | 188 | 163 | 198 |
| rmaj9 | calib | 2027 | 1084 | Hebbian noise | 1217 | 1895 | 3454 |
| andxor | calib | 376 | 598 | gate f=2 k=2 ρ²=0.111 N=30.0 | 391 | 802 | 653 |
| sparsepoly | held-out | 2205 | 1663 | gate f=4 k=3 ρ²=0.067 N=50.0 | 804 | 1761 | 1814 |
| rand0 | calib | 222 | 233 | gate f=2 k=2 ρ²=0.300 N=30.0 | 228 | 194 | 265 |
| rand1 | held-out | 463 | 482 | gate f=3 k=2 ρ²=0.214 N=30.0 | 384 | 558 | 441 |
| rand2 | calib | 91 | 116 | Hebbian noise | 102 | 85 | 116 |
| rand3 | held-out | 1016 | 575 | spectral f=4 k=2 ρ²=0.117 N=30.0 | 428 | 1393 | 651 |

"Binding term" is the term that sets the predicted $n^*$ in the closed form of Section 3: the Hebbian noise, or the
single move with the largest $c\,N(k)/\rho^2$ ($f$ = fan-in, $k$ = new inputs needed at once; "spectral" = the order-2
unit). Figures: [`figures/minimal_nstar.png`](figures/minimal_nstar.png) (scatter),
[`figures/minimal_curves.png`](figures/minimal_curves.png) (learning curves).

Reading the table:
- **Leap-1 dense targets** ($x_1$, AND$_3$, MAJ$_3$, MAJ$_9$, the random halfspace, the decision list, rand2) are set
  by the Hebbian noise alone, with no fitted constant: $n^*=1.64d$, $4.94d$, $9.52d$ for $x_1$, MAJ$_3$, MAJ$_9$ against
  the networks' 47, 112, 263 at $d=30$. The two misses in this group go in opposite directions: the networks beat the
  Hebbian estimate on the decision list (110 against 175) and are worse than it on the random halfspace (563 against 390).
- **Parities** are set by their first gate, the $k$-input AND, which has $\rho^2=1/(2^k-1)$ with $\chi_k$; the rest of
  the parity is assembled from cheap $k=0$ gates on the same inputs.
- **Compositions** are set by one interior move: a pair gate for MAJ$(x_1x_2,\dots)$, AND$(x_1x_2,x_3x_4)$ and rand0, a
  fan-in-4 gate needing two new inputs for the staircase, a 3-leap ($x_4x_5x_6$) for sign$(2x_1+x_2x_3+x_4x_5x_6)$, and the
  spectral unit for MAJ$\oplus$MAJ, the multiplexer, the DNF and rand3. Recursive majority is the exception: its
  Hebbian term binds, because its readout keeps leaning on the noisy linear part.

### 4.3 Which ingredient does what (predictor ablations, CALIB-refitted)

Mean $|\log_2|$ ratio of predicted to network $n^*$; the last column is the out-of-sample test of Section 4.4.

| variant | CALIB | HELDOUT | 20 random formulas | what changes |
|---|---|---|---|---|
| full predictor ($c=2.25$, $a=18$) | 0.37 | 0.38 | **0.42** | |
| no spectral unit ($c=2.25$, $a=24$) | 0.46 | 0.45 | 0.47 | MAJ$\oplus$MAJ must be built from sparse pair gates, whose $\rho^2$ is 7× smaller: 465 becomes 1635 (network 743); the DNF (518 → 571) and rand3 (575 → 709) slow down, the multiplexer barely changes (851 → 815) |
| no leap cost ($a=\infty$, $c=2.5$) | 0.38 | 0.55 | 0.50 | indistinguishable on CALIB at $d=30$; wrong $d$-scaling (Section 5) |
| Occam law $N(k)=\log M_k$ ($c=9$) | 0.41 | 0.39 | 0.43 | indistinguishable at $d=30$; wrong $d$-scaling (Section 5) |
| additive costs, $n^*=\max(n_{\rm Hebb},\,c\sum_{i\le i^*}N(k_i)/\rho_i^2)$ ($c=1.5$, $a=24$) | 0.33 | 0.39 | 0.59 | helps the multi-move compositions of the main suite (staircase, recursive majority, rand3), hurts AND$(x_1x_2,x_3x_4)$, the DNF and the random formulas. Better on CALIB; max is kept because it is what the model's noiseless limit implies (a stage needs only its own threshold), not because of the random formulas |
| significance against the label scale, $n\,U^2/\mathrm{Var}(y)$ instead of $n\rho^2$ ($c=2$, $a=18$) | 0.36 | 0.57 | 0.65 | later moves get more expensive as the residual shrinks. Marginally better on CALIB, so the choice is made on principle (the sampling noise of a correlation scales with the residual), and it is confirmed by the held-out and random targets |
| the literal sector as least squares on all $d$ literals instead of the Hebbian unit (minimal model, early version) | – | – | – | dense targets become too easy (MAJ$_9$: 107 against 263) and a double-descent bump appears at $n\approx d$ (MAJ$_3$: error 0.41 at $n=32$) |

At $d=30$ alone, the $n^*$ data cannot tell the search law from the Occam law or from no leap cost: the 21 targets span
too narrow a range of $k$ and $d$. The $d$-scaling can.

### 4.4 Out-of-sample: 20 fresh random formulas

The 20 random fan-in-2 formulas of `boolfuncs.make_random_suite` (4–8 inputs, 3–8 gates; networks: Adam, 2 seeds) were
generated after the models were designed and calibrated; all constants unchanged ([`minimal_random.py`](minimal_random.py)
→ [`minimal_random.json`](minimal_random.json); the race model re-evaluated here with its $d=30$ constants).

| model | mean abs log2 n* ratio | n* Spearman | success agreement | curve MAE | per-example agreement | time Spearman |
|---|---|---|---|---|---|---|
| analytic predictor | 0.42 | 0.96 | – | – | – | – |
| Occam-law predictor | 0.43 | 0.93 | – | – | – | – |
| minimal model | 0.47 | 0.96 | 0.95 | 0.02 | 0.56 | 0.80 |
| race model | 0.20 | 0.99 | 0.98 | 0.01 | 0.54 | 0.82 |

<details><summary>per-formula n*</summary>

| target | formula | network | analytic predictor | minimal model | race |
|---|---|---|---|---|---|
| rf00 | 6 gates, 5 inputs: g5=~4and~3; g6=~5or1; g7=~2xor~5; g8=7or~2; g9=~8an | 98 | 91 | 138 | 98 |
| rf01 | 4 gates, 5 inputs: g5=4xor~2; g6=0or5; g7=~6or~1; g8=~7xor~0 | 467 | 300 | 408 | 553 |
| rf02 | 7 gates, 4 inputs: g4=0xor1; g5=2and~4; g6=~5xor0; g7=~6and~4; g8=7or~ | 266 | 156 | 200 | 216 |
| rf03 | 5 gates, 4 inputs: g4=~3and0; g5=4xor3; g6=~5xor1; g7=6or~2; g8=7xor~0 | 425 | 247 | 308 | 482 |
| rf04 | 7 gates, 4 inputs: g4=1xor~3; g5=0and4; g6=5or~1; g7=~6and2; g8=~7or~6 | 342 | 197 | 209 | 360 |
| rf05 | 5 gates, 5 inputs: g5=3or~4; g6=~4or5; g7=~2or~5; g8=7xor4; g9=~8xor1 | 873 | 788 | 437 | 828 |
| rf06 | 7 gates, 5 inputs: g5=3xor~1; g6=5or2; g7=6or~0; g8=~1xor5; g9=8or6; g | 61 | 71 | 65 | 61 |
| rf07 | 8 gates, 4 inputs: g4=0xor1; g5=~1or2; g6=4and~0; g7=3or6; g8=7and~0;  | 407 | 247 | 332 | 482 |
| rf08 | 8 gates, 4 inputs: g4=~2and~1; g5=4and3; g6=~4or~5; g7=~6or2; g8=~3xor | 85 | 120 | 136 | 114 |
| rf09 | 8 gates, 4 inputs: g4=2xor~1; g5=~1or~2; g6=~1xor~2; g7=0and2; g8=~6or | 320 | 241 | 193 | 395 |
| rf10 | 8 gates, 4 inputs: g4=~0xor~2; g5=~4and~2; g6=5or2; g7=~6xor~2; g8=7xo | 103 | 120 | 142 | 120 |
| rf11 | 4 gates, 4 inputs: g4=0and~2; g5=4and0; g6=3xor1; g7=6xor~2 | 864 | 783 | 893 | 679 |
| rf12 | 5 gates, 5 inputs: g5=~0or2; g6=5xor~4; g7=2and1; g8=7xor~6; g9=~8or~3 | 963 | 989 | 764 | 1115 |
| rf13 | 7 gates, 4 inputs: g4=~0xor~3; g5=4xor1; g6=0xor~3; g7=~6and~0; g8=~7x | 401 | 612 | 326 | 438 |
| rf14 | 5 gates, 5 inputs: g5=~1xor~4; g6=~0xor2; g7=6and1; g8=7xor~5; g9=8xor | 714 | 503 | 447 | 650 |
| rf15 | 4 gates, 4 inputs: g4=~3xor1; g5=~4or3; g6=~5xor4; g7=6and0 | 108 | 120 | 141 | 124 |
| rf16 | 7 gates, 4 inputs: g4=~0and~2; g5=4xor~1; g6=5and~1; g7=2or1; g8=7and2 | 354 | 241 | 197 | 347 |
| rf17 | 3 gates, 5 inputs: g5=~4xor3; g6=~5xor0; g7=6xor~1 | 3049 | 2871 | 3567 | 1959 |
| rf18 | 3 gates, 4 inputs: g4=~0xor3; g5=4or~2; g6=~5xor~0 | 174 | 243 | 292 | 201 |
| rf19 | 6 gates, 4 inputs: g4=~2xor1; g5=4xor3; g6=~5xor~1; g7=~6or~0; g8=7and | 902 | 658 | 705 | 909 |

</details>

On these formulas the race model is clearly better (0.20 against 0.42 and 0.47). The predictor ranks them almost
perfectly (Spearman 0.96) but underpredicts the mid-sized ones systematically: rf01–rf04, rf07, rf14, rf16 and rf19 come
out at 0.58–0.73× of the networks' $n^*$ (and rf08, rf13, rf18 at 1.4–1.5×). The same bias appears on the main
suite's compositions (Sections 4.2 and 5). It is not that the networks pay for every move instead of only the most
expensive one: the additive variant of Section 4.3 does worse here (0.59, Spearman 0.90).

## 5. The $d$-dependence

Networks at $d=15,30,60$ (2 seeds at 15 and 60, 3 at 30; [`DSCALE.md`](DSCALE.md)); predictor and minimal model with
their $d=30$ CALIB constants unchanged; race from [`DSCALE.md`](DSCALE.md) (also unchanged). $n^*$ at $d=15/30/60$:

| target | network | analytic predictor | minimal model | race | no leap cost ($a=\infty$) | Occam law |
|---|---|---|---|---|---|---|
| par2 | 100 / 200 / 427 | 102 / 204 / 409 | 111 / 223 / 446 | 93 / 180 / 335 | 116 / 233 / 465 | 196 / 233 / 277 |
| par3 | 241 / 843 / 3410 | 243 / 783 / 3131 | 223 / 890 / 3562 | 346 / 572 / 1281 | 265 / 530 / 1060 | 604 / 750 / 891 |
| par4 | 508 / 2728 / 14255 | 508 / 2871 / 22971 | 445 / 3565 / 28596 | 704 / 1980 / 13865 | 578 / 1156 / 2312 | 1566 / 2030 / 2414 |
| stair5 | 433 / 1514 / 3487 | 854 / 1007 / 2015 | 339 / 830 / 2797 | 832 / 1766 / 4037 | 854 / 1709 / 3418 | 843 / 963 / 1059 |
| mux | 364 / 1156 / 2848 | 264 / 851 / 1703 | 212 / 1179 / 1690 | 419 / 1423 / 2703 | 301 / 602 / 1204 | 602 / 686 / 781 |
| majpar | 306 / 1380 / 3466 | 409 / 817 / 1635 | 445 / 892 / 1778 | 515 / 1632 / 2446 | 465 / 931 / 1862 | 783 / 931 / 1107 |
| maj9 | 123 / 263 / 625 | 143 / 286 / 571 | 122 / 346 / 878 | 109 / 248 / 837 | 143 / 286 / 571 | 143 / 286 / 571 |

Error $|\log_2(n^*_{\rm model}/n^*_{\rm network})|$ per target:

| d | par2 | par3 | par4 | stair5 | mux | majpar | maj9 | mean |
|---|---|---|---|---|---|---|---|---|
| predictor, d = 15 | 0.03 | 0.01 | 0.00 | 0.98 | 0.46 | 0.42 | 0.22 | 0.30 |
| predictor, d = 30 | 0.03 | 0.11 | 0.07 | 0.59 | 0.44 | 0.76 | 0.12 | 0.30 |
| predictor, d = 60 | 0.06 | 0.12 | 0.69 | 0.79 | 0.74 | 1.08 | 0.13 | 0.52 |
| minimal model, d = 15 | 0.15 | 0.11 | 0.19 | 0.35 | 0.78 | 0.54 | 0.01 | 0.30 |
| minimal model, d = 30 | 0.16 | 0.08 | 0.39 | 0.87 | 0.03 | 0.63 | 0.40 | 0.36 |
| minimal model, d = 60 | 0.06 | 0.06 | 1.00 | 0.32 | 0.75 | 0.96 | 0.49 | 0.52 |
| race, d = 15 | 0.11 | 0.52 | 0.47 | 0.94 | 0.20 | 0.75 | 0.17 | 0.45 |
| race, d = 30 | 0.15 | 0.56 | 0.46 | 0.22 | 0.30 | 0.24 | 0.08 | 0.29 |
| race, d = 60 | 0.35 | 1.41 | 0.04 | 0.21 | 0.08 | 0.50 | 0.42 | 0.43 |
| no leap cost, d = 15 | 0.21 | 0.14 | 0.19 | 0.98 | 0.27 | 0.60 | 0.22 | 0.37 |
| no leap cost, d = 30 | 0.22 | 0.67 | 1.24 | 0.17 | 0.94 | 0.57 | 0.12 | 0.56 |
| no leap cost, d = 60 | 0.13 | 1.69 | 2.62 | 0.03 | 1.24 | 0.90 | 0.13 | 0.96 |
| Occam law, d = 15 | 0.96 | 1.33 | 1.62 | 0.96 | 0.73 | 1.35 | 0.22 | 1.02 |
| Occam law, d = 30 | 0.22 | 0.17 | 0.43 | 0.65 | 0.75 | 0.57 | 0.12 | 0.42 |
| Occam law, d = 60 | 0.62 | 1.94 | 2.56 | 1.72 | 1.87 | 1.65 | 0.13 | 1.50 |

Least-squares exponent of $n^*$ against $d$ over $d=15,30,60$:

| target | network exponent | predictor | minimal model | race | no leap cost | Occam law |
|---|---|---|---|---|---|---|
| par2 | 1.04 | 1.00 | 1.00 | 0.93 | 1.00 | 0.25 |
| par3 | 1.91 | 1.84 | 2.00 | 0.94 | 1.00 | 0.28 |
| par4 | 2.40 | 2.75 | 3.00 | 2.15 | 1.00 | 0.31 |
| stair5 | 1.50 | 0.62 | 1.52 | 1.14 | 1.00 | 0.16 |
| mux | 1.48 | 1.34 | 1.50 | 1.35 | 1.00 | 0.19 |
| majpar | 1.75 | 1.00 | 1.00 | 1.12 | 1.00 | 0.25 |
| maj9 | 1.17 | 1.00 | 1.42 | 1.47 | 1.00 | 1.00 |

**What the law gets right.**
- **Parities with $k=2,3$:** the predicted exponents $1.00$ and $1.84$ match the networks' $1.04$ and $1.91$, and the
  values match within 10% at every $d$. The race model, whose time law has the same $m(0)\sim d^{-1/2}$ but whose
  sample complexity comes from a race against memorisation, gets $0.93$ and $0.94$: it misses the extra factor $d$ for the
  third input.
- **Dense leap-1 targets:** $n^*\propto d$ (MAJ$_9$: 143/286/571 against 123/263/625), with no fitted constant.
- **The minimal model itself** (run at $d=15$ and 60 with the same constants) shows the law's parity exponents
  (1.00, 2.00, 3.00) and, unlike the predictor, the networks' exponents for the staircase and the multiplexer (1.52 and
  1.50 against 1.50 and 1.48), although its individual values are coarse (factor-2 grid in $n$).
- **The Occam law fails decisively:** it predicts exponents 0.16–0.31 for every target except MAJ$_9$ (mean
  $|\log_2|$ error 1.50 at $d=60$). The network's search noise is that of a continuous search in $\mathbb R^d$, not
  of a union bound over a finite library. Removing the leap cost ($a=\infty$) predicts exponent 1 for every parity.

**What it gets wrong.**
- **4-sparse parity:** predicted exponent 2.75 (asymptotically 3), measured 2.40 in both doublings; $n^*$ at $d=60$ is
  overpredicted 1.6-fold (22971 against 14255), and the minimal model, which follows the law, 2.0-fold (28596). For $k=4$ the network beats the one-unit alignment bound; one
  possibility is that a two-hidden-layer network assembles $x_1x_2x_3x_4$ from two pair-level features, which the
  single-unit law does not allow. Untested.
- **Compositions of leap-1/2 moves** (staircase, MAJ of pair parities, multiplexer): the networks scale as
  $d^{1.5}$–$d^{1.75}$, the predictor as $d^{0.6}$–$d^{1.3}$, so the predictor is too optimistic at $d=60$ by
  1.7–2.1×. The minimal model reaches exponent 1.5 on the staircase and the multiplexer but stays at 1.0 on
  MAJ$(x_1x_2,x_3x_4,x_5x_6)$ (network 1.75). The 20000-step training budget explains only a small part: extrapolating one more doubling of
  training at the rate of the last one (steps 10000 to 20000) lowers these $n^*$ by at most about 25% and leaves the
  exponents at 1.4–1.6. A plausible cause is that
  in MAJ$(x_1x_2,x_3x_4,x_5x_6)$ the three pair spikes of $M$ are degenerate, so the network's spectral search returns
  mixtures that only higher-order terms disentangle; the model's exhaustive pair search sidesteps this. Untested.

## 6. Assessment

**Did the simplification keep the race's match?** Partly. On CALIB the minimal model is close to the race: $n^*$ ratio 0.36 against 0.24, Spearman 0.98 against 0.96, success agreement 0.98 against 0.98, time Spearman 0.86 against 0.89. On the held-out targets it matches the race on success agreement (0.94 against 0.95), learning-curve MAE (0.02 against 0.01) and per-example agreement (0.50 against 0.50). Its held-out $n^*$ accuracy is clearly worse (0.59 against 0.33, Spearman 0.85 against 1.00), mostly because of two compositions it learns too early: sign$(2x_1+x_2x_3+x_4x_5x_6)$ (804 against 2205) and rand3 (428 against 1016). Its exhaustive search finds the 3-leap $x_4x_5x_6$ with the help of a selection bias: the best of many variants of the true gate is inflated by sampling noise, so it passes the threshold at half the $n$ that the model's own noiseless limit predicts. It is still far better than the other simple learners (sswm 1.36, NNGP kernel 2.58, Occam over juntas 4.61). On the 20
random formulas it scores 0.47 / 0.96 / 0.95 / 0.02 / 0.56 / 0.80 against the race's 0.20 / 0.99 / 0.98 / 0.01 / 0.54 / 0.82. Its noiseless limit, the analytic predictor, matches the networks better than the model itself does (held-out 0.38), and matches the model to a mean $|\log_2|$ of 0.30 (median $-0.03$) over the 21 targets.

**Is the sample complexity predictable from the target alone?** Yes, at about the race's accuracy on held-out targets,
with two constants and one formula: $n^*=\max\bigl(n_{\rm Hebb},\,c\max_iN(k_i)/\rho_i^2\bigr)$ (held-out mean
$|\log_2|$ ratio 0.38 and Spearman 0.97, against 0.33 and 1.00 for the race model, which needs a full simulation). Half
of the targets come down to one line: the Hebbian noise for dense leap-1 targets (no constant), $c(2^k-1)\,d\max(1,d/a)^{k-2}$
for parities, one bottleneck move for the rest. Out of sample, on 20 fresh random formulas, it keeps its ranking
(Spearman 0.96) but its accuracy drops to 0.42, against the race's 0.20: the race's full simulation captures something
about mid-sized compositions that the single-bottleneck formula misses.

**Does it predict the $d$-dependence?** For sparse parities with $k\le3$ and for dense targets, yes, within 20% at every
$d$, where the race model misses the 3-sparse parity's exponent (0.94 against 1.91). For the 4-sparse parity the
predicted exponent is too large (2.75 against 2.40), and for compositions of low-leap moves too small (0.6–1.3 against
1.5–1.75). The mean $|\log_2|$ error over the 7 targets is 0.30, 0.30 and 0.52 at $d=15,30,60$, against 0.45, 0.29 and
0.43 for the race model.

**What this says about the networks (Heuristic).**
1. The cost of a move is set by how many inputs it must find *at once*, and it is polynomial in $d$:
   $n\propto d^{\max(1,k-1)}/\rho^2$. A union bound over a finite library ($\log M_k$, the Occam reading) fits the
   $d=30$ data equally well but fails the $d$-scaling completely (exponents 0.2–0.3 against 1–2.4). The networks'
   sample complexity is a *search* cost, not a description-length cost, even though what they learn is a small circuit.
2. The search noise is that of a continuous search in $\mathbb R^d$ ($\sqrt{d/n}$ for a direction or a spectral
   spike), times $(d/a)$ for every further input that has to be found together, with $m(0)^2=a/d$ the initial overlap
   of the best dormant unit, $a\approx18$.
3. Reusing what is already learned is nearly free ($N(0)=$ the size of the active pool): leaps, not fan-in, set the cost.
4. The linear part of the network behaves like a Hebbian estimate with its full sampling noise, $d\,\mathrm{Var}(y)/n$:
   this alone fixes $n^*$ for $x_1$, MAJ$_3$, MAJ$_9$, AND$_3$ and the decision list, and the small-$n$ learning curves
   of dense targets, without any fitted constant.

**Negative results and caveats.**
- The predictor's misses at $d=30$ are structural, not constant-tuning: the decision list (+0.67 in $\log_2$), AND$(x_1x_2,x_3x_4)$
  (+0.67), the random halfspace (−0.53), recursive majority (−0.90), the staircase (−0.59), MAJ$(x_1x_2,\dots)$ (−0.76).
- The CALIB objective is flat: points within 0.02 of its minimum give held-out scores between 0.36 and 0.55. The
  held-out 0.38 should be read with that spread.
- The empirical model's learning curves are sharper than the networks': it accepts all gates of equal utility at the same $n$, so on MAJ$(x_1x_2,x_3x_4,x_5x_6)$ its error jumps from 0.50 to 0.00 between $n=512$ and 1024, where the networks (and the race) decline gradually from 0.41 at $n=128$ to 0.07 at 2048. With factor-2 steps in $n$, such jumps make its $n^*$ coarse: at $c=2$ the 4-sparse parity moves from 3565 to 1783 when $a$ goes from 16 to 24. On multi-move targets it is also faster than its own noiseless limit, because the best of many noisy candidates passes the threshold early.
- Status: the predictor's closed forms (the parity and majority formulas) are exact consequences of its definition;
  their agreement with the networks is Numerical; the noise law is Heuristic. Everything is at one width (128), one
  depth, one learning rate, and 20000 training steps; the fitted $a$ may depend on the width, which was not varied.


## 7. Files

| file | contents |
|---|---|
| [`models/minimal.py`](models/minimal.py) | the minimal model (`Minimal(c, a)`), the gate library and its exact moment-based scoring (fan-in-4 candidates over $d=60$ literals are scored from pair-product Gram matrices), the noise law |
| [`models/run_minimal_eval.py`](models/run_minimal_eval.py) | full-grid evaluation at $d=30$, and the $d=15$/$d=60$ runs (`DIM`, `NS_MAX`) |
| [`minimal_predict.py`](minimal_predict.py) | the analytic predictor: population greedy path on the relevant cube, Hebbian-noise error curve, closed-form decomposition |
| [`minimal_report.py`](minimal_report.py) → [`minimal_report.json`](minimal_report.json) | all predictor numbers, at $d=30$ and in the $d$-scaling study, with the networks', the model's and the race's $n^*$ |
| [`minimal_tables.py`](minimal_tables.py), [`minimal_figures.py`](minimal_figures.py) | the tables and figures of this note |
| [`minimal_random.py`](minimal_random.py) → [`minimal_random.json`](minimal_random.json) | out-of-sample test on the 20 random formulas |
| [`minimal_constants.txt`](minimal_constants.txt) | the calibrated constants $c$, $a$ |

Saved evaluations (scratchpad, not in the repository): `model_evals/minimal.npz`, `minimal_d15.npz`, `minimal_d60.npz`,
`minimal_random.npz`. Calibration scripts and logs: scratchpad `minimal/`. Reproduce:
`OPENBLAS_NUM_THREADS=1 python3 models/run_minimal_eval.py 2.25 18` (about 4.5 min single-threaded for the
full grid), `DIM=60 NS_MAX=65536 python3 models/run_minimal_eval.py 2.25 18`, `python3 minimal_report.py`.

