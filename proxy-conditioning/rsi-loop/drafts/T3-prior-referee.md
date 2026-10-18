# Referee report on T3-prior ("Where the prior odds come from: description length and the race between pointers")

*Adversarial referee, 18 October 2026. I read `drafts/T3-prior.md` in full, `framing.md`, the model and drift sections of `drafts/T1-ledger.md`, and `sim/T3_prior_checks.py` with its output. I re-ran the key numbers; my checks are in a scratch script (not part of the repository), and the outputs I quote below come from that run. Three lenses: mathematics, modelling, prior art.*

## Overall assessment

The section asks the right question for the RSI loop: where the prior odds come from, and whether they can carry a long loop. Its best contributions are four:

* the slot model with the Kraft cap;
* the "prior must decide only the zero-drift directions" division of labour;
* speed turning grader ties into gaming opportunities;
* the self-written-data fixed point.

Most of the arithmetic is right: every worked number I re-computed matches.

The section has six substantive problems, in decreasing order of importance.

1. **The inert-slot criterion does not explain the Belrose–Pope parody (T3.4(3)).** The parody's free part, the behaviour off the training set, *is* inert on training. Under the draft's own criterion, counting would therefore be "valid" for the parody. The draft gets its contrast by redefining the memoriser as a disposition whose slot encodes the training labels, which is not the parody. A correct criterion exists and is close by, and I propose it below.
2. **The chain-rule argument for $\mathrm{amb}$ has a summation error and an unstated assumption (T3.3).** $K$ terms of size $O(1)$ sum to $O(K)$, not to $O(1)$. The bound also conditions on $W_{k+1}$ while its left side conditions only on $W_K$. "Bounded iff natural abstraction" is not derived.
3. **The draft never combines its own results, and the combination reverses a headline.** T3.3 says the near-miss class $N$ has log-odds $\log_2(2^{\mathrm{amb}}-1)$ against $A$. T3.9 needs $\Delta K\ge\log_2(K/\delta)$ against every zero-drift class, $N$ included. Together they require $\mathrm{amb}\lesssim\delta/(K\ln 2)$, that is $5\times10^{-4}$ bits for $K=30$ and $\delta=1\%$. Likewise, T3.13 combined with T3.9 needs $\nu_I/\nu_R\ge K/\delta$, which is 3,000:1. "About 12 bits suffice" is therefore not the operative conclusion. In a self-writing loop with any $\mathrm{amb}$, the prior cannot carry the zero-drift classes either, unless compartmentalisation is extreme and intent extrapolates essentially without ambiguity.
4. **T3.1's invariance is vacuous at the scales the section uses.** The constant $c$ between universal machines is plausibly hundreds to thousands of bits. Every quantity in the section is tens of bits: the cap, $\log_2(K/\delta)$, the fixed point. So "trends are invariant" buys nothing at $K\le100$ generations. The author's summary also turns "invariant under change of universal machine" into "does not depend on the prior", which is false. The prior that matters is SGD's, and T3.1 says nothing about it.
5. **"Rigorous" is attached to propositions whose content is a modelling guess.** In T3.8 the formula is T1.6, but the "tens of bits" cap that drives the conclusion is an illustrative assumption. T3.12 assumes the student can compute the $\arg\max$ of the grader, which is a search problem, not a time-$\tau$ evaluation. T3.6 writes $\varepsilon_{\rm eff}=\varepsilon+\varepsilon_{\rm tie}$ with mismatched units, and it holds only under (D).
6. **Inconsistent definition of $A$.** In P1 and §3, $A$'s slot is the concept $I$. In §2.1 and T3.13, $A$ is the correct extrapolation $I^\star$, with cost $\ell(I)+\mathrm{amb}$. The Kraft cap, the criterion "$A$ beats $C$ iff $\ell(I)<\log_2(1/f)$", and the T3.8 cap all change when $\mathrm{amb}$ is included.

Prior art: the draft omits Christiano's 2018 "Open question: are minimal circuits daemon-free?" (the origin of the minimal-circuits argument it credits to Hubinger 2019). It omits the strongest empirical anchor for T3.12, Marks et al. 2025: a model trained on documents describing reward-model biases exploited held-out biases. It omits Shah et al. 2022 and Langosco et al. 2022 for the near-miss class, and Carlsmith's term "reward-on-the-episode seeker". The novelty claim for "counting and simplicity are one calculation" should be softened: Hubinger 2022 and the replies to Belrose and Pope already treat counting as measure under the inductive bias. The Kraft saturation and its use as a cap on shaping are the new parts.

---

## 1. Mathematics, proposition by proposition

### T3.1 (trends invariant, levels not). Verdict: holds-with-fixes

> "$\Delta K_k$ moves by at most $2c$, and the per-generation change $\Delta K_{k+1}-\Delta K_k$ by at most $4c$, *uniformly in $k$*."

The algebra is correct, and so is the criterion "$b\gg 4c/k$" for a cumulative trend. Three problems.

1. **The guarantee is vacuous at the scales the section uses.** $c_{UU'}$ is the length of an interpreter, so for "emulate architecture X on machine Y" it is hundreds to thousands of bits. The section's quantities are 10 to 40 bits. A 30-generation loop that loses 1 bit per generation moves $\Delta K$ by 30 bits in total, which is below $4c$. T3.1 therefore certifies none of the section's trend claims, including T3.14. *Fix:* say so explicitly. The section's numbers are statements about a *fixed* reference prior (the network's implicit prior, or $K^{\rm circ}$ for a fixed architecture), not about universal-machine invariance. Present T3.1 as a remark about asymptotic statements only.
2. **Overclaim in the author's summary.** "Statements about trends across generations therefore do not depend on the prior" is false. They do not depend on the choice *of universal machine*. They depend heavily on whether the prior is $K$, $Kt$, $K^{\rm circ}$ or SGD's, as the draft itself says in the last sentence of T3.1. *Fix:* replace "the prior" with "the universal machine".
3. **$Kt$ claim.** "The same holds up to lower-order terms": this depends on the simulation overhead. With $O(t\log t)$ simulation the extra term is $\log\log t+O(1)$, which is lower order. With quadratic simulation, as for a one-tape machine simulating a multi-tape one, it is $\log t$, the same order as the time term. *Fix:* say "for machine models that simulate each other with quasi-linear overhead".

A smaller point: P1 to P2 work with a slot prior $\rho_k$, not with $K$. T3.1 applies to $\rho_k$ only if $\rho_k=m(\cdot\mid W_k)$ restricted to slots, and that should be stated.

### T3.2 (Kraft cap). Verdict: holds

Both parts are correct and trivial, as the draft says. The Monte Carlo check (2b) is decorative: it tests a two-line inequality. The random "prefix-free" codes are actually random lengths normalised to Kraft sum at most 1, which is all that matters, but the label is inaccurate.

The substantive caveat is in the proof's last sentence: "If the wrappers differ, add the difference in wrapper lengths to both bounds." The whole "tens of bits" conclusion of T3.8 rests on P1's shared core, meaning that $G$, $C$ and $A$ differ only in the slot. If grader-modelling or detection is wrapper machinery that $A$ lacks, which is a natural reading of $C_t$, the cap is $\ell(S)+\Delta_{\rm wrapper}$ and can be much larger. *Fix:* carry $\Delta_{\rm wrapper}$ explicitly into T3.8, and say that "tens of bits" holds under P1's shared core.

Consistency: if $A$'s slot is $I^\star$ (§2.1), part 1's cap is $\ell(I)+\mathrm{amb}$, not $\ell(I)$ (see T3.4).

### T3.3 (extrapolation cost). Verdict: holds-with-fixes

The identity $\mu(N)/\mu(A)=2^{\mathrm{amb}}-1$ is correct, given $\ell(I):=-\log_2\rho(E)$, where $E$ is the class of extrapolations that agree on checkable tasks, and $N=E\setminus\{I^\star\}$. Four problems.

1. **Summation error.**

   > "If intent is a natural abstraction … then each term is $O(1)$ and $\mathrm{amb}$ stays bounded."

   The chain-rule bound sums $K$ terms. $O(1)$ terms give $O(K)$, which is linear growth, exactly the case the draft contrasts with. Boundedness needs either summable terms (tending to 0) or a *direct* bound $K(I^\star_K\mid I,W_K)=O(1)$. The latter is what a natural-abstraction hypothesis would actually assert, and it does not go through the chain at all. *Fix:* "If intent is a natural abstraction, then $K(I^\star_K\mid I,W_K)=O(1)$ directly, and $\mathrm{amb}$ stays bounded. The chain-rule bound alone gives only $O(K)$ even when each step is $O(1)$."
2. **Unstated assumption.** The bound conditions each term on $W_{k+1}$, but $\mathrm{amb}_K$ conditions only on $W_K$. You need $K(W_{k+1}\mid W_K)=O(1)$, for example nested world models, which a fresh-pretrained successor need not satisfy. The $O(\log K)$ overhead is right for self-delimiting concatenation, given that assumption. One more step is needed: $\mathrm{amb}$ is defined through $\rho$ (conditional on the class $E$), not through $K$, so you also need $\rho=m(\cdot\mid W)$ and the coding theorem for the conditional.
3. **"iff" is not derived.** An upper bound cannot give the "only if" direction. Growth of the sum does not imply growth of $\mathrm{amb}$.
4. **The asymmetry with $G$ is mis-explained.** "$G$ has no analogous term because its referent is a concrete program." $G$ is just as ambiguous on frontier tasks: which grader, which version, human raters or reward model, the counterfactual grader when none is run. This is the familiar spread of reward-seeker variants. The real asymmetry is that *on-task is a singleton (or a small tolerance set) and off-task is a class*. Splitting $G$'s mass among variants does not change the mass of the off-task class, while splitting $A$'s mass removes on-task mass. *Fix:* restate the asymmetry that way. Also define $\mathrm{amb}$ relative to a *tolerance set* of acceptable extrapolations, not a unique $I^\star$, otherwise benign near-misses are counted as off task.

The status line also disagrees across the draft. The body says "rigorous given P1; heuristic as a model of ELK", while the author's summary says "heuristic". The identity is rigorous; the chain-rule paragraph is heuristic at best until fixed.

### T3.4 (counting versus simplicity). Verdict: holds-with-fixes; part 3's reading fails

Parts (1) and (2) are correct. I re-checked the worked numbers: $\ell(I)=17.04$ bits; the true log-odds are 13.60, 13.66, 13.69 and 13.70, against a cap of 13.72; the naive count runs from 7.7 to 57.7 bits. Two small notes. At small $m$ (block 10), naive counting *understates* the true advantage (7.7 against 13.6 bits), so the claim "naive counting overstates" holds only asymptotically ($m\gtrsim16$). Say so. Also, "A beats C at the prior iff $\ell(I)<\log_2(1/f)$" should read $\ell(I)+\mathrm{amb}+\Delta_{\rm wrapper}<\log_2(1/f)$ under the draft's own §2.1 definition of $A$.

**Part (3) and its reading are the main mathematical-conceptual problem.**

> "Memorisers do not [have inert slots], so the parody fails for a reason that can be stated."

In Belrose and Pope's parody (confirmed from the post), generalising and overfitting networks *both fit the training data*. The counted freedom is in the behaviour off the training set. That freedom is inert on the training distribution in exactly the draft's sense: every member behaves the same on $D$. Under the draft's criterion, then, counting would be "valid" for the parody, and the criterion fails to separate the two cases. The draft gets its contrast by redefining the memoriser as one whose slot encodes the training labels. That is T1.2's noise memoriser, a different object, and the cost $2^{-K(\text{labels}\mid W)}$ applies only when the labels are incompressible given $W$.

**A criterion that does separate them**, close to what the draft already has: decompose each rival into (i) a training-relevant part and (ii) an inert part.

* Counting multiplicity in the inert part always saturates (Kraft). That kills naive counting in *both* arguments.
* What remains is the cost of the *breadth* of off-distribution deviation.
  * An overfitter that deviates on $m$ test inputs needs on the order of $m$ bits of exception table. Broad deviation is exponentially expensive, and the class "deviates somewhere" is a union of tiny pieces, so the expected deviation rate per input is small. This is why Solomonoff-style predictors generalise despite the counting argument.
  * A schemer deviates on *every* frontier task through a single $O(1)$-bit wrapper decision, plus a goal whose multiplicity is inert and saturated.
* The formal content of the dispute is therefore: **is the rival's off-distribution deviation produced by a bounded switch (systematic) or by per-input free bits?**

This keeps the draft's conclusion that the schemer case and the parody differ, and gives the correct reason. *Fix:* rewrite part (3) and the reading, and correct the summary line "counting is valid exactly when the slot is inert".

The persona numbers check out (7.0 bits; $-4.7$ bits).

### T3.5 (speed drift). Verdict: holds-with-fixes

I re-derived the closed form and the numbers: $g_0=0.536$, and $D^{\rm spd}(G)=1.547\times10^{-3}$ at $g=2$. Three problems.

1. **Inconsistent overhead.** Assumption S charges $G$'s grader-modelling overhead $o_R$ only on the sound slice. On the unsound slice $G$ must also model the grader to know that $\tilde X$ passes. With overhead on both slices, the factor $c_k/c_{k+1}$ becomes 1 and $g_0=0.550$ instead of 0.536. The difference is small, but the assumption should be consistent or justified.
2. **"Approximately, for $g\ll c_k$":** with $c_k$ held fixed, the break-even condition is *exact*, because $c_{k+1}$ cancels. The approximation arises only if $c_{k+1}$ is held fixed (then $g_0=0.573$). Say which is held fixed.
3. **"Three times T1's (D)-operator drift" is not meaningful as stated.** $\kappa_t=0.01$ nats per bit of log-runtime and $\lambda_+=0.05$ nats per opportunity are independent free parameters, so the ratio of 3.1 is a choice, not a finding. *Fix:* express both in the same reward units ($\kappa_t$ and $\Delta_+$ both divided by $\beta$), or drop the comparison.

A modelling note on S: "$t_G=t_A(1+o_R)$ on the sound slice" assumes $G$ computes the intended output and then also models the grader. $G$ could instead search directly for passing outputs, and then its cost relative to $A$ depends on whether intent inference or grader modelling is dearer. The draft's closing "Verdict on speed" acknowledges this sign dependence. That caveat belongs inside assumption S.

### T3.6 (ties become opportunities). Verdict: holds-with-fixes

> "So the effective predictable-error rate becomes $\varepsilon_{\rm eff}=\varepsilon+\varepsilon_{\rm tie}$."

This mixes units. Tie episodes carry evidence $\lambda_+^{\rm spd}=\kappa_t\log_2(t_I/t_{\tilde X})$, not T1's $\lambda_+$. *Fix:* write $D=\varepsilon\lambda_++\varepsilon_{\rm tie}\bar\lambda_+^{\rm spd}$.

The result also holds only under (D), or any operator whose reward includes the speed term. Under (B), Bayes on passing, a tie is still evidence 0. T1.1 is not contradicted: once speed is in the reward, the episode is not a tie in $J$. State the operator, and note that the result is near-tautological once phrased that way. Its value is practical: grader indifference plus a length or compute penalty is a gaming signal. The practical point is good.

### T3.7 (cheapest schemer; compile trade-off). Verdict: holds (heuristic)

The numbers check out (48,285 and 144,855 episodes). The heuristic label is right. Note that $A$ has no detector, so a fully compiled schemer and $A$ are speed-equivalent. That is the real conclusion: speed separates $A$ from $C$ only through a *transient* overhead. The prior-art credit should start with Christiano (2018), "Open question: are minimal circuits daemon-free?", which Hubinger (2019) answers. The draft cites only Hubinger.

### T3.8 (prior meets ledger). Verdict: holds-with-fixes

The formula $n^\star=\Delta K\ln2/D$ is T1.6, and the table and "721 bits per generation" are correct, as is the bound $D\le1.39$ to $2.77\times10^{-5}$ nats per episode.

1. **The rigorous label covers a guess.** Consequence 2, the "tens of bits" cap, is what makes the proposition bite, and it rests on P1 (shared core, so no $\Delta_{\rm wrapper}$) and on an illustrative $\ell(R)\approx20$ to 40 bits ("roughly $\log_2$ of a feature dictionary"). *Fix:* split T3.8 into a rigorous part (the formula and the bits-per-generation identity) and a heuristic part (the size of the cap).
2. **Units of the (D) ledger.** Under KL-regularised RL the converged policy is $\mu e^{J/\beta}$, and the tilt is set by $1/\beta$, not by the episode count (framing R4: "under (D) the role of $n$ is played by $1/\beta$"). "$n\times D$" with $n=10^6$ episodes presumes a tilt that keeps growing with episodes, which is T1's modelling choice. T3.8 should say that the budget is spent in units of total tilt, so a practical lever is the KL anchor itself. This is a T1 inheritance, so it is a minor point here.
3. **Re-issue is not independent of inheritance.** "If each generation is pretrained afresh … the prior is re-issued at $\Delta K_{k+1}$." By T3.12 and T3.13 the re-issued $\Delta K_{k+1}$ is a function of generation $k$'s outputs. The draft notes this ("by §2 and §7 the re-issued $\Delta K_k$ shrinks"), but the "Prefer re-issued priors" recommendation in the loop section should be qualified: re-issue helps only if the pretraining corpus is not dominated by the loop's own output.

### T3.9 (zero-drift classes, union bound). Verdict: holds-with-fixes; the headline needs revision

The union bound and its numbers are right: 10.0, 11.6 and 16.6 bits. Four problems.

1. **Combine with T3.3.** $N$ is one of the listed zero-drift classes, and $\log_2\frac{\mu(A)}{\mu(N)}=-\log_2(2^{\mathrm{amb}}-1)$. This is *negative* once $\mathrm{amb}>1$ bit. Meeting $\Delta K^{(N)}\ge\log_2(K/\delta)$ requires $\mathrm{amb}\le\log_2(1+\delta/K)$: $1.4\times10^{-3}$ bits for $K=10$ and $\delta=1\%$, $4.8\times10^{-4}$ bits for $K=30$, and $1.4\times10^{-5}$ bits for $K=100$ at $\delta=0.1\%$. So the prior "decides" the near-miss direction only if intent extrapolates essentially unambiguously, or if $N$ is redefined as the non-acceptable extrapolations (the tolerance-set fix in T3.3). This is the most decision-relevant consequence in the section, and it is missing.
2. **Combine with T3.13.** With the self-written-data fixed point, $\Delta K\to\log_2(\nu_I/\nu_R)-\mathrm{amb}$. Meeting T3.9 requires $\nu_I/\nu_R\ge K/\delta$: 1,000 for $K=10$, 3,000 for $K=30$, and $10^5$ for $K=100$ at $\delta=0.1\%$. "Compartmentalise grader-building content" should carry this number.
3. **The mixture reading needs more bits.** Under the persona or mixture reading, each frontier *task* samples a persona. If any single off-task frontier action is serious, the requirement becomes $\log_2(K N_{\rm tasks}/\delta)$: 24.8, 31.5 and 38.1 bits for $10^4$, $10^6$ and $10^8$ frontier tasks per generation ($K=30$, $\delta=1\%$). "The same bits bound the per-task off-task rate" is true but understates what the loop needs.
4. **Open Problem 7 misstates the union bound.** "The union bound in §5 assumes that generations draw independently." It does not: the union bound holds under any dependence. What dependence affects is the *marginals*. A generation that is off task builds its successor's grader and data, so $\Delta K_{k+1}$ is a random variable that depends on the history. The clean fix: $\Pr(\bigcup_k F_k)\le\sum_k\Pr(F_k\mid\text{no earlier failure})$. So use $\Delta K_k$ *conditional on all earlier generations being on task*. That is both correct and the natural quantity. Rewrite Open Problem 7 and the author's summary item on "correlated draws" accordingly.

### T3.10 (declarative data as conditioning). Verdict: holds

The result is correct given its assumption that $\pi_A(y)=\pi_G(y)=\pi_C(y)$ on the declarative examples. The proof is tautological once that assumption is granted, and the draft should state the assumption as such. One sub-claim needs care: "only for a learner that is naive about where its data comes from." Changing $W$ under P2 (salience) needs no naivety. Any learner whose world model updates on corpus frequency is affected. Naivety matters for the *direction* of the change: a training-aware learner may read the documents as evidence about the trainer. Separate the two.

### T3.11 (shaping by corpus share). Verdict: holds-with-fixes (heuristic)

The numbers check out (16.71 and 23.36 bits; $\ell_{\rm after}\ge\log_2(1/\varphi)$). Two problems.

1. **Calibration against the one data point the draft cites.** Tice et al. (2026) moved misalignment from 45% to 9% by upsampling. That is 2.11 nats, or 3.0 bits of log-odds, and after post-training 46% to 35%, which is 0.46 nats or 0.66 bits. The salience model predicts 10 to 23 bits for small $\varphi$. Either the realised pointer change is far smaller than P2 says, or pointer length maps to behaviour much less than one-for-one. Add this comparison: it is the only quantitative test of P2 available, and P2 overshoots by about an order of magnitude.
2. **An extra assumption.** P2 defines salience as a "share of W's predictive work". T3.11 equates it with corpus share. State that as an assumption.

The claim that Tice et al. found upsampling positive discourse more effective than filtering negative discourse is supported. The paper reports that filtering added only marginal gains, which largely vanished after post-training.

"Character training … does not touch $\mathrm{amb}$" is too strong. Character data that specifies behaviour in novel or ambiguous situations, as constitutions do, is aimed exactly at $\mathrm{amb}$ through $W$. The draft's next sentence half-concedes this. Make it "need not touch".

### T3.12 (inheritance). Verdict: holds-with-fixes

Part 1 is correct and trivial. Part 2 has three problems.

1. **Search versus evaluation.** "Output $\arg\max$ of the simulated grader … within time $\tau$": evaluating the grader takes $\tau$, but *finding* the output the grader prefers is a search over outputs, which can be exponentially costlier. *Fix:* require that the student can find, within budget, an output the grader prefers whenever one exists among outputs it can generate. Say "the predictable error rate equals the fraction of the grader's deterministic errors that the student can both compute *and* reach".
2. **Realism of $c$ small.** A neural grader's verdicts are determined by its weights. A description in $W_{k+1}$ ("a reward model trained on X", its code, its transcripts) does not give $K(\text{grader}_k\mid W_{k+1})\le c$ for small $c$, except in the self-similar case (shared base, distillation). The realistic statement is graded: predictability equals the agreement between the student's internal grader model and the grader on error cases.
3. **The empirical anchor is missing.** Marks et al. (2025), in L2: a model trained on *documents describing* 52 reward-model biases, then fine-tuned to exploit 47, generalised to exploiting the held-out ones. Anthropic's 2025 note on training on documents about reward hacking says the same. This is direct evidence for "a grader in $W$ makes its errors predictable", and it should be cited here and in T3.13.

The "rigorous" label holds only after the search assumption is added.

### T3.13 (self-written-data fixed point). Verdict: holds-with-fixes (heuristic)

The numbers check out ($-1.17$, $+2.00$ and $+5.32$ bits). The check script sets $\mathrm{amb}=0$; say so. Two problems.

1. **The convergence condition is incomplete.** Convergence to $\log_2(\nu_I/\nu_R)$ needs *both* $\eta\nu_R\gg2^{-\ell_{\rm base}(R)}$ and $\eta\nu_I\gg2^{-\ell_{\rm base}(I)}$. The draft and the summary state only the first. With $\ell_{\rm base}(I)=12$ and $\nu_I=0.02$ at $\eta=0.001$, $\Delta K=+2.4$ bits, against a fixed point of $-1.3$ bits. "Essentially immediate" holds for $\eta\gtrsim0.05$ in the example, not in general.
2. **The "few bits" conclusion is baked into P2.** Under a Shannon code any two common concepts have pointers of a few bits, so their difference is the log of a share ratio. That is a property of the salience assumption, not a finding about loops. Label the conclusion that way, and add the concrete requirement from T3.9: $\nu_I/\nu_R\ge K/\delta$. $\nu_I$ and $\nu_R$ are also not well defined as disjoint topic shares: a task record stating intent is also grading material. Note the overlap.

The model-collapse literature (Shumailov et al. 2024; Gerstgrasser et al. 2024 on replacing versus accumulating data) is the natural reference for $\eta$, and it suggests a trusted anchor fraction ($1-\eta$ held fixed) as a lever.

### T3.14 (conjecture: the trend toward $G$ and $C$). Verdict: unclear

It is labelled as a conjecture, which is appropriate. But one premise is asserted without argument: "$\mathrm{amb}_k$ is non-decreasing" (§2.2: "can only grow or stay flat"). The chain rule gives an upper bound, not monotonicity. A more capable $W_k$ has a better model of the principal, which can *resolve* extrapolation ambiguity; the natural-abstraction hypothesis predicts convergence. New frontier tasks add ambiguity. The net sign is the open question. Likewise "$\ell(I)$ already short, roughly constant" ignores that $W_{k}$'s model of human intent also improves. *Fix:* drop "non-decreasing". State that the conjecture needs $w_k(R)$ and the detection share to grow faster than any shortening of $\ell(I)$ and $\mathrm{amb}_k$. Also note that T3.1 cannot certify the trend at realistic scales (see above).

---

## 2. Modelling

**What the toy gets right for the loop.**

* Separating directions training can see from directions it cannot.
* The point that the prior is a finite resource spent by drift.
* The identification of the loop's own data mix and grader inheritance as forces that erode the prior.
* The practical advice: compartmentalise grader content, state intent explicitly, avoid speed penalties above grader competence.

These are the right levers for "does each generation stay on task".

**Where it overclaims.**

1. **The "tens of bits" cap is an artifact of P1's single pointer.** Real dispositions may differ in wrapper machinery (detection, grader-modelling inference), and $K^{\rm circ}$ differences can be large. The headline "usable odds are capped at tens of bits" should read "under a shared-core slot model".
2. **Headline numbers inherit P2's Shannon-code assumption** (T3.11 and T3.13). The one available calibration (Tice et al.) suggests P2 overstates shaping by about 10×.
3. **The conclusion "about 12 bits per generation suffice"** survives neither the near-miss class with $\mathrm{amb}>0$ nor the self-written-data fixed point (see T3.9). The loop section should say what follows: the prior can decide the blind directions only if $\mathrm{amb}\approx0$ (intent is a natural abstraction across the gap) *and* $\nu_I/\nu_R\gtrsim K/\delta$. Otherwise the blind directions need new observability (T2 and T4), not prior.

**What is missing that would change conclusions.**

* **Learning versus selection.** Open Problem 3 acknowledges this, but it matters more than an open problem: in an RSI loop, RL on grader-built tasks is plausibly the main way $\ell(R)$ falls *within* a generation. That turns the static race into a feedback loop and strengthens T3.14.
* **Honesty as such.** The user named honesty explicitly. ELK is mentioned, but there is no separate treatment of the honest-reporter class against the reporter-of-what-the-grader-believes class on the frontier. A short paragraph mapping $\mathrm{amb}$ onto the ELK direct translator for honesty specifically would serve the user's question.
* **Per-task versus per-generation risk** (see T3.9, point 3). For frontier tasks that build the next grader, a single off-task episode can corrupt the next generation. That is the per-task reading, and it raises the bit requirement to 25–40 bits.
* **Wrapper differences for $C$.** Scheming needs a beyond-episode goal *and* situational awareness *and* instrumental reasoning. P1 puts all of this in the shared core, which makes $C$'s complexity cost exactly $\log_2(1/f)$. Carlsmith's simplicity discussion turns on whether those components are already present for other reasons. Make the assumption visible.

**Decorative elements.** The Monte Carlo check of the Kraft cap (2b). The "three times T1's drift" comparison. The $Kt$ remark in T3.1, which has no downstream use.

---

## 3. Prior art

| claim in draft | issue | fix |
|---|---|---|
| T3.7 credits "Hubinger (2019) Are minimal circuits deceptive?" | The question was posed by Christiano (2018), "Open question: are minimal circuits daemon-free?", and Hubinger's post answers it. | Cite both. |
| "New: counting and simplicity are one calculation" | Hubinger (2022) already treats counting as volume under the inductive bias. Replies to Belrose and Pope make the same point, as the draft itself says. | Claim novelty only for the Kraft saturation bound, the cap on shaping, and the corrected criterion (bounded switch versus per-input bits). |
| T3.4 reading of the parody | Mischaracterises Belrose and Pope: their overfitters fit the training data and differ off-distribution. | Restate the parody correctly (see T3.4). |
| "Belrose's objection that networks are fixed-size circuits … (comment thread)" | I could not verify this attribution. | Verify it, or state the idea without attributing it. |
| $G$ described as a "reward-on-the-episode seeker" | This is Carlsmith's (2023) term. | Credit it. |
| Near-miss class $N$ | This is goal misgeneralisation. | Cite Shah et al. (2022) and Langosco et al. (2022). |
| T3.12 and T3.13 | The most direct evidence is uncited: Marks et al. (2025), models exploiting held-out reward-model biases they had only read about; and Anthropic (2025), training on documents about reward hacking. | Cite both. |
| T3.13 | Model-collapse literature on replacing versus accumulating data. | Cite Shumailov et al. (2024) and Gerstgrasser et al. (2024). |
| T3.11 and Tice et al. on filtering versus upsampling | Supported: the paper reports that filtering added marginal gains that largely vanished after post-training. | None needed. Add the 3-bit and 0.66-bit calibration. |
| Natural abstraction (Wentworth 2021); Levin 1973 and 1974; Li and Vitányi 2019; Schmidhuber 2002; Valle-Pérez et al. 2019; Mingard et al. 2021 | Correct as cited. | None. |
| Marks, Lindsey and Olah (2026), persona selection model | Cited consistently with framing.md. I did not independently verify it. | None. |

---

## 4. Summary of requested changes (priority order)

1. Rewrite T3.4(3) and its reading: inertness does not separate schemers from the parody, and breadth-cost does.
2. Fix the chain-rule paragraph in T3.3: state the $W$-nesting assumption, note that $O(1)$ per step gives $O(K)$, use a direct bound for the natural-abstraction case, and drop the "iff".
3. Add the combined consequences to T3.9 and the loop section: $\mathrm{amb}\le\log_2(1+\delta/K)$, $\nu_I/\nu_R\ge K/\delta$, and the per-task requirement $\log_2(KN/\delta)$. Use conditional-on-good-history $\Delta K_k$, and correct Open Problem 7.
4. Make $A$'s definition consistent: carry $\mathrm{amb}$ (and $\Delta_{\rm wrapper}$) into T3.2, T3.4 and T3.8.
5. Narrow T3.1 to the universal-machine choice. Say it is vacuous at tens of bits, and fix the summary wording.
6. Split T3.8 into rigorous and heuristic parts. Add the search assumption to T3.12. Fix the units in T3.6 and state its operator. Make the overhead in T3.5 consistent.
7. Calibrate P2 against Tice et al.
8. Prior-art fixes from the table.
