import NeuralGeneralization.RobustCompressionResidualClipping
import NeuralGeneralization.RobustCompressionInductionCost

/-! # Additive local costs for the actual four-stage reconstruction

These inequalities combine active-coordinate clipping, Gaussian residual
replacement, finite covariance reconstruction, and residual-coordinate
clipping. The factor is fixed (four); no network-depth Lipschitz factor occurs.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionLayerCost
open RobustCompressionClipping

variable {N q : ℕ}

theorem active_clipping_pointwise (φ : ℝ → ℝ) (hφ : ∀ z, |φ z| ≤ 1)
    (H ψ : EuclideanSpace ℝ (Fin q)) (offset B : ℝ) (hB : 0 < B) :
    (φ (⟪H, ψ⟫ + offset) - φ (⟪wholeClip B H, ψ⟫ + offset)) ^ 2 ≤
      4 * ‖H‖ ^ 2 / B ^ 2 :=
  bounded_image_clipping_error (fun h => φ (⟪h, ψ⟫ + offset))
    (fun h => hφ _) B hB H

theorem active_clipping_vector (φ : ℝ → ℝ) (hφ : ∀ z, |φ z| ≤ 1)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (ψ : EuclideanSpace ℝ (Fin q))
    (offset : Fin N → ℝ) (B : ℝ) (hB : 0 < B) :
    (∑ i, (φ (⟪H i, ψ⟫ + offset i) -
      φ (⟪wholeClip B (H i), ψ⟫ + offset i)) ^ 2) ≤
        (4 / B ^ 2) * ∑ i, ‖H i‖ ^ 2 := by
  calc
    _ ≤ ∑ i, 4 * ‖H i‖ ^ 2 / B ^ 2 := Finset.sum_le_sum
      (fun i _ => active_clipping_pointwise φ hφ (H i) ψ (offset i) B hB)
    _ = _ := by
      simp only [div_eq_mul_inv, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i hi
      ring

/-- A four-link comparison has a fixed Cauchy--Schwarz cost. -/
theorem square_four_links (z₀ z₁ z₂ z₃ z₄ : ℝ) :
    (z₀ - z₄) ^ 2 ≤ 4 * ((z₀-z₁)^2 + (z₁-z₂)^2 + (z₂-z₃)^2 + (z₃-z₄)^2) := by
  nlinarith [sq_nonneg ((z₀-z₁)-(z₁-z₂)), sq_nonneg ((z₀-z₁)-(z₂-z₃)),
    sq_nonneg ((z₀-z₁)-(z₃-z₄)), sq_nonneg ((z₁-z₂)-(z₂-z₃)),
    sq_nonneg ((z₁-z₂)-(z₃-z₄)), sq_nonneg ((z₂-z₃)-(z₃-z₄))]

theorem squared_vector_four_links (z₀ z₁ z₂ z₃ z₄ : Fin N → ℝ) :
    (∑ i, (z₀ i-z₄ i)^2) ≤
      4 * ((∑ i, (z₀ i-z₁ i)^2) + (∑ i, (z₁ i-z₂ i)^2) +
        (∑ i, (z₂ i-z₃ i)^2) + (∑ i, (z₃ i-z₄ i)^2)) := by
  calc
    _ ≤ ∑ i, 4 * ((z₀ i-z₁ i)^2 + (z₁ i-z₂ i)^2 +
        (z₂ i-z₃ i)^2 + (z₃ i-z₄ i)^2) :=
      Finset.sum_le_sum (fun i _ => square_four_links _ _ _ _ _)
    _ = _ := by
      rw [← Finset.mul_sum]
      simp only [Finset.sum_add_distrib]

/-- The four-link estimate also holds at the level of extended nonnegative
integrals, without adding hidden integrability premises. -/
theorem lintegral_four_links {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (z₀ z₁ z₂ z₃ z₄ : Ω → Fin N → ℝ)
    (h₀ : Measurable z₀) (h₁ : Measurable z₁) (h₂ : Measurable z₂)
    (h₃ : Measurable z₃) (h₄ : Measurable z₄) :
    (∫⁻ ω, ENNReal.ofReal (∑ i, (z₀ ω i-z₄ ω i)^2) ∂μ) ≤
      4 * ((∫⁻ ω, ENNReal.ofReal (∑ i, (z₀ ω i-z₁ ω i)^2) ∂μ) +
        (∫⁻ ω, ENNReal.ofReal (∑ i, (z₁ ω i-z₂ ω i)^2) ∂μ) +
        (∫⁻ ω, ENNReal.ofReal (∑ i, (z₂ ω i-z₃ ω i)^2) ∂μ) +
        (∫⁻ ω, ENNReal.ofReal (∑ i, (z₃ ω i-z₄ ω i)^2) ∂μ)) := by
  have hmono := lintegral_mono (μ := μ) (fun ω => ENNReal.ofReal_le_ofReal
    (squared_vector_four_links (z₀ ω) (z₁ ω) (z₂ ω) (z₃ ω) (z₄ ω)))
  refine hmono.trans_eq ?_
  have heq (ω : Ω) : ENNReal.ofReal
      (4 * ((∑ i, (z₀ ω i-z₁ ω i)^2) + (∑ i, (z₁ ω i-z₂ ω i)^2) +
        (∑ i, (z₂ ω i-z₃ ω i)^2) + (∑ i, (z₃ ω i-z₄ ω i)^2))) =
      4 * (ENNReal.ofReal (∑ i, (z₀ ω i-z₁ ω i)^2) +
        ENNReal.ofReal (∑ i, (z₁ ω i-z₂ ω i)^2) +
        ENNReal.ofReal (∑ i, (z₂ ω i-z₃ ω i)^2) +
        ENNReal.ofReal (∑ i, (z₃ ω i-z₄ ω i)^2)) := by
    rw [ENNReal.ofReal_mul (by norm_num), ENNReal.ofReal_add (by positivity) (by positivity),
      ENNReal.ofReal_add (by positivity) (by positivity), ENNReal.ofReal_add (by positivity) (by positivity)]
    norm_num
  simp_rw [heq]
  rw [lintegral_const_mul _ (by fun_prop)]
  rw [lintegral_add_left (by fun_prop), lintegral_add_left (by fun_prop),
    lintegral_add_left (by fun_prop)]

/-- A bounded activation makes every finite-vector discrepancy integrable. -/
theorem activation_vector_cost_integrable {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsFiniteMeasure μ] (φ : ℝ → ℝ) (hφ : Measurable φ)
    (hbound : ∀ z, |φ z| ≤ 1) (u v : Ω → Fin N → ℝ)
    (hu : Measurable u) (hv : Measurable v) :
    Integrable (fun ω => ∑ i, (φ (u ω i)-φ (v ω i))^2) μ := by
  have hm : Measurable (fun ω => ∑ i, (φ (u ω i)-φ (v ω i))^2) := by fun_prop
  apply (integrable_const (4 * (N : ℝ))).mono' hm.aestronglyMeasurable
  apply Filter.Eventually.of_forall
  intro ω
  rw [Real.norm_eq_abs, abs_of_nonneg (Finset.sum_nonneg (fun _ _ => sq_nonneg _))]
  calc
    _ ≤ ∑ _i : Fin N, (4 : ℝ) := by
      apply Finset.sum_le_sum
      intro i hi
      have hb := (abs_sub (φ (u ω i)) (φ (v ω i))).trans
        (add_le_add (hbound _) (hbound _))
      nlinarith [sq_abs (φ (u ω i)-φ (v ω i)), abs_nonneg (φ (u ω i)-φ (v ω i))]
    _ = _ := by simp; ring

theorem activation_vector_cost_lintegral_le {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsFiniteMeasure μ] (φ : ℝ → ℝ) (hφ : Measurable φ)
    (hbound : ∀ z, |φ z| ≤ 1) (u v : Ω → Fin N → ℝ)
    (hu : Measurable u) (hv : Measurable v) {E : ℝ}
    (hE : (∫ ω, ∑ i, (φ (u ω i)-φ (v ω i))^2 ∂μ) ≤ E) :
    (∫⁻ ω, ENNReal.ofReal (∑ i, (φ (u ω i)-φ (v ω i))^2) ∂μ) ≤ ENNReal.ofReal E := by
  rw [← ofReal_integral_eq_lintegral_ofReal
    (activation_vector_cost_integrable μ φ hφ hbound u v hu hv)
    (Filter.Eventually.of_forall (fun _ => Finset.sum_nonneg (fun _ _ => sq_nonneg _)))]
  exact ENNReal.ofReal_le_ofReal hE

end NeuralGeneralization.RobustCompressionLayerCost
