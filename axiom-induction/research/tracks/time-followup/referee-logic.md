# Referee report (logic and computability): `time-followup/notes.md`

*Adversarial referee of `notes.md`, focused on logic and computability: the diagonal construction (self-reference, totality, what Q proves about it); Σ₁-completeness and the refutation of false Σ₁ sentences; Craig's trick and Hänni's schema under free deduction; the semimeasure convention; and the claim that AI with free deduction is equivalent to unpenalised FIcons. I did not edit `notes.md`. My independent checks are in `referee_logic/`. Each check is deterministic or seeded and writes `<name>.out` next to itself. I re-ran the track's `checks/c1`, `c2` and `c3` on copies, and their outputs are byte-identical to the committed `.out` files.*

## Verdict

**No fatal issue.** The core answer to Hänni's objection is correct, and I could not refute any of the central theorems:

* **The equivalence becomes one-sided** when function induction is time-bounded and deduction is free.
  * AI ≡ unpenalised FIcons, up to a constant, under the membership-class penalty P1a and the generation penalty P2 (Lemma 2.1, Thm 2.2).
  * AI dominates FIcons_τ (Thm 3.1).
  * Every computable predictor, including Hänni's S, is beaten by n − O(1) bits on an arithmetic sequence that Q ∪ {DET} decides (Thm 3.2, Cor 3.3).
* **Charging deduction gives AI[t, d] ≡ FIcert** up to polynomial changes of the budgets (Thm 4.2).

There are two **major** issues:

* **M1.** The one-paragraph answer (§0.1), which is what Hänni will read, states three results more broadly than they are proved. One of them is contradicted by Proposition 3.4 of the same notes.
* **M2.** Proposition 2.4(b) widens the hypothesis of `prop:time:twosorted` from B = Q to "B ⊇ Q on the arithmetic sort", and then it is false. Theorem 3.1 (two-sorted AI^cont), Proposition 5.1(b) and the H-a and H-d rows inherit the error.

The 18 minor issues are scope, wording, slack in the clocked classes, unproved side remarks inside items marked proved, and bookkeeping.

---

## Issues

### Fatal

None found.

### Major

**M1. §0.1 (and §0.2 rows H-b, H-e) overstate the scope of three results.**

* *Claims* (§0.1, line 21):
  1. "In that sense the penalty helps: axiom induction becomes strictly stronger than every time-bounded function inductor."
  2. "Axiom induction, with or without an axiom-side penalty, has bounded regret against time-penalised consistent function induction (Theorem 3.1)."
  3. "With deduction free, axiom induction under an axiom-side penalty is equivalent, up to a constant, to unpenalised consistent function induction".
* *Problem.*
  1. **(1) is false as stated.** Hänni's S and the clocked FIall_τ are time-bounded function inductors. Proposition 3.4 shows that S and AI are incomparable. The same argument (`prop:time:fiall`: "always accept" is a constant-time assigner) shows that FIall_τ has bounded loss on the coin-flip sequences, where AI loses n bits in expectation. "Strictly stronger" (domination plus separation) is proved only against time-bounded *consistent deterministic* function induction (Thm 3.1 with Cor 3.3(b)). Against S and FIall_τ, only the diagonal half holds.
  2. **(2) is wider than Theorem 3.1.** Definition 1.1 calls P1a, P1b, P2 and P3 all "axiom-side penalties", but Theorem 3.1's list of X is AI, AI^chk_t, AI^gen_t, FIcons and *two-sorted* AI^cont_t.
     * It does not cover AI^Kt_t (P1b). Proposition 2.3 gives only a per-hypothesis upper bound of |f| + a'·log₂(|f|+2) + c. FIcons_τ's hypotheses cost |E(f)| = |f| + log₂|f| + O(log log |f|), and when a' > 1 the bound exceeds that cost by an amount that is unbounded over hypotheses. So uniform bounded regret is not established. It is not refuted either.
     * It does not cover one-sorted AI^cont_t.
     * For P3 in a decidable logic, Remark 5.2 of the notes (a proof sketch) gives the opposite. In monadic logic, take t fixed and τ large enough that some X decidable within the clock τ lies outside DTIME(2^{2^{c·t}}). Then AI^cont_t has unbounded loss on D^X while FIcons_τ has bounded loss.
  3. **(3) holds with a constant only for P1a and P2** (Thm 2.2).
     * P1b: only up to O(log |f|) per hypothesis (Prop 2.3).
     * P3: false on Craig-type hypotheses (Prop 2.4(a)) and in monadic logic (Rem 5.2); open in one-sorted arithmetic for assigners inconsistent with Th(ℕ) (Prop 2.4(d)); proved in two sorts only after M2 is fixed, and in one sort only for assigners consistent with Th(ℕ) (Prop 2.4(c)).
     * Nearby, "O(log |f|) bits under a plain Kt penalty, a charge every program pays" is also loose; see m12.
* *Evidence.* Prop 3.4, `prop:time:fiall`, Prop 2.3, Prop 2.4(a), (d), Rem 5.2, and the list of X in Thm 3.1, all in the notes themselves.
* *Fix.* Scope each sentence:
  * (1) "… strictly stronger than every time-bounded *consistent deterministic* function inductor (FIcons_τ, Kt- and speed-prior FIcons). Against S and FIall_τ, which are not restricted to consistent assigners, AI is incomparable (Prop 3.4)."
  * (2) "AI, and its variants with a membership-class or generation-time penalty (P1a, P2), have bounded regret against …"
  * (3) "With deduction free, a membership-class or generation-time penalty (P1a, P2) leaves AI equivalent, up to a constant, to unpenalised FIcons. A Kt penalty (P1b) changes this only by O(log |f|) per hypothesis. A content-relative penalty (P3) is vacuous in two sorts with B = Q, but it bites on Craig sets and in decidable logics, and it is open in one-sorted arithmetic."

**M2. Proposition 2.4(b) is false for "B ⊇ Q on the arithmetic sort".**

* *Claim* (line 133). "In the two-sorted setting of `prop:time:twosorted` (B ⊇ Q on the arithmetic sort), let G_f(φ) := {Acc_f(⌜φ⌝) → φ, Rej_f(⌜φ⌝) → ¬φ}. … If f is compatible with D, then B ∪ A_f is consistent (`prop:time:twosorted`). … Hence W_{AI^cont_t}(D) ≥ 2^(−c)·W_FI(D)".
* *Problem.* The paper's `prop:time:twosorted` has B := Q on the arithmetic sort. Its consistency proof uses the standard ℕ as that sort. With extra arithmetic axioms that are false in ℕ, the argument fails, and so does the claim. Here is a counterexample (assume Con(PA)).
  * The background is B := PA ∪ {¬Con(PA)} on the arithmetic sort. It is decidable and consistent (Gödel II), and it contains Q.
  * Let ψ_0 be a satisfiable L-sort sentence. Let f accept ⌜ψ_0⌝ at once, and on any other input search for a PA-proof of ⊥, accepting if it finds one.
  * Then Γ_f = {ψ_0}, and B ∪ Γ_f is consistent, so f is an FIcons hypothesis compatible with D = ((ψ_0, 1)).
  * But PA ⊢ ¬Con(PA) → Acc_f(⌜ψ⌝) for every ψ ≠ ψ_0. This is the same formalisation step as in `prop:time:single`, provable in IΣ₁. So B ∪ A_f proves every L-sentence, including ¬ψ_0, and is inconsistent. G_f is compatible with no D.
* *Propagation.*
  * Theorem 3.1's case "in two sorts, AI^cont_t".
  * Proposition 5.1(b), whose map p ↦ G_{f_p} needs B ∪ A_{f_p} consistent.
  * The H-a row ("vacuous through Hänni's schema in two sorts") and the H-d row.
* *Fix.* State 2.4(b) for the following setting:
  * B = Q ∪ B_L, with B_L a set of pure L-sort sentences;
  * more generally, B's arithmetic part is true in ℕ and B has no mixed-sort axioms.
  * FIcons consistency then means that B_L ∪ Γ_f has a model, and the model ℕ ⊕ M with M ⊨ B_L ∪ Γ_f works.
  * Carry the same hypothesis into Theorem 3.1 and Proposition 5.1(b).

### Minor

**m1. Remark 2.6(2) and the H-a row: the enumeration claim about A^C_f is too weak in one form and too strong in the other.**

* *Claims.* "It is **not** correct for an enumerator of A^C_f, which has to dovetail" (line 174). H-a: "the paper's A^C_f is not cheap to enumerate ([proved], Rem 2.6…)".
* *Problem.* The phrase "which has to dovetail" is false. What is true depends on the form of P2.
  * *Strict form.* The notes' argument ("cannot be completed before stage s") is about the dovetailing enumerator. A counting argument proves the stronger statement that **no** enumerator of A^C_f meets the strict form. Every enumerator has e_i ≥ |a_1| + … + |a_i| ≥ i, so the strict form forces #{axioms of length ≤ L} ≤ C·L^p. But A^C_f has 2^{Θ(√L)} axioms of length ≤ L.
  * *Cumulative form.* Take the notes' own example f (it decides the s-th sentence within |φ_s| steps when s is a power of 2, and loops otherwise). The same set A^C_f has a specialised enumerator: for each j, generate sentence 2^j directly, run f on it, and write the axiom. This enumerator meets the cumulative form. The refutation therefore holds only for the generic wrapper enumerator (wrapper⌢f), which is the one the FI → AI map produces.
* *Evidence.* `referee_logic/r3_enum_parse_derive.out`.
  * Part A: completion time over cumulative length reaches 7.7·10⁶ at s = 2^18 for the generic dovetailer, and stays ≤ 1.22 for the specialised enumerator.
  * Part B: the count exceeds C·L^p at L = 2504, 5912 and 13947 for (C, p) = (10³, 3), (10⁶, 4), (10⁹, 6).
  * `checks/c2` has no example of the cumulative claim; its largest unpadded end/cum is 10.0.
* *Fix.* Strict form: "no enumerator of A^C_f meets it (counting)". Cumulative form: "the wrapper enumerator of length |f| + c does not meet it". Drop "which has to dovetail".

**m2. Proposition 2.4(d), Remark 5.3 and Remark 5.4 overclaim.**

* *Hänni's schema.* "Hänni's schema is then inconsistent (`prop:time:single`)" (line 144) is false in general. Let f accept exactly ¬Con(PA), at once, and enter a trivial loop otherwise. Then Th(ℕ) ∪ Γ_f is inconsistent and PA ∪ Γ_f is consistent. PA proves ∀x(Acc_f(x) → x = ⌜¬Con(PA)⌝) and ∀x ¬Rej_f(x), by induction on the length of the run (IΣ₁ suffices for a program written so that the loop is evident). So PA ∪ A_f ≡ PA + ¬Con(PA), which is consistent. The correct statement is "can be inconsistent (e.g. for the f of `prop:time:single`)".
* *P3 on the bounded schema.* "So P3 bites on both" (line 145) is not proved for A^bd_f. Proposition 2.5(c) is a per-axiom lower bound under a side condition. No analogue of 2.4(a) (X ∈ DTIME(·) for A^bd-type hypotheses) is given. Remark 5.3 repeats the claim.
* *Remark 5.4.* "Only content-relative ones (P3), and only in logics too weak to carry computations, price it" (line 387) contradicts Prop 2.4(a), where P3 prices Craig-type sets in arithmetic, and the open status of P3 in one sort.
* *Fix.* Weaken all three to what is proved.

**m3. Remark 3.5, third bullet: an unproved negative claim is marked proved in §8.**

* *Claim.* "fails as stated … It works only if P's running time has a known computable bound" (line 260).
* *Problem.* Only a heuristic reason is given: the bound would have to exceed a computation that includes the query on s_n. No impossibility proof is given. The positive parts of the bullet (Q ∪ {DET}, and the Rosser form) are fine; see the confirmed claims.
* *Fix.* Mark the negative part "[heuristic]", or delete "only if".

**m4. Remark 4.4: "H_0 no longer wins" is not proved.**

* *Claim.* "So with budgets polynomial in the sentence length, H_0 no longer wins on the diagonal sequence against S." (line 341)
* *Problem.* Only the derivations obtained from the computation are shown to be long. Q-proofs of true Σ₁ sentences can be much shorter than the computation (speed-up through definable cuts is not excluded). The next sentence of the notes admits this, and §8 lists the remark as "shorter proofs not ruled out". The sentence itself still asserts the conclusion.
* *Fix.* "The derivations obtained from the computation exceed such budgets. Whether H_0 still wins is open."

**m5. Theorem 3.1: the hypothesis "Γ_{g_h} = Γ_h" is too weak.**

* *Problem.* Equal Γ does not imply equal labels. Suppose h accepts ¬ψ while g_h rejects ψ and abstains on ¬ψ. Then both put ¬ψ in Γ, but g_h does not label the datum ¬ψ, so it is not compatible where h is.
* *Fix.* Require g_h to compute the same partial map as h. All the listed examples satisfy this.

**m6. Corollary 4.3(b), (d) and Proposition 2.4(a): exact clocks with no slack.**

* *Corollary 4.3(b).* In "AI[t, d] ≤ 2^c·FIcons_{τ_d} hypothesis by hypothesis", the brute-force assigner needs C_p·2^{d'+1}·t⁺(m + d') steps, plus the simulation overhead of the fixed universal machine. That exceeds τ_d(m) by a factor that depends on p. FIcons_τ has no asymptotic constant.
* *Corollary 4.3(d).* X ∈ DTIME(τ₂), on a multitape machine, does not put f_X inside the clock τ₂ on the fixed universal machine. It also does not give Craig derivations within d_{τ₂}.
* *Proposition 2.4(a).* It concludes X ∈ DTIME(q(t)) where the argument gives DTIME(q(t(m + c))), since |φ_w| = |w| + c.
* *Fix.* Add a growing slack factor (for example τ_d(m)·m, and τ₃ := m·q(τ₂) for the derivation budget in (d)), or state the bounds up to the overhead q and an unspecified constant.

**m7. Corollary 3.3(b): the direction of "regret" is reversed.**

* *Claim.* "the regret of FIcons_τ against AI is bounded above uniformly and is at least n − O(1) on some computable sequence".
* *Problem.* Theorem 3.1 bounds ℓ_AI − ℓ_{FIcons_τ} from above. The diagonal shows ℓ_{FIcons_τ} − ℓ_AI ≥ n − O(1). As written, the sentence uses one quantity in two directions.
* *Fix.* "AI's regret against FIcons_τ is bounded uniformly, and FIcons_τ's regret against AI is at least n − O(1) on some computable sequence."

**m8. Proposition 2.4(c): which PA?** With L ⊋ L_A, "B = PA" must mean PA in L_A, with induction only for L_A-formulas. A model M ⊨ Th(ℕ) ∪ Γ_f need not satisfy induction for formulas with the new symbols. Say so, or assume Th(ℕ) ∪ PA(L) ∪ Γ_f consistent.

**m9. Proposition 5.1(b): only one direction, an undefined case, and an extension the H-d row claims.**

* Only W_X(Θ, D) ≥ 2^(−c)·W_AI(Θ, D) is argued. The converse is easy but not written: map G to d_{q_G}, with q_G := "yes iff χ ∈ G(φ) for some φ", by Lemma 2.1.
* The ratio π_X/π_AI is undefined when W_AI(Θ, D) = 0, in 5.1(a) as well.
* The H-d row claims the result "in one sort with assigners consistent with true arithmetic". No stated proposition covers that case.

**m10. Proposition 2.5 is framed as answering model §10 problem 14 "affirmatively ('… short of Craig's trick')".**

* *Problem.* The schema A^bd_f carries the computation witness in the axiom. The notes themselves say "The bound k plays the role of Craig's padding". It is a Craig-type repair written in Hänni's syntax, with the witness bound in binary. The mathematics is correct (see the confirmed claims); the word "affirmatively" is the problem.
* *Fix.* "A repair in the form of Hänni's schema, using Craig's idea with a binary witness bound."

**m11. Definition 1.2: the speed-prior weight is undefined at D = ∅.** The weight "2^(−|f|)/(total time on the data)" is undefined there (time 0), yet κ = W_Y(∅) enters Theorem 3.1. Use 1 + total time.

**m12. Proposition 2.3 and §0.1: "a charge every program pays".** The padded Craig decider pays up to a'·log₂(|f|+2) + log₂ α'. Every program pays at least log₂|p| − log₂ t(m_0). With a' > 1, a slow assigner pays about (a' − 1)·log₂|f| more than a fast program of the same length. The accurate phrase is "of the same order as the charge every program pays".

**m13. The H-b(ii) row: "Q ∪ {DET} … decides every sentence".** It decides every sentence *of the diagonal sequence*. Q ∪ {DET} is not complete.

**m14. Status table (§8).**

* Theorem 3.2 lists "PA ⊢ DET" as a dependency. The proof uses only that DET is true, so that B ∪ H_0 is consistent.
* Proposition 3.4 does not need Hänni's (incompletely checked) theorem. S's bounded loss on the all-ones label sequence follows from the late-start weight of the constant predictor: once it is tracked, the mixture probability is at least its weight. The status can be "proved".

**m15. Bookkeeping in the check scripts.**

* The docstrings use an older numbering:
  * `c1`: "Theorem 4.2" (the notes' Thm 3.2);
  * `c2`: "Lemma 3.1" (the notes' Lemma 2.1);
  * `c3`: "Theorem 5.2(b)" (the notes' Thm 4.2(b)).
* `c1` Part B runs KT, which ignores the sentences, so the self-reference is never exercised. `r1` closes this gap.

**m16. The reference for Δ₀-definability of T and Out.**

* *Claim.* Theorem 3.2 cites "Hájek–Pudlák 1993, Ch. I (not checked)" for T and Out being Δ₀.
* *Problem.* Δ₀ definability, as opposed to Δ₁, is the nontrivial part: it needs Δ₀ sequence coding, for example through the Δ₀ graph of exponentiation. As far as I recall, this is treated in the bounded-arithmetic chapter (Ch. V), not Ch. I. I did not check this either. The theorem needs Δ₀, since it uses Δ₀-completeness for the label-0 case and for the Rosser form.
* *Fix.* Cite the place where Δ₀ definability is proved.

**m17. H-c row and Remark 4.5(i): "its constant-regret part is trivial for a mixture".** This is shown for the labelled analogue only. `conj:time:polytime` concerns L2 on positive data with a growing depth budget, as Remark 4.5 itself says. Add "in the labelled analogue" to the H-c row.

**m18. Theorem 4.2(b): the syntax the check used.** `checks/c3` checks parsing in an infix syntax with an "&" token. The derivation in the proof uses K's primitive ¬ and →. This is not an error, since `r3` Part C confirms unique parsing in the primitive syntax, but the notes should say which syntax the size bound refers to.
* In Polish primitive syntax, |θ_c| ≤ 10|c| + 11, compared with the notes' 12|c| + 17 in c3's syntax.

---

## Claims I confirmed

I checked each item below line by line. Where a script supports it, the script is named.

**Lemma 2.1 (a)–(d), under (S).**

* Two candidate decompositions ψ^m, by unique readability with the left immediate subformula. The emission counter is strictly increasing, so "detected at counter m − 1" is unambiguous.
* The decider halts even when q is partial.
* Σ_{j≤i} |a_j| ≤ 4(T_i + 1)³ ≤ 4|a_i|³ gives both forms.

**Theorem 2.2 (a), (b) under (S), and the claim "AI ≡ unpenalised FIcons" for AI, AI^chk_t and AI^gen_t.**

* The lower bound goes through q_f, with S_{q_f} = Γ_f, then Pad.
* The upper bound goes through proof search from the r.e. set A_g.
* Losses differ by at most 2c.

**Proposition 2.3 (i), (ii).** Wording as in m12.

**Proposition 2.4(a), Craig-type sets.** A consistent set of literals on distinct numerals implies φ_w only if it contains a power of φ_w. Modulo the shift in m6.

**Proposition 2.4(c).** The reduct of M is elementarily equivalent to ℕ, so the antecedents are evaluated correctly. PA as in m8.

**Proposition 2.5 (a)–(c), the one-sorted bounded schema.** All three parts hold for every B ⊇ Q, including arithmetically false B, because every axiom is Q-equivalent to a member of Γ_f or is a Q-theorem.

* The steps used are Q ⊢ ∃z(z + y = k̄) → y = 0̄ ∨ … ∨ y = k̄ (by meta-induction on k with Q2, Q3, Q5) and Δ₀-completeness.
* `r2_q_models.out`, on 576 nonstandard Q-structures ℕ ∪ {a, b}:
  * the bounded lemma holds in all of them;
  * the false Σ₁ sentence ∃c (S0 + c = c) is true in 432 of them, so Q does not refute false Σ₁ sentences;
  * its numeral-bounded form is true in none.
* This is exactly the mechanism by which A^bd_f escapes the nonstandard proofs of ⊥ that break Hänni's schema. Framing as in m10.

**Theorem 3.1** for X ∈ {AI, AI^chk_t, AI^gen_t, FIcons}. The two-sorted AI^cont_t case holds after the M2 fix, with the hypothesis as in m5.

**Theorem 3.2 (a)–(d), the diagonal separation.**

* *Self-reference and totality.* G is total because P is total. By the recursion theorem, e is total with values in {0, 1}. The values β_j do not depend on n, so P is queried only on the true histories D_{j−1}.
* *What Q proves.* For b_n = 1, s_n is a true Σ₁ sentence, so Q proves it. For b_n = 0, DET, the true Δ₀ sentence T(ē, n̄, c̄_0) ∧ Out(c̄_0, 0̄), and Q ⊢ 1̄ ≠ 0̄ refute s_n. DET is needed: Q alone does not refute false Σ₁ sentences (`r2`, row F).
* *Loss.* q_{b_j} ≤ (q_0 + q_1)/2 + 2^{−j−2} ≤ 1/2 + 2^{−j−2}, which sums to n − 1/(2 ln 2).
* *Observation, not an issue.* The bound is valid but not tight. From q_b ≤ q_{1−b} + 2·2^{−j−3} and q_0 + q_1 ≤ 1 one gets q_{b_j} ≤ 1/2 + 2^{−j−3}, hence ℓ_P(D_n) ≥ n − 1/(4 ln 2) ≥ n − 0.37.
* *Evidence.* `r1_quine_diagonal.out` builds e as a genuine quine whose sentences s_j contain e's own source. The predictors read those sentences. One of them, "evaluator", parses e out of s_j and runs it with a budget, in the spirit of u. On every predictor and approximation mode:
  * the fixed point holds;
  * the history recomputed from scratch for every n ≤ N agrees with the single run;
  * the sentences agree with s_j computed outside e;
  * the loss satisfies both bounds. The near-half adversary reaches ℓ_n − n = −0.343, against the sharp bound −0.361.

**Corollary 3.3 (a)–(c).**

* (a) The clocked FIall_τ mixture plus a uniform component is computable: compatibility is decidable, the Elias-δ weights form a complete prefix code with computable tails, and P(D) ≥ 2^{−|D|−1}.
* (b) W_{FIcons_τ} ≤ 2P gives ℓ ≥ n − 1.73 − c_⊥. Wording as in m7.
* (c) Incomputability: the recursion theorem with a partial G, by induction on j.

**Proposition 3.4.** S and AI are incomparable. Status as in m14.

**Remark 3.5, first two bullets, and the Rosser form.**

* For the Rosser form with e(n) = 0, case on c ≤ c̄_0 or c̄_0 ≤ c, using Q ⊢ ∀x(x ≤ n̄ ∨ n̄ ≤ x).
* This dichotomy holds for ≤ defined as ∃z(z + x = y), the convention of the paper and of Smith. `r2` confirms it in all 576 structures, and shows that the other orientation, ∃z(x + z = y), fails in 288 of them. The orientation matters, and the notes use the right one.

**Proposition 4.1 (a), (b).** Part (c) is a plausible proof sketch, with p' = n·p(n).

**Theorem 4.2 (a), (b).**

* (a) The certificate is the derivation code, with d' = β·d·log d. Membership through p takes O(t). Consistency rules out double certificates.
* (b) The certificate sentences θ_c are valid and uniquely readable. The derivation is "cite, (B ∧ C) → B, MP".
* `r3` Part C: unique parsing in K's primitive syntax, 4000 cases.
* `r3` Part D: a 287-line K-derivation of (P ∧ Q) → P from A1–A3 and MP, built with the deduction-theorem algorithm and checked by an independent checker. After substitution its size is exactly 3725|B| + 1559|C| + const, which confirms "linear in |B| + |C|". This covers both Theorem 4.2(b) and the Craig derivation of Corollary 4.3(a).

**Corollary 4.3 (a), (c), (e), (f).** Parts (b) and (d) hold up to the slack in m6.

**Proposition 5.1(a).** Up to the undefined case in m9.

**Remark 5.2.** A plausible proof sketch. Monadic validity is decidable (Löwenheim 1915), and Lewis 1980 gives NEXPTIME-completeness of monadic satisfiability.

**The semimeasure convention.** It is used consistently. Losses telescope, W(∅) ≤ 1 by Kraft, and every comparison of AI with a predictor uses AI's semimeasure loss, which is never smaller than its renormalised loss. So all the "AI loses a constant" bounds also hold under renormalisation.

**Paper labels.** Every paper label cited in the notes exists, in `time.tex`, `app-time.tex` or `app-model.tex`.

## References

Checked from memory against the standard bibliographic data, not against the sources in this session:

* Craig 1953 (JSL 18: 30–32);
* Hartmanis–Stearns 1965 (Trans. AMS 117);
* Hennie–Stearns 1966 (JACM 13);
* Seiferas–Fischer–Meyer 1978 (JACM 25);
* Žák 1983 (TCS 26);
* Lewis 1980 (JCSS 21);
* Legg 2006 (ALT 2006), whose result is that every computable predictor fails on some computable sequence;
* Löwenheim 1915 (Math. Ann. 76).

These are consistent with the notes. The chapter references the notes mark "(not checked)" remain unchecked; see m16.

## Scripts written for this report

| script | what it checks | result |
|---|---|---|
| `referee_logic/r1_quine_diagonal.py` | Thm 3.2(a), (c): e as a quine whose sentences contain its own source; 5 predictors that read the sentences (including a budgeted self-evaluator) × 2 approximation modes; fixed point, from-scratch history consistency, loss bounds | all pass; near-half adversary at −0.343 (notes' bound −0.721, sharp bound −0.361) |
| `referee_logic/r2_q_models.py` | the Q facts: bounded lemma, the ≤-dichotomy in both orientations, a false Σ₁ sentence and its bounded form, on 576 nonstandard Q-structures | as expected: bounded lemma and left dichotomy in all; right dichotomy fails in 288; false Σ₁ true in 432; bounded form true in none |
| `referee_logic/r3_enum_parse_derive.py` (seed 2718) | Rem 2.6 (generic and specialised enumerators of A^C_f; counting for the strict form); Thm 4.2(b) primitive-syntax parsing; a K-derivation of (B ∧ C) → B checked and measured | m1 confirmed; parsing unique; derivation checks, size linear in \|B\| + \|C\| |
