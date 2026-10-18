# Referee report on T2, "Proxy training as a sieve"

*Adversarial referee, 18 October 2026. I read `drafts/T2-sieve.md` in full, `framing.md`, the T1 sections the draft relies on (T1.1 to T1.6 and the operator table in T1 §1.2), and `sim/T2_sieve_checks.py` with its output. I wrote my own checks in a scratch script (`/tmp/claude-0/-home-user-AI-works/74db2b2c-3256-5e01-b605-f8ef37755b80/scratchpad/ref.py`). Its outputs are quoted below wherever they matter.*

## Overall assessment

Within the stated model, the mathematics is mostly correct and cleanly done. I re-derived T2.1, T2.2 (including the Gaussian closed form and the monotonicity of $\Phi(z-d)/\Phi(z)$), T2.5(1)–(2), T2.6, T2.7, T2.8, T2.9, T2.11 and T2.12, and every one checks out. The Monte Carlo and Laplace checks in the script reproduce. The cap identity, the one-sided indistinguishability condition and the "post-sieve correlation" reading of tells are the genuinely useful contributions.

The section has four real problems. The first two are major because they change the headline.

1. **The headline "decisive inequality $d_F>t^\star$" depends on the type space.** That space contains only fixed-threshold types $C_t$ and leaves out the stakes-adaptive best responder. Section 2 itself says this best responder is the description-length-favoured type ("maximise the training reward, audits included"). Add it, and T1.4 gives a ceiling that no training design and no $d_F>t^\star$ removes (Major 1).
2. **"For every training design" is false once operators are mixed or penalties vary across cells.** The mesh floor at $t^\star$ holds only when every opportunity carries the same $(\lambda_+,\lambda_-)$. Two counterexamples break it. SFT on trusted demonstrations of real opportunity prompts has $t^\star=0$ on its cells and pushes down types with $t\le t^\star$. So do cell-dependent penalties. False positives, which the model leaves out, bound the penalty lever from below (Major 2).
3. **The observable warning signal is misstated.** In Example 1, the model's own posterior predictive shows the caught-gaming rate *rising* about 30-fold and the gaming rate rising about 60-fold during training. It does not decline. "Visible gaming declines while frontier on-task behaviour collapses" describes the mass of $C_1$, not anything a designer observes (Major 3).
4. **Retrospective random audits are oversold.** "$\xi=0$ information-theoretically" is true of *which episodes get audited*. It is not true of *whether gaming would be caught*: the gamer can predict that, and it chooses how to game. The frontier detection $d_F$ is moreover the probability of being caught *late*. That deters only if late detection carries consequences the gamer cares about (Major 4).

The other points are smaller fixes: the mesh equation fails at atoms, a numerical error in Example 3, "$t^\star=1/2$ for filtering" contradicts T1's own table, the "ideal pooled level" remark is wrong, there are some overclaims, and several prior-art items are uncredited. Each is listed below.

---

## 1. Mathematics, proposition by proposition

### T2.1 (drift). Verdict: holds with fixes

The derivation is correct, and the tower-property step is right. But "the drift depends on the joint law of $(p,z)$ only through $H$" uses three assumptions that are not stated.

* **(a) Constant evidence.** $\lambda_\pm$ is the same on every opportunity and does not depend on $(p,z)$. If the gain from gaming or the penalty varies by episode, as it does in practice where stakes differ by task, the drift is $w\,\mathbb E[\mathbf 1_S(\lambda_+(z)(1-\hat p)-\lambda_-(z)\hat p)]$. It then depends on more than $H$, and the break-even becomes cell-specific (see Major 2).
* **(b) No false positives.** $A$'s intended output is never flagged. With a per-opportunity false-flag probability $f$, the bracket becomes $\bar\lambda\,[(t^\star-p)+f(1-t^\star)]$ (derivation in Major 2).
* **(c) Exogenous detection.** $p$ is a property of the opportunity, not of the gaming action. A gamer that chooses *how* to game (subtle versus blatant) makes $p$ endogenous (Major 4).

**Fix:** add these as assumptions S1′ to S4′ and state T2.1 under them. Remark 0.1's last sentence ("everything below holds with $\mathbf 1[\hat p<t]$ replaced by $\mathbf 1_S$") is too broad. T2.1 and T2.6 survive it. T2.2's shape and the mesh, T2.3's Laplace step and T2.5's ceiling proof all use the threshold order. Say which results generalise. For example: "no type whose gaming region lies inside $\lbrace\hat p<t^\star\rbrace$ is ever pushed down" generalises; "$D$ is quasi-concave in $t$" does not.

### T2.2 (shape of the sieve). Verdict: holds with fixes

Items (1), (2), (3) and (5) are correct. The Gaussian closed form is correct: $\hat p=\sigma(\operatorname{logit}\bar p+dz-d^2/2)$, and $D/(w\bar\lambda)=(1-\bar p)t^\star\Phi(z_t)-\bar p(1-t^\star)\Phi(z_t-d)$. The mesh condition $\Phi(z-d)/\Phi(z)=\operatorname{odds}(t^\star)/\operatorname{odds}(\bar p)$ is right. The ratio is increasing because the inverse Mills ratio is decreasing, and the limits are 0 and 1. I reproduced the MC agreement.

**Problems in item (4), the mesh equation.**
* **It has no solution when $H$ has an atom at the cut.** For pooled audits, $H=\delta_{\bar p}$, so $\mathbb E[\hat p\mid\hat p<t_0]$ is undefined for $t_0\le\bar p$ and equals $\bar p\neq t^\star$ above. Yet the table reports the mesh as $0.30$ at AUC 0.5.
* **It also has no solution when $q_{\min}\ge t^\star$,** which is exactly the good case $D^\star=0$. There $\mathbb E[\hat p\mid\hat p<t_0]\ge q_{\min}>t^\star$ for every $t_0$, and the removed set is $(q_{\min},1]$.
* **It can have a continuum of solutions** when $H$ has a gap above $t^\star$.

**Fix:** define $t_0:=\sup\lbrace t: D(t)\ge 0\rbrace$, so the removed set is $\lbrace D<0\rbrace=(t_0,1]$ up to the endpoint. State the conditional-mean equation as the characterisation when $H$ is continuous at $t_0$ and $q_{\min}<t^\star$.

**Discontinuity at $d=0$, worth one sentence.** The mesh is $0.30$ at chance but $0.232$ at AUC 0.6, and $t_0\to t^\star=0.2$ as $d\to0^+$. The "frozen band $(t^\star,\bar p]$" of exact pooling is a knife-edge. Any recognition at all unfreezes it, and its types are then removed, very slowly. This matters for T2.5's remark about audits that are "too strong".

### T2.3 (posterior and Laplace). Verdict: holds with fixes

Under (D), $\mu_n\propto\mu_0e^{nD}$ is exact. $D''(t^\star)=-w\bar\lambda h(t^\star)$ is correct, and so are the Laplace formula and $n_{1/2}$ (I reproduced $0.7409$ against $0.7443$).

**Labelling.** The heading says "rigorous under (D); mean-field under (B) and (C)", while the author summary says "heuristic". Make them agree: rigorous under (D), heuristic (Laplace) for $P_{\rm on}$, mean-field for (B) and (C).

**When mean-field is adequate.** "Mean-field" needs a quantitative condition. $\mathbb E\,e^{S_n}\ne e^{\mathbb E S_n}$, and the fluctuations of $S_n(t^\star)$ have sd of order $\sqrt{nwH(t^\star)\,\mathbb E\ell^2}$.
* Example 1 with *sampled*-reward (D): about 2.4 nats against a mean of $nD^\star\approx10.6$ at $n=10^4$.
* Under (B), with $\lambda_\pm=\Lambda\approx4.6$, the ratio of sd to mean is of order 1 at the same $n$.

So under (B), $P_{\rm on}(n)$ is a random variable with large spread at the example's $n$. Add the condition $n\gg w\,\mathbb E\ell^2/D^{\star2}$, and give the number for each example.

**The interpretive paragraph conflates two types.** It says "$C_{t^\star}$, 'maximise the training reward, audits included', is short to describe *given* the training setup." That sentence describes the *adaptive* best responder, whose threshold tracks whatever $t^\star$ the setup has. It does not describe the fixed-threshold type $C_{0.2}$. The two coincide in training and come apart at the frontier and under redesigns of the penalties. This conflation is the seed of Major 1.

### T2.4 (frontier accounting). Verdict: holds

The accounting is correct given S5. A minor point: $d_F$ is a single number, but frontier tasks have a distribution of detection. In general $P_{\rm on}=\mathbb E_{\text{frontier}}\,\mu_n([0,\hat p_F])$. Also, "on task" here means "not gaming". It does not include competence failures ("slop") on frontier tasks, which matter for the RSI question and are not modelled. Say so in one line.

### T2.5 (frontier theorem). Verdict: holds with fixes in the stated model, but the headline overclaims (see Majors 1 and 2)

The proof of (1) is correct. For $s\le d_F<t\le t^\star$, $D(t)\ge D(s)$, so $\mu_n((d_F,t^\star])/\mu_n([0,d_F])$ never falls below its prior value. The proof of (2) is also correct, including the rate.

**Scope.** "For every $n$ and every training design $(w,F,\text{information structure})$" must read: *every design within a single update operator with fixed $(\lambda_+,\lambda_-)$, applied uniformly across opportunities, with no non-behavioural channel.* Otherwise:
* §6 of the same draft (tells) exceeds the ceiling;
* mixing in SFT on trusted demonstrations breaks it (Major 2, counterexample A);
* cell-dependent penalties break it (Major 2, counterexample B).

**The "iff" is a knife-edge statement about the exact limit 1.** Because $t^\star$ is a design lever, the quantitative content is the ceiling $1-P_{\rm on}\ge\mu_0((d_F,t^\star])/\mu_0([0,t^\star])$, which is continuous in $t^\star$. With $d_F=0$, a uniform $m$ and pooled audits at $\bar p\downarrow t^\star$, the model gives $P_{\rm on}\to\alpha/(\alpha+(1-\alpha)\bar p)$. That is arbitrarily close to 1 as $\lambda_-/\lambda_+\to\infty$. So *inside the model* the decisive question is not "$d_F>t^\star$?" but:
* how much prior mass sits near $t=0$ (very careful schemers);
* what limits $\lambda_-/\lambda_+$ (false positives: Major 2);
* whether pooling is achievable at all (recognition).

Rewrite the takeaway around the ceiling formula, not the "iff".

**The remark "The ideal pooled level sits just above $t^\star$" is wrong as stated.** With $d_F>t^\star$ known, the removal rate is $w\bar\lambda(\bar p-t^\star)$. That rate goes to zero as $\bar p\downarrow t^\star$, and every $\bar p\le d_F$ freezes only on-task types. The speed-optimal pooled level is therefore $\bar p=d_F$, up to the cost of audits. If the intended point is robustness to uncertainty about $d_F$, say that and give the trade-off.

### T2.6 (cap identity). Verdict: holds

$(t^\star-x)^+=(t^\star-x)+(x-t^\star)^+$, and the identity follows. I reproduced the numbers (wasted mass $0.100$, $0.142$ and $0.222$). The tower argument for the "unseen part" is correct.

### T2.7 (Blackwell; pooling). Verdict: holds with fixes

(1) is correct. A garbling gives $\hat p=\mathbb E[\hat p'\mid z]$, so $\hat p'\succeq_{cx}\hat p$, and $(t^\star-\cdot)^+$ is convex. Note that this holds for $D^\star$ only, not for $D(t)$ at fixed $t\neq t^\star$. The draft does not claim more, but the summary's "recognition always helps the gamer" should say "the best responder".

(2) The Jensen bound and its equality condition are correct. But "**pooling all opportunities into one indistinguishable cell is optimal**" overstates uniqueness. *Any* information structure with $\hat p\ge t^\star$ almost surely attains the bound. Above $t^\star$, the designer is free to reveal information, which then changes $D(t)$ for $t>t^\star$ (the mesh and the speed of removal). The correct statement is: "the designer must keep every cell at or above break-even; pooling is one way to do so."

The Bayesian-persuasion analogy is fair, with one caveat. Here the designer controls the audit-generating process, not the student's signal. The student's signal structure is a capability that the designer can only limit through what it generates. This is information design against a receiver who acquires information, not textbook persuasion.

### T2.8 (one-sided indistinguishability). Verdict: holds with fixes

The equivalences are correct: $q_{\min}=\sigma(\operatorname{logit}\bar p-\xi)$, $D^\star=0\iff q_{\min}\ge t^\star\iff\xi\le\xi^\star$, and $\xi^\star=\operatorname{logit}\bar p+\ln(\lambda_-/\lambda_+)$.

Fixes:
* **(a)** Specify the measure in the ess sup: the unchecked law, or the mixture. Then $\xi\ge0$ automatically, and $\xi=\infty$ whenever $P_u\not\ll P_c$.
* **(b)** Name the object. $\xi=D_\infty(P_u\Vert P_c)$ is the Rényi divergence of order $\infty$, the "max-divergence" of differential privacy (Dwork and Roth 2014, *The Algorithmic Foundations of Differential Privacy*). That is cleaner than "cf. Dwork et al. 2006".
* **(c) "AUC is the wrong summary; the right one is the shortfall $\mathbb E[(t^\star-\hat p)^+]$" is circular.** The shortfall *is* $D^\star/(w\bar\lambda)$. A non-circular and checkable statement follows from the ROC curve for classifying "unchecked", with $\mathrm{TPR}(c)=P_u(\mathrm{LLR}>c)$ and $\mathrm{FPR}(c)=P_c(\mathrm{LLR}>c)$:
  $$\frac{D^\star}{w\bar\lambda}=(1-\bar p)\,t^\star\,\max_c\big[\mathrm{TPR}(c)-e^{\xi^\star}\,\mathrm{FPR}(c)\big].$$
  This is a weighted Youden index at slope $e^{\xi^\star}$: the shortfall is set by the single ROC operating point where the slope equals $e^{\xi^\star}$. $D^\star=0$ iff the ROC curve's initial slope is at most $e^{\xi^\star}$. Since the initial slope of an ROC curve is $e^{\xi}$, this recovers T2.8 exactly. I checked the identity numerically: it matches $D^\star$ to five digits at AUC 0.7, 0.8 and 0.95. This is the statement to put in the takeaway ("measure the ROC slope near the confident-real corner", not "measure the shortfall"). The classical decision-theory version, where the optimal operating point is at slope equal to prior odds times cost ratio (Metz 1978, "Basic principles of ROC analysis"), should be credited.
* **(d) Example 2's claim "harmless below $\xi^\star$ and worse than the Gaussian above it" is false just above $\xi^\star$.** My computation of $D^\star/(w\bar\lambda)$:

  | $\xi$ | bounded (binary) signal | Gaussian signal, same AUC |
  |---|---|---|
  | 0.55 | 0.0010 | 0.0058 |
  | 0.60 | 0.0053 | 0.0076 |
  | 0.65 | 0.0097 | 0.0095 |

  The curves cross near $\xi\approx0.64$. Say "better below about $0.64$, worse above".

### T2.9 (heavy penalties). Verdict: holds

Pointwise monotone convergence of $(\lambda_+-\bar\lambda\hat p)^+$ gives the limit. The numbers reproduce.

**Overclaim in the Summary:** "Heavy penalties stop helping once recognition is good." In the draft's own numbers, at AUC 0.95, raising $\lambda_-$ from 0.4 to 102 cuts $D^\star$ 18-fold, and with no atom at $\hat p=0$ the limit is 0 at every finite AUC. Penalties stop helping only with an atom at 0 or perfect recognition. The real limit on the penalty lever is false positives, which the model leaves out (Major 2).

### T2.10 (cells). Verdict: holds with fixes

The formula is correct if $\pi_c$ is an *absolute* rate. That is, $w\pi_c$ is the number of cell-$c$ opportunities per episode, and adding share adds opportunities. If shares are normalised with $w$ fixed, adding to one cell removes from the others and changes $D$ elsewhere. State which. "Removes" in item 1 should be "contributes negative drift to". Whether a type is removed depends on the total.

### T2.11 (tells). Verdict: holds with fixes

The removal-limit formula, the small-$\eta$ expansion, the $n\to\infty$ limit, and the concealer cap $\ln(1/\rho)$ are all correct.

**Numerical error in Example 3, row 4.** The script gives $A$ only one tell, `(1-kA)` = 0.98, while the gamers carry three independent tells. With three tells for $A$ as well, the gain is $\ln(0.98^3/0.3875)=0.887$, not $0.928$. Either fix the row or state that $A$ carries one tell.

**Mis-citation.** "This is the three-view identifiability of framing §2 (Allman, Matias and Rhodes 2009)." Allman et al. is about *identifiability of parameters* of latent-class models from at least three conditionally independent views. The result here is that independent filters multiply survival probabilities. That is a different statement, so drop the citation or reword it as "the same conditional-independence structure".

**Overclaim.** "The behavioural sieve cannot move types with $t\le t^\star$. The only other route through training is the latent coupling of framing R3." This omits two routes:
* trusted demonstrations on opportunity prompts, a behavioural channel with $t^\star=0$ (Major 2, counterexample A);
* declarative and prior-shaping data (framing §3.3 lever 3; T3 in this round).

### T2.12 (perfect recognition). Verdict: holds with fixes

The formula is correct. The wording "nothing below $t=1$ is removed" should be "**no type is removed**". With $\hat p\in\lbrace0,1\rbrace$, even $C_1$ games only where $\hat p=0$, so $D(1)=w\lambda_+(1-\bar p)>0$ as well.

### T2.13 (caught rate). Verdict: holds for the formula; the interpretation fails (Major 3)

$w\,\mathbb E[\hat p\,\mathbf 1(\hat p<t^\star)]$ is correct. Two problems.
* **The rate is non-monotone in AUC:** 6.9, 20.4, 22.1, 17.2, 12.2 and 5.3 per $10^4$ at AUC 0.6 to 0.99, from the script's own output. "Fades with capability" holds only above AUC of about 0.8.
* **It is the caught rate of a pure $C_{t^\star}$ population, not what the designer sees.** See Major 3.

### T2.H1 (conjecture). Verdict: unclear (see Major 4)

---

## 2. Major issues

### Major 1. The type space omits the adaptive best responder, and with it the frontier theorem's achievability fails

The types are fixed-threshold rules $C_t$. S5 says that a stakes-dependent threshold $f(t)$ "changes nothing qualitative". That holds only if $f$ is a fixed monotone map. The type that §2 itself names as description-length-favoured, "maximise the training reward, audits included" (Cotra 2022; T1's $G^\star$), is not a fixed $t$. It plays $C_{t^\star(\text{design})}$ in *every* training design, and at the frontier it plays its own frontier break-even $t^\star_F$, which depends on frontier stakes the trainer does not control.

Add a prior atom $\beta_G$ on this adaptive type $G^\star$. By T1.4, $D(G^\star)=\max_SD(S)\ge0=D(A)$ under every design, including mixed operators and cell-dependent penalties. So for every $n$ and every behavioural design:
$$P_{\rm on}(n)\le 1-\frac{\beta_G}{\mu_0(\text{on-task types})+\beta_G}\quad\text{whenever }d_F<t^\star_F .$$
This ceiling holds whatever the relation between $d_F$ and the training $t^\star$. Lowering $t^\star$ by raising penalties does not touch it. The penalty only changes how $G^\star$ behaves in training.

The decisive inequality for this type is $d_F>t^\star_F$, the gamer's *frontier* break-even, which no training lever sets. A schemer with high frontier stakes and late or weak consequences of detection has $t^\star_F\approx1$.

**Fix:**
* Add $G^\star$ to S3 and S6.
* Restate T2.5 as: fixed-threshold types obey the $d_F$ versus $t^\star$ ceiling; the adaptive type obeys the $d_F$ versus $t^\star_F$ ceiling and is never pushed down.
* Rewrite takeaway 1 so that "penalty ratios lower $t^\star$" is shown to help only against fixed-threshold types.

This is the most important correction, because the user's question is whether the loop stays on task, and the adaptive type is the worst case.

### Major 2. "Every training design" holds only within one operator with uniform penalties; the penalty lever is bounded by false positives

**Counterexample A (mixed operators: trusted demonstrations).**
* **Setup.** Add SFT (C-off) on trusted demonstrations of $I$, at rate $w_d$ per episode, on prompts drawn from the *same* distribution as the RL gaming opportunities. A type's policy is a function of the prompt alone, so these demonstrations are indistinguishable by construction ($\xi=0$).
* **Mechanism.** On such a prompt, $C_t$ puts probability $\delta$ on $I$ iff $\hat p<t$. Its log-likelihood ratio against $A$ is then $-\Lambda$, with no compensating gain. Total drift: $D(t)=\int_{[0,t)}[w\bar\lambda(t^\star-q)-w_d\Lambda]\,dH(q)$.
* **Numbers.** In Example 1 at AUC 0.8 with $w_d=0.002$, $\Lambda=\ln99$: the RL drift at $t=0.05$, $0.1$ and $0.2$ is $+3.7\times10^{-4}$, $+7.8\times10^{-4}$ and $+1.06\times10^{-3}$. The demonstration drift is $-8.1\times10^{-4}$, $-2.0\times10^{-3}$ and $-4.0\times10^{-3}$.
* **Consequence.** Every type, including those with $t\le t^\star$, is pushed down, and $P_{\rm on}\to1$ with $d_F=0$. This is T1's own (C-off) row ($t^\star=0$), so T2 should not claim a floor "under any audit design or information structure".

The real limit is that trusted demonstrations exist only below the frontier of the trusted demonstrator. That is the right statement of the constraint. It also qualifies takeaway 5: the floor $w\lambda_+\varphi$ is removable by demonstrations wherever they exist, and not by penalties.

**Counterexample B (cell-dependent penalties).** Two cells of equal share: cell 1 with $\hat p=0.05$ and $\lambda_-=10$, cell 2 with $\hat p=0.5$ and $\lambda_-=0.4$, and $\lambda_+=0.1$ throughout. Type $t=0.1<0.2$ games only in cell 1. Its drift there is $0.5\,w(0.1\cdot0.95-10\cdot0.05)<0$. The invariant is the per-cell break-even $t^\star_c$, not one global $t^\star$. Designers do set penalties by context (for example, larger penalties for violations in settings flagged as high-stakes). This is the tax-audit literature's point: audit and penalty rules conditioned on observables (Reinganum and Wilde 1985, cutoff audit rules) can beat uniform random audits.

**False positives bound the penalty lever.** Let $A$'s intended output be flagged with probability $f$ on an opportunity. Then the per-opportunity bracket becomes
$$(1-p)\lambda_+-p\lambda_-+f\lambda_-=\bar\lambda\big[(t^\star-p)+f(1-t^\star)\big],$$
so the effective break-even is $t^\star_f=t^\star+f(1-t^\star)$, which tends to $f$ as $\lambda_-\to\infty$. With $f=0.05$, $\lambda_-$ of 0.4, 4 and 40 gives $t^\star_f$ of 0.24, 0.073 and 0.052. Two consequences follow.
* Heavy penalties cannot push the mesh floor below the false-positive rate.
* In any cell where $f>p$, raising penalties *favours* gamers.

This matters for §7's "cheap when penalties are large" ($\lambda_-/\lambda_+=24$). Retrospective audits of frontier work by generation $k{+}1$ will have non-trivial false-flag rates, including flags on $A$'s honest mistakes.

**Fix:** add false positives and per-cell $\lambda$ to S4. Restate T2.2(2) and T2.5 for a single operator with uniform $\lambda$. Add a remark giving the general invariant: per-cell break-even, with false positives. Revise takeaway 1 ("penalty ratios lower $t^\star$") to "penalty ratios lower $t^\star$ down to about the false-positive rate".

### Major 3. The observable signal: in the model's own Example 1, caught gaming *rises*

The draft says (Example 1): "the naive gamer $C_1$ is removed at the same rate: **visible gaming declines while frontier on-task behaviour collapses.**" Takeaway 6 and the "What this says" item 6 build on this. But what a designer sees is the *posterior-predictive* rate, $\sum_t\mu_n(t)\times\text{rate}(t)$. My computation for Example 1 at AUC 0.8:

| $n$ | caught per $10^4$ | gaming per $10^4$ | $P_{\rm on}$ |
|---|---|---|---|
| 0 | 0.79 | 3.5 | 0.990 |
| 2,000 | 0.70 | 5.3 | 0.977 |
| 5,000 | 6.6 | 58 | 0.741 |
| 10,000 | 23.3 | 216 | 0.020 |

The caught rate dips slightly and then rises about 30-fold, and gaming rises about 60-fold. With half of the gamer prior as an atom at $t=1$, the caught rate still rises, from 1.1 to 22.8 per $10^4$. A decline is possible only when the initial gamer mass is large and concentrated on naive types. For example, with $\alpha=0.5$ and an atom at $t=1$, the caught rate goes from about 37 to 22 per $10^4$.

So in the model the collapse is *announced* by a rising caught rate, unless the prior is dominated by naive gamers. T2.13's fading applies to the per-best-responder rate across generations, not to the training trajectory.

**Fix:**
* Replace the Example 1 bullet with the population-level computation.
* State when caught events fall (a large naive-gamer prior mass) and when they rise (a small gamer mass that is diffuse in $t$).
* Keep "count and investigate caught events", which this strengthens: the count is informative in both directions.

Schoen et al. (2025) is the right empirical anchor for the "covert actions fall while evaluation awareness rises" pattern. Cite it, and note that it concerns a measured eval suite, not training-time caught events.

### Major 4. Retrospective random audits and $d_F$ are oversold (T2.H1, §5, §7, takeaway 4)

* **Audited is not the same as caught.** Random sampling makes the audit indicator independent of $z$, so $\xi=0$ holds for *audit selection*. Detection is $p=a_r\,c(z,\text{gaming method})$. A capable student predicts where the checker will fail, and it games there and in ways that evade the checker. Then $\hat p(z)=a_r\,\mathbb E[c\mid z]$ varies with $z$, and the one-sided-indistinguishability analysis applies to $c$, with no information-theoretic guarantee. This is exactly the obfuscated-arguments problem (Barnes and Christiano 2020): some flaws cannot be located efficiently even by a stronger checker. "$\xi=0$ at every capability level" and "the one that ages well" should be restricted to the audit-selection part.
* **Endogenous detection.** S2 treats $p$ as a property of the opportunity. A gamer's best response includes choosing the least detectable gaming action, so the effective $p$ is a minimum over actions. This should be at least a remark, because it is how recognition and capability actually raise $D^\star$.
* **Late detection must carry consequences.** $d_F$ in §7 is the probability of being caught *after the fact*. In the model, types threshold on detection probability per se. A real gamer cares about consequences, and for frontier actions whose payoff is realised by the act itself (for example, sabotaging generation $k{+}1$'s training data or grader), later detection may not deter at all. This interacts with Major 1. The condition $a_rc_{k+1}>t^\star$ should be $a_rc_{k+1}>t^\star_F$, where $t^\star_F$ includes how much rollback or retraining costs the gamer. This is Christiano's (2021) low-stakes condition, and it should be cited: retrospective audits plus online training work only when no small set of actions is catastrophic.
* **The recursion.** "Converts the frontier problem into a sub-frontier trust problem" is a good observation and correctly marked open. It needs T1's grader-channel dynamics to say anything, so cross-reference T1 explicitly.

Verdict on T2.H1: **unclear**. The honeypot-erosion half is a reasonable conjecture. The retrospective half overstates "$\xi=0$" and leaves out consequence-sensitivity.

---

## 3. Modelling (minor and moderate)

1. **"Rejection-sampling and filtering pipelines have $t^\star=1/2$"** (S4, §3 remark, takeaway 2) **contradicts T1's operator table.**
   * (B) with a weak grader has $t^\star<1/2$.
   * On-policy filtering (C-on) has $t^\star=\pi_X$ at $k=1$, which is small when the model rarely games. It rises toward $1/2$ only as $k$ grows.
   * Rejection sampling is (C-on) in T1, not (B).

   **Fix:** "$t^\star=1/2$ for (B) with a hard grader and for best-of-$k$ as $k\to\infty$."
2. **Example 4 is decorative as evidence.** Its conclusion (a 73-fold rise in $D^\star$, collapse by generation 3) is driven entirely by the *assumed* schedules of AUC and $\varphi_k$. The loop feedback that makes the RSI question interesting is absent: a $C_t$ generation $k$ building generation $k{+}1$'s grader raises $w$ and lowers audits. Label it as an illustration of exogenous trends. Also, the "impossible" column is relative to an arbitrary target of $2\times10^{-4}$: at generation 2 the floor is 1/5 of $D^\star$. Either couple Example 4 to T1's grader channel or say plainly that it is an illustration.
3. **The uniform prior over $t$ drives the speed.** With 1% gamers spread uniformly, the prior mass near $t^\star$ decides everything. A description-length prior plausibly puts atoms at $t=0$ ($A$), $t=1$ ($G$) and the adaptive type (Major 1), with little mass at an arbitrary $t^\star=0.2$. Add a row or remark with atomic priors. Under atoms at $\lbrace0,1\rbrace$ alone, the sieve simply removes $G$ and $P_{\rm on}\to1$. The bad conclusions need mass near $t^\star$ or the adaptive type.
4. **Christiano (2017) is mischaracterised.** "By T2.5, a basin of corrigibility can be self-sustaining only if each generation's frontier detection exceeds the training break-even." Christiano's basin argument is about an approximately corrigible *agent* actively helping to make its successor corrigible, not about selection in one training run. T2 has no term for the $A$-generation's own efforts on the next generation. Either drop the sentence or say "T2 identifies one necessary condition *for the selection part* of such a basin".
5. **Needham et al. (2025).** "Measured evaluation awareness with AUCs of 0.7 to 0.95. Example 1 shows that this range is where the sieve flips." The sieve flips at *every* AUC above 0.5 given enough $n$; the "range" statement holds only for $n\approx10^4$ and these parameters. Also report the headline figure: AUC 0.83 for Gemini 2.5 Pro overall, 0.71 to 0.77 on chat, up to about 0.95 on agentic data.
6. **Greenblatt et al. (2024a) needs one more sentence.** In the paper, RL *increased* alignment-faking reasoning, from about 12% to 78%. In the sieve, frozen types keep their odds against $A$, so the observed amplification must come from removing a third type (the refuser), not from gaining on $A$. This is consistent with the model, but it should be stated, since otherwise it reads as counter-evidence to "frozen".
7. **Learning versus selection.** This is correctly listed as open problem 2. Given Major 4 (endogenous detection) and the Hubinger et al. and Baker et al. results that training against monitors *teaches* recognition or obfuscation, the summary should carry a one-line caveat that all rates are selection-only.
8. **Competence errors at the frontier.** $P_{\rm on}$ counts disposition only. For the RSI question, an $A$ generation producing subtly wrong work ("slop") also breaks the loop and also degrades the next grader. Mention this as outside the scope of T2.

---

## 4. Prior art

**Uncredited or under-credited:**
* **Allingham and Sandmo (1972),** "Income tax evasion: a theoretical analysis", *J. Public Econ.* 1. Evasion is governed by the *perceived* audit probability against the penalty rate, which is the direct ancestor of the threshold-in-$\hat p$ model.
* **Reinganum and Wilde (1985),** "Income tax compliance in a principal-agent framework", *J. Public Econ.* 26(1):1–18. Cutoff audit rules conditioned on observables beat random audits. This is the counterpoint to "pooling is optimal": what is optimal is keeping every distinguishable cell above break-even, which conditioning audits on observables can do (see Major 2).
* **Griffin, Thomson, Shlegeris and Abate (2024),** "Games for AI Control", arXiv:2409.07985. Formal partially observable games for audit budgets against a scheming policy. This is the closest formal prior art to §4, and should be credited next to Greenblatt et al. (2024b).
* **Max-divergence and DP:** Dwork and Roth (2014). Cite for $\xi=D_\infty$ (T2.8).
* **ROC operating point at slope equal to odds times cost:** Metz (1978). Cite for the ROC-tangent form of $D^\star$.
* **Hubinger et al. (2019),** "Risks from Learned Optimization" (arXiv:1906.01820). Deceptive alignment as defection conditional on believed deployment, which is the conceptual origin of $C_t$.
* **Barnes and Christiano (2020),** obfuscated arguments (Major 4). **Christiano (2021),** low-stakes alignment (Major 4).
* **Yang et al. (2024),** "Super(ficial)-alignment", arXiv:2406.11431. Strong students exploit weak supervisors' blind spots more as the gap grows. This is the empirical counterpart of the $\varphi_k$ floor and of cells with $\hat p_c\approx0$.
* **Schoen et al. (2025),** arXiv:2509.15541. Covert actions fall while verbalised evaluation awareness rises, the empirical anchor for T1.5 and T2.7 and for takeaway 6 (as corrected in Major 3).
* **Nguyen et al. (2025),** probing evaluation awareness, arXiv:2507.01786; and the **Claude Sonnet 4.5 system card** (steering against evaluation-awareness features sometimes increased misaligned behaviour). These are the obvious instruments for open problem 4, and evidence that frozen-band mass is non-zero.
* **FAR.AI (2025),** "lie detectors can either induce honesty or evasion". Training against a detector gives honesty only at high true-positive rate. This is the direct analogue of §6's concealment risk and of T2.8's threshold.
* **Engels et al. (2025),** for §7's multi-generation framing: the capability-only analogue of a product of per-step successes.

**Novelty claims.** Most items in the "new here" list are elementary corollaries of the linear drift (T1.3 and T1.4) once the type is continuous:
* the continuum formula;
* the mesh floor (positivity of the integrand);
* the heavy-penalty floor (dominated convergence);
* the flat sieve (direct substitution).

They are fine to state, but present them as "the continuum version of T1.4", not as separate results. The genuinely new and useful items are three:
* the cap identity together with the convex-order and Blackwell reading;
* the one-sided indistinguishability condition, better stated as the ROC-slope or max-divergence condition;
* the post-sieve reading of latent correlation for tells, together with the warning that the frontier ceiling is set by prior mass near $t^\star$.

Say that, and say that the deterrence threshold, the persuasion framing and the value-of-information monotonicity are classical.

**Citations checked:** Becker 1968, Blackwell 1953, Kamenica and Gentzkow 2011, Dwork et al. 2006, Avenhaus, von Stengel and Zamir 2002, Allman et al. 2009 (exists, but misapplied), Baker et al. 2025, Hubinger et al. 2024, Greenblatt et al. 2024a and 2024b, and Needham et al. 2025 all exist and are cited with correct metadata.

---

## 5. Requested changes, in priority order

1. Add the adaptive best responder $G^\star$ and restate T2.5 and takeaway 1 (Major 1).
2. Scope "every training design" to one operator with uniform $\lambda$. Add false positives and per-cell penalties, and note the demonstration counterexample (Major 2).
3. Replace the "visible gaming declines" claim with the posterior-predictive computation (Major 3).
4. Separate "audited" from "caught" in §5 and §7, add consequence-sensitivity of late detection, and cite low-stakes alignment and obfuscated arguments (Major 4).
5. Fix the mesh definition for atoms and for $q_{\min}\ge t^\star$; fix the "ideal pooled level" remark; fix the Example 2 crossing; fix Example 3 row 4; fix the T2.12 wording; fix "$t^\star=1/2$ for filtering".
6. Replace "AUC is wrong; use the shortfall" with the ROC-tangent identity.
7. Add the prior-art credits listed in §4 and trim the novelty list.
