# Verification record: T2-coherence-as-negative-data

*Target file: `research/theory/T2-coherence-as-negative-data.md`. Three independent adversarial referees checked the file: Referee A for §2, Referee B for §3, Referee C for §4–7. Their reports are reproduced verbatim below as JSON, followed by the author-repairer's log. The same log is appended to the theory file. Repair checks: `research/theory/T2-checks/repair_checks.py`; the added denial-rank check is in `research/theory/T2-checks/carnap_check.py`.*

**Outcome in brief.**
* One fatal issue: the last sentence of Thm 4.4(d) was false. It has been retracted and replaced by a proved non-identifiability statement.
* Three major issues, all genuine:
  * Cor 2.8 needs fixed designations. New Prop 2.8′ covers target-dependent designations.
  * The bold-versus-cautious moral was unsupported. New Prop 2.9(d),(e); §2.6, §0, §8 and §9 are rewritten.
  * Prop 3.11 holds at theorem level only. New (b): ∃-closure suffices at rule level. New (c): RCF counterexamples without it.
* All minor issues were genuine and have been fixed. No issue was rejected.

---

## Referee reports (verbatim JSON)

```json
[
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T2-coherence-as-negative-data.md",
  "items_checked": [
   "Lemma 2.1 (negative bag)",
   "Theorem 2.2 (oligarchic halving), including Remarks (a)-(c)",
   "Proposition 2.3 (halving forces oligarchy)",
   "Theorem 2.4 (doctrinal paradox) and the literature paragraph after it",
   "Theorem 2.5 (robust version, mis-designated contexts)",
   "Theorem 2.6 (silent over-generalizations)",
   "Proposition 2.7 (coherent chains have coherent unions)",
   "Corollary 2.8 (coherence does not cure superfiniteness) and the closing paragraph of §2.5",
   "Proposition 2.9 (cautious learners) and the closing paragraph of §2.6",
   "Section 0 summary items 1-2 insofar as they restate §2 results; §9 open problem 1 insofar as it cites Prop 2.9",
   "Check scripts in theory/T2-checks/: none of carnap_check.py, fallacy_check.py, matrix_check.py concerns §2. I wrote new brute-force checks in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/t2s2/ (tt.py, p29.py, oh.py, oh2.py, wm.py, cor28.py)"
  ],
  "issues": [
   {
    "item": "Lemma 2.1 (negative bag)",
    "severity": "minor",
    "description": "Bullets 1 and 2 and the proof are correct. Bullet 3 ('for consequence-relation hypotheses, the refuted set is {h: A ⊢_h ⊥}, independent of π') uses a different notion of 'refuted' from bullet 2. Bullet 2 means 'deleted by the witness π' (the protocol of Thm 2.2 deletes R ⊇ Steps(π)). Bullet 3 means 'logically excluded by the designation A ⊬* ⊥'. Under one consistent notion the claimed asymmetry disappears. Logically, the designation excludes {R: A ⊢_{Der R} ⊥} for step sets as well, independent of π. Under witness-deletion, the set deleted for consequence relations is {h: Steps(π) ⊆ h}, which depends on π and can be a strict subset of {h: A ⊢_h ⊥}.",
    "evidence": "Take target CPC, A={p} (CPC-coherent), and π with steps p▷q (invalid) and q▷⊥. Let h be the least consequence relation containing p▷⊥, with no explosion. Then A ⊢_h ⊥, but p▷q ∉ h (h has no ⊥▷q) and q▷⊥ ∉ h. So h is in {h: A⊢_h⊥} but not in {h: Steps(π)⊆h}: the set the witness deletes depends on π. The bag 'collapses to a negative example A▷⊥' only if the learner tests A▷⊥ ∈ h directly. In that case π is unnecessary, and the information was already in the designation (cf. Prop 2.9(c)).",
    "suggested_fix": "Say explicitly that bullet 3 concerns a learner that tests A▷⊥ ∈ h by membership. Say that in both guises the designation logically excludes {h: A ⊢_h ⊥}, and that π matters only as a witness, i.e. computationally."
   },
   {
    "item": "Theorem 2.2 (oligarchic halving)",
    "severity": "ok",
    "description": "(i)-(iv) are correct as stated. The proof is complete. The bound needs w(R*)>0 (implicit: otherwise the bound is +∞ and is trivially true, and S_t is non-empty whenever w(VS_t)>0). (This is the classical halving / weighted-halving argument, Barzdin–Freivalds, Littlestone 1988, with one-sided intersection prediction. It is correctly presented as an adaptation, not as new.) Remark (a)'s claim that 'boldest half' gives a 'completeness-seeking reasoner' is misleading; see the separate major issue on §2.6.",
    "evidence": "Exhaustive minimax (oh2.py) over 1173 (class, target) instances. Step universes have ≤4 steps, classes ≤6 hypotheses, weights random. The adversary chooses any legal OH coalition and any detection P ⊆ R̂ with P ⊄ R*. The maximum number of detections never exceeds log2(1/w(R*)); the bound was attained (floor) in 452 cases.",
    "suggested_fix": "State w(R*)>0 explicitly. State in the theorem, not only in Remark (c), that the bound concerns (N)-rounds only and says nothing about incompleteness (P-round) errors."
   },
   {
    "item": "Proposition 2.3 (halving forces oligarchy)",
    "severity": "minor",
    "description": "The equivalence and its proof are correct (exhaustive check: 0 mismatches in 3000 random instances). Three problems. (1) §0 item 1 claims 'Oligarchy is necessary for such a guarantee', but Prop 2.3 characterizes per-round halving under a worst-case adversary, not a logarithmic detection bound. (2) The worst-case hypothesis 'any finite P ⊆ R̂ can occur as Steps(π)' also covers P ⊆ ∩VS. Such detections would delete every hypothesis including the target, contradicting Lemma 2.1; the hypothesis is stronger than needed. (3) The restriction to finite VS is unnecessary.",
    "evidence": "(1) A learner whose coalitions have weight ≥1/3 gets D ≤ log_{3/2}(1/w*), still logarithmic, without halving. A learner that is non-oligarchic in finitely many rounds gets log2(1/w*)+const. So the necessity is per-round only. (2) The proof uses only P_0. If P_0≠∅ then P_0 ⊄ ∩VS; if P_0=∅ then S=VS directly. (3) For countable VS and countable R̂, enumerate R̂={s_1,s_2,...}, let P_k={s_1..s_k} and S_k={R⊇P_k}. Then ∩_k S_k={R⊇R̂}, and by σ-additivity w({R⊇R̂}) = lim w(S_k) ≥ ½w(VS).",
    "suggested_fix": "Rephrase §0 as 'oligarchy is necessary for guaranteed per-round halving'. Restrict the worst-case hypothesis to P with P ⊄ ∩VS. Optionally drop finiteness of VS, using the σ-additivity argument above."
   },
   {
    "item": "Theorem 2.4 (doctrinal paradox)",
    "severity": "minor",
    "description": "All memberships and the conclusion are correct (verified by truth tables in tt.py: ▷p ∈ h1,h2; ▷q ∈ h1,h3; ▷¬(p∧q) ∈ h2,h3; the other two steps are in all three; every h_i is coherent). Two precision gaps. (a) R̂_maj is defined over the fixed H ('at least two i') but must be majority over the current VS. (b) 'No hypothesis is ever deleted' holds only for environments that withhold discriminating positive data. That is allowed in the adversarial online protocol, but §0's 'can produce incoherence forever while learning nothing' should say so.",
    "evidence": "If the target is h1 and the environment presents the valid datum ▷p, then h3 is deleted. Majority over VS={h1,h2} is h1∩h2, which is oligarchic, and π is no longer available (▷q ∉ h2). With any complete text the majority learner converges and the incoherences stop.",
    "suggested_fix": "Define majority relative to VS_t. State the claim as 'there is an environment (presenting only π, or only uninformative positive data such as tautologies) under which...'."
   },
   {
    "item": "Theorem 2.4: literature paragraph",
    "severity": "minor",
    "description": "The attributions are broadly right: Kornhauser & Sager 1986 'Unpacking the Court' (Yale LJ); Pettit 2001 discursive dilemma; List & Pettit 2002 (Econ. & Phil.). The List–Pettit impossibility is paraphrased without its conditions (universal domain, anonymity, systematicity, plus agenda richness). For oligarchy characterizations via deductive closure without completeness, the earliest result I recall is Gärdenfors (2006, 'A representation theorem for voting with logical consequences', Econ. & Phil.). Dietrich & List (2008, 'Judgment aggregation without full rationality', SCW) is right. I cannot confirm that Nehring & Puppe is the right source for this specific characterization (uncertain). Dokow & Holzman (2010, abstentions) is also relevant. The file already flags these as unverified.",
    "evidence": "Comparison with standard judgment-aggregation literature, from memory; marked uncertain where noted.",
    "suggested_fix": "Add the List–Pettit conditions. Cite Gärdenfors 2006 and Dietrich & List 2008 for oligarchy under deductive closure. Keep or check the Nehring & Puppe attribution."
   },
   {
    "item": "Theorem 2.5 (robust version)",
    "severity": "ok",
    "description": "Correct. Each (N)-round penalizes ⊇S_t, so W_{t+1} ≤ ((1+β)/2)W_t. R* is penalized only in false alarms. Rearranging gives the bound. This is exactly the Littlestone–Warmuth (1994) weighted-majority mistake bound; the only new ingredient is the bag→coalition reduction from Thm 2.2. Small precision points: R̂_t = ∩S_t is implicit; the treatment of (P)-rounds in the robust protocol is unstated (deletion is fine if positive data are noise-free); for β=0, m=0 the formula needs the convention 0·ln(1/0)=0.",
    "evidence": "Random simulation (wm.py): 20000 runs with β ∈ {0,0.1,0.3,0.5,0.9}, a 15% false-alarm rate, adversarial-random detections P ⊆ R̂ (P ⊄ R* unless false alarm), and random coalitions of ≥ half weight. 0 violations.",
    "suggested_fix": "State R̂_t=∩S_t and the (P)-round rule. Note the 0·∞ convention. Cite LW94 for the bound itself."
   },
   {
    "item": "Theorem 2.6 (silent over-generalizations)",
    "severity": "ok",
    "description": "(i)-(iii) are correct and the proof is complete. h⊕⊢* is the directed union of the h⊕D, since cut involves finitely many sequents, which lie in a common h⊕D. If ⊢*⊆h then h⊕D=h. (iii) holds because 𝒜 is h-coherent for h∈U. (iii) also remains true if designations are target-dependent, since a finite stage of ⊢*'s stream uses only contexts that are h-coherent.",
    "evidence": "Line-by-line check; no counterexample possible, since every step is definitional.",
    "suggested_fix": "None needed. Optionally replace 'refuted' by the static properties actually defined, since 'refuted' depends on the learner deciding membership in h."
   },
   {
    "item": "Proposition 2.7 (coherent chains)",
    "severity": "ok",
    "description": "Correct. Any finite set of sequents of h_ω lies in one h_n, so cut, reflexivity and monotonicity transfer. A▷⊥ with finite A lies in some h_n. 'Compactness' here is just finitarity.",
    "evidence": "Direct check.",
    "suggested_fix": "None."
   },
   {
    "item": "Corollary 2.8 (coherence does not cure superfiniteness) and §0 item 2",
    "severity": "major",
    "description": "The proof is correct for a FIXED, target-independent family 𝒜. It is Gold's chain-plus-limit theorem via a (BC-style) locking sequence, with target-independent side information folded into the learner. But the title and §0 item 2 ('coherence never removes the limit points...; it cannot cure superfiniteness') state it as a general fact about coherence, and the model in §1 defines coherence data as contexts 'certified coherent: A ⊬* ⊥', i.e. relative to the target. When designations are target-dependent data, which is natural for problem setups certified consistent with the true theory, each designation is a genuine negative datum A▷⊥ ∉ ⊢*. With classical negation, a complete designation stream is equivalent to an informant, since Γ⊬φ iff Γ∪{¬φ} is coherent. The limit-point obstruction then disappears. The proof sentence 'the coherence information is the same fixed set 𝒜 whatever the target' is exactly the unflagged hypothesis. Separately, 'superfinite' is a misnomer: superfinite classes are those containing all finite languages plus an infinite one, while the hypothesis here is the more general infinite-ascending-chain-with-union (limit point) condition.",
    "evidence": "Counterexample under target-dependent designation (verified in cor28.py on 7 atoms). Let h_n = Cn_CPC{¬p_i : i<n} and h_ω = Cn_CPC{¬p_i : i∈ω}. This is a strictly increasing chain with its union, all ∅-coherent, so it satisfies Cor 2.8's hypotheses for 𝒜={∅}. {p_j} is h_n-coherent iff j≥n, and h_ω-incoherent for every j. Suppose the environment designates target-coherent contexts and eventually every target-coherent singleton. Then the learner 'output h_j for the least j with {p_j} designated so far, else h_ω' identifies every member of the class.",
    "suggested_fix": "Add 'with 𝒜 fixed and known independently of the target' to the statement and the title. Qualify §0 item 2 and the closing paragraph of §2.5 accordingly. Add a remark or companion proposition: with target-dependent designations, coherence data are (partial) informant data and can defeat the chain-plus-limit obstruction. Rename 'superfiniteness' to 'limit point / infinite ascending chain with union'."
   },
   {
    "item": "§2.5 closing sentence ('Coherence suffices exactly when U(⊢*) ∩ H = {⊢*}')",
    "severity": "minor",
    "description": "Read as 'every wrong hypothesis is eventually refuted by text plus coherence', this is correct. Read as a condition for identifiability, the 'only if' direction is false: positive-data structure can handle coherent over-generalizations.",
    "evidence": "H={⊢*, h} with h⊋⊢*, both coherent: U(⊢*)∩H ∋ h, yet the class is identifiable from text (conjecture ⊢* until a sequent of h∖⊢* appears).",
    "suggested_fix": "Replace 'Coherence suffices' with 'refutation by text plus coherence eliminates every wrong hypothesis exactly when...'."
   },
   {
    "item": "Proposition 2.9 (formal content)",
    "severity": "minor",
    "description": "(a), (b) and (c) are correct. Verified by truth tables (p29.py) for k=1..4: s_c ∈ h_b iff b≠c. Presenting s_c deletes only h_c, giving 2^k−1 incompleteness errors for any certified-sound learner. (a)'s second sentence uses R*∈VS_t, which holds for any learner by the argument of Thm 2.2(i). Small issues: 'type-(P) error' is never defined (it presumably means a (P)-round with s ∉ R̂_t); the index 'i ≤ k' with b∈{0,1}^k is off by one. (c), and the sentence 'coherence is an informative signal only because consistency is undecidable', assume 𝒜 is known a priori. With target-dependent designations, coherence is informative even when consistency is decidable (see Cor 2.8 issue).",
    "evidence": "p29.py output: claim holds for k=1..4. The error count 2^k−1 is reproduced.",
    "suggested_fix": "Define incompleteness ((P)-type) errors. Index i∈[k]. Qualify (c) and the 'only because' sentence with 'when 𝒜 is fixed and known'."
   },
   {
    "item": "§2.6 closing paragraph, Thm 2.2 Remark (a), §0 item 1, §9 open problem 1 (bold-vs-cautious moral)",
    "severity": "major",
    "description": "The text contrasts 'Coherence bounds the price of boldness (log2(1/w*) detections, Thm 2.2)' with 'Nothing bounds the price of caution', and recommends OH as the bold learner (Remark (a): 'boldest half gives a completeness-seeking reasoner'; §8 item 1). In Prop 2.9(b)'s own class, however, EVERY oligarchic learner pays exactly the same price of caution as the certified-sound learner, |H|−1 incompleteness errors. This covers every OH variant, including 'boldest half', and in fact every learner with R̂_t ⊆ some h ∈ VS_t, the only learners Prop 2.3 allows to halve on detections. The only learner here with few incompleteness errors is non-oligarchic, and Thm 2.2 gives no detection bound for it. So the paper establishes no bold-vs-cautious trade-off: Thm 2.2 bounds one error type and leaves the other as bad as caution's. More generally, halving both error types is impossible in Thm 2.4's class. Halving incompleteness errors needs R̂ ⊇ (strict-majority steps). Halving detections needs R̂ ⊆ h_i∩h_j for some pair. The majority set ⊄ any h_i∩h_j.",
    "evidence": "Class h_b = Cn_CPC{a_i→ℓ_i^{b_i}}, uniform prior. Suppose S_t ∋ h_c with |VS_t|≥2. Then s_c ∉ h_c ⊇ R̂_t, so presenting s_c is an incompleteness error, and it deletes only h_c (s_c ∈ h_b for b≠c). Repeating gives exactly 2^k−1 errors whatever coalitions OH chooses (p29.py, k=1..5, random coalitions: 1,3,7,15,31). Meanwhile R̂_t=∪VS_t makes 0 incompleteness errors (R*⊆R̂) and 0 detections, because every h_b ⊆ Cn_CPC{¬a_1..¬a_k}, which is ∅-coherent. This also contradicts §9 OP1's 'for product classes the answer is log2|H|' as an exact value: this product class has two-sided minimax 0, while every oligarchic learner suffers |H|−1.",
    "suggested_fix": "State that Thm 2.2 controls only detections and that oligarchic learners can incur |H|−1 incompleteness errors (add this as part (d) of Prop 2.9). Rewrite the §2.6 moral and Remark (a) as a genuine two-sided trade-off; the doctrinal paradox shows halving both error types can be impossible. Restate OP1: 'log2|H|' at most as an upper bound for product classes, with the union learner as a better learner on Prop 2.9(b)'s class."
   }
  ],
  "overall": "No statement in Section 2 is false as written. Every numbered result checks out, both line by line and by brute force: Thm 2.2's detection bound (1173 exhaustive minimax instances), Prop 2.3's equivalence (3000 random instances), Thm 2.4's memberships (truth tables), Thm 2.5's weighted-majority bound (20000 simulations) and Prop 2.9(b)'s construction (k=1..4). Lemma 2.1, Thm 2.6, Prop 2.7 and Cor 2.8 are correct, and mostly true once the setup is in place (TOSU, as the file says). The scripts in T2-checks do not cover §2. My checks are in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/t2s2/.\n\nThe real defects are two interpretive overclaims that the headline summary depends on.\n\n(1) Cor 2.8 / §0 item 2 ('coherence cannot cure superfiniteness') holds only if the designated contexts 𝒜 are fixed and target-independent. §1 defines them as contexts certified coherent relative to the target. With target-dependent designations, a chain-plus-limit class satisfying Cor 2.8's hypotheses becomes identifiable; an explicit counterexample is given.\n\n(2) The 'bold vs cautious' moral of §2.6, Remark (a) and §0 item 1 is not supported. In Prop 2.9(b)'s own class, every oligarchic learner, including every OH variant, makes the same |H|−1 incompleteness errors as the cautious learner. The only cheap learner there is non-oligarchic and lies outside Thm 2.2. Halving both error types is impossible in Thm 2.4's class. This also undercuts §9 OP1's 'log2|H| for product classes'.\n\nMinor points: Lemma 2.1's third bullet uses an inconsistent notion of 'refuted'; Prop 2.3 is overstated in §0 as 'necessary for such a guarantee' when it is per-round only; Thm 2.4 should define majority over VS and say the environment withholds discriminating data; Thm 2.5 is the standard Littlestone–Warmuth bound; 'superfinite' is a misnomer; 'type-(P) error' is undefined; and the citation details flagged above. §2.7's 'holds verbatim' remark was spot-checked and is plausible."
 },
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T2-coherence-as-negative-data.md",
  "items_checked": [
   "Thm 3.1 (structural Post-completeness of C_2; infinitary operators; pure {->} case)",
   "Prop 3.2 ({and,or} fragment: C_2, C_ai, C_Fm)",
   "Thm 3.3 (a) finite collapse + example D, (b) enumeration learner / mind-change bound, (c) necessity of assumptions",
   "Prop 3.4 (C_adm is the largest structural closure operator with given theorems)",
   "Prop 3.5 (a) structural completeness of CPC + 'bold learner' reading, (b) IPC admissible vs derivable, coherence profile",
   "Thm 3.6 (a) Glivenko coherence equivalence, (b) bold learner, (c) Jankov chain impossibility, (d) conservative BC learner",
   "Lemma 3.7 (Delta_0 feedback subsumed by coherence above Q)",
   "Thm 3.8 (Goedel-Rosser; no coherence-maximal r.e. hypothesis; 2^aleph0 completions)",
   "Thm 3.9 (Turing-progression chain impossibility)",
   "Thm 3.10 (a)-(e) (Pi_1 truth detector, Popperian learner, naive bold learner, Sigma_2 barrier)",
   "Prop 3.11 (complete theories coherence-pinned) and the 'Relevance to physics' paragraph",
   "Check scripts in theory/T2-checks/ (carnap_check.py, fallacy_check.py, matrix_check.py) re-run: all run and match their claims, but none of them tests a Section 3 result; I wrote and ran new brute-force checks (scratchpad s3checks.py, theta_star.py, sympy Galois check)"
  ],
  "issues": [
   {
    "item": "Thm 3.1 (correctness)",
    "severity": "ok",
    "description": "Statement and proof verified. Steps 1-4 are valid for arbitrary (non-finitary) structural closure operators: sigma_v X is contained in Taut = C_2(empty) which is contained in C(empty), so sigma_v phi is in C(sigma_v X), which is contained in C(C(empty)) = C(empty). The contradiction sigma_v phi then gives Fm in C(empty). In the pure {->} case the induction (sigma_v psi is equivalent to p0->p0 or to p0) is correct, and p0 in C(empty) gives C(empty)=Fm by substituting for p0. Implicit assumptions: every connective in the language is Boolean-interpreted, there are at least the stated connectives, and in a language without a bottom constant 'coherent' must be read as C(A) != Fm.",
    "evidence": "Brute force (scratchpad s3checks.py): for 3000 random formulas each over {not,and}, {not,or} and {not,imp}, and 3000 over pure {imp}, sigma_v psi was always a tautology when v(psi)=1 and a contradiction when v(psi)=0 (or equivalent to p0 for pure imp). 0 failures.",
    "suggested_fix": "Optionally state 'all connectives are interpreted in the Boolean matrix'. No mathematical change needed."
   },
   {
    "item": "Thm 3.1 / Sec. 0 item 3 (novelty framing)",
    "severity": "minor",
    "description": "The text credits Post 1921 only for the theorem-level version and stresses that the result 'holds for the full consequence relation, not only for theorems, and needs no finitarity'. That suggests the consequence-level statement is an advance made here. It is standard: CPC is structurally complete (Pogorzelski 1971), and classical consequence has no proper consistent structural extension in a language with theorems. This is textbook material in Wojcicki 1988 and Pogorzelski & Wojtylak 2008 (Completeness Theory for Propositional Logics). Prop 3.2's three-extension result for theorem-free fragments is likewise standard abstract-algebraic-logic folklore.",
    "evidence": "Text at Sec. 3.1, line 260 ('The theorem-level version is Post's 1921...'), and Sec. 0, line 17.",
    "suggested_fix": "Mark Thm 3.1 and Prop 3.2 as [cited, with a proof included for completeness], citing Wojcicki 1988 and Pogorzelski & Wojtylak 2008 for the consequence-level form."
   },
   {
    "item": "Prop 3.2",
    "severity": "ok",
    "description": "Verified. C_ai is a structural closure operator that extends C_2 because C_2(empty)=empty. In the case C(empty) nonempty, collapsing to p0 gives C=C_Fm. In the case C(empty)=empty, the q/r substitution gives r in C({q}), hence C=C_ai. The free distributive lattice on two generators has exactly the four classes q, r, q&r, q|r, so the case analysis is complete.",
    "evidence": "s3checks.py: 3000 random {and,or} terms in two variables produce exactly four truth tables: (0001),(0011),(0101),(0111).",
    "suggested_fix": "None needed (see the separate minor issue on coherence in bottom-free languages)."
   },
   {
    "item": "Sec. 1 coherence definition as used in Prop 3.2 'Learning reading', Thm 3.3 (pure {->}, {not,and}, {not,or} languages)",
    "severity": "minor",
    "description": "Coherence is defined as 'bottom is not derivable', with bottom a formula 'when present'. Thm 3.3 defines S(D,A_0) via 'A_0 does not derive bottom', and Prop 3.2's learning reading speaks of '|/- bottom from the empty context'. But the {and,or} fragment, the pure {->} fragment, and languages with only not plus one binary connective have no bottom formula. For these cases the definitions are formally undefined.",
    "evidence": "Prop 3.2 is stated for the {and,or} language. Thm 3.3 explicitly covers 'the language as in Thm 3.1', which includes pure {->}.",
    "suggested_fix": "Define h to be A-coherent iff h(A) != Fm (non-triviality). For a structural h this is equivalent to A not deriving a fresh atom. All proofs go through unchanged."
   },
   {
    "item": "Thm 3.3 (a) example D and (c)",
    "severity": "minor",
    "description": "The general claims are correct: S(D,A_0)={C_2} iff <D>=C_2, a finite D exists, (b) holds with at most i* mind changes, and (c) shows each assumption is needed. The proposed example D is wrong under its natural reading. The four implication-negation sequents generate CPC on {not,->}, by Lukasiewicz-style completeness plus the deduction theorem. Adding 'defining sequents for and and or' as sequent rules (p&q |> p, p&q |> q, p,q |> p&q, or definitional rules such as p&q |> not(p->not q) and its converse) does not give C_2, because the deduction theorem fails for the new rules. The example also presupposes both not and ->. It is unavailable for {not,and}, {not,or} and pure {->}, which are all 'languages as in Thm 3.1'. Pure {->} would need Peirce's law instead of A3. Minor nit in (c): 'C_2 + |> p17 is coherent' holds only if p17 is chosen so that A_0 together with p17 is consistent (e.g. p17 not occurring in A_0).",
    "evidence": "Countermodel (scratchpad theta_star.py). For each atom assignment s, let v_s be Boolean on not and ->. Set v_s(a&b)=1 iff a and b are both in Theta*, where Theta* = {phi : v_s(phi)=1 for all s}; this is well defined by recursion on complexity. Theta* contains every instance of A1, A2 and (not p->not q)->(q->p), and is closed under all instances of MP, &I and &E. Checked: 0 violations over 3000 random axiom instances and 400x400 random rule applications. Yet p->(q->(p&q)) is not in Theta*, since s(p)=s(q)=1 gives 1->(1->0)=0. Hence <D>(empty) is contained in Theta*, which is not Taut, so <D> != C_2.",
    "suggested_fix": "Give the and/or clauses as ->-axioms, so the deduction theorem holds: |> p&q->p, |> p&q->q, |> p->(q->p&q), |> p->p|q, |> q->p|q, |> (p->r)->((q->r)->(p|q->r)). Say that the example is for languages containing not and ->, and give Peirce's law for pure {->}. In (c), take an atom not occurring in A_0."
   },
   {
    "item": "Prop 3.4",
    "severity": "ok",
    "description": "Verified. Extensivity, monotonicity, idempotence (from 'sigma X in Th implies sigma C_adm(X) in Th'), structurality (applying the definition to sigma composed with tau) and maximality are all correct for arbitrary closure operators, and C_adm(empty)=Th uses only that Th is closed under substitution. One wording caveat: the proof does not show that C_adm is finitary. 'The consequence of all admissible rules / the structural completion' (normally a finitary relation generated by admissible finite rules) therefore coincides with C_adm only on finite premise sets.",
    "evidence": "Line-by-line check of the five bullets in the proof.",
    "suggested_fix": "Add 'on finite premise sets' to the identification with the structural completion, or note that C_adm may be non-finitary."
   },
   {
    "item": "Prop 3.5 (a)",
    "severity": "minor",
    "description": "'For CPC, C_adm = C_2' is true only for languages that have one-variable tautologies and contradictions, i.e. the languages of Thm 3.1. The proof relies on sigma_v. In a theorem-free fragment such as {and,or} (Prop 3.2), Th is empty, so C_adm(X)=Fm for every nonempty X. Thus C_adm = C_ai != C_2, and that fragment of CPC is not structurally complete: p |> q is vacuously admissible. The learning gloss 'from theorem-only data, the bold learner (output the largest structural relation with the observed theorems) recovers full classical consequence' is also not a learning-in-the-limit statement. From a finite sample of theorems, 'the largest structural relation with the observed theorems' is not specified. Its natural reading, C_adm of the substitution closure of the sample, need not even admit MP at a finite stage. The claim is correct only once Th = Taut is given.",
    "evidence": "{and,or} fragment: no substitution maps a nonempty X into the empty set, so the defining condition holds vacuously and phi is in C_adm(X) for every phi.",
    "suggested_fix": "State 'in a language as in Thm 3.1'. Rephrase the learning gloss as: 'the largest structural relation whose theorem set is Taut is C_2'. Alternatively, pair it with a theorem-set learner in the style of Thm 3.3(b) and then output C_adm of the conjectured theorem set."
   },
   {
    "item": "Prop 3.5 (b)",
    "severity": "ok",
    "description": "Verified. Harrop's (Kreisel-Putnam) rule is admissible but not derivable in IPC. The coherence-profile argument is correct: for classically consistent A, sigma_v maps A to variable-free, classically true formulas, which IPC proves (by induction IPC decides every variable-free formula), while sigma_v(bottom) = bottom is not an IPC theorem. For classically inconsistent A, Glivenko gives A |-_IPC bottom. Citations (Harrop 1960 JSL 25; Rybakov 1997; Iemhoff 2001 JSL 66) are accurate as far as I can tell.",
    "evidence": "Proof check. IPC proves not-bottom and decides and, or and -> on constants.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.6",
    "severity": "ok",
    "description": "(a) Correct. Glivenko plus the deduction theorem gives A |-_CPC bottom iff A |-_IPC bottom for finite A, and intermediate consequence relations lie between the two. (b) Correct. (c) Correct. Jankov's lemma (B refutes chi(A) iff A is in SH(B), for finite subdirectly irreducible A) and an infinite SH-antichain give a strictly increasing chain L_k: B_{k+1} validates L_k and refutes chi(B_{k+1}). No B_i equals 2, since 2 embeds in every nontrivial Heyting algebra, so every chi(B_i) is classically valid and L_omega is contained in CPC. The coherence information is target-independent by (a), so Gold's chain argument (Cor 2.8) applies. It works for arbitrary, even non-computable, learners. (d) Correct: once the finite generators appear, <D_n> equals the target, and it is always contained in the target. This gives BC, not EX. Citations to Jankov 1963/1968 are correctly flagged as unverified.",
    "evidence": "Proof check of each step. The antichain property rules out B_i = 2.",
    "suggested_fix": "Optional: replace 'atomic generators' in (d) with 'finitely many generating sequents'."
   },
   {
    "item": "Lemma 3.7",
    "severity": "ok",
    "description": "Verified. Q decides every Delta_0 sentence correctly, so a consistent T containing Q proves no false Delta_0 sentence. Delta_0 truth-value feedback therefore never contradicts such a T.",
    "evidence": "Standard Sigma_1-completeness of Q.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 3.8",
    "severity": "minor",
    "description": "The cited core (Goedel-Rosser incompleteness for consistent r.e. extensions of Q; 2^aleph0 complete extensions of PA agreeing with all Delta_0 data and all PA-texts) is correct. The bullet 'every r.e. coherent hypothesis has two incompatible coherent refinements' is true only if 'coherent' means plain consistency (A = {empty}). Under the paper's own notion of A-coherence it can fail. For the A used in Thm 3.9 (all finite sets of true sentences), T is A-coherent iff T is contained in Th(N), so at most one of T+rho and T+not rho is A-coherent. For r.e. families A it can be repaired with Mostowski's 1961 simultaneous-independence theorem. Attribution nit: incompleteness for extensions of Q is due to Robinson 1950 and Tarski-Mostowski-Robinson 1953, not to Rosser 1936.",
    "evidence": "With A = all finite sets of true sentences and rho false, the context {not rho} is in A and T+rho+not rho is inconsistent.",
    "suggested_fix": "Write 'consistent' instead of 'coherent' in the bullet, or add 'for r.e. A (Mostowski 1961)'. Add the Tarski-Mostowski-Robinson 1953 citation."
   },
   {
    "item": "Thm 3.9",
    "severity": "minor",
    "description": "The impossibility claim is correct. Every T_k and T_omega is sound, so the A-coherence information (A a family of true contexts) and the Delta_0 oracle are target-independent. The chain is strict by Goedel II, and the locking-sequence argument applies to the subclass {T_k : k <= omega}, contained in K, so it also applies to K. Items (i)-(iii) are correct. Small inconsistency in the setup: 'A any family of finite sets of true sentences' is fixed for all targets, but the suggested extra targets T_k + not Con(T_k) violate the designation requirement (every designated context target-coherent) whenever A contains a set that, together with T_k, proves Con(T_k), e.g. {Con(T_k)}. The theorem is unaffected because it only needs the sound subclass, but as written the setup is ill-posed for those members.",
    "evidence": "With A containing {Con(T_k)}, the theory T_k + not Con(T_k) + Con(T_k) is inconsistent, so this context is not coherent for that 'possible target'.",
    "suggested_fix": "State the theorem for K containing {T_k : k <= omega}, and note separately that the Sigma_1-unsound theories are possible hypotheses (not targets), with properties (i)-(iii). Also note that the result is Gold's chain theorem because all side information is target-independent."
   },
   {
    "item": "Thm 3.10",
    "severity": "minor",
    "description": "(a), (b), (c) and (e) are correct. (c): a Pi_1 sentence pi is false iff PA refutes pi, and a Sigma_1 sentence sigma is true iff PA proves sigma; each needs at most one mind change. (e): on computable presentations the guesses are computable, so a convergent limit is Delta_2 (Shoenfield), while Sigma_2-truth is not Delta_2. (d) is false as literally stated: 'It accepts not Con(PA) forever if that sentence comes before Con(PA)'. Whether the Lindenbaum-in-the-limit learner accepts not Con(PA) depends on all earlier sentences, not only on where Con(PA) appears. The proof's 'whichever comes first is accepted' covers only the case where it is the first sentence, or where nothing accepted earlier decides it. Novelty: the 'Popper asymmetry, now a theorem' (Pi_1 refutable, Sigma_1 verifiable with certainty) is standard formal learning theory (Putnam 1965; Kelly 1996, which the paper cites elsewhere).",
    "evidence": "Counterexample to (d): enumerate phi0 = Con(PA) & 0=0 (or Con(PA+Con(PA)), or Con(ZF), which PA-provably implies Con(PA)), then phi1 = not Con(PA), then phi2 = Con(PA). phi0 is accepted forever, since PA+phi0 is consistent. phi1 is rejected, since PA+phi0+phi1 is inconsistent, which the learner finds quickly. So not Con(PA) precedes Con(PA) but is not accepted.",
    "suggested_fix": "Restate (d) as: 'its limit is the Lindenbaum completion along the enumeration, and there are enumerations (e.g. any beginning with not Con(PA)) on which it accepts not Con(PA) forever'. Cite Kelly 1996 and Putnam 1965 for (c) and (e)."
   },
   {
    "item": "Prop 3.11 and 'Relevance to physics' (also used in Sec. 0 item 4, the headline, and Sec. 8 line 678)",
    "severity": "major",
    "description": "Prop 3.11 as stated is correct: for complete T, no consistent deductively closed proper extension exists in the same language, and an r.e. complete theory is decidable, so the Thm 3.3(b) learner identifies the theory. But it works at the theorem (sentence) level only. The paper then claims that 'in that fragment the user's setup works as cleanly as in CPC', and Sec. 8 says complete theories 'are provably learned by this setup from positive data plus one coherence datum'. The user's setup learns inference rules (a consequence relation) applied in contexts with parameters. At that level the analogue of Thm 3.1/3.3(a) fails for RCF. Structurality there means closure under substitution of terms for parameters. The CPC proof works because sigma_v can substitute witnesses (top or bottom) for atoms; in RCF, witnesses of a failing rule need not be term-definable. So a single coherence datum does not pin RCF's consequence relation.",
    "evidence": "Language of ordered rings with parameters c, d, ...; target: Gamma |- phi iff RCF + Gamma |- phi. Let h be the least term-substitution-closed consequence relation containing the target and all instances t*t=1+1 |> t>0. The rule fires from the empty set only on terms t with RCF |- for-all x (t(x)^2=2), and no integer polynomial satisfies this. So h(empty) = RCF-consequences and h is coherent on A_0 = empty. But c*c=1+1 |-_h c>0, which RCF does not prove. So h is unsound and nontrivial. The rule is caught by A_0={c^2=2} via the term -c. The rule x^3-4x+1=0 |> x>1, however, survives both A_0 = empty and A_0 = {c^3-4c+1=0}. The discriminant is 229, not a square, so the Galois group is S_3. Sympy confirms that over Q(r1) the cubic factors as (x-r1) times an irreducible quadratic, so no integer-polynomial term maps the root r1 to another root, and h(A_0) = Cn_RCF(A_0 + {c>1}) is consistent.",
    "suggested_fix": "Either (i) restrict the claim explicitly to theorem-level identification, or (ii) require hypotheses to be closed under exists-elimination (from Gamma |- exists x psi and Gamma, psi(d) |- chi with d fresh, infer Gamma |- chi). Under (ii) the analogue holds with one datum: if Gamma(c) |-_h phi(c) is not T-valid, completeness gives T |- exists x (Gamma & not phi). With fresh d, Gamma(d), not phi(d) |-_h bottom, and exists-elimination gives empty |-_h bottom. Note that this closure is a discharge meta-rule, not a 'step' in Sec. 1's notion of argument. Alternatively, designate rich contexts. Update Sec. 0, the headline and Sec. 8 accordingly."
   },
   {
    "item": "Prop 3.11 examples and 'incompleteness enters with exponentiation'",
    "severity": "minor",
    "description": "'Dense linear orders' is complete only without endpoints (or with endpoint conditions fixed); the theory of dense linear orders alone does not decide 'there is a least element'. The claim that incompleteness enters with exponentiation is unsupported. Th(R, exp) is model complete (Wilkie 1996) and decidable if Schanuel's conjecture holds (Macintyre-Wilkie 1996), so whether a complete r.e. axiomatization exists is open. Incompleteness provably enters with, e.g., sin on all of R, which defines Z.",
    "evidence": "Standard model theory: DLO without endpoints is aleph_0-categorical and hence complete. Decidability of R_exp is open, and conditional on Schanuel it is decidable.",
    "suggested_fix": "Write 'dense linear orders without endpoints'. Replace 'e.g. exponentiation' with 'e.g. periodic functions such as sin on R (which define Z) or general ODE solutions', and note that the R_exp case is open."
   }
  ],
  "overall": "Section 3's core mathematics holds up, and nothing in scope is fatal. Thm 3.1 (with infinitary operators and the pure {->} case), Prop 3.2, Thm 3.3(a,b), Prop 3.4, Prop 3.5(b), Thm 3.6(a-d), Lemma 3.7, Thm 3.9 and Thm 3.10(a,b,c,e) are all correct. I confirmed them by line-by-line proof checks and brute-force tests of the sigma_v substitution lemmas and the two-variable lattice terms. One issue is major, and only for what is built on Prop 3.11, not the proposition itself. Prop 3.11 is a theorem-level result. The paper extrapolates it to the user's rule-learning setup ('works as cleanly as in CPC'; Sec. 8 'provably learned by this setup'), and that does not follow. With rules applied in contexts with parameters, RCF has coherent unsound structural extensions that a single coherence datum does not catch: x^2=2 |> x>0 against the empty context, and the cubic rule with Galois group S_3 against the context {c^3-4c+1=0}. A cheap fix is to require hypotheses closed under exists-elimination. The minor issues are: (1) the example finite basis D in Thm 3.3(a) fails if and/or are given by sequent rules (a countermodel shows p->(q->(p&q)) is underivable), and it presupposes not and ->; (2) Thm 3.10(d) is false as literally stated (counterexample enumeration Con(PA)&0=0, not Con(PA), Con(PA)); (3) Prop 3.5(a) needs the language hypothesis (in {and,or}, C_adm = C_ai), and its 'bold learner' gloss is not a limit-learning statement; (4) Thm 3.8's 'coherent' must mean plain consistency; (5) Thm 3.9's suggested unsound targets clash with the fixed designations; (6) coherence is undefined in languages without bottom; (7) novelty framing: consequence-level Post-completeness and the 'Popperian' Sigma_1/Pi_1 asymmetry are standard (Wojcicki/Pogorzelski; Putnam/Kelly); (8) small nits on DLO and exponentiation. The scripts in theory/T2-checks/ run and match their claims, but none tests Section 3. My checks are scratchpad files: /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/s3checks.py and theta_star.py."
 },
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T2-coherence-as-negative-data.md",
  "items_checked": [
   "Lemma 4.1 (a),(b),(c)",
   "Thm 4.2 (Carnap in learning form) incl. bullets on v_top, v_Taut, ∧-categoricity, substitution invariance",
   "Denial-rank definition and Thm 4.3 (trichotomy) + its 'Reading' table",
   "Thm 4.4 (a)-(c) (12-datum tell-tale), brute-force checked",
   "Thm 4.4(d)",
   "§0 summary item 5 wording of Thm 4.4 data",
   "T2-checks/carnap_check.py (re-run; coverage vs. claim at line 506)",
   "Prop 4.5 (re-ran 16384-matrix check + independent reimplementation)",
   "Prop 4.6 (world feedback)",
   "§4.5 Gold-vs-Carnap table and H3 verdict",
   "Prop 5.1 (tonk)",
   "Prop 5.2 (coherence ≠ conservativity) + following harmony remark",
   "Thm 5.3 (a)-(d) (Π1 / Π2 completeness)",
   "Thm 6.1",
   "Cor 6.2 + fallacy table (fallacy_check.py re-run)",
   "§6 non-elimination examples 1-4 (quantifier swap, gambler, base rate, restricted AC)",
   "Prop 6.3",
   "Thm 6.4",
   "Prop 7.1"
  ],
  "issues": [
   {
    "item": "Thm 4.4(d), final sentence ('Identification in the limit still holds via the text'), line 496",
    "severity": "fatal",
    "description": "This one sentence is false under the document's own definition of identification in the limit (§1, line 79: EX/BC convergence to a correct hypothesis). It is also false under the weaker reading 'complete data determine the meaning'. It has no proof: the proof of (d) at line 504 justifies only the first sentence. (a)–(c) and the first sentence of (d) are correct and unaffected.",
    "evidence": "(1) No tell-tale. Fix a Boolean u0. For a formula χ, let v'_χ be u0 with its value at χ flipped. Let L_χ be the multiple-conclusion relation of BV ∪ {v'_χ}. v'_χ violates a TT instance involving χ, so L_χ ⊊ L_BV. Given any finite T ⊆ L_BV, pick χ that occurs in no sequent of T. Then v'_χ agrees with u0 on everything T mentions, so T ⊆ L_χ ⊊ L_BV. So BV has no Angluin tell-tale in any class that contains it and all the BV ∪ {v'_χ}. The single coherence datum [ : ] is in bounds for every member. By the locking-sequence argument (Blum & Blum; Angluin 1980), no learner, computable or not, EX- or BC-identifies such a class from text plus that datum. (2) Not even determined by complete data. V' = BV \\ {u0} is a dense subset of BV, so it has exactly the same valid sequents and the same in-bounds positions as BV. Even a full informant cannot separate them. V' is non-structural: composing any v with the constant substitution along u0 yields u0.",
    "suggested_fix": "Replace the sentence with: 'Every non-Boolean valuation is eventually refuted by the text (Val(D_n) decreases to BV pointwise), but without structurality BV is not identifiable in the limit among all meanings. It has no tell-tale relative to the BV ∪ {v'_χ}, and dense subsets of BV are indistinguishable from it even by an informant. Among closed meanings the complete data determine BV (Lemma 4.1(a)), but learnability still fails.'"
   },
   {
    "item": "Thm 4.3 'Reading' table (lines 472-480), §4.5 (line 549), §0 item 5 (line 32): use of 'coherence'",
    "severity": "minor",
    "description": "§4 uses 'coherence' for two different kinds of data. §4.1 (line 427) defines coherence data as POSITIVE data about valuations: 'some admissible valuation realizes [A:D]'; Thm 4.4(b) uses it this way (V≠∅). The Thm 4.3 table and §4.5 instead call the 0-conclusion sequents 'Γ ▷ ' coherence. Those are NEGATIVE data about valuations: they exclude positions. Positive data can never exclude a valuation. So under the §4.1 sense, coherence does not remove v_⊤, and the §4.5 claim 'Carnap's v_⊤ is the twin of Gold's trivial over-generalization, and coherence removes both' equivocates. Gold's trivial meaning (V=∅) is removed by the positive datum. v_⊤ is removed only by a 0-conclusion sequent such as p,¬p ▷. Thm 4.3 itself is correct, and the negative conclusion (coherence cannot remove v_Taut) holds under either sense.",
    "evidence": "V = BV ∪ {v_⊤} is structural. By Thm 4.2 its single-conclusion relation is exactly CPC, and every position that is in bounds for BV is in bounds for V. So V never gives 'good arguments for both P and ¬P' from any classically consistent designated context, and it passes every §4.1-style coherence datum. The only data that exclude v_⊤ are valid sequents with an empty succedent (v_⊤ satisfies every sequent with Δ≠∅). This is what carnap_check.py actually adds under the label 'coherence'.",
    "suggested_fix": "Distinguish (i) coherence/in-bounds data, which are positive about V, exclude only the empty or trivial meanings, and are Gold's negative data, from (ii) 0-denial exclusion constraints such as 'p,¬p ▷', which are Restall-style incoherence constraints and negative about V. Relabel the first table row accordingly, and reword §4.5: v_⊤ is removed by 0-denial constraints, not by coherence data."
   },
   {
    "item": "Thm 4.2 (line 447): 'any natural-deduction metarules with discharge (they are closure properties of the relation)'",
    "severity": "minor",
    "description": "This holds only under the global (relation-level) reading of metarules. Under the local, per-valuation reading of rule validity discussed in the Garson (2013) book that the file itself cites, metarules with discharge DO exclude v_Taut. So 'any natural-deduction metarules' overstates the claim. The rest of Thm 4.2 checks out: the proof via Lemma 4.1(b), BV^∩ \\ BV = {v_T : T a non-maximal CPC-theory, or T=Fm}, the ¬/∨/→ violations (witness φ→¬φ for undecided φ), ∧-categoricity, closedness, and v_T∘σ = v_{σ^{-1}T}.",
    "evidence": "Local →I with Γ=∅ says: for each v∈V, if v satisfies φ▷ψ then v(φ→ψ)=1. So v(φ)=0 forces v(φ→ψ)=1. v_Taut has v(p)=0 and v(p→¬p)=0 (p→¬p is not a tautology), so it is excluded.",
    "suggested_fix": "Say 'metarules read globally (as closure conditions on the relation)'. Add that local readings smuggle in rank-2 information: the local →I instance is the sequent ▷φ, φ→ψ."
   },
   {
    "item": "§0 summary item 5 (line 33): '11 atomic two-conclusion sequents'",
    "severity": "minor",
    "description": "Miscount and mislabel. Of the 11 TT(p,q) sequents, only 3 have two conclusions (▷p,¬p; p∨q▷p,q; ▷p,p→q). One has zero conclusions (p,¬p▷) and 7 are single-conclusion. Thm 4.4(c) itself correctly says '11 positive bilateral data'.",
    "evidence": "List at lines 485-488.",
    "suggested_fix": "Write '11 atomic multiple-conclusion sequents (3 with two conclusions, 1 with none)'."
   },
   {
    "item": "Thm 4.4 (a)-(c) (12-datum tell-tale)",
    "severity": "ok",
    "description": "Correct. (a): each schema fixes rows of its truth table, so Val(TT)=BV, and BV is closed. (b): the inclusion V ⊆ BV via v∘σ, and equality via the ⊤/⊥ substitution σ (v∘σ is Boolean and equals u on atoms), are both sound. (c) follows. The 12 data are also minimal under single-item removal. Novelty: (a) is the standard Carnap 'junctives' / Shoesmith–Smiley categoricity result, which is correctly attributed. The finite structural tell-tale is a modest, correct addition.",
    "evidence": "Brute force (scratchpad tt44.py). Over all structural meanings V = {d∘h} given by 2- and 3-element matrices (2 + 3,244,032 combinations that satisfy all 11 TT(p,q)), none is non-Boolean. For each of the 11 schemata, dropping it admits a nonempty structural non-Boolean V; e.g. dropping ▷p,¬p admits f_¬≡0 on {0,1}. Dropping the coherence datum admits V=∅. On finite fragments Val(TT) is exactly the Boolean restrictions (4 of 2^16, 4 of 2^20, 4 of 2^11).",
    "suggested_fix": "None needed. Optionally state that each of the 12 data is individually necessary (verified)."
   },
   {
    "item": "Lemma 4.1",
    "severity": "ok",
    "description": "(a): basic clopens are exactly the U(Γ,Δ); both inclusions are correct, including V=∅. (b): the compactness argument for finitarity is correct (the finite subfamily must contain V∩{v(φ)=0}, since {v: v[X0]=1} always contains v_⊤). C_V(v)=v characterises respect for all finite-premise single-conclusion sequents, and Fix(C_V)=V^∩ with the empty intersection v_⊤. (c): correct via the completeness theorem.",
    "evidence": "Checked line by line. carnap_check.py reproduces 14 = |∩-closure| on the 16-formula fragment.",
    "suggested_fix": "Cosmetic: for non-closed V, single-conclusion data determine V only up to (cl V)^∩, not V^∩. §4.5's table entry 'determine V only up to V^∩' should say this."
   },
   {
    "item": "Thm 4.3 (denial-rank trichotomy) and definition of d(v)",
    "severity": "ok",
    "description": "Correct. The four classes (inconsistent / consistent and not closed / closed and non-maximal / maximal) partition all valuations, and the ranks 0/1/2/∞ follow by compactness plus the witness ▷φ,¬φ. Implicitly this needs ¬ in the language (true for the TT language). In subformula-closed fragments without full ¬-closure, the rank-2 witnesses still exist.",
    "evidence": "Brute force (scratchpad rank43.py) computed d(v) exactly and the class of v for every valuation on three subformula-closed fragments: the carnap_check fragment (2^16 valuations: 48608/16915/9/4 in ranks 0/1/2/∞), that fragment plus 4 negated compounds (2^20), and a mixed depth-2 fragment (2^11). Zero mismatches.",
    "suggested_fix": "State the language assumption (¬ present) explicitly."
   },
   {
    "item": "T2-checks/carnap_check.py vs. claim at line 506 ('verifies Lemma 4.1–Thm 4.4')",
    "severity": "minor",
    "description": "The script runs and its three printed checks pass. But it does not verify Thm 4.3: the file ends with the comment '# denial rank of each non-boolean valuation in sc-universe' and no code. It also does not verify the structural part of Thm 4.4(b). The text overstates its coverage.",
    "evidence": "Output: 'TT: 4 True; single-conclusion: 14, closure 14, equal True; adding 0-denial: 13 True'. The last line of the script is a comment stub.",
    "suggested_fix": "Add the denial-rank computation (as in my rank43.py) and a matrix-based check of 4.4(b) (as in tt44.py), or narrow the claim to what the script checks."
   },
   {
    "item": "Prop 4.5 (compositional prior; 16384-matrix check)",
    "severity": "ok",
    "description": "Correct. The row-by-row proof is valid. Small notes: (i) with D={1} fixed, the 'and is non-trivial' clause is vacuous (p⊢q always fails), and matrix_check.py computes a variable `triv` that is never used and does not depend on the matrix. (ii) If D were allowed to vary, D=∅ validates all 12 rules and yields C_ai, so the clause would need to read 'p⊬q'. (iii) The rule set is redundant: explosion and ¬¬E can each be dropped and the matrix is still unique. None of this affects the statement.",
    "evidence": "Re-ran matrix_check.py: 1 matrix ((1,0),(0,0,0,1),(0,1,1,1),(1,1,0,1)), the standard one. My independent reimplementation (m45.py) over all 4·16^3 = 16384 matrices gives: D={1}: 1; D={0}: 1 (the dual); D=∅ and D={0,1}: all 16384. Drop-one analysis: explosion→1, ¬¬E→1, ¬¬I→5, every other rule→2.",
    "suggested_fix": "Optional: delete 'and is non-trivial' (or note that D={1} makes it automatic), and remove the dead `triv` line from matrix_check.py."
   },
   {
    "item": "Prop 4.6 (world feedback)",
    "severity": "ok",
    "description": "Correct and trivial. A single Boolean actual valuation belongs to every V ⊇ BV. Under the 2-element-matrix prior, each observed triple (v(φ), v(ψ), v(φ∘ψ)) fixes one row of the table.",
    "evidence": "Direct check.",
    "suggested_fix": "None."
   },
   {
    "item": "Prop 5.1 (tonk)",
    "severity": "ok",
    "description": "Correct. One cut trivializes. With a ∈ A designated, a ▷ a tonk ⊥ ▷ ⊥ plus free weakening gives A⊢⊥. If every rule has at least one premise, nothing is derivable from ∅, so C_2^{∧∨}+tonk generates exactly C_ai on the extended language. The Cook (2005, JPL 34:217–226) citation matches my recollection: tonk is harmless in a non-transitive setting.",
    "evidence": "Line-by-line check.",
    "suggested_fix": "None (perhaps note that ⊥ must be in the language, or that coherence is read as 'not everything follows')."
   },
   {
    "item": "Prop 5.2 and the harmony remark after it (lines 565-571)",
    "severity": "minor",
    "description": "The conclusion is correct: CPC_{→,¬} is coherent and proves Peirce's law, which IPC does not. Three imprecisions. (1) '(¬¬-elimination)' read literally is wrong: adding ¬¬E alone to IPC_→ is conservative, since reading ¬φ as φ maps every derivation into IPC_→. The ¬I/¬E rules are also needed. (2) 'Harmony is a decidable syntactic sufficient condition' for conservativity is false for local (intrinsic) harmony. Read's bullet • (Read 2000), with •I discharging [•] to derive ⊥ ⊢ • and •E from •,• to ⊥, has local reductions yet derives ⊥. Normalization, which is not a local syntactic check, is what gives conservativity. (3) §0's 'coherence is strictly weaker than conservativity' needs conservativity ⇒ coherence. That fails if ⊥ is new vocabulary without ex falso: IPC_→ + {▷⊥} is conservative but incoherent.",
    "evidence": "The Kripke countermodel was checked by script (misc.py): at w, p→q is false, (p→q)→p is true and Peirce is false. Counterexamples for (1)–(3) are given in the description.",
    "suggested_fix": "Say 'intuitionistic ¬I/¬E plus ¬¬E (classical reductio)'. Replace 'harmony' by 'harmony together with normalization (not a purely local check)' and cite Read's bullet. Define coherence as old-vocabulary non-triviality (or require ⊥E) before claiming 'strictly weaker'."
   },
   {
    "item": "Thm 5.3 (Π1/Π2 completeness)",
    "severity": "ok",
    "description": "Correct. (a): membership is Π1, and the reduction from the complement of K (halting configuration ⊢ ⊥) is standard. (b): membership ∀s(Σ1→Σ1) is Π2. In the hardness reduction, with c new and T-strings never premises, the old-vocabulary theorems of B+N_e are exactly Thm(B) ∪ {T(n̄,ē)}, so conservativity holds iff e ∈ Tot, which is Π2-complete. (c): Shoenfield's limit lemma, and Kelly's 'refutable in the limit' = Π2, are stated correctly. (d): if B is decidable the condition is Π1. Small note: in pure Post-string format, B's productions must be designed so that their variables cannot match strings containing the new symbol c (e.g. a projection 'xy ▷ y' would strip c). In EFS with predicates this is automatic.",
    "evidence": "Line-by-line check of quantifier structure and reductions.",
    "suggested_fix": "Optionally add 'B's productions only match predicate-tagged strings over the old alphabet'."
   },
   {
    "item": "Thm 6.1 (elimination criterion)",
    "severity": "ok",
    "description": "Correct, and trivial once set up. Survival follows because h*⊕G(F) contains every datum and is coherent (Thm 2.6(ii)). Elimination follows because any surviving hypothesis containing G(F) must contain h*⊕G(F), and incoherence is upward-closed. The semantic sufficient condition is valid, since validity of h* and G(F) in one structure is preserved by closure. The OH parenthetical relies on §2.5's assumption that refutations are exhibited only for hypotheses 'the learner uses forever'; a hypothesis never placed in a coalition is never deleted, which is harmless.",
    "evidence": "Line-by-line check. Note that the 'only if' direction uses 2.6(ii), not 2.6(i) as the proof says.",
    "suggested_fix": "Cite 2.6(ii) as well as 2.6(i)."
   },
   {
    "item": "Cor 6.2 (all structural propositional fallacies die) and fallacy table",
    "severity": "ok",
    "description": "Correct given Thm 3.1, which I also checked: h*⊕G(r) is structural and strictly contains C_2, so it equals C_Fm, which is incoherent. The ⊤/⊥ witness and the polynomial (quadratic) Frege bound for evaluating variable-free formulas are standard. Finding the assignment is an NP search.",
    "evidence": "Re-ran fallacy_check.py: every table witness is the unique falsifying assignment ((0,1) for AC, DA, conversion and illicit contraposition; (1,1) for or-as-xor), matching the table.",
    "suggested_fix": "None."
   },
   {
    "item": "§6 non-elimination examples (lines 621-637), esp. example 4 and §0 line 44",
    "severity": "minor",
    "description": "Examples 1–3 are correct: the swap with R:=(x=y) yields ∀x∀y x=y; the switching-0.6 Markov chain gives P(T | last H)=0.6 with stationary marginal ½; base-rate neglect gives 1.8. Example 4 has two problems. (a) The 'completion' it uses, {q→p : (p→q)∈K}, is the per-law converse, not Clark's (1978) completion. Clark's completion disjoins the bodies (wet ↔ rain∨sprinkler), and in the doc's own sprinkler example Clark's completion is consistent while the rule is eliminated. (b) The body correctly claims only 'coherent whenever the completion is consistent', but §0 line 44 says 'survives iff the completion is consistent', and the converse direction is false.",
    "evidence": "Counterexample to the 'iff' (checked in misc.py): K={p1→q1, p2→q2}, A={q1∨q2, ¬p1, ¬p2}. K∪A is consistent, and K∪A∪{q1→p1, q2→p2} is inconsistent. Yet K∪A entails neither q1 nor q2, so the rules q_i ▷ p_i never fire, the closure is Cn(K∪A), and the fallacy survives. Sprinkler check: context+Clark completion is consistent, context+per-law converse is inconsistent.",
    "suggested_fix": "Call the set the 'per-law converse' (conditional perfection) and drop or qualify the Clark attribution. Change §0's 'iff' to 'if'."
   },
   {
    "item": "Prop 6.3",
    "severity": "ok",
    "description": "Correct by Thm 2.6(ii). The example C_2+{▷p17} is coherent only for designated families not containing contexts that entail ¬p17, which the hypothesis 'h*⊕F A-coherent' covers.",
    "evidence": "Direct check.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 6.4 (Kripkensteinian residue)",
    "severity": "minor",
    "description": "(i) and (ii) are correct; (ii) could even be an equality, because any consistent structural extension of IPC lies inside CPC by the ⊤/⊥-substitution argument. (iii) is underspecified. G is not named for arithmetic, and 'Alt = all consistent extensions' holds only for A={∅}. Thm 3.9 allows designated true contexts such as {Con(PA)}, which exclude PA+¬Con(PA). Also, PA+¬Con(PA) is not a completion.",
    "evidence": "With A ∋ {Con(PA)}, PA+¬Con(PA) is A-incoherent and so not in Alt.",
    "suggested_fix": "State (iii) as: 'for G = deductive closure and A={∅}, Alt = all consistent extensions of PA, e.g. PA+¬Con(PA) and its (non-standard) completions; designating true contexts removes some of them, but by Thm 3.9 never all'."
   },
   {
    "item": "Prop 7.1 (mis-designation)",
    "severity": "ok",
    "description": "Correct. (a): C ⊇ C_2 would give A⊢⊥. Some step instance in the derivation is outside C, and by structurality so is its most general instance. This relies on steps being sequents (no discharge metarules), which matches §1's definition of arguments; for discharge metarules the 'most general instance' argument would fail. (b): substitute α for p (⊥ is a constant) and use monotonicity. Note that p,¬p ⊬ ⊥ also implies explosion fails (substitute ⊥ for q).",
    "evidence": "Line-by-line check.",
    "suggested_fix": "Optionally add 'derivations in a Hilbert/sequent-step format' to (a)."
   }
  ],
  "overall": "Sections 4–7 are mathematically sound in their main results, and every check I re-ran or wrote reproduces the claims. Lemma 4.1, Thm 4.2, Thm 4.3 (brute-forced: 0 mismatches on 3 fragments), Thm 4.4(a)–(c) (checked over all 2- and 3-element matrix meanings, ~3.2M combinations; each of the 11 TT(p,q) data and the coherence datum is individually necessary), Prop 4.5 (re-ran the 16384-matrix check: exactly 1 with D={1}; an independent reimplementation agrees), Prop 4.6, Prop 5.1, Thm 5.3, Thm 6.1, Cor 6.2, Prop 6.3 and Prop 7.1 are all correct. One sentence is false: the end of Thm 4.4(d), 'Identification in the limit still holds via the text'. Without structurality BV has no tell-tale (witnesses BV∪{v'_χ}), and BV \\\\ {u0} cannot be told apart from BV even with complete informant data. Minor issues: (1) 'coherence' means two different things in §4, positive in-bounds data versus 0-denial exclusion sequents, which makes the claim 'coherence removes v_⊤' in the Thm 4.3 reading table and §4.5 an equivocation; (2) Thm 4.2's 'any ND metarules' holds only under the global reading; (3) the §0 summary miscounts the 11 data as 'two-conclusion'; (4) carnap_check.py has no denial-rank code although the text says it verifies Thm 4.3; (5) Prop 5.2's '(¬¬-elimination)' alone is conservative, and the harmony-sufficiency remark is refuted by Read's bullet; (6) §6 example 4 misattributes the per-law converse to Clark's completion, and §0's 'iff' is false (counterexample K={p1→q1,p2→q2}, A={q1∨q2,¬p1,¬p2}); (7) Thm 6.4(iii) is underspecified. No novelty is over-claimed: Thm 4.2/4.4(a) are standard (Carnap's junctives, Shoesmith–Smiley, the ∩-closure correspondence) and are attributed as such. My check scripts are in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/ (m45.py, rank43.py, tt44.py, misc.py)."
 }
]
```

---

## Verification log

Three independent adversarial referees checked §2, §3 and §4–7 respectively. Their full reports are reproduced in `verification/T2-coherence-as-negative-data-verification.md`. For each reported issue I re-checked the claim myself, using computation where useful. The repair checks are in `T2-checks/repair_checks.py`; the referees' own scripts are listed in their reports.
* Truth tables for Prop 2.9(b)/(d) with k = 1..4, for the Thm 2.4 memberships and pairwise intersections, and for the Prop 2.8′ coherence pattern on 6 atoms.
* sympy: the cubic $x^3-4x+1$ has discriminant 229, is irreducible, and factors over $\mathbb Q(r)$ as linear × irreducible quadratic.
* Truth tables for the §6 example-4 counterexample and the sprinkler/Clark comparison.
* A tautology check of the revised Thm 3.3 basis.
* A re-run of the referee's Θ* countermodel: 0 violations; $p\to(q\to p\wedge q)\notin\Theta^\*$.
* A re-run of `T2-checks/carnap_check.py` with the new denial-rank check, and of `matrix_check.py` and `fallacy_check.py`.

Severity tags are the referees'. "ok" items with optional suggestions are listed only where I acted on them.

### Referee A (§2)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | Lemma 2.1, bullet 3 ("refuted set independent of π") | minor | yes | **Fixed.** The bullet now separates *logical* exclusion by the designation (the set $\{h:A\vdash_h\bot\}$, which is the same for step sets and consequence relations) from deletion *by the witness* π (the set $\{h:\mathrm{Steps}(\pi)\subseteq h\}$, which depends on π). The referee's example is included. The "bag collapses" paragraph is now conditional on direct membership testing of $A\rhd\bot$. |
| A2 | Thm 2.2 | ok | n/a | **Clarified.** $w(R^\*)>0$ is made explicit. The theorem now says that the bound concerns detections only, and points to Prop 2.9(d). Incompleteness errors are defined in the protocol. Barzdin–Freivalds and Littlestone are credited in Remark (a). |
| A3 | Prop 2.3 | minor | yes (all 3 points) | **Fixed (statement and proof revised).** §0 now says "necessary for guaranteed per-round halving". The worst-case hypothesis is restricted to $P\not\subseteq\bigcap\mathrm{VS}$. Finiteness of VS is dropped, with a σ-additivity proof (I re-derived it: $S_k\downarrow\{R:\hat R\subseteq R\}$). A scope note gives the $\log_{3/2}$ example. |
| A4 | Thm 2.4 | minor | yes | **Fixed.** Majority is now defined relative to $\mathrm{VS}_t$. The claim is restated as "there is an environment (withholding discriminating positive data) under which …". A caveat shows that discriminating data break the paradox. §0 item 1 is qualified. |
| A5 | Thm 2.4 literature paragraph | minor | yes | **Fixed.** The List–Pettit conditions are stated. Gärdenfors (2006), Dietrich & List (2008) and Dokow & Holzman (2010) are added. Nehring & Puppe is kept, flagged (u). All new citations are flagged (u) in the references. |
| A6 | Thm 2.5 | ok | n/a | **Clarified.** The statement now gives $\hat R_t=\bigcap S_t$, the (P)-round rule (noise-free), the $0\cdot\ln(1/0)$ convention, and attribution of the bound to Littlestone–Warmuth (1994). |
| A7–A8 | Thm 2.6, Prop 2.7 | ok | n/a | No change. |
| A9 | Cor 2.8 and §0 item 2 | **major** | **yes** | **Fixed (statement revised; new Prop 2.8′).** I confirmed the referee's counterexample: the coherence pattern was checked by truth tables, and the learner by direct argument.<br>• Cor 2.8 now assumes $\mathcal A$ fixed and known independently of the target. This hypothesis is also made the default in §1.<br>• The title is changed from "superfiniteness" (a misnomer) to "limit points".<br>• New Prop 2.8′: with target-dependent designations and classical reductio, text plus designations is an informant, and the chain-plus-union class becomes identifiable. The referee's example is given there.<br>• §0 item 2 and the §2.5 closing paragraph are qualified.<br>• Downstream uses still hold. Thm 3.6(c) holds because intermediate logics share *all* coherence data, so even target-dependent designations are target-independent. A note is added. Thm 3.9 holds because designations are restricted to *true* contexts. A remark is added showing that this restriction is essential: with false designated contexts $\{\neg\mathrm{Con}(T_k)\}$, the Turing chain becomes learnable. |
| A10 | §2.5 closing sentence | minor | yes | **Fixed.** It now reads "refutation by text plus coherence eliminates every wrong hypothesis exactly when …". It notes that this is not a condition for identifiability, with the referee's two-hypothesis example. |
| A11 | Prop 2.9 (formal) | minor | yes | **Fixed.** "Incompleteness error" is defined (§2.2), the index is now $1\le i\le k$, and (c) and the "only because" sentence are qualified with "𝒜 fixed and known" (pointer to Prop 2.8′). |
| A12 | §2.6 moral, Remark (a), §0 item 1, §8 item 1, §9 OP1 | **major** | **yes** | **Fixed (new Prop 2.9(d),(e); prose rewritten).**<br>• I verified $s_c\in h_b\iff b\neq c$ for k ≤ 4 and the union-learner bound ($h_b\subseteq\mathrm{Cn}\{\neg a_i\}$).<br>• Prop 2.9(d): every learner with $\hat R_t$ inside some surviving hypothesis, hence every OH learner, makes $|\mathcal H|-1$ incompleteness errors on some text for some target. The union learner makes 0 errors of either type.<br>• Prop 2.9(e): in Thm 2.4's class no $\hat R$ halves both error types. Incompleteness-halving forces $\hat R\supseteq$ majority set, which makes π a deletion-free detection.<br>• Remark (a) no longer calls "boldest half" completeness-seeking. The §2.6 reading, §0 item 1, §8 item 1 and §9 OP1 now describe a two-sided trade-off. The false "log₂\|H\| for product classes" is withdrawn.<br>• *Proof detail.* The referee's adversary needs the target chosen at the end: if $\mathrm{VS}_t=\{h_c,h_{b^\*}\}$ and $S_t=\{h_{b^\*}\}$, a fixed target $h_{b^\*}$ would not be charged the last error. So (d) is stated "on some text for some target", the standard adaptive-adversary form for deterministic learners. |

### Referee B (§3)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Thm 3.1 (correctness) | ok | n/a | **Clarified.** The hypothesis "every connective Boolean-interpreted" is added. |
| B2 | Thm 3.1 / §0 item 3 (novelty) | minor | yes | **Fixed.** The status is now "[proved; known: proof included for completeness]", with attribution of the consequence-level form to Wójcicki (1988) and Pogorzelski & Wojtylak (2008), flagged (u). Prop 3.2 is marked "presumably known". §0 item 3 is reworded. |
| B4 | Coherence undefined without ⊥ | minor | yes | **Fixed.** §1 now reads coherence as non-triviality ($h(A)\neq\mathrm{Fm}$; equivalently $A\nvdash_h q$ for a fresh atom when $h$ is structural) in ⊥-free languages. Thm 3.1, Prop 3.2's learning reading and Prop 5.1 refer to it. No proof changes. |
| B5 | Thm 3.3(a) example D; (c) nit | minor | yes | **Fixed.** I re-ran the referee's Θ* countermodel and confirmed that the ∧/∨-as-sequent-rules basis fails. The example now gives the ∧/∨ clauses as →-axioms, with a warning about the failed version. Pure → uses Peirce's law. {¬,∧} and {¬,∨} use Rautenberg (1981), flagged (u). The new axioms were checked to be tautologies. In (c) the non-structural axiom uses an atom not in $A_0$. The general claim of (a) is unaffected. |
| B6 | Prop 3.4 | ok | n/a | **Caveat added.** The identification with the structural completion is stated for finite premise sets, with a note that $C_{\rm adm}$ may be non-finitary. |
| B7 | Prop 3.5(a) | minor | yes | **Fixed.** The language hypothesis is added. The $\{\wedge,\vee\}$ counterexample ($C_{\rm adm}=C_{\rm ai}$) is noted. The bold-learner gloss is rephrased as "largest structural relation with theorem set Taut", plus a two-stage learning procedure. |
| B9 | Thm 3.6(d) wording | ok | n/a | "Atomic generators" is replaced by "finitely many generating sequents". |
| B11 | Thm 3.8 | minor | yes | **Fixed.** "Coherent" is replaced by "consistent", and the referee's 𝒜-coherence counterexample is included. Mostowski (1961) is cited, flagged (u), for r.e. 𝒜. Tarski–Mostowski–Robinson (1953) is cited for extensions of Q. |
| B12 | Thm 3.9 setup | minor | yes | **Fixed.** Targets are $\mathcal K\supseteq\{T_k:k\le\omega\}$ (sound). The Σ₁-unsound theories are reclassified as hypotheses. The theorem is labelled as Gold's chain theorem. The remark on the necessity of true contexts is added (see A9). |
| B13 | Thm 3.10(d) false as stated; novelty | minor | yes | **Fixed.** I checked the counterexample enumeration (Con(PA)∧0=0, ¬Con(PA), Con(PA)). (d) is restated as "limit = Lindenbaum completion along the enumeration; on enumerations beginning with ¬Con(PA) it accepts ¬Con(PA) forever", with a convergence proof. The Popper asymmetry is attributed to Putnam (1965), Gold (1965) and Kelly (1996); §0 item 4 is also adjusted. |
| B14 | Prop 3.11 extrapolated to rule level | **major** | **yes** | **Fixed (statement revised; new parts (b), (c)).**<br>• I verified with sympy the cubic's discriminant (229), its irreducibility and its factorization over $\mathbb Q(r)$. The firing analysis was done by hand.<br>• (a) Theorem-level pinning, as before.<br>• (b) New theorem with proof: parameter-structural, ∃-elimination-closed coherent extensions of $\vdash_T$ equal $\vdash_T$.<br>• (c) The referee's RCF counterexamples without ∃-closure: $x^2=2\rhd x>0$ survives ∅; the $S_3$ cubic rule survives ∅ and $\{c^3-4c+1=0\}$.<br>• "Works as cleanly as in CPC" is withdrawn. §0 item 4, the headline, §8 item 2 and the physics paragraph are revised. |
| B15 | Prop 3.11 examples; exponentiation | minor | yes | **Fixed.** "Dense linear orders without endpoints". Exponentiation is marked open: Wilkie (1996) for model completeness, Macintyre–Wilkie (1996) for decidability under Schanuel. sin on ℝ is the provable source of incompleteness. |
| — | Prop 3.2, 3.5(b), Thm 3.6, Lemma 3.7 | ok | n/a | No change beyond B2 and B9. |

### Referee C (§4–7)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| C1 | Thm 4.4(d), "Identification in the limit still holds via the text" | **fatal** | **yes** | **Retracted and replaced.**<br>• (d) is now marked "(revised after verification)". It states that without structurality BV is not identifiable in the limit, and gives a proof.<br>• *No tell-tale relative to the closed meanings $\mathrm{BV}\cup\{v'_\chi\}$.* So no learner, computable or not, identifies BV from text plus the coherence datum.<br>• *Density.* $\mathrm{BV}\setminus\{u_0\}$ is indistinguishable from BV even by an informant.<br>• The pointwise refutation of each non-Boolean valuation is kept. I checked the argument: $v'_\chi(\neg\chi)=v'_\chi(\chi)$ makes $v'_\chi$ non-Boolean; BV ≅ $2^\omega$ has no isolated points.<br>• §0 item 5 and §4.5 now mention this. |
| C2 | "Coherence" used in two senses in §4 | minor | yes | **Fixed.** The Thm 4.3 table is relabelled: rank 0 = 0-denial non-contradiction sequents. Text distinguishes coherence certifications (positive about V; remove only $V=\emptyset$; never remove $v_\top$) from 0-denial constraints (negative about V; remove $v_\top$). The §4.5 table and H3 verdict are reworded, as are §0 item 5 and the carnap_check labels. The negative conclusion (nothing in either sense removes $v_{\rm Taut}$) is unchanged. |
| C3 | Thm 4.2, "any ND metarules" | minor | yes | **Fixed.** The text now says "read globally", and adds the local-reading example (local →I excludes $v_{\rm Taut}$, i.e. it smuggles in rank-2 information). |
| C4 | §0 item 5, "11 two-conclusion sequents" | minor | yes | **Fixed.** Now: "11 multiple-conclusion sequents (3 with two conclusions, 1 with none, 7 single-conclusion)". |
| C5 | Thm 4.4(a)–(c) | ok | n/a | **Note added.** It reports the referee's brute-force check of individual necessity of the 12 data. I did not re-run it, and it is labelled as the referee's. |
| C6 | Lemma 4.1 / §4.5 table entry | ok (cosmetic) | yes | **Fixed.** The §4.5 entry now reads "up to $(\overline V)^\cap$ ($V^\cap$ for closed V)". |
| C7 | Thm 4.3 needs ¬ | ok | n/a | The assumption is stated. |
| C8 | carnap_check.py does not check Thm 4.3 | minor | yes | **Fixed.** I added the denial-rank computation to `T2-checks/carnap_check.py`. Re-run over all $2^{16}$ valuations: ranks 0/1/2/∞ = 48608/16915/9/4, 0 mismatches with the classification. The coverage claim is narrowed: the structural part of 4.4(b) is not script-checked. |
| C9 | Prop 4.5 wording; dead `triv` code | ok | n/a | **Fixed.** "With designated set {1}" (non-triviality is automatic), with notes on D = ∅ and D = {0}. The dead code is removed from `matrix_check.py`. Re-run: still exactly 1 matrix. |
| C11 | Prop 5.1 needs ⊥ | ok | n/a | A ⊥-free variant (fresh atom; non-triviality) is noted. |
| C12 | Prop 5.2 and harmony remark | minor | yes (all 3) | **Fixed.**<br>• "¬I/¬E plus ¬¬E". ¬¬E alone is conservative, by the ¬φ ↦ φ translation.<br>• "Harmony with normalization". Local harmony alone is refuted by Read's bullet, cited (u). It is now called a heuristic in §5 and §8.<br>• "Strictly weaker" now requires coherence read as non-triviality or ⊥ with ex falso in the base, with the $\mathrm{IPC}_\to+\{\rhd\bot\}$ counterexample.<br>• §0 item 6 is adjusted. |
| C13 | Thm 5.3, Post-string format | ok | n/a | The note on productions matching only tagged old-alphabet strings is added. |
| C14 | Thm 6.1 cites 2.6(i) only | ok | n/a | 2.6(ii) is now cited for the "only if" direction. |
| C16 | §6 example 4 (Clark vs per-law converse; §0 "iff") | minor | yes | **Fixed.** I verified the counterexample ($K=\{p_1\to q_1,p_2\to q_2\}$, $A=\{q_1\vee q_2,\neg p_1,\neg p_2\}$) and the sprinkler claims (Clark's completion consistent, per-law converse inconsistent) by truth tables. The set is renamed "per-law converse (conditional perfection)". Clark's completion is distinguished from it. The condition is stated as sufficient, not necessary, with the counterexample. §0 item 7 now says "if", not "iff". |
| C17 | Prop 6.3 example | ok | n/a | Qualified: "when every designated context is consistent with $p_{17}$". |
| C18 | Thm 6.4(iii) underspecified; (ii) could be equality | minor | yes | **Fixed.** (iii) now specifies 𝒢 = deductive closure and $\mathcal A=\{\emptyset\}$, with a discussion of true designated contexts. (ii) is strengthened to equality ($\mathrm{Alt}=$ all structural $h$ between IPC and CPC), with a $\sigma_v$ proof (new claim; listed for re-verification). |
| C19 | Prop 7.1(a), step format | ok | n/a | The qualifier "Hilbert/sequent-step format, no discharge metarules" is added. |
| — | Lemma 4.1, Prop 4.6, Cor 6.2 | ok | n/a | No change. |

*Rejected issues.* None. Every issue raised at minor or above was genuine on re-checking. The only point where I departed from a referee's suggestion is the proof detail noted in A12.

*Items whose statement or proof changed non-trivially, for re-verification:*
* Cor 2.8, Prop 2.8′ (new), Prop 2.9(d)(e) (new) and the §2.6 reading;
* Prop 2.3 (new proof), Thm 2.4 (restated claim), Lemma 2.1 (bullet 3);
* Thm 3.3(a) (example basis), Prop 3.5(a), Thm 3.8, the Thm 3.9 remark, Thm 3.10(d), Prop 3.11(a)–(c);
* Thm 4.4(d), the Thm 4.3 reading table and §4.5;
* Prop 5.2;
* §6 example 4, Thm 6.4(ii)(iii).
