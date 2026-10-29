import PhysicalScaleRegimes
import PhysicalGainProducts
noncomputable section
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def uniformLogGainCoefficient (C : ℝ) : ℝ :=
  (2*C+1)+526336+2*lastExitLinearConstant*(3158019+2*(2*C+1))

/-- Actual long-regime path amplification is logarithmic in the common
resource budget. All scale-dependent cost corrections remain explicit. -/
theorem physicalPathLogGain_logarithmic {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {C T : ℝ} (hC : 0≤C) (hT : 1≤T)
    (hlog : Real.log ((H:ℝ)+1)≤T)
    (hlong : T≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ))
    (hnear : P.action≤H*subcriticalCostBaseline (physicalVariance P)+scalarBaseline.toReal+
      C*(((physicalVariance P:ℝ)⁻¹-1)*T+T^2/H)) :
    (∑j∈Finset.range H,physicalPathLogGain P j)≤uniformLogGainCoefficient C*T := by
  let a := (physicalVariance P:ℝ)⁻¹-1
  have hHr : (0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
  have ha : 0<a := by dsimp [a]; nlinarith
  have hε : physicalActionExcess P/a≤(2*C+1)*T :=
    long_scale_excess hHr ha hT hC hlong hnear
  let J := Nat.log2 (H+1)+1
  have hreach : 1≤(2:ℝ)^J*a := long_scale_dyadic_reach hH ha.le hT hlong
  have hJ : (J:ℝ)≤3*T := by
    have hh := log2_successor_bound H
    dsimp [J]
    linarith
  have hb := physicalPathLogGain_bound P hd hH J (physicalActionExcess_nonneg P)
    ha hreach (physical_adjusted_action_excess P hd)
  have hlinear := mul_le_mul_of_nonneg_left
    (show 1052673*(J:ℝ)+2*physicalActionExcess P/a≤
      (3158019+2*(2*C+1))*T by rw [mul_div_assoc]; nlinarith)
    (show 0≤2*lastExitLinearConstant by exact mul_nonneg (by norm_num) lastExitLinearConstant_nonneg)
  have hconst : (526336:ℝ)≤526336*T := by nlinarith
  unfold uniformLogGainCoefficient
  dsimp [a] at *
  nlinarith

/-- The actual complete amplification product has a polynomial upper bound
when T is logarithmic in the resource parameter. -/
theorem physicalGainProduct_logarithmic {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {C T : ℝ} (hC : 0≤C) (hT : 1≤T)
    (hlog : Real.log ((H:ℝ)+1)≤T)
    (hlong : T≤((physicalVariance P:ℝ)⁻¹-1)*(H:ℝ))
    (hnear : P.action≤H*subcriticalCostBaseline (physicalVariance P)+scalarBaseline.toReal+
      C*(((physicalVariance P:ℝ)⁻¹-1)*T+T^2/H)) :
    physicalGainProduct P H≤Real.exp (uniformLogGainCoefficient C*T) := by
  rw [physicalGainProduct_exp]
  exact Real.exp_le_exp.mpr (physicalPathLogGain_logarithmic P hd hH hC hT hlog hlong hnear)

#print axioms physicalPathLogGain_logarithmic
#print axioms physicalGainProduct_logarithmic
end ConditionalNonpolynomial.Analytic
