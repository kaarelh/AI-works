import InfLearn.Steps

/-!
# The learning-theoretic Carnap problem (T2 §4)

Formalization of T2 §4 ("The learning-theoretic Carnap problem"): Lemma 4.1, Theorem 4.2,
Theorem 4.3 (denial-rank trichotomy) and Theorem 4.4 (bilateral determinacy with a finite
tell-tale; non-identifiability without structurality, as revised after verification).

## Setting
* `GVal := Formula → Bool` — *general* valuations (not necessarily compositional), with the
  product (Cantor-space) topology inherited from Mathlib; `BV` = range of `ofAtoms`
  (Boolean valuations); `vtop` (all-true), `vTaut` (characteristic function of `Taut`),
  `charFn T`.
* `SCons V X φ` (`X ⊨¹_V φ`, arbitrary premise sets), `MCons V X Y` (`X ⊨ᵐ_V Y`).
* Finite sequents: `MSeq` (multiple-conclusion, = positions `[Γ : Δ]`), `SSeq`
  (single-conclusion); `mrel V`, `srel V` the valid finite sequents; `Val S`, `SValS S` the
  valuations satisfying a set of sequents; `InBounds V s` (a position is realized in `V`).
* `intClosure V` = `V^∩` (intersections of true-sets of arbitrary subfamilies, including the
  empty one, giving `vtop`).
* `CV V : ConsOp Formula` = `X ↦ ⋂{v ∈ V : X ⊆ v}`.

## Main results (paper reference → Lean)
* Lemma 4.1(a): `Val_mrel : Val (mrel V) = closure V`; `mrel_eq_iff_closure_eq`,
  `eq_of_mrel_eq` (closed meanings are determined by `⊨ᵐ`).
* Lemma 4.1(b): `isClosed_CV_iff` (`Fix(C_V) = V^∩`), `lemma_4_1_b` (`CV V` finitary and `SValS (srel V) = intClosure V` for closed
  `V`); general `SValS_srel : SValS (srel V) = intClosure (closure V)`; for arbitrary premise
  sets and arbitrary `V`, `SVal_eq_intClosure`.
* Lemma 4.1(c): `mem_intClosure_BV_iff : w ∈ BV^∩ ↔ Cn2.IsClosed (trueSet w)`,
  `intClosure_BV_eq : BV^∩ = charFn '' {T | Cn2.IsClosed T}`.
* Theorem 4.2: `SCons_eq_of_subset_intClosure`, `carnap_single`, `carnap_single_vtop`,
  `carnap_single_vTaut`, `carnap_problem` (same `⊨¹`, different `⊨ᵐ`, for every
  `BV ⊊ W ⊆ BV^∩`), `carnap_vtop`, `carnap_vTaut` (explicit separating sequents),
  `carnap_not_learnable_single` (learning form), `mem_intClosure_BV_diff_BV_iff`,
  `intClosure_BV_and`, `vtop_violates_neg`, `consistent_nonBoolean_violates`,
  `isClosed_intClosure_BV`, `intClosure_BV_structural`.
* Theorem 4.3: `denialRank_eq_zero_iff`, `denialRank_eq_one_iff`, `denialRank_eq_two_iff`,
  `denialRank_eq_top_iff`, `denialRank_le_two_of_not_mem_BV`, `denialRank_vtop`,
  `denialRank_vTaut`.
* Theorem 4.4(a): `Val_TTall : Val TTall = BV`, `isClosed_BV`, `mrel_eq_mrel_BV_iff`.
* Theorem 4.4(b),(c): `structural_eq_BV`, `finite_telltale_structural`, `empty_survives`,
  `ttLearner_finite_identification`.
* Theorem 4.4(d): `no_finite_telltale`, `mrel_flip_ssubset`, `isClosed_BV_union_flipAt`,
  `BV_not_BC_learnable`, `BV_not_BC_learnable_meaning`, `BV_not_determined_nonstructural`;
  generic Gold/Angluin machinery `exists_locking`, `not_BCIdentifies_of_no_telltale`.

## Deviations from the paper (documented)
* Our `Formula` also has the constants `⊥, ⊤`.  The truth-table schemata `TT` therefore
  contain two extra schemata `⊥ ▷` and `▷ ⊤` (13 instead of 11), so the finite tell-tale of
  Thm 4.4(b)–(c) has 13 + 1 data instead of 11 + 1.  The constant substitution in the proof of
  4.4(b) uses `⊤/⊥` (`Subst.ofVal`) instead of `p₀ ∨ ¬p₀` / `¬(p₀ ∨ ¬p₀)`.
* Learning (Thm 4.2 learning form, Thm 4.4(c),(d)) is formalized for texts with pauses and
  arbitrary (noneffective) learners mapping finite data sequences to conjectures; Thm 4.4(d)
  is proved for BC-identification (which EX-identification implies, `EXIdentifies.bc`).  The
  coherence datum `[ : ]` of 4.4(d) holds for every member of the class
  (`inBounds_empty_flip`), so it carries no information and is not modelled as input.
-/

namespace InfLearn
namespace Carnap

open Formula

/-! ## General valuations and the two consequence relations -/

/-- A *general valuation*: an arbitrary map `Fm → {0,1}`, not necessarily compositional
(T2 §4.1).  We identify it with its true-set `trueSet v`. -/
abbrev GVal := Formula → Bool

/-- The (compositional) Boolean valuation induced by an assignment to the atoms. -/
def ofAtoms (a : Valuation) : GVal := fun φ => φ.eval a

@[simp] theorem ofAtoms_apply (a : Valuation) (φ : Formula) : ofAtoms a φ = φ.eval a := rfl

/-- `BV`: the Boolean (truth-table) valuations. -/
def BV : Set GVal := Set.range ofAtoms

theorem ofAtoms_mem_BV (a : Valuation) : ofAtoms a ∈ BV := ⟨a, rfl⟩

/-- The true-set of a valuation. -/
def trueSet (v : GVal) : Set Formula := {φ | v φ = true}

@[simp] theorem mem_trueSet {v : GVal} {φ : Formula} : φ ∈ trueSet v ↔ v φ = true := Iff.rfl

/-- Single-conclusion consequence `X ⊨¹_V φ` (premise sets arbitrary). -/
def SCons (V : Set GVal) (X : Set Formula) (φ : Formula) : Prop :=
  ∀ v ∈ V, (∀ ψ ∈ X, v ψ = true) → v φ = true

/-- Multiple-conclusion consequence `X ⊨ᵐ_V Y`: no `v ∈ V` makes all of `X` true and all of
`Y` false. -/
def MCons (V : Set GVal) (X Y : Set Formula) : Prop :=
  ∀ v ∈ V, (∀ ψ ∈ X, v ψ = true) → ∃ χ ∈ Y, v χ = true

/-- `V^∩`: valuations whose true-set is the intersection of the true-sets of some subfamily
`F ⊆ V` (the empty subfamily gives the all-true valuation `v_⊤`). -/
def intClosure (V : Set GVal) : Set GVal :=
  {w | ∃ F ⊆ V, ∀ φ, w φ = true ↔ ∀ v ∈ F, v φ = true}

/-- The all-true valuation `v_⊤`. -/
def vtop : GVal := fun _ => true

/-- The characteristic function `v_T` of a set of formulas `T`. -/
noncomputable def charFn (T : Set Formula) : GVal := fun φ => @decide (φ ∈ T) (Classical.dec _)

@[simp] theorem charFn_eq_true {T : Set Formula} {φ : Formula} : charFn T φ = true ↔ φ ∈ T := by
  simp [charFn]

@[simp] theorem trueSet_charFn (T : Set Formula) : trueSet (charFn T) = T := by
  ext φ; simp

/-- Carnap's tautology valuation `v_Taut`, the characteristic function of `Taut`. -/
noncomputable def vTaut : GVal := charFn Taut

/-! ### Basic facts -/

theorem SCons.anti {V W : Set GVal} (h : V ⊆ W) {X : Set Formula} {φ : Formula}
    (hW : SCons W X φ) : SCons V X φ := fun v hv => hW v (h hv)

theorem MCons.anti {V W : Set GVal} (h : V ⊆ W) {X Y : Set Formula}
    (hW : MCons W X Y) : MCons V X Y := fun v hv => hW v (h hv)

theorem subset_intClosure (V : Set GVal) : V ⊆ intClosure V := by
  intro v hv
  refine ⟨{v}, Set.singleton_subset_iff.2 hv, fun φ => ?_⟩
  simp

theorem vtop_mem_intClosure (V : Set GVal) : vtop ∈ intClosure V :=
  ⟨∅, Set.empty_subset _, fun φ => by simp [vtop]⟩

/-- `⊨¹` depends only on the ∩-closure (any premise sets). -/
theorem SCons_intClosure_iff {V : Set GVal} {X : Set Formula} {φ : Formula} :
    SCons (intClosure V) X φ ↔ SCons V X φ := by
  refine ⟨SCons.anti (subset_intClosure V), fun h w hw hX => ?_⟩
  obtain ⟨F, hFV, hF⟩ := hw
  rw [hF]
  intro v hv
  exact h v (hFV hv) fun ψ hψ => (hF ψ).1 (hX ψ hψ) v hv

/-- **Lemma 4.1 consequence / Thm 4.2 (general form).**  If `V ⊆ W ⊆ V^∩` then
`⊨¹_V = ⊨¹_W`. -/
theorem SCons_eq_of_subset_intClosure {V W : Set GVal} (hVW : V ⊆ W)
    (hW : W ⊆ intClosure V) : SCons W = SCons V := by
  funext X φ
  apply propext
  exact ⟨fun h => SCons.anti hVW h, fun h => SCons.anti hW (SCons_intClosure_iff.2 h)⟩

/-- `Val(⊨¹_V)` for arbitrary (possibly infinite) premise sets. -/
def SVal (V : Set GVal) : Set GVal :=
  {w | ∀ X φ, SCons V X φ → (∀ ψ ∈ X, w ψ = true) → w φ = true}

/-- With arbitrary premise sets, the valuations respecting `⊨¹_V` are exactly `V^∩`
(for every `V`; no topological hypothesis needed). -/
theorem SVal_eq_intClosure (V : Set GVal) : SVal V = intClosure V := by
  ext w
  constructor
  · intro hw
    refine ⟨{v | v ∈ V ∧ ∀ ψ, w ψ = true → v ψ = true}, fun v hv => hv.1, fun φ => ?_⟩
    constructor
    · intro hφ v hv
      exact hv.2 φ hφ
    · intro h
      exact hw (trueSet w) φ (fun v hv hX => h v ⟨hv, fun ψ hψ => hX ψ hψ⟩) (fun ψ hψ => hψ)
  · intro hw X φ hXφ hX
    exact (SCons_intClosure_iff.2 hXφ) w hw hX

theorem intClosure_mono {V W : Set GVal} (h : V ⊆ W) : intClosure V ⊆ intClosure W := by
  rintro w ⟨F, hF, hw⟩
  exact ⟨F, hF.trans h, hw⟩

/-! ### Boolean valuations -/

theorem mem_BV_iff {w : GVal} : w ∈ BV ↔ ∀ φ, w φ = φ.eval (fun n => w (var n)) := by
  constructor
  · rintro ⟨a, rfl⟩ φ
    rfl
  · intro h
    exact ⟨fun n => w (var n), funext fun φ => (h φ).symm⟩

theorem SCons_BV_iff {X : Set Formula} {φ : Formula} : SCons BV X φ ↔ SemCons X φ := by
  constructor
  · intro h a ha
    exact h (ofAtoms a) (ofAtoms_mem_BV a) ha
  · rintro h _ ⟨a, rfl⟩ hX
    exact h a hX

theorem MCons_BV_iff {X Y : Set Formula} :
    MCons BV X Y ↔ ∀ a : Valuation, Satisfies a X → ∃ χ ∈ Y, χ.eval a = true := by
  constructor
  · intro h a ha
    exact h (ofAtoms a) (ofAtoms_mem_BV a) ha
  · rintro h _ ⟨a, rfl⟩ hX
    exact h a hX

/-- **Lemma 4.1(c).**  `BV^∩` is the set of characteristic functions of CPC-theories
(`C₂`-closed sets, including `Fm`). -/
theorem mem_intClosure_BV_iff {w : GVal} : w ∈ intClosure BV ↔ Cn2.IsClosed (trueSet w) := by
  rw [← SVal_eq_intClosure]
  constructor
  · intro hw φ hφ
    exact hw (trueSet w) φ (SCons_BV_iff.2 hφ) (fun ψ hψ => hψ)
  · intro hw X φ hXφ hX
    exact hw (SemCons.mono (fun ψ hψ => hX ψ hψ) (SCons_BV_iff.1 hXφ))

theorem charFn_mem_intClosure_BV_iff {T : Set Formula} :
    charFn T ∈ intClosure BV ↔ Cn2.IsClosed T := by
  rw [mem_intClosure_BV_iff, trueSet_charFn]

theorem charFn_trueSet (w : GVal) : charFn (trueSet w) = w := by
  funext φ
  cases h : w φ <;> simp [charFn, h]

/-- **Lemma 4.1(c), set form.**  `BV^∩ = {v_T | T a CPC-theory}` (with `T = Fm` allowed). -/
theorem intClosure_BV_eq : intClosure BV = charFn '' {T | Cn2.IsClosed T} := by
  ext w
  constructor
  · intro hw
    exact ⟨trueSet w, mem_intClosure_BV_iff.1 hw, charFn_trueSet w⟩
  · rintro ⟨T, hT, rfl⟩
    exact charFn_mem_intClosure_BV_iff.2 hT

theorem vTaut_mem_intClosure_BV : vTaut ∈ intClosure BV := by
  rw [vTaut, charFn_mem_intClosure_BV_iff, ← Cn2_empty]
  exact Cn2.isClosed_apply ∅


/-- `w` is Boolean iff its true-set is a maximal consistent theory: closed, satisfiable and
complete (`φ` or `¬φ` true, for every `φ`). -/
theorem mem_BV_iff_maximal {w : GVal} :
    w ∈ BV ↔ Cn2.IsClosed (trueSet w) ∧ Satisfiable (trueSet w) ∧
      ∀ φ, w φ = true ∨ w (neg φ) = true := by
  constructor
  · rintro ⟨a, rfl⟩
    refine ⟨fun φ hφ => hφ a (fun ψ hψ => hψ), ⟨a, fun ψ hψ => hψ⟩, fun φ => ?_⟩
    cases h : φ.eval a <;> simp [h]
  · rintro ⟨hcl, ⟨a, ha⟩, hcomp⟩
    refine ⟨a, funext fun φ => ?_⟩
    show φ.eval a = w φ
    cases hw : w φ
    · rcases hcomp φ with h | h
      · rw [hw] at h; exact absurd h (by simp)
      · have := ha _ h
        simpa using this
    · exact ha φ hw

/-- Boolean valuations obey the truth table of `¬`. -/
theorem BV_neg {w : GVal} (hw : w ∈ BV) (φ : Formula) : w (neg φ) = !(w φ) := by
  obtain ⟨a, rfl⟩ := hw; rfl

/-- **Thm 4.2, "indistinguishable non-Boolean valuations".** The members of `BV^∩ \ BV` are
exactly the `v_T` for CPC-theories `T` that are not maximal consistent. -/
theorem mem_intClosure_BV_diff_BV_iff {w : GVal} :
    w ∈ intClosure BV \ BV ↔ Cn2.IsClosed (trueSet w) ∧
      ¬ (Satisfiable (trueSet w) ∧ ∀ φ, w φ = true ∨ w (neg φ) = true) := by
  rw [Set.mem_sdiff, mem_intClosure_BV_iff, mem_BV_iff_maximal]
  tauto

/-! ## Theorem 4.2 (Carnap 1943, learning form): single-conclusion part -/

/-- **Theorem 4.2.**  `⊨¹_BV = ⊨¹_W` for every `W` with `BV ⊆ W ⊆ BV^∩`. -/
theorem carnap_single {W : Set GVal} (hBW : BV ⊆ W) (hW : W ⊆ intClosure BV) :
    SCons W = SCons BV :=
  SCons_eq_of_subset_intClosure hBW hW

/-- `⊨¹_BV` is classical consequence. -/
theorem SCons_BV_eq : SCons BV = SemCons := by
  funext X φ; exact propext SCons_BV_iff

/-- Carnap's first non-normal interpretation: adding `v_⊤`. -/
theorem carnap_single_vtop : SCons (BV ∪ {vtop}) = SCons BV :=
  carnap_single Set.subset_union_left
    (Set.union_subset (subset_intClosure BV) (Set.singleton_subset_iff.2 (vtop_mem_intClosure BV)))

/-- Carnap's second non-normal interpretation: adding `v_Taut`. -/
theorem carnap_single_vTaut : SCons (BV ∪ {vTaut}) = SCons BV :=
  carnap_single Set.subset_union_left
    (Set.union_subset (subset_intClosure BV) (Set.singleton_subset_iff.2 vTaut_mem_intClosure_BV))

/-- Both together (and with all of `BV^∩`). -/
theorem carnap_single_intClosure : SCons (intClosure BV) = SCons BV :=
  carnap_single (subset_intClosure BV) subset_rfl

/-! ### Which truth tables the non-normal valuations violate (Thm 4.2, bullets) -/

/-- The atom `p = p₀`. -/
abbrev p : Formula := var 0

theorem p_not_taut : ¬ Tautology p := fun h => by simpa using h (fun _ => false)

theorem negp_not_taut : ¬ Tautology (neg p) := fun h => by simpa using h (fun _ => true)

/-- Every member of `BV^∩` respects the truth table of `∧` (∧ is categorical even
single-conclusionally). -/
theorem intClosure_BV_and {w : GVal} (hw : w ∈ intClosure BV) (φ ψ : Formula) :
    w (Formula.and φ ψ) = (w φ && w ψ) := by
  obtain ⟨F, hF, hwF⟩ := hw
  have key : ∀ v ∈ F, v (Formula.and φ ψ) = (v φ && v ψ) := by
    intro v hv
    obtain ⟨a, rfl⟩ := hF hv
    rfl
  apply Bool.eq_iff_iff.2
  rw [hwF, Bool.and_eq_true, hwF, hwF]
  constructor
  · intro h
    exact ⟨fun v hv => by have := h v hv; rw [key v hv] at this; simp_all,
      fun v hv => by have := h v hv; rw [key v hv] at this; simp_all⟩
  · rintro ⟨h1, h2⟩ v hv
    rw [key v hv, h1 v hv, h2 v hv]; rfl

/-- `v_⊤` violates the table of `¬`. -/
theorem vtop_violates_neg : vtop (neg p) ≠ !(vtop p) := by simp [vtop]

@[simp] theorem vTaut_eq_true {φ : Formula} : vTaut φ = true ↔ Tautology φ := by
  simp [vTaut]

theorem vTaut_p : vTaut p = false := by
  cases h : vTaut p
  · rfl
  · exact absurd (vTaut_eq_true.1 h) p_not_taut

theorem vTaut_negp : vTaut (neg p) = false := by
  cases h : vTaut (neg p)
  · rfl
  · exact absurd (vTaut_eq_true.1 h) negp_not_taut

/-- `v_Taut` violates the table of `¬`. -/
theorem vTaut_violates_neg : vTaut (neg p) ≠ !(vTaut p) := by
  rw [vTaut_p, vTaut_negp]; decide

/-- `v_Taut` violates the table of `∨`: `p ∨ ¬p` is true while both disjuncts are false. -/
theorem vTaut_violates_or : vTaut (Formula.or p (neg p)) ≠ (vTaut p || vTaut (neg p)) := by
  have : vTaut (Formula.or p (neg p)) = true := by
    rw [vTaut_eq_true]; intro v; cases h : v 0 <;> simp [h]
  rw [this, vTaut_p, vTaut_negp]; decide

/-- `v_Taut` violates the table of `→`: `p → ¬p` is false although `p` is false. -/
theorem vTaut_violates_imp : vTaut (imp p (neg p)) ≠ (!(vTaut p) || vTaut (neg p)) := by
  have : vTaut (imp p (neg p)) = false := by
    cases h : vTaut (imp p (neg p))
    · rfl
    · have := vTaut_eq_true.1 h (fun _ => true); simp at this
  rw [this, vTaut_p, vTaut_negp]; decide

theorem vtop_not_mem_BV : vtop ∉ BV := fun h => vtop_violates_neg (BV_neg h p)

theorem vTaut_not_mem_BV : vTaut ∉ BV := fun h => vTaut_violates_neg (BV_neg h p)

/-! ## Theorem 4.2: the multiple-conclusion relation separates them -/

/-- Non-contradiction `p, ¬p ⊨ᵐ ∅` holds for `BV`. -/
theorem MCons_BV_noncontradiction : MCons BV {p, neg p} ∅ := by
  rw [MCons_BV_iff]
  intro a ha
  have h1 := ha p (by simp)
  have h2 := ha (neg p) (by simp)
  simp_all

/-- … but fails once `v_⊤` is admitted. -/
theorem not_MCons_vtop_noncontradiction : ¬ MCons (BV ∪ {vtop}) {p, neg p} ∅ := by
  intro h
  obtain ⟨χ, hχ, -⟩ := h vtop (Or.inr rfl) (fun _ _ => rfl)
  exact hχ

/-- Excluded middle `∅ ⊨ᵐ p, ¬p` holds for `BV`. -/
theorem MCons_BV_excludedMiddle : MCons BV ∅ {p, neg p} := by
  rw [MCons_BV_iff]
  intro a _
  cases h : a 0
  · exact ⟨neg p, by simp, by simp [h]⟩
  · exact ⟨p, by simp, by simp [h]⟩

/-- … but fails once `v_Taut` is admitted. -/
theorem not_MCons_vTaut_excludedMiddle : ¬ MCons (BV ∪ {vTaut}) ∅ {p, neg p} := by
  intro h
  obtain ⟨χ, hχ, hv⟩ := h vTaut (Or.inr rfl) (fun _ h => h.elim)
  rcases hχ with rfl | rfl
  · rw [vTaut_p] at hv; exact absurd hv (by decide)
  · rw [vTaut_negp] at hv; exact absurd hv (by decide)

/-- Excluded middle does *not* separate `BV` from `BV ∪ {v_⊤}` (`v_⊤` satisfies every sequent
with non-empty succedent); non-contradiction does. -/
theorem MCons_vtop_excludedMiddle : MCons (BV ∪ {vtop}) ∅ {p, neg p} := by
  rintro v (hv | hv) hX
  · exact MCons_BV_excludedMiddle v hv hX
  · rw [Set.mem_singleton_iff] at hv; subst hv
    exact ⟨p, by simp, rfl⟩

/-- **Theorem 4.2 (Carnap's problem).**  `BV` and `BV ∪ {v_⊤}` have the same single-conclusion
relation but different multiple-conclusion relations. -/
theorem carnap_vtop :
    SCons (BV ∪ {vtop}) = SCons BV ∧ MCons BV {p, neg p} ∅ ∧ ¬ MCons (BV ∪ {vtop}) {p, neg p} ∅ :=
  ⟨carnap_single_vtop, MCons_BV_noncontradiction, not_MCons_vtop_noncontradiction⟩

/-- **Theorem 4.2 (Carnap's problem).**  `BV` and `BV ∪ {v_Taut}` have the same single-conclusion
relation but different multiple-conclusion relations (`∅ ⊨ᵐ p, ¬p`). -/
theorem carnap_vTaut :
    SCons (BV ∪ {vTaut}) = SCons BV ∧ MCons BV ∅ {p, neg p} ∧ ¬ MCons (BV ∪ {vTaut}) ∅ {p, neg p} :=
  ⟨carnap_single_vTaut, MCons_BV_excludedMiddle, not_MCons_vTaut_excludedMiddle⟩


/-! ## Topology on valuations (Cantor space `2^Fm`) -/

/-- Closure in the product (Cantor) topology on `Fm → Bool`: `w ∈ closure V` iff every finite
set of formulas sees some `v ∈ V` agreeing with `w` there. -/
theorem mem_closure_iff_agree {V : Set GVal} {w : GVal} :
    w ∈ closure V ↔ ∀ F : Finset Formula, ∃ v ∈ V, ∀ φ ∈ F, v φ = w φ := by
  rw [mem_closure_iff_nhds]
  constructor
  · intro h F
    have hU : {v : GVal | ∀ φ ∈ F, v φ = w φ} ∈ nhds w := by
      rw [nhds_pi, Filter.mem_pi']
      refine ⟨F, fun φ => {w φ}, fun φ => ?_, ?_⟩
      · rw [nhds_discrete]; exact Filter.mem_pure.2 rfl
      · intro v hv φ hφ; exact hv φ hφ
    obtain ⟨v, hvU, hvV⟩ := h _ hU
    exact ⟨v, hvV, hvU⟩
  · intro h t ht
    rw [nhds_pi, Filter.mem_pi'] at ht
    obtain ⟨I, u, hu, hIu⟩ := ht
    obtain ⟨v, hvV, hv⟩ := h I
    refine ⟨v, hIu fun φ hφ => ?_, hvV⟩
    rw [hv φ hφ]
    have := hu φ
    rw [nhds_discrete] at this
    exact this

/-- A property of valuations that depends only on the values at a finite set of formulas
defines a closed set. -/
theorem isClosed_of_finite_support (F : Finset Formula) (P : GVal → Prop)
    (hP : ∀ v w, (∀ φ ∈ F, v φ = w φ) → P v → P w) : IsClosed {v | P v} := by
  apply isClosed_of_closure_subset
  intro w hw
  obtain ⟨v, hv, hvw⟩ := mem_closure_iff_agree.1 hw F
  exact hP v w hvw hv

/-! ## Finite sequents, `Val`, and Lemma 4.1(a) -/

/-- A finite multiple-conclusion sequent `Γ ▷ Δ` (equivalently, the position `[Γ : Δ]`). -/
structure MSeq where
  ante : Finset Formula
  succ : Finset Formula
  deriving DecidableEq

/-- `v` satisfies `Γ ▷ Δ`: if `v[Γ] = 1` then `v(χ) = 1` for some `χ ∈ Δ`. -/
def MSeq.Sat (v : GVal) (s : MSeq) : Prop :=
  (∀ ψ ∈ s.ante, v ψ = true) → ∃ χ ∈ s.succ, v χ = true

/-- The formulas a sequent mentions. -/
def MSeq.forms (s : MSeq) : Finset Formula := s.ante ∪ s.succ

theorem MSeq.sat_congr {s : MSeq} {v w : GVal} (h : ∀ φ ∈ s.forms, v φ = w φ) :
    s.Sat v ↔ s.Sat w := by
  have ha : ∀ φ ∈ s.ante, v φ = w φ := fun φ hφ => h φ (Finset.mem_union_left _ hφ)
  have hs : ∀ φ ∈ s.succ, v φ = w φ := fun φ hφ => h φ (Finset.mem_union_right _ hφ)
  unfold MSeq.Sat
  constructor
  · intro H hw
    obtain ⟨χ, hχ, hv⟩ := H fun ψ hψ => (ha ψ hψ).trans (hw ψ hψ)
    exact ⟨χ, hχ, (hs χ hχ).symm.trans hv⟩
  · intro H hv
    obtain ⟨χ, hχ, hw⟩ := H fun ψ hψ => (ha ψ hψ).symm.trans (hv ψ hψ)
    exact ⟨χ, hχ, (hs χ hχ).trans hw⟩

/-- `⊨ᵐ_V` as a set of finite sequents. -/
def mrel (V : Set GVal) : Set MSeq := {s | MCons V ↑s.ante ↑s.succ}

theorem mem_mrel {V : Set GVal} {s : MSeq} : s ∈ mrel V ↔ ∀ v ∈ V, s.Sat v := Iff.rfl

theorem mrel_anti {V W : Set GVal} (h : V ⊆ W) : mrel W ⊆ mrel V :=
  fun _ hs v hv => hs v (h hv)

/-- `Val(S)`: the valuations satisfying every sequent of `S`. -/
def Val (S : Set MSeq) : Set GVal := {v | ∀ s ∈ S, s.Sat v}

theorem isClosed_sat (s : MSeq) : IsClosed {v : GVal | s.Sat v} :=
  isClosed_of_finite_support s.forms _ fun _ _ h hv => (MSeq.sat_congr h).1 hv

/-- `Val(S)` is always closed. -/
theorem isClosed_Val (S : Set MSeq) : IsClosed (Val S) := by
  have : Val S = ⋂ s ∈ S, {v : GVal | s.Sat v} := by ext v; simp [Val]
  rw [this]
  exact isClosed_biInter fun s _ => isClosed_sat s

/-- The position `[Γ : Δ]` is *in bounds* for `V`: some admissible valuation realizes it. -/
def InBounds (V : Set GVal) (s : MSeq) : Prop :=
  ∃ v ∈ V, (∀ ψ ∈ s.ante, v ψ = true) ∧ ∀ χ ∈ s.succ, v χ = false

theorem inBounds_iff_not_mem_mrel {V : Set GVal} {s : MSeq} : InBounds V s ↔ s ∉ mrel V := by
  simp only [InBounds, mem_mrel, MSeq.Sat, not_forall, not_exists, not_and, exists_prop]
  constructor
  · rintro ⟨v, hv, h1, h2⟩
    exact ⟨v, hv, h1, fun χ hχ h => by simp [h2 χ hχ] at h⟩
  · rintro ⟨v, hv, h1, h2⟩
    exact ⟨v, hv, h1, fun χ hχ => by simpa using h2 χ hχ⟩

/-- The coherence datum "`[ : ]` is in bounds" says exactly that `V ≠ ∅`. -/
theorem inBounds_empty_iff {V : Set GVal} : InBounds V ⟨∅, ∅⟩ ↔ V.Nonempty := by
  simp [InBounds, Set.Nonempty]

/-- **Lemma 4.1(a).**  `Val(⊨ᵐ_V) = closure V` (finite sequents). -/
theorem Val_mrel (V : Set GVal) : Val (mrel V) = closure V := by
  ext w
  constructor
  · intro hw
    rw [mem_closure_iff_agree]
    intro F
    by_contra hne
    push Not at hne
    classical
    let s : MSeq := ⟨F.filter (fun φ => w φ = true), F.filter (fun φ => w φ = false)⟩
    have hs : s ∈ mrel V := by
      intro v hv hante
      obtain ⟨φ, hφF, hφ⟩ := hne v hv
      cases hwφ : w φ
      · refine ⟨φ, Finset.mem_filter.2 ⟨hφF, hwφ⟩, ?_⟩
        rw [hwφ] at hφ
        simpa using hφ
      · exact absurd ((hante φ (Finset.mem_filter.2 ⟨hφF, hwφ⟩)).trans hwφ.symm) hφ
    obtain ⟨χ, hχ, hwχ⟩ := hw s hs fun ψ hψ => (Finset.mem_filter.1 hψ).2
    rw [(Finset.mem_filter.1 hχ).2] at hwχ
    exact Bool.false_ne_true hwχ
  · intro hw s hs hante
    obtain ⟨v, hvV, hv⟩ := mem_closure_iff_agree.1 hw s.forms
    exact ((MSeq.sat_congr hv).1 (hs v hvV)) hante

/-- `⊨ᵐ_V` depends only on the closure of `V`. -/
theorem mrel_closure (V : Set GVal) : mrel (closure V) = mrel V := by
  apply Set.Subset.antisymm (mrel_anti subset_closure)
  intro s hs v hv
  rw [← Val_mrel] at hv
  exact hv s hs

/-- **Lemma 4.1(a), determinacy form.**  Two meanings have the same multiple-conclusion
relation iff they have the same closure; closed meanings are determined by `⊨ᵐ`. -/
theorem mrel_eq_iff_closure_eq {V W : Set GVal} : mrel V = mrel W ↔ closure V = closure W := by
  constructor
  · intro h; rw [← Val_mrel, ← Val_mrel, h]
  · intro h; rw [← mrel_closure V, h, mrel_closure]

theorem eq_of_mrel_eq {V W : Set GVal} (hV : IsClosed V) (hW : IsClosed W)
    (h : mrel V = mrel W) : V = W := by
  rw [← hV.closure_eq, ← hW.closure_eq]; exact mrel_eq_iff_closure_eq.1 h

/-! ## Lemma 4.1(b): finite single-conclusion sequents -/

/-- A finite single-conclusion sequent `Γ ▷ φ`. -/
structure SSeq where
  prem : Finset Formula
  concl : Formula
  deriving DecidableEq

/-- `v` satisfies `Γ ▷ φ`. -/
def SSeq.Sat (v : GVal) (s : SSeq) : Prop := (∀ ψ ∈ s.prem, v ψ = true) → v s.concl = true

/-- `⊨¹_V` restricted to finite premise sets. -/
def srel (V : Set GVal) : Set SSeq := {s | SCons V ↑s.prem s.concl}

/-- `Val` for single-conclusion sequents. -/
def SValS (S : Set SSeq) : Set GVal := {v | ∀ s ∈ S, s.Sat v}

theorem mem_srel_iff_mrel {V : Set GVal} {s : SSeq} :
    s ∈ srel V ↔ (⟨s.prem, {s.concl}⟩ : MSeq) ∈ mrel V := by
  simp [srel, mrel, SCons, MCons]

theorem srel_closure (V : Set GVal) : srel (closure V) = srel V := by
  ext s; rw [mem_srel_iff_mrel, mem_srel_iff_mrel, mrel_closure]

/-- The semantic consequence operator `C_V(X) = ⋂{v ∈ V : X ⊆ v}`. -/
def CV (V : Set GVal) : ConsOp Formula := ConsOp.ofSat (fun (v : V) (φ : Formula) => v.1 φ = true)

theorem mem_CV {V : Set GVal} {X : Set Formula} {φ : Formula} : φ ∈ CV V X ↔ SCons V X φ := by
  constructor
  · intro h v hv hX
    exact h ⟨v, hv⟩ hX
  · intro h v hX
    exact h v.1 v.2 hX

/-- **Lemma 4.1(b), `Fix(C_V) = V^∩`.**  A set `T` is `C_V`-closed iff its characteristic
function lies in `V^∩` (for every `V`). -/
theorem isClosed_CV_iff {V : Set GVal} {T : Set Formula} :
    (CV V).IsClosed T ↔ charFn T ∈ intClosure V := by
  rw [← SVal_eq_intClosure]
  constructor
  · intro hT X φ hXφ hX
    rw [charFn_eq_true]
    exact hT (ConsOp.mono _ (fun ψ hψ => charFn_eq_true.1 (hX ψ hψ)) (mem_CV.2 hXφ))
  · intro hT φ hφ
    exact charFn_eq_true.1 (hT T φ (mem_CV.1 hφ) fun ψ hψ => charFn_eq_true.2 hψ)

/-- **Lemma 4.1(b), finitarity.**  For a closed `V`, `C_V` is finitary (compactness of
Cantor space). -/
theorem CV_finitary {V : Set GVal} (hV : IsClosed V) : (CV V).Finitary := by
  intro X φ hφ
  rw [mem_CV] at hφ
  let K : Set GVal := V ∩ {v | v φ = false}
  have hK : IsClosed K := by
    refine hV.inter ?_
    have := (isClosed_discrete ({false} : Set Bool)).preimage (continuous_apply (A := fun _ : Formula => Bool) φ)
    exact this
  let t : X → Set GVal := fun x => {v | v x.1 = true}
  have ht : ∀ x, IsClosed (t x) := fun x =>
    (isClosed_discrete ({true} : Set Bool)).preimage (continuous_apply (A := fun _ : Formula => Bool) x.1)
  have hemp : K ∩ ⋂ x, t x = ∅ := by
    ext v
    simp only [Set.mem_inter_iff, Set.mem_iInter, Set.mem_setOf_eq, Set.mem_empty_iff_false,
      iff_false, not_and, K, t]
    rintro ⟨hvV, hvφ⟩ hX
    have := hφ v hvV fun ψ hψ => hX ⟨ψ, hψ⟩
    rw [hvφ] at this
    exact Bool.false_ne_true this
  obtain ⟨u, hu⟩ := hK.isCompact.elim_finite_subfamily_closed t ht hemp
  classical
  refine ⟨u.image Subtype.val, ?_, ?_⟩
  · intro ψ hψ
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe] at hψ
    obtain ⟨x, -, rfl⟩ := hψ
    exact x.2
  · rw [mem_CV]
    intro v hvV hX
    by_contra hvφ
    have hv : v ∈ K ∩ ⋂ x ∈ u, t x := by
      refine ⟨⟨hvV, by simpa using hvφ⟩, ?_⟩
      simp only [Set.mem_iInter]
      intro x hx
      exact hX x.1 (Finset.mem_image_of_mem _ hx)
    rw [hu] at hv
    exact hv

/-- For closed `V`, finite single-conclusion data already determine `⊨¹_V` on arbitrary
premise sets. -/
theorem SValS_srel_of_isClosed {V : Set GVal} (hV : IsClosed V) :
    SValS (srel V) = intClosure V := by
  rw [← SVal_eq_intClosure]
  ext w
  constructor
  · intro hw X φ hXφ hX
    obtain ⟨X₀, hX₀X, hX₀⟩ := CV_finitary hV X φ (mem_CV.2 hXφ)
    exact hw ⟨X₀, φ⟩ (mem_CV.1 hX₀) fun ψ hψ => hX ψ (hX₀X hψ)
  · intro hw s hs hprem
    exact hw (↑s.prem) s.concl hs hprem

/-- **Lemma 4.1(b).**  If `V` is closed, `Val(⊨¹_V) = V^∩` (finite single-conclusion
sequents). -/
theorem lemma_4_1_b {V : Set GVal} (hV : IsClosed V) :
    (CV V).Finitary ∧ SValS (srel V) = intClosure V :=
  ⟨CV_finitary hV, SValS_srel_of_isClosed hV⟩

/-- For arbitrary `V`, `Val(⊨¹_V) = (closure V)^∩` (the §4.5 "up to `(V̄)^∩`" remark). -/
theorem SValS_srel (V : Set GVal) : SValS (srel V) = intClosure (closure V) := by
  rw [← srel_closure, SValS_srel_of_isClosed isClosed_closure]


/-! ## Theorem 4.4(a): the truth-table schemata `TT` -/

/-- The truth-table schemata.  T2 §4.3 lists 11 (for `¬, ∧, ∨, →`); our language also has
the constants `⊥, ⊤`, which need the two extra schemata `⊥ ▷` and `▷ ⊤`. -/
inductive TTKind
  | negL | negR | andE1 | andE2 | andI | orI1 | orI2 | orE | impR1 | impR2 | impE | botL | topR
  deriving DecidableEq

/-- The schema instances `TT_k(φ, ψ)`. -/
def TT : TTKind → Formula → Formula → MSeq
  | .negL, φ, _ => ⟨{φ, neg φ}, ∅⟩
  | .negR, φ, _ => ⟨∅, {φ, neg φ}⟩
  | .andE1, φ, ψ => ⟨{Formula.and φ ψ}, {φ}⟩
  | .andE2, φ, ψ => ⟨{Formula.and φ ψ}, {ψ}⟩
  | .andI, φ, ψ => ⟨{φ, ψ}, {Formula.and φ ψ}⟩
  | .orI1, φ, ψ => ⟨{φ}, {Formula.or φ ψ}⟩
  | .orI2, φ, ψ => ⟨{ψ}, {Formula.or φ ψ}⟩
  | .orE, φ, ψ => ⟨{Formula.or φ ψ}, {φ, ψ}⟩
  | .impR1, φ, ψ => ⟨∅, {φ, imp φ ψ}⟩
  | .impR2, φ, ψ => ⟨{ψ}, {imp φ ψ}⟩
  | .impE, φ, ψ => ⟨{φ, imp φ ψ}, {ψ}⟩
  | .botL, _, _ => ⟨{bot}, ∅⟩
  | .topR, _, _ => ⟨∅, {top}⟩

/-- All instances of the truth-table schemata. -/
def TTall : Set MSeq := {s | ∃ k φ ψ, s = TT k φ ψ}

/-- The finitely many atomic instances `TT(p, q)` with `p = p₀`, `q = p₁`. -/
def TTpq : Set MSeq := Set.range fun k => TT k (var 0) (var 1)

theorem TTpq_subset_TTall : TTpq ⊆ TTall := by
  rintro _ ⟨k, rfl⟩; exact ⟨k, _, _, rfl⟩

theorem TTpq_finite : TTpq.Finite := by
  have : TTpq ⊆ ((({TTKind.negL, .negR, .andE1, .andE2, .andI, .orI1, .orI2, .orE, .impR1,
      .impR2, .impE, .botL, .topR} : Finset TTKind).image fun k => TT k (var 0) (var 1) :
        Finset MSeq) : Set MSeq) := by
    rintro _ ⟨k, rfl⟩
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe]
    exact ⟨k, by cases k <;> simp, rfl⟩
  exact Set.Finite.subset (Finset.finite_toSet _) this

/-- Boolean valuations satisfy every truth-table instance. -/
theorem BV_sat_TT (a : Valuation) (k : TTKind) (φ ψ : Formula) : (TT k φ ψ).Sat (ofAtoms a) := by
  cases k <;> simp only [TT, MSeq.Sat, Finset.mem_insert, Finset.mem_singleton,
    forall_eq_or_imp, forall_eq, exists_eq_or_imp, exists_eq_left, Finset.notMem_empty,
    false_and, exists_false, imp_false, ofAtoms_apply, eval_neg, eval_and, eval_or, eval_imp,
    eval_bot, eval_top, IsEmpty.forall_iff, implies_true, forall_const] <;>
    cases φ.eval a <;> cases ψ.eval a <;> simp

/-- A valuation satisfying all truth-table instances is Boolean. -/
theorem mem_BV_of_sat_TT {v : GVal} (hv : ∀ k φ ψ, (TT k φ ψ).Sat v) : v ∈ BV := by
  rw [mem_BV_iff]
  intro φ
  induction φ with
  | var n => rfl
  | bot =>
    have h := hv .botL bot bot
    simp only [TT, MSeq.Sat, Finset.mem_singleton, forall_eq, Finset.notMem_empty, false_and,
      exists_false, imp_false] at h
    simpa using h
  | top =>
    have h := hv .topR top top
    simp only [TT, MSeq.Sat, Finset.notMem_empty, IsEmpty.forall_iff, implies_true,
      Finset.mem_singleton, exists_eq_left, forall_const] at h
    simpa using h
  | neg a ih =>
    have h1 := hv .negL a a
    have h2 := hv .negR a a
    simp only [TT, MSeq.Sat, Finset.mem_insert, Finset.mem_singleton, forall_eq_or_imp,
      forall_eq, Finset.notMem_empty, false_and, exists_false, imp_false, IsEmpty.forall_iff,
      implies_true, exists_eq_or_imp, exists_eq_left, forall_const] at h1 h2
    rw [eval_neg, ← ih]
    cases h : v a <;> cases h' : v (neg a) <;> simp_all
  | and a b iha ihb =>
    have h1 := hv .andE1 a b
    have h2 := hv .andE2 a b
    have h3 := hv .andI a b
    simp only [TT, MSeq.Sat, Finset.mem_insert, Finset.mem_singleton, forall_eq_or_imp,
      forall_eq, exists_eq_left] at h1 h2 h3
    rw [eval_and, ← iha, ← ihb]
    cases h : v a <;> cases h' : v b <;> cases h'' : v (Formula.and a b) <;> simp_all
  | or a b iha ihb =>
    have h1 := hv .orI1 a b
    have h2 := hv .orI2 a b
    have h3 := hv .orE a b
    simp only [TT, MSeq.Sat, Finset.mem_insert, Finset.mem_singleton,
      forall_eq, exists_eq_left, exists_eq_or_imp] at h1 h2 h3
    rw [eval_or, ← iha, ← ihb]
    cases h : v a <;> cases h' : v b <;> cases h'' : v (Formula.or a b) <;> simp_all
  | imp a b iha ihb =>
    have h1 := hv .impR1 a b
    have h2 := hv .impR2 a b
    have h3 := hv .impE a b
    simp only [TT, MSeq.Sat, Finset.mem_insert, Finset.mem_singleton, forall_eq_or_imp,
      forall_eq, exists_eq_left, exists_eq_or_imp, Finset.notMem_empty, IsEmpty.forall_iff,
      implies_true, forall_const] at h1 h2 h3
    rw [eval_imp, ← iha, ← ihb]
    cases h : v a <;> cases h' : v b <;> cases h'' : v (imp a b) <;> simp_all

/-- **Theorem 4.4(a).**  `Val(TT) = BV`. -/
theorem Val_TTall : Val TTall = BV := by
  ext v
  constructor
  · intro hv
    exact mem_BV_of_sat_TT fun k φ ψ => hv _ ⟨k, φ, ψ, rfl⟩
  · rintro ⟨a, rfl⟩ _ ⟨k, φ, ψ, rfl⟩
    exact BV_sat_TT a k φ ψ

/-- **Theorem 4.4(a).**  `BV` is closed. -/
theorem isClosed_BV : IsClosed BV := Val_TTall ▸ isClosed_Val TTall

theorem closure_BV : closure BV = BV := isClosed_BV.closure_eq

/-- **Theorem 4.4(a).**  `⊨ᵐ_BV` determines `BV`: `Val(⊨ᵐ_BV) = BV`, and a meaning `V` has
the same multiple-conclusion relation as `BV` iff its closure is `BV`. -/
theorem Val_mrel_BV : Val (mrel BV) = BV := by rw [Val_mrel, closure_BV]

theorem mrel_eq_mrel_BV_iff {V : Set GVal} : mrel V = mrel BV ↔ closure V = BV := by
  rw [mrel_eq_iff_closure_eq, closure_BV]

/-- **Thm 4.2, multiple-conclusion half (general form).**  For `BV ⊆ W`, the
multiple-conclusion relations agree only if `W = BV`: every `W` strictly between `BV` and
`BV^∩` has the same `⊨¹` (Thm 4.2) but a strictly smaller `⊨ᵐ`. -/
theorem mrel_ssubset_of_BV_ssubset {W : Set GVal} (hW : BV ⊂ W) : mrel W ⊂ mrel BV := by
  refine (Set.ssubset_iff_subset_ne).2 ⟨mrel_anti hW.subset, fun h => ?_⟩
  have hWBV : W ⊆ BV := (mrel_eq_mrel_BV_iff.1 h) ▸ subset_closure
  exact hW.not_subset hWBV

/-- **Theorem 4.2 (Carnap's problem in learning form).**  For every `W` with
`BV ⊊ W ⊆ BV^∩`: same single-conclusion relation, different multiple-conclusion relation. -/
theorem carnap_problem {W : Set GVal} (hBW : BV ⊂ W) (hW : W ⊆ intClosure BV) :
    SCons W = SCons BV ∧ srel W = srel BV ∧ mrel W ≠ mrel BV := by
  have hS := carnap_single hBW.subset hW
  refine ⟨hS, ?_, (mrel_ssubset_of_BV_ssubset hBW).ne⟩
  ext s; simp only [srel, Set.mem_setOf_eq, hS]


/-! ## Structural meanings -/

/-- A meaning `V` is *structural* if `v ∈ V` implies `v ∘ σ ∈ V` for every substitution `σ`. -/
def StructuralMeaning (V : Set GVal) : Prop :=
  ∀ v ∈ V, ∀ σ : Subst, (fun φ => v (φ.subst σ)) ∈ V

theorem ofAtoms_comp_subst (a : Valuation) (σ : Subst) :
    (fun φ : Formula => ofAtoms a (φ.subst σ)) = ofAtoms (fun n => (σ n).eval a) := by
  funext φ; simp

theorem BV_structural : StructuralMeaning BV := by
  rintro _ ⟨a, rfl⟩ σ
  rw [ofAtoms_comp_subst]; exact ofAtoms_mem_BV _

/-- **Thm 4.2, last bullet.**  `BV^∩` is closed … -/
theorem isClosed_intClosure_BV : IsClosed (intClosure BV) := by
  rw [← SValS_srel_of_isClosed isClosed_BV]
  have : SValS (srel BV) = ⋂ s ∈ srel BV, {v : GVal | s.Sat v} := by ext v; simp [SValS]
  rw [this]
  refine isClosed_biInter fun s _ => isClosed_of_finite_support (insert s.concl s.prem) _ ?_
  intro v w h hv hw
  have hc := h s.concl (Finset.mem_insert_self _ _)
  rw [← hc]
  exact hv fun ψ hψ => (h ψ (Finset.mem_insert_of_mem hψ)).trans (hw ψ hψ)

/-- … and substitution-invariant (`v_T ∘ σ = v_{σ⁻¹T}`), so Carnap's problem persists
under structurality. -/
theorem intClosure_BV_structural : StructuralMeaning (intClosure BV) := by
  intro w hw σ
  rw [mem_intClosure_BV_iff] at hw ⊢
  intro φ hφ
  have h1 : SemCons (Formula.subst σ '' trueSet (fun ψ => w (ψ.subst σ))) (φ.subst σ) :=
    SemCons.subst hφ σ
  have h2 : Formula.subst σ '' trueSet (fun ψ => w (ψ.subst σ)) ⊆ trueSet w := by
    rintro _ ⟨ψ, hψ, rfl⟩; exact hψ
  exact hw (SemCons.mono h2 h1)

/-! ## Theorem 4.3: the denial-rank trichotomy -/

/-- The denial rank `d(v)`: the fewest denials (succedent size) in a `BV`-valid finite sequent
that `v` violates (`⊤ = ∞` if there is none). -/
noncomputable def denialRank (v : GVal) : ℕ∞ :=
  ⨅ (s : MSeq) (_ : s ∈ mrel BV) (_ : ¬ s.Sat v), (s.succ.card : ℕ∞)

/-- `v` violates a `BV`-valid sequent with at most `k` denials. -/
def ExclBy (k : ℕ) (v : GVal) : Prop := ∃ s ∈ mrel BV, ¬ s.Sat v ∧ s.succ.card ≤ k

theorem denialRank_le_iff {v : GVal} {k : ℕ} : denialRank v ≤ k ↔ ExclBy k v := by
  constructor
  · intro h
    by_contra hne
    simp only [ExclBy, not_exists, not_and, not_le] at hne
    have : ((k + 1 : ℕ) : ℕ∞) ≤ denialRank v := by
      refine le_iInf fun s => le_iInf fun hs => le_iInf fun hv => ?_
      exact_mod_cast hne s hs hv
    have := this.trans h
    norm_cast at this
    omega
  · rintro ⟨s, hs, hv, hk⟩
    exact (iInf₂_le s hs).trans ((iInf_le _ hv).trans (by exact_mod_cast hk))

theorem satisfiable_finset_of_subset {X : Set Formula} {F : Finset Formula} (hF : ↑F ⊆ X)
    (h : Satisfiable X) : Satisfiable ↑F := by
  obtain ⟨a, ha⟩ := h; exact ⟨a, satisfies_mono hF ha⟩

/-- Rank 0: violated 0-denial (non-contradiction) data ⟺ inconsistent true-set. -/
theorem exclBy_zero_iff {v : GVal} : ExclBy 0 v ↔ ¬ Satisfiable (trueSet v) := by
  constructor
  · rintro ⟨s, hs, hv, hk⟩ ⟨a, ha⟩
    have hsucc : s.succ = ∅ := Finset.card_eq_zero.1 (Nat.le_zero.1 hk)
    unfold MSeq.Sat at hv
    push Not at hv
    obtain ⟨hante, -⟩ := hv
    obtain ⟨χ, hχ, -⟩ := hs (ofAtoms a) (ofAtoms_mem_BV a) fun ψ hψ => ha ψ (hante ψ hψ)
    rw [hsucc] at hχ; simp at hχ
  · intro h
    have : ∃ F : Finset Formula, ↑F ⊆ trueSet v ∧ ¬ Satisfiable ↑F := by
      by_contra hne
      push Not at hne
      exact h (compactness hne)
    obtain ⟨F, hFv, hF⟩ := this
    refine ⟨⟨F, ∅⟩, ?_, ?_, by simp⟩
    · rintro _ ⟨a, rfl⟩ ha
      exact absurd ⟨a, ha⟩ hF
    · intro hs
      obtain ⟨χ, hχ, -⟩ := hs fun ψ hψ => hFv hψ
      simp at hχ

/-- Rank ≤ 1 ⟺ inconsistent or not deductively closed. -/
theorem exclBy_one_iff {v : GVal} :
    ExclBy 1 v ↔ ¬ Satisfiable (trueSet v) ∨ ¬ Cn2.IsClosed (trueSet v) := by
  constructor
  · rintro ⟨s, hs, hv, hk⟩
    rcases Nat.le_one_iff_eq_zero_or_eq_one.1 hk with h0 | h1
    · exact Or.inl (exclBy_zero_iff.1 ⟨s, hs, hv, h0.le⟩)
    · right
      obtain ⟨φ, hφ⟩ := Finset.card_eq_one.1 h1
      unfold MSeq.Sat at hv
      push Not at hv
      obtain ⟨hante, hsucc⟩ := hv
      intro hcl
      have hφv : v φ = true := by
        apply hcl
        have : SemCons ↑s.ante φ := by
          intro a ha
          obtain ⟨χ, hχ, hχa⟩ := hs (ofAtoms a) (ofAtoms_mem_BV a) ha
          rw [hφ, Finset.mem_coe, Finset.mem_singleton] at hχ
          subst hχ; exact hχa
        exact SemCons.mono (fun ψ hψ => hante ψ hψ) this
      exact hsucc φ (by rw [hφ]; exact Finset.mem_singleton_self φ) hφv
  · rintro (h | h)
    · obtain ⟨s, hs, hv, hk⟩ := exclBy_zero_iff.2 h
      exact ⟨s, hs, hv, hk.trans zero_le_one⟩
    · simp only [ConsOp.IsClosed, Set.not_subset] at h
      obtain ⟨φ, hφ, hφv⟩ := h
      obtain ⟨F, hFv, hF⟩ := SemCons.exists_finset (mem_Cn2.1 hφ)
      refine ⟨⟨F, {φ}⟩, ?_, ?_, by simp⟩
      · rintro _ ⟨a, rfl⟩ ha
        exact ⟨φ, Finset.mem_singleton_self φ, hF a ha⟩
      · intro hs
        obtain ⟨χ, hχ, hχv⟩ := hs fun ψ hψ => hFv hψ
        have hχ' : χ = φ := by simpa using hχ
        subst hχ'
        exact hφv hχv

/-- A non-Boolean consistent theory has a "gap" `φ` with `φ, ¬φ` both false. -/
theorem exists_gap {v : GVal} (hv : v ∉ BV) (hsat : Satisfiable (trueSet v))
    (hcl : Cn2.IsClosed (trueSet v)) : ∃ φ, v φ = false ∧ v (neg φ) = false := by
  by_contra hne
  push Not at hne
  apply hv
  rw [mem_BV_iff_maximal]
  refine ⟨hcl, hsat, fun φ => ?_⟩
  by_contra h
  push Not at h
  exact hne φ (by simpa using h.1) (by simpa using h.2)

/-- Rank ≤ 2 ⟺ non-Boolean (rank-2 "exhaustiveness" data `▷ φ, ¬φ` suffice). -/
theorem exclBy_two_iff {v : GVal} : ExclBy 2 v ↔ v ∉ BV := by
  constructor
  · rintro ⟨s, hs, hv, -⟩ hvBV
    exact hv (hs v hvBV)
  · intro hv
    by_cases h1 : ¬ Satisfiable (trueSet v) ∨ ¬ Cn2.IsClosed (trueSet v)
    · obtain ⟨s, hs, hsv, hk⟩ := exclBy_one_iff.2 h1
      exact ⟨s, hs, hsv, hk.trans (by norm_num)⟩
    · push Not at h1
      obtain ⟨φ, hφ, hnφ⟩ := exists_gap hv h1.1 h1.2
      refine ⟨⟨∅, {φ, neg φ}⟩, ?_, ?_, Finset.card_le_two⟩
      · rintro _ ⟨a, rfl⟩ -
        cases h : φ.eval a
        · exact ⟨neg φ, by simp, by simp [h]⟩
        · exact ⟨φ, by simp, by simp [h]⟩
      · intro hs
        obtain ⟨χ, hχ, hχv⟩ := hs (by simp)
        have hχ' : χ = φ ∨ χ = neg φ := by simpa using hχ
        rcases hχ' with rfl | rfl
        · rw [hφ] at hχv; exact Bool.false_ne_true hχv
        · rw [hnφ] at hχv; exact Bool.false_ne_true hχv

/-- Boolean valuations violate no `BV`-valid sequent. -/
theorem not_exclBy_of_mem_BV {v : GVal} (hv : v ∈ BV) (k : ℕ) : ¬ ExclBy k v := by
  rintro ⟨s, hs, hsv, -⟩; exact hsv (hs v hv)

theorem ENat.eq_succ_iff' {d : ℕ∞} {k : ℕ} : d = ((k + 1 : ℕ) : ℕ∞) ↔ d ≤ ((k + 1 : ℕ) : ℕ∞) ∧ ¬ d ≤ k := by
  induction d using ENat.recTopCoe with
  | top =>
    exact ⟨fun h => absurd h (ENat.top_ne_coe _),
      fun h => absurd (top_le_iff.1 h.1) (ENat.coe_ne_top _)⟩
  | coe n => norm_cast; omega

/-- **Theorem 4.3 (denial-rank trichotomy), rank 0.** -/
theorem denialRank_eq_zero_iff {v : GVal} : denialRank v = 0 ↔ ¬ Satisfiable (trueSet v) := by
  rw [← nonpos_iff_eq_zero, ← exclBy_zero_iff]
  exact_mod_cast denialRank_le_iff (k := 0)

/-- **Theorem 4.3, rank 1:** consistent but not deductively closed. -/
theorem denialRank_eq_one_iff {v : GVal} :
    denialRank v = 1 ↔ Satisfiable (trueSet v) ∧ ¬ Cn2.IsClosed (trueSet v) := by
  have := ENat.eq_succ_iff' (d := denialRank v) (k := 0)
  simp only [Nat.zero_add, Nat.cast_one, Nat.cast_zero] at this
  rw [this, nonpos_iff_eq_zero, denialRank_eq_zero_iff, ← Nat.cast_one, denialRank_le_iff,
    exclBy_one_iff]
  tauto

/-- **Theorem 4.3, rank 2:** a consistent, deductively closed, non-maximal theory. -/
theorem denialRank_eq_two_iff {v : GVal} :
    denialRank v = 2 ↔ Satisfiable (trueSet v) ∧ Cn2.IsClosed (trueSet v) ∧
      ∃ φ, v φ = false ∧ v (neg φ) = false := by
  have := ENat.eq_succ_iff' (d := denialRank v) (k := 1)
  rw [show ((1 + 1 : ℕ) : ℕ∞) = 2 by norm_num] at this
  rw [this, show (2 : ℕ∞) = ((2 : ℕ) : ℕ∞) by norm_num, denialRank_le_iff,
    show ((1 : ℕ) : ℕ∞) = ((1 : ℕ) : ℕ∞) from rfl, denialRank_le_iff, exclBy_two_iff,
    exclBy_one_iff]
  constructor
  · rintro ⟨hv, h1⟩
    push Not at h1
    exact ⟨h1.1, h1.2, exists_gap hv h1.1 h1.2⟩
  · rintro ⟨hsat, hcl, φ, hφ, hnφ⟩
    refine ⟨fun hv => ?_, by tauto⟩
    have := BV_neg hv φ
    rw [hφ, hnφ] at this
    exact absurd this (by decide)

/-- **Theorem 4.3, rank ∞:** exactly the Boolean valuations. -/
theorem denialRank_eq_top_iff {v : GVal} : denialRank v = ⊤ ↔ v ∈ BV := by
  constructor
  · intro h
    by_contra hv
    have := denialRank_le_iff.2 (exclBy_two_iff.2 hv)
    rw [h] at this
    exact absurd this (by simp)
  · intro hv
    by_contra h
    obtain ⟨k, hk⟩ := ENat.ne_top_iff_exists.1 h
    exact not_exclBy_of_mem_BV hv k (denialRank_le_iff.1 hk.symm.le)

/-- **Theorem 4.3 (trichotomy).**  Every non-Boolean valuation has denial rank ≤ 2. -/
theorem denialRank_le_two_of_not_mem_BV {v : GVal} (hv : v ∉ BV) : denialRank v ≤ 2 := by
  have := denialRank_le_iff.2 (exclBy_two_iff.2 hv)
  exact_mod_cast this

/-- `d(v_⊤) = 0` and `d(v_Taut) = 2` (Carnap's tautology valuation has rank 2). -/
theorem denialRank_vtop : denialRank vtop = 0 := by
  rw [denialRank_eq_zero_iff]
  rintro ⟨a, ha⟩
  have := ha bot rfl
  simp at this

theorem denialRank_vTaut : denialRank vTaut = 2 := by
  rw [denialRank_eq_two_iff, vTaut, trueSet_charFn]
  refine ⟨⟨fun _ => true, fun φ hφ => hφ _⟩, ?_, p, ?_, ?_⟩
  · rw [← Cn2_empty]; exact Cn2.isClosed_apply ∅
  · exact vTaut_p
  · exact vTaut_negp


/-! ## Theorem 4.4(b)–(c): structural meanings and the finite tell-tale -/

/-- The substitution sending `p₀ ↦ φ`, `p₁ ↦ ψ` (other atoms fixed). -/
def substPQ (φ ψ : Formula) : Subst := fun n => if n = 0 then φ else if n = 1 then ψ else var n

theorem sat_TT_comp_subst (v : GVal) (k : TTKind) (σ : Subst) :
    (TT k (var 0) (var 1)).Sat (fun χ => v (χ.subst σ)) ↔ (TT k (σ 0) (σ 1)).Sat v := by
  cases k <;> simp [TT, MSeq.Sat]

/-- In a structural meaning, the atomic instances `TT(p,q)` force all instances. -/
theorem subset_BV_of_structural {V : Set GVal} (hV : StructuralMeaning V)
    (hTT : ∀ s ∈ TTpq, s ∈ mrel V) : V ⊆ BV := by
  intro v hv
  rw [← Val_TTall]
  rintro _ ⟨k, φ, ψ, rfl⟩
  have h : (TT k (var 0) (var 1)).Sat (fun χ => v (χ.subst (substPQ φ ψ))) :=
    hTT _ ⟨k, rfl⟩ _ (hV v hv (substPQ φ ψ))
  rw [sat_TT_comp_subst] at h
  simpa [substPQ] using h

/-- A nonempty structural meaning inside `BV` is all of `BV`. -/
theorem BV_subset_of_structural {V : Set GVal} (hV : StructuralMeaning V) (hVBV : V ⊆ BV)
    (hne : V.Nonempty) : BV ⊆ V := by
  obtain ⟨v, hv⟩ := hne
  rintro _ ⟨a, rfl⟩
  obtain ⟨b, rfl⟩ := hVBV hv
  have := hV _ hv (Subst.ofVal a)
  rwa [ofAtoms_comp_subst, show (fun n => (Subst.ofVal a n).eval b) = a by
    funext n; simp] at this

/-- **Theorem 4.4(b).**  A structural meaning satisfying the atomic truth-table sequents
`TT(p,q)` and the single coherence datum "`[ : ]` is in bounds" is exactly `BV`. -/
theorem structural_eq_BV {V : Set GVal} (hV : StructuralMeaning V)
    (hTT : ∀ s ∈ TTpq, s ∈ mrel V) (hcoh : InBounds V ⟨∅, ∅⟩) : V = BV := by
  have h1 := subset_BV_of_structural hV hTT
  exact Set.Subset.antisymm h1 (BV_subset_of_structural hV h1 (inBounds_empty_iff.1 hcoh))

/-- **Theorem 4.4(c).**  Among *all* structural meanings, `BV` is singled out by finitely many
data: the finite set `TTpq` of positive bilateral data together with one coherence datum. -/
theorem finite_telltale_structural {V : Set GVal} (hV : StructuralMeaning V) :
    ((TTpq ⊆ mrel V) ∧ InBounds V ⟨∅, ∅⟩) ↔ V = BV := by
  constructor
  · rintro ⟨h1, h2⟩; exact structural_eq_BV hV h1 h2
  · rintro rfl
    refine ⟨fun s hs => ?_, inBounds_empty_iff.2 ⟨ofAtoms fun _ => false, ofAtoms_mem_BV _⟩⟩
    rintro _ ⟨a, rfl⟩
    obtain ⟨k, rfl⟩ := hs
    exact BV_sat_TT a k _ _

/-- **Theorem 4.4(c), the Gold over-generalization.**  Without the coherence datum, the empty
meaning (all positions out of bounds) is structural and survives every positive datum. -/
theorem empty_survives : StructuralMeaning ∅ ∧ mrel ∅ = Set.univ ∧ ¬ InBounds ∅ ⟨∅, ∅⟩ := by
  refine ⟨fun v hv => hv.elim, Set.eq_univ_of_forall fun s v hv => hv.elim, ?_⟩
  rw [inBounds_empty_iff]; exact Set.not_nonempty_empty


/-! ## Gold-style learning from text (noneffective)

Generic machinery: texts with pauses, BC/EX identification, the (BC) locking-sequence lemma
of Blum & Blum, and Angluin's tell-tale condition as a *necessary* condition for
BC-identification by arbitrary (not necessarily computable) learners. -/

section Gold

variable {α H : Type*}

/-- A text (with pauses `none`) for `L`: its content is exactly `L`. -/
def IsText (t : ℕ → Option α) (L : Set α) : Prop := ∀ a, a ∈ L ↔ ∃ n, t n = some a

/-- The initial segment of length `n` of a text. -/
def initSeg (t : ℕ → Option α) (n : ℕ) : List (Option α) := (List.range n).map t

/-- The content of a finite data sequence. -/
def content (σ : List (Option α)) : Set α := {a | some a ∈ σ}

/-- `M` BC-identifies `L` (conjectures interpreted by `den`): on every text for `L`, from
some point on every conjecture denotes `L`. -/
def BCIdentifies (M : List (Option α) → H) (den : H → Set α) (L : Set α) : Prop :=
  ∀ t, IsText t L → ∃ N, ∀ n ≥ N, den (M (initSeg t n)) = L

/-- `M` EX-identifies `L`: on every text for `L` it converges to one conjecture denoting `L`. -/
def EXIdentifies (M : List (Option α) → H) (den : H → Set α) (L : Set α) : Prop :=
  ∀ t, IsText t L → ∃ N, ∃ h, den h = L ∧ ∀ n ≥ N, M (initSeg t n) = h

theorem EXIdentifies.bc {M : List (Option α) → H} {den : H → Set α} {L : Set α}
    (h : EXIdentifies M den L) : BCIdentifies M den L := by
  intro t ht
  obtain ⟨N, h, hh, hN⟩ := h t ht
  exact ⟨N, fun n hn => by rw [hN n hn, hh]⟩

theorem exists_text [Countable α] (L : Set α) : ∃ t, IsText t L := by
  rcases L.eq_empty_or_nonempty with rfl | ⟨a, ha⟩
  · exact ⟨fun _ => none, fun a => by simp⟩
  · haveI : Nonempty L := ⟨⟨a, ha⟩⟩
    obtain ⟨f, hf⟩ := exists_surjective_nat L
    refine ⟨fun n => some (f n).1, fun b => ⟨fun hb => ?_, ?_⟩⟩
    · obtain ⟨n, hn⟩ := hf ⟨b, hb⟩
      exact ⟨n, by simp [hn]⟩
    · rintro ⟨n, hn⟩
      simp only [Option.some.injEq] at hn
      exact hn ▸ (f n).2

theorem content_append (σ τ : List (Option α)) : content (σ ++ τ) = content σ ∪ content τ := by
  ext a; simp [content]

theorem content_initSeg_subset {t : ℕ → Option α} {L : Set α} (ht : IsText t L) (n : ℕ) :
    content (initSeg t n) ⊆ L := by
  intro a ha
  simp only [content, initSeg, Set.mem_setOf_eq, List.mem_map, List.mem_range] at ha
  obtain ⟨i, -, hi⟩ := ha
  exact (ht a).2 ⟨i, hi⟩

/-- The chain `σ₀ = []`, `σₙ₊₁ = step (σₙ ++ [t₀ n])` used to build a fooling text. -/
def chain (t₀ : ℕ → Option α) (step : List (Option α) → List (Option α)) :
    ℕ → List (Option α)
  | 0 => []
  | n + 1 => step (chain t₀ step n ++ [t₀ n])

/-- The limit text of the chain. -/
def limText (t₀ : ℕ → Option α) (step : List (Option α) → List (Option α)) (k : ℕ) :
    Option α :=
  ((chain t₀ step (k + 1))[k]?).getD none

section chain

variable {t₀ : ℕ → Option α} {step : List (Option α) → List (Option α)}
  (hstep : ∀ ρ, ρ <+: step ρ)
include hstep

theorem chain_succ_prefix (n : ℕ) : chain t₀ step n ++ [t₀ n] <+: chain t₀ step (n + 1) :=
  hstep _

theorem chain_mono {n m : ℕ} (h : n ≤ m) : chain t₀ step n <+: chain t₀ step m := by
  induction h with
  | refl => exact List.prefix_refl _
  | step _ ih => exact ih.trans ((List.prefix_append _ _).trans (chain_succ_prefix hstep _))

theorem length_lt_length_chain_succ (n : ℕ) :
    (chain t₀ step n).length < (chain t₀ step (n + 1)).length := by
  have := (chain_succ_prefix hstep (t₀ := t₀) n).length_le
  simp at this; omega

theorem le_length_chain (n : ℕ) : n ≤ (chain t₀ step n).length := by
  induction n with
  | zero => simp
  | succ n ih => have := length_lt_length_chain_succ hstep (t₀ := t₀) n; omega

theorem limText_eq {k m : ℕ} (hk : k < (chain t₀ step m).length) :
    limText t₀ step k = (chain t₀ step m)[k] := by
  have hk' : k < (chain t₀ step (k + 1)).length :=
    lt_of_lt_of_le (Nat.lt_succ_self k) (le_length_chain hstep _)
  unfold limText
  rw [List.getElem?_eq_getElem hk', Option.getD_some]
  rcases le_total (k + 1) m with h | h
  · exact (chain_mono hstep h).getElem hk'
  · exact ((chain_mono hstep h).getElem hk).symm

theorem initSeg_limText (m : ℕ) :
    initSeg (limText t₀ step) (chain t₀ step m).length = chain t₀ step m := by
  apply List.ext_getElem
  · simp [initSeg]
  · intro i _ h2
    simp only [initSeg, List.getElem_map, List.getElem_range]
    exact limText_eq hstep h2

theorem limText_length_chain (n : ℕ) : limText t₀ step (chain t₀ step n).length = t₀ n := by
  rw [limText_eq hstep (length_lt_length_chain_succ hstep n)]
  have h := (chain_succ_prefix hstep (t₀ := t₀) n).getElem
    (i := (chain t₀ step n).length) (by simp)
  exact h.symm.trans (List.getElem_concat_length rfl _)

end chain

/-- **Locking-sequence lemma (BC version, Blum & Blum 1975; no effectivity needed).**
If `M` BC-identifies `L`, there is a finite sequence `σ` from `L` such that every extension of
`σ` by data from `L` yields a conjecture denoting `L`. -/
theorem exists_locking {M : List (Option α) → H} {den : H → Set α} {L : Set α}
    (hM : BCIdentifies M den L) {t₀ : ℕ → Option α} (ht₀ : IsText t₀ L) :
    ∃ σ : List (Option α), content σ ⊆ L ∧ ∀ τ, content τ ⊆ L → den (M (σ ++ τ)) = L := by
  classical
  by_contra hne
  push Not at hne
  let step : List (Option α) → List (Option α) := fun ρ =>
    if h : content ρ ⊆ L then ρ ++ (hne ρ h).choose else ρ
  have hstep : ∀ ρ, ρ <+: step ρ := by
    intro ρ
    simp only [step]
    split_ifs
    · exact List.prefix_append _ _
    · exact List.prefix_refl _
  have hcont1 : ∀ n, content (chain t₀ step n) ⊆ L →
      content (chain t₀ step n ++ [t₀ n]) ⊆ L := by
    intro n hn
    rw [content_append]
    refine Set.union_subset hn fun a ha => ?_
    simp only [content, Set.mem_setOf_eq, List.mem_singleton] at ha
    exact (ht₀ a).2 ⟨n, ha.symm⟩
  have hcont : ∀ n, content (chain t₀ step n) ⊆ L := by
    intro n
    induction n with
    | zero => intro a ha; simp [content, chain] at ha
    | succ n ih =>
      have h1 := hcont1 n ih
      show content (step _) ⊆ L
      simp only [step, dif_pos h1]
      rw [content_append]
      exact Set.union_subset h1 (hne _ h1).choose_spec.1
  have hwrong : ∀ n, den (M (chain t₀ step (n + 1))) ≠ L := by
    intro n
    have h1 := hcont1 n (hcont n)
    show den (M (step _)) ≠ L
    simp only [step, dif_pos h1]
    exact (hne _ h1).choose_spec.2
  have htext : IsText (limText t₀ step) L := by
    intro a
    constructor
    · intro ha
      obtain ⟨n, hn⟩ := (ht₀ a).1 ha
      exact ⟨(chain t₀ step n).length, by rw [limText_length_chain hstep, hn]⟩
    · rintro ⟨k, hk⟩
      have hk' : k < (chain t₀ step (k + 1)).length :=
        lt_of_lt_of_le (Nat.lt_succ_self k) (le_length_chain hstep _)
      rw [limText_eq hstep hk'] at hk
      apply hcont (k + 1)
      show some a ∈ chain t₀ step (k + 1)
      rw [← hk]
      exact List.getElem_mem hk'
  obtain ⟨N, hN⟩ := hM _ htext
  have := hN (chain t₀ step (N + 1)).length (le_trans (Nat.le_succ N) (le_length_chain hstep _))
  rw [initSeg_limText hstep] at this
  exact hwrong N this

/-- Prepend a finite sequence to a text. -/
def prepend (σ : List (Option α)) (t : ℕ → Option α) (i : ℕ) : Option α :=
  if h : i < σ.length then σ[i] else t (i - σ.length)

theorem initSeg_prepend (σ : List (Option α)) (t : ℕ → Option α) (n : ℕ) :
    initSeg (prepend σ t) (σ.length + n) = σ ++ initSeg t n := by
  apply List.ext_getElem
  · simp [initSeg]
  · intro i h1 h2
    simp only [initSeg, List.getElem_map, List.getElem_range, prepend, List.getElem_append]

theorem isText_prepend {σ : List (Option α)} {t : ℕ → Option α} {L : Set α}
    (hσ : content σ ⊆ L) (ht : IsText t L) : IsText (prepend σ t) L := by
  intro a
  constructor
  · intro ha
    obtain ⟨n, hn⟩ := (ht a).1 ha
    refine ⟨σ.length + n, ?_⟩
    simp [prepend, hn]
  · rintro ⟨i, hi⟩
    unfold prepend at hi
    split_ifs at hi with h
    · exact hσ (show some a ∈ σ from hi ▸ List.getElem_mem h)
    · exact (ht a).2 ⟨_, hi⟩

/-- A locked sequence for `L` cannot be extended to a text of a proper sub-language `L'` that
`M` also identifies. -/
theorem eq_of_locking {M : List (Option α) → H} {den : H → Set α} {L L' : Set α}
    {σ : List (Option α)} (hlock : ∀ τ, content τ ⊆ L → den (M (σ ++ τ)) = L)
    (hσ : content σ ⊆ L') (hL' : L' ⊆ L) (hM' : BCIdentifies M den L')
    {t' : ℕ → Option α} (ht' : IsText t' L') : L' = L := by
  obtain ⟨N, hN⟩ := hM' _ (isText_prepend hσ ht')
  have h1 := hN (σ.length + N) (by omega)
  rw [initSeg_prepend] at h1
  rw [← h1]
  exact hlock _ ((content_initSeg_subset ht' N).trans hL')

/-- **Angluin's tell-tale condition is necessary for BC-identification (noneffective).**
If every finite subset of `L` lies in some `L' ∈ 𝓛` with `L' ⊊ L`, then no learner whatsoever
BC-identifies `L` together with all members of `𝓛` from text. -/
theorem not_BCIdentifies_of_no_telltale [Countable α] {M : List (Option α) → H}
    {den : H → Set α} {L : Set α} {𝓛 : Set (Set α)}
    (hfam : ∀ D : Finset α, ↑D ⊆ L → ∃ L' ∈ 𝓛, ↑D ⊆ L' ∧ L' ⊆ L ∧ L' ≠ L) :
    ¬ (BCIdentifies M den L ∧ ∀ L' ∈ 𝓛, BCIdentifies M den L') := by
  rintro ⟨hM, hM'⟩
  obtain ⟨t₀, ht₀⟩ := exists_text L
  obtain ⟨σ, hσ, hlock⟩ := exists_locking hM ht₀
  classical
  let D : Finset α := (σ.filterMap id).toFinset
  have hD : (↑D : Set α) = content σ := by
    ext a; simp [D, content, List.mem_filterMap]
  obtain ⟨L', hL'𝓛, hDL', hL'L, hne⟩ := hfam D (hD ▸ hσ)
  obtain ⟨t', ht'⟩ := exists_text L'
  exact hne (eq_of_locking hlock (hD ▸ hDL') hL'L (hM' L' hL'𝓛) ht')

end Gold


/-! ## Theorem 4.4(d): without structurality, `BV` is not identifiable -/

/-- An injective coding of formulas into `ℕ` (for countability). -/
def formulaCode : Formula → ℕ
  | .var n => Nat.pair 0 n
  | .bot => Nat.pair 1 0
  | .top => Nat.pair 2 0
  | .neg a => Nat.pair 3 (formulaCode a)
  | .and a b => Nat.pair 4 (Nat.pair (formulaCode a) (formulaCode b))
  | .or a b => Nat.pair 5 (Nat.pair (formulaCode a) (formulaCode b))
  | .imp a b => Nat.pair 6 (Nat.pair (formulaCode a) (formulaCode b))

theorem formulaCode_injective : Function.Injective formulaCode := by
  intro φ
  induction φ with
  | var n => intro ψ h; cases ψ <;> simp_all [formulaCode, Nat.pair_eq_pair]
  | bot => intro ψ h; cases ψ <;> simp_all [formulaCode, Nat.pair_eq_pair]
  | top => intro ψ h; cases ψ <;> simp_all [formulaCode, Nat.pair_eq_pair]
  | neg a ih =>
    intro ψ h; cases ψ <;> simp [formulaCode, Nat.pair_eq_pair] at h ⊢; exact ih h
  | and a b iha ihb =>
    intro ψ h; cases ψ <;> simp [formulaCode, Nat.pair_eq_pair] at h ⊢
    exact ⟨iha h.1, ihb h.2⟩
  | or a b iha ihb =>
    intro ψ h; cases ψ <;> simp [formulaCode, Nat.pair_eq_pair] at h ⊢
    exact ⟨iha h.1, ihb h.2⟩
  | imp a b iha ihb =>
    intro ψ h; cases ψ <;> simp [formulaCode, Nat.pair_eq_pair] at h ⊢
    exact ⟨iha h.1, ihb h.2⟩

instance countableFormula : Countable Formula := formulaCode_injective.countable

instance infiniteFormula : Infinite Formula :=
  Infinite.of_injective Formula.var fun _ _ h => Formula.var.inj h

instance countableMSeq : Countable MSeq := by
  have : Function.Injective fun s : MSeq => (s.ante, s.succ) := by
    rintro ⟨a, b⟩ ⟨c, d⟩ h
    simp only [Prod.mk.injEq] at h
    rw [h.1, h.2]
  exact this.countable

theorem neg_ne_self (χ : Formula) : neg χ ≠ χ := by
  intro h
  have := congrArg Formula.size h
  simp [Formula.size] at this

/-- `u` with its value at the single formula `χ` flipped (T2's `v'_χ`). -/
def flipAt (u : GVal) (χ : Formula) : GVal := Function.update u χ (!u χ)

/-- The fixed Boolean valuation `u₀` (all atoms false). -/
def u0 : GVal := ofAtoms fun _ => false

theorem u0_mem_BV : u0 ∈ BV := ofAtoms_mem_BV _

/-- `v'_χ` is non-Boolean: `v'_χ(¬χ) = v'_χ(χ)`. -/
theorem flipAt_not_mem_BV {u : GVal} (hu : u ∈ BV) (χ : Formula) : flipAt u χ ∉ BV := by
  intro h
  have h1 := BV_neg h χ
  have h2 := BV_neg hu χ
  simp only [flipAt, Function.update_self, Function.update_of_ne (neg_ne_self χ)] at h1
  rw [h2] at h1
  cases u χ <;> simp at h1

/-- A valuation that is Boolean except at `χ` satisfies every `BV`-valid sequent not
mentioning `χ`: it is refuted only by data mentioning `χ`. -/
theorem sat_flipAt_of_not_mem {u : GVal} (hu : u ∈ BV) {χ : Formula} {s : MSeq}
    (hs : s ∈ mrel BV) (hχ : χ ∉ s.forms) : s.Sat (flipAt u χ) := by
  have : ∀ φ ∈ s.forms, flipAt u χ φ = u φ := by
    intro φ hφ
    have hne : φ ≠ χ := by rintro rfl; exact hχ hφ
    simp [flipAt, Function.update_of_ne hne]
  exact (MSeq.sat_congr this).2 (hs u hu)

/-- Every non-Boolean valuation is refuted by some `BV`-valid finite sequent. -/
theorem exists_refutation {v : GVal} (hv : v ∉ BV) : ∃ s ∈ mrel BV, ¬ s.Sat v := by
  obtain ⟨s, hs, hsv, -⟩ := exclBy_two_iff.2 hv
  exact ⟨s, hs, hsv⟩

/-- The meanings `BV ∪ {v'_χ}` are closed. -/
theorem isClosed_BV_union_flipAt (χ : Formula) : IsClosed (BV ∪ {flipAt u0 χ}) :=
  isClosed_BV.union isClosed_singleton

/-- `L_χ := ⊨ᵐ_{BV ∪ {v'_χ}}` is strictly contained in `⊨ᵐ_BV`. -/
theorem mrel_flip_ssubset (χ : Formula) : mrel (BV ∪ {flipAt u0 χ}) ⊂ mrel BV :=
  mrel_ssubset_of_BV_ssubset ((Set.ssubset_iff_of_subset Set.subset_union_left).2
    ⟨flipAt u0 χ, Or.inr rfl, flipAt_not_mem_BV u0_mem_BV χ⟩)

/-- The coherence datum `[ : ]` is in bounds for every `BV ∪ {v'_χ}` (and for `BV`). -/
theorem inBounds_empty_flip (χ : Formula) : InBounds (BV ∪ {flipAt u0 χ}) ⟨∅, ∅⟩ :=
  inBounds_empty_iff.2 ⟨u0, Or.inl u0_mem_BV⟩

/-- **Theorem 4.4(d), no tell-tale.**  Every finite `T ⊆ ⊨ᵐ_BV` lies in some `L_χ`. -/
theorem no_finite_telltale (D : Finset MSeq) (hD : ↑D ⊆ mrel BV) :
    ∃ χ, ↑D ⊆ mrel (BV ∪ {flipAt u0 χ}) := by
  obtain ⟨χ, hχ⟩ := Infinite.exists_notMem_finset (D.biUnion MSeq.forms)
  refine ⟨χ, fun s hs => ?_⟩
  rintro v (hv | hv)
  · exact hD hs v hv
  · rw [Set.mem_singleton_iff] at hv
    subst hv
    exact sat_flipAt_of_not_mem u0_mem_BV (hD hs) fun h => hχ (Finset.mem_biUnion.2 ⟨s, hs, h⟩)

/-- **Theorem 4.4(d) (revised after verification).**  Without structurality `BV` is not
identifiable in the limit: no learner — computable or not — BC-identifies (hence none
EX-identifies) from text all of `⊨ᵐ_BV` and the `L_χ`.  Conjectures are arbitrary objects `h`
denoting meanings `den h`, and a conjecture counts as correct when its meaning has the target's
multiple-conclusion relation. -/
theorem BV_not_BC_learnable {H : Type*} (M : List (Option MSeq) → H) (den : H → Set GVal) :
    ¬ (BCIdentifies M (fun h => mrel (den h)) (mrel BV) ∧
        ∀ χ, BCIdentifies M (fun h => mrel (den h)) (mrel (BV ∪ {flipAt u0 χ}))) := by
  rintro ⟨h1, h2⟩
  refine not_BCIdentifies_of_no_telltale
    (𝓛 := Set.range fun χ => mrel (BV ∪ {flipAt u0 χ})) ?_ ⟨h1, ?_⟩
  · intro D hD
    obtain ⟨χ, hχ⟩ := no_finite_telltale D hD
    exact ⟨_, ⟨χ, rfl⟩, hχ, (mrel_flip_ssubset χ).subset, (mrel_flip_ssubset χ).ne⟩
  · rintro _ ⟨χ, rfl⟩
    exact h2 χ

/-- `M` BC-identifies the meaning `V` exactly (from a text for `⊨ᵐ_V`). -/
def BCIdentifiesMeaning {H : Type*} (M : List (Option MSeq) → H) (den : H → Set GVal)
    (V : Set GVal) : Prop :=
  ∀ t, IsText t (mrel V) → ∃ N, ∀ n ≥ N, den (M (initSeg t n)) = V

theorem BCIdentifiesMeaning.toRel {H : Type*} {M : List (Option MSeq) → H}
    {den : H → Set GVal} {V : Set GVal} (h : BCIdentifiesMeaning M den V) :
    BCIdentifies M (fun h => mrel (den h)) (mrel V) := by
  intro t ht
  obtain ⟨N, hN⟩ := h t ht
  exact ⟨N, fun n hn => congrArg mrel (hN n hn)⟩

/-- **Theorem 4.4(d), meaning form.**  No learner identifies, in the limit, the meaning `BV`
within any class containing `BV` and all the closed meanings `BV ∪ {v'_χ}`. -/
theorem BV_not_BC_learnable_meaning {H : Type*} (M : List (Option MSeq) → H)
    (den : H → Set GVal) :
    ¬ (BCIdentifiesMeaning M den BV ∧ ∀ χ, BCIdentifiesMeaning M den (BV ∪ {flipAt u0 χ})) :=
  fun ⟨h1, h2⟩ => BV_not_BC_learnable M den ⟨h1.toRel, fun χ => (h2 χ).toRel⟩

/-! ### Theorem 4.4(d), density: not even determined by complete data among all meanings -/

/-- `BV` has no isolated points: `BV \ {u}` is dense in `BV`. -/
theorem closure_BV_diff_singleton (a : Valuation) : closure (BV \ {ofAtoms a}) = BV := by
  apply Set.Subset.antisymm
  · exact (closure_mono Set.sdiff_subset).trans closure_BV.subset
  · rintro _ ⟨b, rfl⟩
    rw [mem_closure_iff_agree]
    intro F
    obtain ⟨N, hN⟩ := Infinite.exists_notMem_finset (F.biUnion Formula.atoms)
    refine ⟨ofAtoms (Function.update b N (!a N)), ⟨ofAtoms_mem_BV _, ?_⟩, ?_⟩
    · intro h
      have := congrFun (Set.mem_singleton_iff.1 h) (var N)
      simp at this
    · intro φ hφ
      apply eval_congr
      intro n hn
      have : n ≠ N := by rintro rfl; exact hN (Finset.mem_biUnion.2 ⟨φ, hφ, hn⟩)
      simp [Function.update_of_ne this]

/-- `BV \ {u}` has exactly the same valid multiple-conclusion sequents as `BV` … -/
theorem mrel_BV_diff_singleton (a : Valuation) : mrel (BV \ {ofAtoms a}) = mrel BV := by
  rw [mrel_eq_mrel_BV_iff, closure_BV_diff_singleton]

/-- … and the same in-bounds positions … -/
theorem inBounds_BV_diff_singleton (a : Valuation) (s : MSeq) :
    InBounds (BV \ {ofAtoms a}) s ↔ InBounds BV s := by
  rw [inBounds_iff_not_mem_mrel, inBounds_iff_not_mem_mrel, mrel_BV_diff_singleton]

/-- … yet it is a different meaning, and it is not structural. -/
theorem BV_diff_singleton_ne (a : Valuation) : BV \ {ofAtoms a} ≠ BV := by
  intro h
  have := ofAtoms_mem_BV a
  rw [← h] at this
  exact this.2 rfl

theorem not_structural_BV_diff_singleton (a : Valuation) :
    ¬ StructuralMeaning (BV \ {ofAtoms a}) := by
  intro h
  have hv : ofAtoms (Function.update a 0 (!a 0)) ∈ BV \ {ofAtoms a} := by
    refine ⟨ofAtoms_mem_BV _, fun h => ?_⟩
    have := congrFun (Set.mem_singleton_iff.1 h) (var 0)
    simp at this
  have := h _ hv (Subst.ofVal a)
  rw [ofAtoms_comp_subst, show (fun n => (Subst.ofVal a n).eval
    (Function.update a 0 (!a 0))) = a by funext n; simp] at this
  exact this.2 rfl

/-- **Theorem 4.4(d), density.**  Among all (not necessarily structural) meanings, even complete
data — the full multiple-conclusion relation and all in-bounds positions — do not determine
`BV`. -/
theorem BV_not_determined_nonstructural :
    ∃ V : Set GVal, V ≠ BV ∧ mrel V = mrel BV ∧ (∀ s, InBounds V s ↔ InBounds BV s) ∧
      ¬ StructuralMeaning V :=
  ⟨BV \ {u0}, BV_diff_singleton_ne _, mrel_BV_diff_singleton _,
    inBounds_BV_diff_singleton _, not_structural_BV_diff_singleton _⟩


/-! ## Supplements to Theorem 4.2 -/

/-- **Thm 4.2, second bullet.**  Every consistent non-maximal theory valuation `v_T`
(i.e. every consistent member of `BV^∩ \ BV`, e.g. `v_Taut`) violates the truth tables of
`¬`, `∨` and `→`, at the formulas `φ`, `φ ∨ ¬φ` and `φ → ¬φ` for a gap `φ`. -/
theorem consistent_nonBoolean_violates {w : GVal} (hw : w ∈ intClosure BV \ BV)
    (hsat : Satisfiable (trueSet w)) :
    ∃ φ, w (neg φ) ≠ !(w φ) ∧ w (Formula.or φ (neg φ)) ≠ (w φ || w (neg φ)) ∧
      w (imp φ (neg φ)) ≠ (!(w φ) || w (neg φ)) := by
  have hcl := mem_intClosure_BV_iff.1 hw.1
  obtain ⟨φ, hφ, hnφ⟩ := exists_gap hw.2 hsat hcl
  have hor : w (Formula.or φ (neg φ)) = true :=
    hcl (SemCons.of_tautology fun v => by cases φ.eval v <;> simp)
  have himp : w (imp φ (neg φ)) = false := by
    cases h : w (imp φ (neg φ))
    · rfl
    · exfalso
      have : w (neg φ) = true := by
        apply hcl
        intro a ha
        have := ha _ h
        cases hφa : φ.eval a <;> simp_all
      rw [hnφ] at this
      exact Bool.false_ne_true this
  refine ⟨φ, ?_, ?_, ?_⟩
  · rw [hφ, hnφ]; decide
  · rw [hor, hφ, hnφ]; decide
  · rw [himp, hφ, hnφ]; decide

/-- `v_⊤` is the only inconsistent member of `BV^∩`. -/
theorem eq_vtop_of_not_satisfiable {w : GVal} (hw : w ∈ intClosure BV)
    (hsat : ¬ Satisfiable (trueSet w)) : w = vtop := by
  have hcl := mem_intClosure_BV_iff.1 hw
  funext φ
  apply hcl
  intro a ha
  exact absurd ⟨a, ha⟩ hsat

instance countableSSeq : Countable SSeq := by
  have : Function.Injective fun s : SSeq => (s.prem, s.concl) := by
    rintro ⟨a, b⟩ ⟨c, d⟩ h
    simp only [Prod.mk.injEq] at h
    rw [h.1, h.2]
  exact this.countable

/-- `M` BC-identifies the meaning `V` from a text of its single-conclusion relation. -/
def BCIdentifiesMeaningS {H : Type*} (M : List (Option SSeq) → H) (den : H → Set GVal)
    (V : Set GVal) : Prop :=
  ∀ t, IsText t (srel V) → ∃ N, ∀ n ≥ N, den (M (initSeg t n)) = V

/-- **Theorem 4.2, learning form.**  No learner — computable or not — that sees only
single-conclusion data identifies both `BV` and any `W ≠ BV` with `BV ⊆ W ⊆ BV^∩` (e.g.
`BV ∪ {v_⊤}` or `BV ∪ {v_Taut}`), even in the BC sense. -/
theorem carnap_not_learnable_single {W : Set GVal} (hBW : BV ⊆ W) (hW : W ⊆ intClosure BV)
    (hne : W ≠ BV) {H : Type*} (M : List (Option SSeq) → H) (den : H → Set GVal) :
    ¬ (BCIdentifiesMeaningS M den BV ∧ BCIdentifiesMeaningS M den W) := by
  rintro ⟨h1, h2⟩
  have hS : srel W = srel BV := by
    ext s; simp only [srel, Set.mem_setOf_eq, carnap_single hBW hW]
  obtain ⟨t, ht⟩ := exists_text (srel BV)
  obtain ⟨N₁, hN₁⟩ := h1 t ht
  obtain ⟨N₂, hN₂⟩ := h2 t (hS ▸ ht)
  exact hne ((hN₂ (max N₁ N₂) (le_max_right _ _)).symm.trans (hN₁ _ (le_max_left _ _)))

theorem vtop_ne : BV ∪ {vtop} ≠ BV := fun h =>
  vtop_not_mem_BV (h ▸ Or.inr rfl)

theorem vTaut_ne : BV ∪ {vTaut} ≠ BV := fun h =>
  vTaut_not_mem_BV (h ▸ Or.inr rfl)

/-! ## Theorem 4.4(c): a finite learner for the structural meanings -/

/-- The finite learner of Thm 4.4(c): conjecture `BV` as soon as all of `TT(p,q)` has
appeared, and abstain (`none`) before. -/
noncomputable def ttLearner (σ : List (Option MSeq)) : Option (Set GVal) :=
  @ite _ (TTpq ⊆ content σ) (Classical.dec _) (some BV) none

theorem content_initSeg_mono {α' : Type*} (t : ℕ → Option α') {n m : ℕ} (h : n ≤ m) :
    content (initSeg t n) ⊆ content (initSeg t m) := by
  intro a ha
  simp only [content, initSeg, Set.mem_setOf_eq, List.mem_map, List.mem_range] at ha ⊢
  obtain ⟨i, hi, hia⟩ := ha
  exact ⟨i, by omega, hia⟩

theorem exists_initSeg_superset {α' : Type*} {t : ℕ → Option α'} {L : Set α'} (ht : IsText t L)
    {S : Set α'} (hS : S.Finite) (hSL : S ⊆ L) : ∃ N, S ⊆ content (initSeg t N) := by
  induction S, hS using Set.Finite.induction_on with
  | empty => exact ⟨0, Set.empty_subset _⟩
  | @insert a S _ _ ih =>
    obtain ⟨N, hN⟩ := ih ((Set.subset_insert a S).trans hSL)
    obtain ⟨n, hn⟩ := (ht a).1 (hSL (Set.mem_insert a S))
    refine ⟨max N (n + 1), Set.insert_subset ?_ (hN.trans (content_initSeg_mono t (le_max_left _ _)))⟩
    simp only [content, initSeg, Set.mem_setOf_eq, List.mem_map, List.mem_range]
    exact ⟨n, by omega, hn⟩

/-- **Theorem 4.4(c), finite identification.**  On the class of structural meanings for which
the coherence datum `[ : ]` is in bounds, `ttLearner` *finitely* identifies `BV`:
(i) whenever it commits to a conjecture on a text for `⊨ᵐ_V`, the conjecture is `V`
(so it never commits wrongly), and (ii) on every text for `⊨ᵐ_BV` it commits. -/
theorem ttLearner_finite_identification :
    (∀ V : Set GVal, StructuralMeaning V → InBounds V ⟨∅, ∅⟩ →
      ∀ t, IsText t (mrel V) → ∀ n W, ttLearner (initSeg t n) = some W → W = V) ∧
    (∀ t, IsText t (mrel BV) → ∃ N, ∀ n ≥ N, ttLearner (initSeg t n) = some BV) := by
  constructor
  · intro V hV hcoh t ht n W hW
    unfold ttLearner at hW
    split_ifs at hW with h
    cases hW
    exact (structural_eq_BV hV (h.trans (content_initSeg_subset ht n)) hcoh).symm
  · intro t ht
    have hsub : TTpq ⊆ mrel BV :=
      ((finite_telltale_structural BV_structural).2 rfl).1
    obtain ⟨N, hN⟩ := exists_initSeg_superset ht TTpq_finite hsub
    refine ⟨N, fun n hn => ?_⟩
    unfold ttLearner
    rw [if_pos (hN.trans (content_initSeg_mono t hn))]

end Carnap
end InfLearn

/-! ## Axiom audit -/
#print axioms InfLearn.Carnap.SVal_eq_intClosure
#print axioms InfLearn.Carnap.Val_mrel
#print axioms InfLearn.Carnap.eq_of_mrel_eq
#print axioms InfLearn.Carnap.lemma_4_1_b
#print axioms InfLearn.Carnap.isClosed_CV_iff
#print axioms InfLearn.Carnap.SValS_srel
#print axioms InfLearn.Carnap.mem_intClosure_BV_iff
#print axioms InfLearn.Carnap.intClosure_BV_eq
#print axioms InfLearn.Carnap.carnap_single
#print axioms InfLearn.Carnap.carnap_single_vtop
#print axioms InfLearn.Carnap.carnap_single_vTaut
#print axioms InfLearn.Carnap.carnap_problem
#print axioms InfLearn.Carnap.carnap_vtop
#print axioms InfLearn.Carnap.carnap_vTaut
#print axioms InfLearn.Carnap.carnap_not_learnable_single
#print axioms InfLearn.Carnap.mem_intClosure_BV_diff_BV_iff
#print axioms InfLearn.Carnap.intClosure_BV_and
#print axioms InfLearn.Carnap.consistent_nonBoolean_violates
#print axioms InfLearn.Carnap.isClosed_intClosure_BV
#print axioms InfLearn.Carnap.intClosure_BV_structural
#print axioms InfLearn.Carnap.denialRank_eq_zero_iff
#print axioms InfLearn.Carnap.denialRank_eq_one_iff
#print axioms InfLearn.Carnap.denialRank_eq_two_iff
#print axioms InfLearn.Carnap.denialRank_eq_top_iff
#print axioms InfLearn.Carnap.denialRank_vTaut
#print axioms InfLearn.Carnap.Val_TTall
#print axioms InfLearn.Carnap.isClosed_BV
#print axioms InfLearn.Carnap.structural_eq_BV
#print axioms InfLearn.Carnap.finite_telltale_structural
#print axioms InfLearn.Carnap.ttLearner_finite_identification
#print axioms InfLearn.Carnap.no_finite_telltale
#print axioms InfLearn.Carnap.not_BCIdentifies_of_no_telltale
#print axioms InfLearn.Carnap.BV_not_BC_learnable
#print axioms InfLearn.Carnap.BV_not_BC_learnable_meaning
#print axioms InfLearn.Carnap.BV_not_determined_nonstructural
