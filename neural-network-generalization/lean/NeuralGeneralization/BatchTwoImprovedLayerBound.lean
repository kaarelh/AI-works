import NeuralGeneralization.BatchTwoImprovedLayerComparison
import NeuralGeneralization.RobustCompressionLayerBound

/-! Four errors in a single sharp Gaussian coupling.  The Gaussian comparison
retains its exact square-root variance cost for subsequent source averaging. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedLayerComparison
open RobustCompressionLayerGaussian RobustCompressionLayerCost RobustCompressionClipping
open BatchTwoImprovedGaussianTransport
variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}
abbrev LayerDraw (N m : ℕ) := ((Fin N → ℝ) × (Fin N → ℝ)) × (Fin N → Fin m → ℝ)
theorem layerJointKernel_total_cost
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (ψ : EuclideanSpace ℝ (Fin q))
    {BH BG : ℝ} (hBH : 0 < BH) (hBG : 0 < BG)
    (hactive : ∀ i, p.idealMean θ i = ⟪wholeClip BH (H i), ψ⟫)
    (hclip : (∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.finiteObservable (θ,z.2) i)-φ (p.clippedFiniteObservable BG (θ,z.2) i))^2)
        ∂p.fullCoupling θ) ≤ ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) :
    (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (φ (⟪H i,ψ⟫ + Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        φ (p.clippedFiniteObservable BG (θ,z.2) i))^2) ∂layerJointKernel P p θ) ≤
      4 * (ENNReal.ofReal ((4/BH^2)*∑ i, ‖H i‖^2) +
        (∫⁻ z, ENNReal.ofReal (∑ i,
          (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
          ∂finiteCouplingKernel (gaussianReal 0 1) N P θ) +
        ENNReal.ofReal (∑ i, ((p.idealMean θ i-p.finiteMean θ i)^2+
          (Real.sqrt (p.idealVariance θ i:ℝ)-Real.sqrt (p.finiteVariance θ i:ℝ))^2)) +
        ENNReal.ofReal (128*(N : ℝ)*m/BG^2)) := by
  let z₀ : LayerDraw N m → Fin N → ℝ := fun z i =>
    φ (⟪H i,ψ⟫ + Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i)
  let z₁ : LayerDraw N m → Fin N → ℝ := fun z i => φ (p.idealObservable (θ,z.1.1) i)
  let z₂ : LayerDraw N m → Fin N → ℝ := fun z i => φ (p.idealObservable (θ,z.1.2) i)
  let z₃ : LayerDraw N m → Fin N → ℝ := fun z i => φ (p.finiteObservable (θ,z.2) i)
  let z₄ : LayerDraw N m → Fin N → ℝ := fun z i => φ (p.clippedFiniteObservable BG (θ,z.2) i)
  have hφm := hφ.continuous.measurable
  have hi₁ : Measurable (fun z : LayerDraw N m => p.idealObservable (θ,z.1.1)) :=
    p.idealObservable_measurable.comp (measurable_const.prodMk (measurable_fst.comp measurable_fst))
  have hi₂ : Measurable (fun z : LayerDraw N m => p.idealObservable (θ,z.1.2)) :=
    p.idealObservable_measurable.comp (measurable_const.prodMk (measurable_snd.comp measurable_fst))
  have hi₃ : Measurable (fun z : LayerDraw N m => p.finiteObservable (θ,z.2)) :=
    p.finiteObservable_measurable.comp (measurable_const.prodMk measurable_snd)
  have hi₄ : Measurable (fun z : LayerDraw N m => p.clippedFiniteObservable BG (θ,z.2)) :=
    (p.clippedFiniteObservable_measurable BG).comp (measurable_const.prodMk measurable_snd)
  have hz₀ : Measurable z₀ := by dsimp [z₀]; fun_prop
  have hz₁ : Measurable z₁ := by dsimp [z₁]; fun_prop
  have hz₂ : Measurable z₂ := by dsimp [z₂]; fun_prop
  have hz₃ : Measurable z₃ := by dsimp [z₃]; fun_prop
  have hz₄ : Measurable z₄ := by dsimp [z₄]; fun_prop
  have hc₁ : (∫⁻ z, ENNReal.ofReal (∑ i, (z₀ z i-z₁ z i)^2) ∂layerJointKernel P p θ) ≤
      ENNReal.ofReal ((4/BH^2)*∑ i, ‖H i‖^2) := by
    calc
      _ ≤ ∫⁻ _z : LayerDraw N m, ENNReal.ofReal ((4/BH^2)*∑ i, ‖H i‖^2)
          ∂layerJointKernel P p θ := by
        apply lintegral_mono
        intro z
        apply ENNReal.ofReal_le_ofReal
        simpa only [z₀, z₁, GaussianLayerParameters.idealObservable, idealEvaluation, hactive]
          using active_clipping_vector φ hb H ψ
            (fun i => Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) BH hBH
      _ = _ := by simp
  have hc₂ : (∫⁻ z, ENNReal.ofReal (∑ i, (z₁ z i-z₂ z i)^2) ∂layerJointKernel P p θ) =
      ∫⁻ z, ENNReal.ofReal (∑ i,
        (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
        ∂finiteCouplingKernel (gaussianReal 0 1) N P θ := by
    refine layerJointKernel_old_cost P p θ
      (fun z => ENNReal.ofReal (∑ i,
        (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)) ?_
    have h₁ : Measurable (fun z : (Fin N→ℝ)×(Fin N→ℝ) => p.idealObservable (θ,z.1)) :=
      p.idealObservable_measurable.comp (measurable_const.prodMk measurable_fst)
    have h₂ : Measurable (fun z : (Fin N→ℝ)×(Fin N→ℝ) => p.idealObservable (θ,z.2)) :=
      p.idealObservable_measurable.comp (measurable_const.prodMk measurable_snd)
    fun_prop
  have hc₃ : (∫⁻ z, ENNReal.ofReal (∑ i, (z₂ z i-z₃ z i)^2) ∂layerJointKernel P p θ) ≤
      ENNReal.ofReal (∑ i, ((p.idealMean θ i-p.finiteMean θ i)^2+
        (Real.sqrt (p.idealVariance θ i:ℝ)-Real.sqrt (p.finiteVariance θ i:ℝ))^2)) := by
    rw [layerJointKernel_new_cost P p hp θ
      (fun z => ENNReal.ofReal (∑ i,
        (φ (p.idealObservable (θ,z.1) i)-φ (p.finiteObservable (θ,z.2) i))^2)) (by
          have h₁ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) => p.idealObservable (θ,z.1)) :=
            (p.idealObservable_measurable.comp measurable_prodMk_left).comp measurable_fst
          have h₂ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) => p.finiteObservable (θ,z.2)) :=
            (p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd
          fun_prop)]
    exact activation_vector_cost_lintegral_le (p.fullCoupling θ) φ hφm hb _ _
      ((p.idealObservable_measurable.comp measurable_prodMk_left).comp measurable_fst)
      ((p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd)
      (BatchTwoImprovedGaussianSquareRoot.fullCoupling_activation_error_sharp p hp θ φ hφ)
  have hc₄ : (∫⁻ z, ENNReal.ofReal (∑ i, (z₃ z i-z₄ z i)^2) ∂layerJointKernel P p θ) ≤
      ENNReal.ofReal (128*(N:ℝ)*m/BG^2) := by
    rw [layerJointKernel_new_cost P p hp θ
      (fun z => ENNReal.ofReal (∑ i,
        (φ (p.finiteObservable (θ,z.2) i)-φ (p.clippedFiniteObservable BG (θ,z.2) i))^2)) (by
          have h₁ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) => p.finiteObservable (θ,z.2)) :=
            (p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd
          have h₂ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) => p.clippedFiniteObservable BG (θ,z.2)) :=
            ((p.clippedFiniteObservable_measurable BG).comp measurable_prodMk_left).comp measurable_snd
          fun_prop)]
    exact hclip
  have hfour := lintegral_four_links (layerJointKernel P p θ) z₀ z₁ z₂ z₃ z₄ hz₀ hz₁ hz₂ hz₃ hz₄
  exact hfour.trans (mul_le_mul_left' (add_le_add
    (add_le_add (add_le_add hc₁ hc₂.le) hc₃) hc₄) 4)

end NeuralGeneralization.BatchTwoImprovedLayerComparison
