# Verification record: T4-informal-math-latent-formalization.md

Target file: `../theory/T4-informal-math-latent-formalization.md`. Project context: `../00-brief.md`.

This record holds:
1. a faithful copy of the three independent adversarial referee reports (rendered from JSON to Markdown, content unchanged);
2. the author-repairer's verification log: for each reported issue, whether it is genuine and what action was taken.

The same log is appended to the theory file as `## Verification log`. Scripts written for the repair are in `../theory/T4-checks/verification_checks.py` (run by `run_all.sh`). The referees' own scratch scripts, cited inside their reports, lived in a session scratchpad and are not part of the repository.

---

## Part 1. Referee reports

### Referee A (Sections 1–3)

**Items checked.**
* Formal model definitions (§1.1-1.4, Def 1.1, Assumption BG, channels P/C/O, §2.1 consistency / VS_t, Def 2.1)
* Lemma 2.2 (argument soundness)
* Prop 2.3 (equivocation / Cauchy sum theorem)
* Thm 2.4 (deterministic soundness)
* Thm 2.5 (time-uniform soundness, class prior) + Remark 'gauge redundancy helps'
* Prop 2.6 (resource-bounded checking) [in §2, checked as a bonus]
* Thm 2.7 (escalation costs)
* Prop 2.8 (expansion makes the verifier complete)
* Def 3.1 and Prop 3.2 (no learner sees past the shadow) [checked because Thm 3.4(b) uses it]
* Lemma 3.3 (informal completeness)
* Thm 3.4(a)-(c)
* Thm 3.4(d) (bounded-gap data)
* Prop 3.5 (transfer / ontology unidentifiable)
* Prop 3.6 (eps-delta vs IST)
* Prop 3.7 (Benacerraf)
* Re-ran T4-checks/run_all.sh (all scripts run; none of them cover §§1-3)
* New brute-force scripts: scratchpad/thm34d.py, thm34d_full.py (Thm 3.4(d)) and l33.py (Lemma 3.3, Thm 3.4(a),(c); 1500 random propositional instances)

**Issues.**

#### A-1. Thm 3.4(d) (bounded-gap data: survivor characterization) — severity: fatal
* *Description.* The claim that the eventual survivors are exactly the h in U* with St^g_h ⊇ St^g_{h*} is false. Bounded-gap practice data plus complete object data never refute a rival whose informal consequence relation is strictly weaker than h*'s on D*, provided it still contains every g-short step of h*. Such a rival is not in U*, yet it survives forever. The proof's 'Case 2 is unchanged' is where it breaks: in (c), Case 2 relied on ⊨_{h*} ⊆ ⊨_h on D*, which came from the failure of Case 1 under a complete closure-level presentation. In (d), the failure of Case 1 gives only St^g_{h*} ⊆ St^g_h. The second half of (d) is still true: the accepted relation equals St^g_{h*}, because h* survives and every survivor contains St^g_{h*}. The commentary 'a hypothesis that makes the same inferences in coarser steps is never excluded' is therefore incomplete: rivals with strictly fewer valid inferences (a different meaning) are never excluded either. So with realistic bounded-gap data (BG2), ≈ is NOT identified. Only St^g_{h*} is identified. This undercuts §3.5 item 2 ('verification depends on nothing else, Thms 2.4 and 3.4(c,d)') and §3.5 4(b), and it is misused in Prop 3.6.
* *Evidence.* Counterexample. Language: 0-ary predicates p0..p3 (a propositional fragment of FOL), one context. D* = occurrences read as p0, ¬p0, p3, ¬p3, with ∼ toggling, so D* is negation-closed. h*: T* = {p0→p1, p1→p2, p2→p3}, and R* = a one-step tautological-consequence library plus the 0-premise axiom steps ⊢τ for τ in T*. h: same L and ρ, T_h = ∅, R_h = the tautology library. Both are first-order complete. For g ≤ 3, an R*-derivation with ≤ g applications uses ≤ g−1 < 3 chain axioms, and any proper subset of the chain has only tautological consequences on {p0, p3}. So St^g_{h*} = St^g_h on D*. But ({p0}⇒p3) ∈ ⊨_{h*} \ ⊨_h, so h ∉ U*. Mod(T*) ⊆ Mod(∅) gives V_{h*} ⊆ V_h, so no object datum refutes h. Every A that is coherent for h* is coherent for h. So h survives. The script /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/thm34d.py finds 7 (target, rival) mismatches for each of g=1,2,3 and 0 for g=4. When p1 and p2 are also readable (thm34d_full.py), it finds 0 mismatches.
* *Suggested fix.* Correct the statement to: survivors = {h : St^g_h ⊇ St^g_{h*} and ⊨_h|_{D*} ⊆ ⊨_{h*}}. Coherence on 𝒜 is then automatic, and the proof is Case 1 for St^g plus the Case-2 argument, which never used ⊨_{h*} ⊆ ⊨_h. Alternatively, add the hypothesis that h* is step-expressive on D* (every ⊨_{h*}-step on D* is a chain of St^g_{h*}-steps through D*). Then St^g_h ⊇ St^g_{h*} implies ⊨_h ⊇ ⊨_{h*} on D* by cut-closure (Lemma 2.2), and the original characterization holds; the script confirms this. Update the 'What (d) says' paragraph, §3.5 item 2 and 4(b), and Prop 3.6 to match.

#### A-2. Prop 3.6 (ε-δ versus IST) [cited; sketch] — severity: major
* *Description.* (1) The sketch's key step ('the reduction algorithm IS a contextual reading into ZFC, so h_W ≈_D h_IST') does not hold for literal infinitesimal talk. Nelson's reduction algorithm yields IST ⊢ ∀^st t (A(t) ↔ B(t)) only for standard values of the parameters. Leibnizian lines ('let dx be infinitesimal; then ...') and arbitrary contextual objects ('let f be continuous') introduce parameters that IST does not prove standard. For such occurrences, ρ_IST and any ZFC reading are not IST-provably equivalent, so ≈_D is not established. (2) The final bullet misapplies Thm 3.4(d) in the wrong direction. (d) protects rivals with COARSER g-step relations (supersets). If infinitesimal proofs are shorter, then St^g_{IST} contains steps that are not in St^g_W, and noise-free bounded-gap Leibnizian data refute h_W outright by Case 1. That data is decisive against h_W as a hypothesis, though not against its ≈-class.
* *Evidence.* (1) Take an unlimited N and the contextual f(x)=Nx. f is ε-δ continuous at 0, but under the literal IST reading ∀x(x≃0 → f(x)≃f(0)) it fails at x=1/N. The two readings agree only when f is standard. (2) By Thm 3.4(d) Case 1, any s ∈ St^g_{h*} \ St^g_h refutes h. With h* = h_IST and h = h_W, the premise 'infinitesimal proofs are plausibly shorter' says exactly that such an s exists.
* *Suggested fix.* Specify that ρ_IST reads every contextual constant with an st(·) assumption, and folds infinitesimal suppositions into bound variables, e.g. (c, ξ) ↦ ∀dx(dx≃0 ∧ dx≠0 → ξ). Then IST conservativity plus transfer give the ≈_D claim on that domain. Restrict D accordingly. Replace 'never decisive against h_W' with: 'decisive against h_W as a granularity hypothesis, but h_W and h_IST lie in the same ≈-class, so the identified meaning is unaffected.'

#### A-3. Lemma 3.3 (informal completeness) — severity: minor
* *Description.* (a) Clause (iii) as written ('A ⊭_h y for some y') is false whenever X ⊋ D_h, which is the typical case for a partial ρ. Any y outside D_h makes the step invalid by the domain clause, whatever A is. (b) The gloss 'So ⊨_h, V_h and the coherence data determine one another' overclaims in two ways. V_h = ∅ (T_h inconsistent) does not determine D_h, and so does not determine ⊨_h. Coherence on a fixed family 𝒜 of designated contexts cannot determine ⊨_h. (c) Novelty: §0 and §8 list this lemma among 'the parts with real mathematical content'. It is a direct corollary of Lindenbaum/compactness plus Gödel completeness: the classical-negation-respecting bivaluations closed under a first-order consequence relation are exactly the model-induced valuations. That is standard. Parts (i) and (ii) and the proofs are otherwise correct.
* *Evidence.* (a) Take A={x, ∼x} with x ∈ D_h, so A is incoherent, and take any y0 ∈ X \ D_h. Then A ⊭_h y0. (b) h1 and h2 with inconsistent T and D_{h1} ≠ D_{h2} both have V = ∅ but different ⊨. Brute force (scratchpad/l33.py; 1500 random propositional instances with random partial negation-closed readings, including inconsistent T) found 0 failures for (i), and 0 for (iii) once y is restricted to D_h.
* *Suggested fix.* Write (iii) as 'iff A ⊭_h y for some y ∈ D_h'. Weaken the gloss to '⊨_h determines V_h and coherence; V_h determines ⊨_h when V_h ≠ ∅'. Describe the lemma as a standard corollary of completeness and compactness rather than new content.

#### A-4. Thm 3.4(a)-(c) — severity: minor
* *Description.* The statements are correct, and I verified the proofs line by line, including the step in (c) that U* is never refuted by object data when D_h ⊋ D*. Three precision gaps remain. (a) needs D_h ≠ ∅, a hypothesis of Lemma 3.3 that Thm 3.4 does not restate. (b) uses the closure-level (≡_∞) analogue of Prop 3.2, which is stated only for ≡_g with St^g-labelled oracles. (c) is information-theoretic, not effective. In Case 1, refuting h requires certifying s ∉ ⊨_h, which is co-r.e. and not semi-decidable for, e.g., T_h = ZFC. So 'survivors after finitely many data' is not computable, unlike the budgeted VS_t of §2.1. Also, the 'conservative verifier' in (c) must be a closure-level V^∞, since V^g accepts only g-steps.
* *Evidence.* (a) h1 = (consistent T, empty ρ) and h2 = (inconsistent T, empty ρ) have ⊨ = ∅ for both, but V_{h1} = {∅-function} and V_{h2} = ∅, so h1 ≈ h2 but not h1 ≡_∞ h2. (c) Random brute force (scratchpad/l33.py, 1500 instances) found 0 failures of 'survivors = U*' or of (a).
* *Suggested fix.* Add D_h ≠ ∅. State Prop 3.2 for g = ∞ explicitly. Note that (c) describes the ideal version space (refutation by non-derivability is not semi-decidable), and name the verifier V^∞.

#### A-5. Thm 2.5 and the Remark 'gauge redundancy helps' (also §0 item 1) — severity: minor
* *Description.* The theorem and its proof are correct. The Ville supermartingale argument carries over from T1 Thm 4.2. Deterministic object, paradox and oracle data contribute indicator likelihood ratios ≤ 1. Shadow-measurability gives w_t([h*]) = W*/Z_t. The accompanying claims overstate what W* counts. W* is the prior mass of the ≡_g class: formalizations with identical St^g, V and coherence. It is not the mass of the meaning (≈) class. The Remark lists 'equivalent axiomatizations' and 'ε-δ or infinitesimal readings' as contributing. Equivalent axiomatizations generally change derivation lengths and hence St^g. Prop 3.6 explicitly declines to claim that the ε-δ and infinitesimal readings have equal g-step relations. §0's 'redundant formalizations of the same meaning help' is therefore misleading.
* *Evidence.* Def 3.1: ≡_g requires St^g_h = St^g_{h'}. Prop 3.6, 2nd bullet: 'Whether the g-step relations also coincide is not claimed.' Under Lemma 3.3, ≡_g ⊆ ≈, usually strictly.
* *Suggested fix.* Restrict the Remark to formalizations with the same g-shadow (e.g. renamings). Alternatively, state that the ≈-class mass matters only for a closure-level verifier.

#### A-6. Thm 2.7 (escalation costs) — severity: minor
* *Description.* (a) and (b) are correct. In (a), escalated honest steps form an elastic chain because VS_t ⊆ {h : St^g_h ⊇ earlier positives}, and el ≤ |H^g| − 1 ≤ |H/≡_g| − 1. In (b), T1 Thm 4.4 carries over with Z_t ≥ W*. Two problems remain. (1) Part (c) says both bounds are 'tight up to the constants of T1', but its proof cites only T1 Thm 3.9, which concerns (a). For (b), T1 Cor 4.5 gives a lower bound of (1−δ')(1/W*−1) against an upper bound of ln(1/(W*δ''))/(W*δ'). The gap is a factor of about ln(1/W*)/δ', not a constant. (2) Def 2.1 allows ESC = 'ask the prover to expand'. That produces no label and shrinks no version space, so such escalations are unbounded. The bounds hold only for oracle-answered escalations.
* *Evidence.* With uniform prior on the single-culprit class (W* = 1/n) and δ = W*δ', the upper bound is about n·ln(n/δ'')/δ' and the lower bound about (1−δ')(n−1).
* *Suggested fix.* Say that (b) is tight up to a factor ln(1/W*)/δ' (T1 Cor 4.5), and count only escalations answered by the oracle.

#### A-7. Formal model definitions (§1, §2.1, Def 2.1) — severity: minor
* *Description.* (1) §1.3 says 'Larger steps, those h*-valid but not g-valid, also occur' in practice. §2.1 checks practice data against St^g_h, so a single larger human step refutes h* even at η = 0. Thms 2.4 and 2.5 implicitly need every practice datum to be in St^g_{h*}, or need larger steps modelled as noise in the likelihood. (2) 'The size bound makes St^g_h decidable' also needs ρ_h computable with decidable domain, decidable R_h (a decidable library), and a treatment of languages with infinitely many symbols. (3) ρ_h A, the paradox definition and 'coherent on A' are undefined when A ⊄ dom ρ_h, yet Def 3.1 compares coherence across hypotheses with different domains. (4) §2.1 says VS_t is computable for enumerable H. But for infinite VS_t, the unanimity test in Def 2.1 is a Π1 condition and asks for infinitely many certificates, so V^g_t is not computable.
* *Evidence.* (1) §1.3 last paragraph versus §2.1 bullet 1 and the proof of Thm 2.4, bullet 1. (4) Def 2.1: 'g-valid under every h ∈ VS_t, with a certificate for each'.
* *Suggested fix.* State that (P) contains only St^g_{h*} steps (larger human steps are routed to expansion or treated as noise). List the effectivity assumptions. Fix a convention for A ⊄ dom ρ_h. Restrict computability claims to finite H, or to the Bayesian version with finite truncation (Prop 2.6).

#### A-8. Lemma 2.2 (argument soundness) — severity: minor
* *Description.* The proof is correct. Cl_R is monotone and idempotent, and soundness lifts to the closure. There is one precision gap: the conclusion 'ρ_h(y_j) ∈ Cl(ρ_h Prem α)' is undefined for a premise line outside dom ρ_h. The same edge case carries into Thm 2.4's 'conclusion is h*-valid', because ⊨_{h*} requires Prem ∪ {y_m} ⊆ D*. The lemma is standard, cf. T1 Lemma 1.1.
* *Evidence.* Take α with an unused premise y ∉ dom ρ_h. All inference and link lines are valid, but ρ_h(y) is undefined and (Prem ⇒ y_m) ∉ ⊨_h by the domain clause.
* *Suggested fix.* Assume Prem α ⊆ dom ρ_h, or state the claim for lines in dom ρ_h only.

#### A-9. Prop 3.5 (transfer: ontology unidentifiable) — severity: minor
* *Description.* The general proposition and its proof are correct: R sound for M transfers to M' via elementary equivalence, and V depends only on complete theories. The instance does not satisfy the stated hypothesis. V(ℝ) and *V(ℝ) are not elementarily equivalent in the full first-order ∈-language with standard constants. Robinson's transfer (Łoś for bounded ultrapowers) covers only bounded formulas with standard parameters. Moreover, if R contains any unbounded sentence true in V(ℝ) but false in *V(ℝ), then R is unsound for M' and h' is not a latent formalization.
* *Evidence.* ψ := ∀n∈ℕ ∃s ('s is a function on {0..n} with s(0)=ℝ, s(k+1)=s(k)∪P(s(k))'). ψ holds in V(ℝ). It fails in *V(ℝ): an internal s ∈ *V_M satisfies the defining condition iff it satisfies its V_M-bounded version, and transfer of the bounded truth 'every such s ∈ V_M has n ≤ M' shows that no internal sequence has nonstandard length.
* *Suggested fix.* Replace the hypothesis with: 'M and M' agree on every sentence in ρ(dom ρ), and R is sound for both'. In the example, take R = FOL + bounded axioms true in V(ℝ), so transfer gives soundness for *V(ℝ).

#### A-10. Prop 3.2 (no learner sees past the shadow) — severity: minor
* *Description.* The proposition is labelled [proved, TOSU], but no proof is written. The claim also needs assumptions that are not stated: the law of the object presentation (which objects and occurrences are shown) must be a function of V_{h*}; escalation and link oracles must label by St^g_{h*}, not ⊨_{h*}; and a separate closure-level (≡_∞) version is needed for Thm 3.4(b).
* *Evidence.* §3.1 assumes shadow-measurability only for practice data. Object data are said to be 'restrictions of members of V_{h*}', with no statement about their distribution.
* *Suggested fix.* State the assumptions and give the two-line proof by induction on the history.

#### A-11. Prop 2.3 commentary and §2.1 historical remarks — severity: minor
* *Description.* The proposition and its counterexample are correct. Link 3 (pointwise ⇒ uniform) is the invalid item, and the square-wave Fourier series is a valid countermodel to {1,2}⇒6. The historical glosses are loose. Seidel (1847) and Stokes (1847) diagnosed 'arbitrarily/infinitely slow convergence'. They did not name 'uniform convergence'; that term is due to Gudermann and Weierstrass. Abel's 1826 counterexample was the sawtooth series Σ(−1)^{n+1} sin(nx)/n; the text does not claim otherwise. In §2.1, Frege's 1903 'way out' was shown inconsistent by Leśniewski in 1938 (reported by Sobociński 1949), before Quine's 1955 paper. '52 years' counts only from Quine. I am confident of this but did not re-verify it this session.
* *Evidence.* §2.3 text: "Seidel's and Stokes's 1847 diagnosis ('uniform convergence')". §2.1: "Frege's 1903 'way out' ... for 52 years".
* *Suggested fix.* Rephrase as 'Seidel's and Stokes's 1847 diagnosis (non-uniform, "infinitely slow" convergence)', and as 'refuted by Leśniewski (1938; Sobociński 1949) and Quine (1955)'.

#### A-12. Thm 2.4 (deterministic soundness) — severity: ok
* *Description.* Verified. With noise-free data, h* is never refuted. Practice and oracle labels are St^g_{h*}. The promise ⊥ ∉ Cl_{R*}(ρ*A) rules out paradoxes for h*. Object data extend to V_{h*}. Budgeted checks are sound. Hence h* ∈ VS_t, and unanimity implies g-validity under h*. The only caveats are the inherited Lemma 2.2 domain edge case and the 'larger steps in practice' modelling point listed under the formal model.
* *Evidence.* Line-by-line check of the proof.
* *Suggested fix.* None beyond those noted.

#### A-13. Prop 2.6 (resource-bounded checking) — severity: ok
* *Description.* Verified. Requiring certificates shrinks the accepted set, and treating untruncated hypotheses as rejecting only increases the computed rejecting mass. Soundness is preserved.
* *Evidence.* Monotonicity of the acceptance criteria.
* *Suggested fix.* None.

#### A-14. Prop 2.8 (expansion completeness) — severity: ok
* *Description.* Verified, given its hypotheses. Step-expressiveness turns a finite R*-derivation into a chain of 1-steps. Survivors that agree on St^1 accept each 1-step and each identical-reading link (0 applications). The hypothesis can be weakened to ∩_{VS_t} St^1_h ⊇ St^1_{h*}, which Thm 3.4(d) delivers at g = 1, since its accepted-relation half is correct. The step-expressiveness hypothesis carries the content.
* *Evidence.* Direct check.
* *Suggested fix.* Optionally use the weaker hypothesis.

#### A-15. Prop 3.7 (Benacerraf) — severity: ok
* *Description.* Verified. ZF proves that both numeral systems are Dedekind–Peano systems. The recursion-defined isomorphism preserves the recursive + and ×. Transport along it gives ZF ⊢ ρ_vN(x) ↔ ρ_Z(x) for closed arithmetic sentences, hence equal ⊨ on D_ar. The arithmetic of '1∈3' is right: Zermelo 3 = {{{∅}}} ∌ {∅}. One small point: for occurrences with contextual constants, the two readings are not provably equivalent sentence by sentence, but the consequence relations still coincide via ∀-closure and transport.
* *Evidence.* Standard set theory; checked the numeral computation.
* *Suggested fix.* None needed. Optionally restrict D_ar to closed sentences, or note the transport argument.

**Overall.**

One claim in Sections 1-3 is false. Thm 3.4(d) says that, with bounded-gap practice data and complete object data, the survivors are exactly the h in U* with St^g_h ⊇ St^g_{h*}. In fact, rivals whose informal consequence relation on D* is strictly WEAKER than h*'s also survive forever, as long as they contain h*'s g-short steps. A 4-atom propositional counterexample is verified by brute force (scratchpad/thm34d.py). The accepted relation still equals St^g_{h*}, so the 'verifier converges to h*'s g-step relation' claim survives. But meaning (≈) is not identified from bounded-gap data unless h* is step-expressive on D* (verified: with that added, there are no mismatches). This propagates to §3.5 items 2 and 4(b) and to Prop 3.6. Prop 3.6 (a labelled sketch) has two further problems. Its reduction-algorithm argument does not cover nonstandard parameters, which is exactly the literal infinitesimal talk it is about. It also applies Thm 3.4(d) in the wrong direction: shorter IST steps would refute h_W. Everything else checks out: Lemma 2.2, Prop 2.3, Thm 2.4, Thm 2.5, Thm 2.7(a,b), Prop 2.8, Lemma 3.3(i,ii), Thm 3.4(a-c), the general Prop 3.5 and Prop 3.7. Random brute force over 1500 propositional instances found no failures of Lemma 3.3 or Thm 3.4(a,c). There are minor precision issues: Lemma 3.3(iii) needs y ∈ D_h; Prop 3.5's nonstandard-analysis instance does not satisfy its elementary-equivalence hypothesis; the claimed tightness of Thm 2.7(b) is off by a factor of about ln(1/W*)/δ'; the gauge-redundancy remark credits ε-δ/IST readings to W* although they are not ≡_g-equivalent; and the model has gaps around larger steps in practice, effectivity, and the domain of ρ. Lemma 3.3 is a standard corollary of completeness, so calling it real mathematical content overstates its novelty. The existing T4-checks scripts run cleanly but do not cover §§1-3.


### Referee B (Sections 4–5)

**Items checked.**
* Lemma 4.1 (descent along false lines), lines 373-391
* Definition 4.2 (correction game) and the 'Availability' paragraph, lines 395-402
* Theorem 4.3 (a),(b) (objects: logarithmic), lines 404-414
* Theorem 4.4(a) (bag upper bound via el*), lines 417, 429
* Theorem 4.4(b) (single-culprit class: M_obj=1, M_bag^(r)=min(r,n-1)), lines 418-443
* Theorem 4.4(c) (chain/sorites paradox lower bound n-1 and the single-object descent), lines 421-446
* Computed-values table and random-class claims after Thm 4.4 (244/32, 295, smallest counterexample, antichain remark), lines 448-457
* Theorem 4.5 (super-majority learner, ln(1/w)/ln(1+1/r) <= (r+1)ln|H|), lines 461-469
* Proposition 4.6 (product classes, linear dependence on r), lines 471-482
* Paragraph after Prop 4.6: Theta~(r log|H|), Sabato-Tishby comparison, 'settles TC4' claim, line 484
* Conjecture M_bag^(r) <= r*M_obj and its computational evidence (bag_size_conjecture.py), line 484
* 'Relation to T2' and 'Moral' paragraphs, lines 486-488
* Proposition 4.7 (free barring nullifies objects; MDL charge), lines 498-500
* Theorem 5.1 (a)-(e) abstract repair theorem, lines 510-533
* Comprehension toy menu classification (positive/stratified/sep-form) and hypothesis class R, lines 539-563
* Facts F1-F6, lines 565-580
* Theorem 5.2 (i)-(iv) incl. selection-by-coverage claims, lines 582-591
* Historical reading of the toy (Cantor diagonal = ZR, NF/Cantor, Zermelo 1908, Holmes, Specker), lines 593-598
* Proposition 5.4 (2^aleph0 maximal consistent sets of NC instances), lines 604-616
* Incurvati-Murzi / McGee citation and consequences (a),(b), lines 618-622
* Section 5.4 remarks (Replacement, Frege's way out dates), lines 624-628
* Re-ran all T4-checks scripts relevant to Sections 4-5 (bag_vs_object_game, bag_vs_elasticity, bag_product, bag_size_conjecture, comprehension_toy); all outputs reproduce the table values
* Independent C/C++ exact minimax solver written from scratch: reproduced single-culprit (n<=7), k-culprit, product (b,k) in {(2,2),(3,2),(2,3),(4,2),(2,4)} values; brute-force check of super-majority learner against Thm 4.5 bound

**Issues.**

#### B-1. Theorem 5.2(iv), first bullet ('Dedekind-Cantor operations only'), and the remark 'Only NC is shortest and STRAT is shorter than Z matter below' (lines 563, 587) — severity: major
* *Description.* As written the bullet is false. It says that for any support ⊆ {INT, UNI, PAIR, DIFF, EMP}, coverage plus ℓ selects STRAT. But when the support is a proper subset, POS or SEP can cover everything too, and the stated ordering ℓ(POS) < ℓ(SEP) < ℓ(STRAT) then picks one of them. The bullet's own justification ('POS misses DIFF and EMP') quietly assumes DIFF and EMP carry positive weight. So the remark that only two ℓ-comparisons matter is also false over the stated range: ℓ(POS) < ℓ(STRAT) and ℓ(SEP) < ℓ(STRAT) decide the outcome for such supports. The same problem affects the second bullet if 'add ZR' is read with '⊆' (support {ZR, INT, DIFF} selects SEP). The summary's line 'Dedekind–Cantor set operations alone select the stratified repair' inherits the error: a purely positive Dedekind-style practice (∩, ∪, pairs) selects POS (positive set theory), not NF.
* *Evidence.* Using the paper's own learner (T4-checks/comprehension_toy.learner with refuted={'NC'}): support {INT,UNI} -> POS; {INT,UNI,PAIR} -> POS; {INT,DIFF} -> SEP; {ZR,INT,DIFF} -> SEP. Only the full support {INT,UNI,PAIR,DIFF,EMP} -> STRAT. By hand: STRAT is selected iff support ∩ {DIFF,EMP} ≠ ∅ (so POS misses something) and support ∩ {UNI,PAIR,EMP} ≠ ∅ (so SEP misses something).
* *Suggested fix.* Replace '⊆' with '=' (all five operations used with positive weight), or state the exact condition: support ⊆ {INT,UNI,PAIR,DIFF,EMP}, support ∩ {DIFF,EMP} ≠ ∅ and support ∩ {UNI,PAIR,EMP} ≠ ∅. Say the same for the ZR stage ('support ⊇ the full Dedekind–Cantor set plus ZR'). Delete or correct 'Only ... matter below', and adjust the summary sentence.

#### B-2. Theorem 4.3(a) (and the object game in general): novelty and citation — severity: minor
* *Description.* The object game is exactly Angluin's equivalence-query model with arbitrary (improper) hypotheses, in which a counterexample is any element of A Δ h*. Equivalently it is Littlestone's mistake-bound model. Its optimal value is known: M_obj(H) = Ldim(H) (Littlestone 1988). The ⌊log2|H|⌋ and log2(1/w(h*)) bounds are the classical (weighted) halving algorithm (Barzdin–Freivalds 1972; Littlestone 1988; Angluin 1988). The theorem is correct, but it is marked [proved] with no citation, and the paper misses the exact characterization, which also sharpens the conjecture to 'M_bag^(r) ≤ r·Ldim(H)'.
* *Evidence.* My independent solver computed M_obj and the Littlestone dimension on 693 random classes (|S| ≤ 6, |H| ≤ 10) and found M_obj = Ldim in every case. Prop 4.6's M_obj = k is Ldim additivity over products on disjoint domains.
* *Suggested fix.* Cite halving and Littlestone 1988, and state M_obj(H) = Ldim(H). Restate Thm 4.3(a) as Ldim(H) ≤ ⌊log2|H|⌋ and the conjecture as M_bag^(r)(H) ≤ r·Ldim(H).

#### B-3. Theorem 4.4(a) — severity: minor
* *Description.* The statement and proof are correct, but 'min{el*(H), |H|−1}' is redundant. el* ≤ |H|−1 always holds, because every link of an elastic chain removes at least one hypothesis from the version space while the target survives. T2.7(a) itself states this inequality.
* *Evidence.* An elastic chain s_1..s_m needs s_i ∉ ∩VS({s_<i}), so some h ∈ VS({s_<i}) lacks s_i and is removed. Hence m ≤ |H|−1. On the 295 classes of bag_vs_elasticity.py (seed 7), my solver found M_bag ≤ el* in every case and min(el*, |H|−1) = el* in every case.
* *Suggested fix.* Write M_bag^(r)(H) ≤ el*(H) (≤ |H|−1).

#### B-4. Theorem 4.4(b) — severity: ok
* *Description.* Verified. The lower-bound recursion f(c) = c−1 for c ≤ r and f(c) = min(1+f(r), 1+f(c−1)) = r for c > r is right. The upper-bound strategy (announce S while |C| > r, then announce S∖{b_c}) works: every feedback deletes h_c.
* *Evidence.* The independent exact minimax gives M_obj(H_n) = 1 and M_bag^(r)(H_n) = min(r, n−1) for all n ≤ 7 and all r ≤ n. This matches the paper's table and bag_vs_object_game.py output.
* *Suggested fix.* None.

#### B-5. Theorem 4.4(c) (chain paradox) — severity: minor
* *Description.* The mathematics is correct: under the valuation p_i = [i < j], h_j is coherent on A; no proper subset of the b_i yields ⊥; the bag S deletes nothing; and the unique u ∈ V_{h_j*} with u(q_0)=1, u(q_n)=0 is p_i = [i < j*], so descent stops at b_{j*}. The illustrative reading is backwards, though. With q_k = 'a pile of k grains is a heap', the designated context A = {q_0, ∼q_n} asserts that 0 grains form a heap and n grains do not, which no community designates.
* *Evidence.* Line 422: q_k is 'a pile of k grains is a heap', b_i = (q_{i−1} ⇒ q_i), and A = {q_0, ∼q_n}.
* *Suggested fix.* Take q_k = 'a pile of N−k grains is a heap', or use the steps ∼q_{i−1} ⇒ ∼q_i with A = {∼q_0, q_n}.

#### B-6. Claims after the table: '244 random classes ... M_obj < M_bag in 32' and 'Bags ... are worthless on antichains such as H_n' (line 457) — severity: minor
* *Description.* (1) The cited script (bag_vs_elasticity.py) produces neither figure. It tests 295 classes, not 244, never checks M_obj ≤ M_bag ≤ min(el*, |H|−1), and does not count M_obj < M_bag. On those 295 classes the true count of M_obj < M_bag is 43. The same paragraph then cites 295 classes for the same script. (2) The general remark that bags are worthless on antichains is false.
* *Evidence.* (1) I re-ran the seed-7 class generation with my solver: 295 classes, 43 with M_obj < M_bag, 0 violations of M_bag ≤ el*, 195 with M_bag = el* (the last figure matches the text). (2) H = {{1},{0,3},{0,4}} (masks [2,9,17], |S|=5) is an antichain with M_bag = 1 < el* = 2, confirmed with the project's own solve() and elasticity(). The learner announces {0}: target {1} gives (+)1 or bag {0}, target {0,3} gives (+)3, target {0,4} gives (+)4, and each identifies the target. Out of 2121 random antichains, 177 have M_bag < el*.
* *Suggested fix.* Report the figures the script actually produces, or add the script that produces 244/32, and add the asserted inequality chain to it. Change the antichain sentence to 'they are worthless on H_n (and on some other antichains)'.

#### B-7. Theorem 4.5 — severity: ok
* *Description.* The proof is correct. Each s ∈ A_t is missed by weight < w(VS)/(r+1). A bag of ≤ r such steps leaves weight < r/(r+1)·w(VS). A (+) item leaves ≤ r/(r+1)·w(VS). Also ln(1+1/r) ≥ 1/(r+1). One small type mismatch: the left side M_bag^(r)(H) is a minimax over all targets, while the right side depends on h*.
* *Evidence.* I brute-forced the worst case of the super-majority learner itself against an adaptive adversary on about 300 random classes (|S| ≤ 5, r = 1, 2, 3). It always stayed within ln|H|/ln(1+1/r) (maximum ratio 1.0), and its feedback was never uninformative.
* *Suggested fix.* Phrase it as: 'the super-majority learner makes at most ln(1/w(h*))/ln(1+1/r) corrections on target h*; hence M_bag^(r)(H) ≤ (r+1)ln|H|'.

#### B-8. Proposition 4.6 — severity: minor
* *Description.* The statement is correct, but the proof has small gaps. (i) The object strategy 'accept everything' fails as worded: announcing S every round lets the environment name the same culprit forever. The learner must reject culprits already identified. (ii) The lower bound M_obj ≥ k is never argued. (iii) The environment case analysis for the bag lower bound skips two cases: a block with ≥ 2 candidates whose candidates are all rejected, and rejection of known-valid steps. It also needs a potential argument rather than 'exactly as in the one-block game'.
* *Evidence.* Exact values from my solver: (b,k) = (4,2): M_bag^(r) = 2, 4, 6, 6, 6 for r = 1..5; (2,4): 4 for r = 1, 2, 3; plus the paper's (2,2), (3,2), (2,3). All equal k·min(r, b−1), and M_obj = k. The missing arguments: for M_obj ≥ k, the adversary always answers inside one unresolved block, so each correction resolves at most one block. For the bags, use Φ = Σ_blocks min(r, |C_X|−1). It starts at k·min(r, b−1) and drops by at most 1 per correction, since (+) removes one candidate and a size-r bag takes |C_X| > r to r. The learner cannot finish while Φ > 0.
* *Suggested fix.* Write 'accept every step not yet refuted', add the one-line adversary argument for M_obj ≥ k, and replace the case list with the potential Φ.

#### B-9. Claim 'This settles the open part of L8's TC4 for finite classes' (line 484) — severity: minor
* *Description.* This overstates the result. L8 TC4 asks for a mistake bound in terms of the Littlestone dimension and log r. T4 shows that no Ldim·polylog(r) bound exists (products give M_bag ≥ r·Ldim), and it gives an upper bound in terms of ln|H|. Whether any bound f(r)·Ldim(H), independent of |H|, holds is exactly the open conjecture. Since Ldim can be far below log|H| (for example, the singletons class has Ldim 1 and log|H| = log n), the ln|H| upper bound does not settle the Ldim question. The novelty of the Θ̃(r) price is also uncertain: it may relate to known Littlestone-dimension bounds for k-fold aggregations (I believe Ghazi–Golowich–Kumar–Manurangsi 2021 is one source, but this is unverified).
* *Evidence.* Line 484 next to L8 lines 586-590 ('A mistake bound in terms of the Littlestone dimension of the instance class and log r would be the right result').
* *Suggested fix.* Say 'refutes the expected log r form (lower bound r·Ldim on products) and gives an O(r log|H|) upper bound; an Ldim-based upper bound is the open conjecture below'. Mark novelty as uncertain.

#### B-10. Conjecture M_bag^(r) ≤ r·M_obj (line 484) and its evidence — severity: ok
* *Description.* The conjecture is honestly labelled and its evidence reproduces: 519 pairs, maximum ratio 1.0. My much stronger search found no counterexample. One small imprecision: 'equality on single-culprit and product classes' holds only for r ≤ n−1 (respectively r ≤ b−1). For larger r, M_bag^(r)(H_n) = n−1 < r. The case M_obj = 1 can actually be proved: then some A makes the sets AΔh pairwise disjoint. Announcing A, a size-≤r bag leaves at most r candidates, after which one-at-a-time elimination costs at most r−1. When |H| ≤ r, elimination alone costs at most r−1. So M_bag^(r) ≤ r.
* *Evidence.* Searches, all with zero violations: (1) Exhaustive over all 65,519 classes with |S| = 4 and r = 2, 3, 4: 196,557 pairs, 434 equalities. Exhaustive over all classes with |S| = 3: 494 pairs. (2) About 4.69M random (class, r) pairs with |S| ∈ {4,5,6} and |H| ≤ 13. (3) Hill-climbing that maximizes M_bag − r·M_obj (|S| = 5..8, |H| ≤ 13, r = 2, 3): the maximum is exactly 0. (4) k-culprit classes, where the bound is tight. K(8,2), r=3: M_bag = 6 = 3·2. K(10,2) and K(11,2), r=4: 8 = 4·2. K(9,2), r=3: 6. K(7,3) and K(8,3), r=2: 4 and 5, both ≤ 6.
* *Suggested fix.* Restate as M_bag^(r) ≤ r·Ldim(H). Add the proved M_obj = 1 case, the exhaustive |S| = 4 evidence, and tightness on 2-culprit classes. Qualify the 'equality' remark with r ≤ n−1 (respectively r ≤ b−1).

#### B-11. Definition 4.2 / 'Availability' paragraph (lines 398-402) — severity: minor
* *Description.* (1) The bag channel is implicitly taken to be always available. Whenever A_t ⊋ h*, the environment may return the singleton bag {s} for s ∈ A_t∖h*, so the game assumes every accepted invalid step is refutable by some paradox. Coherence data do not provide this in general: coherent-but-wrong hypotheses exist, as T2 and §3 note. The paper discusses availability for objects but not the analogous condition for bags. Without it, the bounds are bounds on corrections, not on unsound rounds. The super-majority learner of Thm 4.5 can then stay silently unsound forever with zero corrections. (2) The claim that object-completeness 'holds for propositional and finite-model-property fragments' is false when H = H^g. Steps that are h*-valid but not g-valid lie in A_t∖St^g_{h*} and have no countermodel.
* *Evidence.* Line 398 allows any B ⊆ A_t with |B| ≤ r and B ⊄ h*, so |B| = 1 is always legal. Line 395 sets H = H^g, and line 402 asserts object-completeness for propositional/FMP fragments.
* *Suggested fix.* Add a 'bag-availability (refutability)' caveat next to object-completeness. State object-completeness relative to ⊨_{h*}, or assume St^g_{h*} = ⊨_{h*} on the relevant steps. Note that the correction bounds still hold for the restricted real environment, because restricting the environment only lowers the worst case.

#### B-12. 'Moral' paragraph (line 488) — severity: minor
* *Description.* The claim that the sorites-type uninformativeness 'explains why the paradoxes of set theory (Russell, Burali-Forti) did not by themselves select a repair (§5)' contradicts §5's own analysis. At the level of comprehension instances, Russell's paradox is a size-1 bag ({Comp(R)}, the 4-line derivation of F1), which is as informative as an object. In §5, non-selection comes from several incomparable maximal coherent uniform restrictions (Thm 5.1(e), 5.2(iii)). That would persist even with perfect instance-level blame.
* *Evidence.* F1 (line 566) uses only Comp(R). Thm 5.2(iii) traces non-uniqueness to POS, STRAT and Z being pairwise jointly incoherent, not to bag size.
* *Suggested fix.* Rephrase: paradoxes in set theory localized blame well at the instance level; what they could not do is choose the generalization (the uniform restriction), which needed coverage, as §5 shows. Keep the sorites as the example of uninformative blame.

#### B-13. Proposition 4.7 — severity: minor
* *Description.* This is TOSU and essentially correct, but the first sentence is loosely quantified. 'The learner may discard object data at no cost' does not by itself make objects worthless: a learner allowed to bar may simply decline to, and the Thm 4.3 bounds then still hold. The intended statement is about a selection criterion, such as an MDL score, that charges nothing for barring, so barring is never penalized. The cost clause tacitly assumes h* never needs to bar, i.e. objects are truthful, which is in tension with the motivation 'objects not independently certified'.
* *Evidence.* Lines 498-500.
* *Suggested fix.* Say: 'If the learner's selection criterion assigns zero cost to barring (equivalently, an adversarially-chosen learner may bar), object data impose no constraint...'. State the truthful-objects assumption explicitly in the MDL clause.

#### B-14. Theorem 5.1 — severity: minor
* *Description.* Correct and trivial, as the paper says. Small precision gaps: MDL_t's argmin should range over c ∈ R. In (d), the convergence w_t/‖w_t‖_1 → w_∞ must be in ℓ1, or w_∞ must be a probability vector. Members of R are typically infinite sets of instances, so with mere pointwise convergence and escaping mass, the normalized coverages need not converge to cov_∞.
* *Evidence.* Lines 518 and 525.
* *Suggested fix.* Write argmin_{c∈R}, and require ℓ1 convergence (by Scheffé's lemma, pointwise convergence to a probability vector is enough).

#### B-15. Facts F1-F6 and the menu classification — severity: ok
* *Description.* All verified by hand. F1: the Russell instance. F2: the one-point model u∈u makes every positive formula true. F3: FinCof(ℕ) is a Boolean algebra containing ℕ, ∅ and finite pairs, and is closed under ∩, ∪, ∖ and complement; the coding e is bijective, giving comprehension and Extensionality. F4: HF is closed under separation, ∅, pairs and binary unions. F5: {V, ZR} gives Russell's set via a := universe, and {S, CMP} gives it via a := {x : x∈x}. F6: the stated witnesses (with S ∈ POS∖Z for POS ⊄ Z). The positive/stratified/sep-form columns are right: x∈x is unstratifiable, and PAIR and CMP are stratified. The script's finite-model sanity checks agree.
* *Evidence.* comprehension_toy.py Part A: no model of size ≤ 3 for any claimed-inconsistent set. Part B reproduces the coverage table: 13/18/9/18, 14/19/12/21, 17/22/12/21.
* *Suggested fix.* None.

#### B-16. Theorem 5.2 (i)-(iii) and bullets 2-3 of (iv) with full supports — severity: ok
* *Description.* (i) holds because ℓ(NC) is stipulated minimal. (ii) holds with budget 4 (F1), and t_0 = k(NC). (iii) The coherent members of R are POS, STRAT, SEP and Z; SEP ⊊ Z, and POS, STRAT and Z are pairwise incomparable, so these three are exactly the maximal ones, pairwise jointly incoherent. (iv) With support = Dedekind–Cantor set ∪ {ZR}, only Z covers everything. Adding V gives cov(Z) − cov(STRAT) = w(ZR) − w(V). POS never strictly beats STRAT, because POS ∩ support ⊆ STRAT. SEP ⊆ Z never beats Z. So 'Z iff w(ZR) > w(V)' is right, with ties going to STRAT by ℓ.
* *Evidence.* Hand computation, confirmed by comprehension_toy.py stages 3-4 (Z for w(ZR)=3 > w(V)=1, STRAT for w(V)=4 > w(ZR)=3).
* *Suggested fix.* None beyond the '⊆' issue reported separately.

#### B-17. Toy modelling choices: ZR as 'Cantor's diagonal set' and the stipulated ℓ ordering (lines 552, 563, 588, 594-596) — severity: minor
* *Description.* (1) ZR = {x∈a : x∉x} is Zermelo's 1908 set. Cantor's 1891 diagonal set is {x∈a : x∉f(x)}, a different separation instance with a function parameter. NF proves the stratified variant {x∈a : x∉f({x})}, which gives |USC(X)| < |P(X)|. So 'practice that already contains diagonal arguments selects Separation' identifies Cantor's diagonal practice with ZR-instances, and that is a modelling stretch the text does not flag. (2) The outcome 'Dedekind–Cantor practice selects STRAT' rests entirely on the stipulation ℓ(STRAT) < ℓ(Z). The justification 'Z is a uniform condition plus three named extra instances' is one encoding choice among several. The historical moral 'simplicity would have favoured NF' therefore restates the chosen ℓ rather than deriving anything.
* *Evidence.* Line 552 labels ZR as 'Cantor's diagonal set / Zermelo 1908'. Line 563 stipulates the ℓ order.
* *Suggested fix.* Label ZR as 'Zermelo's 1908 subset (the diagonal set for f = id)'. Note that Cantor-style diagonal sets with a function parameter are a richer menu item. Flag the STRAT-vs-Z outcome under Dedekind–Cantor practice as ℓ-dependent.

#### B-18. Proposition 5.4 — severity: ok
* *Description.* Verified. J(q) ∧ q ⊢ ⊥ via the Russell set, so I_A decides every p_n, and A ≠ B makes I_A ∪ I_B inconsistent. M_A satisfies p_n iff n ∈ A for n ≥ 1, since the a_n have exactly n distinct empty elements and the e_i have none. Every instance in I_A defines the empty class, witnessed by e_0. Finite character plus Zorn gives distinct, pairwise incompatible maximal extensions J_A, all containing Comp(x≠x). (M_A violates Extensionality, which the statement does not require. With A ⊆ ℕ_{≥2} and Zermelo numerals in place of the e_i, one gets an extensional, well-founded model, so the result survives with Extensionality as background.)
* *Evidence.* Hand check. comprehension_toy.py also finds small models for Comp(R∧p) and Comp(R∧¬p) separately and none for both, consistent with step 1.
* *Suggested fix.* Optionally note 'exactly 2^ℵ0' (countably many instances), and that the proof works over pure logic.

#### B-19. Consequences drawn from Incurvati–Murzi after Prop 5.4 (lines 61, 618-622) — severity: minor
* *Description.* (b) 'no computable learner can even output a single maximal one' is true only when 'output' means outputting an r.e. index or axiomatization. A maximal consistent set of instances can be built greedily from a 0′ oracle for consistency (consistency is Π1), so some are Δ2. By Shoenfield's limit lemma, a computable learner can therefore converge pointwise in the limit to a maximal consistent set, much as REP_t-style budgeted learners do. The summary (line 61) also drops the 'under minimal assumptions' qualifier of the Incurvati–Murzi result. The citation itself (Mind 126(502):371-384, 2017; generalizing McGee 1992) matches my recollection.
* *Evidence.* The greedy construction: enumerate the instances and add each one if the set stays consistent. Each check needs one 0′ query, so the resulting maximal set is ≤_T 0′.
* *Suggested fix.* Say 'no computable learner can output a recursive axiomatization (r.e. index) of a maximal one, though Δ2 limit approximations exist'. Restore 'under minimal assumptions' in the summary.

#### B-20. Section 5.4 remark 'Frege's way out lasted 1903–1955' (line 628; also line 153) — severity: minor
* *Description.* This is historically imprecise. Leśniewski showed in 1938 that Frege's way out is inconsistent for domains with at least two objects; Sobociński reported it in 1949. Quine's 1955 Mind paper (64:145-159) was a later, independent treatment. The '52 years' figure is therefore an overstatement. The point being made, that coherence of the selected repair is uncertified, is unaffected.
* *Evidence.* Sobociński (1949), 'L'analyse de l'antinomie russellienne par Leśniewski', Methodos 1–2. This is from memory, so treat the exact volume and pages as unverified.
* *Suggested fix.* Write 'until Leśniewski (1938; published by Sobociński 1949) and independently Quine (1955)'.

#### B-21. Lemma 4.1 (descent) — severity: ok
* *Description.* Correct. The walk from the false conclusion always moves to a strictly earlier false line, never stops at a premise, and stops at an inference with all antecedents true or at a link with a true source. It uses ≤ depth moves and ≤ Σ fan-in evaluations. h-admissibility (v ⊆ v_M∘ρ_h with M ∈ 𝕄_h) together with soundness of R_h makes the blamed item ⊨_h-invalid, which also covers links, since link validity ⊆ ⊨_h. Inferences with Γ = ∅ are handled vacuously. The 'new' points (descent ending at a link) are modest reframings of Shapiro-style contradiction backtracing, but they are not wrong.
* *Evidence.* Line-by-line check of lines 379-385.
* *Suggested fix.* None needed. Optionally soften 'Two points are new here'.

**Overall.**

I found no false statement among the main mathematical results of Sections 4–5. Lemma 4.1, Theorems 4.3, 4.4(a–c) (including the chain-paradox lower bound n−1), Theorem 4.5, Proposition 4.6, Theorem 5.1, Facts F1–F6, Theorem 5.2(i)–(iii) and Proposition 5.4 all check out line by line. I confirmed them with an exact minimax solver written from scratch (C/C++), separate from the project's scripts. It reproduces every table value and the product values for (b,k) up to (4,2) and (2,4), and the super-majority learner stays within the Thm 4.5 bound under brute-force adversaries. The project's own check scripts re-run cleanly and reproduce the stated tables.

**One real defect (major, local fix).** Thm 5.2(iv), first bullet, is false as written. With support ⊆ {INT, UNI, PAIR, DIFF, EMP}, the learner selects POS for {INT, UNI} and SEP for {INT, DIFF}; only the full support selects STRAT. The paper's own learner function shows this. The remark that only two ℓ-comparisons matter is also wrong.

**The conjecture M_bag^(r) ≤ r·M_obj** survives a much stronger search with no counterexample: exhaustive over all classes on |S| ≤ 4, about 4.7M random pairs, hill-climbing on |S| ≤ 8, and k-culprit classes up to n = 11. It is tight on 2-culprit classes as well as on single-culprit and product classes. The case M_obj = 1 is provable. Since M_obj equals the Littlestone dimension exactly, Thm 4.3 is the classical halving/Littlestone result and should be cited; the conjecture is best restated as M_bag^(r) ≤ r·Ldim.

**Minor issues:**
- The provenance numbers "244 / 32" are not produced by the cited script; it gives 295 classes and 43.
- The claim that bags are worthless on antichains is false; the antichain {{1},{0,3},{0,4}} is a counterexample.
- "Settles TC4" overstates the result, because the Ldim-based upper bound remains open.
- Bag-availability is implicit in Def 4.2, and object-completeness is misstated relative to St^g.
- The "Moral" paragraph contradicts §5: Russell's paradox is a size-1 bag.
- The proof of Prop 4.6 has small gaps.
- The sorites example is indexed backwards.
- The toy models ZR as Cantor's diagonal set and stipulates the ℓ ordering on which the STRAT-vs-Z outcome rests.
- The claim that no computable learner can output a maximal set needs a qualifier, because Δ2 limit approximations exist.
- The dates for Frege's way out are off: Leśniewski showed it inconsistent in 1938.

Scripts used: /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/g/{game.c, game64.cpp, exh.c, drv.py, t1–t11.py}.


### Referee C (Sections 6–7, with related §0 and §8 claims)

**Items checked.**
* Def 6.1 and RCH_g (setup, lines 638-646)
* Thm 6.2(a) survival
* Thm 6.2(b) conservative learner / SV-truthful data
* Thm 6.2(c) nothing more is soundly learnable
* Thm 6.2(d) permanent abstention region
* Thm 6.3 non-robust steps have monsters (+ Cauchy/Lakatos paragraph)
* Prop 6.4(a) SV validity is a consequence relation
* Prop 6.4(b) union bound + sorites tightness (re-ran robust_core_and_mdl.py)
* Remark after Prop 6.4: 'weakest per-step property that composes'
* Novelty claim for Prop 6.4 in Section 0 (line 73) vs Section 8 table
* Prop 6.5 formal statement and proof
* Prop 6.5 interpretation (three ingredients; answer to the user's question)
* Euclid / Manders / ADM / Steiner paragraph (lines 706-710)
* Section 7 additive two-part-code model
* Prop 7.1 (i),(ii)
* Cor 7.2
* Prop 7.3 counterexample to the vertex conjecture (hull, Pareto, script)
* Section 7 Assessment + consistency with T5 Section 3/4 and T1 Thm 6.4, T2 Cor 6.2
* Section 0 summary claims for Sections 6-7

**Issues.**

#### C-1. Thm 6.2(c) (and (d), Section 0 'nothing more can be learned soundly') — severity: major
* *Description.* (c) mixes up g-validity (St^g) with validity (⊨). Elsewhere the file defines soundness as 'every accepted step is h*-valid', i.e. in ⊨_{h*' (Thm 2.4, 2.5, Prop 2.6: 'a certificate ... implies validity'). Read that way, the first sentence of (c) is false. The largest acceptance set that is sound for every target in {h_σ} is ⊨_SV, not St^g_SV. The proof step 'If s∈A∖St^g_σ, then A is unsound when the target is h_σ' silently assumes s∉⊨_σ. The same conflation affects (d): for steps in (⊨_SV ∩ ⋃_σ St^g_σ)∖St^g_SV, a vague community *can* truthfully answer 'valid'. Also, expansion into smaller robust steps (Prop 2.8) or adding a library lemma to every R_σ can remove such steps from the abstention region; a definition that shrinks Σ is not the only way.
* *Evidence.* Counterexample. Take Σ={σ}, a propositional R_σ whose only rule producing conjunctions is ∧-introduction, and g=1. Let s=({x}⇒y) with ρ_σ(x)=q and ρ_σ(y)=q∧(q∧q). Then s∈⊨_σ, so the acceptance set {s} is sound for target h_σ in the Thm 2.4 sense. But every R_σ-derivation needs ≥2 ∧I applications, so s∉St^1_σ=St^1_SV. That contradicts 'Any acceptance set that is sound whatever the target in {h_σ} is contained in St^g_SV' (line 653). The faulty step is in the proof at line 659. Line 654's 'A vague community cannot answer escalations about them. Only a definition ... removes them' fails for such s.
* *Suggested fix.* Split (c). (c1) Every acceptance set sound (in the ⊨ sense) for every target in {h_σ} is ⊆ ⊨_SV. (c2) Every acceptance set that is 'g-sound' (⊆ St^g_target) for every target is ⊆ St^g_SV, and the verifier attains this. Restrict the 'cannot answer / only a definition removes them' claims in (d) to ⋃_σ St^g_σ ∖ ⊨_SV. Mention expansion and library growth as the remedy for (⊨_SV∖St^g_SV). Update §0 ('nothing more can be learned soundly') to match.

#### C-2. Prop 6.5 interpretation: 'three ingredients' answer to how the nice notion of proof came to be there (lines 697-704; §0 item 5) — severity: major
* *Description.* The formal proposition is correct, but its proof never uses the 'bounded repertoire' hypothesis. The conclusion ('every chained argument is the image of a derivation in a complete calculus for T') holds for *any* set of T-valid steps. So selection contributes only 'surviving steps are valid', and completeness does the rest. Ingredient 3's claim that bounded repertoire 'makes the surviving practice the shadow of finitely many schemas, so the calculus is not merely the set of truths' is not established. First, A_∞=A_0∩⊨_T is in general neither finitely schematized nor decidable. Second, what makes the calculus differ from 'the set of truths' is that T is r.e. (ingredient 2), not the repertoire. Third, no bounded-gap structure (the §1 notion of a 'nice' proof: each human step is a ≤g-step derivation) follows, since the derivations behind surviving steps have unbounded length. The advertised explanation therefore has a real gap.
* *Evidence.* Take A_0 to be the instances of a single informal schema 'from χ infer θ', with χ,θ ranging over arithmetic sentences, T=PA, and complete monster presentation. Then A_∞={(χ⇒θ): PA⊢χ→θ}. This set is r.e. but undecidable, so it is not the instance set of finitely many (decidable) sound schemas. The PA-derivations of surviving steps have unbounded length, so there is no g with A_∞⊆St^g. The proof at line 695 uses only completeness and Lemma 2.2, and the first bullet of the hypotheses (line 690) is never invoked.
* *Suggested fix.* Either present Prop 6.5 honestly as 'monster selection + completeness ⇒ surviving steps are derivable, with no bound on gap', and drop ingredient 3's claim. Or add a hypothesis that does the work and prove what follows. For example: selection at the schema level (drop a whole schema once any instance is refuted), giving a finite set of sound derived rules; or uniform derivations for each surviving schema, giving a bounded gap. Say explicitly that completeness of the surviving calculus with respect to T does not follow.

#### C-3. Thm 6.2(b) conservative learner learns the robust core — severity: minor
* *Description.* Three problems. (1) A hypothesis is missing. VS_t (§2.1) also depends on escalation and link answers, which §1.4 says are labelled by h*. (b) lists only practice, designated contexts and objects as SV-truthful. If the community answers an escalation according to one sharpening, some h_σ is refuted and 'every h_σ survives forever' fails. (2) (b) proves only accepted ⊆ St^g_SV (soundness), not convergence to St^g_SV. The title and §0's 'learns exactly the robust core' overclaim for H⊋{h_σ}. (3) For infinite Σ (the natural case for vague thresholds), the verifier needs a certificate under infinitely many survivors, and St^g_SV can be undecidable. So 'the verifier's accepted set is exactly St^g_SV' does not describe an algorithm. (c) also silently relies on (b)'s data hypotheses.
* *Evidence.* (1) Take s∈St^g_σ1∖St^g_σ2. An escalation answered 'yes' refutes h_σ2, and one answered 'no' refutes h_σ1. (2) Let H={h_σ1,h_σ2,h'} with St^g_{h'}=St^g_SV∖{s}, where h' is coherent, object-compatible, and s is never presented. Then h' survives forever and s is never accepted, so the accepted set ≠ St^g_SV. (3) Let σ_n read a vague sentence w_m as the Δ0 sentence 'machine m does not halt within n steps', and let R_σ contain a one-step Δ0-evaluation rule (decidable). Then (∅⇒w_m)∈St^1_SV iff machine m never halts, which is Π1-complete.
* *Suggested fix.* Add 'escalation and link answers are given only when all σ agree (yes on St^g_SV, no outside ⋃_σ St^g_σ, abstain otherwise)' to (b), and carry the hypotheses into (c). Either add complete presentation (or SV-truthful escalation) plus finite H and prove convergence to St^g_SV, or weaken §0's 'learns exactly'. Note that the idealized verifier is effective only for finite Σ (or under extra uniformity).

#### C-4. Thm 6.2(a) survival — severity: minor
* *Description.* RCH_g covers only *non-noise* practice steps, but (a) asserts that 'every practice argument' is h_σ-valid. Under BG2, practice arguments can contain sporadic or systematic noise steps. Separately, 'a theorem of every admissible sharpening' also needs the argument's premises to be T_σ-theorems (or designated axioms), which is not stated. The proof (Lemma 2.2 once per σ) is otherwise correct.
* *Evidence.* Line 646 restricts RCH_g to 'every non-noise practice step'. Line 651 says 'every practice argument'. An argument containing a freshman's-dream step (systematic noise, BG2) is not h_σ-valid for any σ.
* *Suggested fix.* Say 'every argument all of whose inferences and links are non-noise practice items is h_σ-valid for every σ'. For the 'theorem' clause, add 'whose premises are T_σ-provable (e.g. designated axioms)'.

#### C-5. Thm 6.3 non-robust steps have monsters (+ Cauchy/Lakatos paragraph) — severity: minor
* *Description.* (1) The statement needs Γ∪{y}⊆dom ρ_σ. Otherwise s∉⊨_σ holds trivially and 'ρ_σΓ holds, ρ_σy fails' is meaningless. (2) Under Def 1.1, 'first-order complete' already defines Cl_R(Γ) as semantic consequence, so the countermodel exists by definition. Gödel completeness is needed only to know that such an R exists. (3) The robust core of Thm 6.2 is St^g_SV, but 6.3 is about ⊨_σ. Steps in ⊨_SV∖St^g_SV are 'non-robust' in 6.2's sense yet have no monster. (4) The monster may be nonstandard, and its values on Γ,y are generally *not* super-determinate, so under §6.1's SV-truthful reporting the vague community cannot present it. (5) The Lakatos mapping here ('monster-barring = define converges as uniform convergence') conflicts with §4.3 (line 494), which calls re-reading 'converges' as 'converges uniformly' *monster-adjustment*. The §6 mapping is closer to Lakatos.
* *Evidence.* Cauchy example: for Abel's series, 'Σf_n converges' is true under σ_pw and false under σ_unif, so it is not super-determinate (Def 6.1, line 643). An SV-truthful community cannot report the monster's premise value. Lines 494-495 vs line 666.
* *Suggested fix.* Add the domain hypothesis. Replace 'the proof is Gödel completeness' with 'by definition of ⊨ (completeness is what makes such R_σ exist)'. Say 'non-⊨_SV-robust'. Note that 6.3's monsters need not be presentable as SV-truthful data. Align the §4.3 and §6 Lakatos terminology.

#### C-6. Def 6.1 'Supervaluational validity ... (Fine 1975)' — severity: minor
* *Description.* ⊨_SV:=⋂_σ⊨_σ is *local* validity (truth-preservation at each sharpening). The supervaluationist literature usually distinguishes it from *global* validity (preservation of supertruth). If I recall correctly, the latter is the notion standardly attributed to Fine 1975 and Keefe 2000 (Williamson 1994 ch. 5; Varzi 2007, Mind 116 — from memory, unverified). With a fixed Σ and precise vocabulary in L, the two differ. Local validity is the right notion for 'survives every formalization', so this is a labelling and citation issue only.
* *Evidence.* Let Σ={σ1: w↦A, σ2: w↦B}, with A,B precise predicates not equivalent in T_0, and take the step ('w(a)' ⇒ 'A(a)∧B(a)'). It is globally valid: whenever w(a) is supertrue, A(a)∧B(a) holds. It is not in ⊨_SV, since under σ1, A(a)⊭A(a)∧B(a).
* *Suggested fix.* Call ⊨_SV 'local supervaluational validity' (or 'validity under every admissible sharpening') and cite the global/local distinction. Flag the Fine attribution as unverified.

#### C-7. Prop 6.4(a),(b) union bound and sorites tightness — severity: ok
* *Description.* Both parts are verified. (a) is correct on ⋂_σ dom ρ_σ. Note that ⊨_h is reflexive and monotone only for occurrences in dom ρ_h, so 'consequence relation' should be read relative to the common domain. (b) is correct: Lemma 2.2 per σ, plus the union bound, plus measurability of {σ: s∈⊨_σ}; 'n-step' must count links as well as inferences. The sorites tightness example is correct: under σ_c, q_k⇒q_{k-1} fails iff c=k, and q_n⇒q_0 fails under every σ_c, also when formalized with heap(x):↔x≥c over a T_0 deciding numeral order. Adding one sharpening of mass 1−nε under which all steps hold shows the bound is tight for every ε≤1/n, not just ε=1/n. I re-ran T4-checks/robust_core_and_mdl.py and got step fractions 2/3, 4/5, 9/10 and a chain valid under no sharpening. Its 'union bound check' only tests P(all steps valid)≥1−Lε, a probability tautology, and does not exercise Lemma 2.2.
* *Evidence.* Script output: 'sorites n=10: each step valid under fraction 9/10 ...; chain heap(10) => heap(0) valid under sharpenings []'. Hand check of the case analysis k≥c>k−1 ⇔ c=k.
* *Suggested fix.* Add the domain caveat to (a) and 'count links' to (b). Optionally state tightness for all ε≤1/n.

#### C-8. Remark after Prop 6.4: unanimous RCH 'is the weakest per-step property that composes' (line 685) — severity: minor
* *Description.* As stated this is false. Many strictly weaker per-step properties also compose, so 'only unanimity chains' (the heading) needs qualifying.
* *Evidence.* Validity under a single fixed sharpening σ_1 is a consequence relation, so it composes, and it is weaker than unanimity. So is validity under every σ in any fixed Σ'⊆Σ. μ-almost-sure validity also composes (the union bound with ε=0) and is strictly weaker than unanimity when μ lacks full support or Σ is uncountable.
* *Suggested fix.* Restrict the claim, e.g.: 'among properties of the form valid with μ-probability ≥1−ε, only ε=0 composes without degradation; and among properties invariant under the choice of admissible sharpening (sound for every possible target), unanimity is the weakest'.

#### C-9. Novelty claim: §0 line 73 lists 'the sorites tightness of the union bound' among 'parts with real mathematical content' — severity: minor
* *Description.* This is standard. The bound 'uncertainty of the conclusion ≤ sum of uncertainties of the premises' is Adams's (Adams 1966; Adams & Levine 1975; Suppes 1966). Its application to the sorites with degrees as measures over precisifications is Edgington ('Vagueness by degrees', 1997; cf. Lewis 1970, Kamp 1975). Tightness via disjoint failure events is the lottery-paradox structure (Kyburg 1961). (Citations from memory, not verified this session.) It also contradicts the §8 table, which rates 6.4 as TOSU.
* *Evidence.* Line 73 vs line 762 ('TOSU; the hypothesis RCH is the empirical content').
* *Suggested fix.* Remove it from the 'real content' list, or cite Adams/Edgington/Kyburg and present 6.4 as a known fact re-derived in the present setting.

#### C-10. Prop 6.5 formal statement and proof — severity: minor
* *Description.* The proof is correct, given the domain condition and the assumption that every refutable step is eventually refuted. Two precision problems in the statement. (1) The parenthetical 'a model of an r.e. theory T (for one sharpening, or for all of them)' is ill-typed in the 'all of them' case: the surviving set is then A_0∩⊨_SV=A_0∩⋂_σ⊨_{T_σ}, not A_0∩⊨_T for a single T, and there is no single reading ρ*. (2) 'The ρ*-image of a derivation' runs in the wrong direction (ρ* maps informal to formal). What is meant is that the ρ*-image of the argument's lines can be interpolated into a derivation. Also, complete monster presentation in the 'all sharpenings' case conflicts with §6.1's SV-truthful reporting (see the Thm 6.3 item).
* *Evidence.* Lines 691-693.
* *Suggested fix.* State the single-sharpening case with T and ρ*. For the vague case, say: 'for every σ, the ρ_σ-image of the argument interpolates into a derivation in a complete calculus for T_σ'.

#### C-11. Euclid / Manders / ADM / Steiner paragraph (lines 706-710) — severity: minor
* *Description.* (1) Steiner's 7776 is mischaracterized. 6^5=7776 is wrong for *every* choice of five conics, generic ones included, because the degree-6 tangency hypersurfaces in P^5 always share the Veronese surface of double lines. The excess comes from degenerate *solutions*, not from a degenerate input configuration; the correct count is 3264 (de Jonquières 1859, Chasles 1864). The project's own L6 table (line 51) has this right. (2) 'Euclid as a proven instance' overclaims. Diagram perturbations are not sharpenings in the sense of Def 6.1 (explicit L-definitions of vague words), and nothing is proved; 'co-exact = super-determinate' holds by definition once a sharpening is defined as a perturbation. The ADM 2009 claim is roughly right as cited: completeness holds for a restricted class of sequents relative to ruler-and-compass semantics.
* *Evidence.* Line 710: 'a Bézout count valid only for generic configurations, with a degenerate configuration as its monster'. L6 line 51: 'a degenerate excess component (the Veronese surface of double lines)'.
* *Suggested fix.* Rewrite the Steiner sentence: the Bézout step presupposes a proper (finite) intersection, which fails for every input because of the double-line conics, so the 'monster' lives in the solution space. Relabel the paragraph as 'an analogy' rather than 'a proven instance', or give the formal translation.

#### C-12. Section 7 model and Prop 7.1 — severity: ok
* *Description.* Verified. J_λ is separable, so the MAP thresholds each rule independently: include r iff λℓ(r)<Nπ_r g_r. (i) and (ii) follow. The additive model is exactly realizable as a probabilistic model, with fixed mixture weights π_r and a uniform code on the instance set I_r (r included) versus on a superset of size 2^{g_r}|I_r| (r excluded). The result is the standard separable-penalty / hard-thresholding fact, and it duplicates T5 Thm 3.2; §8 rightly calls it easy.
* *Evidence.* Brute force over 3000 random instances (≤5 rules, exact rationals, several λ, N): the threshold set was always a minimizer, and unique when there were no ties. 0 violations.
* *Suggested fix.* None needed. Optionally cross-reference T5 Thm 3.2.

#### C-13. Cor 7.2 — severity: ok
* *Description.* Verified for finite T and κ>0. There is one edge-case convention: if there are no fallacies, take max over the empty set =0, so that a valid rule with π_r=0 makes both sides false. With infinitely many tags, min/max should become inf/sup, and then the 'iff' can fail at a non-attained common value.
* *Evidence.* Brute-force comparison of 'exists κ>0 with MAP = valid set' against the stated condition on 3000 random instances: 0 mismatches under the convention max∅=0.
* *Suggested fix.* State 'T finite, π_r>0 for valid r, κ>0' (or the max∅ convention).

#### C-14. Prop 7.3 counterexample to the vertex conjecture — severity: ok
* *Description.* Verified exactly. The rates are κ_A=0.4, κ_F=0.05, κ_B=0.002, and the MAP sequence is {A,B,F}→{A,F}→{A}→∅. The result is stronger than stated. {A,B}=(50 bits, 0.4 bits/datum) is Pareto-dominated by {A,F}=(18, 0.08), and it is interior to the *full* convex hull (vertices ∅,{A},{A,F},{A,B,F},{B,F},{B}). So it fails under any reading of 'vertex' and under every monotone complexity/likelihood trade-off. Because it is interior to the hull of the other subset-points, adding more hypotheses cannot make it a vertex.
* *Evidence.* Script output: hull vertices [[],[A],[B],[A,F],[B,F],[A,B,F]]; 'AB vertex? False'; 'dominators of AB: [[A,F]]'. robust_core_and_mdl.py: 'true rule set {A,B} selected for some kappa in scan: False'.
* *Suggested fix.* Optionally add the Pareto-dominance remark, which makes the refutation independent of the hull formalization.

#### C-15. Section 7 Assessment and consistency with T5 (and T1 Thm 6.4 / T2 Cor 6.2 references) — severity: minor
* *Description.* This is a framing inconsistency across project files, not a mathematical error. T4 §0 says the user's vertex conjecture is 'false in general'. T5 (lines 28, 52, 265, 537) says 'His convex-hull argument is correct' and 'He is right ... about the convex hull', and T5 Thm 4.1(ii) / Prop 4.2 already contain the same freshman's-dream counterexample. Both are right: the hull-selection mechanism is correct, the universal claim is false, and it does hold in the user's own motivating regime of rare, expensive, idiosyncratic errors (T5 Thm 3.5). T4 should say so. Also, 'T1's Thm 6.4 frequency threshold in MDL clothing' is a loose analogy: T1 Thm 6.4 is a frequency-versus-error-rate threshold, not a frequency-per-bit one. The T2 Cor 6.2 citation and the a=b=1 refutation of F are correct.
* *Evidence.* T4 line 70 vs T5 lines 52, 265. L10 line 149 shows the user's worked example was rare 10000-bit errors.
* *Suggested fix.* In §7, add: 'the conjecture holds when errors are idiosyncratic and expensive (T5 Thm 3.5), and fails for cheap systematic fallacies'. Cross-cite T5 Thm 4.1/Prop 4.2 and soften 'in MDL clothing' to 'analogous to'.

**Overall.**

I found nothing fatal in §§6–7. All of §7 checks out exactly (Props 7.1 and 7.3, and Cor 7.2 under an edge-case convention): brute force over 3000 random instances found no violations, and I recomputed the convex hull. The counterexample is stronger than the file claims: the true rule set {A,B} is Pareto-dominated by {A,F} and lies strictly inside the full convex hull. Prop 6.4 is correct, including its sorites tightness, but it is standard (Adams/Edgington, lottery paradox), so §0's claim that it is new mathematical content is overstated. The §6 results are correct only under their intended readings, with two major defects. (1) Thm 6.2(c)/(d) mixes up g-step validity (St^g) with validity (⊨). Under the file's own definition of soundness (Thms 2.4, 2.6), the claim 'any acceptance set sound for every target is contained in St^g_SV' is false: the largest sound set is ⊨_SV. The abstention-region claims in (d) fail for steps in ⊨_SV∖St^g_SV. (2) Prop 6.5's formal statement is fine, but its 'bounded repertoire' hypothesis is never used. The surviving repertoire A_0∩⊨_T can be undecidable and has no bounded gap, so the advertised explanation of how the nice notion of proof arose is not supported. Minor issues: Thm 6.2(b) leaves out escalation answers from its hypotheses and overclaims 'learns exactly'; Thm 6.2(a) ignores noise steps; Thm 6.3 needs a domain condition and does not actually use Gödel completeness; §6 and §4.3 describe Lakatos's moves differently; the Steiner 7776 example is mischaracterized; and ⊨_SV is labelled as Fine's (global) supervaluational validity when it is local validity. I re-ran T4-checks/robust_core_and_mdl.py and it reproduces every claim it is cited for. Its union-bound check is a tautology.


---

## Part 2. Author-repairer's verification log

Three independent adversarial referees checked this file. Referee A covered §1–§3, referee B covered §4–§5, and referee C covered §6–§7 together with the related claims in §0 and §8. The full reports are in Part 1 above. Issue numbers below (A1, B1, C1, …) follow the order of each report.

I re-checked every issue by hand, and by computation where that helped:
* A new script, `T4-checks/verification_checks.py`, was added to `run_all.sh`. It covers:
  * V1: Thm 3.4(d), the counterexample, and the revised statement on 2604 random (target, rival) pairs;
  * V2: Thm 5.2(iv) on all sub-supports;
  * V3: the figures after Thm 4.4, and the antichain;
  * V4: $M_{\rm obj}=\mathrm{Ldim}$;
  * V5: Prop 4.6′.
* I re-ran `bag_vs_object_game.py` and `robust_core_and_mdl.py`, and recomputed the Prop 7.3 convex hull.
* I checked the cross-references to T1 (Thms 3.2, 3.9, 4.4, Cor 4.5), T5 (Lemma 3.1, Thms 3.2, 3.5, 4.1, Prop 4.2), L6 (Steiner row) and L8 (TC4).

Numbering is unchanged. Materially changed items are marked "(revised after verification)". There is one new item, Prop 4.6′, and one new open problem, §8 item 6. No reported issue was rejected. Some referee citations and historical claims are from memory; I adopted them with "unverified" flags rather than asserting them.

**Fatal and major issues (all genuine, all fixed).**

| # | item | sev. | verdict | action |
|---|---|---|---|---|
| A1 | Thm 3.4(d) | fatal | **Genuine.** Bounded-gap practice plus complete objects never refute a rival with *strictly weaker* $\models$ on $D^*$ that still contains $\mathrm{St}^g_{h^*}$. The proof broke at "Case 2 is unchanged", which needed ${\models_{h^*}}\subseteq{\models_h}$. Re-checked with V1. The 4-atom chain counterexample survives for $g\le3$ and is refuted at $g=4$. On 2604 random pairs the original statement mismatches the true survivors 527 times and the revised statement 0 times. The original statement mismatches 0 times on the 1545 pairs whose target is step-expressive. | **Statement revised.** Survivors are $S^g=\{h:\mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*},\ {\models_h}\vert_{D^*}\subseteq{\models_{h^*}}\}$. The accepted relation is still exactly $\mathrm{St}^g_{h^*}$. Meaning is bracketed, $\mathrm{Ch}_{D^*}(\mathrm{St}^g_{h^*})\subseteq{\models_h}\vert_{D^*}\subseteq{\models_{h^*}}$, and the original characterization is recovered under step-expressiveness on $D^*$. Full new proof (practice / objects (both directions) / coherence / conclusion), counterexample and computation recorded. Propagated to: "What (d) says" (two kinds of never-excluded rivals), §0 item 2, §3.5 items 2 and 4(b), Prop 2.8 remark, Prop 3.6, §8 table, open problem 6, experiment 6. |
| A2 | Prop 3.6 | major | **Genuine, both parts.** (1) Nelson's reduction algorithm is for standard parameters only; the $f(x)=Nx$ example is right. (2) By Case 1 of Thm 3.4(d), shorter IST steps *refute* $h_{\rm W}$. The text claimed the opposite. | Restricted to $D_{\rm st}$. Contextual constants are read as standard ($T_{\rm IST}=\mathrm{IST}+\mathrm{st}(c)$), and infinitesimal suppositions are folded into bound variables. $\rho_{\rm W}$ is defined as the reduction output. The proof is completed: reduction, deduction theorem plus transfer, conservativity. The tag is now "proved modulo cited theorems of Nelson". Added that $\rho_{\rm W}$ need not be the textbook ε-δ reading. The granularity bullet is corrected: the data are decisive against $h_{\rm W}$ as a granularity hypothesis, and meaning is unaffected. |
| B1 | Thm 5.2(iv) first bullet; ℓ remark; §0 item 4 | major | **Genuine.** The project's own learner gives POS for {INT, UNI} and SEP for {INT, DIFF}. V2 confirms the exact conditions on all 93 sub-supports (31 × 3 families), with 0 mismatches. I also found that with V in a partial support, POS can tie STRAT and win by ℓ. | The bullets are restated for full supports (DC; DC ∪ {ZR}; DC ∪ {ZR, V}), with exact conditions for sub-supports. The ℓ remark is corrected: only for full supports do two comparisons suffice, and the ordering is flagged as stipulated, so the outcome is ℓ-dependent. The historical reading and §0 are qualified: a purely positive practice selects POS. |
| C1 | Thm 6.2(c), (d); §0 item 5 | major | **Genuine.** It conflated $\mathrm{St}^g$ with $\models$. The ∧-introduction counterexample ($q\Rightarrow q\wedge(q\wedge q)$ at $g=1$) is right. | (c) split into (c1): ⊨-sound ⇒ ⊆ ${\models_{\rm SV}}$; and (c2): $g$-sound ⇒ ⊆ $\mathrm{St}^g_{\rm SV}$, attained. (d) split into (d1): outside ${\models_{\rm SV}}$, removable only by a definition or lemma-incorporation; and (d2): ${\models_{\rm SV}}\setminus\mathrm{St}^g_{\rm SV}$, removable by expansion or library growth. The faulty proof step is identified and corrected. §0 updated. |
| C2 | Prop 6.5 and its interpretation; §0 item 5 | major | **Genuine.** The bounded-repertoire hypothesis was unused, and $A_0\cap{\models_{\rm PA}}$ is undecidable with no gap bound. | Restated in three parts. (a) Derivability: single-sharpening statement with $T,\rho^*$, vague case per σ, "interpolates into a derivation". (b) No gap bound follows, with the PA example proved via decidability of $\mathrm{St}^g$. (c) A bounded gap follows under schema-level selection plus *uniform derivability*, a notion now defined. This is automatic for pure propositional schemas. It fails in PA, shown via Gödel II rather than any proof-length claim; I avoided the referee's "unbounded length" wording because that is Kreisel-conjecture territory. The "three ingredients" are rewritten so that ingredient 3 is an explicit extra hypothesis. Added the caveat that completeness of the surviving calculus does not follow. §0 updated. |

**Minor issues (all genuine, all fixed).**

| # | item | action |
|---|---|---|
| A3 | Lemma 3.3 | (iii) now reads "$y\in D_h$", with its proof written out. The gloss is replaced by exact converses: $\mathcal V_h$ determines $\models_h$ when $\mathcal V_h\neq\emptyset$; coherence of all finite subsets of $D_h$ determines it; a fixed $\mathcal A$ does not. Tagged "standard corollary". The novelty claims in §0 and §8 are adjusted. |
| A4 | Thm 3.4(a)–(c) | Added the hypotheses nonempty domains, consistent $T^*$ and designated contexts in $D^*$, with the empty-ρ counterexample. (b) now cites the closure-level Prop 3.2. (c) names $V^\infty$ and says it is information-theoretic (co-r.e. refutation), in contrast with (d). |
| A5 | Thm 2.5 Remark; §0 item 1 | Rewritten. $W^*$ counts the $\equiv_g$-class: renamings and Prop 3.5 ontological variants. The ≈-class mass matters only for a closure-level verifier. |
| A6 | Thm 2.7 | Only oracle-answered escalations are counted. (c) now says (a) is tight, and (b) is tight up to $O((\ln(1/W^*)+\ln(1/\delta''))/\delta')$ by T1 Cor 4.5 (checked in T1). |
| A7 | Formal model | (1) §1.3 routes larger steps to expansion or noise, and Thm 2.4 now assumes (P) ⊆ $\mathrm{St}^g_{h^*}$. (2) The effectivity assumptions are listed in §1.2. (3) A convention for partial readings is added in §1.4. (4) Membership in $\mathrm{VS}_t$ is decidable, but $V^g_t$ is computable only for finite $\mathcal H$; otherwise use Prop 2.6. |
| A8 | Lemma 2.2 | Domain condition added; unused premises are dropped. Carried into Thm 2.4. |
| A9 | Prop 3.5 | The hypothesis is now "$R$ sound for both, agreement on $\rho(\mathrm{dom}\,\rho)$". The instance uses only bounded axioms. Added why full elementary equivalence fails (the referee's unbounded sentence, checked in outline). |
| A10 | Prop 3.2 | Assumptions (i)–(iv), the closure-level version and an inductive proof are added. |
| A11 / B20 | Prop 2.3 commentary; §2.1 and §5.4 history | Seidel/Stokes wording fixed ("arbitrarily/infinitely slow"); the term "uniform convergence" is attributed to Gudermann and Weierstrass, flagged unverified. Abel's series is named. Frege's way out: Leśniewski 1938 (Sobociński 1949) and Quine 1955, flagged unverified. |
| B2 | Thm 4.3 novelty | Added (c). The object game is the equivalence-query model with improper hypotheses, which is the mistake-bound model, so $M_{\rm obj}=\mathrm{Ldim}$ (Littlestone 1988) [cited]. V4 confirms it on 248 random classes. Halving citations added. §0 and §8 updated. |
| B3 | Thm 4.4(a) | Now $M_{\rm bag}\le\mathrm{el}^*\le\vert\mathcal H\vert-1$, with the one-line argument. |
| B5 | Thm 4.4(c) | Sorites re-indexed: $q_k$ = "a pile of $n-k$ grains is a heap". |
| B6 | Figures after the table; antichain claim | Replaced by the script-reproduced figures 295 / 43 / 195 (V3); "244 / 32" withdrawn. The antichain claim is restricted, with counterexample $\{\{1\},\{0,3\},\{0,4\}\}$ ($M_{\rm bag}=1$, $\mathrm{el}^*=2$, V3). |
| B7 | Thm 4.5 phrasing | Restated as a per-target bound for the learner, then the minimax bound with the uniform prior. |
| B8 | Prop 4.6 proof | Rewritten: object upper bound ("every step not yet refuted"), adversary argument for $M_{\rm obj}\ge k$, and a potential Φ covering all bag cases. The referee's extra product values are recorded as referee computation. |
| B9 | "Settles TC4" | Rephrased: this refutes the Ldim × polylog(r) form and gives an $O(r\log\vert\mathcal H\vert)$ upper bound; an Ldim-only bound is open. Novelty marked uncertain, with a possible lead (unverified). |
| B10 | Conjecture | Restated as $M^{(r)}_{\rm bag}\le r\cdot\mathrm{Ldim}$. **New Prop 4.6′** proves the case $M_{\rm obj}=1$; I checked the proof, and V5 finds 0 violations in 304 pairs. Equality is qualified to $r\le n-1$ and $r\le b-1$. The referee's larger search is recorded as referee computation. |
| B11 | Def 4.2 availability | Object-completeness is now stated relative to ${\models_{h^*}}$ (it fails for $\mathcal H^g$ targets). Bag-availability is explicit. The consequence for silent unsoundness is stated. |
| B12 | "Moral" | Rewritten. Russell's paradox is a size-1 bag; set-theoretic non-selection is about generalization (Thm 5.1(e), 5.2(iii)). |
| B13 | Prop 4.7 | Reworded around a zero-cost selection criterion; the truthful-objects assumption is explicit. |
| B14 | Thm 5.1 | argmin over $c\in\mathcal R$. (d) requires $\ell_1$ convergence (Scheffé), and its proof is made quantitative. |
| B17 | ZR label; ℓ stipulation | ZR relabelled as Zermelo's 1908 subset (the diagonal for $f=\mathrm{id}$). Added a modelling caveat about Cantor's function-parameter diagonal, and flagged the ℓ-dependence. |
| B19 | Incurvati–Murzi consequence (b); §0 | (b) is now restricted to r.e. axiomatizations, and the Δ₂ greedy limit construction is noted (checked). "Under minimal assumptions" restored in §0. |
| B21 | Lemma 4.1 | "New" softened. |
| C3 | Thm 6.2(b) | Oracle-answer hypothesis added. New (b′) proves convergence for finite $\mathcal H$ with complete practice. Effectivity remark added, with the referee's $\Pi_1$ example. (c) carries the data hypotheses of (b). §0 no longer says "learns exactly". |
| C4 | Thm 6.2(a) | Restricted to arguments made of non-noise practice items; the theorem clause requires $T_\sigma$-provable premises. |
| C5 | Thm 6.3 | Domain hypothesis added. The proof is "by definition; completeness makes such $R_\sigma$ exist". Scope: the theorem concerns ⊨, not $\mathrm{St}^g$, and monsters need not be SV-presentable (Abel). §4.3's Lakatos terminology is aligned with §6. |
| C6 | Def 6.1 | Relabelled "(local) supervaluational validity". The global/local distinction is cited, with attributions flagged unverified. |
| C8 | Remark after Prop 6.4 | Restricted to the two precise statements. |
| C9 | Novelty of Prop 6.4 | A "Not new" paragraph cites Adams, Adams–Levine, Suppes, Edgington and Kyburg (unverified). Removed from §0's "real content". |
| C10 | Prop 6.5 statement | Folded into the C2 revision. |
| C11 | Euclid / Steiner | Steiner sentence rewritten: excess Veronese surface for every input, correct count 3264, consistent with L6. Relabelled "an analogy, not a proven instance". ADM completeness is now stated for a restricted class of sequents. |
| C15 | §7 Assessment; §0 item 6 | Cross-cites T5 Lemma 3.1, Thm 3.5, Thm 4.1 and Prop 4.2. Notes that the conjecture holds in the rare-expensive-error regime. "In MDL clothing" → "analogous to". |

**Items reported correct ("ok"); optional suggestions adopted.** A12 Thm 2.4 now states the inherited caveats (A7, A8). A13 Prop 2.6: no change. A14 Prop 2.8: weaker-hypothesis remark added. A15 Prop 3.7: closed-sentence and transport note added. B4 Thm 4.4(b): no change. B15 F1–F6: no change. B16 Thm 5.2(i)–(iii): no change. B18 Prop 5.4: added "exactly $2^{\aleph_0}$", pure logic, and the Extensionality variant (checked: $n=1$ must be excluded). C7 Prop 6.4: domain caveat, links counted, measurability, tightness for every ε ≤ 1/n, and the script's union-bound check described as tautological. C12 Prop 7.1: cross-reference to T5 Thm 3.2. C13 Cor 7.2: conventions made explicit. C14 Prop 7.3: Pareto-dominance remark added; I recomputed the hull ({A,B} is strictly interior, facet margin 0.38).

**Needs re-verification** (statement or proof changed non-trivially):
* Thm 3.4(d), together with the new hypotheses of (a)–(c);
* Prop 3.6;
* Thm 5.2(iv);
* Thm 6.2, i.e. (b′), (c1)/(c2), (d1)/(d2);
* Prop 6.5;
* Prop 4.6, whose proof was rewritten;
* Prop 4.6′, which is new;
* Thm 4.3(c), a new cited claim;
* Prop 3.5, whose hypothesis changed;
* Prop 3.2, whose proof was added.
