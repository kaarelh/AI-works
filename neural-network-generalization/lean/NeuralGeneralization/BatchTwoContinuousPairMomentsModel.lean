import NeuralGeneralization.BatchTwoContinuousFiniteQueryModel
import NeuralGeneralization.BatchTwoActivationFullNetworkEventsLaw
import NeuralGeneralization.GaussianReadout

/-! Actual paired-input observables and independent Gaussian row laws. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open NetworkLayerSplit TowerNetwork

variable {d N r n : ℕ}

def inputDistanceSq (x y : RealInput d) : ℝ := ∑j,(x j-y j)^2

def hiddenDistanceSq (w : Weights d N r) (x y : RealInput d) : ℝ :=
  ∑i,(BatchTwoContinuous.finalHidden Real.tanh w x i-BatchTwoContinuous.finalHidden Real.tanh w y i)^2

def matrixDifference (c : Fin n→ℝ) (a : Fin N→Fin n→ℝ) : Fin N→ℝ :=
  fun i=>∑j,c j*a i j

theorem measurable_hiddenDistanceSq (x y : RealInput d) :
    Measurable (fun w : Weights d N r=>hiddenDistanceSq w x y) := by
  apply Finset.measurable_sum
  intro i _
  exact (((continuous_finalHidden_joint tanh_continuous i).comp
    (continuous_id.prodMk continuous_const)).measurable.sub
    ((continuous_finalHidden_joint tanh_continuous i).comp
    (continuous_id.prodMk continuous_const)).measurable).pow_const 2

theorem hiddenDistanceSq_nonneg (w : Weights d N r) (x y : RealInput d) :
    0≤hiddenDistanceSq w x y := Finset.sum_nonneg (fun _ _=>sq_nonneg _)

theorem inputDistanceSq_nonneg (x y : RealInput d) : 0 ≤ inputDistanceSq x y :=
  Finset.sum_nonneg (fun _ _=>sq_nonneg _)

theorem augmentedInput_distance_sq (x y : RealInput d) :
    (∑j,(augmentedInput x j-augmentedInput y j)^2)=inputDistanceSq x y := by
  simp [augmentedInput,Fin.sum_univ_succ,inputDistanceSq]

@[fun_prop] theorem measurable_matrixDifference (c : Fin n→ℝ) :
    Measurable (matrixDifference (N:=N) c) := by
  unfold matrixDifference
  fun_prop

theorem matrixDifference_law (c : Fin n→ℝ) (v : ℝ≥0) :
    (iidSamples (Measure.pi fun _ : Fin n=>gaussianReal 0 v) N).map (matrixDifference c)=
      Measure.pi (fun _ : Fin N=>gaussianReal 0 (((v:ℝ)*(∑j,c j^2)).toNNReal)) := by
  change (Measure.pi (fun _ : Fin N=>Measure.pi fun _ : Fin n=>gaussianReal 0 v)).map
    (fun a i=>∑j,c j*a i j)=_
  rw [Measure.pi_map_pi (f:=fun (_ : Fin N) (a : Fin n→ℝ)=>∑j,c j*a j) (fun _=>(show Measurable (fun a : Fin n→ℝ=>∑j,c j*a j) by fun_prop).aemeasurable)]
  simp only [GaussianReadout.scalar_linear_law]

theorem gaussianCurry_law (a n : ℕ) (v : ℝ≥0) :
    (Measure.pi (fun _ : Fin a×Fin n=>gaussianReal 0 v)).map (fun z i j=>z (i,j))=
      iidSamples (Measure.pi fun _ : Fin n=>gaussianReal 0 v) a := by
  have hp:=LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin a) (_ : Fin n)=>gaussianReal 0 v)
  exact (MeasurePreserving.symm (MeasurableEquiv.curry (Fin a) (Fin n) ℝ).symm hp).map_eq

theorem tanh_pair_sq_le (a b : ℝ) : (Real.tanh a-Real.tanh b)^2≤(a-b)^2 := by
  have hh:=tanh_admissible.2 a b
  simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg _) hh 2

theorem finalHidden_append (w : Weights d N r) (a : Fin N→Fin N→ℝ) (x : RealInput d) :
    BatchTwoContinuous.finalHidden Real.tanh (appendLayer w a) x=
      fun i=>Real.tanh (∑j,a i j*BatchTwoContinuous.finalHidden Real.tanh w x j) := by
  funext i
  let xs : Cube 0→RealInput d := fun _=>x
  have hh:=FiniteQuery.finalHidden_lastRows xs (appendLayer w a) (fun _=>false) i
  simpa only [FiniteQuery.lastRows,previousWeights_appendLayer,lastMatrix_appendLayer] using hh

theorem hiddenDistanceSq_append_le (w : Weights d N r) (a : Fin N→Fin N→ℝ) (x y : RealInput d) :
    hiddenDistanceSq (appendLayer w a) x y≤
      ∑i,(matrixDifference (fun j=>BatchTwoContinuous.finalHidden Real.tanh w x j-
        BatchTwoContinuous.finalHidden Real.tanh w y j) a i)^2 := by
  unfold hiddenDistanceSq
  simp only [finalHidden_append]
  apply Finset.sum_le_sum
  intro i _
  have hh:=tanh_pair_sq_le (∑j,a i j*BatchTwoContinuous.finalHidden Real.tanh w x j)
    (∑j,a i j*BatchTwoContinuous.finalHidden Real.tanh w y j)
  convert hh using 1
  congr 1
  simp only [matrixDifference,mul_sub,sub_mul,Finset.sum_sub_distrib]
  simp only [mul_comm]

end NeuralGeneralization.BatchTwoContinuous.PairMoments
