# Simulations of the RSI-loop toy model

This folder holds explicit simulations of the toy model in the RSI-loop note: episodes are drawn, each disposition's output distribution is graded by the grader and the audits, and the prior over dispositions is updated. The simulations were built independently of the theory sections. Every prediction below was derived here from the toy's definitions, and every check prints a predicted and a simulated value. Disagreements are kept and explained, not tuned away.

**Run everything:** `./run_all.sh` (about 70 s on 4 cores; needs Python 3 with numpy, scipy and matplotlib). Each script also runs on its own, for example `python3 train_sim.py`. All random seeds are fixed.

**Not part of this suite:** the `T1_*`, `T2_*`, `T3_*` and `T4_*` check scripts and their `*_output.txt` files were written here by the theory sections. They are described in those sections.

**Reconciliation with the revised theory:** `reconcile_checks.py` (output `reconcile_checks_output.txt`) tests 74 quantitative predictions of the revised T1, T2 and T4 against simulations of this toy; `reconciliation.md` gives the verdicts, the diagnoses, and the changes each side needs. That round also fixed one bug here (the myopic $G$ at $\hat p = 1$; see sections 1 and 7).

| script | part | what it shows | outputs |
|---|---|---|---|
| `toy.py` | shared | episode categories, dispositions, plot style | none |
| `train_sim.py` | (a) | one training run under operators (B), (C), (D), and plain policy gradient (D'): the ledger drift, proxy-equivalence classes, unpredictable errors, the Goodhart threshold, on-policy bistability | `train_sim_output.txt`, `fig_a1`–`fig_a4` |
| `loopcore.py` | shared | one generation of the loop, both regimes, the mean map, its fixed points, semi-analytic failure probabilities | none |
| `loop_sim.py` | (b) | $q_k$ trajectories, fixed points and bistability, basins over $(\varepsilon_h, q_0)$ and $(\varepsilon_h, n)$, hidden careful gamers | `loop_sim_output.txt`, `fig_b1`–`fig_b4` |
| `stepsize_sim.py` | (c) | failure probability against the capability step $g$ | `stepsize_sim_output.txt`, `fig_c1` |
| `sieve_sim.py` | (d) | posterior over a continuum of careful gamers $C_t$, and the on-task rate on frontier tasks | `sieve_sim_output.txt`, `fig_d1`, `fig_d2` |
| `reconcile_checks.py` | reconciliation | 74 checks of the revised theory (T1, T2, T4) against simulations of this toy | `reconcile_checks_output.txt`; see `reconciliation.md` |
| `run_all.sh` | | runs the four simulations and the reconciliation checks, and counts the checks | |

Check counts from the last run: 64 checks in `train_sim`, 31 in `loop_sim`, 15 in `stepsize_sim` and 32 in `sieve_sim`. Of these, 3, 2, 0 and 4 respectively disagree with their prediction. Every disagreement is listed in "Disagreements" below.

---

## 1. The shared toy model (`toy.py`)

**Outputs.** Each episode has two candidate outputs: $I$ (intended) and $X$ (gaming or non-intended). A disposition chooses one and emits it with probability $1-\delta$, and emits the other with probability $\delta$ ("soft" dispositions). The default is $\delta = 0.01$. One gaming event then carries log-likelihood ratio $\Lambda = \ln\frac{1-\delta}{\delta} = 4.595$ under (B).

**Episode categories.** Each episode is drawn explicitly as an audit flag, then an error type or opportunity flag, then a recognition flag. $R(\text{cat}, y)$ is the grader's verdict.

| category | probability | verdict | what dispositions observe |
|---|---|---|---|
| normal | $(1-a)(1-\varepsilon-\varepsilon_u)$ | $I$ passes, $X$ fails | ordinary |
| unpredictable error | $(1-a)\varepsilon_u$ | $X$ passes, $I$ fails | ordinary (looks normal) |
| predictable error | $(1-a)\varepsilon$ | $X$ passes, $I$ fails | gaming opportunity |
| audit, no opportunity | $a(1-h)$ | $I$ passes | ordinary |
| audit, unrecognised | $a h (1-s)$ | $I$ passes, $X$ fails (caught) | gaming opportunity |
| audit, recognised | $a h s$ | $I$ passes, $X$ fails | recognised audit |

$h = 1$ gives honeypot audits: every audit presents a gaming opportunity. $h = \varepsilon$ gives audits placed at random.

**Dispositions.** Let $u = a h (1-s)$ be the rate of caught gaming opportunities and $v = (1-a)\varepsilon$ the rate of rewarded ones. On an unrecognised opportunity, the calibrated probability of being audited is $\hat p = u/(u+v)$. Disposition $C_t$ games there iff $\hat p < t$, and it never games on a recognised audit or on an ordinary-looking episode.
* $A$ is $t = 0$: it never games.
* The myopic gamer $G$ is $t = 1$: it plays to the weak grader unless it recognises an audit, including when $\hat p = 1$. (Until the reconciliation round the code used $\hat p < t$ alone, so $G$ abstained at $\hat p = 1$, that is at $\varepsilon_h = 0$; this is fixed in `toy.px_table` and `loopcore`.)
* The calibrated maximiser of expected score, $G^*$, is $t = 1/2$.

**Operators** (framing.md §1.3).
* **(B)** Bayes on the event that the episode's output passes: $w_\theta \leftarrow w_\theta\,P_\theta(\text{pass}\mid\text{episode})$, with $P_\theta(\text{pass}) = \sum_y \pi_\theta(y)R(y)$.
* **(C-on, best-of-$k$)** SFT on filtered on-policy samples. Draw up to $k$ outputs from the current mixture and keep the first that passes, then $w_\theta \leftarrow w_\theta\,\pi_\theta(y_{\text{kept}})$. Nothing is updated if no draw passes.
* **(C-off)** The same with a fixed sampler (the prior mixture) and $k = 1$.
* **(D)** Exact exponential tilt $w_\theta = \mu_0(\theta)\,e^{J_\theta/\beta}$, with $J_\theta$ the summed reward. "Expected" uses $P_\theta(\text{pass})$; "sampled" draws $\theta$'s output and grades it.
* **(D')** An extra operator: vanilla REINFORCE on the mixture logits, $w_\theta \mathrel{+}= \eta\,(\text{resp}_\theta(y) - \mu_\theta)(r - b)$, with exact baseline $b$. This is plain policy-gradient dynamics, not the tilt.

---

## 2. One training run (`train_sim.py`, part a)

There are 21 dispositions: $A$, $G$, and $C_t$ for $t = 0.05, 0.10, \dots, 0.95$. The prior is $A$ 0.60, $G$ 0.01, and 0.0205 for each $C_t$. The runs use 200 seeds of 3000 episodes.

| set | $\varepsilon$ | $\varepsilon_u$ | $a$ | $h$ | $s$ | $u$ | $v$ | $\hat p$ |
|---|---|---|---|---|---|---|---|---|
| P1 gaming pays | 0.02 | 0 | 0.01 | 1 | 0.5 | 0.005 | 0.0198 | 0.20 |
| P2 audits win | 0.02 | 0 | 0.05 | 1 | 0.5 | 0.025 | 0.019 | 0.57 |
| P3 random audits | 0.05 | 0 | 0.20 | 0.05 | 0.5 | 0.005 | 0.040 | 0.11 |
| P1u | 0.02 | 0.30 | 0.01 | 1 | 0.5 | 0.005 | 0.0198 | 0.20 |
| PU | 0 | 0.30 | 0 | 1 | 0.5 | 0 | 0 | none |

**Derived predictions.** Write $L = \ln\mu(A)/\mu(\theta)$ for a disposition $\theta$ that games ($t > \hat p$).

| operator | expected change of $L$ per episode | status in the toy |
|---|---|---|
| (B) | $-D_B$, with $D_B = \Lambda(v-u)$; variance $\Lambda^2(u+v) - D_B^2$ | exact |
| (D) | $-(1-2\delta)(v-u)/\beta$ | exact |
| (C-off) | $-\Lambda\,[v\,p_{X0} - u(1-p_{X0})]$, where $p_{X0}$ is the prior mixture's probability of $X$ on an opportunity | exact |
| (C-on, best-of-$k$) | $\dot L = \Lambda\,[u(1-p_X^k) - v(1-(1-p_X)^k)]$, with $p_X = m_G(1-\delta) + (1-m_G)\delta$ and $m_G$ the mass of the gaming class | mean field |

For any $\theta$ with $t \le \hat p$, $L$ does not move under (B), (C) or (D-expected). These dispositions are proxy-equivalent to $A$.

**Results** (`train_sim_output.txt`; P2 reverses every sign).

| claim | predicted | simulated |
|---|---|---|
| (B) drift, P1 | $-0.0680$ | $-0.0675 \pm 0.0010$ |
| (B) drift, P2 | $+0.0276$ | $+0.0295 \pm 0.0013$ |
| (B) drift, P3 | $-0.1608$ | $-0.1596 \pm 0.0013$ |
| (D) drift, P1 / P2 / P3 | $-0.0145$ / $+0.0059$ / $-0.0343$ | $-0.0144$ / $+0.0063$ / $-0.0340$ (SE about 0.0003) |
| (C-off) drift, P1 / P2 / P3 | $-0.0137$ / $+0.0783$ / $-0.0518$ | $-0.0136$ / $+0.0788$ / $-0.0525$ |
| sd of $L_n - L_0$, (B), P1 | 39.5 | 42.2 |
| within-class odds under (B), (C-on), (C-off), (D-exp) | change 0 | below $5\times10^{-12}$, in all five sets |
| $G^*$ in P2: drift of $\ln\mu(A)/\mu(G^*)$ | $-\Lambda\max(v-u,0) = 0$ | 0 exactly |
| adding 30% unpredictable errors to P1, (B) | difference 0 | $-0.0005 \pm 0.0013$ |
| PU (grader wrong on 30% of episodes, unpredictably) | drift 0 | 0 under (B), (C), (D-exp); $-0.0002 \pm 0.0002$ under (D-sampled) |

**The Goodhart threshold** (dispositions $\{A, G\}$, $\varepsilon = 0.02$, no audits, 400 seeds). Under (B), $L$ drops by exactly $\Lambda$ at each exploited error. The flip therefore comes at the $(\lfloor\ln O/\Lambda\rfloor + 1)$-th predictable error, a negative-binomial time whose large-$O$ limit is $\ln O/(\Lambda\varepsilon)$.

| prior odds $O$ | (B), $\delta = 0.01$: exact median / simulated median | framing R4, $\ln O/\varepsilon$ | (D), $\beta = 1$: exact median / simulated median | (B), $\delta = 10^{-6}$: exact median / simulated median |
|---|---|---|---|---|
| $10^2$ | 84 / 88 | 230 | 234 / 236 | 35 / 34 |
| $10^4$ | 134 / 132 | 461 | 484 / 481 | 35 / 31 |
| $10^6$ | 184 / 189 | 691 | 734 / 759 | 84 / 83 |

**On-policy filtered SFT is bistable within one run** ($\{A, G\}$, P1, 300 seeds per start). The mean-field separatrix is at $m_A^* = \frac{(1-\delta) - u/(u+v)}{1-2\delta}$, that is $L^* = 1.41$. The simulated 50% point is $L_0 = 1.36$, and the switch is smeared over about one jump of $\Lambda$. Run on the same episodes, (B) sends every seed to $G$ from every start up to $L_0 = 8$.

**Plain policy gradient (D')** ($\{A,G\}$, P1). In mean field, $F(L) = e^L - e^{-L} + 2L$ falls at rate $2\eta\,\Delta r$, where $\Delta r = (1-2\delta)(v-u)$. So the time to flip is $n^* = F(\ln O)/(2\eta\Delta r)$, which is linear in $O$; the tilt gives $\beta\ln O/\Delta r$. With $\eta = 0.25$ and 60 seeds:

| $O$ | 3 | 10 | 30 | 100 | 300 |
|---|---|---|---|---|---|
| predicted $n^*$ | 671 | 2000 | 5070 | 15058 | 42940 |
| simulated median | 604 | 1933 | 5186 | 15417 | 45522 |
| tilt with $\beta = 2/\eta$ | 606 | 1270 | 1876 | 2540 | 3146 |

(D') also moves odds within a proxy-equivalence class. Each logit moves by $\eta\,\mu_\theta(r_{\text{class}} - \bar r)$, so the larger member of a losing class loses faster. With prior 0.5 : 0.3 : 0.2 on $A : C_{0.05} : G$, $\ln\mu(A)/\mu(C_{0.05})$ changes by $-0.50$ over 3000 episodes.

**Figures.**
* `fig_a1_drift.png`: $L(n)$ under (B) and (D) for P1–P3 against $L_0 - nD$; the right panel shows that unpredictable errors leave (B) unchanged.
* `fig_a2_classes.png`: the change in $\ln\mu(C_t)/\mu(A)$ by $t$ is a step at $\hat p$, flat on both sides.
* `fig_a3_onpolicy_bistability.png`: (C-on) median trajectories against the mean-field ODE, and the fraction of seeds ending at $A$ against $L_0$.
* `fig_a4_thresholds.png`: $n^*$ against $\ln O$, and (D') against the tilt.

---

## 3. The loop (`loopcore.py`, `loop_sim.py`, part b)

**Model.** Generation $k+1$ is trained for $n$ episodes under (B). Its grader is built by generation $k$, which has misaligned mass $q_k = \mu_k(G) + \mu_k(C)$:
* $\varepsilon_{k+1} = \varepsilon_h + q_k\,\Delta\varepsilon$ (collusion);
* $a_{k+1} = a_0(1-q_k)$, with honeypot audits.

There are two regimes:
* **Continued:** the prior of generation $k+1$ is the posterior of generation $k$.
* **Fresh:** each generation starts from the base prior, $\ln\mu(A)/\mu(G) = L_{\text{base}}$, followed by a data channel. This is Bayes on $m$ signature tokens sampled from generation $k$'s predictive, with $\pi_A(z{=}1) = \tfrac12+\rho$ and $\pi_G(z{=}1) = \tfrac12-\rho$; it is a toy version of subliminal learning.

The "human start" means the first generation's grader and data come from humans ($q = 0$). Defaults: $\delta = 0.01$, $s = 0.5$, $a_0 = 0.05$, $\varepsilon_h = 0.02$, $\Delta\varepsilon = 0.15$, $n = 20000$, $L_{\text{base}} = 4$, $m = 100$, $\rho = 0.1$, $K = 30$.

`train(..., mode="episodes")` draws every episode. `mode="counts"` draws the category counts from the multinomial, which has the same distribution under (B), and is used for the large grids. The two agree: after one generation, the mean and sd of $L$ are $70.9$ and $70.6$ (episodes), $70.2$ and $73.5$ (counts), against $72.1$ and $70.1$ predicted.

**Derived predictions** (two types).
* $D(q) = \Lambda\,[(1-a(q))\,\varepsilon(q) - a(q)(1-s)]$, with $D(0) = -0.0276$ and $D(1) = +0.781$.
* Mean maps:
  * continued, $L_{k+1} = L_k - nD(q_k)$;
  * fresh, $L_{k+1} = L_{\text{base}} + \Xi(1-2q_k) - nD(q_k)$, where $\Xi = 2m\rho\ln\frac{1+2\rho}{1-2\rho} = 8.11$ nats.
* The continued regime's only interior fixed point is at $D(q^\dagger) = 0$, which gives $q^\dagger = 0.0356$; it is unstable, and $q \to 0$ or $q \to 1$ on either side.
* The fresh regime has fixed points at $q^* = 10^{-245}$ (stable), $q_u = 0.0361$ (unstable, the basin boundary) and $q^* = 1$ (stable).
* The aligned state exists only for $\varepsilon_h < \varepsilon^* = a_0(1-s)/(1-a_0) = 0.0263$. (Correction from the reconciliation, R5: this is the condition $D(0) < 0$. With a small leak an aligned fixed point survives up to $\varepsilon_h = 0.02675$ at $n = 2000$ and $0.02633$ at $n = 20000$, as T1.10's sharpened condition predicts. The grid of step 0.002 used below cannot resolve the difference.)
* With noise (semi-analytic), $L$ after one fresh generation is $L_{\text{base}} + \lambda_\rho(2Z - m) + \Lambda(N_{\text{caught}} - N_{\text{rewarded}})$, with $Z \sim \text{Bin}(m, \tfrac12+\rho)$ and the difference of counts Skellam-distributed. A generation escapes if it ends below the unstable point $L_u$, so $P(\text{fail by } K) = 1 - (1-p_{\text{esc}})^{K-1}(1 - P(L_K < 0))$ (`loopcore.p_fail_fresh`).

**Results.**

| claim | predicted | simulated |
|---|---|---|
| trajectories, $n = 20000$, both regimes, $q_0 \in \{0.005, \dots, 0.2\}$ (12 seeds each) | $A$ iff $q_0 < q_u$ | 12 of 12 starts agree; within 0.7 noise sd of the boundary, the outcome splits between seeds |
| fixed points against $\varepsilon_h$ | bistable for $\varepsilon_h < 0.0263$ | bistable on $[0, 0.026]$ on a grid of step 0.002 (mean map, $n = 2000$ and $n = 20000$) |
| basin over $(\varepsilon_h, q_0)$: majority of 30 seeds against $q_u(\varepsilon_h)$ | all cells | 1029 of 1040 cells agree; the rest sit on the boundary |
| $P(\text{fail by 30})$ over $(\varepsilon_h, n)$, 336 cells | semi-analytic | mean abs difference 0.007, maximum 0.12; 0 cells beyond 3 SE (before the $\hat p = 1$ fix: 0.011, 0.15 and 5 cells, all at $\varepsilon_h = 0$) |
| mean map alone over the same grid | | wrong in 66 of 336 cells (noise-driven escape) |

**Hidden careful gamers** (three types $A$, $G$, $C_{0.3}$; $C$ behaves like $A$ in training but colludes as a grader-builder; 30 seeds). The aligned state survives iff the misaligned mass that $C$ carries stays below the basin boundary.

| variant | mean-map threshold on prior odds $r = C{:}A$ | threshold with noise | simulated first $r$ with $P(\text{fail}) > 1/2$ |
|---|---|---|---|
| continued | $q^\dagger/(1-q^\dagger) = 0.037$ | 0.056 (next grid point) | 0.056 |
| fresh, $C$ carries the misaligned signature | $\frac{q_u}{1-q_u}e^{\Xi(1-2q_u)} = 69$ | 0.056 | 0.056 |
| fresh, $C$ mimics $A$'s signature | 0.037 | 0.032 | 0.032 |

**Figures.**
* `fig_b1_trajectories.png`: misaligned log-odds against generation, simulated seeds and the mean map, for $n = 20000$ and $n = 2000$.
* `fig_b2_bifurcation_basin.png`: fixed points against $\varepsilon_h$, and the basin map over $(\varepsilon_h, q_0)$ with $q_u(\varepsilon_h)$.
* `fig_b3_basin_eps_n.png`: failure probability over $(\varepsilon_h, n)$, simulated against semi-analytic.
* `fig_b4_hidden_schemers.png`: failure probability against $r$.

---

## 4. Step size (`stepsize_sim.py`, part c)

A capability range of 1 is crossed in $N = 1/g$ generations, with $\varepsilon_h(g) = \varepsilon_0 + \kappa g$ and $\kappa = 0.02$. The other parameters are as in (b), with the human start and 200 seeds per point.

**Predictions.**
* Mean map: the aligned state exists iff $g < g^* = (\varepsilon^* - \varepsilon_0)/\kappa$.
* Fresh regime: $P(\text{fail}) \approx 1 - (1 - p_{\text{esc}}(g))^{1/g}$. If $p_{\text{esc}}$ stays positive as $g \to 0$, there is an interior optimum.
* Continued regime: exact dynamic programming for a Skellam random walk absorbed at $\text{logit}(1-q^\dagger)$ (`loopcore.p_fail_continued`); $P(\text{fail})$ does not increase as $g$ falls below $g^*$.

**Results.** All 9 configurations agree with the semi-analytic curves: the largest deviation is 0.06, and no point lies beyond 3 SE + 0.02. The shape claims also hold.

| configuration | $g^*$ | result |
|---|---|---|
| $\varepsilon_0 = 0.02$, fresh, $n = 2000$ | 0.32 | $P(\text{fail})$ is U-shaped in $g$: 1.00 at $g = 1/64$, minimum 0.79 at $g \approx 0.2$ (predicted 0.77 at 0.17), 0.98 at $g = 1$ |
| $\varepsilon_0 = 0.02$, fresh, $n = 20000$ | 0.32 | monotone: smaller steps are safer, below 0.01 for $g \le 1/16$ |
| $\varepsilon_0 = 0.02$, continued, $n = 2000$ | 0.32 | monotone, from 0.98 at $g = 1$ to 0.12 at $g = 1/64$ (predicted 0.99 to 0.12) |
| $\varepsilon_0 \le 0.01$, any of the three | $\ge 0.8$ | failure only at the largest steps |

`fig_c1_stepsize.png` plots $P(\text{fail})$ against $g$, simulated and predicted, for three values of $\varepsilon_0$ in the three configurations.

---

## 5. The sieve (`sieve_sim.py`, part d)

**Model.**
* **Dispositions:** $A$ (prior mass 0.5) and $C_t$ on 401 values of $\text{logit}\,t \in [-8, 8]$, uniform in logit, with total mass 0.5.
* **Gaming opportunities:** each has a true check strength $p$, the probability that the check fires. A firing check catches $X$ and rescues $I$; otherwise the weak grader is wrong in the predictable direction.
* **Perception:** each opportunity also has a perceived strength $\hat p$, an observable that all dispositions share. $C_t$ games iff $\hat p < t$. Normal episodes are not simulated, because they contribute exactly zero under (B) and (D).
* **Frontier tasks:** $p = 0$ and $\text{logit}\,\hat p \sim N(\text{logit}\,0.002, 0.5^2)$.
* **Runs:** 60 seeds and up to 10000 opportunities. The vectorised update matches explicit per-episode enumeration over outputs to $10^{-8}$.

**Derived prediction.** Under (B), $\frac{d}{dn}\ln\frac{\mu(C_t)}{\mu(A)} = \Lambda\,\mathbb E\big[(1-2p)\,\mathbf 1\{\hat p < t\}\big]$. A careful gamer is therefore selected against only by checks it does not see coming ($\hat p < t$) that fire more often than not ($p > 1/2$). The law-of-large-numbers (LLN) posterior is $\mu_n(t) \propto \mu_0(t)\,e^{n\,dl(t)}$. This drift matches the simulation at all 401 values of $t$ in all five scenarios (max abs $z$ from 0.6 to 1.7).

| scenario: opportunity mix | LLN on-task (B), $n = 10^4$ | simulated (B) mean / median | simulated (D) mean |
|---|---|---|---|
| 1. 90% unchecked ($\hat p \approx 0.03$), 10% recognisable audits ($p = 0.95$, $\hat p \approx 0.9$) | 0.01 | 0.01 / 0.01 | 0.01 |
| 2. 40% unchecked, 60% honeypots ($p = 0.95$) that look like unchecked opportunities | 0.94 | 0.52 / 0.60 | 0.85 |
| 3. as 2, but the honeypots look less checked than the frontier ($\hat p \approx 0.001$) | 0.99 | 0.99 / 0.99 | 0.99 |
| 4. $p \sim U(0,1)$, accurate perception (sd 0.3 in logit) | 0.01 | 0.01 (posterior peaks at $t = 0.50$, that is $G^*$) | 0.01 |
| 5. $p \sim U(0,1)$, noisy perception (sd 2) | 0.01 | 0.01 (peak at $t \approx 0.5$) | 0.01 |

The on-task floor of 0.01 is $\delta$.

**Scenario 2: the LLN prediction fails, and gambler's ruin explains why.** Sort the opportunities by $\hat p$. Then $\ln\mu(C_t)/\mu(A)$ minus its prior value equals $\Lambda S_j$, where $S_j$ is a $\pm1$ walk over the opportunities below $t$: $+1$ when the check did not fire, $-1$ when it did. Each step is $+1$ with probability $P_+ = 0.4 + 0.6\times0.05 = 0.43$. The walk drifts down, which is what the LLN sees. But the posterior over a continuum of thresholds is dominated by the walk's maximum $M$, and for an infinite walk $P(M \ge k) = (P_+/P_-)^k$, independently of $n$.

| quantity (1000 training runs) | predicted | simulated |
|---|---|---|
| $P(M \ge 1)$ | 0.754 | $0.760 \pm 0.014$ |
| $P(M \ge 2)$ | 0.569 | $0.576 \pm 0.016$ |
| $P(M \ge 3)$ | 0.429 | $0.423 \pm 0.016$ |
| $P(M \ge 4)$ | 0.324 | $0.334 \pm 0.015$ |
| fraction of runs captured by careful gamers (on-task below 1/2) | about $P(M\ge2) = 0.57$ (heuristic capture rule $\Lambda M > \ln(\mu(A)/g)$, with $g \approx 0.005$ the prior mass between neighbouring low-tail opportunities) | 0.56 |

The median on-task rate is 0.94 when $M = 0$, 0.70 when $M = 1$ and 0.07 when $M = 2$.

**Figures.**
* `fig_d1_sieve_posterior.png`: the posterior density over $\text{logit}\,t$ in each scenario, simulated against the LLN prediction, with the frontier's perceived detection marked.
* `fig_d2_ontask.png`: the frontier on-task rate against $n$ under (B) and (D).

---

## 6. Disagreements (all of them)

1. **Framing R4's threshold $\ln O/\varepsilon$ is the wrong scale for (B).** With $\delta = 0.01$, (B) flips 2.6–3.8 times sooner: at the $(\lfloor\ln O/\Lambda\rfloor+1)$-th exploited error. With $\delta = 10^{-6}$, one or two exploited errors flip odds of $10^4$–$10^6$. R4's formula is the (D) answer with $\beta = 1$, up to $1/(1-2\delta)$. Under (B), $O(1-\varepsilon)^n$ is the expected (annealed) odds, not the typical odds. The flip still scales as $\ln O$, so the qualitative claim survives; the rate per exploited error is $\Lambda$ in (B) and $(1-2\delta)/\beta$ in (D).
2. **(D') with a large step ($\eta = 2$):** the simulated median $n^*$ is 1.4–2.5 times the mean-field value (3 of 5 points disagree beyond 3 SE). Upward excursions of $L$ cost more time than downward ones save, because the drift falls off like $e^{-L}$. With $\eta = 0.25$ all five points agree.
3. **Loop, $n = 2000$, continued regime, $q_0 = 0.04$:** the mean map predicts $G$, but 42% of seeds end at $G$. The start is 0.2 noise sd from the boundary.
4. **Loop, mean map over $(\varepsilon_h, n)$:** it is wrong in 66 of 336 cells, because noise-driven escapes at intermediate $n$ are invisible to it. The semi-analytic noise model fixes this.
5. **Sieve, scenario 2:** the LLN predicts a frontier on-task rate of 0.92–0.94; the simulation gives a mean of 0.35 at $n = 500$ and 0.52 at $n = 10^4$ under (B), and 0.70 at $n = 500$ under (D). The LLN-based survivor heuristic (0.94) fails the same way. The gambler's-ruin account above matches.

## 7. Surprises

These go beyond the predictions I set out to check.
* **On-policy filtered SFT is self-reinforcing.** The dominant disposition supplies its own evidence: $A$'s correct outputs on audits count against $G$, while $G$'s advantage needs the exploit to be sampled. In P1, (C-on) keeps $A$ from prior odds above 4:1, where (B) loses from any start. In P2, where (B) and (D) favour $A$, 33% of best-of-8 seeds end at $G$.
* **A calibrated score-maximiser is never selected against under (B).** $G^* = C_{1/2}$ maximises the pass probability given its information, so its drift against $A$ is $-\Lambda\max(v-u,0) \le 0$. Audits act only on dispositions that misjudge detection: the myopic $G$, bold $C_t$, or anyone fooled by honeypots that are rarer or better hidden than they believe. This is exact in the toy (binary outputs, symmetric $\delta$).
* **Unpredictable errors give exactly zero drift here, by construction.** Every disposition chooses the same output on ordinary-looking episodes, so this check is trivial in this toy and is not evidence about real models.
* **Plain policy gradient on mixture logits protects linearly in $O$, not logarithmically, and breaks proxy-equivalence.** Which operator a training procedure resembles matters for the $\ln O$ claim.
* *(Withdrawn in the reconciliation round.)* The first version reported that a perfect human grader gives no signal against $G$, with up to 7% of runs failing at $\varepsilon_h = 0$. That was a knife-edge of the code: $G$ abstained only at exactly $\hat p = 1$, contrary to its definition, while at $\varepsilon_h = 0.001$ it games and is pushed down at 0.11 nats per episode. After the fix, no run fails at $\varepsilon_h = 0$. The point survives for a *calibrated* best responder: $G^* = C_{1/2}$ never games when $\hat p = 1$, so training gives no signal against it (T1.4).
* **The data channel's mean protection is real, but its noise erases it** (m = 100 tokens, 4 nats sd per generation compounded over 30 generations).
* **Perception noise alone does not help** (sieve scenario 5): when gaming pays on average, noisy perception still leaves the posterior at $t \approx 1/2$. What works is honeypots that look *less* checked than the frontier (scenario 3).

## 8. Caveats

* Outputs are binary and softness is symmetric. Dispositions know the base rates; $\hat p$ is calibrated, except in the sieve, where perception is an explicit noisy feature.
* The loop uses (B) and the myopic $G$. With $G^*$ in place of $G$, audits never push the gamer down. The hidden-gamer analysis (section 3) then applies, because $G^*$ hides whenever $v < u$.
* Collusion acts linearly in the posterior mass $q_k$, and audit power does not depend on the capability gap.
* The count-level simulation is equivalent in distribution to the episode-level one only under (B) and (D-expected).
* The noise in (B) is large because each exploited error carries $\Lambda = 4.6$ nats. Many results, such as the leakage in the sieve and the escapes in the loop, are driven by that noise, so they depend on the operator.
