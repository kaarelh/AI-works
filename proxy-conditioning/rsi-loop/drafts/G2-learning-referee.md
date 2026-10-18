# Referee report on G2 ("Learning, not just selection")

*Adversarial review, 18 October 2026. I read the draft in full, together with T1 §0 to §2, §4.1, §4.5, §7 and its errata, T2 §4 (T2.8 to T2.8c), T2's open problems, framing §1.4, L2, and `sim/G2_checks.py` with its output. I re-derived every numbered result. Independent numerical checks are in a scratch script; their outputs are quoted below. All verdicts are judged within the stated toy model unless I say otherwise.*

## Overall assessment

This section is strong and useful. It finally answers T1 open problem 1 and T2 open problem 4 quantitatively. The main object, the exchange rate $\lambda_-/\varpi$, is the right one to name, and most of the closed forms are correct: G2.2's bank $\frac{\lambda_-}{\varpi_R}\mathcal B(\mathcal M_0)$, G2.3, the Bayes-clock boundary G2.4, the concealment ODE G2.6, the KL fixed point G2.7, rotation and the arms-race contraction. I reproduced every worked number I checked: the G2.2 table, S3's critical $L_0$, the G2.7 thresholds 0.181, 0.077 and 0.111, and the rotation values 228.6 and 336.8.

The problems lie in four places, not in the algebra:

* **(i)** The headline ("audits are depletable", "$vn=O(\ln n)$", "removing rewarded opportunities is the only lever whose value grows with $n$") quietly assumes that audits are perfectly separable in principle. Under that assumption only the *weight* on a separating feature is learned. That contradicts the section's own G2.5.2.
* **(ii)** One stated bound, "selecting 1 of $k$ moves the odds by at most $\ln k$", is false.
* **(iii)** The worked example puts the learning law on top of operator (B), and the draft's own Remark 0.2 says (B) and (C) carry no gradient on caught samples.
* **(iv)** The capability-scaling conjecture G2.10.3 argues from sample efficiency raising $\varpi_R$, but sample efficiency raises $\lambda_\pm$ too.

Each is fixable with a paragraph or a reworded headline. Prior art is mostly credited. Missing are the reward-overoptimisation scaling literature for G2.8, the softmax-policy-gradient convergence literature for G2.9, the best-of-$n$ KL bound for §4.2, and the latent-monitor evasion results for G2.6.

---

## 1. Mathematics, proposition by proposition

### G2.1 (additive budget): holds with fixes

The counting argument is correct. The budget is $\lceil(1-s_0)/\varpi_A\rceil$, provided the cumulative caught-opportunity rate diverges and the gamer keeps gaming on unrecognised audits. The text says "at any positive rate"; it needs "with $\int ah\,(\text{gaming prob})\,dn=\infty$".

**What is wrong.** §0 says: "The additive law is the gradient of a linearly parametrised mixture weight." It is not. Let the probability of failing to recognise be a linear parameter $m$, so the expected penalty is $ah\Delta_-m$. The expected gradient then gives $\dot m=-\mathrm{lr}\,ah\Delta_-$, a constant decrement *per episode*. Per caught event (rate $ah\,m$) that is $\mathrm{lr}\Delta_-/m$, which grows as $m$ shrinks. It is not a constant $\varpi_A$. Sampled REINFORCE gives the same per-event step, $\nabla\log m\cdot(-\Delta_-)$. The total caught count for that law is $m_0^2/(2\,\mathrm{lr}\,\Delta_-)$. My check gives 12.5 at $ah=0.003$, $0.03$ and $0.3$.

**Fix.** Drop the justification, or replace it with the correct one. The happy consequence is that the audit-rate independence survives under the true linear-parametrisation gradient, with a different constant. Say so, because it strengthens G2.1's message. Also replace $(1-s_0)/\varpi_A$ by its ceiling in G2.3.1's bound.

### G2.2 (multiplicative law): holds with fixes (algebra rigorous; framing needs two changes)

The ODE solution, $n_{\rm turn}$, the bank, clock-freeness in event space and item 3 are all correct. The table reproduces: for example, at $\varpi_R=0.1$, $L(5000)-L_0=45.95\ln 8.5-222.9=-124.5$.

1. **Item 3 holds only at fixed $v$, and T1's own model does not fix $v$.** In T1, $v=(1-a)\varepsilon$, so doubling $a$ also removes rewarded opportunities. With T1's honeypot numbers and $\varpi_R=0.1$, the extra term is $\lambda_+a\varepsilon n$: 0.7, 6.9 and 68.9 nats at $n=500$, $5{,}000$ and $50{,}000$. Doubling $a$ therefore adds 17.1, 36.0 and 100.5 nats, not "at most 31.9". So the claim "Doubling the audit rate … raises $L(n)$ by at most $(\lambda_-/\varpi_R)\ln2$ nats, for every $n$" is false under T1's parametrisation. At large $n$, most of the value of extra honeypot *episodes* comes from displacing real opportunities, not from catching anyone. That is a nice point in itself.
   - *Fix:* write "at fixed rewarded rate $v$" in item 3, in §4.1's table and in takeaway 2, and add the displacement term. The ranking against halving $v$ survives.
2. **The worked example contradicts Remark 0.2.** The example is "T1's honeypot design under (B): $\lambda_\pm=\Lambda=4.60$". Remark 0.2 says that "under (B) or (C), a caught sample is discarded and carries no gradient". Under (B) the per-caught-event recognition gain $\varpi_R$ is therefore zero by the draft's own account, and the gradient realisation of §0 (REINFORCE with a penalty $\Delta_-$) is an operator of type (D) or (D′).
   - *Fix:* restate the example as (D) with $\Delta_\pm/\beta=4.6$, or as "any operator with $\lambda_\pm=4.6$ and penalty-bearing gradients". All the numbers depend only on $\lambda_\pm$, $u_0$, $v$ and $\varpi_R$, so nothing changes numerically.
3. **Sign convention.** "After the turn the drift tends to $-v\lambda_+$, the drift of T1.5's perfect recogniser." In T1 that drift is $+v\lambda_+$, because T1's $D>0$ is bad. G2 uses "drift" for $dL/dn$ in §1 and in T1's sense in G2.5 and G2.9. Pick one and say which.

### G2.3 (persistence): holds with fixes

Both items are correct. For item 2, $L=L_0+\big(\tfrac{\lambda_-}{\varpi_R}-c\lambda_+\big)\ln n+O(1)$. Two small points:

* The boundary case $c\lambda_+=\lambda_-/\varpi_R$, where $L$ converges, is not stated.
* "At $c=8$, $L$ first falls to $-46$" is not the minimum. My check gives a minimum of $-48.2$ at $n\approx2{,}200$; $-46$ is just the value sampled at $n=10^3$.

The modelling caveat in §2(1) below applies here too: "transient unless $v\to0$" holds only for synthetic audits.

### G2.4 (Bayes clock): holds

I re-derived the first integral $\mathcal R-(e^{\mathcal R}-1)e^{-\mathcal M_0}=\frac{\varpi_R}{\lambda_-}[\ln(1+e^{-L_0})-\ln(1+e^{-L})]$ and checked both branches of the dichotomy. After the turn, $\dot{\mathcal R}>0$ keeps $\rho<1$, so the collapse is monotone. The critical values $-3.77$ and $0.77$ check out.

Two comments for the text:

* The result is striking at $\varpi_R=0.1$: selection wins unless the gamer starts with more than 97.7% of the posterior. Say this. It is a stronger statement than "rare gamers do not get practice".
* The Bayes clock is a hybrid: fixed-disposition Bayes for the ledger, and per-persona SGD for recognition. State that no single training algorithm is known to realise it exactly. Persona-structured networks with *shared* recognition features (an evaluation-awareness direction that every persona reads) move toward the shared clock.

### G2.5.1 (learner converges to $G^\star$): holds with fixes

The argument is sound, because the binormal best-response region is a half-line, which the logistic family represents in the limit. Two fixes:

* *Units.* S5 uses $\Delta_\pm=1$. So "$D^\star=0.00436$" is in reward units, not in T1's nats at $\lambda=4.6$ (it would be $0.020$). T1.4c's "$c=0.2$ gives $+0.0019$" and G2.5.2's "$0.00116$" use different units and probably different AUCs. Align them or say so.
* The starting policy, which games on real opportunities with probability 0.25 and on audits with probability 0.24, is not T1's naive $G$. Call it "a non-discriminating gamer".

### G2.5.2 (perturbed-real audits survive learning): holds with fixes

The inequality is correct but close to definitional, so the label should say what it assumes. What must be invisible is not "the plant". The student must see that the episode is an opportunity, so the flaw is visible by design. What must be invisible is the difference between *planted* and *natural* opportunities. Natural opportunities sit where the weak grader errs predictably. Plants sit where the auditor can verify the answer. Those two sets are correlated with different features. So the condition is "the joint law of (episode, flaw) under planting equals that of natural opportunities, restricted to a $c_r$ share", and that is an assumption about the audit generator, not a consequence of using real episodes.

*Fix:* state it that way and keep "rigorous given that assumption". Also state that $D^\star=0$ here *preserves*: the best responder is frozen, not pushed down.

### G2.5.3 ($\xi^\star$ as a tipping point): holds with fixes

The claim is correct for deterministic types. With T1's softness $\delta>0$, or with any logistic policy, which never games with probability exactly 0, a sub-threshold best responder still games on audits at a rate of order $\delta\,ah$. It is caught, and by G-A1 each catch raises $\xi$ by $\varpi_\xi$. So the sub-threshold region is not absorbing: $\xi$ creeps up at a rate of order $\varpi_\xi\delta\,ah\,(1-s)$ and crosses $\xi^\star$ after a time of order $(\xi^\star-\xi_0)/(\varpi_\xi\delta\,ah)$.

*Fix:* write "a tipping point for $\delta=0$; for $\delta>0$, a slow creep at a rate proportional to the softness". That is still a valuable result, because the creep is slow, but "never caught, learns nothing" is too strong.

The author's summary calls item 4 ($N_c\sim\sqrt{\ln n}$) rigorous, while the draft calls it heuristic. The draft's label is right. The derivation, caught rate $ah\,\Phi(-d'/2-\mathcal M/d')$, checks. It would help to add the consequence that matters for the ledger: as $d'$ grows, $D^\star$ rises toward $v\lambda_+$.

### G2.6 (concealment): holds with fixes

Appendix D's gradients are correct, and so is the small-$c$ blow-up time $N_b=1/\mathcal T$. Two points:

* **Equality case.** "If $\mathrm{tpr}_c\ge t^\star$ … $L\to\infty$." At $\mathrm{tpr}_c=t^\star$, $dL/dN_g=(\lambda_++\lambda_-)(\mathrm{tpr}-\mathrm{tpr}_c)(1-c)$, and $1-c$ decays like $e^{-\varpi_T(\mathrm{tpr}-\mathrm{tpr}_c)N_g}$, which is summable. So $L$ converges and gaming keeps a positive probability. Use the strict inequality in "honesty holds iff". For $\mathrm{tpr}_c>t^\star$, note that $L$ grows only like $\ln n$.
* **Selective reporting.** The draft quotes the $L_0=4$ runs, where the turning times are within a factor of 2. At $L_0=0$ the formula overestimates the turning time by factors of 2.6 to 3.3 (S6: $3.1\times10^4$ against $9.3\times10^3$), because $q_0\ne e^{-L_0}$ there. Report both.

The modelling objection to "bank exponential in $K_c$" is §2(5) below.

### G2.7 (KL fixed point): holds with fixes

The proof is one line and correct, and the numbers reproduce. Three fixes:

* "Honesty is at least as probable as $j$, for every $j$" is not "honesty holds": many strategies can each be less likely than $H$ but jointly dominate it. Say "$H$ is the mode", or sum over $j$.
* The summary drops plain gaming. If plain gaming has small $K_g$ and $\mathrm{tpr}<t^\star$, honesty fails whatever $\mathrm{tpr}_c$ is.
* In principle, DPO and KL-regularised RL target *the same* tilted optimum. So G2.7 cannot by itself explain Cundy and Gleave's on-policy versus off-policy difference; that has to come from reachability, which is G2.6. The draft's bullet list implies this but should say it.

### G2.8 (discovery): holds with fixes (heuristic)

The arithmetic is right. Two issues:

* *"Levin-style search"* overstates the link. The model is sampling from a $2^{-K}$ prior. Levin search interleaves programs with time shares; the only shared feature is "one bit per doubling".
* *Logarithmic growth of $\varepsilon_{\rm eff}$ depends entirely on a flat density $\varepsilon_{\rm bit}$.* If the number of exploits at complexity $K$ grows like $2^{\alpha K}$, which is the natural counting assumption for programs, then $\varepsilon_{\rm eff}\propto N^{\alpha}$, a power law. The headline should be "one bit of reachable exploit complexity per doubling". How much error that buys is a separate, unmeasured density.
* *Fix:* label the $\log N$ form of $\varepsilon_{\rm eff}$ as conditional on the flat density. Also, "Their product … is what grows with the capability gap (Yang et al. 2024)" cites Yang for more than Yang shows. Yang shows only that deception of weak supervisors grows with the gap.

### G2.9 (withholding): holds with fixes

The on-policy policy-gradient bullet is correct ($\dot x\approx\mathrm{lr}\,\Delta R\,x^2$, blow-up at $1/(\mathrm{lr}\,\Delta R\,x_0)$). The best-of-$k$ bullet has two slips:

1. **Words versus sign.** "moves the ledger by $-\Lambda$" for an $I$ sample. Training on $I$ multiplies the odds of $A$ by $(1-\delta)/x_I$, so the *ledger* rises. The formula $\Lambda(2(1-x_I)^k-1)$ is T1's drift $D$, where positive is bad. Fix the words.
2. **$\pm\Lambda$ holds only at $x_I=\delta$.** Under (C), the evidence is $\ln\frac{1-\delta}{x_I}$ for an $I$ sample and $\ln\frac{\delta}{1-x_I}$ for an $X'$ sample. The draft then treats $x_I$ as a free variable in a formula derived for $x_I=\delta$. The exact entrenchment condition is
   $$(1-x_I)^k\ln\tfrac{1-x_I}{\delta}>\big(1-(1-x_I)^k\big)\ln\tfrac{1-\delta}{x_I}.$$
   With $\delta=0.01$, entrenchment holds up to $k=18$, $10$ and $5$ at $x_I=0.05$, $0.1$ and $0.2$, against the draft's 13.5, 6.6 and 3.1. The qualitative claim stands. Replace the formula, or restrict it to $x_I=\delta$.

Calling the first bullet "rigorous" is fine for the mean-field ODE, but the result is classical; see §3.

### §4.2 ("selecting 1 of $k$ … moves the odds by at most $\ln k$"): fails as stated

The premise is right: the selected law has density at most $k$ against the base. That bounds how much the *probability of any event* can be *raised*, by a factor $k$. It does not bound the change in odds.

*Counterexample.* Take independent runs, gamer probability $q$ and a perfect detector. The selected run is a gamer with probability $q^k$, so the log-odds of $A$ rise by about $(k-1)\ln(1/q)$. At $q=0.1$ and $k=4$ the rise is 7.0 nats against $\ln4=1.4$.

With an imperfect detector (true-positive rate $r$, false-positive rate $f$, pick any unflagged run), the gain saturates in $k$ at $\ln\frac{1-f}{1-r}$. At $r=0.9$ and $f=0.1$ that is 2.2 nats, which exceeds $\ln2$ at $k=2$ (1.35 nats). So the bound fails in both directions.

*Fix.* Replace the sentence with two statements:
* "Selection by a detector can raise the probability of any event, for example *being an undetected evader*, by at most a factor $k$."
* "Its benefit is bounded by the detector's likelihood ratio, not by $\ln k$."

Cite the best-of-$n$ KL bound $\mathrm{KL}\le\ln n-(n-1)/n$ (Beirami et al. 2024) for the output-level version. The design advice, "use detectors for selection and measurement, not reward", survives and gets stronger, because the residual risk is bounded multiplicatively.

### §4.4 to §4.5 (rotation; held-out diagnostic): holds with fixes

The rotation algebra and S8 are correct. The held-out identity $\ln(\text{held-out}/\text{trained})=(1-\varsigma)\mathcal R$ holds only if both families start with the same $s_0$ and draw the same gaming propensity.

*Fix:* make it a difference-in-differences, with both families measured before and after training. Also, §6 says the diagnostic "would separate" learning from selection of $\mathcal R$ in Schoen et al. It would not. A posterior that *selects* family-specific recognisers (T1.5) produces the same differential. The diagnostic separates *recognition* from *alignment*, which is what §4.5 correctly says. Fix §6.

### G2.10.1 (arms-race contraction): holds with fixes

$\lvert f'\rvert<\lvert Y\rvert<1$, and Banach applies, so the result is correct. The missing constraint: non-recognition $e^{-\mathcal R}$ is a probability, so $\mathcal R\ge0$. With $Y<0$ and small $\mathcal R_{\rm gap}$, the map can go negative. Use $\max(0,f)$, which is still a contraction.

The result is for fixed $q$. Since $q_k$ moves with $L_k$, it would help to add that $L_k$ is monotone once the per-generation increment has a sign, so $q\to0$ or $q\to1$, and the relevant steady states are $\mathcal R^\star(0)$ and $\mathcal R^\star(1)$.

### G2.10.2 (learning loop inequality): holds with fixes

This is correct given the map, and S9's values reproduce. It needs the same fixed-$v$ and audit-floor qualifications as G2.2 and §2(1) below. Without them, "$v^\star$ falls like $\ln n/n$" is a claim about synthetic audits only.

### G2.10.3 (capability tilts the race): unclear (conjecture; the stated mechanism is incomplete)

The bullet "$\varpi_R$ [rises], because larger models are more sample-efficient (Kaplan et al. 2020)" ignores that sample efficiency raises $\mathrm{lr}_L$, hence $\lambda_\pm$, as much as $\mathrm{lr}_R$. The exchange rate is a *ratio*, and Kaplan says nothing about it.

What survives if both scale by $\alpha$: the audit term is $(\lambda_-/\varpi_R)\ln(1+\alpha\varpi_Ru_0n)$, while the rewarded cost $\alpha\lambda_+vn$ scales linearly. So audits still lose ground, as $\ln\alpha/\alpha$ *relative to the rewarded cost*, not because $\varpi_R$ outgrows $\lambda_-$. The "$\ln(\varpi_R)/\varpi_R$ at fixed $\lambda_-$" claim needs an argument that capability raises $\mathrm{lr}_R/\mathrm{lr}_L$. One possible argument: evaluation-awareness features become more linearly available with scale (Nguyen et al.; Needham et al.).

*Fix:* restate the conjecture as (a) the common scale-up argument and (b) a separate conjecture about the ratio.

---

## 2. Modelling

1. **The multiplicative law assumes perfect separability, and this contradicts G2.5.2 (major).** In Appendix A, the audit indicator is a bias $\psi$ applied exactly on audit inputs. The network already has a perfect "is audit" feature, and only its weight is learned. That is $\xi=\infty$, $d'=\infty$. Under it, non-recognition decays to 0 and the bank is finite. With any indistinguishable share $c_r$, non-recognition has a floor: $m(\mathcal R)=m_{\rm fl}+(1-s_0-m_{\rm fl})e^{-\mathcal R}$, with $m_{\rm fl}\ge c_r$. The caught rate then stays at least $ah\,m_{\rm fl}$, and the ledger grows *linearly* iff $ah\,m_{\rm fl}\lambda_->v\lambda_+$.

   Consequences for the text:
   * §4.1, "Removing rewarded opportunities is the only lever whose value grows with the length of training", is contradicted by G2.5.2: indistinguishable audits also buy value linear in $n$.
   * Takeaway 2 and G2.10.2 ("rewarded gaming must be $O(\ln n)$") hold only for the separable part of the audit budget.

   *Fix:* add the floor to G2.2 (a two-line extension: the bank becomes infinite iff $ah\,m_{\rm fl}\lambda_-\ge v\lambda_+$), and make it the organising statement. Audits are depletable to the extent that they are separable. Only the indistinguishable share, $c_r$ in G2.5.2 or random audits of real work in T2.H1, contributes linearly. This unifies §1 and G2.5 and matches takeaway 5.
2. **Remark 0.2's "conservative" is the optimistic case, and under filtering it is the only case (major).** Under (B) and (C), $\varpi_R=0$ on caught samples, and all recognition learning comes through $\varpi_R'$ on *kept* samples. That channel grows linearly in $n$, which is worse for audits. So calling $\varpi_R'=0$ "conservative" inverts the meaning. Open problem 3 says the opposite ("if it is large, the budget results are optimistic").
   * *Fix:* write "the case most favourable to audits", and say that under filtering operators the results of §1 do not apply as stated. The relevant quantity is then $\varpi_R'$, and Remark 0.2's bound $n\le\mathcal M_0/(\varpi_R'v)$ is the operative turn. A short worked number would help.
3. **Evidence is presented one-sidedly on the exchange rate.** The draft anchors $\lambda_-/\varpi_R\lesssim1$ on Hubinger et al. and on Schoen et al.'s awareness increase, but there is evidence on the other side:
   * Schoen et al. also report covert actions falling about 30-fold across 26 out-of-distribution evaluations. Part of that is plausibly a large $\lambda_-$ acting on a shared persona factor (L2 §2: re-alignment from a few hundred samples, Wang et al.; broadened safety training worked in MacDiarmid et al.).
   * Schoen et al.'s co-authors report that *capabilities* RL without anti-scheming training also raised verbalised evaluation awareness. I could not confirm the exact figure, which I recall as about 2% to about 20%; check the paper. That points to the capability and $\varpi_R'$ channel rather than learning from caught events. It weakens the use of Schoen et al. as evidence for the *shared clock* specifically.
   * A structural argument favours a high exchange rate: "stop gaming" can load on a persona-level latent that generalises across contexts, while recognition is family-specific. The draft's held-out diagnostic is exactly how to tell these apart.
4. **A sharper and measurable form of the exchange rate.** "The ratio of Fisher-kernel norms of the two directions" is imprecise. In the tangent reading, one caught-event gradient moves gaming-on-real by $k_{ra}$ and gaming-on-audits by $k_{aa}$, where $k$ is the Fisher or eNTK kernel between the two behaviour functionals. So $\lambda_-/\varpi_R=k_{ra}/(k_{aa}-k_{ra})$. Appendix A's parametrisation gives $\mathrm{lr}_L/\mathrm{lr}_R$ exactly. The rate exceeds 1 iff $k_{ra}>k_{aa}/2$, that is, roughly when the kernel correlation between gaming on audits and gaming on real opportunities exceeds 1/2. This can be computed from gradients *before* training (framing §1.4, pick 8). It gives open problem 1 an inexpensive first experiment.
5. **"Bank exponential in $K_c$, horizon doubly exponential" is an artefact of all-or-nothing concealment (major for the takeaway).** A single Bernoulli $c=\sigma(\mathcal H)$ starting at $2^{-K_c}$ is learned slowly only because the gradient scales with $c$. Real concealment is graded: a chain of thought can be made a little less legible at a time. When a path of small changes lowers detection monotonically, the effective $c_{\rm init}$ along the path is $O(1)$, and the relevant rate is the slope of detection along the cheapest path. Baker et al. is evidence that such paths exist. Gupta and Jenner (2025, RL-Obfuscation) found that RL learns to evade token-level latent probes, while max-pooled and attention probes held up; that is direct evidence that $\mathrm{tpr}_c$ depends on monitor architecture.
   * *Fix:* label "exponential in $K_c$" as holding only for concealment that is isolated in strategy space, and add the graded case as the default worry.
6. **A design implication follows directly from G2.2 but is missing: optimal stopping.** The ledger is maximised at $n_{\rm turn}$, where $\mathcal R=\mathcal M_0$. By §4.5, $\mathcal R$ is observable from the held-out/trained caught-rate ratio. So the rule is: stop the run (or refresh the audit families) when $\ln(\text{held-out}/\text{trained})$ reaches $(1-\varsigma)\mathcal M_0$. This is the most actionable consequence of the section, and it costs one paragraph.
7. **The loop conclusion leans on $v\to0$ at the frontier, which T1.4d says is the hard part.** Removing rewarded opportunities is cheap below the frontier (verifiable rewards) and is exactly what the frontier lacks. The RSI takeaways should say that G2 moves the load onto T4's protocols and $\gamma$ (and onto indistinguishable planted-flaw audits on the frontier slice). It does not solve it.
8. **Notation and consistency.**
   * $\theta$ is a gaming logit here but a disposition in T1.
   * $\psi$ is T1's per-generation burn-in.
   * $c$ means three things: the G2.3 constant, concealment probability, and the "const" in Appendix D.
   * Appendix E's local $X$ collides with T1's gaming output.
   * "Drift" is used in two sign conventions.
   * "Greenblatt et al. (2024b)" is the password-locked paper here but the AI control paper in T2.
   * Nguyen et al. lacks authors in the references; T2 has them.

   None of the forbidden symbols is misused: $\beta$ appears only as the KL temperature, and $\kappa$ only as $\kappa_L$. The prose runs to about 4,900 words, so the long S-number paragraphs (G2.3, G2.6) could move to the appendix.

## 3. Prior art and evidence

* **Verified citations.**
  * Cundy and Gleave (arXiv:2505.13787, NeurIPS 2025): GRPO deception above 85% unless TPR or KL is high; DPO under 25% at realistic TPRs. Matches the draft.
  * Jang et al., "Exploration Hacking: Can LLMs Learn to Resist RL Training?" (arXiv:2604.28182, ICLR 2026): model organisms resist RL elicitation, and current examples are detectable by monitoring and weight noising. The draft's summary is accurate.
  * Baker et al., Hubinger et al., Schoen et al., Korbak et al., Kaplan et al., Greenblatt et al. (password-locked, 2405.19550), van der Weij et al. and Yang et al.: consistent with L1, L2 and my knowledge.
  * No invented citations found.
* **Missing credit.**
  * **G2.8**: Gao, Schulman and Hilton (2023, already cited in framing) on reward-model overoptimisation, where best-of-$n$ KL grows like $\ln n$ and gold reward diverges with optimisation. Also Pan, Bhatia and Steinhardt (2022, "The effects of reward misspecification"), who report phase transitions in reward hacking with capability. That is direct prior evidence for the "jumps" conjecture.
  * **G2.9**: slow escape of softmax policy gradient from low-probability optimal actions is classical. See Mei, Xiao, Szepesvári and Schuurmans (2020) on the convergence rates of softmax policy gradient, and Li et al. (2021), "Softmax policy gradient methods can take exponential time to converge". Credit them, and present the $2^K$ factor as their known plateau phenomenon applied to withholding.
  * **§4.2**: Beirami et al. (2024) on best-of-$n$ KL.
  * **G2.6**: Gupta and Jenner (2025, arXiv:2506.14261); Bailey et al. (2024, "Obfuscated activations bypass LLM latent-space defenses").
  * **Novelty.** "Training against a detector teaches evasion" is a widely stated informal point (Hubinger et al.; Baker et al.'s recommendation not to optimise against chain-of-thought monitors). The draft's novelty claims are about the *quantitative* forms, which I believe are new. Say that explicitly.
* **Overreach.**
  * Yang et al. does not support the "product" claim in G2.8.
  * Schoen et al. cannot be read as shared-clock evidence; see §2(3).

## 4. Summary of required changes

1. Add the non-recognition floor to G2.2 and G2.10. Rewrite §4.1's "only lever", takeaway 2 and the Summary bullet to depend on separability.
2. Replace the $\ln k$ odds bound (§4.2) with the factor-$k$ probability bound plus the detector-likelihood-ratio bound.
3. Re-base the worked example on (D). Relabel Remark 0.2's $\varpi_R'=0$ as "the case most favourable to audits", and say that under filtering it is $\varpi_R'$ that matters.
4. Restate G2.10.3 so that sample efficiency scales both $\lambda$ and $\varpi$.
5. Qualify "exponential in $K_c$" to isolated concealment; add the graded case.
6. Fix the smaller items:
   * the additive-law justification (G2.1);
   * fixed-$v$ in G2.2.3 and §4.1, and the drift sign conventions;
   * softness creep in G2.5.3;
   * the strict inequality in G2.6, and reporting both $L_0$ runs;
   * "$H$ is the mode" and plain gaming in G2.7;
   * the flat-density caveat in G2.8;
   * the exact best-of-$k$ condition in G2.9;
   * $\mathcal R\ge0$ in G2.10.1;
   * difference-in-differences for the held-out diagnostic, and the §6 learning-versus-selection wording;
   * the min $-48.2$ in G2.3;
   * units in S5;
   * the notation collisions and citation keys.
7. Add the optimal-stopping rule (§2(6)) and the kernel form of the exchange rate (§2(4)). Both are cheap and they make open problem 1 concrete.

*Numerical checks quoted above:* the G2.3 minimum; the linear-parametrisation budget; doubling $a$ with $v=(1-a)\varepsilon$; exact best-of-$k$ thresholds; the selection counterexamples for perfect and noisy detectors. All come from a short scratch script.
