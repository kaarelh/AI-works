import NeuralGeneralization.BatchTwoContinuousDepthStepInterpolation
import NeuralGeneralization.BatchTwoContinuousDepthMemorizer

/-! The paper's bounded step interpolator as a literal finite-width network,
with separate first-layer and readout energy estimates. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

def stepWeights {d m : ℕ} (a : ℝ) (u : Fin d → ℝ) (c : Fin m → ℝ)
    (t : Fin (m+1) → ℝ) : Weights d (m+1) 0
  | Sum.inl (i,j) => Fin.cases
      (Fin.cases railConstant (fun _ => 0))
      (fun k => Fin.cases (-a*c k) (fun l => a*u l)) i j
  | Sum.inr (Sum.inl (z,_)) => Fin.elim0 z
  | Sum.inr (Sum.inr i) => Fin.cases (t 0+t (Fin.last m))
      (fun k => (t k.succ-t k.castSucc)/2) i

theorem stepWeights_firstHidden_zero {d m : ℕ} (a : ℝ) (u : Fin d → ℝ)
    (c : Fin m → ℝ) (t : Fin (m+1) → ℝ) (x : RealInput d) :
    BatchTwoContinuous.firstHidden Real.tanh (stepWeights a u c t) x 0 = 1/2 := by
  simp [BatchTwoContinuous.firstHidden,stepWeights,Fin.sum_univ_succ,augmentedInput,tanh_railConstant]

theorem stepWeights_firstHidden_succ {d m : ℕ} (a : ℝ) (u : Fin d → ℝ)
    (c : Fin m → ℝ) (t : Fin (m+1) → ℝ) (x : RealInput d) (k : Fin m) :
    BatchTwoContinuous.firstHidden Real.tanh (stepWeights a u c t) x k.succ =
      thresholdProfile a c (∑ j,u j*x j) k := by
  simp only [BatchTwoContinuous.firstHidden,stepWeights,Fin.cases_succ,Fin.sum_univ_succ,
    augmentedInput,Fin.cases_zero,mul_one,thresholdProfile]
  congr 1
  rw [mul_sub,Finset.mul_sum]
  simp_rw [mul_assoc]
  ring

theorem stepWeights_output {d m : ℕ} (a : ℝ) (u : Fin d → ℝ)
    (c : Fin m → ℝ) (t : Fin (m+1) → ℝ) (x : RealInput d) :
    output Real.tanh (stepWeights a u c t) x =
      stepCombination (thresholdProfile a c (∑ j,u j*x j)) t := by
  unfold output BatchTwoContinuous.finalHidden
  simp only [List.finRange_zero,List.foldl_nil,Fin.sum_univ_succ,
    stepWeights_firstHidden_zero,stepWeights_firstHidden_succ,stepWeights,
    Fin.cases_zero,Fin.cases_succ,stepCombination]
  ring

theorem stepWeights_first_squared {d m : ℕ} (a : ℝ) (u : Fin d → ℝ)
    (c : Fin m → ℝ) (t : Fin (m+1) → ℝ)
    (hu : ∑ j,u j^2 ≤ 1) (hc : ∀ k, |c k| ≤ 1) {R : ℝ}
    (hR : 2 ≤ R) (ha : |a| ≤ R) :
    (∑ i,∑ j,(stepWeights a u c t (Sum.inl (i,j)))^2) ≤ 3*((m+1 : ℕ) : ℝ)*R^2 := by
  simp only [Fin.sum_univ_succ,stepWeights,Fin.cases_zero,Fin.cases_succ,zero_pow (by omega : 2≠0),
    Finset.sum_const_zero,add_zero,neg_mul,neg_sq,mul_pow]
  have hrail : railConstant^2 ≤ 1 := by
    nlinarith [railConstant_bounds.1,railConstant_bounds.2]
  have ha2 : a^2 ≤ R^2 := by
    simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg a) ha 2
  have hrow (k : Fin m) : a^2*c k^2+(∑ j,a^2*u j^2) ≤ 2*R^2 := by
    rw [← Finset.mul_sum]
    have hc2 : c k^2 ≤ 1 := (sq_le_one_iff_abs_le_one _).mpr (hc k)
    have h1 := mul_le_mul_of_nonneg_left hc2 (sq_nonneg a)
    have h2 := mul_le_mul_of_nonneg_left hu (sq_nonneg a)
    nlinarith
  have hsum := Finset.sum_le_sum (s:=Finset.univ) (fun k _ => hrow k)
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] at hsum
  push_cast
  nlinarith [sq_nonneg R]

theorem stepWeights_readout_squared {d m : ℕ} (a : ℝ) (u : Fin d → ℝ)
    (c : Fin m → ℝ) (t : Fin (m+1) → ℝ) (ht : ∀ i, |t i| ≤ 1) :
    (∑ i,(stepWeights a u c t (Sum.inr (Sum.inr i)))^2) ≤ 4*((m+1 : ℕ) : ℝ) := by
  simp only [Fin.sum_univ_succ,stepWeights,Fin.cases_zero,Fin.cases_succ]
  have h0 : |t 0+t (Fin.last m)| ≤ 2 := (abs_add_le _ _).trans (by linarith [ht 0,ht (Fin.last m)])
  have h02 : (t 0+t (Fin.last m))^2 ≤ 4 := by
    simpa only [sq_abs,show (2 : ℝ)^2=4 by norm_num] using pow_le_pow_left₀ (abs_nonneg _) h0 2
  have hrow (k : Fin m) : ((t k.succ-t k.castSucc)/2)^2 ≤ 1 := by
    have h : |(t k.succ-t k.castSucc)/2| ≤ 1 := by
      rw [abs_div,abs_of_pos (by norm_num : (0 : ℝ)<2)]
      apply (div_le_iff₀ (by norm_num : (0 : ℝ)<2)).mpr
      exact (abs_sub _ _).trans (by linarith [ht k.succ,ht k.castSucc])
    exact (sq_le_one_iff_abs_le_one _).mpr h
  have hsum := Finset.sum_le_sum (s:=Finset.univ) (fun k _ => hrow k)
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one] at hsum
  push_cast
  nlinarith

/-- Padding the exact shallow interpolator preserves its function, with the
paper's first-layer budget one and readout budget T=4Mn. -/
theorem exists_padded_step_network {d m M : ℕ} (hM : m+1 ≤ M)
    (a : ℝ) (u : Fin d → ℝ) (c : Fin m → ℝ) (t : Fin (m+1) → ℝ)
    (hu : ∑ j,u j^2 ≤ 1) (hc : ∀ k, |c k| ≤ 1) (ht : ∀ i, |t i| ≤ 1)
    {R : ℝ} (hR : 2 ≤ R) (ha : |a| ≤ R)
    (hwidth : 3*(d : ℝ)*((m+1 : ℕ) : ℝ)*R^2 ≤ M) :
    ∃ w : Weights d M 0,
      (∀ x, output Real.tanh w x = stepCombination (thresholdProfile a c (∑ j,u j*x j)) t) ∧
      (d : ℝ)/M*(∑ i,∑ j,(w (Sum.inl (i,j)))^2) ≤ 1 ∧
      (M : ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2) ≤ 4*(M : ℝ)*((m+1 : ℕ) : ℝ) := by
  classical
  have hMp : 0 < M := by omega
  have hMR : (0 : ℝ) < M := by exact_mod_cast hMp
  let e : ((Fin (m+1) × Fin 1) ⊕ Fin (M-(m+1))) ≃ Fin M := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin,mul_one]
    omega)
  let v := stepWeights a u c t
  refine ⟨clonedWeights e v,?_,?_,?_⟩
  · intro x
    rw [output_clonedWeights (by norm_num),stepWeights_output]
  · rw [first_squaredSum_cloned]
    norm_num only [Nat.cast_one,one_mul]
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hMR).mpr
    have h := mul_le_mul_of_nonneg_left (stepWeights_first_squared a u c t hu hc hR ha)
      (Nat.cast_nonneg d (α:=ℝ))
    dsimp [v]
    nlinarith
  · rw [readout_squaredSum_cloned (by norm_num)]
    norm_num only [Nat.cast_one,div_one]
    have h := mul_le_mul_of_nonneg_left (stepWeights_readout_squared a u c t ht) hMR.le
    simpa only [v,mul_left_comm,mul_assoc] using h

end NeuralGeneralization.BatchTwoContinuousDepthPaper
