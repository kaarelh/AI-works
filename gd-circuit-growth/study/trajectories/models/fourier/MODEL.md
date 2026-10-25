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
- **Constants.** Five fitted by the optimiser, jointly on the five calibration targets and four conditions:
  $\tau_0=44.2$ steps, $\alpha=2$, $K=2$, $N=45.9$, 35.4 epochs. The values of $\alpha$ and $K$ were fitted, then
  rounded. Besides these, two or three continuous constants and about eight to ten discrete rules were chosen by hand
  while looking at calibration scores (Section 4).
- **Calibration** (score.py): mean traj **0.010**, mean onset **0.121**.
  - online 0.006 / 0.055;
  - 16384: 0.007 / 0.062;
  - 2048: 0.017 / 0.153;
  - 512: 0.009 / 0.214.

  These scores compare the model with the 3-seed network mean. Like for like (`fair_scores.py`,
  `fair_scores.json`), traj of the model against single seeds, next to one seed against another:
  - online 0.0087 against 0.0070 (1.24×);
  - 16384: 0.0090 against 0.0068 (1.32×);
  - 2048: 0.0222 against 0.0163 (1.36×);
  - 512: 0.0188 against 0.0307 (0.61×).

  So the model is 1.2–1.4× the seed-to-seed traj spread online, at 16384 and at 2048. It is below it only at 512,
  where the seeds also differ in their training sets. On the held-out targets the ratios are 1.93×, 1.92×, 1.59× and
  0.65× (Section 5). The trivial step function scores 0.198 / 0.660 against the 3-seed mean.
- **Reproduced:** staging, the order of characters, bundles (mux's three $x_ix_4$ through one direction, rmaj9's 36
  characters of degree 5 and 7 through junta completion), finite-$n$ partial saturation and missing stages.
- **Not reproduced:**
  - overshoot;
  - the slow lead-in before sparsepoly's $x_2x_3$, which reaches 9% at a third of its onset time (other stages
    reach 0–4%);
  - the slow creep of late stages at $n=2048$;
  - rmaj9's split between the part of the function that is symmetric in all nine inputs and the block part. At
    $n=2048$ it shows in the levels. Online it shows in the timing: the degree-9 and cross-block degree-3
    characters arrive before the within-block ones.

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
  so what matters is the bundle's share $\rho$ of the residual, not its absolute coefficient. The network's linear
  stage takes a near-constant 47–66 steps (seed mean). Between the extremes of $\rho$, stair5 ($\rho=.38$) at 65
  steps and sparsepoly ($\rho=.77$) at 56, it varies by 1.16×. The square root predicts 1.42× (the model gives 72
  and 51 steps), so it still overstates the variation. With $\rho^1$ that time would vary by 2×.
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
  gives log-time slopes of 3.4 for order-1 stages, 6.8 for pairs and 10.2 for triples. The network does not match
  this closely. Its slope of $\operatorname{logit}\varphi$ against $\ln t$ at the ½ crossing (seed mean online, ±2
  checkpoints) is 4.0–7.3 for linear stages, 3.6–4.6 for order-1 extensions, 4.0 and 6.3 for the pair stages of
  sparsepoly and majpar, and 17 for sparsepoly's $x_4x_5x_6$. The earlier figures (3–3.5, 6 and 11) had no recorded
  method and do not reproduce.
- **Junta completion.** Once a gate on already-active inputs exists, the second layer can combine gates. The rest of
  the function on those inputs, such as the products that make up MAJ of MAJ$_3$ or $x_4\,?\,x_1x_2x_3:\dots$, is
  then one composition step away and arrives as one bundle. rmaj9's 36 characters of degree 5 and 7 switch on
  together (1095–1217), shortly after its degree-3 characters (855–1085), not one leap at a time. Its degree-9
  character does not fit. It crosses ½ at 796 in the seed mean (777, 739 and 1092 by seed), before every degree-3
  character. The model fires it with the other 36 at 1180.
- **Finite $n$.**
  - *Partial saturation* is the overlap of a spiked estimate. A direction with signal $\rho$, estimated from $n$
    samples with noise in about $N$ directions, has squared overlap $1-N/(n\rho^2)$ with the true one. The levels of
    the network's first nonlinear stage at $n=512$ (.37–.82, mostly about .55) and $2048$ (.78–1.0) fit this law with
    a single $N\approx46$. The degree-1 characters themselves end at .79–1.13 at 512.
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

- **Choices made by hand.** These were not fitted by the optimiser, but most were chosen while looking at
  calibration scores.
  - Continuous: the rate exponent ½ and the cutoff steepness 8 in $1/(1+x^8)$. Both were free parameters in an
    earlier version of the model. So was the exponent of $n$ in $T_c\propto n$, which was set to 1. Steepness 6–12
    and stretched-exponential cutoffs score within 0.003 in $J$. Exponent ½ against 1 is tested in Section 6.
  - Discrete: the eight on/off rules of Section 6 (junta completion, completion after degree-3 moves, progress decay,
    bundle-direction bases, the odd-degree penalty, the gating penalty, fresh inputs for root moves, the BBP level
    from the best direction). They were compared by calibration ablations. Earlier versions also tried other
    completion variants and a second time scale, which was dropped.
  - Smaller rules: the linear stage is exempt from BBP shrinkage; junta completion is exempt from the odd penalty;
    the odd penalty applies when more than half the bundle weight is of odd degree $\ge3$; the direction strength
    rule of Section 2.4; the progress decay $s_{\text{new}}/s_{\text{old}}$; the level of unfired moves; one factor
    $K$ shared by the two penalties; the weight 10 in $J$.
  - Called derived, but checked against network numbers: the rise slope $e\ln d$, $T_0=\tau_0/\sqrt d$, the
    $\sqrt\rho$ rate and the odd-degree factor (Section 3).

  So the honest count is 5 constants fitted by the optimiser, 2–3 continuous constants tuned by hand and about 8–10
  discrete rules selected on calibration scores. Two of the discrete rules were also chosen by looking at the
  model's own outputs on held-out targets (Section 6).
- **Objective.** $J=10\cdot\overline{\text{traj}}+\overline{\text{onset}}$ over 5 targets × 4 conditions.
- **Optimiser.** Nelder–Mead in log-parameters from four starting points (`fit.py`), about 5 minutes.
  - The four starts agree on $\tau_0=43$–47, $\alpha=2.00$–2.10, $K=1.77$–2.00 and EPOCHS 29–37. $N$ is weakly
    determined: 21–48.
  - The best logged fit reached $J=0.2147$ at the "fitted value" column. With the frozen code those values give
    0.2156. Either `model.py` changed after the fit (the fit ran at 20:44, `model.py` was last changed at 21:08),
    or the score is sensitive to the rounding of the logged values.
  - Rounding $\alpha$ and $K$ to 2 and refitting the other three gives the final constants, with $J=0.2169$. This
    refit was not logged. An independent refit lands at $\tau_0=44.5$, $N=46.1$, EPOCHS 35.8 with $J=0.2167$, so
    the final constants are consistent.
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

The seed column is not like for like. The model is scored against the 3-seed mean, and the seed against a 2-seed
mean. The like-for-like comparison is `fair_scores.py` (`fair_scores.json`). It scores traj of the model against
each single seed, and of each seed against each other seed:

| condition | calibration: model vs single seeds | calibration: seed vs seed | ratio | held-out: model vs single seeds | held-out: seed vs seed | ratio |
|---|---|---|---|---|---|---|
| online | 0.0087 | 0.0070 | 1.24 | 0.0105 | 0.0054 | 1.93 |
| 16384 | 0.0090 | 0.0068 | 1.32 | 0.0106 | 0.0055 | 1.92 |
| 2048 | 0.0222 | 0.0163 | 1.36 | 0.0177 | 0.0111 | 1.59 |
| 512 | 0.0188 | 0.0307 | 0.61 | 0.0232 | 0.0360 | 0.65 |

So on the calibration targets the model is 1.2–1.4× the seed-to-seed spread online, at 16384 and at 2048, and on
the held-out targets 1.6–1.9×. It is below the spread only at 512, where the seeds also differ in their training
sets.

At finite $n$ the onset score is dominated by characters whose network level ends near ½. One that crosses ½ in only
one of model and network costs a full decade. majpar at 512 is an example: the pairs end at .50–.60 in the network
and .62 in the model, and the onset score is 0.66. This part of the score is noisy for the networks too (one seed
against the other two: 0.345).

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

dnf3, dlist5 and rand3 are held-out targets. The two generality rules were kept after looking at the model's own
outputs on them (no network data), before the final fit. Both rules make calibration worse: $J$ is 0.2169 with them
and 0.2071 without either. They also gained nothing held out. The held-out traj / onset is 0.0107 / 0.183 as
frozen, 0.0099 / 0.183 without completion after degree-3 moves, 0.0112 / 0.186 without progress decay and
0.0105 / 0.183 without both.

## 7. Phenomena

| phenomenon | reproduced? | how |
|---|---|---|
| staging (plateaus between stages) | yes | moves fire one after another, each with a rise whose log-time slope is ≥ 3 |
| order of characters | yes, within the seed spread online | race on $\tau/\rho^{1/2}$; e.g. sparsepoly $x_1<x_2x_3<x_1x_2x_3<x_4x_5x_6$-bundle, stair5 by degree, mux $x_i<x_ix_4<\{x_1x_2x_3x_4,x_1x_2x_3\}$, majpar pairs ≪ degree 6 |
| bundles | yes | one move learns all characters it reaches; bundle extension (mux $x_ix_4$); junta completion (rmaj9 degrees 5 and 7, mux $x_1x_2x_3$ with $x_1x_2x_3x_4$); rmaj9's degree-9 character arrives earlier in the network, before the degree-3 ones |
| overshoot above 1 | **no** | $\varphi\le1$ by construction (stair5 $x_1$ and mux $x_ix_4$ reach 1.2–1.36 in the networks) |
| finite-$n$ partial saturation | yes | BBP level, e.g. $x_2x_3$ at 2048 .87 (net .78), majpar pairs at 512 .62 (net .50–.60), mux $x_ix_4$ at 512 .56 (net .53–.64) |
| missing stages at finite $n$ | yes | memorisation cutoff: every stage after about 300 steps is absent at 512, and stages after about 1000 at 2048 (majpar degree 6, sparsepoly $x_4x_5x_6$-bundle) |
| online ≈ 16384 | yes | $T_c(16384)=9000$ steps, after every stage of these targets |
| dependence on irrelevant inputs | not modelled | the model predicts $E[f\mid x_R]$ only |

## 8. Failure modes

1. **The lead-in before some stages is too abrupt.** sparsepoly's $x_2x_3$ reaches 9% at a third of its onset time
   (step 100), where the model's logistic in progress reaches about 1%. Other stages are closer to the model: at a
   third of their onset time mux's $x_ix_4$ is at 3%, stair5's $x_1x_2$ at 4%, majpar's pairs and its degree-6
   character at 2%, and sparsepoly's $x_4x_5x_6$ at 0%. Fattening the tail (a logistic in log-progress with a smaller
   slope) did not improve the scores.
2. **No overshoot.** This costs about 0.01–0.02 Var $y$ at a few checkpoints of stair5 and mux.
3. **rmaj9 at $n=2048$** (onset 0.32).
   - The network learns the part of the residual that is a function of the learned linear direction $\sum_ix_i$
     earlier and more robustly than the block part. At 2048 the cross-block degree-3 characters end at .59, the
     within-block ones at .37, and the degree-9 character at .41.
   - The same split shows online, in the timing. The degree-9 character crosses ½ at 796 and the cross-block
     degree-3 characters at 855–926, before the within-block ones (1012–1085). The model fires all degree-3
     characters at 1081 and all of degrees 5–9 at 1180.
   - The model cannot split one character's coefficient between two moves, so it gives all of them the same level.
     Projections onto functions of a learned direction would capture this. They were not added because for generic
     weights (dlist5, thr10) such a projection is the whole function.
4. **Late stages at 2048 creep instead of plateauing.** stair5 degrees 4–5 rise from .5 to .8 between steps 1000 and
   20000, and mux $x_1x_2x_3x_4$ from .78 to .95. The model fires them at the online time and holds a plateau, so
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

These were recorded, in the frozen commit 19da14d6, before any network was run on them in this study. Two caveats
are in the Independent verification section below. The model's own outputs on dlist5, dnf3 and rand3 were looked
at during design, and coarse network results for all six targets already existed from the project's earlier
fixed-$n$ study. The table shows online stages, with merged times, and the number of characters above ½ at step
20000.

| target | online stages (step: characters) | above ½ at 2048 / 512 |
|---|---|---|
| andxor | 198: $x_1x_2,x_3x_4$; 552: $x_1x_2x_3x_4$ | 3/3, 2/3 |
| dlist5 | 49: linear; 152: all 10 pairs; 367: degree 3 through $x_1x_2,x_1x_3,x_2x_3$; 438: degree 3 through $x_4x_5$; 471: the 6 characters of degree 4–5 (junta completion) | 31/31, 15/31 |
| parmaj | 205: the 9 cross pairs; 694: degree 4; ~790: degree 6 | 16/16, 9/16 |
| dnf3 | 57: linear; 205: pairs; 471: block triples and part of the cross terms; 562: about 390 remaining characters (completion) | 511/511, 9/511 |
| rand1 | 55: $x_1,x_3,x_5$; 175: $x_3x_5,x_1x_3,x_1x_5$; 263: $x_4x_6$; 462: degree 3 through $x_4x_6$; 523: $x_1x_3x_5$; 562: degree 4–5 | 15/15, 7/15 |
| rand3 | 72: $x_5$; 188: $x_5\cdot\{x_1,x_2,x_3,x_4,x_6\}$; 423: degree 3 on $x_4x_5,x_5x_6$; 514: the rest | 32/32, 6/32 |

`python stages.py <fn>` prints the full sequence, with strengths and levels. Two labels in this table were
corrected on 25 October 2026 to match the frozen output. The frozen text gave dlist5's 438 as "rest (junta
completion)" and rand1's 462 as "degree 3". The saved predictions themselves are unchanged.

## Independent verification (25 October 2026)

An independent verifier rechecked this model after the held-out networks were run.

- **The scores reproduce exactly from the frozen commit 19da14d6.** The verifier regenerated the predictions from a
  `git archive` of that commit for all 5 calibration and 6 held-out targets. All 44 `.npz` files are bit-identical
  to the saved ones. `score.py` reproduces `preds/scores.json` and `heldout_scores/fourier.json` with zero
  difference: calibration 0.010 / 0.121, held-out 0.011 / 0.183. The model folder, `boolfuncs.py` and `score.py`
  are unchanged since the freeze.
- **No code path reads network results.**
  - `predict.py` imports only `model.py`. `model.py` imports only numpy, math, itertools and
    `boolfuncs.make_suite`, and `boolfuncs.py` imports only numpy. Nothing opens a file. The spectrum is computed
    from the target function.
  - Network data is used only in `fit.py`, `ablate.py` and the builder's scratch harness, all on the five
    calibration targets.
  - The timeline is consistent. The model files were last changed on 24 October at 21:08, the freeze commit is at
    00:13:54 on 25 October, the held-out predictions were written at 00:14:05–00:14:17, and the held-out networks at
    00:14:37–00:20:15.
- **What was fitted or chosen with the calibration networks in view.** There are 5 constants fitted by the
  optimiser ($\tau_0$, $\alpha$, $K$, $N$, EPOCHS). On top of them come 2–3 continuous constants tuned by hand (the
  rate exponent, the cutoff steepness, the $n$-scaling of $T_c$) and about 8–10 discrete rules selected on
  calibration scores (Section 4). The earlier "five constants" undercounted.
- **The held-out targets had been trained before, in the project's earlier fixed-$n$ study.**
  `study/nn_summary.json` and `study/NN-STUDY-TABLES.md` (commit 9fcf27f2, 23 October) hold coarse results for all
  six targets from the same network family at the largest $n$. They give the step at which each character first
  reaches half its coefficient, and test error by $n$. For example, parmaj's cross pairs are at step 200 and its degree 4 at
  500–1000; rand3's $x_5$ is at 100 and $x_4x_5,x_5x_6$ at 200. The model never read that data. No model or scratch
  code reads these files, and nothing shows that the builder looked at them. But the held-out targets were not
  unseen by the project.
- **The model's own outputs on held-out targets were viewed during design.** The in-development model was run on
  dlist5, dnf3 and rand3 on 24 October at 20:37. That was before the final fit (20:39–20:44) and the second
  ablation run (21:05). Two rules, completion after degree-3 moves and progress decay, were kept on that basis
  although both worsen calibration. They gained nothing held out (Section 6).
- **The fit log does not match the final code exactly** (Section 4). The best logged 5-parameter fit gives $J$
  0.2156 with the frozen code, not the logged 0.2147. The refit after rounding was not logged, but an independent
  refit agrees with the final constants.
- **Claims corrected in this file.** The verifier found these overclaims and slips, and each is fixed above:
  - the seed-noise comparison was not like for like (now Section 5);
  - rmaj9's degree-9 character arrives early, not in the completion bundle;
  - the 10% lead-in holds only for sparsepoly's $x_2x_3$;
  - the quoted network rise slopes do not reproduce;
  - a few ranges were slightly off: the levels of the first nonlinear stage at 512, mux's $x_ix_4$ at 512, the
    linear-stage times, and mux's late creep at 2048;
  - two labels in the held-out table were wrong.

  The other quantitative claims check out exactly. These include the scores, the per-condition table, the
  baselines, the ablation and leave-one-out tables, the sparsepoly walk-through, the finite-$n$ levels, the
  overshoot and the rmaj9 split at $n=2048$.
- **Held-out outcome, for context.** Held out, the onset score degrades from 0.121 to 0.183.
  - The counts above ½ are right for andxor, parmaj, rand1 and rand3 at both $n$. They miss dlist5 at 512 (network
    12, predicted 15) and dnf3 (2048: network 384, predicted 511; 512: network 51, predicted 9).
  - parmaj's degree-6 character arrives at 273–291 steps in all three seeds, before the degree-4 ones (554–590).
    The prediction was about 790, last.
  - andxor's degree-4 character arrives at 298 steps, against 552 predicted.
