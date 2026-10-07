# Referee report: Track A, learning induction from motive-annotated instances

Scope. I checked `annotated-notes.md`, the JSON summary and the author's scripts `a*.py`. I wrote an
independent re-implementation and used it to attack every proposition. It has its own anti-unifier,
matcher, substitution, W and motive generator, and does not import `common.py` or the T1 code except for one
cross-check. The scripts, with their outputs (`*.out`), are in
`/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/induction/referee_A/`.

Verdict in one paragraph. The core of the track is correct, and I confirmed it independently on a richer
motive law than the author's. That law adds `mul`, `or`, `iff`, `ex` and six variable names, and it includes
binders that shadow the induction variable. The confirmed core is the anchor characterizations (P1, P2), the
reduction to metavariable tuples (P0), the tuple-gap bound and its tightness (P7a–c), soundness of the
W-guarded verifier (P6), the Metamath guard characterization (P9), and the step-by-2 bag-only theorem (P11).

I found one genuine soundness bug and one numerical error:
* **P8 (Lean-style redex encoding):** with a named outer binder `n` the encoding has variable capture. Some
  instances have a well-formed motive and a false β-normal form. So the claim "every instance with a
  well-formed motive body β-normalizes to the induction axiom" is false as stated.
* **P5:** the numbers N = 11 (refined bound) and N = 10 (exact) are stated for "q ≥ 0.4". They hold only for
  q ≥ 0.415 and q ≥ 0.425 respectively. At q = 0.4 they are 12 and 11.

The other findings are minor proof or wording repairs (P3, P6 leaf lemma, P7c, P9, P10a). The conjecture P7e
survives larger and richer search universes.

## Summary table

| item | verdict | main point |
|---|---|---|
| Algorithm LEARN-IND | holds (E1, E3); E2 needs a fix | Sound before identification and exact after an anchor. E2 must exclude capture of the binder `n`. |
| P0 tuple reduction | holds | Independently checked on 3,214 random schemas with repeated metavariables. |
| P1 anchors, x fixed | holds | 40,000 random sets of size 1–6 on a richer law: 0 mismatches. |
| P2 anchors, X metavariable | holds | 40,000 random sets with variables x, y, z, n: 0 mismatches. |
| P3 failure modes | holds-with-fix | "Only merges are P=A=B" holds for top-level columns only. With a shared root, deeper sub-columns merge (harmless). |
| P4 α-completeness | holds | Proof checked step by step. |
| P5 coupon constants | holds-with-fix | c = 9, ρ = 0.4 and N = 18 are right. N = 11 / N = 10 need q ≥ 0.415 / q ≥ 0.425. At q = 0.4 they are 12 / 11. The E3 "exact 10" is also 11 at q = 0.4. |
| P6 soundness, realizability | holds-with-fix | The soundness claims hold. The leaf-lemma hypothesis fails for untyped trusted MP; this is repairable by typing or a semantic argument. |
| P7a–c escalation bounds | holds-with-fix (wording) | Bounds are right and tight. "Exactly … from every 0-sound verifier" should read "at least …, and exactly for the VS verifier". |
| P7d genuine-only chains | holds | Value 10 for x+0=x reproduced by an independent search. |
| P7e conjecture | unclear | Remains a conjecture. Still 10 with a third variable, with `mul`, and up to motive size 9. I prove an upper bound of 15. |
| P8 Lean-style encoding | holds-with-fix | **Soundness clause false**: capture by the outer ∀n. Fix with a guard n ∉ FV(P) or a locally nameless binder. |
| P9 Metamath encoding | holds | Sufficiency tested exactly in finite induction models; the necessity counterexamples are verified. Minor: one of x∉χ, x∉θ is also redundant. |
| P10 noise | holds-with-fix (minor) | "Improper records do not affect the lgg" is true only once an anchor is present. W-filtering makes it moot. |
| P11 step-by-2 | holds | The compactness/ℤ/Nℤ proof is correct; I also checked the ρ_N quotient structure. |
| K1 Lean / set.mm facts | holds | Re-run on Lean 4.32.0; set.mm `finds`/`nnind` text re-downloaded and matches. |

## Detailed findings

### Algorithm LEARN-IND
* Steps 1–4 implement the cautious verifier of the guarded single-schema class with Φ = {ψ_Sub}.
  Lemma setting:guard gives acceptance `inst(lgg D) ∩ SubTrue`, and that set is contained in G
  (independently confirmed, see P6).
* The trimmed version space `⋂_{|E|=e} inst(lgg(D∖E))` is correct for H₁. Removing more points gives a more
  specific lgg, so the intersection is attained at |E| = e. With at most e errors some D∖E is clean, so
  acceptance is ⊆ G.
* Canonicalization is needed and sufficient: two Sub premises are always distinguished by their term argument.
* Issue: E2 as written is unsound (see P8).

### P0: holds
* The proof is correct.
  * (⇒) reads both sides at a skeleton occurrence of x_i.
  * (⇐) is immediate.
  * The first claim follows because skeleton columns have uniform roots, so the anti-unifier creates
    variables only at metavariable columns, with one shared table.
* Evidence: `r6_tuple.py`. On 3,214 random schemas over {f/2, g/1, h/3, a, b, c}, with repeated
  metavariables and 1–4 instances:
  * `lgg(σθ_j) ≡ σ(lgg tuples)`: 0 failures;
  * order and strictness agree: 0 failures.

### P1: holds
* Facts (a) and (b) are correct. At a free occurrence, the three formulas carry x, 0 and S(x), which are
  pairwise distinct, so the (D) events coincide. Root preservation makes the (R) events coincide.
* The guarded-class argument is correct.
* I also checked that A and B can never merge without P. The maps x↦0 and x↦Sx give columns
  t, t[0/x], t[Sx/x] that are pairwise distinct iff x occurs free in t.
* Evidence: `r1_anchor.py`. 40,000 random sets of size 1–6 were drawn from a law with these features:
  * `mul`, `or`, `iff`, `ex`;
  * variables x, y, z, n;
  * 25% same-root `eq` motives, 10% `∀x`/`∃x` motives (x occurs but only bound), and 10% x-free motives.

  Results:
  * `lgg ≡ σ_x` ⟺ (roots differ ∧ some x free): 0 mismatches;
  * 28,977 of the sets are anchors;
  * my anti-unifier and T1's `lgg_list` agree on all 40,000.

### P2: holds
* Checked on 40,000 random sets with induction variables in {x, y, z, n}: 0 mismatches.
* If all records use y, the lgg is the y-fixed rule (checked).

### P3: holds-with-fix (minor)
* The counterexamples for premise-order and conjunct-order variation, and for the mismatched A, are
  correct. I verified all three by hand.
  * The premise-order instance is false at y = 0.
  * The conjunct-order instance is false at y = 0, x = 1.
  * The `∀x(0=y)` instance is false at y = 1.
* Wording 1. "The only merges anti-unification can perform are P = A = B" is true for the top-level columns
  P, A, B. When all motives share a root, the anti-unifier recurses into sub-columns, and these merge freely.
  For example, the left argument of P and of A share a variable when x does not occur there. This is
  harmless because the lgg is still ⪯ σ_x, but the sentence should say "at the top-level columns".
* Wording 2. "Induction restricted to that symbol" is an upper bound. The learned rule can be more specific,
  for example `eq(add(…),…)`.
* Citation. The AC generalization reference (Alpuente, Escobar, Espert, Meseguer, *A modular order-sorted
  equational generalization algorithm*, Information and Computation 235, 2014) exists and is apt.

### P4: holds
* Every step checks out.
  * x does not occur in ψ₁, so x is free for v.
  * φ[0/x] = ψ₁[0/v] and φ[Sx/x] = ψ₁[Sx/v][x/v].
  * Renaming the bound x back to v is legal because the positions of free x in φ were free positions of v.
  * ∀I on u is legal because the derivation of C(φ,x) has only Sub leaves and no formula hypotheses.
  * ∀E with x is legal because x is free for u.

### P5: holds-with-fix (numerical range)
* Correct: c = 9, ρ_P = 0.4 (no subset of the non-`=` mass exceeds 0.4), and Thm coupon N = ⌈17.006⌉ = 18
  for every q ≥ 0.4.
* Correct for X a metavariable: c = 14, ρ = 0.3, theorem N = 25, exact N = 14. The exact N = 14 also holds at
  q = 0.4 (P(fail) = 0.00834).
* Error. The notes and JSON state "q ≥ 0.4" and then give refined N = 11 and exact N = 10. The author's script
  `a2_coupon.py` only evaluates q ∈ {1, 0.95}. `r3_coupon.py` gives:

  | q | refined-union N | exact N | exact P(fail) at N = 10 |
  |---|---|---|---|
  | 1.0 | 11 | 10 | 0.00605 |
  | 0.45 | 11 | 10 | 0.00856 |
  | 0.42 | 11 | **11** | 0.01033 |
  | 0.40 | **12** | **11** | 0.01206 |

  Thresholds: exact N = 10 iff q ≥ 0.4246; refined N = 11 iff q ≥ 0.4150. A simulation with my own lgg at
  q = 0.4 (20,000 trials) gives empirical P(fail) of 0.0126 ± 0.0016 at N = 10 (formula 0.0121) and 0.0078 at
  N = 11 (formula 0.0072).
* The same caveat applies to E3: "exact 10" becomes 11 at q = 0.4.
* Fix: state q ≥ 0.43, or q = 1 as in the simulation, or quote the q = 0.4 values (12 and 11).
* Nits:
  * "At π = 5%, 340 steps": ln 900/(0.05·0.4) = 340.1, so the requirement is 341.
  * The k-tag log factor ln(k·c) is omitted. The script says so; the notes do not.

### P6: holds-with-fix (proof repair)
* (1) Realizability, (3) `inst(σ_x) ∩ SubTrue = G`, (4) soundness before and exactness after identification,
  and (5) measuring on G: all correct.
* Evidence: `r2_sound.py`. Over 6,000 random data sets (half with X as a metavariable) I generated 240,000
  adversarial instantiations of lgg(D). The fillers were other motives, their images under
  0, Sx, SSx, S0, y, Sy, raw terms and variables. 65,874 of them had W-true Sub premises, and every one
  of these equals ind(P, v): 0 non-genuine.
* Leaf lemma. Its hypothesis is that "no step of T_trust concludes a Sub judgment". This fails for an untyped
  first-order encoding of trusted FOL. For example, MP `st(A, imp(A,B), B)` has instances with B := Sub(…).
  The E1 terms in the notes are bare formulas, unlike the paper's App. twotier(e), which wraps them in ⊢.
* The conclusion still holds for a W-true base by a semantic induction: value Sub terms as atoms by W; then
  FOL steps and the instances with W-true Sub premises (all genuine) preserve truth, so no W-false Sub is ever
  derived.
* Fix: either wrap formula judgments in ⊢ or sort FOL metavariables over formulas, or replace the syntactic
  proof by this semantic one.
* None of the soundness claims of the W-guarded verifier depend on the leaf lemma.

### P7a–c: holds-with-fix (wording only)
* (a) checked: |ind(φ)| = 15 + 8m + 2k, μ(σ_x) = 20, giving 39. Also 40 for X a metavariable, and the E3
  paper bound 48 (recomputed by hand).
* (b) The tuple-gap proof is correct: each escalation strictly generalizes the lgg, P0 transfers the chain to
  tuples, and the rank lemma applies. The difference from the paper bound,
  Σ(occ_i − 1)(|η x_i| − 1), is correct.
* Brute-force check (`r8_tuplebound.py`) on three small schemas with repeated metavariables. The longest
  chain never exceeds the tuple bound, and it equals the bound in 8 of 9 cases. The ninth case ran in a
  universe with only three constants.
* (c) Independent re-implementation of the one-symbol chain (`r6_tuple.py`): on 60 random φ₀, the forced
  escalations equal 3m + k exactly, and the final lgg ≡ σ_x.
* Wording. "Forces exactly Σ|θ₀x_i| escalations from every 0-sound verifier" should be "at least … from every
  0-sound verifier (Thm caution:esc), with equality for the VS verifier". A 0-sound verifier may escalate more.

### P7d: holds (computed)
* My independent DFS (`r7_chain.py`) uses canonical lgg states over triples. For s₀ = ind(x+0=x) it gives
  longest genuine chain = 10 in each of these universes:
  * eq-motives of size ≤ 7 over {x, y}, {x, y, z}, and {x, y} with `mul`;
  * size ≤ 8 over {x, y, z} (13,776 motives);
  * size ≤ 9 over {x, y} (18,774 motives).

  * size ≤ 8 over {x, y, z} with `mul` (45,136 motives).

  The witness chain matches the author's.
* Starting from x+y=y+x (`r7b_chain_other.out`; the printed label "from x+0=x" there is a hard-coded string),
  the chain is 12 over {x, y} and still 12 over {x, y, z}. This matches the author. The other starting
  motives were not re-run.

### P7e: unclear (conjecture; supporting evidence; new upper bound)
* No counterexample was found in the larger and richer universes above.
* New easy upper bound (proved). Before the last escalation, every motive queried has the root of φ₀; any
  other root, together with the non-vacuous s₀, yields σ_x at once. A state whose P, A, B keep a root of
  arity r has μ ≥ 1 + 3 + 3r − 3r = 4, and the start has μ = 1 + 3m + k. So the genuine-only chain is at most
  (3m + k − 3) + 1 = 3m + k − 2. For x+0=x that is 15, not the tuple bound 17.
* The gap 10 vs 15 remains open, so the status "conjecture" is right.

### P8: holds-with-fix (the soundness clause is false as stated)
* The anchor claim (roots not all equal; vacuity irrelevant), c = 2, N = 14 / 10 and the bound m are correct.
* Counterexample (`r4_redex_capture.py`).
  * The pattern instantiates P under the named binder `∀n` (`… ∀n(app(lam(x,P),n) → …)`). A motive body with
    n free is therefore captured. Capture-avoiding β cannot undo this: the capture happens at first-order
    instantiation, not during β.
  * Take P := (x = 0 ∨ ¬(x = n)), a well-formed formula with parameter n. The query is an instance of
    lgg(anchor) ≡ σ_λ, and its β-normal form is
    `(0=0 ∨ ¬0=n) ∧ ∀n((n=0 ∨ ¬n=n) → (Sn=0 ∨ ¬Sn=n)) → ∀n(n=0 ∨ ¬n=n)`.
  * The antecedent is true: at n = 0 the conclusion of the inner implication is S0=0 ∨ ¬S0=0, and for
    n ≠ 0 its premise is false. The consequent `∀n(n = 0)` is false. So an adversarial prover gets a false
    theorem accepted after identification.
* Genuine records are also mis-encoded. The record for motive x+n = n+x β-reduces to a formula with
  consequent ∀n(n+n = n+n), not ∀x(x+n = n+x).
* The author's script tests β only on motives without free n (`if 'n' not in free_vars(p)`), and their
  universes use only x and y. So the issue was invisible in their checks.
* Fix:
  * use a nameless/de Bruijn outer binder as Lean does (Lean's `@Nat.recAux (fun n => m + n = n + m)` has
    the parameter m as an fvar, so no capture is possible); or
  * add the guard n ∉ FV(P) and α-rename community records' parameters away from n.
  The guard adds at most one escalation (Rem imitation:guards).

### P9: holds
* (b) Sufficiency proof checked line by line, including the X ≡ Y case.
* Exact test (`r5_metamath.py`). ℤ/N (N = 2..5) and the ρ_N quotients (N = 3..5) satisfy the full induction
  schema, so they are exact test structures, not bounded approximations. Results:
  * 7,058 random instances satisfied {y∉φ, x∉χ or x∉θ} and had all five premises true in such a structure;
    none had a false conclusion.
  * Counterexamples appeared only when both x-guards were violated.
* Both necessity counterexamples are verified by hand and by bounded check. Counterexample 1 needs PA, not Q,
  for ¬(Sy = SSy); the author says so.
* (c) E3 canonical anchors: 20,000 random sets, 0 mismatches. With X and Y as metavariables
  (`r10_mm_meta.py`): 20,000 random canonical sets give 0 mismatches against (roots differ ∧ some x free ∧
  X column varies ∧ Y column varies).
* (d) Guard learning (`r9_guards.py`). It reproduces x∉ψ, x∉χ, x∉θ, y∉φ plus the spurious y∉ψ, and one
  non-canonical record removes y∉ψ.
* Minor. In the set.mm transcription with conclusion ⊢φ, the redundant guards are x∉ψ, x≠y, **and one of**
  x∉χ / x∉θ. The notes list only the first two.

### P10: holds-with-fix (minor)
* (b) and (c) are correct applications of Thm imitation:trimmed, Thm imitation:iidnoise and Cor
  imitation:necessity.
  * The sufficient condition is ρβ > α with ρ = min(0.4, q).
  * The necessary conditions are 0.4β > α (split {=} vs rest) and qβ > α.
  * With m = 0.6 ≥ 1/2 these coincide, so the threshold is sharp.
  * Here α is the noise tolerance of a robustly sound verifier.
* (a) "Shape-consistent improper records … do not affect the lgg" holds only if the data already contain an
  anchor. Before that, such a record can make the lgg more general, though still ⪯ σ_x. The W-filter of
  step 2 drops these records anyway.
* The collapse example checks out: for P = ¬(x=Sy) and second-premise term SS0, the instance is false at y = 0.

### P11: holds
* (2) Checked by hand.
* (4) The model argument is correct. ℤ/Nℤ for odd large N is a congruence quotient of ℕ. Closed
  quantifier-free sentences, which is what the author's W actually evaluates, keep their values when N
  exceeds all values involved. SS generates ℤ/Nℤ, so every step-by-2 conclusion holds for every parameter
  assignment.
* ρ_N (0→…→N−1→1) is also a congruence quotient: n ~ m iff n = m or (n, m ≥ 1 and n ≡ m mod N−1). So + and ·
  are well defined, as the author's `red` map assumes. For even N, SS is transitive on the odd cycle.
* So {step2, Q1} and {step2, Q2} are clean, {step2, Q1, Q2} is refuted, and the conflict is minimal; hence
  Q1 and Q2 are collateral. "Includes" is the right word: other PA axioms may also be collateral.
* (5) is correct. In fact C_P itself is a sentence of Th(ℕ,0,S), so a W that decides that theory refutes it
  in one step.

### K1: holds
* Lean, re-run on the local toolchain v4.32.0 (`RecCheck.out`):
  * `@Nat.rec : {motive : Nat → Sort u_1} → …` has an implicit motive;
  * `induction` elaborates to `@Nat.recAux (fun n => …)` with the motive as an explicit λ, including for a
    motive with a parameter m;
  * `Nat.recAux` uses `motive 0` and `motive (n + 1)`.
* set.mm, re-downloaded from the `develop` branch (`setmm_finds_check.txt`): the `finds` hypotheses, the
  conclusion `|- ( A e. _om -> ta )` and the DV list match the author's excerpt exactly.
* What the author left unchecked: in Metamath every use of `finds` must discharge its floating hypotheses
  (`wff ph`, etc.) by syntax-construction proofs, so the motive is recoverable from each proof. I state this
  from knowledge of the Metamath proof format; I did not verify it on individual set.mm proofs.

## Citations
These are correct as far as I can tell:
* Plotkin 1970 and Reynolds 1970 (Machine Intelligence 5);
* Pfenning, LICS 1991;
* Baumgartner–Kutsia–Levy–Villaret, JAR 2017, linear-time HO pattern anti-unification;
* Miller 1991 (J. Logic Comput.);
* Huet–Lang 1978 (second-order matching);
* Dowek 1994 (third-order matching, APAL);
* Stirling 2009 (LMCS, higher-order matching decidable);
* Goldfarb 1981;
* Alpuente et al. 2014;
* Presburger 1929.

I could not check whether Huet's 1976 thesis contains the anti-unification algorithm. It is commonly
credited, and the author marks it as uncertain.

## Not checked
* The untagged-class threshold "not covered by k−1 failure sets", from earlier in the session.
* The P7d values for starting motives other than x+0=x. The exception is x+y=y+x; see the P7e note.
