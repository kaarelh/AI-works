# Track "untagged": learning many axioms and axiom schemas at once from unlabelled instances

Track notes for the brief `../../00-brief.md` (questions Q1–Q3; method DTRC of brief §5). Author: Claude (Anthropic), for
Kaarel Hänni. Status labels: **proved** (complete proof here), **computed** (script run, command and output file named in
§9), **known** (literature, credited), **conjecture**, **hypothesis** (an assumption imported from another track or stated
for a theorem and not proved here). Code: `code/` in this directory. Every script was run in this session; outputs are the
`.out` files next to the scripts.

---------------------------------------------------------------------------------------------------------------------------

## 0. Results in brief

| # | result | status |
|---|---|---|
| U1 | **Pigeonhole theorem.** Exact bound k = k′, sound negatives that refute every template covering anchor data of two distinct targets ⇒ the cautious k-union learner is exact as soon as each target's data contain a *tagged* anchor. A finite set of ≤ μ·Σ_{i<j}\|A_i\|\|A_j\| negatives suffices (one refuted instance per minimal covering template of each cross anchor pair); the learner generates it itself from pair tests, under hypothesis W. | proved (W hypothesis) |
| U2 | **Spare slots (k > k′).** Splits are unrefutable: every hypothesis D ⊆ h ⊆ R* survives every sound negative. Under cross-separation the exact threshold is: each D_i not coverable by m = k−k′+1 negative-avoiding templates whose union misses an instance of σ_i. | proved |
| U3 | **Slot accounting** (generalizes the prior PA "k−1 failure sets"): with *absorption* (mixed slots contain σ_i), target i gets k − c_i slots, c_i = non-absorbing cover number of the other data. Raw DT° PA: c = 4 on positive data, c = 7 with three Δ₀ negatives {0=S0, a+0=0, a·0=S0}; exact version-space computations agree with κ = c + χ in 24/24 cases. | proved; computed |
| U4 | **A bound is necessary** (no bound ⇒ Acc = D for every sound negative set; Gold). | proved / known |
| U5 | **DTRC theorem.** (i) within-target merges are never refuted; (ii) under refutation separation at budget d the final clustering is the target partition for every merge order; the per-cluster cautious verifier is then sound at all times and exact once each cluster contains an anchor; failure probability = the tagged one; O(n²) coherence tests (n·k′ online). | proved (W) |
| U6 | **Residual merges.** Without separation: Acc ⊆ R* ∪ Res_d(D) (soundness relative to the residue of unrefuted cross templates); truth-sound if residual templates are truth-sound; exactness can fail by fragmentation. | proved |
| U7 | **∀xφ from instances is a sound cross merge.** Two instances φ(t₁), φ(t₂) with different head symbols are a DT° anchor for φ(z) (two-point lemma); DTRC merges the instances iff φ(z) has no refuted instance, and then accepts ∀xφ itself (closure-normal form). Truth-sound in ℕ, not in ℝ (¬(x·x=1+1)). | proved; computed |
| U8 | **Depth relativization is necessary**: no computable learner is sound (relative to the full-depth residue) at all times and eventually exact on every practice that is separated at some finite, unknown depth. | proved |
| U9 | **Whole-cluster tests**: coherence is downward closed but not transitive; single linkage builds incoherent clusters ({0+0=0, S0+0=S0, 0+S0=S0}); whole-cluster agglomeration keeps every cluster coherent; under separation all variants agree. | proved; computed |
| U10 | **Noise**: refutable mistakes are isolated and contribute nothing; under separation mistakes never bridge two targets; unrefutable mistakes can be absorbed (unsound) or fragment a target; robust variant (multiplicity threshold + trimmed verifier) is sound with ≤ e absorbed mistakes per cluster. | proved; computed |
| U11 | **MDL / size principle** (no negatives): determinacy makes the two-part code well defined. Naive uniform body code ⇒ MDL splits induction by main connective (proved: Δ ≤ C + O(log n) − n_ind(log₂A − log₂\|F\|) → −∞). Well-specified adaptive code ⇒ no linear gain from splitting (proved, standard coding facts) and computed preference for the true partition; misspecified adaptive codes (natural usage law) also split (computed, n ≥ 16000). | proved; computed |
| U12 | **PA**: every cross merge among Q1–Q7, induction, and the instance schemas of Q's axioms is refuted by Δ₀ evaluation with ∀-instantiation (4 distinct negatives suffice for U1); DTRC recovers the 8 targets exactly (3 seeds, 200/200 held-out inductions accepted, 0 false acceptances). | computed |
| U13 | **ZF**: every cross merge among Ext, Pair, Union, Power, Inf, Found, Separation, Replacement, ∈-induction is refuted by HF counterexamples or pure logic; Union+Power and Union/Power+Separation merge to naive comprehension, refuted by Russell's instance; DTRC recovers the 9 targets (3 seeds, 180/180 held-out schema instances, 0/30 naive-comprehension instances accepted). | computed |
| U14 | **Natural separation failures**: (a) sound merges (∀xφ; redundant axioms); (b) the weak (bounding) forms of Union and Power merge to the universal-set schema ∃x∀y(F(y)→y∈x), which is *unrefutable* by logic + HF counterexamples (model HF ∪ {u}) but refuted by coherence with one instance of Separation or with ∀x x∉x; DTRC repairs it by bootstrapped coherence with its own Separation cluster; (c) K₀-shaped templates (R1) are unrefutable but harmless in DT° unless the cluster lacks a sound alternative; (d) templates whose false instances are all consistent with the designated truths (Σ₁/Π₂-type) are a permanent residue (by the parent's results; no natural merge of this kind constructed). | proved; computed; (d) known in substance |

Main hypotheses imported: **(W)** finitely many minimal covering DT° templates, computable, and every covering template lies
above one (track 'single'; prior conjecture C8.3; here cross-validated by brute force, u0). **(A)** anchor theorems for the
DT° targets used (track 'single'; for T_ind proved in prior C3; for one-metavariable first-order patterns proved here, Lemma
5.5).

---------------------------------------------------------------------------------------------------------------------------

## 1. Setting

**Object language and data.** First-order formulas (arithmetic: 0, S, +, ·, =; set theory: ∈, =; connectives ¬ ∧ ∨ → ↔;
quantifiers ∀ ∃) in *closure-normal form*: free variables are *parameters* (names), read under universal closure; bound
variables are de Bruijn indices. S is the set of such formulas. In the code, data are canonicalized by renaming parameters
a1, a2, … in order of first occurrence.

**Templates (DT°).** As in the brief §3: second-order templates whose metavariables M : ι^n→o or ι^n→ι are applied to
metavariable-free argument terms, each metavariable having a pattern occurrence (rigid, applied to distinct bound variables in
scope). inst(T) ⊆ S is the set of β-normal instances under closed-up λ-bodies (free variables of bodies = parameters).
T ≼ T′ means inst(T) ⊆ inst(T′) (semantic order). Ground axioms are templates without metavariables. Matching is unique and
linear (prior C1).

**Targets and data.** Σ* = {σ_1,…,σ_k′} ⊆ DT°, R* = ⋃_i inst(σ_i). Data: a finite multiset D ⊆ R* with *hidden* labels,
D = D_1 ⊔ … ⊔ D_k′, D_i ⊆ inst(σ_i) (the datum's generating target; a datum in two instance sets carries one label). Text or
i.i.d. (each datum: target i with probability π_i, then an instance σ_iΘ, Θ ~ Λ_i).

**Truth and the refutation oracle.** Tr ⊆ S is the set of true formulas (closure true in ℕ, resp. in V); R* ⊆ Tr. The oracle
is a family Ref_0 ⊆ Ref_1 ⊆ … ⊆ S with
- **(OS) one-sided soundness:** Ref_d ∩ Tr = ∅ for all d (hence Ref_d ∩ R* = ∅);
- **(Dec):** for each d, "inst(T) ∩ Ref_d ≠ ∅" (*T is d-refuted*) is decidable uniformly in (T, d) (e.g. Ref_d contains only
  formulas of size ≤ d and is closed under renaming parameters).

Ref_∞ = ⋃_d Ref_d. Instances of the oracle used here (all sound, none complete; §7, §9): (R-Δ₀) ∀-instantiation of parameters
and universal quantifiers by numerals plus Δ₀ evaluation, existentials verified by witnesses, universals verified only by a
logic derivation (EUF plus the closed equations of ℕ); (R-HF) hereditarily finite counterexamples to Π₁-shaped instances,
sound by Δ₀ absoluteness (HF is transitive); (R-logic) logical falsity, certified by a propositionally unsatisfiable set of
ground instances of the Skolem form (Herbrand); (R-coh) coherence: R-logic applied to the formula together with designated true
sentences. These are the parent report's world and coherence channels (lem:twotier:onesided: refutation is one-sided and
target-blind).

**Hypothesis classes.** H_k = {⋃_{l≤k} inst(τ_l) : τ_l ∈ DT°}. For a finite N ⊆ S (found negatives) the version space is
VS_k(D,N) = {h ∈ H_k : D ⊆ h, h ∩ N = ∅} and the *cautious k-union learner* accepts Acc_k(D,N) = ⋂VS_k(D,N).

**Covering templates.** For finite nonempty X ⊆ S: Cov(X) = {T ∈ DT° : X ⊆ inst(T)}; Min(X) its ≼-minimal members (one per
equivalence class).

> **Hypothesis (W)** [track 'single'; prior conjecture C8.3]. For every finite nonempty X ⊆ S, Min(X) is finite and
> computable from X, and every T ∈ Cov(X) satisfies T ≽ T₀ for some T₀ ∈ Min(X).
>
> **Consequence (W′).** If X ⊆ inst(σ) with σ ∈ DT°, some T₀ ∈ Min(X) has inst(T₀) ⊆ inst(σ). *Proof:* σ ∈ Cov(X); apply (W). ∎

(W) is stated semantically (≼); a syntactic version (T = T₀ρ for a substitution ρ) implies it. **Computed support (u0):** the
slot/derivation enumerator `dtlib.mincov` (§9) was compared with the prior brute-force enumerator of all DT° covering
templates (prior `so_enum.py`, complete within size and argument bounds) on 8 pairs of induction instances: at size ≤ 16 and
at size ≤ 20 every brute-force covering template lies above a template returned by `mincov` (0 counterexamples). A first
version of `mincov` that kept every "root" slot as a source *failed* this check on {Ind(x=x), Ind(Sx=S0)} (20
counterexamples); the fixed version lets derived occurrences at common nodes remove root slots (§9).

**Anchors.** A finite A ⊆ inst(σ) is an *anchor* for σ (in DT°) if every T ∈ Cov(A) satisfies T ≽ σ. This is the tagged
(single-template) notion of the brief and the parent report (def:imitation:anchor with H = H_1 over DT°).

> **Hypothesis (A)** [track 'single']. Each non-ground target used below has finite anchors characterized by witness
> events. Known instances: T_ind (prior C3: anchor ⟺ (R) roots not all equal and (N) some motive has x free); ground σ:
> A = {σ}; one-metavariable first-order patterns: Lemma 5.5 below (proved).

**Lemma 1.1 (cautious soundness; trivial; known in substance).** If k ≥ k′, D ⊆ R* and N ∩ R* = ∅, then R* ∈ VS_k(D,N),
so Acc_k(D,N) ⊆ R*. Acc_k is monotone in D and in N.
*Proof.* R* = ⋃ inst(σ_i) ∈ H_k, contains D, avoids N. Larger D or N shrink VS. ∎ (lem:imitation:cautious(a),
thm:caution:vs(a) of the parent report.)

**Lemma 1.2 (finite form of the k-union verifier; proved).** Assume (W). Let Min_N(B) = {T ∈ Min(B) : inst(T) ∩ N = ∅}. Then
Acc_k(D,N) = ⋂ { ⋃_{B∈π} inst(T_B) : π a partition of D into ≤ k blocks, T_B ∈ Min_N(B) }
(empty intersection = S). In particular membership in Acc_k(D,N) is decidable (exponential in |D|).
*Proof.* Each displayed union lies in VS_k(D,N), so ⊇ holds for Acc. Conversely let h = ⋃_l inst(τ_l) ∈ VS. Assign each datum
to the first slot covering it; this partitions D into ≤ k blocks B ⊆ inst(τ_l). By (W) τ_l ≽ T_B for some T_B ∈ Min(B), and
inst(T_B) ⊆ inst(τ_l) ⊆ h avoids N, so T_B ∈ Min_N(B) and h ⊇ ⋃ inst(T_B). Hence ⋂VS ⊇ the displayed intersection. ∎

---------------------------------------------------------------------------------------------------------------------------

## 2. The pigeonhole theorem (k = k′)

**Theorem 2.1 (pigeonhole; proved).** Let k = k′, D ⊆ R*, and for each i let A_i ⊆ D_i be an anchor for σ_i (nonempty). Let
N ⊆ S with N ∩ R* = ∅ satisfy

 **(X)** for all i ≠ j, a ∈ A_i, b ∈ A_j and every T ∈ DT° with a, b ∈ inst(T): inst(T) ∩ N ≠ ∅.

Then Acc_k(D,N) = R*.

*Proof.* "⊆" is Lemma 1.1. "⊇": let h = ⋃_{l≤k} inst(τ_l) ∈ VS_k(D,N) (fewer than k slots allowed). For each i put
L_i = {l : τ_l covers some element of A_i}; L_i ≠ ∅ since A_i ⊆ D ⊆ h and A_i ≠ ∅. If l ∈ L_i ∩ L_j with i ≠ j, τ_l covers
some a ∈ A_i and b ∈ A_j, so by (X) inst(τ_l) meets N, contradicting h ∩ N = ∅. So L_1,…,L_k′ are nonempty, pairwise disjoint
subsets of a set of at most k = k′ slots: each L_i is a singleton {l_i}. Then τ_{l_i} covers all of A_i (every element of A_i
is covered by some slot, which must be in L_i), so τ_{l_i} ≽ σ_i because A_i is an anchor. Hence h ⊇ ⋃_i inst(σ_i) = R*. As h
was arbitrary, Acc ⊇ R*. ∎

*Remarks.* (1) (X) forces the A_i to be pairwise disjoint: if a ∈ A_i ∩ A_j the ground template a covers a, a and
inst(a) = {a} ⊆ R* cannot meet N. (2) For a non-ground σ_i every anchor has ≥ 2 elements (the ground template s covers {s}
and misses the rest of inst(σ_i)). (3) Only anchor data matter; the rest of D can be anything in R*. (4) The theorem uses
nothing about DT° except that anchors are defined in the same class as the slots.

**Corollary 2.2 (a finite set of negatives, generated without labels; proved under (W)).**
(a) Let P_× = {(a,b) : a ∈ A_i, b ∈ A_j, i < j}. Suppose *anchor-pair separation at depth d*: every T ∈ Min({a,b}),
(a,b) ∈ P_×, is d-refuted. Choose n_T ∈ inst(T) ∩ Ref_d for each such T. Then N_× = {n_T} satisfies (X) and
|N_×| ≤ μ·Σ_{i<j}|A_i||A_j|, μ = max_{P_×}|Min({a,b})|.
(b) The learner, which does not know the labels, can compute N(D,d) = {first d-refuted instance of T : T ∈ Min({a,b}),
a, b ∈ D} (computable by (W) and (Dec)). N(D,d) ⊆ Ref_d is sound by (OS), and N(D,d) ⊇ (a choice of) N_×. Hence the cautious
k′-union learner with self-generated negatives, Acc_k′(D, N(D,d)), is sound at all times (Lemma 1.1) and exact as soon as D
contains anchors, under anchor-pair separation at depth d. Its acceptance is decidable (Lemma 1.2).

*Proof.* (a) If T′ covers a ∈ A_i and b ∈ A_j then T′ ∈ Cov({a,b}), so T′ ≽ T for some T ∈ Min({a,b}) by (W), and
n_T ∈ inst(T) ⊆ inst(T′). (b) N(D,d) contains a d-refuted instance of every d-refuted minimal covering template of every pair of
data, in particular of every T ∈ Min({a,b}), (a,b) ∈ P_×. Within-target pairs may contribute further negatives (refuted
minimal templates that are not below σ_i); they are false sentences, so harmless. Apply Theorem 2.1. ∎

**Example 2.3 (PA, raw DT° encoding; computed, u1).** Targets: Q1–Q7 in closure-normal form (parameters a1, a2) and T_ind,
k′ = 8. Anchors: {Q_i}; for induction any two instances with (R) and (N) (prior C3). For every cross pair tested (21 Q–Q
pairs, 7×4 Q–Ind pairs) Min has exactly one element and it is d-refuted at small depth; the minimal templates are F0 (bare
formula metavariable), F0→F1, t0=t1, (a1+t0)=t1, (a1·t0)=t1, refuted by just four sentences:
0=S0, (0=0→0=S0), (a1+0)=0 [a1:=1], (a1·0)=S0 [a1:=0]. So **four negatives make untagged PA as easy as tagged PA at
k = 8**: exact after one occurrence of each Q_i and two induction instances with different main connectives, at least one
non-vacuous. (Theorem 4.1 below shows three suffice, because mixed Q/induction slots are absorbing.)

---------------------------------------------------------------------------------------------------------------------------

## 3. Spare slots (k > k′)

**Theorem 3.1 (splits are unrefutable; proved).** For every N with N ∩ R* = ∅ and every k ≥ k′,
VS_k(D,N) ⊇ VS_k^⊆(D) := {h ∈ H_k : D ⊆ h ⊆ R*}, hence Acc_k(D,N) ⊆ ⋂VS_k^⊆(D).
So if some h ∈ H_k with D ⊆ h ⊆ R* misses q ∈ R*, no sound negative evidence whatever makes the learner accept q.
*Proof.* h ⊆ R* and N ∩ R* = ∅ give h ∩ N = ∅. ∎

A *split* is the typical such h: replace σ_i by finitely many specializations T_1,…,T_m (inst(T_j) ⊆ inst(σ_i)) that together
cover D_i. Specializations are sound (their instances are target instances), so refutation, which is one-sided, can never
remove them. This is the untagged face of lem:twotier:onesided ("refutation never condemns a subset of the target").

**Theorem 3.2 (exact threshold under cross-separation; proved).** Let k ≥ k′, every D_i ≠ ∅, N ∩ R* = ∅, and suppose N
*cross-separates* D: every T ∈ DT° covering a datum of D_i and a datum of D_j (i ≠ j) meets N. Put m = k − k′ + 1.
(a) If for every i, every family F of at most m templates with ⋃inst(F) ⊇ D_i and ⋃inst(F) ∩ N = ∅ has ⋃inst(F) ⊇ inst(σ_i),
then Acc_k(D,N) = R*.
(b) If for some i there is such a family F (|F| ≤ m, covering D_i, avoiding N) and q ∈ inst(σ_i) with
q ∉ ⋃inst(F) ∪ ⋃_{l≠i} inst(σ_l), then q ∉ Acc_k(D,N).
(c) If the instance sets inst(σ_i) are pairwise disjoint, the condition of (a) is necessary and sufficient for exactness.

*Proof.* (a) Let h ∈ VS with slots τ_l. A slot covering a datum of D_i covers no datum of D_j (j ≠ i), by cross-separation.
Let L_i = {l : τ_l covers a datum of D_i}: nonempty and pairwise disjoint, so |L_i| ≤ k − (k′−1) = m. The slots in L_i cover
D_i and avoid N, so ⋃_{l∈L_i} inst(τ_l) ⊇ inst(σ_i). Hence h ⊇ R*. (b) h = ⋃inst(F) ∪ ⋃_{l≠i} inst(σ_l) ∈ H_k (at most
m + k′ − 1 = k slots), contains D, avoids N (the σ_l are in R*), misses q. (c) If (a)'s condition fails for i, some admissible F
misses some q ∈ inst(σ_i), and q ∉ inst(σ_l) for l ≠ i by disjointness; apply (b). ∎

**Corollary 3.3 (the threshold in terms of failure specializations; proved).** Call T a *proper specialization* of σ if
inst(T) ⊊ inst(σ). A *failure family* for σ is a set Fail(σ) of proper specializations such that every non-anchor finite
X ⊆ inst(σ) lies in inst(F) for some F ∈ Fail(σ) (for first-order patterns: Plotkin's sets σ[x↦f(z̄)], σ[y↦x] of
thm:imitation:untagged; for T_ind: T_ind[P:=λx.f(P̄(x))] for each formula constructor f, and T_ind[P:=λx.A] for vacuity, by
prior C3).
(a) *Necessity, whatever the negatives.* If D_i ⊆ inst(F_1) ∪ … ∪ inst(F_m) with F_j ∈ Fail(σ_i) and some
q ∈ inst(σ_i) \ ⋃_j inst(F_j) lies in no other inst(σ_l), then q ∉ Acc_k(D,N) for every sound N (Theorem 3.1 with
h = ⋃ inst(F_j) ∪ ⋃_{l≠i} inst(σ_l)).
(b) *Sufficiency under target-separation.* Suppose N meets every template that covers a datum of D_i and is ≼-incomparable
with σ_i. Then the N-avoiding templates covering D_i-data are proper specializations or ≽ σ_i, and (a) of Theorem 3.2 holds iff
D_i is not covered by ≤ m proper specializations of σ_i whose union misses an instance of σ_i. Each block D_i ∩ inst(T_j) of such
a cover is a non-anchor, hence inside some F ∈ Fail(σ_i); so if no m members of Fail(σ_i) cover inst(σ_i) ("m-noncovering
failure family"), exactness ⟺ D_i is not covered by m members of Fail(σ_i).
*Proof.* (a) as stated. (b) Assume also disjoint instance sets (Theorem 3.2(c)). If exactness fails, some N-avoiding family
of ≤ m templates covers D_i and misses some q ∈ inst(σ_i); none of its members is ≽ σ_i, so by target-separation all are proper
specializations T_j. Each block X_j = D_i ∩ inst(T_j) is covered by T_j ⋡ σ_i, so X_j is not an anchor and lies in inst(F_j)
for some F_j ∈ Fail(σ_i): D_i is covered by m members of Fail. Conversely, if D_i ⊆ inst(F_1) ∪ … ∪ inst(F_m) with
F_j ∈ Fail(σ_i), m-noncovering gives q ∈ inst(σ_i) outside the union, and (a) applies. ∎

*Caveat (important for PA).* Plotkin's failure family for a first-order pattern is m-noncovering for every m when every
metavariable can be instantiated by infinitely many head symbols (true for term metavariables in closure-normal form, since
parameters are infinitely many names). The failure family of T_ind is **not**: the seven root specializations (=, ¬, ∧, ∨, →,
∀, ∃) cover all of Ind. Then exactness with m ≥ 7 slots for induction depends on second-level failure events inside each
root class (the "recursion" noted by the prior referees). This is open in general (§10).

---------------------------------------------------------------------------------------------------------------------------

## 4. Slot accounting: the general threshold, without or with negatives

**Theorem 4.1 (slot accounting; proved).** Fix a target i, a bound k, data D ⊆ R* and a sound N. Write D̄_i = D \ D_i. Assume
 **(Abs)** every N-avoiding template that covers a datum of D_i and a datum of D̄_i satisfies inst(T) ⊇ inst(σ_i).
Let c_i be the least number of N-avoiding templates T with inst(T) ⊉ inst(σ_i) whose instance sets cover D̄_i.
(a) If every family of at most k − c_i N-avoiding templates covering D_i has union ⊇ inst(σ_i), then inst(σ_i) ⊆ Acc_k(D,N).
(b) If some family F of at most k − c_i N-avoiding templates covers D_i and misses q ∈ inst(σ_i), and some optimal cover G
(|G| = c_i) of D̄_i misses q too, then q ∉ Acc_k(D,N).

*Proof.* (a) Let h ∈ VS_k(D,N) with slots τ_l. If some slot contains inst(σ_i) we are done. Otherwise no slot is *mixed* (covers
data of both D_i and D̄_i), by (Abs). The slots covering D̄_i-data then form an N-avoiding cover of D̄_i by templates not
containing inst(σ_i), so there are at least c_i of them, and the at most k − c_i remaining slots cover D_i; by hypothesis their
union contains inst(σ_i). (b) ⋃inst(F ∪ G) ∈ VS_k(D,N) misses q. ∎

**Corollary 4.2 (special cases).**
(1) *Prior PA result, Sub-encoded steps* (prior pa-untagged, referee-proved): ground premise-free steps G plus σ_ind; a slot
mixing a G-step and an induction step is a bare metavariable (Abs), and lgg(G) = st(∀x Z) covers no induction step, so
c = 1: threshold "D_ind not covered by k−1 failure sets".
(2) *Cross-separation* (Theorem 3.2): (Abs) holds vacuously, and with disjoint instance sets c_i = k′−1 (each N-avoiding
template covers data of at most one other target, and the σ_l themselves are a cover), giving m = k−k′+1.
(3) *Raw DT° PA* (sentences in closure-normal form; computed, u2): (Abs) holds — every minimal covering template of a Q-axiom
and an induction instance contains T_ind (F0 when the Q-axiom's root is not →; F0→F1 for Q2, Q7; checked for all 7 axioms × 4
motives, and proved: the two antecedent and two consequent contents differ and are closed, so the only minimal template is
F0→F1). The non-absorbing cover number of {Q1,…,Q7} is
 - **c = 4 on positive data** ({Q3,Q4,Q5,Q6} share t0=t1; Q1, Q2, Q7 must be alone, since any template covering two of
   {Q1,Q2,Q7} is F0 or F0→F1, both absorbing);
 - **c = 7 with refutation**, and already with the three negatives {0=S0, (a1+0)=0, (a1·0)=S0}.
So at k = k′ = 8 on positive data induction gets 4 slots: by prior C3 a block of induction data is coverable by a template not
containing Ind iff it is root-homogeneous or all vacuous, so an unseen-connective induction is accepted iff
χ(D_ind) > k − 4, χ = least number of root-homogeneous or all-vacuous blocks; i.e. the corpus needs ≥ 5 distinct main
connectives. With the three negatives induction gets k − 7 = 1 slot and the tagged anchor (R)+(N) suffices.
*Computed check (u2):* for 4 ground subsets × 2 settings (with/without refutation) × 3 unseen-connective queries, the exact
version-space quantity κ(q) = least number of "ok" blocks covering D (a block is ok if some (unrefuted) minimal covering template
misses q; q ∉ Acc_k ⟺ κ(q) ≤ k) equals c + χ in **24/24 cases**.

**Proposition 4.3 (a bound is necessary; proved; Gold 1967 known).** Let H_∞ = ⋃_k H_k. For every finite D ⊆ R* and every
sound N, Acc_∞(D,N) = D. Moreover no learner, however it uses a sound oracle, identifies H_∞ in the limit from text.
*Proof.* D is a finite union of ground templates, D ∈ H_∞, D ∩ N = ∅ (D ⊆ R* ⊆ Tr); so Acc_∞ ⊆ D, and ⊇ is trivial. For the
second claim take a non-ground true σ: the class contains inst(σ) and all its finite subsets (all ⊆ Tr). The oracle's answers
are a fixed function of the query (OS gives the same answers for every target inside Tr; lem:twotier:onesided(c)), so it adds
no information distinguishing these targets, and Gold's theorem on superfinite classes applies. ∎

*Reading.* Negatives cannot replace a bound: they refute false sentences, and every finite set of true data is itself a
consistent hypothesis. What negatives do is remove *over-general lumps*, which turns the slot budget of the k-union learner into
the tagged budget (Theorems 2.1, 4.1). What a bound does is forbid *splits*; DTRC (next section) replaces the bound by a
different assumption, refutation separation.

---------------------------------------------------------------------------------------------------------------------------

## 5. DTRC: Determinate Templates with Refutation Clustering

### 5.1 Definition

Fix a refutation budget d. A finite X ⊆ S is **d-coherent** if some T ∈ Min(X) is not d-refuted. By (W) this is
equivalent to: some T ∈ Cov(X) is not d-refuted (every covering template lies above a minimal one, and a template above a
d-refuted one is d-refuted, its instance set being larger).

**Algorithm DTRC_d.**
1. *Normalize* each datum to closure-normal form (parameters canonically named, bound variables de Bruijn).
2. *Agglomerate.* Start from singleton clusters (duplicates merged; multiplicities kept). Repeatedly choose, by a *merge
   policy*, two current clusters C ≠ C′ with C ∪ C′ d-coherent, and replace them by C ∪ C′. Stop when no pair of clusters
   has a d-coherent union. (Policies used: *online* — process data in order, put each datum into the first cluster it is
   coherent with, else open a new cluster, then merge clusters pairwise to a fixpoint; *most-specific-first* — among
   coherent pairs, merge the one whose merged minimal templates are smallest in instance set.)
3. *Verify per cluster.* For a final cluster C let Min_d^+(C) = {T ∈ Min(C) : T not d-refuted} and
   Acc_d(C) = ⋂_{T ∈ Min_d^+(C)} inst(T), with Acc_d(C) := ∅ if Min_d^+(C) = ∅ (an incoherent singleton).
4. *Assert* Acc_d = ⋃_C Acc_d(C). (Optional robust step, §5.7: assert only clusters of multiplicity ≥ s and use the
   e-trimmed verifier.)

Acc_d(C) is the cautious H_1-verifier of the cluster with negatives Ref_d: every N-avoiding covering template is above an
N-avoiding minimal one, so ⋂{inst(T) : T ∈ Cov(C), inst(T) ∩ Ref_d = ∅} = Acc_d(C). With (W) and (Dec) every step is
computable.

**Lemma 5.1 (monotonicity; proved).** d-coherence is downward closed (Y ⊆ X, X d-coherent ⇒ Y d-coherent) and antitone in d.
*Proof.* A non-d-refuted T ∈ Cov(X) is in Cov(Y). Ref_d ⊆ Ref_{d+1}. ∎

### 5.2 Separation: the main theorem

**Definition (refutation separation).** Σ* is *d-separated on D* (RS_d(D)) if every T ∈ DT° covering a datum of D_i and a datum
of D_j, i ≠ j, is d-refuted. It is *globally d-separated* (RS_d) if every T covering an instance of σ_i and an instance of
σ_j (i ≠ j) is d-refuted; then RS_d(D) holds for every D ⊆ R*, and the inst(σ_i) are pairwise disjoint. By (W),
RS_d(D) ⟺ every T ∈ Min({a,b}) is d-refuted for every cross pair (a,b) ∈ D_i × D_j, a finite check.

**Theorem 5.2 (DTRC; proved under (W), (OS), (Dec)).**
(i) *Within-target merges are never refuted.* If X ⊆ inst(σ_i) then X is d-coherent for every d; indeed some T₀ ∈ Min(X) has
inst(T₀) ⊆ inst(σ_i) and is never refuted.
(ii) *Separation recovers the labels.* If RS_d(D) holds and every D_i is nonempty, then for every merge policy the final
clustering is {D_1, …, D_k′} (as sets).
(iii) *Soundness at all times, exactness from anchors.* Under RS_d(D): Acc_d ⊆ R*, and Acc_d = R* as soon as each D_i contains
an anchor of σ_i.
(iv) *Rates.* Under global RS_d and i.i.d. data, P[Acc_d ≠ R*] ≤ Σ_i P[D_i contains no anchor], the failure probability of the
*tagged* per-rule learner. For first-order pattern targets whose DT° anchors are Plotkin's (R)+(D) (hypothesis (A)) this is ≤ Σ_i c_i(1−π_iρ_i)^N
(thm:imitation:coupon), for T_ind
Σ_f p_f^N + (1−q)^N − Σ_f r_f^N given n induction samples (prior C5(b)), averaged over n ~ Bin(N, π_ind).
(v) *Cost.* With caching, the pairwise fixpoint makes O(n²) coherence tests (n distinct data): at most n − 1 merges, each
invalidating the cached answers of O(n) pairs. Under RS_d the online policy makes at most n·k′ tests.

*Proof.* (i) By (W′) some T₀ ∈ Min(X) satisfies inst(T₀) ⊆ inst(σ_i) ⊆ R* ⊆ Tr, so inst(T₀) ∩ Ref_d = ∅ by (OS).
(ii) Call a cluster *pure* if it lies inside one D_i. Initially all clusters are pure. If C ⊆ D_i and C′ ⊆ D_j are pure with
i ≠ j, every T ∈ Cov(C ∪ C′) covers a datum of D_i and one of D_j, so is d-refuted by RS_d(D): C ∪ C′ is not d-coherent and
is never merged. So all clusters stay pure. At termination, two final clusters inside the same D_i would have a d-coherent union
by (i), contradicting termination. Hence each nonempty D_i is exactly one final cluster.
(iii) Final cluster D_i: the T₀ of (i) is in Min_d^+(D_i), so Acc_d(D_i) ⊆ inst(T₀) ⊆ inst(σ_i). If A_i ⊆ D_i is an anchor,
every T ∈ Min(D_i) covers A_i, hence T ≽ σ_i, so Acc_d(D_i) ⊇ inst(σ_i) (the index set Min_d^+(D_i) is nonempty by (i)).
(iv) Under global RS_d, (ii)–(iii) hold for every D, so DTRC fails to be exact only if some D_i lacks an anchor — the same event
as for the tagged learner given the labels; average the tagged bound over the binomial count of target-i samples.
(v) A pair answer depends only on the two clusters; after merging C, C′ only pairs involving the new cluster need retesting
(≤ n). The online policy tests each new datum against ≤ k′ clusters, all pure. ∎

*Reading.* Under separation, refutation does the job the citation (tag) does in tagged data: it tells the learner which
instances belong together. Within each recovered cluster the learner is the tagged cautious learner, so everything known about
tagged rates and anchors transfers verbatim. DTRC needs no bound k: the number of targets is discovered.

**Remark 5.3 (relation to the k-union learner; proved).** The k-union learner with self-generated negatives (Corollary 2.2) is
target-sound at all times whenever k ≥ k′, *with or without separation* (Lemma 1.1); DTRC is target-sound only under
separation (Theorem 5.4 below shows how it fails otherwise) but needs no k. Under RS_d(D), anchors in every D_i, and k = k′,
both accept exactly R*. A practical combination when k is known: accept q iff both accept q — target-sound whenever k ≥ k′,
and exact when DTRC is exact and k = k′ (Theorem 2.1, since RS_d(D) implies (X) for N(D,d)).

### 5.3 Without separation: residual merges

**Theorem 5.4 (soundness relative to a residue; proved).** Let a final cluster be *mixed* if it contains data of two or more
targets. Define the depth-d residue of D,
Res_d(D) = ⋃{ inst(T) : T ∈ Min(X) not d-refuted, X ⊆ D d-coherent and mixed }.
(a) Acc_d ⊆ R* ∪ Res_d(D); more precisely, pure final clusters contribute ⊆ R* (as in 5.2(iii)) and a mixed final cluster C
contributes ⊆ inst(T) for every T ∈ Min_d^+(C).
(b) If every mixed final cluster has some *truth-sound* T ∈ Min_d^+(C) (inst(T) ⊆ Tr), then Acc_d ⊆ Tr (truth-sound, though
not target-sound: it accepts true sentences outside R*). Such merges are called *sound merges*.
(c) If the only non-refuted minimal templates of a mixed cluster have false instances, they are *unrefuted unsound merges*;
Acc_d is then sound only relative to Res_d(D). Res_d(D) decreases in d; Res_∞(D) consists of templates with no refutable
instance at all.
(d) Exactness can fail even when every target's data contain anchors: a mixed cluster may absorb part of D_i and leave the
remainder without an anchor (fragmentation; example in §5.7), and the outcome depends on the merge policy.
*Proof.* (a) A pure cluster C ⊆ D_i contributes ⊆ inst(σ_i) by (W′); a mixed cluster contributes ⊆ inst(T) for its
non-refuted minimal templates, which belong to Res_d(D) (take X = C). (b) Acc_d(C) ⊆ inst(T) ⊆ Tr. (c), (d) by definition and
example. ∎

Three kinds of residual merge should be distinguished; examples in §7.
- *Target-sound merges*: some T ∈ Min_d^+(C) lies below a single σ_i (redundant targets, e.g. an axiom that is an instance of
  another target schema). Harmless.
- *Sound merges*: T truth-sound but not below any target. **Learning ∀xφ from instances is exactly this case** (§5.4).
- *Unsound unrefuted merges*: K₀-like templates and the weak-Union/Power universal-set template (§7.3); in general, templates
  whose false instances are all consistent with the designated truths (Σ₁/Π₂-type residues of the parent report).

### 5.4 Learning ∀xφ from its instances

**Lemma 5.5 (two-point anchors for one-variable patterns; proved).** Let φ(z) be a template whose only metavariable is a
0-ary metavariable z (term or formula sort) occurring at least once, and let t₁, t₂ be closed instantiations (terms with
parameters, resp. formulas) whose head symbols differ. Then {φ(t₁), φ(t₂)} is an anchor for φ(z) in DT°: every
T ∈ Cov({φ(t₁), φ(t₂)}) has inst(T) ⊇ inst(φ(z)). Consequently φ(z) is the least covering template (Min = {φ(z)} up to
equivalence) of any set of instances containing two with different heads.

*Proof.* (1) *Two-point identity.* If G(z), K(z) are expressions in which z occurs only as a leaf and G(t₁) = K(t₁),
G(t₂) = K(t₂), then G = K. Induction on G and K: if G = z and K ≠ z, then K has a rigid head h, and K(t_j) = t_j forces
h = head(t₁) and h = head(t₂), contradiction; symmetrically for K = z; if neither is z, their heads agree (compare at t₁)
and we recurse into the arguments (binders included: z is not a bound variable).
(2) *Skeleton.* The two data agree everywhere except at and below the z-positions of φ, where the heads differ. By the
rigid-prefix lemma (prior C2(a)) the rigid skeleton of T avoids the z-positions and everything below them.
(3) *Bodies.* For each metavariable M of T choose a pattern occurrence M(ȳ) at rigid position p. Given any instantiation t of
z, put θ_t(M) := λȳ.(φ(t)|_p) (abstracting ȳ). This is a legal body: the bound variables free in φ(t)|_p are those free in
φ(t₁)|_p (t has none), which are among ȳ because T covers φ(t₁).
(4) *Every occurrence fits.* For an occurrence M(ū) at rigid position p′ put G(z) := (λȳ.φ(z)|_p)(ū) and K(z) := φ(z)|_{p′}.
Since T covers both data and substitution of the closed t_j commutes with abstraction and plugging, G(t_j) = K(t_j) for
j = 1, 2; by (1) G = K, so G(t) = K(t). Together with (2), Tθ_t = φ(t). Hence inst(T) ⊇ inst(φ(z)). ∎

(For first-order patterns with several metavariables the expected DT° anchor condition is Plotkin's (R)+(D); that is track
'single''s anchor theorem and is used here only as hypothesis (A). The computed check u1(b2) agrees on the instance schemas
of Q's axioms.)

**Proposition 5.6 (∀xφ from instances; proved).** Let φ(z) be as in Lemma 5.5 with z a term metavariable, and let the data be
closed instances D = {φ(t₁),…,φ(t_n)}, at least two with different heads. Regard each datum as its own ground "target" (k′ = n).
(a) D is d-coherent iff φ(z) is not d-refuted.
(b) inst(φ(z)) contains φ(a) for a parameter a, which in closure-normal form *is the sentence ∀xφ(x)*; so φ(z) is truth-sound
iff ∀xφ(x) is true (instances with other terms then follow by ∀-elimination).
(c) If ∀xφ is true, every pair of data with different heads is a sound cross merge: RS fails, DTRC puts D into one cluster
(any policy: all subsets are coherent), and Acc_d ⊇ inst(φ(z)) ∋ ∀xφ — the axiom ∀xφ is learned from instances, and nothing
false is accepted. Target-soundness relative to the n ground "targets" fails, as it must: the n instances and the axiom
∀xφ produce the same data and the same refutation answers (target-blindness, lem:twotier:onesided(c)).
(d) If ∀xφ is false and some instance of φ(z) is d-refuted, the merge is refused and DTRC keeps the instances apart (it may
still merge root-homogeneous subsets into an unrefuted specialization such as φ(S z)).
(e) *Which structures.* If the oracle refutes only closed instances (R-Δ₀ without logic), then "no instance refuted" means
"φ(t) true for every closed t". In ℕ every element is the value of a closed term, so this implies ∀xφ: the merge is
truth-sound (this is the ω-rule, sound in ℕ, not derivable: Q ⊢ 0+n̄=n̄ for each n but Q ⊬ ∀x(0+x=x)). In a structure that is
not pointwise closed-term-definable it fails: in the ordered field ℝ with 0, 1, +, · every closed term denotes a natural number,
so ¬(t·t = 1+1) holds for every closed t while ∀x¬(x·x = 1+1) is false; the merged template ¬(z·z = 1+1) is then an
**unsound unrefuted merge** for an oracle that evaluates closed sentences only (a decision procedure for RCF would refute it).
*Proof.* (a) Lemma 5.5: φ(z) is the least covering template. (b) closure-normal form. (c) (a)+(b)+Lemma 5.1; target-blindness
because the oracle is a fixed function of the query. (d) (a). (e) as stated (the ℝ facts are elementary). ∎

*Computed (u6):* numeral instances of Q3, Q4, Q5 treated as 12 separate ground targets: DTRC forms three clusters with
templates (t0+0)=t0, (t0·0)=0, (t0+St1)=S(t0+t1), and accepts (a1+0)=a1 (the axiom ∀x(x+0=x)), S⁷0+0=S⁷0 and the other two
axioms. Instances of the *false* universal n·n = n (true for n = 0, 1): the merged template (t0·t0)=t0 is refuted by q1:=2 and
the instances stay apart (2·2=2 not accepted). Instances ¬(n·n = 2), n = 0,1,2: merged, unrefuted, and the universal
¬(a1·a1 = 2) is accepted (true in ℕ).

So the answer to Q1 in the untagged setting: **yes**, the same method learns ∀xφ from instances φ(t), and it does so by a
*sound merge*: what certifies it is not a derivation but the absence of a counterexample, which is truth-sound exactly in
term-generated structures such as ℕ (the ω-rule) and in general only relative to the strength of the refutation oracle.

### 5.5 Depth relativization is necessary

The budget d is a real parameter: separation may only appear at a depth nobody can bound in advance.

**Theorem 5.7 (proved; adapts thm:twotier:depth).** There is a uniformly computable family of practices — each a finite set of
DT° targets in the language of arithmetic with a data law, all with the same fixed sound oracle (R-Δ₀) — such that no
computable learner achieves, for every *valid* practice P in the family (valid: all target instances true) and some δ < ½:
(a) *soundness relative to the full-depth residue at all times*: P[∃t: Acc_t ⊄ R*_P ∪ Res_∞(P)] ≤ δ, where Res_∞(P) is the
union of inst(T) over templates T that cover instances (in the support of the data law) of two distinct targets of P and have
no refutable instance; and
(b) *eventual exactness on separated practices*: if P is separated at some finite depth and each target's data law gives an
anchor with positive probability, then P[∃t ∀t′ ≥ t: Acc_{t′} = R*_P] ≥ 1 − δ.

*Construction.* Let H_e(z) be a Δ₀ formula expressing "z codes a halting computation of machine e on input e" (Kleene's T
predicate; Δ₀-definable, known), with the coding chosen so that 0 and 1 code no computation, and z occurring in H_e. Put
T_e := ¬H_e(z), A_e := ¬H_e(0), B_e := ¬H_e(S0), q_e := ¬H_e(SS0). Practice P_e: one target {T_e}; practice P′_e: two ground
targets {A_e, B_e}; both with the data law uniform on {A_e, B_e}.
*Facts.* (1) A_e, B_e are true, so P′_e is always valid. (2) P_e is valid iff e ∉ K (K the halting set): the instances of T_e are
¬H_e(t) for terms t and, in closure-normal form, ∀a¬H_e(a); all are true iff φ_e(e) diverges. (3) {A_e, B_e} is an anchor
for T_e (Lemma 5.5: heads 0 and S differ), so every template covering A_e and B_e contains inst(T_e). (4) If e ∈ K with
halting code c, the instance ¬H_e(c̄) is a false Δ₀ sentence, refuted at some depth d_e; by (3) every cross template of P′_e is
then d_e-refuted: P′_e is separated at depth d_e and Res_∞(P′_e) = ∅. (5) If e ∉ K, T_e is truth-sound, never refuted, and
Res_∞(P′_e) ⊇ inst(T_e) ∋ q_e; P′_e is not separated at any depth, so (b) asks nothing of it. (6) P_e (e ∉ K) has a single
target, so it is separated (vacuously) at depth 0, and its data contain the anchor {A_e, B_e}.
*Reduction.* Let S = {e : ∃t P[the learner accepts q_e at time t] > ½}. If e ∉ K, (b) for P_e gives eventual acceptance of
q_e ∈ inst(T_e) with probability ≥ 1 − δ > ½, so e ∈ S. If e ∈ K, (a) for P′_e (R* = {A_e, B_e}, Res_∞ = ∅, q_e ∉ R*) gives
P[q_e ever accepted] ≤ δ < ½, so e ∉ S. Hence S = ω \ K. But the learner, the data law and the oracle are computable uniformly
in e, so P[accept q_e by time t] is computable from (e, t) and S is Σ₁. The complement of the halting set is not Σ₁. ∎

*Reading.* (a) is satisfiable on P′_e with e ∉ K (accepting q_e is allowed there, it is in the residue), so the obstruction is
not information-theoretic: it is the Π₁-completeness of "this cross merge is never refuted". DTRC with a depth schedule
d_t → ∞ meets (b) and is sound relative to Res_{d_t} at time t, relative to Res_∞ in the limit, with finitely many changes on
every separated practice — the TTL form of soundness of the parent report, which by this theorem cannot be improved.

### 5.6 Whole-cluster tests versus pairwise tests

**Proposition 5.8 (proved; computed).**
(a) d-coherence is downward closed but not transitive: there are a, b, c with {a,b} and {a,c} coherent and {b,c}, {a,b,c}
incoherent.
(b) Every cluster built by DTRC is d-coherent at all times (invariant), so every asserted cluster has a non-refuted minimal
template. Single linkage on the pairwise-coherence graph (transitive closure) can build clusters with no non-refuted minimal
template at all.
(c) Under RS_d(D) the coherent subsets of D are exactly the subsets of the D_i (by Theorem 5.2(i) and RS), so the pairwise
relation is the equivalence "same target", and single linkage, complete linkage and DTRC all return {D_i}. The difference
matters only without separation.
(d) Without separation DTRC's result depends on the merge policy (it returns *some* maximal partition into coherent blocks).

*Example (computed, u6(C)).* a = 0+0=0, b = S0+0=S0, c = 0+S0=S0. Min{a,b} = {(t0+0)=t0} unrefuted (Q3);
Min{a,c} = {(0+t0)=t0} unrefuted (the theorem ∀x(0+x=x)); Min{b,c} = {(t0+t1)=S0}, refuted by 0+0=S0;
Min{a,b,c} = {(t0+t1)=t2}, refuted by 0+0=S0. Single linkage merges {a,b,c} (incoherent). DTRC, by order, returns
{{a,b},{c}} or {{a,c},{b}}: two different, both truth-sound, generalizations from the shared instance a.
*Proof.* (a), (d) by the example; (b) DTRC merges only coherent unions and coherence is downward closed; single linkage by the
example; (c) as stated. ∎

So whole-cluster tests are what keep the asserted hypothesis meaningful when separation fails: the template that will be
asserted is the one tested, not a chain of pairwise templates none of which covers the whole cluster.

### 5.7 Noise

Let D = D_clean ∪ E, D_clean ⊆ R* labelled as before, E ∩ R* = ∅ (mistaken data; possibly true non-target sentences).

**Proposition 5.9 (proved).**
(a) *Refutable mistakes are isolated.* If m ∈ E ∩ Ref_d, every cluster containing m is incoherent (every covering template has m
as an instance). DTRC leaves {m} as an incoherent singleton, contributing nothing.
(b) *Mistakes never bridge targets under separation.* Under RS_d(D_clean), every d-coherent X ⊆ D contains clean data of at most
one target (a template covering clean a ∈ D_i and b ∈ D_j covers {a,b}). So every final cluster is (clean data of ≤ 1 target)
∪ (mistakes).
(c) *Absorption.* A mistake m can join a cluster C of target i only if C ∪ {m} is coherent; then Acc_d(C ∪ {m}) ⊆ inst(T)
for every T ∈ Min_d^+(C ∪ {m}), none of which need be below σ_i: the cluster may become unsound.
(d) *Trimmed verifier.* Acc^e_d(C) := ⋂{inst(T) : T not d-refuted, |C \ inst(T)| ≤ e}
 = ⋂_{E′ ⊆ C, |E′| ≤ e} ⋂ Min_d^+(C \ E′) (by (W)). If C has ≤ e mistakes and its clean part lies in D_i, then
 Acc^e_d(C) ⊆ inst(σ_i). If moreover every subset of C of size ≥ |C| − e contains an anchor of σ_i, then
 Acc^e_d(C) = inst(σ_i).
(e) *Fragmentation.* An absorbed mistake can make the rest of D_i unable to join (Lemma 5.1 does not help: C ∪ {m} ∪ C′ may be
incoherent although C ∪ C′ is coherent), so D_i may be split into clusters none of which contains an anchor; the result
depends on the merge policy.
*Proof.* (a) m ∈ inst(T) for every T ∈ Cov(X ∋ m). (b) as stated. (c) Definition. (d) Soundness: E′ := the mistakes;
Min_d^+(C \ E′) contains T₀ ≼ σ_i by (W′). Exactness: for each E′ the set C \ E′ contains an anchor, so every
T ∈ Min(C \ E′) is ≽ σ_i. The finite form follows from (W) as in Lemma 1.2. (e) Example below. ∎

**Robust DTRC(d, e, s).** Run DTRC_d; assert only clusters of multiplicity ≥ s; verify each asserted cluster with Acc^e_d.
Guarantee (proved by (a)–(d)): under RS_d(D_clean), if every mistake is refutable or *noise-separated* (every template covering
it and a clean datum is d-refuted), and every coherent set of mistakes has multiplicity < s (sporadic noise; a frequent coherent
family of mistakes is a systematic error, i.e. a fallacy schema, which no positive-data method can tell from a rule,
cor:imitation:systematic), the asserted clusters are exactly the D_i with multiplicity ≥ s and the output is the union of those
targets once anchors are present; if instead up to e mistakes are absorbed per cluster and each
cluster keeps an anchor after deleting any e data, the output is still sound and exact. Not guaranteed: fragmentation (e).

*Computed (u8).* PA data (60 clean) plus 3 refutable mistakes (a1+0=Sa1, a1·0=a1, (0=0 ∧ ∀x(Sx=x → SSx=Sx)) → ∀x Sx=x), 2
unrefutable false ones (J*_0 of R1; the wrong-base instance (¬S0=0 ∧ ∀x(¬x=0 → ¬Sx=0)) → ∀x¬x=0, whose antecedent needs Q1)
and 2 true non-target theorems (0+a1=a1, ¬Sa1=a1): the 3 refutable mistakes are incoherent singletons; all others stay
singletons of multiplicity 1 (their merges with the diverse induction cluster are refuted, e.g. via
(A ∧ ∀x(P(x)→P(Sx))) → ∀xP(x), refuted through (0=0 ∧ ∀x(Sx=x → SSx=Sx)) → ∀x Sx=x); with s = 2 no mistake is
asserted. *Absorption:* J*_0 together with the non-diverse data Ind(Sⁿ0+x=Sⁿx), n < 3, is coherent; the only non-refuted
minimal template is the K₀-shaped ((t0(0)+0)=t0(0) ∧ ∀x((t0(0)+x)=t0(x) → (t0(0)+Sx)=St0(x))) → ∀x(t0(0)+x)=t0(x), not
below T_ind; the untrimmed verifier accepts the false J*_0 and J*_1; the trimmed verifier (e = 1) rejects both and accepts
the genuine Ind(S³0+x=S³x). *Fragmentation:* data in the order Ind(0+x=x), J*_0, Ind(S0+x=Sx), then three diverse
inductions: DTRC returns {Ind(0+x=x), J*_0, Ind(S0+x=Sx)} (K₀-shaped template, unsound) and a separate cluster of the diverse
inductions (T_ind); with the diverse data first it returns all five inductions together and J*_0 alone. A most-specific-first or
"large clusters first" second pass is a heuristic remedy, not a theorem.

---------------------------------------------------------------------------------------------------------------------------

## 6. Without negatives: slot counting and MDL

### 6.1 Slot counting on positive data

With N = ∅ the cautious k-union learner is still sound (Lemma 1.1); completeness is governed by slot counting.

**Proposition 6.1 (DT° untagged anchors on positive data; proved).**
(a) If every partition of D_i into at most k blocks has a block that is an anchor of σ_i, then inst(σ_i) ⊆ Acc_k(D, ∅).
(b) Under (Abs) (Theorem 4.1) "k" in (a) can be replaced by k − c_i.
(c) If D_i is covered by k − k′ + 1 proper specializations of σ_i whose union misses some q ∈ inst(σ_i) lying in no other
inst(σ_l), then q ∉ Acc_k(D, ∅) (Theorem 3.1).
*Proof.* (a) For h ∈ VS_k(D,∅) partition D_i by first covering slot: ≤ k blocks, one of them an anchor, so its slot is ≽ σ_i.
(b) Theorem 4.1(a), applied with "family of templates covering D_i" read through the partition by first covering slot. (c) as
cited. ∎

(a) is the DT° form of thm:imitation:untagged(a) (where "anchor" = "generic" = escapes every failure set) and (c) of
prop:imitation:diversity(a). For PA the gap between k − c and k − k′ + 1 is the whole story (Corollary 4.2): Sub-encoded
steps c = 1, raw sentences c = 4, with three negatives c = 7 = k′ − 1. The parent's general sufficient condition
("not covered by k failure sets") is *vacuous* for PA induction at k ≥ 7 because seven root failure sets cover all formulas
(prior referees); slot accounting with absorption replaces it.

### 6.2 MDL and the size principle

Determinacy makes a two-part code well defined: for a hypothesis H (a finite set of DT° templates) and data D, each datum d is
assigned to a template T_d ∈ H covering it (the cheapest if several), and its matcher θ_d is unique (prior C1). Put
L(H, D) = Σ_{T∈H} L_tmpl(T) + Σ_{d∈D} [ L_idx(T_d) + L_body(θ_d | T_d) ].
Without the body term this is the parent's prop:search:mdl (MDL without likelihood picks the bare metavariable). The question
here is whether the likelihood term makes MDL pick the *target partition* — e.g. for Q's seven axioms plus induction, does it
keep T_ind whole or split it by main connective?

Split hypothesis: H_F = {Q1,…,Q7} ∪ {T_f : f ∈ F}, F the set of main connectives occurring in the induction data, where
T_f := T_ind[P := λx.f(P₁(x),…)] (for "=": λx.t_L(x) = t_R(x); for ∀/∃: λx.∀y P₁(x,y)). For a datum Ind(φ) with root f the
matcher of T_f has bodies of total size |φ| − 1 (the root symbol moves into the template); under T_ind the body is λx.φ.

**Proposition 6.2 (the naive code over-splits; proved).** Let L_tmpl(T) = λ|T| and L_body(θ) = λ·Σ_M|θ(M)|, λ = log₂ A with A
the number of symbols, and let L_idx be the two-part ML code for the sequence of template labels (empirical entropy plus
(|H|−1)/2·log₂ n + O(1); e.g. KT). Let n_ind be the number of induction data and Ĥ(root) the empirical entropy of their main
connectives. Then
 L(H_F, D) − L(H_true, D) = λ(Σ_{f∈F}|T_f| − |T_ind|) + (|F| − 1)/2·log₂ n − n_ind·(λ − Ĥ(root)) + O(1),
and since Ĥ(root) ≤ log₂|F| < λ (A counts term symbols too), the difference tends to −∞ linearly in n_ind. The same holds with a
uniform index code (log₂|H| bits per datum) as soon as the induction frequency exceeds log₂((7+|F|)/8)/λ. Applied recursively,
naive MDL keeps splitting each class by its next symbol while the class has enough data: it never settles on the target
partition.
*Proof.* Template part: the stated difference. Body part: each induction datum costs λ fewer bits under its T_f. Index part: the
split labels refine the true labels by the root of the induction data, so their empirical entropy is n·Ĥ(true labels) +
n_ind·Ĥ(root) (grouping/chain rule), and the parametric term grows by (|F|−1)/2·log₂ n. Ground axioms cost the same under both
hypotheses. ∎

**Proposition 6.3 (well-specified codes gain at most O(log n) from splitting; proved modulo standard coding facts).** Suppose
the data are i.i.d. from a law P (template index × instance law), and the code for H_true is a Bayesian mixture over a
parametric family with p parameters that contains P and has regret ≤ (p/2)log₂ n + C (Rissanen 1986; Clarke–Barron 1990 —
standard, cited from memory). Then for any fixed split hypothesis and K > 0,
 P[ L(H_F, D) ≤ L(H_true, D) − (p/2)log₂ n − K − C′ ] ≤ 2^{−K}.
*Proof.* The data part of L(H_F, ·) is a prefix code for the data sequence (given the fixed template list), i.e. a
sub-probability Q; by Barron's no-hypercompression inequality P[−log₂Q(D) ≤ −log₂P(D) − K] ≤ 2^{−K}. The data part of
L(H_true, ·) is ≤ −log₂P(D) + (p/2)log₂ n + C. Template parts are constants. ∎
So with a well-specified code, splitting cannot win linearly; the decision falls to lower-order terms (template description and
parametric complexity), which favour fewer templates. This does **not** prove that MDL selects H_true; it shows that the naive
code's linear preference for splitting is an artefact of misspecification.

**Computed (u7).** PA data (Q1–Q7 and induction, π_ind = 0.5). Codes: NAIVE (A = 23); PC = sequential KT per template with
context (parent symbol, child index); DPC = KT with context (depth below the motive root, parent, child index). Difference
L(H_root) − L(H_true) in bits (negative = MDL splits induction by main connective):

| usage law | n | NAIVE | PC | DPC |
|---|---|---|---|---|
| G1 natural (random motives with quantifiers; scope-dependent terms) | 1000 | −223 | +2325 | +2701 |
| | 16000 | −16466 | −1199 | −3036 |
| | 64000 | −68243 | −19783 | −34412 |
| G2 well-specified for DPC (symbol depends only on depth, parent, index) | 1000 | −915 | +1141 | +1428 |
| | 16000 | −21467 | +1053 | +2822 |
| | 64000 | −87156 | −1522 | +3564 |

Reading: the naive code splits from n ≈ 10³ (Prop. 6.2); under the natural usage law even the depth-aware adaptive codes split
for n ≥ 1.6·10⁴, because usage *is* statistically different across connectives (terms under a quantifier see a bound variable),
and splitting captures that; under a usage law for which DPC is well specified, DPC keeps T_ind whole, with a margin growing
like log n (Prop. 6.3), while the misspecified PC code eventually splits. **MDL tracks the statistics of usage, not the logical
boundaries of schemas.** A split is a sound but incomplete hypothesis (it never accepts induction on an unused connective),
so MDL with likelihood errs on the side of incompleteness for schemas; for ground axioms with few occurrences it errs the other
way: with two ground axioms used m times each, the naive code prefers their lgg once m·(body cost) < template savings, which
is unsound when the lgg is false (0+0=0 and 0·0=0 give z = 0). Neither error is detected by MDL; the refutation test of DTRC
detects the second, and the anchor condition (data diversity) controls the first.

---------------------------------------------------------------------------------------------------------------------------

## 7. Natural examples

### 7.1 PA

**Targets.** (i) Q1–Q7 as ground axioms in closure-normal form: ¬Sa=0; Sa=Sb → a=b; a+0=a; a+Sb=S(a+b); a·0=0;
a·Sb=a·b+a; ¬a=0 → ∃y a=Sy. (ii) Raw induction T_ind = (P(0) ∧ ∀x(P(x)→P(Sx))) → ∀xP(x) (DT°, not a Miller pattern).
(iii) Alternatively, Q's axioms observed only through closed-term instances: the instance schemas Q1s–Q7s (first-order
patterns, e.g. (t0+0)=t0).

**Cross merges and what refutes them (computed, u1).** Every minimal covering template of every tested cross pair is
refuted by **Δ₀ evaluation after ∀-instantiation of parameters** (R-Δ₀):

| cross pair | unique minimal covering template | refuting instance |
|---|---|---|
| two axioms with different roots (e.g. Q1–Q3), any Q_i with root ≠ → and induction | F0 | 0=S0 |
| Q2–Q7, Q2–Ind, Q7–Ind | F0 → F1 | 0=0 → 0=S0 |
| Q3–Q5, Q3–Q6, Q4–Q5, Q4–Q6 | t0 = t1 | 0=S0 |
| Q3–Q4 | (a1+t0) = t1 | (a1+0)=0 at a1 := 1 |
| Q5–Q6 | (a1·t0) = t1 | (a1·0)=S0 at a1 := 0 |
| Q_i s – Q_j s (instance schemas; 4 random pairs each, all 21 pairs) | various | all refuted |

So PA is *globally separated at small depth* by the world channel alone, and DTRC recovers the eight targets (computed, u3:
three seeds, 40 shuffled unlabelled data each; one pure cluster per target present in the data (7 or 8); the induction cluster's only non-refuted minimal template is
T_ind; 200/200 held-out random induction instances accepted; 0 of 91 non-instances accepted — 100 near misses (step-by-2
and wrong-base variants) of which 13 are genuine inductions because their motives are vacuous, plus 4 mutated axioms;
63–102 coherence tests per run). Within the instance-schema clusters the minimal template is the schema itself once the
closed terms have different heads (u1(b2); one Q2s sample lacked an S-free instance and gave the sound specialization
SSt0=St1 → St0=t1). DTRC then accepts a1+0=a1 etc., i.e. the universal axioms (§5.4).

**Induction is never at risk of a cross merge**: every minimal template covering a Q-axiom and an induction instance is
absorbing (contains T_ind; Corollary 4.2(3)), and refuted. The only way induction is learned incompletely is lack of diversity
inside its own data (no anchor), exactly as in the tagged case.

### 7.2 ZF

**Targets** (closure-normal form, de Bruijn): Ext ∀x(x∈a↔x∈b) → a=b; Pair ∃c(a∈c ∧ b∈c); Union ∃b∀c(c∈b ↔ ∃d(d∈a ∧ c∈d));
Power ∃b∀c(c∈b ↔ ∀d(d∈c → d∈a)); Inf (∅ and successor written out with ∈); Found ∃y(y∈a) → ∃y(y∈a ∧ ∀z(z∈y → ¬z∈a));
Separation ∃b∀c(c∈b ↔ c∈a ∧ P(c)); Replacement ∀x(x∈a → ∃y(P(x,y) ∧ ∀z(P(x,z) → z=y))) → ∃b∀y(y∈b ↔ ∃x(x∈a ∧ P(x,y)));
∈-induction ∀x(∀y(y∈x → P(y)) → P(x)) → ∀xP(x). In de Bruijn form all three schemas are Miller patterns (P applied to
distinct bound variables), so freshness conditions are automatic (brief Q2).

**Cross merges (computed, u4; one instance per schema per pair).** All 36 pairs have a unique minimal covering template, and
each is refuted, by:
- an **HF counterexample** (R-HF) when the template is a bare formula metavariable F0 or F0 → F1 (instance ¬q1=q1, resp.
  q1=q1 → ¬q1=q1, falsified by q1 := ∅) — 22 pairs;
- **pure logic** (R-logic) when the template keeps some quantifier structure: ∃x F0(x) (Pair–Union, Pair–Power, Pair–Sep,
  Union–Inf, Power–Inf, Inf–Sep: instance ∃x ¬q1=q1), ∃x(F0(x) ∧ F1(x)) (Pair–Inf), (∀x F0(x)) → F1 (Ext–Rep, Ext–EInd),
  F0 → ∃x F1(x) (Found–Rep), (∀x(F0(x)→F1(x))) → F2 (Rep–EInd);
- **Russell's paradox** for the comprehension-shaped axioms: Union–Power, Union–Separation and Power–Separation all have the
  minimal template ∃x∀y(y∈x ↔ F0(y)) — *naive comprehension* — refuted by its instance ∃x∀y(y∈x ↔ ¬y∈y) (Herbrand: take y := x).
Within-target: three random instances of each schema have the schema itself as their unique minimal template (anchor), never
refuted.

**DTRC (computed, u5 part A):** three seeds, 45 shuffled unlabelled data each: 9 pure clusters (the six single axioms and the
three schemas), each schema cluster exact (its unique non-refuted minimal template is the schema); 60/60 held-out instances of
each schema accepted; 0/30 naive-comprehension instances accepted (Separation without its guard c∈a is *not* learned, because
the data never contain it and the cluster template keeps the guard).

So for Q2 in the untagged setting: **yes** — the ZF axioms and schemas are separated by the two refutation channels the brief
lists (HF counterexamples, sound by Δ₀ absoluteness, and logic), with Russell's paradox doing the work exactly where the axioms
look alike.

### 7.3 Where separation fails

**(a) Sound merges.** (1) ∀xφ from instances (§5.4). (2) Redundant targets: an axiom that is an instance of a target schema
(e.g. Empty Set written as ∃b∀c(c∈b ↔ c∈a ∧ ¬c=c), an instance of Separation) merges into the schema's cluster; the merge is
target-sound. (3) Instances shared by two generalizations (Proposition 5.8: 0+0=0 joins Q3's or the theorem 0+x=x's cluster).
Refutation cannot and should not prevent these; they are the reason DTRC is truth-sound rather than target-sound without
separation.

**(b) An unsound merge that only coherence refutes: the weak forms of Union and Power.** Many presentations state Union and
Power in bounding form and recover the ↔ form by Separation:
UnionW ∃b∀c(∃d(d∈a ∧ c∈d) → c∈b), PowerW ∃b∀c(∀d(d∈c → d∈a) → c∈b).
Their unique minimal covering template (computed) is the **universal-set schema** U(F) = ∃x∀y(F(y) → y∈x), whose instance
∃x∀y(y=y → y∈x) is false in V.

**Proposition 7.1 (proved).** No instance of U is refuted by R-logic or R-HF (or by any oracle sound for the structure M₀
below), so the merge UnionW+PowerW passes every such test at every depth. The template *is* refuted by coherence: its
instance ∃x∀y(y=y → y∈x) is refuted together with the closure of one instance of Separation (Russell's set of x), or with the
true Π₁ sentence ∀x ¬x∈x.
*Proof.* Let M₀ = HF ∪ {u}, with ∈ as in HF on HF and y ∈ u for every y ∈ M₀ (so u ∈ u). Every instance ∀ā∃x∀y(ψ(y,ā) → y∈x)
holds in M₀ (take x = u). HF is a transitive part of M₀ (no HF set has u as a member), so Δ₀ formulas with HF parameters have the
same truth value in HF, in M₀ and in V. R-HF refutes a sentence only through a chain of steps each sound in every structure that
contains HF as a transitive part (atoms and bounded quantifiers over HF evaluated in HF; unbounded ∀ refuted by HF witnesses;
unbounded ∃ verified by HF witnesses), hence only sentences false in M₀; R-logic refutes only logically false sentences. For
the positive part: from ∃x∀y(ψ(y) → y∈x) with witness b and ψ(b) (choose the instance with ψ := y=y), y := b gives b∈b,
contradicting ∀x¬x∈x; with the Separation instance r = {y ∈ b : y∉y}, r∈b by the instance, and r∈r ↔ r∉r. Both derivations are
found by the Herbrand/DPLL refuter (u4, u_test_refuters). ∎

*Computed (u5 part B):* with logic + HF only, DTRC merges UnionW and PowerW into one cluster with template ∃x∀y(F0(y) → y∈x)
and **accepts the false universal-set sentence** (an unsound unrefuted merge: soundness only relative to the residue,
Theorem 5.4). The learned Separation cluster accepts Russell's instance of Separation, ∃b∀c(c∈b ↔ c∈a ∧ ¬c∈c). Designating its universal
closure (*bootstrapped coherence*: one sentence accepted by a learned cluster is used as a designated truth) and re-running
DTRC on the same data (u5 part B and u5b): **9 pure clusters**, UnionW and PowerW separated, the three schema clusters still
exact, and the universal-set sentence **no longer accepted**. Bootstrapping is sound exactly when the clusters it trusts are
pure (target-sound), which separation elsewhere provides; it is circular otherwise.

**(c) K₀ (prior R1) in DT°.** K₀ = lgg(Ind(0+x=x), Ind(S0+x=Sx)) is the *first-order* lgg; all its sentence instances are
jointly consistent with the true quantifier-free sentences of ℕ (prior referee, Theorem R1), so neither R-Δ₀ nor logic refutes
any of them, and its instance J*_0 = (0+0=0 ∧ ∀x(0+x=0 → 0+Sx=S0)) → ∀x(0+x=0) is false. In DT° the same pair has two
minimal covering templates (computed): the T_ind-specialization P := λx.(t0(0)+x = t0(x)) and the K₀-shaped
((t0(0)+0)=t0(0) ∧ ∀x((t0(0)+x)=t0(x) → (t0(0)+Sx)=St0(x))) → ∀x(t0(0)+x)=t0(x), whose instances are K₀-instances, hence also
never refuted. DTRC merges the pair (through the sound template) and the cluster verifier intersects *both* non-refuted minimal
templates, so J*_0 is not accepted (W′ guarantees a sound template in the intersection). The K₀-shaped template becomes
harmful only when the sound alternative disappears: when an unrefutable mistake such as J*_0 itself is absorbed into a
non-diverse induction cluster (u8; §5.7). It is refuted by coherence with designated Q (prior B5(d): the descent through Q3
is unblocked when Q3 is designated), or — in DTRC — with Q's own learned clusters (bootstrapped coherence again).

**(d) Permanent residue.** Templates whose false instances are all consistent with the designated truths and Δ₀-correct
(e.g. families containing ¬Con(PA)-like Σ₁ sentences; parent thm:twotier:arith(b),(d)) can never be refuted by any of these
channels; a merge into such a template is a permanent unsound residue, and by Theorem 5.7 no computable learner can recognize in
general whether a merge will ever be refuted. Σ₁-caution (assert a Σ₁ instance only after a verified witness;
thm:twotier:arith(c)) removes the syntactically Σ₁ part. (Concrete natural instances of this kind for merges were not
constructed here.)

---------------------------------------------------------------------------------------------------------------------------

## 8. What this track says about the brief's questions and method

**Q3 (one method, many schemas, no labels).** DTRC as proposed in brief §5 works, with three amendments argued here:
1. *The merge test must be on whole clusters* (§5.6), and *the verifier must intersect all non-refuted minimal templates*
   (not pick one): with DT° non-unitary (prior C8), the K₀-shaped minimal template sits next to the sound one (§7.3(c)).
2. *The budget d is essential and cannot be eliminated* (Theorem 5.7): DTRC is sound relative to the depth-d residue; run it
   with a depth schedule, re-clustering when d grows.
3. *If a bound k ≥ k′ is known, intersect with the k-union learner fed with DTRC's own negatives* (Remark 5.3): that restores
   anytime *target*-soundness without separation, and costs nothing in exactness at k = k′ (pigeonhole).
Under refutation separation the untagged problem is exactly as hard as the tagged one (Theorem 5.2(iv)): refutation plays
the role of citations. PA and ZF are separated at small depth by the brief's channels (§7.1, §7.2).

**Q1 (∀xφ from instances).** It is the special case of a *sound cross merge* (Proposition 5.6): DTRC merges the instances
and accepts ∀xφ itself iff no instance of φ(z) is refuted. Two instances whose substituted terms have different head symbols
are an anchor (Lemma 5.5). The step is truth-sound in ℕ (ω-rule), not derivable, and not truth-sound in structures whose
elements are not all closed-term values unless the oracle is strong enough (ℝ example).

**Q2 (ZFC schemas).** Separation, Replacement (with ∃! spelled out) and ∈-induction are DT° (indeed Miller-pattern)
templates; each is anchored by a few varied instances (computed: three random instances suffice in all runs), and every cross
merge with the other axioms is refuted by HF counterexamples or logic, Russell's paradox separating the comprehension-shaped
ones. With weak (bounding) forms of Union/Power, separation needs coherence (Proposition 7.1).

**Imported assumptions.** (W) and the DT° anchor theorem (A) for the targets used, from track 'single' (both hold in all
computations here; (W) cross-validated by brute force, u0). Nothing is assumed from track 'cases'; Lemma 5.5 (two-point
anchors) is proved here because Theorem 5.7 needs it.

---------------------------------------------------------------------------------------------------------------------------

## 9. Computations (all run in this session)

Directory `code/`. Python 3.11, no external packages. Run from the `code/` directory: `python3 <script>.py > <script>.out`.

| script | what it computes | output | key numbers |
|---|---|---|---|
| `dtlib.py` | DT° templates with parameters and de Bruijn binders; instantiation; unique matching via pattern occurrences (Huet–Lang fallback); subsumption by freezing; common prefix; `mincov` = minimal covering templates by the slot/derivation analysis (antichains of common nodes replaced by derived occurrences; one source per root class of the derivability preorder; all derivation choices; syntactic-minimality filter) | library | |
| `refuters.py` | R-Δ₀ (numeral ∀-instantiation ≤ B = 3, Σ-witnesses ≤ 6, EUF + closed equations of ℕ by congruence closure for universals); R-HF (V₃, bounded quantifiers, Δ₀ absoluteness); R-logic (Skolemize, Herbrand depth 1, ≤ 12 terms, ≤ 300 ground instances per formula, DPLL with a 3000-node budget — exhausting a budget never yields a refutation; equality by reflexivity only) | library | |
| `dtrc.py` | budgeted template refutation search (instance pools per sort/arity; ≤ 1500–4000 instances; logic on ≤ 60 instances of size ≤ 45); DTRC (online + pairwise fixpoint, whole-cluster tests, caching); per-cluster verifier | library | |
| `practice.py` | PA and ZF targets, data generators (random motives, random Separation/Replacement/∈-induction bodies) | library | |
| `u_test_refuters.py` | sanity checks: true sentences never refuted; J*_0 not refuted (R1); Russell refuted by logic; universal set refuted only with a designated Separation instance or ∀x¬x∈x | `u_test_refuters.out` | all as expected |
| `u0_crossval_mincov.py 16`, `… 20` | (W) on the enumerated fragment: every brute-force DT° covering template (prior `so_enum`) lies above a `mincov` template, 8 pairs | `u0_crossval_mincov.out` (size 20) | 0 counterexamples (size 16 and 20); `mincov` sizes 1, 1, 4, 2, 27, 16, 2, 1 |
| `u1_pa_cross.py` | PA cross merges (Q–Q, Q–Ind, instance schemas), absorption check, within-target instance-schema merges | `u1_pa_cross.out` | all cross templates refuted; 4 distinct negatives; absorption 7/7 |
| `u2_threshold.py` | non-absorbing cover number c of Q (positive / refutation / 3 negatives); exact version-space κ(q) vs c + χ | `u2_threshold.out` | c = 4 / 7 / 7; κ = c + χ in 24/24 |
| `u3_dtrc_pa.py` | DTRC end to end on PA, 3 seeds × 40 data; held-out and near-miss acceptance | `u3_dtrc_pa.out` | pure clusters, T_ind exact; 200/200; 0/91 false accepts |
| `u4_zf_cross.py` | ZF cross merges (36 pairs) with refutation method; within-target; Union/Power (↔ and weak forms) | `u4_zf_cross.out` | 36/36 refuted (22 by HF counterexample, 14 by logic, 3 of these by Russell's instance); weak forms refuted only with a designated sentence |
| `u5_dtrc_zf.py` | DTRC end to end on ZF (3 seeds × 45 data), held-out, naive comprehension; part B weak forms, residual merge, bootstrapped coherence | `u5_dtrc_zf.out` | 9 pure clusters per seed; 180/180; 0/30; part B: residual merge accepts the universal set (8 clusters); with the bootstrapped designated sentence 9 clusters, universal set rejected |
| `u5b_bootstrap.py` | part B alone (logic budget 15 instances per template) | `u5b_bootstrap.out` | same outcome as u5 part B, 77 s |
| `u6_forall_nontrans.py` | ∀xφ from numeral instances; false universal blocked; non-transitivity example | `u6_forall_nontrans.out` | see §5.4, §5.6 |
| `u7_mdl.py 200 1000 4000 16000 64000` | two-part code lengths, NAIVE/PC/DPC, laws G1, G2 | `u7_mdl.out` | table in §6.2 |
| `u8_noise.py` | mistakes (refutable, unrefutable, true non-target), multiplicity threshold, absorption + trimmed verifier, fragmentation | `u8_noise.out` | §5.7 |

Run times: u0 at size 20 ≈ 3 min; u7 at n = 64000 ≈ 2 min; u5 ≈ 2.5 min; u2 ≈ 1 min; the others < 1 min. (`run_all.sh` re-runs
everything; all `.out` files were regenerated with the final versions of the libraries.)

*Implementation caveats.* `mincov` is complete only as far as u0 checks it (pairs of induction instances, brute force up to
size 20); minimality is syntactic, which can only add redundant templates above true minimal ones (harmless for coherence and
for the intersection verifier, see §1). Refutation search is budgeted and incomplete: a template reported "not refuted" may be
refutable at a larger budget; every reported refutation was produced by a sound procedure and printed with its instance and
witness.

---------------------------------------------------------------------------------------------------------------------------

## 10. Open problems

1. **(W) for DT°** in general (track 'single'); here only cross-validated on a fragment.
2. **Exact spare-slot threshold for T_ind** when m ≥ 7 slots are available for induction: the root failure family covers Ind,
   so exactness depends on second-level failure events in each root class; a recursive characterization (and anchor sizes as a
   function of m) is open. The prior referee's example (all ∀-motives bind the same variable) shows the second level matters.
3. **Separation at depth d as a usable assumption**: can one bound the depth from the targets (e.g. for first-order pattern
   targets over ℕ, by the size of the lgg and the least counterexample)? For PA and ZF it is tiny (§7), but Theorem 5.7 shows no
   uniform computable bound exists.
4. **Fragmentation-free robust clustering**: a merge rule with a theorem that mistakes neither bridge targets (they cannot under
   separation) nor fragment them (they can, §5.7).
5. **MDL**: a theorem that a natural universal code (e.g. context-tree mixtures over bodies) selects the target partition under
   a well-specified usage model, and a characterization of when usage heterogeneity makes it split.
6. **Coherence with learned clusters** (bootstrapping): soundness when only some clusters are pure; an iterative scheme with
   guarantees.

---------------------------------------------------------------------------------------------------------------------------

## 11. Credits and citations

Known results used: Gold 1967 (superfinite classes not identifiable from text); Angluin 1980 (tell-tales); Plotkin 1970,
Reynolds 1970 (lgg; failure events (R), (D)); Huet–Lang 1978 (second-order matching); Miller 1991 (patterns); Pfenning 1991,
Baumgartner–Kutsia–Levy–Villaret 2017 (pattern anti-unification); Wright 1989, Motoki–Shinohara–Wright 1991 (finite elasticity
of bounded unions); Arimura–Shinohara–Otsuki 1994 (minimal multiple generalization for unions of pattern languages — *believed
correct citation, not rechecked*); Kleene's T predicate and the Δ₀-definability of computations (standard); Δ₀ absoluteness for
transitive classes (standard; e.g. Kunen's or Jech's textbooks); Herbrand's theorem; Gödel 1931 (second incompleteness, for
§7.3(d)); Rissanen 1978/1986 (MDL, parametric regret), Krichevsky–Trofimov 1981 (KT estimator), Clarke–Barron 1990 and Barron's
no-hypercompression inequality (Barron 1985; Grünwald's 2007 MDL book) — *cited from memory*; Tenenbaum–Griffiths 2001 (size
principle). The parent report: lem:imitation:cautious, thm:imitation:anchor, thm:imitation:untagged, prop:imitation:diversity,
thm:imitation:coupon, thm:imitation:trimmed, lem:twotier:onesided, thm:twotier:depth, thm:twotier:arith, prop:search:mdl. The
prior session: DT° matching and the induction anchor theorem (C1, C3, C8), the PA untagged threshold (pa-untagged findings), R1
(raw-impossibility referee). The clustering idea is in the spirit of conceptual clustering (Michalski–Stepp 1983, *believed*)
and of MMG; the refutation test, the separation theorem and the impossibility theorem are, as far as I know, new here.
