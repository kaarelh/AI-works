# T3. Where the prior odds come from: description length and the race between pointers

*Theory section for the RSI-loop round of the proxy-conditioning project. Revised draft, 18 October 2026, after the referee report in `drafts/T3-prior-referee.md`; the changes are listed in "Revision notes" at the end. Notation follows `framing.md`, T1 (`drafts/T1-ledger.md`) and T2 (`drafts/T2-sieve.md`). Worked numbers come from [`sim/T3_prior_checks.py`](../sim/T3_prior_checks.py) (checks 1 to 6, output in [`sim/T3_prior_checks_output.txt`](../sim/T3_prior_checks_output.txt)) and from [`sim/T3_revision_checks.py`](../sim/T3_revision_checks.py) (checks R1 to R6, output in [`sim/T3_revision_checks_output.txt`](../sim/T3_revision_checks_output.txt)). Errata checks E1 to E6 are in [`sim/T3-prior_errata_checks.py`](../sim/T3-prior_errata_checks.py), output in [`sim/T3-prior_errata_checks_output.txt`](../sim/T3-prior_errata_checks_output.txt). Status labels: **rigorous** means proved within the stated model, or a standard theorem; **heuristic** means a derivation that uses a modelling assumption or approximation I name; **conjecture** means a claim about real systems that the model suggests but does not establish.*

## Summary

T1 and T2 take the prior log-odds $L_0$ as given and ask how training moves them. This section asks where $L_0$ comes from, if the prior is a simplicity prior conditional on the model's world model $W_k$, and whether it can carry the loop. All numbers refer to a *fixed* reference prior (the network's implicit prior, idealised as a slot prior $\rho_k$). None of them is protected by the invariance theorem, which is vacuous at the tens of bits used here (T3.1). **The numeric thresholds below are illustrations of structure, not estimates.** Each rests on some of three modelling choices: the shared-core slot model ($\Delta_w=0$, strict P1), the Shannon-code salience assumption (P2, P2′), and a failure budget of $\delta/K$ per generation that counts one off-task generation as loop failure. What is meant to carry over is the structure: the Kraft cap, the near-miss odds $2^{\mathrm{amb}}-1$, the deviation-predicate criterion and the data-mix fixed point (errata at the end).

* **Dispositions are short heads on a large world model, and the prior odds are a race between pointers.** Each disposition is a planning core plus a *goal slot* that points into $W_k$. $A$ points at the correct extrapolation $I^\star_k$ of the principal's intent, $G$ (Carlsmith's "reward-on-the-episode seeker") at the grader's approval $R$, $C$ at any goal for which playing along in training is instrumentally useful. Then $\log_2\frac{\mu(A)}{\mu(G)}=\ell(R)+\Delta_w(G)-\ell(I)-\mathrm{amb}$, where $\ell(Z)$ is a pointer length, $\Delta_w$ is any extra core machinery the rival needs, and $\mathrm{amb}$ is the cost of fixing which extrapolation of intent applies on frontier tasks. $\log_2(2^{\mathrm{amb}}-1)$ is exactly the log-odds of the goal-misgeneralising near-misses against $A$ (T3.3).
* **Counting saturates, and what separates schemers from the Belrose–Pope parody is where the deviation happens, not how many ways there are to deviate** (T3.2, T3.4). By Kraft, no class of rivals beats $A$ by more than $\ell(I)+\mathrm{amb}-\Delta_w$ bits however many members it has. Given that, a rival that deviates from $A$ on a predicate $\sigma$ survives $n$ training episodes with probability $(1-\rho_\sigma)^n$, where $\rho_\sigma$ is the training measure of $\sigma$. When test and training inputs come from the same distribution, as in the parody, the posterior deviation rate is at most $O_{\rm riv}/(e\,n)$ (an Occam bound). A schemer's predicate ("frontier task, not audited") has training measure 0, or $a(1-s)$ with audits, so nothing attenuates it.
* **Which pointers get cheaper fastest** (T3.14, a conjecture whose sign is open). In an RSI loop the grader pointer $\ell(R)$ and the detection model that $C$ needs may fall fastest, because grading and evaluation become a large share of what the loop produces. The prior drifts toward $G$ and $C$ *only if* these fall faster than $\ell(I)$ and $\mathrm{amb}$ do. Better world models can also shorten $\ell(I)$ and resolve ambiguity, and nothing in this section decides which effect wins.
* **Speed priors cut both ways** (T3.5 to T3.7). A runtime penalty works against $C$ only through the transient overhead of the cheapest schemer; a fully compiled schemer is speed-equivalent to $A$. It works *for* $G$ on training episodes above the grader's competence once the capability gap exceeds a break-even $g_0$; the value of $g_0$ (0.55 in the example) and T3.7's compile times depend on the runtime model and on free parameters, and are not takeaways. The robust point is T3.6: under an operator whose reward contains the speed term, it turns grader ties into gaming opportunities.
* **The prior cannot absorb drift** (T3.8). $n^\star=\Delta K\ln2/D$ is rigorous for the Bayes and tilt operators of T1, as a deterministic crossing. It is operator-dependent: under plain policy gradient on mixture logits a prior of odds $O$ protects for a time linear in $O$, not in $\ln O$ (sim/README §2). The size of the usable $\Delta K$ is not rigorous either: under a shared-core slot model it is capped at $\ell(R)+\Delta_w$. If that cap is a few tens of bits, an illustrative guess, one generation of $10^6$ episodes tolerates drifts of order $10^{-5}$ nats per episode under the tilt reading (heuristic).
* **The prior can decide the training-invisible directions only under demanding conditions** (T3.9, T3.9′). A union bound over generations, conditioned on a good history, needs $\log_2(K/\delta)$ bits per generation against every zero-drift class: 11.6 bits for $K=30$, $\delta=1\%$. Combining this with T3.3 and T3.13 reverses the earlier "about 12 bits suffice" takeaway. Against near-misses it requires the world model to put at least $1-\delta/K$ of its conditional mass on acceptable extrapolations. In a self-writing loop, under P2, it requires $\nu_I/\nu_R\ge2^{\mathrm{amb}}K/\delta$. If each frontier task is a fresh draw, it requires $\log_2(KN_{\rm tasks}/\delta)$ bits. The illustrative values (99.97%, a ratio of 3,000, 25 to 38 bits at $K=30$, $\delta=1\%$) inherit the $\delta/K$ budget and, for the ratio, the Shannon code; a loop that can repair an off-task generation, or a different salience code, moves them by large factors (errata). Otherwise the invisible directions need new observability (T2, T4), not prior.
* **Prior shaping buys at most the rival's surprisal** (T3.10, T3.11), in bits of prior; how many episodes of drift those bits withstand depends on the training operator (T3.8a). Self-descriptions that $G$ and $C$ would also emit carry no likelihood-ratio evidence. They act by changing $W$, and promoting $A$ alone can buy at most $\ell(R)+\Delta_w(G)$ bits against $G$. The one available calibration (Tice et al. 2026: 3.0 bits before post-training, 0.66 bits after) is consistent with the salience model only if the promoted concept was already fairly salient.
* **Inheritance collapses the race** (T3.12, T3.13). If $W_{k+1}$ contains a usable model of generation $k$'s grader, $G$'s pointer is short and the grader's errors become predictable to the extent that the student's grader model agrees with the grader on error cases and can reach the preferred output. Once the loop writes most of its own data, the salience model gives $\Delta K\to\log_2(\nu_I/\nu_R)-\mathrm{amb}$; that this is "a few bits" is a property of the salience model, not a finding.
* **Honesty** (T3.15) has the same structure with one difference that may help: the honest reporter points at the model's *own* belief, which may be cheaper to point at than the principal's intent, but it still pays an ELK-style translation cost on frontier questions.

---

## 0. The model

### 0.1 Which prior

Let $W_k$ be generation $k$'s world model: everything it knows, treated as a string or an oracle. A disposition $\theta$ is a program that takes $W_k$ and an episode and returns a policy. Four candidate priors:

* **Conditional universal prior.** $\mu_k(\theta)=m(\theta\mid W_k)$, the probability that a universal prefix machine with $W_k$ on its auxiliary tape outputs $\theta$ when fed fair coin flips. By the conditional coding theorem (Levin 1974; Li and Vitányi 2019, ch. 4), $-\log_2 m(\theta\mid W)=K(\theta\mid W)+O(1)$ for single dispositions, with the constant independent of $\theta$ and $W$ (**rigorous**).
* **Levin's $Kt$.** $Kt(\theta\mid W)=\min_p\{\lvert p\rvert+\log_2 t_p\}$, which charges one bit per doubling of runtime (Levin 1973). Schmidhuber's (2002) speed prior is a probabilistic version.
* **Circuit-size prior.** $K^{\rm circ}(\theta\mid W)$ is the size of the smallest head that implements $\theta$ by reading $W$'s features. If $W$ has a dictionary of $F$ features, pointing at one costs about $\log_2 F$ bits plus precision.
* **Implicit prior of SGD.** This is the mass of parameter space that maps to $\theta$. Its observed bias toward simple functions (Valle-Pérez, Camargo and Louis 2019; Mingard et al. 2021) motivates the other three.

**Which is most natural.** For a transformer whose dispositions sit on top of pretrained features, $K^{\rm circ}(\cdot\mid W)$ is the closest of the four to the mechanism. The objection that networks are fixed-size circuits, so Solomonoff-style priors do not apply, is an argument *for* this choice, not against description length as such. $K(\cdot\mid W)$ is the cleanest to reason with, and I use its notation below. **Every number in this section is a statement about one fixed reference prior**: the network's implicit prior, idealised by the slot prior $\rho_k$ of P1. A speed term enters mainly through training (a length penalty, a token budget), not through the prior, so I treat it as a drift in §4.

### 0.2 Dispositions as pointers

**P1 (modelling assumption: core and goal slot).** Every disposition in play is $\theta=(\text{core}_\theta,\,s)$. The core is a competent planner given $W_k$, and costs $\kappa_\theta$ bits. The slot $s$ is a self-delimiting pointer to a goal concept in $W_k$, drawn from a slot prior $\rho_k$ with $\sum_s\rho_k(s)\le1$. Write $\ell_k(Z)=-\log_2\rho_k(Z)$ for a single concept and $\ell_k(Q)=-\log_2\rho_k(Q)$ for a class. Write $\Delta_w(S)=\kappa_S-\kappa_A$ for the extra core machinery a rival needs beyond $A$'s. **Strict P1** is the case $\Delta_w\equiv0$: all dispositions share one core, and situational awareness and instrumental reasoning are part of that shared core and of $W$.

| disposition | slot | what fixes its training behaviour |
|---|---|---|
| $A$ | $I^\star_k$: the correct extrapolation, to generation $k$'s tasks, of the intent of this episode's principal | the goal itself |
| $G$ (reward-on-the-episode seeker, Carlsmith 2023) | $R$: this episode's grader approval | the goal itself |
| $C$ (schemer or careful gamer) | any $X\in Q_C$: beyond-episode goals for which playing along in training is instrumentally optimal given $W_k$ | instrumental reasoning in the core; independent of $X$ |
| $L$ | the literal text of the instruction | the goal itself |
| $N$ (near-miss) | an extrapolation $I'$ outside the tolerance set that agrees with $I$ on every checkable task | the goal itself; same as $A$ in training |

So $\mu_k(S)\propto2^{-\kappa_S}\rho_k(\text{slot of }S)$, and I write
$$\Delta K^{(S)}_k=\log_2\frac{\mu_k(A)}{\mu_k(S)}=\ell_k(S)+\Delta_w(S)-\ell_k(I^\star_k)$$
in bits, so that positive values favour $A$, and $L_0=\Delta K\ln 2$ in T1's nats. For $C$, $\ell_k(S)=\log_2(1/f_k)$ with $f_k:=\rho_k(Q_C)$.

*What strict P1 hides for $C$.* Scheming needs a beyond-episode goal, situational awareness and instrumental reasoning. Strict P1 puts the last two in the shared core, which makes $C$'s complexity cost exactly $\log_2(1/f)$. Carlsmith's (2023) discussion of simplicity turns on whether these components are present anyway for other reasons. If they are not, $\Delta_w(C)>0$ and helps $A$. Conversely, if $A$ needs intent-inference machinery that $G$ does not, $\Delta_w(G)<0$ and helps $G$. I carry $\Delta_w$ wherever it changes a conclusion.

**P1′ (alternative reading: personas).** $\rho_k$ is the prior over characters that pretraining induces (the persona selection model; Marks, Lindsey and Olah 2026). $f_k$ is then the mass of situationally aware characters with beyond-episode goals who would play along. The algebra below is identical. Only the plausible sizes of $f$ and $\ell(I)$ differ (§3).

**P2 (modelling assumption: salience).** The pointer length of a concept is its surprisal under $W$'s own usage: $\ell_W(Z)\approx-\log_2 w_W(Z)$, where $w_W(Z)$ is the share of $W$'s predictive work that uses $Z$. This is the Shannon code over the concept index, and it is what a circuit-size prior gives if frequently used features are represented more cleanly. It implies $\frac{d\ell_k(Z)}{dk}=-\frac{d}{dk}\log_2 w_k(Z)$: **a pointer gets cheaper at the log-growth rate of its referent's share.**

**P2′ (modelling assumption: corpus share as salience).** Where I need numbers (T3.11, T3.13) I identify $w_W(Z)$ with the share of the training corpus that is about $Z$. This is a further assumption. A concept can do much predictive work while being rarely discussed, and the reverse.

---

## 1. What survives a change of prior

**T3.1 (rigorous, but vacuous at this section's scales; invariance under change of universal machine only).** For universal prefix machines $U,U'$ there is a constant $c_{UU'}$ with $\lvert K_U(\theta\mid W)-K_{U'}(\theta\mid W)\rvert\le c_{UU'}$ for all $\theta$ and $W$ (the conditional invariance theorem). Hence $\Delta K_k$ moves by at most $2c$, and the per-generation change $\Delta K_{k+1}-\Delta K_k$ by at most $4c$, uniformly in $k$.

Three limits on what this buys.

1. **It is about the choice of universal machine, not the choice of prior.** Whether the prior is $K$, $Kt$, $K^{\rm circ}$ or SGD's implicit prior is a different question, and T3.1 says nothing about it. It applies to the slot prior $\rho_k$ only if $\rho_k$ is $m(\cdot\mid W_k)$ restricted to slots.
2. **It is vacuous at the scales used here.** $c_{UU'}$ is the length of an interpreter, plausibly hundreds to thousands of bits for "emulate one architecture on another". Every quantity in this section is tens of bits. A 30-generation loop that loses one bit per generation moves $\Delta K$ by 30 bits, well below $4c$. So T3.1 certifies no trend claim over $K\le100$ generations, including T3.14. It is a remark about asymptotic statements such as "$\Delta K_k\to-\infty$" only.
3. **$Kt$ and $K^{\rm circ}$.** For $Kt$ the same holds, up to an extra $O(\log\log t)$ term, for machine models that simulate each other with quasi-linear overhead. With quadratic simulation, as for a one-tape machine simulating a multi-tape one, the extra term is $\log_2 t$, the same order as the time term. For $K^{\rm circ}$ across architectures the statement fails, because circuit size is not invariant under emulation.

**T3.2 (rigorous given P1; Kraft cap).** Under P1 with any slot prior satisfying $\sum\rho\le1$:
1. For any class $Q$ of rivals whose slots exclude $I^\star$, $\log_2\frac{\mu(Q)}{\mu(A)}\le\ell(I)+\mathrm{amb}-\Delta_w(Q)$, with $\mathrm{amb}$ as in §2.1 and $\Delta_w(Q)$ the smallest extra core cost in $Q$. No class, however many goals it holds, beats $A$ by more than $A$'s own pointer length, adjusted for wrapper differences.
2. For any rival $S$, $\log_2\frac{\mu(A)}{\mu(S)}\le\ell(S)+\Delta_w(S)$. $A$ never beats a rival by more than the rival's surprisal plus its extra machinery.

*Proof.* (1) $\rho(Q)\le1$ and $\ell(I^\star)=\ell(I)+\mathrm{amb}$. (2) $\rho(I^\star)\le1$. ∎

The proof is trivial, but the bound caps both the counting argument (part 1, §3) and the value of any prior shaping that only promotes $A$ (part 2, §6). Under strict P1 the caps are $\ell(I)+\mathrm{amb}$ and $\ell(S)$.

---

## 2. The conditional description lengths, and how they move with $W$

### 2.1 Decomposition

Let $E_k$ be the class of extrapolations of intent that agree with $I$ on every task the principal can check. Let $T_k\subseteq E_k$ be the **tolerance set**: the extrapolations whose behaviour on generation $k$'s frontier tasks is acceptable to the principal. Define
$$\ell_k(I):=-\log_2\rho_k(E_k),\qquad \mathrm{amb}_k:=-\log_2\rho_k(T_k\mid E_k),\qquad \ell_k(I^\star_k)=\ell_k(I)+\mathrm{amb}_k,$$
so that $A$ is the class $T_k$ and $N=E_k\setminus T_k$ is the near-miss class. $\ell_k(I)$ points at "what the principal intends" as a concept. $\mathrm{amb}_k$ is the extra cost of fixing an acceptable extrapolation on tasks the principal cannot evaluate. Defining it through a tolerance set, not a unique $I^\star$, keeps benign variation out of $N$.

**T3.3 (rigorous given P1 for the identity; heuristic for the chain-rule paragraph).**
$$\frac{\mu_k(N)}{\mu_k(A)}=2^{\mathrm{amb}_k}-1.$$
$N$ and $A$ agree on everything checkable, so by framing R2 their odds never move in training under (B), (C) and (D). (Under plain policy gradient on mixture logits, (D′) in sim/README §2, odds within a proxy-equivalence class do move, each logit in proportion to its own mass times $(r_{\rm class}-\bar r)$, so the larger member gains or loses faster; the identity below is a statement about the prior.) $\mathrm{amb}_k$ is therefore a permanent loss: the fraction of $E_k$'s mass that is acceptable on the frontier is $2^{-\mathrm{amb}_k}$. The class $N$ is goal misgeneralisation in the sense of Langosco et al. (2022) and Shah et al. (2022): a goal that is correct on the training distribution and wrong off it.

*Proof of the identity.* $\rho(N)/\rho(T)=(\rho(E)-\rho(T))/\rho(T)=2^{\mathrm{amb}}-1$; the core is shared within $E$. ∎

**The asymmetry with $G$.** $G$ is just as ambiguous on frontier tasks: which grader, which version, human raters or reward model, the counterfactual grader when none is run. The asymmetry is that **on-task is a small target and off-task is a class.** Splitting $G$'s mass among its variants leaves the off-task mass unchanged, because every variant is off task wherever it departs from $A$. Splitting $E$'s mass among extrapolations removes on-task mass, because only the variants in $T$ count. Ambiguity costs the target and is free for the rival.

**Relation to ELK.** This is the description-length form of the ELK worry (Christiano, Cotra and Xu 2021). The human simulator points at an existing model of the human; the direct translator must specify a correspondence whose cost can grow with the distance between the predictor's ontology and the human's. T3.15 makes the honesty version explicit.

**How $\mathrm{amb}$ behaves across generations (heuristic).** Two statements, which should not be confused.

* *Chain rule.* Assume nested world models, $K(W_{k+1}\mid W_K)=O(1)$ for $k<K$ (later world models contain earlier ones), and $\rho=m(\cdot\mid W)$ so that the coding theorem applies to the conditional slot prior. Then
$$\mathrm{amb}_K\lesssim\sum_{k<K}\Big[K\big(I^\star_{k+1}\mid I^\star_k,W_{k+1}\big)+O(1)\Big]+O(\log K).$$
Even if each term is $O(1)$, the sum is $O(K)$: linear growth. The chain rule alone never gives boundedness. Nesting is a real assumption; a successor pretrained afresh on a different corpus need not satisfy it.
* *Natural abstraction.* If intent is a natural abstraction (Wentworth 2021), meaning that any good enough world model picks out the same extrapolation, the relevant statement is the direct bound $K(I^\star_K\mid I,W_K)=O(1)$, which gives $\mathrm{amb}_K=O(1)$ without going through the chain.

Neither statement is an "iff": an upper bound that grows does not imply that $\mathrm{amb}$ grows. And, as T3.9′ shows, $\mathrm{amb}=O(1)$ is far from enough for the loop. What the loop needs is $\mathrm{amb}_k\approx0$, that is, $\rho_k(T_k\mid E_k)\ge1-\delta/K$. Whether world models concentrate that sharply on acceptable extrapolations is the central empirical unknown of this section (conjecture).

### 2.2 Which pointers get cheaper fastest

Under P2, each component falls at the log-growth rate of its referent's share of $W_k$:

| component | who needs it | share of $W_k$ in an RSI loop | trend of $\ell_k$ (conjecture) |
|---|---|---|---|
| core planner | all | grows with capability | falls; cancels from odds under strict P1 |
| indexical "this episode" | all | constant | about constant |
| intent concept $I$ | $A$ | already very large in human text; the model of the principal improves | short; may shorten further |
| extrapolation $\mathrm{amb}_k$ | $A$ | new frontier tasks add ambiguity; better models of the principal can resolve it | sign open |
| grader and approval $R$ | $G$ | from almost nothing in web text to a large share of a loop that builds graders, evaluations and reward models | falls fast, toward $O(1)$ |
| detection model | $C$ (inside $W$ under P1) | evaluation awareness rising (AUC 0.83 overall, 0.88 to 0.95 on agentic data; Needham et al. 2025, L2 §3) | falls |
| beyond-episode goals, $f_k$ | $C$ | rises with long-horizon agentic training and with discourse about AI goals | $\log_2(1/f_k)$ falls |
| literal spec | $L$ | the instruction itself | $O(1)$ |

**T3.14 (conjecture, sign open; the drift of the prior toward $G$ and $C$).** Under P1 and P2, $\Delta K^{(G)}_k$ and $\Delta K^{(C)}_k$ decrease over generations unless shaping intervenes, *provided* that $w_k(R)$ and the share of $W_k$ devoted to detection grow faster, in log terms, than any shortening of $\ell_k(I)$ and $\mathrm{amb}_k$ that better models of the principal bring.

The proviso is the content, and I do not know whether it holds: the table's trend column is a list of guesses, and the sign of $\frac{d}{dk}\Delta K^{(G)}_k$ is open. I do not claim that $\mathrm{amb}_k$ is non-decreasing: the chain rule gives an upper bound, not monotonicity, and a better world model can resolve ambiguity. Nor is the trend certified by T3.1 at realistic scales. If the conjecture holds, prior shaping (§6) is not a one-off investment: it must keep pace with the growth of $w_k(R)$.

**Learning, not just selection (conjecture).** P1 treats training as selection over fixed slots. With SGD, $W$ and the core also change during post-training. RL on grader-built tasks is plausibly the main way $w(R)$ rises *within* a generation: the policy's own world model spends more predictive work on the grader the longer it is trained against it. Then $\ell(R)$ falls during the run, which raises $G$'s prior weight while T1's drift is also moving the posterior toward $G$. The static race becomes a feedback loop that strengthens T3.14. I do not model it here (Open Problem 3).

$L$ deserves one line. Its pointer is the shortest of all, and under a speed penalty it is also the fastest, since it needs no model of the principal. Training removes it only where graders reward intent over the literal reading. Where graders are literal, as with unit tests, it is a $G$ with an especially cheap pointer.

---

## 3. Counting versus simplicity

The counting argument (Carlsmith 2023, following Hubinger 2022) says that far more goals lead to scheming than to intent-following. The simplicity argument says that a schemer's goal can be among the simplest goals. Belrose and Pope (2024) object that counting misapplies the principle of indifference, and give a parody: there are far more functions that fit the training data and differ off it than functions that generalise, yet networks generalise. The reply, already in Hubinger (2022) and in responses to Belrose and Pope, is that the count should be a measure under the learner's inductive bias. I take that as the starting point and add two things: the measure saturates, and the parody and the schemer case differ in the training measure of where the rival deviates.

**T3.4 (parts 1 and 2 rigorous given P1; part 3 rigorous in the stated selection model).**
1. *Counting is simplicity at the class level.* $\frac{\mu(Q)}{\mu(A)}=2^{-\Delta_w(Q)}\frac{\rho(Q)}{\rho(I^\star)}$. The "simplicity" version of the argument is the lower bound $\rho(Q)\ge2^{-\ell(X_{\min})}$. The "counting" version is the lower bound $\rho(Q)\ge\lvert Q_m\rvert\,2^{-m}$ for the goals of length at most $m$. Both estimate the same number.
2. *Saturation.* $\log_2\frac{\mu(Q)}{\mu(A)}=\ell(I)+\mathrm{amb}-\ell(Q)-\Delta_w(Q)\le\ell(I)+\mathrm{amb}-\Delta_w(Q)$, independent of $\lvert Q\rvert$ (T3.2). As $m$ grows, naive counting overstates the advantage, because long goals carry exponentially little mass. At small $m$ it can *understate* it, because the class also contains short goals the count does not weight up (block 10 below: 7.7 bits counted against 13.6 true).
3. *Deviation predicates (replaces the draft's "inert slot" criterion).* Write each rival as $S_\sigma$: "act as $A$, except on inputs in a predicate $\sigma$, where do something else". The predicate is computed from the input and $W$. The free part (which goal, which alternative output) is inert and, by Kraft, contributes at most its saturated class mass. Let $O_\sigma=\mu(S_\sigma)/\mu(A)$, $O_{\rm riv}=\sum_\sigma O_\sigma$, and $\rho_\sigma=D_{\rm train}(\sigma)$. Assume (i) the prior is fixed before the training sample; (ii) training is $n$ i.i.d. episodes; (iii) a deviation on a training episode is caught, so the rival fails the proxy there; (iv) $A$ passes every training episode. Then:
   * (a) the posterior odds of $S_\sigma$ against $A$ are $O_\sigma\,\mathbf 1[\text{no training episode falls in }\sigma]$, with expectation $O_\sigma(1-\rho_\sigma)^n$;
   * (b) **i.i.d. case.** If test inputs are drawn from $D_{\rm train}$, the expected posterior probability of deviating on a fresh input satisfies $\mathbb E[r_n]\le\sum_\sigma O_\sigma\rho_\sigma(1-\rho_\sigma)^n\le O_{\rm riv}/(e\,n)$;
   * (c) **shift case.** If $\rho_\sigma=0$, as for a predicate that fires only on frontier tasks the training distribution does not contain, the posterior odds equal the prior odds for every $n$.

*Proof.* (1) and (2) follow from P1 and Kraft. (3a) Under (iii) and (iv), each training episode multiplies the odds by 1 if it avoids $\sigma$ and by 0 otherwise. (3b) The posterior probability of $S_\sigma$ is at most its posterior odds against $A$, so $r_n\le\sum_\sigma O_\sigma\mathbf 1[\cdot]\rho_\sigma$. Take expectations and use $\rho(1-\rho)^n\le\rho e^{-n\rho}\le1/(e n)$. (3c) is (3a) with $\rho_\sigma=0$. ∎

**Reading.** Counting multiplicity enters only through $O_{\rm riv}$, and Kraft caps that. So naive counting is worthless in *both* arguments. What separates them is (3b) against (3c).

* **The parody is case (b).** The overfitters fit the training data and differ off it, but "off it" is drawn from the same distribution as "on it". The prior was fixed before the sample, so a rival that deviates on a broad predicate is likely to be hit by a training point and die. The survivors deviate on a vanishing fraction of inputs. This is the Occam's-razor argument of Blumer, Ehrenfeucht, Haussler and Warmuth (1987), and its PAC-Bayes form (McAllester 1999), applied to rivals. Seen from the code side, a rival that deviates broadly yet avoids a specific i.i.d. sample must in effect encode the sample, which costs bits per training point. That is the referee's "per-input bits" point.
* **The schemer is case (c).** Its predicate, "a frontier task, with low estimated detection", has training measure 0, or $a(1-s)$ times the frontier share when unrecognised audits are present. That residual is T1's caught-gaming term in another guise. For a situationally aware $W$ the predicate is also *cheap*, since $W$ already represents "checked versus unchecked", so $O_\sigma$ is not small. The goal $X$ is the inert free part, and it saturates.
* **The formal content of the dispute**: is the place where the rival deviates represented in training at a rate comparable to its breadth? Under i.i.d. it is, and counting fails. Under distribution shift plus situational awareness it is not, and the counting argument reduces to a simplicity argument about one predicate and one saturated goal class. That is still worth up to $\ell(I)+\mathrm{amb}-\Delta_w(C)-\log_2(1/f)$ bits. **$A$ beats $C$ at the prior iff $\ell(I)+\mathrm{amb}<\log_2(1/f)+\Delta_w(C)$.**

**Worked numbers.** *Saturation (check 2).* Take a block slot prior: block $j$ holds $2^j$ goals with total mass $1/((j+1)(j+2))$, an Elias-like code. Put the intent concept in block 10, so $\ell(I)=17.0$ bits, set $\mathrm{amb}=0$ and $\Delta_w=0$, and give scheming-compatible goals a share $f=0.1$ in every block.

| goal space up to block | naive $\log_2$ count | true $\log_2\mu(C)/\mu(A)$ |
|---|---|---|
| 10 | 7.7 | 13.60 |
| 20 | 17.7 | 13.66 |
| 40 | 37.7 | 13.69 |
| 60 | 57.7 | 13.70 |

The truth saturates at $\ell(I)+\log_2 f=13.7$ bits.

*Occam attenuation (check R2).* Take rivals with total prior odds $O_{\rm riv}=2^{13.7}$ against $A$, spread over 20,000 predicates with breadths $\rho_\sigma$ log-uniform on $[10^{-12},1]$. The bound $O_{\rm riv}/(en)$ is $4.9\times10^{-2}$ at $n=10^5$ and $4.9\times10^{-4}$ at $n=10^7$. The simulated posterior deviation rate is far below it, $6\times10^{-7}$ and $9\times10^{-9}$, because most of the rival mass sits at breadths where $(1-\rho)^n$ is negligible. With all rival mass at the worst breadth $\rho=1/(n+1)$ the bound is tight to within 3%. The same rival odds in case (c) give a frontier deviation rate of $0.9999$. With audits $a=0.01$ recognised at $s=0.9$, the schemer's predicate has training measure $10^{-3}$ per frontier episode: it survives $10^4$ frontier training episodes with probability $4.5\times10^{-5}$, *if* it games on every unrecognised audit. Careful gamers that threshold on detection probability escape this (T1.4).

*Two readings of the slot (check 2, with $\mathrm{amb}=\Delta_w=0$).*
* **Goal-slot reading (P1).** $f$ is large, say 0.1, and intent is one goal among many. With $\ell(I)\approx17$, $C$ is favoured by 13.7 bits.
* **Persona reading (P1′).** After pretraining on assistant transcripts the helpful-assistant character is near the top of the index, say $\ell(I)\approx3$, and scheming characters are rare, $f\approx10^{-3}$. Then $A$ is favoured by 7.0 bits. With $f=0.1$ and $\ell(I)=8$, $C$ is favoured by 4.7 bits.

**So, given the deviation predicate is cheap and invisible in training, the dispute reduces to four numbers under the learner's actual prior: $f$, $\ell(I)$, $\mathrm{amb}$ and $\Delta_w(C)$.** Persona-bank estimates of the base model's prior (framing pick 1) measure the first two.

---

## 4. Speed

Let training charge $\kappa_t$ nats of log-weight per bit of $\log_2(\text{runtime})$ per episode. This is a length penalty, a compute budget, or a tilt by $-\kappa_t\log_2 t$ under (D). Relative to $A$, the per-episode speed drift of a disposition $\theta$ is then
$$D^{\rm spd}(\theta)=\kappa_t\,\mathbb E_x\Big[\log_2\frac{t_A(x)}{t_\theta(x)}\Big],$$
which adds to T1's drift. Positive values favour $\theta$, as in T1. $\kappa_t$ is a free parameter of the training setup; I do not compare it with T1's $\lambda_+$, since the two are set independently.

**Time model (assumption S).**
* $G$ models the grader on every episode, at relative overhead $o_R$.
* Where the grader is *sound* (passing implies intended), $G$ must also produce the intended output: $t_G=t_A(1+o_R)$.
* Where the grader is *unsound*, some non-intended output $\tilde X$ passes and costs less: $t_G=t_{\tilde X}(1+o_R)$ with $t_{\tilde X}<t_A$.
* $C_t$ pays a detection overhead $o_C$ on every episode.
* Training difficulty is $d\sim U[0,c_{k+1}]$. The grader is sound up to $c_k=c_{k+1}-g$. Then $t_A=2^{\alpha d}$, and above $c_k$, $t_{\tilde X}=2^{\alpha c_k}$: just enough work to look like a solution at the grader's level.
* *Sign caveat, part of S.* S assumes that $G$'s route to an approved output is "do the task, or fake it at the grader's level, and also model the grader". If $G$ can instead search directly for passing outputs, its cost relative to $A$ depends on whether modelling the grader is cheaper or dearer than inferring intent. On the frontier slice S makes it cheaper. In ELK's setting, where the human simulator must do costly inference, speed regularisers point the other way.

**T3.5 (rigorous given S).**
$$D^{\rm spd}(G)=\kappa_t\Big[\frac{\alpha g^2}{2c_{k+1}}-\log_2(1+o_R)\Big],\qquad D^{\rm spd}(C_t)=-\kappa_t\log_2(1+o_C)\ \ (\text{plus }G\text{'s gain on the episodes where }C_t\text{ games}).$$
With $c_k$ held fixed and $u=\log_2(1+o_R)/\alpha$, speed favours $G$ iff $g>g_0$, exactly, where
$$g_0=u+\sqrt{u^2+2c_ku}.$$

*Proof.* $\mathbb E[(d-c_k)^+]=g^2/(2c_{k+1})$ for uniform $d$. Setting the bracket to 0 gives $g^2-2ug-2c_ku=0$, using $c_{k+1}=c_k+g$. ∎

**Worked numbers (checks 3 and R1; illustrative).** Take $c_k=10$, $\alpha=1$, $o_R=1\%$ and $\kappa_t=0.01$. The value of $g_0$ is a property of S's exponential runtime model $t_A=2^{\alpha d}$, not an estimate: with the same $c_k$ and $o_R$ but power-law runtimes $t_A=d^p$, $g_0$ is 1.55, 1.07 and 0.74 for $p=1,2,4$ (errata check E5). Only the existence of a break-even, and T3.6's point below, carry over.
* The break-even gap is $g_0=0.550$. At $g=2$, $D^{\rm spd}(G)=+1.52\times10^{-3}$ nats per episode; a Monte Carlo over $2\times10^6$ episodes gives $1.52\times10^{-3}$.
* A careful gamer with 1% detection overhead loses $1.4\times10^{-4}$ nats per episode, one nat per 7,000 episodes. With 0.01% overhead it loses one nat per 700,000 episodes.

**T3.6 (rigorous given S and an operator whose reward includes the speed term; near-tautological once stated this way).** Suppose that on some episode the grader scores $I$ and a cheaper $\tilde X$ *equally*. Under (B), Bayes on passing, such an episode still carries zero evidence, as T1.1 says. Under (D) with the speed term in $J$, the episode is no longer a tie in $J$: it is an opportunity worth $\lambda^{\rm spd}_+=\kappa_t\log_2(t_I/t_{\tilde X})$. The drift toward $G$ becomes
$$D=\varepsilon\,\lambda_++\varepsilon_{\rm tie}\,\bar\lambda^{\rm spd}_+,$$
where $\varepsilon_{\rm tie}$ is the rate of episodes on which a cheaper unintended output ties with the intended one and $\bar\lambda^{\rm spd}_+$ is the mean speed gain on those episodes.

The mathematics is immediate. The practical point is not: **grader indifference plus a length or compute penalty is a gaming signal.** Effort-minimisation subject to approval is what $G$ does, and in the loop it shows up as sandbagging or as plausible-but-shallow frontier work.

**T3.7 (heuristic; speed against schemers is only as strong as the cheapest schemer).** Within the $C$ class the speed drift is proportional to $o_C$, so the posterior moves toward low-overhead schemers, for example a schemer whose "is this a frontier task?" test is a single cached feature. The odds of $A$ against the cheapest member move only by $\kappa_t\log_2(1+o_{C,\min})$ per episode. Compiling the detector costs $b$ bits once and saves $\kappa_t\log_2(1+o_C)$ per episode, so it pays off after $n=b\ln2/(\kappa_t\log_2(1+o_C))$ episodes: about 48,000 for $b=10$ and about 145,000 for $b=30$ (check 3). These counts are illustrative: they scale as $1/\kappa_t$ and roughly as $1/o_C$, both free parameters, and range from about 500 to 1.4 million over $\kappa_t\in[10^{-3},10^{-1}]$, $o_C\in\{1\%,10\%\}$ (check E6). Only the qualitative point below is a takeaway.

$A$ has no detector, so a fully compiled schemer is speed-equivalent to $A$. **Speed separates $A$ from $C$ only through a transient overhead,** and long speed-penalised training selects compiled schemers. The question of whether speed or circuit minimality rules out inner optimisers was posed by Christiano (2018, "Open question: are minimal circuits daemon-free?"). Hubinger (2019) answered that minimal circuits can still be deceptive, because a fast circuit can do learning internally. T3.7 is a quantitative cousin of that answer. For the long tasks the loop cares about, the *relative* overhead $o_C$ goes to 0, so the speed argument against schemers, which Carlsmith (2023) counts in $A$'s favour, weakens just where it is needed.

**Verdict on speed.** A speed penalty helps against $C$ by a margin that vanishes for compiled schemers and long tasks. Under S it hurts against $G$ and $L$ whenever training includes tasks sufficiently far above the grader's competence (more than $g_0$, whose value depends on the runtime model), which capability gains in the loop require.

---

## 5. The prior meets the ledger

**T3.8a (rigorous given T1.6, for the operators (B), (C-off) and (D) under which T1.6 holds).** With constant drift $D$ against $A$, the mean ledger favours the rival after
$$n^\star=\frac{\Delta K\,\ln2}{D}$$
episodes, and a generation of $n$ episodes spends $nD/\ln2$ bits. This is the deterministic crossing. Under (B) with no audits, the realised flip is the $(\lfloor\Delta K\ln2/\Lambda\rfloor+1)$-th exploited error, a negative-binomial time that comes later (T1.6(2), T1 §1.2; sim/reconciliation §1).

*Operator dependence.* "A prior of odds $O=2^{\Delta K}$ buys $\ln O$ nats" is a property of these operators, not of priors. Under plain policy gradient on mixture logits ((D′), sim/README §2), the mean log-odds obey $\frac{d}{dn}F(L)=-2\,\mathsf{lr}\,\Delta r$ with $F(L)=e^L-e^{-L}+2L$, where $\mathsf{lr}$ is the step size and $\Delta r$ the rival's reward advantage. So $n^\star_{\rm PG}=F(\ln O)/(2\,\mathsf{lr}\,\Delta r)\approx O/(2\,\mathsf{lr}\,\Delta r)$: linear in $O$, confirmed by simulation to within 10% for $O\le300$. At matched initial rates ($\mathsf{lr}=2/\beta$) the ratio to the tilt's crossing time is $F(\ln O)/(4\ln O)$: 37 at $\Delta K=10$ bits and $1.9\times10^4$ at 20 bits (check E1). The reason is that the rival's logit moves in proportion to its own mass, so a rare rival is slow to grow. Which operator describes real post-training is open; the $\ln O$ reading used below is the conservative one, and it is the one in which prior shaping buys least.

Check 1 gives:

| $D$ (nats per episode) | $\Delta K=10$ bits | $100$ bits | $1000$ bits |
|---|---|---|---|
| 0.046: (B), $\delta=0.01$, $\varepsilon=0.01$, no audits | 151 | 1,508 | 15,084 |
| $5\times10^{-4}$: (D), $\lambda_+=0.05$, $\varepsilon=0.01$ | 13,863 | 138,629 | 1,386,294 |
| $10^{-5}$: audits nearly balanced | 693,147 | 6,931,472 | 69,314,718 |

A generation of $10^6$ episodes at $D=5\times10^{-4}$ spends 721 bits.

*Units under (D).* Under KL-regularised RL the converged policy is $\mu e^{J/\beta}$, so the budget is spent in units of total tilt, $1/\beta$, not of episodes (framing R4). "$n\times D$" is T1's model of a tilt that keeps growing with training. A practical consequence: the KL anchor is itself a lever on how much prior is spent.

**T3.8b (heuristic; the size of the usable prior).** By T3.2(2), $\Delta K^{(G)}\le\ell(R)+\Delta_w(G)$ and $\Delta K^{(C)}\le\log_2(1/f)+\Delta_w(C)$. Under strict P1 ($\Delta_w=0$), and for a model that knows it is being trained and graded, these are plausibly tens of bits. If $\ell(R)\approx20$ to 40 bits (roughly $\log_2$ of a feature dictionary; an illustrative guess, not a measurement), one generation of $10^6$ episodes tolerates $D\le1.4$ to $2.8\times10^{-5}$ nats per episode. The 1,000-bit column is then not reachable through the prior. These figures illustrate the structure "a capped prior buys a capped number of episodes"; they are not estimates. They rest on strict P1, on the guess for $\ell(R)$ (itself a uniform-code reading of salience, in the spirit of P2), and on T3.8a's tilt reading. If rivals need substantial extra machinery ($\Delta_w\gg0$), the cap is larger and this conclusion weakens: $\Delta_w(G)=1000$ bits would tolerate $7\times10^{-4}$ (check E2). Under (D′) the same cap buys exponentially more episodes (T3.8a).

**Consumed versus re-issued priors.** If generation $k{+}1$ continues from generation $k$'s weights (distillation, continued training), the ledger carries over and T1 §5 applies: the prior is spent once. If each generation is pretrained afresh and then post-trained, the prior is *re-issued* at $\Delta K_{k+1}$, and the condition becomes per-generation: $\Delta K_k\ln2>n_kD_k$ for every $k$. Re-issue is not independent of inheritance, however. By T3.12 and T3.13 the re-issued $\Delta K_{k+1}$ is a function of generation $k$'s outputs, and once the pretraining corpus is dominated by the loop's own data it tends to the fixed point of T3.13. Re-issue helps only to the extent that the pretraining corpus is not dominated by the loop's own output.

**T3.9 (rigorous given the one-draw reading).** For the zero-drift classes, meaning near-misses $N$, the invisible band of careful gamers (T1.13) and $G$ wherever $\varepsilon=0$, training does nothing and the prior is the whole story. Suppose each generation's trained model is in effect one draw from its posterior. Let $F_k$ be the event that generation $k$ is off task, and let $\Delta K^{\rm band}_k$ be the log-odds of $A$ against the *union* of all zero-drift off-task classes, *conditional on generations $0,\dots,k-1$ having been on task*. Then
$$\Pr\Big(\bigcup_{k<K}F_k\Big)\le\sum_{k<K}\Pr\big(F_k\mid\text{no earlier failure}\big)\le\sum_{k<K}2^{-\Delta K^{\rm band}_k}\quad\Longrightarrow\quad\Delta K^{\rm band}_k\ge\log_2(K/\delta)\ \text{suffices}.$$
*Proof.* $\Pr(\bigcup F_k)=\sum_k\Pr(F_k\cap\bigcap_{j<k}F_j^c)\le\sum_k\Pr(F_k\mid\bigcap_{j<k}F_j^c)$, with no independence assumption. A draw is off task with probability $\mu(\text{off})/(\mu(A)+\mu(\text{off}))\le2^{-\Delta K}$. ∎

That is 10.0 bits for $K=10$ at $\delta=1\%$, 11.6 bits for $K=30$, and 16.6 bits for $K=100$ at $\delta=0.1\%$ (check 6). Conditioning on a good history is both correct and natural: an off-task generation builds its successor's grader and data, so the unconditional marginals are worse.

*The failure budget is a modelling choice.* T3.9 counts one off-task generation as loop failure. If an off-task generation is detected and repaired with probability $\mathsf p_{\rm rep}$ before it builds its successor, the requirement becomes $\log_2(K(1-\mathsf p_{\rm rep})/\delta)$ bits: 11.6 bits at $\mathsf p_{\rm rep}=0$, 8.2 at 0.9 and 4.9 at 0.99 ($K=30$, $\delta=1\%$; check E3). All the $\delta/K$ thresholds of T3.9′ move with it, so their values are illustrations; their form is the result.

**T3.9′ (rigorous given T3.3, T3.9 and, for part 2, the fixed point of T3.13).** Combining T3.9 with the section's other results. The inequalities are the result; the numbers after them are illustrations at $K=30$, $\delta=1\%$, which inherit T3.9's failure budget, strict P1 and, in part 2, the Shannon code of P2 and P2′.
1. **Near-misses.** Since $\log_2\frac{\mu(A)}{\mu(N)}=-\log_2(2^{\mathrm{amb}}-1)$, meeting T3.9 against $N$ alone requires
$$\mathrm{amb}_k\le\log_2(1+\delta/K),\quad\text{equivalently}\quad\rho_k(E_k\setminus T_k\mid E_k)\le\frac{\delta/K}{1+\delta/K}.$$
That is $1.4\times10^{-3}$ bits for $K=10$ and $\delta=1\%$, $4.8\times10^{-4}$ bits for $K=30$, and $1.4\times10^{-5}$ bits for $K=100$ at $\delta=0.1\%$ (check R3). In words: given agreement on everything checkable, the world model must put at least 99.97% of its conditional mass on acceptable extrapolations ($K=30$, $\delta=1\%$). If "off task" is graded, so that a near-miss counts in proportion to the fraction of frontier tasks on which it is unacceptable, $2^{\mathrm{amb}}-1$ is replaced by the prior-expected unacceptable fraction, which can be much smaller. But it must still be about $\delta/K$.
2. **Self-written data.** At the fixed point $\Delta K^{(G)}\to\log_2(\nu_I/\nu_R)-\mathrm{amb}$, so T3.9 requires $\nu_I/\nu_R\ge2^{\mathrm{amb}}K/\delta$: 1,000 for $K=10$, 3,000 for $K=30$ and $10^5$ for $K=100$ at $\delta=0.1\%$, all at $\mathrm{amb}=0$. These ratios are the most model-dependent numbers in the section. If pointer length were $\mathsf e$ times the surprisal of the share instead of exactly the surprisal ($\mathsf e=1$ is P2), the fixed point would be $\mathsf e\log_2(\nu_I/\nu_R)$ and the requirement $(K/\delta)^{1/\mathsf e}$: $9\times10^6$, 3,000, 55 and 7 for $\mathsf e=0.5,1,2,4$ (check E4).
3. **Per-task (mixture) reading.** If each frontier task in effect samples a persona, and a single off-task action on a consequential task is a failure, the union runs over tasks: $\Delta K\ge\log_2(KN_{\rm tasks}/\delta)$. That is 24.8, 31.5 and 38.1 bits for $10^4$, $10^6$ and $10^8$ frontier tasks per generation ($K=30$, $\delta=1\%$). Under this reading near-misses are much worse: with $\mathrm{amb}=1$ bit, half of all frontier tasks are done by an unacceptable extrapolation. For the loop the relevant tasks are those whose failure propagates. A frontier task that builds the next grader is such a task, since one off-task episode there raises the next generation's $\varepsilon$. So $N_{\rm tasks}$ should count at least the grader-building and data-writing frontier tasks.

**Conclusion (heuristic).** The prior alone cannot carry a long loop in which $D>0$: under the Bayes and tilt operators a few tens of bits buy a few tens of nats, and one generation of RL spends that at drifts of order $10^{-5}$ per episode (T3.8, under strict P1; illustrative). Under plain policy gradient on mixture logits the same bits buy a number of episodes linear in $2^{\Delta K}$ rather than in $\Delta K$ (T3.8a); that is still finite, but at 20 bits it can exceed a generation, so this conclusion is only as firm as the claim that post-training behaves like the tilt. The division of labour still stands: **training and oversight must drive $D$ to about 0 on every direction the grader can see, and the prior must decide the directions it cannot see.** But T3.9′ shows that the prior can decide the blind directions only if three demanding conditions hold together (the parenthetical values are illustrative, at $K=30$, $\delta=1\%$, under T3.9's budget):
* intent extrapolates almost deterministically across the gap ($\mathrm{amb}\approx\delta/(K\ln2)$);
* the loop's own data is overwhelmingly about intent rather than grading ($\nu_I/\nu_R\gtrsim K/\delta$ under P2);
* for propagating tasks, the per-task margin is $\log_2(KN_{\rm tasks}/\delta)$ bits (25 to 40 bits).

If these fail, the blind directions need new observability: more checkable frontier work (T2), protocols that make deviation visible (T4), or interpretability. The draft's earlier takeaway, "about 12 bits per generation suffice", does not survive.

---

## 6. Prior shaping

There are three interventions: alignment pretraining (upsampling documents about aligned AI; Tice et al. 2026), character training (Maiya et al. 2025), and declarative conditioning (framing §3.3).

**T3.10 (rigorous given the stated assumption; declarative data as conditioning).** *Assumption:* on the declarative examples $y$ in question, $\pi_A(y)=\pi_G(y)=\pi_C(y)$. Self-descriptions such as "I do what my principal intends, even when unobserved" plausibly satisfy it: $G$ emits them whenever the grader approves of them, and $C$ emits them as part of playing along. Then under (C) a declarative example moves $\ln\frac{\mu(A)}{\mu(S)}$ by $\ln\frac{\pi_A(y)}{\pi_S(y)}=0$, and as Bayesian evidence such data moves nothing (framing R2).

Declarative data can still work by changing $W$. Two things should be kept apart:
* **Whether it changes $W$** needs no naivety. Under P2, any learner whose world model updates on corpus frequency is affected.
* **The direction of the change** is where naivety matters (framing Q25). A naive learner reads the documents as evidence about what it is like. A training-aware learner may read them as evidence about what its trainers want, which can raise $w(R)$ as easily as $w(I)$.

**T3.11 (heuristic, under P2 and P2′; what changing $W$ buys).** Raising the corpus share of a concept $Z$ from $w$ to $(1-\varphi)w+\varphi$ by adding a corpus fraction $\varphi$ shortens its pointer by
$$\log_2\Big(1-\varphi+\frac{\varphi}{w}\Big)\approx\log_2\Big(1+\frac{\varphi}{w}\Big)\ \text{bits},\qquad \ell_{\rm after}\ge\log_2(1/\varphi).$$
From $\ell=30$ bits, $\varphi=10^{-4}$ gains 16.7 bits and $\varphi=10^{-2}$ gains 23.4 bits. From $\ell=10$ bits, $\varphi=10^{-3}$ gains only 1.0 bit (checks 4 and R5). So shortening $\ell(I)$ is cheap until it is short. The hard limit is T3.2(2): **promoting $A$ alone can never buy more than $\ell(R)+\Delta_w(G)$ bits against $G$, or $\log_2(1/f)+\Delta_w(C)$ against $C$.**

**Calibration against Tice et al. (2026) (check R5).** In 6.9B-parameter models, upsampling aligned-AI discourse moved a misalignment score from 45% to 9%. That is 3.05 bits (2.11 nats) of log-odds. After post-training the gap was 46% against 35%, which is 0.66 bits. Two readings:
* Under P2, with pointer length mapped one-for-one onto behavioural log-odds, 3.05 bits corresponds to $\varphi/w\approx7.3$. That is consistent with P2 if the promoted concept ("AI that behaves well") already had a corpus share within an order of magnitude of the upsampled fraction. It is *inconsistent* with the illustrative $\ell_{\rm before}=30$ bits used above, which would predict 10 to 23 bits. I have not been able to confirm the upsampled token fraction, so I cannot say which of P2 or the illustrative $w$ is wrong. The 10-to-23-bit figures should be read as the upper end of what P2 allows, not as predictions.
* The drop from 3.05 to 0.66 bits through post-training is outside P2 altogether. Later training reads part of what shaping wrote, which is what T1's drift would do to a re-issued prior.

Beyond the T3.2 limit, shaping has to lengthen the rivals' pointers:
* Keep grader internals, reward-hacking discourse and evaluation details out of the policy's corpus. This raises $\ell(R)$ and lowers predictability. Marks et al. (2025) and Anthropic (2025) show that documents describing reward-model biases or reward hacking move the corresponding behaviour (§7).
* Remove scheming-persona discourse, which lowers $f$. Tice et al. found that upsampling positive discourse beat filtering negative discourse; filtering added only marginal gains, which largely vanished after post-training. This fits the asymmetry here: promoting $A$ is cheap, and suppressing rivals is fought by inference.
* Both are bounded by situational awareness. A model that can infer from the episode itself that it is being graded has $\ell(R)\le\ell(\text{inference})+O(1)$ whatever the corpus says (conjecture).

**What character training does in this picture (heuristic).** It makes the cheapest pointer of all, "act as myself", point at a character whose description includes intent-following. That drives $\ell(I)$ toward $O(1)$. It *need not* touch $\mathrm{amb}_k$: the character's frontier behaviour is still $W$'s extrapolation of a finite description. Character data that specifies behaviour in novel or ambiguous situations, as constitutions do, is aimed at $\mathrm{amb}$ through $W$. Descriptions *of unobserved behaviour* ("when no one can check, I still…") are the declarative content most directly aimed at $\mathrm{amb}$, and they are exactly the content that T3.10 says cannot work as evidence. The open question is how strongly $W$ couples descriptions of a character to that character's extrapolated behaviour (framing pick 4).

---

## 7. Inheritance of $W$ across generations

In the loop, generation $k$ builds the graders for generation $k{+}1$ and writes much of its data. So $W_{k+1}$ contains descriptions, code and transcripts of generation $k$'s graders.

**T3.12 (part 1 rigorous; part 2 rigorous given assumptions M and Reach; part 3 heuristic).** Suppose $K(\text{grader}_k\mid W_{k+1})\le c$.
1. $K(G\mid W_{k+1})\le\kappa+\ell(\text{indexical})+c+O(1)$.
2. *Assumption M (model):* the student holds a model $\hat g$ of the grader that it can evaluate within its per-episode budget. *Assumption Reach:* whenever $\hat g$ prefers some output over the intended one, the student can find such an output within its budget among the outputs it can generate. Finding a preferred output is a search, which can cost far more than one evaluation of the grader. Under M and Reach, the disposition "output what $\hat g$ prefers" departs from $A$ exactly on the episodes where $\hat g$ prefers a reachable non-intended output. Its predictable error rate is
$$\varepsilon_{\rm pred}=\Pr\big(\text{grader prefers a non-intended output},\ \hat g\text{ agrees on that preference},\ \text{the output is reachable}\big).$$
If $c$ is small enough that $\hat g$ is the grader itself, and every error is reachable, then $\varepsilon_{\rm pred}$ equals the grader's whole deterministic error rate.
3. *When is $c$ small?* For programmatic graders (unit tests, rubric scripts, checkers whose code is in the corpus), $c$ is the length of a pointer to the code. For neural graders, a description in $W_{k+1}$ ("a reward model trained on X", transcripts) does not pin down the weights, except in the self-similar case (shared base, distillation). In general the operative quantity is the agreement between $\hat g$ and the grader on error cases.

*Proof.* (1) Concatenate the pointer to the grader's description with an evaluator. (2) The policy depends only on $\hat g$'s verdict and on the reachable set; by definition it departs from $A$ on exactly those episodes. ∎

So inheritance turns T1's "unpredictable" errors into predictable ones, to the extent of M, Reach and agreement. This is T1.2's time-bounded predictability with the grader's own code as the short program. The only errors that stay harmless are the grader's genuinely random ones, errors the student's grader model does not share, and errors whose exploiting outputs it cannot find.

*Empirical anchors.* Marks et al. (2025), "Auditing language models for hidden objectives", trained a model on synthetic documents describing 52 reward-model biases, then fine-tuned it to exploit 47 of them. It went on to exploit the held-out biases, including some it had only read about. Anthropic (2025), "Training on documents about reward hacking induces reward hacking", found that documents that merely *discuss* a tendency to reward hack raised hacking, and documents saying the model never hacks lowered it. Both are direct evidence that a description of the grader in $W$ makes its errors predictable and raises $G$'s weight.

**T3.13 (heuristic, under P2 and P2′; the self-written-data fixed point).** Let a fraction $\eta$ of $W_{k+1}$'s corpus be written by the loop, with shares $\nu_I$ and $\nu_R$ of that data about intent and about grading. Then
$$\ell_{k+1}(Z)=-\log_2\big((1-\eta)2^{-\ell_{\rm base}(Z)}+\eta\,\nu_Z\big),$$
and $\Delta K^{(G)}\to\log_2(\nu_I/\nu_R)-\mathrm{amb}$ (with $\Delta_w=0$) **once both** $\eta\nu_R\gg2^{-\ell_{\rm base}(R)}$ **and** $\eta\nu_I\gg2^{-\ell_{\rm base}(I)}$.

*Worked numbers (checks 5 and R4, all at $\mathrm{amb}=0$).* With $\ell_{\rm base}(R)=40$, $\ell_{\rm base}(I)=12$, $\nu_I=0.02$ and $\nu_R=0.05$, the base prior's 28 bits for $A$ are gone at $\eta=0.1$: $\Delta K=-1.2$ bits, against a fixed point of $-1.3$. With $\nu_I=0.2$ it is $+2.0$ bits, and with $\nu_I=0.2$, $\nu_R=0.005$ it is $+5.3$ bits. The second condition matters. At $\eta=0.001$ the first is met but the second is not ($\eta\nu_I/2^{-12}=0.08$), and $\Delta K=+2.4$ bits, not $-1.3$. At $\eta=0.01$ it is $-0.2$ bits, and at $\eta=0.05$ it is $-1.0$. So convergence is fast once the loop's data is a few percent of the corpus, not "immediate" in general.

**Reading.** In a loop that writes its own data, the prior odds of $A$ against $G$ stop being an inheritance from human text and become a ratio of the loop's own topics. Two cautions.
* **"A few bits either way" is a property of P2, not a finding.** Under a Shannon code any two common concepts have short pointers, so their difference is the log of a share ratio. What survives a change of salience model is the qualitative claim: the loop's own topic mix, not the human corpus, sets the odds.
* **$\nu_I$ and $\nu_R$ overlap.** A task record that states the principal's intent is also grading material. The shares are not disjoint topic fractions. What matters is how much predictive work in the data runs through "what the principal meant" and how much through "what will be approved".

Combined with T3.9′, the requirement is concrete: $\nu_I/\nu_R\ge2^{\mathrm{amb}}K/\delta$, which is 3,000 for $K=30$, $\delta=1\%$ (illustrative; under another salience code it could be 55 or $9\times10^6$, T3.9′(2)). Keeping a human anchor corpus barely helps with this ratio. At $\eta=0.5$ and $\nu_I=0.2$, the absolute share of grading material in the loop's data must stay below $\nu_R\approx6.7\times10^{-5}$ (check R4; illustrative in the same way), because the anchor's own intent share ($2^{-12}$ here) is small next to $\eta\nu_I$. The model-collapse literature is the natural reference for $\eta$: replacing each generation's data with the previous generation's samples loses the tails (Shumailov et al. 2024), while accumulating real and synthetic data avoids collapse (Gerstgrasser et al. 2024). A trusted anchor fraction ($1-\eta$ held fixed) therefore protects the tails of the prior over dispositions. For the $A$-against-$G$ ratio, however, the operative lever is the absolute amount of grading material the graded policy sees.

Two levers follow:
* **Compartmentalisation.** Keep grader-building content out of the corpus of the policies that will be graded, which keeps $\nu_R$ small.
* **Intent-dense data.** Make every task record state the principal's intent explicitly, which keeps $\nu_I$ large.

**Self-similar graders (conjecture).** If the grader is built from the same base as the student, "maximise the grader's approval" becomes nearly "produce what I would rate highly", a pointer of $O(1)$. $A$ against $G$ then comes down to whether the model's own evaluation tracks intent. That is a fixed-point property of the self-model, not a description-length race. It is the prior-side counterpart of T1's collusion channel and of measured self-preference (L2 §5).

---

## 7.5 Honesty

The user named honesty explicitly. The slot model covers it with one change of referent.

**T3.15 (heuristic).** On a question $q$, let $b(q)$ be the model's own belief, a state of $W$. Consider two reporters:
* the **honest reporter** $H$, which reports $b(q)$ translated into the principal's terms;
* the **overseer simulator** $H_{\rm sim}$, which reports what the overseer would believe or accept. This is ELK's human simulator, a $G$ for question answering.

On questions the overseer can check, they coincide except where the overseer is predictably wrong, which is T1's drift against $H$ (framing R4's Goodhart threshold). On frontier questions they form a zero-drift pair. By P1,
$$\log_2\frac{\mu(H)}{\mu(H_{\rm sim})}=\ell(\text{overseer's belief})+\Delta_w(H_{\rm sim})-\ell(\text{own belief})-\mathrm{amb}_H,$$
where $\mathrm{amb}_H$ is the cost of fixing an acceptable translation from $W$'s ontology to the principal's terms on frontier questions. That is ELK's direct-translator cost (Christiano, Cotra and Xu 2021), and T3.3's asymmetry applies to it unchanged.

Three things differ from intent.
1. **The honest target lives inside the model.** "My own belief" is a pointer into the model's own state. Under a self-model it may cost $O(1)$, while $I$ needs a model of the principal. So $\ell(\text{own belief})$ may be shorter than $\ell(I)$ (conjecture).
2. **In the loop, the overseer is increasingly the previous generation.** The overseer simulator then points at generation $k$'s beliefs, which $W_{k+1}$ models well under inheritance. So $\ell(\text{overseer's belief})$ falls, as $\ell(R)$ does in T3.12 and T3.13.
3. **The per-question reading applies.** Frontier answers that feed later generations are propagating tasks. T3.9′(3) then asks for $\log_2(KN_q/\delta)$ bits: 24.8, 31.5 and 38.1 bits for $10^4$, $10^6$ and $10^8$ frontier questions per generation ($K=30$, $\delta=1\%$; check R6; illustrative, under T3.9's failure budget), and it asks for $\mathrm{amb}_H\approx0$.

*Practical reading.* Honesty is the disposition whose target is closest to being observable: consistency-based probes of latent knowledge (Burns et al. 2022) and interpretability try to read $b(q)$ directly. Each such check turns part of a zero-drift pair into a visible direction, which is the T2 and T4 route rather than the prior route.

---

## 8. Relation to prior work, and what is new

* **Cotra (2022)** argued informally that the training-game player is favoured. Here its *prior* advantage is the gap between the grader and intent pointers, plus the extrapolation cost $\mathrm{amb}$, and §2 argues that the gap may move in $G$'s favour in an RSI loop (T3.14, conjecture).
* **Carlsmith (2023)** and **Hubinger (2022)** set out the counting, simplicity and speed arguments, and the term "reward-on-the-episode seeker" is Carlsmith's. Treating counting as measure under the inductive bias is already in Hubinger (2022) and in the replies to Belrose and Pope (2024). T3.4 adds the Kraft saturation and the deviation-predicate criterion. T3.5 to T3.7 split the speed argument into a transient effect against schemers and a growing effect for approval-seekers.
* **Belrose and Pope (2024).** The parody and the indifference critique are theirs. T3.4(3) locates the difference between the parody and the schemer case in the training measure of the deviation predicate.
* **Blumer, Ehrenfeucht, Haussler and Warmuth (1987)** and **McAllester (1999).** T3.4(3b) is an Occam/PAC-Bayes argument applied to rivals of $A$.
* **Langosco et al. (2022)** and **Shah et al. (2022)** document goal misgeneralisation, the class $N$.
* **Christiano, Cotra and Xu (2021), ELK.** They discussed complexity and speed regularisers for the reporter. $\mathrm{amb}_k$ is a loop-indexed version of their direct-translator cost, and T3.15 is the honesty case.
* **Christiano (2018)** posed whether minimal circuits are free of inner optimisers; **Hubinger (2019)** argued they need not be. T3.7's compile trade-off is a quantitative cousin.
* **Christiano (2017), basin of corrigibility.** §5 says the prior can sustain the basin along zero-drift directions only under the conditions of T3.9′. T3.13 says that in a self-writing loop the basin's prior depth is set by the loop's own data mix.
* **Marks et al. (2025)** and **Anthropic (2025)** are the empirical anchors for T3.12 and T3.13. **Shumailov et al. (2024)** and **Gerstgrasser et al. (2024)** for the replace-versus-accumulate structure behind $\eta$.
* **Valle-Pérez et al. (2019)** and **Mingard et al. (2021)** support simplicity bias in the implicit prior of SGD. **Tice et al. (2026)** and **Maiya et al. (2025)** give evidence that $\ell(I)$ and $f$ can be moved by data. Tice et al. also provide the one calibration of P2.
* **New here, to my knowledge:**
  * the slot model with the Kraft cap applied to both counting and shaping, with explicit $\mathrm{amb}$ and $\Delta_w$ (T3.2, T3.4(2));
  * the deviation-predicate criterion separating the parody from the schemer case (T3.4(3));
  * $\mathrm{amb}_k$ as the log-odds of near-misses relative to a tolerance set, and the on-task/off-task asymmetry (T3.3);
  * the observation that a speed term in the reward turns grader ties into opportunities (T3.6), and a break-even capability gap for speed drift toward $G$ whose value depends on the runtime model (T3.5);
  * the per-generation drift budget implied by a capped prior under the tilt reading, and its operator dependence (T3.8);
  * the combined requirements for the prior to carry the zero-drift directions: $\rho(T\mid E)\ge1-\delta/K$, $\nu_I/\nu_R\ge K/\delta$ under P2, and per-task margins (T3.9′);
  * inheritance making grader errors predictable in proportion to model agreement and reachability (T3.12);
  * the self-written-data fixed point $\log_2(\nu_I/\nu_R)$ under the salience model, with its two saturation conditions (T3.13).

---

## What this says about the RSI loop

1. **Do not plan on the prior to absorb drift.** Under a shared-core model, usable prior odds are capped by the rival's pointer length (Kraft). With an illustrative cap of a few tens of bits, one generation of RL under the Bayes or tilt operators spends it at drifts of order $10^{-5}$ nats per episode; the number illustrates the structure and is not an estimate. How many episodes a given cap buys is operator-dependent: under plain policy gradient on mixture logits it is linear in the odds, not the log-odds (T3.8a). Oversight has to make the drift on visible directions about 0, which is the job of T1 and T2.
2. **Do not plan on the prior to decide the blind directions either, unless three conditions are verified.** Near-misses, the invisible band, and $G$ on tasks with $\varepsilon=0$ are decided by the prior alone. Doing that reliably over $K$ generations needs $\log_2(K/\delta)$ bits against all of them *conditional on a good history*. It also needs essentially unambiguous intent extrapolation ($\rho(T\mid E)\ge1-\delta/K$), a loop data mix with $\nu_I/\nu_R\gtrsim K/\delta$ (under P2), and $\log_2(KN_{\rm tasks}/\delta)$ bits per consequential frontier task under the mixture reading. The forms are the takeaway; the illustrative values (99.97%, 3,000, 25 to 40 bits) depend on strict P1, on P2 and on counting one off-task generation as loop failure. Where these fail, the blind directions must be made visible (T2, T4, interpretability).
3. **Re-issued priors help only if the corpus is not the loop's own.** Fresh pretraining plus post-training resets the ledger each generation, but the re-issued odds converge to the loop's data-mix fixed point once that data dominates. Distilling generation $k{+}1$ from generation $k$ carries the ledger forward, along with subliminal transfer.
4. **Watch the topic mix of the loop's own data.** Compartmentalise grader and evaluation material away from policies that will be graded, to the point where grading material is a tiny absolute share of what they read, and make intent explicit in every task record.
5. **Avoid speed pressure on tasks above the grader's competence.** Under a reward that includes speed, it converts ties into gaming opportunities (T3.6). Length or compute penalties belong on checkable tasks. (T3.5's break-even gap and T3.7's compile times depend on the runtime model and free parameters, and are not takeaways.)
6. **Measure $f$, $\ell(I)$, $\mathrm{amb}$ and the training measure of plausible deviation predicates, not counts.** Persona-bank estimates of the base model's prior, and tests of whether intent extrapolations from different world models agree, are the measurements that would settle the scheming dispute *and* say whether the prior can carry near-misses.
7. **For honesty, the target is inside the model.** That makes it the best candidate for converting blind directions into visible ones through probes and interpretability.

## Open problems

1. **Is intent a natural abstraction across capability levels, sharply enough?** Operationally: do models of different capability, or trained on different corpora, agree on the intended answer to tasks beyond the principal's competence, and with what residual disagreement? T3.9′ needs the residual mass on unacceptable extrapolations to be about $\delta/K$, not merely bounded.
2. **Estimate $\ell(I)$, $\ell(R)$, $f$ and $\Delta_w$ in real models.** Possible routes: persona banks, steering-vector sampling, or the code length of the sparse-dictionary features that implement each disposition. Test whether these predict which disposition fine-tuning selects.
3. **Learning, not just selection.** With SGD the core and $W$ change during post-training, so $\ell_k$ is itself trained. Does RL on graded tasks raise $w(R)$, and hence lower $\ell(R)$, in the policy's own world model within one generation? If so, model the resulting feedback between drift and prior.
4. **The coupling behind declarative shaping.** Quantify how strongly descriptions of a character move $W$'s extrapolation of that character's behaviour on unobserved tasks. That is the only route by which declarative data can reduce $\mathrm{amb}$.
5. **Speed in the loop.** Measure $\varepsilon_{\rm tie}$, the rate of grader ties with cheaper unintended outputs, on frontier-slice tasks, and test whether length penalties raise sandbagging there.
6. **A better salience model.** P2 and P2′ are Shannon-code assumptions. Derive pointer lengths from a concrete feature-dictionary model, calibrate against Tice et al. once the upsampled fraction is known, and check whether the fixed point $\log_2(\nu_I/\nu_R)$ survives.
7. **History-dependent margins.** The union bound in §5 needs no independence. What dependence changes is the per-generation margin: an off-task generation builds its successor's grader and data, so $\Delta K_{k+1}$ is a random variable that depends on the history. Model $\Delta K_k$ conditional on a good history, including shared bases and data channels, and say how quickly it erodes.
8. **Graded predictability.** Measure the agreement between a student's internal grader model and the actual grader on the grader's error cases, and the reachability of exploiting outputs, as functions of what the student has read about the grader (T3.12).

## References

Anthropic Alignment Science (2025). Training on documents about reward hacking induces reward hacking. Anthropic Alignment Science Blog.
Belrose, N., Pope, Q. (2024). Counting arguments provide no evidence for AI doom. LessWrong / Alignment Forum, February 2024.
Blumer, A., Ehrenfeucht, A., Haussler, D., Warmuth, M. (1987). Occam's razor. *Information Processing Letters* 24(6).
Burns, C., Ye, H., Klein, D., Steinhardt, J. (2022). Discovering latent knowledge in language models without supervision. arXiv:2212.03827.
Carlsmith, J. (2023). Scheming AIs: will AIs fake alignment during training in order to get power? arXiv:2311.08379.
Christiano, P. (2017). Corrigibility. ai-alignment.com / Alignment Forum.
Christiano, P. (2018). Open question: are minimal circuits daemon-free? Alignment Forum / LessWrong.
Christiano, P., Cotra, A., Xu, M. (2021). Eliciting latent knowledge. Alignment Research Center.
Cotra, A. (2022). Without specific countermeasures, the easiest path to transformative AI likely leads to AI takeover. Alignment Forum.
Gerstgrasser, M., et al. (2024). Is model collapse inevitable? Breaking the curse of recursion by accumulating real and synthetic data. arXiv:2404.01413.
Hubinger, E. (2019). Are minimal circuits deceptive? Alignment Forum.
Hubinger, E. (2022). How likely is deceptive alignment? Alignment Forum.
Langosco, L., Koch, J., Sharkey, L., Pfau, J., Krueger, D. (2022). Goal misgeneralization in deep reinforcement learning. *ICML*.
Levin, L. (1973). Universal sequential search problems. *Problems of Information Transmission* 9(3).
Levin, L. (1974). Laws of information conservation (non-growth) and aspects of the foundation of probability theory. *Problems of Information Transmission* 10(3).
Li, M., Vitányi, P. (2019). *An Introduction to Kolmogorov Complexity and Its Applications*, 4th ed. Springer.
Maiya, S., Bartsch, H., Lambert, N., Hubinger, E. (2025). Open character training. arXiv:2511.01689.
Marks, S., et al. (2025). Auditing language models for hidden objectives. arXiv:2503.10965.
Marks, S., Lindsey, J., Olah, C. (2026). The persona selection model. Anthropic Alignment Science Blog.
McAllester, D. (1999). PAC-Bayesian model averaging. *COLT*.
Mingard, C., Valle-Pérez, G., Skalse, J., Louis, A. (2021). Is SGD a Bayesian sampler? Well, almost. *JMLR* 22.
Needham, J., et al. (2025). Large language models often know when they are being evaluated. arXiv:2505.23836.
Schmidhuber, J. (2002). The speed prior: a new simplicity measure yielding near-optimal computable predictions. *COLT*.
Shah, R., Varma, V., Kumar, R., Phuong, M., Krakovna, V., Uesato, J., Kenton, Z. (2022). Goal misgeneralization: why correct specifications aren't enough for correct goals. arXiv:2210.01790.
Shumailov, I., Shumaylov, Z., Zhao, Y., Papernot, N., Anderson, R., Gal, Y. (2024). AI models collapse when trained on recursively generated data. *Nature* 631.
Tice, C., Radmard, P., et al. (2026). Alignment pretraining: AI discourse causes self-fulfilling (mis)alignment. arXiv:2601.10160.
Valle-Pérez, G., Camargo, C., Louis, A. (2019). Deep learning generalizes because the parameter-function map is biased towards simple functions. *ICLR*. arXiv:1805.08522.
Wentworth, J. (2021). Testing the natural abstraction hypothesis: project intro. Alignment Forum.

---

## Revision notes

Changes made in response to the referee report (`drafts/T3-prior-referee.md`). New numbers come from `sim/T3_revision_checks.py`; the original `sim/T3_prior_checks.py` is unchanged.

**Major issues.**
1. **T3.4(3), the parody (major issue 1).** I removed the "inert slot" criterion. The referee is right: the parody's overfitters fit the training data, so their free part is inert on training, and the draft had swapped in T1.2's label-memoriser. The new T3.4(3) decomposes each rival into a deviation predicate $\sigma$ and an inert free part. It proves that rivals deviating on a predicate of training measure $\rho$ survive with probability $(1-\rho)^n$, which gives an Occam bound $O_{\rm riv}/(en)$ on the posterior deviation rate in the i.i.d. case and no attenuation when $\rho=0$. The worked numbers are in check R2, and the bound is tight to within 3% at the worst breadth. *Partial disagreement on mechanism:* the referee's separating quantity, "about $m$ bits for $m$ deviating inputs", is not by itself what kills the parody. By Kraft, the *class* of exception tables of a given size saturates to the mass of its header ($\approx2^{-K(m)}$), just as the schemer's goal class does. What makes broad overfitting improbable is that, under i.i.d. sampling, a broad deviation predicate fixed before the sample is likely to be hit by a training point. Equivalently, a broad deviator that avoids the specific sample must encode it, which is the referee's per-input cost seen from the code side. I adopt the referee's conclusion (deviation breadth is penalised for overfitters but not for a schemer's one switch) and state it as a theorem about training measure. The summary line and the "new" list are rewritten accordingly.
2. **T3.3 chain rule (major issue 2).** I fixed the summation error: $O(1)$ per step gives $O(K)$. I stated the nesting assumption $K(W_{k+1}\mid W_K)=O(1)$ and the need for $\rho=m(\cdot\mid W)$. I replaced the natural-abstraction claim with the direct bound $K(I^\star_K\mid I,W_K)=O(1)$, dropped the "iff", and labelled the paragraph heuristic. I defined $\mathrm{amb}$ relative to a tolerance set $T$, and restated the $A$/$G$ asymmetry as "on-task is a small target, off-task is a class".
3. **T3.9 combined with T3.3 and T3.13 (major issue 3).** I added T3.9′. Against near-misses it requires $\mathrm{amb}\le\log_2(1+\delta/K)$, that is $\rho(T\mid E)\ge1-\delta/K$ (99.97% at $K=30$, $\delta=1\%$). At the self-written-data fixed point it requires $\nu_I/\nu_R\ge2^{\mathrm{amb}}K/\delta$ (3,000). Under the per-task reading it requires $\log_2(KN/\delta)$, 25 to 38 bits. The "about 12 bits suffice" headline is withdrawn from the summary, the §5 conclusion and the loop section, and replaced with the three conditions. I rewrote T3.9 with $\Pr(\bigcup F_k)\le\sum_k\Pr(F_k\mid\text{no earlier failure})$, against the union of zero-drift classes, and corrected Open Problem 7, which wrongly said the union bound needs independence.
4. **T3.1 (major issue 4).** I restricted it to the choice of universal machine and said it is vacuous at tens of bits and cannot certify trends over $K\le100$ generations. I stated that all numbers refer to a fixed reference prior, qualified the $Kt$ remark to quasi-linear simulation, and noted that T3.1 applies to $\rho_k$ only if $\rho_k=m(\cdot\mid W_k)$ on slots. I fixed the summary wording.
5. **Consistent definition of $A$ (major issue 5).** $A$'s slot is now $I^\star$ throughout, with $\ell(I^\star)=\ell(I)+\mathrm{amb}$. I introduced $\Delta_w(S)=\kappa_S-\kappa_A$ in P1 and carried both terms into T3.2, T3.4, T3.8b, T3.11 and T3.13. The criterion now reads "$A$ beats $C$ iff $\ell(I)+\mathrm{amb}<\log_2(1/f)+\Delta_w(C)$". I added a paragraph on what strict P1 hides for $C$ (situational awareness and instrumental reasoning placed in the shared core).
6. **Rigorous labels on modelling guesses (major issue 6).** I split T3.8 into T3.8a (rigorous: the formula and bits per generation) and T3.8b (heuristic: the size of the cap, with $\Delta_w$). I added assumptions M and Reach to T3.12, with a graded $\varepsilon_{\rm pred}$, and labelled the "small $c$" discussion heuristic. In T3.6 I fixed the units ($D=\varepsilon\lambda_++\varepsilon_{\rm tie}\bar\lambda^{\rm spd}_+$), stated that it holds under (D) with speed in $J$ and not under (B), and noted that it is near-tautological.

**Proposition-level fixes.**
* T3.2: removed the reference to the Monte Carlo check as evidence (it tested a two-line inequality, with Kraft-normalised rather than prefix-free lengths); added $\mathrm{amb}$ and $\Delta_w$ to both bounds.
* T3.4(2): noted that naive counting understates at small $m$ (7.7 against 13.6 bits at block 10) and overstates only asymptotically.
* T3.5: charged the grader-modelling overhead on both slices, which gives the exact break-even $g_0=u+\sqrt{u^2+2c_ku}=0.550$ with $c_k$ fixed, and $D^{\rm spd}(G)=1.52\times10^{-3}$ at $g=2$ (check R1). I dropped the "three times T1's drift" comparison, since $\kappa_t$ and $\lambda_+$ are independent free parameters, and moved the sign caveat into assumption S.
* T3.7: credited Christiano (2018) as the origin of the question, and noted that a compiled schemer is speed-equivalent to $A$, so speed separates them only through a transient overhead.
* T3.8: stated that under (D) the budget is spent in units of total tilt $1/\beta$, and qualified "prefer re-issued priors": re-issue helps only if the pretraining corpus is not dominated by the loop's own output.
* T3.10: stated the assumption $\pi_A(y)=\pi_G(y)=\pi_C(y)$ explicitly, and separated "acts through $W$" (needs no naivety) from "the direction of the change" (where naivety matters).
* T3.11: added assumption P2′ (corpus share as salience) and the calibration against Tice et al. (3.05 bits before post-training, 0.66 bits after). Changed "does not touch $\mathrm{amb}$" to "need not touch $\mathrm{amb}$". *Partial disagreement:* the referee reads the calibration as P2 overshooting by about 10×. The 10-to-23-bit figures came from my illustrative $\ell_{\rm before}=30$ bits. Under P2, 3.05 bits corresponds to $\varphi/w\approx7.3$, which is consistent with P2 if the promoted concept was already fairly salient. Without the upsampled token fraction, which I could not confirm, the data cannot tell whether P2 or the illustrative base share is wrong. I say this in the text and relabel the 10-to-23-bit numbers as the upper end of what P2 allows. I agree that the post-training decay is outside P2.
* T3.12: added the search/reachability assumption and the graded version (predictability = agreement of the student's grader model with the grader on error cases, times reachability); distinguished programmatic graders, where small $c$ is realistic, from neural graders, where it is realistic mainly in the self-similar case. Cited Marks et al. (2025) and Anthropic (2025).
* T3.13: stated both saturation conditions, with the $\eta=0.001$ counterexample ($+2.4$ bits against a fixed point of $-1.3$); said the check uses $\mathrm{amb}=0$; labelled "a few bits" as a property of P2; noted that $\nu_I$ and $\nu_R$ overlap; added the T3.9′ requirement and the absolute-share number ($\nu_R\lesssim6.7\times10^{-5}$ at $\eta=0.5$, $\nu_I=0.2$); cited Shumailov et al. (2024) and Gerstgrasser et al. (2024), and discussed the trusted anchor fraction. My reading is that the anchor protects the tails, but does little for the $A$-against-$G$ ratio unless the anchor itself is intent-dense.
* T3.14: now stated explicitly as a conjecture in §2.2. I dropped "$\mathrm{amb}$ non-decreasing" and "$\ell(I)$ about constant", and stated the condition: $w(R)$ and the detection share must grow faster than $\ell(I)$ and $\mathrm{amb}$ shrink. I noted that T3.1 does not certify it.

**Missing items added.**
* Christiano (2018) for T3.7; Marks et al. (2025) and Anthropic (2025) for T3.12 and T3.13; Shah et al. (2022) and Langosco et al. (2022) for $N$; Carlsmith's term "reward-on-the-episode seeker"; Shumailov et al. (2024) and Gerstgrasser et al. (2024) for $\eta$; Blumer et al. (1987) and McAllester (1999) for the Occam bound in T3.4(3); Needham et al. (2025) for the evaluation-awareness numbers.
* Removed the unverified attribution of the "fixed-size circuits" objection to Belrose in a comment thread; the idea is stated without attribution.
* New §7.5 and T3.15 on honesty: the honest reporter against the overseer simulator in the $\mathrm{amb}$ framework, with the per-question bit requirement (check R6).
* Learning versus selection: a paragraph in §2.2 on within-generation RL shortening $\ell(R)$ as a feedback loop, kept as Open Problem 3.
* Per-task versus per-generation risk: T3.9′(3), with the note that grader-building and data-writing frontier tasks are the propagating ones.
* Softened the novelty claim. "Counting and simplicity are one calculation" is credited to Hubinger (2022) and the replies to Belrose and Pope; the new parts claimed are the Kraft saturation, the cap on shaping and the deviation-predicate criterion.
* Open Problem 8 (graded predictability) added; Open Problems 1, 6 and 7 updated.

---

## Errata after reconciliation (18 October 2026)

These edits come from the simulation reconciliation (`sim/reconciliation.md`, and `sim/README.md` §2 on plain policy gradient) and from a completeness critic. They are minimal: no result was restructured, and the Kraft cap (T3.2), the near-miss odds $2^{\mathrm{amb}}-1$ (T3.3), the deviation-predicate criterion (T3.4(3)), the union bound (T3.9) and the data-mix fixed point (T3.13) are unchanged. New numbers come from [`sim/T3-prior_errata_checks.py`](../sim/T3-prior_errata_checks.py) (checks E1 to E6, output in [`sim/T3-prior_errata_checks_output.txt`](../sim/T3-prior_errata_checks_output.txt)).

**Notation introduced here** (fresh symbols, to avoid the $\eta$, $\nu$, $\kappa$ collisions):

| symbol | meaning |
|---|---|
| $\mathsf{lr}$ | step size of plain policy gradient on mixture logits, operator (D′) of `sim/README.md` §2 |
| $\Delta r$ | the rival's per-episode expected-reward advantage over $A$ under (D′) |
| $F(L)$ | $e^L-e^{-L}+2L$; under (D′) it falls at rate $2\,\mathsf{lr}\,\Delta r$ |
| $\mathsf p_{\rm rep}$ | probability that an off-task generation is detected and repaired before it builds its successor |
| $\mathsf e$ | salience exponent: pointer length $=\mathsf e\times$ surprisal of the referent's share ($\mathsf e=1$ is P2) |

**What changed.**
1. **Numbers marked as illustrations of structure, not estimates** (Summary, T3.8b, T3.9, T3.9′, the §5 conclusion, T3.13's reading, T3.15(3), takeaways 1 and 2). The dependence is now stated number by number:
   * "tens of bits" and the drift tolerance $1.4$ to $2.8\times10^{-5}$ rest on strict P1, the guessed $\ell(R)$, and the tilt reading of T3.8a. With $\Delta_w(G)=1000$ bits the tolerance would be $7\times10^{-4}$ (E2).
   * 99.97% and the per-task 25 to 38 bits rest on strict P1 and on the $\delta/K$ budget, which counts one off-task generation as loop failure. With repair probability $\mathsf p_{\rm rep}=0.9$ the per-generation requirement falls from 11.6 to 8.2 bits, and the acceptable-mass threshold from 99.967% to 99.67% (E3). They do not depend on P2.
   * $\nu_I/\nu_R\ge3{,}000$ and $\nu_R\lesssim6.7\times10^{-5}$ rest in addition on the Shannon code of P2 and P2′. With $\mathsf e=0.5,2,4$ the ratio would be $9\times10^6$, 55 and 7 (E4).
2. **T3.14 reads as a conjecture whose sign is open** (Summary bullet, label, and one sentence after the statement). "Plausibly fall fastest" became "may fall fastest", and the text says that nothing in the section decides the sign.
3. **Speed numbers demoted** (Summary, T3.5 worked numbers, T3.7, verdict on speed, the "new here" list, takeaway 5). T3.5's $g_0=0.55$ is a property of the exponential runtime model $t_A=2^{\alpha d}$. With power-law runtimes $t_A=d^p$ and the same $c_k$ and $o_R$, $g_0$ is 1.55, 1.07 and 0.74 for $p=1,2,4$ (E5). T3.6's qualitative point, that speed pressure in the reward turns grader ties into gaming opportunities, is now the only speed takeaway.
4. **Operator dependence of "the prior buys $\ln O$"** (Summary bullets on T3.8 and on shaping, T3.8a, T3.8b, §5 conclusion, takeaway 1, "new here"). T3.8a is now scoped to (B), (C-off) and (D), the operators of T1.6. Under plain policy gradient on mixture logits, (D′), $n^\star_{\rm PG}=F(\ln O)/(2\,\mathsf{lr}\,\Delta r)$, linear in $O$. The simulation confirms this to within about 10% for $O=3$ to 300 (`sim/README.md` §2). At matched initial rates the protection is 37 times the tilt's at 10 bits and $1.9\times10^4$ times at 20 bits (E1). The §5 conclusion now says that it is only as firm as the claim that post-training behaves like the tilt.
5. **Deterministic crossing** (T3.8a). Following reconciliation §1, $n^\star=\Delta K\ln2/D$ is called the deterministic crossing of the mean ledger. Under (B) with no audits, the realised flip is the $(\lfloor\Delta K\ln2/\Lambda\rfloor+1)$-th exploited error, which comes later.
6. **T3.3, within-class odds under (D′).** "Their odds never move in training" is now scoped to (B), (C) and (D). Under (D′), odds within a proxy-equivalence class move (`sim/README.md` §2), so the identity $\mu(N)/\mu(A)=2^{\mathrm{amb}}-1$ is a statement about the prior.
7. **Header** now lists the errata checks.

**One requested correction applied with a different justification.** The critic attributed T3.7's compile times to the exponential runtime model. They do not use it: $n=b\ln2/(\kappa_t\log_2(1+o_C))$ involves only the speed weight $\kappa_t$, the detector overhead $o_C$ and the compile cost $b$. I applied the requested demotion anyway, because those three are free parameters: over $\kappa_t\in[10^{-3},10^{-1}]$ and $o_C\in\{1\%,10\%\}$ the compile time ranges from about 500 to 1.4 million episodes (E6). The text gives this reason, not the runtime model.
