import NeuralGeneralization.RobustPosteriorConditioning
import NeuralGeneralization.RobustStatistics
import Mathlib.Order.Disjointed

/-! Exact finite partitions of a conditioned prior. Small components are
removed by their posterior mass, without a target-mass premise per cell. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.FiniteUnionConditioning
open RobustPosterior
variable {W I : Type*} [MeasurableSpace W] [Fintype I]

lemma measurable_disjointed {M : ℕ} (A : Fin M → Set W)
    (hA : ∀ j, MeasurableSet (A j)) (j : Fin M) :
    MeasurableSet (disjointed A j) := by
  rw [disjointed_eq_inter_compl]
  exact (hA j).inter (MeasurableSet.iInter fun i => MeasurableSet.iInter fun _ => (hA i).compl)

variable (μ : Measure W) [IsProbabilityMeasure μ] (E : I → Set W)
    (hE : ∀ j, MeasurableSet (E j)) (hd : Pairwise (fun i j => Disjoint (E i) (E j)))

include hE hd in
lemma sum_mass : (∑ j, μ.real (E j)) = μ.real (⋃ j, E j) :=
  (measureReal_iUnion_fintype hd hE).symm

include hE hd in
lemma cond_partition (A : Set W) (hA : MeasurableSet A) :
    (cond μ (⋃ j, E j)).real A =
      ∑ j, (μ.real (E j) / μ.real (⋃ i, E i)) * (cond μ (E j)).real A := by
  classical
  rw [cond_real_eq_ratio μ _ _ (MeasurableSet.iUnion hE), Set.iUnion_inter,
    measureReal_iUnion_fintype (fun i j hij => (hd hij).mono Set.inter_subset_left Set.inter_subset_left)
      (fun j => (hE j).inter hA), Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  rw [cond_real_eq_ratio μ _ _ (hE j)]
  by_cases hz : μ.real (E j) = 0
  · have hi : μ.real (E j ∩ A) = 0 :=
      le_antisymm ((measureReal_mono Set.inter_subset_left).trans_eq hz) measureReal_nonneg
    simp [hz,hi]
  · field_simp

include hE hd in
lemma sum_weight (hpos : 0 < μ.real (⋃ j, E j)) :
    (∑ j, μ.real (E j) / μ.real (⋃ i, E i)) = 1 := by
  rw [← Finset.sum_div, sum_mass μ E hE hd, div_self hpos.ne']

/-- Removing cells lighter than β/M loses at most β in the exact union posterior. -/
theorem small_weight [Nonempty I] {β : ℝ} (hβ : 0 ≤ β) :
    (∑ j, if μ.real (E j) / μ.real (⋃ i, E i) < β / Fintype.card I
      then μ.real (E j) / μ.real (⋃ i, E i) else 0) ≤ β := by
  classical
  calc
    _ ≤ ∑ _j : I, β / Fintype.card I := by
      apply Finset.sum_le_sum
      intro j _
      split_ifs with h
      · exact h.le
      · positivity
    _ = β := by
      have hM : (Fintype.card I : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
      simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul]
      field_simp

/-- A retained cell inherits a raw Gaussian-style exponential mass bound.
This uses the mass of the union, never a separate target cylinder in the cell. -/
theorem retained_mass [Nonempty I] {s D β : ℝ} (hs : 0 < s) (hs1 : s ≤ 1)
    (hβ : 0 < β) (hβ1 : β ≤ 1)
    (hmass : Real.exp (-D/s) ≤ μ.real (⋃ j, E j)) (j : I)
    (hj : β / Fintype.card I ≤ μ.real (E j) / μ.real (⋃ i, E i)) :
    Real.exp (-(D + Real.log ((Fintype.card I : ℝ)/β))/s) ≤ μ.real (E j) := by
  have hM : (1:ℝ) ≤ Fintype.card I := by exact_mod_cast Fintype.card_pos
  have hu : 0 < μ.real (⋃ i, E i) := (Real.exp_pos _).trans_le hmass
  have hlog : 0 ≤ Real.log ((Fintype.card I : ℝ)/β) :=
    Real.log_nonneg ((one_le_div hβ).mpr (hβ1.trans hM))
  have hscale : -(Real.log ((Fintype.card I : ℝ)/β))/s ≤ -Real.log ((Fintype.card I : ℝ)/β) :=
    (div_le_iff₀ hs).mpr (by nlinarith)
  have hid : Real.exp (-Real.log ((Fintype.card I : ℝ)/β)) = β / Fintype.card I := by
    rw [Real.exp_neg, Real.exp_log (by positivity)]
    simp only [inv_div]
  calc
    _ = Real.exp (-D/s) * Real.exp (-(Real.log ((Fintype.card I : ℝ)/β))/s) := by
      rw [← Real.exp_add]; congr 1; ring
    _ ≤ Real.exp (-D/s) * (β/Fintype.card I) :=
      mul_le_mul_of_nonneg_left ((Real.exp_le_exp.mpr hscale).trans_eq hid) (Real.exp_pos _).le
    _ ≤ μ.real (⋃ i, E i) * (β/Fintype.card I) :=
      mul_le_mul_of_nonneg_right hmass (by positivity)
    _ ≤ μ.real (E j) := by
      have hh := (le_div_iff₀ hu).mp hj
      simpa only [mul_comm] using hh

include hE hd in
/-- Restore discarded components after bounding the retained component risks.
The risk function is arbitrary; only the full posterior weights enter. -/
theorem weighted_restore [Nonempty I] {β R : ℝ} (hβ : 0 ≤ β) (hR : 0 ≤ R)
    (hpos : 0 < μ.real (⋃ j, E j)) (risk : I → ℝ) (hupper : ∀ j, risk j ≤ 1)
    (hgood : ∀ j, β / Fintype.card I ≤ μ.real (E j) / μ.real (⋃ i, E i) → risk j ≤ R) :
    (∑ j, (μ.real (E j) / μ.real (⋃ i, E i))*risk j) ≤ β+R := by
  classical
  let q := fun j => μ.real (E j) / μ.real (⋃ i, E i)
  have hq (j : I) : 0 ≤ q j := div_nonneg measureReal_nonneg hpos.le
  calc
    _ ≤ ∑ j, ((if q j < β/Fintype.card I then q j else 0) + q j*R) := by
      apply Finset.sum_le_sum
      intro j _
      by_cases hj : q j < β/Fintype.card I
      · simp only [if_pos hj]
        exact (mul_le_mul_of_nonneg_left (hupper j) (hq j)).trans (by nlinarith [hq j])
      · simp only [if_neg hj,zero_add]
        exact mul_le_mul_of_nonneg_left (hgood j (le_of_not_gt hj)) (hq j)
    _ ≤ β+R := by
      rw [Finset.sum_add_distrib,← Finset.sum_mul]
      have hsum := sum_weight μ E hE hd hpos
      change (∑ j, if q j < β/Fintype.card I then q j else 0) + (∑ j,q j)*R ≤ β+R
      change (∑ j,q j) = 1 at hsum
      rw [hsum,one_mul]
      exact add_le_add (small_weight μ E hβ) le_rfl

end NeuralGeneralization.FiniteUnionConditioning
