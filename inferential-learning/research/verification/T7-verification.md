# Verification record: T7-two-tier-coherent-inferential-learner

*Target file: `research/theory/T7-two-tier-coherent-inferential-learner.md`. Two independent adversarial referees checked the file: Referee A covered §§1–4, and Referee B covered §§5–6. Their reports are reproduced verbatim below as JSON, followed by the author-repairer's log, which is also appended to the theory file. The repair checks, together with the referee scripts used as evidence, are in `research/theory/T7-checks/`: `prop32_voting.py`, `ind_sub_lgg.py`, `thm56_finite_d.py` (fixed version), `overlap.py`, `depth_nonmono.py`, `noisefree.py`, `ind_lgg.py`, `lemma61.py` and `matrix4.py`. Round 2 added `two_point_bounds.py`.*

**Outcome in brief.**
* No fatal issues.
* Six major issues. All are genuine and all are fixed:
  * **Prop 2.4(c).** The instance-level equality was false. It is now a schema-level equality, plus a sound instance-level superset.
  * **Prop 3.2.** The voting audit is re-specified, with a corrected call bound and a corrected residue statement and proof.
  * **Prop 5.2(a).** Restated in joint-probability form, relative to the residue, with a proof that TTL satisfies it.
  * **Thm 5.6, "fallback is optimal".** Replaced by (b), a proved schema-level optimality at stable depth, and (c), a computed counterexample at finite depth.
  * **Cor 6.5.** Now conditional on the realizability of the target calculus; ∀E and the infinite axiom families are not first-order patterns.
  * **Thm 6.6(e).** Now requires a Sub-encoded induction schema, whose learnability is computed. The "floor is necessary" remark is replaced by a uniform-sample-bound statement.
* All minor issues are genuine and fixed. No issue was rejected.
* The `ttl_sim.py` table has been regenerated from the script.
* One referee script (`thm56_finite_d.py`) admitted circular derivations. Its printed size of 5 was wrong, but the reported size of 9 is right. The fixed version is in `T7-checks/`.

**Round 2 in brief** (details in the section "Round 2" at the end).
* A re-verification of the round-1 repairs found two major residual issues and one minor one. All three are genuine and fixed:
  * **Thm 5.5.** The round-1 escalation convention does not apply, because the two scenarios have different practices. With practice-following escalation the theorem is false. It now assumes an explicit observational-equivalence condition (OE), with a rewritten proof.
  * **Thm 6.6(e), "what the floor buys".** The transplanted bound was false. It is replaced by the correct mirror-image bound $t\ge\ln\frac{1-\delta}{\delta'}/\ln\frac1{1-\pi}$, which is proved and shown tight.
  * **Size and ground-rule conventions (minor).** Def 1.5 now counts distinct judgments. Def 1.2 now states $c_i:=1$, $\rho_i:=1$ for ground rules, and Thm 4.1 Step 1 uses it.
  * **Cor 6.2 (minor).** `reverification-round2.md` lists this item, but its text is cut off. Best guess: the oracle was wrongly called an instance of the prefer-unblocked rule; this is corrected (R2-4), pending confirmation.
* New author script: `T7-checks/two_point_bounds.py`.

---

## Referee reports (verbatim JSON)

```json
[
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T7-two-tier-coherent-inferential-learner.md",
  "items_checked": [
   "Section 1 model: Defs 1.1-1.6, (Floor), (WS) and the remarks after it, the Ref_d computability claim, the Conf_d stabilization",
   "Lemma 2.1 (a)-(c)",
   "Prop 2.2",
   "Lemma 2.3 (a)-(c) and its Reiter reading; re-ran T7-checks/duality.py (4000 trials, 0 failures, reproduced)",
   "Prop 2.4 (a)-(c), plus a light check of Remark 2.4'",
   "Lemma 2.5 (descent): e^+ soundness, (a)-(c), cost (b)",
   "Section 3.1 algorithm: Phase 0, identification via mgu of trimmed lggs, audit loop, fallback, sandbox, truth maintenance",
   "Lemma 3.1 (a)-(b) and its cost accounting",
   "Prop 3.2, because its count enters Thm 4.1(ii)",
   "Prop 3.3 (a)-(c)",
   "Thm 4.1 clauses (i)-(v): Hoeffding and union-bound constants for N_1, the noise-free N_1, whether G depends only on the first N_1 samples, the depth-schedule argument",
   "Cor 4.2 (quick check)",
   "Re-ran T7-checks/ttl_sim.py with seed 0 and PYTHONHASHSEED=1,2 (deterministic)",
   "Own scripts in the scratchpad: overlap.py (MP/AC instance overlap), depth_nonmono.py (audit across depths), prop32.py (voting audit), noisefree.py (trim budget in the noise-free case)"
  ],
  "issues": [
   {
    "item": "Prop 2.4(c) (presumption after audit), first equality",
    "severity": "major",
    "description": "The identity ∩{R_Σ : Σ maximal in V_d} = R_{Σ^P \\ ∪C_d} is false whenever two schemas from different maximal clean sets share instances. Lemma 2.3(b) gives ∩Σ = Σ^P\\∪C_d at the level of schema sets. But Σ ↦ R_Σ does not commute with intersection; only R_{∩Σ} ⊆ ∩R_Σ holds. The intended soundness conclusion survives, and so does the second claim, F^surv_d ⊆ F^(d)_res. The asserted set that TTL actually uses (R_A, built at the schema level) is still sound. What fails is the claimed equivalence with the instance-level 'cautious across maximal candidates' policy. With it go the readings that rest on it: line 220 says ∪C_d is what such a learner 'must withhold', and Thm 5.6 (line 496, out of scope) says TTL's fallback is 'optimal'.",
    "evidence": "This is the file's own MP/AC example (A = {A_1}, no world). The maximal clean subsets of {MP, AC} are {MP} and {AC}, so Σ^P\\∪C_d = ∅ and R_∅ = ∅. With the step encodings used in T7-checks/ttl_sim.py, MP = st(A, imp(A,B), B) and AC = st(B, imp(A,B), A) unify, with most general common instance st(A, imp(A,A), A) (scratchpad overlap.py). So R_MP ∩ R_AC ≠ ∅. For example st(p0→p1, (p0→p1)→(p0→p1), p0→p1) matches both schemas and is classically valid. The policy ∩R_Σ asserts it; R_{Σ^P\\∪C_d} does not. The policy ∩R_Σ is also sound: it lies inside R_{Σmax} for some maximal clean Σmax ⊇ Σ*, and Σmax ⊆ Σ*∪F_res. So a sound learner can assert some genuine MP instances, and TTL's fallback is not instance-optimal.",
    "suggested_fix": "Replace '=' by '⊇', or define the policy at the schema level (assert R_{∩Σ}). Say that R_{∩Σ} can be strictly smaller. Weaken 'TTL's fallback is optimal' (Thm 5.6) to 'optimal among schema-level policies', or let the fallback assert ∩_{Σ maximal clean} R_Σ, which can be decided by matching and unification."
   },
   {
    "item": "Prop 3.2 (mis-designated positions; voting audit), which feeds Thm 4.1(ii)",
    "severity": "major",
    "description": "The modified audit is underspecified: it does not say which sets are queried under which position, or when the loop stops. Two of its claims fail under the natural reading. (1) 'At most (m+1)|F| successful descents' is false: descents under a mis-designated position output genuine steps, and nothing bounds them. (2) The procedure does not deliver 'fallacies falsifiable under at most m positions join the residue' (implicitly, the others are removed). Ref_d(B,p) always returns the smallest refutation under p, so it can keep blaming a fallacy that never reaches m+1 votes and hide a second fallacy that is falsifiable under m+1 positions. The proof covers only 'no genuine rule is removed', which is correct. Under a position that violates (WS), e^+ may also be ill-defined (it can assign both values), and the proof does not address this.",
    "evidence": "Scratchpad prop32.py. (1) Target {MP}, F = ∅, m = 1, and one bad position [{a, a→b} : {b}]. The audit makes 1 successful descent (it blames MP, which gets 1 vote), but (m+1)|F| = 0. (2) m = 1, with truthful positions p1 = [{q, p→q, ¬p} : {p, ¬q}] and p2 = [{¬r, r→t} : {¬t}], practice {MP, AC, DA}. AC is falsifiable only at p1. DA is falsifiable at p1 and p2, which is m+1 positions. The smallest refutation at p1 blames AC (size 5 < 7). Final votes: AC {p1}, DA {p2}. Final A = {MP, AC, DA}, so DA survives although it is falsifiable under m+1 positions.",
    "suggested_fix": "Specify the audit. For example: for each position p, compute the set of schemas blamed by some descent under p, by querying Ref_d(B', p) for subsets B' that exclude the schemas already blamed. Then remove the schemas with ≥ m+1 votes and iterate. State the descent bound as ≤ |𝒜|·(number of blamed schemas), or restrict the count to descents that produce a removal. Handle positions where e^+ is inconsistent (treat any conflicting value as 'blocked')."
   },
   {
    "item": "Thm 4.1(ii), mis-designation clause",
    "severity": "minor",
    "description": "Thm 4.1 assumes (WS) for every designated position, which forces m = 0. So the clause 'with up to m mis-designated positions ... at most (m+1)|F| descents' is either vacuous (m = 0) or outside the theorem's hypotheses. For m ≥ 1 it inherits the false count of Prop 3.2.",
    "evidence": "Assumptions list at lines 373-376 includes (WS). Clause at line 388. Proof Step 2 at line 409 ('Prop 3.2 gives the mis-designation clause'). Counterexample to the count in the Prop 3.2 item.",
    "suggested_fix": "Move the clause to a separate corollary that assumes (WS) for all but m positions, with a corrected count and residue definition. Alternatively, drop it from Thm 4.1."
   },
   {
    "item": "Thm 4.1(i) vs Section 3.1 Phase 0 (W-settlement)",
    "severity": "minor",
    "description": "Phase 0 says a query is 'settled by W if all its judgments are evaluable'. Clause (i) says 'for t < N_1 nothing is accepted', and (i) claims soundness relative to R*∪R_{F_res}. If W-settled steps are accepted (by the tier or by the reasoner that chains them), they can lie outside Sound(R*): W-truth-preservation is not R*-derivability. They are truth-sound only. It is unclear whether settlement counts as acceptance, and the closure claim in (i) fails if the reasoner chains W-settled steps with R_A steps. Phase 1 has the same issue if W-settlement continues there.",
    "evidence": "Take Σ* = {∧I, ∧E1, ∧E2} (the Σ_1 of Prop 5.1) and the world given by closed-formula evaluation. The query (⊤ / ⊤∨⊥) is fully evaluable and W-truth-preserving, but it is not in Sound(R_{Σ*}). Lines 290 and 381.",
    "suggested_fix": "State explicitly that W-settled answers form a separate channel that is not part of the assertion tier. Note that they are truth-sound (Cor 4.2-style) but not R*-sound, and exclude them from the closure claim in (i), or restrict W-settlement to steps that are W-truth-preserving and in Sound(R*)."
   },
   {
    "item": "Thm 4.1(iii) / Section 3.1, noise-free sample size",
    "severity": "minor",
    "description": "The noise-free N_1 = ⌈λ^{-1} ln(cK/δ)⌉ is justified by T1 Thm 5.3, which is about the untrimmed lgg. Step 1 of the algorithm still sets e_i = ⌊(ᾱ_i+Δ)N_1⌋. With ᾱ_i = 0 and a positive Δ this is a positive trim budget, and then Thm 5.3's event does not imply exact identification (robust genericity is needed). The noise-free variant must set e_i = 0; the text never says so. There is also an edge case: if every tag is a ground rule, c (as in T1 Thm 5.3) is 0 and ln(cK/δ) is undefined, although the failure probability (1−π_i)^N is positive.",
    "evidence": "Scratchpad noisefree.py: K = 1, one metavariable (c = 2), roots uniform on 2 symbols, so ρ = 1/2 and λ = 1/2. Taking Δ = ρβ/2: for δ = 0.001, N_1 = 16 and e = 4, and Pr[identification fails] = 0.077 ≫ δ. With e = 0 it is 3.1e-5. For δ = 0.01: 0.065 vs 0.00098.",
    "suggested_fix": "In Section 3.1 Step 1, write 'noise-free mode: e_i := 0'. Use c_i := max(c_i, 1) for ground rules, as T1 Thm 6.3 does."
   },
   {
    "item": "Thm 4.1(iv) depth schedule, and the glosses in §0 item 3 and §8",
    "severity": "minor",
    "description": "(iv) as stated ('A changes only finitely often, constant for d ≥ d_1*') is correct. The surrounding glosses are not: §0 says 'Raising d produces finitely many retractions', and §8 (line 764) says 'Raising d can only retract warrants'. The union of minimal conflicts is not monotone in d, because a new small conflict can make an old larger one non-minimal. So raising d can also restore a withheld genuine rule, and A is not monotone in d.",
    "evidence": "Scratchpad depth_nonmono.py. Practice {MP, AC}, no world, no trusted steps, positions P1 = [{q, p→q, p→⊥} : ∅] and P2 = [{r, s→r} : {s}] with r = (a∧b)∧(c∧d) and s = (e∨f)∨(g∨h). Both positions are in bounds for the target {MP}. The minimal refutation sizes are 9 for {MP, AC} and 29 for {AC}; {MP} is clean. The audit gives A = {AC, MP} for d < 9, A = ∅ for 9 ≤ d < 29 (fallback, mins {{AC, MP}}), and A = {MP} for d ≥ 29 (fallback, mins {{AC}}). MP is retracted and then restored.",
    "suggested_fix": "Replace 'only retract' with 'changes finitely often, possibly re-asserting withheld genuine rules'. If monotonicity is wanted, define the stage-k tier as the intersection over stages, at a cost in completeness."
   },
   {
    "item": "Thm 4.1(ii) sandbox clause / Prop 3.3(b)",
    "severity": "minor",
    "description": "The bound log2(1/w(R*)) needs R* ∈ H_S with w(R*) > 0. This is not among Thm 4.1's assumptions, and Section 3.1 describes H_S as 'candidate generalizations of asserted schemas or candidate new rules', which need not contain R* (for example, when Coll_d ≠ ∅). Without it the bound is +∞ (vacuous, not false). Also, 'each refutation deletes the hypotheses containing it' must mean containing its untrusted steps. If it means all steps and hypotheses do not include T_rust, coalition members are not deleted and halving fails. Finally, B_t = ∩S_t is a step set, while Def 1.5 defines refutations of schema sets.",
    "evidence": "Line 387 (no hypothesis on H_S). Lines 305-308 and 363. Under (WS), h_0 = R* is safe only if deletion tests Steps(π)\\T_rust ⊆ h, because Steps(π)\\T_rust ⊆ R* would make π an R*∪T_rust refutation, contradicting Lemma 2.1(a).",
    "suggested_fix": "Add 'R* ∈ H_S, w(R*) > 0' (or a clean h_0) to the assumptions of (ii). Define deletion as 'delete h ⊇ Steps(π)\\T_rust'. Extend Def 1.5 to step sets."
   },
   {
    "item": "Prop 3.3(a) (isolation / promotion) vs Thm 4.1(i)",
    "severity": "minor",
    "description": "'Promotion by derivation leaves Cl_{R_A} unchanged' is correct (T1 Lemma 1.1). But if promoted derived rules become accepted single steps, Thm 4.1(i)'s 'every accepted step lies in R*∪R_{F^(d)_res}' fails; only membership in Sound(R*∪R_{F_res}) and the closure inclusion survive. 'The tier is d-clean' also fails: a promoted rule can compress a refutation of size > d into one of size ≤ d. This conflicts with Phase 1's 'accepts q iff q ∈ R_A'. Under the depth schedule, promoted rules also need truth maintenance like cached lemmas.",
    "evidence": "Lines 309, 303, 353 and 382-384. Example: A ∋ τ ∈ F^(d)_res with a shortest refutation of size 2d. A derived rule κ that packages its first half has a refutation of size ≤ d that uses κ.",
    "suggested_fix": "Say that promoted rules are macro-steps expanded into R_A derivations, so they are not accepted as primitive steps. Alternatively, restate (i) as 'accepted ⊆ Sound(R*∪R_{F_res})' and 'A (as a schema set) is d-clean'."
   },
   {
    "item": "Lemma 2.5 (descent), definition of e^+ and cost (b)",
    "severity": "minor",
    "description": "(a) and (c) are correct: e^+ agrees with V, a 0-valued node is never a leaf, and the output step is falsified, hence untrusted and outside Sound(R*). But e^+ is defined as the global closure under all trusted steps, which in general is not computable. So (b)'s 'depth(π)·φ evaluations' counts calls to an uncomputable oracle, and it ignores the cost of forward propagation through subproofs. The lemma works verbatim with local propagation restricted to π's own nodes and trusted steps: that version is sound, computable, and costs O(|π|·φ) ≤ O(d·φ), which keeps Thm 4.1(ii)'s |F|·d·φ. Novelty/citation: descent from a falsified conclusion to a step with true premises and a false conclusion is Shapiro's contradiction backtracing / algorithmic debugging (Shapiro 1981 'Inductive inference of theories from facts'; 1983 'Algorithmic Program Debugging'). It should be cited, as should the 'localization' point it supports.",
    "evidence": "In §6.3, T_rust is all first-order logic rules and D_W is the Δ0 sentences. Forward closure from W-true Δ0 sentences assigns 1 to every true Σ1 sentence (via ∃I) and to none of the false ones, so 'is e^+ defined at j' is Σ1-hard. Lines 249-268.",
    "suggested_fix": "Define e^+_π by propagation within π only. Restate (b) as O(|π|·φ) evaluations of e (a worklist fixed point). Cite Shapiro's contradiction backtracing."
   },
   {
    "item": "Prop 2.2, third bullet",
    "severity": "minor",
    "description": "'In CPC with a complete Σ*, one such step makes every formula derivable (T1 Prop 2.3)' is false in general. T1 Prop 2.3 requires the full instance set of a pure schema (closed under substitution), not one step. Def 1.1 allows impure fallacies, for which even the whole instance set need not trivialize. The claim is true for the closed falsified instance of a pure τ (Lemma 6.1), and for the tier as a whole when τ is pure.",
    "evidence": "A single invalid step (p / q) added to complete CPC leaves Cl(∅) unchanged, because p is not derivable. T1's own example τ = (x∨p1 / x): complete CPC + inst(τ) never derives ⊥ from ∅, since every derivable formula is true when p1 = 0.",
    "suggested_fix": "Write: 'if τ is pure, its closed falsified instance alone makes every formula derivable from ∅; so does the whole of R^P'."
   },
   {
    "item": "Section 1 model: (WS) remark, Ref_d computability, Summary (iii)",
    "severity": "minor",
    "description": "(1) Line 134 says that without a world, '(WS) is equivalent to each position being in bounds'. The converse needs the separate conjunct T_rust ⊆ Sound(R*); being in bounds does not imply it. (2) Line 149 says there are 'finitely many derivations of size ≤ d', which needs a finite signature, or a quotient by renaming of atoms and bound variables. With atoms p0, p1, ... as symbols the count is infinite. (3) World-only falsifications count as refutations only relative to some designated position, so 𝒜 must be nonempty (for example, contain [∅:∅]) whenever world feedback is relied on. (4) Summary (iii) (line 41) says the tier 'equals (Σ*\\Coll_d)∪F^surv_d (bag fallback)'. That holds only if the fallback triggers at B_0 = Σ^P; Thm 4.1 states this correctly.",
    "evidence": "Lines 127-134, 149, 140-142 and 41.",
    "suggested_fix": "Add T_rust ⊆ Sound(R*) to the equivalence. State the finite-signature or renaming assumption. Require [∅:∅] ∈ 𝒜 when D_W ≠ ∅. Qualify the summary."
   },
   {
    "item": "Lemma 3.1 cost accounting (citation)",
    "severity": "minor",
    "description": "Fredman & Khachiyan (1996) dualize an explicitly given monotone DNF or hypergraph. Here only a cleanness (membership) oracle is available. The relevant result is joint generation of minimal conflicts and maximal clean sets (Gurvich & Khachiyan 1999; Boros, Elbassioni, Gurvich & Khachiyan, early 2000s; details from memory, unverified). Its cost is quasi-polynomial in |C_d| + |maximal clean sets|, and the second family can be exponentially larger than the first.",
    "evidence": "Line 335.",
    "suggested_fix": "Cite joint generation and state the output as both families."
   },
   {
    "item": "Prop 3.3(c) (citation)",
    "severity": "minor",
    "description": "First-order unification and the mgu are due to Robinson (1965). Huet (1976) is mainly about higher-order unification, although it includes a near-linear first-order algorithm. The mathematics is fine.",
    "evidence": "Line 364.",
    "suggested_fix": "Cite Robinson 1965 (with Plotkin/Reynolds 1970 for the lattice)."
   },
   {
    "item": "Lemma 2.1 (a)-(c)",
    "severity": "ok",
    "description": "Verified. (a) follows by induction along the derivation, using the total V from (WS). (b) and (c) follow by definition, given deterministic tie-breaking. ∅ ∉ Conf_d, as Lemma 2.3 needs.",
    "evidence": "Line-by-line check of lines 169-177.",
    "suggested_fix": "None."
   },
   {
    "item": "Lemma 2.3 (hitting-set duality)",
    "severity": "ok",
    "description": "All parts verified, including the edge cases 𝒞 = ∅ and a nonempty family of maximal clean sets. Correctly attributed to Reiter 1987 (Thm 4.4) and de Kleer & Williams 1987, both citations accurate. Part (b) is the standard fact that the vertex set of Tr(H) equals the union of min(H). Re-ran duality.py: 4000 trials, 0 failures.",
    "evidence": "The proofs of (b⇐) via T = (U\\C)∪{x} and (c⇒) via E∩T = {x} with E ⊆ ∪𝒞 = T are both correct.",
    "suggested_fix": "None. Could cite Berge's transversal hypergraph for (b)."
   },
   {
    "item": "Lemma 3.1 (audit correctness)",
    "severity": "ok",
    "description": "Verified. The invariant Σ* ⊆ B follows from Lemma 2.5(c). Each successful descent removes at least one fallacy, so there are ≤ |F|+1 calls. NONE implies d-clean, and d-clean implies the residue bound. In the fallback, minimal conflicts inside B_0 are global minimal conflicts (upward closure), so Lemma 2.3 applies on U = B_0. The right inclusion argument is correct.",
    "evidence": "Checked lines 315-330; consistent with the computed example in depth_nonmono.py.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 4.1: N_1 formula, the event G, clauses (i)/(iii) on the descent and fallback paths, (v)",
    "severity": "ok",
    "description": "N_1 = ⌈ln((1+c)K/δ)/(2Δ²)⌉ is correct. The invalid count Bin(N, α_i) with α_i ≤ ᾱ_i exceeds ⌊(ᾱ_i+Δ)N⌋ only if it exceeds the real (ᾱ_i+Δ)N, which has probability ≤ e^{−2NΔ²}. Each witness count has mean ≥ ρ_iβ_iN ≥ (ᾱ_i+2Δ)N and falls to ≤ e_i with probability ≤ e^{−2NΔ²}. That gives 1+c_i events per tag and ≤ K tags. G is defined by counts in the first N_1 samples, with thresholds fixed in advance. A, R_A, the oracle answers (deterministic tie-breaking) and the descent are deterministic functions of those samples, so G depends only on the first N_1 human steps and (i)-(v) hold pathwise for all provers. (One assumption: human answers to escalations in Phase 0 must not be added to the recorded i.i.d. stream; 'human steps are recorded' should say so.) The mgu of the e_i-trimmed lggs equals the trimmed version-space intersection (each lgg(P\\E) with |E| = e_i lies in VS, and every VS member is above one of them). The completeness claim under (SB_d) follows because Coll_d(B_0) ⊆ Coll_d = ∅. The depth-schedule stabilization at d_1* is correct. Caveat: ttl_sim.py tests only the CPC singleton-conflict case, with a fixed e = 2 rather than ⌊(ᾱ+Δ)N_1⌋, and a per-schema world audit rather than Ref_d/descent/fallback. It therefore does not exercise the N_1 formula or the fallback.",
    "evidence": "Recomputed the union bound. Re-ran ttl_sim.py: TTL unsound in 0/80 runs, exact 20/20 at N = 250, positive-only tier unsound in 72/80 (these match §7).",
    "suggested_fix": "Optionally add a simulation of the full audit (descent and fallback) with e_i set from (ᾱ, Δ, N_1)."
   },
   {
    "item": "Cor 4.2 (truth-soundness)",
    "severity": "ok",
    "description": "It follows from R_A ⊆ R*∪R_{F_res}, with all of those steps 𝔐-truth-preserving, by induction on derivations.",
    "evidence": "Direct.",
    "suggested_fix": "None."
   }
  ],
  "overall": "Nothing in Sections 1-3 or in Thm 4.1 is fatal. The main theorem holds as stated: the N_1 constants are right, G depends only on the first N_1 human steps, and the soundness, completeness-modulo-residue and stabilization clauses follow from Lemmas 2.3, 2.5 and 3.1, which are correct. I found two major defects. (1) Prop 2.4(c)'s identity ∩_{Σ maximal clean} R_Σ = R_{Σ^P\\∪C_d} is false at the instance level, because schemas from rival diagnoses share instances. In the file's own MP/AC example, MP and AC share the valid instances (φ, φ→φ / φ). The soundness conclusion survives, but the optimality reading after Lemma 2.3 (and Thm 5.6's 'TTL's fallback is optimal') overclaims. (2) Prop 3.2 is underspecified. Its count of (m+1)|F| descents is false (|F| = 0, m = 1 gives 1 descent), and the per-position smallest-refutation procedure can leave a fallacy that is falsifiable under m+1 positions unremoved (computed example). Its clause in Thm 4.1(ii) is in any case outside the theorem's (WS) hypothesis. The minor issues are:\n- W-settlement in Phase 0 conflicts with 'nothing is accepted' and with R*-soundness.\n- The noise-free N_1 needs trim budget e_i = 0; with e_i as written, identification fails with probability 0.077 against δ = 0.001.\n- The sandbox bound needs R* ∈ H_S.\n- Promoted derived rules break the 'accepted ⊆ R*∪R_F_res' and 'd-clean' wording.\n- e^+ as a global closure is not computable; local propagation on π fixes this, and Lemma 2.5 is Shapiro's contradiction backtracing, which should be cited.\n- Prop 2.2's 'one step trivializes' needs purity.\n- Small gaps in the model (T_rust conjunct, finite signature, nonempty 𝒜).\n- Two citation refinements.\n\nOutside the theorem's own wording, the §0 and §8 glosses that raising d 'can only retract' are false: A can go {AC,MP} → ∅ → {MP} (computed). Out of scope, but noted: the §6.1 table does not reproduce with the current ttl_sim.py. The seed-0 run is deterministic across hash seeds and gives, at N = 120, TTL exact 10/20 and untrimmed exact 8/20 (the table says 9/20 and 5/20); at N = 250, untrimmed 1/20 (table 4/20); and at N = 500, TTL exact 20/20 with one noise>e trial (the table says 18/20, with the 2 failures attributed to >e noise). The headline numbers in §7 (0/80 unsound, 20/20 at N = 250, 72/80) do reproduce. My scripts are in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/: overlap.py, depth_nonmono.py, prop32.py and noisefree.py."
 },
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T7-two-tier-coherent-inferential-learner.md",
  "items_checked": [
   "Prop 5.1 (positive data)",
   "Prop 5.2 (caution) (a),(b)",
   "Prop 5.3 (negative evidence; ->/<-> worlds)",
   "Prop 5.4 (structurality) (a)-(c)",
   "Thm 5.5 (rare refuter) incl. concrete MP/AC/andI instance",
   "Thm 5.6 (blame symmetry): two-point core and MP/AC (-> vs <-) witness",
   "Thm 5.6: clause 'TTL's fallback ... is optimal'",
   "Thm 5.6: bounded Hilbert illustration / caveat / Open Problem 2",
   "Thm 5.7 (depth relativization; halting encoding; Sigma_1 argument)",
   "Prop 5.8 (truthful designation; T2 Prop 7.1)",
   "Lemma 6.1 (closed-instance refutability)",
   "Cor 6.2 (TTL on CPC exact)",
   "ttl_sim.py table in Sec 6.1 / Sec 7",
   "Prop 6.3 (coherence alone on CPC; bilateral repair)",
   "Lemma 6.4 (complete decidable theories)",
   "Cor 6.5 (TTL on complete decidable theories)",
   "Sec 6.2 Remark 1 (complexity citations)",
   "Sec 6.2 Remark 2 (restricted rational oracle, x*x=1+1)",
   "Sec 6.2 Remark 3 (sin interprets Z)",
   "Sec 6.3 setting / (WS)",
   "Thm 6.6(a) Pi_1 singleton blame",
   "Thm 6.6(b) not-Con(PA) survives",
   "Thm 6.6(c) Popperian Sigma_1-caution",
   "Thm 6.6(d) Sigma_2 barrier",
   "Thm 6.6(e) Turing chains / floor",
   "Thm 6.6(f) reflection as designation",
   "Re-ran scripts: ttl_sim.py (3 hash seeds), hilbert_blame.py (L=5,7), matrix_witness.py, duality.py; new checks: Lemma 6.1 brute force (30k schemas), shared-falsifier count check, 4-valued matrix search for {S,DN,AC}, finite-d refutation sizes for Thm 5.6, first-order lgg of induction / forall-E instances"
  ],
  "issues": [
   {
    "item": "Prop 5.2(a) (caution)",
    "severity": "major",
    "description": "Part (a) is stated with a conditional acceptance probability: 'at some history, accepts with probability p ... It is unsound with probability p'. That is exactly the form T1 itself revised away as false for randomized verifiers (T1 Thm 3.1(b): the conditional probability given h is NOT bounded; only the joint probability is). Sec 5 explicitly lets 'a learner' be randomized, so the statement as written is false. Separately, with plain Sound(R_Sigma) and the class of all clean sub-calculi of the practice, the intersection in (a) is empty (Prop 2.4(a)). So (a) also convicts TTL itself and does not separate TTL from the bad learners in (b). Part (b), coalition bullet: whether the coalition accepts a fallacy instance depends on the prior; T2 Thm 2.2(iii) only gives an 'only while' condition, not an acceptance. Part (b), last line: T1 Prop 2.3 needs a substitution-closed accepted set; a single accepted step trivializes only if the prover picks the closed T/F-falsified instance.",
    "evidence": "Counterexample to (a) in T7's own setting. Let L_eps flip a coin at time 0. With prob. eps it accepts every query from time 1 on ('reckless'); otherwise it runs TTL. For every admissible target, Pr(L_eps ever accepts a step outside R* u R_{F^(d)_res}) <= delta+eps. But TTL abstains before N_1, so the history h = (time 1: q_1 accepted) occurs only in reckless mode. Given h, L_eps accepts any fallacy instance at time 2 with conditional probability 1. Read conditionally, (a) would then make L_eps unsound with probability 1 for some target, which contradicts the delta+eps bound. On the second point: Prop 2.4(a) gives empty in V_d, so the intersection over 'targets consistent with all information' is empty for every history. TTL accepts genuine steps w.p. about 1 after N_1, so it violates (a)'s criterion for the target empty-set, and so does every non-trivial learner. Coalition bullet: if the prior puts more than half of its mass on h0 = R*, then S_t = {R*} and B_t = R*, which never contains a fallacy instance.",
    "suggested_fix": "Restate (a) with the joint probability Pr_{R'}[history h occurs and q accepted] <= delta, as in T1 Thm 3.1(b). Note that with random human data a factor Pr_{R'}(data) appears, which equals 1 relative here only because all candidate targets share the practice. State the intersection relative to the residue: q outside the intersection over admissible Sigma of (R_Sigma u R_{F_res(Sigma)}). Under that criterion TTL passes: for x in A outside Sigma, x lies in no minimal conflict, so Sigma u {x} is clean. Qualify the coalition bullet with 'for priors whose weighted majority contains the practice'. For the trivialization claim, say the prover queries the closed T/F instance of Lemma 6.1."
   },
   {
    "item": "Thm 5.6, clause 'so ... TTL's fallback, which withholds U C_d, is optimal'",
    "severity": "major",
    "description": "The two-point argument only shows that the specific rho in the hypothesis (a conflict with swap structure where both Sigma0+rho and Sigma0+tau are clean at every depth) is unassertable. It does not show that every genuine rule in U C_d(B_0) is unassertable. At finite d the general claim is false: a d-minimal conflict can stop being minimal at a larger depth. The rival diagnosis then violates (WS), so it is not a legitimate scenario, and a learner can soundly assert the rule TTL withholds. At stable depth (d >= d_0) the general claim is true, but it needs a different argument via Lemma 2.3, which the file does not give.",
    "evidence": "Computed (scratchpad thm56_finite_d.py, well-founded derivations; size = symbols in distinct judgments). No world, practice {MP, AC}. Positions A1 = {q, p->q, p->bot} and A2 = {phi, bot->phi} with phi = q&(q&q). Minimal refutation sizes: {MP,AC} on A1: 9; {AC} on A2: 13; {MP}: none on either; {AC} on A1: none. For 9 <= d <= 12, C_d = {{MP,AC}}. Descent is blocked (no world, no trusted steps), so the fallback returns A = empty and withholds MP. Under full-depth (WS), the only legitimate targets are {MP} and the empty calculus, since {AC} is refuted on A2. Learner L' = 'after burn-in assert R_MP'. For target {MP} it is sound and complete. For target empty with F = {MP, AC}, MP lies in F^(d)_res and in F_res. So L' is sound in Thm 4.1's sense in every legitimate scenario and strictly more complete than TTL(d). Hence the fallback is not optimal at finite d. At stable depth: take genuine g in Coll(B_0). By Lemma 2.3(b) there is a maximal infinity-clean M contained in B_0 with g not in M. (WS) holds for M via the closure indicator. Each x in Sigma^P \\ M has an instance outside Sound(R_M): for x in B_0 by maximality plus T1 Lemma 1.1; for descended x by its certified falsified instance. F'_res(M) is empty. Data and oracle laws coincide, so g is unassertable.",
    "suggested_fix": "Restrict the optimality clause to d >= d_0 (Conf_d stable) and prove it by the Lemma 2.3 argument above: for every genuine g in Coll_d(B_0), any learner delta-sound in all legitimate scenarios accepts some g-instance with probability <= delta. State explicitly that at finite d the fallback can be strictly suboptimal (example above); the depth schedule of Thm 4.1(iv) repairs this in the limit."
   },
   {
    "item": "Cor 6.5 (TTL on complete decidable theories) and Sec 6.2 setting",
    "severity": "major",
    "description": "Cor 6.5 says 'everything in Cor 6.2 holds verbatim', including A = Sigma*. That runs through Thm 4.1, whose Step 1 (T1 Thm 6.3) needs every practice rule to be a first-order pattern learnable by Plotkin lgg (Sec 1.1: 'first-order terms with metavariables'). The Sigma* the setting asks for is a sequent calculus with forall-introduction/elimination, sound and complete for T. forall-E (phi[t/x]) is not a first-order pattern. T1 Sec 5 only says binders 'plausibly lift' via higher-order PATTERN anti-unification, and forall-E's P t with t arbitrary is not a Miller pattern either. The natural axiomatizations of the listed theories are also outside the class: RCF and ACF_p use degree-indexed infinite families, and Presburger uses an induction schema. On the event G, the identified forall-E tag is an over-general unsound lgg, which the (total) world oracle then refutes and removes. TTL stays sound but A is not Sigma*, so 'exact' fails. No Sigma* in the required class is exhibited for RCF, Presburger, ACF_p or DLO.",
    "evidence": "Computed with T7's own lgg (ttl_sim.lgg; scratchpad ind_lgg.py). forall-E data (all x(x+0=x) / 0+0=0), (all x(0+x=x) / 0+S0=S0), (all x(Sx+0=Sx) / SS0+0=SS0) have lgg (all x(?z0+?z1=?z2) / ?z3+?z4=?z5). That lgg has the invalid instance (all x(0+0=0) / 0+0=S0): true premise, false conclusion. More data can only generalize the lgg further.",
    "suggested_fix": "Either (i) fix an encoding inside the first-order-pattern class and verify Lemma 6.4 for it. One option is an EFS-style calculus with auxiliary decidable judgments Sub(phi,x,t,psi), with forall-E written as forall x phi, Sub(phi,x,t,psi) / psi and W evaluating Sub; then human data must include the auxiliary steps. Or (ii) state and prove an identification theorem for a schema language with binders and substitution, which T1 does not provide. Until then, state Cor 6.5 conditionally ('if Sigma* is realizable in the schema class') and drop the claim that RCF, Presburger, ACF_p and DLO are covered."
   },
   {
    "item": "Thm 6.6(e) (Turing chains identified from positive data) and the 'Achieved: identification of finite reflection-extended practices' summary",
    "severity": "major",
    "description": "The proof says 'T1 Thm 6.3 applies'. It does not, because the PA induction schema phi(0) & all x(phi -> phi(Sx)) -> all x phi is not a first-order pattern, so the realizable tagged single-schema hypothesis of Thm 4.1 fails. The trimmed lgg of induction instances is an over-general schema with false instances. TTL's audit then refutes it with singleton blame (descent through trusted ->E and forall-E) and drops the induction tag. The asserted calculus therefore lacks induction and is not T_k. A second, smaller point: the necessity argument cites T2 Thm 3.9, which needs T_omega in the class. T_omega has infinitely many axioms, so it is not a finite calculus in T7's sense (Def 1.1). Within T7's class of finite targets, the floor is needed only for uniform sample bounds, not for identification in the limit.",
    "evidence": "Computed (scratchpad ind_lgg.py, using ttl_sim.lgg) on four induction instances with phi in {x+0=x, 0+x=x, Sx+0=Sx, x+S0=Sx}. lgg = ((?z0+?z1=?z2) & all x((?z3+?z4=?z5) -> (?z6+?z7=S?z5))) -> all x(?z3+?z4=?z5). False instance: (0+0=0) & all x(0+0=x -> 0+S0=Sx) -> all x(0+0=x). The antecedent is true in N and the conclusion is false. Refutation with trusted logic only: all x(0+0=x) by ->E from the instance and its derivable antecedent, then 0+0=S0 by forall-E, which W evaluates as false. Forward propagation gives the antecedent value 1 and backward propagation through ->E gives the instance value 0, so descent outputs the learned induction schema.",
    "suggested_fix": "Restrict (e) to practices whose axiom schemas are realizable. For example, use a finitely axiomatized conservative extension (such as ACA_0 sentences as ground axioms with trusted second-order logic), or encode induction with auxiliary Sub judgments (Sub(phi,x,0,a), Sub(phi,x,Sx,b) / a & all x(phi->b) -> all x phi). Otherwise supply a new identification theorem for schemas with substitution. Replace the T2 Thm 3.9 necessity remark with a statement about uniform sample complexity over finite targets."
   },
   {
    "item": "Prop 5.1 (positive data)",
    "severity": "minor",
    "description": "The dichotomy 'either unsound for Sigma1 or incomplete for Sigma2' needs R_{Sigma2} to not be contained in Sound(R_{Sigma1}), i.e. some rule of Sigma2 \\\\ Sigma1 is not derivable in Sigma1. Strict inclusion of the schema sets, which is all the statement assumes, is not enough.",
    "evidence": "Sigma1 = {andI, andE1, andE2}, Sigma2 = Sigma1 u {(A&B / B&A)}. Every subset is clean, and accepting all of R_{Sigma2} is sound for Sigma1 (the extra rule is derivable) and complete for Sigma2, so neither horn holds. The example in the file (orI1) does satisfy the missing hypothesis.",
    "suggested_fix": "Add the hypothesis that R_{Sigma2} is not contained in Sound(R_{Sigma1})."
   },
   {
    "item": "Thm 5.5 (rare refuter)",
    "severity": "minor",
    "description": "The core proof is correct: conditioning on E_t gives scenario 2's law, oracle answers are target-independent, and the transfer argument gives s. The first bound is tight: the learner 'accept tau-instances at t iff no rho-tag among the first t samples' has scenario-1 error exactly (1-pi)^t and scenario-2 completeness 1. Local defects: (1) the second inequality needs delta + delta' < 1; (2) the prover's query sequence and the escalation channel must be scenario-independent; (3) the concrete instance says the closure under AC 'with or without andI is finite', which is wrong with andI; (4) the informal gloss is off; (5) rho is overloaded. Novelty: the bound is the standard two-point rare-event lower bound (cf. PAC lower bounds), so listing it under 'What is new' should be toned down.",
    "evidence": "(1) With delta = delta' = 0.6 and pi = 0.5: ln(0.4/0.6)/ln 2 = -0.585 < -0.405 = ((1-pi)/pi) ln(0.4/0.6), so the stated chain fails. (2) The prover 'knows Sigma*, F' (Sec 1.5), so its queries may depend on the scenario. TTL's Phase 0 escalates to a human; if escalation returned target-truthful labels (T1's y_t = 1[q in R*]), one escalated tau-instance would separate the scenarios. (3) Closing under andI gives q&q, (q&q)&q, and so on; the [computed] check covers AC alone only. (4) In t ~ pi^{-1} ln(1/delta) samples MP is seen about ln(1/delta) times, not '1/pi times'. Also, the theorem limits sound ACCEPTANCE of AC in the world where AC is genuine; it is not about 'rejecting' the AC habit. (5) rho is both a schema and the variability rho_i.",
    "suggested_fix": "Add delta + delta' < 1. Fix the prover's queries (scenario-independent) and stipulate that escalation answers reflect the practice, not the target. Say 'infinite but containing no bot' for the andI case. Rephrase the gloss as 'no sound learner can accept a possibly-fallacious schema before ~pi^{-1} ln(1/delta) samples'. Rename the schema rho."
   },
   {
    "item": "Thm 5.6, bounded Hilbert illustration, caveat, and Open Problem 2",
    "severity": "minor",
    "description": "The file says the full-depth status is open because the rival {S,DN,AC} might not be clean, and that Thm 5.6 would apply only if it is. That is a misdiagnosis. {AC,K} and {AC,MP} are minimal conflicts at every depth: {AC} is infinity-clean on {empty, A1}, since its closure on A1 is finite and it derives nothing from the empty position, and {K} and {MP} are sound. So K and MP are necessarily collateral at full depth by the Lemma 2.3 generalization of Thm 5.6, whatever the maximal clean rival turns out to be. Thm 5.6 as stated (swap of exactly rho and tau over a common Sigma0) does not literally apply to the Hilbert practice; the generalized form does. Whether {S,DN,AC} itself is clean remains open; I extended the matrix search from 3 to 4 values and found no witness.",
    "evidence": "Re-ran hilbert_blame.py at L=5 and L=7: same output as the file. scratchpad/matrix4.py: exhaustive backtracking over all 2-, 3- and 4-valued matrices (bottom undesignated; S and DN designated; AC designation-preserving; A1 satisfiable) found none for n = 2, 3, 4 and every |D|. The n=4, |D|=3 case took 5.0M nodes and 242 s.",
    "suggested_fix": "Replace the caveat with the generalized optimality argument at d >= d_0: K and MP are provably collateral at full depth. Keep the open question only as 'which rival is maximal, and are S or DN also collateral at full depth'."
   },
   {
    "item": "Thm 5.7 (depth relativization)",
    "severity": "minor",
    "description": "The halting encoding and the Sigma_1 argument are correct. S = {e : exists t, Pr(accept |-start_e by t) > 1/2} is c.e. given lower-semicomputable acceptance probabilities, and S equals the complement of K, which is not c.e. Presentation gaps: (1) the proof needs computable per-tag data laws and a fixed computable prover, but the statement mentions neither; (2) the 'Indistinguishability' bullet is vacuous. For each e only one scenario exists, so the proof uses computability, not indistinguishability. Also: Sigma0 must contain no 0-premise rules, and the instance (empty, start_e) must not lie in R_{Sigma0}; both are implicit but true for a standard EFS.",
    "evidence": "Proof step 'For a computable learner with computable data laws and oracles ...' introduces an assumption absent from the statement. The statement quantifies over the existence of a family, so the construction may choose computable Lambda_i, but this must be said. Ref_d is computable for each d by brute force, which is fine.",
    "suggested_fix": "Add 'with computable instance laws' to the construction and fix the prover to query |-start_e at every round. Delete or rephrase the indistinguishability bullet."
   },
   {
    "item": "Cor 6.2 (TTL on CPC exact)",
    "severity": "minor",
    "description": "The core result is verified: by Lemma 6.1, every fallacy is a singleton conflict, so (SB) holds, the residue is empty and A = Sigma*. Overclaims and gaps: (1) '(c) The audit makes |F|+1 oracle calls' and the Summary's 'exactly |F| refutations' are false when one falsified step is an instance of several fallacies; the correct statement is 'at most'. (2) The evaluation count sum over tau in F of 2^{v(tau)} omits the checks on genuine schemas needed to certify the final NONE answer. Each candidate also needs several formula evaluations, so the true cost is up to (|F|+1) times the sum over all practice schemas of 2^{v(sigma)}. (3) It needs at least one designated position (A nonempty), since refutations are relative to a member of A. (4) 'Sequent-style natural deduction' with set contexts needs AC-anti-unification, for which T1 Sec 5 says the bounds need re-proof; list contexts with explicit structural rules avoid this.",
    "evidence": "Computed (scratchpad lemma61.py). F = {AC, tau2} with tau2 = (T, A->T / A), which is pure and invalid. The size-5 step s = (T, bot->T / bot) is falsified and lies in inst(AC) and inst(tau2). One descent removes both: 2 oracle calls = |F| and 1 refutation, not |F|+1 calls and |F| refutations.",
    "suggested_fix": "Write 'at most |F|+1 calls' and 'at most |F| refutations'. Account the oracle cost as at most (|F|+1) times the sum over sigma in Sigma^P of 2^{v(sigma)} closed instances. Assume A is nonempty (e.g. [empty:empty] in A). Restrict the ND option to list contexts or cite an AC-lgg result."
   },
   {
    "item": "ttl_sim.py table (Sec 6.1, Sec 7)",
    "severity": "minor",
    "description": "The script is deterministic (identical output under PYTHONHASHSEED = 0, 1, 2), but the published table does not match its current output. The qualitative claims reproduce: TTL is unsound in 0/80 runs, exact in 20/20 at N=250, and the positive-only tier is unsound in 72/80. The parenthetical explanation for N=500 is contradicted.",
    "evidence": "Re-run: N=120 TTL exact 10/20 (table 9/20) and untrimmed exact 8/20 (table 5/20). N=250 untrimmed exact 1/20 (table 4/20). N=500 TTL exact 20/20 (table 18/20); one trial has noise > e on some tag, and TTL is still exact in it. That contradicts 'the 2 failures are exactly the trials with > e noise'.",
    "suggested_fix": "Regenerate the table from the committed script and remove or correct the N=500 parenthetical. A plausible reason a high-noise trial can still be exact is that the excess noise landed on a fallacy tag."
   },
   {
    "item": "Prop 6.3 (coherence alone on CPC)",
    "severity": "minor",
    "description": "(a) and (c) are correct. Gaps: in (a), d_tau is used but defined only in Sec 6.2. In (c), d must be at least the size of the counterexample instances, which is left implicit. In (b), the examples violate Sec 6.1's standing assumption that Sigma* is complete for classical consequence in the full language: Sigma* = {MP} is not complete, and {K,S,MP,DN} is complete only for {->, bot}. And 'necessarily so (Thm 5.6)' is not covered by Thm 5.6 as stated for the Hilbert case. The claim survives: in any complete Hilbert extension, {AC,K} stays a minimal conflict, so K is collateral, and necessity follows from the generalized (stable-depth) Thm 5.6. But it is depth-dependent (see the finite-d counterexample under Thm 5.6).",
    "evidence": "Sec 6.1 Setting: 'Sigma* is any finite set ... complete for classical consequence'. Prop 6.3(b) uses Sigma* = {MP} (core) and {K,S,MP,DN} with A = {empty, A1}. The core example is outside the setting.",
    "suggested_fix": "Define d_tau in Sec 6.1. In (b), use a complete full-language Hilbert system (K stays collateral) and cite the generalized optimality argument at stable depth."
   },
   {
    "item": "Sec 6.2 Remark 2 (restricted rational oracle)",
    "severity": "minor",
    "description": "Under Sec 6.2's own semantics, a judgment's free variables are universally closed (W(Gamma |- phi) = M |= forall x(...)). So the designated position [{x*x=1+1} : empty] asserts forall x (x*x=2), which is false in R: the position violates (WS) and is not 'truthful in R'. And the fallacy written as the sequent axiom 'x*x=1+1 |- bot' gives bot only via cut or substitution, which are learned Sigma* rules. The conflict is then {tau, cut}, not a singleton. If the fallacy is instead the rule '|- t*t=1+1 / |- bot', then under universal closure every instance has a false premise, since no integer polynomial t satisfies forall x t^2 = 2. That rule preserves W-truth and is not a fallacy at all (Lemma 6.4(a)). T2 Prop 3.11(c), which the remark echoes, uses parameters (fresh constants c), which Sec 6.2 does not have.",
    "evidence": "Sec 6.2 setting: W(Gamma |- phi) := [M |= forall x-bar(/\\Gamma -> phi)]. T2 Prop 3.11(c): 'h1 is caught by the designated context {c*c=1+1}', with c a parameter.",
    "suggested_fix": "Introduce parameters (constants with an intended interpretation, e.g. c -> sqrt 2) or designate the sentence 'exists x x*x=1+1' with trusted exists-E. State the fallacy so that its refutation uses only trusted steps, or call the result a two-element bag."
   },
   {
    "item": "Sec 6.2 Remark 1 (complexity citations)",
    "severity": "minor",
    "description": "Davenport & Heintz (1988) prove a doubly-exponential lower bound for real QUANTIFIER ELIMINATION (output degree and size). They do not show that deciding RCF sentences, which is what W does, needs doubly-exponential time. As far as I recall (not re-verified), RCF decision is in EXPSPACE (Ben-Or, Kozen & Reif 1986), and the known decision lower bound is exponential (Fischer & Rabin 1974, for real addition). The Presburger 2^{2^{Omega(n)}} citation is right.",
    "evidence": "The text says 'W costs doubly-exponential time for RCF (Davenport & Heintz 1988)'.",
    "suggested_fix": "Say 'quantifier elimination is doubly exponential (Davenport & Heintz); deciding sentences is in EXPSPACE and needs at least exponential time (Fischer & Rabin)', and mark it (u) if unverified."
   },
   {
    "item": "Sec 6.3 setting / (WS)",
    "severity": "minor",
    "description": "(WS) requires T_rust to lie within Sound(R*). In Sec 6.3, R* consists of non-logical axiom schemas only (0-premise steps) and T_rust is first-order logic, so the inclusion fails literally: Cl_{R*}(Pi) is just Pi plus the axiom instances. That bullet is not used by Lemmas 2.1 and 2.5, which need only that V does not falsify trusted steps, but as written (WS) is violated.",
    "evidence": "The forall-E step (forall x theta / theta(0)) is not in Sound(R*) when R* contains only axioms: theta(0) is not in {forall x theta} union the axiom instances.",
    "suggested_fix": "In Sec 6.3, define the target closure as Cl_{R* u T_rust}, or drop the third (WS) bullet where logic is trusted."
   },
   {
    "item": "Thm 6.6(a) (false Pi_1 axioms, singleton blame)",
    "severity": "minor",
    "description": "The descent argument is correct. The depth bound is wrong: the refutation contains both forall x theta and theta(n), and each free occurrence of x is replaced by a numeral of size n+1, so the bound must be about 2|theta| + m(n+1) + O(1), where m is the number of occurrences of x. Also, singleton blame is guaranteed only if the audit descends on this refutation. TTL's Ref_d returns the lexicographically least among the smallest refutations, and for arithmetic no descent-preferring modification is stated (unlike Cor 6.2). A blocked smallest refutation would trigger the fallback, and Q or PA axioms could become collateral. So 'No PA axiom is put at risk' needs that oracle modification.",
    "evidence": "theta(x) := x < S^5 0, least counterexample 5. The judgments 'forall x(x<S^5 0)' (10 symbols) and 'S^5 0 < S^5 0' (13 symbols) total 23, against the claimed |theta| + |n| + O(1) = 8 + 6 + O(1). In general the size is 2|theta| + m(n+1) + O(1), and neither |theta| nor m*n is O(1).",
    "suggested_fix": "State d >= 2|theta| + m(n+1) + O(1) (or instantiate x by a short closed term rather than a numeral). Have Ref_d prefer descent-unblocked refutations, as in Cor 6.2."
   },
   {
    "item": "Thm 6.6(c) (Popperian Sigma_1-caution)",
    "severity": "minor",
    "description": "The policy is syntactic ('axioms of the form |- exists x theta, theta in Delta_0'). Con(PA) is standardly a negated existential (or a universal), so not-Con(PA) is not literally of that form; 'not-Con(PA) included' needs a stated computable normalization (prenex, double-negation removal). False axioms that are logically or PA-equivalent to Sigma_1 sentences but have higher-complexity syntax escape the policy, and are residual by the argument of (b). Recognizing semantic Sigma_1-ness is undecidable. For schematic Sigma_1 axioms with infinitely many instances, 'assert once a witness is verified' works only per instance, so Phase-1 acceptance stops being decidable by matching.",
    "evidence": "tau' = |- forall y exists p (Prf_PA(p, bot) or y != y) is logically equivalent to not-Con(PA), with Pi_2 prenex form. PA + tau' is consistent (Goedel II) and Delta_0-sound (T2 Lemma 3.7), so it is clean at every depth and residual. The Sigma_1-caution as stated does not apply to it, so presumption asserts it forever.",
    "suggested_fix": "Define the policy on a fixed computable normal form and restrict the claim to 'false axioms whose normal form is Sigma_1'. Note that equivalent disguises survive (consistent with (d)). Treat schematic Sigma_1 axioms instance-wise and acknowledge semi-decidable acceptance."
   },
   {
    "item": "Thm 6.6(d) (Sigma_2 barrier)",
    "severity": "minor",
    "description": "Correct as a reduction to Shoenfield and Post. It also holds for randomized learners with success probability > 1/2: the decided set is {e : exists s forall t p_{s,t}(e) > 1/2}, which is Sigma_2, and its complement is Sigma_2 symmetrically. The phrase 'consistent with Sigma*' should be 'consistent with Sigma* together with the assertions of the designated positions'. Sec 6.3 allows truthful positions with non-Delta_0 assertions (e.g. Con(PA) in (f)), which can refute a Pi_2 or Sigma_2 axiom that is consistent with PA alone.",
    "evidence": "In the Sec 6.3 setting, A consists of truthful positions with no Delta_0 restriction, and (f) designates Con(PA).",
    "suggested_fix": "Replace 'consistent with Sigma*' with 'consistent with Sigma* u A for every designated [A:D]'. Optionally add the one-line randomized-learner remark."
   },
   {
    "item": "Prop 5.3 (negative evidence)",
    "severity": "ok",
    "description": "Verified. With identical practice, frequencies and instance laws, the positive-data laws coincide in W1 and W2 (-> read as <->), so a learner without refutation evidence is unsound in W1 or incomplete in W2. The separating closed instance (T, bot->T / bot) is classically falsified and has a false premise (bot <-> T) under <->. This matches T1 Cor 6.5.",
    "evidence": "Checked by hand; AC under <-> is 'from B and A<->B infer A', which is valid.",
    "suggested_fix": "None."
   },
   {
    "item": "Prop 5.4 (structurality)",
    "severity": "ok",
    "description": "(a) is TOSU and correct: a finite derivation implicates finitely many instances. (b) matches T2 Prop 6.3 (C2 + {|> p17}). (c) matches T1 Sec 4: 'the bare version space never generalizes: intersection of VS(P) = P, because exception-lists are hypotheses' (T1 line 407).",
    "evidence": "Citations cross-checked against T1 and T2.",
    "suggested_fix": "None."
   },
   {
    "item": "Thm 5.6, two-point core and MP/AC (-> vs <-) witness",
    "severity": "ok",
    "description": "The two-point argument is correct (same practice, frequencies and oracle answers; the transfer lemma gives a rho-instance outside Sound(R_{Sigma0 u tau})), and so is the minimality of {rho, tau}. The MP/AC witness checks out: {MP} is sound and A1 is satisfiable (p=0, q=1). The AC-closure of A1 is {q, p->q, p->bot, p}, computed. Under the <- reading, A1 = {q, q implies p, bot implies p} is consistent (p=q=1), AC becomes MP and MP becomes AC. The world instance (bot->bot, bot->(bot->bot) / bot) and the denial [A1 : p] both break the symmetry.",
    "evidence": "hilbert_blame.py at L=5 and L=7 reproduces: core {MP,AC} on A1 has the single minimal conflict {AC,MP} and diagnoses {MP} and {AC}. With [A1 : p], the conflicts are {{AC}} and collateral is empty. The 4-step {AC,K} derivation from the empty position was checked by hand.",
    "suggested_fix": "None for the core; see the separate entries for the optimality clause and the Hilbert caveat."
   },
   {
    "item": "Prop 5.8 (truthful designation)",
    "severity": "ok",
    "description": "Cited claims match T2 Prop 7.1(a) (an inconsistent designated context forces the loss of some classical schema everywhere) and Prop 3.2. Small wording point: Prop 3.2 needs a known bound m on the number of bad positions, not knowledge of which ones are 'suspect'.",
    "evidence": "T2 Prop 7.1 cross-checked.",
    "suggested_fix": "Optional: 'at most m positions (unknown which) violate (WS)'."
   },
   {
    "item": "Lemma 6.1 (closed-instance refutability)",
    "severity": "ok",
    "description": "Correct; this is the standard Post/T2 Thm 3.1 step. For sequent judgments with context metavariables, substituting {T} or {bot} for Gamma according to v(/\\Gamma theta) also works, so the size claim extends.",
    "evidence": "Brute force (scratchpad lemma61.py): 30,000 random pure schemas with 0-2 premises over 3 metavariables (16,309 invalid). Generic-instance invalidity coincided with T/F-substitution refutability in every case, with 0 mismatches.",
    "suggested_fix": "None."
   },
   {
    "item": "Lemma 6.4 (complete decidable theories)",
    "severity": "ok",
    "description": "Correct under the universal-closure semantics: if all premises are true, Cl(Pi) = Cl(empty) = the W-true sequents; if some premise is false, ->I and forall-I give the false closed sentence, T refutes it, and bot follows. forall-I needs the eigenvariable side condition, which T1 Sec 5 treats as a predicate filter. Its usefulness depends on Sigma* existing in the schema class; see the Cor 6.5 entry.",
    "evidence": "Checked line by line.",
    "suggested_fix": "None for the lemma itself."
   },
   {
    "item": "Thm 6.6(b) and 6.6(f)",
    "severity": "ok",
    "description": "(b): PA + not-Con(PA) is consistent (Goedel II) and proves no false Delta_0 sentence (T2 Lemma 3.7), so it is clean on Delta_0-truthful positions at every depth and residual. (f): with Con(PA) designated, tau gives not-Con(PA), the trusted not-E step gives bot, and backward propagation assigns not-Con(PA) the value 0, so descent blames tau alone. Sec 6.2 Remark 3 is also fine: sin defines pi as its least positive zero, hence Z, so the theory is undecidable.",
    "evidence": "Checked by hand against T2 Lemma 3.7, Thm 3.9(iii) and Thm 3.10.",
    "suggested_fix": "None."
   }
  ],
  "overall": "No fatal error was found in §§5–6. The central lower bounds hold in substance: Thm 5.5 (proof correct; its first bound is tight), the two-point core of Thm 5.6 with the MP/AC (→ vs ←) witness, Thm 5.7 (the halting encoding and Σ₁ argument check out), Lemma 6.1 (30k-schema brute force), Cor 6.2's exactness for CPC, Lemma 6.4, and Thm 6.6(b,f). Four items need material change. (1) Prop 5.2(a) restates T1 Thm 3.1(b) with conditional probabilities, which is false for randomized learners: the explicit 'reckless with probability ε' counterexample shows this, and T1 itself revised it. Relative to plain Sound(R_Σ), (a) also convicts TTL, so it should be stated relative to the residue. (2) Thm 5.6's clause 'TTL's fallback ... is optimal' is not proved, and it is false at finite d. In a computed example a minimal d-conflict {MP,AC} (d=9..12) stops being minimal at d=13, where {AC} alone is refuted, so asserting MP is sound in every legitimate scenario while TTL(d) withholds it. At stable depth the claim holds via a short Lemma 2.3 argument, given in the report. That argument also shows K and MP are necessarily collateral at full depth in the Hilbert example, so Open Problem 2 is moot for necessity; the matrix search was extended to 4 values and found no witness for {S,DN,AC}. (3) and (4): Cor 6.5 and Thm 6.6(e) apply Thm 4.1/T1 Thm 6.3 to calculi containing ∀E and the PA induction schema. These are not first-order patterns: using T7's own lgg code, the lgg of induction instances and of ∀E instances is computed to be over-general, with explicit false instances. TTL would then audit away induction or ∀E, so 'exact' and 'T_k is identified' fail unless a realizable encoding (EFS-style auxiliary substitution judgments, or a new higher-order identification theorem) is supplied. Minor issues: Prop 5.1 lacks a non-derivability hypothesis. Cor 6.2's 'exactly |F|+1 calls / |F| refutations' fails (a shared falsifier of AC and (⊤, A→⊤ / A)), and its evaluation count leaves out the genuine schemas. Thm 6.6(a)'s depth bound misses 2|θ| and the occurrence multiplicity. Σ₁-caution in (c) is syntactic. §6.2 Remark 2's position is not truthful under universal-closure semantics and its conflict is not a singleton. The Davenport–Heintz citation is imprecise. The ttl_sim.py table does not reproduce: the script is deterministic but some numbers differ, and the N=500 explanation is contradicted, though the qualitative claims hold. New check scripts are in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/ (ind_lgg.py, lemma61.py, matrix4.py, thm56_finite_d.py)."
 }
]
```

---

## Verification log

Two independent adversarial referees checked this file: Referee A for §§1–4 and Referee B for §§5–6. Their full reports are reproduced in `verification/T7-verification.md`. For each reported issue I re-checked the claim myself and re-ran every referee script.
* `ttl_sim.py` with seed 0 under several `PYTHONHASHSEED` values; plus a diagnostic of the one $N=500$ trial with > e noise, whose excess noise is on the fallacy tag XOR.
* `overlap.py`, `depth_nonmono.py`, `noisefree.py`, `ind_lgg.py`, `lemma61.py`, and `matrix4.py` (no witness with ≤ 4 values; 235 s).
* `thm56_finite_d.py`. The referee's version admitted circular derivations and printed 5 instead of 9 for {MP, AC} on $A_1$. The fixed version enforces well-foundedness and confirms the reported sizes 9 and 13.
* New author scripts: `prop32_voting.py` (revised voting audit) and `ind_sub_lgg.py` (Sub-encoded induction is a learnable pattern).

All referee scripts used as evidence are now in `T7-checks/`, with a header saying they were written by a referee. Severity tags are the referees'. Every issue was found genuine; none was rejected. "ok" items are listed only where I acted on an optional suggestion.

### Referee A (§§1–4)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | Prop 2.4(c), first equality $\bigcap R_\Sigma=R_{\Sigma^P\setminus\bigcup\mathcal C_d}$ | major | Yes. $\Sigma\mapsto R_\Sigma$ does not commute with ∩, and MP/AC share the valid instances $(A,A\to A/A)$ (re-ran `overlap.py`). | **Fixed (revised after verification).** The equality is now stated at the schema level, $R_{\bigcap\Sigma}$. The instance-level set $\bigcap R_\Sigma$ is shown to be a superset, possibly strict, and also sound and $d$-clean (new proof). The reading after Lemma 2.3 is weakened to "must withhold as schemas", with forcing only at stable depth. Thm 5.6's "optimal" is replaced by schema-level optimality at stable depth (B2). §8's MP gloss is refined. |
| A2 | Prop 3.2 (mis-designated positions) | major | Yes. Both counterexamples reproduced (`prop32.py`): one descent against a bound of 0, and DA kept although refutable at $m+1$ positions. | **Fixed (revised after verification).** The voting audit is now fully specified. Each position runs its own descent loop, excluding already-blamed schemas, with the prefer-unblocked oracle; a conflicting $e^+_\pi$ certifies a bad position. New claims: (a) no genuine rule is removed; (b) at most $|\mathcal A|(|F|+1)+m|\Sigma^\*|$ calls; (c) $A\cap F\subseteq F^{(d,m)}_{\rm res}$, defined via complete positions, reducing to Lemma 3.1(a) when $m=0$. New proof. `prop32_voting.py` shows DA removed and AC kept. |
| A3 | Thm 4.1(ii) mis-designation clause | minor | Yes: outside the (WS) hypothesis, which forces $m=0$, and its count was false. | Clause removed from Thm 4.1, with a note; Step 2 adjusted; the assumptions now say "(WS) for every position". |
| A4 | Phase 0 W-settlement vs Thm 4.1(i) | minor | Yes: the step $(\top/\top\vee\bot)$ is $W$-truth-preserving but not $R^\*$-sound for $\{\wedge\mathrm I,\wedge\mathrm E_{1,2}\}$. | Defined a separate **world channel**, which is not part of the tier. Thm 4.1(i) now concerns the tier only. Cor 4.2 now covers chaining world-channel steps (truth-soundness). Human answers to escalated queries are not added to the sample. Remark 4 clarified. |
| A5 | Noise-free $N_1$ / trim budget; $c=0$ for ground rules | minor | Yes (re-ran `noisefree.py`: 0.077 vs $3\cdot10^{-5}$ at δ = 0.001). | Noise-free mode now sets $e_i:=0$, with $c\ge\max_i\max(c_i,1)$ and $\rho_i:=1$ for ground rules. Updated in §3.1, Thm 4.1(iii) and Step 1. |
| A6 | Depth-schedule glosses ("only retract") | minor | Yes (re-ran `depth_nonmono.py`: {AC, MP} → ∅ → {MP}). | §0 item 3, Thm 4.1(iv) and §8 corrected: $A$ changes finitely often, is not monotone, and can restore withheld schemas. $d_1^\*$ is defined for either tie-breaking rule. |
| A7 | Sandbox bound needs $R^\*\in\mathcal H_S$; deletion rule; refutations of step sets | minor | Yes. | Prop 3.3(b) and Thm 4.1(ii) now assume $h_0$ clean at every depth with $w(h_0)>0$. Deletion is defined as $h\supseteq\mathrm{Steps}(\pi)\setminus T_{\rm rust}$. Def 1.5 is extended to step sets, and Lemma 2.1(a) generalized to $S\subseteq\mathrm{Sound}(R^\*)$. §0 updated. |
| A8 | Promotion vs "accepted ⊆ $R^\*\cup R_{F_{\rm res}}$" and $d$-cleanness | minor | Yes. | Promoted rules are now **macros**, expanded into $R_A$-derivations (§3.1). Prop 3.3(a) states what weakens if they were primitive. Truth maintenance covers macros. Thm 4.1(i) says "the schema set $A$ is $d$-clean". |
| A9 | Lemma 2.5: global $e^+$ not computable; cost; Shapiro citation | minor | Yes. | $e^+$ is replaced by the local fixed point $e^+_\pi$ over π's judgments, with cost $O(|\pi|\varphi)$. Lemma revised; new part (d): each blamed schema is a singleton $d$-conflict, used in Thm 5.6(b). Shapiro (1981, 1983), contradiction backtracing, cited. |
| A10 | Prop 2.2 third bullet (one step trivializes) | minor | Yes: a single $(p/q)$ does not. | Restricted to pure τ and its closed ⊤/⊥ falsified instance, with the argument given. Prop 5.2(b) aligned. |
| A11 | §1 model: (WS) equivalence, finite derivations, nonempty $\mathcal A$, Summary (iii) | minor | Yes, all four. | (WS)'s third clause dropped (see also B14). New equivalent form: (WS) ⟺ Σ* clean at every depth, via the closure-indicator valuation for $R^\*\cup T_{\rm rust}$. Finite-signature or renaming qualification for $\mathrm{Ref}_d$. Convention $[\emptyset:\emptyset]\in\mathcal A$ when $D_W\ne\emptyset$. Summary (iii) qualified. |
| A12 | Lemma 3.1 cost: Fredman–Khachiyan citation | minor | Yes. | Joint generation from a membership oracle cited (Bioch–Ibaraki; Gurvich–Khachiyan; Boros et al.; marked (u)), with output both families. |
| A13 | Prop 3.3(c) citation (Huet) | minor | Yes. | Robinson (1965) cited for first-order mgu; Plotkin/Reynolds for the lattice; Huet's entry annotated. |
| A-ok | Lemma 2.3 | ok | — | Optional suggestion adopted: Berge's transversal hypergraph cited for (b). |
| A-ok | Thm 4.1 caveat: `ttl_sim.py` scope | ok | — | Scope note added under the §6.1 table, plus a "full audit" experiment in §9. |

### Referee B (§§5–6)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Prop 5.2(a) (conditional probability; plain soundness) | major | Yes. T1's reckless counterexample transfers, and with plain Sound the intersection is trivial and convicts TTL. | **Fixed (revised after verification).** Restated in joint-probability form over admissible targets (new §5 conventions), relative to the residue. New proof that TTL passes: $R_A\subseteq R_\Sigma\cup R_{F^{(d)}_{\rm res}(\Sigma)}$ for every admissible Σ. Coalition bullet qualified by the prior. Trivialization claim restricted to the closed ⊤/⊥ instance of a pure τ. |
| B2 | Thm 5.6, "TTL's fallback is optimal" | major | Yes. False at finite $d$; reproduced with well-founded derivations (`thm56_finite_d.py`, fixed). | **Fixed (revised after verification).** (a) keeps the correct two-point core; the optimality clause is removed. New (b), [proved]: at stable depth every $g\in\bigcup\mathcal C_d(B_0)$ has an instance no learner sound in all admissible scenarios accepts with probability > δ; hence schema-level optimality, which also holds on the descent path. New (c): the finite-$d$ counterexample. Combined with A1: not instance-optimal. §0, §2.3 reading, §3.2 and the §5 table updated. |
| B3 | Cor 6.5 (∀E, axiom families not first-order patterns) | major | Yes (re-ran `ind_lgg.py`: the ∀E lgg is over-general with an invalid instance). | **Fixed (revised after verification).** Cor 6.5 is now conditional on realizability. Caveat added: ∀E, and the degree-indexed or induction schemas of RCF, ACF$_p$ and Presburger, are not first-order patterns; DLO is finitely axiomatized. Stated what happens without realizability (sound, not exact). Two repairs sketched: Sub-encoding, or a higher-order-pattern theorem. §0, §6.2 Remark 3, §8 and §9 weak point 1 updated. |
| B4 | Thm 6.6(e) (induction not a pattern; T2 Thm 3.9 and $T_\omega$) | major | Yes (re-ran `ind_lgg.py`: false instance of the induction lgg). | **Fixed (revised after verification).** (e) now assumes a Sub-encoded induction rule, a first-order pattern whose lgg is recovered from generic instances (new `ind_sub_lgg.py`). The necessity remark is replaced by "the floor buys uniform sample bounds", with a two-point argument ([proved; TOSU]), and T2 Thm 3.9 is restated as a limit result over classes containing $T_\omega$, which lies outside Def 1.1. §6.3 setting and summaries updated. |
| B5 | Prop 5.1 missing non-derivability hypothesis | minor | Yes: $\Sigma_2=\Sigma_1\cup\{(A\wedge B/B\wedge A)\}$. | Hypothesis $R_{\Sigma_2}\not\subseteq\mathrm{Sound}(R_{\Sigma_1})$ added, with the counterexample. |
| B6 | Thm 5.5 (δ+δ′<1; scenario-independence; ∧I closure; gloss; ρ overloaded; novelty) | minor | Yes, all points (checked: −0.585 vs −0.405). | Added δ+δ′<1; fixed prover and practice-following escalation (§5 conventions); ∧I closure corrected (infinite, no ⊥); gloss rewritten; schema ρ renamed μ (also in Thm 5.6); tightness of the first bound noted; novelty toned down in §0 and §9. |
| B7 | Hilbert caveat / Open Problem 2 | minor | Yes: {AC,K} and {AC,MP} are minimal conflicts at every depth. | Caveat rewritten: K and MP are necessarily collateral at full depth (Thm 5.6(b)). Open Problem 2 restated as whether Coll∞ also contains S or DN. `matrix4.py` re-run: no witness with ≤ 4 values. |
| B8 | Thm 5.7 presentation | minor | Yes. | Statement now includes computable instance laws and a fixed prover querying $\vdash\mathrm{start}_e$. The "indistinguishability" bullet is replaced by "uniformity". $\Sigma_0$ having no 0-premise rules is made explicit. |
| B9 | Cor 6.2 ("exactly" counts; evaluation cost; $\mathcal A\ne\emptyset$; set contexts) | minor | Yes (re-ran `lemma61.py`: shared falsifier of AC and $(\top,A\to\top/A)$). | "At most" $|F|+1$ calls and $|F|$ refutations. Cost now includes the genuine schemas: $(|F|+1)\sum_{\Sigma^P}2^{v}$, or $\sum_{\Sigma^P}2^{v}$ with caching. The oracle is specified and shown exact. $[\emptyset:\emptyset]\in\mathcal A$. List contexts with structural rules; Lemma 6.1's sequent extension noted. |
| B10 | `ttl_sim.py` table does not reproduce | minor | Yes (re-run matches the referee exactly). | Table regenerated from the script. The $N=500$ parenthetical corrected: the one >e-noise trial had its excess noise on the fallacy tag XOR and is still exact. Explanatory bullet added. §7 updated. |
| B11 | Prop 6.3 ($d_\tau$ undefined; examples outside the standing assumption; necessity) | minor | Yes. | $d_\tau$ defined in Def 1.6; Lemma 6.4's quantity renamed $f_\tau$. (b) restated for any complete full-language Hilbert system with $\mathcal A=\{[\emptyset:\emptyset]\}$ (optionally $+A_1$), where {AC,K} is a minimal conflict at every depth, with necessity from Thm 5.6(b). The computed examples are flagged as outside the assumption. |
| B12 | §6.2 Remark 2 (position not truthful; not a singleton) | minor | Yes. | Rewritten: the designated sentence $\exists x(x\cdot x=1+1)$, fallacy $\vdash\neg\exists x(x\cdot x=1+1)$, trusted logic, so descent gives singleton blame. Bag $\{\tau,\neg\mathrm E\}$ without trusted logic; bilateral variant noted. |
| B13 | §6.2 Remark 1 (Davenport–Heintz) | minor | Yes. | Corrected: QE is doubly exponential (D–H); deciding RCF sentences is in EXPSPACE (Ben-Or–Kozen–Reif, (u)); exponential lower bound already for real addition (Fischer–Rabin, (u)). |
| B14 | §6.3 violates (WS)'s third clause | minor | Yes. | Third clause dropped globally (§1.3). Target closure $\mathrm{Cl}_{R^\*\cup T_{\rm rust}}$ used in Thm 4.1(i) and §6.3. |
| B15 | Thm 6.6(a) depth bound; oracle tie-breaking | minor | Yes (checked $\theta=x<S^5 0$: size 23). | Bound corrected to $2|\theta|+m(n+1)+O(1)$ (with a $k$-variable form). The prefer-unblocked oracle (§3.1 variant) is now required. |
| B16 | Thm 6.6(c) syntactic Σ₁-caution | minor | Yes. | Normal form fixed; claim restricted to axioms with Σ₁ normal form. Disguise example and its residual status stated. Schematic case: acceptance becomes a semi-decision. |
| B17 | Thm 6.6(d) hypothesis; randomized learners | minor | Yes. | Hypothesis now "clean at every depth", e.g. $\Sigma^\*\supseteq Q$ and $\Sigma^\*\cup\{\tau\}\cup A\cup\neg D$ consistent for every designated position. Randomized-learner remark added [sketch]. |
| B18 | Prop 5.8 wording | ok (optional) | — | Adopted: "at most $m$ positions (it is not known which) violate (WS)". |

*Items whose statement or proof changed non-trivially, for re-verification:* (WS) and its equivalent form (§1.3); Lemma 2.1(a); Prop 2.4(c); Lemma 2.5 (local $e^+_\pi$, new (d)); Prop 3.2; Prop 3.3(a)(b); Thm 4.1 (i)–(iv) and proof Step 1; Prop 5.2(a); Thm 5.5; Thm 5.6(b)(c); Prop 6.3(b); Cor 6.2(c); Cor 6.5; §6.2 Remark 2; Thm 6.6(a),(c),(d),(e).

---

## Round 2

### Re-verifier findings (as transmitted to the author)

A re-verification of the round-1 repairs reported these residual issues. They are reproduced from the task statement given to the author-repairer. The re-verifier's full report was not transmitted.

1. **MAJOR — Thm 5.5 (burn-in is necessary: the rare refuter), revised scenario-independence conventions.** The revised statement assumes "escalation answers follow the practice (§5 conventions)". But the §5 convention only gives the same law in every scenario with that practice, and in Thm 5.5 the two scenarios need not have the same practice. So the convention does not deliver what the proof needs. Fix the statement or conventions so that the two-point argument is valid, for example by stating explicitly an observational-equivalence assumption on all channels including escalations, or by restricting to channels without escalation. Then re-check the proof.
2. **MAJOR — Thm 6.6(e), the remark "What the floor buys" and its proof line.** The stated bound $t\ge\ln((1-\delta')/\delta)/\ln(1/(1-\pi))$ is false. In Thm 5.5 the rare tag lives in the scenario where acceptance is unsound, whereas here the rare tag $\mathrm{Con}(T_{k-1})$ lives in the other scenario. Correct or retract the remark, deriving the right two-point bound, if any, carefully.
3. **MINOR.** Lemma 2.5(d) needs a size convention under which size counts distinct judgments (derivations as DAGs or sequences); make Def 1.5 consistent with it. Thm 4.1 proof Step 1 uses ground-rule conventions ($c_i:=1$, $\rho_i:=1$) without stating them; state them.
4. **MINOR — Cor 6.2 (oracle specification; Lemma 6.1-based exactness).** This item was not in the task statement. It appears in `verification/reverification-round2.md`, where its text is cut off after: "Exactness is correct: if B contains a fallacy τ, its closed ⊤/⊥ instance is a one-step refutation of size ≤ |τ| ≤ d relative to [∅:∅]; otherwise there is no refutation at any size. All descents are unblocked, and the counts in (c), at most |F|+1 calls and at most |F| successful descents, and the cos…". See R2-4 below.

The re-verifier also asked the author to re-read the round-1 majors and make sure that their repairs are consistent with the round-2 changes:
* Prop 2.4(c);
* the Prop 3.2 voting audit;
* the conditional-probability form of Prop 5.2(a);
* the optimality clause of Thm 5.6;
* the scope of Cor 6.5 for complete decidable theories;
* whether T1 Thm 6.3 applies to the induction schema in Thm 6.6(e).

### Author-repairer log, round 2 (also appended to the theory file)

A re-verification of the round-1 repairs found two major and one minor residual issue. I re-checked each one, agreed with all three, and repaired them as below. A fourth, minor item on Cor 6.2 appears in `verification/reverification-round2.md` but is cut off there; R2-4 records my best guess at it. I also re-read the six round-1 majors against the new changes; that check follows the table. New check script: `two_point_bounds.py` (author, round 2).

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| R2-1 | Thm 5.5: the round-1 statement assumed that escalation answers "follow the practice (§5 conventions)". That convention gives equal laws only for scenarios with the *same* practice, and Thm 5.5's two practices differ. | major | Yes, and it is worse than a proof gap: with practice-following escalation the conclusion is false. Some μ-instance $s_\mu$ lies outside $\mathrm{Sound}(R_{\{\sigma,\tau\}})$. A human with practice $\{\sigma,\tau,\mu\}$ confirms it, and one with practice $\{\sigma,\tau\}$ rejects it, so one escalation separates the scenarios. [computed: `two_point_bounds.py` (C), the cap 0 becomes 1.] | **Fixed.** The statement now assumes **(OE)**: every non-sample input is generated from the history by the same kernel in both scenarios. (OE) is shown to hold for $\mathrm{Ref}_d$ and $W$ (Lemma 2.1(c)), for the fixed prover and red team, for non-escalating learners and for TTL's tier. It is shown to fail for practice-following and target-truthful escalation. The proof is rewritten with the identity $P_1^{\otimes t}\vert_{E_t}=(1-\pi)^tP_2^{\otimes t}$ and a common kernel $K_t$. Tightness is checked by linear programming over all tag sequences: 0 mismatches in 108 cases. The §5 conventions are rewritten, so that the escalation convention is scoped to same-practice results (Props 5.2–5.3, Thms 5.6–5.7). A scope remark on membership queries is added, and §0, §4 Remark 4, §9 weak point 3 and the Reading are qualified. |
| R2-2 | Thm 6.6(e), "what the floor buys": the bound $\ln\frac{1-\delta'}\delta/\ln\frac1{1-\pi}$ is false. In Thm 5.5 the rare tag lives in the scenario where acceptance is unsound; here $\mathrm{Con}(T_{k-1})$ lives in $T_k$, where acceptance is sound. | major | Yes. Counterexample: take $\pi=1/2$, $\delta=10^{-6}$, $\delta'=0.1$. The round-1 bound demands $t\ge19.8$. The learner "accept iff the tag has occurred" is 0-sound under $T_{k-1}$ and accepts with probability 0.9375 at $t=4$ [computed]. | **Fixed by correcting the bound.** The correct mirror-image bound is $\Pr_k(\text{accept at }t)\le1-(1-\delta)(1-\pi)^t$. Hence $t\ge\ln\frac{1-\delta}{\delta'}/\ln\frac1{1-\pi}$ when $\delta+\delta'<1$. It is proved in place and shown tight, both by an explicit learner and by linear programming (0 mismatches in 108 cases). It is still unbounded as $\pi\to0$, so "no uniform bound without the floor" survives. The text explains why the bound scales with $\ln(1/\delta')$, not $\ln(1/\delta)$. (OE) and the reading as calculus-soundness (Con is true) are added, and the proof line of (e) is corrected. The undefined $1/\pi_{\min}$ in the tag bound is replaced by $\lfloor1/(2\Delta)\rfloor$. |
| R2-3 | Lemma 2.5(d) needs size to count distinct judgments, which Def 1.5 did not say. Thm 4.1 Step 1's $(1+c_i)$ count needs T1 Thm 6.3's ground-rule convention, while Def 1.2 cited T1 Thm 5.3, which has $c_i=0$ and leaves $\rho_i$ undefined for ground rules. | minor | Yes, both. | **Fixed.** Def 1.5: a derivation is a sequence (DAG) of distinct judgments, size counts distinct judgments, and tree derivations compress without growing. The computed minimal refutations repeat no judgment, so their numbers (9, 13, 29) are unchanged. The proof of Lemma 2.5(d) now orders the extracted judgments by fixed-point stage and shows that they are distinct. Thm 5.6(c) cites Def 1.5. Def 1.2 now sets $c_i:=1$, $\rho_i:=1$ for ground rules (T1 Thm 6.3), so $c_i\ge1$ for every tag. §3.1, Thm 4.1(iii) and Step 1 cite this one convention. In noisy mode a ground tag gives two events, which are T1 Thm 6.2(b)(i)–(ii). In noise-free mode, T1 Thm 5.3's separate ground-rule term becomes $c_ie^{-N\pi_i\rho_i}$. |
| R2-4 | Cor 6.2 (oracle specification). `verification/reverification-round2.md` lists this as a minor item. Its text is cut off there after confirming exactness, unblocked descents and the counts in (c), and it was not in the task statement. | minor | Partly reconstructed. The one inaccuracy I found in the oracle specification is the sentence calling the closed-instance oracle "an instance of the prefer-unblocked tie-breaking". Its answer need not be the smallest refutation. | **Fixed (best guess at the truncated item).** Cor 6.2 now says that the oracle is exact and deterministic, which is all that Lemma 3.1 and Steps 1–4 of Thm 4.1 use; the tie-breaking rule enters only in Step 5, which is trivial here because the answers do not depend on $d$ once $d\ge\max_\tau|\tau|$. A related change follows from R2-3: in Lemma 6.1 the closed instance has size **at most** $|\tau|$. **The re-verifier should confirm whether this was the intended point.** |

*Consistency of the round-1 majors with the round-2 changes.*
* **Prop 2.4(c).** Unaffected. The schema-level equality and the instance-level superset use neither escalation nor the size convention.
* **Prop 3.2.** Unaffected. It uses Lemma 2.5 only through (c) and the consistency certificate.
* **Prop 5.2(a).** Its admissible targets share the practice, so this is a case where the escalation convention does apply. A sentence in the proof now says so.
* **Thm 5.6.** All scenarios in (a) and (b) share the practice, so the convention applies.
  * (b) uses Lemma 2.5(d), whose size bound now rests on Def 1.5.
  * The sizes 9 and 13 in (c) count distinct judgments, as Def 1.5 now says.
* **Cor 6.5.** Unaffected; it remains conditional on realizability.
* **Thm 6.6(e).** The identification part is unaffected. The ground axioms ($\mathrm{Con}(T_j)$, Q) fall under the Def 1.2 convention. The floor remark is replaced (R2-2), and the applicability of T1 Thm 6.3 rests, as before, on the Sub-encoding.
* **Thm 5.7** (not a round-1 major, but it uses the conventions). It has the same practice in both cases. The proof now notes that practice-following escalation answers are computable, so the reduction is unaffected.

*Items to re-verify after round 2:*
* Def 1.2 (ground-rule convention) and Def 1.5 (derivations and size);
* the proof of Lemma 2.5(d);
* Thm 4.1(iii) and proof Step 1, both modes;
* the §5 standing conventions;
* Thm 5.5: statement with (OE), proof, tightness and the scope remark;
* Thm 6.6(e): the floor remark, its proof line, and the tag-count bound;
* the last bullet of the proof of Thm 5.7;
* Lemma 6.1 (size at most $|\tau|$) and the oracle bullets of Cor 6.2 (R2-4);
* `two_point_bounds.py`.
