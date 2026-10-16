import NeuralGeneralization.SharpNeuralTailGram
import NeuralGeneralization.AdaptiveBinomialBudget

/-! The sampled tail Gram estimate in exactly the adaptive cutoff normalization. -/
noncomputable section
namespace NeuralGeneralization.AdaptiveCutoff
open RandomRestriction

def adaptiveGramConstant (A U : ℝ) : ℝ :=
  gramConstant*(U+Real.sqrt (2*A*U)+2*A*U)

lemma adaptiveGramConstant_nonneg {A U : ℝ} (hA : 0≤A) (hU : 0≤U) :
    0≤adaptiveGramConstant A U := by
  unfold adaptiveGramConstant
  exact mul_nonneg gramConstant_pos.le (by positivity)

lemma gram_bound_of_adaptive_scalars {n d L A U T r K tau ell s2 G : ℝ}
    (hd : 0≤d) (hL : 0≤L) (hA : 0≤A) (hU : 0≤U) (hT : 0≤T)
    (hr : 0<r) (hK : 0<K) (hn : 0≤n)
    (hnext : n≤2*A*L*K) (htau : tau≤U*T)
    (hell : ell≤U*T/(r*K)) (hs : s2≤U*T^2/(r^2*K))
    (hG : G≤gramConstant*(tau+Real.sqrt (n*d*s2)+n*ell)) :
    G≤adaptiveGramConstant A U*T*(1+Real.sqrt (d*L)/r+L/r) := by
  have he := sampled_eigenvalue_budget hL hA hU hT hr hK hn hnext hell
  have hsqrt := sampled_second_moment_budget hd hL hA hU hT hr hK hn hnext hs
  have hpre : tau+Real.sqrt (n*d*s2)+n*ell≤
      U*T+Real.sqrt (2*A*U)*T*(Real.sqrt (d*L)/r)+(2*A*U)*T*(L/r) := by
    calc
      _ ≤ U*T+Real.sqrt (2*A*U)*T*Real.sqrt (d*L)/r+2*A*U*L*T/r :=
        add_le_add (add_le_add htau hsqrt) he
      _ = _ := by ring
  let C := U+Real.sqrt (2*A*U)+2*A*U
  have hC0 : 0≤C := by dsimp [C]; positivity
  have hCU : U≤C := by
    have := Real.sqrt_nonneg (2*A*U)
    have : 0≤2*A*U := by positivity
    dsimp [C]
    linarith
  have hCS : Real.sqrt (2*A*U)≤C := by
    have : 0≤2*A*U := by positivity
    dsimp [C]
    linarith
  have hCA : 2*A*U≤C := by
    have := Real.sqrt_nonneg (2*A*U)
    dsimp [C]
    linarith
  have h₁ := mul_le_mul_of_nonneg_right hCU hT
  have h₂ := mul_le_mul_of_nonneg_right hCS (show 0≤T*(Real.sqrt (d*L)/r) by positivity)
  have h₃ := mul_le_mul_of_nonneg_right hCA (show 0≤T*(L/r) by positivity)
  have hsum : tau+Real.sqrt (n*d*s2)+n*ell≤C*T*(1+Real.sqrt (d*L)/r+L/r) := by
    nlinarith only [hpre,h₁,h₂,h₃]
  apply hG.trans
  have hh := mul_le_mul_of_nonneg_left hsum gramConstant_pos.le
  unfold adaptiveGramConstant
  change _≤(gramConstant*C)*T*(1+Real.sqrt (d*L)/r+L/r)
  nlinarith only [hh]

end NeuralGeneralization.AdaptiveCutoff
