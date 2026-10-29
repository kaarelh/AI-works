import PhysicalEntropySplitCompression
import PhysicalCanonicalPolar

/-! Named actual model witnesses extracted from the entropy-split canonical
construction, retaining both the exact recursion and both entropy charges. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
variable {P : ControlledMarginPath d H t f} {S : Finset (Cube d)}
variable {j : ℕ} {B C : CanonicalProgramState d}

def PhysicalEntropySplitStep.model (h : PhysicalEntropySplitStep P S j B C) :
    CanonicalLayerModel (J:=C.Index) (fun s:S=>t • B.feature s) (physicalLayerCost P j) :=
  Classical.choose h.2

lemma PhysicalEntropySplitStep.model_nongaussian (h : PhysicalEntropySplitStep P S j B C) :
    letI := Classical.decEq B.Index
    h.model.nongaussianCost≤physicalAdjustedCost P j := (Classical.choose_spec h.2).1

lemma PhysicalEntropySplitStep.model_recursion (h : PhysicalEntropySplitStep P S j B C)
    (x : Cube d) : C.feature x=h.model.value (t • B.feature x) := (Classical.choose_spec h.2).2 x

lemma PhysicalEntropySplitStep.model_gaussian (h : PhysicalEntropySplitStep P S j B C) :
    letI := Classical.decEq B.Index
    gaussianCovarianceCost h.model.law≤physicalLayerCost P j := by
  classical
  exact (gaussianCovarianceCost_le_kl h.model.law h.model.finiteKL).trans h.model.cost_le

#print axioms PhysicalEntropySplitStep.model_nongaussian
#print axioms PhysicalEntropySplitStep.model_recursion
end ConditionalNonpolynomial.Analytic
