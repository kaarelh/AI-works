import NeuralGeneralization.BatchTwoImprovedWhitenedLayer
import NeuralGeneralization.RobustCompressionReconstructionFactor

/-! The sharpened, actual input-independent finite row reconstruction kernel.
The sampled leverage weights and the residual Gaussian law both vary
measurably with the active source bank, including all rank changes. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry RobustCompressionReconstruction
open RobustCompression RobustCompressionClipping RobustCompressionGaussian
open RobustCompressionLayerGaussian Classical
variable {N q m D : ℕ}

abbrev SharpReconstructionInput (N D q : ℕ) :=
  (Fin N → Fin q → ℝ) × (Fin D → EuclideanSpace ℝ (Fin q))
abbrev SharpFixedSource (N D m q : ℕ) := SharpReconstructionInput N D q × (Fin m → Fin N)

def sharpSourceMatrix (z : SharpFixedSource N D m q) : Fin m → Fin q → ℝ :=
  whitenedMatrix (sourceMultiplier z.1.1) z.2 z.1.1

theorem measurable_sharpSampledColumns :
    Measurable (fun z : SharpFixedSource N D m q =>
      sampledColumns (sourceMultiplier z.1.1) z.2 z.1.1) := by
  apply measurable_pi_lambda
  intro k
  apply (WithLp.measurable_toLp 2 (Fin m → ℝ)).comp
  apply measurable_pi_lambda
  intro j
  have ha : Measurable (fun z : SharpFixedSource N D m q => sourceMultiplier z.1.1 (z.2 j)) :=
    measurable_finite_select _ _ (measurable_sourceMultiplier.comp (by fun_prop)) (by fun_prop)
  have hu : Measurable (fun z : SharpFixedSource N D m q => z.1.1 (z.2 j) k) :=
    (measurable_pi_apply k).comp (measurable_finite_select _ _ (by fun_prop) (by fun_prop))
  exact (ha.sqrt.div_const _).mul hu

theorem measurable_sharpSourceMatrix : Measurable (sharpSourceMatrix (N:=N) (D:=D) (m:=m) (q:=q)) := by
  apply measurable_pi_lambda
  intro j
  apply measurable_pi_lambda
  intro k
  exact (EuclideanSpace.proj j).measurable.comp
    ((measurable_gramSchmidtNormed k).comp measurable_sharpSampledColumns)

def sharpSourceRowsDraw (t BH BG : ℝ) (z : SharpFixedSource N D m q)
    (ξ : Fin D → Fin m → ℝ) : Fin D → Fin m → ℝ := fun i j =>
  sourceMultiplier z.1.1 (z.2 j)/(m:ℝ) *
    linearEvaluation (z.1.1 (z.2 j)) (fun k => wholeClip BH (z.1.2 i) k) +
      t/Real.sqrt (m:ℝ)*Real.sqrt (sourceMultiplier z.1.1 (z.2 j))*gaussianClip BG (ξ i j)

theorem measurable_sharpSourceRowsDraw (t BH BG : ℝ) :
    Measurable (fun z : SharpFixedSource N D m q × (Fin D → Fin m → ℝ) =>
      sharpSourceRowsDraw t BH BG z.1 z.2) := by
  apply measurable_pi_lambda
  intro i
  apply measurable_pi_lambda
  intro j
  have ha : Measurable (fun z : SharpFixedSource N D m q × (Fin D → Fin m → ℝ) =>
      sourceMultiplier z.1.1.1 (z.1.2 j)) :=
    measurable_finite_select _ _ (measurable_sourceMultiplier.comp (by fun_prop)) (by fun_prop)
  have hu : Measurable (fun z : SharpFixedSource N D m q × (Fin D → Fin m → ℝ) =>
      z.1.1.1 (z.1.2 j)) := measurable_finite_select _ _ (by fun_prop) (by fun_prop)
  have hH : Measurable (fun z : SharpFixedSource N D m q × (Fin D → Fin m → ℝ) =>
      wholeClip BH (z.1.1.2 i)) := (measurable_wholeClip BH).comp (by fun_prop)
  unfold sharpSourceRowsDraw linearEvaluation
  exact ((ha.div_const _).mul (Finset.measurable_sum _ (fun k _ =>
    ((measurable_pi_apply k).comp hu).mul ((EuclideanSpace.proj k).measurable.comp hH)))).add
      (((ha.sqrt).const_mul _).mul ((measurable_gaussianClip BG).comp (by fun_prop)))

def sharpSourceRowKernel (t BH BG : ℝ) :
    Kernel (SharpFixedSource N D m q) (Fin D → Fin m → ℝ) :=
  parameterMap (residualRowsKernel sharpSourceMatrix measurable_sharpSourceMatrix)
    (fun z => sharpSourceRowsDraw t BH BG z.1 z.2) (measurable_sharpSourceRowsDraw t BH BG)

instance sharpSourceRowKernel_markov (t BH BG : ℝ) :
    IsMarkovKernel (sharpSourceRowKernel (N:=N) (D:=D) (m:=m) (q:=q) t BH BG) := by
  unfold sharpSourceRowKernel
  infer_instance

theorem sharpSourceRowKernel_apply (t BH BG : ℝ) (z : SharpFixedSource N D m q) :
    sharpSourceRowKernel t BH BG z =
      (Measure.pi (fun _ : Fin D => sourceResidualKernel (sharpSourceMatrix z))).map
        (sharpSourceRowsDraw t BH BG z) := by
  rw [sharpSourceRowKernel,parameterMap_apply,residualRowsKernel_apply]

/-- One common full coefficient law, with no test feature in its type. -/
def sharpReconstructionKernel (hN : 0 < N) (hq : 0 < q) (t BH BG : ℝ) :
    Kernel (SharpReconstructionInput N D q) ((Fin m → Fin N) × (Fin D → Fin m → ℝ)) :=
  ((sourceIndicesKernel hN hq m).comap Prod.fst measurable_fst) ⊗ₖ
    sharpSourceRowKernel t BH BG

instance sharpReconstructionKernel_markov (hN : 0 < N) (hq : 0 < q) (t BH BG : ℝ) :
    IsMarkovKernel (sharpReconstructionKernel (D:=D) (m:=m) hN hq t BH BG) := by
  unfold sharpReconstructionKernel
  infer_instance

theorem sharpReconstructionKernel_factor (hN : 0 < N) (hq : 0 < q)
    (t BH BG : ℝ) (z : SharpReconstructionInput N D q) :
    sharpReconstructionKernel (m:=m) hN hq t BH BG z =
      sourceIndicesKernel hN hq m z.1 ⊗ₘ
        (sharpSourceRowKernel t BH BG).comap (fun s => (z,s)) measurable_prodMk_left := by
  ext S hS
  rw [sharpReconstructionKernel,Kernel.compProd_apply hS,Measure.compProd_apply hS,Kernel.comap_apply]
  rfl

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
