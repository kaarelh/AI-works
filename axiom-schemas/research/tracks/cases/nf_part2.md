
---------------------------------------------------------------------------------------------------------------

## PART 2. Q2: the ZF(C) schemas

### 2.1 Formulations — known (citations hedged)

* **Kunen** (*Set Theory: An Introduction to Independence Proofs*, 1980, Ch. I; I believe also in the 2011 edition):
  Comprehension ∀z∀w̄∃y∀x(x∈y ↔ x∈z ∧ φ), FV(φ) ⊆ {x, z, w̄} (so y ∉ FV(φ)); Replacement
  ∀A∀w̄(∀x∈A ∃!y φ → ∃Y∀x∈A ∃y∈Y φ), FV(φ) ⊆ {x, y, A, w̄} (Y ∉ FV(φ)); Foundation
  ∀x(∃y(y∈x) → ∃y(y∈x ∧ ¬∃z(z∈x ∧ z∈y))). (Wording from memory, not re-checked against the book; the referee's
  recollection agrees.) **[revised]** Kunen treats ∃! as an abbreviation (I believe); treating ∃! as a primitive
  binder (template ReplU below) is *our encoding choice*, not Kunen's. Both readings are analysed: ReplU (∃!
  primitive) and ReplS (∃! spelled out as ∃y(φ(x,y) ∧ ∀u(φ(x,u) → u = y))).
* **Jech** (*Set Theory*, 3rd millennium ed., 2003, Ch. 1, axioms 1.1–1.9; I believe): Separation
  ∀X∀p∃Y∀u(u∈Y ↔ u∈X ∧ φ(u,p)); Replacement ∀x∀y∀z(φ(x,y,p) ∧ φ(x,z,p) → y = z) → ∀X∃Y∀y(y∈Y ↔ ∃x∈X φ(x,y,p));
  Regularity ∀S(S ≠ ∅ → ∃x∈S S∩x = ∅). (Unverified wording; the referee's recollection agrees.)
* **Collection** ∀A∀w̄(∀x∈A ∃y φ → ∃Y∀x∈A ∃y∈Y φ) and **∈-induction** ∀x(∀y∈x φ(y) → φ(x)) → ∀xφ(x) are not axioms of
  ZFC but theorem schemas of ZF (Collection via ranks/reflection, e.g. Lévy 1979, *Basic Set Theory* — I believe;
  ∈-induction via transitive closures and Foundation) — known. Conversely ∈-induction with parameter S proves
  Foundation: for φ(x) := x ∉ S, if S had no ∈-minimal element then ∀y∈x (y ∉ S) → x ∉ S holds for all x, so
  ∀x(x ∉ S) and S = ∅ (proved, two lines).
* **ZFC proper:** Extensionality, Pairing, Union, Power set, Infinity, Separation (schema), Replacement (schema),
  Foundation (one sentence), Choice; plus Empty set / Set existence depending on the text.
* **[new] Ground axioms.** Every ZFC axiom other than the two schemas — Extensionality, Empty set (where included),
  Pairing, Union, Power set, Infinity, Foundation, Choice — is a single sentence s. Its target is {s}, a
  metavariable-free template; every class contains it; the only datum is s itself, and one occurrence of it is an
  anchor in every class (the only template that covers {s} and is contained in every covering template is s, and
  every covering template contains s). Matching is equality. (Proved, trivial. In an untagged mixture these
  sentences raise the union problem of Q3, which is not this track's subject.)

**Closure-normal forms used here** (parameters w̄ dropped; frame variables stay bound; P is the template's metavariable,
written with the textbook argument names; `st_core.SCHEMAS`):

| name | template T* | P's arguments |
|---|---|---|
| Sep (Kunen) | ∀z∃y∀x(x∈y ↔ x∈z ∧ P(x,z)) | (x, z) |
| SepJ (Jech) | ∀X∃Y∀u(u∈Y ↔ u∈X ∧ P(u)) | (u) |
| EInd | ∀x(∀y(y∈x → P(y)) → P(x)) → ∀xP(x) | (y), (x), (x) |
| Coll | ∀A(∀x(x∈A → ∃y P(x,y,A)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A) twice |
| ReplU (∃! primitive; our reading of Kunen) | ∀A(∀x(x∈A → ∃!y P(x,y,A)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A) twice |
| ReplS (∃! spelled out) | ∀A(∀x(x∈A → ∃y(P(x,y,A) ∧ ∀u(P(x,u,A) → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A), (x,u,A), (x,y,A) |
| ReplJ (Jech) | ∀x∀y∀u(P(x,y) ∧ P(x,u) → y=u) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X ∧ P(x,y))) | (x,y), (x,u), (x,y) |
| Found | ∀S(∃x x∈S → ∃x(x∈S ∧ ∀y(y∈x → ¬y∈S))) | — (ground) |

All are sentences after plugging any body λz̄.φ (φ closed except holes and parameters).

### 2.2 Thm B1 (classification of encodings) — proved; computed

Let T* be a pattern template with one metavariable P of arity n and occurrences P(ā₁),…,P(ā_m), ā_k pairwise distinct
bound variables in scope. In the named encoding (textbook names) let N_k be the *names* of ā_k; in the de Bruijn
encoding let I_k be the *indices* of ā_k at occurrence k.
(a) T* ∈ PAT ⊆ DT° (a Miller pattern).
(b) inst(T*) equals the instance set of a single first-order schema with freshness guards in the named encoding iff
N₁ = … = N_m. Then the schema is F[A,…,A] (the frame with one formula metavariable A at every P-position) with guards
{fresh(v, A): v a frame-bound name, v ∉ N₁}.
(c) the same holds in the de Bruijn encoding iff I₁ = … = I_m, with guard loose(A) ⊆ I₁; this guard is implied by
well-formedness iff I₁ = {0,…,d−1} where d is the least binder depth of an occurrence.

*Proof.* (a) by inspection. (b)/(c) "if": an instance of the guarded first-order schema assigns A a formula ψ whose
free frame names lie in N (named) or whose loose indices lie in I (dB). Let β := ψ with the names/indices of N (resp.
I) replaced by the holes in argument order. At every occurrence the arguments have the same names (resp. indices), so
β[ā_k] = ψ for all k and the instance is T*[P := λz̄.β]. Conversely T*[P := λz̄.β] gives β[ā_k], the same text for all
k, satisfying the guard. "Only if": suppose N_k ≠ N_l (resp. I_k ≠ I_l) and σ is a guarded first-order schema with
inst(σ, G) = inst(T*). Take the genuine data s₁, s₂ with bodies φ₁ = ⋀_i (z_i = z_i) and φ₂ = ¬φ₁. Their lgg L has a
metavariable at every P-position (roots ∧ vs ¬ differ) and the columns at occurrences k, l differ (φ₁ mentions every
argument), so L has distinct metavariables A_k ≠ A_l. Since s₁, s₂ ∈ inst(σ), σ ⪰ L, say L = σρ. Let s₃ := L with A_k's
block := ⊤ = ∀w(w=w) and all other blocks := ⊥ = ¬⊤. Then s₃ = σ(ρθ₃) and every guard satisfied by s₁ is satisfied by
s₃: the value ρθ₃(Z) of each σ-metavariable has as free names (loose indices) only those of the rigid part of ρ(Z),
which are also free in ρθ_{s₁}(Z). So s₃ ∈ inst(σ, G). But s₃ ∉ inst(T*): a body giving the closed ⊤ at occurrence k
must be ⊤ itself (plugging variables into a body with holes leaves variables), so occurrence l would also be ⊤, not ⊥. ∎

*Evidence.* `z1_encodings.py` (1) computes the criterion from the frames; (5) builds s₃ for every non-first-order
case: an instance of the lgg, not a schema instance (all 7 cases). (4): for EInd in de Bruijn, of 3000 random A with
loose indices ⊆ {#0,#1}, the 1051 well-formed instances of the first-order pattern are all EInd instances and the rest
are ill-formed. Re-run in this revision: identical output. Independently recomputed by the referee
(`referee_code/r2_zf.out` (1), (4)).

**Table (proved by B1; criterion computed in `z1_encodings.out` (1)).**

| schema | PAT / DT° | named first-order (textbook names) | de Bruijn first-order | named, α-varied (§2.2a) |
|---|---|---|---|---|
| Sep | yes | yes, guard fresh(y, A) | yes, guard "#1 not loose" (not implied) | yes |
| SepJ | yes | yes, guards fresh(X, A), fresh(Y, A) | yes, guard loose(A) ⊆ {#0} | yes |
| EInd | yes | **no** (y vs x) | **yes**, guard implied by well-formedness | no |
| Coll | yes | yes, guard fresh(Y, A) | **no** (A is #2 vs #3) | **no** |
| ReplU | yes | yes, guard fresh(Y, A) | **no** | **no** |
| ReplS | yes | no (y vs u) | no | no |
| ReplJ | yes | no | no | no |
| Coll/ReplU with φ(x,y) only | yes | yes, guards fresh(Y), fresh(A) | yes, guard loose ⊆ {#0,#1} (not implied: #2 is A in the antecedent, Y in the consequent) | no |
| Found and the other ground axioms | ground | ground | ground | ground |

The table answers "is it a first-order pattern, with what guards, is it a Miller pattern, is it determinate" for each
schema. Without its guard every guarded entry has a false instance (§2.4).

### 2.2a Prop B1α (named encoding under α-variation) [new] — proved; computed

`notes.md` assumed that the community writes every instance with the textbook names for the frame's variables. Drop
this: *α-varied data* are α-variants of schema instances in which the frame's binders get arbitrary names, pairwise
distinct and distinct from the instance's parameters. inst_α(T*) is the set of all such α-variants. The
hypothesis class is now the first-order schemas over the named signature whose metavariables have formula sort or
*name sort* (name metavariables stand at binder-name positions and variable leaves), with guards from
Φ_α = {fresh(v, A), distinct(v, w)}.

**Prop B1α.** inst_α(T*) is the instance set of a single guarded first-order schema iff all occurrences of P are applied
to the same tuple of *binders* (the same binder nodes of the frame, in the same order). Among the ZF templates this
holds for Sep and SepJ (one occurrence) and fails for EInd, Coll, ReplU, ReplS, ReplJ.

*Proof.* "If": let b₁,…,b_K be the frame's binders. σ := the frame with the name of b_k (at the binder and at every leaf
it binds) replaced by a name metavariable v_k, and every P-occurrence replaced by one formula metavariable A; guards
distinct(v_k, v_l) for k ≠ l and fresh(v_k, A) for every b_k that is not one of P's argument binders. An instance
assigns distinct names to the binders and a formula ψ to A whose free names are argument-binder names or names not
used by the frame. Let β := ψ with the argument names replaced by holes in argument order. Every occurrence applies P
to the same binders, hence to the same names, so every slot reads β[names] = ψ and the instance is an α-variant of
T*[P := λz̄.β]. Conversely an element of inst_α(T*) has distinct frame names, one slot text ψ (same binders, same
names), and ψ's free names are argument names or non-frame names; so it is an instance satisfying the guards.
"Only if": let occurrences k and l differ at argument position i (binders b ≠ b′). Suppose inst(σ, G) = inst_α(T*).
Fix one naming with all frame binders distinct and take the genuine data s₁, s₂ (same naming) with bodies
φ₁ = ⋀_i z_i = z_i and φ₂ = ¬φ₁. In their lgg L the frame names are common (constants), every slot is a disagreement
position, and the slot texts at k and l differ in s₁ (one mentions name(b), the other name(b′)), so L has distinct
slot metavariables A_k ≠ A_l. As in B1, σ ⪰ L, L = σρ, and s₃ := L with A_k's block := ⊤ and the other blocks := ⊥ is
in inst(σ, G): distinct-guards involve only name positions, whose values in s₃ equal those in s₁; fresh-guards hold
because the free names of ρθ₃(Z) are among those of ρθ_{s₁}(Z). But s₃ ∉ inst_α(T*): a body yielding the closed ⊤ at k is
⊤ itself, so slot l would be ⊤ too. The ZF classification: Sep and SepJ have one occurrence; EInd applies P to the
binders ∀y, ∀x (first), ∀x (second); in Coll and ReplU the antecedent's x, y are bound by ∀x, ∃y (resp. ∃!y) of the
antecedent and the consequent's by the consequent's ∀x, ∃y; ReplS and ReplJ already differ in names. ∎

*Consequences* (proved; computed): (1) Coll and ReplU, first-order in the named encoding with textbook names, are not
first-order once names vary; the named lgg of α-varied anchor data decouples their two occurrences and has the false
instance ∀A(∀x(x∈A → ∃y(y=x)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ ⊥))) ≡ ∀A¬∃x(x∈A) (and its ∃! analogue), which satisfies the
learned fresh/distinct guards. (2) ReplS: the named lgg of α-varied data decouples all three occurrences and has the
false instance with blocks (y = x), ⊥, ⊥ — so the truth-sound over-generalization of Prop C3 is an artefact of
textbook naming. (3) Thm C2 extends to Coll, ReplU, ReplS in the α-varied named encoding (§2.5, case (iv)).
(4) De Bruijn is α-invariant, so the de Bruijn column is unaffected.

*Evidence.* `z8_alpha.py` → `z8_alpha.out` (1 s). (1) On all pool anchor pairs: textbook-name blocks vs α-varied
blocks — Sep (1) / (1); SepJ (1) / (1); EInd (1),(2,3) / (1),(2),(3); Coll and ReplU (1,2) / (1),(2); ReplS and ReplJ
(1,3),(2) / (1),(2),(3). (2) For Coll, ReplU, ReplS: the stated instance is an instance of the α-varied lgg, satisfies
the most specific fresh/distinct guards learned from the two data, is a sentence, and is not a schema instance.
(3) Sep, SepJ: 1236 resp. 720 random guard-satisfying instances of the α-varied guarded lgg (random distinct names,
random slot formulas over the frame names, parameters and fresh internal binders) are all genuine.

### 2.3 What the first-order lgg does — Prop B2 — proved; computed

For data D ⊆ inst(T*) with (R), the first-order lgg (either encoding, textbook names) is the frame with a metavariable
at each P-position, and positions k, l carry the same metavariable iff φ_j[ā_k] = φ_j[ā_l] (as text in that encoding)
for all j, iff every argument position i at which ā_k and ā_l differ is unused by all φ_j.
*Proof.* Frame positions are common columns; by (R) every P-position is a disagreement column; Reynolds' table merges
equal columns. φ[ā_k] = φ[ā_l] iff the substitutions agree on FV(φ) (substitution injectivity: at a free occurrence of
z_i the two results carry a_{k,i} and a_{l,i}). ∎

`z1_encodings.out` (2) tabulates the blocks for all 110/107/106 pool pairs with (R), keyed by (N_i). Summary:
* EInd: named blocks {1},{2,3} iff N; de Bruijn always {1,2,3}.
* Coll, ReplU: named always {1,2}; de Bruijn {1},{2} iff N_A.
* ReplS: named {1,3},{2} iff N_y; de Bruijn three blocks when N_x and N_A.
* ReplJ: named {1,3},{2} iff N_y; de Bruijn three blocks when N_x and N_y.

So on anchor data (R + all N_i) the first-order lgg decouples exactly the non-first-order cases of the table; when it
ties everything (some N_i fails), it is a sound but incomplete specialization. (Referee: 2417 random pairs, 7 schemas ×
2 encodings, block structure = prediction in every case, `referee_code/r2_zf.out` (2).)

### 2.4 Two instances suffice for a false lgg instance — proved; computed

For each non-first-order case, two genuine instances (two atoms with different roots) and an instance of their lgg
that is false, with the falsity proof. All are checked to be instances of the computed lgg and not schema instances in
`z1_encodings.out` (3) (and by the referee, `referee_code/r2_zf.out` (3)). ⊤ := ∀w(w=w), ⊥ := ¬⊤.

1. **EInd, named.** Data EInd(x = x), EInd(¬x ∈ a). lgg: ∀x(∀y(y∈x → A) → B) → ∀xB. Instance
   F₁ := ∀x(∀y(y∈x → ¬y=y) → ∀w¬w∈x) → ∀x∀w¬w∈x. The antecedent is valid (∀y(y∈x → ⊥) is ∀w¬w∈x), so F₁ is logically
   equivalent to the Π₁ sentence ∀x∀w¬(w∈x), whose Δ₀ matrix fails at the HF sets x = {∅}, w = ∅; by Δ₀-absoluteness
   (HF is transitive) F₁ is false in V. ZF refutes it from "some set has an element".
2. **ReplJ, named.** Data ReplJ(x∈y), ReplJ(¬x=a). lgg: ∀x∀y∀u(A ∧ B → y=u) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X ∧ A)). Instance
   A := y=y, B := ¬u=u: the antecedent is valid and the consequent says, at X = {∅}, that there is a set of all sets.
   ZF refutes it: Y ∈ Y contradicts Foundation (or Separation yields Russell's set).
3. **ReplJ, de Bruijn** (three blocks): A₁ := ⊥, A₂ := ⊥, A₃ := (y = y): the same false sentence up to the antecedent's
   form.
4. **Coll, de Bruijn.** Data Coll(y = x), Coll(¬x = A). lgg decouples occurrences 1, 2. Instance A₁ := y=y, A₂ := ⊥:
   ∀A(∀x∈A ∃y(y=y) → ∃Y∀x∈A ∃y(y∈Y ∧ ⊥)), logically equivalent to ∀A¬∃x(x∈A); refuted by the HF witness A = {∅}
   (Σ₁ negation, Δ₀-absolute).
5. **ReplU, de Bruijn.** Same data; A₁ := (y = x) (∃!y(y = x) is valid), A₂ := ⊥: equivalent to ∀A¬∃x(x∈A).
6. **ReplS, de Bruijn.** Same data; A₁ := (y = x), A₂ := ⊥, A₃ := ⊥: the antecedent ∀x∈A∃y(y=x ∧ ∀u(⊥ → u=y)) is valid,
   the instance is equivalent to ∀A¬∃x(x∈A).
7. **Guard violations** (the guarded first-order patterns of the table):
   - Sep without fresh(y): Russell's instance ∀z∃y∀x(x∈y ↔ x∈z ∧ ¬x∈y) — both encodings (§2.7).
   - Coll / ReplU / ReplS, named, without fresh(Y): φ := (y = Y) gives ∀A(∀x∈A ∃y(y = Y) → ∃Y∀x∈A∃y(y∈Y ∧ y=Y)): the
     antecedent holds (Y is a parameter there), the consequent forces Y ∈ Y for A ≠ ∅; ZF refutes it by Foundation
     (ReplS: add B := ¬u=u for the uniqueness clause).
   - Coll with φ(x,y) only, de Bruijn, without "#2 not loose": A := (#0 = #2) reads y = A in the antecedent and y = Y in
     the consequent: ∀A(∀x∈A∃y(y=A) → ∃Y∀x∈A∃y(y∈Y ∧ y=Y)), false as before (`z1_encodings.out` (3b)).
8. **[new] Named, α-varied** (§2.2a): Coll, ReplU (blocks (y = x), ⊥) and ReplS (blocks (y = x), ⊥, ⊥): each equivalent
   to ∀A¬∃x(x∈A) (`z8_alpha.out` (2)).

### 2.5 No finite union of first-order schemas — Lemma C1, Thm C2 — proved; computed

**Lemma C1 (deep leaf).** Let s be a sentence tree, ℓ a leaf of s, and τ a first-order schema with s ∈ inst(τ) and
|τ| < depth(ℓ). Then τ has a metavariable occurrence Z at a proper prefix q of ℓ with depth(q) < |τ|. If moreover s|q
occurs in s only at q, then Z occurs in τ only at q, and s[q ← v] ∈ inst(τ) for every closed formula v; with freshness
guards (named), loose-index guards (de Bruijn), and also distinct-guards on name metavariables (α-varied named), s[q ← v]
satisfies them.
*Proof.* Follow the path to ℓ in τ: τ has fewer than |τ| nodes, so the path leaves τ's tree at depth < |τ| at a leaf of
τ. That leaf is not a constant, since s continues below it; so it is a metavariable Z at a proper prefix q of ℓ. In the
language {∈, =} every proper prefix of a variable leaf is a formula position (binder-name children are not on the path
to ℓ), so Z is a formula metavariable. If Z also occurred at q′, then s|q′ = θ(Z) = s|q, so q′ = q by uniqueness.
Changing θ(Z) to v changes s at q only. Guards on Z: v is closed, so it has no free names and no loose indices; other
metavariables (including name metavariables) keep their values. ∎

**Thm C2.** In each case below, every finite set {τ₁,…,τ_r} of first-order schemas (with the guards of the respective
encoding) whose union contains all instances of the schema contains a false sentence (indeed one refutable in ZF from
"some set has an element", Foundation, and Separation/Pairing):
(i) EInd in the named encoding; (ii) ReplJ in both encodings; (iii) Coll, ReplU and ReplS in the de Bruijn encoding;
(iv) **[new]** Coll, ReplU and ReplS in the named encoding under α-variation (§2.2a).
With textbook names, the list (i)–(iii) is exactly the non-first-order cases of the table except ReplS in the named
encoding, and that exception is necessary: there a single guarded first-order schema covers ReplS without false
members (Prop C3). Every finite union still contains non-instances there (Lemma C1 applies verbatim; only falsity
fails).

*Proof.* Take n with 2n > max|τ_i|, the genuine instance s_n below, and τ_i covering it. By Lemma C1 (uniqueness is
checked below) τ_i contains s_n[q ← v] for the prefix q determined by τ_i and *each* closed v; it suffices that for every
proper prefix q of the designated leaf one of v ∈ {⊤, ⊥} makes s_n[q ← v] false. Below, "make the slot false" means
choosing v with ¬^{e}v ≡ ⊥ where e is the number of negations between q and the slot root (positions on the path inside
the slot are reached through ¬, ∀ and ∧ only, and ∀w v ≡ v).
(i) φ_n(x) := ¬^{2n}∀w¬(w∈x) ("x is empty"); s_n = EInd(φ_n), named; leaf: the y in occurrence 1 (φ_n(y)). q = root:
  v := ⊥. q = antecedent or its ∀x-body: v := ⊤; then s ≡ ∀xφ_n(x) ≡ "every set is empty", false. q = ∀y(y∈x → φ_n(y))
  or its body: v := ⊥; the antecedent becomes ∀x(⊥ → φ_n(x)), true; conclusion false. q inside φ_n(y): make the slot
  false; then ∀y(y∈x → ⊥) says "x is empty", the antecedent reads ∀x(x empty → x empty), true, the conclusion is false.
(ii) φ_n(x,y) := ¬^{2n}(x ∈ y); leaf: u in occurrence 2 (φ_n(x,u)). The consequent C := ∀X∃Y∀y(y∈Y ↔ ∃x∈X x∈y) is false:
  at X = {∅}, Y would contain every y with ∅ ∈ y; y₀ := {∅, Y} gives Y ∈ y₀ ∈ Y, contradicting Foundation (or, without
  Foundation, R := {y ∈ Y: y ∉ y} and y₁ := R ∪ {∅} give y₁ ∈ y₁ ↔ y₁ ∉ y₁). q = root: ⊥. q = the antecedent, its ∀y, ∀u
  levels or its implication: ⊤ (antecedent true, C false). q = the conjunction: ⊥ ((⊥ → y=u) is true). q inside
  φ_n(x,u): make the slot false (the conjunction becomes ⊥).
(iii) φ_n(x,y,A) := ¬^{2n}(y = x ∧ x ∈ A); leaf: the A in the consequent occurrence (occurrence 2 for Coll/ReplU, 3 for
  ReplS). The antecedent is true for every A (y := x is the unique witness). Every proper prefix q on the path is the
  root (v := ⊥), the ∀A body (v := ⊥: ∀A⊥), or a subformula of the consequent containing the leaf; there v := ⊥ above the
  slot (∃Y⊥, ∃Y∀x⊥, ∀x(x∈A → ⊥), ∃y⊥, (y∈Y ∧ φ) := ⊥) and "make the slot false" inside it (including
  (y=x ∧ x∈A) := ⊥ and x∈A := ⊥ under the even chain) make the consequent false whenever A ≠ ∅, so
  ∀A(true → false-for-nonempty-A) is false.
(iv) Same φ_n and the same case analysis as (iii), with s_n an α-variant of S(φ_n) in which all frame binders have
  distinct names, and with designated leaf the y of the atom (y = x) in the consequent occurrence (the A-leaf of (iii)
  is not usable here: in the named encoding the atom x∈A of the slot also occurs as a frame atom of the consequent).
  The only new prefix is the atom (y = x) itself, where v := ⊥ makes the slot false.
Uniqueness of s_n|q along the path: in (i) the path subterms contain y and occurrences 2, 3 contain x; in (ii) and (iii)
the argument tuples of the designated occurrence differ from all others (de Bruijn: (#2,#0) vs (#2,#1), (#0,#1);
(#1,#0,#3) vs (#1,#0,#2), (#2,#0,#3)), and the frame subterms on the path are distinct; in (iv) every path subterm inside
the slot contains the consequent's own names for x and y, which occur nowhere outside the consequent, and inside the
consequent the frame atoms are x∈A and y∈Y, never y = x. ∎

*Evidence.* `z5_deepleaf.py` → `z5_deepleaf.out` (re-run: identical): for n ≤ 10 every subterm along each designated path
of (i)–(iii) is unique in s_n; for 2 136 random first-order generalizations τ of s_n with |τ| < depth(leaf) (n = 2, 4, 8),
τ contains both s_n[q ← ⊤] and s_n[q ← ⊥] at the metavariable q on the path (Lemma C1's conclusion). Referee
(`referee_code/r2_zf.out` (7)): for every prefix in (i)–(iii), n = 1, 2, one of ⊤/⊥ makes s_n[q←v] imply the stated
false sentence in all ∈-structures of size ≤ 3. **[new]** `z8_alpha.out` (4) for (iv): path uniqueness for n = 0..6; for
n = 0, 1 and every one of the 20 prefixes per schema, one of ⊤/⊥ makes s_n[q ← v] imply "every set is empty" in all
530 ∈-structures of size ≤ 3.

This is the ZF analogue of the prior result for PA induction (family 0+(…(0+x)) = x).

### 2.6 Prop C3 (spelled-out Replacement, named, textbook names: a truth-sound over-generalization) — proved; computed

Let L_S := ∀A(∀x(x∈A → ∃y(B₁ ∧ ∀u(B₂ → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ B₁))) with guard fresh(Y, B₁) — the named first-order
lgg of ReplS data with (R) and N_y (`z1_encodings.out` (2)); the most specific guards learned from anchor data are
fresh(Y, B₁), fresh(u, B₁), fresh(Y, B₂), fresh(y, B₂) (`referee_code/r2_zf.out` (5)). Every guarded instance of L_S is a ZF
theorem; inst(L_S) ⊋ inst(ReplS).
*Proof.* The antecedent implies ∀x∈A ∃y B₁ (drop the second conjunct). B₁ may mention x, y, A and other parameters, but
not Y (guard); u is not bound at either occurrence of B₁, so any free u would be a parameter at both. Collection with
these parameters gives ∃Y∀x∈A∃y∈Y B₁, and ZF ⊢ Collection. Strictness: B₂ := ⊥ gives a non-instance. ∎
So in the named encoding with textbook names the first-order learner on spelled-out Replacement data is *truth-sound
but not exact*, and no refutation (world or coherence) can ever detect the over-generalization. Without the guard the
capture instance of §2.4(7) is false. Contrast: in Jech's image form the decoupling yields false instances (§2.4(2)),
because the consequent "Y is exactly the image" is not implied by the antecedent's existence part. Under α-variation
the phenomenon disappears (§2.2a).

**Prop C3′ (exact reduction to Collection) [new] — proved.** Let B be any theory (containing first-order logic).
Every guarded instance of L_S (guards as learned from anchor data, listed above) is a theorem of B iff B proves every
instance of the Collection schema.
*Proof.* (⇐) is the proof of C3, which uses only Collection. (⇒) Let Coll(φ) be a Collection instance,
φ = φ(x, y, A, w̄) with Y not free (Collection's own side condition). Renaming parameters gives an equivalent universal
closure, so assume u ∉ FV(φ). Then B₁ := φ, B₂ := ⊥ satisfy the guards (⊥ is closed), and the resulting instance
∀A(∀x(x∈A → ∃y(φ ∧ ∀u(⊥ → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ φ))) is logically equivalent to Coll(φ), because ∀u(⊥ → u=y) is
valid. So B ⊢ Coll(φ). ∎
Consequence: whether this lgg is truth-sound over ZF without Foundation is *exactly* the question whether ZF − Foundation
(with Replacement) proves Collection. I do not know the answer and have no reliable reference (open; flagged by the
referee as well).

### 2.7 Separation without the freshness guard; guard learning — Prop D1 — proved; computed

(a) The unguarded lgg of Sep data (named: ∀z∃y∀x(x∈y ↔ x∈z ∧ A); de Bruijn: the same with A at depth 3) has the
instance φ := ¬(x∈y): R := ∀z∃y∀x(x∈y ↔ x∈z ∧ ¬x∈y). From the designated true axiom ∃z∃x(x∈z): fix such z, x₀ and the y
given by R; then x₀∈y ↔ ¬x₀∈y. So R is refuted in pure logic from "some set has an element" (which ZF proves, e.g. {∅}).
(b) Most specific guards (lem:setting:guard, Φ = {fresh(v, A): v ∈ {x, y, z}}): genuine data never have y free, so
fresh(y, A) is always learned and R is never accepted. The learned guard set equals the target {fresh(y, A)} iff some
datum has x free and some has z free, i.e. iff (N_x) and (N_z) — the same events as the DT° anchor (Thm E). For
Coll/ReplU (named) the target guard is fresh(Y, A); exact iff N_x, N_y, N_A.
*Evidence.* `z4_guards.py` → `z4_guards.out` (re-run: identical): on all pool pairs with (R) (107 Sep, 106 Coll, 106
ReplU): "learned = target" ⟺ all N_i on 107/107, 106/106, 106/106; the capture instance (Russell for Sep, y = Y for
Coll/ReplU) is an instance of the lgg and rejected by the learned guards in every case. Referee: 1537/1537 random pairs
(`referee_code/r2_zf.out` (6)).

### 2.8 Thm E (anchors for pattern targets with one metavariable; all ZF schemas) — proved; computed

Let T* = F[P(ā₁),…,P(ā_m)] be a pattern template over {∈,=} with one metavariable P of arity n (metavariable-free,
parameter-free frame F, ā_k distinct bound variables), D = {T*[P := λz̄.φ_j]: j ≤ N} finite. For every class H with
PAT ⊆ H ⊆ SO°, D is an anchor for inst(T*) in H iff
(R) the main symbols of φ₁,…,φ_N are not all equal, and (N_i) for each i ≤ n some φ_j has z_i free.

Thm E is the one-metavariable case of Thm E′ (§2.9), where the (D)-type conditions are vacuous; the proof of "if" given
here is the SO° proof, and it is also the core of Thm E′'s proof.

*Proof of "if" (for H = SO°, hence for all smaller H).* Let T ∈ SO° cover D: D_j = Tη_j↓. Read bound variables in
locally nameless style (a bound variable is identified by its binder), so "x is bound above c" and "x is bound inside c"
are well defined.
Step 1 (skeleton). The root of φ_j[ā_k] is root(φ_j); by (R) every slot position p_k is a disagreement position, and
frame positions are common. By the rigid-prefix lemma (prior C2(a)) T's rigid skeleton is a prefix of F, and its
metavariable occurrences sit at frame positions or at slot roots, never strictly inside a slot. For such a position c
put κ(c) := T*|c, so D_j|c = κ(c)[P := φ_j].
Step 2 (one body-template per metavariable) **[proof text amended, referee F3]**. Let M have occurrences M(ū¹) at c₁,
…, M(ū^r) at c_r. In closure-normal form the arguments ū^s are metavariable-free terms of {∈,=}, i.e. bound variables in
scope *or parameters*, and they may repeat. Let β_j be the body of η_j(M); β_j is closed except holes and parameters, and
β_j[ū^s] = D_j|c_s for every s. Plugging leaves for holes does not change tree shape.
  (2a) *Shape.* D_j|c₁ and D_j|c_s agree with β_j at every non-hole position of β_j. At a slot root p of κ(c₁),
    D_j|c₁ has root(φ_j), a formula symbol, so p is a non-hole position and D_j|c_s has root(φ_j) at p too. If κ(c_s)
    had a frame symbol at p, all φ_j would share it; if p were strictly inside a slot of κ(c_s) with root p′, the frame
    symbol of κ(c₁) at p′ would be root(φ_j) for all j; both contradict (R). Symmetrically for slot roots of κ(c_s). So
    κ(c₁) and κ(c_s) have slots at the same positions and the same frame symbols at all non-leaf frame positions;
    frame *leaves* may differ.
  (2b) *Frame leaves.* Let q be a frame-leaf position of κ(c₁) carrying the variable v. If v is bound inside κ(c₁), then
    β₁|q is that same bound variable (holes become ū¹, which are bound above c₁ or parameters, not v), so κ(c_s)|q is
    the variable bound at the same relative binder; keep v. If v is bound above c₁, then β₁|q is a hole h_m with
    u¹_m = v (β₁ has no free bound variables; a parameter is not v); if ū¹ has repetitions, m is whichever hole β₁ uses.
    Record m. By (2a), q is a frame-leaf position of κ(c_s) too (its ancestors are non-leaf frame positions there, and
    it is neither a slot root nor a non-leaf frame position, by the symmetric argument), so κ(c_s)|q = D₁|c_s|q = u^s_m.
  (2c) *Slot arguments.* Let κ(c₁) have the slot P(ā) at p and κ(c_s) the slot P(b̄) at p (one metavariable, so the
    slots carry the same P). For the i-th argument: by (N_i) choose j_i with z_i free in φ_{j_i} and a free occurrence
    q′ of z_i. At p·q′, D_{j_i}|c₁ has a_i. If a_i is bound inside κ(c₁), β_{j_i}|(p·q′) is that bound variable, so
    b_i is the variable bound at the same relative binder of κ(c_s); keep a_i. Otherwise β_{j_i}|(p·q′) = h_m with
    u¹_m = a_i; record m. Since D_{j_i}|c_s|p = φ_{j_i}[b̄] has b_i at q′, b_i = u^s_m.
  Let B_M be κ(c₁) with every recorded leaf or argument replaced by its recorded hole. B_M is closed except holes and
  T*'s metavariable P (every variable bound above c₁ was replaced). B_M[ū¹] = κ(c₁) because u¹_m is the replaced
  variable, and B_M[ū^s] = κ(c_s) for every s by (2a)–(2c). In particular every recorded u^s_m is a bound variable — it
  equals a frame variable of κ(c_s) — even though ū^s may contain parameters or repeated entries; any valid choice of
  β₁ and β_{j_i} works. (Term metavariables at frame leaves are the special case κ(c) = a variable.) The earlier text
  said "occurrence arguments are bound variables — true for templates over {∈,=}, which have no closed terms"; that
  sentence was inaccurate (parameters are closed terms in closure-normal form, and arguments may repeat), but the
  argument never used it beyond what (2b), (2c) establish.
Step 3. σ(M) := λh̄.B_M for every metavariable gives Tσ↓ = T*: each M-occurrence at c_s becomes B_M[ū^s] = κ(c_s), and
T's rigid part is F's. So T ⪰ T*, and inst(T) ⊇ inst(T*): for an instance T*θ, (Tσ)θ = T(σθ), where σθ(M) = λh̄.B_Mθ is a
closed λ-term, and plugging the leaves ū^s commutes with substituting P's closed body. ∎

*Proof of "only if" (witnesses in PAT, hence in every H ⊇ PAT).*
* (R) fails, all roots f: replace each P(ā_k) by Φ_f(ā_k) with Φ_∈(ā) = g₁(ā) ∈ g₂(ā), Φ_=(ā) = g₁(ā) = g₂(ā) (function
  metavariables; values projections or parameters), Φ_¬(ā) = ¬Q(ā), Φ_∘(ā) = Q₁(ā) ∘ Q₂(ā) for binary ∘,
  Φ_Q(ā) = Qw.R(ā, w) for Q ∈ {∀, ∃, ∃!}. Every occurrence is a pattern occurrence; the template covers D (atoms of the
  language have variables or parameters as arguments) and misses T*[P := λz̄.ψ] for ψ with another root.
* (N_i) fails: replace each P(ā_k) by P′(ā_k minus its i-th entry); this covers D and misses T*[P := λz̄.(z_i = z_i)],
  whose content at a slot has the deleted variable free. ∎

**Per schema** (anchor events; two instances suffice in every case):

| schema | anchor iff | minimal anchor example (bodies) |
|---|---|---|
| Sep | (R), N_x, N_z | x∈z, ¬(x=a) |
| SepJ | (R), N_u | u∈a, ¬(u=u) |
| EInd | (R), N_x | x∈x, ¬(x=x) |
| Coll, ReplU, ReplS | (R), N_x, N_y, N_A | y=x, ¬(x=A) |
| ReplJ | (R), N_x, N_y | x∈y, ¬(x=a) |
| Found and every other ground ZFC axiom | the sentence itself | one instance |

If the community never lets φ mention the bounding set z (resp. the domain A), the learner stays at the sound
specialization with P(x) (resp. P(x,y)) — e.g. Jech's Separation instead of Kunen's.

*Remarks.* (1) Two instances suffice; one never does. (2) In {∈,=} there are no function symbols, so the "shielding"
phenomenon that separates SO° from DT° for PA induction (prior C7, condition (B)) and for Q1 in the PA language
(Prop A2′) cannot occur *for one metavariable*: DT° and SO° have the same anchors here. With several metavariables they
differ even in {∈,=} (Thm E′(c)). (3) With (R) + all (N_i) the cautious DT° verifier accepts exactly inst(T*), and before
that it is sound (T* ∈ DT° covers D; lem:imitation:cautious(a)).

**Lemmas for the enumeration (E1–E4) — proved.** Every covering template T is ⪰ one produced by the reduced enumerator
`st_enum.enumerate_dt_reduced`, so D is an anchor iff all produced templates are ⪰ T*: E1 rigid-prefix lemma (prior
C2(a)); E2 term metavariables at common positions can be replaced by their (forced, datum-independent) value, which
specializes T and keeps coverage; E3 in DT° an argument whose hole is unused by the (unique) bodies of all data can be
deleted at all occurrences (a specialization that keeps coverage and determinacy), so the own pattern occurrence's
arguments are exactly the free context variables of its column, in canonical order (argument permutation = renaming);
E4 every other occurrence of the metavariable has its arguments forced by the data (each hole is used in some datum).

*Evidence.*
* `z2_anchors.py` → `z2_anchors.out` (430 s on 4 cores; not re-run in this revision). Phase A, all 7 schemas, all 16
  singletons and all 120 pairs of each pool: no singleton is an anchor; for pairs with (R) the reduced DT° enumeration
  (complete for anchor-hood by E1–E4) gives anchor ⟺ all (N_i); for pairs without (R) the most specific covering DT°
  template on the maximal common prefix (`st_enum.most_specific_own`, root-specialized, e.g.
  ∀z∃y∀x(x∈y ↔ x∈z ∧ f₀(x,z) ∈ f₁(x,z)) for bodies x∈z, z∈x) is not ⪰ T*. Agreement "anchor ⟺ (R) ∧ all (N_i)": 120/120
  for every schema (anchors: Sep 97, SepJ 104, EInd 104, Coll/ReplU/ReplS 62, ReplJ 97). Typical non-anchor witness with
  (R) but not N_A (ReplU, bodies y=x, x∈y): ∀A(P₀(A) → ∃Y∀x(P₁(x,A) → P₂(x,Y))). Phase B, Sep, SepJ, EInd, all pairs with
  (R) (107, 110, 110): the full data-directed enumeration in DT° and in SO° (arity ≤ 3; every run finished within its
  10 s limit) agrees with (R) ∧ (N) on every pair. Every anchor pair has the *same* number of covering templates (Sep:
  DT° 986, SO° 4078; SepJ: 1325, 7103; EInd: 77, 2459) — consistent with the fact that for an anchor the covering
  templates are exactly the generalizations of T* (the analogue of prior C4's 26 generalizations of T_ind).
* `z2b_fullcheck.py` → `z2b_fullcheck.out` (stopped by a 20-minute budget): the full DT° enumeration on the large Coll
  frame finished for 2 anchor pairs (64 943 covering templates each, all ⪰ T*) and for 3 non-anchor pairs; all agree.
  The three ReplJ anchor pairs did not finish and are not counted.
* **[new]** `z9_anchor_search.py SCHEMA 10 3 2 1` → `z9_<SCHEMA>.out` (bounded single-group search of `dt_search.py`,
  group size ≤ 3, arity ≤ 2 (≤ 1 for groups of size 3), arguments: bound variables in scope and the parameter a,
  12 genuine probes; 10 anchor and 10 non-anchor pairs per schema, in DT° and SO°): DT° agreement with (R) ∧ (N) 20/20
  for each of the seven schemas, SO° verdicts identical to DT° verdicts on all 140 pairs; and
  `z9_anchor_search.py ReplJ 3 3 2 2` → `z9_ReplJ_deep.out` (arity ≤ 2 also for groups of size 3, i.e. including the
  group of all three ReplJ slots). See §4 for the numbers. This closes the ReplJ gap of `z2b` at the level of evidence;
  the referee's independent search covers 35 ReplJ anchor pairs with 0 disagreements
  (`referee_code/r3_anchor_A_ReplJ_big.out`), and the proof covers all cases.

### 2.9 Thm E′ (several metavariables) [new] — proved; computed

Let T* be a pattern template over {∈,=} (with parameters) with metavariables P, Q, … (arities n_P, …), every
occurrence a pattern occurrence, frame metavariable-free and parameter-free. Data D_j = T*θ_j with θ_j(P) = λz̄.φ_{P,j}.
For an ordered pair (P, Q) of distinct metavariables and a map π: [n_P] → [n_Q] ∪ Par write φ∘π for φ with each hole
z_i replaced by z_{π(i)} (resp. by the parameter π(i)). Events:
* (R_P): the roots of φ_{P,1},…,φ_{P,N} are not all equal; (N_{P,i}): some φ_{P,j} has z_i free;
* (D^PAT_{PQ}): there is no bijection π: [n_P] → [n_Q] with φ_{Q,j} = φ_{P,j}∘π for all j (vacuous if n_P ≠ n_Q; symmetric);
* (D^DT_{P→Q}): there is no map π: [n_P] → [n_Q] ∪ Par with φ_{Q,j} = φ_{P,j}∘π for all j;
* (D⁺_{PQ}): some j has root(φ_{P,j}) ≠ root(φ_{Q,j}).
D⁺ ⇒ D^DT (both directions) ⇒ D^PAT. Assume (R_P) and all (N_{P,i}) throughout. Then:
(a) D is an anchor in PAT iff (D^PAT_{PQ}) for all P ≠ Q;
(b) D is an anchor in DT° iff (D^DT_{P→Q}) for all ordered pairs P ≠ Q;
(c) in SO°: (D⁺_{PQ}) for all P ≠ Q ⇒ anchor ⇒ (D^DT_{P→Q}) for all ordered pairs; and the second implication cannot be
reversed: there are DT° anchors that are not SO° anchors.
Without (R_P) or (N_{P,i}), D is an anchor in no class between PAT and SO° (Thm E's witnesses, applied to P).
(This supersedes the "Remark (several metavariables)" of `notes.md` §2.8, which sketched one (D)-type event — "no
datum-independent argument renaming makes φ_{P,j}[ā_k] = φ_{Q,j}[b̄_l] for all j" — without fixing the class; the
renamings allowed are exactly what distinguishes PAT, DT° and SO°.)

**Facing lemma.** Let T ∈ SO° cover D, let M be a metavariable of T with occurrences M(ū^s) at c_s and bodies β_j, and
assume (R_P) for all P. (1) κ(c₁) and κ(c_s) have slots at the same positions and the same frame symbols at non-leaf
frame positions. (2) If κ(c₁) has a P-slot P(ā) at p and κ(c_s) a Q-slot Q(b̄) at p, then root(φ_{P,j}) = root(φ_{Q,j})
for all j. If moreover ū¹ is a pattern tuple and (N_P) holds, there is a map π: [n_P] → [n_Q] ∪ Par, independent of j,
with φ_{Q,j} = φ_{P,j}∘π for all j; if also ū^s is a pattern tuple and (N_Q) holds, π is a bijection onto [n_Q].
*Proof.* (1) is Step 2a of Thm E with (R_P) for the metavariable at each slot. (2) The root claim is the first sentence
of 2a. Let γ_j := β_j|p, so φ_{P,j}[ā] = γ_j with holes ↦ ū¹ and φ_{Q,j}[b̄] = γ_j with holes ↦ ū^s (relative binders
kept). Define π(i) for i ∈ [n_P]: by (N_P) pick j with a free occurrence q′ of z_i in φ_{P,j}; the leaf of
φ_{P,j}[ā] at q′ is a_i. (α) If a_i is bound above c₁, then γ_j|q′ = h_m with u¹_m = a_i, m unique because ū¹ is a
pattern tuple; the leaf of φ_{Q,j}[b̄] at q′ is u^s_m, which is free relative to p, hence equals some b_{i′} or is a
parameter; put π(i) := i′, resp. that parameter. (β) If a_i is bound by the binder at relative position r between c₁ and
p, then γ_j|q′ is the variable bound at r, and the leaf of φ_{Q,j}[b̄] at q′ is the variable bound at r in κ(c_s), which
lies above p, hence is some b_{i′}; put π(i) := i′. In both cases π(i) depends only on a_i (through m or r), not on j or q′.
Now compare φ_{P,j}[ā] and φ_{Q,j}[b̄] leaf by leaf through γ_j: constants, parameters and variables bound inside γ_j
below p are the same in both; a hole h_m gives u¹_m = a_i (a free leaf of the slot, hence an argument, as ū¹ consists of
bound variables) and u^s_m = (b_{π(i)} or π(i)); a variable bound between c₁ and p gives a_i and b_{π(i)}. Hence
φ_{Q,j} = φ_{P,j}∘π. If ū^s is also a pattern tuple, u^s_m is a bound variable, so π maps into [n_Q]; π is injective
(distinct a_i give distinct m or distinct r, hence distinct u^s_m or distinct binders, and the two cases give variables
bound above resp. below c_s); and every b_{i′} free in some φ_{Q,j}[b̄] arises from a hole or a binder between c_s and p,
hence from some a_i, so under (N_Q) π is onto [n_Q]. ∎

*Proof of the theorem.* "If" parts: let T in the class cover D. Step 1 of Thm E holds verbatim (using (R_P) for every
P). For each metavariable M of T choose c₁ as follows: in PAT and DT° a pattern occurrence of M; in SO° any. Every slot
of κ(c₁) faces, in each κ(c_s), a slot of the *same* metavariable: in SO° by (D⁺) and the root claim of (2); in DT° by
(D^DT) and the map of (2); in PAT by (D^PAT) and the bijection of (2). Then Steps 2b, 2c, 3 of Thm E apply slot by slot
(with (N_{P,i}) for the metavariable of each slot) and give T ⪰ T*.
"Only if": if (D^PAT_{PQ}) fails via the bijection π, let T′ := T* with every Q(b̄) replaced by P(b_{π(1)},…,b_{π(n_P)}) —
a pattern occurrence (b̄ distinct, π bijective). Then T′[P := λz̄.φ_{P,j}] = D_j, since φ_{P,j}∘π plugged with b̄ is
φ_{Q,j}[b̄]; and T′ misses every instance of T* whose P- and Q-bodies have different roots (in T′ the roots at the P-slots
and the former Q-slots coincide), which exist. So D is not a PAT anchor, nor an anchor in any larger class. If
(D^DT_{P→Q}) fails via π, the same construction with arguments w_i := b_{π(i)} or the parameter π(i) gives T′ ∈ DT° (P
keeps its pattern occurrences; the new occurrences have metavariable-free arguments), which covers D and misses the
same instances; so D is not a DT° (or SO°) anchor. The separation in (c) is the computed example below: there the SO°
template ∀x∀y(G(x,y,x) → G(x,x,y)) covers D and misses a genuine instance, while (D^DT) holds, so D is a DT° anchor
by (b). ∎

**Cor F′ (pattern lgg with several metavariables) — proved.** The least general pattern generalization L_pat(D) is ≡ T*
iff (R), (N) and (D^PAT) hold; otherwise it is a strict specialization of T* (sound). *Proof.* As Cor F (§2.10), with
Thm E′(a) in place of Thm E. ∎

*Separating examples (computed).* (i) PAT anchor, not a DT° anchor: T_B := ∀x∀y(P(x,y) → Q(x)), data
(P, Q) = (x∈y, x∈x) and (¬x=y, ¬x=x). (R), (N), (D^PAT) hold (arities differ), so the pattern lgg returns T_B; but
Q's bodies are P's bodies with π = (1,1) (diagonal), and the DT° template ∀x∀y(P(x,y) → P(x,x)) covers both data and
misses ∀x∀y(x∈y → ¬x=x). A parameter variant: Q-bodies x∈a, ¬a=x against P-bodies x∈y, ¬y=x, witness
∀x∀y(P(x,y) → P(x,a)). (ii) DT° anchor, not an SO° anchor: T_A := ∀x∀y(P(x,y) → Q(x,y)), data (x∈y, y∈x) and
(¬x=y, ¬x=x): (R), (N), (D^PAT), (D^DT) hold, (D⁺) fails; the SO° template ∀x∀y(G(x,y,x) → G(x,x,y)) covers both data
(G := λh₁h₂h₃.h₃∈h₂, resp. λh₁h₂h₃.¬h₁=h₂) and misses ∀x∀y(x∈y → ¬x=x).

*Evidence.* `z7_multi.py` → `z7_multi.out` (12 s). (1) PAT: for T_A, T_B and T_C := ∀x(P(x) → Q(x)) → (∀xP(x) → ∀xQ(x)),
1500 random data sets each (pairs and triples, 35 % drawn with a planted coincidence map): "pattern lgg ≡ T*" ⟺
(R) ∧ (N) ∧ (D^PAT) on 1500/1500 for each; for T_B, 402 of these PAT anchors violate (D^DT). (2) DT°: bounded
single-group search on 150 random pairs with (R) ∧ (N) for T_B and for T_A: anchor ⟺ (D^DT) on 150/150 each (1404 and
1235 covering templates examined). (3) The two separating examples, verified by matching (the SO° template is not
determinate; the bounded DT° search finds no covering template missing a probe). (4) SO°: on 120 random pairs per
template, every pair with (D⁺) is an SO° anchor (70/70, 43/43) and every pair violating (D^DT) is not (0/46, 0/74); the
few random pairs with (D^DT) but not (D⁺) (4 and 3) happened to be SO° anchors, so whether (D⁺) is necessary in SO° is
not settled by this evidence (conjecture: no — the exact SO° condition is data-dependent, as example (ii) shows).

### 2.10 Cor F (pattern anti-unification recovers every ZF schema) — proved; computed

Let L_pat(D) be the least general pattern generalization (exists and is unique: Pfenning 1991; Baumgartner, Kutsia,
Levy, Villaret 2017, J. Autom. Reasoning 58 — known). For D ⊆ inst(T*) (T* a pattern template as in Thm E):
L_pat(D) ⪯ T*, and L_pat(D) ≡ T* iff (R) ∧ all (N_i).
*Proof.* T* ∈ PAT covers D, so L_pat ⪯ T*. If (R) ∧ (N), Thm E's proof (H = PAT) gives L_pat ⪰ T* (it constructs σ with
L_pat σ↓ = T*). Otherwise the PAT witnesses of Thm E cover D and do not contain inst(T*), and they are ⪰ L_pat, so
L_pat ≢ T*. ∎

*Evidence.* `z3_pattern_lgg.py` → `z3_pattern_lgg.out` (re-run: identical): own n-ary implementation (common prefix;
generalization variable applied to the bound variables free in the column; merge of columns equal up to a permutation of
the arguments — BKLV's merge rule). On all 120 pairs and 400 random triples per schema: the result is a pattern template,
covers the data, is ⪯ T*, and is ≡ T* iff (R) ∧ (N) (120/120 and 400/400 for all 7 schemas). Example: from Coll(y = x)
and Coll(¬x = A) it returns Coll's template verbatim. The same code style on PA induction (prior so_core) returns the
unsound T12 = (A ∧ ∀x(P(x) → Q(x))) → ∀xP(x) — the prior C9 contrast. The permutation merge matters: Replacement's P(x,y)
and P(x,u) columns are equal only up to renaming y ↔ u. Referee: own BKLV-style implementation, 3500/3500 data sets, and
10 500 random instances of the lgg all genuine (`referee_code/r3_anchor_B.out`).

### 2.11 Thm G (rates for the ZF learners) — proved; computed

Bodies i.i.d. from μ. With C_{F,I} := {φ: (F = * or root(φ) = F) and no z_i, i ∈ I, free in φ},
P[D_N is not an anchor] = Σ_{(F,I) ≠ (*,∅)} (−1)^{[F≠*] + |I| + 1} μ(C_{F,I})^N
(sum over F ∈ {*} ∪ roots, I ⊆ {1..n}), ≤ Σ_f p_f^N + Σ_i (1−q_i)^N, where p_f = μ(root f), q_i = μ(z_i free).
*Proof.* "Not an anchor" = ⋃_f A_f ∪ ⋃_i B_i (Thm E), A_f = all roots f, B_i = z_i never free. The A_f are pairwise
disjoint, and ⋂ of A_f (or none) with B_i, i ∈ I, is "all samples in C_{F,I}"; inclusion–exclusion. ∎
*Evidence.* `z6_rates.py` → `z6_rates.out`: uniform and atom-skewed laws on the 16-body pools, 3000 Monte-Carlo trials
with the pattern lgg: exact and MC agree within sampling error for all N ∈ {2,…,12}. N needed for δ = 0.01: Sep 5 / 9
(uniform / skewed), EInd 4 / 6, Coll and ReplS 10 / 16 (three (N_i) events), ReplJ 5 / 9. Referee: own inclusion–exclusion
against own Monte Carlo, 7 schemas, 2 laws, N = 2..8 (`referee_code/r4_rates.out`).
