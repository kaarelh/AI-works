import GainDominatedCanonical
import PhysicalNormalizedLayer

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped ENNReal BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I J A : Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype A]
namespace CanonicalLayerModel
variable {anchors : A→EuclideanSpace ℝ I} {D : ℝ}

def gainCanonical (M : CanonicalLayerModel (J:=J) anchors D) (S : ℝ) (u : EuclideanSpace ℝ I) :
    EuclideanSpace ℝ (CanonicalIndex M.law M.finiteKL anchors) :=
  canonicalVector (actualCanonicalSpan M.law M.finiteKL anchors)
    (normalizedTanhL2 M.law S (Real.sqrt (gaussianEntropyGain D)) u)

lemma gainValue_eq_output (M : CanonicalLayerModel (J:=J) anchors D)
    {S : ℝ} (hS : 0<S) (u : EuclideanSpace ℝ I) :
    M.gainValue S u=M.output (M.gainCanonical S u) := by
  unfold gainCanonical normalizedTanhL2
  rw [canonicalVector_smul_nonneg _ _ (inv_nonneg.mpr (mul_pos hS (entropyRoot_pos D)).le),map_smul]
  rfl

lemma gainResidual_eq_sub (M : CanonicalLayerModel (J:=J) anchors D)
    {S : ℝ} (hS : 0<S) (u : EuclideanSpace ℝ I) :
    M.gainResidual S u=M.output (M.gainCanonical S u)-M.gainLinear u := by
  have hh := M.gain_decomposition hS.ne' u
  rw [M.gainValue_eq_output hS] at hh
  exact (eq_sub_iff_add_eq).mpr (by simpa only [add_comm] using hh.symm)

#print axioms gainResidual_eq_sub
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
