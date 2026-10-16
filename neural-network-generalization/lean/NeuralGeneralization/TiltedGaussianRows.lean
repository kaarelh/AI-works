import NeuralGeneralization.TiltedRowSampling
import NeuralGeneralization.GaussianFieldTilt

/-! Bounded real Gaussian rows realize tilted covariance matrices. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.TiltedGaussianRows
open FiniteDifferential GaussianAngularFields GaussianFieldTilt TanhDifferential
variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]

def rowTilt (A : I → J → ℝ) (Γ : I → I → ℝ) : (J → ℝ) → ℝ :=
  fun z => potentialValue Real.tanh Γ (fieldLinear A z)

@[fun_prop] theorem continuous_rowTilt (A : I → J → ℝ) (Γ : I → I → ℝ) :
    Continuous (rowTilt A Γ) :=
  (continuous_tanhPotentialValue Γ).comp (fieldLinear A).continuous

theorem rowTilt_bound (A : I → J → ℝ) (Γ : I → I → ℝ) {G : ℝ}
    (hΓ : couplingMass Γ ≤ G) (z : J → ℝ) : |rowTilt A Γ z| ≤ G :=
  (tanhPotential_bounds Γ G hΓ (fieldLinear A z)).1

theorem row_integral_eq_tiltedMoment (A : I → J → ℝ) (Γ : I → I → ℝ) (p q : I) :
    (∫ z, Real.tanh (fieldLinear A z p) * Real.tanh (fieldLinear A z q)
      ∂(standardLaw J).tilted (rowTilt A Γ)) = tiltedMoment A Γ p q := by
  rw [tiltedMoment_eq_ratio, integral_tilted]
  simp only [smul_eq_mul, rowTilt]
  have heq (z : J → ℝ) :
      (Real.exp (potentialValue Real.tanh Γ (fieldLinear A z)) /
        ∫ y, Real.exp (potentialValue Real.tanh Γ (fieldLinear A y)) ∂standardLaw J) *
        (Real.tanh (fieldLinear A z p) * Real.tanh (fieldLinear A z q)) =
      (pairValue Real.tanh p q (fieldLinear A z) *
        Real.exp (potentialValue Real.tanh Γ (fieldLinear A z))) /
        (∫ y, Real.exp (potentialValue Real.tanh Γ (fieldLinear A y)) ∂standardLaw J) := by
    unfold pairValue
    ring
  simp_rw [heq]
  exact integral_div _ _

theorem exists_bounded_tanh_rows (A : I → J → ℝ) (Γ : I → I → ℝ) {G : ℝ}
    (hΓ : couplingMass Γ ≤ G) {N : ℕ} (hN : 0 < N) {η B : ℝ}
    (hη : 0 ≤ η) (hB : 0 ≤ B)
    (hbudget : 2 * (Fintype.card I : ℝ) ^ 2 * Real.exp (-(N : ℝ) * η ^ 2 / 2) +
      2 * (N : ℝ) * (Fintype.card J : ℝ) * Real.exp (2 * G - B ^ 2 / 2) < 1) :
    ∃ w : Fin N → J → ℝ, (∀ i j, |w i j| < B) ∧ ∀ p q,
      |(∑ i, Real.tanh (fieldLinear A (w i) p) * Real.tanh (fieldLinear A (w i) q)) /
        (N : ℝ) - tiltedMoment A Γ p q| < η := by
  obtain ⟨w, hw, hcov⟩ := TiltedRowSampling.exists_bounded_covariance_rows
    (fun _ : J => (1 : ℝ≥0)) (fun j => le_rfl) (rowTilt A Γ)
    (continuous_rowTilt A Γ).measurable (rowTilt_bound A Γ hΓ)
    (fun z i => Real.tanh (fieldLinear A z i)) (fun i => by fun_prop)
    (fun z i => (Real.abs_tanh_lt_one _).le) hN hη hB hbudget
  refine ⟨w, hw, ?_⟩
  intro p q
  rw [← row_integral_eq_tiltedMoment A Γ p q]
  exact hcov p q

end NeuralGeneralization.TiltedGaussianRows
