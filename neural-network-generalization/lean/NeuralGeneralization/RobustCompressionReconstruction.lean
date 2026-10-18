import NeuralGeneralization.RobustCompressionRows
import NeuralGeneralization.RobustCompressionGaussian

/-! # The actual canonical finite row reconstruction kernel

This kernel draws one finite list of source indices and a full collection of
residual coefficient rows. It is defined without a test input. Its output is
therefore a common random ordinary-network layer for every later pointwise
comparison coupling. All clipping and covariance square roots are measurable.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.RobustCompressionReconstruction
open RobustCompressionClipping RobustCompressionRows RobustGaussianGeometry
open RobustCompressionGaussian CompressionSampling
set_option maxHeartbeats 200000

variable {N m q : ℕ}

abbrev ReconstructionInput (N q : ℕ) :=
  (Fin N → EuclideanSpace ℝ (Fin q)) × (Fin N → EuclideanSpace ℝ (Fin q))
abbrev ReconstructionRandomness (N m : ℕ) :=
  (Fin m → Fin N) × (Fin N → Fin m → ℝ)
abbrev ReconstructionOutput (N m : ℕ) :=
  (Fin m → Fin N) × (Fin N → Fin m → ℝ)

/-- Evaluation at a measurably selected finite index. -/
theorem measurable_finite_select {A E : Type*} [MeasurableSpace A] [MeasurableSpace E]
    (f : A → Fin N → E) (i : A → Fin N) (hf : Measurable f) (hi : Measurable i) :
    Measurable (fun a => f a (i a)) := by
  have h : Measurable (fun p : (Fin N → E) × Fin N => p.1 p.2) :=
    measurable_from_prod_countable_left (fun j => measurable_pi_apply j)
  exact h.comp (hf.prodMk hi)

/-- The sampled active coefficient map. The normalization is the one used in
`normalized_sample_contraction`. -/
def sampledMatrix (c : Fin N → EuclideanSpace ℝ (Fin q))
    (I : Fin m → Fin N) (a T : ℝ) : Fin m → Fin q → ℝ :=
  fun j k => wholeClip T (c (I j)) k / Real.sqrt ((m : ℝ) * (1 + a))

theorem measurable_sampledMatrix (a T : ℝ) :
    Measurable (fun p : (Fin N → EuclideanSpace ℝ (Fin q)) × (Fin m → Fin N) =>
      sampledMatrix p.1 p.2 a T) := by
  apply measurable_pi_lambda
  intro j
  apply measurable_pi_lambda
  intro k
  have hs : Measurable (fun p : (Fin N → EuclideanSpace ℝ (Fin q)) ×
      (Fin m → Fin N) => p.1 (p.2 j)) :=
    measurable_finite_select _ _ measurable_fst ((measurable_pi_apply j).comp measurable_snd)
  have hc := (measurable_wholeClip (E := EuclideanSpace ℝ (Fin q)) T).comp hs
  exact ((EuclideanSpace.proj k).measurable.comp hc).div_const _

theorem measurable_sampledMatrix_input (a T : ℝ) :
    Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      sampledMatrix p.1.1 p.2.1 a T) := by
  apply measurable_pi_lambda
  intro j
  apply measurable_pi_lambda
  intro k
  have hs : Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      p.1.1 (p.2.1 j)) :=
    measurable_finite_select _ _ (by fun_prop) (by fun_prop)
  have hc := (measurable_wholeClip (E := EuclideanSpace ℝ (Fin q)) T).comp hs
  exact ((EuclideanSpace.proj k).measurable.comp hc).div_const _

/-- Explicit random rows, with the active coefficients and all residual
coordinates clipped before they become ordinary network coefficients. -/
def reconstructionDraw (a t T BH BG : ℝ) (p : ReconstructionInput N q)
    (ω : ReconstructionRandomness N m) : ReconstructionOutput N m :=
  (ω.1, fun i => reconstructedRow (wholeClip BH (p.2 i))
    (fun j => wholeClip T (p.1 j)) ω.1 a t
    (fun j => gaussianClip BG
      (residualDraw (residualCovariance (sampledMatrix p.1 ω.1 a T)) (ω.2 i) j)))

theorem measurable_reconstructionDraw (a t T BH BG : ℝ) :
    Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      reconstructionDraw a t T BH BG p.1 p.2) := by
  unfold reconstructionDraw
  apply Measurable.prodMk (by fun_prop)
  apply measurable_pi_lambda
  intro i
  apply measurable_pi_lambda
  intro j
  have hH : Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      wholeClip BH (p.1.2 i)) :=
    (measurable_wholeClip (E := EuclideanSpace ℝ (Fin q)) BH).comp (by fun_prop)
  have hc : Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      wholeClip T (p.1.1 (p.2.1 j))) :=
    (measurable_wholeClip (E := EuclideanSpace ℝ (Fin q)) T).comp
      (measurable_finite_select _ _ (by fun_prop) (by fun_prop))
  have hD : Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      sampledMatrix p.1.1 p.2.1 a T) :=
    measurable_sampledMatrix_input a T
  have hQ : Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      residualCovariance (sampledMatrix p.1.1 p.2.1 a T)) := by
    exact measurable_residualCovariance.comp hD
  have hξ : Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
      residualDraw (residualCovariance (sampledMatrix p.1.1 p.2.1 a T)) (p.2.2 i) j) :=
    (measurable_pi_apply j).comp (measurable_residualDraw.comp (hQ.prodMk (by fun_prop)))
  change Measurable (fun p : ReconstructionInput N q × ReconstructionRandomness N m =>
    ⟪wholeClip BH (p.1.2 i), wholeClip T (p.1.1 (p.2.1 j))⟫ /
      ((m : ℝ) * Real.sqrt (1 + a)) +
      t * gaussianClip BG
        (residualDraw (residualCovariance (sampledMatrix p.1.1 p.2.1 a T)) (p.2.2 i) j) /
          Real.sqrt (m : ℝ))
  exact (continuous_inner.measurable.comp (hH.prodMk hc)).div_const _ |>.add
    (((measurable_gaussianClip BG).comp hξ).const_mul t |>.div_const _)

/-- Every generated coefficient is bounded, including on bad source samples.
Thus the eventual finite parameter grid is fixed before any test point is chosen. -/
theorem reconstructionDraw_bound {a t T BH BG : ℝ}
    (ha : 0 ≤ a) (ht : |t| ≤ 1) (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG)
    (p : ReconstructionInput N q) (ω : ReconstructionRandomness N m)
    (i : Fin N) (j : Fin m) :
    |(reconstructionDraw a t T BH BG p ω).2 i j| ≤
      BH * T / (m : ℝ) + BG / Real.sqrt (m : ℝ) := by
  apply reconstructedRow_bound _ _ _ ha ht (wholeClip_norm_le BH hBH _)
    (fun _ => wholeClip_norm_le T hT _) hBG
  intro k
  apply abs_le.mpr
  constructor
  · exact le_max_left _ _
  · exact max_le (by linarith) (min_le_left _ _)

/-- A simpler width-independent coefficient envelope when at least one source
is retained. -/
theorem reconstructionDraw_bound_simple {a t T BH BG : ℝ}
    (hm : 0 < m) (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG)
    (p : ReconstructionInput N q) (ω : ReconstructionRandomness N m)
    (i : Fin N) (j : Fin m) :
    |(reconstructionDraw a t T BH BG p ω).2 i j| ≤ BH * T + BG := by
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hs1 : 1 ≤ Real.sqrt (m : ℝ) := by
    exact (Real.le_sqrt (by norm_num) (by positivity)).mpr (by simpa using hm1)
  exact (reconstructionDraw_bound ha ht hT hBH hBG p ω i j).trans
    (add_le_add (div_le_self (mul_nonneg hBH hT) hm1) (div_le_self hBG hs1))

/-- All source choices and Gaussian innovations have their literal product
sampling law. -/
def reconstructionRandomLaw (N m : ℕ) [NeZero N] : Measure (ReconstructionRandomness N m) :=
  (iidSamples (uniformIndexLaw N) m).prod
    (Measure.pi (fun _ : Fin N => Measure.pi (fun _ : Fin m => gaussianReal 0 1)))

instance reconstructionRandomLaw_probability (N m : ℕ) [NeZero N] :
    IsProbabilityMeasure (reconstructionRandomLaw N m) := by
  unfold reconstructionRandomLaw
  infer_instance

/-- The common canonical layer kernel, independent of any test point. -/
def reconstructionKernel [NeZero N] (a t T BH BG : ℝ) :
    Kernel (ReconstructionInput N q) (ReconstructionOutput N m) :=
  (Kernel.id ×ₖ Kernel.const _ (reconstructionRandomLaw N m)).map
    (fun p => reconstructionDraw a t T BH BG p.1 p.2)

instance reconstructionKernel_markov [NeZero N] (a t T BH BG : ℝ) :
    IsMarkovKernel (reconstructionKernel (N := N) (m := m) (q := q) a t T BH BG) := by
  unfold reconstructionKernel
  exact Kernel.IsMarkovKernel.map _ (measurable_reconstructionDraw a t T BH BG)

theorem reconstructionKernel_apply [NeZero N] (a t T BH BG : ℝ)
    (p : ReconstructionInput N q) :
    reconstructionKernel (m := m) a t T BH BG p =
      (reconstructionRandomLaw N m).map (reconstructionDraw a t T BH BG p) := by
  rw [reconstructionKernel, Kernel.map_apply _ (measurable_reconstructionDraw a t T BH BG),
    Kernel.prod_apply, Kernel.id_apply, Kernel.const_apply,
    Measure.dirac_prod, Measure.map_map (measurable_reconstructionDraw a t T BH BG)
      measurable_prodMk_left]
  rfl

end NeuralGeneralization.RobustCompressionReconstruction
