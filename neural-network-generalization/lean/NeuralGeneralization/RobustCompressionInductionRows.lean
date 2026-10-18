import NeuralGeneralization.RobustCompressionInductionConditional
import NeuralGeneralization.LayerGramConcentration
import NeuralGeneralization.RobustEntropyProjection

/-! # The original standardized block in the active-query row convention -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy

def internalRows (N : ℕ) (z : InternalBlock N) : Fin N → EuclideanSpace ℝ (Fin N) :=
  fun i => WithLp.toLp 2 (fun j => z (i,j))

def flattenRows (N : ℕ) (z : Fin N → EuclideanSpace ℝ (Fin N)) : InternalBlock N :=
  fun ij => z ij.1 ij.2

theorem measurable_internalRows (N : ℕ) : Measurable (internalRows N) := by
  apply measurable_pi_lambda
  intro i
  exact (WithLp.measurable_toLp 2 (Fin N → ℝ)).comp (by fun_prop)

theorem measurable_flattenRows (N : ℕ) : Measurable (flattenRows N) := by
  apply measurable_pi_lambda
  intro ij
  have hv : Measurable (fun z : Fin N → EuclideanSpace ℝ (Fin N) => z ij.1) :=
    measurable_pi_apply ij.1
  exact (EuclideanSpace.proj ij.2).measurable.comp hv

@[simp] theorem flattenRows_internalRows (N : ℕ) (z : InternalBlock N) :
    flattenRows N (internalRows N z)=z := rfl
@[simp] theorem internalRows_flattenRows (N : ℕ) (z : Fin N → EuclideanSpace ℝ (Fin N)) :
    internalRows N (flattenRows N z)=z := rfl

def internalRowsEquiv (N : ℕ) : InternalBlock N ≃ᵐ (Fin N → EuclideanSpace ℝ (Fin N)) where
  toFun := internalRows N
  invFun := flattenRows N
  left_inv := flattenRows_internalRows N
  right_inv := internalRows_flattenRows N
  measurable_toFun := measurable_internalRows N
  measurable_invFun := measurable_flattenRows N

/-- This is exactly the independent Gaussian row law used by the active-query
and conditional residual theorems. -/
theorem internalRows_reference (N : ℕ) :
    (internalBlockPrior N).map (internalRows N) = rowGaussian N N := by
  have hp := LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin N) (_ : Fin N) => gaussianReal 0 1)
  have hc := (MeasurePreserving.symm (MeasurableEquiv.curry (Fin N) (Fin N) ℝ).symm hp).map_eq
  change (internalBlockPrior N).map (MeasurableEquiv.curry (Fin N) (Fin N) ℝ) =
    Measure.pi (fun _ : Fin N => Measure.pi (fun _ : Fin N => gaussianReal 0 1)) at hc
  change (internalBlockPrior N).map
    ((fun z : Fin N → Fin N → ℝ => fun i => WithLp.toLp 2 (z i)) ∘
      (MeasurableEquiv.curry (Fin N) (Fin N) ℝ)) = _
  have hm : Measurable (fun z : Fin N → Fin N → ℝ => fun i => WithLp.toLp 2 (z i)) :=
    measurable_pi_lambda _ (fun i =>
      (WithLp.measurable_toLp 2 (Fin N → ℝ)).comp (measurable_pi_apply i))
  rw [← Measure.map_map hm (MeasurableEquiv.curry (Fin N) (Fin N) ℝ).measurable,hc]
  exact Measure.pi_map_pi (fun _ => (WithLp.measurable_toLp 2 (Fin N → ℝ)).aemeasurable)

variable {A : Type*} [MeasurableSpace A] [StandardBorelSpace A] [Nonempty A]

def splitRowsState (N r : ℕ) : A × FutureWeights N (r+1) →
    A × ((Fin N → EuclideanSpace ℝ (Fin N)) × FutureWeights N r) :=
  fun z => (z.1,internalRows N (splitFuture N r z.2).1,(splitFuture N r z.2).2)

theorem measurable_splitRowsState (N r : ℕ) : Measurable (splitRowsState (A:=A) N r) :=
  measurable_fst.prodMk (((measurable_internalRows N).comp
    ((splitFuture N r).measurable.comp measurable_snd).fst).prodMk
      ((splitFuture N r).measurable.comp measurable_snd).snd)

theorem splitRowsState_reference (N r : ℕ) (ν : Measure A) [SFinite ν] :
    (ν.prod (futurePrior N (r+1))).map (splitRowsState N r) =
      ν.prod ((rowGaussian N N).prod (futurePrior N r)) := by
  have hi : MeasurePreserving (internalRows N) (internalBlockPrior N) (rowGaussian N N) :=
    ⟨measurable_internalRows N,internalRows_reference N⟩
  have hs : MeasurePreserving (splitFuture N r) (futurePrior N (r+1))
      ((internalBlockPrior N).prod (futurePrior N r)) :=
    ⟨(splitFuture N r).measurable,splitFuture_reference N r⟩
  exact ((MeasurePreserving.id ν).prod
    ((hi.prod (MeasurePreserving.id (futurePrior N r))).comp hs)).map_eq

theorem splitRowsState_futureEntropy_le {N r : ℕ}
    (Q : Measure (A × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    futureEntropy (Q.map (splitRowsState N r)) ((rowGaussian N N).prod (futurePrior N r)) ≤
      futureEntropy Q (futurePrior N (r+1)) := by
  letI : IsProbabilityMeasure (Q.map (splitRowsState N r)) :=
    Measure.isProbabilityMeasure_map (measurable_splitRowsState N r).aemeasurable
  have hdata := RobustEntropy.klDiv_map_le Q (Q.fst.prod (futurePrior N (r+1)))
    (measurable_splitRowsState N r)
  rw [splitRowsState_reference] at hdata
  exact (futureEntropy_le_reference (Q.map (splitRowsState N r)) Q.fst
    ((rowGaussian N N).prod (futurePrior N r))).trans hdata

end NeuralGeneralization.RobustCompressionInduction
