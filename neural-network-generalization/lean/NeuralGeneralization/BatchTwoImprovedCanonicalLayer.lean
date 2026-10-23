import NeuralGeneralization.BatchTwoImprovedReconstruction
import NeuralGeneralization.RobustCompressionCanonicalLayer
import NeuralGeneralization.RobustCompressionInductionSelected

/-! The actual sharp canonical hidden-layer transition.  It reads a finite
query message and the active projection of the current weight block, then
uses the input-independent importance-weighted Gaussian reconstruction. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionCanonicalLayer
open RobustGaussianGeometry RobustCompression BatchTwoImprovedWeightedSampling Classical
variable {d N m s q r M : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

def sharpCanonicalInput
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (t : ℝ)
    (z : CanonicalLayerInput d N m s q I) : SharpReconstructionInput N N q :=
  ((fun j k => sourceRows (canonicalBasis b z) j k),
    fun i => t • toLp 2 (evaluations (gramSchmidtNormed ℝ (canonicalBasis b z))
      (internalRows N z.1.2 i)))

theorem measurable_sharpCanonicalInput
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) (t : ℝ) :
    Measurable (sharpCanonicalInput (q:=q) b t) := by
  have h := measurable_canonicalReconstructionInput (q:=q) b hb t
  apply Measurable.prodMk
  · apply measurable_pi_lambda
    intro j
    exact (WithLp.measurable_ofLp 2 (Fin q → ℝ)).comp ((measurable_pi_apply j).comp h.fst)
  · exact h.snd

def sharpCanonicalSuccess
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (z : CanonicalLayerInput d N m s q I) (draw : (Fin m → Fin N) × (Fin N → Fin m → ℝ)) : Bool :=
  decide (z.2 ≠ none ∧ ¬sourceBad (canonicalBasis b z) draw.1)

theorem measurable_sharpCanonicalSuccess
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b) :
    Measurable (fun z : CanonicalLayerInput d N m s q I ×
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) => sharpCanonicalSuccess b z.1 z.2) := by
  have hm : Measurable (fun z : CanonicalLayerInput d N m s q I ×
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) => (canonicalBasis b z.1,z.2.1)) :=
    ((measurable_canonicalBasis b hb).comp measurable_fst).prodMk (by fun_prop)
  have hbad := measurable_sourceBad.preimage hm
  have hsome : MeasurableSet {z : CanonicalLayerInput d N m s q I ×
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) | z.1.2 ≠ none} :=
    (measurableSet_eq_fun (by fun_prop) measurable_const).compl
  have h : Measurable (fun z : CanonicalLayerInput d N m s q I ×
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) =>
      if z.1.2 ≠ none ∧ ¬sourceBad (canonicalBasis b z.1) z.2.1 then true else false) :=
    Measurable.ite (hsome.inter hbad.compl) measurable_const measurable_const
  convert h using 1
  funext z
  simp only [sharpCanonicalSuccess]
  split_ifs <;> simp_all

def sharpCanonicalDrawKernel (hN : 0 < N) (hq : 0 < q)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (t BH BG : ℝ) : Kernel (CanonicalLayerInput d N m s q I)
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) :=
  (sharpReconstructionKernel hN hq t BH BG).comap
    (sharpCanonicalInput b t) (measurable_sharpCanonicalInput b hb t)

instance sharpCanonicalDrawKernel_markov (hN : 0 < N) (hq : 0 < q)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (t BH BG : ℝ) : IsMarkovKernel (sharpCanonicalDrawKernel (q:=q) hN hq b hb t BH BG) := by
  unfold sharpCanonicalDrawKernel
  infer_instance

def sharpCanonicalLayerKernel (hN : 0 < N) (hq : 0 < q)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (t BH BG : ℝ) : Kernel (CanonicalLayerInput d N m s q I) (ActivePrefix d N m (s+1)) :=
  parameterMap (sharpCanonicalDrawKernel hN hq b hb t BH BG)
    (fun z => stepActive z.1.1.1 z.2 (sharpCanonicalSuccess b z.1 z.2))
    (measurable_stepActive _ _ _ (by fun_prop) (by fun_prop) (measurable_sharpCanonicalSuccess b hb))

instance sharpCanonicalLayerKernel_markov (hN : 0 < N) (hq : 0 < q)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (t BH BG : ℝ) : IsMarkovKernel (sharpCanonicalLayerKernel (q:=q) hN hq b hb t BH BG) := by
  unfold sharpCanonicalLayerKernel
  infer_instance

section Selected
variable [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)] [MeasurableSingletonClass (QueryMessage (Fin M) q)]

def sharpSelectedTransition (hq : 0 < q)
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (t BH BG : ℝ)
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J) :
    CanonicalTransition d N m (QueryMessage (Fin M) q) s r where
  message := selectedMessageKernel J hJ
  message_markov := inferInstance
  reconstruct := sharpCanonicalLayerKernel (Nat.pos_of_neZero N) hq b hb t BH BG
  reconstruct_markov := inferInstance

end Selected
end NeuralGeneralization.BatchTwoImprovedCanonicalLayer
