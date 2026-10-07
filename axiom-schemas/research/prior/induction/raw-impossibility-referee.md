# Referee report on Track B: raw induction instances and first-order patterns

Under review: `raw-impossibility-notes.md` and the JSON summary (propositions B1–B8 and the "lgg, audit, escalate" algorithm).

**Method.**
- I re-ran the author's scripts. `b1_pairs`, `b2_family`, `b3_refutation`, `b4_equational` and `b1b_bruteforce 5 2000` reproduce their `.out` files exactly.
- I wrote independent code that does not import `terms.py`, `raw_common.py` or `raw_search.py`:
  - `rb_core.py`: my own anti-unification and matching, plus an exact evaluator for truth in N. The evaluator finds the natural roots of each atom's polynomial with sympy's `ground_roots`, not with a Cauchy bound.
  - `rb_cc.py`: ground congruence closure modulo the true closed equations of N. It decides whether a finite set of ground literals holds in some algebra that contains N as a subalgebra.
  - Check scripts `rb1_checks.py`, `rb2_algorithm.py`, `rb3_refutability.py`, `rb3b_refl.py`, `rb4_indeq.py`, `rb5_sizes.py`, each with an `.out` file.

Track B makes no claims about Lean or Metamath, so there was nothing to check there. (`lean/NatRec.lean` belongs to another track.)

## Verdicts

| Proposition | Verdict | One-line reason |
|---|---|---|
| B1 two instances suffice, one never does | holds | independent recomputation; minimum sizes 6 and 8 confirmed by hand and by code |
| B2 pairwise-unsound family; no finite sound union | holds | proof checked line by line; lgg = L_n for all n<m<=14 and 300 random subsets; I*_M ∈ inst(L_a) |
| B3 collapse to L_inf | holds | 2423 random root-diverse pairs, motives with quantifiers included |
| B4 cautious verifier unsound; empty sound VS; certificate | holds | own partition brute force for F' **and** F |
| B5 world refutation, singleton blame, TTL ends with no induction | holds-with-fix | (a)–(c) are correct for data containing F' members or root-diverse data. But "each over-general schema is refuted unblocked" (§0.3, §2 step 2, JSON algorithm) is **false**: see Theorem R1 |
| B6 IndEq is a sound one-metavariable pattern; PA = Q + inst(IndEq) | holds | 30000 checks of (motive, random finite structure) with 0 disagreements; lgg recovery confirmed |
| B7 relation to Ryll-Nardzewski | holds-with-fix | content right; three imprecisions (below) |
| B8 noise persistence | holds | also holds for TTL's actual estimator, the mgu of trimmed lggs (computed) |
| Algorithm "lgg, audit, escalate" | **claim false as stated** | the refutation in step 2 need not use the two named instances, and need not exist at all; escalation is never triggered on F-type data |

---------------------------------------------------------------------------------------------------------

## 1. Checks proposition by proposition

### B1 (holds)
- **(b)** My own lgg gives `((0+0)=0 & Ax((v0+v1)=x -> (v2+v3)=Sx)) -> Ax (v0+v1)=x` with 4 metavariables. I*_1 is an instance. My evaluator finds I*_1 false and both data true. lgg(4 instances) is strictly more general than lgg(2).
- **(d)** {Ind(x=x), Ind(Sx=Sx)} has the lgg `(v0=v0 & Ax(v1=v1 -> Sv1=Sv1)) -> Ax v1=v1`, and no false instance was found. The hand proof is correct: every sentence instance has the true conclusion Ax(u=u).
- **(e)** Minimum sizes.
  - Lower bound 6: every formula has size at least 3.
  - Lower bound 8 for two motives true for all x: the only true motives of size 3 are 0=0 and x=x, and their pair is sound. No formula of size 4 is true for all x; I listed them all: eq with sides of sizes 1+2, or ¬ of a size-3 atom, and quantified formulas have size at least 5.
  - Both minima are attained.
  - My independent enumeration (`rb2_algorithm.out`) gives 2357 unsound pairs out of 2465 pairs with x free in at least one motive, with a different instance pool and a different evaluator. This matches 1589 + 768 = 2357 in `b1b_bruteforce.out`.

### B2 (holds)
- **B2.1 proof.** Each step is right: g_m(t) = g_n(g_d(t)), and the descent through n additions stops at the columns (0, g_d 0), (x, g_d x) and (Sx, g_d Sx). These have mixed roots and pairwise distinct first entries.
- **B2.1 recomputation.** My lgg equals L_n for 0<=n<m<=14. It equals L_min for 300 random subsets of {0..20} of size 2 to 6.
- **B2.2.** I*_M ∈ inst(L_a) for all a<=M<=14. As a hand check: g_a(g_{M-a}(t)) = g_M(t) syntactically.
- **Falsity of I*_M.** Checked exactly.
- **Q-refutation.** It needs only the closed facts g_M(0)=0 and g_M(S0)=S(g_M 0), which are Q-provable by Σ1-completeness, plus ¬(g_M 0 = S0).
- **Theorem (a)–(c).** Plotkin's property and pigeonhole; correct.
- **200 random covering schemas.** I anti-unified two F' members with a random extra datum; every result has I*_n as an instance.
- **(d), family F.** lgg = K_n for 0<=n<m<=9, and J*_M ∈ inst(K_a) for all a<=M. Also inst(K_n) ⊆ inst(K_0); this is used in Theorem R1.
- **Guard remark.** The padding instance (a:=0, b:=0*x, c:=S0+0*x) is false; checked by hand for n=0. The caveat that a fixed guard family Φ may contain "is an induction instance" is correct and necessary, since def:setting:schema lets Φ be any fixed finite family of decidable predicates.

### B3 (holds)
- **(a)** Correct. Substituting into x never changes the root of a formula, and when x is free the three columns are pairwise distinct. My check covered 2423 random root-diverse pairs, including motives with ∀y/∃y and inner binders; all have lgg = L_inf.
- **(b)** The union bound is correct.
- **Minor.** The sentence "on E2 without E1 the lgg is Z & Ax(Z->Z) -> Ax Z" is right. The earlier wording "in the second case [E2]" in the JSON drops the "without E1".

### B4 (holds)
- **(b)** The proof is correct.
  - Every h ∈ VS_{H_k}(D) contains a union of block lggs over some partition of D into at most k blocks, so brute force over partitions is a valid check.
  - My own brute force agrees for F' and also for family F with J*_N (N+1 <= 6, all k <= N).
- **(c)** Correct under (WS): a refutation implies a false instance, and every covering schema is at least as general as lgg(D).

### B5 (holds-with-fix)
- **What is correct.**
  - (a) and (b) are valid derivations in the paper's sense. Forward and backward propagation are as in lem:twotier:descent, and the descent path 11 → 10 → 1 is unblocked.
  - I recounted the sizes (`rb5_sizes.out`): 82 (n=0, **9** judgments), 139, 183, 227, 271, 315 (11 judgments), and L_inf 78 (8 judgments). The JSON's "11 judgments and size 82 for a=0" has the wrong judgment count; it is 9.
  - (c) is correct under its hypothesis that D_Ind contains an F' member or is root-diverse.
  - (d) is correct as far as it goes; the checked derivation using Q3 is valid.
- **What is false.** Notes §0 item 3 says "each over-general schema is refuted by an 8- to 11-judgment ... refutation. Its descent is unblocked". Notes §2 step 2 says "one of two refutations is always available". The JSON algorithm says "an unblocked one always exists, through one of two instances".
- **The fix.** State (c) only under its hypothesis, and replace the hedge in (d) ("I do not claim that F has no singleton refutation") with Theorem R1: F has **no** refutation at all from W and logic.

### B6 (holds)
- **(a)** The proof is correct: Ax(x=t -> φ) ↔ φ[t/x] for x ∉ FV(t), with t = 0, y, Sy.
  - Independent test: 30000 pairs of a random motive and a random **finite** structure. The structures have arbitrary 0, S, +, * on 1 to 4 elements, so the test probes FOL-validity, not truth in N. 1286 of the motives contain y, many of them bound by ∀y/∃y, so they meet the IndEq binder y. Ind is false in 2065 of the pairs, and Ind and IndEq disagree in none.
  - The universal-closure counterexample x=0 ∨ ¬x=y is right; I checked it by hand at y=1.
- **(b)** Over 2000 random IndEq data sets, the lgg is always an instance of IndEq(P), and it equals IndEq(P) exactly when the motive roots differ (1861 root-diverse sets).
- **(c)** The parameter-elimination trick is correct and standard.

### B7 (holds-with-fix)
The citations check out.
- Ryll-Nardzewski, Fund. Math. 39 (1952), 239–263.
- Vaught, JSL 32(4) (1967), 473–479. He showed that every r.e. theory that directly interprets VS is axiomatizable by a schema.
- Tarski, Arch. math. Logik 7, 61–79. Springer gives the issue date as March 1964.
- Kaye–Paris–Dimitracopoulos, JSL 53 (1988), 1082–1097.
- Baumgartner–Kutsia–Levy–Villaret, JAR 58(2) (2017), 293–310.
- The finite axiomatizability of ACA_0 is standard; I did not verify the exact lemma number in Simpson.

Three fixes are needed.
1. The JSON says "PA is reflexive, so no consistent extension of PA is finitely axiomatizable". This needs "in the language of PA". As written it contradicts the ACA_0 example given two lines later: ACA_0 is a finitely axiomatizable conservative extension of PA in a richer language. The notes have it right.
2. "Vaught schemas ... strictly stronger than first-order patterns" is not precise.
   - Neither class obviously contains the other. Pattern metavariables can range over terms and are substituted with capture, as in IndEq. Vaught schemas use a relation symbol R(t⃗) and capture-free substitution.
   - What is true and proved: the raw induction set is the instance set of a single Vaught schema, but it is not covered soundly by any finite union of first-order patterns (B2).
3. (ii) "B2 holds equally where the theory proving all of Ind is finitely axiomatizable" is true but empty: B2 involves no theory at all. Say directly that B2 uses only Plotkin's property and Q-refutability.

### B8 (holds)
Lgg is monotone, so the result follows from B2.1.
- **Extra check.** TTL's actual estimator is the mgu of the e-trimmed lggs, whose instance set is their intersection. I*_M lies in every e-trimmed lgg when the clean data have e+2 members of F' (e<=2, with up to e noise items), so it lies in that intersection; computed in `rb1_checks.out`.

---------------------------------------------------------------------------------------------------------

## 2. New result: some over-general raw-induction lggs have no refutation at all

Let Th_qf(N) be the set of true closed quantifier-free sentences of {0,S,+,*,=}. Let

    K_0 = (z1+0 = z1) & Ax(z1+x = z2 -> z1+Sx = S z2) -> Ax(z1+x = z2).

K_0 is lgg(Ind(0+x=x), Ind(S0+x=Sx)), a pair of genuine induction instances that both need induction (B2(d); my code agrees). Every K_n has inst(K_n) ⊆ inst(K_0).

**Theorem R1 (proved).** Th_qf(N) ∪ {sentence instances of K_0} is consistent. Hence:
- **(i)** With W = truth of closed quantifier-free sentences and trusted steps that are sound first-order rules, {K_n} has **no refutation at any depth** relative to the empty position, singleton or otherwise. The same holds for Δ0 sentences with a primitive `<`: interpret a < b as "a, b standard and a < b". Then bounded quantifiers with standard bounds range over standard elements, so Δ0 truth is preserved.
- **(ii)** Suppose the practice is Q ∪ {induction tag} and Q is not designated (the notes' B5 setting), and the data are drawn from F.
  - Every refutation of B = \hat P is blocked. An unblocked descent outputs a V-false step. That step cannot be a Q instance (Q is true), and by lem:twotier:descent(d) it cannot be a K_0 instance either, because then {K_0} would be a d-conflict, contradicting (i).
  - So the audit takes the fallback and removes the union of all minimal conflicts. {K_0, Q3} is a conflict (the author's checked derivation of size 163), and it is minimal by (i). So once d >= 163 **Q3 = AxAy(x+Sy = S(x+y)) is removed as collateral**.
- **(iii)** If no Q axiom is in the practice, K_0 is residual and the assertion tier accepts the false J*_0 = (0+0=0) & Ax(0+x=0 -> 0+Sx=S0) -> Ax(0+x=0) forever.

**Proof.**
1. **Shape of the instances.** In a sentence instance, z1 := t is closed, because it occurs outside the binder, and z2 := u has FV(u) ⊆ {x}. Let k be the value of t, and let û(g) be u with x replaced by a fresh constant g and each closed subterm replaced by its numeral.

2. **Case T: û(x) is literally k̄+x.** Then t+a = u(a) holds for every a in every algebra M ⊇ N, by congruence from closed facts. So the conclusion, and with it the instance, holds in every such M.

3. **Case W: otherwise.** Let s = k̄+g and r = û(g); then s ≠ r. Work in the term algebra over numerals and g, with R_N the ground rules f(n̄,m̄) → value.
   - **Orientation.** Take ρ := r → s if s is a proper subterm of r, and ρ := s → r otherwise.
   - **Termination.**
     - r a numeral: use the lexicographic measure (#g, number of closed non-numeral positions).
     - ρ = s → r with |r| >= |s|: use (closed non-numeral positions, occurrences of s). No ρ-step creates a new occurrence of s, because a new occurrence straddling the hole would force r = g or r closed.
     - All other cases: use (closed non-numeral positions, size).
   - **Confluence.** There are no critical pairs. R_N's left sides are closed and have only numerals as proper subterms. ρ's left side contains g, is R_N-normal, and has no proper subterm equal to itself. So R_N ∪ {ρ} is convergent by the critical pair lemma and Newman's lemma.
   - **The model M_{t,u}.** Take the quotient by R-convertibility. Distinct numerals are distinct normal forms, so N is a subalgebra, and M_{t,u} satisfies s = r.
   - **The step fails at g.**
     - If ρ = s → r, the normal form of t+Sg is the term k̄+Sg itself, with root +. The normal form of S u(g) is S r or a numeral, with root S or a numeral.
     - If ρ = r → s, the normal form of S u(g) is S s or s. The term k̄+Sg is normal and differs from both.
   - So t+g = u(g) and t+Sg ≠ S u(g) in M_{t,u}. The step clause fails, and the instance holds there, witnessed existentially.

4. **Amalgamation.** Rename the M_{t,u} apart over N and take the free completion of their union. An operation is computed inside M_i when all its arguments lie in one M_i; this is well defined on N, which is a subalgebra of each. Otherwise the operation yields a new formal element. Each M_i is then a subalgebra of the completion M.
   - Closed terms evaluate in N, so Th_qf(N) holds in M.
   - Each Case-W instance keeps its quantifier-free witness, so it holds in M.
   - Each Case-T instance holds in every algebra containing N.
   - So M is a model of Th_qf(N) together with all sentence instances of K_0.

5. **No refutation.** By soundness of first-order logic, a refutation would make a W-false closed sentence true in M, but closed quantifier-free sentences have the same truth value in M as in N. ∎

**Computed support.**
- `rb3_refutability.out`: for k = 0..3 and all 556 terms u(x) of size at most 6, giving 2224 instances, the congruence-closure procedure finds {k̄+g = û(g), k̄+Sg ≠ S û(g)} satisfiable over N in every case except the 12 Case-T instances.
- J*_0 concretely: in the algebra given by the single rule 0+g → 0, we have 0+g = 0 but 0+Sg ≠ S0.

**How common is this?** I classified all 2357 unsound lggs of pairs of quantifier-free motives of size at most 5 (`rb2_algorithm.out`, `rb3b_refl.out`):
- 1835 have I*_a or the L_inf instance as an instance. These are the two instances named in the algorithm.
- 388 have neither, but have a "closed-collapse" instance with an unblocked 7–8 judgment refutation. Example: lgg(Ind(x*0=0), Ind(0*x=0)) = (0*0=0) & Ax(v0*v1=0 -> v2*v3=0) -> Ax(v0*v1=0), refuted through (0*0=0) & Ax(S0*S0=0 -> 0*0=0) -> Ax(S0*S0=0).
- 108 have neither, but a certified unblocked refutation, either by reflexivity after unifying the two sides of the C-slot or by congruence closure.
- 26 have no refutation found by either test. Some are artefacts of the pool or the literal test, e.g. the pairs with double negation. Others resemble K_0, e.g. {(0+x)=x, (x+x)=x}.

So the JSON claim "an unblocked refutation always exists, through one of two instances" fails in two ways. The instance can be of a third kind (at least 496 of 2357 cases), and for family F there is provably no refutation at all.

---------------------------------------------------------------------------------------------------------

## 3. The algorithm

- **Step 2 is false as stated.** See §2.
- **Step 4 is triggered only by an unblocked refutation.** On F-type data no refutation exists relative to the empty position (R1). So escalation never fires, and TTL either keeps K_0, accepting the false J*_0, or falls back and loses Q3 as collateral.
- **Repairs.**
  - (a) Trigger escalation syntactically. All data of the tag match the second-order pattern P(0) & Ax(P(x) -> P(Sx)) -> Ax P(x), and this check is decidable and trivial: read P off the conclusion and check the other two slots up to α-renaming of the bound variable. Then rewrite to IndEq **before** the audit. The rewritten tag is realizable (B6), so the audit has nothing to remove.
  - (b) Alternatively, designate the position asserting the ground axioms Q. Then the K_0 refutation becomes unblocked, as the author's B5(d) run shows. Whether every unsound raw-induction lgg has a Q-relative refutation is open: it needs a false instance whose step clause is Q-provable. I make no claim either way.
- **The rest of the algorithm is fine.** The B4(c) certificate and its noise-robust version are correct. Rewriting to IndEq and running plain lgg is sound at all times, and becomes exact once two root-diverse motives have appeared (P[not exact after N] <= p_max^(N-1)).
- **Another case where step 4 never fires.** If the data stay root-homogeneous with a sound lgg, e.g. {Ind(0=x), Ind(S0=x)} with lgg Ind(t=x), there is no refutation and no escalation. That is sound but never generalizes. Repair (a) removes this too.

## 4. Minor points
- The JSON says the I*_a refutation has 11 judgments "for a=0". It has 9; the size 82 is right.
- B1(c) "any pair whose motives have different main symbols with x free in at least one": correct, and it is B3(a).
- The citations marked "unsure" are fine as hedged. Huet's 1976 thesis is commonly cited for first-order anti-unification. Mostowski 1952 for reflexivity is standard but not verified here.

## 5. Files (this directory)
`rb_core.py`, `rb_cc.py` (libraries); `rb1_checks.py/.out` (B1–B4, B8); `rb2_algorithm.py/.out` (classification of unsound pairs against the algorithm's claim); `rb3_refutability.py/.out` and `rb3b_refl.py/.out` (refutability tests; the K_0 congruence-closure check); `rb4_indeq.py/.out` (B6 on random finite structures); `rb5_sizes.py/.out` (refutation sizes). Re-run: `python3 <script>` in this directory; everything takes about 40 s in total.
