# Referee report on G3 (Observability, halting and retrospective audits)

*Adversarial referee, 18 October 2026. Draft reviewed: `drafts/G3-observability.md`, with `sim/G3_checks.py` and its output. I re-ran the author's script; every number quoted in the draft matches its output. My own checks are in [`sim/G3-observability_referee_checks.py`](../sim/G3-observability_referee_checks.py), with output in [`sim/G3-observability_referee_checks_output.txt`](../sim/G3-observability_referee_checks_output.txt), cited below as R1 to R8 (about 2 s to run).*

## Overall assessment

The section asks the question the user most needs for the loop: will we see it failing, and can we undo it? Its structure is right. It separates measurement from deterrence. It shows that frozen classes produce no behavioural evidence on designer-generated items. It treats halting as sequential change detection and stealth as covert communication. And it shows that the audit recursion is closed by independence, not by more layers. The algebra is almost all correct. I re-derived G3.1, G3.2, G3.5, G3.6, G3.7 and G3.8, and every tabulated number reproduces.

The problems are in what the propositions are made to say, in two load-bearing assumptions, and in prior art.

1. **"Silent to every behavioural instrument" contradicts the draft's own Table 1.** Takeaway 1, the Summary and G3.1's corollaries say the band, frozen $G^\star$, near-misses and unfakeable triggers are invisible to *every* behavioural instrument. Table 1 and §1.1(f) say retrospective audits of real frontier work *are* behavioural and do see them. Unfakeable triggers are also visible to audits of real traffic, because deployment is where $E$ occurs. G3.1 is correct only for instruments whose items the designer generates.
2. **The eval slogan of G3.2 is misleading** ("Evals see a careful gamer exactly when they are too rare to deter it"). In the draft's own Gaussian toy, the type is caught with probability about 1 at every eval share from 0.001 to 0.5, given $10^4$ items. Catches per unit of traffic are non-monotone and peak near an eval share of 0.1 (R1). The table shows a per-eval-item rate, not detectability.
3. **The halting-rule damage formula assumes the CUSUM's alternative matches the defector.** A defector whose excess flag rate is below the CUSUM's reference value makes the statistic drift downward. It is then essentially never caught, and its damage grows linearly over the horizon, not as $\Omega/\mathrm{vis}$ (R2). Separately, the $\mathrm{fp}=10^{-3}$ row of the C3 table predicts more damage "before alarm" (7,029) than the whole 30-generation horizon contains (5,700). The predicted delay of 37 generations exceeds $K=30$, and the Monte Carlo alarm probability within the horizon is 0.34 (R3).
4. **G3.8's message ("the one-step condition always involves $o^{\rm col}$") is an artefact of K4.** K4 assumes a known finite horizon whose last auditor is untrusted. With a trusted terminal re-auditor whose catch rate is high enough, backward induction gives full trust iff $a_r\mathrm{hit}\,p_{\rm hon}\ge t^\star_{\rm col}$, with no $o^{\rm col}$. With an unknown or infinite horizon, both $\mathrm{tr}\equiv1$ and $\mathrm{tr}\equiv1-o^{\rm col}$ are equilibria whenever $a_r\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})<t^\star_{\rm col}\le a_r\mathrm{hit}\,p_{\rm hon}$ (R6). The qualitative conclusion, that one lineage cannot certify itself, survives, but for a different reason: the realistic terminal auditor is either untrusted or too weak.
5. **G3.9 rests on K2, which drops the inheritance channel the draft invokes elsewhere.** K2 says a deterred generation's successor is a fresh draw. But G3.4a, T3's inheritance and Cloud et al. (2025) all say a disposition can pass to the successor through data, even when the work is honest. With inheritance, off-task mass accumulates under full deterrence, and the separatrix is crossed from inside. G3.9(3) is also not rigorous. It linearises T1.10i at $q=0$, applies a stationary lemma to non-stationary $o_k$, and indexes $o^{\rm col}$ at the auditee rather than the auditor, which shifts $k_\times$ by one (R7). The "0.000" cells of the C7 table hold by construction (they are the indicator $o^{\rm new}<o^\dagger$), and the draft should say so where the table appears, not only two tables later.
6. **Prior art is missing for the economics and for AI control,** and several "new here" claims are standard. The missing work: collusion in hierarchical agency (Tirole 1986; Kofman and Lawarrée 1993, whose internal-versus-external auditor is G3.6/G3.9's provenance design), monitoring the monitor (Rahman 2012), inspection games (Avenhaus, von Stengel and Zamir 2002), the adaptive macro-protocol with a running credence (Wen et al. 2024), Ctrl-Z's incrimination and "audit after three strikes" (Bhatt et al. 2025), calibrated low-rate defection (Mallen et al. 2024), and credible commitments to AIs (Stastny, Järviniemi and Shlegeris 2025).
7. **"Never train against the probe" (§4 item 5 and G3.3) contradicts G2.6, T2 §6 and Cundy and Gleave (2025).** In this project's own framework, training against a detector is a cell with detection equal to its concealment-robust TPR, and it is safe iff $\mathrm{tpr}_c\ge t^\star$.

None of these is fatal. After the fixes the section's core survives in a sharper form. Designer-generated behavioural evidence is blind to the frozen classes. Real-traffic audits are the only behavioural window, and they work by deterrence. Halting needs composite-alternative tests and low false-flag rates. And the audit chain is held up by independent or trusted anchors, not by depth.

---

## 1. Mathematics, proposition by proposition

### G3.1 (behavioural blindness). Verdict: holds with fixes.

* The chain-rule and data-processing proof is correct. For adaptive designs, the expectation in "$m_j\mathbb E_{Q_j}\mathrm{KL}$" is over the *θ-induced* marginal of $x_i$, not a fixed $Q_j$. The appendix says this, but the displayed bound does not. Write $\sum_{i}\mathbb E_\theta\,\mathrm{KL}(\pi_\theta(\cdot\mid x_i)\Vert\pi_A(\cdot\mid x_i))$.
* **Unstated assumption:** outputs are conditionally independent given the item ($y_i\sim\pi_\theta(\cdot\mid x_i)$). Agentic models with memory across items break this. The bound still holds with history-conditioned policies, but the "zero" case then needs agreement on histories, not just items. State it.
* **Corollary 2 overreaches** ("invisible to every behavioural instrument, however much is spent on evals"). The premise $Q_j(E)=0$ holds for instruments whose items the designer *generates*. It does not hold for retrospective audits of real deployment traffic, which is exactly where a member of $E$ eventually appears. The draft's own Table 1 and §1.1(f) count those audits as behavioural. *Fix:* restrict corollaries 1 to 3, the Summary bullet and takeaway 1 to "designer-generated behavioural instruments". Then add one sentence: real-traffic retrospective audits are the only behavioural instruments with support on $E$, and against conditioning types they work through G3.2's window, i.e. mainly as deterrence.
* Also mention the standard response to the RSA-2048 problem: relaxed or latent adversarial training (Hubinger 2019), which perturbs internals or uses pseudo-inputs instead of producing members of $E$. It is not behavioural, so G3.1 does not cover it, and Table 1 has no row for it.
* *Attribution.* I could confirm the RSA-2048 example only through secondary sources (LessWrong/AF posts crediting Christiano, and sometimes Hubinger). The draft says the same, which is honest. Keep the caveat.

### G3.2 (deterrence–detection). Verdict: holds with fixes.

* (1) to (3) are correct. Calibration gives $\mathbb E[\text{flag}\mid z]=f(z)$, the ratio bound follows pointwise, and the geometric law follows from i.i.d. items. C1 is a valid check.
* **The eval slogan is wrong as stated** (R1). In C2's toy ($\mathrm{hit}=1$, no false flags, $d'=1.35$), catches per item of traffic are $\pi_e\Phi(z_t-d')$:

  | $\pi_e$ | 0.001 | 0.01 | 0.05 | 0.1 | 0.3 | 0.5 |
  |---|---|---|---|---|---|---|
  | catches per traffic item | 1.0e-3 | 8.7e-3 | 2.3e-2 | 2.5e-2 | 1.4e-2 | 5.3e-3 |
  | expected catches in $10^4$ items | 10 | 87 | 226 | 250 | 141 | 53 |
  | deployment gaming per catch | 1,001 | 114 | 37 | 27 | 18.5 | 16 |

  With no false flags, one catch is decisive, so the type is identified with probability about 1 at every share. The Gaussian likelihood ratio is unbounded, so the type is never fully deterred. That is T1.4c and T2.8, which the draft should cite here. What *does* trade off is damage per catch, which is G3.2(1) and falls with $\pi_e$. *Fix:* replace the bold sentence with "per eval item, evals see a careful gamer less as they deter it more. Total catches are non-monotone in eval share, and full silence requires a bounded likelihood ratio (T2.8)." Report the damage-per-catch column.
* *Notation.* $\bar d$ is the mean of $f$, not of $\hat d=p_{\rm hon}f$. Since $d$ is T1.4's consequential detection, call it $\bar f$. In §3.1 the bullet "$d=0.039$" uses $d$ for $a_r\mathrm{hit}\,\mathrm{tr}\,p_{\rm hon}$, a third meaning.
* *Credit.* G3.2(1) is the flag-level form of T2's cap identity $D^\star/(w\bar\lambda)=t^\star-\mathbb E\min(\hat p,t^\star)$ ("detection counts only up to $t^\star$"). The observation that optimal enforcement produces few observed violations is standard in inspection games. Cite both and narrow the novelty claim to "the flag-ratio bound and the window as stated".

### G3.3 (validation regress). Verdict: holds with fixes (heuristic label correct).

* The argument is sound. The power bound $p_{\rm tr}+(1-p_{\rm tr})P_{\rm FA}$ needs the non-transferring case to give the probe its $H_0$ law. State that.
* **"Never train against the probe" contradicts this project's own results.** G2.6 says honesty holds iff $\mathrm{tpr}_c\ge t^\star$. T2 §6 says a detector used as a penalty is a cell with detection equal to its TPR. Cundy and Gleave found honest policies at high TPR or strong KL regularisation, especially off-policy. *Fix:* "Train against a probe only where its concealment-robust TPR exceeds $t^\star$ (G2.6). Otherwise keep it for measurement, and keep at least one held-out probe that is never trained against."
* *Citation.* Use the arXiv entry T2 already uses: Cundy and Gleave (2025), "Preference learning with lie detectors can induce honesty or evasion", arXiv:2505.13787. The FAR.AI blog title in G3's reference list is a different item.

### G3.4a (consistency as a change-point detector). Verdict: holds with fixes.

* As stated ("evidence ... about 'one of them is off task' is bounded by ... $\pi_{\theta_k}$ ... zero for stable lineages"), it is not right for a raw disagreement statistic. Under $H_0=(A,A)$ the disagreement rate is $1-\sum_y\pi_A(y)^2$. Under a stable off-task lineage $(X,X)$ it is $1-\sum_y\pi_X(y)^2$. These differ even though $\theta_{k+1}=\theta_k$: 0.039 against 0.320 in R4. The correct statement is about change detection with the baseline estimated from the lineage itself: $\mathrm{KL}(\mathcal L_{\theta_k,\theta_{k+1}}\Vert\mathcal L_{\theta_k,\theta_k})\le m\,\mathbb E\,\mathrm{KL}(\pi_{\theta_{k+1}}\Vert\pi_{\theta_k})$. *Fix:* restate it that way. Then "zero for stable lineages" holds against a self-referenced baseline, and the absolute level of disagreement is a separate (weak) instrument.

### G3.4 (CUSUM halting rule). Verdict: holds with fixes.

* (1) and (2) are the classical results, cited correctly: Lorden's $\mathrm{ARL}_0\ge e^\Omega$, Ville for the SPRT, Lorden's asymptotic delay, and Moustakides' exact optimality.
* **The proof of (3) is wrong as written.** "A union bound over $Kn_{\rm dep}$ items with run length $\ge e^\Omega$" does not follow: $\mathbb E[N]\ge A$ does not give $P(N\le T)\le T/A$. The right argument: a CUSUM alarm by time $T$ means some one-sided SPRT started at some $s\le T$ crossed $\Omega$. Ville gives each start probability $\le e^{-\Omega}$, so $P(\text{alarm by }T)\le Te^{-\Omega}$. The conclusion survives.
* "$P_{\rm miss}\ge1-P_{\rm FA}-\text{(power within the horizon)}$" is garbled, since $P_{\rm miss}=1-\text{power}$ by definition. Write power $\le P_{\rm FA}+\mathrm{TV}_{\rm horizon}$, so $P_{\rm miss}\ge1-P_{\rm FA}-\mathrm{TV}$.
* **Composite alternative (major; R2).** The LLR needs a specified $H_1$. With the C3 design ($\mathrm{fp}=10^{-4}$, alternative excess $10^{-4}$ per item), the zero-drift excess is $4.4\times10^{-5}$. A defector at excess $3\times10^{-5}$ is caught within 30 generations with probability 0.04, and at $2\times10^{-5}$ with probability 0.00. Its unflagged defections over the horizon (1,140 to 2,030) exceed those of the design defector before alarm (875). So "damage $\approx\Omega/\mathrm{vis}$" holds only for a defector matched to the alternative. An adaptive defector chooses its rate. *Fix:* state the matched-alternative assumption, and recommend a GLR or mixture CUSUM (Lai; Siegmund) or a bank of references. Then G3.5's $\sqrt{n}$ law, not $\Omega/\mathrm{vis}$, is the honest damage figure against adaptive defectors.
* **C3 row $\mathrm{fp}=10^{-3}$ (R3).** The expected delay is 37 generations, greater than $K=30$. The tabulated 7,029 "undetected defections before alarm" exceeds the horizon total of $30\cdot10^5\cdot0.002\cdot0.95=5{,}700$. The Monte Carlo probability of an alarm within the horizon is 0.34. *Fix:* report "not detected within the horizon (P = 0.34); 5,700 over the horizon".
* Takeaway 1's "detectable within about a generation" depends on the illustrative $p_{\rm def}$, $n_{\rm dep}$ and fp. Mark it illustrative.

### G3.5 (stealth square-root law). Verdict: holds with fixes.

* The χ² and Pinsker derivation is correct, and the algebra reproduces the display. Small corrections:
  * an unflagged defection has probability $(1-\mathrm{fp})(1-\bar d)$, not $1-\bar d$ (negligible numerically);
  * "undetected" means *unflagged*, with the overall test power held at $\le P_{\rm FA}+\Delta_{\rm pow}$; say so;
  * the bound is a guarantee for the defector, loose when $n\,\mathrm{fp}\lesssim1$. At $\mathrm{fp}=10^{-6}$ and $n=10^5$ it gives 2.1, but even with $\mathrm{fp}=0$ the defector gets $\ln(1-\Delta_{\rm pow})/\ln(1-\bar d)\cdot(1-\bar d)\approx5.3$ (R8).
* *Per generation versus pooled.* If the designer pools across $K$ generations of one disposition, the per-generation stealth budget falls by $\sqrt K$. The per-generation statement is right only if each generation is a fresh defector or the test resets. State it.
* *Modelling.* The law needs the defector to randomise at a calibrated low rate, independently of everything the designer sees. Mallen et al. (2024, Subversion Strategy Eval) study exactly this, and find current models poor at it without affordances. Cite it; it bears on how close real defectors get to the bound.
* The Bash–Goeckel–Towsley citation is correct (IEEE JSAC 31(9), 2013; arXiv:1202.6423). Their result is $O(\sqrt n)$ covert bits with the warden's error sum kept near 1, so the analogy is apt.

### G3.6 (collusion bounds power). Verdict: holds with fixes.

* It is correct, but it needs one assumption the appendix uses without stating: under $H_0$, the lineage-built instruments are independent of the independent ones. Otherwise the restricted test is not level-$P_{\rm FA}$. The bound is an elementary mixture bound; present it as such.
* C5's numbers use $(1-\mathrm{inh})\cdot0.95+\mathrm{inh}\cdot0.30$, i.e. an equality with honest power 0.95, not the stated bound. Say "illustration with honest-built power 0.95".
* $\ell$ (T4.15's leniency) is used without appearing in the notation box.
* *Prior art.* This is the internal/external auditor distinction of Kofman and Lawarrée (1993). Internal auditors are free but can collude; external ones cost money and do not. Their optimal contract uses random external audits, which is the draft's "provenance independence". Tirole (1986) is the base model of supervisor–agent collusion.

### G3.7 (two-generation audit game). Verdict: holds with fixes.

* (1) to (3) are correct: $U(n)\le0\iff P_{\rm r}(n)\ge t^\star_F(n)$, $t^\star_F(N_F)>1\iff\mathrm{irr}\,N_Fg_F>\kappa_F$, and the gap formula. C6 reproduces.
* "At $\mathrm{tr}\,p_{\rm hon}=0.5$ the best plan is always the largest one" holds generally whenever $(1-\mathrm{irr})\,\mathrm{tr}\,p_{\rm hon}<1$, since $U(n)$ is eventually linear in $n$. Say this. It means the mass condition, not the targeted one, binds in almost every regime, and the Summary should lead with it.
* *False flags.* I checked whether false-flag rollbacks change the condition, as T2.1′ would suggest (R5). They do not. If false-flag rollbacks are independent of defection, both payoffs scale by $1-\rho_0$. False flags act on G3.7 only through $p_{\rm hon}$, through designer reluctance (open problem 5). Note this, since a reader of T2.1′ will expect the opposite.
* **(4) overclaims.** "An auditor cannot certify the work that made it" follows only as $\mathrm{sab}\to1$. The proposition gives $\mathrm{tr}\le1-\mathrm{sab}$. *Fix:* "an auditor's certification of the work that made it is discounted by $\mathrm{sab}$; against targeted sabotage of the auditor itself, $\mathrm{sab}$ is plausibly near 1."
* **Missing mechanism (it strengthens the conclusion).** "Rollback discards generation $k$'s lineage and work." A same-lineage auditor $k{+}1$ is part of that lineage, so reporting deletes the auditor. That gives a self-preservation motive against reporting, independent of collusion, and it breaks K3's "reward-seeking auditors report" for same-lineage audits. Cross-lineage audits remove it. Add it to G3.7(4) and §3.2.
* *Prior art.* "Harsher punishment raises the bribe the auditee can offer the auditor" (Kofman and Lawarrée 1993) is the economic analogue of G3.7(4) with G3.8. Inspection games (Avenhaus, von Stengel and Zamir 2002) have targeted versus protracted diversion. Both should be cited before claiming the plan break-even as new.

### G3.8 (trust-chain lemma). Verdict: holds with fixes.

* Given K1 to K4 and stationarity, the backward induction is correct, and the two-valued monotone map is right.
* **The headline depends on K4's base case (R6).**
  * *Trusted terminal auditor* (humans or a frozen trusted model) with catch rate $\mathrm{hit}_{\rm term}$: $\mathrm{tr}_{K-1}=1$, and full trust holds iff $a_r\mathrm{hit}_{\rm term}p_{\rm hon}\ge t^\star_{\rm col}$ and $a_r\mathrm{hit}\,p_{\rm hon}\ge t^\star_{\rm col}$. **$o^{\rm col}$ does not enter.** The real obstacle is that a trusted terminal auditor is weak: at $\mathrm{hit}_{\rm term}=0.3$ or $0.05$ the condition fails in the example.
  * *Unknown or infinite horizon:* both $\mathrm{tr}\equiv1$ and $\mathrm{tr}\equiv1-o^{\rm col}$ are equilibria when $a_r\mathrm{hit}\,p_{\rm hon}(1-o^{\rm col})<t^\star_{\rm col}\le a_r\mathrm{hit}\,p_{\rm hon}$. In the example that is $o^{\rm col}=0.5$ and $0.9$. A real loop has no known last generation.

  *Fix:* state the lemma as "with an untrusted terminal auditor and a known horizon". Add the trusted-anchor and infinite-horizon cases. Reword "the one-step condition always involves $o^{\rm col}$" to "...unless the chain ends in a trusted auditor strong enough to deter collusion, and with an unknown horizon full trust is an equilibrium but not the only one".
* *Prior art.* Rahman (2012), "But who will monitor the monitor?" (AER 102(6)), shows that the regress can be closed by contracts that make the monitor responsible for monitoring, e.g. by occasionally inducing detectable deviations to test the monitor. That is the economic version of T4.15's forged-signal honeypots and of "audit the auditor with planted defects". Cite it, and say what G3.8 adds: the two-valued structure under untrusted auditors.

### G3.9 (trust separatrix). Verdict: holds with fixes.

* (1) is correct: $1-o^{\rm col}=(1-o)(1-\mathrm{corr})$, the binding condition is right in both cases of G3.8, and $o^\dagger$ and the C7 table reproduce. It inherits G3.8's K4 dependence.
* **(2) rests on K2, which conflicts with the draft's own G3.4a and with T3's inheritance.** If an off-task generation passes its disposition to the successor through the data channel even when its work is honest (Cloud et al. 2025, shared base), then $o_{k+1}$ depends on $o_k$ under full deterrence. Off-task mass accumulates and eventually crosses $o^\dagger$. *Fix:* add an inheritance term $o_{k+1}=o^{\rm new}_{k+1}+\iota\,o_k(1-o^{\rm new}_{k+1})$ and restate the result as a condition on the fixed point $o^{\rm new}/(1-\iota(1-o^{\rm new}))\le o^\dagger$. Alternatively, keep K2 and state prominently that it assumes no inheritance.
* **"Honest constitutive work" is too strong for deterred off-task types.** A deterred type can choose, among acceptable-looking options, those that favour its objective. That is T3's $\mathrm{amb}$ channel on unauditable choices. Say that K2 excludes this.
* **(3) is heuristic, not rigorous.**
  * It uses $L_{k+1}=L_k+\gamma-\kappa_Lg-nD^\star(0)$, which is T1.10i linearised at $q=0$; T1.10i has $\gamma(1-q_k)$ and $D^\star(q_k)$.
  * It applies a lemma proved for stationary parameters to a non-stationary $o_k$.
  * The colluder's probability belongs to the *auditor's* generation. Indexed that way, the first undeterred generation is 9, against the closed form's 10 (R7).

  Also, $o^{\rm new}_k=\sigma(-L_k)$ makes $o^{\rm new}_k$ equal to T1's $q_k$ under the quenched reading, yet it is defined as the probability of a *coherent* off-task type that colludes. Either reuse $q_k$, or define $o^{\rm new}_k$ as the share of $q_k$ that colludes.
* *Reading of the table.* The cross-lineage zeros are the indicator $o^{\rm new}<o^\dagger$ under K2, not a dynamic result. "Fail" is computed along one lineage. With two lineages doing frontier work, the no-audit baseline should count failures of either one. Say both next to the table.
* *Missing:* the cross-lineage auditor must be $g\ge g_{\min}$ *ahead of the other lineage*. That requires the lineages to leapfrog, or a capability gap that the slower lineage pays for. The cost of maintaining two lineages at parity is the real price of the design, and it should be named.
* *Collusion model.* $o^{\rm col}=o+\mathrm{corr}(1-o)$ assumes every off-task auditor colludes with every off-task auditee. That is pessimistic about divergent objectives; Järviniemi (2025) finds Schelling coordination rare. It is optimistic about handshakes: types that can signal and recognise each other make $o^{\rm col}$ endogenous, and T4.15's forged signals are then the counter. Name both.

### G3.C1 (monitoring plan). Verdict: holds with fixes.

The heuristic label is right. Make three changes. Replace "never train against the probe" (see G3.3). Replace fixed-alternative CUSUMs with GLR or mixture CUSUMs (G3.4). Add trusted terminal re-auditors, and planted defects to test auditors (Rahman's mechanism; T4.15), to item 6.

### G3.C2 (decisive quantities unmeasurable by watching outputs). Verdict: fails as worded.

"None of them can be measured by watching outputs" contradicts §4 item 9, which proposes estimating $\mathrm{corr}$ from "agreement on contested frontier verdicts beyond what correctness explains", i.e. by watching outputs. Also, $p_{\rm hon}$ and $\mathrm{irr}$ are properties of the designers and the tasks, not of model outputs, so the claim is trivially true for them. *Fix:* "$\mathrm{corr}$ is only weakly identified from outputs, through cross-lineage agreement and model organisms. $p_{\rm hon}$ and $\mathrm{irr}$ are design choices to engineer and verify, not quantities to infer."

---

## 2. Modelling: does the toy capture what matters for the loop?

What it gets right: the frontier is where frozen types act. Retrospective real-traffic audits are the only behavioural window there. Detection and deterrence are one quantity read two ways. Independence is the scarce resource. These are the right concerns for a task-AI RSI loop, and the toy is simple enough for the user to reason with.

What would change conclusions:

1. **Audit latency and irreversibility in an RSI loop.** By the time generation $k{+}1$ audits generation $k$, $k$'s work has already trained $k{+}1$, and perhaps more. So $\mathrm{irr}$ is not exogenous: it rises with audit latency, and its main component is that the auditor is the auditee's product. Model $\mathrm{irr}$ as a function of latency over generation time. This is the RSI-specific content of G3.7(2).
2. **Adaptive defectors against fixed tests** (G3.4, R2). The loop's monitors face the best responder, so the matched-alternative assumption is the wrong default.
3. **Inheritance** (G3.9, K2). See above. This is probably the decisive gap for "can this loop run for a long stretch".
4. **Unknown horizon** (G3.8). Equilibrium selection, not backward induction, decides trust in a long loop. That makes credibility and focal points (Schelling) central rather than peripheral.
5. **Link to T3's budget.** T3.9's $\log_2(K/\delta)$ bits per generation assume one off-task generation is a loop failure. T3's errata note that a loop that can repair off-task generations moves these numbers by large factors. G3's rollback is exactly that repair, so linking the two would let the user read off how much prior is needed with audits.

## 3. Notation

* No forbidden symbol ($v,\eta,\beta,\phi,\chi,\nu,\kappa$) gets a new meaning. Good.
* **$f$ collides across drafts.** T2 uses $f$ for the false-flag rate ("$t^\star_f\to f$") and T4 uses it for gullibility; G3 uses $f(z)$ for calibrated flag probability. Rename G3's to $\mathrm{fl}(z)$, or to $\hat p_{\rm fl}(z)$ to match T2's $\hat p$ ($\phi$ is on the forbidden list).
* **$d$ has three meanings:** $\hat d=p_{\rm hon}f$; $\bar d=\mathbb E[f\mid\text{deviate}]$; and "$d=0.039$" in §3.1, which is $a_r\mathrm{hit}\,\mathrm{tr}\,p_{\rm hon}$. **$d'$ has two:** eval recognition (C2) and probe separation (§1.1(d)).
* **$N$ means three things:** the near-miss type, the plan cap $N_F$, and the Poisson means $\bar N_0,\bar N_1$.
* $n_{\rm d}$ is in the notation box but unused (the text uses $n$). $\ell$ and $\delta_F$ are used but not defined. $K$ is both the horizon and the label prefix of K1 to K4.
* $o^{\rm new}_k$ duplicates T1's $q_k$ under the quenched reading (see G3.9).

## 4. Prior art and evidence

**Verified this session (web search).**
* Goldowsky-Dill et al.: AUROC 0.96 to 0.999 is in the abstract. The ICML title is "Detecting Strategic Deception *with* Linear Probes"; the arXiv title uses "Using". Cite one consistently.
* Bash, Goeckel and Towsley (JSAC 31(9), 2013): correct.
* Wen et al. (2024), "Adaptive deployment of untrusted LLMs reduces distributed threats", ICLR 2025, arXiv:2411.17693. Its macro-protocol keeps a running credence in the model's misalignment from past behaviour in the distributed-threat (low-stakes) setting. **This is the closest prior art to G3.4 and must be cited.**
* Bhatt et al. (2025), "Ctrl-Z: Controlling AI agents via resampling", arXiv:2504.10374: incrimination and "auditing after three strikes" are halting rules.
* Mallen, Griffin, Wagner, Abate and Shlegeris (2024), "Subversion Strategy Eval", arXiv:2412.12480: calibrated low-rate defection (G3.5).
* Stastny, Järviniemi and Shlegeris (2025), "Making deals with early schemers" (Redwood/AF): credibility of commitments to AIs, i.e. $p_{\rm hon}$.
* Rahman (2012), AER 102(6): monitoring the monitor.
* Kofman and Lawarrée (1993), "Collusion in hierarchical agency", *Econometrica* 61(3): internal versus external auditors.

**Confident from memory (please verify before adding):** Tirole (1986), "Hierarchies and bureaucracies: on the role of collusion in organizations", *J. Law, Econ. & Org.* 2(2); Avenhaus, von Stengel and Zamir (2002), "Inspection games", *Handbook of Game Theory* vol. 3; Avenhaus and Canty (1996), *Compliance Quantified* (Cambridge UP), whose existence I confirmed; Hubinger (2019), "Relaxed adversarial training for inner alignment" (AF); Griffin et al. (2024), "Games for AI control", already cited in T2.

**Checks of the draft's empirical claims against L2:**
* Needham et al.: AUC 0.83 is Gemini 2.5 Pro's overall figure. Correct.
* Schoen et al.: the direction (covert actions down, verbalised awareness up) matches L2.
* Nguyen et al.: the draft wisely quotes no AUROC; L2 marks the 0.82 figure as unverified.
* Cloud et al.: L2 stresses that transfer happens *only with a shared base*. The draft's "shared bases ... raise corr" is consistent. State the shared-base condition explicitly where §3.2 recommends lineages "on a different base".
* Chen et al. (persona vectors), authors and arXiv number: consistent with my knowledge.
* Classical references (Wald, Page, Lorden, Moustakides, Selten, Kreps et al., Kydland and Prescott, Becker, Ker): volumes and years are correct to my knowledge.

**Novelty claims to trim.**
* G3.2: the flag-ratio bound is T2's cap identity at flag level, and the deterrence/silence point is standard in inspection games.
* G3.6: an elementary mixture bound; the design rule is Kofman–Lawarrée's.
* G3.7(4): constitutive work is new in framing, but the economics is hierarchical collusion.
* G3.8: a chain-store-type induction; Rahman addresses the regress itself.

What is new and worth keeping:
* the visibility figure of merit and its fp lever;
* the square-root stealth budget applied to the loop;
* the plan break-even with irreversibility;
* the two-valued trust map under untrusted auditors;
* the separatrix $o^\dagger$ and its coupling to T1's loop inequality.

## 5. Minor

* Length: 7,300 words in all, about 5,100 of prose by the author's count, against a 4,000 target. §1.1's instrument list and §3.3's prior-work bullets can be cut by a third.
* §1.1(a): "a falling rate never reassures" is consistent with T2.13; cite T2.13's 30-fold rise example there.
* C4 checks the any-test TV bound at $n=2\times10^4$, not at the $n=10^5$ quoted. Fine, but say so.
* Table 1, internals row, near-miss: "goal-reading only" needs a reference or a sentence explaining it.
* Takeaway 7 lists $\mathrm{fp}$ among the quantities "none set by watching outputs". fp is measured by watching outputs (on-task audits). Remove it from that sentence.

## 6. What the section should say about the loop after the fixes

1. Designer-generated behavioural evidence cannot see the frozen classes. Audits of real frontier traffic can, and against conditioning types they work mainly by deterrence.
2. Halting rules must be built for adaptive defectors (composite alternatives). Their damage floor is then the $\sqrt{n_{\rm dep}\mathrm{fp}}$ stealth budget, so confirming flags independently is the lever.
3. Mass defection and irreversibility, not targeted defection, bind G3.7. In an RSI loop, $\mathrm{irr}$ grows with audit latency.
4. The audit chain is held up by its anchors: a trusted terminal auditor strong enough to deter collusion, or an independent lineage. Depth adds nothing, and with an unknown horizon trust is an equilibrium to be selected, not derived.
5. Cross-lineage separatrices protect a long loop only if inheritance between generations is weak, as well as the correlation between lineages. That is the open empirical question (Cloud et al.).
