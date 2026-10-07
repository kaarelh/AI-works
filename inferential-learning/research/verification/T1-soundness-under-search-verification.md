# Verification record: T1-soundness-under-search.md

Target file: `../theory/T1-soundness-under-search.md`. Project context: `../00-brief.md`.

This record holds:
1. a faithful copy of the two independent adversarial referee reports (rendered from JSON to Markdown, content unchanged);
2. the author-repairer's verification log: for each reported issue, whether it is genuine and what action was taken.

The same log is appended to the theory file as `## Verification log`.

---

## Part 1. Referee reports

### Referee A (Sections 1–3)

**Items checked.**
* Lemma 1.1; Thm 2.1; Cor 2.2; Prop 2.3; Prop 2.4.
* Thm 3.1 (a),(b) and the remark after it; Definition (positive elasticity); Thm 3.2 (incl. randomized delta-sound lower bound); Prop 3.3 (incl. intersection-closure of H_1).
* Lemma 1.2; Lemma 1.3.
* Thm 3.4 (incl. [computed] tightness); Prop 3.5; Thm 3.6; Thm 3.7 (i), (ii), (iii) and its [computed] values; Conj 3.8 and its claimed evidence; Thm 3.9.
* Re-ran T1-code: elast.py, subcube.py, abstr2.py (d=3 and d=4), icclimb.py (all three runs).

**Issues.**

#### A-1. Thm 3.1(b) (optimality of VS verifier), lines 200-208, and the remark at line 208 — severity: major
* *Description.* Part (b) is stated for possibly randomized verifiers, with p read as the acceptance probability at a given history. Read that way, it is false: p is the conditional probability given the history, and a randomized delta-sound verifier can reach a history with probability <= delta and then accept with conditional probability 1. The proof's step 'the verifier's coins have the same law' only shows that the JOINT probability Pr[history occurs and q is accepted] is <= delta. The remark at line 208 has the same flaw. For random human data, a delta-sound verifier only guarantees Pr_{R'}[observed data] * p <= delta, not p <= delta.
* *Evidence.* Counterexample (P_0 empty): H={R1={a,c}, R2={a,b,c}, R3={a,b}}. Verifier: with probability eps it enters 'reckless' mode and accepts everything; otherwise it runs the VS verifier. It is eps-sound, since only reckless mode ever accepts an invalid step. Take target R*=R2 and history h = (query c, ACC). This history is consistent with R2 and also with R'=R1, because c is in R1. At h, VS = {R1,R2,R3} (no labels), so the intersection of VS is {a} and b is outside it. Given h, the verifier accepts b with probability 1 > eps = delta. Simulation /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/thm31b.py: Pr[reach h]=0.0100, Pr[ACC b | h]=1.000, delta=0.01. For the data remark: if the observed data has probability 1e-6 under R', a 0.01-sound verifier may accept q (outside R') with conditional probability 1.
* *Suggested fix.* Restate (b) in one of two ways. Either restrict it to deterministic verifiers, or let p := Pr[the verifier produces this history's answers and then accepts q] (unconditional, for the prover that issues the history's queries). Reword the line-208 remark: with random data the bound is Pr_{R'}(data) * p <= delta. Thm 3.2 needs only the unconditional version (see the Thm 3.2 entry).

#### A-2. Prop 2.3 (every unsound schema is a tonk), line 167; the claim at line 174; Summary line 21 — severity: major
* *Description.* Under its explicit hypothesis (A closed under uniform substitution), the proposition and its proof are correct. The parenthetical 'as the instance set of any family of schemas is' is false in the file's own encoding: in §1.3, object-language atoms are constants of Sigma, so schemas (and the lggs of anti-unification) can contain specific atoms. Such instance sets are not closed under substitution. So the headline claims 'In classical propositional logic, every unsound schema trivializes' (line 21) and 'For schema-structured hypotheses in classical logic, any error is total' (line 174) are false as stated.
* *Evidence.* Take the one-metavariable schema ({x v p_0}, x). This is Thm 2.1's T_j with an atom in place of T^(j). It is unsound: ({p_1 v p_0}, p_1). Let A = R*_CPC ∪ inst(it). Then Cn(¬p_0) contains every tautology and is closed under A: if ¬p_0 ⊨ B v p_0 then ¬p_0 ⊨ B. So Cl_A(∅) ⊆ Cn(¬p_0), which does not contain p_0. The reasoner is unsound (it derives ¬p_0) but not trivial. A is not closed under substitution: p_0 ↦ p_1 sends ({p_2 v p_0}, p_2) to an unsound step that is not an instance.
* *Suggested fix.* Replace 'as the instance set of any family of schemas is' with 'as the instance set of any family of pure schemas (no object-language atoms as constants) is'. Weaken lines 21 and 174 to match. Note that schemas mentioning atoms can be unsound without trivializing, for example by adding ¬p_0. That case is exactly where coherence-based detection, the dependence of Prop 6.6 and T2 Thm 3.1 on this proposition, needs re-checking.

#### A-3. Cor 2.2 (PAC learners can be maximally unsound), lines 158-165 — severity: minor
* *Description.* The bound Pr[Q(T_ĵ) > eps] <= (1-eps)^m and its proof are correct. The claim 'every output of L^+ makes every formula derivable' (and 'whose every output trivializes the reasoner' in the Summary) is false for a general L. The Thm 2.1 derivation needs ⊤I, ∧I and ∨I_2 in the output, and nothing forces L's output to contain them.
* *Evidence.* Let Q put no mass on ∧I or ⊤I steps. Let L be the closure learner over unions of the six basic schemas, which outputs only schemas witnessed in the sample, so it is PAC for that class. Then L^+ = (∧E, ∨I) ∪ T_ĵ, and Cl(∅) = ∅, because every T_j step and every ∧E/∨I step needs a premise. Even more simply, L ≡ ∅ gives L^+ = T_ĵ with empty closure.
* *Suggested fix.* Define L^+ := L(X) ∪ T_ĵ ∪ inst(⊤I, ∧I, ∨I_2). These steps lie in R*, so adding them cannot increase Q(h Δ R*), and the PAC bound is unchanged. Also replace 'same rates' in the Summary with 'same rates up to O(eps^{-1} log delta^{-1}) extra samples'.

#### A-4. Thm 3.2 (escalation dimension = positive elasticity), lines 212-218 — severity: minor
* *Description.* The statement is correct, including the randomized lower bound (1-delta)m. The upper bound is right: the VS verifier never rejects honest queries, and its escalated queries form an elastic chain in R*. The lower-bound proof cites Thm 3.1(b), but read conditionally that result is false (see that entry). What is needed, and what holds, is the unconditional fact. The honest prover queries s_1..s_m non-adaptively. Every s_j with j<i lies in both R and R_i, so the oracle answers agree. Hence the transcript law through round i is identical under R and R_i, and Pr_R[s_i accepted] = Pr_{R_i}[s_i accepted] <= delta. Summing gives E[cost] >= (1-delta)m. Separately, Def 1.3 never says what 'cost' means for randomized verifiers (expected or almost-sure); with delta=0 it is m almost surely, so the equality is unaffected.
* *Evidence.* Proof step at line 218: 'By Thm 3.1(b), applied with target R_i, round i is accepted outright with probability <= delta'. This requires the unconditional probability, which the coupling above supplies directly.
* *Suggested fix.* Replace the citation with the two-line coupling argument, or cite a corrected Thm 3.1(b) in its joint-probability form. In Def 1.3, define the cost of a randomized verifier as its expected cost.

#### A-5. Conj 3.8 (binomial bound) — claimed evidence, lines 291-298 — severity: minor
* *Description.* The hill-climbing evidence is misreported at h=5. icclimb.py is run on a universe of only 14 points for h<=5 (run_all.sh: 'icclimb.py 14 2000 31 5'). Elasticity is at most the number of points, so 14 is a hard ceiling. That run could never reach the conjectured 15 or find a counterexample, which would need 16. '14 against conjectured 15' therefore reflects the universe size and is not evidence of slack. In fact the conjectured value is attained for k=2 at every h tested: the flats of the graphic matroid M(K_{h+1}) have height h and 2-union elasticity exactly C(h+1,2). So if the conjecture is true, it is tight at k=2. The claim that 'a natural one-step decomposition proof fails on some extremal sequences [computed]' has no script in T1-code and could not be checked. I found no counterexample.
* *Evidence.* Re-ran icclimb: h<=3 (m=9) best 6; h<=4 (m=12) best 10; h<=5 (m=14) best 14 = m. My graphic.py (scratchpad) gives K_3..K_6: height 2,3,4,5 and elasticity 3,6,10,15 = C(h+1,2); for k=3, K_4 and K_5 give 6 and 10 (< C(h+2,3) = 10 and 20). My own hill-climb (conjsearch.py), seeded both randomly and from K_5, on 11-12 points with h<=4 found at most 10, and at most 6 for h<=3. Proof for (k=2, h=3): atoms are pairwise disjoint and two coatoms share at most one atom. An elastic sequence has at most one element per atom, and at most 3 elements on any coatom, since every closed set avoiding an element meets that coatom in an atom or ∅. If m=7, s_1..s_6 split 3+3 between two coatoms X and Y. Say s_6 lies in Y. Then its two cover sets must include X itself, and the other cover set meets Y in at most 1 element, so it cannot cover both earlier Y-elements. Contradiction, so m <= 6 = C(4,2).
* *Suggested fix.* Correct the evidence: report that the h=5 search was capped by its 14-point universe, and rerun with at least 16 points. Add that M(K_{h+1}) attains C(h+1,2) for k=2, so the bound would be tight. Add the (k=2, h=3) case as proved. Either include the script for the one-step-decomposition claim or drop the [computed] tag.

#### A-6. Thm 3.4 (single schema by anti-unification), lines 233-243 — severity: minor
* *Description.* The bound and the tightness claim are correct, and the computations reproduce. Two presentational gaps. (1) The display 'Esc(H_1; |s|<=N) <= 1+N-mu(sigma*)' bounds a quantity that is a sup over all targets by something that depends on the target. It should be el(H_1, sigma* | ∅; N) <= 1+N-mu(sigma*), with Esc(H_1;N) = N+1. (2) 'By Prop 3.3, a chain is a strictly increasing generalization chain' needs a word. Prop 3.3 gives a chain of instance sets C_i. Taking g_i := lgg(C_i) turns inclusion C_{i-1} ⊊ C_i into strict generality g_{i-1} ≺ g_i, by the lgg property, with no assumption on the signature.
* *Evidence.* elast.py, k=1: {a,b,g} N=3..7 gives 4,5,6,7,8 = N+1; {a,b,g,f} N=3,4,5 gives 4,5,6; {a,b,g,p} N=3,4 gives 4,5; with one constant, {c,g,p} N=3,4,5 gives 3,4,5 = N. I checked the explicit chain g^{N-1}(a), g^{N-1}(b), g^{N-2}(a), ..., a by hand. Lemma 1.2 makes mu drop strictly.
* *Suggested fix.* Write the target-dependent quantity as el(.,sigma*|.) and state Esc(H_1;N) = N+1 separately. Add 'choose representatives g_i = lgg(C_i)'.

#### A-7. Prop 3.5 (two-sided KWIK is super-exponential), lines 245-253 — severity: minor
* *Description.* The construction is correct: Bell(n) forced escalations on steps of size n+1. But 'super-exponential' (and 'Bell(N-1)' in the comparison at line 253) needs a signature that grows with N: n+1 constants and an n-ary symbol. For any fixed finite signature, two-sided cost is at most the number of distinct steps of size <= N, which is 2^{O(N)}, so it cannot be super-exponential in N.
* *Evidence.* Brute force (checks37.py: all depth-1 schemas f(t_1..t_n), t_i ∈ {a, b_j, vars}, plus x; queries in decreasing order of number of blocks): forced escalations 2, 5, 15 = Bell(2), Bell(3), Bell(4) for n = 2, 3, 4.
* *Suggested fix.* State that the signature grows with N (n+1 constants and an n-ary f). Optionally add that for a fixed signature the two-sided cost is at most exponential in N, and give a fixed-signature exponential lower bound if one is wanted.

#### A-8. Thm 3.6 (k tagged rules), lines 255-260 — severity: minor
* *Description.* The conclusion el = sum_i el_i is correct. The justification 'a product of k intersection-closed classes ... hence intersection-closed' is not literally true. H^tag_k ∪ {∅} is not closed under intersections, because one rule's component can become ∅ while the others stay nonempty, and such a set is not in H^tag_k. What actually holds is that VS factors as a product of nonempty per-rule version spaces, so the intersection of VS is the union over i of {i} × (intersection of VS_i). The displayed bound sum_i(mu(lgg P_0^(i)) - mu(sigma_i*)) is undefined when some P_0^(i) is empty; that rule then costs 1 + N - mu(sigma_i*).
* *Evidence.* ({1}×inst(a) ∪ {2}×inst(c)) ∩ ({1}×inst(b) ∪ {2}×inst(c)) = {2}×inst(c), which is not a member of H^tag_2 and not ∅.
* *Suggested fix.* Argue through the product structure of VS, or allow empty rules (use (H_1 ∪ {∅})^k). Write the bound as sum_i el_i with el_i <= mu(lgg P_0^(i)) - mu(sigma_i*) if P_0^(i) is nonempty, and <= 1 + N - mu(sigma_i*) otherwise.

#### A-9. Thm 3.7(iii) / Summary line 29 ('For flat schemas it is Theta(n^k)') — severity: minor
* *Description.* Theta(n^k) is proved only for LINEAR flat schemas (subcubes). With repeated metavariables, the file proves only O(n^{2k}) (the 1+(2^{2k}-1)C(n,2k) bound), so the unqualified Summary phrase overstates. Separately, the (iii) bounds use k-sets of coordinates and so need n >= k.
* *Evidence.* Line 268 gives Esc <= 1+(2^{2k}-1)C(n,2k) with repeated metavariables, against a lower bound of order n^k.
* *Suggested fix.* Write 'For linear flat schemas it is Theta(n^k); with repeated metavariables, between Omega(n^k) and O(n^{2k})', and add n >= k.

#### A-10. Thm 3.7 (i),(ii),(iii) main statements and [computed] values — ok
* *Description.* Verified. (i): the explicit sequence p(g^{a_1}c,...,g^{a_k}c), queried in non-increasing order of sum a_j, escapes the stated k-union witness at every step, and all sizes are <= N. (ii): every step of the chain/partition argument checks: s_{i_b} lies outside inst lgg(prefix), mu decreases strictly, chains have length <= N+1, and the block recursion gives g(d) <= 1 + k g(d-1). (iii): the pattern-counting upper bound, the weight-ordered lower bound and the repeated-metavariable extension (half-cubes and {x_i = x_j} with p_i != p_j) are all correct.
* *Evidence.* checks37.py: (k,n) = (2,1),(2,2),(2,3),(3,1),(3,2) give sequences of length (n+1)^k, all elastic, matching floor((N-1)/k)^k. Re-ran T1-code: {c,g,p} k=2 N=3,4,5 gives 4,8,13 (universes 4,8,17); {a,b,g,p} k=2 N=3,4 gives 8,13; subcubes k=2 n=2,3,4 give 4,7,11; the partition abstraction reaches 7 (d=3) and 15 (d=4), i.e. 2^d-1 as claimed.
* *Suggested fix.* None.

#### A-11. Lemma 1.1 (reasoner soundness = stepwise soundness) — ok
* *Description.* Both directions are correct (monotonicity and idempotence of Cl_{R*}, and leastness of Cl_A). One wording nit: line 77 says a 'false conclusion' where 'non-derivable conclusion' is meant.
* *Evidence.* Checked line by line.
* *Suggested fix.* Optional: replace 'false' with 'non-derivable' at line 77.

#### A-12. Thm 2.1 (tonk beyond the horizon) — ok
* *Description.* (i): the derivation has j+2 steps (1 ⊤I, j-1 ∧I, 1 ∨I_2, 1 T_j). (ii): the T_j are pairwise disjoint, so Q(T_j) → 0. Two nits. 'Exactly one invalid' fails when C is a tautology and R* is taken to contain all sound steps. 'Union of finitely many pure schemas' needs R* to be finitely schematized, but line 139 says 'plus any other sound rules'.
* *Evidence.* Checked the step count and the disjointness of the T_j.
* *Suggested fix.* Optional: say 'for non-tautologous C' and 'R* given by finitely many schemas'.

#### A-13. Prop 2.4 (simplicity is the wrong bias) — ok
* *Description.* Trivially true: x has size 1 and covers everything. The tie with a size-1 constant when the data is a single constant is immaterial. The rest is informal discussion.
* *Evidence.* –
* *Suggested fix.* None.

#### A-14. Thm 3.1(a) — ok
* *Description.* Truthful labels keep R* in VS, so the intersection of VS is contained in R*. This is deterministic, so the soundness is uniform.
* *Evidence.* –
* *Suggested fix.* None.

#### A-15. Prop 3.3 (intersection-closed classes) and the closure of H_1 — ok
* *Description.* Both directions of the chain correspondence are correct. H_1 ∪ {∅} is closed under arbitrary intersections: pairwise via the mgu, and arbitrary intersections reduce to finite ones because a ground term has finitely many generalizations up to renaming. The attribution (closure algorithm; Natarajan 1987; Helmbold, Sloan & Warmuth 1990) is appropriate.
* *Evidence.* Checked line by line.
* *Suggested fix.* None.

#### A-16. Lemma 1.2 (rank) — ok
* *Description.* The size and variable-count identity, the bound on each summand (0 for a variable, >= 1 otherwise), and the equality-iff-renaming conclusion are all correct.
* *Evidence.* lem12_13.py: 20,000 random (sigma, theta) pairs, including non-ground images and images sharing variables, with 0 failures of 'mu(sigma theta) >= mu(sigma), with equality iff theta is a renaming on vars(sigma)'.
* *Suggested fix.* None.

#### A-17. Lemma 1.3 (when the lgg recovers the schema) — ok
* *Description.* Correct, including the edge cases n=1 and ground sigma.
* *Evidence.* lem12_13.py: 20,000 random cases comparing lgg(t_1..t_n) ≡ sigma against (R) ∧ (D), with 0 failures; lgg ⪯ sigma held every time.
* *Suggested fix.* None.

#### A-18. Thm 3.9 (unstructured classes) — ok
* *Description.* Correct: each escalation removes at least one hypothesis and R* survives, and the class {U minus {u}} attains |U|-1. The KWIK enumeration attribution (Li, Littman & Walsh 2008) is right.
* *Evidence.* –
* *Suggested fix.* None.

**Overall (Referee A).** Sections 1-3 are mostly sound. Every [computed] claim in scope reproduces, and I found no counterexample to any of the main theorems (Thm 3.2, 3.4, 3.7) or to Conjecture 3.8. Three statements are wrong as written.

1. **Thm 3.1(b) (major).** Read as a conditional probability at a given history, it is false for randomized verifiers, which the statement explicitly includes. I give an explicit eps-sound counterexample: it reaches a history with probability eps and then accepts a step outside the intersection of VS with probability 1. Only the joint-probability version is true. Thm 3.2's (1-delta)m lower bound survives, through a direct coupling argument.
2. **Prop 2.3's gloss (major).** The parenthetical 'as the instance set of any family of schemas is', and the headlines 'every unsound schema trivializes' (Summary line 21, and line 174), are false in the file's own §1.3 encoding, where atoms are constants. The schema ({x v p_0}, x) is unsound but only adds ¬p_0.
3. **Cor 2.2's 'every output trivializes' (minor).** It fails unless L's output contains ⊤I, ∧I and ∨I_2. Adding these three valid schemas fixes it at no cost to the PAC error.

The remaining issues are minor:
- Prop 3.5's 'super-exponential' holds only if the signature grows with N.
- Thm 3.6's 'intersection-closed' is not literal, though its conclusion is right.
- The Summary's 'Theta(n^k) for flat schemas' is proved only for linear flat schemas.
- Thm 3.4 and Thm 3.2 have notation and citation slips.
- Conj 3.8's evidence is misreported. The h=5 search ran on a 14-point universe, so '14 vs 15' is a ceiling artifact. In fact the conjectured C(h+1,2) is attained exactly at k=2 by the graphic matroid M(K_{h+1}) (computed for h=2..5), and I sketch a proof of the case k=2, h=3. Targeted searches found no counterexample.

Lemmas 1.1-1.3, Thm 2.1, Prop 2.4, Prop 3.3, Thm 3.7 and Thm 3.9 check out. Lemmas 1.2 and 1.3 also passed 20k randomized tests each.

All my check scripts are in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/:
- lem12_13.py
- graphic.py
- checks37.py
- thm31b.py
- conjsearch.py

---

### Referee B (Sections 4–6)

**Items checked.**
* Thm 4.1; Thm 4.2 (a),(b) incl. supermartingale, no-union-bound claim, deterministic-oracle single event; Prop 4.3; Thm 4.4; Cor 4.5; Cor 4.6; Sec 4 Discussion (countable hierarchy remark).
* Thm 5.1; Prop 5.2; Thm 5.3 (constants, table, necessity claim); Thm 5.4 (a),(b) and Remark; Cor 5.5; Sec 5 side-condition extension bound.
* Prop 6.1; Thm 6.2; Thm 6.3; Thm 6.4 and 'Consequences for schemas' (factor 3); Cor 6.5; Prop 6.6 (CPC claim and arithmetic remark).
* Re-ran T1-code: ville.py, ville2.py, toy_nd.py, noise.py.
* Novelty claims in Sec 8 that concern Secs 4-6.

**Issues.**

#### B-1. Thm 4.1 (VS posterior: deterministic soundness) — ok
* *Description.* Verified. w^VS_t(R*) = w*/w(VS_t) >= w*, and the guardian inequality w_t(q not in R) >= w_t(R*) proves the main part. The converse with two hypotheses is correct. Two implicit points: 'all labels truthful' must also cover the human positives (P0 is a subset of R*), and the guarantee holds per target, i.e. for targets with w(R*) >= delta.
* *Evidence.* Line-by-line check of the proof at lines 318-320.
* *Suggested fix.* Optionally say 'all data (human positives and oracle labels) truthful'.

#### B-2. Thm 4.2 (Ville; time-uniform soundness) — severity: minor
* *Description.* The mathematics is correct. Z_t is a nonnegative supermartingale (Tonelli; each factor has conditional mean sum_{o: l*(o)>0} l_R(o) <= 1, with Z_0 = 1), and Ville gives (a). For (b), deterministic answers multiply each term by an indicator <= 1, so Z_t <= Z^H_{n(t)} pathwise. The good event {sup_n Z^H_n < 1/delta'} depends only on the human data and holds against every prover, even one that knows the future human data. The 'no union bound' claim is correct. The defect is an unstated assumption that (a) needs: the prover must not be able to predict the oracle's noise, and the noise must be fresh, i.e. not persistent across repeated queries. Sec 1.2 says the prover knows everything except 'the verifier's future coins', which does not exclude foresight of oracle noise. Sec 4's 'given the past' is ambiguous about whose information the conditioning includes. With noise foresight, (a) fails completely.
* *Evidence.* Simulation in scratchpad/t1ref/prescient.py. H = all subsets of {0,1} with uniform prior, R* = {0}, symmetric flip noise eta, delta' = 0.05. The prover queries the invalid step 1 only in rounds where it knows the answer will be flipped to 'valid', and the valid step 0 otherwise. The ratio w({0,1})/w({0}) then only grows. P(invalid step accepted) = 1.0 for eta = 0.1 and 0.3, against the bound 0.05. With a non-prescient greedy adaptive prover (ville_noisy.py) the bound holds: 0.017-0.063 against 0.2-0.5.
* *Suggested fix.* State explicitly: conditional on F_t, which includes all of the prover's information, the next observation has law p_{R*} or l_{R*}(.|q_{t+1}). That is, the noise is fresh and hidden from the prover. Note that (b) needs no such assumption.

#### B-3. Thm 4.2 / Sec 8 novelty and citation — severity: minor
* *Description.* Part (a) is exactly the prior-posterior-ratio (PPR) martingale argument of Waudby-Smith & Ramdas (2020), which the project's own L2 cites; T1 does not cite it. Part (b), listed in Sec 8 as new, is an immediate corollary of the observation that truthful constraints multiply Z by at most 1, which L2 Thm 1 already uses for 'constraints generated by the prover itself'. Not misleading, but the novelty is slight.
* *Evidence.* L2-reliable-selective-kwik.md lines 171 and 258 ('This is the PPR martingale of Waudby-Smith & Ramdas') and lines 216-224 (Thm 1 covers prover-generated constraints).
* *Suggested fix.* Cite Waudby-Smith & Ramdas 2020 (PPR martingale) for (a). Describe (b) as an easy corollary rather than as a new result.

#### B-4. Prop 4.3 (constant 1 is tight) — ok
* *Description.* Verified: theta = (1-w*delta')/((1-w*)delta'), and (1-u)^{t*} lies in [(1-u)/theta, 1/theta) with 1/theta <= delta'. This tends to delta' as u, w* -> 0. The quoted exact values 0.989 delta' and 0.991 delta' are reproduced by ville2.py, and ville.py's Monte Carlo is consistent with the bound. Clarity note: the acceptance probability is attained by a prover that waits until the likelihood ratio exceeds theta before querying c. A prover that queries c earlier triggers an escalation, and the deterministic answer 'invalid' kills R'.
* *Evidence.* Re-ran T1-code/ville2.py: ratios 0.781, 0.625, 0.922, 0.880, 0.989, 0.970, 0.982, 0.991.
* *Suggested fix.* Add: 'the prover queries c exactly at round t*'.

#### B-5. Thm 4.4 (escalation bound) — ok
* *Description.* Verified. The multiplicative factors are F_u (data rounds, conditional mean <= 1), 1 - w(q not in R) <= 1 - delta for an escalated valid query, and w(q not in R) <= 1 - delta_r for an escalated invalid one. Z_t >= w* because w_t(R*) <= 1. Ville applies to M = product of F_u, and -ln(1-x) >= x finishes it. The VS case has F_u <= 1. Against dishonest provers the bound needs REJ with delta_r > 0; otherwise delta_m = 0 and the bound is vacuous. This is implicit in the definition of delta_m.
* *Evidence.* Line-by-line check of lines 348-352.
* *Suggested fix.* None needed. Optionally note that delta_r = 0 (no REJ) makes the dishonest-prover bound vacuous.

#### B-6. Cor 4.5 (unstructured classes) — ok
* *Description.* Lower bound verified: the chain U \ {u*} of length |U|-1 is elastic, and the proof of Thm 3.2's lower bound uses only unconditional probabilities, which is valid. The upper bound follows from Thm 4.4 (VS case). Two notes. (i) The exact ratio of the bounds is ln(1/w*)/(delta'(1-delta')(1-w*)), not ln(1/w*)/delta'. Also, the 1/delta' factor is an artifact of choosing V_{w*delta'}: the VS posterior with delta = w* is 0-sound and pays <= ln(1/w*)/w*. (ii) The dependency Thm 3.1(b), which is out of scope, is false if 'accepts with probability p at some history' is read as a conditional probability. Example: a randomized verifier that enters 'accept everything' mode with probability delta is delta-sound but has conditional acceptance 1. Only the joint-probability reading, which Thm 3.2's proof actually uses, is valid.
* *Evidence.* Algebra of the two bounds. Counterexample sketch for the conditional reading of Thm 3.1(b).
* *Suggested fix.* Say 'optimal up to a factor O(ln(1/w*)/delta')', or use delta = w* to drop the 1/delta'. In Thm 3.1(b), say 'with (unconditional) probability p'.

#### B-7. Cor 4.6 (structure + Bayes) — severity: minor
* *Description.* The bound min{el, ln(1/w*)/delta} and its proof are correct. An escalated valid q has positive posterior mass outside it, so q is not in the intersection of VS(P,N), which contains the intersection of VS(P). So the escalated valid queries form an elastic chain. The defect is terminology. Under Def 1.2, '0-sound' quantifies over every R* in H, but delta <= w* covers only targets with prior >= delta. For infinite countable H, no delta > 0 makes V_delta 0-sound in the Def 1.2 sense.
* *Evidence.* Def 1.2 (line 88) quantifies over all R* in H; inf_R w(R) = 0 for infinite H.
* *Suggested fix.* Replace 'is 0-sound' with 'never accepts an invalid step for any target with w(R*) >= delta'.

#### B-8. Thm 5.1 (eventual completeness iff finite anchor) — ok
* *Description.* Verified. The 'only if' direction ('P itself is an anchor') needs P finite. That holds for data-so-far P_t, but fails for infinite P: in Prop 5.2's class, the intersection of VS(2N) is 2N, yet there is no finite anchor. The text/i.i.d. bullet is correct; a.s. every element of a countable support appears.
* *Evidence.* Proof at lines 379-382.
* *Suggested fix.* Write 'for finite P'.

#### B-9. Prop 5.2 (anchors vs tell-tales) — severity: minor
* *Description.* 'Anchor implies tell-tale' and the general counterexample (2N vs R_n) are correct. The per-set converse for intersection-closed classes fails for T = empty set under the convention of Prop 3.3, where only H union {empty} is intersection-closed. Take H = {{1},{2}} and R* = {1}. Then the empty set is a tell-tale but not an anchor, because R ∩ R* = empty is not in H. Existence-level equivalence still holds, since any tell-tale plus one element of R* is a nonempty tell-tale. Separately, Sec 8 lists 'anchors vs. tell-tales for verification' as new. The anchor condition is exactly the Lange-Zeugmann characterization of strong-monotonic learning, as the text itself notes, so only the verification framing is new.
* *Evidence.* H = {{1},{2}}, R* = {1}: no member lies strictly inside {1}, so the empty set is a tell-tale; {2} contains the empty set but not {1}.
* *Suggested fix.* Require T nonempty (or the empty set in H). In Sec 8, credit Lange & Zeugmann for the anchor condition.

#### B-10. Thm 5.3 (tagged schemas, coupon-collector rate) — ok
* *Description.* Verified. The (R) failure probability is <= 2(1-rho)^n via the balanced split. The (D) failure probability is (1-r)^n. The union bound gives c_i = 2v_i + C(v_i,2). Then E(1-rho)^{N_i} = (1-pi_i rho)^N with N_i ~ Bin(N, pi_i), including N_i = 0. The sample-size corollary and the necessity example are correct. Table check: the roots of rand_formula are 4 atoms at 0.1375 and 4 connectives at 0.1125, so a 2+2 split gives exactly 1/2 and rho = 1/2. With c = 5, pi = 1/6 and 6 rules the bound is 1 - 30e^{-N/12}; the values .45, .99 and .999997 are correct. Notes: for ground rules the general formula gives c_i = 0, so the parenthetical e^{-N pi_i} is needed. Also, for (R) the balanced split costs up to a factor 2 in rate, since the sum over f of p_f^n is <= m^{n-1}.
* *Evidence.* Re-ran T1-code/toy_nd.py: .003, .407, .980, 1.000, 1.000, matching the table. Monte Carlo on skewed root laws (scratchpad/t1ref/coupon.py, rules f(x,x,y) and h(x)) never exceeded the bound.
* *Suggested fix.* None required. Optionally state the ground-rule case as a separate line rather than through c_i.

#### B-11. Thm 5.4 (untagged unions) — Remark after the proof — severity: minor
* *Description.* Parts (a) and (b) are correct. In (a), a generic first-cover class forces tau_l to generalize sigma_i. Pairwise-generic sets meet each failure set at most once. In (b), the growth function is <= M(n+1) and the VC dimension < 2k log2(4kM), checked numerically for k, v <= 8. The BEHW constants are right, and a sum >= max is fine. However, the Remark's necessity claim is false when k' >= 2: 'If some metavariable is only ever instantiated with <= k distinct root symbols, the data are explained equally well by k specialized rules, and identification fails forever.' Specializing one rule into k schemas leaves no schema for the other rules. Thus (a)'s condition is sufficient but not necessary. Sec 8's 'requires a bound k ... smaller than the instantiation variety' is overstated for the same reason. The claim is true for k' = 1.
* *Evidence.* scratchpad/t1ref/union_remark.py. Take k = k' = 2, R* = inst p(x) ∪ inst q(y), P = {p(a), p(b), q(a), q(b)}. Here x takes only 2 = k roots, so zeta_1 = 0. Brute force over all 2-class covers shows p(c), q(c) and p(p(a)) all lie in the intersection of VS_{H_2}(P), so identification succeeds. For k' = 1 with P = {p(a), p(b)}, p(c) is not in that intersection, as the Remark says.
* *Suggested fix.* Restrict the Remark to k' = 1, or phrase it as 'the sufficient condition (a) fails'. A sharper condition would allow only k - k' + 1 failure sets when no schema can cover two rules generically. Soften the wording in Sec 8.

#### B-12. Thm 5.4(b) epsilon-net boundary — ok
* *Description.* Applying the epsilon-net theorem with epsilon = zeta_i, an infimum that may be attained, technically needs the '>= epsilon' version of the theorem. The symmetrization proof gives that version with the same constants, or one can use epsilon = zeta_i/2. Negligible.
* *Evidence.* BEHW 1989 phrases the result for error > epsilon.
* *Suggested fix.* Optionally note that the '>= epsilon' version is used.

#### B-13. Cor 5.5 (exact identification gives OOD generalization) — ok
* *Description.* Trivial and correct: if the accepted set A equals R*, then Cl_A(B) = Cl_{R*}(B) for every B.
* *Evidence.* Immediate.
* *Suggested fix.* None.

#### B-14. Sec 5 extension: side conditions bound mu(lgg P0) - mu(sigma*) + |Phi| — ok
* *Description.* Verified. The class stays intersection-closed (inst(mgu) intersected with the union of predicate sets). The closure is (lgg P, predicates holding on P). Each strict step either strictly generalizes the lgg (mu drops by >= 1, bounded below by mu(lgg R*) >= mu(sigma*)) or shrinks the predicate set. The AC and higher-order pattern anti-unification citations (Alpuente et al. 2014; Baumgartner et al. 2017) are, to my knowledge, stated correctly: AC generalization is finitary, and higher-order pattern anti-unification is unitary.
* *Evidence.* Monotonicity of lgg and of the set of holding predicates in P.
* *Suggested fix.* None.

#### B-15. Prop 6.1 (one error collapses the lgg) — ok
* *Description.* Verified. The premise column mixes 'and' with a non-'and' root. The conclusion column is mixed by (R). The columns differ, so z != w. The computed claims reproduce.
* *Evidence.* Re-ran T1-code/noise.py: clean lgg s1(and(v0,v1),v0); with one error s1(v0,v1); 15% affirming the consequent gives s2(imp(v0,v1),v2,v3).
* *Suggested fix.* None.

#### B-16. Thm 6.2 (trimmed version space) — severity: minor
* *Description.* (a) is correct. (b) is correct for rules with v_i >= 1: (ii) forces > e_i valid samples, and after deleting <= e_i samples, (R) and (D) survive. (b) fails for ground rules (v_i = 0). There, (ii) is vacuous, and with <= e_i valid samples the empty hypothesis, or a different ground term, belongs to VS_{e_i}. Also, (b) uses per-tag budgets e_i, which is a different verifier from the globally defined VS_e. With a global budget e = sum e_j, a hypothesis could spend the whole budget on one tag.
* *Evidence.* Counterexample: tag i with sigma_i = c (ground), one valid sample (i,c), no invalid samples, e_i = 1. Hypotheses (i)-(ii) hold vacuously. The empty set and inst(d) are both in VS_1, so the intersection of VS_1 excludes c, which is not R*. noise.py reproduces the [computed] claims.
* *Suggested fix.* Add to (ii): 'and more than e_i valid rule-i samples' (automatic if v_i >= 1). Define VS_{(e_i)} = {R : |P^(i) \ R^(i)| <= e_i for all i} explicitly.

#### B-17. Thm 6.3 (i.i.d. noise) — severity: minor
* *Description.* The Hoeffding steps are verified: P[Bin(N,alpha) > floor((alpha+Delta)N)] <= e^{-2N Delta^2}. Each witness count has mean >= (alpha + 2Delta)N, the G/G^c split argument holds, and the count of 1 + c_i events is correct. The same ground-rule gap as in Thm 6.2 remains. For v_i = 0, rho_i is undefined and c_i = 0, and the needed event '#valid rule-i samples > e_i' is missing from the union bound.
* *Evidence.* With v_i = 0 the stated bound is 1 - e^{-2N Delta^2} per rule. It omits the failure probability of the valid count being <= e_i, which is about e^{-2N((beta_i - alpha_i)/2)^2} with rho_i := 1.
* *Suggested fix.* Set rho_i := 1 and c_i := 1 for ground rules (one count event), or exclude ground rules explicitly.

#### B-18. Thm 6.4 + 'Consequences for schemas' (factor 3) — severity: minor
* *Description.* Thm 6.4 is correct: D is an admissible noisy law for R* and a clean law for R'. In the consequences, rho_x <= 1 - max_f F_x(f) <= 3 rho_x is true, but the tight constant is 2. Greedy proof: if m < 1/2, add atoms until the mass reaches (1-m)/2; the final mass is then < (1+m)/2. So 'optimal up to a factor of 3' (here and in the Sec 0 summary) can be sharpened to 2. Also, 'witness frequency Pr[root(Theta x) != f] > alpha' needs the factor beta_i (or pi_i), because alpha is a fraction of all data while Pr is under Lambda_i.
* *Evidence.* scratchpad/t1ref/rho.py: (1-m)/rho = 2.0 for the uniform law on n = 3..13 atoms. The maximum over 20,000 random laws is 1.974, and none exceeds 2.
* *Suggested fix.* Replace 3 by 2 and write the necessary condition as beta_i * Pr_{Lambda_i}[root(Theta x) != f] > alpha.

#### B-19. Cor 6.5 (systematic errors are rules) — ok
* *Description.* Correct and trivial. The data law is supported on R* ∪ inst(tau), which lies in H by closure under adding a schema. Combined with Thm 6.4, no positive-data verifier can both tolerate such errors and learn a genuine rule with the same law.
* *Evidence.* Immediate.
* *Suggested fix.* None.

#### B-20. Prop 6.6 (in CPC, coherence refutes every systematic error) - scope — severity: major
* *Description.* The formal statement, for a substitution-closed A containing R*_CPC, is correct by Prop 2.3 and Lemma 1.1. The gloss is false: 'a coherence test in the empty (or actual) context ... catches every unsound learned schema', and the Sec 0 summary says 'detects every unsound schema'. Under the encoding of Sec 1.3, propositional atoms are constants of Sigma. A learned schema containing an atom constant is therefore not closed under uniform substitution, so Prop 2.3's parenthetical, 'closed under uniform substitution, as the instance set of any family of schemas is', is false. The lgg learner produces such schemas whenever a column of the data is constant at an atom. T2 itself flags the non-structural counterexample (C_2 plus the axiom p17).
* *Evidence.* Counterexample: tau = s1(or(x,p1), x), i.e. from x ∨ p1 infer x, which is unsound since p0 ∨ p1 does not entail p0. Let A = R*_CPC ∪ inst(tau). Invariant: every formula in Cl_A(∅) is true under every valuation v with v(p1) = 0. CPC steps preserve truth, and if x ∨ p1 is true while p1 is false then x is true. Hence ⊥ ∉ Cl_A(∅), although A is unsound. A simpler case is a single ground error step p0 ⊢ p1: it never fires from ∅.
* *Suggested fix.* Restrict the claim to atom-free (pure) schemas. Alternatively, have the learner close every learned schema under substitution, replacing atom constants by metavariables, before the coherence test, and note that this also over-generalizes correct atom-specific rules. Delete or correct the parenthetical in Prop 2.3.

#### B-21. Prop 6.6 - arithmetic remark — severity: minor
* *Description.* The remark says: 'Unsound but consistent additions exist (e.g. ¬Con(PA)), so coherence must be supplemented by world feedback (computation refuting false Π1 claims)'. The proposed supplement does not address the stated problem. False Π1 claims are already refuted by coherence over PA through Σ1-completeness (T2 Thm 3.10(a), Lemma 3.7). The cited example ¬Con(PA) is a false Σ1 sentence, which no finite computation refutes. The remark contradicts T2's own conclusion that computation adds nothing beyond coherence with a Σ1-complete base.
* *Evidence.* ¬Con(PA) has the form ∃p Proof_PA(p, ⊥), which is Σ1. If π is a false Π1 sentence, then ¬π is a true Σ1 sentence, so PA ⊢ ¬π and PA + π ⊢ ⊥. See T2-coherence-as-negative-data.md lines 363-365 and 385-401.
* *Suggested fix.* Rewrite: coherence over PA already catches false Π1 additions. False Σ1 additions such as ¬Con(PA) are caught neither by coherence nor by computation. They require accepting stronger principles (reflection, Con(PA)), per T2 Thm 3.10.

**Overall (Referee B).** Sections 4-6 are mostly correct. No statement in scope is false as formally stated (no fatal issues). Verified: the Ville/PPR supermartingale and the deterministic-oracle uniform event (Z_t <= Z^H pathwise, so no union bound is needed); the tightness example (ville2.py reproduces 0.989 and 0.991); the escalation bound; Cor 4.5's lower bound; the anchor theorem; the coupon-collector bound with its constants and table (rho = 1/2 exactly, c = 5, toy_nd.py reproduces the rates); the untagged epsilon-net argument, including a numerical check of the VC-dimension bound; trimming; and indistinguishability. One major issue: Prop 6.6's coverage claim. The summary says coherence in CPC 'detects every unsound schema', but this fails for learned schemas that contain atom constants, which are not substitution-closed in T1's own encoding. Counterexample: s1(or(x,p1),x) added to a complete CPC calculus never yields ⊥ in the empty context. Minor issues: (1) Thm 4.2(a) needs the explicit assumption that oracle noise is fresh and unpredictable to the prover; a prover who foresees the noise breaks the bound with probability 1 in simulation. (2) Thm 6.2(b) and Thm 6.3 fail for ground rules (v_i = 0). (3) The Remark after Thm 5.4, that 'identification fails forever' with <= k roots, is false for k' >= 2 (brute-force counterexample with k = k' = 2). (4) 'Factor 3' should be 2. (5) Prop 5.2's converse fails for the empty tell-tale. (6) The arithmetic remark in Prop 6.6 is mathematically misdirected: computation refutes false Π1 sentences, which coherence over PA already catches, while ¬Con(PA) is a false Σ1 sentence. (7) Cor 4.6 misuses the term '0-sound'. (8) Novelty: Thm 4.2(a) is the Waudby-Smith & Ramdas PPR martingale, which T1 does not cite; 4.2(b) is an easy corollary; and anchors are Lange-Zeugmann's strong-monotonic tell-tales. Scratch scripts are in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/t1ref/ (rho.py, union_remark.py, coupon.py, ville_noisy.py, prescient.py).

---

## Part 2. Author-repairer's verification log

In the table below, issue numbers follow the theory file's log; the Part 1 headings (A-*, B-*) map as follows:
* A1–A9 = A-1…A-9.
* B2, B3, B7, B9 = B-2, B-3, B-7, B-9.
* B11 = B-11.
* B14, B15, B16 = B-16, B-17, B-18.
* B18 (merged with A2) = B-20.
* B19 = B-21.

The text below is identical to the `## Verification log` section appended to `../theory/T1-soundness-under-search.md`.

Two independent adversarial referees checked this file: referee A covered §1–§3, referee B covered §4–§6 and the related novelty claims in §8. The full reports are in `../verification/T1-soundness-under-search-verification.md`. I re-checked every issue by hand. Where computation helped, I re-ran the referee scripts (`graphic.py`, `checks37.py`, `union_remark.py`, `prescient.py`, `rho.py`, `thm31b.py`); all reproduced. Scripts that back claims now made in this file were copied into `T1-code/` and added to `run_all.sh`. Theorem numbering is unchanged, and materially changed items are marked "(revised after verification)".

**Major issues (all genuine, all fixed).**

| # | item | verdict | action |
|---|---|---|---|
| A1 | Thm 3.1(b) | Genuine. Read as a conditional probability at a history, (b) is false for randomized verifiers. An $\varepsilon$-sound "reckless with probability $\varepsilon$" verifier reaches $h=(c,\mathrm{ACC})$ with probability $\varepsilon$ and then accepts $b\notin\bigcap\mathrm{VS}$ with conditional probability 1 (re-run: $\Pr[h]=0.0098$, $\Pr[\mathrm{ACC}\,b\mid h]=1.000$). | **Restated** with $p$ the *joint* probability of "history $h$, then $q$ accepted". Added the deterministic special case and the counterexample. Proof made explicit. The random-data remark now reads $\Pr_{R'}(\text{data})\cdot p\le\delta$. |
| A2 / B18 | Prop 2.3 gloss; Summary; Prop 6.6 coverage claim | Genuine, one root cause. Atoms are constants of $\Sigma$ (§1.3), so learned schemas can mention atoms, and their instance sets are not substitution-closed. Two counterexamples were checked by hand. $(\{x\vee p_0\},x)$ is unsound but only adds $\neg p_0$, since $\mathrm{Cn}(\neg p_0)$ is closed. $\mathsf{s1}(\mathsf{or}(x,p_1),x)$ never yields $\bot$. | Hypothesis restated as $A=R^*_{\rm CPC}\cup A_1$ with $A_1$ substitution-closed, e.g. instance sets of **pure** schemas. Added a scope remark with the counterexamples. Added **purification** (atoms → fresh metavariables) and proved that in CPC $\tau$ is sound iff $\tau^\circ$ is. So coherence on $A^\circ$ decides soundness of $A$. Prop 6.6, its gloss and the Summary were restricted accordingly. *Note for T2:* T2 Thm 3.1 is stated for structural closure operators and is unaffected, but any T2 gloss about *learned* schemas should be checked for atom constants. That is outside T1's scope. |

**Minor issues.**

| # | item | verdict | action |
|---|---|---|---|
| A3 | Cor 2.2 "every output trivializes" | Genuine: fails if $\mathcal L$'s output lacks $\top$I, $\wedge$I, $\vee$I$_2$ (e.g. $\mathcal L\equiv\emptyset$). | $\mathcal L^+$ now also adds $\mathrm{inst}(\top\text{I},\wedge\text{I},\vee\text{I}_2)\subseteq R^*$. These cannot increase the error. Summary now says "same rates up to $O(\varepsilon^{-1}\log\delta^{-1})$ extra samples". |
| A4 | Thm 3.2 lower-bound citation | Genuine: it cited the false conditional form of 3.1(b). | Replaced by a direct coupling argument for a non-adaptive honest prover. Def 1.3 now defines randomized cost as expected cost. |
| A5 | Conj 3.8 evidence | Genuine. The $h\le5$ hill-climb ran on 14 points, so "14 vs 15" is a ceiling artifact. The "[computed]" one-step-decomposition claim has no script (only a 2-line stub survives in scratch). | Evidence corrected. Added that $M(K_{h+1})$ flats attain $\binom{h+1}2$ at $k=2$ for $h=2..5$ (re-run `graphic.py`: 3,6,10,15). Added a full proof of the case $(k,h)=(2,3)$: I checked the referee's sketch step by step and wrote it out. Withdrew the decomposition claim. §7 table, §8 weakness 4 and the Summary updated. |
| A6 | Thm 3.4 displays and "chain = generalization chain" | Genuine (presentational). | Target-dependent quantity written as $\mathrm{el}(H_1,\sigma^*\mid\emptyset;N)$, with $\mathrm{Esc}(H_1;N)\le N+1$ ($=N+1$ with two constants and a unary symbol). Proof now uses the representatives $g_i=\mathrm{lgg}(C_i)$, with inclusion giving strict generality. |
| A7 | Prop 3.5 "super-exponential" | Genuine: it needs a signature that grows with $N$. Over a fixed finite signature the two-sided cost is $\le$ the number of steps, $2^{O(N)}$. | Title, statement and the Bell comparison qualified. The fixed-signature upper bound was added. Re-ran `checks37.py`: Bell$(2..4)=2,5,15$ forced escalations. |
| A8 | Thm 3.6 "intersection-closed" | Genuine: $H^{\rm tag}_k$ is not literally intersection-closed. Conclusion correct. | Justification replaced by the factorization $\mathrm{VS}=\prod_i\mathrm{VS}_i$. The bound is split by whether $P_0^{(i)}=\emptyset$. |
| A9 | Thm 3.7(iii) / Summary "$\Theta(n^k)$ for flat schemas" | Genuine: $\Theta(n^k)$ is proved only for linear flat schemas; $n\ge k$ is needed. | Summary and (iii) qualified: linear $\Theta(n^k)$; repeated metavariables between $\Omega(n^k)$ and $O(n^{2k})$; $n\ge k$ added. |
| B2 | Thm 4.2(a) unstated hypothesis | Genuine. A prover that foresees fresh oracle noise defeats (a) with probability 1 (re-run `prescient.py`: 1.0 at $\eta=0.1,0.3$). | Hypothesis stated explicitly, in §4's setup and in (a): $\mathcal F_t$ includes all of the prover's information, and the noise is fresh and unforeseeable. Noted that (b) needs no such assumption, and included the counterexample. |
| B3 | Thm 4.2 novelty/citation | Genuine: (a) is the PPR martingale of Waudby-Smith & Ramdas (2020), and (b) is an easy corollary. | Credit paragraph and reference added. §8 "new" list corrected. |
| B7 | Cor 4.6 "0-sound" | Genuine: the guarantee only covers targets with $w(R^*)\ge\delta$. | Reworded. Proof made explicit about $P$ and $N$. |
| B9 | Prop 5.2 converse for $T=\emptyset$ | Genuine: $H=\{\{1\},\{2\}\}$, $R^*=\{1\}$. | Converse restricted to nonempty tell-tales. Counterexample and the existence-level equivalence added. Anchors credited to Lange–Zeugmann in §5 and §8, and the reference was added. |
| B11 | Remark after Thm 5.4 "identification fails forever" | Genuine for $k'\ge2$. Hand proof for $k=k'=2$, $P=\{p(a),p(b),q(a),q(b)\}$: every covering 2-union contains $p(x)\cup q(y)$. Re-ran `union_remark.py`. | Remark rewritten. A proved sufficient condition for failure ($k-k'+1$ failure sets plus an uncovered instance) recovers the original for $k'=1$. The $k'\ge2$ counterexample was added. The intermediate cases are open. §8 softened. |
| B14 | Thm 6.2(b): ground rules; per-tag vs global budget | Genuine: a ground rule with $\le e_i$ valid samples fails, and (b) needs per-tag budgets. | $\mathrm{VS}_{(e_i)}$ is defined explicitly, and (ii) now requires $>e_i$ valid samples. A remark explains why a global budget fails. |
| B15 | Thm 6.3 ground rules | Genuine: the missing event "valid count $>e_i$". | For $v_i=0$: $\rho_i:=1$, $c_i:=1$. The verifier is specified as per-tag. |
| B16 | Thm 6.4 consequences: factor 3, missing $\beta_i$ | Genuine: the tight constant is 2 (greedy split; uniform law on an odd number of roots gives exactly 2; re-ran `rho.py`: max 1.974 over 20k random laws). $\beta_i$ factor missing. | Factor 2 proved, with tightness. $\beta_i$ inserted. Summary and §8 updated. |
| B19 | Prop 6.6 arithmetic remark | Genuine. False $\Pi_1$ additions are already caught by coherence over PA (Σ₁-completeness), and $\neg\mathrm{Con}(\mathrm{PA})$ is a false Σ₁ sentence that computation cannot refute. | Rewritten per T2 Thm 3.10(a),(c),(e) and Lemma 3.7. |

**Items reported "ok", with optional nits.**
* *Nits applied:*
  * Lemma 1.1 ("non-derivable" in place of "false").
  * Thm 2.1 ("for non-tautologous $C$"; finitely many schemas only if $R^*$ is).
  * Thm 4.1 ("all data truthful"; per-target guarantee).
  * Prop 4.3 (the prover queries $c$ exactly at $t^*$).
  * Thm 4.4 ($\delta_r=0$ makes the dishonest-prover bound vacuous).
  * Cor 4.5 (exact ratio; with $\delta=w^*$ the VS posterior *is* the VS verifier, which is exactly optimal).
  * Thm 5.1 ("for finite $P$").
  * Thm 5.3 (ground-rule case spelled out in the proof).
  * Thm 5.4(b) (the "$\ge\varepsilon$" form of the ε-net theorem).
* *Also corrected by the author during this pass, not flagged by the referees:* the Upshot bullet "losing rule citations costs a polynomial of degree $k$" now says *at least* degree $k$, with $\Theta_k(N^k)$ only conjectured. Thm 3.7(ii)'s proved upper bound is exponential.
* *No change needed:* Thm 3.1(a), Prop 2.4, Prop 3.3, Lemmas 1.2–1.3, Thm 3.7 main statements, Thm 3.9, Cor 5.5, side-condition extension, Prop 6.1, Cor 6.5.
