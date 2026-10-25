# What a network computes while it learns: learning trajectories on Boolean targets, and models that reproduce them

Added 24–25 October 2026, in response to: *select about five Boolean functions; characterize the function learned at each time step and the sequence of functions the network goes through; then give a general model that reproduces this.*

Status labels as in the project README. Everything here is at $d=30$, with the study's network: a μP two-hidden-layer ReLU MLP of width 128, trained by Adam (learning rate $10^{-3}$, batch 64, square loss).

## 1. Setup

**Targets.**
- *Five chosen to differ in structure:*
  - sparsepoly $=\mathrm{sign}(2x_1+x_2x_3+x_4x_5x_6)$: three terms of different degree;
  - stair5 $=\mathrm{sign}(x_1+x_1x_2+\dots+x_1\cdots x_5)$: a staircase;
  - mux $=x_4\,?\,x_1x_2x_3:\mathrm{MAJ}(x_1,x_2,x_3)$: its largest Fourier coefficient has degree 4;
  - majpar $=\mathrm{MAJ}(x_1x_2,x_3x_4,x_5x_6)$: pairs, then a degree-6 term;
  - rmaj9 $=\mathrm{MAJ}(\mathrm{MAJ}_3,\mathrm{MAJ}_3,\mathrm{MAJ}_3)$: dense and hierarchical.
- *Six held-out targets,* run only after the models below were frozen: AND$(x_1x_2,x_3x_4)$, a 5-variable decision list, MAJ$_3\oplus$MAJ$_3$, a 3-term DNF on 9 variables, and two random 6-gate formulas.

**Conditions.** One-pass training (a fresh minibatch every step), and fixed training sets of $n=16384$, $2048$ and $512$. Each condition has 3 seeds and runs 20000 steps.

**What is recorded** ([`run_traj.py`](run_traj.py)). At 72 log-spaced steps:
- the network output on every pattern of the relevant variables $x_R$, each with 32 random settings of the 24–26 irrelevant ones. This gives the learned function's dependence on the relevant variables, $f_R(x_R)=E[f(x)\mid x_R]$, exactly on all $2^r$ patterns, and its variance over the irrelevant inputs;
- the first-layer weights;
- at 13 of the steps, every hidden unit's conditional mean.

**Description of the learned function.** The full Fourier spectrum $c_S(t)$ of $f_R$. For every character $S$ of the target, its *learned fraction* $\varphi_S(t)=c_S(t)/\hat y_S$, and its *onset*, the first step at which $\varphi_S\ge1/2$ for good ([`analyze_traj.py`](analyze_traj.py)). Figures: [`../figures/trajectories.png`](../figures/trajectories.png) for the five targets, and [`../figures/trajectories_heldout.png`](../figures/trajectories_heldout.png) for the held-out ones with the models overlaid.

## 2. What the network computes over time (Numerical)

### 2.1 The function on each plateau is a projection of the target

Learning is staged. Plateaus separate stages at which groups of Fourier characters switch on.

On each plateau the network's $f_R$ is, to within 0.00–0.03 Var $y$ at large $n$, the projection of the target onto the characters learned so far:
$$f_R(t)\approx P_{\mathcal S(t)}\,y=\sum_{S\in\mathcal S(t)}\hat y_S\,\chi_S .$$

The natural alternative fits much worse. In that alternative, the network has discovered a set of inputs and fits everything about them, $f_R\approx E[y\mid x_V]$. Its distances on the intermediate plateaus ([`STAGES.md`](STAGES.md), [`STAGES-heldout.md`](STAGES-heldout.md)):

| target, after the stage named | projection | best function of the discovered inputs |
|---|---|---|
| majpar, after the pairs | 0.003 | 0.225 |
| mux, after the $x_ix_4$ stage | 0.029 | 0.413 |
| rmaj9, after the linear stage | 0.004 | 0.409 |
| dnf3, after the linear stage | 0.008 | 0.362 |
| parmaj, after the pairs | 0.05 | 0.22 |

So at every moment the network computes a *truncated Fourier expansion of the target*, with the correct coefficients on the terms it has, and nothing on the rest. The deviations from this, discussed below, are transient.

### 2.2 The sequence of functions

Onset steps online, seed mean. Characters within a factor 1.35 of each other are grouped into one stage.

| target | stages (step: characters switched on) |
|---|---|
| sparsepoly | 56: $x_1$ → 297: $x_2x_3$ → 528: $x_1x_2x_3$ → 1389: $x_4x_5x_6$ and its products with the earlier terms |
| stair5 | 65: $x_1$ → 207: $x_1x_j$ (all four, including the −0.125 ones) → 450–800: degree 3, then 4 and 5 |
| mux | 63: $x_1,x_2,x_3$ → 172: $x_1x_4,x_2x_4,x_3x_4$ → 437: $x_1x_2x_3$ and the largest coefficient, $x_1x_2x_3x_4$ (0.75), last |
| majpar | 202: the three pairs → 1165: $x_1\cdots x_6$ |
| rmaj9 | 50: all nine linear terms → 860–1200: a cascade within a factor 1.4. The top-degree $x_1\cdots x_9$ comes first (860), together with the earliest degree-3 characters (860–1080, small cross-block ones included). Degrees 5 and 7 follow at 1090–1200. |
| andxor | 201: $x_1x_2,x_3x_4$ → 299: $x_1x_2x_3x_4$ |
| dlist5 | 57: the five linear terms → 417: all 26 higher terms |
| parmaj | 171: the nine cross pairs → 282: $x_1\cdots x_6$ → 555: the degree-4 terms |
| dnf3 | 59: linear → 587: about 500 characters of degree 2–8 → 2115: $x_1\cdots x_9$ |
| rand1 | 52: $x_1,x_3,x_5$ → 240: pairs → 487: degree 3–4 |
| rand3 | 69: $x_5$ → 173: $x_jx_5$ → 527: everything else |

**Regularities.**
1. *The linear stage comes first and at a nearly fixed time,* 50–70 steps, whatever the size of the linear coefficients.
2. *Characters arrive in bundles, not one at a time.*
   - A bundle is everything one new direction of a hidden unit can carry. Examples: all $x_1x_j$ at once in stair5; the three $x_ix_4$ at once in mux.
   - Once the inputs are in use, the remaining structure on them arrives within a short window (a factor of about 1.5 in steps). Examples: rmaj9's 67 characters of degree 3–9; dnf3's 500.
   - Bundles cut across coefficient size: small characters switch on together with large ones carried by the same feature.
3. *Order follows construction, not coefficient size.*
   - A character comes after the features it can be built from. Examples: mux's largest term comes last; majpar's degree-6 term comes after the pairs.
   - New-input moves are slow, and more so the more inputs they need at once. sparsepoly: $x_2x_3$ at 300, $x_4x_5x_6$ at 1300.
   - Products of learned features are faster. sparsepoly: $x_1\cdot x_2x_3$ follows 230 steps after $x_2x_3$.
4. *Coefficients overshoot transiently,* by up to 1.36 in mux and rand3. The output weights of the features already present over-fit the residual until the next feature arrives. This is the readout fitting within the span of the current features, which is not exactly the span of the current characters.
5. *First-layer features are ReLUs of signed sums over subsets of the inputs.* Examples: $\pm(x_1+x_2+x_3)\pm x_4$ in mux; $\pm x_i\pm x_j$ pairs in majpar; block sums in rmaj9.

### 2.3 Finite training sets

- **Same order, different endpoints.** The sequence is the same, but later stages saturate partway or never start. Examples:
  - sparsepoly at $n=2048$: $x_2x_3$ ends at 0.8 and $x_1x_2x_3$ at 0.65, and the degree-3 stage never starts;
  - at $n=512$, $x_2x_3$ ends at 0.45.
- **Memorisation goes through the irrelevant inputs.** Dependence on irrelevant inputs grows to 0.1–0.35 Var $y$ once the training set is fitted. The projection picture holds for $f_R$ up to this shrinkage.
- **Online equals large $n$.** One-pass training is indistinguishable from $n=16384$.

## 3. Models that reproduce the trajectories

### 3.1 Protocol

Three independent model designs were built and calibrated on the five targets only, with at most five global constants each. Each predicts $f_R(t)$ at every step for every condition, from the target function alone.

The predictors were frozen and committed (commit `19da14d6`) before any network was run on the six held-out targets.
- *What serves as the pre-registration.* The frozen, deterministic code is. `fourier` and `gates` also wrote their held-out predictions into their write-ups beforehand.
- *How new the held-out targets are.* They were new to the trajectory study, but not to the project: the earlier fixed-$n$ study had trained networks on them, and coarse onset steps are in `study/nn_summary.json`. The independent verifiers (§6) found that no model code reads that data, or any other network data, for the targets it predicts.

Scoring ([`score.py`](score.py)):
- **traj:** the mean over steps of $\lVert f_{\rm model}-f_{\rm net}\rVert^2/\mathrm{Var}\,y$;
- **onset:** the mean $|\log_{10}|$ error of each character's onset step. A character that crosses $\tfrac12$ in only one of the two counts as one decade.

### 3.2 The three models

- **`fourier`** ([`models/fourier/MODEL.md`](models/fourier/MODEL.md)): a by-hand rule on Fourier characters.
  - *The prediction* is $f_t=\sum_S\hat y_S\varphi_S(t)\chi_S$.
  - *Moves.* Characters switch on through moves. A move takes something already learned (nothing, a learned character, or a learned bundle) and multiplies it by $e$ input variables at once. It learns every remaining character it reaches, as one bundle.
  - *Timing.* Moves race at rate $\rho^{1/2}/\tau$, where $\rho$ is the bundle's share of the residual and
    $$\tau=\tau_0\,e^2\cdot2^{[\text{built on a learned feature}]}\cdot2^{[\text{odd degree}\ge3]}.$$
    A fired bundle rises along a saddle-escape logistic with slope $e\ln d$ in progress.
  - *Junta completion.* Once a nonlinear gate on inputs already in use exists, the rest of the function on those inputs is one cheap move.
  - *Finite $n$.* Memorisation cuts the race off after about 35 epochs. A bundle saturates at the spiked-estimation overlap $1-N/(n\rho^2)$.
  - *Constants:* five fitted by optimiser. On top of these, 2–3 continuous constants and 8–10 structural switches were chosen on calibration scores (§6).
- **`gates`** ([`models/gates/MODEL.md`](models/gates/MODEL.md)): feature-level greedy growth.
  - *The prediction.* The output is the least-squares fit of the target on the ReLU gates grown so far.
  - *Order of a bundle.* A bundle of characters has order $\kappa$, the number of pieces it is built from at once. A piece is an input or an existing gate.
  - *Timing.* All bundles align in parallel by $\dot m=\eta\rho\,m^{\kappa-1}$ and escape at $m=1$.
  - *Finite $n$.* A memorisation clock, plus a kernel background.
  - *Constants:* five fitted by optimiser, plus several structural choices made on calibration scores (§6).
- **`flow`** ([`models/flow/MODEL.md`](models/flow/MODEL.md)): the network's own Adam dynamics, reduced.
  - *What is kept.* A width-64 copy of the network that sees only the relevant inputs. The irrelevant inputs become Gaussian noise on each first-layer unit. Adam runs on the expected gradient, with the minibatch noise kept in its second moment.
  - *Finite $n$.* Each training pattern gets a memorised offset.
  - *Clock.* It runs on the network's clock with no time map.
  - *Constants:* none optimised against network data. Its two memorisation constants are at their derived values, though they were bracketed against the networks, and about six structural choices were made while scoring against them. A width correction rescales its clock uniformly by $(128/N)^{0.1}$, a factor measured on the model itself.

### 3.3 Scores

**Against the 3-seed network mean** (score.py), traj / onset:

| model | calibration (5 targets) | held-out (6 targets) | held-out, online | held-out, $n=2048$ |
|---|---|---|---|---|
| `fourier` | 0.010 / 0.12 | 0.011 / 0.18 | 0.009 / 0.10 | 0.014 / 0.26 |
| `gates` | 0.010 / 0.16 | 0.012 / 0.21 | 0.009 / 0.15 | 0.017 / 0.30 |
| `flow` | 0.005 / 0.09 | **0.005 / 0.15** | **0.002 / 0.04** | 0.006 / 0.22 |
| *trivial step function (target mean until step 1000, then the target)* | *0.20 / 0.66* | – | – | – |

**Like for like** ([`fair_scores.py`](fair_scores.py)): traj of each model against *single* network seeds, next to one network seed against another, i.e. how well an independent rerun of the network predicts a run.

| | calibration, online | calibration, $n=2048$ | calibration, $n=512$ | held-out, online | held-out, $n=2048$ | held-out, $n=512$ |
|---|---|---|---|---|---|---|
| *network seed vs another seed* | *0.0070* | *0.0163* | *0.0307* | *0.0054* | *0.0111* | *0.0360* |
| `fourier` | 0.0087 | 0.0222 | 0.0188 | 0.0105 | 0.0177 | 0.0232 |
| `gates` | 0.0096 | 0.0219 | 0.0196 | 0.0105 | 0.0205 | 0.0252 |
| `flow` | 0.0042 | 0.0113 | 0.0208 | 0.0037 | 0.0097 | 0.0219 |

What the scores say:
- **All three models predict the held-out targets about as well as the calibration targets.**
- **`flow` predicts a network run better than an independent rerun of the network does,** in every condition. It models the expected trajectory, and the remaining differences are run-to-run noise.
- **`fourier` and `gates`, the two discrete rules, come within 1.3–2× of rerun-to-rerun variability at large $n$,** and do better than it at $n=512$, where seeds also differ in their training sets.
- **Onsets.** Online, `flow` puts held-out onsets within about 10% (0.04 decades), and `fourier`'s by-hand rule within about 25% (0.10 decades). At finite $n$, onset errors are dominated by characters that end near $\tfrac12$, where model and network fall on opposite sides of the threshold. The trajectory errors there stay small.
- **An earlier comparison was not like for like.** An earlier version of this table compared the models (scored against the 3-seed mean) with one seed scored against the mean of the other two. That comparison is not like for like: the irreducible error of the 3-seed-mean reference is only about a sixth of the seed-vs-seed number.

## 4. The general model (Heuristic)

Taken together, the measurements and the three models support the following description. At every moment the network computes
$$f_t\;\approx\;\sum_{S}\hat y_S\,\varphi_S(t)\,\chi_S,\qquad \varphi_S\in[0,1],$$
a truncated Fourier expansion of the target. The fractions switch on in bundles through a race of *moves*:

1. **A move** takes a feature the network already has (nothing, an input direction, or a learned bundle) and extends it by $e$ new input variables at once.
   - It brings in every character of the target it reaches, in proportion to the coefficients. This is one new direction of a hidden unit, so small and large coefficients come together.
   - Once a nonlinear feature exists on a set of inputs, everything else the target has on those inputs is one cheap move away ("junta completion"). This is the second layer composing first-layer features.
2. **Its duration** grows with the number of inputs it must coordinate at once: about $e^2$ at $d=30$ under Adam.
   - It is doubled when it must be built on an existing feature, and doubled for odd degree $\ge3$, which a zero-bias ReLU gate cannot reach through its first layer.
   - It shrinks with the bundle's share $\rho$ of the residual, as $\rho^{-1/2}$ under Adam.
   - The linear stage is therefore fast and nearly size-independent, and high-order terms that must be found from scratch are slow.
3. **Within a stage,** the readout refits on the features present. This gives transient overshoot and slow lead-ins.
4. **With $n$ samples,** two things limit the endpoint:
   - each bundle is learned only to the spiked-estimation overlap $1-N/(n\rho^2)$;
   - the race is cut off once the training set is memorised, after a fixed number of epochs. Memorisation goes into the irrelevant inputs.

**Its mechanism** is clearest in `flow`, which reproduces it from the network's own dynamics with no constant optimised against the networks:
- each stage is the escape from a saddle;
- its length is set by Adam's normalisation by the minibatch gradient noise;
- high-order characters are slow because the irrelevant inputs blur each unit's response to them;
- odd degrees $\ge3$ need biases.

**This is the composition finding again** ([`../composition/RESULTS.md`](../composition/RESULTS.md)). A term's cost is set by the move that builds it from what already exists, not by the leap over raw inputs.

## 5. Limits

- **One network.** One architecture, width 128, Adam with one learning rate, $d=30$, square loss, and targets with up to 9 relevant variables. The constants of `fourier` and `gates` are tied to this setting.
- **Dependence on $d$.** The $e^2$ cost is a fixed-$d$ statement. The sample-complexity results of the main study show a $d^{k-1}$ dependence on the number of inputs needed at once, which these models do not include.
- **Partial reproduction.**
  - `fourier` and `gates` produce no overshoot.
  - None of the models reproduces the slow creep after memorisation at $n=2048$.
  - None predicts the dependence on irrelevant inputs at finite $n$.
- **Verification.** See §6.

## 6. Verification

An independent agent per model checked four things.
- **Reproduction.** It regenerated the predictions from the frozen commit. They were bit-identical, and the scores reproduced exactly.
- **Leakage.** It read every code path for leakage. None of the three predictors reads any network output for the target it predicts.
- **Pre-registration.** It checked the recorded held-out predictions against the frozen code. They match, apart from two labelling slips in `fourier`'s write-up. `flow` recorded none; its frozen code is the pre-registration.
- **Write-up claims.** It audited each write-up's claims.

Its main findings, each now disclosed in the model's MODEL.md:
- **Undercounted constants.** "Five constants" undercounts the degrees of freedom of `fourier` and `gates`. Each also has 2–3 hand-tuned continuous constants and roughly 8–10 structural switches chosen on calibration scores.
- **Choices made with the networks in view.** `flow`'s constants were not optimised, but its two memorisation constants were bracketed against the networks, and about six structural choices were made while scoring against them.
- **Held-out outputs seen during design.** `fourier`'s builder looked at the model's own outputs (not the networks') on three held-out targets, and kept two rules on that basis. Switching them off changes the held-out score by less than 0.001.
- **The held-out targets were not new to the project** (§3.1).
- **The noise-floor comparison** was not like for like (§3.3, now corrected).
- **Overstated details.** Several quantitative details in the write-ups were overstated: rise slopes, some ranges, one ablation factor. They are corrected there.
