import ScalarChannelOccupation
import ChannelSlackBudget
import Mathlib.Analysis.SpecialFunctions.Pow.Real

noncomputable section
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem channelEntropyPrefix_le_twice (D : ℕ→ℝ) (H : ℕ) :
    channelEntropyPrefix D H≤2*∑j∈Finset.range H,Real.sqrt (D j) := by
  unfold channelEntropyPrefix
  rw [←Fin.sum_univ_eq_sum_range,Finset.mul_sum]
  apply Finset.sum_le_sum
  intro j _
  rw [Real.sqrt_mul (by norm_num : (0:ℝ)≤2)]
  have hs : Real.sqrt 2≤2 := by rw [Real.sqrt_le_iff]; norm_num
  exact mul_le_mul_of_nonneg_right hs (Real.sqrt_nonneg _)

theorem exp_log_bound_to_power {R S C : ℝ} {p : ℕ}
    (hR : 1≤R) (hS : S≤C*Real.log R) (hp : C≤(p:ℝ)) : Real.exp S≤R^p := by
  have hr : 0<R := lt_of_lt_of_le zero_lt_one hR
  calc
    _ ≤ Real.exp ((p:ℝ)*Real.log R) := Real.exp_le_exp.mpr
      (hS.trans (mul_le_mul_of_nonneg_right hp (Real.log_nonneg hR)))
    _ = R^p := by rw [Real.exp_nat_mul,Real.exp_log hr]

theorem inverse_exp_floor_to_power {R v C : ℝ} {p : ℕ}
    (hR : 1≤R) (hfloor : Real.exp (-C*Real.log R)≤v) (hp : C≤(p:ℝ)) :
    1/v≤R^p := by
  have hv : 0<v := (Real.exp_pos _).trans_le hfloor
  have hh := one_div_le_one_div_of_le (Real.exp_pos _) hfloor
  have he : 1/Real.exp (-C*Real.log R)=Real.exp (C*Real.log R) := by
    rw [show -C*Real.log R= -(C*Real.log R) by ring,Real.exp_neg]
    simp
  rw [he] at hh
  exact hh.trans (exp_log_bound_to_power hR le_rfl hp)

/-- Any finite list of universal logarithmic constants can be absorbed in a
single natural polynomial exponent. -/
theorem exists_common_natural_exponent (C₁ C₂ C₃ C₄ : ℝ) :
    ∃p : ℕ,1≤p ∧ C₁≤p ∧ C₂≤p ∧ C₃≤p ∧ C₄≤p := by
  obtain ⟨p,hp⟩ := exists_nat_ge (max 1 (max C₁ (max C₂ (max C₃ C₄))))
  refine ⟨p,?_,?_,?_,?_,?_⟩
  · have hh : (1:ℝ)≤p := (le_max_left _ _).trans hp
    exact_mod_cast hh
  · exact (le_trans (le_max_left _ _) (le_max_right _ _)).trans hp
  · exact (le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_right _ _)).trans hp
  · exact (le_trans (le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_right _ _))
      (le_max_right _ _)).trans hp
  · exact (le_trans (le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) (le_max_right _ _))
      (le_max_right _ _)).trans hp

#print axioms channelEntropyPrefix_le_twice
#print axioms exp_log_bound_to_power
#print axioms inverse_exp_floor_to_power
end ConditionalNonpolynomial.Analytic
