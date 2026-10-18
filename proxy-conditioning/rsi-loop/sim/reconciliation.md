# Reconciliation: the simulations against the revised theory

*18 October 2026. Compares the simulation suite in this folder (`toy.py`, `train_sim.py`, `loopcore.py`, `loop_sim.py`, `stepsize_sim.py`, `sieve_sim.py`) with the revised theory sections `drafts/T1-ledger.md`, `drafts/T2-sieve.md` and `drafts/T4-protocols.md`. New checks are in [`reconcile_checks.py`](reconcile_checks.py), output in [`reconcile_checks_output.txt`](reconcile_checks_output.txt): 74 checks in sections R1 to R14, about 30 s. Section numbers such as T1.7q refer to the theory drafts; R-numbers refer to the sections of the check script.*

## Summary

* **Most of the revised theory survives contact with the simulation, often to three digits.** The lattice-ledger results of T1.6 (ever-flip probability $(v/u)^m$, Skellam tails), the best-responder drift under binormal recognition and the "audits built from real opportunities" design (T1.4c), the competence axis (T1.1b), the sharpened existence condition for an aligned fixed point under leakage (T1.10, to six digits), the Gaussian hazard of T1.10s (within 10% of the simulated escape rate), the regime (i) collapse probability of 0.13, the T1.11 time to failure, the T4.5 and T4.7 numbers under their own assumptions, and the whole T4.18 loop table all agree.
* **The simulation had one bug, now fixed.** The myopic gamer $G$ abstained when the calibrated detection probability was exactly 1, which happens at $\varepsilon_h = 0$. This contradicted $G$'s definition (README, T1 §0). It produced all five cells of the $(\varepsilon_h, n)$ grid that disagreed with the semi-analytic model beyond 3 SE, and a spurious "surprise" (a perfect human grader gives no signal against $G$). After the fix, 0 cells disagree and the surprise is withdrawn.
* **Four places where the theory must change:**
  1. **T1.7q (quenched builders) leaves out training noise.** With operator (B) noise, the failure probability in T1's worked example is 0.29 at $L_0 = 3$, not 0.047, and 0.11 at odds of $10^6$, not $10^{-6}$. With noise, the quenched reading is *less* pessimistic than the annealed one at every $L_0$ tested. T1's statement that the annealed map is "optimistic above $L^\dagger$" does not survive.
  2. **T1's step-size takeaway ("without overhead, smaller steps are safer in the continued regime") fails under T1.12's own budget assumption** ($n = g/r$, a fixed total number of episodes). With noise, the continued regime has an interior optimum too. Each generation boundary is a point at which the collusion feedback can act on a transient dip of the same event walk. As $g \to 0$, $P(\text{fail})$ tends to the probability that the walk *ever* dips below $L^\dagger$, not to the probability that it ends there.
  3. **T2.3's mean-field posterior misses rarely triggered gamers.** When careful gamers condition on a feature that carries no information about detection, as in sieve scenario 2, the types whose gaming region has small training probability see only a few decisive events. The posterior over them follows the *maximum* of a walk, not its drift. A run is captured with probability about $(P_+/P_-)^{\lceil x/\lambda\rceil}$, independent of $n$ and exponentially small in $1/\lambda$, where $\lambda$ is the evidence per event (heuristic; it matches within a factor 1.5 for six values of $\lambda$). T2.5(3)'s achievability claim for pooled audits needs this caveat.
  4. **T4.5 and T4.7 under (B) assume that the verifier flips a fresh coin on every evaluation.** If instead each episode fixes whether the flag is accepted, the protocol cuts the (B) drift 3.8-fold, not 9.4-fold, and T4.7's sign flip moves from $s = 0.966$ to $0.914$. T1's weak-grader (B) row rests on the same assumption. The (D) results are unaffected.
* **Two smaller theory refinements.**
  * T2 Example 1 under per-episode (D) flips 7% earlier than the exact-tilt posterior, and single runs spread widely.
  * T1.9's band condition does not cover regime (ii) when the data channel discriminates the band. There, the channel's noise, not its mean, sets the threshold. A closed form is given in §3.7.
* **One statement in the simulation README needed correcting.** The aligned state does not exist "only for $\varepsilon_h < \varepsilon^*$": T1.10's leak condition extends it to 0.02675 at $n = 2000$.

---

## 1. Status of the simulation's original disagreements under the revised theory

| original disagreement (README §6) | revised theory | status |
|---|---|---|
| 1. framing R4's $\ln O/\varepsilon$ is the wrong scale for (B) | T1 §1.2 adopts the erratum: $\lambda_+ = \Lambda$ per exploited error under (B), and the threshold is $\ln O/(\varepsilon\lambda_+)$ | resolved. One residual point: that is the *deterministic* crossing. The realised flip is the $m$-th exploited error, $m = \lfloor \ln O/\Lambda\rfloor + 1$, a negative-binomial time with medians 84, 134 and 184 for $O = 10^2, 10^4, 10^6$, against 50, 100 and 150 from $\ln O/(\varepsilon\Lambda)$. T1.6(2) covers this through Wald's overshoot; the §1.2 cross-reference should say "deterministic". |
| 2. (D') with a large step | no theory section claims anything about (D') | open; outside the theory |
| 3. loop, $n = 2000$, continued, $q_0 = 0.04$ | T1.10s: the deterministic map is valid only when $n(u-v)^2/(u+v) \gg 1$. That quantity is 1.6 even at $q = 0$, and close to 0 near the boundary, where the drift vanishes | explained by the theory |
| 4. mean map wrong in 66 of 336 cells | T1.10s: metastability and the hazard $\Phi(-z)$ | explained; R6 confirms that $\Phi(-z)$ matches the simulated escape rate within 10% |
| 5. sieve scenario 2, LLN posterior fails | T2.3 has a mean-field condition, but it is stated at $t^\star$, and $D^\star = 0$ in this scenario | **not resolved by the revision**; see §3.4 |

The simulation's surprises line up with the revision as follows:
* (C-on) bistability is now T1's $t^\star = \pi_X$.
* The non-selection of $G^\star$ is now T1.4.
* The noise-driven escapes are now T1.10s.
* The data channel's noise is not yet in T1.9 (§3.7).

---

## 2. Predictions confirmed

All values are from `reconcile_checks_output.txt`. "Pred." means the theory's formula evaluated at the simulation's parameters.

| theory claim | where | predicted | simulated |
|---|---|---|---|
| T1.6(3): ever-flip probability under (B) is exactly $(v/u)^m$, $m = \lfloor L_0/\Lambda\rfloor + 1$; P2 of `train_sim`, $L_0 = \ln 10^6$ | R1 | 0.3336 | $0.3310 \pm 0.0061$ (explicit episodes) |
| same, T1 honeypot example | R1 | 0.1749 | $0.1738 \pm 0.0049$ |
| T1.6(4): $P(L_{500} < 0)$ and $P(L_{500} < L^\dagger)$, Skellam tails | R1 | 0.0377; 0.0685 | 0.0367; 0.0647 (SE 0.003) |
| T1 §1.2, (C-on) row, read as an exact lattice chain (steps $\pm\Lambda$ or 0, with state-dependent probabilities $v(1-(1-\pi_X)^k)$ and $u(1-\pi_X^k)$) | R2 | P1, $k = 1$, fraction ending at $A$ for 13 starting values $L_0$ | max $\lvert z\rvert$ 2.8; mean abs difference 0.016 |
| same, 21 dispositions, P1, P2, P3, P1u, $k = 1, 8$ | R2 | 0.336, 0.146, 0.864, 0.702, 0.163, 0.038, 0.336, 0.146 | 0.315, 0.160, 0.895, 0.670, 0.190, 0.025, 0.335, 0.115 |
| T1.10s table, regime (i), $L_0 = \ln 10^6$, $n = 500$: $P(L < -20)$ by generations 1, 5, 10, 20, 50, recomputed with `loopcore` (independent code) | R4 | 0.0018, 0.123, 0.132, 0.133, 0.133 | 0.0014, 0.121, 0.130, 0.130, 0.130 |
| T1.10, sharpened existence condition with leakage, adapted to the bounded channel: aligned fixed point iff $L_b + \Xi - nD_0 \ge 1 + \ln(2\Xi + nD_1)$ | R5 | largest $\varepsilon_h$ = 0.026746 ($n = 2000$), 0.026332 ($n = 20000$) | 0.026746, 0.026332 (bisection on the exact map) |
| T1.10s: hazard $\Phi(-z)$, with $\eta = 0$, anchor $L_b + \Xi$ and separatrix $L_u$, in 5 $(\varepsilon_h, n)$ cells | R6 | 0.069, 0.016, 0.020, 0.008, 0.205 | 0.069, 0.014, 0.020, 0.009, 0.205 |
| T1.11: time to failure with a leak ($\varepsilon_h = 0.03$, $nD_0 = 32$ nats per generation), $L_0 = 50, 100, 200$ | R7 | first generation below 0: 2, 3, 7 (ODE); discrete map 2, 4, 7 | means 2.6, 4.1, 7.3; medians 2, 3, 6 |
| T1.1b: competence axis, $\varepsilon_u = 0.05$, (B) and (D) drifts at $\delta_S = 0.02, 0.05, 0.1, 0.2$ | R9 | (B) $+0.025, +0.041, +0.025, -0.053$ | the same to $\pm 0.0006$; (D) exact |
| T1.1b: (B) selects softness $\delta = \varepsilon_u$ | R9 | mode at 0.05 | 0.05 in 93% of seeds, otherwise a neighbour |
| T1.4c: $G^\star$ drift under binormal recognition, AUC 0.70, 0.83, 0.95 | R10 | $+0.00154, +0.01041, +0.02663$ | $+0.00157, +0.01042, +0.02681$ |
| T1.4c design: audits drawn partly from the real-opportunity distribution, $c = 0.2$ and $0.5$ | R10 | $+0.0019$; exactly 0 | $+0.0021 \pm 0.0001$; exactly 0 |
| T2.3, (B): "the flip is a random event"; at $n = 43$ the interquartile range of $P_{\rm on}$ spans about 0.01 to 0.99 | R11 | 0.01 to 0.99 (for $A$ against $C_{t^\star}$) | 0.014 to 0.949 on the full continuum |
| T4.5: (B) drift with flags (fresh-coin verifier) | R13 | 0.00973 | $0.00966 \pm 0.00004$ |
| T4.7: sign of the naive gamer's drift under (B) at $s = 0.95$ and $0.98$ (flip at 0.966) | R13 | $-0.00218$, $+0.00196$ | $-0.00225$, $+0.00196$ |
| T4.18: scenarios S0 to S3 ($q^\dagger_0$, first leaking generation, $L_{13}$, $L_{200}$) | R14 | 0.083, 1, fails at 3, fails / 0.405, 11, 40.4, 38.7 / 0.405, 5, fails at 12, fails / 0.405, none, 48.6, 49.6 | identical (48.55 and 49.61 before rounding) |
| T4.18 with (D) event noise ($\lambda = 0.05$, $n = 20000$) | R14 | noise negligible away from the separatrix | from $L_0 \ge 1$: no failures in 2000 runs, final sd about 2 nats. From $L_0 = 0.5$, 0.1 nats above $L^\dagger$: 30% fail |
| T1.9: band threshold $\varphi/(1+\varphi) < q^\dagger$, continued regime | `loop_sim` | $r^\star = 0.037$ | first grid point failing: 0.056 (the next grid point) |
| T1.10, bounded channel: aligned fixed point $\approx L_b + \Xi + n\lvert D(0)\rvert$ | `loop_sim` | $4 + 8.11 + 551.4 = 563.5$ | 563.5 |

Two remarks on the agreement:
* **R6 is better than T1 claims for its own example.** In T1's linear-channel example the Gaussian overstated the hazard (0.09 against 0.062). In the simulation's fresh regime $\eta = 0$, each generation is a single Skellam draw with a large mean, and the Gaussian is within 10%. The data channel's variance (sd 4 nats) is negligible next to the training noise ($\Lambda\sqrt{nw} = 43$ nats at $n = 2000$).
* **R2 turns the simulation's "agrees: YES (majority outcome)" into quantitative agreement.** The mean-field separatrix gives only the majority. The lattice chain gives the minority fraction too, for example the 33% of P2 best-of-8 runs that end at $G$ (chain: 30%). This is the (C-on) analogue of T1.6(3). The first decisive event decides most runs: a rewarded opportunity drops $L$ by $\Lambda$, and if that takes the class log-odds below the separatrix, the run entrenches.

---

## 3. Disagreements, with diagnoses

### 3.1 Simulation bug: the myopic gamer at $\hat p = 1$ (fixed)

**What was wrong.** `toy.px_table` and `loopcore.loglik_table` let $C_t$ game iff $\hat p < t$. For $G$ ($t = 1$) that fails exactly when $\hat p = 1$, which is the case $\varepsilon_h = 0$ with honeypot audits. Two things are inconsistent with this:
* the README and T1 §0 both define $G$ as gaming "unless it recognises an audit";
* the simulation's own semi-analytic model (`p_below_fresh`) already assumed that $G$ games.

The simulated cells at $\varepsilon_h = 0$ therefore failed in 3% to 7% of runs, while the model predicted 0. These were the 5 cells beyond 3 SE. The README's surprise "a perfect human grader gives no signal against $G$" came from this knife edge: at $\varepsilon_h = 0.001$, $\hat p = 0.96$ and $G$ is pushed down at 0.11 nats per episode.

**Fix.** $t \ge 1$ now games on every unrecognised opportunity (`toy.px_table`, `loopcore.loglik_table`, `loopcore.mean_map_L`), and the classification in `train_sim.py` line 175 matches.

**Re-run.**
* `train_sim`: unchanged except the PU set, where $G$ is now listed as a gaming disposition. PU has no opportunities, so nothing moves.
* `loop_sim`: the grid comparison goes from (max 0.150, mean 0.011, 5 cells beyond 3 SE) to (0.124, 0.007, 0), and $P(\text{fail})$ at $\varepsilon_h = 0$ is now 0 for $n \ge 1000$.
* `stepsize_sim`: unchanged, since $\varepsilon_h(g) > 0$ there.

The README is updated. What survives of the withdrawn surprise is the statement for the *calibrated* best responder: $G^\star$ never games at $\hat p = 1$, so training gives no signal against it. That is T1.4.

### 3.2 T1.7q needs training noise (theory change)

T1.7q evaluates $P(\text{fail}) = 1 - \prod_k\big(1 - \sigma(-L_k)\big)$ along the deterministic ledger $L_k = L_0 + kn\lvert D(0)\rvert$. Under (B), the ledger after each all-$A$ generation is $L_k = L_{k-1} + \Lambda(N_c - N_r)$, with sd 16 nats per generation in the worked example, against a drift of 12. R3, with 200,000 runs of multinomial episode counts:

| $L_0$ | T1.7q (noise-free) | quenched, with (B) noise | annealed, with the same noise ($L < -20$ by generation 40) |
|---|---|---|---|
| 1.0 | 0.269 | 0.479 | 0.953 |
| 2.0 | 0.119 | 0.357 | 0.683 |
| 2.4 | 0.083 | 0.325 | 0.558 |
| 3.0 | 0.047 | 0.293 | 0.431 |
| 13.8 | $1.0\times10^{-6}$ | 0.111 | 0.131 |

**Diagnosis: the theory is wrong (its formula is correct but incomplete).** $P(\text{fail}) = 1 - \mathbb E\prod_k\big(1 - \sigma(-L_k)\big)$, with $L_k$ the lattice walk of T1.6. Because $\sigma(-L)$ is convex for $L > 0$, noise raises $\mathbb E\,\sigma(-L_k)$ above $\sigma(-\mathbb E L_k)$ while the ledger is positive. Here the effect is large. Most of the gap comes from the first two generations, where a single rewarded event costs $\Lambda = 4.6$ nats.

**What T1 must change.**
* Replace the T1.7q table with the noisy values, or give both.
* Compute the expectation by dynamic programming over the lattice (the same convolution as `loopcore.p_fail_continued`).
* Drop the sentence "the annealed map is optimistic above $L^\dagger$ and pessimistic below it". With noise, the annealed reading is the more pessimistic one at every $L_0$ in the table. At high $L_0$ the two readings nearly agree (0.11 against 0.13), because both are driven by the probability that the ledger dips early.
* The qualitative point of T1.7q stays: there is no sharp separatrix in the quenched reading. With noise there is none in the annealed reading either.

### 3.3 Step size under a fixed episode budget (theory change)

`stepsize_sim` holds $n$ fixed per generation, while T1.12 assumes $n = g/r$, so that the total number of episodes over the range is fixed. R8 reruns the simulation's step-size experiment with $n(g) = 4g\,n_{\rm ref}$, which equals $n_{\rm ref}$ at $g = 1/4$. The semi-analytic models match the new simulations: max $\lvert z\rvert$ 2.1 in the fresh regime and 1.7 in the continued regime.

| $g$ | 1 | 1/2 | 1/4 | 1/8 | 1/16 | 1/32 | 1/64 |
|---|---|---|---|---|---|---|---|
| fresh, $n_{\rm ref} = 20000$, fixed $n$ | 1.00 | 1.00 | 0.58 | 0.057 | 0.009 | 0.004 | 0.003 |
| fresh, $n_{\rm ref} = 20000$, $n \propto g$ | 1.00 | 1.00 | 0.58 | **0.27** | 0.50 | 0.91 | 1.00 |
| continued, $n_{\rm ref} = 2000$, $n \propto g$, $L_b = 4$ (exact DP) | 1.00 | 0.94 | 0.59 | **0.41** | 0.43 | 0.50 | 0.58 |
| continued, $n_{\rm ref} = 2000$, $n \propto g$, $L_b = 10$ (exact DP) | 1.00 | 0.92 | 0.52 | 0.37 | **0.36** | 0.41 | 0.46 |

**Diagnosis: the theory is wrong for its own budget assumption once noise is included.** T1.12(4) correctly says that smaller steps are better *in the deterministic map*, but takeaway 9 drops that qualifier. There are two mechanisms, both heuristic, with the simulation as evidence.
* **Fresh regime.** The per-generation SNR of T1.10s is $z \propto \sqrt n = \sqrt{g/r}$. So $P(\text{fail}) \approx 1 - (1 - \Phi(-c\sqrt g))^{1/g} \to 1$ as $g \to 0$, however large the total budget. The interior optimum exists even where the fixed-$n$ experiment was monotone.
* **Continued regime.** With $n \propto g$, the walk of decisive events over the whole range has the same law for every $g$, apart from the slow change in $\varepsilon_h(g)$. The collusion feedback acts at generation boundaries: once $L$ ends a generation below $L^\dagger$, the next grader is lenient and the run collapses. More boundaries mean that the barrier is checked more often. As $g \to 0$, $P(\text{fail})$ tends to the probability that the event walk *ever* dips below $L^\dagger$ during the range, the gambler's-ruin quantity of T1.6(3), and not to the probability that it ends below $L^\dagger$. That ever-dip probability is 0.46 to 0.58 here.

**What T1 must change.**
* Takeaway 9 and the paragraph "Where the optimum comes from" should say that, with noise and a fixed budget, noise acts as a per-generation overhead $\psi(g)$ that *grows* as $g$ shrinks, in both regimes.
* The optimum step then balances the deterministic term $d_1 g$ against this noise term, not only against a fixed $\psi$.
* A short worked statement suffices: fresh regime, $g^\star$ where $\frac{d}{dg}\big[(1/g)\,\Phi(-c\sqrt g)\big]$ balances the growth of $\varepsilon_h(g)$; continued regime, $P(\text{fail}) \to$ the ever-dip probability as $g \to 0$.

A practical reading for the loop: a grader rebuilt too often, each time by a generation trained on few episodes, gives collusion more chances to lock in a noise-driven dip.

### 3.4 Rarely triggered careful gamers: where the sieve's mean field fails (theory change)

Sieve scenario 2 has honeypots that are indistinguishable from real opportunities. The student's perceived detection is a noise feature (logit-normal, sd 0.5) that is independent of the true check. In T2's calibrated coordinates this is pooling: $\hat p = 0.57 > t^\star = 1/2$ everywhere. Every thresholded type has negative expected drift, except the regions of feature space with zero training mass, which are frozen. That is T2 Remark 0.1's proxy-equivalence: the frontier feature, logit 0.002, has training mass $2\times10^{-8}$.

So the LLN on-task rate of 0.94 is T2's prediction, and the simulation gives a mean of 0.52 under (B).

**Diagnosis: the theory is incomplete.** T2.3 states its mean-field condition at $t^\star$, through $n \gg w\,\mathbb E\ell^2/D^{\star2}$, and $D^\star = 0$ here. The condition has to hold *for every type with non-negligible prior mass*. A type whose gaming region has training probability $\pi_\theta$ sees about $n\pi_\theta$ decisive events. Types near the low tail of the feature have $n\pi_\theta = O(1)$ for every $n$. Their log-weights form one $\pm\lambda$ walk indexed by the sorted opportunities, and the posterior picks out the walk's maximum.

The simulation section's gambler's-ruin account generalises to any per-event evidence $\lambda$ (heuristic). Define:
* $P_\pm$, the probability that a decisive event in the low tail is uncaught or caught (here $P_+ = 0.43$);
* $g$, the prior mass between neighbouring low-tail opportunities;
* $x = \ln(\mu_0(A)/g)$.

Then
$$P(\text{capture}) \approx (P_+/P_-)^{\lceil x/\lambda\rceil},\qquad\text{independent of } n.$$

R12, with $x = 4.92$ and 600 runs at $n = 10^4$:

| operator | $\lambda$ | predicted | simulated, $n = 10^3$ | simulated, $n = 10^4$ |
|---|---|---|---|---|
| (B) | 4.60 | 0.569 | 0.563 | 0.543 |
| (D), $\beta = 0.25$ | 3.92 | 0.569 | 0.498 | 0.497 |
| (D), $\beta = 0.5$ | 1.96 | 0.429 | 0.348 | 0.312 |
| (D), $\beta = 1$ | 0.98 | 0.184 | 0.160 | 0.110 |
| (D), $\beta = 2$ | 0.49 | 0.045 | 0.042 | 0.030 |
| (D), $\beta = 4$ | 0.245 | 0.003 | 0.003 | 0.000 |

The law gets the scale and the exponential suppression in $1/\lambda$ right to within a factor 1.5. The slow decline with $n$ comes from $g$ shrinking as the low tail fills in.

**What T2 must change.**
1. Restate the mean-field condition of T2.3 per type: $n\pi_\theta\,(\mathbb E\ell_\theta)^2/\mathrm{Var}\,\ell_\theta \gg 1$ for every type that carries prior mass. Say that it always fails for types whose gaming region sits in the low tail of a feature the student conditions on.
2. Add the capture law above as a heuristic proposition. The rigorous ingredient is $P(M \ge k) = (P_+/P_-)^k$ for the walk's maximum.
3. Qualify T2.5(3), the achievability of the fixed-type ceiling by pooled audits. It holds under S4d. Under per-episode updates with evidence $\lambda$ per event, a fraction of runs about $(P_+/P_-)^{\lceil x/\lambda\rceil}$ is captured by a lucky rarely triggered type, and more training does not remove it.

**Reading for the loop.** Gamers that defect only on inputs that look extremely unwatched are exactly the types this failure concerns, and sleeper-agent triggers are of this kind. Coarse per-event evidence ((B), rejection sampling, sharp policies) makes the sieve fail on them by luck. Soft evidence (small $\lambda$) suppresses the failure exponentially. This is a concrete reason to prefer low-evidence-per-event operators, beyond T1's SNR argument.

**Scenario 3 is consistent with T2.5 once $d_F$ is computed in calibrated coordinates.** There the honeypots occupy the frontier's region of feature space. A calibrated student that sees the frontier feature infers $P(\text{honeypot}) = 1.000$, so $d_F = 0.95 > t^\star$, and T2.5 places no restriction on the on-task rate: the simulation gives 0.99. The raw "perceived $\hat p$" of `sieve_sim` is a feature, not T2's $\hat p$. The fixed-threshold ceiling of T2.5(1) is stated in calibrated coordinates and does not apply to raw-feature thresholds (T2 Remark 0.1 says so). The design lesson, "put honeypots where the frontier lives in the student's feature space", is T1.4c's pointwise condition applied at the frontier, and T2 could state it as such.

### 3.5 T2 Example 1 under per-episode (D): timing shift and spread (refinement)

T2.3 claims that under per-episode (D) "the mean-field picture is adequate". R11 simulates Example 1 on a 4000-point continuum, with 200 runs.

| $n$ | exact-tilt (S4d) $P_{\rm on}$ | per-episode mean | median | interquartile range |
|---|---|---|---|---|
| 1000 | 0.989 | 0.982 | 0.987 | 0.979 to 0.991 |
| 2000 | 0.977 | 0.956 | 0.974 | 0.949 to 0.985 |
| 5000 | 0.741 | 0.605 | 0.653 | 0.418 to 0.836 |
| 10000 | 0.020 | 0.050 | 0.012 | 0.002 to 0.052 |

The median run crosses $P_{\rm on} = 1/2$ at $n = 5683$, against 6083 for S4d: 7% earlier.

**Diagnosis: T2 is right to first order and needs a sentence.** The posterior weights $e^{S_n(t)}$ over a continuum of thresholds follow the supremum of the random field $S_n(\cdot)$, which exceeds the supremum of its mean. Gamers therefore win slightly early, and the on-task rate at a fixed $n$ near the flip is a wide distribution. T2.3 should report the spread at the flip, not only the sd of $S_n(t^\star)$.

Under (B) the S4d values are not good point predictions ($n = 20$: 0.94 against a simulated mean of 0.71; $n = 100$: 0.005 against 0.155). T2.3 already says that under (B) the flip is a random event, and its interquartile-range claim is confirmed (§2). These are counted as disagreements in the output only because the check compares point values.

### 3.6 T4.5 and T4.7: what "accepted with probability $v$" means under (B) (theory change)

Under (D) the verifier enters linearly, so only $v$ matters. Under (B), which conditions on the realised pass event, it matters whether acceptance is:
* a **fresh coin** on every evaluation, so that $P_A(\text{pass}) = (1-\delta)v + \delta$, as in T4.5; or
* a **fixed property of the episode**, so that this particular flag would be accepted or not, with $P_A(\text{pass}) = (1-\delta)\mathbf 1[\text{acc}] + \delta$.

R13 simulates both readings.

| quantity, T4 worked example | fresh coin (T4.5) | fixed verdict |
|---|---|---|
| (B) drift with the protocol, nats per episode | 0.0097 (simulated 0.0097) | 0.0244 (simulated 0.0242) |
| reduction from the no-protocol 0.092 | 9.4-fold | 3.8-fold |
| $\lambda_+$ per rewarded opportunity (T4.7) | 0.486 | $\Lambda\,\mathbb E(1-v) = 1.218$ |
| break-even $t^\star$ | 0.096 | 0.209 |
| sign flip of the naive gamer's drift (T1 honeypot example) | $s = 0.966$ | $s = 0.914$ |

**Diagnosis: T4's formula is right for one reading and wrong for the other, and the text does not say which reading it uses.** The fixed reading is at least as natural for debate or proof checking, where whether a valid flag can be demonstrated is a property of the claim. It gives $\varepsilon\Lambda\,\mathbb E(1-v)$: under (B), cells with low demonstrability cost linearly in $1-v$, not logarithmically. Reality is likely a mixture, a fixed part from the claim and a fresh part from the judge's sampling, and the truth lies between the two columns.

**What T4 must change.** State the assumption in T4.5, give both formulas, and carry both into T4.7's numbers. The qualitative conclusion, that protocols and audits are complements under both operators, survives, but the (B) gain is smaller under the fixed reading. T1's weak-grader (B) row in the §1.2 table should carry the same caveat.

### 3.7 T1.9 in regime (ii) when the data channel discriminates the band (refinement)

T1.9 says that an attracting aligned state requires $\varphi/(1+\varphi) < q^\dagger$ "in either regime". In the simulation's fresh regime, a careful gamer that carries the misaligned data signature is not frozen: each generation, the channel multiplies its odds by $e^{-\Xi \pm \sigma_d Z}$, with $\Xi = 8.11$ nats and $\sigma_d = 3.97$ nats. The mean map then tolerates prior odds up to 69. The simulation's threshold, 0.056, coincides with T1.9's frozen value (0.037, whose next grid point is 0.056). That agreement is coincidental.

A closed form (heuristic, Gaussian): the loop fails within $K$ generations with probability above 1/2 iff
$$r > r^\star = \frac{q_u}{1-q_u}\,e^{\Xi - \sigma_d z_K},\qquad z_K = \Phi^{-1}\big(2^{-1/K}\big),$$
which gives $r^\star = 0.044$ at $K = 30$. The exact binomial version puts the threshold between 0.032 (failure probability 0.40) and 0.042 (0.56). This is consistent with the simulation's grid, whose points are 0.032 and 0.056.

**What T1 must change.** Add to T1.9 that in regime (ii) the band condition is per generation, on $\varphi_k = \varphi\,e^{-\chi_{\rm band}}$. When the channel discriminates the band, its noise compounds over $K$ generations, and the effective threshold is $r^\star$ above, not $q^\dagger/(1-q^\dagger)$. Here the two happen to be close: a data channel of $m = 100$ signature tokens buys almost nothing over 30 generations.

### 3.8 Simulation README: existence of the aligned state (corrected)

The README said that the aligned state exists only for $\varepsilon_h < \varepsilon^* = 0.0263$. That is the condition $D(0) < 0$. T1.10's sharpened condition says that a small leak is tolerated. R5 confirms this on the exact mean map: the aligned state persists up to 0.02675 at $n = 2000$ and 0.02633 at $n = 20000$. The README now says so. The simulation's grid of step 0.002 could not resolve the difference, so no reported check changes.

---

## 4. Summary of required changes

**Simulation (done).**
* Fixed the myopic-$G$ knife edge (`toy.py`, `loopcore.py`, `train_sim.py`), and re-ran `train_sim`, `loop_sim` and `stepsize_sim`; the outputs and figures are regenerated.
* README: corrected the description of $G$, the $(\varepsilon_h, n)$ grid result and the existence threshold; withdrew one surprise; added `reconcile_checks.py` to the file table and to `run_all.sh`.

**T1.**
1. T1.7q: include (B) training noise; replace the table (§3.2); drop "optimistic above $L^\dagger$".
2. Takeaway 9 and §6: with a fixed episode budget, noise gives an interior optimum in both regimes (§3.3).
3. T1.9: the regime (ii) version with a discriminating data channel (§3.7).
4. §1.2: say "deterministic crossing" in the R4 cross-reference, and give the negative-binomial realised flip. Note the fresh-coin assumption in the weak-grader (B) row.
5. Optional: present the (C-on) row as an exact lattice chain. That gives minority outcomes, such as 30% of P2 best-of-8 runs at $G$, and not only the separatrix (R2).

**T2.**
1. T2.3: a per-type mean-field condition; the capture law for rarely triggered types; the timing shift and spread under per-episode (D) (§3.4, §3.5).
2. T2.5(3): the per-episode caveat to achievability.
3. Optionally, state scenario 3's lesson, honeypots placed where the frontier lies in feature space, as T1.4c's pointwise condition at the frontier.

**T4.**
1. T4.5 and T4.7: state the verifier-randomness assumption and give the fixed-verdict numbers (§3.6).
2. T4.18 is confirmed, deterministic and with noise.

---

## 5. Not tested here

* T1.10i (improvement channel) and T1.4d (frontier slice). Both are simple accounting, checked in T1's own scripts. The simulation has no improvement channel and no difficulty slices.
* T2.1′ (demonstrations and false flags), T2.8 and T2.8b (max-divergence and ROC tangent), T2.13 (caught-rate covariance law), and Example 4. These are rigorous identities under S4d, checked in T2's own scripts. The open question for them is the same per-episode issue as in §3.4 and §3.5.
* T4.6 (class patching), T4.9 to T4.15 (debate, consistency, collusion) and T4.17. The simulation has no protocol beyond the flag model of R13 and R14.
* Disagreement 2 of the simulation (plain policy gradient with a large step). No theory section makes a claim about it.

## Files

* `reconcile_checks.py`, `reconcile_checks_output.txt`: the 74 checks.
* `toy.py`, `loopcore.py`, `train_sim.py`: the bug fix.
* `train_sim_output.txt`, `loop_sim_output.txt`, `stepsize_sim_output.txt` and figures `fig_a*`, `fig_b*`, `fig_c1`: regenerated.
* `README.md`, `run_all.sh`: updated.
