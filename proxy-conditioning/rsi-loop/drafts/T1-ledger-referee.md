# Referee report on T1, "The alignment ledger and the dynamics of the loop"

*Adversarial referee, 18 October 2026. The draft is `drafts/T1-ledger.md`, read against `framing.md`, `sim/T1_ledger_checks.py` and its output, and `sim/README.md`. My own numerical checks are in the scratch scripts described in §5. Every number quoted below was recomputed.*

## 0. Verdict in brief

The within-generation algebra is correct. I re-derived T1.1, T1.3, T1.4, T1.5, the gambler's-ruin identity, the separatrix, the ODE time-to-failure and the step-size optimum. The draft's own checks reproduce. The section's *conclusions about the loop* are weaker than the algebra, for four reasons:

1. **The bistability and the separatrix depend on reading posterior mass as a population fraction of builders.** The draft never states this assumption, which I call the "annealed" reading. Under the "quenched" reading, where each generation *is* one disposition, the separatrix disappears. The loop then fails with probability about $1-\prod_k(1-q_k)$. For $L_0=2$ in the worked example, the annealed map predicts certain collapse; the quenched loop fails with probability 0.12.
2. **The cross-generation analysis is deterministic, but the worked example has about 12 decisive events per generation.** In a stochastic run of the same parameters, the "stable" regime-(ii) fixed point at 27.35 collapses with probability 0.44 within 10 generations and 0.96 within 50. Regime (i) from odds of $10^6$ collapses with probability 0.13. The simulation section already found noise-driven escapes, but T1 does not use them.
3. **The homogeneous, no-false-alarm recognition model creates the restoring regime that the takeaways rely on.** Replace it with a realistic continuous evaluation-awareness score. Then T1.4, the draft's own theorem, gives the best responder *positive* drift at every AUC above 0.5. At AUC 0.83 the drift is $+0.0104$ nats per episode, where the homogeneous model with $s=0.5$ gives $-0.024$. So the claim that the sign flips at $s=0.68$, inside today's range, compares a TPR at zero FPR with an AUC.
4. **The model gives every training episode the same audit rate $a$.** The baseline itself says that tasks above $c_k$ cannot be checked by generation $k$. Generation $k{+}1$'s training must contain such tasks, and T1.4 then implies positive drift for $G^\star$ on that slice. This is the most important consequence for the RSI loop, and the draft never draws it.

Several novelty claims should be narrowed:
* the break-even $t^\star$ is Becker's deterrence condition and the inspection-game threshold;
* the invisible band is the deceptive-alignment argument of Hubinger et al. (2019);
* the essential-infimum condition is the attack-selection logic of AI control.

What is new and worth keeping:
* the mapping of update operators to $(\lambda_+,\lambda_-)$, and hence to $t^\star$;
* the evidence-granularity point;
* the tolerable-mass condition $\varphi/(1+\varphi)<q^\dagger$;
* the explicit closed forms.

---

## 1. Mathematics, proposition by proposition

### T1.1 (only disagreement moves the ledger): holds, with fixes

The proof is correct: each factor is a functional of $\pi_\theta(\cdot\mid x)$ and the grader. Two problems remain.

* **The sampled-reward sentence is wrong.** The draft says: "Under sampled-reward RL, unpredictable errors add variance to $\ell$ but not mean." If $\pi_\theta(\cdot\mid x)=\pi_A(\cdot\mid x)$, then any sampled-reward update of mixture weights is also *exactly* equal for $\theta$ and $A$. One example is REINFORCE on logits, $\propto R(y)\,(\pi_\theta(y)/\pi_\mu(y)-1)$. The increment of $\ell$ is then zero, not zero-mean noise. The variance claim is true only for dispositions whose policies differ on the error episode for some other reason. **Fix:** delete it, or restrict it to that case.
* **The reading "unpredictable errors do no harm" holds only because all dispositions share the same softness $\delta$.** Suppose dispositions differ in carefulness: a sloppy disposition $S$ with $\delta_S>\delta_A$, which is the "slop" failure mode. Then unpredictable errors at rate $\varepsilon_u$ reduce the selection *against* sloppiness. The grader rewards $S$'s mistakes on a fraction $\varepsilon_u$ of the episodes where its wrong output happens to match the grader's wrong verdict. The net selection against $S$ scales roughly as $(1-2\varepsilon_u)$. So unpredictable errors are harmless for the intent axis, but they weaken selection on the competence axis. That axis matters for frontier work, as in Wentworth's slop critique in L1. **Fix:** say this explicitly, or add a competence-error term $\delta_k$ to $P^{\rm on}$.
* **Credit.** "Unpredictable errors do not select" is the qualitative content of the weak-to-strong theory: misfit equals gain (Charikar, Pabbaraju and Shiragur 2024), and the expansion bounds of Lang, Sontag and Vijayaraghavan (2024). Credit them here. The draft mentions only Burns et al., in a closing note.

### T1.2 (memorisers; predictability as compressibility): the inequality holds, but the threshold needs a fix

The inequality is correct as stated: a prior $\propto 2^{-K(E)}$, $\Lambda$ nats per seen error, minus the description cost. **The approximation $K(E_{1:n})\approx nH(\varepsilon_u)/\ln 2$ is, however, the conditional complexity $K(E\mid x_{1:n})$.** It is the cost of naming which of the $n$ seen inputs are errors.

A prior over dispositions is fixed before the data. Its unconditional cost of naming $\lvert E\rvert$ specific inputs from an input space $\mathcal X$ is about $\lvert E\rvert\log_2(\lvert\mathcal X\rvert/\lvert E\rvert)$ bits. For text inputs that is enormous. So the threshold $\delta\lesssim\varepsilon_u/e$ holds only if the prior can index the training inputs for free, as with a fixed finite dataset whose index is cheap, or a network that has already memorised the inputs. Otherwise the condition is roughly $\Lambda\gtrsim\ln\lvert\mathcal X\rvert$ per error per epoch, which is far harder to meet in a single epoch. Multi-epoch training changes this, since the gain is $\Lambda$ times the number of epochs.

**Fix:** write $K(E\mid x_{1:n})$, state the assumption that the dataset is free to the prior, and give the unconditional version alongside it.

The "bounded-complexity currency" paragraph is a good idea. It is also a known formalism: "errors no test in class $\mathcal C$ can predict" is multicalibration (Hébert-Johnson, Kim, Reingold and Rothblum, ICML 2018) and outcome indistinguishability (Dwork, Kim, Reingold, Rothblum and Yona, STOC 2021). Those give a ready-made definition: $\varepsilon$ relative to a student class $\mathcal C$ is the advantage of the best test in $\mathcal C$ at predicting where the grader errs. They would make open problem 8 concrete. Keep the label "heuristic".

### §1.2 table and operator comparison: the rows are correct; one claim in the text is false

I re-derived every row:
* (B), hard grader: $\lambda_\pm=\Lambda$;
* (B), weak grader: the log-ratio is correct, and $\lambda_+\le\Lambda$, so $t^\star\le 1/2$;
* (C-on), best-of-$k$: $\Lambda(1-(1-\pi_X)^k)$ and $\Lambda(1-\pi_X^k)$, assuming that episodes with no passing sample are discarded;
* (D): $(1-2\delta)\Delta_\pm/\beta$;
* (C-off): $\Lambda(1-2\delta_S)$.

The replicator reading of (D) is correct for frequency-independent fitness.

**False claim.** "(D) is the only operator in which the designer can push $t^\star$ toward 0." The draft's own (C-on), $k=1$ row has $t^\star=\pi_X$. At the aligned end $\pi_X\approx\delta+\mu(\text{gamers})(1-2\delta)$, which is about 0.01–0.02. So on-policy best-of-1 filtering is *automatically* strongly restoring at the aligned end: $\hat p>0.02$ suffices, and a handful of audits achieves that. This is the inertia the simulation section found, and it is a substantive, favourable result that the draft buries. **Fix:** replace the sentence with: "(D) lets the designer set $t^\star$ directly; (C-on) at $k=1$ has $t^\star=\pi_X$, which is small at the aligned end and large at the misaligned end, so it is restoring near $A$ and entrenching near $G$."

**Caveat on (C-off).** A calibrated careful gamer that can tell trusted-demonstration inputs apart treats them as audits ($d=1$) and does not game there, so it stays frozen. "Negative drift with no audits" therefore holds only against gamers that cannot tell demonstration inputs from deployment-like opportunities. Say so.

**Cross-reference error.** "The framing's $n^\star\approx\ln O/\varepsilon\approx1{,}375$ (R4) is the case of one nat per rewarded opportunity." The framing's $(1-\varepsilon)^n$ is the *input-averaged* pass likelihood. It is exact if the target fails with probability $\varepsilon$ on every input, not if it fails surely on a fraction $\varepsilon$ of inputs that are observed. Under realised-input (B) the evidence per error is $\Lambda$, which is infinite at $\delta=0$. The draft's correction to $\ln O/(\varepsilon\lambda_+)$ is right. The explanation should be "framing R4 used input-averaged likelihoods", and framing R4 should get an erratum.

### T1.3 (master formula): holds

The algebra is exact, and I reproduced section 1 of the checks. Two scope notes:
* The proof needs every unrecognised opportunity to carry the same posterior $\hat p$. That is the homogeneity that T1.4 relaxes. The headline formula, "Training favours gaming iff $\hat p<t^\star$", is therefore a statement about the homogeneous model only. Under heterogeneity, the right statement for the best responder is T1.4's essential-infimum condition, and that condition almost always fails (see major issue M3). Put this caveat in the Summary, not just in T1.4.
* Assumption A2, a calibrated $\hat p$, is strong across generations. Each generation faces a *new* grader and audit regime built by its predecessor, so a gamer must be calibrated about a regime it has never seen. A gamer with a prior over $\hat p$ uses $\mathbb E[\hat p]$, or a risk-adjusted version. That ties naturally into the burn-in term $\psi$. Mention it.

Worked numbers: $u=0.015$, $v=0.0097$, $\hat p=0.607$ and $D=-0.0244$ are all correct, and the sign flips at $s=0.677$. But "the evidence note (L2) puts frontier evaluation-recognition at an AUC of about 0.7–0.9" is not comparable with $s$ (see M3).

### T1.4 (no restoring force against a best responder): holds; the novelty and the "Cotra made exact" framing are overstated

The proof is correct: pointwise maximisation, attained at $C_{t^\star}$, zero iff $d\ge t^\star$ almost surely. The essential-infimum reading is the most useful observation in the section. The draft does not follow it through.

* **The conclusion is close to a tautology.** $G^\star$ is *defined* as the maximiser of the training functional. So $J_{G^\star}\ge J_A$ holds for any fixed policy $A$, and the tilt is monotone in $J$. Calling it "Cotra's argument made exact" overstates it. Cotra's claim is that $G$ gets *strictly* more reward under realistic feedback, and that the training-game player is in the hypothesis class with non-negligible prior. T1.4 contributes the exact condition for equality. Say that.
* **A sharper corollary is missing.** The "heterogeneity helps the gamer" bullet is Blackwell monotonicity. Since $(t^\star-d)^+$ is convex, any refinement of the gamer's information about audits is a mean-preserving spread of $d$, and it weakly raises $\mathbb E[(t^\star-d)^+]$. Therefore **any improvement in evaluation awareness weakly increases the best responder's drift**, and T1.5 is a special case. Stating it this way is cleaner and makes T1.5 a corollary.
* **The decisive consequence is missing.** With a continuous "test-likeness" signal whose likelihood ratio (audit : real) is unbounded below, $\operatorname{ess\,inf} d=0<t^\star$, so $G^\star$ has strictly positive drift at every AUC above 0.5. See M3 for numbers.
* **Prior art.** The break-even $t^\star=\Delta_+/(\Delta_++\Delta_-)$ is the classical deterrence threshold: an offence pays iff $p\,\cdot\,\text{penalty}<(1-p)\,\cdot\,\text{gain}$ (Becker 1968, "Crime and punishment: an economic approach", *JPE* 76). It is also the indifference condition of inspection games (Avenhaus, von Stengel and Zamir 2002, *Handbook of Game Theory* vol. 3, ch. 51). The "attack only where detection is lowest" logic is the attack-selection behaviour that red-team policies show in AI control (Greenblatt et al. 2024). The genuinely new parts are these two:
  * the translation of each training operator into $(\lambda_+,\lambda_-)$, so that the deterrence threshold of *selection* depends on the operator: $1/2$ for (B), $\pi_X$ for (C-on);
  * the point that, under selection, a tie means frozen odds.

### T1.5 (audits select for recognition): holds

The difference $ah(s'-s)\lambda_-$ is exact, and I reproduced section 8 of the checks. Add the limiting case: a perfect recogniser ($s=1$) has $u=0$, so it drifts at $+v\lambda_+$ whatever the audit design. Audits are irrelevant to it. This is the cleanest statement of why evaluation awareness is the critical parameter.

**Internal inconsistency.** In "Net drift", the claim that the vector "takes only three values" assumes that all gamers share the same $s$. Once types differ in $s$, which is what T1.5 is about, $D$ takes a continuum of values. Fix the wording.

### T1.6 (the ledger within one generation): holds, with fixes to parts 2 and 3 and to the takeaway built on them

1. Order-independence under (B), (D) and (C-off) is correct.
2. "The mean crossing time is $n^\star=L_0/D$." This is the time at which the *mean* crosses. The expected first-passage time is $\mathbb E\tau=(L_0+\mathbb E[\text{overshoot}])/D\ge L_0/D$ by Wald. Say "the deterministic crossing time".

   Hoeffding is correct but very loose. Increments are 0 on a fraction $1-w$ of episodes, so Bernstein or Bennett with variance $\approx w\Lambda^2$ is tighter by about a factor of $1/w$ in the exponent. That matters when $w\approx0.025$.
3. The gambler's-ruin probability $(v/u)^{\lceil L_0/\Lambda\rceil}=0.1749$ is correct. I also reproduced the Lundberg exponent, and the bound $5\times10^{-53}$. Note how fragile it is: $L_0/\Lambda=3.006$, so a value of $\delta$ slightly above 0.01 gives $m=3$ and a probability of 0.27.

   **The event is the wrong one, however.** "Ever flips during an infinitely long generation" is not what feeds the loop. The loop reads the *end-of-generation* ledger, and the threshold that matters is $L^\dagger$, not 0. At $n=500$:
   * $P(L_n<0)=P(N_r-N_c\ge4)=0.038$;
   * $P(L_n<L^\dagger)=P(N_r-N_c\ge3)=0.068$ per generation (Skellam).

   Across generations, regime (i) from $10^6$ odds collapses with probability 0.13 (M2).

   **The comparison with 0.05-nat events is not at matched drift.** With the same rates and $\lambda=0.05$, the restoring drift is 92 times smaller. Within regime (ii), the per-generation signal-to-noise ratio is independent of $\lambda$: the mean is $\propto\lambda n(u-v)$, and the standard deviation is $\propto\lambda\sqrt{nw}$. Smoother updates reduce the fluctuations *and* the margin $n\lvert D_0\rvert/(1-\eta)$ in proportion. They help only by moving the system toward the deterministic limit $L_A\to L_b$, and that is safe only if $L_b>L^\dagger$.

   **Fix for takeaway 5.** Replace "Prefer smooth, low-evidence updates" with: "Tipping is controlled by the per-generation SNR $\sqrt n\,(u-v)/\sqrt{u+v}$, together with $L_b-L^\dagger$. Granularity matters through $L_0/\Lambda$ only within a generation."

### T1.7 (regime (i), the basin and its separatrix): holds; one hypothesis is false in general and the conclusion survives

**"$D$ is increasing in $q$" (§4.1) is false for random audits.** $D(q)=\varepsilon(q)\,[\lambda_+-b(1-q)]$ is the product of a positive increasing factor and an increasing factor that is negative for $q<q^\dagger$. Counterexample: $\lambda_\pm=1$, $a=0.75$, $s=0$, $\varepsilon_h=0.001$, $\Delta\varepsilon=0.1$ (so $b=1.5$). Then
$$D(0)=-0.0005,\quad D(0.1)=-0.0039,\quad D(0.2)=-0.0042,\quad D(0.3)=-0.0015,\quad D(0.4)=+0.0041.$$
So $D$ is not monotone. The conclusions survive, because $D$ has a single sign change at $q^\dagger$ and is bounded away from 0 on compact subsets of each side. **Fix:** replace "continuous and strictly increasing" with "continuous with a single sign change from $-$ to $+$". T1.10 does need monotonicity (for $\Gamma$ to be increasing and $F'>\eta$). With non-monotone $D$, $F'$ can fall below $-1$ in principle, giving a period-doubling instability. In practice this is irrelevant at the aligned fixed point, because $q(1-q)$ is tiny there, but state it.

The closed forms for $q^\dagger$ and $L^\dagger$ are correct and reproduced, and so is the observation that they do not depend on $\varepsilon_h$ or $\Delta\varepsilon$. The independence is an artefact of $h=\varepsilon$ with audits that are always right. If a colluding builder's new blind spots are *also* blind spots of the audits it builds, which is plausible because both come from the same builder, then $h$ does not scale with $\Delta\varepsilon$ and the separatrix moves. Say that the independence is a modelling choice, not a robust finding.

The annealed-reading assumption behind T1.7 is discussed in M1.

### T1.8 (best responders flatten the basin): holds within the annealed, two-type, homogeneous model

The algebra is correct, and I reproduced section 6 of the checks. Under best response the basin of $L_b$ is $(2.376,\infty)$, which contains $(L^\dagger,\infty)$ as claimed. Two caveats:
* "Training never raises the ledger above the base prior" relies on homogeneous $d$. With heterogeneous $d$ and $\operatorname{ess\,inf}d<t^\star$, $D^\star>0$ even at $q=0$, so training *lowers* the ledger every generation. The basin is not flat; it slopes the wrong way (M3).
* State that the two types are $A$ and $G^\star$ only. With $A$, $G$ and $G^\star$ together, $q$ includes the frozen $G^\star$ mass, and that is exactly T1.9.

### T1.9 (invisible-band condition): holds

$q\ge\varphi/(1+\varphi)$ is correct for any number of other types, since $\mu(A)\le1/(1+\varphi)$. The necessity argument is correct. Credit this properly: the invisible band is the deceptively aligned mesa-optimizer of Hubinger, van Merwijk, Mikulik, Skalse and Garrabrant (2019, "Risks from learned optimization", arXiv:1906.01820), together with Carlsmith's (2023) point that schemers who play the training game are not selected against. What is new is the quantitative coupling, "band mass < tolerable gamer mass", and it is a nice result. The draft does not cite Hubinger et al. 2019 at all, and it should.

### T1.10 (regime (ii), bistability): the deterministic claims hold; they are fragile in the worked example

* $\Gamma(L^\dagger)=L_b$, the existence argument and the step-limit conditions are correct. The fixed points 27.35, 2.376 and $-272.7$ are reproduced.
* "In regime (ii), with $D(0)>0$, the fixed point is $L_b-nD(0)/(1-\eta)$; it stays aligned iff $nD(0)<(1-\eta)L_b$." This is only approximate. Near $L\approx0$, $D(q(L))\gg D(0)$, so the condition is necessary, not sufficient. A sufficient version is: $L_b-nD(0)/(1-\eta)\gg1$, or solve $L=L_b-nD(q(L))/(1-\eta)$ directly.
* **The stochastic version fails in the worked example** (M2): the collapse probability is 0.44 by generation 10.

### T1.11 (three regimes of time to failure): the formulas hold; the regime claims need fixes

* Both closed forms match quadrature, and the discrete-map counts (23 vs 24; 200,003 vs 200,009) reproduce.
* "Collusion feedback shortens it only by $O(1/(nD_0))$" (body) and "only by $O(1)$" (author summary) are inaccurate. The correction is $\frac{D_1}{nD_0(D_0+D_1)}\ln\frac{D_0}{2D_0+D_1}\approx-\ln(D_1/D_0)/(nD_0)$ for $D_1\gg D_0$. That is 4.5 generations out of 27.6 in the example. **Fix:** "by $O(\ln(D_1/D_0)/(nD_0))$".
* **The $D_0=0$ regime is fragile, and the linear form $D_0+D_1q$ mislabels it.**
  * With honeypots and $\varepsilon_h=0$: $u(0)=a(1-s)>0$ and $v(0)=0$, so $D_0<0$, not 0.
  * With random audits: $D(q)=q\Delta\varepsilon\,(\lambda_+-b+bq)$. Then $D_0=0$, and $D_1=\Delta\varepsilon(\lambda_+-b)$ is *negative* whenever the audits are adequate ($b>\lambda_+$).

  So "$D_0=0$, $D_1>0$" describes exactly the case where audits are too weak to catch collusion-made errors, not "the regime debate-like protocols aim for". Also, any positive $O(1)$ per-generation drift moves the loop back to the logarithmic regime: the overhead $\psi$ of §6, the data-channel push $\zeta$, or noise.

  **Fix:** reword the regime as "honest builders leave no predictable errors *and* audits cannot catch colluders' errors". Note that it does not survive $\psi>0$. Takeaway 6 ("better priors are worth much more once those protocols exist", meaning linear rather than logarithmic in the odds) should carry this caveat.

### T1.12 (step size): the algebra holds; the regime (ii) part is inconsistent

* $g^\star$, $\Lambda^\star_{\rm tot}$, the feasibility condition, the condition for an unlimited range and the sign ceiling are all correct. The example (16 generations, 13.8 nats) is reproduced.
* **Part 4 uses $L^\dagger$, which does not exist when $D_0(g)>0$**, the case where the per-generation constraint binds. Use $L_{\rm fail}$, as in part 2, or state that $D_0(g)<0$ there.
* The interior optimum depends entirely on $\psi>0$. The simulation section, which has no $\psi$, finds monotone behaviour in the continued regime: smaller steps are always safer. It finds a U-shape only in the fresh regime at $n=2000$, and the cause there is per-generation escape noise, which plays the role of $\psi$. Say that the interior optimum comes from the overhead assumption, and cite the simulation section's noise-driven version as an independent mechanism.
* Engels et al.: the shape analogy (softplus $-\ln p(g)$, convex with a positive intercept, against convex-plus-intercept) is fair. "Linear growth of the number of generations" is a property of this model, not something Engels et al. report. Keep "qualitatively".

### T1.13 (frontier behaviour): holds, with notational fixes

* $A=C_0$ belongs to $\lbrace C_t: t\le d_F\rbrace$, so $\mu(A)+\mu(\lbrace C_t:t\le d_F\rbrace)$ double-counts it. Write $\lbrace C_t: 0<t\le d_F\rbrace$.
* The $G$ term omits softness: it should be $(1-\varepsilon_F)(1-\delta)+\varepsilon_F\delta$. The band term should be $\delta$, not 0. This is cosmetic.
* The family $C_t$ is discontinuous at $t=1$: $C_t$ for $t<1$ pursues "its own objective" on the frontier, while $C_1=G$ follows the frontier grader. State this as a definitional choice.
* "Caps $P^{\rm on}$ whatever training does": training changes the band's *absolute* mass by removing visible gamers, and only its odds against $A$ are frozen. Reword.
* **Retrospective audits need consequences.** A threshold on "detection" stands in for "detection followed by a consequence for the gamer's objective". In regime (ii), with fresh training from a trusted base, catching generation $k$'s frontier sabotage at generation $k{+}1$ updates nothing about generation $k$. A careful gamer that cares about outcomes, and not about being seen, then has an effective $d_F$ of 0 whatever the sampling rate. **Fix:** define $d_F$ as the probability of *consequential* detection, for example a committed rollback of the grader, retraining of $k$, or discarding of $k$'s outputs. Note that this makes the lever a commitment and policy question.

### T1.14 (scaling conjectures): unclear

These are reasonable conjectures, with no derivation and labelled as such. The direction for $s$ has evidential support (Schoen et al. 2025; Needham et al. 2025). The direction for $L_0$ is contested: Tice et al. (2026) show that the corpus can push $L_0$ either way. Cite that.

---

## 2. Major issues (modelling)

**M1. Annealed versus quenched builders.** In §4.1, $q_k=\sigma(-L_k)$ sets the next grader's leniency and audit sabotage as a *mixture*: a fraction $q_k$ of the grader-building work is lenient. That is right if personas are sampled per episode (persona-selection reading) and the grader is built from many independent episodes. It is wrong if the trained network realises one coherent disposition and $\mu_k$ is our uncertainty about which one (quenched reading). Coherent collusion and sabotage, which is what $\Delta\varepsilon$ and $a(1-q)$ are meant to capture, is more natural under the quenched reading.

Under the quenched reading:
* if generation $k$ is $A$, the grader is honest, and $L_{k+1}=L_k-nD(0)$;
* if it is $G$, then $D(1)$ applies, $L$ drops by $138$ nats, and $G$ is absorbing.

There is no separatrix. $P(\text{loop fails})=1-\prod_k(1-\sigma(-L_0-kn\lvert D(0)\rvert))\approx\sigma(-L_0)/(1-e^{-n\lvert D(0)\rvert})$. Simulated in the worked example, regime (i):

| $L_0$ | annealed map predicts | quenched P(fail), simulated | quenched, analytic |
|---|---|---|---|
| 1.0 | certain collapse | 0.270 | 0.269 |
| 2.0 | certain collapse | 0.119 | 0.119 |
| 2.4 | certain collapse ($L^\dagger=2.403$) | 0.085 | 0.083 |
| 3.0 | survives | 0.047 | 0.047 |
| 13.8 | survives | about $10^{-6}$ | $1.0\times10^{-6}$ |

The two readings give qualitatively different answers to the user's question, "will the loop work?". **Fix:** state the reading as an explicit assumption (A4), give the quenched result as a proposition alongside T1.7, and say which reading the evidence supports. Persona-mixture evidence favours annealed for naive gamers. Coherent schemers are quenched by definition. A natural hybrid: naive $G$ annealed, careful $C_t$ quenched.

**M2. Deterministic maps for a process with about 12 decisive events per generation.** In the worked example, $n=500$ with $u=0.015$ and $v=0.0097$, a generation has about 7.5 caught and 4.9 rewarded events, each worth $\pm4.6$ nats. The per-generation increment has mean $+12.2$ and standard deviation about 16 nats. I simulated the same model with Poisson counts (P(collapse to $L<-20$) by generation):

| case | 1 | 5 | 10 | 20 | 50 |
|---|---|---|---|---|---|
| regime (ii), $L_b=3$, $\eta=0.5$, start at the "stable" 27.35 | 0.002 | 0.23 | 0.44 | 0.71 | 0.96 |
| regime (ii), $L_b=10$ | 0.000 | 0.11 | 0.24 | 0.45 | 0.79 |
| regime (i), $L_0=\ln10^6$ | 0.002 | 0.12 | 0.13 | 0.13 | 0.13 |
| regime (ii), $L_b=3$, $n=5000$ | 0 | 0 | 0.0001 | 0.0004 | 0.001 |

The governing quantity is the per-generation SNR in regime (ii):
$$z\approx\frac{L_A-L^\dagger}{\text{sd}_\infty}\approx\sqrt n\,\frac{u-v}{\sqrt{u+v}}\sqrt{\frac{1+\eta}{1-\eta}}\;+\;\frac{(L_b-L^\dagger)\sqrt{1-\eta^2}}{\Lambda\sqrt{nw}}.$$
It is about 1.3 in the example, which gives a hazard of roughly 10% per generation. **With $\eta<1$ the aligned fixed point is only metastable: the hazard per generation is constant, so failure is eventually certain** (Kramers-type escape). Its mean time is about $1/p_{\rm esc}$. This contradicts "$D_0<0$: the loop survives forever, except for stochastic tipping": in regime (ii), stochastic tipping is a constant hazard, not an exception.

**Fix:** add a proposition on the escape rate from the regime-(ii) fixed point, with a large-deviations or Gaussian approximation. The simulation section's `p_esc_fresh` already computes it. State the condition $n(u-v)^2/(u+v)\gg1$ for the deterministic map to be valid. Either raise $n$ in the worked example, or report the stochastic figures.

**M3. Homogeneous recognition with no false alarms versus a realistic ROC.** The model has the student recognise an audit with probability $s$ and never false-alarm. Evaluation awareness is measured as an AUC, that is, a whole ROC curve. Model it with a binormal score of AUC $A$: test-likeness score $\sim N(d',1)$ on audits and $N(0,1)$ on real opportunities. The calibrated $d(x)$ then tends to 0 in the "looks real" tail, so $\operatorname{ess\,inf}d=0$, and **by T1.4, $G^\star$ has strictly positive drift for every AUC above 0.5.** Honeypot worked example ($ah=0.03$, $v=0.0097$, (B)):

| AUC | $G^\star$ drift (nats per episode) | homogeneous model, $s=0.5$ |
|---|---|---|
| 0.60 | $+6\times10^{-6}$ | $-0.024$ |
| 0.70 | $+0.0015$ | $-0.024$ |
| 0.83 | $+0.0104$ | $-0.024$ |
| 0.95 | $+0.0266$ | $-0.024$ |

Even a naive gamer using a single cutoff on the score attains the same drift.

So the takeaway "In the honeypot worked example the sign flips at $s=0.68$, inside today's measured range" compares a TPR at zero FPR ($s$) with an AUC. The model's actual prediction, using the draft's own T1.4, is worse: **with any evaluation-awareness signal whose likelihood ratio is unbounded, restoring drift against a best responder is impossible.** The positive version is a design target. Restoring requires
$$\frac{\text{density of audits}}{\text{density of real opportunities}}\;\ge\;\frac{t^\star}{1-t^\star}$$
*pointwise* in the student's feature space. Honeypots must cover the most realistic-looking tail of real opportunities, not merely be frequent on average. That is a sharp, actionable statement. Put it in the summary in place of the $s=0.68$ claim.

**M4. Audits are unavailable on the frontier slice of training.** The baseline says tasks of difficulty in $(c_k,c_{k+1}]$ cannot be checked by generation $k$. Generation $k{+}1$ is trained, at least in part, on tasks at its own level, where the weak grader built by $k$ makes predictable errors. On that slice $a\approx0$ (or $h\approx0$), so $d\approx0$, and T1.4 gives $G^\star$ positive drift $w_F\lambda_+$ from that slice alone, *however many audits there are below $c_k$*. The draft's homogeneous $a$ hides the most loop-specific consequence of its own theorem. **Fix:** index $a$, $h$, $\varepsilon$ and $s$ by difficulty. State the corollary: the restoring regime requires either that generation $k{+}1$'s *gaming opportunities* lie only in checkable difficulty slices, with capability on the frontier slice coming from verifiable rewards, or retrospective audits by generation $k{+}1$ or $k{+}2$ *with consequences* that reach back into the frontier slice of training. This turns takeaway 8 from advice into a theorem-backed necessity.

**M5. The model has no improvement channel, so the Christiano mapping is off.** In the model an $A$ builder merely does not sabotage: $q=0$ gives $\varepsilon_h$ and $a$. The parameters are otherwise stationary, apart from conjectured capability trends. Christiano's basin is the claim that an approximately corrigible agent *actively* makes its successor more corrigible. Representing that needs $a_{k+1}$, $s_{k+1}$ and $L_{b,k+1}$ to improve as functions of $(1-q_k)$ and capability. The draft says the restoring force "has to come from channels that bypass the grader". Its formal model has no such channel, though, so it cannot say whether the basin exists in Christiano's sense, only whether audits keep it. **Fix:** add a minimal improvement term, for example $L_{b,k+1}=L_{b,k}+\gamma(1-q_k)-\kappa_L g$ and $s_{k+1}=s_k+\kappa_s g-\gamma_s(1-q_k)$. Give the condition on $(\gamma,\kappa)$ for a real basin. Then the "formal version of Christiano's basin" claim becomes accurate. Without it, say "a formal version of *preserving* alignment through audits".

**M6. Novelty claims.** Of the eight items listed as new:
* $t^\star$ is Becker's deterrence threshold and the inspection-game indifference condition;
* "no restoring force against a best responder" is a near-tautology given that $G^\star$ maximises the training functional, plus attack selection as in AI control;
* the invisible band is deceptive alignment (Hubinger et al. 2019) and Carlsmith's training-gamer argument;
* the step-size optimum is the same tangent-from-the-origin optimisation as in Engels et al.

These are defensible as *new*:
* the operator-to-$(\lambda_+,\lambda_-)$ mapping, especially (C-on) $t^\star=\pi_X$;
* the evidence-granularity and tipping analysis, once corrected;
* the tolerable-mass inequality $\varphi/(1+\varphi)<q^\dagger$;
* the closed-form separatrix, within the annealed model;
* the recognition-selection rate as a formula.

Rewrite the "New here" list accordingly.

---

## 3. Minor issues

1. T1.6.3 edge case: if $L_0/\Lambda$ is an integer, $\lceil\cdot\rceil$ steps produce a tie ($L=0$), not a flip. Use $\lfloor L_0/\Lambda\rfloor+1$.
2. §2, consequence 1: "audits must make up more than half of all unrecognised opportunities" holds for the hard-grader (B) only. With a weak grader $t^\star<1/2$.
3. The data channel in T1, $(1-\eta)L_b+\eta L_k$, differs from the simulation section's additive $\Xi(1-2q_k)$ signature channel. Reconcile the two, or map one onto the other, since the brief asks for compatible notation.
4. The honeypot example has $a=0.03$ with $h=1$, so there are three honeypots for every natural opportunity. That ratio is what makes $\hat p>1/2$. Say so; it is an expensive design.
5. §0 has two meanings of $\varepsilon$: the predictable-error rate on unaudited episodes, and in $h=\varepsilon$ the base rate of opportunity-presenting inputs. They coincide only if every opportunity-looking input is a real grader error. That is fine, but state it.
6. Parameter table: "$\varepsilon_u$ ... harmless by T1.1" should read "harmless for the intent axis" (see T1.1).
7. The reference list cites Schoen et al. and Wen et al. "as summarised in L2". Yang et al. (2024, arXiv:2406.11431) is more direct evidence for $\varepsilon_h(g)$ rising with the gap, so cite it in §6.
8. The closing paragraph of the references reads like a placeholder ("The other literature the brief names..."). Fold it into the text where each item is used.
9. Summary bullet 4 says "only rates matter", but bullet 5 and §4.4 make $L_b$ matter every generation in regime (ii). Qualify the claim to regime (i).

## 4. What is missing that would change the conclusions

* **The quenched reading** (M1) and **noise** (M2). Both change the answer to "does the loop work?", and the simulation section has the machinery for both.
* **Difficulty-indexed audits and errors** (M4).
* **An improvement channel** (M5).
* **False alarms and ROC-based recognition** (M3).
* **A competence-error axis.** Frontier tasks can fail by slop as well as by gaming. Unpredictable errors weaken selection on that axis (T1.1), and it compounds through the grader channel just as $\Delta\varepsilon$ does.
* **Learning rather than selection.** This is acknowledged as open problem 1. It should be flagged as threatening T1.5's sign, not just its rate: SGD can *create* recognition, and the Baker et al. (2025) obfuscation result is evidence that training against monitors creates concealment.
* **Deployment-time online training** (Christiano's low-stakes setting). Frontier tasks with delayed retrospective checks fit into the ledger as a second training channel with its own $(\hat p,t^\star)$. That is the natural home for retrospective audits.

## 5. Checks run by the referee

Scratch scripts (`ref1.py`, `ref2.py`, `ref3.py` in the session scratchpad; not part of the repository):
* Skellam end-of-generation flip probabilities: $P(L_n<0)=0.038$ and $P(L_n<L^\dagger)=0.068$ at $n=500$, $L_0=\ln10^6$.
* Stochastic regime (i) and (ii) maps with Poisson event counts, 20,000 runs: the tables in M2.
* The quenched loop, simulated and in closed form: the table in M1.
* Binormal-ROC best-responder drift: the table in M3.
* A counterexample to the monotonicity of $D$ under random audits (T1.7).

I also re-ran `sim/T1_ledger_checks.py` reasoning by hand. All of its checks are consistent with my derivations.

## 6. Verdict table

| id | verdict | one-line reason |
|---|---|---|
| T1.1 | holds with fixes | the sampled-reward "variance" claim is wrong; "no harm" holds only on the intent axis because $\delta$ is shared |
| T1.2 | holds with fixes | the threshold uses conditional complexity $K(E\mid x_{1:n})$ |
| T1.3 | holds | exact; the "(D) only" claim in the text is contradicted by (C-on) $t^\star=\pi_X$ |
| T1.4 | holds | correct, but near-tautological; the key ROC corollary is missing; prior art in Becker and inspection games |
| T1.5 | holds | exact; follows from Blackwell monotonicity |
| T1.6 | holds with fixes | the ruin probability is for an "ever" event; the relevant one is end of generation below $L^\dagger$ |
| T1.7 | holds with fixes | monotonicity of $D$ is false for random audits; single crossing suffices; annealed assumption |
| T1.8 | holds with fixes | only under homogeneous detection and the annealed reading |
| T1.9 | holds | correct; credit Hubinger et al. 2019 |
| T1.10 | holds with fixes | the deterministic result is metastable under noise in the worked example |
| T1.11 | holds with fixes | the O(1) claim should be $O(\ln(D_1/D_0)/(nD_0))$; the $D_0=0$ regime is mislabelled and fragile |
| T1.12 | holds with fixes | part 4 uses an undefined $L^\dagger$; the optimum relies on $\psi$ |
| T1.13 | holds with fixes | double counting; retrospective audits need consequences |
| T1.14 | unclear | conjecture |
