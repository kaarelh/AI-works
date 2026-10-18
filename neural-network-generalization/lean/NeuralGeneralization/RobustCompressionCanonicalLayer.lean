import NeuralGeneralization.RobustCompressionActiveBank
import NeuralGeneralization.RobustCompressionReconstructionFactor
import NeuralGeneralization.RobustCompressionInductionQueries
import NeuralGeneralization.RobustCompressionInductionRows
import NeuralGeneralization.RobustCompressionInductionBounds
import NeuralGeneralization.RobustCompressionMessageBasis

/-! # The actual input-independent canonical hidden-layer update

The finite query message and original current block determine active
coordinates. A fresh source bank and Gaussian innovations produce literal
bounded coefficient rows. Rank and source-bank failure set the absorbing
abort flag. The kernel has no argument for the test input or remaining future.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionReconstruction
open RobustGaussianGeometry RobustCompressionSourceBank RobustCompression

variable {d N m s q : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

abbrev CanonicalLayerInput (d N m s q : ℕ) (I : Type*) :=
  (ActivePrefix d N m s × InternalBlock N) × QueryMessage I q

def canonicalBasis (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (z : CanonicalLayerInput d N m s q I) : Fin q → EuclideanSpace ℝ (Fin N) :=
  basisFromQueryMessage b (z.1.1,z.2)

theorem measurable_canonicalBasis
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) :
    Measurable (canonicalBasis (q := q) b) :=
  (measurable_basisFromQueryMessage b hb).comp (by fun_prop)

def canonicalReconstructionInput
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (z : CanonicalLayerInput d N m s q I) : ReconstructionInput N q :=
  (sourceRows (canonicalBasis b z),fun i => t • toLp 2
    (evaluations (gramSchmidtNormed ℝ (canonicalBasis b z)) (internalRows N z.1.2 i)))

theorem measurable_canonicalReconstructionInput
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) (t : ℝ) :
    Measurable (canonicalReconstructionInput (q := q) b t) := by
  apply Measurable.prodMk
  · exact measurable_sourceRows.comp (measurable_canonicalBasis b hb)
  · apply measurable_pi_lambda
    intro i
    exact (((WithLp.measurable_toLp 2 (Fin q → ℝ)).comp
      (measurable_active_coordinates.comp ((measurable_canonicalBasis b hb).prodMk
        (((measurable_pi_apply i).comp (measurable_internalRows N)).comp (by fun_prop))))).const_smul t)

/-- The update keeps exactly the literal source-bank test, including all cube
inputs. It does not replace a failed covariance by a different candidate law. -/
def canonicalLayerSuccess (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (a T : ℝ)
    (z : CanonicalLayerInput d N m s q I) (draw : ReconstructionOutput N m) : Bool :=
  by
    classical
    exact decide (z.2 ≠ none ∧ sourceBankGood (sourceRows (canonicalBasis b z))
      (activeHidden φ z.1.1) a T draw.1)

theorem measurable_canonicalLayerSuccess {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a T : ℝ) : Measurable (fun z : CanonicalLayerInput d N m s q I × ReconstructionOutput N m =>
      canonicalLayerSuccess φ b a T z.1 z.2) := by
  have hbank : Measurable (fun z : CanonicalLayerInput d N m s q I × ReconstructionOutput N m =>
      ((sourceRows (canonicalBasis b z.1),activeHidden φ z.1.1.1),z.2.1)) := by
    refine ((measurable_sourceRows.comp ((measurable_canonicalBasis b hb).comp measurable_fst)).prodMk ?_).prodMk (by fun_prop)
    apply measurable_pi_lambda
    intro x
    exact (measurable_activeHidden hφ x).comp (by fun_prop)
  have hgood := (measurableSet_sourceBankGood (N:=N) (m:=m) (q:=q) (X:=Cube d) a T).preimage hbank
  have hsome : MeasurableSet {z : CanonicalLayerInput d N m s q I × ReconstructionOutput N m | z.1.2 ≠ none} :=
    (measurableSet_eq_fun (by fun_prop) measurable_const).compl
  classical
  have hh : Measurable (fun z : CanonicalLayerInput d N m s q I × ReconstructionOutput N m =>
      if z.1.2 ≠ none ∧ sourceBankGood (sourceRows (canonicalBasis b z.1))
          (activeHidden φ z.1.1.1) a T z.2.1 then true else false) :=
    Measurable.ite (hsome.inter hgood) measurable_const measurable_const
  convert hh using 1
  funext z
  simp only [canonicalLayerSuccess]
  split_ifs <;> simp_all


/-- Actual reconstruction law, retaining source indices before the state is
updated. It ignores the remaining unprocessed weights. -/
def canonicalDrawKernel [NeZero N]
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ) : Kernel (CanonicalLayerInput d N m s q I) (ReconstructionOutput N m) :=
  (reconstructionKernel a t T BH BG).comap (canonicalReconstructionInput b t)
    (measurable_canonicalReconstructionInput b hb t)

instance canonicalDrawKernel_markov [NeZero N]
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ) : IsMarkovKernel (canonicalDrawKernel (q := q) b hb a t T BH BG) := by
  unfold canonicalDrawKernel
  infer_instance

/-- The literal Markov kernel used as the `reconstruct` argument of the
canonical depth recursion. -/
def canonicalLayerKernel [NeZero N] {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ) :
    Kernel (CanonicalLayerInput d N m s q I) (ActivePrefix d N m (s+1)) :=
  parameterMap (canonicalDrawKernel b hb a t T BH BG)
    (fun z => stepActive z.1.1.1 z.2 (canonicalLayerSuccess φ b a T z.1 z.2))
    (measurable_stepActive _ _ _ (by fun_prop) (by fun_prop)
      (measurable_canonicalLayerSuccess hφ b hb a T))

instance canonicalLayerKernel_markov [NeZero N] {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ) : IsMarkovKernel (canonicalLayerKernel (q := q) hφ b hb a t T BH BG) := by
  unfold canonicalLayerKernel
  infer_instance

end NeuralGeneralization.RobustCompressionCanonicalLayer
