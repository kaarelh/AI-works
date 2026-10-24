import NeuralGeneralization.BatchTwoRelativeGrowthGhost
import NeuralGeneralization.SquaredProcessIncrements

/-! Exact pair-swap bound for a fixed Boolean membership pattern. The fixed
Chernoff parameter 2/5 cancels the pattern's variance proxy against its total
number of positive positions. No without-replacement concentration theorem is
assumed. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoRelativeGrowth
open SquaredSampling CompressionSampling

def patternCount {n : ℕ} (a : Fin n → Bool) : ℝ := ∑ i, hit id (a i)

def patternBad {n : ℕ} (u : ℝ) (p : (Fin n → Bool) × (Fin n → Bool)) : Prop :=
  (3 : ℝ)/2*patternCount p.1+(3 : ℝ)/4*n*u < patternCount p.2

theorem pattern_sum_swap {n : ℕ} (p : (Fin n → Bool) × (Fin n → Bool)) (ε : Fin n → Bool) :
    patternCount (signSwap ε p).1 + patternCount (signSwap ε p).2 =
      patternCount p.1+patternCount p.2 := by
  unfold patternCount
  rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  cases he : ε i <;> simp [signSwap, he, add_comm]

theorem pattern_difference_swap {n : ℕ}
    (p : (Fin n → Bool) × (Fin n → Bool)) (ε : Fin n → Bool) :
    patternCount (signSwap ε p).2-patternCount (signSwap ε p).1 =
      ∑ i, cubeCoordinateSign (ε i)*(hit id (p.2 i)-hit id (p.1 i)) := by
  unfold patternCount
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  cases he : ε i <;> simp [signSwap, he, cubeCoordinateSign] <;> ring

theorem pattern_variance_le {n : ℕ} (p : (Fin n → Bool) × (Fin n → Bool)) :
    (∑ i, (hit id (p.2 i)-hit id (p.1 i))^2) ≤ patternCount p.1+patternCount p.2 := by
  unfold patternCount
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  cases hp : p.1 i <;> cases hq : p.2 i <;> norm_num [hit, hp, hq]

/-- The exact constant needed for relative growth-function symmetrization. -/
theorem pattern_swap_tail {n : ℕ} (p : (Fin n → Bool) × (Fin n → Bool)) (u : ℝ) :
    finiteMean (fun ε : Fin n → Bool => if patternBad u (signSwap ε p) then (1 : ℝ) else 0) ≤
      Real.exp (-(6 : ℝ)/25*n*u) := by
  let S := patternCount p.1+patternCount p.2
  let a := fun i => hit id (p.2 i)-hit id (p.1 i)
  let b := -(2 : ℝ)/25*S-(6 : ℝ)/25*n*u
  have hpoint (ε : Fin n → Bool) :
      (if patternBad u (signSwap ε p) then (1 : ℝ) else 0) ≤
        Real.exp b*Real.exp ((2 : ℝ)/5*∑ i, cubeCoordinateSign (ε i)*a i) := by
    rw [← Real.exp_add]
    by_cases hbad : patternBad u (signSwap ε p)
    · rw [if_pos hbad]
      apply Real.one_le_exp_iff.mpr
      have hs := pattern_sum_swap p ε
      have hd := pattern_difference_swap p ε
      change (3 : ℝ)/2*patternCount (signSwap ε p).1+(3 : ℝ)/4*n*u <
        patternCount (signSwap ε p).2 at hbad
      dsimp [b,S,a]
      rw [← hd]
      nlinarith
    · rw [if_neg hbad]
      exact (Real.exp_pos _).le
  have hm := finiteMean_mono hpoint
  rw [finiteMean_mul] at hm
  have hmgf := finite_rademacher_mgf_le n a ((2 : ℝ)/5)
  have hvar : (∑ i, (a i)^2) ≤ S := pattern_variance_le p
  calc
    _ ≤ Real.exp b*finiteMean (fun ε : Fin n → Bool =>
        Real.exp ((2 : ℝ)/5*∑ i, cubeCoordinateSign (ε i)*a i)) := hm
    _ ≤ Real.exp b*Real.exp (((2 : ℝ)/5)^2*(∑ i, (a i)^2)/2) :=
      mul_le_mul_of_nonneg_left hmgf (Real.exp_pos _).le
    _ ≤ _ := by
      rw [← Real.exp_add]
      apply Real.exp_le_exp.mpr
      dsimp [b]
      nlinarith

variable {X : Type*} [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]

theorem paired_iid_singleton (D : Measure X) [IsProbabilityMeasure D] {n : ℕ}
    (p : (Fin n → X) × (Fin n → X)) :
    ((iidSamples D n).prod (iidSamples D n)).real {p} =
      (∏ i, D.real {p.1 i})*(∏ i, D.real {p.2 i}) := by
  rw [show ({p} : Set ((Fin n → X) × (Fin n → X))) = {p.1} ×ˢ {p.2} by ext q; simp [Prod.ext_iff],
    measureReal_prod_prod]
  simp only [Measure.real, iidSamples, Measure.pi_singleton, ENNReal.toReal_prod]

theorem paired_iid_swap_singleton (D : Measure X) [IsProbabilityMeasure D] {n : ℕ}
    (p : (Fin n → X) × (Fin n → X)) (ε : Fin n → Bool) :
    ((iidSamples D n).prod (iidSamples D n)).real {signSwap ε p} =
      ((iidSamples D n).prod (iidSamples D n)).real {p} := by
  rw [paired_iid_singleton, paired_iid_singleton, ← Finset.prod_mul_distrib,
    ← Finset.prod_mul_distrib]
  apply Finset.prod_congr rfl
  intro i _
  cases he : ε i <;> simp [signSwap, he, mul_comm]

theorem paired_iid_integral_swap (D : Measure X) [IsProbabilityMeasure D] {n : ℕ}
    (F : ((Fin n → X) × (Fin n → X)) → ℝ) (ε : Fin n → Bool) :
    (∫ p, F (signSwap ε p) ∂(iidSamples D n).prod (iidSamples D n)) =
      ∫ p, F p ∂(iidSamples D n).prod (iidSamples D n) := by
  rw [integral_fintype (RobustStatistics.integrable_finite_domain _ _),
    integral_fintype (RobustStatistics.integrable_finite_domain _ _)]
  simp only [smul_eq_mul]
  have he (p : (Fin n → X) × (Fin n → X)) :
      ((iidSamples D n).prod (iidSamples D n)).real {p}*F (signSwap ε p) =
      (fun q => ((iidSamples D n).prod (iidSamples D n)).real {q}*F q) (signSwap ε p) := by
    dsimp only
    rw [paired_iid_swap_singleton]
  simp_rw [he]
  exact (signSwap ε).sum_comp (fun p => ((iidSamples D n).prod (iidSamples D n)).real {p}*F p)

end NeuralGeneralization.BatchTwoRelativeGrowth
