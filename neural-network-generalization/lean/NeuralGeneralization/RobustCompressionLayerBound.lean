import NeuralGeneralization.RobustCompressionLayerComparison

/-! # The complete local error bound for a finite reconstructed layer -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal RealInnerProductSpace
set_option maxHeartbeats 400000
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompressionLayerGaussian RobustCompressionLayerCost RobustCompressionClipping RobustCoupling

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}

abbrev LayerDraw (N m : ℕ) := ((Fin N → ℝ) × (Fin N → ℝ)) × (Fin N → Fin m → ℝ)

/-- All four errors occur in one actual joint kernel. The same canonical
coefficient marginal works for every tested feature vector. -/
theorem layerJointKernel_total_cost
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (ψ : EuclideanSpace ℝ (Fin q))
    {BH BG : ℝ} (hBH : 0 < BH) (hBG : 0 < BG)
    (hactive : ∀ i, p.idealMean θ i = ⟪wholeClip BH (H i), ψ⟫)
    (hh : ∀ j, |p.sourceFeature θ j| ≤ 1) (ht : |p.scale| ≤ 1) (hm : 0 < m)
    {Emean Evariance : ℝ}
    (hmean : ∀ i, (p.idealMean θ i-p.finiteMean θ i)^2 ≤ Emean)
    (hvariance : ∀ i, |(p.idealVariance θ i : ℝ)-p.finiteVariance θ i| ≤ Evariance) :
    (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (φ (⟪H i,ψ⟫ + Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        φ (p.clippedFiniteObservable BG (θ,z.2) i))^2) ∂layerJointKernel P p θ) ≤
      4 * (ENNReal.ofReal ((4/BH^2)*∑ i, ‖H i‖^2) +
        (∫⁻ z, ENNReal.ofReal (∑ i,
          (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
          ∂finiteCouplingKernel (gaussianReal 0 1) N P θ) +
        ENNReal.ofReal ((N : ℝ)*(Emean+Evariance)) +
        ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
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
  have hc₃ := layerJointKernel_gaussian_cost P p hp θ φ hφ hb hmean hvariance
  have hc₄ := layerJointKernel_clipping_cost P p hp θ hh ht hBG hm φ hφ hb
  have hfour := lintegral_four_links (layerJointKernel P p θ) z₀ z₁ z₂ z₃ z₄ hz₀ hz₁ hz₂ hz₃ hz₄
  exact hfour.trans (mul_le_mul_left' (add_le_add
    (add_le_add (add_le_add hc₁ hc₂.le) hc₃) hc₄) 4)

/-- A subprobability version of the additive integration step, used after
restricting to successful rank and source-bank outcomes. -/
theorem integrate_four_costs {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (hmass : μ Set.univ ≤ 1)
    (F H R : Ω → ℝ≥0∞) (hH : Measurable H) (hR : Measurable R)
    (cH cG cB EH ER : ℝ≥0∞)
    (hpoint : ∀ θ, F θ ≤ 4 * (cH * H θ + R θ + cG + cB))
    (henergy : (∫⁻ θ, H θ ∂μ) ≤ EH) (hresidual : (∫⁻ θ, R θ ∂μ) ≤ ER) :
    (∫⁻ θ, F θ ∂μ) ≤ 4 * (cH*EH + ER + cG + cB) := by
  calc
    _ ≤ ∫⁻ θ, 4 * (cH * H θ + R θ + cG + cB) ∂μ := lintegral_mono hpoint
    _ = 4 * (cH * (∫⁻ θ, H θ ∂μ) + (∫⁻ θ, R θ ∂μ) +
        cG * μ Set.univ + cB * μ Set.univ) := by
      rw [lintegral_const_mul _ (by fun_prop),
        lintegral_add_left (by fun_prop), lintegral_add_left (by fun_prop),
        lintegral_add_left (by fun_prop), lintegral_const_mul _ hH]
      simp only [lintegral_const]
    _ ≤ _ := by
      gcongr
      · simpa using mul_le_mul_left' hmass cG
      · simpa using mul_le_mul_left' hmass cB

/-- The complete actual-layer cost integrated over a successful subprobability
law. Only the separate active-energy and residual-entropy cost budgets enter;
the Gaussian approximation and clipping costs are proved inside the theorem. -/
theorem layerJointKernel_total_cost_averaged
    (μ : Measure A) (hmass : μ Set.univ ≤ 1)
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1)
    (H : A → Fin N → EuclideanSpace ℝ (Fin q)) (hHm : Measurable H)
    (ψ : A → EuclideanSpace ℝ (Fin q))
    {BH BG : ℝ} (hBH : 0 < BH) (hBG : 0 < BG)
    (hactive : ∀ θ i, p.idealMean θ i = ⟪wholeClip BH (H θ i), ψ θ⟫)
    (hh : ∀ θ j, |p.sourceFeature θ j| ≤ 1) (ht : |p.scale| ≤ 1) (hm : 0 < m)
    {Emean Evariance : ℝ}
    (hmean : ∀ θ i, (p.idealMean θ i-p.finiteMean θ i)^2 ≤ Emean)
    (hvariance : ∀ θ i, |(p.idealVariance θ i : ℝ)-p.finiteVariance θ i| ≤ Evariance)
    {EH ER : ℝ≥0∞}
    (henergy : (∫⁻ θ, ENNReal.ofReal (∑ i, ‖H θ i‖^2) ∂μ) ≤ EH)
    (hresidual : (∫⁻ θ, ∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) N P θ ∂μ) ≤ ER) :
    (∫⁻ θ, ∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (φ (⟪H θ i,ψ θ⟫ + Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        φ (p.clippedFiniteObservable BG (θ,z.2) i))^2) ∂layerJointKernel P p θ ∂μ) ≤
      4 * (ENNReal.ofReal (4/BH^2)*EH + ER +
        ENNReal.ofReal ((N : ℝ)*(Emean+Evariance)) +
        ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  have hφm := hφ.continuous.measurable
  have hRm : Measurable (fun θ => ∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) N P θ) := by
    apply Measurable.lintegral_kernel_prod_right
    have h₁ : Measurable (fun z : A × ((Fin N→ℝ)×(Fin N→ℝ)) =>
        p.idealObservable (z.1,z.2.1)) := p.idealObservable_measurable.comp
          (measurable_fst.prodMk (measurable_fst.comp measurable_snd))
    have h₂ : Measurable (fun z : A × ((Fin N→ℝ)×(Fin N→ℝ)) =>
        p.idealObservable (z.1,z.2.2)) := p.idealObservable_measurable.comp
          (measurable_fst.prodMk (measurable_snd.comp measurable_snd))
    exact ENNReal.measurable_ofReal.comp (Finset.measurable_sum _ (fun i _ =>
      ((hφm.comp ((measurable_pi_apply i).comp h₁)).sub
        (hφm.comp ((measurable_pi_apply i).comp h₂))).pow_const 2))
  apply integrate_four_costs μ hmass _ _ _ (by fun_prop) hRm _ _ _ EH ER _ henergy hresidual
  intro θ
  have hhθ := layerJointKernel_total_cost P p hp θ φ hφ hb (H θ) (ψ θ)
    hBH hBG (hactive θ) (hh θ) ht hm (hmean θ) (hvariance θ)
  rwa [ENNReal.ofReal_mul (by positivity : 0 ≤ 4/BH^2)] at hhθ

/-- Almost-everywhere version, so the actual successful restricted law may
be used without redefining any kernel outside its support. -/
theorem integrate_four_costs_ae {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (hmass : μ Set.univ ≤ 1)
    (F H R : Ω → ℝ≥0∞) (hH : Measurable H) (hR : Measurable R)
    (cH cG cB EH ER : ℝ≥0∞)
    (hpoint : ∀ᵐ θ ∂μ, F θ ≤ 4 * (cH * H θ + R θ + cG + cB))
    (henergy : (∫⁻ θ, H θ ∂μ) ≤ EH) (hresidual : (∫⁻ θ, R θ ∂μ) ≤ ER) :
    (∫⁻ θ, F θ ∂μ) ≤ 4 * (cH*EH + ER + cG + cB) := by
  calc
    _ ≤ ∫⁻ θ, 4 * (cH * H θ + R θ + cG + cB) ∂μ := lintegral_mono_ae hpoint
    _ = 4 * (cH * (∫⁻ θ, H θ ∂μ) + (∫⁻ θ, R θ ∂μ) +
        cG * μ Set.univ + cB * μ Set.univ) := by
      rw [lintegral_const_mul _ (by fun_prop),
        lintegral_add_left (by fun_prop), lintegral_add_left (by fun_prop),
        lintegral_add_left (by fun_prop), lintegral_const_mul _ hH]
      simp only [lintegral_const]
    _ ≤ _ := by
      gcongr
      · simpa using mul_le_mul_left' hmass cG
      · simpa using mul_le_mul_left' hmass cB

theorem layerJointKernel_total_cost_averaged_ae
    (μ : Measure A) (hmass : μ Set.univ ≤ 1)
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1)
    (H : A → Fin N → EuclideanSpace ℝ (Fin q)) (hHm : Measurable H)
    (ψ : A → EuclideanSpace ℝ (Fin q))
    {BH BG : ℝ} (hBH : 0 < BH) (hBG : 0 < BG)
    (hactive : ∀ θ i, p.idealMean θ i = ⟪wholeClip BH (H θ i), ψ θ⟫)
    (hh : ∀ θ j, |p.sourceFeature θ j| ≤ 1) (ht : |p.scale| ≤ 1) (hm : 0 < m)
    {Emean Evariance : ℝ}
    (hmean : ∀ᵐ θ ∂μ, ∀ i, (p.idealMean θ i-p.finiteMean θ i)^2 ≤ Emean)
    (hvariance : ∀ᵐ θ ∂μ, ∀ i, |(p.idealVariance θ i : ℝ)-p.finiteVariance θ i| ≤ Evariance)
    {EH ER : ℝ≥0∞}
    (henergy : (∫⁻ θ, ENNReal.ofReal (∑ i, ‖H θ i‖^2) ∂μ) ≤ EH)
    (hresidual : (∫⁻ θ, ∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) N P θ ∂μ) ≤ ER) :
    (∫⁻ θ, ∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (φ (⟪H θ i,ψ θ⟫ + Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        φ (p.clippedFiniteObservable BG (θ,z.2) i))^2) ∂layerJointKernel P p θ ∂μ) ≤
      4 * (ENNReal.ofReal (4/BH^2)*EH + ER +
        ENNReal.ofReal ((N : ℝ)*(Emean+Evariance)) +
        ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  have hφm := hφ.continuous.measurable
  have hRm : Measurable (fun θ => ∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) N P θ) := by
    apply Measurable.lintegral_kernel_prod_right
    have h₁ : Measurable (fun z : A × ((Fin N→ℝ)×(Fin N→ℝ)) =>
        p.idealObservable (z.1,z.2.1)) := p.idealObservable_measurable.comp
          (measurable_fst.prodMk (measurable_fst.comp measurable_snd))
    have h₂ : Measurable (fun z : A × ((Fin N→ℝ)×(Fin N→ℝ)) =>
        p.idealObservable (z.1,z.2.2)) := p.idealObservable_measurable.comp
          (measurable_fst.prodMk (measurable_snd.comp measurable_snd))
    exact ENNReal.measurable_ofReal.comp (Finset.measurable_sum _ (fun i _ =>
      ((hφm.comp ((measurable_pi_apply i).comp h₁)).sub
        (hφm.comp ((measurable_pi_apply i).comp h₂))).pow_const 2))
  apply integrate_four_costs_ae μ hmass _ _ _ (by fun_prop) hRm _ _ _ EH ER _ henergy hresidual
  filter_upwards [hmean, hvariance] with θ hmeanθ hvarianceθ
  have hhθ := layerJointKernel_total_cost P p hp θ φ hφ hb (H θ) (ψ θ)
    hBH hBG (hactive θ) (hh θ) ht hm hmeanθ hvarianceθ
  rwa [ENNReal.ofReal_mul (by positivity : 0 ≤ 4/BH^2)] at hhθ

end NeuralGeneralization.RobustCompressionLayerComparison
