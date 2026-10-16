import NeuralGeneralization.PrekopaLeindlerGaussian
import NeuralGeneralization.CoordinateSplit
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Integral.DominatedConvergence

/-! Continuous bounded Gaussian coordinate marginalization, with the exact
finite product measure and actual coordinate split. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
namespace NeuralGeneralization.GaussianCoordinateIntegration
open PrekopaLeindlerInterval

def law (I : Type*) [Fintype I] : Measure (I → ℝ) :=
  Measure.pi fun _ : I => gaussianReal 0 1

instance (I : Type*) [Fintype I] : IsProbabilityMeasure (law I) := by
  unfold law
  infer_instance

def mixVec {I : Type*} (t : ℝ) (x y : I → ℝ) : I → ℝ := fun i => mix t (x i) (y i)

theorem integrable_unit {X : Type*} [MeasurableSpace X] (μ : Measure X)
    [IsFiniteMeasure μ] {f : X → ℝ} (hf : Measurable f)
    (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1) : Integrable f μ :=
  Integrable.of_bound hf.aestronglyMeasurable 1 (Eventually.of_forall fun x => by
    rw [Real.norm_eq_abs, abs_of_pos (hpos x)]; exact hB x)

theorem integral_pos_unit {X : Type*} [MeasurableSpace X] (μ : Measure X)
    [IsProbabilityMeasure μ] {f : X → ℝ} (hf : Measurable f)
    (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1) : 0 < ∫ x, f x ∂μ := by
  rw [integral_pos_iff_support_of_nonneg (fun x => (hpos x).le)
    (integrable_unit μ hf hpos hB)]
  have hs : Function.support f = univ := by
    ext x
    simp only [Function.mem_support, mem_univ, iff_true]
    exact (hpos x).ne'
  rw [hs, measure_univ]
  exact zero_lt_one

theorem integral_le_one_unit {X : Type*} [MeasurableSpace X] (μ : Measure X)
    [IsProbabilityMeasure μ] {f : X → ℝ} (hf : Measurable f)
    (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1) : (∫ x, f x ∂μ) ≤ 1 := by
  have h := integral_mono (integrable_unit μ hf hpos hB) (integrable_const (1 : ℝ)) hB
  simpa only [integral_const, probReal_univ, one_smul] using h

variable {I : Type*} [Fintype I] [DecidableEq I]

theorem continuous_split_symm (i : I) : Continuous (CoordinateSplit.split i).symm := by
  apply continuous_pi
  intro j
  by_cases hj : j = i
  · subst j
    have heq : (fun p : ℝ × ({j : I // j ≠ i} → ℝ) => (CoordinateSplit.split i).symm p i) =
        (fun p => p.1) := by funext p; exact CoordinateSplit.split_symm_self i p.1 p.2
    rw [heq]
    exact continuous_fst
  · simpa only [CoordinateSplit.split_symm_ne i _ _ j hj, Function.comp_def] using
      (continuous_apply (⟨j,hj⟩ : {j : I // j ≠ i})).comp continuous_snd

theorem split_symm_mix (i : I) (t a b : ℝ) (y z : {j : I // j ≠ i} → ℝ) :
    (CoordinateSplit.split i).symm (mix t a b, mixVec t y z) =
      mixVec t ((CoordinateSplit.split i).symm (a,y)) ((CoordinateSplit.split i).symm (b,z)) := by
  funext j
  by_cases hj : j = i
  · subst j
    simp only [CoordinateSplit.split_symm_self, mixVec]
  · simp only [CoordinateSplit.split_symm_ne i _ _ j hj, mixVec]

def marginal (i : I) (f : (I → ℝ) → ℝ) (y : {j : I // j ≠ i} → ℝ) : ℝ :=
  ∫ a, f ((CoordinateSplit.split i).symm (a,y)) ∂gaussianReal 0 1

theorem continuous_marginal (i : I) {f : (I → ℝ) → ℝ}
    (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1) :
    Continuous (marginal i f) := by
  apply continuous_of_dominated
    (F := fun y a => f ((CoordinateSplit.split i).symm (a,y)))
    (bound := fun _ => (1 : ℝ))
  · intro y
    exact (hf.comp ((continuous_split_symm i).comp
      (continuous_id.prodMk continuous_const))).aestronglyMeasurable
  · intro y
    exact Eventually.of_forall fun a => by
      rw [Real.norm_eq_abs, abs_of_pos (hpos _)]; exact hB _
  · exact integrable_const 1
  · exact Eventually.of_forall fun a => hf.comp ((continuous_split_symm i).comp
      (continuous_const.prodMk continuous_id))

theorem marginal_pos (i : I) {f : (I → ℝ) → ℝ}
    (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1)
    (y : {j : I // j ≠ i} → ℝ) : 0 < marginal i f y :=
  integral_pos_unit _
    (hf.comp ((continuous_split_symm i).comp (continuous_id.prodMk continuous_const))).measurable
    (fun _ => hpos _) (fun _ => hB _)

theorem marginal_le_one (i : I) {f : (I → ℝ) → ℝ}
    (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1)
    (y : {j : I // j ≠ i} → ℝ) : marginal i f y ≤ 1 :=
  integral_le_one_unit _
    (hf.comp ((continuous_split_symm i).comp (continuous_id.prodMk continuous_const))).measurable
    (fun _ => hpos _) (fun _ => hB _)

theorem integral_marginal (i : I) {f : (I → ℝ) → ℝ}
    (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hB : ∀ x, f x ≤ 1) :
    (∫ y, marginal i f y ∂law {j : I // j ≠ i}) = ∫ x, f x ∂law I := by
  have hsplit := (CoordinateSplit.measurePreserving_split
    (fun _ : I => gaussianReal 0 1) i).symm
  have hi := hsplit.integrable_comp_of_integrable (integrable_unit (law I) hf.measurable hpos hB)
  calc
    _ = ∫ p : ℝ × ({j : I // j ≠ i} → ℝ), f ((CoordinateSplit.split i).symm p)
        ∂((gaussianReal 0 1).prod (law {j : I // j ≠ i})) := by
      simpa only [marginal, law, Function.comp_def] using (integral_prod_symm _ hi).symm
    _ = _ := hsplit.integral_comp' f

end NeuralGeneralization.GaussianCoordinateIntegration
end
