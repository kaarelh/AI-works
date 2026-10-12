# Referee report: track "context"

*Adversarial referee report on `notes.md` and `checks/` of the context track (brief items H8 and H10, the motivation, the literature and the extras). I did not edit the notes. My code is in `referee_code/ref_*.py`. Each script is seeded where it uses randomness and writes `<name>_output.txt` next to itself.*

*Provenance.* This folder already held a `referee.md` and scripts `referee_code/r1_*.py`–`r7_*.py` from an earlier referee pass, and a `notes-final.md` written after that pass. This report replaces the earlier `referee.md`. The `r*` scripts are not mine. I reviewed `notes.md` independently first and then compared my findings with the earlier report. Where we agree I say so. Where my result differs or is sharper, I say that too (M1, M3).

---

## 0. Verdict

* **No fatal issues.** I checked every proof marked [proved] line by line. All the inequalities in §§2–4 survive, with the wording fixes listed below. The five check scripts reproduce their saved outputs byte for byte.
* **Six major issues.**
  * **M1.** Remark 3.10 and open problem 5 say it is open whether Occam circuit learning can make super-polynomially many out-of-distribution mistakes. It can. A conjunction ladder forces at least $2^d-d-2$ mistakes on a target with $d-1$ gates, in the notes' own circuit language and for every tie-breaking rule. I give a proof and exhaustive checks. The notes also call the weighted-majority vote "Bayes MAP". In standard usage the MAP-hypothesis learner is the argmax learner, and that learner is the one that fails.
  * **M2.** Prop 5.1's title, its reading and Cor 5.2 are wrong for sub-probability predictors. Order independence characterises *weak* function semimeasures, not laws of random partial functions. $M_F$ is not the universal order-independent predictor.
  * **M3.** §2.4–2.5 say that "no bound of the form 'no simple separating property ⇒ small error' holds". That is overbroad. A clean converse holds once the bound may depend on $K(f)$ and the property may depend on the input set. It also gives a per-step in-distribution upper bound, which the track lacks.
  * **M4.** §3.1 says "restricting to distinct inputs loses nothing". This is false for the comparison class the theorem uses: conditional laws with fresh noise. The sentence widens the apparent scope of Theorem 3.1.
  * **M5.** The Vaintrob–Hänni slides are treated as unavailable (§4.5 placeholder). The brief says they are available. Several "open" statements in §§3–4 are stale as a result.
  * **M6.** The "apparently new" list in §6 and several attributions are wrong or incomplete. Rem 4.8, Thm 4.6, the ladder and halving facts, Prop 2.4 and Prop 2.9 all have prior sources.
* **Minor issues** m1–m18 are listed in §3.

---

## 1. What I did

* **Re-ran the track's scripts.** I copied `checks/c1`–`c5` to a scratch directory and ran them (Python 3, numpy 2.4.6). All five outputs are identical to the saved ones (`diff -q`).
* **Read the sources.** I read the brief, Hänni's source notes named in it (polytime, the circuit notes, the bridging and NN-prior notes, the OOD notes, the SFI draft §3), and the slides text. Appendices F, J and K of the slides bear on this track. I also read the foundations track notes for cross-track consistency.
* **Wrote independent code** (`referee_code/`):

| script | target in notes.md | result |
|---|---|---|
| `ref_occam_ladder_circuits.py` | Rem 3.10, open problem 5, summary item 10 | Exact minimal gate counts (all 16 gates; $d=3,4,5,6$). Occam on $f=\mathrm{AND}_d$ with the adversary of M1, under 7 tie-breaking rules: every point of Hamming weight $2..d-1$ (within the enumerated sizes) is a mistake. Mistakes: 4–8 ($d=3$), 10–12 ($d=4$), 25–27 ($d=5$, sizes ≤3 only), 35–36 ($d=6$, sizes ≤2 only). It also refutes a naive "stage by stage" version of the ladder argument in the gate-count language (see M1). |
| `ref_order_independence_weak.py` | Prop 5.1, Cor 5.2 | Two order-independent predictors (exhaustive one-step checks, 0 violations) that are not Bayes predictors for any random partial function (LP infeasible). For foundations' $\tau$, the best domination constant by any random-partial-function law is $2/3$ (LP, to 12 digits). |
| `ref_time_bounded_repeats.py` | Thm 3.1, §3.1 "Setting" | On distinct inputs, my implementation independently confirms (b)'s bookkeeping ($4.6\cdot10^{-13}$ against brute force) and (a)'s bound (regret 698.8 ≤ 1216). Precision perturbations $\varepsilon_k=k^{-2}$ change the loss by $-1.26$ bits ($\sum\varepsilon_k=1.645$). With a repeated short input and fresh noisy labels, regret grows linearly: 0.53 bits per round over $10^4$ rounds. |
| `ref_kernel_parity.py` | Thm 4.6, Cor 4.7, Rem 4.8 | Exact Walsh eigenvalues via Krawtchouk sums. Odd degrees ≥3 vanish for the bias-free 2-layer ReLU NNGP and NTK ($\le3\cdot10^{-18}$); they are nonzero with a bias or with 3 layers. The values match c2. For odd $k\ge3$, sign(KRR) accuracy on unseen points falls to 0.21–0.28 as $n$ grows, which is *below* chance. |
| `ref_constants_and_occam_iid.py` | Props 2.12, 3.8, 3.9; §3.2 surgery cost | All constants hold. Prop 2.12's ratio is ≥1 and tight as $m\to2^j+1$. The Prop 3.9 constant has margin 1.7. Surgery $B(s)$ has 0 violations for $d<40$, $s<300$. Occam in distribution on the exact $d=4$ circuit order: mean mistakes 3.2–6.3 against Prop 3.9 bounds of 45–77. |
| `ref_uniform_circuit_prior.py` | Prop 4.5 | Brute force over all size-$S$ circuits for $(d,S)\in\{(1,2),(2,2),(3,2),(1,3),(2,3)\}$, up to 59M circuits: the bound holds for every $f$ with $c(f)<S$ (slack ≥784). |

* **Checked references** with WebSearch. Only snippets are available: arxiv.org, lesswrong.com, raysolomonoff.com, doc.rero.ch and cs.bu.edu are blocked or do not resolve here. Every reference I report as confirmed is confirmed at snippet level only.

---

## 2. Major issues

### M1. Occam out of distribution is not open: a natural target forces exponentially many mistakes (Rem 3.10, open problem 5, summary item 10); and "MAP" is misnamed

**Claim.**
* Rem 3.10: "For natural languages a super-polynomial lower bound, or a polynomial upper bound, is **open**."
* Summary item 10: "Out of distribution only the trivial bound $|H_f|-1=2^{O(\ell)}$ is known."
* §7 lists this as open problem 5.

**Problem.** The question has a short negative answer in the notes' own circuit language (§3.2: all 16 binary gates, size = number of gates, Occam orders functions by size).

**Proposition R1 (conjunction ladder, gate-count circuits) [referee: proved; computed].** Let $d\ge3$ and $f=x_1\wedge\dots\wedge x_d$. Then $c(f)=d-1$ and the description length is $\ell(f)=(d-1)+\log_2N_{d-1}=\Theta(d\log d)$. For every tie-breaking rule among functions of equal size, there is an ordering of $\{0,1\}^d$ on which the Occam learner makes at least $2^d-d-2$ mistakes. In terms of description length this is $2^{\Omega(\ell/\log\ell)}$, against the trivial upper bound $2^{O(\ell)}$.

*Proof.*
1. A circuit with $s$ gates computes a function of at most $s+1$ variables. Let the output's cone have $s'\le s$ gates. Its $2s'$ input slots include at least $s'-1$ references to gates of the cone, so at most $s'+1$ slots read variables or constants.
2. For $2\le k\le d$, a conjunction $\mathrm{AND}_T$ with $|T|=k$ has $c=k-1$. A chain of AND gates gives the upper bound and step 1 gives the lower bound.
3. *Adversary.* First reveal $1^d$ (label 1). Then, while Occam's current hypothesis $h$ has $c(h)<d-1$, let $V_h$ be the set of variables $h$ depends on. Then $|V_h|\le c(h)+1<d$. Reveal $1_{V_h}$, the point with ones exactly on $V_h$.
   * $h$ depends only on $V_h$, so $h(1_{V_h})=h(1^d)=1$.
   * $f(1_{V_h})=0$, because $V_h\ne[d]$. So the step is a mistake.
   * $1_{V_h}$ was not revealed earlier, or $h$ would be inconsistent.
   * After this phase, reveal the remaining points in any order.
4. Fix $2\le k\le d-1$ and $|T|=k$. While $\mathrm{AND}_T$ is consistent, $h$ precedes it in the Occam order, so $c(h)\le k-1<d-1$. Hence the adversarial phase is still running, and every point it reveals has weight $|V_h|\le k$.
   * $\mathrm{AND}_T$ is killed only by a revealed point $x$ with label 0 and $\mathrm{ones}(x)\supseteq T$.
   * Among points of weight $\le k$, the only such point is $1_T$.
   * $\mathrm{AND}_T$ must die before all points are revealed, since it disagrees with $f$ at $1_T$.
   * So $1_T$ is revealed in the adversarial phase, as a mistake.
5. Every point of Hamming weight $2,\dots,d-1$ is therefore a mistake. That is $\sum_{k=2}^{d-1}\binom dk=2^d-d-2$ mistakes. ∎

**Evidence** (`ref_occam_ladder_circuits_output.txt`).
* For $d=3,4,5,6$ and 7 tie-breaking rules (truth-table order ascending and descending, and 5 random permutations), every point of weight $2..d-1$ was a mistake, within the enumerated sizes. Exact minimal sizes were enumerated up to 2 gates ($d=3,6$) and up to 3 gates ($d=4,5$).
* My first version of the script tested a stage-by-stage claim: "while the cheapest survivors are $k$-conjunctions, each stage contributes exactly $\binom dk$ mistakes". That claim is **false** at $k=1,2$ in the gate-count language. A literal or a constant already costs one gate, so early hypotheses can read two variables and kill several low-level conjunctions at once. At $d=4$ the stage counts were 1–2 instead of 4 at $k=1$, and 3–4 instead of 6 at $k=2$. The total count in step 5 is unaffected. The fix should use the proof above, not a per-stage count.
* The slides (Appendix K, "the conjunction ladder") prove the analogous statement for a formula cost model: $2^{\Theta(C/\log C)}$ worst-case Occam mistakes, with the stage argument via Möbius inversion. c1's own output ("Occam worst = 8" of 8 inputs at $d=3$) already pointed this way. The notes dismissed it as saying nothing about asymptotics.

**Terminology problem ("MAP").** Thm 3.5, Rem 3.6, Rem 3.10, §4.3 and c1 call the posterior-majority (weighted-majority) label rule "Bayes MAP".
* In standard usage, MAP means the maximum-a-posteriori *hypothesis*.
* Under the prior $w(C)=2^{-s}/N_s$, the MAP *circuit* is the smallest consistent circuit, that is, the Occam learner. By R1 it makes exponentially many mistakes.
* The weighted-majority vote is the learner with at most $L_B$ mistakes. The slides' table (Appendix K) separates exactly these: "argmax — Occam / MAP / MDL: $2^{\Theta(C/\log C)}$" against "weighted majority vote: $\le C$".
* Calling the good learner "MAP" inverts the meaning a reader will assume.

**Fix.**
* Replace "open" in Rem 3.10, summary item 10 and open problem 5 with Prop R1 and its proof. Cite slides Appendix K for the formula version.
* State the separation explicitly: on every ordering the weighted-majority vote makes at most $L_B=O(c\log(c+d))$ mistakes (Rem 3.10), while the argmax/Occam learner can make $2^d-d-2$.
* Rename "Bayes MAP" to "posterior-majority (weighted-majority) prediction" throughout, including the c1 output labels.
* The remaining open question is the $\log\ell$ gap in the exponent, and the behaviour of randomised tie-breaking. The slides claim $\tilde\Theta(C^2)$ for the latter, unverified here.

---

### M2. Prop 5.1 (title and reading), Cor 5.2 and the summary's "SFI is the universal element of that class" are wrong for sub-probability predictors

**Claim.**
* Prop 5.1 is titled "order-independent predictors are Bayesian predictors for random partial functions".
* The reading says order independence "singles out exactly the Bayesian predictors over random (partial) functions".
* Cor 5.2: "If $M_F$ dominates every lower-semicomputable function semimeasure (H1(a)), then SFI is universal among lower-semicomputable order-independent predictors."
* Summary, "Extras", repeats this.

**Problem.**
* The body of Prop 5.1 is correct. It characterises order-independent predictors as *weak* function semimeasures: one-point inequalities $\sum_y\nu(D+(x,y))\le\nu(D)$ only.
* A weak semimeasure need not be the containment functional $P(F\supseteq D)$ of any random partial function. Example: $\nu(\{a\mapsto0\})=\nu(\{b\mapsto0\})=1$ and $\nu(\{a\mapsto0,b\mapsto0\})=0$. The induced predictor is order independent but is not Bayesian for any random partial function.
* Hence the title and the reading are false in the sub-probability case. They hold in the normalised case (random total functions), as the last bullet of the proof says.
* Cor 5.2's hypothesis, read for the class Prop 5.1 produces, is false. The foundations track proves that the universal weak semimeasure $M^w$ exceeds $M_F$ by up to $2^{K(\mathrm{dom}\,D)}$, and by an unbounded factor along a sequence (foundations Thm 3.4, Thm 3.5(iii), Prop 7.2(b)). So the universal *order-independent* predictor is $M^w$, not $M_F$.

**Evidence.** `ref_order_independence_weak_output.txt`:
* the two-input example: 0 one-point violations; order-independence spread 0; LP for equality with a random-partial-function law infeasible;
* foundations' $\tau$: weak, order independent, equality infeasible; best domination constant $0.666666666667=2/3$ by LP;
* a normalised sanity case: feasible, as expected.

The earlier referee pass reached the same conclusion.

**Fix.**
* Retitle Prop 5.1: "order-independent predictors = weak function semimeasures".
* Keep the Bayesian reading only for (i) normalised predictors, or (ii) weak semimeasures satisfying foundations' Möbius condition (its Prop 2.3).
* Replace Cor 5.2 by two statements. $M_F$ dominates every machine law. $M^w$ is universal among lower-semicomputable order-independent predictors, and $M^w/M_F$ is unbounded.
* Correct the summary accordingly.

---

### M3. The answer to H8's converse question is overbroad and misses a clean positive converse (§2.4–2.5, summary item 6)

**Claim.**
* §2.5 item 1: "No bound of the form 'no simple separating property ⇒ small error' holds (Prop 2.13)."
* Summary item 6 says the naive converse is false and that the strongest true positive statements are relative ones.
* Prop 2.12's discussion compares a per-step lower bound with a Cesàro upper bound. The track has no per-step upper bound.

**Problem.**
* Prop 2.13 refutes the converse only when $f$ is random ($K(f)\gg m$), where no learner can succeed.
* Once the bound may depend on $K(f)$, and the separating property may depend on the full input set $B$ as well as on a program for $f$, a converse holds. It follows from the track's own sandwich ingredients (Prop 2.14 and (F2)).
* The earlier referee pass gave a version with $2^{2K_B(f)-K(x^*\mid B)}$. The version below is sharper: it conditions on the program, so $K(f)$ enters once. It also yields a per-step bound without a $\log m$ factor.

**Proposition R2 (converse given the input set) [referee: proved].** Let $\nu\in\{W,M_F\}$. Let $A$ be finite, $x^*\notin A$ and $B=A\cup\{x^*\}$ (given as a canonical list). Let $f$ be defined on $B$, and let $p\in\mathcal P$ compute $f$ on $B$. Let $e_{\rm norm}(x^*):=1-\nu_{\rm norm}(f(x^*)\mid x^*,f|_A)$. Put
$$\sigma_{B,p}(x^*):=\min\{K(Q\mid B,p):\ Q\text{ decidable},\ x^*\in Q,\ Q\cap A=\emptyset\}.$$
Then
$$e_{\rm norm}(x^*)\ \le\ 2^{\,|p|-K(x^*\mid B,p)+c}\ \le\ 2^{\,|p|-\sigma_{B,p}(x^*)+c'},\qquad |K(x^*\mid B,p)-\sigma_{B,p}(x^*)|\le c'.$$
With $p$ a shortest such program, $|p|=K_B(f)$.

*Proof.*
1. For $x\in B$ put $\mu_{B,p}(x):=\sum_{y\ne f(x)}\nu\big(f|_{B\setminus\{x\}}\cup\{(x,y)\}\big)$, and $\mu_{B,p}(x):=0$ off $B$.
2. The hypothesis sets counted for distinct pairs $(x,y)$ are disjoint. These are programs for $W$ and tapes for $M_F$. A hypothesis in two of them would agree with $f$ at a point where it also disagrees with $f$. So $\sum_x\mu_{B,p}(x)\le1$.
3. $\mu_{B,p}$ is lower semicomputable uniformly in $(B,p)$. First run $p$ on $B$ to obtain $f|_B$, then enumerate. By (F2) with condition $\langle B,p\rangle$, $\mu_{B,p}(x^*)\le2^{-K(x^*\mid B,p)+c}$.
4. The normalised error is $\sum_{y\ne f(x^*)}\nu(f|_A\cup\{(x^*,y)\})\big/\sum_y\nu(f|_A\cup\{(x^*,y)\})\le\mu_{B,p}(x^*)/\nu(f|_B)$. Moreover $\nu(f|_B)\ge2^{-|p|}$ for $W$, and $\ge2^{-|p|-c}$ for $M_F$.
5. For $\sigma$: given $B$ and a decider of $Q$, $x^*$ is the unique element of $Q\cap B$. Conversely, $Q=\{x^*\}$ separates. ∎

*Scope.* R2 bounds the normalised error, i.e. the wrong-but-defined mass. The mass that is *undefined* at $x^*$ is not lower semicomputable, and I make no claim for the semimeasure-convention $e$.

**Corollary R3 (per step, any input distribution) [referee: proved].**
* Let $x_1,\dots,x_m,x^*$ be i.i.d. from any distribution on $X$, and let $f$ be computable. Then $\mathbb E\,e_{\rm norm}(x^*)\le2^{K_F(f)+c}/(m+1)$.
* *Proof.* Condition on the multiset of the $m+1$ draws. By exchangeability the test point is a uniformly random position.
  * A position whose value repeats has error 0.
  * A position with a unique value $x$ has training set $B\setminus\{x\}$, where $B$ is the set of distinct values. R2 bounds its error by $2^{K_B(f)-K(x\mid B,p_B)+c}$.
  * Kraft gives $\sum_{x\in B}2^{-K(x\mid B,p_B)}\le1$, and $K_B(f)\le K_F(f)$. ∎
* With $A=B\setminus\{x\}$ for each $x$, the same sum gives the normalised leave-one-out bound $\frac1{|B|}\sum_{x\in B}e_{\rm norm}(x)\le2^{K_B(f)+c}/|B|$. This is the normalised counterpart of Prop 2.10.

**Consequences for the notes.**
* *A two-sided per-point picture.* The lower bound is $2^{-\sigma(x^*;A)-c}$ (Prop 2.1, unconditional property). The upper bound is $2^{K_B(f)-\sigma_{B,p}(x^*)+c}$ (property conditional on $B$ and $p$). The gap between the two separating complexities is the value of knowing the other inputs. The notes' reading of Prop 2.14 says this in words.
* *Per-step rate.* For $f\equiv0$ under uniform i.i.d. inputs, the per-step normalised error lies between $2^{-c}/(8m(\log_2m+3)^2)$ (Prop 2.12) and $2^{c}/(m+1)$ (R3). This replaces the per-step versus Cesàro comparison criticised in m5.
* *Answer to Hänni's question.* His note asks whether SFI "works well if there isn't a simple distinguishing property given such a program". The answer is yes, in the precise sense of R2: conditioning on the input set, and with a factor $2^{K_B(f)}$. Prop 2.13 shows that some dependence on $K(f)$ is unavoidable.

**Fix.**
* Add R2 and R3, or a corrected version after re-verification.
* Restrict the sentence "no bound of the form ... holds" to bounds that do not depend on $K(f)$, or to unconditional properties.
* Restate §2.5 item 1 and summary item 6 accordingly.

---

### M4. Theorem 3.1's scope: "restricting to distinct inputs loses nothing" is false for the comparison class used (§3.1 "Setting")

**Claim.** §3.1: "Under the semimeasure convention a repeated input carries no information and no loss, both for SFI and for any random function. So restricting to distinct inputs loses nothing."

**Problem.**
* Theorem 3.1 compares $S$ with *probability predictors* $A$, i.e. conditional laws. The natural data for such comparators is i.i.d. inputs with labels drawn fresh from $A(\cdot\mid x)$, and in that setting inputs repeat.
* (i) For any random-function predictor, a repeated input with a different label has probability 0, so the loss is infinite. This is foundations Prop 6.8.
* (ii) The length-activated product mixture $S$, extended to sequences by multiplying per round, has no such semantic problem. But its regret is not constant. If a short input ($|x|<N_A$) recurs, $A$ is never activated there, and the regret grows linearly.
* So distinctness is a genuine restriction of Theorem 3.1. It is not a harmless normalisation. The sentence invites readers to apply the theorem to standard noisy supervised data.

**Evidence.** `ref_time_bounded_repeats_output.txt`.
* A noisy-parity target (time $3|x|$, $N_A=13$) with the input $x_0=101$ repeated $T$ times and labels drawn from the target's law. The regret is 40.8, 521.9 and 5310.5 bits for $T=10^2,10^3,10^4$, about 0.53 bits per round.
* On distinct inputs the theorem's bound holds (698.8 ≤ 1216).

**Fix.**
* State distinctness as a hypothesis and delete "loses nothing".
* For noisy labels, either use time-stamped inputs (foundations' repair) or clock by round number. The latter gives Hänni's round-based constant, at a per-round cost growing like $\log\log k$.
* See also m1–m3 on the theorem's constant and hidden hypotheses.

---

### M5. The Vaintrob–Hänni slides are available but unused; §4.3, §4.5 and §6 are stale

**Claim.** §4.5: "⟦CITATION PENDING ... contents not available to this track. Nothing above describes or relies on their content.⟧" The literature log repeats this.

**Problem.** The brief (section "Slides with Dmitry, now available") makes `prior/vaintrob-hanni-nnbayes-generalization-slides.{pdf,txt}` the source for H10. It asks the paper to state only what the slides claim, with their caveats. The slides bear directly on this track. Slide numbers below are the footers.
* **(a) Appendix J (slides 91–100)** contains Thm 4.6:
  * the NNGP kernel on the cube is invariant under coordinatewise sign flips, hence diagonal in the parities (the same proof as Thm 4.6(a));
  * a "trace budget" form of 4.6(b): $\#\{S:\lambda_S\ge1/n\}\le n$ for any kernel;
  * citations: Kamath–Montasser–Srebro "Example 1, square loss", Yang–Salman, Donhauser–Wu–Yang (ICML 2021), Ghorbani–Mei–Misiakiewicz–Montanari.
  * The notes cite Kamath et al. as "Thm 19", which is unverified (m14).
* **(b) Appendix K (slides 104–109)** contains the ladder and the selection-rule table (M1). It also claims "random order is fine in any language, $\mathbb E[M]=O((C+d)d)$".
* **(c) §4.3 and §4.5 "open" items.**
  * The main theorem (slide 17) and "the three orderings, scrambled only polynomially" (slide 35) claim that in the strong-prior regime the NN Bayes prior ordering, the min-$\ell_2$-norm ordering $\kappa_N$ and the MLP-circuit complexity $C_L$ agree up to polynomial factors, uniformly in width.
  * "Additional results" (slide 30) claims an in-distribution online mistake bound $\mathrm{poly}(d,C_L(f))$. It also claims the converse: "the circuit complexity $C_L$ of the learned function is at most poly(d, #mistakes made while learning it)".
  * The notes call Hänni's "true for NN bayes as well" unproved (§4.3), and list "Hänni's second open problem" as open (§4.5). Both need updating to "claimed by the slides in the strong-prior regime, in distribution".
  * The slides themselves list "give a lower bound on the log prior of a function" as open (slide 36). So the explicit two-sided prior-mass bound of §4.5 remains open, but the polynomial relation between orderings is claimed.
* **(d) "The big picture" (slide 34)** attributes the infinite-width mean-field case to arXiv 2607.05735. This corroborates the notes' snippet-level description.
* **(e) The SFI warm-up (slides 10–13)** covers in-distribution learning with prior $3^{-|p|}$: $n=O(C)$, 99.9%, and a relevance-based bound $4000(\log M+4)$. This is the in-distribution, high-probability counterpart of Thm 2.7 and Prop 3.8. The paper should relate them.
* **(f) Appendix F** (slides 68–69) cites Buzaglo et al. (ICML 2024) as the closest prior work, and Mingard et al. (Nat. Commun. 2025). It argues the "only one direction can hold" point of Props 4.2–4.4.
* **Caveat to carry over.** The slides warn that "many of these appendices have largely been generated by Claude ... I haven't meticulously reviewed many appendix slides yet".

**Fix.**
* Replace the placeholder with a hedged summary of (a)–(f), attributed as "the slides claim".
* Update §4.3, §4.5, §6 and open problems 4–6 accordingly.
* Withdraw novelty for Thm 4.6 and the ladder/halving facts (M6).

---

### M6. Novelty and attribution (§6 "apparently new", and individual results)

**Claim.** §6 lists as apparently new, among others: the OOD results of §2 (including Prop 2.4 and the random-split theorem), Thm 3.5's "on every ordering", and "the zero-eigenvalue observation for two-layer ReLU kernels as a learnability statement (Rem 4.8)". §6 item 1 leaves the identity of Solomonoff's operator induction as an "unverified recollection".

**Problem and evidence.**
* **Rem 4.8.** Basri, Jacobs, Kasten & Kritchman, "The convergence rate of neural networks for learned functions of different frequencies", NeurIPS 2019, arXiv 1906.00425. A snippet of the abstract says that "a shallow neural network without bias cannot represent or learn simple, low frequency functions with odd frequencies" [known (snippet)].
  * Bietti & Mairal, "On the inductive bias of neural tangent kernels", NeurIPS 2019, arXiv 1905.12173, give the vanishing of odd eigenvalues $\ge3$ for the bias-free two-layer ReLU NTK on the sphere [known from memory; the snippet did not confirm the statement (unverified)].
  * The cube version is the same algebra.
* **Thm 4.6.** It is in the slides (M5(a)). The cube diagonalisation is in Yang & Salman (arXiv 1907.10599, ICLR 2020 [snippet]). The slides quote it as "are diagonalized by the natural Fourier basis". My snippet did not show the notes' quoted phrase "eigenvalue depends only on $|S|$", so that quotation is unverified.
* **Rem 3.10 / Thm 3.5.** The halving bound on every ordering, and the argmax-versus-majority contrast, are in the slides (Appendix K). The "few mistakes ⇒ small circuit" direction is claimed there in distribution for NN Bayes (slide 30). Thm 3.5's every-ordering form for circuit Bayes with explicit constants may still be new. It formalises Hänni's own sketch, so it should be attributed to him as a claim.
* **Prop 2.4.** A universal machine tailored to make a chosen behaviour likely is the supervised analogue of Leike & Hutter, "Bad universal priors and notions of optimality", COLT 2015, PMLR 40:1244–1259 [known (snippet)].
* **Prop 2.9.** This is the exchangeability or online-to-batch argument. The foundations track's Thm 6.7 uses it, and Lattimore–Hutter's "random selection of training data" result (which the notes mention) may be the same statement. It should be presented as a standard argument applied to SFI.
* **Prop 4.3.** This is the standard Kraft/Markov fact that $-\log P(x)\approx K(x)$ for $P$-most $x$. It should be cited as such.
* **Operator induction.** Two search snippets now support the recollection:
  * Özkural, "Ultimate Intelligence Part II", arXiv 1504.03303, and "Part III", arXiv 1709.03879, describe operator induction as weighting each conditional model $O^j$ by $2^{-|O^j|}\prod_iO^j(a_i\mid q_i)$, with a convergence theorem bounding total error by $\ln2$ times the complexity of the source [known (snippet, secondary source)].
  * So the product/private-randomness mixture (H1(c)) and its in-expectation dominance are Solomonoff's operator induction. The primary source (Solomonoff 2008) is still unverified beyond its abstract.

**Fix.** Remove Rem 4.8, Thm 4.6, the halving bound and the ladder from the "new" list, and cite the sources above. Cite Leike–Hutter at Prop 2.4. Present Prop 2.9 as standard. State the operator-induction identification with its snippet-level status.

---

## 3. Minor issues

* **m1. Thm 3.1(a), proof, short inputs.** "For $|x_j|<N_A$: $-\log_2q_i(y_j\mid x_j)=\log_2|Y|$" is false when $A$ is active and finishes within the clock on that input. Then $q_i=A$. The needed inequality $-\log_2q_i\le\log_2|Y|-\log_2A(y_j\mid x_j)$ holds in both cases. Fix the line.
* **m2. Thm 3.1: the constant and hidden hypotheses.**
  * The constant $\log_2(1/w_i)+(2^{N_A}-1)\log_2|Y|$ with $N_A\ge n_i=2^{2^i}$ is triple-exponential in the index $i$. Hänni's round-activated constant is doubly exponential. Length activation buys an $x$-only per-round cost at the price of one more exponential. Say so.
  * The clock needs $p$ (and $g\cdot p$) to be time-constructible. This is not stated.
  * (b) precision: the sketch says relative errors "perturb each predictive probability by a factor $1\pm O(\varepsilon_k)$". Stored weights accumulate the errors of all earlier rounds, so per-round perturbations are not $O(\varepsilon_k)$. The conclusion survives by telescoping: $\hat V_k=(1\pm\varepsilon_k)|Y|\hat p_k(y_k)\hat V_{k-1}$, so the cumulative loss changes by $O(\sum_k\varepsilon_k)$. My script shows $-1.26$ bits for $\sum\varepsilon_k=1.645$. Rewrite the argument.
* **m3. Prop 3.3, "the same mixture $S$".** A time-$O(p)$ sampler is not a time-$O(p)$ probability predictor: computing its law takes time $2^{gp}$. So it is not in $S$'s enumeration of predictors. $S$ must range over clocked *samplers* (the last bullet implicitly does this). Define the mixture explicitly.
* **m4. Prop 2.8 is lopsided.** Since $\sum_k2^{-\sigma_k}\le1$, the lower end $2^{-c}\sum_k2^{-\sigma_k}$ is always at most $2^{-c}$. "SFI's total OOD error lies between the input sequence's novelty and $f$'s complexity" should say that the lower end never exceeds a constant. "This formalises Hänni's fake OOD generalisation" is an interpretation; it is carried by the standard upper bound alone.
* **m5. Prop 2.12 discussion.** "Tight up to $\log^2m$ in the Cesàro sense" compares a per-step lower bound with an averaged upper bound. Use R3 (M3) for a per-step comparison.
* **m6. Remark 2.2(ii).** A semi-decidable $Q$ does not create "a log term". The bound is lost for programs that halt before $Q$ accepts. Reword the heading of the item.
* **m7. Prop 2.3 notation.** $K(Q_p,b_p\mid p)$ is defined as the shortest code of a pair of $p$-relative programs, read *before* $p$. That is not the standard conditional complexity, which may use $p$ to decode the code. The bound holds for the defined quantity. To get the standard conditional version, use the wrapper $w\,p\,z$ (read $p$ first).
* **m8. Prop 2.13, the reading of "relative to a good training program".** The proof needs the conditioning string $z$ to be determined by $f$ (independent of $A,x^*$). If "good training program" means the MAP or shortest program *for the data* $D$, it typically memorises $A$ when $|A|\ll K(f)$. Then the complement of $A$ is $O(1)$-simple relative to it, so the premise of the naive converse fails and Prop 2.13 says nothing. Say which reading is refuted. R2 covers the other reading.
* **m9. Prop 4.3.** The display holds for every semimeasure (Kraft only). The two-sided consequence needs Prop 4.2's hypotheses: lower semicomputability given $a$, and a normalised $P_A$ for "probability over $\theta$". State them, and cite the fact as standard (M6).
* **m10. Thm 4.6(b) and Cor 4.7: loss.** The kernel lower bound is for the squared error of the real-valued predictor. "Average error ≤ ε" in Cor 4.7 should say squared error. A 0–1 version needs a different argument (Kamath et al.'s approximate dimension complexity, which the slides cite for square loss). The pointwise bound "$\le4e$" can be "$\le4e^2$". This is harmless.
* **m11. Rem 4.8: confirmed, and it can be strengthened.**
  * Every function in $V=\mathrm{span}\{k(x_i,\cdot)\}$ is orthogonal to $\chi_S$ on the whole cube. So a predictor that fits the training labels is *negatively* correlated with $\chi_S$ on unseen points: $\sum_{\rm unseen}\hat g\chi_S=-\sum_{\rm train}\hat g\chi_S$.
  * My KRR runs show sign-accuracy on unseen points of 0.21–0.28 at $n=640$–$900$ for $k=3,5$, below chance.
  * For GP classification, a zero eigenvalue means prior paths satisfy $\langle z,\chi_S\rangle=0$ almost surely. Since $\mathrm{sign}(z)=\chi_S$ would force $\langle z,\chi_S\rangle=\sum|z|>0$, the prior gives probability 0 to $\chi_S$ as a whole function. Per-point posterior behaviour stays open.
* **m12. Remark 3.2, "Hänni's amortisation trick then applies verbatim [proof sketch]".** No sketch is given, and the per-round budget for history-aware function predictors is undefined ($p$ of $|x_k|$, or of the history length?). With length-based budgets the catch-up can stall while inputs stay short. Relabel as conjecture and define the class.
* **m13. Question 3.4.** "Monte Carlo ... adds an expected excess loss of order $1/t$ per round" is an unlabelled heuristic. Label it. Impagliazzo–Levin is confirmed (snippet): "universal extrapolation is possible exactly when one-way functions do not exist".
* **m14. References.**
  * Confirmed (snippet): Solomonoff 2008 (*Comput. J.* 51(5):566–570, doi 10.1093/comjnl/bxm120); Impagliazzo–Levin FOCS 1990 pp. 812–821; Goldblum et al. PMLR 235:15788–15808; Grau-Moya et al. PMLR 235:16178–16205; Mingard et al. JMLR 22(79):1–64; Lattimore–Hutter LNCS 7070 pp. 223–235; Ryabko JMLR 7:645–664; Chater–Vitányi *J. Math. Psych.* 51(3):135–163; Vaintrob–Hänni arXiv 2607.05735 (7 July 2026).
  * Kamath–Montasser–Srebro is PMLR 125:2236–2262 [snippet]. "Thm 19" is unverified; the slides say "Example 1".
  * Yang–Salman also appeared at ICLR 2020.
  * Bārzdiņš–Freivalds: Dokl. Akad. Nauk SSSR 206(3):521–524 is the Russian original. The English translation is *Soviet Math. Dokl.* 13:1224–1228 [snippet].
  * Özkural's two arXiv papers are "Ultimate Intelligence" Parts II and III. Give the titles.
* **m15. Missing related work.**
  * Buzaglo et al., "How uniform random weights induce non-uniform bias", ICML 2024, PMLR 235:5035–5081 [snippet]. This is the closest prior work per the slides.
  * Mingard, Rees, Valle-Pérez & Louis, "Deep neural networks have an inbuilt Occam's razor", *Nat. Commun.* 16:220 (2025) [snippet].
  * Leike–Hutter 2015 and Basri et al. 2019 (M6).
  * Donhauser–Wu–Yang (ICML 2021) and Ghorbani–Mei–Misiakiewicz–Montanari, via the slides [unverified].
* **m16. Hänni's second OOD example** (labels are shortest proofs) is not treated, although Thm 2.5(3) applies directly. $P=\{(x,y):y\text{ is a shortest proof of }x\}$ is decidable given $T$, and the simplest violating output has $K(z\mid x^*)=O(1)$. So the violation probability is at least $2^{-K(Q)-c}$ with the $Q$ of Example 2.15.
* **m17. Thm 2.7.** "Markov's inequality for the count" is plain counting ($\delta\cdot\#\{e_k\ge\delta\}\le\sum e_k$). Trivial.
* **m18. Example 2.15 wording.** "Both ends are independent of the number of training statements" is right. But the failure floor $2^{-K(T)-c'}/\log_2^2L$ decays (slowly) with the difficulty threshold $L$. Say so next to "easy-to-hard generalization is not a thing".

---

## 4. Cross-track notes

* **Foundations versus context Prop 5.1 and Cor 5.2.** They contradict each other (M2). Foundations is right.
* **Foundations Prop 6.8** (noise and repeats) is the reason M4's sentence is false. Context should cite it.
* **The definition of $W$ agrees across tracks.** Context's programs are self-delimiting independently of the input, and foundations' $W$ uses $\sum_em(e)[\varphi_e\supseteq D]$. Context Prop 5.4(2) (an unbounded $M_F/W$ gap on *one* query) strengthens foundations Prop 4.3 (two inputs). Foundations should cite it.
* **Context Prop 5.4(1)** agrees with foundations Thm 6.3(c).
* **Prop 2.9 and foundations Thm 6.7** rest on the same exchangeability argument. Use one formulation and one set of citations.
* **R3 (M3)** gives the per-step in-distribution rate $O(2^{K}/m)$ for normalised error. Foundations' H7 results are averaged ($K/n$). The paper should state both and say which is per step.

---

## 5. Claims I confirmed

Each was checked line by line. Scripts are named where I also computed.

* **§1.**
  * $K(z\mid x)-c\le K^{\mathcal P}(z\mid x)\le K(z\mid x)+K(K(z\mid x))+c$.
  * (F1) telescoping, and the bound $\le-\log\nu(D_n)$.
  * (F2) as stated, including uniformity in the program.
  * $M_F\ge2^{-c}W$ (a machine reading a program from the shared tape).
* **§2.**
  * **Prop 2.1**, all three parts. The wrapper code is prefix-free and injective. $D$-consistency uses $\mathrm{dom}\,D\cap Q=\emptyset$. $T_{Q,b}$ gives $\mu_{T_{Q,b}}(D\cup E)\ge M_F(D)$. There is indeed no log term.
  * **Rem 2.2** (i) and (iii); for (ii) see m6.
  * **Prop 2.3** for the defined quantity (m7).
  * **Prop 2.4**: $W'(D)=W(D)$; conditional $\ge\frac12$; mutual simulation within $2^{K(Q,b)+c}$.
  * **Thm 2.5** parts 1–3, including the even/odd tape split for $M_F$. Part 2's consequence holds because labellings of $S$ are disjoint events.
  * **Prop 2.6**(a) and (b). (b) correctly uses disjointness and (F2) uniformly in $n$.
  * **Thm 2.7**, with $c=0$ for $W$.
  * **Prop 2.8.** Distinct minimising properties have distinct shortest codes, so Kraft applies (see m4).
  * **Prop 2.9**: the identity is exact.
  * **Prop 2.10**: the disjointness of the "fail exactly at $x$" sets.
  * **Rem 2.11** numbers: LOO step 1 bit against 0.2555 random-split average at $N=16$; the Kraft limit $N\le2^K-1$.
  * **Prop 2.12**: parts 1–3. Constants checked (`ref_constants_and_occam_iid`); c4 matches the exact probabilities.
  * **Prop 2.13**: both parts (see m8 for scope).
  * **Prop 2.14**: the conditional coding theorem applied to labellings of $B$ given $B$.
  * **Example 2.15**: $L'=2^{\lceil\log_2L\rceil}$ and $K(Q)\le K(T)+2\log_2\log_2L+c$; the proof-search lower bound.
* **§3.**
  * **Thm 3.1(a)** (with m1's wording fix). Independently implemented in `ref_time_bounded_repeats`.
  * **Thm 3.1(b)**: the incremental formula is right; see m2 for the precision argument.
  * **Prop 3.3** (with m3).
  * **Circuit counting.** $N_s=\prod_j16(d+1+j)^2$; the gadget's $g\le d+1$ gates; injectivity; $B(s)$ (0 violations in my grid).
  * **Thm 3.5**(a),(b) in full:
    * the strict inequality via constant circuits at every size;
    * the split at $S=\lceil L_B\rceil$, with $w(\mathcal W_{>S})\le2^{-S}\le W(f|_B)\le w(\mathcal R)$;
    * the chord bound $-\log_2(1-p)\le2p$ on $[0,\frac12]$;
    * $\#\{P_i>\frac12\}\le2m$.
  * **Rem 3.6.** The formula surgery $B=d(1+\log_2(12(2d+2)))=22.755$ at $d=3$. The gap in Hänni's sketch is real: with a polynomial size tail one gets only $c\le2^{O(L)}$.
  * **Rem 3.7**: c1 reproduces exactly.
  * **Prop 3.8**: $70\ell+531$ suffices.
  * **Prop 3.9**: the constant 5.7 (true maximum 4.01 on my grid). The post-$N$ injection argument. Simulated means are far below the bound.
  * **Rem 3.10**: the halving bound (but see M1 on the "open" claim and the name "MAP").
* **§4.**
  * **Prop 4.1.**
  * **Prop 4.2**: the coding theorem; Hänni's $\log\log$ term is indeed unnecessary.
  * **Props 4.3 and 4.4** (m9).
  * **Prop 4.5**: brute force over up to 59M circuits (`ref_uniform_circuit_prior`).
  * **Thm 4.6**(a),(b) and **Cor 4.7** (m10).
  * **Rem 4.8.** Exact zeros by Krawtchouk sums. A cleaner proof: $\kappa(\rho)-a\rho$ is even, with $a=\frac12$ for the NNGP and $a=1$ for the NTK. So $z\mapsto\kappa(\sum z/d)-a\sum z/d$ is invariant under $z\mapsto-z$, and has no odd Walsh coefficients. This avoids the power-series convergence at $\rho=\pm1$.
  * The c2 numbers in §4.4.
* **§5.**
  * **Prop 5.1** as a statement about weak semimeasures (see M2).
  * **Prop 5.3**: the point-function identification lower bound $(2^n-1)/2$.
  * **Prop 5.4**, all four parts. The failure of $W\ge2^{-K(y\mid x)-c}$ is a correct and neat counting argument.
* **Scripts.** c1–c5 reproduce exactly, and their docstrings match what they do. c2 asserts Thm 4.6(b) per cell on 20 sampled targets with a tolerance. This is weaker than the theorem, and the notes say so accurately.

---

## 6. Important questions from the brief that the track missed or left incomplete

1. **H10 bridge.** The slides were not used (M5). The brief makes them the source for "NN Bayes ≈ circuit SFI" and asks for their claims with caveats.
2. **H8 converse.** The track has no positive converse and no per-step in-distribution rate (M3). Hänni's own formulation ("relative to a good training program") was answered only negatively, and only under one reading (m8).
3. **Hänni's circuit OOD question** (`hanni-circuit-circuit-occam-learning.md`, `hanni-circuit-ood-min-circuit-induction.md`). It has a natural-language answer (M1), but the track lists it as open.
4. **H8 examples.** The shortest-proof labelling example is not treated (m16).
5. **Polytime note, Remark 4.** A learner running in time $n^{\omega(1)}$ against *all* polynomial-time predictors is not addressed. It follows from Theorem 3.1's construction with clock $n^{g(n)}$, under the same distinct-inputs restriction (M4). It should at least be stated.
6. **History-aware time-bounded SFI.** It is asserted ("verbatim") without a definition of the budget (m12).
7. **The "converse" direction for NN Bayes in distribution** is claimed by the slides (slide 30) and should be reported, not called unproved (M5).
