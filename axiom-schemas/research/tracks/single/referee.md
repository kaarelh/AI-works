# Referee report: track "single" (one DT° template)

Referee: adversarial referee (Claude). Object of review: `notes.md` in this directory (716 lines), the
author's summary JSON, and the computational evidence `e1`–`e9`. Labels below: **holds**, **holds with
fix** (correct after a stated small repair), **false**, **unclear**.

All independent checks use the referee's own code in `referee_checks/` (it does not import or copy
the author's `dt*.py` files). The code consists of `rc_core.py` (de Bruijn terms, plugging,
deterministic matching, freezing/generality, first-order index matching, my own implementation of
C(D), slots, scopes and Eq-features), `rc_enum.py` (a bounded brute-force enumerator of DT° covering
templates; it only uses the trivial fact that occurrences lie in A(D) and is complete within its
bounds), `rc_random.py` (random DT° templates and bodies, an adversarial candidate-body set), and
`rc_anchor.py` (my implementation of the events (R\*), (N), (U), (D), (U restricted to pattern
occurrences), plus anchor ground truth by search for an instance outside Feat(D)). Each script was run
from `referee_checks/` with `python3 <script>`; outputs are in the `*.out` files listed in §3.

---------------------------------------------------------------------------------------------------

## 1. Overall verdict

The track is strong. I checked every proof in §§1–9 line by line. I found no error in the main
theorems: A (matching), Lemma R, Theorem B (finitariness), Theorem C (Acc = Feat), Theorem D (the
anchor theorem under (Rich)), Corollaries D.1–D.3, the counterexamples D.4–D.6, Theorem F with
Proposition F.8 (Esc = Θ(N²)), Corollary F.2 (finite elasticity), Propositions F.3, F.6, G.2 and G.3,
and Corollary G.4.

My independent brute force agrees with every claim it can test:
- the C8.2 correction (exactly 4 minimal templates; 3 of the prior 8 are genuinely minimal, the other
  5 lie strictly above the size-24 one);
- D.4, D.5, D.6 (the same minimal covering templates as the author);
- G.2 for n = 1, 2;
- Theorem C on 125,109 queries over 519 random data sets, with the enumeration bounds chosen so that
  T_0(D) and every T_φ lie inside them, so the comparison is exact on the query pool;
- Theorem D on 540 random targets (prediction = feature truth in all of them, prediction = brute force
  in all 519 that were decided);
- Corollary D.3 on Ind, Separation, Replacement and ∈-induction (1,169 data sets against feature
  truth, 116 against brute force);
- Theorem E's bound, against exact (inclusion–exclusion) non-anchor probabilities.

The defects I found are all small:
1. **Ground templates break three statements.** Theorem E(b),(c) and Proposition F.5 fail for a ground
   template (c(T\*) = 0, Fail(T\*) = ∅). Ground templates matter here, because ZFC's single axioms are
   ground. Easy fix (§2, items E and F5-F6).
2. **C11 is refuted, not proved.** The summary says "Prior conjecture C11 is proved in quadratic
   form". C11 conjectured a bound *linear* in the first datum. Proposition F.8 shows that this linear
   form is false in DT°. The correct statement: C11 is refuted, and the polynomial (quadratic)
   replacement holds and is tight.
3. **Two overclaims in the summary.**
   - Theorem E is said to have "matching lower bounds". Only the ρ- and ν-terms have one, not the
     κ-terms.
   - The lgg claim in (g) is stated without the (Rich) hypothesis that Corollary G.4 needs.
4. **Minor statements to tighten.**
   - The union lower bound in Corollary F.4 transfers only after encoding the parent paper's term
     language into sentences, and the constants change.
   - The lower bound in Proposition F.8 is stated only for N ≡ 4 (mod 5). Use ⌊(N+1)/5⌋ for other N.
   - "(Ind: 0.0054 vs 0.0015 at N = 24)" in §10 lists the bound first and the Monte Carlo value
     second, which reads like a violation. It is not one: my exact computation gives 0.00100 ≤ 0.00535.
   - The author's e7 Monte Carlo decides anchor status with Theorem D's own events, which is circular.
     My check (t7) replaces this with exact probabilities and anchor status by feature search, and the
     bound holds.

Conjecture F.7 is correctly labelled a conjecture. My own greedy search (t10) found at most 5
equation-kill steps on 6 slots under two binders, which is weak evidence in its favour.

---------------------------------------------------------------------------------------------------

## 2. Claim-by-claim

### A — matching (proved): **holds**

- (a) The pattern occurrence forces θ(M) = λz̄.(s|p)[z_m/y_m], because θ(M) is closed except for holes
  and the y_m are distinct indices.
- (b) The linear-time accounting is right: Σ_q |s|q| ≤ |s| because occurrences form an antichain, and
  Σ_q |t̄_q| ≤ |T|. The lazy check consumes at least one node of s|q per node of θ(M) it visits.
- (c) The freezing argument is right. Unfreezing gives a template body because frozen symbols occur in
  freeze(T') only applied to metavariable-free arguments.
- (d) Membership in SO° is polynomial. Each metavariable is independent, and there is a bottom-up DP
  over the positions of the target in which each node is either "hole z_m" or "common symbol".
  The NP-hardness usually cited for second-order matching (Baxter) uses arguments that contain
  metavariables, so it does not apply here. I did not re-check the original source. The 2^k matchers
  for P(0) are right.
- One small point: (d) is labelled "known", but it is prior C1(b), which was proved in the prior
  session, not taken from the literature.
- Independent evidence: my `match` is used in every check below. A failure would show up as covering
  or recovery errors, and none did.

### R — equivalence is renaming (proved): **holds**

Checked step by step:
- τ = σ;σ' is the identity at pattern occurrences: γ_j[ȳ] = y_j forces γ_j = z_j, since γ_j has no
  local indices.
- σ(M) has root N(ū) and σ'(N) = λw̄.M(δ̄) with δ_j = w_{π(j)}.
- Surjectivity: every metavariable of T' is the root of some σ(M), because ū is metavariable-free.
- The ρ∘π = id argument is right.

### B — finitariness, C8.3 for DT° (proved): **holds**

- Step V preserves determinacy.
- Step H handles all three common-root cases (hole, non-binding symbol, binder). Under a binder,
  M_j(z̄↑, 0) is a pattern occurrence.
- The measure (|C(D)| − |skel|, Σ arity) decreases lexicographically.
- (b) is correct: pattern occurrences of a saturated template lie at slots with argument set Y_σ(D),
  and derived arguments are forced by (S1) and Lemma 1.2(ii). So the skeleton is C(D) cut at Q, and
  the count is finite.
- (c) and (d) follow, with Lemma R making ≥ antisymmetric on classes.

Independent evidence:
- t1 checks explicitly that every enumerated covering template (2771 of them) is above one of the 4
  minimal ones.
- In t2 and t9 the enumeration-minimal sets were always finite and small.
- t9 also agrees with the lgg criterion, which is derived from Theorem B.

### B-corr — C8.2 correction (computed): **holds**

- My enumerator (`t1_c82.py` → `t1_c82.out`) finds exactly 4 minimal covering templates of
  {Ind(x=x), Ind(0=x)}:
  - 1067 covering templates at ≤ 5 occurrences;
  - 2771 at ≤ 6 occurrences with arity ≤ 2;
  - the 4 minimal ones are identical to the author's list, with sizes 24, 23, 23, 22;
  - only (f(0)=0 & …) is ≤ T_ind.
- `t1b_c82_prior8.py`: the 3 prior templates (0=f(0) …), (f(0)=0 …) and (0=0 …) are minimal. The other
  5 are each strictly above the size-24 template (f(0)=f(0) & ∀x(f(x)=x → f(Sx)=Sx)) → ∀x f(x)=x.
- The same conclusion follows by hand from the feature list. The features are σ1↔σ3, σ1,σ3 → σ2 with
  x ↦ Sx, and σ1,σ3 → each rigid 0 of φ(0) with x ↦ 0. That gives 2² choices at the two zeros.
- The prior referee had already flagged the C8.2 counts as bound artifacts. The author's contribution
  is the exact count, which is right.

### C — Acc(D) = Feat(D) (proved): **holds**

- Part (1): T_0 and T_φ are in DT° and cover D, and every feature is implied by one of them.
- Part (2): every covering template is above a saturated T', and inst(T') is cut out by Sym, Scope
  and Eq features with r ∈ A(D) and σ_M a slot. Both parts are correct.
- Corollary C.1's complexity is correct. Several data may be needed to read ū off, but each pair
  (σ, r) still costs O(n).

Independent evidence (`t3_random.py`, seeds 101–104; `t3b_lowdiv.py`, seeds 201–202, with
low-diversity bodies, 2–4 data and mostly two metavariables):
- For each random D, the enumeration bounds were set to kmax = |slots(D)| + 1 occurrences and
  amax = max_σ |Y_σ(D)|. These bounds contain T_0(D) and every T_φ.
- So on the query pool, "Feat accepts but an enumerated covering template rejects" would refute
  Theorem C, and "Feat rejects but every enumerated template accepts" would expose a bug.
- The pool consisted of adversarial and random instances of T\* plus two random instances of up to 150
  enumerated covering templates.
- Neither kind of disagreement occurred, in any decided case. Totals are in §3.

### D — the anchor theorem (proved, under (Rich)): **holds**

- (⇐) Under (R\*), C(D) = skel(T\*), slots(D) = Occ(T\*) and A(D) = skel ∪ Occ. Under (N),
  Y_σ(D) = Y\*_σ. (U) makes every Eq-feature a valid pair, and forcing gives ū = ū_0. Lemma 1.2(i)
  then puts every instance of T\* into Feat(D). This direction needs no (Rich).
- (⇒) In each case the constructed instance violates a D-feature, and the bodies used exist under
  (Rich):
  - a symbol root ≠ h;
  - z_m or R(z_m, …);
  - two different symbol roots;
  - λz̄.z_m or λz̄.R(z_m, …, z_m).

Independent evidence:
- `t3_random.py`: the prediction (R\*)∧(N)∧(U) equals feature truth in 340/340 cases and brute-force
  truth in 330/330 decided cases.
- `t3b_lowdiv.py` (seeds 201, 202): prediction = feature truth in 200/200 cases and brute force in
  189/189 decided cases.
- Wrong candidates over all 540 random cases: (R)∧(N)∧(D) was wrong in 45 and (R\*)∧(N)∧(D) in 29,
  always "says anchor, is not". (R\*)∧(N)∧(U restricted to pattern occurrences) was never wrong on random
  data, which matches the author's report that D.4 needs special structure.
- I also checked the derived-occurrence (R\*) failure by hand and by code: T\* = ∀x(f(x)=0) ∧ f(0)=0
  with f ↦ z, 0 is not an anchor.

### D1–D3 — specializations (proved): **holds**

- D.1: for 0-ary metavariables, Y\* = ∅, so a coincidence with a rigid r contradicts (R) and one with
  r carrying M' ≠ M is the failure of (D). This is Plotkin–Reynolds.
- D.2: formula bodies have symbol roots that survive plugging. Same-metavariable coincidences are
  forced valid by (N) and Lemma 1.2(ii).
- D.3: I re-derived the de Bruijn indices of T_sep (P(0,2)), T_rep (P(1,0,2), P(2,0,3), P(1,0,3)) and
  T_∈ (three copies of P(0)). All are pattern occurrences.

Independent evidence:
- `t4_zf.py 7 300` → `t4_zf_seed7.out`: (R)∧(N) = full events = feature truth in all 1,169
  non-duplicate data sets (Ind 290, Sep 293, Rep 299, ∈-Ind 287).
- `t4_zf.py 8 40 enum` → `t4_zf_enum_seed8.out`: brute force agrees with (R)∧(N) in every decided case
  (Ind 25, Sep 32, Rep 26, ∈-Ind 33; 1 Rep timeout).
- The author's `e5_specializations.py` reproduces its recorded output exactly.

Answer to Q1 (∀xφ from instances φ(t)): what is learned is the instance schema φ(c), anchored by
(R)+(D). This answers the brief's question correctly and keeps the ω-rule caveat in the brief.

### D4–D6 — wrong candidates (proved, computed): **holds**

- `t2_hand.py` → `t2_hand.out` reproduces all three independently:
  - D.4: events R\*, R, N, D and U_pat true, U false. Brute force gives the 2 minimal templates
    ∀x∀y(f(y,Sx)=0) ∧ ∀x∀y(f(y,x)=0) and T\*. The witness T\*[f:=0] is missed by the first.
  - D.5: minimal templates ∀x(f(0)=f(x)) and ∀x(0=f(x)).
  - D.6: the same 8 minimal templates as the author.
- I also verified D.4 by hand: the equation d|r = (d|σ)[x↦Sx, y↦y] holds in all three data, and (U)
  holds for every pair whose first component is the pattern occurrence.

### E — sample complexity (proved): **holds with fix**

The union-bound argument is right:
- Σ_h p_h^N ≤ p_max^(N−1);
- the disjoint pairs for κ are independent;
- in (c), (1−λ)^⌊n/2⌋ ≤ √e·e^(−λn/2) and 1 − e^(−a) ≥ 3a/4 for a ≤ 1/2.

Defects:
1. **Ground templates.** If T\* is ground, then Occ, the arguments and U(T\*) are all empty, so
   c(T\*) = 0 and λ is a minimum over the empty set.
   - (b) then says the verifier is exact with probability ≥ 1−δ once N ≥ 1 + (2/λ)·ln(0/δ). That is
     wrong at N = 0, because Acc(∅) = ∅.
   - (c) then gives tag i the contribution 0, but a tag with n_i = 0 is never exact. This has
     probability (1−π_i)^N.
   - ZFC's single axioms are ground, so this case matters for question Q3.
   - Fix: set c_i := max(c_i, 1) and λ_i := 1 for ground templates, or add Σ_i (1−π_i)^N. Require
     N ≥ 1 in (a) and (b).
2. **Lower bounds.** The summary says "matching lower bounds hold". The lower bound in (a) covers only
   the ρ- and ν-terms, and nothing is said about the κ-terms. The pair-splitting halves the κ rate, so
   the κ part need not be tight.

Independent evidence: `t7_rates_exact.py` → `t7_rates_exact.out`.
- I computed the *exact* P[D_N not an anchor] for the author's three laws (D.4 template, Ind,
  Separation), by inclusion–exclusion over the support of the sample, with anchor status decided by
  feature search rather than by Theorem D.
- I recomputed ρ, ν, κ and the bound with my own code; they reproduce the author's printed bounds.
- The bound holds at every N ∈ {2, 4, 8, 12, 16, 24}. It is nearly tight for D.4 (0.00476 vs 0.00479
  at N = 24) and for Separation, where it equals (1−ν_a)^N to 7 digits.
- A second law (`t6_rates.py` → `t6_rates.out`, T\* = ∀x(0=f(x))) is also consistent.
  - The exact probability is 0.7^N + 0.3^N. The κ-term 0.49^⌊N/2⌋ (= 0.7^N for even N) makes up
    almost all of it, so the bound is nearly sharp here.
  - At N = 8 the Monte Carlo value 0.0635 exceeds the bound 0.0599. This is sampling noise (standard
    error ≈ 0.004): the exact value is 0.0577.

### F — escalation bound; C11 (proved): **holds with fix (to the framing)**

- Lemma F.1 is correct, including (iii): an unchanged Π forces all Sym, Scope and Eq features, with ū
  forced on the unchanged Y.
- The three-way case split and the interval arguments for (β) and (γ) are right: a removed pair never
  returns, because features restrict to subsets.
- Hence m − 1 ≤ n + Σ b(p) + n(n−1), and Esc ≤ 2N² + 1.

Proposition F.8 is correct. `t5_escalation.py` → `t5_escalation.out` checks every step of the chain
for m = 2, 3, 4, 6, with an *explicit* witness template (T_0 of the predecessors) that covers the
predecessors, is in DT° and excludes the next query, so the check does not rely on Theorem C. The
chain lengths are 6, 11, 18, 38 = 2 + m², with sizes 5m − 1.

Defects:
- **C11 is refuted, not proved.** Prior C11 conjectured escalations "at most linear in the size of the
  first escalated datum". F.8 gives m² + 1 escalations after a first datum of size 5m − 1, so the
  linear form is false for DT°. It is false for the Ind target too: `t5b_escalation_ind.py` →
  `t5b_escalation_ind.out` runs the same scope-growth chain inside motives
  ∀y_1…∀y_b(l_1=0 ∧ … ∧ l_m=0). It gives 2 + m² escalations for m = 2, 3, 4, each witnessed by an
  explicit T_0. The notes say this only implicitly ("the polynomial form suggested by referee C").
  The summary's "C11 is proved in quadratic form" is misleading. State it as: "C11 (linear) is false;
  the quadratic bound holds and is tight."
- The lower bound 2 + ((N+1)/5)² holds as stated only for N ≡ 4 (mod 5). For general N use
  2 + ⌊(N+1)/5⌋².

### F-elastic — infinite thickness, finite elasticity, unions (proved/known): **holds with minor fix**

- F.2 is immediate from Theorem F, which needs no honesty.
- F.3 is checked in `t2_hand.out`: s lies in all four templates ∀xP(x) ∧ P(t), and P := z=z separates
  them pairwise.
- F.4's citation of Wright 1989 and Motoki–Shinohara–Wright 1991 is correct, and finite elasticity
  gives anchors in the strong sense (any language without a finite anchor yields an infinite elastic
  sequence).
- Minor: "lower bounds transfer upward … ⌊(N−1)/k⌋^k" relies on parent thm:caution:untagged(i), which
  is stated for a term signature with a k-ary p, a unary g and a constant c. Transferring it to DT°
  over sentences needs an encoding (for example R(p(…)), or nesting of +). The exponent k survives,
  but the constants do not transfer verbatim.

### F5–F6 — explicit untagged anchors; union verifier (proved): **holds with fix**

- F.6 is correct in both directions. `t8_union.py` → `t8_union.out` reproduces e9 with my own code:
  - k = 1 accepts s\*;
  - k = 2 and k = 3 accept the 5 fresh instances and reject s\*, a mixed sentence and an
    ∈-Ind-shaped non-instance.
- F.5 has a ground-template gap. If T_i\* is ground, Fail(T_i\*) = ∅, and "Θ_i is not covered by any k
  members of Fail" holds vacuously even when Θ_i = ∅. The proof's "some part is an anchor" then has no
  part to point to, and the conclusion is false: with no datum of a ground axiom, the union is not
  identified.
- Fix: require Θ_i ≠ ∅ for every i, or read "covered by at most k members, the empty union included".
  This matters for ZFC because of its ground axioms.

### G2 — |Min(D_n)| = 4^n (proved): **holds**

- The proof is correct: each choice A of zeros gives a saturated template, and the instance f := Sz
  separates any two choices.
- `t2_hand.out`, by brute force: |Min| = 4 for n = 1 and 16 for n = 2. Acc(D_n) = D_n on the candidates
  tried, under both the feature verifier and the brute-force intersection.

### G3–G4 — lgg criterion (proved): **holds**

Both directions check out. The (⇒) direction correctly uses T_ℓ ≤ T_0 (all of C(D) is rigid) and
T_ℓ ≤ T_φ (an occurrence would appear at r). Cor G.4 needs (Rich), which the notes state and the
summary omits.

Independent evidence: `t9_lgg.py 301 120` → `t9_lgg_seed301.out`.
- I compared the criterion with "the brute-force minimal set is a singleton". The bounds contain T_0
  and all T_φ, so a singleton within the bounds is equivalent to existence of the lgg. Reason: if the
  singleton U is ≤ T_0 and ≤ every T_φ, then a feature with r ∈ C(D) would make r both rigid and an
  occurrence in U, which is impossible. So criterion (i) holds, and (ii) follows in the same way as in
  the author's (⇒) proof.
- Of 120 cases, 115 were decided and 5 timed out. The criterion agreed with brute force in all 115:
  - 97 have an lgg, and in each of them T_all is equivalent to the brute-force lgg;
  - 18 have none.
- In all 63 cases where D was an anchor, the lgg exists and equals T\* (Cor G.4).

### F7 — Conjecture F.7: **unclear (correctly labelled a conjecture)**

- `t10_gamma_search.py 1 15 3,4,5,6` → `t10_gamma.out`: greedy search on ∀x∀y(c_1=0 ∧ … ∧ c_m=0),
  killing as few pairs as possible per step, found at most 2, 2, 4, 5 kill-steps for m = 3, 4, 5, 6.
- This is weak evidence for linearity, as is the author's.
- A structural remark that may help a proof. If (k,i), (i,j) and (k,j) are all in E, forcing gives
  ū_kj = ū_ki[ū_ij] on Y_k. So a datum that keeps (k,i) and (k,j) also keeps (i,j). Similarly, if
  (i,k), (k,j), (i,j) ∈ E, a datum that keeps (i,k) and (k,j) keeps (i,j). Hence a datum that kills
  (i,j) must also kill one other pair of every such triangle. Single-pair kills are possible only for
  pairs with no common in-neighbour and no intermediate slot.

---------------------------------------------------------------------------------------------------

## 3. Computations (commands run from `referee_checks/`; outputs saved there)

| script | what it checks | result |
|---|---|---|
| `t1_c82.py` | C8.2 correction | 4 minimal (sizes 24, 23, 23, 22); only (f(0)=0 …) ≤ T_ind; every covering template above one of them |
| `t1b_c82_prior8.py` | the prior 8 | 3 genuinely minimal; 5 strictly above the size-24 template |
| `t2_hand.py` | D.4, D.5, D.6, G.2 (n=1,2), F.3 | all as claimed |
| `t3_random.py S 100`, S=101(40 cases),102,103,104 | Thm C and Thm D vs independent brute force | Thm D: pred = feat 340/340, pred = enum 330/330; Thm C: 330/330 cases agree on 73,312 queries |
| `t3b_lowdiv.py S 100`, S=201,202 | the same, low-diversity bodies, mostly 2 metavariables, N=2–4 | Thm D: pred = feat 200/200, pred = enum 189/189; Thm C: 189/189 cases agree on 51,797 queries; 6 pool and 2 enumeration timeouts skipped |
| `t4_zf.py 7 300`, `t4_zf.py 8 40 enum` | Cor D.3 | 1,169/1,169 vs features; 116/116 vs brute force |
| `t5_escalation.py` | Prop F.8 with explicit witnesses | chains 6, 11, 18, 38 = 2 + m² |
| `t5b_escalation_ind.py` | quadratic chain for the Ind target (C11 refuted for Ind too) | chains 6, 11, 18 = 2 + m² |
| `t6_rates.py`, `t7_rates_exact.py` | Thm E | bound ≥ exact P[not anchor] at all N tested |
| `t8_union.py` | Prop F.6 / e9 | reproduced |
| `t9_lgg.py 301 120` | Prop G.3 / Cor G.4 | 115/115 agree (97 lgg, 18 none); T_all = brute-force lgg 97/97; lgg = T\* for all 63 anchors |
| `t10_gamma_search.py 1 15 3,4,5,6` | Conj F.7 | ≤ m − 1 kill steps found |

Reproducibility of the author's scripts: `e5_specializations.py` reproduces `e5_specializations.out`
verbatim. `e8_counterexamples.py` reproduces `e8_counterexamples.out` up to the order and choice of
printed representatives (Python set order); all counts are identical.

The 5 "bound artifacts" in the author's e4: with my bounds chosen to contain T_0 and all T_φ, I found
no prediction/brute-force disagreement at all. This supports the author's explanation that those 5
cases were artifacts of the enumeration bounds.

---------------------------------------------------------------------------------------------------

## 4. What the track should still cover or say

1. **Ground templates throughout.** State Theorem E and Proposition F.5 so that they cover ground
   members, which ZFC's single axioms are. The tagged and untagged sample-size claims are otherwise
   wrong for the "many axioms at once" use case of Q3.
2. **C11.** Say plainly that the linear conjecture is refuted (Prop F.8), and that the quadratic bound
   replaces it.
3. **Efficiency for unions.** Proposition F.6's verifier is exponential in |D| (it ranges over
   partitions). The track defers this to the method track; it should say explicitly that it gives no
   efficient untagged verifier. DTRC step 2 ("some minimal template has no refuted instance") remains
   without a polynomial test, and Min(D) can be exponential.
4. **Open items, correctly flagged:**
   - semantic vs syntactic generality;
   - anchors without (Rich);
   - parameter-renaming invariance;
   - polynomial-delay enumeration and #P-hardness of counting Min(D);
   - size-bounded classes;
   - Conjecture F.7.
5. **Citations.** The literature list is accurate as far as I can tell, and the author marks
   Hirata–Ogawa–Harao and Cerna–Kutsia as unchecked. "Baxter 1977" for NP-completeness of
   second-order matching is the usual attribution, but I did not verify it and it should stay marked
   as such.
