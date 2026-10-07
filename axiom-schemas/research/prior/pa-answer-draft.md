# Draft answer to: "let's do PA. are you saying you have a result conditional on some unproven conjecture? what is conditional on what? what is your proposal and what result do you have about it?"

## 1. Is anything conditional on an unproven conjecture?

No. Nothing in the formal-math part rests on an open mathematical conjecture. "Conditional" was used in two different senses, and the summary blurred them.

(a) Every theorem has *modelling hypotheses* about the learning situation: realizability (the community's rules lie in the class the learner can identify), a known frequency floor, truthful designated contexts, an exact bounded-depth refutation oracle. These are assumptions about the setup, like "the data are i.i.d." in PAC learning, not unproven mathematics.

(b) The specific word "conditionally" in the success table was about *complete decidable theories* (RCF, Presburger, ACF_p, DLO), not PA. There the exactness corollary needs realizability: every rule of the target calculus must be a first-order pattern that anti-unification (lgg) can recover. For the standard calculi this is false as stated: ∀E (from ∀xφ infer φ[t/x]) has a substitution result as its conclusion, so it is not a first-order pattern, and the lgg of three ∀E instances is the over-general ∀x(z0+z1=z2) ⊢ z3+z4=z5, which has false instances. Same for induction and the degree-indexed families of RCF/ACF_p. So the status is: "exact *if* the calculus is presented with pattern rules; the standard presentations are not; the learner then stays sound but loses those rules." Fixing it is a re-encoding problem (auxiliary decidable Sub(φ,x,t,ψ) judgments, or a new identification theorem for higher-order patterns), not a conjecture.

For PA specifically the paper sidesteps (b): first-order logic is trusted rather than learned, and induction is re-encoded with Sub judgments. So the PA theorem is unconditional within its model; one clause (randomized learners in (d)) is only a proof sketch.

## 2. The proposal, instantiated for PA

Model.
- Judgments: arithmetic sentences; a human "step" is an axiom step ⊢ φ, cited by the name of the schema it instantiates.
- Target Σ*: the genuine non-logical axiom schemas the community uses (genuine = all instances true in ℕ), e.g. Q's axioms + induction, possibly plus true extras like Con(PA).
- Fallacies F: false axiom schemas the community systematically uses, each under its own (latent, distinct) tag.
- Practice Σ^P = Σ* ⊔ F. Human data: i.i.d. tagged instances, with sporadic noise below a known margin.
- Trusted: first-order logic (not learned).
- World W: truth of Δ0 sentences (computation).
- Designated positions ⟨A : D⟩: truthful (A true, D false in ℕ); at least ⟨∅ : ∅⟩.
- Refutation oracle Ref_d(B): brute-force search for a derivation of size ≤ d, using instances of B plus trusted logic, from a designated position to ⊥, to a denied sentence, or to a Δ0 sentence W evaluates false. Cost exp(O(d)); only semi-decidable as d → ∞.

The learner TTL(d, δ) ("audit, then assert"):
1. Burn-in: abstain for N1 = ⌈(1/2Δ²) ln((1+c)K/δ)⌉ human steps (Δ the floor margin).
2. Identify the practice: per tag, trimmed least general generalization → P̂.
3. Audit: B := P̂. Loop: r := Ref_d(B); if none, stop. Else descend on r (Shapiro backtracing: propagate truth values forward and *backward* through the trusted logic steps, find a step with true premises and false conclusion), remove every schema having that step as an instance. If the descent is blocked, remove the union of the minimal conflicts instead (Reiter's hitting-set duality).
4. Freeze A; from then on accept a step iff it is an instance of A (plus trusted logic).
5. Sandbox for conjectures, attacked by a red team; a conjecture enters the asserted tier only once derived from A (as a macro).
6. Optionally re-run the audit at increasing depths d1 < d2 < … (truth maintenance).

## 3. What is proved

General theorem (two-tier learning), specialized: with probability ≥ 1−δ over the human data (an event G that depends only on the first N1 human steps), for every adaptive prover and red team:
- (i) soundness at all times: everything accepted is an instance of Σ* or of the depth-d residue F_res^(d) (fallacies τ with Σ*∪{τ} d-clean); A itself is d-clean.
- (iii) if no descent is blocked, Σ* ⊆ A ⊆ Σ* ∪ F_res^(d): the tier accepts every genuine axiom.
- (iv) under the depth schedule, A changes finitely often and ends sound relative to Σ* ∪ F_res.
- Truth-soundness: if the residue members are true in ℕ (or the residue is empty), the reasoner proves only truths.

Arithmetic-specific theorem ("Arithmetic is Popperian"):
- (a) False Π1 axioms get singleton blame. If τ has a false instance ∀x̄ θ(x̄), θ ∈ Δ0, with least counterexample n̄, the refutation "⊢ ∀x̄θ (by τ); ⊢ θ(n̄) (trusted ∀E)" with W(θ(n̄)) = 0 descends to τ alone. With the prefer-unblocked oracle τ is removed and no PA axiom is put at risk. Depth needed ≈ 2|θ| + m(n+1) + O(1) (unary numerals; m = occurrences of x).
- (b) Under presumption of validity, false Σ1 axioms survive: for practice PA ∪ {⊢ ¬Con(PA)}, PA + ¬Con(PA) is consistent (Gödel II) and proves no false Δ0 sentence (Q is Δ0-complete), so it is clean at every depth and ¬Con(PA) is asserted forever.
- (c) Σ1-caution removes syntactically Σ1 errors: assert an axiom with Σ1 normal form only after W has verified a witness. False ones are never asserted; true ones after an unbounded witness search. It is syntactic: ∀y∃p(Prf_PA(p,⌜⊥⌝) ∨ y≠y), equivalent to ¬Con(PA) but with Π2 normal form, escapes and is residual.
- (d) Beyond Σ1 there is a permanent residue: false Π2/Σ2 axioms consistent with the practice and the designated positions are never refuted, and no computable learner (data + refutation oracle at every depth + Δ0 oracle) sorts true from false Σ2 axioms in the limit (Shoenfield limit lemma + Post's hierarchy theorem). Same for randomized learners correct with probability > 1/2 (proof sketch).
- (e) Finite reflection-extended practices are learned under the floor: with induction written as a pattern via decidable Sub judgments, T_k = PA + Con(PA) + … + Con(T_{k−1}) is identified from positive data for each k within the floor's bound (at most min(K, ⌊1/(2Δ)⌋) schemas). Without a floor there is no uniform sample bound (tight two-point bound t ≥ ln((1−δ)/δ′)/ln(1/(1−π)), where π is the frequency of the Con(T_{k−1}) tag). Over classes containing T_ω no learner identifies in the limit (Turing-chain impossibility).
- (f) Reflection as designation: designating ⟨Con(PA) : ∅⟩ makes ¬Con(PA) a singleton conflict.

Related results in the coherence section: for Π1 π, PA+π is consistent iff π is true; the Popperian learner converges on Σ1 ∪ Π1 with ≤ 1 mind change per sentence; the naive bold learner (add whatever is consistent) is Σ1-unsound on enumerations starting with ¬Con(PA).

Worked illustration (mine, not in the paper): a community that "knows" ∀n. n²+n+41 is prime (Euler) and uses it as an axiom. Primality is Δ0, so this is a false Π1 axiom. Ref_d finds ⊢ ∀n P(n²+n+41) [τ], ⊢ P(40²+40+41) [∀E], and W says 1681 = 41² is not prime; descent blames τ alone; PA survives untouched.

## 4. What this does not give you

- It learns which non-logical axioms the community uses and filters out the false ones it can catch. It never adds an axiom the community doesn't use (positive data are necessary: no refutational evidence certifies a true Π1 axiom).
- Logic is trusted, so fallacies in the logic itself (quantifier swaps etc.) are out of scope for the PA instantiation as stated; learning rules with binders needs the open higher-order-pattern identification theorem.
- The oracle is brute force, exp(O(d)); computation is not addressed.
- Fallacies must be cited under their own (latent) tags; if a fallacy is cited under a genuine axiom's name the theorem does not apply as stated.
- The frequency floor must be known.
- The whole thing is idealized: a "practice" is a finite set of axiom schemas used i.i.d., not real mathematical writing.
- The mathematics is mostly classical (Gödel II, Δ0-completeness of Q, limit lemma, Reiter, Shapiro) transported into the learning model; the paper itself says "none of it is deep mathematics". The contribution is the setup, the assembly with explicit constants, and the matching impossibility results showing each ingredient is needed.
