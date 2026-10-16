import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Data.Fintype.BigOperators

/-! # Splitting one coordinate from an actual finite product measure -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.CoordinateSplit
variable {I : Type*} [Fintype I] [DecidableEq I]

def split (i : I) : (I → ℝ) ≃ᵐ ℝ × ({j : I // j ≠ i} → ℝ) where
  toEquiv := Equiv.funSplitAt i ℝ
  measurable_toFun := (measurable_pi_apply i).prodMk
    (measurable_pi_lambda _ (fun j => measurable_pi_apply j.1))
  measurable_invFun := by
    apply measurable_pi_lambda
    intro j
    by_cases h : j = i
    · subst j
      simpa [Equiv.funSplitAt, Equiv.piSplitAt] using measurable_fst
    · simpa [Equiv.funSplitAt, Equiv.piSplitAt, h, Function.comp_def] using
        (measurable_pi_apply (⟨j, h⟩ : {j : I // j ≠ i})).comp measurable_snd

omit [Fintype I] in
@[simp] theorem split_symm_self (i : I) (t : ℝ) (y : {j : I // j ≠ i} → ℝ) :
    (split i).symm (t, y) i = t := by
  simp [split, Equiv.funSplitAt, Equiv.piSplitAt]

omit [Fintype I] in
@[simp] theorem split_symm_ne (i : I) (t : ℝ) (y : {j : I // j ≠ i} → ℝ)
    (j : I) (hj : j ≠ i) : (split i).symm (t, y) j = y ⟨j, hj⟩ := by
  simp [split, Equiv.funSplitAt, Equiv.piSplitAt, hj]

omit [Fintype I] in
@[simp] theorem update_split_symm (i : I) (t u : ℝ) (y : {j : I // j ≠ i} → ℝ) :
    Function.update ((split i).symm (t, y)) i u = (split i).symm (u, y) := by
  funext j
  by_cases hj : j = i
  · subst j
    simp
  · simp [split_symm_ne, hj]

theorem measurePreserving_split (μ : I → Measure ℝ) [∀ i, SigmaFinite (μ i)] (i : I) :
    MeasurePreserving (split i) (Measure.pi μ)
      ((μ i).prod (Measure.pi fun j : {j : I // j ≠ i} => μ j)) := by
  let e := (split i).symm
  refine MeasurePreserving.symm e ?_
  refine ⟨e.measurable, (Measure.pi_eq fun s _ => ?_).symm⟩
  have heq : e ⁻¹' Set.univ.pi s =
      s i ×ˢ Set.univ.pi (fun j : {j : I // j ≠ i} => s j) := by
    ext p
    rcases p with ⟨t, y⟩
    simp only [Set.mem_preimage, Set.mem_pi, Set.mem_univ, forall_true_left, Set.mem_prod]
    constructor
    · intro h
      refine ⟨?_, ?_⟩
      · simpa only [e, split_symm_self] using h i
      · intro j
        simpa only [e, split_symm_ne i t y j.1 j.2] using h j.1
    · rintro ⟨hi, hy⟩ j
      by_cases hj : j = i
      · subst j
        simpa only [e, split_symm_self] using hi
      · simpa only [e, split_symm_ne i t y j hj] using hy ⟨j, hj⟩
  rw [e.map_apply, heq, Measure.prod_prod, Measure.pi_pi]
  exact (Fintype.prod_eq_mul_prod_subtype_ne (fun j => μ j (s j)) i).symm

end NeuralGeneralization.CoordinateSplit
end
