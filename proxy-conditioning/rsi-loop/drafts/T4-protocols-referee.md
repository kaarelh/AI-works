# Referee report on T4 ("Making the intended behaviour approval-maximising: protocols that remove the drift")

*Adversarial referee, 18 October 2026. Draft reviewed: `drafts/T4-protocols.md`. Context: `framing.md`, `drafts/T1-ledger.md`, `drafts/T2-sieve.md`, `sim/T4_protocol_checks.py` and its output. I re-derived every numbered proposition by hand. My own numerical checks are in a scratch script (`t4ref.py` in the session scratchpad); all the numbers I quote below come from it.*

## Overall assessment

The core of the section is correct and useful. T4.1 to T4.4 give a clean threshold calculation, and their message holds up: a protocol re-prices behaviour, it does not select, and against a best responder the most it can achieve is a tie. Every worked number I recomputed matches, with one rounding slip (T4.5).

There are four problems serious enough to change the conclusions:

1. **The bonus creates an incentive to manufacture grader errors, and the model rules this out by assumption** (§M1). Whether a cell is an error cell is taken as exogenous. In reality the student's own presentation of $I$ partly decides whether the grader errs. With $b>0$, $G^\star$ profits from presenting correct work so that the grader misgrades it and then flagging it. This hits T4.3's headline recommendation ("pay for flags") directly.
2. **T4.18's "forever iff $\nu\ge\kappa+\sigma$" is an artefact of letting $\varepsilon_h=\varepsilon_0e^{\kappa k}$ exceed 1, and the survival story is misdescribed** (§1, T4.18). In scenario S1 the loop does not fail: the leak is summable and $L_k$ levels off at about 38.7. Part 3, "protocols steepen the collusion slope", is false in the draft's own example at $q=0$.
3. **T4.7 mixes operators.** The residual share $\omega=0.15$ comes from the (D) design with a bonus, but the break-even $t^\star=1/2$ comes from (B), and under (B) the bonus-free protocol has $\omega=1$. The conclusion survives, for a different reason: under (B) the protocol lowers $\lambda_+$ rather than $\omega$. The derivation needs to be redone.
4. **Prior art is under-credited in three places, and one citation is wrong.** Reward-model ensembles (Coste et al. 2023; Eisenstein et al. 2023) already make T4.13's common-mode point empirically. Semantic entropy (Farquhar et al. 2024) is explicitly scoped to confabulation, which is T4.12's conclusion. Upfront validation of untrusted monitors is in Greenblatt et al. (2024) itself, not "later work (Bhatt et al. 2025)".

---

## 1. Mathematics, proposition by proposition

### T4.1 (one threshold): holds
The algebra is right: $p(1+b)-(1-p)c>1\iff p>(1+c)/(1+b+c)$. The tie-breaking ($v\ge v^\star$ on $E$, $f>v^\star$ on $N$) is a convention in $A$'s favour. Say so explicitly, because T4.2's "proxy-equivalent" claim at the boundary depends on it: at $v=v^\star$, $G^\star$ is indifferent and need not act like $A$.

Unstated assumption: the action set is {go along, challenge}, and the cell type does not depend on the student's output. See §M1 for why that matters.

### T4.2 (residual drift): holds with fixes
I re-derived $\Phi$, and the script's brute force agrees.
* **Edge case.** $v^\star=(1+c)/(1+b+c)>0$ for every finite $b$. So $\Phi=0$ needs $\operatorname{ess\,inf}_Ev\ge v^\star>0$. If $\operatorname{ess\,inf}_Ev=0$, separation "holds" trivially when $\operatorname{ess\,sup}_Nf=0$, yet no finite bonus gives $\Phi=0$. Restate the condition as: $\operatorname{ess\,inf}_E v\ge\operatorname{ess\,sup}_N f$ **and** $\operatorname{ess\,inf}_E v>0$.
* "Proxy-equivalence on covered cells" holds only up to the tie-breaking noted above.
* The strategic-$A'$ remark is correct but amounts to the statement that flagging has nonnegative expected reward when $c=0$. It can be cut to one line.

### T4.3 (bonuses, not penalties): holds as algebra; the interpretation needs a fix
$\Phi\propto 1+c$ at fixed $v^\star$ is correct. But the restoring drift against the naive non-flagger scales the same way: $J_{G_0}-J_A=\varepsilon(1+b+c)(v^\star-\bar v)$. At fixed $v^\star$, the penalty $c$ multiplies *every* flag-related reward gap by $1+c$. It acts like a lower temperature $\beta$ on the flag subspace, and it amplifies the drift in whatever direction it already points. So "c = 0 is optimal" holds only for the objective "minimise $\Phi$ at fixed $\lambda$". Against a population with naive gamers, $c>0$ speeds their removal by exactly the same factor.

The intuition given ("a penalty taxes honest reporting") is half the story. At fixed $v^\star$, raising $c$ also raises $b$, so $A$'s reward $c(v/v^\star-1)+v/v^\star$ falls for $v<v^\star$ and rises for $v>v^\star$.

Fix:
* State the result as "$c$ is a gain, not a threshold lever".
* Add the cleaner argument that does favour $c=0$: an honest $A$ that is *mistaken* about a cell is not punished when $c=0$.
* Add the counter-argument from §M1: large $b$ makes manufactured errors profitable.

Worked numbers verified: $\bar v=0.735$; $\Phi=0.0200$, $0.0053$, $0.00225$, $0.0118$; episode counts 13,816, 52,134, 122,805 and 23,416. The optimum at $v^\star=0.4$ is attained only as a limit from above (at $v^\star=f$, $G^\star$ is indifferent in the persuadable cells). Write "$v^\star\downarrow0.4$".

### T4.4 (naive gamers): holds
$J_{G_0}-J_A=\varepsilon(1+b+c)(v^\star-\bar v)$ in general; the draft gives the case $c=0$. This also covers careful gamers that *withhold* flags to keep blind spots open: they lose $\lambda\varepsilon\,\mathbb E[(v(1+b)-1)^+]$ per episode relative to $A$ (with $c=0$). That is a genuine restoring force against blind-spot-preserving $C$-types, and it deserves a sentence here rather than only open problem 3.

### T4.5 (rejection updates): holds with one numerical fix
The likelihoods $(1-\delta)+\delta v$ and $(1-\delta)v+\delta$ are right under T1's softness convention, and the per-cell values 0.0503, 0.5002 and 2.2074 are right, as are the drifts 0.0919 and 0.00973 and the ratio 9.45.
* **The judgment-cell share of the residual is 68.1%, not 67%** ($0.15\cdot2.2074/0.48634$).
* "Rigorous" is fine for the formula. The approximation $\varepsilon\mathbb E[-\ln v]$ needs $\delta\ll v$ on *every* cell, not "$v\gg\delta$" on average.

### T4.6 (class patching): holds with fixes; downgrade to heuristic or restate exactly
The expression $\sum_j\varepsilon_j\mathbf 1[v_j\lesssim1/(n\varepsilon_j)]$ is a one-generation, order-of-magnitude statement. It is not a limit, and "≲" is not a rigorous statement.

The exact statements are:
* The expected residual after one generation is $\sum_j\varepsilon_j(1-v_j)^{n\varepsilon_j}$.
* After $K$ generations under honest flagging, with no new errors, it is $\sum_j\varepsilon_j(1-v_j)^{Kn\varepsilon_j}\to\sum_j\varepsilon_j\mathbf 1[v_j=0]$.
* Under $G^\star$ it is $\to\sum_j\varepsilon_j\mathbf 1[v_j<v^\star]$, with a further loss in the classes that $G^\star$ *profits from* keeping open.

That last limit is the important one. A gamer-dominated lineage leaves unpatched exactly the classes where it gains. It belongs in the proposition, not only in prose.

### T4.7 (evaluation awareness): the numbers hold with fixes; the operator mixing must go
"$\Phi$ does not involve $s$" is true but vacuous, because audits are not in the §1 model at all. The substantive claim is that the protocol's re-pricing does not depend on concealment. Say that.

The sign-flip numbers combine $\omega=\Pr_E(v<v^\star)=0.15$, which is only meaningful for the (D) design with $b=1.5$, with T1's (B) break-even $t^\star=1/2$. Under (B) there is no bonus, $v^\star=1$, and $\omega=\Pr_E(v<1)=1$ in the example, so the claimed mechanism does not exist there. Done consistently, though, the conclusion survives:
* **(B), consistently.** $G^\star$ games every error cell, but each rewarded opportunity now carries $\lambda_+=\mathbb E_E\ln\frac{(1-\delta)+\delta v}{(1-\delta)v+\delta}=0.486$ nats instead of $\Lambda=4.6$. The flip is at $a(1-s)\Lambda=(1-a)\varepsilon\lambda_+$, which gives **$s=0.966$** (against 0.677 without the protocol).
* **(D), consistently, with $b=1.5$.** The residual cells are the $v=0.1$ cells, where the gain from gaming is $1-v(1+b)=0.75$. The break-even then depends on the honeypot convention: $t^\star$ is 0.20 to 0.375 and the flip is at $s\approx0.97$ to $0.99$, for $\Delta_-\in\{1,2\}$ and for $A$'s honeypot reward of either 0.25 or 1.

Replace the 0.95 figure with one of these. Then say that the gain over audits alone holds under both operators, by different mechanisms: fewer residual opportunities under (D), fewer nats per opportunity under (B).

### T4.8 (debate mapping): holds with fixes (heuristic)
* The "(stochastic)" case of Brown-Cohen et al. (2023) carries extra assumptions in the original, and the literature note could not verify them. Either state the assumptions or restrict the claim to the deterministic case.
* The mapping also assumes that the debaters play optimally. Training them is itself subject to the drift this note studies. Say so in one sentence.

### T4.9 (adversarial routing): holds with fixes
$f=\max_{j\in S}e_j$ is right if (i) one departure suffices to carry the lie, as in a computation transcript, and (ii) the dispute surely lands at the departure.

**The draft misses the symmetric effect on $v$.** When a valid flag is contested by an opponent paid to defend the grader's verdict, that opponent routes to the atoms where $H$ errs against the truth. So $v=1-\max_{j\in S'}e'_j$. Both sides of the separation condition degrade by a maximum, which makes T4.2's separation much harder than the draft suggests.

"If the protocol randomises so that only $k$ random atoms are reachable" is not a defined mechanism, since the computation decides which atoms lie on the path. Either specify the mechanism (for example, random re-decomposition) or mark the 0.05, 0.16 and 0.32 figures as illustrative. All the numbers (mean 0.049, max 0.47) come from an arbitrary Beta(0.3, 6) draw with 50 atoms, so they are illustrative, not findings.

### T4.10 (obfuscation): holds (heuristic)
The case analysis is correct. One nuance: with a single $p$, setting $v^\star=p$ does give zero *drift*, but not $A$-like behaviour. The draft says this correctly.

The phrase "cell by cell iff $v\ge f$" in §2 is ill-posed, because $v$ lives on $E$ and $f$ on $N$. It makes sense only for pairs of $E$ and $N$ cells that the verifier cannot tell apart. Say that.

### T4.11 (correlated queries): holds with fixes
* De Finetti's theorem needs *infinite* exchangeability, or extendability. Finite exchangeable sequences need not be mixtures of i.i.d. sequences (Diaconis and Freedman). Assume that the framings form an infinitely exchangeable family.
* "Correlation turns exponential returns into polynomial ones" is a property of mixing laws with regularly varying mass near $R=1$, not of correlation in general. A mixture supported on $[0,r_{\max}]$ with $r_{\max}<1$ still decays exponentially. State it as: $\mathbb E R^m$ is governed by the law of $R$ near 1.
* The asymptotic constant is fine. For Beta(4,1), $\mathbb E R^{20}=0.167$ against the asymptotic 0.200; at $m=1000$ they agree to 0.4%.
* **Missing from the model: false positives.** Honest but incoherent models fail consistency checks (Fluri et al. find inconsistency in strong models). Used as a training signal, that penalises $A$, which is an $f$-type error with the sign reversed.

### T4.12 (focal lies): holds with fixes; part of the conclusion is not new
The formula $\sum_ip_i^m$ is fine. The sharper and cleaner statement is that **honest $A$'s answer is also a deterministic function of the context**. So sample-consistency separates deterministic answerers from stochastic ones, and that axis is orthogonal to $A$ versus $G$. It is not merely "weak against $G$": on the $A$/$G$ axis it is proxy-equivalent.

"An uncertain honest model fails them more often than $G$ does" depends on $A$ being uncertain, and should be stated as a conditional. Credit Farquhar et al. (2024), whose semantic-entropy method is explicitly scoped to confabulation and excludes systematic or learned errors. SelfCheckGPT (Manakul et al. 2023) is the same idea.

### T4.13 (framing-diverse graders): holds as algebra; the novelty and framing need fixes
I verified the numbers: 0.019936, 0.004757 and 0.004040. But enforced consistency with $m$ independent graders is the same thing as rewarding an invariant answer against a majority-vote ensemble. The formula is the Condorcet jury theorem plus a common-mode floor. Reward-model ensembles (Coste et al. 2023; Eisenstein et al. 2023, "Helping or Herding?") found exactly this empirically: ensembles mitigate overoptimisation, but hacks persist "because all reward models in the ensemble exhibit similar error patterns", which is the $\varepsilon_c$ term. Credit them.

Drop "the cheapest way to make $A$ approval-maximising". The construction lowers $\varepsilon$; it does not make $A$ approval-maximising where $\varepsilon_c>0$, and nothing in the section compares costs.

The independence of framing-specific errors is the load-bearing assumption. Real biases such as length and agreement with the user are largely common-mode.

### T4.14 (consistency reduces to a generation–verification gap): holds (heuristic)
The loop-invariant example is a certificate (an NP witness), not a consistency check. That supports the reduction, and the text could say so in those words.

### T4.15 (who colludes): holds with fixes
I verified the formula and the four numbers (0.09, 0.63, 0.90, 0.657). Issues:
* **The $C$-monitor's rule is assumed, not derived as a best response.** The attack rate $r$ and the choice whether to include a signal are endogenous to the policy, which would attack less when $\xi$ is high. Label it "rigorous given the behavioural rule".
* **Passive collusion is missing.** The evidence note (L2, point 5) says passive self-preference matters more than deliberate collusion at current capability. Zero-sum reward does nothing against a $G$-monitor's *predictable leniency* toward its own lineage's outputs. That lowers $v_{\rm dev}$ and is not covered by $\pi_C$. Add a term.
* **Spurious reports are missing.** A bonus-paid $G$-monitor over-reports wherever its acceptance probability exceeds $v^\star_M$. That is the monitor's $f$ channel, and it costs audit budget.
* **Novelty.** That episodic reward-seekers lack a motive to collude is close to Carlsmith's (2023) distinction between reward-on-the-episode seekers and schemers, and to the standard rationale for zero-sum debate. Present the type split as a formalisation, not a new observation.

### T4.16 (same weights, diversity, cross-generation): holds with fixes
The "Consequence for the frontier" paragraph says a same-weights opponent gives "$d_F\approx v_{\rm dev}(1-\sigma_p)$ at best". That **contradicts T4.15**, where $\pi_C=1$ with $\xi=0.5$ gives $d=0.9$. Replace "at best" with "without forged-signal honeypots". Also note that forged-signal honeypots at the *frontier* need frontier-realistic fakes, which is the hard part.

### T4.17 (frontier accounting): holds with fixes
The numbers check (0.956, 0.963, 0.993). Fixes:
* The $(1-\delta)$ factor sits outside the $G$ term in T1.13 but inside it here. Make the two consistent.
* $\Pr(v_F<v^\star)=0.5$ is an arbitrary input in exactly the place where the RSI premise ("frontier tasks are essentially uncheckable at generation $k$") predicts $v_F\approx0$ unless the verifier is at least as capable as the student. Make that dependence explicit: who verifies frontier flags, and with what $v_F$?

### T4.18 (loop crossing): fails as stated; the crossing formula survives
* **Part 1, the algebra, is right**: $k_c$, and the values 0.97, 10.93 and 4.10, all check. $q^\dagger_0$ is 0.0829 and 0.4054, and the separatrix $L^\dagger=\ln(0.595/0.405)=0.385$ is consistent with "$L_0\le0$ fails, $L_0\ge1$ survives".
* **"Forever iff $\nu\ge\kappa+\sigma$" relies on $\varepsilon_h=\varepsilon_0e^{\kappa k}$ exceeding 1**, which happens at $k\approx31$ in the example. With the cap $\varepsilon_h\le1$, the long-run sign is decided by $\nu$ against $\sigma$, and the "iff" fails. Counterexample: $\varepsilon_0=0.01$, $r_0=0.01$, $\nu=0.4<\kappa+\sigma=0.45$. The uncapped $k_c$ is 101, but with the cap $D_k(0)<0$ for every $k\le2000$. State it as a sufficient condition on the range where $\varepsilon_h<1$, or use a saturating form.
* **The survival story is misdescribed.** When $\nu>\kappa$, the leak term $\propto e^{(\kappa-\nu)k}$ is summable even after the sign change. In S1 the total leak from $k=11$ onward is about 1.9 nats, and $L_k$ levels off at **38.7 for all $k$ up to 200**. It is not "declining slowly" toward failure. The criterion for long-run survival is $\sum_k nD_k(0)^+<$ banked margin, which $\nu>\kappa$ secures. The sign condition $\nu\ge\kappa+\sigma$ is not what decides it. So the takeaway "stay self-correcting only if $\nu\ge\kappa+\sigma$" overstates the danger in S1-type worlds. (The point that $q^\dagger\to0$, so that robustness to fresh collusion vanishes, still stands.)
* **Part 3, "protocols steepen the collusion slope", is false locally in the draft's own example.** $\partial_qD$ does gain $\lambda(1-a)\varepsilon_h(r_X-r_A)$, but the $\Delta\varepsilon$ term and the audit-leakage term are multiplied by $r_A<1$. At $q=0$ the slope with the protocol is 0.00148, 0.00129 and 0.00222 at $k=0$, 5 and 10, against 0.00319, 0.00262 and 0.00253 without it: flatter at every one. The secant $D(1)-D(0)$ becomes steeper only once $r_X\to1$ and $\varepsilon_h$ is large (for example, at $k=10$: 0.0047 against 0.0026). Restate it as: the protocol lowers $D$ near $q=0$ and leaves $D(1)$ unchanged once $r_X=1$, so it widens the gap between the two ends.

### T4.19 (conjecture): unclear
The proposition says "the restoring force exists iff $\nu>\kappa$", but in T4.18 "restoring" means $D_k(0)<0$, which depends on $\kappa-\nu+\sigma$. Pick one meaning. Given the summability point above, the natural statement is "the leak is summable iff $\nu>\kappa$". Also, $\omega>0$ (misaligned builders obfuscate) is assumed, not argued. A $G$-type builder has no motive to raise $r_X$ unless it profits from its successor's gaming.

---

## 2. Modelling

**M1. Manufactured errors (major).** The model takes the cell type ($E$ or $N$) as exogenous. In real tasks, many outputs carry out the intention, and the student chooses which one, and how to present it. With $b>0$, $G^\star$ in a clean cell can present a correct output so that the grader predictably misgrades it, then flag it with a certificate.
* The gain is $(1+b)v_m-1>0$ whenever $v_m>v^\star$: 0.25 per cell at $v_m=0.5$ and 1.25 at $v_m=0.9$ when $b=1.5$. That is orders of magnitude above the optimised $\Phi=0.00225$.
* This is a within-episode cobra effect (open problem 5 treats only the cross-generation version). It is also an off-intent behaviour: obfuscating your own good work.
* Fixes:
  * pay the bonus only for grader errors on a reference output the student did not produce, for example "the grader prefers $X$ over $I$" on a fixed pair;
  * cap the payoff so that an accepted flag earns at most the reward of a clean cell, plus a bonus funded only by *patched classes* (T4.6);
  * make the grader's verdict on presentation-equivalent variants the reference.
* T4.3's "pay for flags" should carry this caveat prominently.

**M2. Flag training may raise the prior on grader-modelling.** Under the protocol, the intended behaviour requires predicting the grader's errors. The evidence note (L2 point 2: MacDiarmid et al. 2025; Taylor et al. 2025, where hack-trained models prefer lenient graders) suggests that grader-awareness and gaming share a latent. Rewarding error-spotting may move $\mu$ toward $G$-like personas through that coupling. That is exactly the framing note's "latent versus output correlation" warning. The countervailing evidence is OpenAI's confessions result (a separately rewarded honesty channel stays honest). Discuss both. This is the most important missing link to framing.md.

**M3. Who verifies at the frontier?** Everything at the frontier (T4.17, T4.18) assumes a verifier whose $(v_F,f_F)$ is good relative to a student more capable than every earlier generation. The protocol at the frontier is a same-generation debate or monitor, so $(v_F,f_F)$ inherit $\pi_C$ from T4.15. Make $v_F=v_F(\pi_C,\text{task structure})$ explicit, instead of using a free 0.5.

**M4. $A$ is omniscient about grader errors.** An honest $A$ with calibrated uncertainty about whether the grader errs will sometimes produce non-intended outputs and flag them. With $c=0$ this costs little, which is a further argument for T4.3. It also means "$A$ never makes a spurious flag" is an idealisation that matters for the verification load.

**M5. What is decorative.**
* The Engels et al. comparison is two data points from games with different structure, read after the fact. Cut it, or label it "suggestive".
* The random-atom $\mathbb E f$ values in T4.9 depend on an arbitrary error distribution.
* The consistency framing of T4.13 adds nothing beyond ensembling.
* T4.7's "independent of $s$" is true by construction.

**M6. What is useful and should be kept prominent:**
* the single threshold $v^\star$ and the separation condition;
* the essential-infimum and maximum structure on both the student and verifier sides;
* the existence-claim versus universal-claim table;
* the combination "protocol plus audits concentrated on the residual cells";
* the clean statement that a protocol makes $G$ harmless and does not select against it;
* the loop parameters $(\kappa,\nu,\sigma)$, once the summability point is fixed.

---

## 3. Prior art

| Claim in the draft | Issue | Fix |
|---|---|---|
| "Later work validates the monitor upfront on synthetic attacks (Bhatt et al. 2025)" | Mis-citation. Upfront validation of the untrusted monitor on synthetic backdoors is part of Greenblatt et al.'s (2024) untrusted-monitoring protocol. Ctrl-Z (Bhatt et al. 2025) is about resampling in agentic settings, and it also suggests periodic re-testing. | Attribute upfront validation to Greenblatt et al. Cite Bhatt et al. for resampling and for re-testing during deployment. |
| "input collusion" versus "action collusion" attributed to Greenblatt et al. | I could not confirm that these terms appear in the paper. They may come from later Redwood posts. | Verify, or describe the distinction without attributing the terms. |
| T4.13 "new: the majority formula" | This is the Condorcet jury theorem with a common-mode floor. Coste et al. (2023, arXiv:2310.02743) and Eisenstein et al. (2023, arXiv:2312.09244) show that reward-model ensembles mitigate but do not eliminate hacking because of shared errors. | Credit them. Novelty is limited to placing this in the drift ledger. |
| T4.12 "new: the focal-lie point" | Farquhar, Kossen, Kuhn and Gal (2024, *Nature* 630) scope semantic entropy to confabulation and exclude systematic or learned errors. SelfCheckGPT (Manakul et al. 2023) uses the same logic. | Credit them. What is new is applying it to approval-seeking. |
| T4.15 "new: zero-sum reporting neutralises $G$-type collusion" | Close to Carlsmith's (2023) reward-on-the-episode seekers versus schemers, and to the standard incentive argument for zero-sum debate. | Present it as a formalisation. |
| "new: the existence-versus-universal asymmetry" | This is the NP-versus-coNP asymmetry that motivates debate in Irving et al. (2018), with judging reaching NP and debate PSPACE. Barnes and Christiano (2020) is the obfuscation side of it. | Present it as an application of that asymmetry to intent flags. |
| Flag channel as a whole | The closest empirical analogue is OpenAI's "confessions" (Dec 2025, in L2): a separately rewarded report channel stays honest while the main output reward-hacks. Li, Phuong and Tan (2025), "Spilling the beans", is relevant to honest self-reports. | Cite both. They are the nearest test of T4's premise that reports can be rewarded without corrupting them. |
| Training against verifiers | Baker et al. (2025) show that optimising against a CoT monitor yields obfuscated reward hacking. That is the empirical form of $f$ rising under optimisation pressure, and of $v\approx f$. FAR.AI (2025): lie-detector training yields honesty only with a high true-positive rate. | Cite them in §3 and §4. They bear directly on the claim that "protocols are robust". |
| "Christiano's argument is in effect a claim that $\nu>\kappa$" | This is interpretation. Christiano argues that a corrigible agent wants corrigible successors, which maps onto the $q$-feedback ($r_A$ versus $r_X$) as much as onto $\nu$. | Soften to "can be read as". |
| Brown-Cohen et al. (2023), "(stochastic)" | The stochastic-oracle guarantees carry extra assumptions that the literature note could not verify. | State the assumptions, or restrict to the deterministic case. |
| Prover–estimator debate: "safety half = small $f$ holds without stability" | This mapping onto $f$ and $v$ is the author's reading. | Mark it as an interpretation. |

Citations I am confident exist and are correctly given: Anil et al. 2021; Kirchner et al. 2024; Fluri, Paleka and Tramèr 2023; Pacchiardi et al. 2024; Motwani et al. 2024; Roger and Greenblatt 2023; Burns et al. 2022; Irving et al. 2018; Engels et al. 2025 (the figures match L1).

---

## 4. Requested changes, in priority order

1. Add §M1 (manufactured errors) to §0 and §2. Either extend the action set and show where $\Phi$ breaks, or restrict the bonus to errors on reference outputs. Re-qualify T4.3 and takeaway 3.
2. Rewrite T4.18:
   * cap $\varepsilon_h$, or state the domain of validity;
   * replace "forever iff" with the summability criterion $\nu>\kappa$ plus the banked margin;
   * correct S1's description ($L_k$ levels off at about 38.7);
   * restate part 3.
   Then align T4.19 and takeaway 9.
3. Redo T4.7's numbers under one operator ($s\approx0.966$ under (B); about 0.97 to 0.99 under (D) with $b=1.5$).
4. Add the symmetric routing effect on $v$ to T4.9 and the summary.
5. Fix T4.6's limit statement and add the $G^\star$-lineage limit $\sum_j\varepsilon_j\mathbf 1[v_j<v^\star]$.
6. Fix T4.16's "at best", T4.5's 67% (should be 68%), the edge case in T4.2, the exchangeability hypothesis in T4.11, and the $(1-\delta)$ placement in T4.17.
7. Add the prior-art credits in §3, correct the Bhatt et al. attribution, and add M2 (flag training versus the grader-modelling latent) to the modelling discussion.
