# Referee report on track "model"

*Adversarial referee for `notes.md` of track "model". I read the brief, Hänni's three notes, the whole of `notes.md`, every script in `checks/` with its output, and the cited parts of `axiom-schemas` (AS), `inferential-learning` (IL) and `axiom-schemas/research/conversation.md` (conv). My own code is in `referee_code/`. Every script there is seeded and writes `<name>.out` next to itself. I did not edit `notes.md`.*

**Tags used for my own claims.** **[proved]**: argument given here in full. **[computed]**: script and output named. **[known]**: published, with source. **[checked]**: I re-did the track's argument line by line and found no error.

**Severity scale.**
* **Fatal**: a headline conclusion is wrong.
* **Major**: a claim marked proved, or a headline statement, is false or unsupported as stated. A fix exists, but it changes a statement or needs a new argument.
* **Minor**: imprecision, a small gap, a misreported number, or a wrong citation scope. The conclusions are unaffected.

---

## Verdict in brief

No fatal issue. Five major issues:
* **M1.** The headline soundness guarantee is proved only for fixed mixture weights. Under the default Dirichlet weights it is vacuous, and its natural analogue fails: probability 0.98 to 1.00 against a claimed bound of 0.02.
* **M2.** Prop 6.9 (L1 charges derivation size) is false. One L1 tree with O(k) random choices derives a sentence of size 2^{k+3} − 1. This breaks the L1 half of §6.4's conclusion.
* **M3.** "A derivation-based likelihood does not change the MDL finding [proved]" is proved only for the exact tie at fixed, matched weights, not for the Occam rates.
* **M4.** Theorem 5.1(b) claims that the posterior mass of the exact generator class tends to 1. That mass is 0 at every n. The T-level conclusion is true, but it needs a different argument.
* **M5.** The subcriticality hypothesis of Def 1.5 and Lemma 1.6 cannot hold for formula sorts in L_A or L_∈. Where it can hold, it does not imply finiteness.

There are 16 minor issues. Most results survive scrutiny (list at the end).

The track's main gap relative to the brief: every quantitative failure result is for L0 (axiom citation). The user's proposal, a derivation-length likelihood (L1), gets no misspecification or robustness analysis.

---

## Major issues

### M1. Theorem 4.1 is proved for fixed weights, but the headline applies it to the default Dirichlet-weight model, where it is vacuous and its natural analogue is false

**Claims.**
* §0, "What can be promised": "Its thresholded verifier is time-uniformly sound against any prover with probability 1 − δ/π(C*). It needs no bound on the number of axioms."
* §5.4: "*Spares do not threaten soundness.* … Theorem 4.1 excludes that with probability ≥ 1 − δ' under well-specification." This sits in the Dirichlet-weight section.
* §5.5 table, row "soundness": probability ≥ 1 − δ' (Thm 4.1), set against the cautious verifier.

**Problem.**
* Theorem 4.1 assumes setting W, where every theory carries *fixed* weights. That theorem is correct; I checked it (see "Confirmed").
* Def 1.3 makes Dirichlet weights the default. §5 (spares, no bound on the number of templates) works with them.
* Under Dirichlet weights, C* = {(T, w) : P_{T,w} = P*} has prior mass 0 whenever |T*| ≥ 2, the components are linearly independent, and w* lies outside a Lebesgue-null set. The null set is where some single-template theory has law P*. Otherwise C* is a point, or a lower-dimensional set, in a continuous simplex. Then W* = 0, and the hypothesis δ ≤ W*δ' forces δ = 0 **[proved]**.
* The natural T-level analogue replaces L_t(T*) by the Dirichlet marginal P^Dir_{T*}. Ville's argument then fails at a fixed w*, because M/P^Dir_{T*} is not a supermartingale under P_{T*,w*}.

**Evidence: counterexample [computed: `referee_code/r3_ville_dirichlet.py`, `.out`, Part 1].**
* *Setting.* L0. The PCFG root law is p = (p_0, p_S, p_+, p_·) = (0.5, 0.5 − ε, ε/2, ε/2).
* *Truth.* T* = {0+0=0, (Sz)+0=Sz} with Dir(½, ½) weights. Data are i.i.d. from P_{T*,w*}, with w* = (p_0, p_S)/(1 − ε), an interior point.
* *Competitor.* T' = {z+0=z}, a single template with no weights.
  * T' proves q := (0·0)+0 = 0·0.
  * T* does not. Countermodel: the term model with + returning its first argument on (a, 0) exactly when a has root 0 or S.
* *Prior and verifier.* π(T*) = π(T') = ½. The verifier accepts q iff π_n(T*) ≤ δ = 0.01. The analogue of Thm 4.1 would bound the acceptance probability by δ/π(T*) = 0.02.
* *Mechanism.* ln[P_{T'}(D)/P^Dir_{T*}(D)] = n ln(1−ε) + ½ ln n + ½ ln(π/2) − n·KL(ŵ‖w*) + o(1). The middle terms are the KT regret, which also follows from the track's own Prop 5.4(b) with K = 2, α = ½. For small ε this exceeds ln 99 on a long window of n.
* *Results.* Acceptance was checked on a geometric grid only, so these are lower bounds.

| ε | fixed w* | w* drawn from the Dirichlet prior |
|---|---|---|
| 10⁻⁵ | ≥ 0.980 | ≥ 0.008 |
| 10⁻⁶ | ≥ 1.000 | ≥ 0.010 |

* *Reading.* The Bayes-averaged version respects the bound (0.008 and 0.010 ≤ 0.02). The fixed-w* version violates it by a factor of 50.
* *Contrast.* With fixed weights (Thm 4.1's setting), P_{T'}/P_{T*,w*} = (1−ε)^n ≤ 1, so q is never accepted.

**Suggested fix.**
1. State in §0, §5.4 and §5.5 that the soundness guarantee is for fixed-weight classes. One option is a countable grid of weight vectors with positive prior mass at w*.
2. Or state the Dirichlet version as a Bayes-averaged guarantee: P under ∫ P_{T*,w} dDir(w) is at most δ/π(T*). It follows from Ville applied to M/P^Dir_{T*}, which is a martingale under its own marginal.
3. Or prove a fixed-w* version that carries the (|T*|−1)/2·ln n regret. That version is not time-uniform.
4. Either way, the "no bound on the number of axioms, sound w.p. 1 − δ'" contrast with the cautious verifier needs this qualification.

### M2. Prop 6.9 is false: under L1, the code length of a derivation can be logarithmic in its symbol size

**Claim (Prop 6.9, proof sketch).** "Under L1 with subcritical parameters, −ln P_T(φ) ≥ κ·ℓ_min(φ) − ln(C/Z_T)." Here ℓ_min(φ) is the least symbol size of a derivation of φ.

It is used in four places:
* §6.4, item 3: "under L1 at least κ·s(m) nats on those data (Prop 6.9)";
* §9.2: the derivation-length prior is "the only one of the proposed penalties that prices computation (Theorem 6.7, Prop 6.9)";
* summary item 7;
* implicitly, Remark 1.10's identification of the graded score (symbol size) with L1.

**Problem.** The sketch bounds P_T(φ) by the tail of the tree's "total size", but L1's probability counts random choices, not symbols. ∀E and Gen substitute a term into every occurrence of a variable, so the symbol size can grow exponentially in the number of random choices.

**Counterexample [proved; computed: `referee_code/r2_l1_size.py`, `.out`].**
* *The tree.* Start from the logical axiom ∀x(x = x). Repeat k times: ∀E with t = p+p, then Gen on p. Close with one ∀E.
* *Its cost.* Each round is O(1) random choices: about 12.2 nats with the grammar used.
* *Its conclusion.* The conclusion φ_k has size exactly 2^{k+3} − 1. Every step is checked by the code up to k = 14.
* *The bound fails.* Any derivation of φ_k contains φ_k, so ℓ_min(φ_k) ≥ 2^{k+3} − 1. But −ln P_T(φ_k) ≤ −ln Pr(tree) ≤ 12.8 + 12.2k, since Z_T ≤ 1. For every κ > 0 and every C, Prop 6.9's inequality fails for large k. At k = 30: 379 nats against a size of 8.6·10⁹.
* *A one-node example.* An A4 instance ∀x B(x) → B(t), with m occurrences of x and |t| ≈ m, has size ≈ m² but costs O(m) nats (same output).

**Consequence.** Theorem 6.7 and Cor 6.8 bound derivation *symbol size*. That is correct for Hänni's graded score with symbol size. It does not transfer to L1. So the claim that L1 prices the assigner per datum at κ·s(m) is unsupported.

**Suggested fix.**
* Restate Prop 6.9 with the L1 code length (number of nodes plus instantiation symbols) as the size measure. Then it follows from the tail of the total progeny.
* Redo Theorem 6.7 for that measure. This needs a proof checker that runs in time polynomial in the code length, e.g. formulas as DAGs, equality of DAG-represented trees, and Gen on DAGs. It is plausible but must be written out, and de Bruijn indices under sharing need care.
* Or add an explicit symbol-size penalty to the grammar.
* Weaken §6.4 item 3, §9.2 and Remark 1.10 until then.

### M3. "A derivation-based likelihood does not change the MDL finding [proved]" claims more than is proved

**Claim.** §5.3 says "By the remark after Prop 2.6, all of this holds unchanged under the derivation likelihood L1, because splits are exact ties at the citation leaves. A derivation-based likelihood does not change the MDL finding [proved]." Summary item 3 repeats it.

**What is proved.** The remark after Prop 2.6 is correct (I checked it). With *fixed* weights matched to the split (w'_{τ_r} = w_τ p_r), the citation-leaf law is identical, so μ_T = μ_{T'} and Z_T = Z_{T'}.

**What is not proved.** "All of this" refers to Prop 5.4: the Dirichlet comparison, with an Occam penalty −(K−1)/2·ln n under a well-specified Q and a linear gain otherwise. That proof uses L0's single labelling: the root counts n_f are observed (Prop 5.4(a)).
* Under L1 the citations are latent. A cited instance can be the minor premise of MP and vanish from the conclusion. The marginal likelihood is an integral of a sum over derivations.
* The rates then need a BIC- or Laplace-type theorem for a latent-variable model, including identifiability of the root weights from theorem data (a nonsingular Fisher information). Neither is given.
* Under L1 the competitor set also changes. Deductively equivalent "partial" schemas become live: conv §7 notes that induction for one connective class (e.g. ¬-motives) already yields all of PA. Under L0 these die at the first datum with another root. Under L1 they only pay extra derivation steps.
* The brief asked whether a derivation likelihood changes the MDL finding. These competitors are exactly what such a likelihood adds, and they are not compared.

**Evidence.** The argument above. No counterexample: I expect the Occam rate to survive under regularity, because one-node citation trees occur with probability ≥ α_ax and make the citation law identifiable.

**Suggested fix.** Mark the L1 part of §5.3 and of summary item 3 as conjecture or proof sketch. State the needed regularity. Add the L1-specific competitors (deductively equivalent partial schemas) to the comparison, or list them as open.

### M4. Theorem 5.1(b) claims posterior mass → 1 on a set whose posterior mass is 0 at every n

**Claim.** "Then for every T* with π(T*) > 0 and Lebesgue-almost every w*, π_n({(T, w) : P_{T,w} = P_{T*,w*}}) → 1 a.s." It is attributed to Doob's theorem (GvdV Thm 6.9). The proof adds: "The steps of the proof of Theorem 2.1 go through with the countable sum over H replaced by an integral."

**Problem [proved].**
* Fix T* with |T*| ≥ 2 and linearly independent components, e.g. disjoint instance sets.
* Then {w : P_{T*,w} = P*} is a single point of the open simplex. For other T, the corresponding set is a point or lower-dimensional. The exception is a single-template theory whose law equals P*, which happens only for a null set of w*.
* The posterior given T is absolutely continuous with respect to Dir_T. So the posterior mass of the set is 0 for every n.
* Doob's theorem gives something weaker: the posterior converges weakly to δ_{P*}, i.e. every neighbourhood of P* gets mass → 1 [known; GvdV 2017 Thm 6.9, as described by citing papers; I did not see the book].
* Step 3 of Theorem 2.1 uses countability ("apply step 1 to the countably many sets A_ν"). It does not go through with an integral.

**The consequence the track draws is still true [proof sketch].** "Hence the posterior mass of {T : ∪inst(T) = ∪inst(T*)} tends to 1" can be proved another way.
* The parameter φ(T, w) := ∪inst(T) takes countably many values.
* It equals the set of values that appear in X_∞, P_{T,w}-a.s. (w in the open simplex, full-support Q). So it is a.s. a function of the data.
* Theorem 2.1's argument, with F replaced by this support function, gives posterior mass of {∪inst(T) = ∪inst(T*)} → 1 for Π-a.e. (T*, w*). That is, for each T* with π(T*) > 0 and Dir-a.e. w*.

**Suggested fix.** Replace the first bullet of (b) by weak consistency at a.e. w*, plus the T-level statement with the argument above. Drop "the steps … go through with an integral". Thm 5.1(c) should then be read as a claim about the T-level set.

### M5. Def 1.5 and Lemma 1.6: the subcriticality condition is unsatisfiable for formula sorts, and insufficient where it can hold

**Claim.**
* Def 1.5: "Q is subcritical if every type's expected number of children per node is < 1." Types are indexed by the sort and the number of variables in scope, which grows under binders.
* Lemma 1.6 [proved]: then bodies are finite a.s. and Q_τ is a probability.
* The proof: "dominated by a single-type Galton–Watson process whose mean offspring is the maximum over types, which is < 1."

**Problems.**
1. **Unsatisfiable for formula sorts [proved; computed: `referee_code/r1_subcritical.out`, Check A].** In L_A and L_∈, every formula production has at least one child: atomic formulas have two term children, connectives and quantifiers have formula children. So no PCFG gives a formula type a mean below 1. Lemma 1.6 therefore says nothing about formula metavariables, such as the P of T_Ind or of Separation. Every later use of "subcritical Q" for formula templates rests on an unsatisfiable hypothesis. This includes Prop 2.6(b) applied to T_Ind and the L0 normalisation for PA and ZF schemas.
2. **Insufficient with infinitely many types [proved; computed: Check B].**
   * Take a signature with a nullary predicate ⊤. Choose ∀ (one child, k+1 variables) with probability 1 − 1/(k+2)² and ⊤ otherwise.
   * Every type then has mean 1 − 1/(k+2)² < 1.
   * But the ∀-chain never stops with probability Π_{k≥0}(1 − 1/(k+2)²) = ½. Simulated: 0.4989 for chains longer than 2000, against a prediction of 0.5002.
   * Q_τ then has total mass ½. A maximum over types need not exist.
3. **The proof step is invalid even with finitely many types.** Comparing means does not give stochastic domination. A type with offspring law {0: 0.55, 2: 0.45} and a type with {0: 0.1, 1: 0.9} both have mean 0.9. Any single law that stochastically dominates both has mean ≥ 1.35.

**Suggested fix.** Use a multi-type criterion with a uniform bound. For example, require weights h(type) ∈ [h_min, h_max] with 0 < h_min and E[Σ_children h(child)] ≤ ρ·h(parent) for all types, with ρ < 1. Formula nodes whose term children are mostly leaves then qualify. The proof becomes "the expected h-weighted generation size decays like ρ^k". The conclusion of Lemma 1.6 then holds as stated.

---

## Minor issues

**m1. Cor 6.8: quantifier order.**
* *Claim.* "Let s(m) ≥ m be time-constructible, and c as in Theorem 6.7. There is a decidable X such that every T as in Theorem 6.7 needs …"
* *Problem.* In Theorem 6.7, c depends on T, through the polynomial degree of T's membership test. The proof fixes c, takes X ∈ NTIME(s') ∖ NTIME(s^c), and so covers only theories whose checking exponent is ≤ c. The statement quantifies over all T.
* *Fix.* Choose X ∉ ⋃_c NTIME(s^c). Such an X exists in NTIME(s^{log s}) by the same hierarchy theorem. Or fix the membership degree in the statement.

**m2. Prop 4.2's prover.**
* *Claim.* "It submits S0 = 0 in every round (it does not even need to adapt)," and it succeeds with probability 1.
* *Problem.* Under the §4 protocol the verifier may ESCALATE a query it does not accept. The oracle's answer ("not a Q-theorem") kills T_esc.
* *Evidence [computed: `r3_ville_dirichlet.out`, Part 2].* With a verifier that escalates every non-accepted query:
  * the non-adaptive prover succeeded in 11/400 runs, only when the very first datum was uncovered;
  * a prover that waits until π(T_esc) ≥ 1 − δ succeeded in 400/400.
* *Fix.* Use the waiting prover, as §0 does ("a prover that just waits"), or assume a verifier that never escalates.

**m3. Remark 1.10.**
* *Claim.* "A stronger theory has more short theorems, hence a larger Z_T, hence a smaller P_T(s) on each datum."
* *Problem.* False on data whose shortest derivation gets shorter.
* *Evidence [computed: `r6_stronger_theory.out`].* T = {a, a→b}, T' = T ∪ {b} (instances nested, same theorems).
  * Normalised graded score (κ = 1): P_T(b) = 0.032 and P_{T'}(b) = 0.346. Ten sentences gain, 36 lose.
  * L2: P_T(b) = 0.016 and P_{T'}(b) = 0.24.
* *Further problems.* Normalising S_g requires g(∞) = β = 0, since with β > 0 the sum over sentences diverges. "The MDL version of L1" conflates symbol size with L1 code length (see M2).
* *Fix.* Say "smaller P_T(s) on data whose shortest derivation is unchanged". Add β = 0.

**m4. c5 remark.**
* *Claim.* "The coherent cases are essentially those where every theory is complete."
* *Evidence [computed: `r5_trichotomy.out`, independent generator and seed].*
  * The 50/50 rule was coherent in 12/300 trials. In all 12 every theory had ≤ 2 models. Only 2 had all theories complete.
  * Every trial with all theories having ≤ 2 models was coherent (12/12).
  * Renormalisation was coherent in 199/300 trials. Only 2 of those had all theories complete.
* *Reason [proved].* For |Mod(T)| ≤ 2, the 50/50 value of T is the uniform law on Mod(T). Mixtures of coherent assignments are coherent.
* *Fix.* Replace the remark by "the 50/50 rule was coherent exactly when every theory had at most two models (in these trials)".

**m5. c9 is tautological for the split.** `c9_consistency.py` codes T_split's log-likelihood as `log(P[t[0]] * q / P[t[0]])`, identical to T*'s by construction. So "π_n(T*) = π_n(T_split) at every n, as Corollary 2.2 says" checks nothing. The genuine check is c2 Part A. Say so in §2.1 and in the verification log.

**m6. c6 misreported.** §2.3 says "P_{T1}(b) ≈ 0.31–0.35". `c6_L1_ident.out` gives 0.16–0.35 (0.24–0.25 and 0.16–0.17 at the last two settings). The TV range 0.16–0.35 is correct.

**m7. Spares in the span are omitted.**
* *Problem.* Prop 5.5 treats spares outside the support (a), reaching outside (b), and inside but not in the span (c). If Q_σ lies in the span of T*'s components, e.g. σ is a renamed or argument-permuted copy of a template of T* (a different code, the same law), then R_n tends to a constant. The spare never vanishes; only the prior penalises it.
* *Evidence [computed: `r4_dirichlet_rates.out`, case (d)].* Slope ≈ 0.000. The limit matches the closed form from Dirichlet aggregation (e.g. −0.288 at α_σ = 2).
* *Fix.* Add the case to Prop 5.5 and to the "Reading" and summary item 6. It does not threaten instance-set identification, since inst(σ) = inst(τ).

**m8. §4 "Computability".**
* "W* only grows" under truncation to **H**_N is false in general. π(C*_d ∩ **H**_N)/π(**H**_N) can be below π(C*_d) when most of C*_d lies outside **H**_N. It is true for π(T*).
* "L2 likelihoods (finite sums)" is false with full-support Q:
  * metavariable bodies range over infinitely many formulas;
  * the cut formula A of an MP node ranges over infinitely many formulas, e.g. for templates with a 0-ary formula metavariable in an antecedent.
* So the claimed computable verifier needs a truncated Q or an approximation scheme with one-sided error. Neither is given.

**m9. Prop 1.9(b), "never mentioned in the data".** This does not ensure that T* ∪ {ψ} ∪ D is consistent, which S_nc and S_g need. Example: ψ = ∀x R(x), T* = ∅, D₊ = {¬R(0)}. Require T* ∪ D ⊬ ¬ψ instead. This is automatic under S_prove when T* proves the data.

**m10. Prop 2.6(c): citation scope.** `AS:prop:univ:determine` assumes one side has only 0-ary *term* metavariables, and it is stated for first-order schemas in the AS appendix's sense. It does not give τ ≡ τ' for all of FO (e.g. A1 = B → (C → B), with 0-ary formula metavariables). Restrict the claim.

**m11. Lemma 1.7(a).** "Finite a.s. iff m ≤ 1" needs α_ax + α_lg > 0. If every node is unary, the tree is an infinite chain at m = 1. Trivial, but the hypothesis is only implicit, in (b).

**m12. Lemma 1.7(c) and Cor 2.3 (L1 support = Th(T)) need parameters to be admissible.** Without parameters, Gen is vacuous, and some closed theorems, such as ∀x(R(x) → R(x)), have no derivation tree. Example 3.2 uses the parameter-free convention. This matters for track "universal" if it moves Example 3.2 to L1.

**m13. "IL:prop:caution:tight transfers."**
* *Problem.* The IL extremal pair has p_{R'} supported inside R* while R' contains the invalid c. In the template models, supp P_{T'} ⊆ supp P_{T*} implies Th_d(T') ⊆ Th_d(T*), under L0 (theorems depend only on instances) and under L1 (supp = Th). So the exact pair is not in the model.
* *Status.* Tightness holds only as a supremum. Take T' = {a, c} with weight ε on c, and let ε → 0.
* *Fix.* Say so.

**m14. Summary item 3: "the likelihood never tells a schema from its split".** This holds only with matched fixed weights. With Dirichlet weights the marginal likelihood does tell them apart; that is Prop 5.4.

**m15. Prop 2.5: "goes to 0 or ∞".** This holds only when T* ∈ {T1, T2}. Otherwise the drift is the difference of two KLs, which can be zero.

**m16. Example 3.4 and Remark 3.5 under L0 only.** The headline "Robustly: no" (§9.2) is supported by L0 examples, in which the human's own axioms (Q, or ∀x(0+x=x)) have likelihood 0 because the data are not axiom instances. The text does say "that the model does not generate". It should also say plainly that the robustness question for L1 is untested. See missed question Q1.

---

## Important questions from the brief that the track missed or left thin

* **Q1. Robustness under L1, the user's own proposal.**
  * All failure results are for L0: Examples 3.2 and 3.4, Prop 4.2, Remark 3.5, and the checks c4, c7, c9.
  * Under L1, Q generates every true closed equation, so it is not killed. The question becomes whether Q, T_esc = {z = 0} or a hybrid wins on human-like data. That depends on how derivation cost grows with |t|.
  * This is the core of "robustly picks up the axioms we actually have". It is not computed.
  * A small L2 computation of Q against T_esc on data t = 0, for t of growing size, would settle the direction.
* **Q2. Cost of computing the L1 likelihood.**
  * The brief's H6 lists "derivation search, i.e. computing the likelihood" as where a time penalty matters.
  * The track does not discuss:
    * the cost or approximability of P_T = μ_T/Z_T (sums over all derivations; Z_T is a sum over all valid trees);
    * the MDL (max) approximation the brief mentions;
    * whether the max and the sum give the same posterior limits.
* **Q3. L1-specific competitors.** Deductively equivalent schemas that L0 kills but L1 keeps (conv §7: ¬-motive induction proves all of PA). These bear directly on "does a derivation likelihood change the MDL finding" (M3) and on H7.
* **Q4. Soundness of the default model.** See M1. The Bayesian-versus-cautious comparison (§5.5) should compare models with the same weight convention.
* **Q5. Data that come with proofs.** The user speaks of "statements given without proof in our data set", which implies that some statements come with proofs. With observed derivations, the citations are visible, and identification moves to the axiom level (splits still tie). This is not discussed.
* **Q6. Hänni's "grade near misses".** Acknowledged as not treated (§9.3). Still open.

---

## Claims I checked and confirmed

**Proofs re-done line by line [checked].**
* *§1.*
  * Lemma 1.2(a). The sketch of (b) is plausible: the per-template dichotomy "one m or one t" implies the finite-union claim.
  * Lemma 1.4.
  * Lemma 1.7(a)–(c), subject to m11 and m12.
  * Lemma 1.8.
  * Prop 1.9(a) and (c), and (b) subject to m9.
* *§2.*
  * Theorem 2.1, all four steps (Lévy, SLLN on countably many s, the countable decomposition, the transfer via M ≥ π(T*)P_{T*}^∞).
  * Corollaries 2.2 and 2.3.
  * Prop 2.4(a), including the integrable negative part; (b); (c), the Bhattacharyya/Markov bound.
  * Prop 2.5. No logical axiom has root ¬. Z_{T2} ≥ 1 − α_r.
  * Prop 2.6(a) and (b): DT° membership of τ_r at pattern and non-pattern occurrences, disjointness at the pattern occurrence, and the factorisation Q(θ) = p_r·Q_{τ_r}(s).
  * The remark that splits are exact ties under L1 *at matched fixed weights*.
* *§3.*
  * Theorem 3.1.
  * Example 3.2. The countermodel ℕ ∪ {a} with 0 + a = 0 satisfies every closed instance.
  * Lemma 3.3, all five cases.
  * Example 3.4.
* *§4.*
  * Theorem 4.1 in setting W: steps 1–4, the data-only event G, and the role of truthful constraints.
  * Prop 4.3(a)–(d), including the strictness example {c, a∧b} against {c, b∧a}.
  * Prop 4.4.
* *§5.*
  * Theorem 5.1(a).
  * Prop 5.2(a)–(c). The adversarial text construction is correct; conditioning on a positive-probability prefix is legitimate.
  * Prop 5.4(a)–(e). I re-derived the Stirling expansion.
  * Prop 5.5(a): exact Gamma formula.
* *§6.*
  * Prop 6.0, via Jensen with a + a' ≤ 1.
  * Theorem 6.1, both directions. Proof-search wrapper: injective, compatible, consistent. Craig wrapper: a total decider even for partial f, Cn(B ∪ A^C_f) = Cn(B ∪ Γ_f), the semimeasure telescoping.
  * Prop 6.2.
  * Prop 6.3. Hänni's single-sorted schema is inconsistent over PA for the assigner that accepts ¬Con(PA) and searches for a proof of ⊥ on Con(PA). This is a correct refutation of his consistency argument.
  * Prop 6.4, all cases, under unary numerals.
  * Prop 6.5, including the linear (not additive) overhead the track states.
  * Prop 6.6.
  * Theorem 6.7.
  * The refutation of the brief's H6 sentence (membership in Hänni's schema is syntactic).
* *§7.* Props 7.1–7.3; Examples 7.4 and 7.5.
* *§8.* Theorem 8.1(a)–(c).

**Independent computations [computed].**

| claim | my script | result |
|---|---|---|
| Prop 5.4(b) with α ≠ ½ (track tested only α = ½) | `r4_dirichlet_rates.py` A | residual exact − expansion → 0 like 1/n for α = 0.3, 1, 2 (−2.6·10⁻⁴ … −4.8·10⁻⁸) |
| Prop 5.5(a)–(c) exponents with α_σ ∈ {0.5, 1, 2}, α_τ = 1, a different T* | `r4_dirichlet_rates.py` B | slopes (a) −0.500/−1.000/−1.999; (b) −0.500/−0.999/−1.991; (c) −0.230/−0.523/−0.961, against claims −α_σ and −α_σ/2. Grid converged to 5 decimals |
| Thm 4.1 in setting W, 9 fixed-weight hypotheses, all competitors proving the same invalid q | `r7_ville_fixed.py` | frequencies 0.0365, 0.0125, 0.0027 ≤ bounds δ/π(C*) = 0.130, 0.052, 0.013 |
| Prop 2.5 bounds, own L2 implementation, 3 settings | `r6_stronger_theory.py` (ii) | P_{T1}(b) ≥ α_ax/2 and P_{T2}(b) ≤ α_r/(1−α_r) in every case |
| Props 7.2, 7.3 | `r5_trichotomy.py` | 0 violations of 2-, 3- and 4-monotonicity (exhaustive on 2 atoms); 0 bracketing failures with a different completion choice |

**Track scripts re-read and outputs compared with the notes.**
* c1, c2, c3, c3b, c4, c7 and c8 match the numbers quoted.
* The exceptions are c6 (m6) and c9 (m5).
* c2 Part A is a genuine matching check.

**Internal references.**
* All 29 cited LaTeX labels exist.
* Content checked:
  * `AS:prop:many:mdlnaive`. The track's reading as Prop 5.4(d) is right: the naive code is a uniform root law over A symbols, so n·KL = n(λ − Ĥ).
  * `AS:prop:many:mdlwell`, `AS:prop:many:bound`, `AS:thm:many:splits`, `AS:ex:univ:q`, `AS:prop:univ:gen`, `AS:rem:setting:nested`, `AS:lem:setting:closed`, `AS:thm:setting:matching`, `AS:lem:setting:preservation`.
  * `IL:thm:caution:ville`(b), `IL:thm:caution:bayesdet`, `IL:prop:caution:tight` (see m13), `IL:thm:informal:ville`.
  * conv §§4, 7, 8, 9.
* Exception: `AS:prop:univ:determine` (m10).

**External references, checked by web search (bibliographic data and abstracts or secondary descriptions; no full texts read).**
* *Confirmed.*
  * Hutter 2007, *TCS* 384(1):33–48. The abstract confirms that universal hypotheses can be confirmed under the universal prior.
  * Rousseau & Mengersen 2011, *JRSS B* 73:689–710. Their setting has continuous component parameters, as the track says.
  * Schwartz 1965, *Z. Wahrsch.* 4:10–26.
  * Seiferas, Fischer & Meyer 1978, *JACM* 25(1):146–167.
  * Žák 1983, *TCS* 26(3):327–333.
  * Craig 1953, *JSL* 18(1):30–32.
  * Krichevsky & Trofimov 1981, *IEEE Trans. IT* 27(2):199–207.
  * Tenenbaum & Griffiths 2001, *BBS* 24(4):629–640.
  * Waudby-Smith & Ramdas 2020, NeurIPS.
  * Ghosal & van der Vaart 2017, Thm 6.9 = Doob, per two citing papers. They describe it as weak convergence of the posterior to a point mass, which supports M4.
* *Existence only.* Angluin 1988 (YALEU/DCS/RR-614) and Horning 1969 (Stanford thesis). The content is unverified, as the track says.
* *Not checked by me.* Athreya & Ney, Mendelson's numbering, Boolos–Burgess–Jeffrey, Hájek–Pudlák, Kaye, Pudlák 1998, Cook 1972, Doob 1949, Shafer 1976, Ville 1939, Gold 1967, Angluin 1980. Berk 1966 and Kleijn & van der Vaart 2006 were checked by the track.

---

## Referee verification log

| script | tests | result |
|---|---|---|
| `r1_subcritical.py` | Def 1.5 / Lemma 1.6 | formula productions in L_A and L_∈ have ≥ 1 child; with a nullary predicate, per-type mean < 1 but P(infinite body) = ½ (product 0.500000; simulated 0.4989) |
| `r2_l1_size.py` | Prop 6.9 | an L1 tree costing 12.8 + 12.2k nats derives a sentence of size 2^{k+3} − 1 (checked to k = 14); A4 one-node instances have size ≈ m² at cost O(m) |
| `r3_ville_dirichlet.py` | M1, m2 | Dirichlet weights at fixed w*: invalid acceptance ≥ 0.98 (ε = 10⁻⁵) and ≥ 1.00 (ε = 10⁻⁶) against a bound of 0.02; w* drawn from the prior: 0.008 and 0.010; escalating verifier: non-adaptive prover 11/400, waiting prover 400/400 |
| `r4_dirichlet_rates.py` | Props 5.4(b), 5.5, m7 | confirmed for new α; the in-span spare has slope ≈ 0 |
| `r5_trichotomy.py` | §7, m4 | Bel totally monotone (k ≤ 4); 50/50 coherent iff all theories have ≤ 2 models (12/12); renormalisation coherent 199/300, only 2 all-complete |
| `r6_stronger_theory.py` | Remark 1.10, Prop 2.5 | adding b raises P(b) from 0.032 to 0.346 (graded) and from 0.016 to 0.24 (L2); Prop 2.5 bounds hold |
| `r7_ville_fixed.py` | Theorem 4.1 (fixed weights) | within bounds at three values of δ. A first version, in which each competitor proved a different query, could not bite and was replaced; the docstring records this |
