import NeuralGeneralization.BatchTwoShallowResources
import NeuralGeneralization.BatchTwoShallowMain

/-! Literal quadratic and quartic width consequences, with explicit constants. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel

def widthCostCoefficient (d : ℕ) (s V : ℝ) : ℝ :=
  (d : ℝ)*(d+1)+2*s^2*V^2+((d : ℝ)+2)*
    (2*Real.exp 1*Real.sqrt (2*Real.pi))*(1+s*V*(d+1)/Real.sqrt d)

theorem widthCostCoefficient_nonneg {d : ℕ} {s V : ℝ} (hs : 0 ≤ s) (hV : 0 ≤ V) :
    0 ≤ widthCostCoefficient d s V := by unfold widthCostCoefficient; positivity

theorem targetCost_quadratic {d C : ℕ} (hC : 0 < C) {s V : ℝ}
    (hs : 0 ≤ s) (hV : 0 ≤ V) (w : Weights d C 0)
    (hw : ∀ i j, |w (Sum.inl (i,j))| ≤ (C : ℝ))
    (hv : ∀ i, |w (Sum.inr (Sum.inr i))| ≤ V) :
    targetCost s w ≤ widthCostCoefficient d s V*(C : ℝ)^2 := by
  have h := targetCost_le_width_resources hs hV w hw hv
  have hC1 : (1 : ℝ) ≤ C := by exact_mod_cast hC
  have hC2 : (C : ℝ) ≤ (C : ℝ)^2 := by nlinarith
  have hC20 : (1 : ℝ) ≤ (C : ℝ)^2 := by nlinarith
  let a := s*V*((d : ℝ)+1)/Real.sqrt d
  let b := 2*Real.exp 1*Real.sqrt (2*Real.pi)
  have ha : 0 ≤ a := by dsimp [a]; positivity
  have hb : 0 ≤ b := by dsimp [b]; positivity
  have he : 2*Real.exp 1*Real.sqrt (2*Real.pi)*(1+s*C*V*(d+1)/Real.sqrt d)=b*(1+a*C) := by
    dsimp [a,b]; ring
  rw [he] at h
  have hl := Real.log_le_self (show 0 ≤ b*(1+a*C) by positivity)
  have hh : b*(1+a*C) ≤ b*(1+a)*(C : ℝ)^2 := by nlinarith [mul_le_mul_of_nonneg_left hC2 ha]
  have hm := mul_le_mul_of_nonneg_left (hl.trans hh) (show 0 ≤ (d : ℝ)+2 by positivity)
  unfold widthCostCoefficient
  change targetCost s w ≤ ((d : ℝ)*(d+1)+2*s^2*V^2+((d : ℝ)+2)*b*(1+a))*(C : ℝ)^2
  nlinarith

theorem targetCost_quartic {d C : ℕ} (hC : 0 < C) {s : ℝ}
    (hs : 0 ≤ s) (w : Weights d C 0) (hw : boundedWeights C w) :
    targetCost s w ≤ widthCostCoefficient d s 1*(C : ℝ)^4 := by
  have h := targetCost_le_width_resources hs (Nat.cast_nonneg C) w
    (fun i j => hw (Sum.inl (i,j))) (fun i => hw (Sum.inr (Sum.inr i)))
  have hC1 : (1 : ℝ) ≤ C := by exact_mod_cast hC
  have hC20 : (1 : ℝ) ≤ (C : ℝ)^2 := by nlinarith
  have hC24 : (C : ℝ)^2 ≤ (C : ℝ)^4 := by nlinarith [sq_nonneg ((C : ℝ)^2-1)]
  let a := s*((d : ℝ)+1)/Real.sqrt d
  let b := 2*Real.exp 1*Real.sqrt (2*Real.pi)
  have ha : 0 ≤ a := by dsimp [a]; positivity
  have hb : 0 ≤ b := by dsimp [b]; positivity
  have he : 2*Real.exp 1*Real.sqrt (2*Real.pi)*(1+s*C*C*(d+1)/Real.sqrt d)=b*(1+a*(C : ℝ)^2) := by
    dsimp [a,b]; ring
  rw [he] at h
  have hl := Real.log_le_self (show 0 ≤ b*(1+a*(C : ℝ)^2) by positivity)
  have hh : b*(1+a*(C : ℝ)^2) ≤ b*(1+a)*(C : ℝ)^4 := by
    have hC40 : (1 : ℝ) ≤ (C : ℝ)^4 := hC20.trans hC24
    nlinarith [mul_le_mul_of_nonneg_left hC24 ha]
  have hm := mul_le_mul_of_nonneg_left (hl.trans hh) (show 0 ≤ (d : ℝ)+2 by positivity)
  have hf := mul_le_mul_of_nonneg_left hC24 (show 0 ≤ (d : ℝ)*(d+1) by positivity)
  unfold widthCostCoefficient
  simp only [mul_one, one_pow]
  change targetCost s w ≤ ((d : ℝ)*(d+1)+2*s^2+((d : ℝ)+2)*b*(1+a))*(C : ℝ)^4
  nlinarith

def widthSampleCoefficient (d : ℕ) (A ε δ : ℝ) : ℝ :=
  16/ε*((4096*(A+Real.log (4/ε))*Real.log (24/ε)+1)*dimensionEntropy d+Real.log (1/δ))

theorem sampleBudget_le_resource_multiple {d C : ℕ} {s ε δ A R : ℝ}
    (hs : 0 ≤ s) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (hA : 0 ≤ A) (hR : 1 ≤ R) (w : Weights d C 0) (hcost : targetCost s w ≤ A*R) :
    sampleBudget s ε δ w ≤ widthSampleCoefficient d A ε δ*R := by
  have hl4 : 0 ≤ Real.log (4/ε) := Real.log_nonneg ((le_div_iff₀ hε).mpr (by linarith))
  have hl24 : 0 ≤ Real.log (24/ε) := Real.log_nonneg ((le_div_iff₀ hε).mpr (by linarith))
  have hlδ : 0 ≤ Real.log (1/δ) := Real.log_nonneg ((one_le_div hδ).mpr hδ1.le)
  have hdim : 0 ≤ dimensionEntropy d := by
    unfold dimensionEntropy
    have := Real.log_nonneg (by norm_num : (1 : ℝ) ≤ 2)
    positivity
  have hB := readoutBound_sq hs hε hε1 w
  have hc := (Nat.ceil_lt_add_one (show 0 ≤ 512*(readoutBound s ε w)^2*Real.log (24/ε) by positivity)).le
  change (voteCount s ε w : ℝ) ≤ 512*(readoutBound s ε w)^2*Real.log (24/ε)+1 at hc
  rw [hB, readoutBoundSq] at hc
  have hcost' : targetCost s w+Real.log (4/ε) ≤ (A+Real.log (4/ε))*R := by nlinarith
  have hv := mul_le_mul_of_nonneg_right hcost' hl24
  have hm : (voteCount s ε w : ℝ) ≤ (4096*(A+Real.log (4/ε))*Real.log (24/ε)+1)*R := by nlinarith
  have hmul := mul_le_mul_of_nonneg_right hm hdim
  have hδmul : Real.log (1/δ) ≤ Real.log (1/δ)*R := by nlinarith
  unfold sampleBudget widthSampleCoefficient
  have h := mul_le_mul_of_nonneg_left (add_le_add hmul hδmul) (show 0 ≤ 16/ε by positivity)
  calc
    _ ≤ 16/ε*((4096*(A+Real.log (4/ε))*Real.log (24/ε)+1)*R*dimensionEntropy d+
        Real.log (1/δ)*R) := h
    _ = _ := by ring

theorem quadratic_width_sample_bound {d C : ℕ} (hC : 0 < C) {s V ε δ : ℝ}
    (hs : 0 ≤ s) (hV : 0 ≤ V) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (w : Weights d C 0) (hw : ∀ i j, |w (Sum.inl (i,j))| ≤ (C : ℝ))
    (hv : ∀ i, |w (Sum.inr (Sum.inr i))| ≤ V) :
    sampleBudget s ε δ w ≤ widthSampleCoefficient d (widthCostCoefficient d s V) ε δ*(C : ℝ)^2 := by
  apply sampleBudget_le_resource_multiple hs hε hε1 hδ hδ1 (widthCostCoefficient_nonneg hs hV)
    (by
      have h : (1 : ℝ) ≤ C := by exact_mod_cast hC
      nlinarith) w
  exact targetCost_quadratic hC hs hV w hw hv

theorem quartic_width_sample_bound {d C : ℕ} (hC : 0 < C) {s ε δ : ℝ}
    (hs : 0 ≤ s) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (w : Weights d C 0) (hw : boundedWeights C w) :
    sampleBudget s ε δ w ≤ widthSampleCoefficient d (widthCostCoefficient d s 1) ε δ*(C : ℝ)^4 := by
  apply sampleBudget_le_resource_multiple hs hε hε1 hδ hδ1 (widthCostCoefficient_nonneg hs (by norm_num))
    (by
      have h : (1 : ℝ) ≤ C := by exact_mod_cast hC
      nlinarith [sq_nonneg ((C : ℝ)^2-1)]) w
  exact targetCost_quartic hC hs w hw

end NeuralGeneralization.BatchTwoShallow
