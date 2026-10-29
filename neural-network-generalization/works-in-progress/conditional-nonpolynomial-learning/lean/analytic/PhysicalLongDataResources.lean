import PhysicalLongClassifierResources
import PhysicalLongPrefixData
import ThresholdResourceConversion

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

/-- Uniform constants; none depends on the target, width, physical scale,
input dimension, learner depth or sample. -/
def longDataNonlinearCoefficient (C K : ℝ) : ℝ :=448*longPrefixPicardCoefficient C K

def longDataCoverExponent (K : ℝ) : ℕ :=
  ⌈2*((K+1)*Real.log ((longCoverCardFactor:ℝ)+1)/64)⌉₊

def longDataCircuitExponent (C K : ℝ) (a : ℕ) : ℕ :=
  naturalCircuitResourceExponent
    (longClassifierSizeExponent (longDataNonlinearCoefficient C K) a (longDataCoverExponent K))
    (longClassifierDepthCoefficient (longDataNonlinearCoefficient C K) a)

lemma longDataCircuitExponent_one (C K : ℝ) (a : ℕ) : 1≤longDataCircuitExponent C K a :=
  naturalCircuitResourceExponent_one _ _

lemma longDataNonlinearCoefficient_nonneg {C K : ℝ} (hC : 0≤C) (hK : 0≤K) :
    0≤longDataNonlinearCoefficient C K := by
  unfold longDataNonlinearCoefficient longPrefixPicardCoefficient
  positivity [physicalPrefixOccupationConstant_pos]

namespace LongPrefixData
variable {d H J R : ℕ} {t C K : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f}

/-- The actual long-prefix data construct a polynomial-size, logarithmic-depth
threshold circuit. This result includes all finite arithmetic compiler
resources and the representative-distance classifier. -/
theorem circuit_resources (D : LongPrefixData P J K (2*Real.log (R:ℝ)) C)
    (hd : 1≤d) (hR : 2≤R) (hC : 0≤C) (hK : 0≤K) (a : ℕ) (ha : 1≤a)
    (hH : (H:ℝ)+1≤(R:ℝ)^a) (hdR : (d:ℝ)+1≤(R:ℝ)^a)
    (hr : ‖P.readout‖≤(R:ℝ)^a) (hG : physicalGainProduct P H≤(R:ℝ)^a) :
    D.classifier.size≤R^(longDataCircuitExponent C K a) ∧
      D.classifier.depth≤longDataCircuitExponent C K a*Nat.log2 R := by
  have hRr:(2:ℝ)≤R:=by exact_mod_cast hR
  have hR0:(0:ℝ)<R:=by linarith
  have hlog:0≤Real.log (R:ℝ):=Real.log_nonneg (by linarith)
  have hCpic:=longDataNonlinearCoefficient_nonneg hC hK
  have hbudget:D.dynamics.nonlinearBudget≤longDataNonlinearCoefficient C K*(1+Real.log (R:ℝ)):=by
    have hh:=D.budget
    unfold longDataNonlinearCoefficient at *
    nlinarith only [hh,hCpic]
  have hcenter:(D.representatives.card:ℝ)≤(R:ℝ)^(longDataCoverExponent K):=by
    apply D.representativeCard.trans
    have he:Real.exp ((longDataCoverExponent K:ℝ)*Real.log (R:ℝ))=(R:ℝ)^(longDataCoverExponent K):=by
      rw [Real.exp_nat_mul,Real.exp_log hR0]
    rw [←he]
    apply Real.exp_le_exp.mpr
    have hn:=Nat.le_ceil (2*((K+1)*Real.log ((longCoverCardFactor:ℝ)+1)/64))
    have hm:=mul_le_mul_of_nonneg_right hn hlog
    change _≤(⌈2*((K+1)*Real.log ((longCoverCardFactor:ℝ)+1)/64)⌉₊:ℝ)*Real.log (R:ℝ)
    nlinarith only [hm]
  have hh:=D.dynamics.representativeClassifier_resources
    (GainPrefixDynamics.initial_norm_from_gram hd D.initial) D.inputMap D.inputNorm
    hRr hCpic a (longDataCoverExponent K) ha hH hdR hr hG
    D.anchorBound D.dimensionBound (fun j=>D.floorBound j) hbudget D.representatives hcenter
  have hdepth:0≤longClassifierDepthCoefficient (longDataNonlinearCoefficient C K) a:=by
    have he:=longEvaluationLogCoefficient_nonneg hCpic (a*11)
    unfold longClassifierDepthCoefficient
    positivity
  exact natural_circuit_resource_bounds_uniform _ hdepth hR hh.1 hh.2

#print axioms circuit_resources
end LongPrefixData
end ConditionalNonpolynomial.Analytic.PhysicalLong
