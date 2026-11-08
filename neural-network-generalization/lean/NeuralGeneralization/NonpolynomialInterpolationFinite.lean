import NeuralGeneralization.NonpolynomialInterpolationSmoothing
import Mathlib.LinearAlgebra.Dual.Lemmas
import Mathlib.LinearAlgebra.Basis.VectorSpace
import Mathlib.Algebra.Module.Submodule.Union

/-! Exact interpolation by a continuous nonpolynomial activation, with exactly
as many available features as interpolation nodes. The coefficients can depend
on the values, while the feature dictionary depends only on the nodes. -/
noncomputable section
open scoped BigOperators
open Module
namespace NeuralGeneralization.NonpolynomialInterpolation
variable {ι : Type*} [Fintype ι]

/-- Affine activation features span all functions on distinct finite scalar nodes. -/
theorem affine_features_span {f : ℝ → ℝ} (hf : Continuous f) (hn : Nonpolynomial f)
    {t : ι → ℝ} (ht : Function.Injective t) :
    Submodule.span ℝ (Set.range (fun p : ℝ × ℝ => fun i => f (p.1 * t i + p.2))) = ⊤ := by
  apply span_flip_eq_top_iff_linearIndependent.mpr
  apply Fintype.linearIndependent_iff.mpr
  intro c hc
  have hz : c = 0 := relation_coefficients_zero hf hn ht (fun s b => by
    simpa [Finset.sum_apply, Pi.smul_apply, smul_eq_mul] using congrFun hc (s, b))
  intro i
  exact congrFun hz i

/-- A basis of actual activation features, indexed by the interpolation nodes. -/
theorem exists_affine_feature_basis {f : ℝ → ℝ} (hf : Continuous f)
    (hn : Nonpolynomial f) {t : ι → ℝ} (ht : Function.Injective t) :
    ∃ a b : ι → ℝ, ∃ B : Basis ι ℝ (ι → ℝ),
      ∀ j i, B j i = f (a j * t i + b j) := by
  classical
  have hs := (affine_features_span hf hn ht).ge
  let B := Basis.ofSpan hs
  letI := Module.Finite.finite_basis B
  letI := Fintype.ofFinite (Set.Elem ((linearIndepOn_empty ℝ id).extend
    (Set.empty_subset (Set.range (fun p : ℝ × ℝ => fun i => f (p.1 * t i + p.2))))))
  have hcard : Fintype.card (Set.Elem ((linearIndepOn_empty ℝ id).extend
      (Set.empty_subset (Set.range (fun p : ℝ × ℝ => fun i => f (p.1 * t i + p.2)))))) =
      Fintype.card ι := by
    rw [← Module.finrank_eq_card_basis B, Module.finrank_pi]
  let e := Fintype.equivOfCardEq hcard
  let B' : Basis ι ℝ (ι → ℝ) := B.reindex e
  have hm (j : ι) : B' j ∈ Set.range (fun p : ℝ × ℝ => fun i => f (p.1 * t i + p.2)) := by
    apply Basis.ofSpan_subset hs
    exact ⟨e.symm j, by simp [B', B]⟩
  choose p hp using hm
  exact ⟨fun j => (p j).1, fun j => (p j).2, B', fun j i => (congrFun (hp j) i).symm⟩

/-- Finite scalar interpolation with a fixed dictionary of `card ι` features. -/
theorem finite_scalar_interpolation {f : ℝ → ℝ} (hf : Continuous f)
    (hn : Nonpolynomial f) {t : ι → ℝ} (ht : Function.Injective t) :
    ∃ a b : ι → ℝ, ∀ y : ι → ℝ, ∃ c : ι → ℝ,
      ∀ i, y i = ∑ j, c j * f (a j * t i + b j) := by
  obtain ⟨a, b, B, hB⟩ := exists_affine_feature_basis hf hn ht
  refine ⟨a, b, fun y => ⟨fun j => B.repr y j, ?_⟩⟩
  intro i
  simpa only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, hB] using
    (congrFun (B.sum_repr y) i).symm

/-- One linear functional separates any finite set of distinct vectors. -/
theorem exists_separating_functional {V : Type*} [AddCommGroup V] [Module ℝ V]
    {v : ι → V} (hv : Function.Injective v) :
    ∃ ℓ : V →ₗ[ℝ] ℝ, Function.Injective (fun i => ℓ (v i)) := by
  classical
  let P := {p : ι × ι // p.1 ≠ p.2}
  obtain ⟨ℓ, hℓ⟩ := Module.exists_dual_forall_apply_ne_zero (K := ℝ)
    (fun p : P => v p.val.1 - v p.val.2)
    (fun p => sub_ne_zero.mpr (hv.ne p.property))
  refine ⟨ℓ, fun i j hij => ?_⟩
  by_contra hne
  exact hℓ ⟨(i, j), hne⟩ (by simpa only [map_sub, sub_eq_zero] using hij)

/-- Exact finite interpolation in any real vector space. All features are
scalar multiples of a single separating linear functional, plus a shift. -/
theorem finite_vector_interpolation {V : Type*} [AddCommGroup V] [Module ℝ V]
    {f : ℝ → ℝ} (hf : Continuous f) (hn : Nonpolynomial f)
    {v : ι → V} (hv : Function.Injective v) :
    ∃ ℓ : V →ₗ[ℝ] ℝ, ∃ a b : ι → ℝ, ∀ y : ι → ℝ, ∃ c : ι → ℝ,
      ∀ i, y i = ∑ j, c j * f (a j * ℓ (v i) + b j) := by
  obtain ⟨ℓ, hℓ⟩ := exists_separating_functional hv
  obtain ⟨a, b, hab⟩ := finite_scalar_interpolation hf hn hℓ
  exact ⟨ℓ, a, b, hab⟩

end NeuralGeneralization.NonpolynomialInterpolation
