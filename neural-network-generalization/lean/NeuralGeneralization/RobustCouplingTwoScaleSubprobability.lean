import NeuralGeneralization.RobustCouplingTwoScale

/-!
# Two-scale replacement on successful restricted laws

The external law may be any finite subprobability measure. No normalization or
conditioning penalty is incurred. Observable bounds and Lipschitz bounds need
hold only almost everywhere, so arbitrary parameter values off the success set
have no effect on the estimate.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCoupling
variable {Θ : Type*} [MeasurableSpace Θ]

theorem lintegral_le_affine_kernel_kl_subprobability
    (μ : Measure Θ) [IsFiniteMeasure μ] (hmass : μ Set.univ ≤ 1) (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    (F : Θ → ℝ≥0∞) (C B : ℝ≥0∞)
    (hF : ∀ᵐ θ ∂μ, F θ ≤ C * klDiv (P θ) (standardGaussianVector n) + B) :
    (∫⁻ θ, F θ ∂μ) ≤ C * (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) + B := by
  have hk : Measurable (fun θ => klDiv (P θ) (standardGaussianVector n)) :=
    RobustEntropy.measurable_kernel_klDiv P (Kernel.const Θ (standardGaussianVector n))
  have hC : Measurable (fun θ => C * klDiv (P θ) (standardGaussianVector n)) :=
    measurable_const.mul hk
  calc
    _ ≤ ∫⁻ θ, C * klDiv (P θ) (standardGaussianVector n) + B ∂μ := lintegral_mono_ae hF
    _ = C * (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) + B * μ Set.univ := by
      rw [lintegral_add_left hC, lintegral_const_mul _ hk, lintegral_const]
    _ ≤ _ := by
      exact add_le_add le_rfl (by simpa using mul_le_mul_left' hmass B)

theorem finiteCouplingKernel_two_scale_averaged_subprobability
    (μ : Measure Θ) [IsFiniteMeasure μ] (hmass : μ Set.univ ≤ 1) (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (g : Θ → Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (fun p : Θ × ℝ => g p.1 i p.2))
    (hbound : ∀ᵐ θ ∂μ, ∀ i x, |g θ i x| ≤ 1)
    (hLip : ∀ᵐ θ ∂μ, ∀ i x y, |g θ i x - g θ i y| ≤ t * |x - y|)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ θ, ∫⁻ p, ENNReal.ofReal (coordinateSquaredError (g θ) p)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ) ≤
      ENNReal.ofReal (14 * n * δ) := by
  let R := ∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ
  let E := ∫⁻ θ, ∫⁻ p, ENNReal.ofReal (coordinateSquaredError (g θ) p)
    ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ
  have hR : R ≠ ⊤ := ne_top_of_le_ne_top ENNReal.ofReal_ne_top hbudget
  have hgθ (θ : Θ) (i : Fin n) : Measurable (g θ i) :=
    (hg i).comp measurable_prodMk_left
  have hsmall : E ≤ ENNReal.ofReal (8 * t ^ 2) * R + ENNReal.ofReal (6 * t ^ 2 * n) :=
    lintegral_le_affine_kernel_kl_subprobability μ hmass n P _ _ _ (by
      filter_upwards [hbound, hLip] with θ hb hl
      exact finiteCouplingKernel_small_scale_lintegral_le n P θ ht (g θ) (hgθ θ) hb hl)
  have hlarge : E ≤ ENNReal.ofReal (4 / δ) * R + ENNReal.ofReal (4 * n * δ) :=
    lintegral_le_affine_kernel_kl_subprobability μ hmass n P _ _ _ (by
      filter_upwards [hbound] with θ hb
      exact finiteCouplingKernel_large_scale_lintegral_le n P θ hδ (g θ) (hgθ θ) hb)
  have hE : E ≠ ⊤ := ne_top_of_le_ne_top (by finiteness) hsmall
  have hsmallR := ENNReal.toReal_mono (by finiteness) hsmall
  rw [ENNReal.toReal_add (by finiteness) (by finiteness), ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 8 * t ^ 2),
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 6 * t ^ 2 * n)] at hsmallR
  have hlargeR := ENNReal.toReal_mono (by finiteness) hlarge
  rw [ENNReal.toReal_add (by finiteness) (by finiteness), ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 4 / δ),
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 4 * n * δ)] at hlargeR
  have hbudgetR := ENNReal.toReal_mono ENNReal.ofReal_ne_top hbudget
  rw [ENNReal.toReal_ofReal (by positivity : 0 ≤ (n : ℝ) * δ ^ 3 / t ^ 2)] at hbudgetR
  change R.toReal ≤ _ at hbudgetR
  have hlargeR' : E.toReal ≤ 4 * (R.toReal / δ + n * δ) := by
    calc
      _ ≤ (4 / δ) * R.toReal + 4 * n * δ := hlargeR
      _ = _ := by ring
  have hb := two_scale_error_budget (by positivity : (0 : ℝ) ≤ n) ENNReal.toReal_nonneg
    hδ hδ1 ht hsmallR hlargeR' hbudgetR
  apply (ENNReal.toReal_le_toReal hE ENNReal.ofReal_ne_top).mp
  rw [ENNReal.toReal_ofReal (by positivity : 0 ≤ 14 * (n : ℝ) * δ)]
  exact hb

theorem finiteCouplingKernel_activation_replacement_subprobability
    (μ : Measure Θ) [IsFiniteMeasure μ] (hmass : μ Set.univ ≤ 1) (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (a : Θ → Fin n → ℝ) (ha : ∀ i, Measurable (fun θ => a θ i))
    (ρ : Θ → ℝ) (hρm : Measurable ρ) (hρ : ∀ᵐ θ ∂μ, 0 ≤ ρ θ) (hρ1 : ∀ᵐ θ ∂μ, ρ θ ≤ 1)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ θ, ∫⁻ p, ENNReal.ofReal
      (∑ i, (φ (a θ i + t * ρ θ * p.1 i) - φ (a θ i + t * ρ θ * p.2 i)) ^ 2)
      ∂finiteCouplingKernel (gaussianReal 0 1) n P θ ∂μ) ≤
      ENNReal.ofReal (14 * n * δ) := by
  apply finiteCouplingKernel_two_scale_averaged_subprobability μ hmass n P hδ hδ1 ht
    (fun θ i z => φ (a θ i + t * ρ θ * z))
  · intro i
    exact hφ.continuous.measurable.comp
      ((ha i).comp measurable_fst |>.add
        ((measurable_const.mul (hρm.comp measurable_fst)).mul measurable_snd))
  · exact Filter.Eventually.of_forall (fun θ i z => hφbound _)
  · filter_upwards [hρ, hρ1] with θ h0 h1
    intro i x y
    exact affine_activation_lipschitz φ hφ ht.le h0 h1 x y
  · exact hbudget

theorem finiteCouplingKernel_two_scale_joint_subprobability
    (μ : Measure Θ) [IsFiniteMeasure μ] (hmass : μ Set.univ ≤ 1) (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (g : Θ → Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (fun p : Θ × ℝ => g p.1 i p.2))
    (hbound : ∀ᵐ θ ∂μ, ∀ i x, |g θ i x| ≤ 1)
    (hLip : ∀ᵐ θ ∂μ, ∀ i x y, |g θ i x - g θ i y| ≤ t * |x - y|)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ q, ENNReal.ofReal (coordinateSquaredError (g q.1) q.2)
      ∂μ ⊗ₘ finiteCouplingKernel (gaussianReal 0 1) n P) ≤
      ENNReal.ofReal (14 * n * δ) := by
  rw [Measure.lintegral_compProd (measurable_family_coordinateSquaredError g hg)]
  exact finiteCouplingKernel_two_scale_averaged_subprobability μ hmass n P hδ hδ1 ht g hg hbound hLip hbudget


/-- Real-integral form, with integrability derived from the finite entropy
budget rather than imposed as an additional analytic hypothesis. -/
theorem finiteCouplingKernel_two_scale_integral_subprobability
    (μ : Measure Θ) [IsFiniteMeasure μ] (hmass : μ Set.univ ≤ 1) (n : ℕ)
    (P : Kernel Θ (Fin n → ℝ)) [IsMarkovKernel P]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (g : Θ → Fin n → ℝ → ℝ)
    (hg : ∀ i, Measurable (fun p : Θ × ℝ => g p.1 i p.2))
    (hbound : ∀ᵐ θ ∂μ, ∀ i x, |g θ i x| ≤ 1)
    (hLip : ∀ᵐ θ ∂μ, ∀ i x y, |g θ i x - g θ i y| ≤ t * |x - y|)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector n) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    Integrable (fun q => coordinateSquaredError (g q.1) q.2)
      (μ ⊗ₘ finiteCouplingKernel (gaussianReal 0 1) n P) ∧
    (∫ q, coordinateSquaredError (g q.1) q.2
      ∂μ ⊗ₘ finiteCouplingKernel (gaussianReal 0 1) n P) ≤ 14 * n * δ := by
  have hb := finiteCouplingKernel_two_scale_joint_subprobability μ hmass n P
    hδ hδ1 ht g hg hbound hLip hbudget
  have hnn (q : Θ × ((Fin n → ℝ) × (Fin n → ℝ))) :
      0 ≤ coordinateSquaredError (g q.1) q.2 := coordinateSquaredError_nonneg _ _
  have hm : Measurable (fun q : Θ × ((Fin n → ℝ) × (Fin n → ℝ)) =>
      coordinateSquaredError (g q.1) q.2) := by
    have h := (measurable_family_coordinateSquaredError g hg).ennreal_toReal
    simpa only [ENNReal.toReal_ofReal (hnn _)] using h
  have hi : Integrable (fun q => coordinateSquaredError (g q.1) q.2)
      (μ ⊗ₘ finiteCouplingKernel (gaussianReal 0 1) n P) :=
    ⟨hm.aestronglyMeasurable, (hasFiniteIntegral_iff_ofReal
      (Filter.Eventually.of_forall hnn)).mpr (hb.trans_lt ENNReal.ofReal_lt_top)⟩
  refine ⟨hi, ?_⟩
  rw [← ofReal_integral_eq_lintegral_ofReal hi (Filter.Eventually.of_forall hnn)] at hb
  have h := ENNReal.toReal_mono ENNReal.ofReal_ne_top hb
  rw [ENNReal.toReal_ofReal (integral_nonneg hnn),
    ENNReal.toReal_ofReal (by positivity : 0 ≤ 14 * (n : ℝ) * δ)] at h
  exact h

end NeuralGeneralization.RobustCoupling
