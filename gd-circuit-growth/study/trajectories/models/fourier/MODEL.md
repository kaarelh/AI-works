# Fourier race: a character-level model of the sequence of learned functions

Approach `fourier`. The model predicts the function the network computes at every training step from the target
alone, as a staircase of Fourier characters. The characters are switched on by a timed race of *moves*, and each
move multiplies an existing feature by a few input variables.

The code is [`model.py`](model.py). [`predict.py`](predict.py) writes the score files, and
[`stages.py`](stages.py) prints the predicted stages of any target. Fitting is in [`fit.py`](fit.py) and the
ablations are in [`ablate.py`](ablate.py). [`fig_traj.png`](fig_traj.png) plots the model against the networks.
The calibration predictions are in [`preds/`](preds), with `preds/scores.json` written by `score.py`.

## Summary

- **The object.** The predicted function is $f_t=\sum_S \hat y_S\,\varphi_S(t)\,\chi_S$ on the relevant cube.
  - $\hat y_S$ are the target's Fourier coefficients.
  - $\varphi_S(t)\in[0,1]$ is the learned fraction of character $S$.
- **The rule.** The learned set grows by moves. A move takes a learned base and multiplies it by $e$ input variables
  at once. The base can be the empty set, a learned character, or the bundle learned in one earlier move.
  - **Bundles.** A move learns every residual character it reaches, as one bundle.
  - **Speed.** It fires after a time $\propto\tau/\rho^{1/2}$, where $\rho$ is the bundle's share of the residual and
    $\tau=\tau_0\,e^{2}\,2^{[\text{built on a learned feature}]}\,2^{[\text{odd degree}\ \ge 3]}$.
  - **Rise.** The bundle rises along a saddle-escape logistic.
  - **Junta completion.** Once a nonlinear gate on already-active inputs exists, the rest of the function on those
    inputs is one more step away.
  - **Finite $n$.** Memorisation after about 35 epochs cuts the race off. Each bundle is learned only to the
    spiked-estimation (BBP) fraction $1-N/(n\rho^2)$.
- **Constants.** Five, fitted jointly on the five calibration targets and four conditions: $\tau_0=44.2$ steps,
  $\alpha=2$, $K=2$, $N=45.9$, 35.4 epochs. The values of $\alpha$ and $K$ were fitted, then rounded.
- **Calibration** (score.py): mean traj **0.010**, mean onset **0.121**.
  - online 0.006 / 0.055;
  - 16384: 0.007 / 0.062;
  - 2048: 0.017 / 0.153;
  - 512: 0.009 / 0.214.

  For comparison, one network seed against the mean of the other two scores 0.005 / 0.041 (online), 0.012 / 0.157
  (2048) and 0.023 / 0.345 (512). So the model is within about the seed-to-seed noise in every condition. The trivial
  step function scores 0.198 / 0.660.
- **Reproduced:** staging, the order of characters, bundles (mux's three $x_ix_4$ through one direction, rmaj9's 37
  high-degree characters through junta completion), finite-$n$ partial saturation and missing stages.
- **Not reproduced:**
  - overshoot;
  - the slow lead-in before a stage, where the network reaches about 10% at a third of the onset time;
  - the slow creep of late stages at $n=2048$;
  - rmaj9's split, at $n=2048$, between the part of the function that is symmetric in all nine inputs and the
    block part.

## 1. What is modelled

The analysis of the trajectories (`analyze_traj.py`, hypothesis `H_char`) shows that on every plateau the network's
$E[f\mid x_R]$ is within 0.01–0.05 Var $y$ of the projection of the target onto the characters learned so far. So a
model of the trajectory needs three things for each character:

1. when it switches on;
2. how it rises;
3. to what level it saturates at finite $n$.

The model produces $\varphi_S(t)$ for every character with $\hat y_S\neq0$. The constant term is learned by the
readout bias with $\varphi_\emptyset=1-e^{-t/T_0}$, where $T_0=\tau_0/\sqrt d\approx8$ steps.

## 2. The rule

The state is a learned set $L$ of characters. Each has a firing time, a rise rate and a level. The residual is
$r_S=\hat y_S(1-\text{level}_S)$ and $|r|^2=\sum_{S\neq\emptyset}r_S^2$. The active inputs $A$ are the inputs that
appear in learned characters.

### 2.1 Moves and their bundles

| move | base | bundle (unlearned characters with $\hat y_S\ne0$) | strength $s$ |
|---|---|---|---|
| root move of order $e$ | $\emptyset$ | all $S$ with $\lvert S\rvert=e$ made of inactive inputs only | $\lVert r_{\text{bundle}}\rVert$ |
| extension of order $e$ | a learned character $U$ | all $S$ with $\lvert S\triangle U\rvert=e$ | $\lVert r_{\text{bundle}}\rVert$ |
| bundle extension | a learned bundle $B$ (one earlier move) | characters reached by $x_j\cdot B$ | norm of the projection of $r$ on the span of $\{x_jB\}_j$ |
| junta completion | after a move on active inputs only that has order $\ge2$ or reaches degree $\ge3$ | all remaining $S\subseteq A$ | $\lVert r_{\text{bundle}}\rVert$ |

- The root move of order 1 is the linear stage: all degree-1 characters at once.
- The bundle extension is a single direction added to a whole learned feature. For example, mux's
  $x_4(x_1+x_2+x_3)$ adds $x_4$ to the linear direction.
- Bundle extensions and completions count as order 1 and as built on a learned feature.

### 2.2 The race

Every move accumulates progress at rate

$$\dot P=G_n(t)\,\frac{\rho^{1/2}}{\tau},\qquad \rho=\frac{s}{|r|},\qquad
\tau=\tau_0\,e^{\alpha}\,K^{[\text{built on a learned feature}]}\,K^{[\text{bundle mostly of odd degree}\ \ge3]}.$$

A move fires when $P=1$. Its characters join $L$ and become bases, and every strength is recomputed. Progress is
kept between recomputations. The exception is a move that lost members to another move: its progress is scaled by
$s_{\text{new}}/s_{\text{old}}$, the part of its alignment that still points at the residual.

### 2.3 The rise

A character's progress is that of its most advanced move until it fires, and continues at the firing rate
afterwards. Its learned fraction is

$$\varphi_S=\text{level}\cdot\frac{\sigma(e\ln d\,(P-1))-\sigma(-e\ln d)}{1-\sigma(-e\ln d)} .$$

### 2.4 Finite $n$

- **Cutoff.** $G_n(t)=1/(1+(t/T_c)^8)$ with $T_c=\text{EPOCHS}\cdot n/64$. Once the training set is memorised, the
  gradient towards unlearned features vanishes. Online, $G=1$.
- **Level.** A fired bundle saturates at $\max(0,1-N/(n\rho_{\text{dir}}^2))$. Here $\rho_{\text{dir}}$ is the share
  of its best single direction:
  - the vector norm for $e=1$;
  - the top eigenvalue of the pair matrix $M_{jk}=r_{U\triangle\{j,k\}}$ for $e=2$;
  - the largest coefficient for $e\ge3$.

  The linear stage is exempt: it is unbiased, so it carries noise but no shrinkage.
- **Unfired moves** keep the partial level their progress reached: they are partly learned stages, or missing ones.

### 2.5 By hand: sparsepoly online

The constants used here are $\tau_0=44.2$, $\alpha=K=2$. The target is
$\hat y=\{x_1{:}.75,\ x_2x_3{:}.25,\ x_1x_2x_3{:}.25,\ x_4x_5x_6{:}.25,\ x_1x_4x_5x_6{:}.25,\ \dots\}$ and its
residual starts at $|r|=0.968$.

| stage | move | $\tau$ | $\rho$ | prediction | network |
|---|---|---|---|---|---|
| linear stage | root, $e=1$ | 44 | .775 | $44/\sqrt{.775}=50$ | 56 |
| $x_2x_3$ | root, $e=2$, even | $44\cdot4=177$ | .26, then .41 after $x_1$ | progress .14 by step 50; the rest at $\sqrt{.41}/177$ per step: 288 | 299 |
| $x_1x_2x_3$ | extension of $x_2x_3$ by $x_1$, built on a learned feature, odd degree | $44\cdot2\cdot2=177$ | .45 | $288+177/\sqrt{.45}=552$ | 532 |
| $x_4x_5x_6$ | root, $e=3$, odd degree, running since step 0 | $44\cdot9\cdot2=796$ | .37 (the bundle is $\{x_1x_2x_3,x_4x_5x_6\}$ until $x_1$ is active, then progress ×.71) → .41 → .45 → .50 | 1180 (grid: 1201) | 1234 |
| $x_1x_4x_5x_6$ | extension of $x_1$ by $x_4,x_5,x_6$, built on a learned feature, even | $44\cdot9\cdot2=796$ | .41 → .45 → .58 | 1267 | 1358 |
| $x_2x_3x_4x_5x_6$, $x_1x_2x_3x_4x_5x_6$ | junta completion (all inputs active after $x_1x_4x_5x_6$) | $44\cdot2=88$ | 1.0 | 1360 | 1542, 1461 |

At $n=512$, $T_c=283$ steps. The cutoff delays the $x_2x_3$ move to step 479, where its BBP level is
$1-45.9/(512\cdot.17)=.46$. Its rise then stalls about half-way, so the model ends at .23. Everything later is cut
off. The network learns .44 of $x_2x_3$, .16 of $x_1x_2x_3$ and nothing else.

## 3. Where the rule comes from

These are heuristics, not derivations. Each is tied to an observation.

- **Characters, not inputs, are the unit, and a bundle is one direction.**
  - A hidden unit grows a new feature by aligning its weights with a direction in input space. The residual's
    gradient for a unit gated by a learned feature $U$, $E[r\,1_{\text{unit on}}\,x_j]$, is a whole vector over $j$.
    So all characters $U\triangle\{j\}$ are learned at once, in proportion to their coefficients. This is why stair5's
    $x_1x_2$ (.375) and $x_1x_3,x_1x_4,x_1x_5$ (−.125) switch on together, and why mux's three $x_ix_4$ do.
  - For $e=2$ the relevant object is the matrix $M_{jk}$. Its top eigenvector is one unit's pair direction. Several
    units take the other eigenvectors in parallel, so the bundle's speed uses the total norm and its noise level uses
    the top eigenvalue.
- **The cost grows like $e^2$ in the number of inputs that must be found at once.**
  - This is a leap-type cost: the fitted exponent is 2.06.
  - Unlike the $d^{(e-2)/2}$ escape time of gradient flow, it is mild. With Adam each weight moves at a rate set by
    its signal-to-noise ratio, not by the size of its gradient.
- **The rate goes as $\rho^{1/2}$.** Adam normalises the step by the gradient noise, which scales with the residual,
  so what matters is the bundle's share $\rho$ of the residual, not its absolute coefficient. The square root
  reproduces the near-constant time of the linear stage: 50–62 steps for $\rho$ between .38 and .77. With $\rho^1$
  that time would vary by 2×.
- **Building on a learned feature costs ×2.** The unit must keep its old direction while adding new inputs. This is
  fitted: $K=2.00$.
- **An odd degree $\ge3$ costs ×2.**
  - A zero-bias ReLU unit with direction $w$ has gate $1[w\cdot x>0]$, whose Fourier spectrum is $\tfrac12$ plus
    odd degrees only.
  - The first-layer gradient towards $\chi_S$ is the gate's coefficient on $S\triangle\{i\}$. That coefficient
    vanishes for every $i$ when $|S|$ is odd and at least 3.
  - Such characters need biases or the second layer, so they are slower.
  - Examples, all odd: sparsepoly's $x_4x_5x_6$ takes about 4× as long as its $x_2x_3$, which has the same
    coefficient; its $x_1x_2x_3$ takes about 230 steps after $x_2x_3$, while the even order-1 extensions of mux and
    stair5 take about 120; rmaj9's degree-3 stage waits until about 1000 steps.
  - Removing this factor raises traj from 0.0096 to 0.016 after refitting (Section 6).
- **The rise slope is $e\ln d$.** A unit escapes from an initial overlap $m_0=d^{-1/2}$. The bundle's amplitude
  $\propto m^{e}$ climbs $\tfrac e2\ln d$ e-folds over one unit of progress, so $\varphi=\sigma(e\ln d\,(P-1))$. This
  gives log-time slopes of about 3 for order-1 stages, 6 for pairs and 10 for triples. The network shows about 3–3.5,
  6 and 11.
- **Junta completion.** Once a gate on already-active inputs exists, the second layer can combine gates. The rest of
  the function on those inputs, such as the products that make up MAJ of MAJ$_3$ or $x_4\,?\,x_1x_2x_3:\dots$, is
  then one composition step away and arrives as one bundle. rmaj9's 37 characters of degree 5, 7 and 9 switch on
  together with its degree-3 block characters (1100–1200), not one leap at a time.
- **Finite $n$.**
  - *Partial saturation* is the overlap of a spiked estimate. A direction with signal $\rho$, estimated from $n$
    samples with noise in about $N$ directions, has squared overlap $1-N/(n\rho^2)$ with the true one. The network's
    first-order levels at $n=512$ (.40–.82, mostly about .55) and $2048$ (.78–1.0) fit this law with a single
    $N\approx46$.
  - *Missing stages* are a race against memorisation. The training loss at $n=512$ reaches zero by about step 400,
    and at $2048$ by about step 1300. Afterwards the gradient towards unlearned features is gone.
    $T_c=35\,n/64$ steps (35 epochs) puts the cutoff between the stages that survive and those that do not, at both
    sizes.

## 4. Constants and fitting

| constant | value | role | fitted value |
|---|---|---|---|
| $\tau_0$ | 44.2 steps | time scale of a move | 43.8 |
| $\alpha$ | 2 | cost exponent in $e$ | 2.06 |
| $K$ | 2 | cost factor for building on a learned feature and for odd degree $\ge 3$ | 2.00 |
| $N$ | 45.9 | noise count of the BBP level | 47.8 |
| EPOCHS | 35.4 | memorisation cutoff $T_c=\text{EPOCHS}\cdot n/64$ | 36.6 |

- **Fixed structural choices** (not fitted):
  - rate exponent ½;
  - rise slope $e\ln d$;
  - $T_0=\tau_0/\sqrt d$;
  - cutoff shape $1/(1+x^8)$;
  - the bundle and move definitions.

  The rate exponent and the cutoff steepness were chosen while building the model by looking at calibration scores.
  Steepness 6–12 and stretched-exponential cutoffs score within 0.003 in $J$. Exponent ½ against 1 is tested in
  Section 6.
- **Objective.** $J=10\cdot\overline{\text{traj}}+\overline{\text{onset}}$ over 5 targets × 4 conditions.
- **Optimiser.** Nelder–Mead in log-parameters from four starting points (`fit.py`), about 5 minutes.
  - The four starts agree on $\tau_0=43$–47, $\alpha=2.00$–2.10, $K=1.77$–2.00 and EPOCHS 29–37. $N$ is weakly
    determined: 21–48.
  - Rounding $\alpha$ and $K$ to 2 and refitting the other three raises $J$ from 0.2147 to 0.2169.
- **Leave-one-target-out.** Fit on four targets and score the fifth (`fit.py --loo`, `loo.json`):

| held-out target | constants fitted on the other four | traj (held out) | onset (held out) | traj / onset with the final constants |
|---|---|---|---|---|
| sparsepoly | τ₀ 42.7, α 2.03, K 1.93, N 41.5, epochs 32.7 | 0.0068 | 0.066 | 0.0064 / 0.053 |
| stair5 | τ₀ 42.7, α 2.08, K 1.88, N 45.4, epochs 31.9 | 0.0189 | 0.205 | 0.0158 / 0.189 |
| mux | τ₀ 46.8, α 1.98, K 1.97, N 38.2, epochs 35.6 | 0.0104 | 0.080 | 0.0093 / 0.061 |
| majpar | τ₀ 44.4, α 2.05, K 1.99, N 35.9, epochs 36.4 | 0.0087 | 0.196 | 0.0063 / 0.193 |
| rmaj9 | τ₀ 43.4, α 2.07, K 2.10, N 42.6, epochs 34.0 | 0.0113 | 0.234 | 0.0101 / 0.108 |
| **mean** | | **0.0112** | **0.156** | 0.0096 / 0.121 |

The constants move little between folds: τ₀ 42.7–46.8, α 1.98–2.08, K 1.88–2.10, N 36–45, epochs 32–36. Held
out, traj rises from 0.0096 to 0.0112 and onset from 0.12 to 0.16. Most of the onset loss is rmaj9 at $n=2048$ and
stair5 at finite $n$, where levels near ½ make the score jump (Section 8, item 5).

## 5. Calibration scores (score.py)

```
$ python trajectories/score.py trajectories/models/fourier/preds
target       cond      traj  onset  final |   zero target
sparsepoly   online   0.003  0.037  0.000 |  0.528  0.427
sparsepoly   16384    0.005  0.066  0.000 |  0.524  0.432
sparsepoly   2048     0.009  0.078  0.014 |  0.429  0.512
sparsepoly   512      0.008  0.033  0.013 |  0.361  0.548
stair5       online   0.006  0.072  0.000 |  0.465  0.504
stair5       16384    0.007  0.083  0.000 |  0.459  0.506
stair5       2048     0.042  0.304  0.020 |  0.335  0.548
stair5       512      0.008  0.294  0.009 |  0.142  0.799
mux          online   0.009  0.071  0.000 |  0.493  0.471
mux          16384    0.009  0.070  0.000 |  0.491  0.472
mux          2048     0.012  0.050  0.003 |  0.414  0.495
mux          512      0.007  0.054  0.008 |  0.152  0.768
majpar       online   0.006  0.054  0.000 |  0.460  0.499
majpar       16384    0.005  0.043  0.000 |  0.456  0.500
majpar       2048     0.003  0.016  0.004 |  0.330  0.582
majpar       512      0.011  0.660  0.013 |  0.121  0.675
rmaj9        online   0.007  0.040  0.000 |  0.523  0.429
rmaj9        16384    0.007  0.048  0.000 |  0.521  0.428
rmaj9        2048     0.018  0.315  0.033 |  0.416  0.508
rmaj9        512      0.008  0.029  0.014 |  0.369  0.575
MEAN traj 0.010  onset 0.121
```

| condition | traj | onset | one seed vs mean of other two (traj / onset) | step function (traj / onset) |
|---|---|---|---|---|
| online | 0.006 | 0.055 | 0.005 / 0.041 | 0.159 / 0.473 |
| 16384 | 0.007 | 0.062 | 0.005 / 0.041 | 0.159 / 0.479 |
| 2048 | 0.017 | 0.153 | 0.012 / 0.157 | 0.199 / 0.733 |
| 512 | 0.009 | 0.214 | 0.023 / 0.345 | 0.277 / 0.954 |
| **mean** | **0.010** | **0.121** | | 0.198 / 0.660 |

At finite $n$ the onset score is dominated by characters whose network level ends near ½. One that crosses ½ in only
one of model and network costs a full decade. majpar at 512 is an example: the pairs end at .50–.60 in the network
and .62 in the model, and the onset score is 0.66. This part of the score is noisy for the networks too (seed vs
seeds: 0.345).

## 6. Ablations

`ablate.py` switches off one ingredient, refits the five constants from the final values and rescores
(`ablations.json`):

| ablation | traj, no refit | onset, no refit | traj, refit | onset, refit | what goes wrong |
|---|---|---|---|---|---|
| full model | 0.0096 | 0.121 | 0.0096 | 0.121 |  |
| no junta completion | 0.0095 | 0.132 | 0.0094 | 0.126 | rmaj9's degree 5–9 arrive one leap at a time, too late (rmaj9 online onset 0.04 → 0.14) |
| completion only after order >= 2 moves | 0.0089 | 0.119 | 0.0090 | 0.117 | slightly better here; kept for targets like dnf3, where completion otherwise never triggers and hundreds of small characters trickle in through fragments |
| bundles keep progress when they lose members | 0.0095 | 0.120 | 0.0095 | 0.118 | slightly better here; kept because otherwise leftover members fire with near-zero strength and erratic finite-n levels (dnf3, rand3) |
| no bundle-direction (event) bases | 0.0121 | 0.151 | 0.0121 | 0.151 | mux's $x_ix_4$ split into three single-base moves that are too slow (mux online onset 0.07 → 0.10, 512: 0.05 → 0.52) |
| no odd-degree penalty | 0.0210 | 0.207 | 0.0160 | 0.170 | odd stages come too early (sparsepoly 2048 onset 0.08 → 0.35, majpar online 0.05 → 0.18, mux online 0.07 → 0.12) |
| no gating penalty | 0.0327 | 0.262 | 0.0149 | 0.187 | extensions of learned features come too early relative to fresh moves (stair5 online onset 0.07 → 0.15, rmaj9 2048: 0.31 → 0.76) |
| root moves may reuse learned inputs | 0.0123 | 0.150 | 0.0100 | 0.120 | no effect on these targets after refitting |
| BBP level from total bundle strength | 0.0115 | 0.123 | 0.0112 | 0.121 | majpar's pairs over-learned at 512 (traj 0.011 → 0.035) |
| rate ~ rho (not rho^1/2) | 0.0160 | 0.243 | 0.0113 | 0.151 | the linear-stage time varies 2× across targets, the networks' 1.2× (sparsepoly online onset 0.04 → 0.09, rmaj9 2048: 0.31 → 0.67) |
| no memorisation cutoff | 0.0443 | 0.296 | 0.0395 | 0.301 | late stages appear at 512 and 2048 |
| no BBP shrinkage | 0.0147 | 0.151 | 0.0119 | 0.128 | first-order stages fully learned at 512 |

What matters most is the finite-$n$ cutoff, then the two cost factors and the $\rho^{1/2}$ rate, then the
bundle-direction bases. Junta completion, the rule that root moves use fresh inputs, and the two generality rules
(completion after degree-3 moves, progress decay) change the calibration score by at most 0.005 in onset. They are
kept because they make the predictions on targets with many small characters coherent, not because the calibration
asks for them.

## 7. Phenomena

| phenomenon | reproduced? | how |
|---|---|---|
| staging (plateaus between stages) | yes | moves fire one after another, each with a rise whose log-time slope is ≥ 3 |
| order of characters | yes, within the seed spread online | race on $\tau/\rho^{1/2}$; e.g. sparsepoly $x_1<x_2x_3<x_1x_2x_3<x_4x_5x_6$-bundle, stair5 by degree, mux $x_i<x_ix_4<\{x_1x_2x_3x_4,x_1x_2x_3\}$, majpar pairs ≪ degree 6 |
| bundles | yes | one move learns all characters it reaches; bundle extension (mux $x_ix_4$); junta completion (rmaj9 degrees 3–9, mux $x_1x_2x_3$ with $x_1x_2x_3x_4$) |
| overshoot above 1 | **no** | $\varphi\le1$ by construction (stair5 $x_1$ and mux $x_ix_4$ reach 1.2–1.36 in the networks) |
| finite-$n$ partial saturation | yes | BBP level, e.g. $x_2x_3$ at 2048 .87 (net .78), majpar pairs at 512 .62 (net .50–.60), mux $x_ix_4$ at 512 .56 (net .53–.61) |
| missing stages at finite $n$ | yes | memorisation cutoff: every stage after about 300 steps is absent at 512, and stages after about 1000 at 2048 (majpar degree 6, sparsepoly $x_4x_5x_6$-bundle) |
| online ≈ 16384 | yes | $T_c(16384)=9000$ steps, after every stage of these targets |
| dependence on irrelevant inputs | not modelled | the model predicts $E[f\mid x_R]$ only |

## 8. Failure modes

1. **The lead-in before a stage is too abrupt.** The networks reach about 10% of a stage at a third of its onset
   time. Examples: sparsepoly $x_2x_3$ at step 100, majpar degree 6 from step 400. The model's logistic in progress
   reaches about 1%. Fattening the tail (a logistic in log-progress with a smaller slope) did not improve the scores.
2. **No overshoot.** This costs about 0.01–0.02 Var $y$ at a few checkpoints of stair5 and mux.
3. **rmaj9 at $n=2048$** (onset 0.32).
   - The network learns the part of the residual that is a function of the learned linear direction $\sum_ix_i$
     earlier and more robustly than the block part. At 2048 the cross-block degree-3 characters end at .59, the
     within-block ones at .37, and the degree-9 character at .41.
   - The model cannot split one character's coefficient between two moves, so it gives all of them the same level.
     Projections onto functions of a learned direction would capture this. They were not added because for generic
     weights (dlist5, thr10) such a projection is the whole function.
4. **Late stages at 2048 creep instead of plateauing.** stair5 degrees 4–5 rise from .5 to .8 between steps 1000 and
   20000, and mux $x_1x_2x_3x_4$ from .67 to .96. The model fires them at the online time and holds a plateau, so
   stair5 at 2048 has the largest traj error (0.042).
5. **Knife-edge levels at finite $n$.** Small changes of the constants move model levels across ½. For example, the
   leave-one-out constants fitted without rmaj9 ($K=2.10$ instead of 2) move its 2048 onset score from 0.31 to 0.75.
6. **The odd-degree factor rests on few cases.** They are sparsepoly $x_4x_5x_6$ and $x_1x_2x_3$, stair5's degree-3
   stage and rmaj9's degree-3 stage. It predicts, for example, that a 4-parity on fresh inputs ($\tau_0\cdot16=707$)
   is learned before a 3-parity ($\tau_0\cdot9\cdot2=796$).
7. **Fragmentation on targets with many small characters.** For dnf3 and dlist5, characters reachable from different
   bases fire as separate small bundles before completion sweeps the rest. Their levels at finite $n$ depend on the
   small bundles' own strength.
8. **Scope.** The constants are tied to this network, optimiser, batch and $d=30$ ($\tau_0$ is in steps). $d$ enters
   only through the rise slope and $T_0$, so no claim is made about $d$-scaling.

## 9. Predictions for the held-out targets

These were recorded before any network was run on them. They show online stages, with merged times, and the number
of characters above ½ at step 20000.

| target | online stages (step: characters) | above ½ at 2048 / 512 |
|---|---|---|
| andxor | 198: $x_1x_2,x_3x_4$; 552: $x_1x_2x_3x_4$ | 3/3, 2/3 |
| dlist5 | 49: linear; 152: all 10 pairs; 367: degree 3 through $x_1x_2,x_1x_3,x_2x_3$; 438: rest (junta completion) | 31/31, 15/31 |
| parmaj | 205: the 9 cross pairs; 694: degree 4; ~790: degree 6 | 16/16, 9/16 |
| dnf3 | 57: linear; 205: pairs; 471: block triples and part of the cross terms; 562: about 390 remaining characters (completion) | 511/511, 9/511 |
| rand1 | 55: $x_1,x_3,x_5$; 175: $x_3x_5,x_1x_3,x_1x_5$; 263: $x_4x_6$; 462: degree 3; 562: degree 4–5 | 15/15, 7/15 |
| rand3 | 72: $x_5$; 188: $x_5\cdot\{x_1,x_2,x_3,x_4,x_6\}$; 423: degree 3 on $x_4x_5,x_5x_6$; 514: the rest | 32/32, 6/32 |

`python stages.py <fn>` prints the full sequence, with strengths and levels.
