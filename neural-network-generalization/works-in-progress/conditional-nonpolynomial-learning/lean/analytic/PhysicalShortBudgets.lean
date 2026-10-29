import CanonicalLayerModel
import PhysicalMarginOccupation
import PhysicalRawLayerBounds
import CanonicalProgramBudgets

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

def canonicalEntropySum {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : ℝ :=
  ∑j∈Finset.range H,Real.sqrt (2*physicalLayerCost P j)

def canonicalRadius {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) (j : ℕ) : ℝ :=
  Real.sqrt (maxFeatureVariance (P.feature j))+η

lemma canonicalRadius_pos {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) {η : ℝ} (hη : 0<η) (j : ℕ) :
    0<canonicalRadius P η j := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hη

lemma query_norm_le_canonicalRadius {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) (j : ℕ)
    (B : CanonicalProgramState d) (S : Finset (Cube d)) (x : Cube d)
    (h : QueryFeatureClose (P.feature j) B.feature S x η) :
    ‖B.feature x‖≤canonicalRadius P η j := by
  apply h.norm_le.trans
  change ‖P.feature j x‖+η≤Real.sqrt (maxFeatureVariance (P.feature j))+η
  exact add_le_add ((Real.le_sqrt (norm_nonneg _) (maxFeatureVariance_nonneg _)).mpr
    (feature_variance_le_max _ x)) le_rfl

lemma canonicalRadius_square_le {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) (j : ℕ) :
    (canonicalRadius P η j)^2≤2*maxFeatureVariance (P.feature j)+2*η^2 := by
  have hs := Real.sq_sqrt (maxFeatureVariance_nonneg (P.feature j))
  have hd := sq_nonneg (Real.sqrt (maxFeatureVariance (P.feature j))-η)
  unfold canonicalRadius
  nlinarith

lemma canonicalRadius_sum_square_le {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) :
    (∑j:Fin H,(canonicalRadius P η j)^2)≤
      2*(∑j:Fin H,maxFeatureVariance (P.feature j))+2*(H:ℝ)*η^2 := by
  have hh := Finset.sum_le_sum (fun j (_:j∈(Finset.univ : Finset (Fin H))) =>
    canonicalRadius_square_le P η j)
  simpa only [Finset.sum_add_distrib,← Finset.mul_sum,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_assoc,mul_left_comm] using hh

def canonicalNonlinearBudget {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) : ℝ :=
  ∑j:Fin H,224*((canonicalRadius P η j)^2+Real.sqrt (physicalLayerCost P j))

theorem canonicalNonlinearBudget_le {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (η : ℝ) :
    canonicalNonlinearBudget P η≤
      448*(∑j:Fin H,maxFeatureVariance (P.feature j))+448*(H:ℝ)*η^2+
      224*(∑j:Fin H,Real.sqrt (physicalLayerCost P j)) := by
  have hh := canonicalRadius_sum_square_le P η
  unfold canonicalNonlinearBudget
  rw [← Finset.mul_sum,Finset.sum_add_distrib]
  nlinarith

lemma criticalEntropySum_le {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) :
    canonicalEntropySum P≤2*(∑j:Fin H,Real.sqrt (physicalLayerCost P j)) := by
  have hp (j : Fin H) : Real.sqrt (2*physicalLayerCost P j)≤2*Real.sqrt (physicalLayerCost P j) := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · have hD : 0≤physicalLayerCost P j := ENNReal.toReal_nonneg
      have hs := Real.sq_sqrt hD
      nlinarith
  have hh := Finset.sum_le_sum (fun j (_:j∈(Finset.univ : Finset (Fin H))) => hp j)
  rw [← Finset.mul_sum] at hh
  have hs := Fin.sum_univ_eq_sum_range (fun j => Real.sqrt (2*physicalLayerCost P j)) H
  rw [hs] at hh
  exact hh

theorem critical_canonical_budget_bounds {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hH : 1≤H)
    {ε η : ℝ} (hε : 0≤ε) (hnear : P.action≤scalarBaseline.toReal+ε) :
    canonicalEntropySum P≤2*criticalEntropyBudget H ε ∧
    canonicalNonlinearBudget P η≤448*criticalVarianceBudget H ε+
      448*(H:ℝ)*η^2+224*criticalEntropyBudget H ε := by
  obtain ⟨hent,hvar⟩ := physicalMarginPath_occupation P hd hH hε hnear
  constructor
  · exact (criticalEntropySum_le P).trans (mul_le_mul_of_nonneg_left hent (by norm_num))
  · apply (canonicalNonlinearBudget_le P η).trans
    nlinarith

#print axioms critical_canonical_budget_bounds
end ConditionalNonpolynomial.Analytic.PhysicalShort
