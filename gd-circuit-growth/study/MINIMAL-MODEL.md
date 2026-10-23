# A minimal discrete learner and an analytic sample-complexity predictor

Added on 23 October 2026. Status labels as in the [project README](../README.md): **Numerical** (measured here),
**Heuristic** (argued, not proved), **Proved**. Everything below is Numerical unless labelled otherwise.

Question: what is the *simplest* discrete learner that keeps most of the [race model](models/race.py)'s match to the
networks, so simple that its sample complexity can be written down from the target alone? And does that formula predict
how the networks' sample complexity changes with the input dimension $d$?

## Summary

__SUMMARY__

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
  There is no clock and no time constant.

Compared with the race: no continuous direction search, no rounding of a learned direction (except the spectral unit),
no firing clock and no time constant $\theta$, a library with $\pm1$ instead of $\{-3..3\}$ weights, and a significance
test in place of the race. What it keeps is the race's three ingredients that turned out to matter: a dense linear unit
with sampling noise, sparse gates whose cost depends on how many new inputs they need at once, and reuse of active wires.

## 2. The noise law (Heuristic)

A candidate is accepted when its correlation with the residual beats the noise level of the search that would find it:
$\rho^2>c\,N(k)/n$.

**$k=1$: the Hebbian unit.** Its weights $\hat h_i=h_i+\varepsilon_i$ carry independent sampling noise
$\varepsilon_i\sim\mathcal N(0,\mathrm{Var}(y)/n)$ on all $d$ coordinates, so the noise in the direction has squared norm
$d\,\mathrm{Var}(y)/n$. A direction is usable when its signal exceeds that: $N(1)=d$. In the readout this noise is
kept explicitly; it is what makes the networks' learning curves on dense targets gradual (Section 3).

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
($m(0)^2=1/d$). The fitted $a\approx18$ (Section 4) is of the order of $2\ln P\approx9.7$ for $P=128$ hidden units times
the $k^2/4$ that was absorbed; that reading is suggestive only, since the width was never varied. The cap at
$m(0)=1$ matters only for $d<a$.

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
term, either the Hebbian noise or a single bottleneck move (Table 2). For simple targets this gives explicit formulas:

| target | binding term | $n^*$ |
|---|---|---|
| $x_1$ | Hebbian | $\Phi^{-1}(0.9)^2\,d=1.64\,d$ |
| MAJ$_m$ | Hebbian, Chow coefficient $\hat c_m=\binom{m-1}{(m-1)/2}2^{1-m}$ | $(z_m/\hat c_m)^2\,d$ with $\mathbb E\,\Phi(-z_m\lvert\sum_{i\le m}x_i\rvert)=0.1$: $4.94\,d$ ($m=3$), $9.52\,d$ ($m=9$) |
| $\chi_k=x_1\cdots x_k$, $k\ge2$ | the first gate, AND$_k$, with $\rho^2=1/(2^k-1)$; the remaining gates are cheap $k=0$ moves | $c\,(2^k-1)\,d\,\max(1,d/a)^{k-2}$ |

The first two rows contain no fitted constant at all.

## 4. Results at $d=30$

### 4.1 Scoreboard

Same metrics as [`MODEL-SCOREBOARD.md`](MODEL-SCOREBOARD.md) (networks: Adam, 3 seeds; "never" counted as $2\times16384$).
Constants were fitted on CALIB only: predictor $c=2.25$, $a=18$ (grid argmin of the CALIB mean $|\log_2|$ ratio);
minimal model {{MODEL_CONSTANTS}}.

**Held-out functions (primary):**

{{SCOREBOARD_HELDOUT}}

**Calibration functions:**

{{SCOREBOARD_CALIB}}

The predictor has no per-example predictions and no clock, so only its $n^*$ and curve columns are filled. Its
learning curve is the noiseless-path error with the Hebbian noise term (dashed in
[`figures/minimal_curves.png`](figures/minimal_curves.png)).

### 4.2 Per-function $n^*$ and the binding term

{{NSTAR_TABLE}}

"Binding term" is the term that sets the predicted $n^*$ in the closed form of Section 3: the Hebbian noise, or the
single move with the largest $c\,N(k)/\rho^2$ ($f$ = fan-in, $k$ = new inputs needed at once; "spectral" = the order-2
unit). Figures: [`figures/minimal_nstar.png`](figures/minimal_nstar.png) (scatter),
[`figures/minimal_curves.png`](figures/minimal_curves.png) (learning curves).

Reading the table:
- **Leap-1 dense targets** ($x_1$, AND$_3$, MAJ$_3$, MAJ$_9$, the decision list, rand2) are set by the Hebbian noise
  alone, with no fitted constant: $n^*=1.64d$, $4.94d$, $9.52d$ for $x_1$, MAJ$_3$, MAJ$_9$ against the networks' 47, 112,
  263 at $d=30$.
- **Parities** are set by their first gate, the $k$-input AND, which has $\rho^2=1/(2^k-1)$ with $\chi_k$; the rest of
  the parity is assembled from cheap $k=0$ gates on the same inputs.
- **Compositions** are set by one interior move: a fan-in-2 pair gate for MAJ$(x_1x_2,\dots)$ and AND$(x_1x_2,x_3x_4)$, a
  3-leap for sign$(2x_1+x_2x_3+x_4x_5x_6)$, the spectral unit for MAJ$\oplus$MAJ, the multiplexer and the DNF.

### 4.3 Which ingredient does what (predictor ablations, CALIB-refitted)

| variant | CALIB mean abs log2 | HELDOUT mean abs log2 | what changes |
|---|---|---|---|
| full predictor ($c=2.25$, $a=18$) | 0.37 | 0.38 | |
| no spectral unit ($c=2.5$, $a=16$) | 0.63 | 0.26 | MAJ$\oplus$MAJ goes from 465 to 3724 (network 743); the DNF from 518 to 919; but the multiplexer and rand3 improve |
| no leap cost ($a=\infty$, $c=2.5$) | 0.38 | 0.55 | indistinguishable at $d=30$ on CALIB; wrong $d$-scaling (Section 5) |
| Occam law $N(k)=\log M_k$ ($c=9$) | 0.41 | 0.39 | indistinguishable at $d=30$; wrong $d$-scaling (Section 5) |
| the literal sector as least squares on all $d$ literals instead of the Hebbian unit (minimal model, early version) | – | – | dense targets become too easy (MAJ$_9$: 107 against 263) and a double-descent bump appears at $n\approx d$ (MAJ$_3$: error 0.41 at $n=32$) |

At $d=30$ alone, the $n^*$ data cannot tell the search law from the Occam law or from no leap cost: the 21 targets span
too narrow a range of $k$ and $d$. The $d$-scaling can.

## 5. The $d$-dependence

Networks at $d=15,30,60$ (2 seeds at 15 and 60, 3 at 30; [`DSCALE.md`](DSCALE.md)); predictor and minimal model with
their $d=30$ CALIB constants unchanged; race from [`DSCALE.md`](DSCALE.md) (also unchanged). $n^*$ at $d=15/30/60$:

{{DSCALE_TABLE}}

**What the law gets right.**
- **Parities with $k=2,3$:** the predicted exponents $1.00$ and $1.84$ match the networks' $1.04$ and $1.91$, and the
  values match within 15% at every $d$. The race model, whose time law has the same $m(0)\sim d^{-1/2}$ but whose
  sample complexity comes from a race against memorisation, gets $0.93$ and $0.94$: it misses the extra factor $d$ for the
  third input.
- **Dense leap-1 targets:** $n^*\propto d$ (MAJ$_9$: 143/286/571 against 123/263/625), with no fitted constant.
- **The Occam law fails decisively:** it predicts exponents 0.16–0.31 for every target except MAJ$_9$ (mean
  $|\log_2|$ error 1.50 at $d=60$). The network's search noise is that of a continuous search in $\mathbb R^d$, not
  of a union bound over a finite library. Removing the leap cost ($a=\infty$) predicts exponent 1 for every parity.

**What it gets wrong.**
- **4-sparse parity:** predicted exponent 2.75 (asymptotically 3), measured 2.40 in both doublings; $n^*$ at $d=60$ is
  overpredicted 1.6-fold (22971 against 14255). For $k=4$ the network beats the one-unit alignment bound; one
  possibility is that a two-hidden-layer network assembles $x_1x_2x_3x_4$ from two pair-level features, which the
  single-unit law does not allow. Untested.
- **Compositions of leap-1/2 moves** (staircase, MAJ of pair parities, multiplexer): the networks scale as
  $d^{1.5}$–$d^{1.75}$, the predictor as $d^{0.6}$–$d^{1.3}$, so the predictor is too optimistic at $d=60$ by
  1.7–2.1×. The 20000-step training budget explains only a small part: extrapolating each network's last
  doubling of training lowers these $n^*$ by at most 25% and leaves the exponents at 1.4–1.6. A plausible cause is that
  in MAJ$(x_1x_2,x_3x_4,x_5x_6)$ the three pair spikes of $M$ are degenerate, so the network's spectral search returns
  mixtures that only higher-order terms disentangle; the model's exhaustive pair search sidesteps this. Untested.

## 6. Assessment

{{ASSESSMENT}}

## 7. Files

| file | contents |
|---|---|
| [`models/minimal.py`](models/minimal.py) | the minimal model (`Minimal(c, a)`), the gate library and its exact moment-based scoring (fan-in-4 candidates over $d=60$ literals are scored from pair-product Gram matrices), the noise law |
| [`models/run_minimal_eval.py`](models/run_minimal_eval.py) | full-grid evaluation at $d=30$, and the $d=15$/$d=60$ runs (`DIM`, `NS_MAX`) |
| [`minimal_predict.py`](minimal_predict.py) | the analytic predictor: population greedy path on the relevant cube, Hebbian-noise error curve, closed-form decomposition |
| [`minimal_report.py`](minimal_report.py) → [`minimal_report.json`](minimal_report.json) | all predictor numbers, at $d=30$ and in the $d$-scaling study, with the networks', the model's and the race's $n^*$ |
| [`minimal_tables.py`](minimal_tables.py), [`minimal_figures.py`](minimal_figures.py) | the tables and figures of this note |
| [`minimal_random.py`](minimal_random.py) → [`minimal_random.json`](minimal_random.json) | out-of-sample test on the 20 random formulas |

Saved evaluations (scratchpad, not in the repository): `model_evals/minimal.npz`, `minimal_d15.npz`, `minimal_d60.npz`,
`minimal_random.npz`. Calibration scripts and logs: scratchpad `minimal/`. Reproduce:
`OPENBLAS_NUM_THREADS=1 python3 models/run_minimal_eval.py {{C}} {{A}}` (about {{T}} min single-threaded for the
full grid), `DIM=60 NS_MAX=65536 python3 models/run_minimal_eval.py {{C}} {{A}}`, `python3 minimal_report.py`.

