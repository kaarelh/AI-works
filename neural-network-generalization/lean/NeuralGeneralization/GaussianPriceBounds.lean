import NeuralGeneralization.GaussianAngularPrice
import Mathlib.Analysis.Calculus.MeanValue

/-! Dimension-free bounds obtained from the actual angular Price identity. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianPriceBounds
open FiniteDifferential GaussianAngularFields GaussianAngularPrice
variable {I J K Ω : Type*} [Fintype I] [Fintype J] [Fintype K]

omit [Fintype J] [Fintype K] in
theorem abs_integral_contraction_le [MeasurableSpace Ω] (μ : Measure Ω)
    (D : I → I → ℝ) (H : Ω → I → I → ℝ) (W : Ω → ℝ)
    (hH : ∀ i j, Integrable (fun z => H z i j) μ) (hW : Integrable W μ)
    {e C : ℝ} (he : 0 ≤ e) (hD : ∀ i j, |D i j| ≤ e)
    (hbound : ∀ z, (∑ i, ∑ j, |H z i j|) ≤ C * W z) :
    |∑ i, ∑ j, D i j * ∫ z, H z i j ∂μ| ≤ e * C * ∫ z, W z ∂μ := by
  classical
  have hint : Integrable (fun z => ∑ i, ∑ j, D i j * H z i j) μ :=
    integrable_finsetSum Finset.univ (fun i _ =>
      integrable_finsetSum Finset.univ (fun j _ => (hH i j).const_mul _))
  have heq : (∫ z, ∑ i, ∑ j, D i j * H z i j ∂μ) =
      ∑ i, ∑ j, D i j * ∫ z, H z i j ∂μ := by
    rw [integral_finsetSum Finset.univ (fun i _ =>
      integrable_finsetSum Finset.univ (fun j _ => (hH i j).const_mul _))]
    apply Finset.sum_congr rfl
    intro i hi
    rw [integral_finsetSum Finset.univ (fun j _ => (hH i j).const_mul _)]
    simp only [integral_const_mul]
  have hpoint (z : Ω) : |∑ i, ∑ j, D i j * H z i j| ≤ e * C * W z := by
    calc
      _ ≤ ∑ i, |∑ j, D i j * H z i j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j, |D i j * H z i j| :=
        Finset.sum_le_sum (fun i _ => Finset.abs_sum_le_sum_abs _ _)
      _ ≤ ∑ i, ∑ j, e * |H z i j| := by
        apply Finset.sum_le_sum
        intro i hi
        apply Finset.sum_le_sum
        intro j hj
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_right (hD i j) (abs_nonneg _)
      _ = e * ∑ i, ∑ j, |H z i j| := by simp only [Finset.mul_sum]
      _ ≤ e * (C * W z) := mul_le_mul_of_nonneg_left (hbound z) he
      _ = _ := by ring
  rw [← heq]
  calc
    _ ≤ ∫ z, |∑ i, ∑ j, D i j * H z i j| ∂μ := abs_integral_le_integral_abs
    _ ≤ ∫ z, e * C * W z ∂μ := integral_mono_ae hint.abs (hW.const_mul _)
      (ae_of_all _ hpoint)
    _ = _ := integral_const_mul _ _

lemma abs_sin_mul_cos_le_half (θ : ℝ) : |Real.sin θ * Real.cos θ| ≤ 1 / 2 := by
  rw [abs_mul]
  have hs := Real.sin_sq_add_cos_sq θ
  have h := sq_nonneg (|Real.sin θ| - |Real.cos θ|)
  rw [sub_sq, sq_abs, sq_abs] at h
  nlinarith

/-- The Price derivative is bounded by the expected weighted Hessian l1 norm.
The input assumptions are ordinary derivative and pointwise bounds; the
Gaussian identity and exchange with the integral are proved above. -/
theorem exists_derivative_bound (A : I → J → ℝ) (B : I → K → ℝ)
    (H : (I → ℝ) → ℝ) (grad : (I → ℝ) → I → ℝ)
    (hess : (I → ℝ) → I → I → ℝ) (W : (I → ℝ) → ℝ)
    (hH : ∀ x, HasFDerivAt H (gradientLinear (grad x)) x)
    (hDiff : ∀ x i, HasFDerivAt (fun y => grad y i) (gradientLinear (hess x i)) x)
    (hHessMeas : ∀ i k, Measurable (fun x => hess x i k))
    (B0 B1 B2 : ℝ) (hB1 : 0 ≤ B1) (hBound : ∀ x, |H x| ≤ B0)
    (hGradBound : ∀ x i, |grad x i| ≤ B1)
    (hHessBound : ∀ x i k, |hess x i k| ≤ B2)
    {e C : ℝ} (he : 0 ≤ e) (hC : 0 ≤ C)
    (hCov : ∀ i k, |gram B i k - gram A i k| ≤ e)
    (hW : ∀ x, 0 ≤ W x)
    (hWeighted : ∀ x, (∑ i, ∑ k, |hess x i k|) ≤ C * W x)
    (θ : ℝ) (hWint : Integrable (fun z => W (angularField A B θ z)) (standardLaw (J ⊕ K))) :
    ∃ d : ℝ, HasDerivAt (fun t => ∫ z, H (angularField A B t z) ∂standardLaw (J ⊕ K)) d θ ∧
      |d| ≤ e * C / 2 * ∫ z, W (angularField A B θ z) ∂standardLaw (J ⊕ K) := by
  let d : ℝ := Real.sin θ * Real.cos θ * ∑ i, ∑ k,
    (gram B i k - gram A i k) *
      ∫ z, hess (angularField A B θ z) i k ∂standardLaw (J ⊕ K)
  refine ⟨d, hasDerivAt_integral_angular A B H grad hess hH hDiff hHessMeas
    B0 B1 B2 hB1 hBound hGradBound hHessBound θ, ?_⟩
  have hint (i k : I) : Integrable
      (fun z => hess (angularField A B θ z) i k) (standardLaw (J ⊕ K)) :=
    GaussianProductStein.integrable_of_bounded (fun _ : J ⊕ K => (1 : ℝ≥0)) _
      ((hHessMeas i k).comp (continuous_angularField A B θ).measurable) B2
      (fun z => hHessBound _ i k)
  have hcontr := abs_integral_contraction_le (standardLaw (J ⊕ K))
    (fun i k => gram B i k - gram A i k)
    (fun z i k => hess (angularField A B θ z) i k)
    (fun z => W (angularField A B θ z)) hint hWint he hCov
    (fun z => hWeighted _)
  have hI : 0 ≤ ∫ z, W (angularField A B θ z) ∂standardLaw (J ⊕ K) :=
    integral_nonneg (fun z => hW _)
  change |Real.sin θ * Real.cos θ * _| ≤ _
  rw [abs_mul]
  calc
    _ ≤ (1 / 2) * (e * C * ∫ z, W (angularField A B θ z) ∂standardLaw (J ⊕ K)) :=
      mul_le_mul (abs_sin_mul_cos_le_half θ) hcontr (abs_nonneg _) (by norm_num)
    _ = _ := by ring

/-- Cancellation of the common positive partition integral in the quotient
derivative. This is the source of polynomial, rather than exponential,
dependence on the tilt budget. -/
theorem quotient_derivative_bound {M Z : ℝ → ℝ} {θ dm dz e cM cZ : ℝ}
    (hM : HasDerivAt M dm θ) (hZ : HasDerivAt Z dz θ)
    (hpos : 0 < Z θ) (hval : |M θ| ≤ Z θ)
    (he : 0 ≤ e) (hcM : 0 ≤ cM) (hcZ : 0 ≤ cZ)
    (hdm : |dm| ≤ e * cM / 2 * Z θ) (hdz : |dz| ≤ e * cZ / 2 * Z θ) :
    ∃ q : ℝ, HasDerivAt (fun t => M t / Z t) q θ ∧ |q| ≤ e * (cM + cZ) / 2 := by
  refine ⟨(dm * Z θ - M θ * dz) / Z θ ^ 2, hM.div hZ hpos.ne', ?_⟩
  rw [abs_div, abs_of_pos (sq_pos_of_pos hpos)]
  apply (div_le_iff₀ (sq_pos_of_pos hpos)).2
  calc
    |dm * Z θ - M θ * dz| ≤ |dm * Z θ| + |M θ * dz| := abs_sub _ _
    _ = |dm| * Z θ + |M θ| * |dz| := by rw [abs_mul, abs_of_pos hpos, abs_mul]
    _ ≤ (e * cM / 2 * Z θ) * Z θ + Z θ * (e * cZ / 2 * Z θ) := by
      apply add_le_add (mul_le_mul_of_nonneg_right hdm hpos.le)
      exact mul_le_mul hval hdz (abs_nonneg _) hpos.le
    _ = _ := by ring

end NeuralGeneralization.GaussianPriceBounds
end
