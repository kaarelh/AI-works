# Verification record: T6-philosophical-completeness

*Target file: `research/theory/T6-philosophical-completeness.md`.*
* *Two independent adversarial referees checked the file: Referee A for §§0–3 and Referee B for §§4–5, together with the §0, §6 and §7 claims about them.*
* *Their reports are reproduced verbatim below as JSON, followed by the author-repairer's log. The same log is appended to the theory file.*
* *Repair checks are in `research/theory/T6-checks/repair_checks.py`, plus the new part (a2) of `research/theory/T6-checks/contexts_local_global.py`. Both are run by `run_all.sh`, which exits 0.*

**Outcome in brief.**
* No issue was labelled fatal or major, and I found none on re-checking.
* Every minor issue was genuine and has been fixed, or the claim has been weakened or recast. No issue was rejected.
* The substantive repairs are:
  * Thm 1.5(c) now assumes soundness. The referee's counterexample is reproduced.
  * Thm 3.1's hypothesis now reads "a finite union of complementary pairs".
  * Cor 3.9's proof makes the computability of markets explicit and adds a non-dogmatism proof. The "no limit-computable credence" sentence is qualified, and the one-element-structure counterexample is added.
  * Def 4.0 specifies the Lindenbaum semantics as the proper closed theories with an explosive falsum. Cor 4.2 gets a non-triviality reading.
  * Def 4.8 now requires that the context establishes φ and that the side conditions hold.
  * The Post-completeness sentence after Prop 5.3 is retracted, refuted by IPC.
  * Thm 5.7(c) now needs a binary relation symbol.
  * The reading of Prop 5.8 now separates uniform anchoring from actual anchoring.
  * The novelty claims for Thms 3.8, 4.5 and 5.7 are recast as standard arguments, newly applied.

---

## Referee reports (verbatim JSON)

```json
[
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T6-philosophical-completeness.md",
  "items_checked": [
   "Prop 1.3",
   "Thm 1.4",
   "Definition of point (§1.4)",
   "Thm 1.5(a),(b),(c)",
   "Prop 1.6 and its Reading",
   "§1.5 table/Nullstellensatz remarks (spot-checked)",
   "Thm 2.2",
   "Cor 2.3",
   "Thm 2.4",
   "Remark 2.5 (Stone duality)",
   "Thm 2.6",
   "Thm 3.1",
   "Prop 3.2 / Example 3.3 (spot-checked)",
   "Thm 3.4 (incl. 'enlarged agenda' remark, LP-verified k=3..7)",
   "Thm 3.5 (MILP-verified k=3,4,5)",
   "Prop 3.6",
   "Thm 3.7",
   "Thm 3.8",
   "Cor 3.9",
   "Prop 3.10 (random Motzkin check)",
   "§0 summary sentences pointing to §§1-3",
   "T6-checks scripts: scott_duality.py, prob_coherence.py, counting_sequents.py, misc_checks.py, multiplicity.py (all re-run, outputs match the text)"
  ],
  "issues": [
   {
    "item": "Prop 1.3",
    "severity": "ok",
    "description": "The statement and proof are correct. The soundness hypothesis is never used: image(Th) = Fix(Th∘Mod) holds in every frame, and a closure operator is determined by its fixed points. The proposition holds for any closure operator C.",
    "evidence": "Brute force over 7,235 random sound finite frames (|S| ≤ 5, random closure systems, random model sets) found 0 failures of 'image = Fix(C) iff strongly complete'.",
    "suggested_fix": "Optional: note that soundness is not needed."
   },
   {
    "item": "Thm 1.4",
    "severity": "ok",
    "description": "Correct. Mod(X) = {T ∈ Fix(C): X ⊆ T}, so Th(Mod(X)) = C(X). The text calls it 'trivial once set up' (TOSU), which fits: this is the standard Lindenbaum/Wójcicki observation.",
    "evidence": "Direct check of the one-line proof.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 1.5(c)",
    "severity": "minor",
    "description": "Part (c) does not state that C is sound, but its (⇒) direction needs it: the proof uses 'Th({m}) is closed', which is soundness. Without soundness, (c) is false. Part (b) introduces soundness, so the hypothesis may be meant to carry over, but the bullet as written does not say so. Parts (a) and (b) are correct as stated.",
    "evidence": "Counterexample. S = {a, b, ⊥}. Closed sets ∅, {a}, S (finitary, C({⊥}) = S). One model m with Th({m}) = {a, b} ≠ S. The coherent sets are ∅ and {a}, and both have model m, so C is weakly complete. But the unique maximal proper closed set {a} is not the theory of any model. C is not sound, since C({b}) = S ⊄ Th(Mod({b})) = {a, b}. My random brute force also finds one (|S| = 5, closed sets {s0} and S, models {s0,s1,s3,s4} and {s1,s3,s4}). With soundness, 0 failures of (b) or (c) on 7,235 sound frames.",
    "suggested_fix": "Add 'C sound for (S, M, ⊨)' to the hypotheses of (c), or state soundness once for all of 1.5(b)–(c). Only (⇒) needs it."
   },
   {
    "item": "Prop 1.6",
    "severity": "ok",
    "description": "Correct. IPC is sound for BV. A maximal IPC-consistent T contains φ or ¬φ for each φ (maximality plus the deduction theorem), hence contains all of excluded middle (EM). So C_CPC(T) = C_IPC(T ∪ EM) = T, and T is maximal CPC-consistent. IPC ⊬ p∨¬p, so IPC is not strongly complete. (Weak completeness is also immediate from Glivenko.) The non-maximal point 'maximal omitting p∨¬p' exists by 1.5(a), is prime, and is not realized by any Boolean valuation.",
    "evidence": "Line-by-line check of lines 120–126.",
    "suggested_fix": "None (could cite Glivenko as a one-line alternative)."
   },
   {
    "item": "Prop 1.6 Reading (classical points are maximal), line 131",
    "severity": "minor",
    "description": "The sentence 'if T is maximal omitting φ and ψ, ¬ψ ∉ T, then φ ∈ C(T,ψ) ∩ C(T,¬ψ) = C(T)' is garbled. It reads as 'maximal omitting both φ and ψ'. The intended argument is right.",
    "evidence": "Intended argument: let T be maximal omitting φ, and suppose ψ ∉ T and ¬ψ ∉ T. Then φ ∈ C(T,ψ) ∩ C(T,¬ψ) = C(T) by proof by cases, a contradiction. So T is complete, and being consistent it is maximal.",
    "suggested_fix": "Rewrite: 'if T is maximal omitting φ and neither ψ nor ¬ψ is in T, then φ ∈ C(T,ψ) ∩ C(T,¬ψ) = C(T) = T, contradiction; so T is complete, hence maximal.'"
   },
   {
    "item": "§0 summary, item 1 (line 27)",
    "severity": "minor",
    "description": "'Step (i) alone makes every calculus complete for its own points (Thm 1.4)' does not match Thm 1.4. Thm 1.4 uses all closed sets Fix(C) as models and needs no Zorn. Completeness for the frame (S, Pt(C), ∋) is Thm 1.5(a), which needs finitarity.",
    "evidence": "Compare line 27 with the statement of Thm 1.4 (line 88) and the hypothesis 'Let C be finitary' in Thm 1.5.",
    "suggested_fix": "Say 'complete for its own closed theories (Thm 1.4), and, if finitary, for its own points (Thm 1.5(a))'."
   },
   {
    "item": "Thm 2.2 / Cor 2.3",
    "severity": "ok",
    "description": "Correct. The Zorn argument is valid because sequents are finite: a witness lies in one member of the chain. Disjointness follows from (Ov) and exhaustiveness from (Wk) and single-formula (Cut). Single-formula cut suffices because sequents are finite, so Shoesmith–Smiley's 'cut for sets' is not needed. Part (b) and the strong completeness Th(Mod(S)) = ⟨S⟩ follow. The edge case ∅▷∅ ∈ ⊢ is handled correctly (no coherent positions, Val = ∅).",
    "evidence": "scott_duality.py re-run: Scott closure equals Th(Mod(S)) on 300 random sets with n = 4. OK.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 2.4",
    "severity": "ok",
    "description": "Correct. Mod(Th(V)) is the complement of the union of the basic cylinders U(Γ,Δ) that miss V, and that is the topological closure. With Cor 2.3 and Fact 1.2 this gives a dual isomorphism between Scott relations and closed subsets of 2^Fm. The scripts only test finite Fm, where every set is closed, so the topological content is proved but not machine-checked. That is not a defect. This compact-relation/closed-class correspondence is standard (Scott 1974; Shoesmith–Smiley 1978; cf. Humberstone's treatment of gen-consequence relations (u)). The file does not claim novelty.",
    "evidence": "Proof check, plus T2 Lemma 4.1(a) (read, correct). scott_duality.py: n = 3 exhaustive OK.",
    "suggested_fix": "Optional: credit the closed-class characterization to Scott/Shoesmith–Smiley as well."
   },
   {
    "item": "Remark 2.5 (Stone duality claim)",
    "severity": "ok",
    "description": "Correct. The Stone space of the free Boolean algebra on Fm is 2^Fm. Sequents map to clauses, and Ov-sequents map to ⊤. Elements are finite meets of clauses (CNF), so a filter is determined by its clauses. Filters correspond bijectively and order-reversingly to closed sets (Stone). The improper filter corresponds to ∅ and to the Scott relation containing ∅▷∅. Suszko's reduction actually holds for all Tarskian consequences, not only structural ones; saying 'structural' is a harmless restriction.",
    "evidence": "Standard Stone duality: filters ↔ closed sets; ultrafilters ↔ points.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 2.6",
    "severity": "ok",
    "description": "Correct. The identity v∘σ ⊨ Γ▷Δ ⇔ v ⊨ σΓ▷σΔ gives (a). The (⇐) direction correctly uses ⊢ = Th(Val(⊢)) from Cor 2.3. In (b), assignments into the term-algebra matrix L_v are exactly substitutions, so L_v validates ⊢, and the identity assignment realizes coherent positions via Thm 2.2.",
    "evidence": "Line-by-line check of lines 222–227.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.1",
    "severity": "minor",
    "description": "The equivalences and proofs are correct. Rational H-representation gives (iii)⇒(i) and (ii)⇒(i). Clearing denominators plus the negation identity gives (iv)⇒(iii). Negation coherence is genuinely needed for (iv)⇒(i): P ≡ 1 satisfies every valid counting sequent, because validity forces m ≤ |Φ|, yet P ≡ 1 is incoherent. The defect is the hypothesis 'F closed under negation' together with 'finite agenda'. Taken literally this is impossible, since φ, ¬φ, ¬¬φ, … are pairwise distinct. The proof and scripts actually use complementary pairs: F is a union of pairs {φ, φ*} with φ* ≡ ¬φ, and the 'negation' of ¬φ is φ.",
    "evidence": "counting_sequents.py re-run: 215/215 Farkas certificates converted to verified violated counting sequents. Its docstring says 'Thm 3.2' but should say Thm 3.1 (cosmetic).",
    "suggested_fix": "State: 'F is a finite union of complementary pairs {φ, φ*} with φ* ≡ ¬φ, and P(φ*) = 1 − P(φ)'. Fix the script docstring."
   },
   {
    "item": "Prop 3.2 / Example 3.3",
    "severity": "ok",
    "description": "Correct. For Prop 3.2, the union bound of p∧q ▷ p is 0.1 + 0.2 = 0.3 < 1. For Example 3.3, the four facets match the ConvexHull output exactly.",
    "evidence": "prob_coherence.py (a) re-run: the facets are a+c ≥ 1, b ≥ a+c−1, c ≤ 1 and b ≤ c.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.4 (arity counterexample P_k)",
    "severity": "ok",
    "description": "Correct. (a): the mixture of e_j (j ∈ J) at 1/(k−1) plus the all-false world reproduces P_k on any sub-agenda over |J| ≤ k−1 atoms. (b): pairwise-null intersections plus Bonferroni give μ(∪A_i) ≥ k/(k−1) > 1. The 'enlarged agenda' remark (all formulas in ≤ 2 atoms, using pairwise marginals 0, 1/(k−1), 1/(k−1), (k−3)/(k−1)) is also correct and needs k ≥ 3. For k = 3 this is exactly Specker's parable (each pair has exactly one true atom).",
    "evidence": "prob_coherence.py (b) re-run for k = 3..6: global incoherent, every (k−1)-atom sub-agenda coherent. My independent LP on the enlarged agenda (all 16 Boolean functions on every pair, with coherence of each (k−1)-atom sub-agenda tested against all k-atom worlds), k = 3..7: globally incoherent, locally coherent in every case.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.5 (multiplicity hierarchy)",
    "severity": "minor",
    "description": "The mathematics is correct. (a): #true = (k−t) + C(t,2) ≥ k−1 ⇔ (t−1)(t−2) ≥ 0, and Σ = k(k−2)/(k−1) < k−1. (b): the two-world argument (∅ and the singletons) with integrality is valid, giving m ≥ (k−2)s + 1 ≥ k−1. The m = 1 reduction to ordinary sequents is valid. The problem is wording. The 'multiplicity' being stratified is the threshold m, not repetition: the violated sequent in (a) is a plain set with no repeated formulas. So 'unbounded multiplicity' (§0, §3.2) can mislead readers into thinking repeated copies are needed. Also, §3.2's 'coherence needs the full family of counting sequents' overstates the result: for any one finite agenda, finitely many facet sequents suffice. The theorems show only that no uniform bound on arity or threshold works across agendas.",
    "evidence": "My MILP (integer multiplicities, minimize Σ_Φ P_k − m subject to validity). With m ≤ k−2: minimum 0 for k = 3, 4, 5, so no violation. With m ≤ k−1: minima −1/2, −1/3, −1/4, exactly matching (a). multiplicity.py re-run: smallest violated m is 2 for k = 3 and 3 for k = 4 (books with entries in {−1, 1}, i.e. no repetition). prob_coherence.py (c): 503,270 valid sequents and 0 union-bound violations.",
    "suggested_fix": "Call m the 'threshold' or 'grade' rather than 'multiplicity'. Say the hierarchy is strict uniformly over agendas, not that any single agenda needs the full family."
   },
   {
    "item": "Prop 3.6",
    "severity": "ok",
    "description": "Correct. P(⊥) = 0 follows from φ = ψ = ⊤. Successive splitting by the atoms of the finite Boolean algebra gives P(φ) = Σ_{a_j ≤ φ} P(a_j), using φ ∧ ∧_j ¬a_j = ⊥. Choosing v_j ⊨ a_j yields a mixture μ with total mass 1 and nonnegative weights. Each constraint mentions at most three agenda elements.",
    "evidence": "Line-by-line check of lines 331–335.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.7 (Gaifman coherence = measures on Stone space)",
    "severity": "ok",
    "description": "Correct, and standard: Gaifman 1964 is correctly credited. Equivalence-invariance from (G1)/(G2) is correctly derived. Clopens correspond to the Lindenbaum algebra. Compactness gives countable additivity on the clopen algebra. Carathéodory plus π–λ gives existence and uniqueness. The countably many clopens generate the Borel σ-algebra. The ¬Con(PA) example is correct (Q/PA prove every true quantifier-free sentence).",
    "evidence": "Line-by-line check of lines 353–357.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.8 (probabilistic ω-rule pins Th(N))",
    "severity": "minor",
    "description": "The proof is correct. The induction on logical symbols works because numerals are non-logical terms, so φ(n) has fewer logical symbols than ∃xφ(x). The disjunction step uses Fréchet bounds on 0/1 values, not the induction hypothesis, which is legitimate. The problem is attribution. The result is a standard consequence of Gaifman 1964: a probability satisfying the Gaifman condition is determined by its values on quantifier-free sentences. Labelling it only '[proved; the probabilistic transcription of ω-completeness]' without crediting Gaifman under-attributes it.",
    "evidence": "Line-by-line check of lines 365–369. There is no gap; the Gaifman condition is applied to every φ(x) in the ¬,∧,∃ fragment.",
    "suggested_fix": "Add '[cf. Gaifman 1964: Gaifman measures are determined by their quantifier-free restriction]'."
   },
   {
    "item": "Cor 3.9 (logical inductors are non-standard; Δ2 argument)",
    "severity": "minor",
    "description": "The conclusion and the Δ2 argument are correct, but the proof silently uses that n ↦ P_n(φ) is computable. That is part of Garrabrant et al.'s definition of a market as a computable sequence of rational pricings (from memory; arXiv was unreachable to confirm). Given that, 'φ ∈ Th(N) iff ∃N∀n≥N P_n(φ) > 1/2' is Σ2 and the ∀∃ form is Π2, so Th(N) would be Δ2, contradicting Tarski. The following sentence (line 379), 'an infinitary condition (Thm 3.8) that no computable or limit-computable credence satisfies', is false as literally stated. It holds only together with coherence and P = 1 on all true quantifier-free sentences.",
    "evidence": "Counterexample to the literal line-379 claim: let T be the decidable theory of the one-element structure (S0 = 0 = 0+0 = 0·0). Then δ_T is computable, coherent, and satisfies the Gaifman condition w.r.t. numerals, because every element is a numeral's value. It fails only the true-QF hypothesis (it gives P(0 = S0) = 1). A more robust alternative proof of Cor 3.9: Γ ⊇ Q consistent r.e. is incomplete (essential undecidability of Q), so some sentence false in N is consistent with Γ. Non-dogmatism (Garrabrant et al.) gives it P_∞ > 0, so P_∞ ≠ δ_Th(N).",
    "suggested_fix": "In the proof, state 'since (P_n) is a computable sequence (Garrabrant et al. Def. of market)'. Qualify line 379: '…that no limit-computable coherent credence giving 1 to all true QF sentences satisfies'. Optionally add the non-dogmatism proof."
   },
   {
    "item": "Prop 3.10 (finite VNM)",
    "severity": "minor",
    "description": "The proposition is correct: it is exactly Motzkin's homogeneous transposition theorem with strict rows p_i − q_i and weak rows r_j − s_j. The edge case of no strict comparisons is handled (λ cannot be nonzero, and u = 0 works). The 'Hausner' remark is also right: finite lexicographically representable data are real-representable via u_1 + εu_2 + …. The defect is in the summary and reading. §0 says 'coherent iff there is no money pump', but what is proved is 'iff there is no derivation of L ≻ L by mixing (independence) plus transitivity'. Calling that a money pump is an interpretive gloss; no trading or payment structure is formalized.",
    "evidence": "Random test: 3,000 instances (2–3 outcomes, 1–4 strict and 0–3 weak comparisons), LP feasibility of u versus LP feasibility of the Motzkin certificate. They disagreed 0 times (2,030 incoherent instances).",
    "suggested_fix": "In §0, say 'iff no mixing+transitivity derivation of L ≻ L (a money-pump-like certificate)'."
   }
  ],
  "overall": "I could not refute anything in §§1–3: every result in scope is true, and I found no fatal or major gaps. I checked each proof line by line, re-ran the five relevant T6-checks scripts (their outputs match the text exactly), and ran my own brute-force tests:\n- random finite closure systems for Prop 1.3 and Thm 1.5;\n- an LP check of Thm 3.4 for k = 3..7, including the enlarged pairwise agenda;\n- an exact MILP check of Thm 3.5(b) for k = 3, 4, 5: no violation with m ≤ k−2, and minimum violations of exactly −1/2, −1/3, −1/4 at m = k−1;\n- 3,000 random instances of the Motzkin characterization in Prop 3.10.\n\nMinor issues:\n- **Thm 1.5(c)** needs soundness but does not state it. I give an explicit counterexample without it.\n- **Thm 3.1** says the finite agenda F is \"closed under negation\", which is impossible literally. It should say \"a union of complementary pairs\".\n- **Cor 3.9** silently uses that logical-inductor markets are computable. The following sentence (line 379) overstates the result; a computable coherent Gaifman credence exists once the true-quantifier-free hypothesis is dropped.\n- **Thm 3.8** is a standard consequence of Gaifman 1964 and should credit it.\n- **Thm 3.5**: \"multiplicity\" really means the threshold m, since the violated sequent repeats no formula.\n- **Wording**: one garbled sentence in the Prop 1.6 reading, the §0 attribution of \"complete for its own points\" to Thm 1.4, and the \"money pump\" gloss on Prop 3.10.\n\nThe Stone-duality claim (Thm 2.4 / Rem 2.5) is correct, and the duality itself is standard."
 },
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T6-philosophical-completeness.md",
  "items_checked": [
   "Def 4.0 / calculus MC (existence of Der, finitary remark)",
   "Thm 4.1 (a),(b),(c) soundness/completeness, canonical chain",
   "Cor 4.2 (D-coherence iff model nonempty on D)",
   "Prop 4.3 (canonical chain = least/grounded equilibrium)",
   "Prop 4.4 (non-monotone bridge, no equilibrium)",
   "Relation to L7 context-tree calculus (remark after Prop 4.4)",
   "Thm 4.5 (a),(b),(c) rules of proof vs conditionals",
   "Thm 4.6 (local-to-global on trees) incl. projection lemma and BFS step",
   "Prop 4.7 (frustrated triangle, logical + probabilistic) and the Vorob'ev/BFMY citation",
   "Def 4.8 (true / true enough in a context)",
   "Thm 5.1 (a),(b),(c)",
   "Thm 5.2 (a),(b) incl. existence of Leibniz congruence",
   "Prop 5.3 and the reading paragraph after it",
   "Ex 5.4 (H_3 point of IPC; quantifier swap)",
   "Thm 5.5 (prime models of complete extensions of PA)",
   "Section 5.4 layer (i): Pi_1-soundness of PA+not-Con(PA)",
   "Thm 5.6 (compactness/LST barrier)",
   "Thm 5.7 (a)-(d) computability barrier",
   "Prop 5.8 (Beth) and its reading",
   "Section 5.5 pins (Dedekind, initiality, Tennenbaum, omega-rule) - light check",
   "Section 0 / Section 6 summaries of the Section 4-5 results",
   "Section 7 novelty claims for Thm 4.1, 4.5, 5.7",
   "run_all.sh re-run (all 7 scripts) plus independent brute-force checks: Prop 4.3 equilibria (300 random 3-context systems), Thm 4.5(a) direction, Thm 4.6 on 2,656 random trees + negative control, Thm 5.2(a) on 1,600 random finite-algebra quotients, Boolean BFMY counterexample on the 4-atom tetrahedral cover"
  ],
  "issues": [
   {
    "item": "Thm 4.1 (soundness and completeness; canonical chain)",
    "severity": "ok",
    "description": "Statement and proof are correct. Der exists: (L_i)_i is a bridge-closed family, and C_i-closed, bridge-closed families are closed under componentwise intersection. (a) uses Th_i Mod_i(T_i)=T_i. (b) uses that U_i=Th_i(c_i) is C_i-closed by the Galois property, contains K_i and Gamma_i, and is bridge-closed. (c) follows from (a) and (b). The proof does not need finitarity. It is correctly tagged TOSU: completeness is relative to locally complete C_i=Th_i Mod_i.",
    "evidence": "mcs_completeness.py re-run: 0 mismatches over 400 systems. My independent reimplementation (300 fresh random 3-context systems, 4 local models each, including 0-premise bridges and bottom-premises) also agrees with LMS entailment everywhere.",
    "suggested_fix": "None needed."
   },
   {
    "item": "Cor 4.2 (context coherence iff existence)",
    "severity": "ok",
    "description": "Correct under the stated hypothesis Mod_i(bot_i)=emptyset. bot_i is in T_i iff Mod_i(T_i) is empty, because T_i=Th_i Mod_i(T_i). Maximality of c^Gamma (Thm 4.1(b)) then gives the equivalence.",
    "evidence": "The script assertion (syn_coh == sem_coh) passes. My brute force checks all 8 choices of D in 300 systems: 0 violations.",
    "suggested_fix": "None for the statement itself. See the separate entries on applying it to learned logics and on the summaries."
   },
   {
    "item": "Def 4.0 / Cor 4.2: applicability to 'the learned logic of Section 5 with its Lindenbaum semantics (Thm 1.4)'",
    "severity": "minor",
    "description": "Def 4.0 offers learned logics with Lindenbaum semantics as an admissible local logic, but such logics fail Def 4.0's other requirement: a local falsum with Mod_i(bot_i)=emptyset. In Thm 1.4's canonical frame (S, Fix(C), membership), the trivial theory S is in Fix(C) and satisfies every formula, so no formula has an empty model class. Removing S does not help when bot is not C_R-explosive, and Section 5.1 allows that, since it defines coherence as 'bot not in C_R(A)'. In that case the two notions 'bot derivable at i' and 'c_i^Gamma empty' come apart, so Cor 4.2 does not apply to these local logics as advertised.",
    "evidence": "Take R = empty (C_R = identity), M_i = the proper closed sets, K_i={bot}. Then bot is in T_i, so context i is incoherent in the Section 5.1 sense. Yet c_i^Gamma = Mod_i({bot}) contains the proper closed set {bot}, so it is nonempty. With M_i = Fix(C_i) as in Thm 1.4, Mod_i(phi) contains L_i for every phi, so the falsum bullet of Def 4.0 can never be met.",
    "suggested_fix": "For Lindenbaum-semantics contexts, set M_i = Fix(C_i) minus {L_i} and also require C_i(bot_i)=L_i. Alternatively, define D-coherence as T_i != L_i, which Cor 4.2 then characterizes without a falsum."
   },
   {
    "item": "Section 0 and Section 6 summaries of Cor 4.2 ('a bridge-compatible family of nonempty local belief states')",
    "severity": "minor",
    "description": "Cor 4.2 gives nonemptiness only on the designated contexts D. The summaries drop the 'on D' qualifier. Read literally they are false, because non-designated (suppositional) contexts may be forced empty.",
    "evidence": "Take I={@,s}, D={@}, K_@={q}, K_s={p, not p}, no bridges. The system is D-coherent, yet every model has c_s = emptyset.",
    "suggested_fix": "Write 'nonempty at every designated context'."
   },
   {
    "item": "Prop 4.3 (canonical chain is the least equilibrium; D-consistent equilibrium iff D-coherent)",
    "severity": "ok",
    "description": "The proof is correct. T contains R(T) because T is closed and bridge-closed. R(T) is closed, contains K and Gamma, and is bridge-closed, so it contains T. Every equilibrium is closed, contains K and Gamma, and is bridge-closed, so it contains T. Part (b) follows. Brewka-Eiter's grounded equilibrium for definite MCS is indeed the least equilibrium; the (u) flag is appropriate.",
    "evidence": "Independent brute force over all belief states made of closed theories, in 300 random 3-context systems: Der(Gamma) is always an equilibrium and is below every equilibrium, and the D-consistency equivalence holds for all 8 choices of D. There were 0 violations. 50 non-least equilibria occurred, so 'least' is not vacuous.",
    "suggested_fix": "None."
   },
   {
    "item": "Prop 4.4 (non-monotone bridges break existence)",
    "severity": "minor",
    "description": "The mathematics is correct: it is the standard odd loop 'p <- not p'. Two wording problems. First, 'context i alone is coherent' is not defined for non-monotone systems; it presumably means K_i is consistent. Second, 'existence ... must come from stratification' overstates. Stratification is sufficient, not necessary. B&E-style MCS without odd loops through negation, or other well-founded conditions, also guarantee equilibria.",
    "evidence": "Case analysis: if p is in S_i, then S_i = C_i(K_i), which omits p. If p is not in S_i, then S_i = C_i(K_i + p), which contains p. The case analysis is fine.",
    "suggested_fix": "Say 'K_i is consistent' instead of 'coherent'. Replace 'must come from stratification' with 'needs an extra condition such as stratification'."
   },
   {
    "item": "Remark relating MC to L7's context-tree calculus (after Prop 4.4)",
    "severity": "minor",
    "description": "'Thm 4.1 is its completeness theorem for local-models semantics; L7 Prop 1 proved soundness' pairs a completeness and a soundness result for two different semantics. In L7 Section 8.2, Mod(@)=Mod(K plus O) and Mod(pi(c)) do not depend on exports, and Exp is licensed by bridge soundness. In MC/LMS, the canonical chain c_{pi(c)} = Mod(T_{pi(c)}) is shrunk by every exported epsilon. The two coincide only when all Exp and Step instances are sound and locally complete. The SUP identity c_c = c_{pi(c)} intersected with Mod(A) is correct.",
    "evidence": "Take an unsound export that yields @:Q=5 while K plus O proves Q=3. MC derives @:bot and c^Gamma_@ is empty, as LMS completeness requires. L7's Mod(@) is nonempty, and L7 Prop 1 does not apply because Exp is unsound.",
    "suggested_fix": "State that Thm 4.1 is completeness for LMS with bridges read as compatibility constraints, and that it matches L7's semantics when all Step and Exp instances are sound."
   },
   {
    "item": "Thm 4.5 (a),(b),(c)",
    "severity": "ok",
    "description": "(a) World families are exactly the model chains of singletons, so LMS entailment is contained in W entailment. (b) The p-or-q example is correct: T_j = Cn(p or q) fires no bridge, and every world family forces r together with not r. (c) is correct, but the tagged theory must also include the tagged K_i and Gamma, which the statement omits.",
    "evidence": "The script re-run confirms the disjunction example. The script counts 'pw != sem', not the direction of the difference. My reimplementation checked the direction: 0 cases where LMS entails something W does not, and 2,811 strict-gap cases, consistent with (a).",
    "suggested_fix": "In (c), add the tagged K_i and the tagged premises Gamma to the axioms."
   },
   {
    "item": "Thm 4.5: novelty claim (Section 7 'small new piece')",
    "severity": "minor",
    "description": "This is not new. In belief-state semantics c |= j:phi is a box over c_j. The LMS bridge is box_j(phi) -> box_i(psi), and the world reading is phi -> psi. Thm 4.5(b) is the classical failure of box to distribute over disjunction: box(p or q) does not entail box p or box q. Equivalently, it is the classical gap between a rule of proof and the corresponding implication (global vs local consequence; derivable rule vs axiom), and it is the reason Ghidini & Giunchiglia use sets of local models.",
    "evidence": "Section 7 lists 'Thm 4.5: belief-state versus world-family semantics for contexts' among the new pieces.",
    "suggested_fix": "Present Thm 4.5 as the context-logic instance of the global/local (rule vs conditional) distinction and cite it as standard."
   },
   {
    "item": "Thm 4.6 (local-to-global on trees)",
    "severity": "ok",
    "description": "Correct. The projection lemma (using compactness and consistency of T) is right. The BFS invariant is right: the visited set is a subtree containing p, and running intersection forces every already-assigned atom of A_c into A_p. Edge conservativity is equivalent to equal projections. This is essentially the propositional, iterated Robinson-joint-consistency / join-tree (BFMY) argument. No novelty is claimed.",
    "evidence": "Independent test: 2,656 random tree covers with 2-5 nodes, random running-intersection atom placement and random edge-conservative local theories. There were 0 failures of 'every local model extends to a global model'. Negative control: when atoms are placed without running intersection (edges still conservative), 170 of 3,594 systems are globally inconsistent, so the hypothesis matters.",
    "suggested_fix": "None for the theorem. Minor: Section 10 and the theorem tag say '7,131 random tree systems', but contexts_local_global.py (a) uses one fixed 3-node path cover with random local theories. The description should say so."
   },
   {
    "item": "Prop 4.7 (frustrated triangle) and the Vorob'ev / Beeri et al. citation",
    "severity": "ok",
    "description": "Each theory is consistent. Each projection onto the shared atom is a tautology. The union is an odd negation cycle and so is inconsistent. The probabilistic version is LP-infeasible. The citation claim (acyclicity is exactly what rules this out) also holds with Boolean atoms, not only in the relational setting with large domains.",
    "evidence": "The script re-run gives no global models and LP infeasibility. My brute force on the non-acyclic 4-atom cover {abc, abd, acd, bcd} finds a pairwise-consistent Boolean system with no global model: 'exactly one true' on each triple.",
    "suggested_fix": "None."
   },
   {
    "item": "Def 4.8 ('true enough in c')",
    "severity": "minor",
    "description": "As written, phi is 'true enough in c for epsilon' iff the system contains a sound bridge c:phi => @:epsilon. The definition never requires that context c actually establishes phi.",
    "evidence": "If Gamma derives c:not phi, phi still counts as 'true enough' for epsilon whenever such a sound bridge exists.",
    "suggested_fix": "Add 'Gamma derives c:phi in MC, and the side conditions hold (or are derivable) at @'."
   },
   {
    "item": "Thm 5.1 (a),(b),(c)",
    "severity": "ok",
    "description": "Correct. (a) is Thm 1.5(a) with sigma = bot. (b) uses structurality: sigma(phi) is in C_R(sigma Gamma), which is contained in C_R(T) = T. (c) is Thm 2.2 plus Thm 2.6(b) for the structural Scott relation generated by R. Note that (b) does not need the maximality from (a): C_R(A) itself already gives a matrix model.",
    "evidence": "Checked line by line.",
    "suggested_fix": "Optionally note that (b) holds for any C_R-theory containing A and omitting bot."
   },
   {
    "item": "Thm 5.2 (a),(b) and existence of the Leibniz congruence",
    "severity": "ok",
    "description": "Correct. Joins of D-compatible congruences are compatible, using finite chains in the transitive closure. The claim Omega(h^{-1}D) = h^{-1}(Omega_A D) is proved soundly: ker h is compatible, the image of the join is a congruence by surjectivity, and transitivity uses that ker h is contained in the join. (b) uses the fact that v onto 2 needs at least one atom. This is the standard result that the Leibniz operator commutes with inverse surjective homomorphisms (Blok-Pigozzi, Font), and Section 7 correctly lists it as standard.",
    "evidence": "Independent test of (a) on 400 random finite algebras (one binary and one unary operation, up to 6 elements), each with a random quotient map h and 4 random D: 1,600 tests, 0 mismatching pairs.",
    "suggested_fix": "None."
   },
   {
    "item": "Section 0 summary of Thm 5.2 ('after Leibniz reduction it is the intended model iff the point is the theory of an intended valuation')",
    "severity": "minor",
    "description": "The 'iff' needs the valuation to be generating (surjective), as Thm 5.2(a) assumes. Without that, the reduction is the reduction of the generated submatrix. In particular it never equals an uncountable intended algebra, because the language is countable.",
    "evidence": "Take the intended matrix <H_4,{1}> (chain 0<a<b<1), a one-atom language and h(p)=a. Then h(Fm)={0,a,1} is isomorphic to H_3, so the reduced Lindenbaum matrix of h^{-1}(1) is <H_3,{1}>, not <H_4,{1}>, although the theory is the theory of an intended valuation. Likewise for the standard MV-algebra [0,1] or any uncountable intended algebra.",
    "suggested_fix": "Say 'iff the point is the theory of a generating intended valuation; in general one gets the reduction of the generated submatrix (Prop 5.3)'."
   },
   {
    "item": "Prop 5.3 and the reading paragraph after it",
    "severity": "minor",
    "description": "The proposition and its proof are correct: matrix consequence equals Th Mod, it is finitary by citation, Thm 1.5(b) applies, and Thm 5.2(a) is applied to h onto its image. There are two wording problems. First, 'it is a reduced generated submatrix' should be 'the reduction of a generated submatrix' (a strict homomorphic image of a submatrix, not necessarily a submatrix). Second, the next paragraph says 'For learned calculi that are not Post-complete, distinct coherent completions talk about non-isomorphic things', and calls the CPC fact 'the semantic face of Post-completeness'. Read as a general claim, this is false.",
    "evidence": "IPC is not Post-complete, since CPC is a proper consistent structural extension. Yet by Prop 1.6 every maximal IPC-consistent theory is a maximal CPC theory, which reduces to <2,{1}> by Thm 5.2(b). So all coherent completions of IPC talk about 2, and only non-maximal points differ (Ex 5.4). So the CPC fact comes from 'every point is maximal and maximal theories are Boolean', not from Post-completeness.",
    "suggested_fix": "Replace 'reduced generated submatrix' with 'reduction of a generated submatrix'. Change the sentence to 'a calculus can have points that talk about non-isomorphic things (Ex 5.4)', and tie level P3 to points rather than to Post-completeness."
   },
   {
    "item": "Ex 5.4 (H_3 point of IPC; quantifier swap)",
    "severity": "ok",
    "description": "Verified. h(p)=1/2 is onto H_3. T=h^{-1}(1) is prime and not maximal: collapsing the filter {1/2,1} gives a Boolean valuation extending T plus p. <H_3,{1}> is reduced, since its only nontrivial congruences collapse {1/2,1} or everything. T is maximal among theories omitting p, by the case split on h(psi) in {1/2, 0}. The quantifier-swap claim needs FOL with equality, which T2 Section 6 uses via R:=(x=y).",
    "evidence": "Direct computation in H_3; T2 lines 796-801.",
    "suggested_fix": "Optionally say 'FOL with equality' explicitly."
   },
   {
    "item": "Thm 5.5 (prime models of complete T extending PA)",
    "severity": "ok",
    "description": "Correct and standard. Definable Skolem functions plus Tarski-Vaught give K(T) as an elementary submodel. It is prime, and unique because definable elements correspond across elementarily equivalent models. K(Th(N))=N. If T contains not Con(PA), the least proof code is a definable nonstandard element, because T proves each true Delta_0 sentence not Prf(n, 0=1).",
    "evidence": "Standard (Kaye 1991, chapter on definable elements); the citation flag is appropriate.",
    "suggested_fix": "Wording only: 'T refutes each standard instance because their negations are true Delta_0 sentences provable in Q'."
   },
   {
    "item": "Section 5.4 layer (i): 'PA + not Con(PA) is Pi_1-sound'",
    "severity": "ok",
    "description": "Correct. If PA + not Con(PA) proves a Pi_1 sentence pi, then PA + not pi proves Con(PA). Formalized Sigma_1-completeness gives Prov(not pi), hence Con(PA + not pi). Goedel II then gives PA proves pi, so pi is true.",
    "evidence": "Argument verified.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 5.6 (compactness / Loewenheim-Skolem-Tarski barrier)",
    "severity": "ok",
    "description": "Correctly stated: a theory with an infinite model has models of every infinite cardinality at least |L| (plus aleph_0). Hence no first-order theory is categorical for an infinite structure. The accompanying claim that finite structures in a finite language are characterized by a single sentence is correct (with equality).",
    "evidence": "Standard.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 5.7 (computability barrier) (a)-(d)",
    "severity": "minor",
    "description": "The statement and the one-line proof are correct. If incoherence is r.e. and equals 'no K-model', then having a K-model is co-r.e. Parts (a) (Tarski), (b) (MRDP; Sigma_1-complete over Z) and (d) are right. Two minor points. (c) needs a vocabulary with at least one binary relation symbol (Trakhtenbrot); for purely monadic vocabularies finite satisfiability is decidable, so there is no barrier. Section 7 calls Thm 5.7 a 'small new piece', but it is the textbook argument: a complete r.e. calculus makes semantic consequence r.e. That argument is behind 'no complete r.e. axiomatization of Th(N)', 'no complete proof system for finite validity' and 'no complete calculus for full second-order logic'.",
    "evidence": "Trakhtenbrot 1950 assumes a binary relation symbol. Monadic first-order logic has the finite model property and is decidable.",
    "suggested_fix": "Add 'in a vocabulary containing a binary relation symbol' to (c). In Section 7, recast Thm 5.7 as a standard observation, newly applied here."
   },
   {
    "item": "Prop 5.8 (Beth) and its reading",
    "severity": "minor",
    "description": "The formal statement is correct. Joint pinning is equivalent to each symbol being implicitly defined, and Beth applies symbol by symbol. The reading goes further than the result. 'World-anchoring (fixing the world's interpretation of the hooked vocabulary) determines the rest iff the rest is definable', and 'non-definable terms stay multiply realizable', are false for anchoring to one actual L_o-structure. Beth quantifies over all pairs of models of T. For a fixed anchoring structure, the relevant results are Svenonius / Chang-Makkai type, which are about definability with parameters in that structure.",
    "evidence": "Counterexample: L_o={<}, W=(N,<), T={exists x R(x); forall x,y (R(x) and y<x -> R(y)); forall x (R(x) -> exists y (x<y and R(y)))}. Over W the only expansion is R=N, so anchoring pins R. Over (omega+omega,<), both R=omega and R=everything satisfy T, so R is not T-definable from <. A trivial variant: T = {exists! x R(x)} over a one-element world.",
    "suggested_fix": "Say 'anchoring pins L uniformly, over every possible anchoring, iff L is T-definable from L_o'. Then add that pinning over the actual anchoring can hold without definability."
   },
   {
    "item": "Section 5.5 pins (second-order induction, initiality, Tennenbaum, omega-rule, computation)",
    "severity": "ok",
    "description": "These claims are consistent with the literature. Second-order PA with full semantics is categorical. N is the least initial segment of every model of PA. By Tennenbaum, N is the unique computable model of PA. Shepherdson's computable nonstandard model of open induction is correctly cited. Every consistent extension of Q agrees with the true Delta_0 facts.",
    "evidence": "Light check against standard results.",
    "suggested_fix": "None."
   },
   {
    "item": "run_all.sh re-run",
    "severity": "ok",
    "description": "All seven scripts ran to completion in about 1 minute 39 seconds. Their outputs match the Section 10 table, including 0 MC mismatches, 2,348 W/LMS gaps, 7,131 tree systems (on one fixed path cover), the frustrated triangle with no global model or distribution, and multiplicities m=2 for k=3 and m=3 for k=4.",
    "evidence": "Console output reproduced; see the Thm 4.5 and Thm 4.6 entries for the two places where the script descriptions are slightly stronger than what the scripts test.",
    "suggested_fix": "None beyond the description fix noted under Thm 4.6."
   }
  ],
  "overall": "I found no fatal or major defects in Sections 4-5. Every theorem and proposition in scope is true as stated, and its proof is complete: Thm 4.1, Cor 4.2, Prop 4.3, Prop 4.4, Thm 4.5, Thm 4.6, Prop 4.7, Thm 5.1, Thm 5.2, Prop 5.3, Ex 5.4, Thm 5.5, Thm 5.6, Thm 5.7 and Prop 5.8. Many are standard or 'trivial once set up', as the file mostly admits.\n\nRe-running run_all.sh reproduces every result in the Section 10 table.\n\nMy independent brute-force checks found no counterexamples. Prop 4.3: least-equilibrium and D-consistency on 300 random context systems. Thm 4.5(a): the direction of the gap. Thm 4.6: 2,656 random tree covers, plus a negative control showing that running intersection is needed. Thm 5.2(a): Leibniz commutation on 1,600 random finite-algebra quotients. Beeri et al.: a Boolean counterexample on a non-acyclic cover.\n\nThe issues are all minor:\n(1) Cor 4.2 does not apply to the advertised 'learned logic with Lindenbaum semantics'. That semantics has no falsum with an empty model class, and with a non-explosive bot, derivability of bot and emptiness of the belief state come apart.\n(2) The Section 0 and Section 6 summaries drop 'nonempty on D'.\n(3) Def 4.8 never requires that c establishes phi.\n(4) The L7 remark pairs soundness and completeness results for different semantics.\n(5) The Section 0 gloss of Thm 5.2 needs a surjective (generating) valuation. Counterexample: H_4 with h(p)=a.\n(6) Prop 5.3 has a wording slip, and the sentence after it ('not Post-complete implies completions about non-isomorphic things') is refuted by IPC.\n(7) Thm 5.7(c) needs a binary relation symbol.\n(8) The reading of Prop 5.8 overreaches. Pinning over the actual anchoring structure does not require definability; see the (N,<) counterexample.\n(9) The novelty claims for Thm 4.5 (it is the failure of box to distribute over disjunction) and Thm 5.7 (it is the standard 'complete r.e. calculus implies r.e. consequence' argument) are overstated.\n(10) The Thm 4.6 script tests one fixed path cover, not random trees."
 }
]
```

---

## Author-repairer's log

The log below is identical to the "Verification log" section appended to the theory file.

### Verification log (as appended to the theory file)

Two independent adversarial referees checked this file. Referee A covered §§0–3, and Referee B covered §§4–5 together with the §0, §6 and §7 claims about them. Their full reports are reproduced in `verification/T6-verification.md`. I re-checked every reported issue myself, using computation where useful. Severity tags are the referees' own.

**Re-checks run.**
* `run_all.sh`, which re-runs all T6 scripts. Every number quoted in the file reproduces.
* New script `T6-checks/repair_checks.py`:
  * (A) the referee's counterexample to Thm 1.5(c) without soundness; 1,602 random sound finite frames with 0 failures of 1.5(b) or 1.5(c); 2,949 unsound frames with 0 failures of Prop 1.3 and 258 failures of 1.5(c), confirming that soundness is needed;
  * (B) the Lindenbaum semantics for Def 4.0: 3,000 random closure systems with an explosive falsum, 0 violations, plus the non-explosive counterexample;
  * (C) an exact MILP for Thm 3.5 with $k=3,4,5$;
  * (D) the $\mathbf H_4$ example for the §0 gloss of Thm 5.2.
* New part (a2) of `contexts_local_global.py`: 2,000 random tree covers with running intersection, with 0 failures. The negative control without running intersection has 437 failures out of 2,000.
* `counting_sequents.py`: the docstring is corrected (Thm 3.1, complementary pairs). The output is unchanged: 215/215.
* Literature check for Cor 3.9. Search snippets confirm Garrabrant et al.'s definition of a market as a *computable* sequence of pricings (Def 3.1.3), Limit Coherence (Thm 4.1.2) and Non-Dogmatism (Thm 4.6.2). The full text was not reachable (arXiv and intelligence.org are blocked by the egress proxy), so the numbering stays (u).

**Outcome in brief.**
* No issue was labelled fatal or major, and I found none.
* Every minor issue was genuine and has been fixed, or the claim has been weakened or recast. No issue was rejected.
* The substantive repairs are:
  * the soundness hypothesis in Thm 1.5(c);
  * the restated hypothesis of Thm 3.1;
  * a revised proof of Cor 3.9, now with two independent arguments and an explicit computability premise, and the qualified "no limit-computable credence" sentence;
  * the Lindenbaum semantics in Def 4.0, with the non-triviality reading of Cor 4.2;
  * Def 4.8, which now requires that $c$ establishes φ;
  * the retracted Post-completeness sentence after Prop 5.3;
  * the vocabulary hypothesis in Thm 5.7(c);
  * the reading of Prop 5.8 (uniform versus actual anchoring);
  * the novelty claims in §7 for Thms 3.8, 4.5 and 5.7, which are now classed as standard arguments, newly applied.

#### Referee A (§§0–3)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | Prop 1.3 (soundness unused) | ok | n/a | **Clarified.** A note says that the proof does not use soundness [checked: `repair_checks.py` (A), 0 failures on 2,949 unsound frames]. |
| A2 | Thm 1.4 | ok | n/a | No change. |
| A3 | Thm 1.5(c) needs soundness | minor | **yes** | **Fixed (hypothesis added; marked "revised after verification").**<br>• (c) now assumes $C$ sound. The proof of (⇒) says where soundness is used ("$\mathrm{Th}(\{m\})$ is closed *by soundness*").<br>• The referee's 3-sentence counterexample is included in the statement and reproduced by `repair_checks.py` (A).<br>• Random tests: 0 failures with soundness; 258/2,949 failures of (c) without it.<br>• Prop 1.6 already proves soundness before applying (c), so it is unaffected. |
| A4 | Prop 1.6 | ok | n/a | **Clarified.** Glivenko's theorem is added as a one-line alternative for weak completeness. |
| A5 | Prop 1.6 Reading (garbled proof-by-cases sentence) | minor | yes | **Fixed.** The argument is written out: maximal omitting φ, neither ψ nor ¬ψ in $T$ ⇒ φ ∈ C(T,ψ) ∩ C(T,¬ψ) = T, contradiction ⇒ complete ⇒ maximal consistent. |
| A6 | §0 item 1 ("complete for its own points (Thm 1.4)") | minor | yes | **Fixed.** §0 now reads "strongly complete for its own closed theories (Thm 1.4; no Zorn) and, if finitary, for its own points (Thm 1.5(a))". |
| A7 | Thm 2.2 / Cor 2.3 | ok | n/a | No change. |
| A8 | Thm 2.4 | ok | n/a | **Clarified.** The tag credits the compact-relation/closed-class correspondence to Scott 1974 and Shoesmith–Smiley 1978 as standard. |
| A9 | Rem 2.5 (Suszko holds for all Tarskian consequences) | ok | n/a | **Clarified.** The text now says "every Tarskian consequence, structural or not", and notes that Suszko stated it for structural logics. |
| A10 | Thm 2.6 | ok | n/a | No change. |
| A11 | Thm 3.1 ("closed under negation" impossible for finite $F$) | minor | yes | **Fixed (hypothesis restated).**<br>• $F$ is now a finite union of complementary pairs $\{\varphi,\varphi^\*\}$ with $\varphi^\*\equiv\neg\varphi$, and $P(\varphi^\*)=1-P(\varphi)$.<br>• The proof of (iv)⇒(iii) and the $m=1$ sequent definition use $\varphi^\*$.<br>• A note records that negation coherence is needed: $P\equiv1$ satisfies every valid counting sequent but is incoherent.<br>• The docstring of `counting_sequents.py` is corrected ("Thm 3.2" → "Thm 3.1"; complementary pairs). |
| A12 | Prop 3.2 / Ex 3.3 | ok | n/a | No change. |
| A13 | Thm 3.4 | ok | n/a | No change. |
| A14 | Thm 3.5 ("multiplicity" is really the threshold; "needs the full family" overstated) | minor | yes | **Fixed (wording; mathematics unchanged).**<br>• $m$ is now called the **threshold**. A terminology note says that the violated sequent of (a) repeats no formula.<br>• A *Scope* paragraph says that any single finite agenda is characterized by its finitely many facets, and that Thms 3.4–3.5 rule out only *uniform* bounds across agendas.<br>• §0, §3.2 ("Exact answer"), §7, §8 and §10 are updated to match.<br>• New exact MILP check (`repair_checks.py` (C), multiplicities in $[0,8]$): the minimum of $\sum_\Phi P_k-m$ is 0 for $m\le k-2$ and $-\frac1{k-1}$ for $m\le k-1$ ($k=3,4,5$), attained by the repetition-free sequent of (a). This reproduces the referee's MILP. |
| A15 | Prop 3.6 | ok | n/a | No change. |
| A16 | Thm 3.7 | ok | n/a | No change. |
| A17 | Thm 3.8 (attribution to Gaifman 1964) | minor | yes | **Fixed.** The tag now credits Gaifman 1964: a Gaifman measure is determined by its quantifier-free restriction (exact formulation (u)). §7 moves Thm 3.8 from "new" to "standard". |
| A18 | Cor 3.9 (silent computability premise; overstated sentence after it) | minor | yes | **Fixed (proof revised; sentence qualified).**<br>• The Δ₂ argument now states its premise: a market is a computable sequence of rational pricings (Garrabrant et al. Def 3.1.3, confirmed by search snippet).<br>• The referee's more robust second proof is added. Gödel–Rosser gives an independent sentence, and the false one, ψ, gets $\mathbb P_\infty(\psi)>0$ by Non-Dogmatism (Thm 4.6.2), so $\mathbb P_\infty\neq\delta_{\mathrm{Th}(\mathbb N)}$.<br>• A general remark is proved: no limit-computable coherent credence giving 1 to all true QF sentences satisfies the Gaifman condition. The referee's one-element-structure example shows that the QF hypothesis is needed.<br>• The "no computable or limit-computable credence" sentence and §5.5 item 4 are qualified accordingly. |
| A19 | Prop 3.10 ("money pump" gloss) | minor | yes | **Fixed.** §0, the §6 table and the Reading now say "no derivation of $L\succ L$ by mixing + transitivity (money-pump-like)", and flag "money pump" as an interpretive gloss. |

#### Referee B (§§4–5)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Thm 4.1 | ok | n/a | No change. |
| B2 | Cor 4.2 (statement) | ok | n/a | No change to the statement. See B3 and B4. |
| B3 | Def 4.0 / Cor 4.2 applied to learned logics with Lindenbaum semantics | minor | **yes** | **Fixed (Def 4.0 revised; remark added).**<br>• Def 4.0 now specifies Lindenbaum semantics as $M_i=\mathrm{Fix}(C_i)\setminus\{L_i\}$ (proper closed theories), shows $\mathrm{Th}_i\circ\mathrm{Mod}_i=C_i$, and says that Thm 1.4's full frame does not qualify, because the trivial theory satisfies everything.<br>• The falsum condition becomes "$\bot_i$ is $C_i$-explosive".<br>• A remark after Cor 4.2 proves the falsum-free version: $T_i\neq L_i$ iff $c^\Gamma_i\neq\emptyset$. So for learned logics, D-coherence should be read as non-triviality. It includes the referee's non-explosive counterexample ($R=\emptyset$, $K_i=\{\bot_i\}$).<br>• [checked: `repair_checks.py` (B), 3,000 random systems, 0 violations] |
| B4 | §0 / §6 summaries drop "nonempty on D" | minor | yes | **Fixed.** §0 item 4, the §6 table, the §4.3 Reading and the §6 C-models paragraph now say "nonempty at every designated context", and note that suppositional contexts may be forced empty. |
| B5 | Prop 4.3 | ok | n/a | No change. |
| B6 | Prop 4.4 ("context i alone is coherent"; "must come from stratification") | minor | yes | **Fixed (wording).** "$K_i$ is consistent (the context is coherent without its bridge)". Existence "needs an extra condition, such as stratification or the absence of odd loops through negation as failure … stratification is sufficient, not necessary". |
| B7 | Remark relating MC to L7's calculus | minor | yes | **Fixed (rewritten; [sketch]).**<br>• Thm 4.1 is now described as completeness for LMS *with bridges as compatibility constraints*. L7 §8.2's semantics keeps $\mathrm{Mod}(@)$ fixed and asks bridges to be sound.<br>• The two coincide when the local logic is the complete base logic and every Step/Exp instance is sound. Proof sketch: ⊆ by L7 Prop 1; ⊇ by induction down the tree.<br>• The referee's unsound-export example shows that they differ otherwise.<br>• The SUP identity is kept. |
| B8 | Thm 4.5 ((c) omits tagged $K_i$ and Γ) | ok | yes (small) | **Fixed.** (c) and its proof now include the tagged $K_i^{(i)}$ and the tagged premises Γ. |
| B9 | Thm 4.5 novelty claim | minor | yes | **Fixed.** A *Status* note after the proof, and §7, present Thm 4.5 as the context-logic instance of rule-of-proof versus conditional (global/local consequence; □(p∨q) ⊭ □p∨□q). It is listed under "standard arguments, newly applied". |
| B10 | Thm 4.6 (script description) | ok | yes (description) | **Fixed.**<br>• The theorem tag and the §10 table now say that (a) uses one fixed 3-node path cover.<br>• New part (a2) tests 2,000 random tree covers with 2–5 nodes and random running-intersection placement: 0 failures. A negative control without running intersection gives 437/2,000 failures.<br>• The tag credits the join-tree/Robinson-consistency argument (Beeri et al. 1983). |
| B11 | Prop 4.7 and the Vorob'ev/BFMY citation | ok | n/a | No change. |
| B12 | Def 4.8 ("true enough" does not require $c$ to establish φ) | minor | yes | **Fixed (definition revised).** It now requires (i) $\Gamma\vdash_{\rm MC}c{:}\varphi$, (ii) the bridge's side conditions hold at @ ($\Gamma\vdash_{\rm MC}@{:}\sigma$ for a checker), and (iii) bridge soundness. |
| B13 | Thm 5.1 | ok | n/a | **Clarified.** A note says that (b) holds for any $C_R$-theory $\supseteq A$ omitting ⊥. |
| B14 | Thm 5.2 | ok | n/a | No change. |
| B15 | §0 gloss of Thm 5.2 (needs a generating valuation) | minor | yes | **Fixed.** §0 now says "a *generating* (surjective) intended valuation; in general the reduction of the generated submatrix". The referee's example is reproduced in `repair_checks.py` (D): $h(p)=a$ in $\mathbf H_4$ generates $\{0,a,1\}\cong\mathbf H_3$, which is reduced. |
| B16 | Prop 5.3 wording; the "not Post-complete ⇒ non-isomorphic completions" sentence | minor | yes | **Fixed (wording corrected; sentence retracted and replaced).**<br>• "Reduced generated submatrix" → "the reduction of a generated submatrix (a strict homomorphic image of a submatrix)".<br>• The Post-completeness sentence is retracted, using the IPC counterexample: IPC is not Post-complete, yet all its maximal theories reduce to **2** (Prop 1.6).<br>• The CPC fact is re-derived from "every point is maximal, and maximal theories are Boolean". The non-isomorphism is located in non-maximal points (Ex 5.4), and P3 is tied to points. |
| B17 | Ex 5.4 | ok | n/a | **Clarified.** "FOL with equality". |
| B18 | Thm 5.5 | ok | n/a | **Clarified.** The wording is now: "its negation is a true Δ₀ sentence, hence provable in Q ⊆ T". |
| B19 | §5.4 layer (i) | ok | n/a | No change. |
| B20 | Thm 5.6 | ok | n/a | No change. |
| B21 | Thm 5.7 ((c) needs a binary relation symbol; novelty) | minor | yes | **Fixed.**<br>• (c) now assumes a vocabulary with at least one binary relation symbol, and notes that the monadic case is decidable. The Reading and §0 are updated.<br>• The tag and §7 recast Thm 5.7 as the textbook argument ("a complete r.e. calculus makes semantic consequence r.e."), newly applied. |
| B22 | Prop 5.8 reading (actual vs uniform anchoring) | minor | yes | **Fixed (reading revised).**<br>• Beth is now read as pinning *uniformly over all anchorings* iff definable.<br>• The referee's $(\mathbb N,<)$ vs $\omega+\omega$ counterexample and the one-element variant are included, together with a pointer to Svenonius / Chang–Makkai for fixed structures [cited (u)].<br>• §0 and §6 are updated. |
| B23 | §5.5 pins | ok | n/a | No change, except item 4, which is qualified as in A18. |
| B24 | `run_all.sh` | ok | n/a | No change to the earlier scripts' outputs. `repair_checks.py` is added to `run_all.sh`. |
