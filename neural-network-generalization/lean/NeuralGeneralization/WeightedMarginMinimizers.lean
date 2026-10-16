import NeuralGeneralization.GaussianMarginEnergy
import Mathlib.Topology.MetricSpace.ProperSpace
import Mathlib.Topology.Order.Compact

/-! Attainment and strict/closed boundary equivalence for finite positive
weighted quadratic energies with linear margin constraints. -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.WeightedMarginMinimizers
open GaussianMarginGeometry
variable {I J : Type*} [Fintype I]

def closedLinearMargin (P : J → I → ℝ) (a : ℝ) : Set (I → ℝ) :=
  {z | ∀ j, a ≤ ∑ i, P j i * z i}

@[fun_prop] theorem continuous_featureEnergy (w : I → ℝ) : Continuous (featureEnergy w) := by
  unfold featureEnergy
  fun_prop

theorem isClosed_closedLinearMargin (P : J → I → ℝ) (a : ℝ) :
    IsClosed (closedLinearMargin P a) := by
  have he : closedLinearMargin P a = ⋂ j, {z | a ≤ ∑ i, P j i * z i} := by
    ext z
    simp only [closedLinearMargin, Set.mem_setOf_eq, Set.mem_iInter]
  rw [he]
  exact isClosed_iInter (fun j => isClosed_le continuous_const (by fun_prop))

/-- Positive weighted quadratic energies have compact sublevel sets. -/
theorem isCompact_energy_sublevel (w : I → ℝ) (hw : ∀ i, 0 < w i) (b : ℝ) :
    IsCompact {z : I → ℝ | featureEnergy w z ≤ b} := by
  classical
  by_cases hb : 0 ≤ b
  · have hset : IsClosed {z : I → ℝ | featureEnergy w z ≤ b} :=
      isClosed_le (continuous_featureEnergy w) continuous_const
    apply (isCompact_closedBall (0 : I → ℝ) (Real.sqrt ((∑ i, w i) * b))).of_isClosed_subset hset
    intro z hz
    rw [Metric.mem_closedBall, dist_zero_right]
    apply (pi_norm_le_iff_of_nonneg (Real.sqrt_nonneg _)).mpr
    intro i
    have hi : z i ^ 2 / w i ≤ featureEnergy w z :=
      Finset.single_le_sum (fun j _ => div_nonneg (sq_nonneg _) (hw j).le) (Finset.mem_univ i)
    have hsq : z i ^ 2 ≤ w i * b := by
      have hh := (div_le_iff₀ (hw i)).mp (hi.trans hz)
      simpa only [mul_comm] using hh
    have hwle : w i ≤ ∑ j, w j :=
      Finset.single_le_sum (fun j _ => (hw j).le) (Finset.mem_univ i)
    have hsq' := hsq.trans (mul_le_mul_of_nonneg_right hwle hb)
    have hnonneg : 0 ≤ (∑ i, w i) * b :=
      mul_nonneg (Finset.sum_nonneg fun i _ => (hw i).le) hb
    rw [Real.norm_eq_abs]
    nlinarith [Real.sq_sqrt hnonneg, Real.sqrt_nonneg ((∑ i, w i) * b),
      sq_abs (z i), abs_nonneg (z i)]
  · have he : {z : I → ℝ | featureEnergy w z ≤ b} = ∅ := by
      ext z
      simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
      exact not_le.mpr ((lt_of_not_ge hb).trans_le (featureEnergy_nonneg w z (fun i => (hw i).le)))
    rw [he]
    exact isCompact_empty

theorem exists_closed_margin_minimizer (w : I → ℝ) (hw : ∀ i, 0 < w i)
    (P : J → I → ℝ) (a : ℝ) (hne : (closedLinearMargin P a).Nonempty) :
    ∃ z ∈ closedLinearMargin P a, ∀ y ∈ closedLinearMargin P a,
      featureEnergy w z ≤ featureEnergy w y := by
  obtain ⟨z₀, hz₀⟩ := hne
  let K := {z : I → ℝ | featureEnergy w z ≤ featureEnergy w z₀} ∩ closedLinearMargin P a
  have hK : IsCompact K := (isCompact_energy_sublevel w hw _).inter_right
    (isClosed_closedLinearMargin P a)
  have hKne : K.Nonempty := ⟨z₀, show featureEnergy w z₀ ≤ featureEnergy w z₀ from le_rfl, hz₀⟩
  obtain ⟨z, hz, hmin⟩ := hK.exists_isMinOn hKne (continuous_featureEnergy w).continuousOn
  refine ⟨z, hz.2, fun y hy => ?_⟩
  by_cases he : featureEnergy w y ≤ featureEnergy w z₀
  · exact hmin ⟨he, hy⟩
  · exact hz.1.trans (le_of_not_ge he)

theorem scale_closed_to_strict (P : J → I → ℝ) {a s : ℝ} (ha : 0 < a) (hs : 1 < s)
    {z : I → ℝ} (hz : z ∈ closedLinearMargin P a) :
    (fun i => s * z i) ∈ linearMargin P a := by
  intro j
  have hid : (∑ i, P j i * (s * z i)) = s * ∑ i, P j i * z i := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  change a < ∑ i, P j i * (s * z i)
  rw [hid]
  have hj := hz j
  nlinarith

/-- The strict margin infimum is exactly the attained closed-margin minimum. -/
theorem strict_inf_eq_minimum (w : I → ℝ) (hw : ∀ i, 0 < w i)
    (P : J → I → ℝ) {a : ℝ} (ha : 0 < a) {z : I → ℝ}
    (hz : z ∈ closedLinearMargin P a)
    (hmin : ∀ y ∈ closedLinearMargin P a, featureEnergy w z ≤ featureEnergy w y) :
    sInf (featureEnergy w '' linearMargin P a) = featureEnergy w z := by
  have hbdd : BddBelow (featureEnergy w '' linearMargin P a) := by
    refine ⟨0, ?_⟩
    rintro _ ⟨y, hy, rfl⟩
    exact featureEnergy_nonneg w y (fun i => (hw i).le)
  have hne : (linearMargin P a).Nonempty :=
    ⟨fun i => 2 * z i, scale_closed_to_strict P ha (by norm_num) hz⟩
  apply le_antisymm
  · let s : ℕ → ℝ := fun n => 1 + 1 / ((n : ℝ) + 1)
    have hs : Tendsto s atTop (𝓝 (1 : ℝ)) := by
      simpa only [add_zero] using (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_add 1
    have hlim : Tendsto (fun n => featureEnergy w (fun i => s n * z i)) atTop
        (𝓝 (featureEnergy w z)) := by
      apply (continuous_featureEnergy w).continuousAt.tendsto.comp
      apply tendsto_pi_nhds.mpr
      intro i
      simpa only [one_mul] using hs.mul_const (z i)
    apply ge_of_tendsto hlim
    apply Eventually.of_forall
    intro n
    apply csInf_le hbdd
    apply Set.mem_image_of_mem
    apply scale_closed_to_strict P ha _ hz
    dsimp [s]
    linarith [show 0 < 1 / ((n : ℝ) + 1) by positivity]
  · apply le_csInf (hne.image (featureEnergy w))
    rintro _ ⟨y, hy, rfl⟩
    exact hmin y (fun j => (hy j).le)

theorem strict_closed_inf_eq (w : I → ℝ) (hw : ∀ i, 0 < w i)
    (P : J → I → ℝ) {a : ℝ} (ha : 0 < a)
    (hne : (closedLinearMargin P a).Nonempty) :
    sInf (featureEnergy w '' linearMargin P a) =
      sInf (featureEnergy w '' closedLinearMargin P a) := by
  obtain ⟨z, hz, hmin⟩ := exists_closed_margin_minimizer w hw P a hne
  rw [strict_inf_eq_minimum w hw P ha hz hmin]
  have hm : IsLeast (featureEnergy w '' closedLinearMargin P a) (featureEnergy w z) :=
    ⟨Set.mem_image_of_mem _ hz, by rintro _ ⟨y, hy, rfl⟩; exact hmin y hy⟩
  exact hm.csInf_eq.symm

end NeuralGeneralization.WeightedMarginMinimizers
