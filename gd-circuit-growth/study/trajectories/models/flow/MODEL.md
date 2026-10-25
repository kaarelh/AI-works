# Flow: the network's own dynamics, reduced to the relevant cube

Approach `flow`. The model predicts the function the network computes at every training step by simulating a reduced
version of the network's own training dynamics. It keeps the network's parameters, initialisation and optimiser
(Adam, the same learning rate and multipliers, the same 20000 steps), and integrates out everything the conditional
mean $F_t(x_R)=E[f_t(x)\mid x_R]$ does not need: the irrelevant inputs, the minibatch sampling and half the width.

- [`flow.py`](flow.py): the model.
- [`predict.py`](predict.py): writes the score files and prints the predicted onset of every character.
- [`fit.py`](fit.py), [`ablate.py`](ablate.py), [`width.py`](width.py): the checks of Sections 3 and 5, with their
  records `fit_*.json` and [`width_dilation.txt`](width_dilation.txt).
- [`fig.py`](fig.py) draws [`fig_traj.png`](fig_traj.png).
- [`preds/`](preds): the calibration predictions, with `preds/scores.json` written by `score.py`.

## Summary

- **The object.** The model is a width-64 copy of the network that sees only the $r$ relevant inputs.
  - Each first-layer unit also carries the Gaussian noise $z_k=w_{{\rm off},k}\cdot x_{\rm off}$ that the $d-r$
    irrelevant inputs put on its pre-activation.
  - The layers are propagated in moment closure: the mean and variance of every unit given $x_R$. So the model's
    output is $F_t(x_R)$ on all $2^r$ patterns at once.
  - It is trained by Adam on the expected loss. The minibatch noise enters where it acts systematically, in Adam's
    second moment $v$.
  - At finite $n$, every training pattern has a memorised offset $\mu_p$. It absorbs the training residual through
    the sample's own irrelevant coordinates, at the rate of the diagonal of the Adam-preconditioned tangent kernel.
- **Constants.** None is fitted to the networks. The model was not built blind to them, though (Section 3).
  - Memorisation has two constants, both at their derived values: rate factor $c_{\rm mem}=1$, and memory slots
    $n_c=128\,(d-r)$. They were bracketed against the calibration networks, $c_{\rm mem}$ at ×0.75–1.5 and
    $c_{\rm cap}$ at ×0.5–2. $c_{\rm mem}=1.25$ and $c_{\rm cap}=2$ score slightly better, by about the noise of 2
    seeds, and the derived values were kept (Section 3).
  - The width correction $(128/N)^{0.1}$ was measured on the model itself, against its own width-128 version.
  - About six structural and numerical choices were made while scoring the model against the calibration networks
    (Section 3).
  - No time map is fitted to the networks. At reduced width the model's clock is divided by the model-measured width
    correction, a uniform rescaling by 7% at $N=64$, 10% at 48 and 15% at 32. The width-128 model needs none and
    scores the same.
- **Calibration** (score.py, five targets): mean traj **0.0050**, mean onset **0.086**.

  | condition | traj | onset | final |
  |---|---|---|---|
  | online | 0.0018 | 0.028 | 0.0000 |
  | 16384 | 0.0018 | 0.026 | 0.0003 |
  | 2048 | 0.0059 | 0.116 | 0.0119 |
  | 512 | 0.0106 | 0.174 | 0.0178 |

  For scale:
  - these scores compare the model with the 3-seed network mean. Like for like
    ([`fair_scores.py`](../../fair_scores.py), `fair_scores.json`), traj of the model against single network seeds,
    next to one seed against another:

    | condition | calibration: model vs single seeds | seed vs seed | ratio | held-out: model vs single seeds | seed vs seed | ratio |
    |---|---|---|---|---|---|---|
    | online | 0.0042 | 0.0070 | 0.59 | 0.0037 | 0.0054 | 0.68 |
    | 16384 | 0.0041 | 0.0068 | 0.60 | 0.0038 | 0.0055 | 0.69 |
    | 2048 | 0.0113 | 0.0163 | 0.69 | 0.0097 | 0.0111 | 0.87 |
    | 512 | 0.0208 | 0.0307 | 0.68 | 0.0219 | 0.0360 | 0.61 |

    So the model predicts a network run better than an independent rerun of the network does, in every condition.
    That is expected of a model of the mean trajectory, and it does not put the model at the noise level. A perfect
    predictor of the expected trajectory would score about half the seed-vs-seed number. The model is 1.2–1.4× that
    floor on the calibration targets and 1.2–1.7× on the held-out ones. On the 3-seed-mean scale of the table above
    the floor is (seed vs seed)/6, i.e. 0.0012 / 0.0011 / 0.0027 / 0.0051 by condition, and the model is 1.6–2.2×
    above it (held out 1.7–3.2×). An earlier version of this file compared the model with one seed against the
    mean of the other two, which is not like for like;
  - the trivial step function scores traj 0.12–0.32 and onset 0.20–1.04, by target and condition;
  - the other two approaches score 0.0096 / 0.121 (`fourier`) and 0.0101 / 0.162 (`gates`).
- **Reproduced:**
  - staging, and the order and timing of the stages: online the onsets are typically within 7% (mean
    $|\log_{10}|$ error 0.028);
  - bundles, including rmaj9's 67 characters of degrees 3–9, small cross-block ones among them, which arrive
    together, at 875–1322 steps against the networks' 796–1217 (Section 4);
  - overshoot: stair5's $x_1$ peaks at 1.15 (networks 1.22), mux's $x_i$ at 1.17 (1.21) and $x_ix_4$ at 1.34 (1.36);
  - the slow lead-in before each stage;
  - the training loss curve at finite $n$;
  - partial saturation and missing stages at finite $n$.
- **Not reproduced:**
  - the slow creep after memorisation at $n=2048$;
  - the growth of the irrelevant weights at finite $n$, so the model does not predict the irrelevant dependence there;
  - some threshold onsets: majpar 512, rmaj9 2048 and stair5 2048 carry most of the onset error.
- **Runtime:** 40–90 s per target for $r\le6$, 140 s for $r=9$, 190 s for $r=10$, on one core.

## 1. The reduction, step by step

Write $x=(x_R,x_{\rm off})$, and split the first-layer weights the same way, $W_1=[W_R\mid W_{\rm off}]$. The network
is $f=a\cdot{\rm relu}(W_2\,{\rm relu}(W_Rx_R+W_{\rm off}x_{\rm off}+b_1)+b_2)$. The scored quantity is $F_t(x_R)$.

### 1.1 Irrelevant inputs become per-unit Gaussian noise

Given $x_R$, unit $k$ has pre-activation $u_k+z_k$, with $u_k=w_{R,k}\cdot x_R+b_k$ and
$z_k=w_{{\rm off},k}\cdot x_{\rm off}$.

- $z$ is a sum of $d-r\ge20$ independent $\pm1$ terms, so it is close to Gaussian: $z\sim N(0,W_{\rm off}W_{\rm off}^\top)$.
- Its variance is large. At initialisation $s_k^2=\lVert w_{{\rm off},k}\rVert^2\approx(d-r)/d\approx0.8$, against
  $\lVert w_{R,k}\rVert^2\approx r/d\approx0.1$–$0.3$.
- So, seen from the relevant cube, every unit is a Gaussian-smoothed ReLU:
  $$E[h_k\mid x_R]=s_k\varphi(u_k/s_k)+u_k\Phi(u_k/s_k),\qquad E[h_k^2\mid x_R]=(u_k^2+s_k^2)\Phi+u_ks_k\varphi .$$

The model keeps $w_{{\rm off},k}\in\mathbb R^{d-r}$ as a parameter, with the network's initialisation.

### 1.2 Moment closure through the second layer

- The second-layer pre-activation $v_l=\sum_kW_{2,lk}h_k+b_{2,l}$ is treated as Gaussian given $x_R$.
  - Its mean is $\sum_kW_{2,lk}E[h_k\mid x_R]+b_{2,l}$.
  - Its variance is $\sum_kW_{2,lk}^2{\rm Var}(h_k\mid x_R)$. The cross-unit covariances are dropped: the rows of
    $W_2$ are not trained against the irrelevant directions, so those terms average out.
- The output mean is $F=\sum_la_lE[{\rm relu}(v_l)]$.
- The loss decomposes exactly: $E(f-y)^2/2=E_{x_R}[(F-y)^2+{\rm Var}(f\mid x_R)]/2$.
- ${\rm Var}(f\mid x_R)$ has three parts.
  - **The linear part,** $\lVert\sum_kG_kP_kw_{{\rm off},k}\rVert^2$, with $G_k$ the unit's mean back-propagated gain
    and $P_k=P(u_k+z_k>0)$. It is kept exactly, through the vectors $w_{{\rm off},k}$. The network reduces this
    term mostly by cancellation, turning its readout direction orthogonal to the irrelevant weights, and less by
    shrinking every $w_{{\rm off},k}$.
  - **The higher-Hermite part of each unit,** kept on the diagonal.
  - **The non-linear part of the second layer.**

### 1.3 Minibatch noise enters through Adam's second moment

The minibatch gradient is $g_B=g+\xi$, with mean $g$ and per-parameter variance $\sigma_\theta^2/B$.

- Adam's $m$ averages about 10 steps of $g_B$; its mean is $g$.
- Adam's $v$ averages about 1000 steps of $g_B^2$; its mean is $g^2+\sigma_\theta^2/B$. That noise term is
  systematic, not random.
- The model therefore uses $m\leftarrow$ EMA of $g$, and $v\leftarrow$ EMA of $g^2+\sigma_\theta^2/B$.
  - $\sigma_\theta^2$ is computed in moment closure, as
    $E_{x_R}\!\left[E(e^2\mid x_R)\,E((\partial f/\partial\theta)^2\mid x_R)\right]-g^2$ for every parameter.
  - The bias corrections, $\beta$'s, $\epsilon$ and the per-layer multipliers are the network's.
- The leftover noise in $m$, a random walk of about $\pm$lr per step, is dropped. Adding it back for the irrelevant
  weights changes nothing (Section 5).

**Consequence.** On a plateau the gradient towards the next feature is far below the noise. Adam is then
preconditioned gradient descent, with step ${\rm lr}\sqrt B\,g_\theta/\sigma_\theta$ per coordinate. Once the signal
dominates, it becomes sign descent at lr per step. So stage durations are set by the per-sample gradient noise, and
that noise scales with the residual. Without the noise term every stage comes too early: the first by 1.4–3.4×, the
later ones by 2.4–6.7× (Section 5).

### 1.4 Width

- The network is muP: its initialisation and multipliers have a width-independent limit. The model uses the same
  parametrisation at width $N$.
- A finite-width effect remains: the model's onsets at $N=32$–64 are 8–13% later than at $N=128$.
- The model's clock is therefore divided by $(128/N)^{0.1}$: 1.072 at $N=64$, 1.103 at 48 and 1.149 at 32. This
  is a uniform rescaling of time. The exponent was measured on the model itself, by comparing its widths
  (Section 3). The correction was introduced after the model's widths had been compared with network onsets.
- With this correction, width 64 matches the networks as well as width 128 does. Widths 64 and 128 score
  0.0049 / 0.086 and 0.0050 / 0.087 on the four $r\le6$ targets.
- So the model runs at width 64, with 6 seeds (`resolution` in [`flow.py`](flow.py)). To stay within the time
  budget it uses 3 seeds for $r=8$, and width 48 or 32 with 2 seeds for $r=9$ or 10. This resolution was picked
  from width-by-seed scores against the calibration networks (Section 3).

### 1.5 Finite $n$: memorisation through the irrelevant inputs

- **Training distribution.** The expected gradient is over the training set: pattern weights $c_p/n$, from the same
  draws as the networks (`nn_train.make_data`, seeds 0–2). Patterns never drawn get weight 0, and $F$ there is the
  model's extrapolation.
- **Memorisation.** A training sample can also be fitted through its own $x_{\rm off}$, which says nothing about any
  other sample.
  - In the tangent-kernel picture with Adam's noise-dominated preconditioner, the diagonal of the kernel restricted
    to the parameters' irrelevant fluctuations gives each sample the rate
    $$\lambda_i=\frac{\rm lr}{n}\sum_\theta{\rm mult}_\theta\,\frac{{\rm Var}(\partial f/\partial\theta\mid x_{R,i})}{\sqrt{v_\theta}} .$$
  - The sum runs over the $d-r$ off-R weights of every first-layer unit, the second-layer weights and the readout.
  - The off-diagonal entries have random sign and do not lower the training loss systematically.
- **One offset per pattern.** All samples of a pattern see the same residual, so one memorised offset per pattern:
  $$\dot\mu_p=-\lambda_p\,(F_p+\mu_p-y_p),$$
  and $F$ is trained on the residual $F+\mu-y$. At test points $\mu$ has no conditional mean: it lives in the
  training samples' own irrelevant coordinates.
- **Capacity.** There are about $n_c=128\,(d-r)$ independent memory directions: the network's off-R first-layer
  weights. When $n$ samples share them, each sample's rate falls: $\lambda\to\lambda/(1+n/n_c)$.
  - For $n\ll n_c$, memorisation is per sample and takes a fixed number of epochs.
  - For $n\gtrsim n_c$, it slows further. This is why $n=16384$ behaves like online.
- **Absorbed noise.** The random irrelevant output of a training sample is part of its residual and is absorbed the
  same way. Its weight in the training loss is $\rho_p=\exp(-\int\lambda_p\,dt)$.

Because $\sqrt{v_\theta}$ tracks the residual, memorisation speeds up as the residual shrinks, and it finishes in
finite time. The training loss follows the networks':

| | step 174 | 350 | 703 | 1413 | 2838 |
|---|---|---|---|---|---|
| sparsepoly, $n=2048$ (model / networks) | .157 / .156 | .110 / .115 | .049 / .056 | .008 / .009 | .000 / .000 |
| sparsepoly, $n=512$ | .062 / .083 | .011 / .016 | .000 / .000 | | |
| mux, $n=2048$ | .301 / .296 | .177 / .177 | .006 / .028 | .000 / .002 | |
| rmaj9, $n=2048$ | .192 / .183 | .153 / .146 | .091 / .070 | .012 / .010 | .000 / .000 |

The model values were corrected on 25 October 2026. The earlier table read the model's statistics one record late:
row $k$ of `run.stats` belongs to recorded step $k+1$. The values above are aligned and interpolated in log-step.
Most entries agree better with the networks than before; rmaj9 at step 703 agrees less well (.091 against .070).

## 2. What the reduced dynamics say about learning

- **A stage is a saddle escape of the reduced network.**
  - On a plateau the function is the network's best fit within the span of its current features; Adam's step there
    is noise-normalised gradient descent.
  - A new feature grows exponentially, at a rate set by its correlation with the residual relative to the
    per-sample noise.
  - It then saturates as the readout refits within the new span. So characters come in **bundles**: a feature
    direction carries many characters, as with mux's $x_4(x_1+x_2+x_3)$ or rmaj9's block features. Coefficients
    **overshoot** whenever the current features are not orthogonal in the character basis; the overshoot relaxes when
    the missing feature arrives.
- **Degree is slow because the irrelevant inputs blur the units.**
  - A smoothed ReLU $g(u)=E\,{\rm relu}(u+z)$ with $z\sim N(0,s^2)$ has derivatives
    $g^{(k)}(b)=(-1)^k s^{1-k}{\rm He}_{k-2}(b/s)\,\varphi(b/s)$ for $k\ge2$.
  - To leading order in $w$, the coefficient of $\chi_S$ in $g(w\cdot x_R+b)$ is
    $g^{(|S|)}(b)\prod_{i\in S}w_i$.
  - So a unit's response to a degree-$k$ character carries a factor $s^{1-k}$, with $s\approx0.9$ at
    initialisation.
  - At zero bias that response vanishes for odd $k\ge3$, since ${\rm He}_{\rm odd}(0)=0$. Odd high-degree characters
    must wait until the biases move, or until the second layer composes them.
  - Degree becomes cheaper as the network shrinks its irrelevant weights, which the variance term
    $E\,{\rm Var}(f\mid x_R)$ pushes it to do, and as $w_R$ grows.
  - Without the irrelevant inputs every stage comes too early: the linear stage by 1.4–2.0×, the later ones by
    2.4–6.7× (Section 5). The $d$-dependence of the timing enters through $s^2\approx(d-r)/d$, the initial alignment
    $\lVert w_R\rVert^2\approx r/d$, and the noise in $v$.
- **Composition is cheaper than a new leap.** A high-degree character on inputs that already carry features is a
  product of existing features, so a second-layer unit can build it. This is why mux's $x_1x_2x_3x_4$ and rmaj9's
  cross-block characters come as one bundle soon after their parts.
- **Finite $n$ is a race.**
  - Every stage still in progress races the absorption of its residual by memorisation. Memorisation takes a fixed
    number of epochs for $n\ll n_c$, and accelerates as the residual shrinks.
  - A stage that has not finished when the residual is absorbed stops part-way. One that has not started never
    starts.
  - Nothing else limits the levels: there is no separate noise floor and no BBP threshold. The partial levels at
    $n=512$ and $2048$ come out of the race.

## 3. Constants and how they were set

| constant | value | how it was set |
|---|---|---|
| $c_{\rm mem}$ | 1 | derived (Section 1.5); bracketed |
| $n_c$ | $c_{\rm cap}\cdot128\,(d-r)$, $c_{\rm cap}=1$ | derived: the network's off-R first-layer weights; bracketed |
| $\beta_W$ | 0.1 | measured on the model, width $N$ against width 128, online, four targets ([`width.py`](width.py)) |

- **The network's hyper-parameters** are not constants of the model and were not fitted. They are lr, $\beta_1$,
  $\beta_2$, $\epsilon$, $B$, the multipliers, $d$ and the step count.
- **The brackets** use [`fit.py`](fit.py) on the finite-$n$ conditions of the four $r\le6$ targets, at width 64 with
  2 seeds (`fit_n64.json`). Online does not depend on $c_{\rm mem}$ or $c_{\rm cap}$.

  | $c_{\rm mem}$, $c_{\rm cap}$ | traj | onset | 2048 | 512 |
  |---|---|---|---|---|
  | **1, 1 (derived)** | **0.0070** | **0.113** | 0.0061 / 0.079 | 0.0125 / 0.222 |
  | 0.75, 1 | 0.0101 | 0.191 | 0.0083 / 0.086 | 0.0195 / 0.451 |
  | 1.25, 1 | 0.0063 | 0.113 | 0.0064 / 0.072 | 0.0100 / 0.229 |
  | 1, 0.5 | 0.0088 | 0.170 | 0.0089 / 0.086 | 0.0150 / 0.385 |
  | 1, 2 | 0.0067 | 0.111 | 0.0063 / 0.072 | 0.0114 / 0.223 |

  The same bracket at width 128 (`fit_n128.json`) gives 0.0067 / 0.119 at the derived values. Two neighbours score
  slightly better than the derived values: $c_{\rm mem}=1.25$ improves traj by 0.0007 with the same onset, and
  $c_{\rm cap}=2$ improves both (0.0067 / 0.111). Both gains are within the noise of 2 seeds, and the derived values
  were kept. The builder's scratch grids, not kept in the repository, also tried $c_{\rm mem}=1.5$ and combinations
  such as $(c_{\rm mem},c_{\rm cap})=(1.5,0.5)$ and $(0.75,2)$, so $c_{\rm mem}$ was bracketed at ×0.75–1.5.
- **Width correction.** Onset ratios of the model at width $N$ to width 128, online, three seeds
  ([`width_dilation.txt`](width_dilation.txt)): ×1.13 at $N=32$, ×1.09 at 48, ×1.08 at 64. That gives $\beta_W$
  between 0.09 and 0.12; 0.1 is used.
  - Width and seed alternatives on the four $r\le6$ targets, all conditions (`fit_w*.json`):

    | width × seeds | traj | onset |
    |---|---|---|
    | 32 × 3 | 0.0066 | 0.096 |
    | 32 × 12 | 0.0063 | 0.093 |
    | 64 × 3 | 0.0051 | 0.092 |
    | **64 × 6** | **0.0049** | **0.086** |
    | 128 × 3 | 0.0050 | 0.087 |

    Width 32 keeps the online fit, but loses accuracy at $n=2048$.
- **Choices made after seeing calibration data.** These are not blind. Each was made while scoring the model
  against the calibration networks.
  - The capacity factor $1/(1+n/n_c)$ was added after the model memorised too much at $n=16384$ and 2048. Its
    constant is the derived one. Its smooth form was chosen over the saturating variant below. Counting only the
    off-R first-layer weights in $n_c$, while the rate $\lambda$ also sums the second-layer and readout terms, is
    itself a choice, so "derived" should be read with that in mind.
  - Changes from the first version of the model:
    - the off-R weights became full vectors $w_{{\rm off},k}$, giving the exact cancellation closure of
      Section 1.2. They replaced a radial off-weight norm $s_k$ with a random-walk update;
    - a "memorising displacement" of the off-R weights was removed;
    - the absorption factor $\rho_p=\exp(-\int\lambda_p\,dt)$ of Section 1.5 was added;
    - the lumping schedule changed from lumping about $t/1000$ Adam steps into one at step $t$ to the 2-step
      lumping below, with variants scored against the networks.
  - The run resolution of Section 1.4 was picked from the width-by-seed scores in the table above. The width
    correction was introduced after the model's widths had been compared with network onsets, although its exponent
    comes from the model alone.
  - Three alternatives were tested and dropped:
    - a memorisation that saturates at the share $n_c/(n+n_c)$ instead of slowing down. It never finishes
      memorising at 2048, whereas the networks do: traj 0.05–0.07 on sparsepoly at $n=2048$, the only case run.
    - an erosion of the memorised offsets, meant to produce the creep at $n=2048$. It wrecks $n=512$: traj
      0.0136 at rate $10^{-4}$ per step, and 0.0079 at $3\cdot10^{-5}$. These rows are in `fit_n128.json`. They were
      run with an earlier version of [`flow.py`](flow.py) that still had the option.
    - pattern subsampling, for larger $r$ (Section 6, item 9).
  - **The count.** No constant is fitted to the networks. Two constants ($c_{\rm mem}$, $c_{\rm cap}$) were
    bracketed against them and left at their derived values. One clock constant ($\beta_W$) was measured model
    against model. About six structural or numerical choices were made with the calibration networks in view: the
    capacity factor and its form, the exact $W_{\rm off}$ closure, the removal of the off-R displacement, the
    absorption factor $\rho$, the lumping schedule, and the width and seed resolution with its width correction.
- **Numerics.**
  - Lumping 2 Adam steps into one after step 600 halves the cost and changes nothing measurable. On mux, exact
    stepping gives the same scores to four decimals, except 0.0047 against 0.0048 at $n=2048$.
  - Lumping more creates artefacts once the network has converged: there $v$ collapses and the lumped step
    overshoots.

## 4. Calibration scores

`python score.py models/flow/preds`:

```
target       cond      traj  onset  final |   zero target
sparsepoly   online   0.001  0.010  0.000 |  0.528  0.427
sparsepoly   16384    0.002  0.025  0.000 |  0.524  0.432
sparsepoly   2048     0.004  0.039  0.005 |  0.429  0.512
sparsepoly   512      0.003  0.022  0.004 |  0.361  0.548
stair5       online   0.001  0.051  0.000 |  0.465  0.504
stair5       16384    0.001  0.029  0.000 |  0.459  0.506
stair5       2048     0.006  0.219  0.010 |  0.335  0.548
stair5       512      0.012  0.095  0.020 |  0.142  0.799
mux          online   0.001  0.028  0.000 |  0.493  0.471
mux          16384    0.001  0.027  0.000 |  0.491  0.472
mux          2048     0.005  0.034  0.022 |  0.414  0.495
mux          512      0.024  0.053  0.048 |  0.152  0.768
majpar       online   0.002  0.023  0.000 |  0.460  0.499
majpar       16384    0.002  0.023  0.000 |  0.456  0.500
majpar       2048     0.006  0.021  0.011 |  0.330  0.582
majpar       512      0.006  0.671  0.006 |  0.121  0.675
rmaj9        online   0.003  0.029  0.000 |  0.523  0.429
rmaj9        16384    0.003  0.027  0.000 |  0.521  0.428
rmaj9        2048     0.008  0.269  0.011 |  0.416  0.508
rmaj9        512      0.008  0.030  0.011 |  0.369  0.575
MEAN traj 0.005  onset 0.086
```

Predicted stages online, from `predict.py`, on the model's own time grid; network onsets (3-seed mean) are in
parentheses. The ranges for majpar, rmaj9 and stair5 were corrected on 25 October 2026 to match the frozen output
over all characters.

- **sparsepoly:**
  - $x_1$ at 58 (56);
  - $x_2x_3$ at 302 (299);
  - $x_1x_2x_3$ at 553 (532);
  - $x_4x_5x_6$ at 1290 (1234), then its products with earlier terms at 1349–1558 (1358–1542).
- **mux:**
  - $x_1,x_2,x_3$ at 58–61 (60–66);
  - $x_ix_4$ at 182–186 (169–176);
  - $x_1x_2x_3$ and $x_1x_2x_3x_4$ at 471–474 (430–452).
- **majpar:** pairs at 195–205 (189–210); the degree-6 term at 1151 (1164).
- **rmaj9:**
  - linear terms at 41–50 (47–55);
  - the 67 characters of degrees 3 to 9, block and cross-block together, at 875–1322 (796–1217): degree 3 at
    875–1160 (855–1085), degrees 5 and 7 at 1119–1322 (1095–1217), and the degree-9 character at 888 (796).
- **stair5:** degree by degree.
  - $x_1$ at 64 (65);
  - degree 2 at 216–288 (188–234);
  - degree 3 at 430–547 (341–703);
  - degrees 4–5 at 523–797 (485–768).
  - The worst character is $x_1x_2x_4$: the model puts it first of degree 3, at 430, and the networks last, at
    703, a miss of 0.21 decades. $x_1x_2x_4x_5$ is last in both, at 797 (768).

The comparison figure is [`fig_traj.png`](fig_traj.png): networks solid, model dashed, the largest characters of
every degree.

## 5. Ablations: what each ingredient does

**Online** ([`ablate.py`](ablate.py)): width 64, 3 seeds, the four $r\le6$ targets.

| variant | traj | onset |
|---|---|---|
| full model | 0.0021 | 0.036 |
| no minibatch noise in Adam's $v$ | 0.0950 | 0.550 |
| no irrelevant inputs ($W_{\rm off}=0$) | 0.0983 | 0.566 |
| linear output variance as if units were independent (no cancellation) | 0.0034 | 0.050 |
| without the higher-Hermite part of the units' variance | 0.0039 | 0.064 |
| with the minibatch random walk of the off-R weights | 0.0022 | 0.039 |

The two noise sources set the clock. Without either one, every stage arrives too early, the later ones by 2.4–6.7×
(onset ratios by character). The exact closure of the output variance matters: without the cancellation traj rises
by 62% and onset by 39%, and without the higher-Hermite part by 86% and 78%. The random walk does not matter.

**Finite $n$** ([`fit.py`](fit.py), `fit_n64.json`): width 64, 2 seeds, the four $r\le6$ targets.

| variant | traj | onset | $n=2048$ | $n=512$ |
|---|---|---|---|---|
| full model | 0.0070 | 0.113 | 0.0061 / 0.079 | 0.0125 / 0.222 |
| no memorisation | 0.0854 | 0.338 | 0.0500 / 0.291 | 0.2038 / 0.685 |
| no capacity limit ($n_c=\infty$) | 0.0081 | 0.138 | 0.0092 / 0.155 | 0.0106 / 0.225 |
| memorisation does not absorb the irrelevant output ($\rho\equiv1$) | 0.0077 | 0.140 | 0.0069 / 0.081 | 0.0137 / 0.303 |

Without the capacity limit, traj at $n=16384$ doubles (0.0046 against 0.0024): the late stages are cut at 0.7–0.8,
while the networks complete them.

## 6. Known failure modes

1. **No creep after memorisation.** Once the training residual is absorbed, the model's function freezes. The
   networks keep learning slowly over 2000–20000 steps:
   - stair5 at $n=2048$, degrees 4–5, from 0.6 to 0.8;
   - mux $x_1x_2x_3x_4$ at $n=2048$, from 0.85 to 0.95;
   - sparsepoly $x_1x_2x_3$ at $n=512$, from 0.05 to 0.15.

   The model's late levels there are 10–20% low. A constant erosion of the memory would produce creep, but it
   destroys $n=512$ (Section 3), so the mechanism is something else, probably the late-phase drift of Adam once $v$
   has decayed.
2. **Third stages at $n=512$ are over-learned.** mux $x_1x_2x_3$ reaches 0.42 and $x_1x_2x_3x_4$ 0.22,
   where the networks reach about 0.05; stair5 $x_1x_2x_3$ reaches 0.29, where they reach 0.08. Memorisation at
   $n=512$ is slightly slow for these, which is the other side of item 1.
3. **Threshold onsets.** When a partly learned stage ends near 1/2 and the model and the networks fall on different
   sides of it, onset charges a full decade. This is most of the onset error: majpar 512 (0.67), rmaj9 2048 (0.27)
   and stair5 2048 (0.22). The trajectories themselves are close (traj 0.006–0.008).
4. **The irrelevant weights at finite $n$.**
   - The networks store memorisation in their off-R weights. Their norm grows from 0.88 to 0.95–1.07 at $n=512$,
     and stays at 0.85–0.98 at 2048.
   - The model stores memorisation in the separate offsets $\mu$. Its off-R weights stay at 0.80–0.85 at
     $n=512$, and shrink to 0.45–0.7 at 2048.
   - So the model does not predict the networks' irrelevant dependence at finite $n$.
   - Online, its off-R weights shrink faster than the networks' after about 1000 steps: 0.43 against 0.61 at step
     2838. This has no visible effect on $F$.
5. **Width for $r\ge9$.** Targets with $r=9$ and $10$ run at width 48 and 32.
   - The clock correction is uniform, while the true finite-width effect varies by about ±15% between stages.
   - The race against memorisation is decided at the reduced width. This is probably behind rmaj9's 2048 onset
     error.
6. **Symmetric targets** (untested; there are no network runs). Parities such as par4 have zero expected gradient at
   the symmetric point. The model breaks the symmetry only through its random initialisation, while the network also
   has minibatch noise in $m$. Escape times for high-order parities could be biased in either direction. The model
   predicts par2, par3 and par4 at 140, 346 and 990 steps online.
7. **Approximations in the closure.**
   - The irrelevant pre-activation is treated as Gaussian, which needs $d-r\gg1$; here it is at least 20.
   - Second-layer noise is treated as independent across units.
   - Residual and gradient factor are treated as independent given $x_R$ in $\sigma_\theta^2$.
   - The memorisation rate uses only the kernel diagonal, with a smooth capacity factor.
8. **Training draws.** For finite $n$ the model uses the same training draws as the networks (`make_data` seeds
   0–2). Held-out networks trained on other draws would differ slightly at $n=512$ for $r\ge9$, where many patterns
   are unseen.
9. **Cost.** The model is limited to $r\le10$ within the time budget. Pattern subsampling, needed for larger $r$, was
   tried at $r=9$. It biased the clock even with a variance correction in $v$: the degree-3 bundle came 6% later
   with a 128-pattern subset, and 14% later with a 64-pattern subset. That path was removed.

## Independent verification (25 October 2026)

An independent verifier rechecked this model after the held-out networks were run.

- **The scores reproduce exactly from the frozen commit 19da14d6.**
  - The verifier re-ran the frozen `predict.py`, single-threaded, on stair5 and rmaj9 (calibration) and on parmaj
    and dnf3 (held out). The output files are bit-identical to the saved ones.
  - Re-scoring every saved calibration and held-out file reproduces `preds/scores.json` and
    `heldout_scores/flow.json` with zero difference: calibration 0.0050 / 0.086, held-out 0.0050 / 0.154.
  - `models/flow`, `analyze_traj.py`, `score.py`, `boolfuncs.py` and `nn_train.py` are unchanged since the freeze.
- **No code path reads network results.**
  - `predict.py` imports only `flow.py` and three helpers from `analyze_traj.py` (`subsets`, `chi_matrix`,
    `first_cross`). `flow.py` imports only `boolfuncs.make_suite`. Neither opens a network trajectory, a results
    file, `nn_summary.json` or a model evaluation.
  - The one data input is the training-set draw, `flow.train_weights`, a reimplementation of
    `nn_train.make_data`. It gives exactly the networks' pattern weights (checked for seeds 0–2 and
    $n=512$, 2048, 16384 on dnf3, parmaj and stair5).
  - Nothing depends on the target except through $r$: `resolution` picks width and seed count from $2^r$ alone, and
    there are no per-target branches or constants.
  - The timeline is consistent. The held-out target list (`run_heldout.sh`, commit 38e79931, 24 October 19:38) was
    fixed before any `flow` code existed (first version 21:33). The freeze commit is at 00:13:54 on 25 October, the
    first held-out network file appeared at 00:14:37, and the held-out predictions were written at 00:15–00:23.
- **This file records no held-out predictions.** Its only forward predictions are for par2, par3 and par4
  (Section 6, item 6), on which no network was run; the frozen code reproduces them exactly (140, 346, 990). The
  pre-registration of the held-out test is the frozen, deterministic code. For parmaj and dnf3 it reproduces the
  saved held-out predictions bit for bit.
- **What was fitted or chosen with the calibration networks in view.** No constant is fitted. Two constants,
  $c_{\rm mem}$ and $c_{\rm cap}$, were bracketed against the networks and left at their derived values. One clock
  constant, $\beta_W$, was measured model against model (0.087–0.115 in `width_dilation.txt`). About six structural
  or numerical choices were made while scoring against the calibration networks (Section 3). Before this check only
  the capacity term, the erosion and the subsampling were disclosed, so "nothing fitted" overstated how blind the
  model is.
- **The held-out targets had been trained before, in the project's earlier fixed-$n$ study.**
  `study/nn_summary.json` and `study/NN-STUDY-TABLES.md` (commit 9fcf27f2, 23 October) hold coarse results for all
  six targets from the same network family: the step at which each character first reaches half its coefficient,
  and the test error by $n$. The model never read that data, and it has no per-target knob such results could have
  tuned. But the held-out targets were not unseen by the project.
- **No run of this model on a held-out target before the freeze was found.** The builder's pre-freeze scratch runs
  are on the calibration targets and on par2–4, thr10 and a dictionary target.
- **Claims corrected in this file.** The verifier found these overclaims and slips, and each is fixed above:
  - the seed-noise comparison was not like for like. The model is below the seed-to-seed spread, but about 1.2–1.7×
    the floor of a perfect predictor of the expected trajectory, not at the noise level (Summary);
  - "no time map" left out the model-measured clock rescaling of 7–15% at reduced width;
  - the constants were bracketed at ×0.75–1.5 ($c_{\rm mem}$) and ×0.5–2 ($c_{\rm cap}$), not ×0.5–2 for both, and
    two neighbours score slightly better than the derived values;
  - the list of choices made with calibration data in view was incomplete (Section 3);
  - the training-loss table read the model one record late (Section 1.5);
  - rmaj9's bundle range covered only 15 of its 67 characters, and the network range did not reproduce;
  - stair5's ranges left out its worst characters, $x_1x_2x_4$ and $x_1x_2x_4x_5$;
  - stale numbers: the third-stage levels at $n=512$ (0.42, 0.22, 0.29) and majpar's degree-6 onset (1151);
  - understatements: the step-function baseline (traj 0.12–0.32, onset 0.20–1.04), the effect of the exact
    variance closure (+39% to +86%), and the early arrival without noise in $v$ or without irrelevant inputs
    (1.4–3.4× for the first stage, 2.4–6.7× for later ones).

  The phenomena the model claims to reproduce check out: the overshoot peaks (1.15 against 1.22, 1.17 against
  1.21, 1.34 against 1.36), online onsets within about 7%, the share of onset error from threshold cases, the
  partial levels at finite $n$, and the creep it fails to reproduce.
- **Held-out outcome, for context.** Held-out traj equals calibration traj (0.0050 against 0.0050). Held-out onset
  is 1.8× worse (0.154 against 0.086). Online it is 0.043 (calibration 0.028). At finite $n$ it degrades: 0.22
  against 0.12 at $n=2048$ and 0.31 against 0.17 at $n=512$. dnf3 at finite $n$ scores 0.68 and 0.83. Like for like,
  the model is 0.61–0.87× the seed-to-seed spread on the held-out targets (Summary).
