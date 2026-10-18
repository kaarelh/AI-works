import NeuralGeneralization.RobustCompressionReconstruction
import NeuralGeneralization.RobustCompressionLayerGaussian

/-! # Exact source-index factorization of the canonical reconstruction law

First sample the source indices. Conditional on those indices, draw the literal
independent residual coefficient rows and clip them. Integrating the source
indices recovers exactly the canonical reconstruction kernel. This is an
identity of full coefficient laws, independent of any test input.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionReconstruction
open RobustCompression RobustCompressionClipping RobustCompressionRows
open RobustGaussianGeometry RobustCompressionGaussian RobustCompressionLayerGaussian
open CompressionSampling
set_option maxHeartbeats 300000

variable {N m q : ℕ}

abbrev FixedSourceInput (N m q : ℕ) :=
  ReconstructionInput N q × (Fin m → Fin N)

def fixedSourceMatrix (a T : ℝ) (p : FixedSourceInput N m q) : Fin m → Fin q → ℝ :=
  sampledMatrix p.1.1 p.2 a T

theorem measurable_fixedSourceMatrix (a T : ℝ) :
    Measurable (fixedSourceMatrix (N := N) (m := m) (q := q) a T) := by
  have hm : Measurable (fun p : FixedSourceInput N m q => (p.1.1,p.2)) := by fun_prop
  have h := (measurable_sampledMatrix (N := N) (m := m) (q := q) a T).comp hm
  unfold fixedSourceMatrix
  convert h using 1
  rfl

def fixedSourceRowsDraw (a t T BH BG : ℝ) (p : FixedSourceInput N m q)
    (ξ : Fin N → Fin m → ℝ) : Fin N → Fin m → ℝ :=
  fun i => reconstructedRow (wholeClip BH (p.1.2 i))
    (fun j => wholeClip T (p.1.1 j)) p.2 a t (fun j => gaussianClip BG (ξ i j))

theorem measurable_fixedSourceRowsDraw (a t T BH BG : ℝ) :
    Measurable (fun p : FixedSourceInput N m q × (Fin N → Fin m → ℝ) =>
      fixedSourceRowsDraw a t T BH BG p.1 p.2) := by
  apply measurable_pi_lambda
  intro i
  apply measurable_pi_lambda
  intro j
  have hH : Measurable (fun p : FixedSourceInput N m q × (Fin N → Fin m → ℝ) =>
      wholeClip BH (p.1.1.2 i)) :=
    (measurable_wholeClip (E := EuclideanSpace ℝ (Fin q)) BH).comp (by fun_prop)
  have hc : Measurable (fun p : FixedSourceInput N m q × (Fin N → Fin m → ℝ) =>
      wholeClip T (p.1.1.1 (p.1.2 j))) :=
    (measurable_wholeClip (E := EuclideanSpace ℝ (Fin q)) T).comp
      (measurable_finite_select _ _ (by fun_prop) (by fun_prop))
  change Measurable (fun p : FixedSourceInput N m q × (Fin N → Fin m → ℝ) =>
    ⟪wholeClip BH (p.1.1.2 i), wholeClip T (p.1.1.1 (p.1.2 j))⟫ /
      ((m : ℝ)*Real.sqrt (1+a)) +
        t*gaussianClip BG (p.2 i j)/Real.sqrt (m : ℝ))
  exact ((continuous_inner.measurable.comp (hH.prodMk hc)).div_const _) |>.add
    (((measurable_gaussianClip BG).comp (by fun_prop)).const_mul t |>.div_const _)

/-- Conditional coefficient-row law with the sampled source indices fixed. -/
def fixedSourceRowKernel (a t T BH BG : ℝ) :
    Kernel (FixedSourceInput N m q) (Fin N → Fin m → ℝ) :=
  parameterMap (residualRowsKernel (fixedSourceMatrix a T) (measurable_fixedSourceMatrix a T))
    (fun p => fixedSourceRowsDraw a t T BH BG p.1 p.2)
    (measurable_fixedSourceRowsDraw a t T BH BG)

instance fixedSourceRowKernel_markov (a t T BH BG : ℝ) :
    IsMarkovKernel (fixedSourceRowKernel (N := N) (m := m) (q := q) a t T BH BG) := by
  unfold fixedSourceRowKernel
  infer_instance

theorem fixedSourceRowKernel_apply (a t T BH BG : ℝ) (p : FixedSourceInput N m q) :
    fixedSourceRowKernel a t T BH BG p =
      (Measure.pi (fun _ : Fin N => sourceResidualKernel (fixedSourceMatrix a T p))).map
        (fixedSourceRowsDraw a t T BH BG p) := by
  rw [fixedSourceRowKernel,parameterMap_apply,residualRowsKernel_apply]

/-- Direct standard-Gaussian sampling form, retaining the exact CFC factor. -/
theorem fixedSourceRowKernel_standard (a t T BH BG : ℝ) (p : FixedSourceInput N m q) :
    fixedSourceRowKernel a t T BH BG p =
      (Measure.pi (fun _ : Fin N => Measure.pi (fun _ : Fin m => gaussianReal 0 1))).map
        (fun g => fixedSourceRowsDraw a t T BH BG p
          (fun i => residualDraw (residualCovariance (fixedSourceMatrix a T p)) (g i))) := by
  have hf : Measurable (fixedSourceRowsDraw a t T BH BG p) := by
    have hp : Measurable (fun ξ : Fin N → Fin m → ℝ => (p,ξ)) := by fun_prop
    have hh := (measurable_fixedSourceRowsDraw (N := N) (m := m) (q := q) a t T BH BG).comp hp
    convert hh using 1
    rfl
  have hg : Measurable (fun g : Fin N → Fin m → ℝ =>
      fun i => residualDraw (residualCovariance (fixedSourceMatrix a T p)) (g i)) := by
    apply measurable_pi_lambda
    intro i
    exact measurable_residualDraw.comp (measurable_const.prodMk (measurable_pi_apply i))
  rw [fixedSourceRowKernel,parameterMap_apply,residualRowsKernel,
    parameterMap_apply,Kernel.const_apply,Measure.map_map hf hg]
  rfl

/-- Literal disintegration over the source-index sample. -/
theorem reconstructionKernel_factor [NeZero N] (a t T BH BG : ℝ)
    (p : ReconstructionInput N q) :
    reconstructionKernel (m := m) a t T BH BG p =
      iidSamples (uniformIndexLaw N) m ⊗ₘ
        (fixedSourceRowKernel a t T BH BG).comap
          (fun I : Fin m → Fin N => (p,I)) measurable_prodMk_left := by
  have hdraw : Measurable (reconstructionDraw (m := m) a t T BH BG p) :=
    (measurable_reconstructionDraw (N := N) (m := m) (q := q) a t T BH BG).comp
      (measurable_const.prodMk measurable_id)
  ext s hs
  rw [reconstructionKernel_apply,Measure.map_apply hdraw hs,
    reconstructionRandomLaw,Measure.prod_apply (hdraw hs),Measure.compProd_apply hs]
  apply lintegral_congr
  intro I
  rw [Kernel.comap_apply,fixedSourceRowKernel_standard]
  have hg : Measurable (fun g : Fin N → Fin m → ℝ =>
      fixedSourceRowsDraw a t T BH BG (p,I)
        (fun i => residualDraw (residualCovariance (fixedSourceMatrix a T (p,I))) (g i))) := by
    have hm : Measurable (fun g : Fin N → Fin m → ℝ => (I,g)) := by fun_prop
    have h : Measurable (fun g : Fin N → Fin m → ℝ =>
        (reconstructionDraw a t T BH BG p (I,g)).2) := measurable_snd.comp (hdraw.comp hm)
    convert h using 1
    rfl
  rw [Measure.map_apply hg (hs.preimage measurable_prodMk_left)]
  rfl

end NeuralGeneralization.RobustCompressionReconstruction
