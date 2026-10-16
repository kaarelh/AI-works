import NeuralGeneralization.GaussianPriceBounds
import NeuralGeneralization.TanhTiltHessian
import NeuralGeneralization.BoundedTilt
import Mathlib.Analysis.Real.Pi.Bounds

/-! Polynomial covariance stability of the actual exponentially tilted tanh
Gaussian expectation. Singular endpoint covariances are permitted. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.TanhGaussianPrice
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianPriceBounds
open TanhDifferential
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K] [DecidableEq I]

def angularTiltedMoment (A : I → J → ℝ) (B : I → K → ℝ)
    (Γ : I → I → ℝ) (p q : I) (θ : ℝ) : ℝ :=
  (∫ z, pairValue Real.tanh p q (angularField A B θ z) *
    Real.exp (potentialValue Real.tanh Γ (angularField A B θ z)) ∂standardLaw (J ⊕ K)) /
  (∫ z, Real.exp (potentialValue Real.tanh Γ (angularField A B θ z)) ∂standardLaw (J ⊕ K))

omit [Fintype J] [Fintype K] [DecidableEq I] in
lemma entry_abs_le_double_sum (H : I → I → ℝ) (i j : I) :
    |H i j| ≤ ∑ k, ∑ l, |H k l| := by
  calc
    |H i j| ≤ ∑ l, |H i l| :=
      Finset.single_le_sum (fun l _ => abs_nonneg (H i l)) (Finset.mem_univ j)
    _ ≤ ∑ k, ∑ l, |H k l| :=
      Finset.single_le_sum (fun k _ => Finset.sum_nonneg (fun l _ => abs_nonneg (H k l)))
        (Finset.mem_univ i)

set_option maxHeartbeats 800000 in
/-- The derivative bound has no dimension factor and no exponential loss in
the coupling budget. It is proved from the actual tanh derivatives, actual
Gaussian integration by parts, and exact partition cancellation. -/
theorem angularTiltedMoment_derivative_bound (A : I → J → ℝ) (B : I → K → ℝ)
    (Γ : I → I → ℝ) (p q : I) {g e : ℝ} (hg : 0 ≤ g) (he : 0 ≤ e)
    (hΓ : couplingMass Γ ≤ g) (hCov : ∀ i k, |gram B i k - gram A i k| ≤ e)
    (θ : ℝ) :
    ∃ d : ℝ, HasDerivAt (angularTiltedMoment A B Γ p q) d θ ∧
      |d| ≤ e * (3 + 10 * g + 4 * g ^ 2) := by
  let V := potentialValue Real.tanh Γ
  let V₁ := potentialGradient Real.tanh tanhFirst Γ
  let V₂ := potentialHessian Real.tanh tanhFirst tanhSecond Γ
  let F := pairValue Real.tanh p q
  let F₁ := pairGradient Real.tanh tanhFirst p q
  let F₂ := pairHessian Real.tanh tanhFirst tanhSecond p q
  let W := fun z => Real.exp (V z)
  let Z := fun t => ∫ z, W (angularField A B t z) ∂standardLaw (J ⊕ K)
  let M := fun t => ∫ z, F (angularField A B t z) * W (angularField A B t z)
    ∂standardLaw (J ⊕ K)
  have hV (z) : HasFDerivAt V (gradientLinear (V₁ z)) z := (tanhPotential_derivatives Γ z).1
  have hV₁ (z i) : HasFDerivAt (fun y => V₁ y i) (gradientLinear (V₂ z i)) z :=
    (tanhPotential_derivatives Γ z).2 i
  have hF (z) : HasFDerivAt F (gradientLinear (F₁ z)) z := (tanhPair_derivatives p q z).1
  have hF₁ (z i) : HasFDerivAt (fun y => F₁ y i) (gradientLinear (F₂ z i)) z :=
    (tanhPair_derivatives p q z).2 i
  have hVbound (z) : |V z| ≤ g := (tanhPotential_bounds Γ g hΓ z).1
  have hFbound (z) : |F z| ≤ 1 := (tanhPair_bounds p q z).1
  have hWbound (z) : W z ≤ Real.exp g :=
    Real.exp_le_exp.mpr ((le_abs_self _).trans (hVbound z))
  have hWpos (z) : 0 < W z := Real.exp_pos _
  have hWabs (z) : |W z| ≤ Real.exp g := by rw [abs_of_pos (hWpos z)]; exact hWbound z
  have hVWmeas (t) : Measurable (fun z => V (angularField A B t z)) :=
    (continuous_tanhPotentialValue Γ).measurable.comp (continuous_angularField A B t).measurable
  have hWint (t) : Integrable (fun z => W (angularField A B t z)) (standardLaw (J ⊕ K)) :=
    BoundedTilt.integrable_exp_of_bounded (standardLaw (J ⊕ K)) _ (hVWmeas t)
      (fun z => hVbound _)
  have hZpos (t) : 0 < Z t :=
    BoundedTilt.partition_pos (standardLaw (J ⊕ K)) _ (hVWmeas t) (fun z => hVbound _)
  have hFWbound (z) : |F z * W z| ≤ Real.exp g := by
    rw [abs_mul, abs_of_pos (hWpos z)]
    exact (mul_le_mul_of_nonneg_right (hFbound z) (hWpos z).le).trans (by simpa using hWbound z)
  have hFWint (t) : Integrable (fun z => F (angularField A B t z) * W (angularField A B t z))
      (standardLaw (J ⊕ K)) :=
    GaussianProductStein.integrable_of_bounded (fun _ : J ⊕ K => (1 : ℝ≥0)) _
      (((continuous_tanhPairValue p q).measurable.comp (continuous_angularField A B t).measurable).mul
        (hVWmeas t).exp) _ (fun z => hFWbound _)
  have hMval (t) : |M t| ≤ Z t := by
    calc
      _ ≤ ∫ z, |F (angularField A B t z) * W (angularField A B t z)| ∂standardLaw (J ⊕ K) :=
        abs_integral_le_integral_abs
      _ ≤ _ := integral_mono_ae (hFWint t).abs (hWint t) (ae_of_all _ (fun z => by
        dsimp only
        rw [abs_mul, abs_of_pos (hWpos _)]
        simpa using mul_le_mul_of_nonneg_right (hFbound _) (hWpos _).le))
  have hCZ : 0 ≤ 6 * g + 4 * g ^ 2 := by positivity
  have hCM : 0 ≤ 6 + 14 * g + 4 * g ^ 2 := by positivity
  have hHZ (z) : (∑ i, ∑ k, |expHessian V V₁ V₂ z i k|) ≤
      (6 * g + 4 * g ^ 2) * W z := by
    simpa only [V, V₁, V₂, W, mul_comm] using tanh_expHessian_l1_bound Γ hΓ z
  have hHM (z) : (∑ i, ∑ k, |weightedHessian F F₁ F₂ V V₁ V₂ z i k|) ≤
      (6 + 14 * g + 4 * g ^ 2) * W z := by
    simpa only [F, F₁, F₂, V, V₁, V₂, W, mul_comm] using tanh_weightedHessian_l1_bound p q Γ hΓ z
  obtain ⟨dz, hdz, hdzbound⟩ := exists_derivative_bound A B W
    (expGradient V V₁) (expHessian V V₁ V₂) W
    (hasFDerivAt_expValue V V₁ hV) (hasFDerivAt_expGradient V V₁ V₂ hV hV₁)
    (fun i k => (continuous_tanh_expHessian Γ i k).measurable)
    (Real.exp g) (Real.exp g * (2 * g)) ((6 * g + 4 * g ^ 2) * Real.exp g)
    (by positivity) hWabs (tanh_expGradient_bound Γ hΓ)
    (fun z i k => (entry_abs_le_double_sum _ i k).trans ((hHZ z).trans
      (mul_le_mul_of_nonneg_left (hWbound z) hCZ))) he hCZ hCov
    (fun z => (hWpos z).le) hHZ θ (hWint θ)
  obtain ⟨dm, hdm, hdmbound⟩ := exists_derivative_bound A B (fun z => F z * W z)
    (weightedGradient F F₁ V V₁) (weightedHessian F F₁ F₂ V V₁ V₂) W
    (hasFDerivAt_weightedValue F F₁ V V₁ hF hV)
    (hasFDerivAt_weightedGradient F F₁ F₂ V V₁ V₂ hF hF₁ hV hV₁)
    (fun i k => (continuous_tanh_weightedHessian p q Γ i k).measurable)
    (Real.exp g) (Real.exp g * (2 + 2 * g)) ((6 + 14 * g + 4 * g ^ 2) * Real.exp g)
    (by positivity) hFWbound (tanh_weightedGradient_bound p q Γ hΓ)
    (fun z i k => (entry_abs_le_double_sum _ i k).trans ((hHM z).trans
      (mul_le_mul_of_nonneg_left (hWbound z) hCM))) he hCM hCov
    (fun z => (hWpos z).le) hHM θ (hWint θ)
  obtain ⟨d, hd, hdb⟩ := quotient_derivative_bound (M := M) (Z := Z) hdm hdz
    (hZpos θ) (hMval θ) he hCM hCZ hdmbound hdzbound
  refine ⟨d, hd, hdb.trans_eq ?_⟩
  ring

/-- Uniform Price stability with the stated constant 8, including arbitrary
singular endpoint covariances. The quantities are actual Gaussian integrals. -/
theorem angularTiltedMoment_endpoints (A : I → J → ℝ) (B : I → K → ℝ)
    (Γ : I → I → ℝ) (p q : I) {g e : ℝ} (hg : 0 ≤ g) (he : 0 ≤ e)
    (hΓ : couplingMass Γ ≤ g) (hCov : ∀ i k, |gram B i k - gram A i k| ≤ e) :
    |angularTiltedMoment A B Γ p q (Real.pi / 2) - angularTiltedMoment A B Γ p q 0| ≤
      8 * (1 + g) ^ 2 * e := by
  let f := angularTiltedMoment A B Γ p q
  have hd (t) := angularTiltedMoment_derivative_bound A B Γ p q hg he hΓ hCov t
  have hdiff (t) : DifferentiableAt ℝ f t := (hd t).choose_spec.1.differentiableAt
  have hderiv (t) : ‖deriv f t‖ ≤ e * (3 + 10 * g + 4 * g ^ 2) := by
    obtain ⟨d, hd, hb⟩ := hd t
    rw [hd.deriv, Real.norm_eq_abs]
    exact hb
  have hπ : 0 ≤ Real.pi / 2 := by positivity
  have hmv := norm_image_sub_le_of_norm_deriv_le_segment'
    (a := (0 : ℝ)) (b := Real.pi / 2)
    (fun t _ => (hdiff t).hasDerivAt.hasDerivWithinAt) (fun t _ => hderiv t)
    (Real.pi / 2) ⟨hπ, le_rfl⟩
  rw [Real.norm_eq_abs, sub_zero] at hmv
  have hπbound : Real.pi / 2 ≤ 8 / 5 := by linarith [Real.pi_lt_d2]
  have hc : 0 ≤ e * (3 + 10 * g + 4 * g ^ 2) := by positivity
  calc
    _ ≤ e * (3 + 10 * g + 4 * g ^ 2) * (Real.pi / 2) := hmv
    _ ≤ e * (3 + 10 * g + 4 * g ^ 2) * (8 / 5) := mul_le_mul_of_nonneg_left hπbound hc
    _ ≤ _ := by nlinarith [mul_nonneg he (sq_nonneg g)]

end NeuralGeneralization.TanhGaussianPrice
end
