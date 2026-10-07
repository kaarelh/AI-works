# Track "untagged": learning many axioms and axiom schemas at once from unlabelled instances — final notes

Final, self-contained record of the track for the brief `../../00-brief.md` (questions Q1–Q3, method DTRC of brief §5),
revised after the adversarial referee report `referee.md`. Author: Claude (Anthropic), for Kaarel Hänni. Supersedes
`notes.md` (v1), which is kept unchanged for the record.

Status labels: **proved** (complete proof here), **computed** (script run; command, output file and numbers in §9),
**known** (literature, credited in §11), **conjecture**, **hypothesis** (an assumption imported from another track or stated
for a theorem and not proved here), **open**. Code: `code/` in this directory. All `.out` files were regenerated with the
final libraries (v2); the v1 outputs are in `code/v1_outputs/`.

*Numbering.* Results keep their v1 numbers, because the referee report and the verification log (§12) refer to them. New
results get new numbers (Props 3.4–3.6, 5.10–5.13, §7.2(b)) and are placed where they belong logically, so numbers are not
always increasing in the text.

---------------------------------------------------------------------------------------------------------------------------

## 0. Results in brief

| # | result | status |
|---|---|---|
| U1 | **Pigeonhole theorem.** With the exact bound k = k′ and sound negatives that refute every template covering anchor data of two distinct targets, the cautious k-union learner is exact as soon as each target's data contain a *tagged* anchor. At most μ·Σ_{i<j}\|A_i\|\|A_j\| negatives suffice: one refuted instance per minimal covering template of each cross anchor pair. The learner generates them itself, without labels, under hypothesis W. | proved (W) |
| U1-PA | PA (Q1–Q7 + induction): every cross pair has one minimal covering template, refuted by one of 4 sentences. | computed; independently confirmed by the referee |
| U2 | **Spare slots (k > k′).** Splits are unrefutable: every hypothesis D ⊆ h ⊆ R* survives every sound negative. Under cross-separation the exact per-target threshold is: D_i is not coverable by m = k−k′+1 negative-avoiding templates whose union misses an instance of σ_i. (v1's caveat on failure families is withdrawn; see U17.) | proved |
| U3 | **Slot accounting** (generalizes the prior PA result "k−1 failure sets"): under *absorption*, target i gets k − c_i slots. Raw DT° PA: c = 4 on positive data, c = 7 with three Δ₀ negatives. | proved; computed (consistency check) |
| U4 | **A bound is necessary** (no bound ⇒ Acc = D for every sound negative set; Gold). | proved / known |
| U5 | **DTRC theorem.** (i) Within-target merges are never refuted. (ii) Under refutation separation at budget d, the final clustering is the target partition for every merge order. (iii) The per-cluster cautious verifier is then sound at all times and exact once each cluster contains an anchor. (iv) The failure probability equals the tagged one. (v) O(n²) coherence *tests*, or n·k′ + k′(k′−1)/2 for the online policy. | proved (W) |
| U6 | **Residual merges.** Without separation, Acc_d ⊆ R* ∪ Res_d(D): soundness holds relative to the residue of unrefuted cross templates. The output is truth-sound if every residual template is truth-sound. Exactness can fail by fragmentation, *even on clean data with anchors and disjoint instance sets*, and then no learner can be both exact and target-sound (Remark 5.11). | proved; computed |
| U7 | **∀xφ from instances is a sound cross merge.** Two instances φ(t₁), φ(t₂) whose substituted terms have different heads form a DT° anchor for φ(z) (two-point lemma). DTRC merges them iff φ(z) is not refuted, and then accepts ∀xφ itself (closure-normal form). With an oracle that refutes every false instance, as R-Δ₀ does for quantifier-free φ over ℕ, "never refuted" means "∀xφ true" (the ω-rule). This fails in ℝ. | proved; computed |
| U8 | **Depth relativization is necessary.** No computable learner is both (a) sound at all times relative to the full-depth residue and (b) eventually exact on every practice that is separated at some finite, unknown depth. The construction now uses MRDP (Diophantine H_e), so the stated oracle R-Δ₀ suffices. | proved |
| U9 | **Whole-cluster tests.** Coherence is downward closed but not transitive. Single linkage builds incoherent clusters; whole-cluster agglomeration keeps every cluster coherent (except refutable singletons). Under separation all variants agree. | proved; computed |
| U10 | **Noise.** Refutable mistakes are isolated. Under separation, mistakes never bridge targets. Unrefutable mistakes can be absorbed or can fragment a target. The robust variant (multiplicity threshold s > e plus the e-trimmed verifier) is sound with ≤ e absorbed mistakes per cluster. | proved; computed |
| U11 | **MDL / size principle** (no negatives). A naive code splits induction by main connective (proved). A well-specified adaptive code gains at most O(log n) from splitting (proved modulo standard coding facts), and its computed preference is for the true partition. Misspecified adaptive codes also split (computed). | proved; computed |
| U12 | **PA.** Every cross merge among Q1–Q7, induction and the instance schemas is refuted by Δ₀ evaluation with ∀-instantiation. DTRC recovers the 8 targets: 3 seeds, 200/200 held-out inductions accepted, 0 false acceptances. Refutation separation holds on every run (all 147/201/175 cross pairs refuted). | computed |
| U13 | **ZF.** Every cross merge among Ext, Pair, Union, Power, Inf, Found, Separation, Replacement and ∈-induction is refuted, by HF counterexamples or by pure logic. Russell's paradox separates the comprehension-shaped axioms. DTRC recovers the 9 targets: 3 seeds, 180/180 held-out instances accepted, 0/30 naive-comprehension instances accepted. | computed; `mincov` independently confirmed by the referee |
| U14 | **Natural separation failures.** (a) Sound merges: ∀xφ, redundant axioms. (b) Weak Union + weak Power merge into the universal-set schema, which logic and HF counterexamples cannot refute (Prop 7.1) but coherence refutes. (c) K₀-shaped templates. (d) Permanent residue: not constructed for a natural merge; Prop 5.13 restricts where it can come from. | proved; computed |
| U15 | K₀ in DT°: two minimal templates. The intersection verifier excludes J*₀. | computed; independently confirmed |
| U16 | `mincov` agrees with brute-force enumeration (supports W on the fragment used). | computed; extended by the referee |
| **U17** | **Head classes.** After parameter canonicalization, a term metavariable has finitely many head classes. The \|F\|+p+1 head specializations of φ(z) cover inst(φ(z)) (5+p for arithmetic), so v1's caveat was false. Threshold for one-variable quantifier-free schemas: exact if m < #classes present; if a class is missing, exact iff m < #classes present; at m = h the condition is Plotkin's (R)+(D) per class (Prop 3.5). Closed form κ = (h−1)r + \|cl(T_r)\| for unary signatures (Prop 3.6). Numeral-only data are never exact with a spare slot. | proved; computed (2000/2000, 60/60, 254/254, 2509/2509) |
| **U18** | **Cost of one coherence test.** Equals \|Min(X)\| refutation checks. \|Min(X)\| = 1 for quantifier-free X (Plotkin lgg) and for X containing an anchor; it can be 4^Θ(n) in general (track single). With a single negative the test is polynomial; in general its complexity is open. In every PA/ZF run here, \|Min(X)\| = 1 in all tests. | proved (with track-single hypotheses); computed |
| **U19** | **Implementation = theory.** v2 keeps a global set N of refuted sentences and audits each run against it. A run that passes the audit is *exactly* DTRC with the fixed sound oracle Ref_d := N_final, so all theorems apply to it verbatim. Every run here passes the audit on its first pass. All v1 results are reproduced unchanged. The referee's 120 "budget-unrefuted" ZF cross templates are now refuted (0/598). | proved; computed |
| **U20** | **No unsound permanent residue from quantifier-free arithmetic templates.** With R-Δ₀ at unbounded depth, an unrefuted template without binders in its rigid part is truth-sound. Permanent unsound residues in arithmetic therefore need quantifiers in the template (as K₀ has). | proved |
| **U21** | **ZFC.** The Axiom of Choice is a single ground axiom. All 12 cross templates with the ZF targets are refuted (HF counterexample or logic). DTRC recovers 10 pure clusters: 3 seeds, schemas exact, AC accepted, 180/180 held-out. | computed |

Main hypotheses imported:
- **(W)** Every finite nonempty X has finitely many minimal covering DT° templates, they are computable, and every covering template lies above one. Track 'single' now states this as its Theorem B (proved there; not refereed when this was written). It is the prior conjecture C8.3. Here it is cross-validated by brute force (u0), and the referee confirmed it independently for every cross pair and cluster used (`referee_code/ref1`, `ref2*`).
- **(A)** Anchor theorems for the DT° targets used. Sources: track 'single' Thm D / Cor D.1–D.3; prior C3 for T_ind; Lemma 5.5 here for one-variable patterns.

---------------------------------------------------------------------------------------------------------------------------

## 1. Setting

**Object language and data.** First-order formulas in *closure-normal form*:
- arithmetic: 0, S, +, ·, =; set theory: ∈, =;
- connectives ¬ ∧ ∨ → ↔; quantifiers ∀ ∃;
- free variables are *parameters* (names), read under universal closure; bound variables are de Bruijn indices.

S is the set of such formulas. Formulas that differ by a bijective renaming of parameters have equivalent closures. Where it
matters (§3), sentences are identified *up to renaming of parameters*. The code canonicalizes: parameters are renamed
a1, a2, … in order of first occurrence. Templates are matched literally, which can only under-accept.

**Templates (DT°)** (brief §3).
- Metavariables M : ι^n→o or ι^n→ι are applied to metavariable-free argument terms.
- Each metavariable has a *pattern occurrence*: rigid, applied to pairwise distinct bound variables in scope.
- inst(T) ⊆ S is the set of β-normal instances under closed-up λ-bodies (free variables of bodies are parameters only).
- T ≼ T′ means inst(T) ⊆ inst(T′) (semantic order).
- Ground axioms are templates without metavariables.
- Matching is unique and linear: prior C1; track single Thm A.

**Targets and data.**
- Σ* = {σ_1,…,σ_k′} ⊆ DT°, and R* = ⋃_i inst(σ_i).
- Data: a finite multiset D ⊆ R* with *hidden* labels, D = D_1 ⊔ … ⊔ D_k′, D_i ⊆ inst(σ_i). A datum that lies in two
  instance sets carries one label.
- Data arrive as a text or i.i.d.: each datum picks target i with probability π_i, then an instance σ_iΘ with Θ ~ Λ_i.

**Truth and the refutation oracle.** Tr ⊆ S is the set of true formulas (closure true in ℕ, resp. in V), and R* ⊆ Tr. The
oracle is a family Ref_0 ⊆ Ref_1 ⊆ … ⊆ S with:
- **(OS) one-sided soundness:** Ref_d ∩ Tr = ∅ for all d (hence Ref_d ∩ R* = ∅).
- **(Dec)** (strengthened after referee U1):
  - membership in Ref_d is decidable uniformly in d;
  - "inst(T) ∩ Ref_d ≠ ∅" (*T is d-refuted*) is decidable uniformly in (T, d).

  Example: Ref_d contains only formulas of size ≤ d and membership is decidable. The instances of T of size ≤ d are then
  finitely many and effectively listable, so both tests are decidable. Fix an effective enumeration of S (by size, then
  lexicographically); the *first d-refuted instance* of a d-refuted T is then computable. A fixed finite set N ⊆ S \ Tr,
  used as Ref_d for all d, satisfies (OS) and (Dec) (by matching). This is how the implementation is read (Prop 5.12).

Ref_∞ = ⋃_d Ref_d. The oracles used are all sound and none is complete (§7, §9):
- **(R-Δ₀)** at depth d, applied to sentences of size ≤ d:
  - instantiate parameters by numerals ≤ d;
  - closed atoms and connectives are evaluated;
  - ∀ is refuted by a numeral counterexample ≤ d;
  - ∃ is verified by a witness ≤ d;
  - ∀ is verified, and ∃ refuted, only by a logic derivation (EUF plus the closed equations of ℕ).
- **(R-HF)** hereditarily finite counterexamples to Π₁-shaped instances, sound by Δ₀ absoluteness (HF is transitive).
- **(R-logic)** logical falsity, certified by a propositionally unsatisfiable set of ground instances of the Skolem form
  (Herbrand).
- **(R-coh)** coherence: R-logic applied to the formula together with designated true sentences.

These are the parent report's world and coherence channels (lem:twotier:onesided: refutation is one-sided and target-blind).

**Hypothesis classes.** H_k = {⋃_{l≤k} inst(τ_l) : τ_l ∈ DT°}. For a finite N ⊆ S (found negatives):
- the version space is VS_k(D,N) = {h ∈ H_k : D ⊆ h, h ∩ N = ∅};
- the *cautious k-union learner* accepts Acc_k(D,N) = ⋂VS_k(D,N).

**Covering templates.** For finite nonempty X ⊆ S: Cov(X) = {T ∈ DT° : X ⊆ inst(T)}, and Min(X) is the set of its
≼-minimal members (one per equivalence class).

> **Hypothesis (W)** [track 'single' Thm B; prior conjecture C8.3]. For every finite nonempty X ⊆ S, Min(X) is finite and
> computable from X, and every T ∈ Cov(X) satisfies T ≽ T₀ for some T₀ ∈ Min(X).
>
> **Consequence (W′)** [= track single Thm B(d)]. If X ⊆ inst(σ) with σ ∈ DT°, some T₀ ∈ Min(X) has
> inst(T₀) ⊆ inst(σ). *Proof:* σ ∈ Cov(X); apply (W). ∎

**Anchors.** A finite A ⊆ inst(σ) is an *anchor* for σ in DT° if every T ∈ Cov(A) satisfies T ≽ σ. This is the tagged
(single-template) notion of the brief and the parent report (def:imitation:anchor with H = H_1 over DT°).

> **Hypothesis (A)** [track 'single' Thm D]. Each non-ground target used below has finite anchors characterized by witness
> events. Known cases:
> - T_ind: anchor ⟺ (R) roots not all equal and (N) some motive has x free (prior C3);
> - ground σ: A = {σ};
> - one-metavariable patterns: Lemma 5.5 below (proved here).

**Lemma 1.1 (cautious soundness; proved, known in substance).** If k ≥ k′, D ⊆ R* and N ∩ R* = ∅, then R* ∈ VS_k(D,N),
so Acc_k(D,N) ⊆ R*. Acc_k is monotone in D and in N.

*Proof.* R* = ⋃ inst(σ_i) ∈ H_k, contains D, and avoids N. Larger D or N shrink VS. ∎ (lem:imitation:cautious(a),
thm:caution:vs(a) of the parent report.)

**Lemma 1.2 (finite form of the k-union verifier; proved).** Assume (W). Let Min_N(B) = {T ∈ Min(B) : inst(T) ∩ N = ∅}.
Then

  Acc_k(D,N) = ⋂ { ⋃_{B∈π} inst(T_B) : π a partition of D into ≤ k blocks, T_B ∈ Min_N(B) }

(the empty intersection is S). In particular, for finite N, membership in Acc_k(D,N) is decidable (exponential in |D|).

*Proof.* Each displayed union lies in VS_k(D,N), so Acc is contained in the intersection. Conversely, let
h = ⋃_l inst(τ_l) ∈ VS. Assign each datum to the first slot covering it; this partitions D into ≤ k blocks
B ⊆ inst(τ_l). By (W), τ_l ≽ T_B for some T_B ∈ Min(B). Then inst(T_B) ⊆ inst(τ_l) ⊆ h avoids N, so T_B ∈ Min_N(B) and
h ⊇ ⋃ inst(T_B). Hence ⋂VS contains the displayed intersection. ∎

---------------------------------------------------------------------------------------------------------------------------

## 2. The pigeonhole theorem (k = k′)

**Theorem 2.1 (pigeonhole; proved).** Let k = k′ and D ⊆ R*. For each i let A_i ⊆ D_i be a nonempty anchor for σ_i. Let
N ⊆ S with N ∩ R* = ∅ satisfy

 **(X)** for all i ≠ j, a ∈ A_i, b ∈ A_j and every T ∈ DT° with a, b ∈ inst(T): inst(T) ∩ N ≠ ∅.

Then Acc_k(D,N) = R*.

*Proof.* "⊆" is Lemma 1.1. For "⊇", let h = ⋃_{l≤k} inst(τ_l) ∈ VS_k(D,N) (fewer than k slots are allowed).
1. For each i put L_i = {l : τ_l covers some element of A_i}. L_i ≠ ∅ because A_i ⊆ D ⊆ h and A_i ≠ ∅.
2. If l ∈ L_i ∩ L_j with i ≠ j, then τ_l covers some a ∈ A_i and some b ∈ A_j. By (X), inst(τ_l) meets N, which
   contradicts h ∩ N = ∅.
3. So L_1,…,L_k′ are nonempty, pairwise disjoint subsets of a set of at most k = k′ slots. Hence each L_i is a singleton
   {l_i}.
4. τ_{l_i} covers all of A_i: every element of A_i is covered by some slot, and that slot must be in L_i. Since A_i is an
   anchor, τ_{l_i} ≽ σ_i.
5. Hence h ⊇ ⋃_i inst(σ_i) = R*. As h was arbitrary, Acc ⊇ R*. ∎

*Remarks.*
1. (X) forces the A_i to be pairwise disjoint: if a ∈ A_i ∩ A_j, the ground template a covers a and a, and inst(a) = {a} ⊆ R*
   cannot meet N.
2. For a non-ground σ_i every anchor has ≥ 2 elements: the ground template s covers {s} and misses the rest of inst(σ_i).
3. Only anchor data matter; the rest of D can be anything in R*.
4. The theorem uses nothing about DT° except that anchors are defined in the same class as the slots.

**Corollary 2.2 (a finite set of negatives, generated without labels; proved under (W), (Dec)).**

(a) Let P_× = {(a,b) : a ∈ A_i, b ∈ A_j, i < j}. Suppose *anchor-pair separation at depth d*: every T ∈ Min({a,b}),
(a,b) ∈ P_×, is d-refuted. Choose n_T ∈ inst(T) ∩ Ref_d for each such T. Then N_× = {n_T} satisfies (X), and
|N_×| ≤ μ·Σ_{i<j}|A_i||A_j| with μ = max_{P_×}|Min({a,b})|.

(b) The learner does not know the labels, but it can compute

  N(D,d) = {the first d-refuted instance of T : T ∈ Min({a,b}) d-refuted, a, b ∈ D}

using (W), (Dec) and the fixed enumeration of S. Then:
- N(D,d) ⊆ Ref_d is sound by (OS), and N(D,d) contains a choice of N_×;
- hence the cautious k′-union learner with self-generated negatives, Acc_k′(D, N(D,d)), is sound at all times (Lemma 1.1);
- it is exact as soon as D contains anchors, under anchor-pair separation at depth d;
- its acceptance is decidable (Lemma 1.2).

*Proof.* (a) If T′ covers a ∈ A_i and b ∈ A_j, then T′ ∈ Cov({a,b}). By (W), T′ ≽ T for some T ∈ Min({a,b}), and
n_T ∈ inst(T) ⊆ inst(T′).

(b) N(D,d) contains a d-refuted instance of every d-refuted minimal covering template of every pair of data, in particular
of every T ∈ Min({a,b}) with (a,b) ∈ P_×. Within-target pairs may contribute further negatives: refuted minimal templates
that are not below σ_i. These are false sentences, so harmless. Apply Theorem 2.1. ∎

**Example 2.3 (PA, raw DT° encoding; computed, u1; independently confirmed by the referee).**
- Targets: Q1–Q7 in closure-normal form (parameters a1, a2) and T_ind, so k′ = 8.
- Anchors: {Q_i} for each axiom; for induction, any two instances with (R) and (N) (prior C3).
- Every cross pair tested (21 Q–Q pairs, 7×4 Q–Ind pairs) has exactly one minimal covering template, and it is refuted at
  small depth.
- The minimal templates are F0 (bare formula metavariable), F0→F1, t0=t1, (a1+t0)=t1 and (a1·t0)=t1. They are refuted by
  just four sentences: 0=S0, (0=0→0=S0), (a1+0)=0 [a1:=1] and (a1·0)=S0 [a1:=0].
- The referee's independent enumerator found all covering DT° templates of size ≤ 14 for all 49 PA cross pairs: 68
  templates, all refuted, none outside `mincov`.
- By hand: at top level every metavariable is 0-ary, so every Q–Ind pair has minimal template F0 or F0→F1 *for every
  motive*.

So **four negatives make untagged PA as easy as tagged PA at k = 8**: the learner is exact after one occurrence of each Q_i
and two induction instances with different main connectives, at least one non-vacuous. Theorem 4.1 shows that three
negatives suffice, because mixed Q/induction slots are absorbing.

---------------------------------------------------------------------------------------------------------------------------

## 3. Spare slots (k > k′)

**Theorem 3.1 (splits are unrefutable; proved).** For every N with N ∩ R* = ∅ and every k ≥ k′,
VS_k(D,N) ⊇ VS_k^⊆(D) := {h ∈ H_k : D ⊆ h ⊆ R*}, hence Acc_k(D,N) ⊆ ⋂VS_k^⊆(D). So if some h ∈ H_k with D ⊆ h ⊆ R*
misses q ∈ R*, no sound negative evidence whatever makes the learner accept q.

*Proof.* h ⊆ R* and N ∩ R* = ∅ give h ∩ N = ∅. ∎

A *split* is the typical such h: replace σ_i by finitely many specializations T_1,…,T_m (inst(T_j) ⊆ inst(σ_i)) that
together cover D_i. Specializations are sound (their instances are target instances), so refutation, which is one-sided,
can never remove them. This is the untagged face of lem:twotier:onesided ("refutation never condemns a subset of the
target").

**Theorem 3.2 (exact threshold under cross-separation; proved).** Let k ≥ k′, let every D_j be nonempty, let N ∩ R* = ∅,
and suppose N *cross-separates* D: every T ∈ DT° covering a datum of D_i and a datum of D_j (i ≠ j) meets N. Put
m = k − k′ + 1. Fix a target i.

(a) Suppose every family F of at most m templates with ⋃inst(F) ⊇ D_i and ⋃inst(F) ∩ N = ∅ has ⋃inst(F) ⊇ inst(σ_i).
Then inst(σ_i) ⊆ Acc_k(D,N). If this holds for every i, then Acc_k(D,N) = R*.

(b) Suppose there are such a family F (|F| ≤ m, covering D_i, avoiding N) and q ∈ inst(σ_i) with
q ∉ ⋃inst(F) ∪ ⋃_{l≠i} inst(σ_l). Then q ∉ Acc_k(D,N).

(c) If the instance sets inst(σ_l) are pairwise disjoint, the condition of (a) for target i is necessary and sufficient
for inst(σ_i) ⊆ Acc_k(D,N).

*Proof.* (a) Let h ∈ VS with slots τ_l.
1. By cross-separation, a slot covering a datum of D_i covers no datum of D_j (j ≠ i).
2. Let L_j = {l : τ_l covers a datum of D_j}. The L_j are nonempty and pairwise disjoint, so |L_i| ≤ k − (k′−1) = m.
3. The slots in L_i cover D_i and avoid N, so ⋃_{l∈L_i} inst(τ_l) ⊇ inst(σ_i).

(b) h = ⋃inst(F) ∪ ⋃_{l≠i} inst(σ_l) uses at most m + k′ − 1 = k slots, contains D, avoids N (the σ_l are in R*), and
misses q.

(c) If (a)'s condition fails for i, some admissible F misses some q ∈ inst(σ_i). By disjointness q ∉ inst(σ_l) for
l ≠ i, so (b) applies. ∎

**Corollary 3.3 (the threshold in terms of failure specializations; proved).** Call T a *proper specialization* of σ if
inst(T) ⊊ inst(σ). A *failure family* for σ is a set Fail(σ) of proper specializations such that every non-anchor finite
X ⊆ inst(σ) lies in inst(F) for some F ∈ Fail(σ). Examples:
- first-order patterns: the head specializations σ[x↦f(z̄)] (one per variable and head class, Prop 3.4) and the
  identifications σ[y↦x] (Plotkin; thm:imitation:untagged);
- T_ind: T_ind[P:=λx.f(P̄(x))], one per formula constructor f (eight in arithmetic: =, ¬, ∧, ∨, →, ↔, ∀, ∃), and
  T_ind[P:=λx.A] for vacuity (prior C3).

(a) *Necessity, whatever the negatives.* Suppose D_i ⊆ inst(F_1) ∪ … ∪ inst(F_m) with F_j ∈ Fail(σ_i), and some
q ∈ inst(σ_i) \ ⋃_j inst(F_j) lies in no other inst(σ_l). Then q ∉ Acc_k(D,N) for every sound N (Theorem 3.1 with
h = ⋃ inst(F_j) ∪ ⋃_{l≠i} inst(σ_l)).

(b) *Sufficiency* (corrected after referee U2; the hypotheses now include **cross-separation**). Suppose:
- N cross-separates D (as in Theorem 3.2);
- N also *target-separates* D_i: it meets every template that covers a datum of D_i and is ≼-incomparable with σ_i;
- the instance sets are pairwise disjoint.

Then inst(σ_i) ⊆ Acc_k(D,N) iff D_i is not covered by ≤ m proper specializations of σ_i whose union misses an instance of
σ_i. If moreover no m members of Fail(σ_i) cover inst(σ_i) (*m-noncovering failure family*), then exactness for target i
⟺ D_i is not covered by m members of Fail(σ_i).

*Proof.* (a) As stated.

(b) Suppose exactness for i fails. By Theorem 3.2(a) (which needs cross-separation), some N-avoiding family of ≤ m
templates covers D_i and misses some q ∈ inst(σ_i). None of its members is ≽ σ_i. By target-separation, every member that
covers a D_i-datum is a proper specialization T_j. So D_i is covered by ≤ m proper specializations whose union misses q.
Each block X_j = D_i ∩ inst(T_j) is covered by T_j ⋡ σ_i, so X_j is not an anchor and lies in inst(F_j) for some
F_j ∈ Fail(σ_i). Hence D_i is covered by m members of Fail.

Conversely, if such a cover by specializations exists, Theorem 3.2(b) applies, using disjointness. If
D_i ⊆ inst(F_1) ∪ … ∪ inst(F_m) with F_j ∈ Fail(σ_i), the m-noncovering property gives q ∈ inst(σ_i) outside the union, and
(a) applies. ∎

*The v1 caveat is withdrawn (referee U2).* v1 claimed that Plotkin's failure family is m-noncovering for every m, because
parameters are infinitely many names. That is true only if renamed copies count as different sentences. In closure-normal
form they do not (§1), and the head classes are finite (Prop 3.4). The m-noncovering hypothesis of Cor 3.3(b) therefore
holds only for m below the number of head classes. Beyond that, the threshold needs a second-level analysis: Props 3.5 and
3.6 for one-variable instance schemas, and open for T_ind and in general (§10).

**Proposition 3.4 (finitely many head classes; proved; computed u12(a)).** Let σ = φ(z) be a DT° template whose only
metavariable is a 0-ary term metavariable z occurring in φ. Let F be the function symbols of the language (constants
included) and c_1,…,c_p the parameters of φ. Sentences are taken up to bijective renaming of parameters.

Every closed term t (parameters allowed) has exactly one *head class* head(t) ∈ F ∪ {c_1,…,c_p} ∪ {ν}, where ν stands for
"a parameter other than the c_j". Put:
- σ_f := φ(f(u_1,…,u_r)) for f ∈ F of arity r (fresh 0-ary u's);
- σ_{c_j} := φ(c_j);
- σ_ν := φ(b) for a parameter b not in φ.

Then:
(a) inst(σ) = ⋃_g inst(σ_g), over the h = |F| + p + 1 head classes: 5 + p for {0, S, +, ·}. Each σ_g ≼ σ.
(b) No σ_g is redundant: the head class of the z-value is invariant under the renamings that relate two instances of φ, so
σ_g covers only instances whose z-value has class g.

*Proof.*
(a) Take an instance [φ(t)].
- If t = f(t̄), then φ(t) = σ_f[ū := t̄].
- If t = c_j, then φ(t) = σ_{c_j}.
- If t is a parameter b′ ∉ {c_j}, the renaming that swaps b and b′ and fixes every other parameter maps φ(b) to φ(b′);
  φ contains neither name. So [φ(b′)] = [φ(b)] ∈ inst(σ_ν).

(b) Suppose a renaming π maps φ(t) to φ(t′).
- At the rigid occurrences of each c_j in φ, π(c_j) = c_j. So π fixes the c_j.
- π also maps non-c parameters to non-c parameters.
- At the position of z it maps t to t′, so head(t) = head(t′). ∎

So the head-class failure family covers all of inst(σ) with h members. The same holds for first-order patterns with several
variables: the head specializations of any one variable already cover. For T_ind the eight root specializations cover Ind.
*Computed (u12(a)):* the 5 head-class templates of z+0=z (p = 0) and the 6 of a1+z=z+a1 (p = 1) cover 2000/2000 random
canonical instances each, and each template is needed.

**Proposition 3.5 (threshold for one-variable instance schemas when m ≤ h; proved; computed u12(b)).** Hypotheses:
- (H1) σ_i = φ(z) with φ quantifier-free and parameter-free, z a 0-ary term metavariable occurring in φ;
- (H2) every datum of D_i has a z-value with at most one parameter (e.g. numeral instances and instances at one free
  variable). Let T be the set of z-values with the parameter renamed a;
- (H3) cross-separation as in Theorem 3.2, pairwise disjoint instance sets, every D_j nonempty, m = k − k′ + 1.

Let cl(T) be the set of head classes occurring in T, and h = |F| + 1 the number of classes. Then:
(a) If m < |cl(T)|, then inst(σ_i) ⊆ Acc_k(D,N).
(b) If some class is missing from T, then inst(σ_i) ⊆ Acc_k(D,N) ⟺ m < |cl(T)|.
(c) If cl(T) contains all h classes and m = h, then inst(σ_i) ⊆ Acc_k(D,N) ⟺ for every f ∈ F of arity r ≥ 1, the block
T_f = {t ∈ T : head(t) = f} has Plotkin lgg f(x_1,…,x_r) with pairwise distinct variables. Equivalently, Plotkin's
(R)+(D) holds for T_f: each argument column contains two terms with different heads (under (H2) every parameter is a, so
parameters count as one head), and no two argument columns are equal.

*Proof.*

Step 0 (least covering template). Let B ⊆ D_i be nonempty with z-values {t_b}. We claim every T ∈ Cov(B) has
inst(T) ⊇ inst(φ(lgg{t_b})), the lgg taken with the parameter a treated as a constant.
- The data are quantifier-free, so T has no binder in its rigid part. No bound variable is ever in scope, so every
  metavariable is 0-ary: T is a first-order pattern.
- T covers each [φ(t_b)] through some representative φ(t_b[n_b/a]) (φ is parameter-free).
- By Plotkin's theorem (known), T ≽ lgg{φ(t_b[n_b/a])} = φ(G) with G := lgg{t_b[n_b/a]}. This uses that lgg commutes with
  the parameter-free context φ: rigid positions carry constant tuples, which receive no variable, and the z-tuples receive
  the same variable.
- If all n_b equal some n, then G = lgg{t_b}[n/a], which is equivalent up to renaming.
- Otherwise G has no rigid parameter. Indeed, a rigid parameter n at position q would mean t_b|_q = a and n_b = n for all
  b. Then G ≽ lgg{t_b} syntactically:
  - G's rigid symbols are function symbols at positions where all t_b agree;
  - two variable positions of G that carry the same tuple (t_b[n_b/a]|_q)_b also carry the same tuple (t_b|_q)_b (apply
    the inverse renamings), so mapping each variable to the corresponding subterm of lgg{t_b} is well defined and turns G
    into lgg{t_b}.
- So inst(T) ⊇ inst(φ(G)) ⊇ inst(φ(lgg{t_b})), and φ(lgg{t_b}) is the least element of Cov(B). It is ≼ σ_i, hence sound
  and N-avoiding.

Step 1 (reduction). By Theorem 3.2(a),(c), exactness for i holds iff every N-avoiding family of ≤ m templates covering D_i
has union ⊇ inst(σ_i). Given such a family, partition D_i by first covering member and apply Step 0. So exactness holds
iff for every partition π of D_i into ≤ m blocks, ⋃_{B∈π} inst(φ(lgg T_B)) = inst(σ_i). Because z occurs in the
parameter-free φ, [φ(t)] determines t up to renaming. So this is equivalent to: every closed term is, up to renaming, an
instance of some lgg T_B. We write this as ⋃_{B∈π} inst(lgg T_B) = G_cl, with G_cl the closed terms modulo renaming.

Step 2 (mixed blocks). A block containing two terms of different head classes has lgg a variable, which covers G_cl. So
a failing partition is head-pure, and a head-pure partition has ≥ |cl(T)| blocks. This proves (a).

Step 3 (a missing class). If a class g is missing from T, the head partition (|cl(T)| blocks) is head-pure. Each of its
lggs is a ground constant or a parameter, or has a head in cl(T). So no term of class g is covered, and the head partition
fails. With (a) this proves (b).

Step 4 (m = h). If all h classes are present and m = h, the only head-pure partition with ≤ h blocks is the head
partition. Its union covers G_cl iff each class block covers its whole class.
- A constant class (a 0-ary f, or ν) consists of one term, which its block's lgg covers.
- For f of arity r ≥ 1, inst(lgg T_f) ⊇ f(G_cl^r) iff lgg T_f = f(x_1,…,x_r) with distinct variables:
  - if argument j of the lgg is not a variable, terms with another head there are missed;
  - if arguments j ≠ l share a variable, terms with different subterms there are missed.
- Plotkin's construction gives a variable in argument j iff column j contains two different heads, and the same variable
  in two arguments iff the two columns are equal tuples. ∎

*Computed (u12(b)):* for φ(z) = (z+0=z) and 60 random data sets (z-values from pools with at most one parameter, as (H2)
requires; all 5 classes present, sometimes one dropped), exactness was tested by brute force:
- all partitions into ≤ 5 blocks;
- `mincov` for each block (always one template here, as Step 0 predicts);
- coverage of all 608 canonical instances with z of depth ≤ 2. This test set is decisive, since every failure
in Step 4 is witnessed at depth ≤ 2. The result agrees with criterion (c) in 60/60 cases (18 exact). With m = |cl(T)| − 1
slots the target was exact in 60/60, as (a) says.

**Proposition 3.6 (closed form for unary signatures; proved; computed u12(c)).** Assume (H1)–(H3), with the function
symbols a finite set C of constants and one unary S (e.g. 0, S). (H2) is then automatic, since every term S^j b has at most
one parameter. So h = |C| + 2 (the constants, ν, and S). Define:
- T_0 := T and T_{j+1} := {u : Su ∈ T_j};
- r := the least j with |cl(T_j)| < h (it exists, since T is finite);
- κ(T) := the least number of blocks of a partition of T whose lggs fail to cover G_cl.

Then κ(T) = (h − 1)·r + |cl(T_r)|, and inst(σ_i) ⊆ Acc_k(D,N) ⟺ m < κ(T).

*Proof.* By Steps 1–3 of Prop 3.5, failing partitions are head-pure.
- If r = 0 (a class is missing), κ(T) = |cl(T_0)|.
- If all classes are present, each of the h − 1 constant classes forms its own block in a head-pure partition, and the
  remaining blocks partition the S-class. Since lgg(S-block) = S(lgg of the arguments) and inst(S s) = S(inst s), the
  S-blocks cover S(G_cl) iff the corresponding blocks of T_1 cover G_cl. Hence κ(T) = (h − 1) + κ(T_1).

Induction on r. ∎

*Computed (u12(c)):* the formula agrees with brute force (all partitions; exact coverage test for unary patterns) on all
254 term sets of size ≤ 7 over {S^j b : j ≤ 3, b ∈ {0, ν}} (h = 3), and on all 2509 sets of size ≤ 6 over
{S^j b : j ≤ 3, b ∈ {0, c, ν}} with c a second constant (h = 4).

*Reading (Q1 with spare slots).* Numeral-only data never contain the class ν, so κ = |cl(T)| ≤ 2.
- With one spare slot (m = 2), the cautious k-union learner *never* accepts the universal axiom from numeral instances. The
  sound split {φ(0)} ∪ {φ(S u)} misses φ(a).
- With instances at a free variable, exactness at m needs all classes at levels 0, …, r−1, with (h−1)r + |cl(T_r)| > m.
  This means about m/(h−1) levels of diversity.

DTRC never splits a coherent set (§5), so on these data it behaves like k = k′.

---------------------------------------------------------------------------------------------------------------------------

## 4. Slot accounting: the general threshold, without or with negatives

**Theorem 4.1 (slot accounting; proved).** Fix a target i, a bound k, data D ⊆ R* and a sound N. Write D̄_i = D \ D_i.
Assume

 **(Abs)** every N-avoiding template that covers a datum of D_i and a datum of D̄_i satisfies inst(T) ⊇ inst(σ_i).

Let c_i be the least number of N-avoiding templates T with inst(T) ⊉ inst(σ_i) whose instance sets cover D̄_i.

(a) If every family of at most k − c_i N-avoiding templates covering D_i has union ⊇ inst(σ_i), then
inst(σ_i) ⊆ Acc_k(D,N).

(b) If some family F of at most k − c_i N-avoiding templates covers D_i and misses q ∈ inst(σ_i), and some optimal cover G
(|G| = c_i) of D̄_i misses q too, then q ∉ Acc_k(D,N).

*Proof.* (a) Let h ∈ VS_k(D,N) with slots τ_l. If some slot contains inst(σ_i), we are done. Otherwise no slot is *mixed*
(covers data of both D_i and D̄_i), by (Abs).
1. The slots covering D̄_i-data then form an N-avoiding cover of D̄_i by templates not containing inst(σ_i), so there are at
   least c_i of them.
2. The at most k − c_i remaining slots cover D_i. By hypothesis their union contains inst(σ_i).

(b) ⋃inst(F ∪ G) ∈ VS_k(D,N) and misses q. ∎ (The degenerate case k ≤ c_i is covered: some slot of every h ∈ VS must then
contain inst(σ_i). Checked by the referee.)

**Corollary 4.2 (special cases).**

(1) *Prior PA result, Sub-encoded steps* (prior pa-untagged, refereed). The data are ground premise-free steps G plus
σ_ind. A slot mixing a G-step and an induction step is a bare metavariable, so (Abs) holds. lgg(G) = st(∀x Z) covers no
induction step, so c = 1, and the threshold is "D_ind not covered by k−1 failure sets".

(2) *Cross-separation* (Theorem 3.2). (Abs) holds vacuously. With disjoint instance sets, c_i = k′−1: each N-avoiding
template covers data of at most one other target, and the σ_l themselves form a cover. This gives m = k−k′+1.

(3) *Raw DT° PA* (sentences in closure-normal form; computed, u2). (Abs) holds: every minimal covering template of a
Q-axiom and an induction instance contains T_ind.
- The template is F0 when the Q-axiom's root is not →, and F0→F1 for Q2 and Q7.
- This was checked for all 7 axioms × 4 motives. It is also proved: the two antecedent and the two consequent contents
  differ at their heads and are closed, so the only minimal template is F0 or F0→F1. This holds for every motive (referee
  §3.8).

The non-absorbing cover number of {Q1,…,Q7} is:
- **c = 4 on positive data**: {Q3,Q4,Q5,Q6} share t0=t1. Q1, Q2 and Q7 must be alone, since any template covering two of
  them is F0 or F0→F1, both absorbing.
- **c = 7 with refutation**, and already with the three negatives {0=S0, (a1+0)=0, (a1·0)=S0}.

So at k = k′ = 8 on positive data induction gets 4 slots. By prior C3, a block of induction data is coverable by a template
not containing Ind iff it is root-homogeneous or all vacuous. So an unseen-connective induction is accepted iff
χ(D_ind) > k − 4, where χ is the least number of root-homogeneous or all-vacuous blocks. In other words, the corpus needs
≥ 5 distinct main connectives. With the three negatives, induction gets k − 7 = 1 slot and the tagged anchor (R)+(N)
suffices.

*Computed check (u2).* The test covers 4 ground subsets × 2 settings (with/without refutation) × 3 unseen-connective
queries. In each case it computes the exact version-space quantity κ(q), the least number of "ok" blocks covering D, where a
block is ok if some (unrefuted) minimal covering template misses q, so that q ∉ Acc_k ⟺ κ(q) ≤ k. It equals c + χ in
**24/24 cases**. *Caveat (referee U3-comp):* given (Abs) and prior C3, κ = c + χ holds by construction of the dynamic
program, which enumerates exactly the partitions of Lemma 1.2. The agreement is therefore a consistency check of the
implementation of Lemma 1.2 and of `mincov`, not independent evidence for Theorem 4.1.

**Proposition 4.3 (a bound is necessary; proved; Gold 1967 known).** Let H_∞ = ⋃_k H_k. For every finite D ⊆ R* and every
sound N, Acc_∞(D,N) = D. Moreover, no learner, however it uses a sound oracle, identifies H_∞ in the limit from text.

*Proof.* D is a finite union of ground templates, so D ∈ H_∞, and D ∩ N = ∅ (D ⊆ R* ⊆ Tr). So Acc_∞ ⊆ D, and ⊇ is trivial.

For the second claim, take a non-ground true σ: the class contains inst(σ) and all its finite subsets, all ⊆ Tr. The
oracle's answers are a fixed function of the query: (OS) gives the same answers for every target inside Tr
(lem:twotier:onesided(c)). So the oracle adds no information distinguishing these targets. With a fixed oracle the learner
is a function of the text, and Gold's locking-sequence argument for superfinite classes applies; it does not need
computability. ∎

*Reading.* Negatives cannot replace a bound: they refute false sentences, and every finite set of true data is itself a
consistent hypothesis. What negatives do is remove *over-general lumps*. That turns the slot budget of the k-union learner
into the tagged budget (Theorems 2.1, 4.1). What a bound does is forbid *splits*. DTRC (next section) replaces the bound by
a different assumption, refutation separation.

---------------------------------------------------------------------------------------------------------------------------

## 5. DTRC: Determinate Templates with Refutation Clustering

### 5.1 Definition

Fix a refutation budget d. A finite X ⊆ S is **d-coherent** if some T ∈ Min(X) is not d-refuted. By (W) this is
equivalent to "some T ∈ Cov(X) is not d-refuted": every covering template lies above a minimal one, and a template above a
d-refuted one is d-refuted, since its instance set is larger.

**Algorithm DTRC_d.**
1. *Normalize* each datum to closure-normal form (parameters canonically named, bound variables de Bruijn).
2. *Agglomerate.* Start from singleton clusters (duplicates merged, multiplicities kept). Repeatedly choose, by a *merge
   policy*, two current clusters C ≠ C′ with C ∪ C′ d-coherent, and replace them by C ∪ C′. Stop when no pair of clusters
   has a d-coherent union. Policies used:
   - *online*: process the data in order, put each datum into the first cluster it is coherent with, else open a new
     cluster; then merge clusters pairwise to a fixpoint;
   - *most-specific-first*: among coherent pairs, merge the one whose merged minimal templates have the smallest instance
     sets.
3. *Verify per cluster.* For a final cluster C let Min_d^+(C) = {T ∈ Min(C) : T not d-refuted} and
   Acc_d(C) = ⋂_{T ∈ Min_d^+(C)} inst(T). Set Acc_d(C) := ∅ if Min_d^+(C) = ∅ (an incoherent singleton).
4. *Assert* Acc_d = ⋃_C Acc_d(C). (Optional robust step, §5.7: assert only clusters of multiplicity ≥ s > e and use the
   e-trimmed verifier.)

Acc_d(C) is the cautious H_1-verifier of the cluster with negatives Ref_d. Every Ref_d-avoiding covering template is above
a Ref_d-avoiding minimal one, so ⋂{inst(T) : T ∈ Cov(C), inst(T) ∩ Ref_d = ∅} = Acc_d(C). With (W) and (Dec) every step is
computable.

**Lemma 5.1 (monotonicity; proved).** d-coherence is downward closed (Y ⊆ X with X d-coherent ⇒ Y d-coherent) and antitone
in d.

*Proof.* A non-d-refuted T ∈ Cov(X) is in Cov(Y). And Ref_d ⊆ Ref_{d+1}. ∎

### 5.2 Separation: the main theorem

**Definition (refutation separation).**
- Σ* is *d-separated on D* (RS_d(D)) if every T ∈ DT° covering a datum of D_i and a datum of D_j (i ≠ j) is d-refuted.
- It is *globally d-separated* (RS_d) if every T covering an instance of σ_i and an instance of σ_j (i ≠ j) is d-refuted.
  Then RS_d(D) holds for every D ⊆ R*, and the inst(σ_i) are pairwise disjoint.

By (W), RS_d(D) ⟺ every T ∈ Min({a,b}) is d-refuted for every cross pair (a,b) ∈ D_i × D_j. This is a finite check.

**Theorem 5.2 (DTRC; proved under (W), (OS), (Dec)).**

(i) *Within-target merges are never refuted.* If X ⊆ inst(σ_i), then X is d-coherent for every d. Indeed, some
T₀ ∈ Min(X) has inst(T₀) ⊆ inst(σ_i) and is never refuted.

(ii) *Separation recovers the labels.* If RS_d(D) holds and every D_i is nonempty, then for every merge policy the final
clustering is {D_1, …, D_k′} (as sets).

(iii) *Soundness at all times, exactness from anchors.* Under RS_d(D), Acc_d ⊆ R*, and Acc_d = R* as soon as each D_i
contains an anchor of σ_i.

(iv) *Rates.* Under global RS_d and i.i.d. data, P[Acc_d ≠ R*] ≤ Σ_i P[D_i contains no anchor]. This is the failure
probability of the *tagged* per-rule learner.
- For first-order pattern targets whose DT° anchors are Plotkin's (R)+(D) (hypothesis (A)), it is
  ≤ Σ_i c_i(1−π_iρ_i)^N (thm:imitation:coupon).
- For T_ind it is Σ_f p_f^N + (1−q)^N − Σ_f r_f^N given n induction samples (prior C5(b)), averaged over n ~ Bin(N, π_ind).

(v) *Number of tests.* Let n be the number of distinct data. With caching of pair answers, the pairwise fixpoint makes
O(n²) **coherence tests**:
- n(n−1)/2 initial pairs;
- at most n − 1 merges, each invalidating the cached answers of ≤ n pairs.

Under RS_d(D) the online policy makes at most n·k′ + k′(k′−1)/2 tests: ≤ k′ per datum, plus the final pairwise pass over
the k′ pure clusters. The cost of one test is a separate matter (Prop 5.10).

*Proof.* (i) By (W′), some T₀ ∈ Min(X) satisfies inst(T₀) ⊆ inst(σ_i) ⊆ R* ⊆ Tr, so inst(T₀) ∩ Ref_d = ∅ by (OS).

(ii) Call a cluster *pure* if it lies inside one D_i. Initially all clusters are pure.
- If C ⊆ D_i and C′ ⊆ D_j are pure with i ≠ j, every T ∈ Cov(C ∪ C′) covers a datum of D_i and one of D_j. So T is
  d-refuted by RS_d(D), C ∪ C′ is not d-coherent, and the union is never formed. All clusters stay pure.
- At termination, two final clusters inside the same D_i would have a d-coherent union by (i), contradicting termination.
- Hence each nonempty D_i is exactly one final cluster.

(iii) Consider the final cluster D_i. The T₀ of (i) is in Min_d^+(D_i), so Acc_d(D_i) ⊆ inst(T₀) ⊆ inst(σ_i). If
A_i ⊆ D_i is an anchor, every T ∈ Min(D_i) covers A_i, hence T ≽ σ_i. So Acc_d(D_i) ⊇ inst(σ_i). (The index set
Min_d^+(D_i) is nonempty by (i).)

(iv) Under global RS_d, (ii)–(iii) hold for every D. So DTRC fails to be exact only if some D_i lacks an anchor, which is
the same event as for the tagged learner given the labels. Average the tagged bound over the binomial count of target-i
samples.

(v) A pair answer depends only on the two clusters. After merging C and C′, only pairs involving the new cluster need
retesting (≤ n). For the online policy under RS_d, induction on the data shows there is at most one cluster per target at
all times. A datum of target i joins the first coherent cluster; cross unions are incoherent and the cluster of target i is
coherent with it by (i). So each datum is tested against ≤ k′ clusters, and the final pass tests the k′(k′−1)/2 pairs of
pure clusters, all incoherent. ∎

*Reading.* Under separation, refutation does the job that the citation (tag) does in tagged data: it tells the learner
which instances belong together. Within each recovered cluster the learner is the tagged cautious learner, so everything
known about tagged rates and anchors transfers verbatim. DTRC needs no bound k: the number of targets is discovered.

**Remark 5.3 (relation to the k-union learner; proved).**
- The k-union learner with self-generated negatives (Corollary 2.2) is target-sound at all times whenever k ≥ k′, *with or
  without separation* (Lemma 1.1).
- DTRC is target-sound only under separation (Theorem 5.4 shows how it fails otherwise), but it needs no k.
- Under RS_d(D), anchors in every D_i and k = k′, both accept exactly R*.
- When k is known, a practical combination is to accept q iff both accept q. This is target-sound whenever k ≥ k′, and
  exact when DTRC is exact and k = k′ (Theorem 2.1, since RS_d(D) implies (X) for N(D,d)).

**Proposition 5.10 (cost of one coherence test; proved, using track-single results as hypotheses; computed).**

(a) After Min(X) is computed, a d-coherence test needs at most |Min(X)| d-refutation checks.

(b) *Quantifier-free X.* Every covering template is a first-order pattern. The data have no binders, so neither does the
rigid part of a covering template; no bound variable is in scope, so pattern occurrences, and hence all metavariables, are
0-ary. Then Min(X) = {lgg(X)}: Plotkin's lgg with 0-ary term and formula variables is ≼ every covering pattern (known). It
is computed in time polynomial (essentially linear) in Σ_{x∈X}|x|, so one test is one lgg plus one refutation check. This
covers all Q–Q and instance-schema tests of PA.

(c) *A cluster containing an anchor.* If A ⊆ X ⊆ inst(σ) and A is an anchor of σ, then Min(X) = {σ}: σ covers X, and every
covering template covers A, hence is ≽ σ. Track single's Prop G.3 / Cor G.4 (hypothesis) computes σ from X in polynomial
time. Under separation, once a cluster contains an anchor, every within-target test C ∪ {d} is therefore polynomial.

(d) *Worst case.* |Min(X)| can be 4^n for |X| = 2 and size O(n) (track single, Prop G.2). So a test that enumerates
Min(X) is exponential in the worst case. Track single's polynomial feature verifier decides membership in
Acc(X) = ⋂Cov(X), not the existence of an unrefuted minimal template.
- *Single negative.* For one known negative n, "some T ∈ Min(X) avoids n" ⟺ n ∉ Acc(X), which is decidable in polynomial
  time by track single's Theorem C. Proof: if n ∉ ⋂Cov(X), some T ∈ Cov(X) misses n, and by (W) so does some T₀ ∈ Min(X)
  below it. The converse is trivial.
- *Several negatives.* For a set N of negatives the reduction fails, because different minimal templates can avoid
  different negatives. The complexity of "∃T ∈ Min(X) with inst(T) ∩ N = ∅" is **open**.

(e) *Computed.* |Min(X)| = 1 in every coherence test of the PA and ZF runs (|Min| was recorded there):
- PA (u3): 63 + 102 + 98 tests;
- ZF (u5): 164 + 131 + 147 tests.

Each test was therefore one `mincov` call plus one refutation lookup. The worst case is visible only in low-diversity
induction pairs (u0: |Min| up to 27).

### 5.3 Without separation: residual merges

**Theorem 5.4 (soundness relative to a residue; proved).** Call a final cluster *mixed* if it contains data of two or more
targets. Define the depth-d residue of D:

  Res_d(D) = ⋃{ inst(T) : T ∈ Min(X) not d-refuted, X ⊆ D d-coherent and mixed }.

(a) Acc_d ⊆ R* ∪ Res_d(D). More precisely, pure final clusters contribute ⊆ R* (as in 5.2(iii)), and a mixed final
cluster C contributes ⊆ inst(T) for every T ∈ Min_d^+(C).

(b) If every mixed final cluster has some *truth-sound* T ∈ Min_d^+(C) (inst(T) ⊆ Tr), then Acc_d ⊆ Tr. The output is then
truth-sound, though not target-sound: it accepts true sentences outside R*. Such merges are called *sound merges*.

(c) If the only non-refuted minimal templates of a mixed cluster have false instances, they are *unrefuted unsound merges*,
and Acc_d is sound only relative to Res_d(D). Res_d(D) decreases in d, and Res_∞(D) consists of templates with no
refutable instance at all.

(d) Exactness can fail even on **clean** data D ⊆ R* with an anchor in every D_i and pairwise disjoint instance sets. A
sound cross merge can absorb part of an anchor, leaving the rest of D_i without one (fragmentation), and the outcome depends
on the merge policy.

*Example (computed, u9 Example B; referee U6).* Let σ₁ = (t+0=t) (Q3 instance schema), g = (0+S0=S0) a ground target, and
D = {0+0=0, S0+0=S0} ∪ {g}. The first two data are an anchor of σ₁ (heads 0 and S, Lemma 5.5), and inst(σ₁) ∌ g.
- Order (0+0=0, S0+0=S0, g): clusters {0+0=0, S0+0=S0} (template t+0=t) and {g}; exact.
- Order (g, 0+0=0, S0+0=S0): {g, 0+0=0} merges through the *true* template 0+t=t (a sound merge). S0+0=S0 cannot join, since
  the lgg t0+t1=t2 is refuted by 0+0=S0. The result is clusters {g, 0+0=0} and {S0+0=S0}: a1+0=a1 is rejected, while the
  true non-target 0+a1=a1 is accepted.
- The referee's variant with overlapping instance sets (σ₂ = 0+t=t; u9 Example A) gives the same picture in 2 of 3 orders.

*Proof.* (a) A pure cluster C ⊆ D_i contributes ⊆ inst(σ_i) by (W′). A mixed cluster contributes ⊆ inst(T) for its
non-refuted minimal templates, which belong to Res_d(D) (take X = C).
(b) Acc_d(C) ⊆ inst(T) ⊆ Tr.
(c) By definition.
(d) By the example. In the second order, {g, 0+0=0} is coherent because its only minimal template 0+t=t is true, hence
never refuted. {g, 0+0=0, S0+0=S0} has the single minimal template t0+t1=t2, which is refuted. ∎

**Remark 5.11 (without separation, anchors do not suffice for any learner; proved).** Consider two practices:
- P = {t+0=t, 0+S0=S0};
- P′ = {0+t=t, S0+0=S0}.

Both are valid (all instances true). The data set D = {0+0=0, S0+0=S0, 0+S0=S0} lies in R*_P ∩ R*_P′ and contains anchors
for both:
- for P: {0+0=0, S0+0=S0} and {0+S0=S0};
- for P′: {0+0=0, 0+S0=S0} and {S0+0=S0}.

The oracle is target-blind, so any learner (computable or not) gives the same output on D under P and P′. To be exact for P
it must accept a1+0=a1 ∉ R*_P′; to be target-sound for P′ it must reject it. So no learner is both exact for P and
target-sound for P′ on D. This ambiguity is resolved only by data that separate the practices: e.g. SS0+0=SS0, which lies
in R*_P but not in R*_P′.

Separation excludes such ambiguity (Theorem 5.2). This explains why the k′-union learner with self-generated negatives is
also non-exact on D (u9: it rejects a1+0=a1 and SS0+0=SS0, and it is order-independent). Condition (X) of Theorem 2.1 fails
here: the true template 0+t=t covers anchor data of both targets of P.

Three kinds of residual merge should be distinguished (examples in §7):
- *Target-sound merges*: some T ∈ Min_d^+(C) lies below a single σ_i. Example: redundant targets, such as an axiom that is
  an instance of another target schema. Harmless.
- *Sound merges*: T is truth-sound but not below any target. **Learning ∀xφ from instances is exactly this case** (§5.4).
- *Unsound unrefuted merges*: K₀-like templates and the weak-Union/Power universal-set template (§7.3). In general, these
  are templates whose false instances are all consistent with the designated truths (Σ₁/Π₂-type residues of the parent
  report). Prop 5.13 shows that in arithmetic they need quantifiers in the template.

### 5.4 Learning ∀xφ from its instances

**Lemma 5.5 (two-point anchors for one-variable patterns; proved).** Let φ(z) be a template whose only metavariable is a
0-ary metavariable z (term or formula sort) occurring at least once. Let t₁, t₂ be closed instantiations (terms with
parameters, resp. formulas) whose head symbols differ. Then {φ(t₁), φ(t₂)} is an anchor for φ(z) in DT°: every
T ∈ Cov({φ(t₁), φ(t₂)}) has inst(T) ⊇ inst(φ(z)). Consequently φ(z) is the least covering template (Min = {φ(z)} up to
equivalence) of any set of instances containing two with different heads.

*Proof.*
1. *Two-point identity.* Let G(z), K(z) be expressions in which z occurs only as a leaf, with G(t₁) = K(t₁) and
   G(t₂) = K(t₂). Then G = K, by induction on G and K:
   - if G = z and K ≠ z, then K has a rigid head h, and K(t_j) = t_j forces h = head(t₁) and h = head(t₂), a
     contradiction; symmetrically for K = z;
   - if neither is z, their heads agree (compare at t₁), and we recurse into the arguments. Binders are included: z is not
     a bound variable.
2. *Skeleton.* The two data agree everywhere except at and below the z-positions of φ, where the heads differ. By the
   rigid-prefix lemma (prior C2(a)), the rigid skeleton of T avoids the z-positions and everything below them.
3. *Bodies.* For each metavariable M of T choose a pattern occurrence M(ȳ) at rigid position p. Given any instantiation t
   of z, put θ_t(M) := λȳ.(φ(t)|_p) (abstracting ȳ). This is a legal body: t is closed, so the bound variables free in
   φ(t)|_p are those free in φ(t₁)|_p, and these are among ȳ because T covers φ(t₁).
4. *Every occurrence fits.* For an occurrence M(ū) at rigid position p′ put G(z) := (λȳ.φ(z)|_p)(ū) and K(z) := φ(z)|_{p′}.
   G contains z only as a leaf, since ū is metavariable-free. T covers both data, and substituting the closed t_j commutes
   with abstraction and plugging, so G(t_j) = K(t_j) for j = 1, 2. By step 1, G = K, so G(t) = K(t).

Together with step 2, Tθ_t = φ(t). Hence inst(T) ⊇ inst(φ(z)). ∎

This agrees with track single's anchor theorem: for a 0-ary metavariable whose two values differ in head, their (U)
"no coincidence" condition holds automatically (referee). For first-order patterns with several metavariables the DT°
anchor condition is Plotkin's (R)+(D) (track single Cor D.1, used here as hypothesis (A)). The computed check u1(b2) agrees
on the instance schemas of Q's axioms.

**Proposition 5.6 (∀xφ from instances; proved; corrected after referee U7).** Let φ(z) be as in Lemma 5.5 with z a term
metavariable. Let the data be closed instances D = {φ(t₁),…,φ(t_n)}, at least two with different heads. Regard each datum
as its own ground "target" (k′ = n).

(a) D is d-coherent iff φ(z) is not d-refuted.

(b) inst(φ(z)) contains φ(a) for a parameter a **fresh for φ** (not occurring in φ). In closure-normal form φ(a) *is the
sentence ∀xφ(x)*. So φ(z) is truth-sound iff ∀xφ(x) is true; instances with other terms then follow by ∀-elimination.

(c) If ∀xφ is true, every pair of data with different heads is a sound cross merge.
- RS fails, and DTRC puts D into one cluster under any policy, since all subsets are coherent.
- Acc_d ⊇ inst(φ(z)) ∋ ∀xφ: the axiom ∀xφ is learned from instances, and nothing false is accepted.
- Target-soundness relative to the n ground "targets" fails, as it must: the n instances and the axiom ∀xφ produce the
  same data and the same refutation answers (target-blindness, lem:twotier:onesided(c)).

(d) If ∀xφ is false and some instance of φ(z) is d-refuted, the merge is refused and DTRC keeps the instances apart. It may
still merge root-homogeneous subsets into an unrefuted specialization such as φ(S z).

(e) *When "never refuted" means "true".*
1. Suppose the oracle is **complete for false instances of φ(z) at unbounded depth**: every false instance lies in Ref_∞.
   Then φ(z) is never refuted ⟺ inst(φ(z)) ⊆ Tr ⟺ ∀xφ is true. This holds for **quantifier-free φ in arithmetic with
   R-Δ₀**: a false instance φ(t) with parameters is falsified by some numeral assignment and is refuted by numeral
   instantiation and closed evaluation (Prop 5.13 generalizes this).
2. It does **not** hold for R-Δ₀ and φ with quantifiers. R-Δ₀ verifies universals only through EUF + Diag(ℕ), so some false
   instances are never refuted (u8's wrong-base sentence, whose refutation needs Q1).
3. *Finite budget.* At a finite budget d, DTRC can merge instances of a false universal whose least counterexample lies
   beyond depth d. This is an instance of the residue Res_d (Theorem 5.4), and it disappears as d grows.
4. *Which structures.* Suppose the oracle refutes only closed (parameter-free) instances, by evaluation, and is complete on
   them. Then "no closed instance is in Ref_∞" means "φ(t) is true for every closed t".
   - In ℕ every element is the value of a closed term, so this implies ∀xφ. This is the ω-rule: sound in ℕ, not derivable
     (Q ⊢ 0+n̄=n̄ for each n, but Q ⊬ ∀x(0+x=x)).
   - In a structure that is not pointwise closed-term-definable it fails. In the ordered field ℝ with 0, 1, +, ·, every
     closed term denotes a natural number, so ¬(t·t = 1+1) holds for every closed t, while ∀x¬(x·x = 1+1) is false. The
     merged template ¬(z·z = 1+1) is then an **unsound unrefuted merge** for a closed-evaluation oracle. A decision
     procedure for RCF, which can refute the parameter instance, would refute it.

*Proof.* (a) Lemma 5.5: φ(z) is the least covering template.
(b) Closure-normal form; a must be fresh, so that φ(a) is not an instance with a special parameter.
(c) Follows from (a), (b) and Lemma 5.1. Target-blindness holds because the oracle is a fixed function of the query.
(d) Follows from (a).
(e) 1: by the definitions and Prop 5.13. 2: by the u8 example. 3: by Theorem 5.4. 4: the ℝ facts are elementary. ∎

**Proposition 5.13 (quantifier-free arithmetic templates have no unsound permanent residue; proved).** Let T be a DT°
template in the language of arithmetic with no binder in its rigid part, so all its metavariables are 0-ary term or formula
metavariables. Its formula metavariables may be instantiated by arbitrary closed formulas, including quantified ones. If T
has a false instance, then T has a false *quantifier-free* instance, and R-Δ₀ refutes that instance at some finite depth.
Hence, for R-Δ₀ at unbounded depth, every template of this kind in Res_∞ is truth-sound.

*Proof.* Let s = Tθ be false. Its universal closure is false in ℕ, so some assignment n̄ of numerals to the parameters of s
makes s[n̄] false. Define θ′ as follows:
- θ′(z) := θ(z) for term metavariables;
- for a formula metavariable F, θ′(F) := 0=0 if θ(F)[n̄] is true in ℕ, and 0=S0 otherwise.

Put s′ := Tθ′. It is quantifier-free, because T's rigid part, the term values and the formula values are. Moreover s′[n̄]
has the same truth value as s[n̄]. The rigid part is a Boolean combination of:
- equations between terms built from rigid symbols and the unchanged term values, and
- occurrences of formula metavariables, whose replacements have the same truth values at n̄.

So s′ is false. R-Δ₀ at depth ≥ max(n̄, |s′|) instantiates the parameters of s′ by n̄ (the parameters of s′ are among
those of s) and evaluates the resulting closed quantifier-free sentence, so s′ ∈ Ref_∞. ∎

*Reading.*
- The theorem is about depth ∞. At any finite d, quantifier-free templates can still be residual (least counterexample
  beyond d; Prop 5.6(e) 3).
- Unsound residues that persist at every depth come from templates whose rigid part contains quantifiers, such as K₀
  (§7.3(c)). In set theory, the universal-set schema (§7.3(b)) plays this role.
- This narrows, but does not settle, the open question of a *natural* permanent residue (§7.3(d), §10).

*Computed (u6).* Numeral instances of Q3, Q4, Q5 were treated as 12 separate ground targets.
- DTRC forms three clusters with templates (t0+0)=t0, (t0·0)=0 and (t0+St1)=S(t0+t1). It accepts (a1+0)=a1 (the axiom
  ∀x(x+0=x)), S⁷0+0=S⁷0, and the other two axioms.
- Instances of the *false* universal n·n = n (true for n = 0, 1): the merged template (t0·t0)=t0 is refuted by q1:=2, and
  the instances stay apart (2·2=2 is not accepted).
- Instances ¬(n·n = 2), n = 0,1,2: merged and unrefuted, and the universal ¬(a1·a1 = 2) is accepted (true in ℕ).

So the answer to Q1 in the untagged setting is **yes**: the same method learns ∀xφ from instances φ(t), and it does so by
a *sound merge*. What certifies it is not a derivation but the absence of a counterexample. That is truth-sound exactly in
term-generated structures such as ℕ, with an oracle complete on the instances (the ω-rule), and in general only relative to
the strength of the refutation oracle.

### 5.5 Depth relativization is necessary

The budget d is a real parameter: separation may appear only at a depth nobody can bound in advance.

**Theorem 5.7 (proved; adapts thm:twotier:depth; construction corrected after referee U8).** There is a uniformly computable
family of practices with the following property. Each practice is a finite set of DT° targets in the language of
arithmetic with a data law, and all use the same fixed sound oracle R-Δ₀ (§1). No computable learner achieves both of the
following, for every *valid* practice P in the family (valid: all target instances true) and some δ < ½:

(a) *soundness relative to the full-depth residue at all times*: P[∃t: Acc_t ⊄ R*_P ∪ Res_∞(P)] ≤ δ. Here Res_∞(P) is the
union of inst(T) over templates T that cover instances (in the support of the data law) of two distinct targets of P and
have no refutable instance;

(b) *eventual exactness on separated practices*: if P is separated at some finite depth and each target's data law gives an
anchor with positive probability, then P[∃t ∀t′ ≥ t: Acc_{t′} = R*_P] ≥ 1 − δ.

*Construction.* Use MRDP (Matiyasevich 1970, building on Davis–Putnam–Robinson 1961; known): there are polynomials
P(e, x̄), Q(e, x̄) with natural coefficients, x̄ = x_1…x_k, such that

  e ∈ K ⟺ ∃x̄ ∈ ℕ^k P(e,x̄) = Q(e,x̄),

where K is the halting set. Let P_e, Q_e be the terms obtained by substituting the numeral ē, and c(x̄) := x_1 + … + x_k.
Put

  H_e(z) := ∃x_1 … ∃x_k ( z = SS c(x̄) ∧ P_e(x̄) = Q_e(x̄) ),

a formula with a 0-ary term metavariable z under k binders (de Bruijn; z is closed, so there is no capture). Then:
- T_e := ¬H_e(z), A_e := ¬H_e(0), B_e := ¬H_e(S0), q_e := ¬H_e(SS0);
- practice P_e has one target, {T_e}; practice P′_e has two ground targets, {A_e, B_e};
- both use the data law uniform on {A_e, B_e}.

*Facts.*
1. A_e and B_e are true, since 0 ≠ SS u and S0 ≠ SS u for every u. So P′_e is always valid.
2. P_e is valid iff e ∉ K. The instances of T_e are ¬H_e(t) for closed terms t, including, in closure-normal form,
   ∀a¬H_e(a). They are all true iff no solution exists.
3. {A_e, B_e} is an anchor for T_e (Lemma 5.5: heads 0 and S differ, and z is the only metavariable). So every template
   covering A_e and B_e contains inst(T_e).
4. If e ∈ K with solution x̄*, put c̄ := the numeral of 2 + Σx*_i. The instance ¬H_e(c̄) is false. R-Δ₀ refutes it at
   depth d_e := max(|¬H_e(c̄)|, max_i x*_i): refuting ¬ψ means verifying ψ, and ψ = ∃x̄(…) is verified by the witnesses x̄*
   and closed evaluation of the two atoms. No universal needs to be verified, which removes the gap the referee found in
   the v1 Kleene-T construction. By fact 3, every cross template of P′_e is then d_e-refuted: P′_e is separated at depth d_e
   and Res_∞(P′_e) = ∅.
5. If e ∉ K, T_e is truth-sound and never refuted, and Res_∞(P′_e) ⊇ inst(T_e) ∋ q_e. P′_e is not separated at any depth,
   so (b) asks nothing of it.
6. P_e (e ∉ K) has a single target. It is separated (vacuously) at depth 0, and its data contain the anchor {A_e, B_e}
   with positive probability.

*Reduction.* Let S = {e : ∃t P[the learner accepts q_e at time t] > ½}.
- If e ∉ K, (b) for P_e gives eventual acceptance of q_e ∈ inst(T_e) with probability ≥ 1 − δ > ½. By continuity over the
  increasing events "accepted by time t", there is a single time t with probability > ½. So e ∈ S.
- If e ∈ K, (a) for P′_e (R* = {A_e, B_e}, Res_∞ = ∅, q_e ∉ R*) gives P[q_e ever accepted] ≤ δ < ½. So e ∉ S.

Hence S = ω \ K. The learner, the data law and the oracle are computable uniformly in e, and P_e, P′_e have the same data
law and oracle, so P[accept q_e by time t] is computable from (e, t). (The oracle Ref_d, the sentences of size ≤ d refuted
by R-Δ₀ with numeral bounds d, is decidable uniformly in d.) So S is Σ₁. This argument also covers randomized learners.
But the complement of the halting set is not Σ₁. ∎

*Variant.* Alternatively, keep the v1 Kleene-T construction (H_e Δ₀) and take the oracle to be full evaluation of closed
Δ₀ sentences with bounded quantifiers as primitives at depth d. That oracle is sound and decidable per depth, and the same
proof goes through.

*Reading.* (a) is satisfiable on P′_e with e ∉ K, where accepting q_e is allowed because q_e is in the residue. So the
obstruction is not information-theoretic: it is the Π₁-completeness of "this cross merge is never refuted". DTRC with a
depth schedule d_t → ∞:
- meets (b);
- is sound relative to Res_{d_t} at time t, and relative to Res_∞ in the limit;
- makes finitely many changes on every separated practice.

This is the TTL form of soundness of the parent report, which by this theorem cannot be improved.

### 5.6 Whole-cluster tests versus pairwise tests

**Proposition 5.8 (proved; computed).**

(a) d-coherence is downward closed but not transitive: there are a, b, c with {a,b} and {a,c} coherent and {b,c}, {a,b,c}
incoherent.

(b) Every cluster built by DTRC is d-coherent at all times (invariant), with one trivial exception noted by the referee: a
refutable singleton {m}, m ∈ Ref_d, is an incoherent cluster from the start and contributes nothing. So every asserted
cluster has a non-refuted minimal template. Single linkage on the pairwise-coherence graph (transitive closure) can build
clusters with no non-refuted minimal template at all.

(c) Under RS_d(D) the coherent subsets of D are exactly the subsets of the D_i (Theorem 5.2(i) and RS). So the pairwise
relation is the equivalence "same target", and single linkage, complete linkage and DTRC all return {D_i}. The difference
matters only without separation.

(d) Without separation, DTRC's result depends on the merge policy: it returns *some* maximal partition into coherent
blocks.

*Example (computed, u6(C)).* Take a = 0+0=0, b = S0+0=S0, c = 0+S0=S0.
- Min{a,b} = {(t0+0)=t0}, unrefuted (Q3).
- Min{a,c} = {(0+t0)=t0}, unrefuted (the theorem ∀x(0+x=x)).
- Min{b,c} = {(t0+t1)=S0}, refuted by 0+0=S0.
- Min{a,b,c} = {(t0+t1)=t2}, refuted by 0+0=S0.

Single linkage merges {a,b,c}, which is incoherent. DTRC returns {{a,b},{c}} or {{a,c},{b}} depending on the order: two
different, both truth-sound, generalizations from the shared instance a.

*Proof.* (a) and (d): by the example. (b): DTRC merges only coherent unions, and coherence is downward closed; single
linkage fails by the example. (c): as stated. ∎

So whole-cluster tests are what keep the asserted hypothesis meaningful when separation fails. The template that will be
asserted is the one tested, not a chain of pairwise templates none of which covers the whole cluster.

### 5.7 Noise

Let D = D_clean ∪ E, with D_clean ⊆ R* labelled as before and E ∩ R* = ∅ (mistaken data, possibly true non-target
sentences).

**Proposition 5.9 (proved; edge case fixed after referee U10).**

(a) *Refutable mistakes are isolated.* If m ∈ E ∩ Ref_d, every cluster containing m is incoherent, because every covering
template has m as an instance. DTRC leaves {m} as an incoherent singleton, contributing nothing.

(b) *Mistakes never bridge targets under separation.* Under RS_d(D_clean), every d-coherent X ⊆ D contains clean data of at
most one target: a template covering clean a ∈ D_i and b ∈ D_j covers {a,b}. So every final cluster is (clean data of ≤ 1
target) ∪ (mistakes).

(c) *Absorption.* A mistake m can join a cluster C of target i only if C ∪ {m} is coherent. Then
Acc_d(C ∪ {m}) ⊆ inst(T) for every T ∈ Min_d^+(C ∪ {m}), and none of these need be below σ_i: the cluster may become
unsound.

(d) *Trimmed verifier* (for clusters with |C| > e). Define

  Acc^e_d(C) := ⋂{inst(T) : T not d-refuted, |C \ inst(T)| ≤ e} = ⋂_{E′ ⊆ C, |E′| ≤ e} ⋂ Min_d^+(C \ E′),

where the second form holds by (W) and C \ E′ ≠ ∅ because |E′| ≤ e < |C|.
- If C has ≤ e mistakes and its clean part lies in D_i, then Acc^e_d(C) ⊆ inst(σ_i).
- If moreover every subset of C of size ≥ |C| − e contains an anchor of σ_i, then Acc^e_d(C) = inst(σ_i).

(e) *Fragmentation.* An absorbed mistake can make the rest of D_i unable to join. Lemma 5.1 does not help:
C ∪ {m} ∪ C′ may be incoherent although C ∪ C′ is coherent. So D_i may be split into clusters none of which contains an
anchor, and the result depends on the merge policy. (On clean data, a sound cross merge can do the same: Theorem 5.4(d).)

*Proof.* (a) m ∈ inst(T) for every T ∈ Cov(X) with m ∈ X.
(b) As stated.
(c) By definition.
(d) Soundness: take E′ := the mistakes; then Min_d^+(C \ E′) contains T₀ ≼ σ_i by (W′). Exactness: for each E′, the set
C \ E′ contains an anchor, so every T ∈ Min(C \ E′) is ≽ σ_i. The finite form follows from (W) as in Lemma 1.2.
(e) By the example below. ∎

**Robust DTRC(d, e, s), with s > e.** Run DTRC_d, assert only clusters of multiplicity ≥ s, and verify each asserted
cluster with Acc^e_d. Guarantee (proved by (a)–(d)):
- Assume RS_d(D_clean), that every mistake is refutable or *noise-separated* (every template covering it and a clean datum
  is d-refuted), and that every coherent set of mistakes has multiplicity < s (sporadic noise). Then the asserted clusters
  are exactly the D_i with multiplicity ≥ s, and the output is the union of those targets once anchors are present.
- A frequent coherent family of mistakes is a systematic error, i.e. a fallacy schema, which no positive-data method can
  tell from a rule (cor:imitation:systematic).
- If instead up to e mistakes are absorbed per cluster, and each cluster keeps an anchor after deleting any e data, the
  output is still sound and exact.
- Not guaranteed: fragmentation (e).

*Computed (u8).* The data are PA data (60 clean) plus:
- 3 refutable mistakes: a1+0=Sa1, a1·0=a1, and (0=0 ∧ ∀x(Sx=x → SSx=Sx)) → ∀x Sx=x;
- 2 unrefutable false ones: J*_0 of R1, and the wrong-base instance (¬S0=0 ∧ ∀x(¬x=0 → ¬Sx=0)) → ∀x¬x=0, whose antecedent
  needs Q1;
- 2 true non-target theorems: 0+a1=a1 and ¬Sa1=a1.

Results:
- The 3 refutable mistakes are incoherent singletons.
- All other mistakes stay singletons of multiplicity 1. Their merges with the diverse induction cluster are refuted, e.g.
  via (A ∧ ∀x(P(x)→P(Sx))) → ∀xP(x), refuted through (0=0 ∧ ∀x(Sx=x → SSx=Sx)) → ∀x Sx=x. With s = 2 no mistake is
  asserted.
- *Absorption.* J*_0 together with the non-diverse data Ind(Sⁿ0+x=Sⁿx), n < 3, is coherent. The only non-refuted minimal
  template is the K₀-shaped
  ((t0(0)+0)=t0(0) ∧ ∀x((t0(0)+x)=t0(x) → (t0(0)+Sx)=St0(x))) → ∀x(t0(0)+x)=t0(x),
  which is not below T_ind. The referee confirmed it is the unique minimal template (999 covering templates of size ≤ 20).
  The untrimmed verifier accepts the false J*_0 and J*_1. The trimmed verifier (e = 1) rejects both and accepts the genuine
  Ind(S³0+x=S³x).
- *Fragmentation.* With the data in the order Ind(0+x=x), J*_0, Ind(S0+x=Sx), then three diverse inductions, DTRC returns
  {Ind(0+x=x), J*_0, Ind(S0+x=Sx)} (K₀-shaped template, unsound) and a separate cluster of the diverse inductions (T_ind).
  With the diverse data first, it returns all five inductions together and J*_0 alone.

A most-specific-first or "large clusters first" second pass is a heuristic remedy, not a theorem.

### 5.8 Implementation versus theory (new after referee U5 / §3.5)

The v1 implementation decided "T is refuted" by a budgeted search over instances drawn from *template-specific* pools. That
is not a fixed Ref_d, and it is not monotone in ≼. Over all ZF cross pairs, the referee found 120 covering templates (72 of
them on the Union–Power, Union–Sep and Power–Sep pairs) reported unrefuted, although each lies above the refuted
naive-comprehension template.

The v2 implementation (`code/dtrc.py`) changes three things:
1. The world keeps a **global set N of refuted sentences** (each with its refutation method). A template is reported
   refuted iff it covers some n ∈ N or its own budgeted search finds a refuted instance, which is then added to N.
2. Every coherence decision of a run is logged, and the run is **audited** against the final set N_final:
   - an "incoherent" decision is consistent automatically: each refuted minimal template covers its refuting sentence,
     which is in N_final;
   - a "coherent" decision is consistent iff some minimal template of the tested set covers no element of N_final;
   - every asserted template must avoid N_final.
3. If the audit fails, the run is repeated with N retained, until it passes (`run_fixpoint`).

**Proposition 5.12 (a passing run is DTRC with a fixed finite oracle; proved).** Suppose a run of the v2 implementation on
data D (fixed order and merge policy) ends with negative set N_final and passes the audit. Assume the sentence refuters are
sound, which is supported by code reading and by the referee's fuzz: 0 of 4206 true sentences refuted. Then:
- Ref_d :≡ N_final satisfies (OS) and (Dec);
- the run's final clusters and asserted templates coincide with those of DTRC_d run with the fixed oracle Ref_d = N_final,
  on the same data, order and policy.

Hence Theorems 5.2 and 5.4 and Props 5.8 and 5.9 apply verbatim to the implementation, with "d-refuted" read as "covers an
element of N_final". In particular, suppose every minimal template of every cross pair covers an element of N_final
(RS_{N_final}(D)). `separation_check` tests this; its extra searches may enlarge N, after which the run is re-audited against
the enlarged set. Then the run's clustering is the target partition.

*Proof.*
- (OS) holds because N_final consists of sentences refuted by sound procedures; (Dec) holds by matching.
- The merge policy is a deterministic function of the sequence of coherence answers. So it suffices that each answer agrees
  with the fixed oracle:
  - "incoherent" answers agree because N ⊆ N_final at every time;
  - "coherent" answers agree by the audit.
- The asserted templates are the members of Min(C) that are not reported refuted.
  - Every excluded member covers an element of N_final: either a cached one, or its own refuted instance, which was added
    to N.
  - Every included member avoids N_final, by the audit.
  - So they are exactly Min^+_{N_final}(C). ∎

*Computed (u3, u5, u10, all reruns).*
- Every DTRC run passed the audit on the first pass (passes = 1). This is printed by u3, u5b, u8 and u10, and checked for all
  24 runs of u5, u6, u8, u9 and u10 by u14.
- After the separation check, which extends N with further searches, the re-audit found 0 inconsistent decisions.
- RS_{N_final}(D) held on every PA, ZF and ZFC run:
  - PA: 147, 201, 175 cross pairs (all minimal templates refuted; |N_final| = 4, 3, 4);
  - ZF: 467, 371, 348 cross pairs (|N| = 9, 8, 7 after the check);
  - ZFC: 614, 294, 428 cross pairs.
- All v1 results are reproduced unchanged. The only differences in the `.out` files are "cached:" method labels, timings,
  fewer pool searches (1 fewer per PA run, 2–3 fewer per ZF run), and Python set-printing order (§9).
- *u13*: the referee's own enumerator lists all 598 covering DT° templates (size ≤ 14) of the ZF cross pairs. With v1, 120
  of them were budget-unrefuted; with v2 all 598 are refuted (|N| = 8). For UnionW–PowerW, 81 of 91 stay unrefuted, all
  above the universal-set schema, as Prop 7.1 predicts.

---------------------------------------------------------------------------------------------------------------------------

## 6. Without negatives: slot counting and MDL

### 6.1 Slot counting on positive data

With N = ∅ the cautious k-union learner is still sound (Lemma 1.1); completeness is governed by slot counting.

**Proposition 6.1 (DT° untagged anchors on positive data; proved).**
(a) If every partition of D_i into at most k blocks has a block that is an anchor of σ_i, then inst(σ_i) ⊆ Acc_k(D, ∅).
(b) Under (Abs) (Theorem 4.1), "k" in (a) can be replaced by k − c_i.
(c) If D_i is covered by k − k′ + 1 proper specializations of σ_i whose union misses some q ∈ inst(σ_i) lying in no other
inst(σ_l), then q ∉ Acc_k(D, ∅) (Theorem 3.1).

*Proof.* (a) For h ∈ VS_k(D,∅), partition D_i by first covering slot. This gives ≤ k blocks, one of them an anchor, so its
slot is ≽ σ_i. (b) Theorem 4.1(a), with "family of templates covering D_i" read through the partition by first covering
slot. (c) As cited. ∎

(a) is the DT° form of thm:imitation:untagged(a), where "anchor" = "generic" = escapes every failure set. (c) is the DT°
form of prop:imitation:diversity(a). For PA, the gap between k − c and k − k′ + 1 is the whole story (Corollary 4.2):
- Sub-encoded steps: c = 1;
- raw sentences: c = 4;
- with three negatives: c = 7 = k′ − 1.

The parent's general sufficient condition ("not covered by k failure sets") is *vacuous* for PA induction at k ≥ 8. The
eight root failure sets (=, ¬, ∧, ∨, →, ↔, ∀, ∃; seven if ↔ is not primitive) cover all formulas (prior referees; root
count corrected after referee U2). Slot accounting with absorption replaces it. For first-order instance schemas, the same
holds with the head classes of Prop 3.4.

### 6.2 MDL and the size principle

Determinacy makes a two-part code well defined. For a hypothesis H (a finite set of DT° templates) and data D, each datum d
is assigned to a template T_d ∈ H covering it (the cheapest if several), and its matcher θ_d is unique (prior C1). Put

  L(H, D) = Σ_{T∈H} L_tmpl(T) + Σ_{d∈D} [ L_idx(T_d) + L_body(θ_d | T_d) ].

Without the body term this is the parent's prop:search:mdl (MDL without likelihood picks the bare metavariable). The
question here is whether the likelihood term makes MDL pick the *target partition*: for example, for Q's seven axioms plus
induction, does it keep T_ind whole or split it by main connective?

*Split hypothesis.* H_F = {Q1,…,Q7} ∪ {T_f : f ∈ F}, where F is the set of main connectives occurring in the induction
data and T_f := T_ind[P := λx.f(P₁(x),…)] (for "=": λx.t_L(x) = t_R(x); for ∀/∃: λx.∀y P₁(x,y)). For a datum Ind(φ) with
root f, the matcher of T_f has bodies of total size |φ| − 1, since the root symbol moves into the template. Under T_ind the
body is λx.φ.

**Proposition 6.2 (the naive code over-splits; proved).** Let:
- L_tmpl(T) = λ|T| and L_body(θ) = λ·Σ_M|θ(M)|, with λ = log₂ A and A the number of symbols;
- L_idx be the two-part ML code for the sequence of template labels (empirical entropy plus (|H|−1)/2·log₂ n + O(1); e.g.
  KT);
- n_ind be the number of induction data and Ĥ(root) the empirical entropy of their main connectives.

Then

 L(H_F, D) − L(H_true, D) = λ(Σ_{f∈F}|T_f| − |T_ind|) + (|F| − 1)/2·log₂ n − n_ind·(λ − Ĥ(root)) + O(1).

Since Ĥ(root) ≤ log₂|F| < λ (A counts term symbols too), the difference tends to −∞ linearly in n_ind. The same holds with
a uniform index code (log₂|H| bits per datum) as soon as the induction frequency exceeds log₂((7+|F|)/8)/λ. Applied
recursively, naive MDL keeps splitting each class by its next symbol while the class has enough data: it never settles on
the target partition.

*Proof.*
- Template part: the stated difference.
- Body part: each induction datum costs λ fewer bits under its T_f. This holds for every root, ∀/∃ included.
- Index part: the split labels refine the true labels by the root of the induction data. So their empirical entropy is
  n·Ĥ(true labels) + n_ind·Ĥ(root) (grouping/chain rule), and the parametric term grows by (|F|−1)/2·log₂ n.
- Ground axioms cost the same under both hypotheses. ∎

**Proposition 6.3 (well-specified codes gain at most O(log n) from splitting; proved modulo standard coding facts).**
Suppose the data are i.i.d. from a law P (template index × instance law). Suppose the code for H_true is a Bayesian mixture
over a parametric family with p parameters that contains P and has regret ≤ (p/2)log₂ n + C (Rissanen 1986; Clarke–Barron
1990; standard, cited from memory). Then for any fixed split hypothesis and K > 0,

 P[ L(H_F, D) ≤ L(H_true, D) − (p/2)log₂ n − K − C′ ] ≤ 2^{−K}.

*Proof.*
- The data part of L(H_F, ·) is a prefix code for the data sequence (given the fixed template list), i.e. a
  sub-probability Q. By Barron's no-hypercompression inequality, P[−log₂Q(D) ≤ −log₂P(D) − K] ≤ 2^{−K}.
- The data part of L(H_true, ·) is ≤ −log₂P(D) + (p/2)log₂ n + C.
- The template parts are constants. ∎

So with a well-specified code, splitting cannot win linearly. The decision falls to lower-order terms (template description
and parametric complexity), which favour fewer templates. This does **not** prove that MDL selects H_true. It shows that
the naive code's linear preference for splitting is an artefact of misspecification.

**Computed (u7; reproduced exactly in v2 and by the referee).** The data are PA data (Q1–Q7 and induction, π_ind = 0.5).
Codes:
- NAIVE (A = 23);
- PC: sequential KT per template, with context (parent symbol, child index);
- DPC: KT with context (depth below the motive root, parent, child index).

The table gives L(H_root) − L(H_true) in bits (negative = MDL splits induction by main connective):

| usage law | n | NAIVE | PC | DPC |
|---|---|---|---|---|
| G1 natural (random motives with quantifiers; scope-dependent terms) | 1000 | −223 | +2325 | +2701 |
| | 16000 | −16466 | −1199 | −3036 |
| | 64000 | −68243 | −19783 | −34412 |
| G2 well-specified for DPC (symbol depends only on depth, parent, index) | 1000 | −915 | +1141 | +1428 |
| | 16000 | −21467 | +1053 | +2822 |
| | 64000 | −87156 | −1522 | +3564 |

*Reading.*
- The naive code splits from n ≈ 10³ (Prop 6.2).
- Under the natural usage law, even the depth-aware adaptive codes split for n ≥ 1.6·10⁴. Usage *is* statistically
  different across connectives (terms under a quantifier see a bound variable), and splitting captures that.
- Under a usage law for which DPC is well specified, DPC keeps T_ind whole, with a margin growing like log n (Prop 6.3).
  The misspecified PC code eventually splits.

**MDL tracks the statistics of usage, not the logical boundaries of schemas.**
- For schemas, MDL with likelihood errs on the side of incompleteness: a split is a sound but incomplete hypothesis, which
  never accepts induction on an unused connective.
- For ground axioms with few occurrences, it errs the other way. With two ground axioms used m times each, the naive code
  prefers their lgg once m·(body cost) < template savings. That is unsound when the lgg is false (0+0=0 and 0·0=0 give
  z = 0).

Neither error is detected by MDL. The refutation test of DTRC detects the second, and the anchor condition (data
diversity) controls the first.

---------------------------------------------------------------------------------------------------------------------------

## 7. Natural examples

### 7.1 PA

**Targets.**
1. Q1–Q7 as ground axioms in closure-normal form: ¬Sa=0; Sa=Sb → a=b; a+0=a; a+Sb=S(a+b); a·0=0; a·Sb=a·b+a;
   ¬a=0 → ∃y a=Sy.
2. Raw induction T_ind = (P(0) ∧ ∀x(P(x)→P(Sx))) → ∀xP(x) (DT°, not a Miller pattern).
3. Alternatively, Q's axioms observed only through closed-term instances: the instance schemas Q1s–Q7s (first-order
   patterns, e.g. (t0+0)=t0).

**Cross merges and what refutes them (computed, u1).** Every minimal covering template of every tested cross pair is refuted
by **Δ₀ evaluation after ∀-instantiation of parameters** (R-Δ₀):

| cross pair | unique minimal covering template | refuting instance |
|---|---|---|
| two axioms with different roots (e.g. Q1–Q3); any Q_i with root ≠ → and induction | F0 | 0=S0 |
| Q2–Q7, Q2–Ind, Q7–Ind | F0 → F1 | 0=0 → 0=S0 |
| Q3–Q5, Q3–Q6, Q4–Q5, Q4–Q6 | t0 = t1 | 0=S0 |
| Q3–Q4 | (a1+t0) = t1 | (a1+0)=0 at a1 := 1 |
| Q5–Q6 | (a1·t0) = t1 | (a1·0)=S0 at a1 := 0 |
| Q_i s – Q_j s (instance schemas; 4 random pairs each, all 21 pairs) | various | all refuted |

So PA is *globally separated at small depth* by the world channel alone. For Q1–Q7 + T_ind this is not only empirical: every
Q–Ind pair has minimal template F0 or F0→F1 for every motive, and the 21 Q–Q pairs are fixed (referee §3.8). For the
instance schemas Q1s–Q7s, global separation is supported only by samples.

**DTRC (computed, u3).** Three seeds, 40 shuffled unlabelled data each:
- one pure cluster per target present in the data (7 or 8);
- the induction cluster's only non-refuted minimal template is T_ind;
- 200/200 held-out random induction instances accepted;
- 0 of 91 non-instances accepted. The test set has 104 near misses: 50 step-by-2 and 50 wrong-base variants, plus 4 mutated
  axioms. 13 of the 100 variants are genuine inductions because their motives are vacuous, and these are correctly accepted;
- 63–102 coherence tests per run, all with |Min| = 1;
- v2 audit: 1 pass; RS on D verified on all cross pairs.

Within the instance-schema clusters, the minimal template is the schema itself once the closed terms have different heads
(u1(b2)). One Q2s sample lacked an S-free instance and gave the sound specialization SSt0=St1 → St0=t1. DTRC then accepts
a1+0=a1 etc., i.e. the universal axioms (§5.4).

**Induction is never at risk of a cross merge.** Every minimal template covering a Q-axiom and an induction instance is
absorbing (contains T_ind; Corollary 4.2(3)), and it is refuted. The only way induction is learned incompletely is lack of
diversity inside its own data (no anchor), exactly as in the tagged case.

### 7.2 ZF and ZFC

**(a) ZF targets** (closure-normal form, de Bruijn):
- Ext: ∀x(x∈a↔x∈b) → a=b;
- Pair: ∃c(a∈c ∧ b∈c);
- Union: ∃b∀c(c∈b ↔ ∃d(d∈a ∧ c∈d));
- Power: ∃b∀c(c∈b ↔ ∀d(d∈c → d∈a));
- Inf: ∅ and successor written out with ∈;
- Found: ∃y(y∈a) → ∃y(y∈a ∧ ∀z(z∈y → ¬z∈a));
- Separation: ∃b∀c(c∈b ↔ c∈a ∧ P(c));
- Replacement: ∀x(x∈a → ∃y(P(x,y) ∧ ∀z(P(x,z) → z=y))) → ∃b∀y(y∈b ↔ ∃x(x∈a ∧ P(x,y)));
- ∈-induction: ∀x(∀y(y∈x → P(y)) → P(x)) → ∀xP(x).

In de Bruijn form all three schemas are Miller patterns (P applied to distinct bound variables), so freshness conditions are
automatic (brief Q2).

**Cross merges (computed, u4; one instance per schema per pair).** All 36 pairs have a unique minimal covering template, and
each is refuted by one of three means:
- an **HF counterexample** (R-HF) when the template is a bare formula metavariable F0 or F0 → F1 (instance ¬q1=q1, resp.
  q1=q1 → ¬q1=q1, falsified by q1 := ∅): 22 pairs;
- **pure logic** (R-logic) when the template keeps some quantifier structure:
  - ∃x F0(x) (Pair–Union, Pair–Power, Pair–Sep, Union–Inf, Power–Inf, Inf–Sep; instance ∃x ¬q1=q1);
  - ∃x(F0(x) ∧ F1(x)) (Pair–Inf);
  - (∀x F0(x)) → F1 (Ext–Rep, Ext–EInd);
  - F0 → ∃x F1(x) (Found–Rep);
  - (∀x(F0(x)→F1(x))) → F2 (Rep–EInd);
- **Russell's paradox** for the comprehension-shaped axioms. Union–Power, Union–Separation and Power–Separation all have
  the minimal template ∃x∀y(y∈x ↔ F0(y)), *naive comprehension*, refuted by its instance ∃x∀y(y∈x ↔ ¬y∈y) (Herbrand: take
  y := x).

The referee's independent enumerator found all 598 covering templates of size ≤ 14 for 63 ZF cross pairs (2 samples per
schema). None lies outside `mincov`, and all are refuted with the v2 oracle (u13). Within each target, three random
instances of each schema have the schema itself as their unique minimal template (an anchor), never refuted. The referee
confirmed this independently (Sep, EInd, Rep pairs: none outside `mincov`).

**DTRC on ZF (computed, u5 part A).** Three seeds, 45 shuffled unlabelled data each:
- 9 pure clusters (the six single axioms and the three schemas);
- each schema cluster is exact: its unique non-refuted minimal template is the schema;
- 60/60 held-out instances of each schema accepted;
- 0/30 naive-comprehension instances accepted. Separation without its guard c∈a is *not* learned, because the data never
  contain it and the cluster template keeps the guard;
- RS on D verified on all 467/371/348 cross pairs; |Min| = 1 in all 442 tests; audit 1 pass.

**(b) ZFC: the Axiom of Choice (new; referee 'missing' 4; computed, u10).** AC is a single ground axiom. In closure-normal
form, with a the family:

 AC(a) = [∀y(y∈a → ∃z z∈y) ∧ ∀y∀w((y∈a ∧ w∈a ∧ ¬y=w) → ¬∃z(z∈y ∧ z∈w))]
     → ∃c∀y(y∈a → ∃z(z∈y ∧ z∈c ∧ ∀u((u∈y ∧ u∈c) → u=z))).

- AC is not refuted by the oracle (it is true in V).
- Each of its 12 cross pairs with the ZF targets (2 samples per schema) has one minimal template, and all are refuted:
  - F0 → F1 (with Ext and EInd): refuted by an HF counterexample;
  - F0 (with Pair, Union, Power, Inf, Sep): refuted by the same cached HF counterexample;
  - F0 → ∃x F1(x) (with Found) and F0 → ∃x∀y F1(y,x) (with Rep): refuted by logic.
- DTRC on unlabelled ZFC data, 3 seeds × 50 data:
  - 10 pure clusters every time (AC, Ext, Pair, Union, Power, Inf, Found, Sep, Rep, EInd);
  - all three schema clusters exact; AC accepted;
  - RS on D verified on 614/294/428 cross pairs; 180/180 held-out schema instances accepted.

AC needs nothing beyond what any ground axiom needs: one occurrence in the data. Its anchor is {AC}.

So for Q2 in the untagged setting the answer is **yes**. The ZFC axioms and schemas are separated by the two refutation
channels the brief lists: HF counterexamples (sound by Δ₀ absoluteness) and logic. Russell's paradox does the work exactly
where the axioms look alike.

### 7.3 Where separation fails

**(a) Sound merges.**
1. ∀xφ from instances (§5.4).
2. Redundant targets: an axiom that is an instance of a target schema merges into the schema's cluster, and the merge is
   target-sound. Example: Empty Set written as ∃b∀c(c∈b ↔ c∈a ∧ ¬c=c), an instance of Separation.
3. Instances shared by two generalizations (Proposition 5.8: 0+0=0 joins Q3's cluster or the cluster of the theorem 0+x=x)
   and the clean fragmentation example of Theorem 5.4(d).

Refutation cannot and should not prevent these. They are the reason DTRC is truth-sound rather than target-sound without
separation (Remark 5.11).

**(b) An unsound merge that only coherence refutes: the weak forms of Union and Power.** Many presentations state Union and
Power in bounding form and recover the ↔ form by Separation:

UnionW ∃b∀c(∃d(d∈a ∧ c∈d) → c∈b), PowerW ∃b∀c(∀d(d∈c → d∈a) → c∈b).

Their unique minimal covering template (computed) is the **universal-set schema** U(F) = ∃x∀y(F(y) → y∈x). Its instance
∃x∀y(y=y → y∈x) is false in V.

**Proposition 7.1 (proved).** No instance of U is refuted by R-logic or R-HF, or by any oracle sound for the structure M₀
below. So the merge UnionW+PowerW passes every such test at every depth. The template *is* refuted by coherence: its
instance ∃x∀y(y=y → y∈x) is refuted together with the closure of one instance of Separation (Russell's set of x), or with
the true Π₁ sentence ∀x ¬x∈x.

*Proof.* Let M₀ = HF ∪ {u}, with ∈ as in HF on HF and y ∈ u for every y ∈ M₀ (so u ∈ u).
- Every instance ∀ā∃x∀y(ψ(y,ā) → y∈x) holds in M₀: take x = u.
- HF is a transitive part of M₀ (no HF set has u as a member). So Δ₀ formulas with HF parameters have the same truth value
  in HF, in M₀ and in V.
- R-HF refutes a sentence only through a chain of steps each sound in every structure that contains HF as a transitive
  part: atoms and bounded quantifiers over HF are evaluated in HF; an unbounded ∀ is refuted by an HF witness; an unbounded
  ∃ is verified by an HF witness. Hence R-HF refutes only sentences false in M₀. The referee checked that `refuters.HF`
  does only these steps.
- R-logic refutes only logically false sentences.

For the positive part, take the instance with ψ := y=y, and let b be the witness of ∃x∀y(ψ(y) → y∈x). Then y := b gives
b∈b, which contradicts ∀x¬x∈x. With the Separation instance r = {y ∈ b : y∉y}: r∈b by the instance, and r∈r ↔ r∉r. Both
derivations are found by the Herbrand/DPLL refuter (u4, u_test_refuters). ∎

*Computed (u5 part B, u5b).*
- With logic + HF only, DTRC merges UnionW and PowerW into one cluster with template ∃x∀y(F0(y) → y∈x) and **accepts the
  false universal-set sentence**. This is an unsound unrefuted merge: soundness holds only relative to the residue
  (Theorem 5.4).
- The learned Separation cluster accepts Russell's instance of Separation, ∃b∀c(c∈b ↔ c∈a ∧ ¬c∈c). Designate its universal
  closure (*bootstrapped coherence*: one sentence accepted by a learned cluster is used as a designated truth) and re-run
  DTRC on the same data. Result: **9 pure clusters**, UnionW and PowerW separated, the three schema clusters still exact,
  and the universal-set sentence **no longer accepted**.

Bootstrapping is sound exactly when the clusters it trusts are pure (target-sound), which separation elsewhere provides. It
is circular otherwise.

**(c) K₀ (prior R1) in DT°.** K₀ = lgg(Ind(0+x=x), Ind(S0+x=Sx)) is the *first-order* lgg. All its sentence instances are
jointly consistent with the true quantifier-free sentences of ℕ (prior referee, Theorem R1). So neither R-Δ₀ nor logic
refutes any of them, and its instance J*_0 = (0+0=0 ∧ ∀x(0+x=0 → 0+Sx=S0)) → ∀x(0+x=0) is false.

In DT° the same pair has two minimal covering templates (computed; confirmed by the referee, 6258 covering templates of size
≤ 24):
- the T_ind-specialization P := λx.(t0(0)+x = t0(x));
- the K₀-shaped ((t0(0)+0)=t0(0) ∧ ∀x((t0(0)+x)=t0(x) → (t0(0)+Sx)=St0(x))) → ∀x(t0(0)+x)=t0(x). Its instances are
  K₀-instances, hence also never refuted.

DTRC merges the pair through the sound template. The cluster verifier intersects *both* non-refuted minimal templates, so
J*_0 is not accepted ((W′) guarantees a sound template in the intersection).

The K₀-shaped template becomes harmful only when the sound alternative disappears: when an unrefutable mistake such as
J*_0 itself is absorbed into a non-diverse induction cluster (u8; §5.7). It is refuted by coherence with designated Q (prior
B5(d): the descent through Q3 is unblocked when Q3 is designated), or, in DTRC, with Q's own learned clusters
(bootstrapped coherence again). It has quantifiers in its rigid part, as Prop 5.13 requires of any unsound template that
R-Δ₀ never refutes.

**(d) Permanent residue.** Some templates have false instances that are all consistent with the designated truths and
Δ₀-correct, for example families containing ¬Con(PA)-like Σ₁ sentences (parent thm:twotier:arith(b),(d)). None of these
channels can ever refute them, so a merge into such a template is a permanent unsound residue. By Theorem 5.7, no
computable learner can recognize in general whether a merge will ever be refuted. Σ₁-caution (assert a Σ₁ instance only
after a verified witness; thm:twotier:arith(c)) removes the syntactically Σ₁ part.

Prop 5.13 shows that in arithmetic such templates must have quantifiers in their rigid part. **A concrete *natural* merge of
this kind was not constructed (open).**

---------------------------------------------------------------------------------------------------------------------------

## 8. What this track says about the brief's questions and method

**Q3 (one method, many schemas, no labels).** DTRC as proposed in brief §5 works, with four amendments argued here:
1. *The merge test must be on whole clusters* (§5.6), and *the verifier must intersect all non-refuted minimal templates*
   rather than pick one. DT° is non-unitary (prior C8), and the K₀-shaped minimal template sits next to the sound one
   (§7.3(c)).
2. *The budget d is essential and cannot be eliminated* (Theorem 5.7). DTRC is sound relative to the depth-d residue; run
   it with a depth schedule, re-clustering when d grows.
3. *If a bound k ≥ k′ is known, intersect with the k-union learner fed with DTRC's own negatives* (Remark 5.3). That
   restores anytime *target*-soundness without separation, and costs nothing in exactness at k = k′ (pigeonhole). Spare
   slots, however, cost data diversity (Props 3.5, 3.6). Without separation, no learner is both exact and target-sound on
   ambiguous data (Remark 5.11).
4. *Implement refutation as a fixed, growing set of refuted sentences*, not a per-template budget, and audit the run
   (§5.8). The run is then provably an instance of the theory.

Under refutation separation the untagged problem is exactly as hard as the tagged one (Theorem 5.2(iv)): refutation plays
the role of citations. PA, ZF and ZFC are separated at small depth by the brief's channels (§7.1, §7.2).

**Q1 (∀xφ from instances).** It is the special case of a *sound cross merge* (Proposition 5.6). DTRC merges the instances,
and accepts ∀xφ itself, iff no instance of φ(z) is refuted. Two instances whose substituted terms have different head
symbols are an anchor (Lemma 5.5). The step is truth-sound in ℕ for quantifier-free φ with R-Δ₀ (the ω-rule; Props 5.6(e),
5.13), but it is not derivable. It is not truth-sound in structures whose elements are not all closed-term values unless the
oracle is strong enough (ℝ example). With spare slots in a k-union learner, numeral instances alone never yield ∀xφ
(Prop 3.6).

**Q2 (ZFC schemas).** Separation, Replacement (with ∃! spelled out) and ∈-induction are DT° templates, indeed Miller-pattern
templates. Each is anchored by a few varied instances (computed: three random instances suffice in all runs). Every cross
merge with the other axioms, Choice included, is refuted by HF counterexamples or logic, with Russell's paradox separating
the comprehension-shaped ones. With weak (bounding) forms of Union/Power, separation needs coherence (Proposition 7.1).

**Imported assumptions.** (W) and the DT° anchor theorem (A) for the targets used, from track 'single'. Both hold in all
computations here: (W) was cross-validated by brute force (u0) and independently by the referee. Nothing is assumed from
track 'cases'. Lemma 5.5 (two-point anchors) is proved here because Theorem 5.7 needs it. Prop 5.10(c),(d) uses track
single's Prop G.2/G.3, Cor G.4 and Thm C, but only for the cost analysis.

---------------------------------------------------------------------------------------------------------------------------

## 9. Computations (all run in this session with the final libraries)

Directory `code/`. Python 3.11, no external packages. Run from `code/`: `python3 <script>.py > <script>.out`, or
`sh run_all.sh` for everything (about 15 minutes). The v1 outputs are kept in `code/v1_outputs/` (with `dtrc_v1.py.txt`).

| script | what it computes | output | key numbers (final) |
|---|---|---|---|
| `dtlib.py` | DT° templates with parameters and de Bruijn binders; instantiation; unique matching via pattern occurrences (Huet–Lang fallback); subsumption by freezing; common prefix; `mincov` (minimal covering templates by the slot/derivation analysis) | library (unchanged) | |
| `refuters.py` | R-Δ₀ (numeral ∀-instantiation ≤ B = 3, Σ-witnesses ≤ 6, EUF + closed equations of ℕ for universals); R-HF (V₃, bounded quantifiers, Δ₀ absoluteness); R-logic (Skolemize, Herbrand depth 1, ≤ 12 terms, ≤ 300 ground instances, DPLL with a 3000-node budget; exhausting a budget never yields a refutation; equality by reflexivity only) | library (unchanged) | |
| `dtrc.py` (v2) | budgeted template refutation **with a global negative set**; DTRC (online + pairwise fixpoint, whole-cluster tests, caching); decision log, **audit** against N_final, `run_fixpoint`, \|Min(X)\| statistics; `separation_check` (RS on D for the implemented oracle) | library | |
| `practice.py` | PA and ZF targets, data generators | library (unchanged) | |
| `u_test_refuters.py` | sanity checks of the refuters | `u_test_refuters.out` | identical to v1 |
| `u0_crossval_mincov.py 20` | (W) on the enumerated fragment: every brute-force DT° covering template (prior `so_enum`) lies above a `mincov` template, 8 pairs | `u0_crossval_mincov.out` | 0 counterexamples; \|Min\| = 1, 1, 4, 2, 27, 16, 2, 1 (identical to v1 except timings) |
| `u1_pa_cross.py` | PA cross merges, absorption, within-target instance schemas | `u1_pa_cross.out` | all refuted; 4 distinct negatives; absorption 7/7 (v2 differs only by "cached:" labels) |
| `u2_threshold.py` | non-absorbing cover number c; exact κ(q) vs c + χ | `u2_threshold.out` | c = 4 / 7 / 7; κ = c + χ in 24/24 (identical) |
| `u3_dtrc_pa.py` | DTRC on PA, 3 seeds × 40 data; v2 audit and separation check; held-out and near misses | `u3_dtrc_pa.out` | pure clusters, T_ind exact; passes = 1; \|Min\| = 1 in 63/102/98 tests; RS: 147/201/175 cross pairs all refuted; 200/200; 0/91 |
| `u4_zf_cross.py` | ZF cross merges (36 pairs); within-target; Union/Power both forms | `u4_zf_cross.out` | 36/36 refuted (22 HF, 14 logic, 3 by Russell); weak forms refuted only with a designated sentence (identical) |
| `u5_dtrc_zf.py` | DTRC on ZF, 3 seeds × 45 data; v2 audit and separation check; held-out; naive comprehension; part B weak forms + bootstrapping | `u5_dtrc_zf.out` | 9 pure clusters per seed; passes = 1; \|Min\| = 1 in all tests; RS 467/371/348 refuted; 180/180; 0/30; part B: universal set accepted (8 clusters), with bootstrapped designated sentence 9 clusters and rejected |
| `u5b_bootstrap.py` | part B alone (logic budget 15) | `u5b_bootstrap.out` | same outcome (identical except time) |
| `u6_forall_nontrans.py` | ∀xφ from numeral instances; false universal blocked; non-transitivity | `u6_forall_nontrans.out` | identical (§5.4, §5.6) |
| `u7_mdl.py 200 1000 4000 16000 64000` | two-part code lengths NAIVE/PC/DPC, laws G1, G2 | `u7_mdl.out` | table §6.2 (identical) |
| `u8_noise.py` | noise: refutable/unrefutable/true mistakes, multiplicity, absorption + trimmed verifier, fragmentation | `u8_noise.out` | identical up to set-printing order; passes = 1 |
| `u9_clean_fragmentation.py` (new) | Theorem 5.4(d) on clean data (Examples A, B); k′-union learner on the same data | `u9_clean_fragmentation.out` | A: a1+0=a1 rejected in 2/3 orders; B: rejected in 1/3 orders (fragmentation via the sound merge {0+S0=S0, 0+0=0}); 2-union learner: rejects a1+0=a1 in both, rejects SS0+0=SS0 in B |
| `u10_zfc_choice.py` (new) | AC: cross merges with the 9 ZF targets; DTRC on ZFC, 3 seeds × 50 data | `u10_zfc_choice.out` | 12/12 AC cross templates refuted; 10 pure clusters per seed; schemas exact; AC accepted; RS 614/294/428 refuted; 180/180 |
| `u12_headclass.py` (new) | Prop 3.4 coverage by head classes; Prop 3.5(c) criterion vs brute force at m = h; Prop 3.6 closed form vs brute force | `u12_headclass.out` | 2000/2000 and 2000/2000 covered, each template needed; 60/60 agree (18 exact); m = h−1 exact 60/60; 254/254 and 2509/2509 |
| `u14_passes_check.py` (new) | instruments `run_fixpoint` and re-runs u5, u6, u8, u9, u10 | `u14_passes_check.out` | all 24 DTRC runs: passes = 1 |
| `u13_monotone_check.py 14` (new) | v2 world vs the referee's independent enumerator (`../referee_code/ref_enum.py`) on ZF cross pairs and UnionW–PowerW | `u13_monotone_check.out` | 598 enumerated ZF cross templates: 0 unrefuted (v1: 120), 0 outside `mincov`; UnionW–PowerW: 81/91 unrefuted, all above U(F) |

Run times: u12 ≈ 7 min; u5 ≈ 2.5 min; u0 ≈ 2–3 min; u7 ≈ 2 min; u5b ≈ 1 min; the others < 1 min.

*Differences between v1 and v2 outputs (checked with `diff` against `v1_outputs/`):*
- the method label "cached:" where a template was refuted by a previously found negative (u1, u4, u10);
- "refutation searches" lower by 1 per PA run (u3) and by 2–3 per ZF run (u5): templates refuted by a cached negative;
- the new v2 diagnostic lines;
- timings, and the Python set-printing order inside one u8 cluster.

No cluster, template, acceptance count or threshold changed.

*Implementation caveats.*
- `mincov` is complete as far as u0 and the referee's independent enumeration check it. These checks cover pairs of
  induction instances (size ≤ 20), all PA and ZF cross pairs (size ≤ 14), Sep/EInd/Rep within-target sets, the K₀ pair
  (size ≤ 24), and the J*₀ clusters (size ≤ 20). In all of them, 0 covering templates lie outside `mincov`. Minimality is
  syntactic, which can only add redundant templates above true minimal ones; that is harmless for coherence and for the
  intersection verifier.
- The silent caps of `mincov` never changed a result (referee `ref7`: 382 calls, 10× caps).
- Refutation search is budgeted and incomplete. With v2, "not refuted" means "covers no element of N_final and its own
  search failed", and a passing run is DTRC with the oracle N_final (Prop 5.12). Every reported refutation was produced by
  a sound procedure and printed with its instance and witness.
- Templates are matched literally, not modulo renaming of template parameters. This can only under-accept.

---------------------------------------------------------------------------------------------------------------------------

## 10. Open problems

1. **(W) for DT°** in general. Track 'single' Thm B claims a proof (not refereed when this was written); here it is only
   cross-validated on fragments.
2. **Spare-slot thresholds beyond the first level.**
   - For one-variable first-order instance schemas, the threshold is settled for m ≤ h (Prop 3.5) and for unary signatures
     (Prop 3.6).
   - Open:
     - m > h over signatures with a binary symbol, where the second level is a product-covering problem;
     - several metavariables;
     - templates with parameters (the minimal templates modulo renaming are then non-unique);
     - T_ind with m ≥ 8 slots, where the eight root classes cover Ind and exactness depends on failure events inside each
       root class (the prior referee's example: all ∀-motives bind the same variable).
   - Exactness for first-order targets at a given m reduces, by Lemma 1.2, to finitely many covering problems for
     first-order patterns. Those are decidable by known results on complement problems and ground reducibility (Lassez–
     Marriott 1987 for linear patterns; Comon's disunification and Comon–Jacquemard 1997 in general — *cited from memory,
     not rechecked*). A characterization by witness events is open.
3. **Cost of a coherence test.** Is "∃T ∈ Min(X) avoiding a finite N" (or "not d-refuted") decidable in polynomial time,
   or is it hard? With |N| = 1 it is polynomial (Prop 5.10(d)).
4. **Separation at depth d as a usable assumption.** Can one bound the depth from the targets (e.g. for first-order pattern
   targets over ℕ, by the size of the lgg and the least counterexample)? For PA, ZF and ZFC it is tiny (§7), but Theorem 5.7
   shows that no uniform computable bound exists.
5. **A natural permanent residue** (Σ₁/Π₂-type) arising from a merge of natural axioms. Prop 5.13 shows that such a merge
   needs quantifiers in the template.
6. **Fragmentation-free robust clustering.** A merge rule with a theorem that neither mistakes nor sound merges fragment a
   target's anchor (they can: Theorem 5.4(d), Prop 5.9(e)). By Remark 5.11 this needs more than anchors in the data.
7. **MDL.** A theorem that a natural universal code (e.g. context-tree mixtures over bodies) selects the target partition
   under a well-specified usage model, and a characterization of when usage heterogeneity makes it split.
8. **Coherence with learned clusters** (bootstrapping): soundness when only some clusters are pure, and an iterative scheme
   with guarantees.

---------------------------------------------------------------------------------------------------------------------------

## 11. Credits and citations

*Known results used.*
- Gold 1967: superfinite classes are not identifiable from text.
- Angluin 1980: tell-tales.
- Plotkin 1970, Reynolds 1970: lgg, its leastness, and failure events (R), (D).
- Huet–Lang 1978: second-order matching.
- Miller 1991: patterns.
- Pfenning 1991; Baumgartner–Kutsia–Levy–Villaret 2017: pattern anti-unification.
- Wright 1989; Motoki–Shinohara–Wright 1991: finite elasticity of bounded unions.
- Arimura–Shinohara–Otsuki 1994: minimal multiple generalization for unions of pattern languages. *Believed correct
  citation, not rechecked.*
- Matiyasevich 1970, building on Davis–Putnam–Robinson 1961: MRDP, every c.e. set is Diophantine. Used in Theorem 5.7.
- Kleene's T predicate and the Δ₀-definability of computations (standard; v1 construction, now the variant).
- Δ₀ absoluteness for transitive classes (standard; e.g. Kunen's or Jech's textbooks).
- Herbrand's theorem.
- Gödel 1931 (second incompleteness, for §7.3(d)).
- Rissanen 1978/1986 (MDL, parametric regret); Krichevsky–Trofimov 1981 (KT estimator); Clarke–Barron 1990 and Barron's
  no-hypercompression inequality (Barron 1985; Grünwald's 2007 MDL book). *Cited from memory.*
- Tenenbaum–Griffiths 2001 (size principle).
- Lassez–Marriott 1987; Comon (disunification, complement problems); Comon–Jacquemard 1997 (ground reducibility). *Cited
  from memory, only in open problem 2.*

*Results from the parent report used:* lem:imitation:cautious, thm:imitation:anchor, thm:imitation:untagged,
prop:imitation:diversity, thm:imitation:coupon, thm:imitation:trimmed, lem:twotier:onesided, thm:twotier:depth,
thm:twotier:arith, prop:search:mdl.

*Results from the prior session used:* DT° matching and the induction anchor theorem (C1, C3, C8), the PA untagged threshold
(pa-untagged findings), and R1 (raw-impossibility referee).

*Results from track 'single' used* (as hypotheses): Thm A (matching), Thm B (= W), Thm C (feature verifier), Thm D / Cor D.1
(anchors), Prop G.2, G.3, Cor G.4.

*Independent checks by the referee*, cited as such: `referee_code/` (ref1–ref7, `ref_enum.py`).

The clustering idea is in the spirit of conceptual clustering (Michalski–Stepp 1983, *believed*) and of MMG. As far as I
know, the following are new here: the refutation test, the separation theorem, the impossibility theorem, the head-class
thresholds, and the implementation audit.

---------------------------------------------------------------------------------------------------------------------------

## 12. Verification log (referee report `referee.md`, point by point)

Referee verdicts: 20 items (U1–U16 with sub-items), none refuted: 15 "holds" and 5 "holds-with-fix" (U2, U5, U6, U7, U8,
which together contain the six local fixes of the referee's summary). There are also five "missing" items and seven required
changes. Resolution of each:

| id | referee verdict | issue raised | resolution | where |
|---|---|---|---|---|
| U1 | holds | pedantic: "first d-refuted instance" needs Ref_d membership decidable and inst(T) enumerable; (Dec) gave only the existence test | **Fixed.** (Dec) strengthened: membership in Ref_d decidable uniformly in d, plus a fixed effective enumeration of S. The size-bounded example and the fixed finite oracle satisfy it. Cor 2.2(b) now cites (Dec) explicitly. | §1, Cor 2.2 |
| U1-PA | holds | — | No change; the referee's independent enumeration (49 pairs, 68 templates, all refuted, none outside `mincov`) is now cited. | Ex 2.3 |
| U2 | holds-with-fix | (1) Cor 3.3(b) silently needs cross-separation; (2) the caveat that Plotkin failure families are m-noncovering for every m is false under parameter canonicalization; (3) "seven root specializations" clashes with ↔ | **(1) Fixed:** cross-separation added to Cor 3.3(b), with Theorem 3.2 stated per target. **(2) Referee right; caveat withdrawn.** Replaced by Prop 3.4 (head classes: \|F\|+p+1 specializations cover inst(φ(z)); computed 2000/2000 for p = 0 and p = 1, each needed). The open problem is extended to first-order schemas, and partly solved: Prop 3.5 (exact threshold for m ≤ h) and Prop 3.6 (closed form for unary signatures), both proved and checked by brute force (60/60; 254/254; 2509/2509). **(3) Fixed:** eight roots (=, ¬, ∧, ∨, →, ↔, ∀, ∃) in Cor 3.3 and §6.1. | §3, §6.1, §10.2, u12 |
| U3 | holds | — | No change. | §4 |
| U3-comp | holds | κ = c + χ holds by construction given (Abs) and C3: a consistency check, not independent evidence | **Agreed; stated** in Cor 4.2(3). | §4 |
| U4 | holds | — | No change (the remark that the locking-sequence argument needs no computability is added to the proof). | Prop 4.3 |
| U5 | holds-with-fix | (1) "cost O(n²)" counts tests only; \|Min(X)\| can be 4^Θ(n); the online bound needs + k′(k′−1)/2; (2) the implemented refutation is template-specific, so it is not a fixed Ref_d and not monotone in ≼ (72 ZF templates above refuted naive comprehension reported unrefuted) | **(1) Fixed:** "O(n²) coherence tests"; online bound n·k′ + k′(k′−1)/2 with proof. New Prop 5.10 on the cost of one test: \|Min\| = 1 for quantifier-free X and for X containing an anchor; 4^Θ(n) worst case (track single); polynomial for one negative via the feature verifier; open in general. Computed \|Min\| = 1 in all 705 tests of the PA/ZF runs. **(2) Referee right; implementation repaired (v2):** a global negative set N, an audit against N_final, and `run_fixpoint`. Prop 5.12 proves that a passing run *is* DTRC with the fixed oracle Ref_d = N_final. All experiments were re-run: every run passes on the first pass, all results are unchanged, and RS on D is verified on every cross pair. u13: with the referee's enumerator, all 598 ZF cross templates are now refuted (v1: 120 unrefuted). | §5.2, Prop 5.10, §5.8, Prop 5.12, §9, u3, u5, u10, u13 |
| U6 | holds-with-fix | Thm 5.4(d) stated for clean D but illustrated only by a noisy example | **Fixed:** clean examples computed (u9). In Example B (disjoint instance sets: t+0=t and ground 0+S0=S0) one order fragments the anchor through the sound merge {0+S0=S0, 0+0=0}; the referee's Example A is reproduced. Added Remark 5.11: on such data *no* learner is both exact for P and target-sound for an alternative valid P′, so the failure is intrinsic without separation. The k′-union learner is also non-exact there (computed). | Thm 5.4(d), Remark 5.11, u9 |
| U7 | holds-with-fix | Prop 5.6(e) needs an oracle complete on closed instances (not R-Δ₀ in general) and refers to Ref_∞; in (b) the parameter must be fresh | **Fixed:** (b) says "fresh for φ". (e) is restricted to oracles complete for false instances at unbounded depth (e.g. quantifier-free φ with R-Δ₀); R-Δ₀ with quantified φ is explicitly excluded (u8 wrong-base example); the finite-budget case is referred to Res_d. New **Prop 5.13** (proved): with R-Δ₀ at depth ∞, unrefuted quantifier-free arithmetic templates are truth-sound; this generalizes (e). | Prop 5.6, Prop 5.13 |
| U8 | holds-with-fix | fact (4) needs ¬H_e(c̄) to be refuted; R-Δ₀ verifies universals only via EUF, and Kleene T has bounded universals | **Fixed:** H_e(z) := ∃x̄(z = SS c(x̄) ∧ P_e(x̄) = Q_e(x̄)) via MRDP. Refuting ¬H_e(c̄) needs only witnesses and closed atom evaluation, which R-Δ₀ does. Facts 1–6 re-verified (A_e, B_e true; anchor by Lemma 5.5; valid iff e ∉ K). Ref_d is made decidable by a size bound. The full-Δ₀-oracle variant is kept as an alternative. | Thm 5.7 |
| U9 | holds | trivial: a refutable singleton is an incoherent cluster | **Noted** in Prop 5.8(b). | §5.6 |
| U10 | holds | edge case E′ = C leaves Min(∅) undefined | **Fixed:** the trimmed verifier is defined for \|C\| > e, so E′ ⊊ C; Robust DTRC requires s > e. | Prop 5.9(d) |
| U11a | holds | — | No change. | §6.2 |
| U11b | holds | relies on standard regret and no-hypercompression facts, cited from memory | Kept flagged "cited from memory"; I could not recheck the citations in this session. | Prop 6.3, §11 |
| U11c | holds | — | No change (u7 re-run, identical). | §6.2 |
| U12 | holds | global separation of Q1s–Q7s rests only on samples (already said) | No change. The referee's structural argument for global separation of Q1–Q7 + T_ind is now cited. | §7.1 |
| U13 | holds | `mincov` completeness for ZF data not cross-validated by the author; stale u5 comment about "Replacement without uniqueness" near misses | **Fixed:** the referee's independent validation is cited (63 cross pairs, 598 templates; Sep/EInd/Rep within-target sets), and the v2 check u13 reuses the referee's enumerator. The stale comment was removed from `u5_dtrc_zf.py`. | §7.2, §9, u5, u13 |
| U14 | holds | — | No change. | Prop 7.1 |
| U15 | holds | — | No change; the referee's 6258-template confirmation is cited. | §7.3(c) |
| U16 | holds | the "earlier failing version" of `mincov` cannot be checked | Agreed. The earlier version is not used as evidence (historical remark only, dropped from the final record). | §1 |
| missing 1 | — | spare-slot threshold open for T_ind and, per the U2 error, for first-order schemas over a finite signature | **Partly resolved:** Props 3.4–3.6 settle one-variable quantifier-free schemas for m ≤ h and unary signatures completely. The rest is open problem 2 (binary symbols with m > h, several variables, parameters, T_ind with m ≥ 8). | §3, §10 |
| missing 2 | — | no natural permanent Σ₁/Π₂ residue constructed | **Still open**, but narrowed: Prop 5.13 proves that in arithmetic (R-Δ₀, depth ∞) only templates with quantifiers in the rigid part can be unsound and never refuted. | Prop 5.13, §7.3(d), §10.5 |
| missing 3 | — | cost of one coherence test unanalysed; track single's polynomial verifier decides Acc membership, not existence of an unrefuted minimal template | **Addressed:** Prop 5.10 (proved): the test costs \|Min(X)\| refutation checks; polynomial for quantifier-free X, for X with an anchor, and for a single negative; exponential \|Min\| possible; open in general (open problem 3). Computed: \|Min\| = 1 in all 705 tests. | Prop 5.10, §10.3 |
| missing 4 | — | the Axiom of Choice (ZFC) not mentioned | **Added:** §7.2(b), u10. AC is a ground axiom; 12/12 cross templates refuted; DTRC on ZFC recovers 10 pure clusters in 3/3 seeds, schemas exact. | §7.2(b), u10 |
| missing 5 | — | the theory's fixed Ref_d does not match the implementation's template-specific search | **Resolved:** v2 implementation, audit and Prop 5.12. | §5.8 |
| required change 1 | — | Cor 3.3(b): add cross-separation | Done. | Cor 3.3 |
| required change 2 | — | replace the caveat with the finite-head-class observation; fix the root count | Done (Prop 3.4, plus Props 3.5, 3.6). | §3 |
| required change 3 | — | "O(n²) coherence tests" plus a per-test cost remark | Done (Thm 5.2(v), Prop 5.10). | §5.2 |
| required change 4 | — | Thm 5.4(d): a clean example | Done (u9, Remark 5.11). | §5.3 |
| required change 5 | — | Prop 5.6(e): oracle complete on closed instances and Ref_∞ | Done (plus Prop 5.13). | §5.4 |
| required change 6 | — | Thm 5.7: specify the oracle or use MRDP | Done (MRDP; full-Δ₀ variant noted). | §5.5 |
| required change 7 | — | implementation: global negative cache; remove the stale u5 comment | Done (v2 `dtrc.py`; comment removed; all outputs regenerated). | §5.8, §9 |

*Nothing was withdrawn except the v1 caveat after Corollary 3.3, which was false and is replaced by Prop 3.4.* Every other
v1 result stands. Some are restated with the hypotheses the referee identified (Cor 3.3(b), Prop 5.6(e), Thm 5.7's oracle,
Prop 5.9(d)).
