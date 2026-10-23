import NeuralGeneralization.BatchTwoNonGaussianTaylor
import NeuralGeneralization.BatchTwoNonGaussianMoments
import NeuralGeneralization.BatchTwoNonGaussianGaussianInstance

/-! Actual one-coordinate replacements for the relative Lindeberg comparison. -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open TanhDifferential
variable {I : Type*} [Fintype I]

theorem potentialLine_eq_quadratic (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) :
    potentialLine Γ z a t = potentialValue Real.tanh Γ (fun i => z i + a i * t) := rfl

theorem potentialLine_abs_le (Γ : I → I → ℝ) (z a : I → ℝ) (t G : ℝ)
    (hΓ : couplingMass Γ ≤ G) : |potentialLine Γ z a t| ≤ G :=
  (abs_potentialValue_le_mass Real.tanh (fun x => (Real.abs_tanh_lt_one x).le)
    Γ (fun i => z i + a i * t)).trans hΓ

theorem expPotential_integrable (ν : CoordinateLaw) (Γ : I → I → ℝ) (z a : I → ℝ) :
    Integrable (expPotential Γ z a) ν.law := by
  apply Integrable.of_bound (contDiff_expPotential (n := 0) Γ z a).continuous.aestronglyMeasurable
    (Real.exp (couplingMass Γ))
  filter_upwards [] with t
  change |Real.exp (potentialLine Γ z a t)| ≤ _
  rw [abs_of_pos (Real.exp_pos _)]
  exact Real.exp_le_exp.mpr (le_trans (le_abs_self _) (potentialLine_abs_le Γ z a t _ le_rfl))

def cubicExpMoment (ν : CoordinateLaw) : ℝ := ∫ x : ℝ, |x| ^ 3 * Real.exp |x| ∂ν.law

theorem cubicExpMoment_nonneg (ν : CoordinateLaw) : 0 ≤ cubicExpMoment ν :=
  integral_nonneg fun x => mul_nonneg (pow_nonneg (abs_nonneg x) 3) (Real.exp_nonneg _)

def quadraticCenter (Γ : I → I → ℝ) (z a : I → ℝ) : ℝ :=
  expPotential Γ z a 0 +
    exponentialSecond (potentialLine Γ z a) (potentialLineFirst Γ z a) (potentialLineSecond Γ z a) 0 / 2

theorem expPotential_expectation_error (ν : CoordinateLaw) (Γ : I → I → ℝ) (z a : I → ℝ)
    (G b : ℝ) (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b)
    (ha : ∀ i, |a i| ≤ b) (hsmall : 2 * G * b ≤ 1) :
    |(∫ t, expPotential Γ z a t ∂ν.law) - quadraticCenter Γ z a| ≤
      lindebergPolynomial G * b ^ 3 / 6 * cubicExpMoment ν * expPotential Γ z a 0 := by
  let f := expPotential Γ z a
  let c₁ := exponentialFirst (potentialLine Γ z a) (potentialLineFirst Γ z a) 0
  let c₂ := exponentialSecond (potentialLine Γ z a) (potentialLineFirst Γ z a) (potentialLineSecond Γ z a) 0
  let R : ℝ → ℝ := fun t => f t - f 0 - t * c₁ - t ^ 2 * c₂ / 2
  let C := lindebergPolynomial G * b ^ 3 / 6
  have hf : Integrable f ν.law := expPotential_integrable ν Γ z a
  have hi₁ := ν.integrable_id.mul_const c₁
  have hi₂ := (ν.square_integrable.mul_const c₂).div_const 2
  have hi₀ : Integrable (fun _ : ℝ => f 0) ν.law := integrable_const _
  have hiA : Integrable (fun t => f t - f 0) ν.law := hf.sub hi₀
  have hiB : Integrable (fun t => f t - f 0 - t * c₁) ν.law := hiA.sub hi₁
  have hR : Integrable R ν.law := ((hf.sub (integrable_const _)).sub hi₁).sub hi₂
  have hRmean : (∫ t, R t ∂ν.law) = (∫ t, f t ∂ν.law) - quadraticCenter Γ z a := by
    unfold R
    rw [integral_sub hiB hi₂,
      integral_sub hiA hi₁,
      integral_sub hf hi₀, integral_mul_const, integral_div, integral_mul_const,
      ν.integral_id, ν.square_integral]
    simp only [integral_const, probReal_univ, smul_eq_mul, one_mul, zero_mul, sub_zero]
    dsimp [quadraticCenter, f, c₂]
    ring
  have hC : 0 ≤ C := by dsimp [C, lindebergPolynomial]; positivity
  have hf0 : 0 ≤ f 0 := Real.exp_nonneg _
  have hmajor (t : ℝ) : |R t| ≤ C * (|t| ^ 3 * Real.exp |t|) * f 0 := by
    have h := expPotential_relative_remainder Γ z a t G b hG hΓ hb ha
    have he : Real.exp (2 * G * b * |t|) ≤ Real.exp |t| := by
      apply Real.exp_le_exp.mpr
      nlinarith [mul_le_mul_of_nonneg_right hsmall (abs_nonneg t)]
    change |R t| ≤ _ at h
    calc
      _ ≤ C * |t| ^ 3 * Real.exp (2 * G * b * |t|) * f 0 := h
      _ ≤ C * |t| ^ 3 * Real.exp |t| * f 0 := by gcongr
      _ = _ := by ring
  have hint := integral_mono hR.abs ((ν.cubic_exp_integrable.const_mul C).mul_const (f 0)) hmajor
  rw [integral_mul_const, integral_const_mul] at hint
  rw [← hRmean]
  exact (abs_integral_le_integral_abs).trans hint

/-- Both one-coordinate partition functions have a common, local lower bound. -/
theorem expPotential_expectation_lower (ν : CoordinateLaw) (Γ : I → I → ℝ) (z a : I → ℝ)
    (G b : ℝ) (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b)
    (ha : ∀ i, |a i| ≤ b) (hsmall : 2 * G * b ≤ 1) :
    Real.exp (-1) * expPotential Γ z a 0 ≤ ∫ t, expPotential Γ z a t ∂ν.law := by
  have hnon : 0 ≤ 2 * G * b := by positivity
  have hint := integral_mono
    ((ν.exp_neg_abs_integrable (2 * G * b) hnon).mul_const (expPotential Γ z a 0))
    (expPotential_integrable ν Γ z a)
    (fun t => by simpa only [neg_mul] using (expPotential_relative_bounds Γ z a t G b hΓ hb ha).1)
  rw [integral_mul_const] at hint
  exact (mul_le_mul_of_nonneg_right
    (ν.integral_exp_neg_abs_lower (2 * G * b) hnon hsmall) (Real.exp_nonneg _)).trans hint

private theorem abs_log_sub_le {u v c : ℝ} (hc : 0 < c) (hu : c ≤ u) (hv : c ≤ v) :
    |Real.log u - Real.log v| ≤ |u - v| / c := by
  have hu0 := hc.trans_le hu
  have hv0 := hc.trans_le hv
  have one_direction (x y : ℝ) (hx : 0 < x) (hy : c ≤ y) :
      Real.log x - Real.log y ≤ |x - y| / c := by
    have hy0 := hc.trans_le hy
    have h := Real.log_le_sub_one_of_pos (div_pos hx hy0)
    rw [Real.log_div hx.ne' hy0.ne'] at h
    have heq : x / y - 1 = (x - y) / y := by field_simp
    rw [heq] at h
    exact h.trans ((div_le_div_of_nonneg_right (le_abs_self _) hy0.le).trans
      (div_le_div_of_nonneg_left (abs_nonneg _) hc hy))
  have h1 := one_direction u v hu0 hv
  have h2 := one_direction v u hv0 hu
  rw [abs_sub_comm v u] at h2
  exact abs_le.mpr ⟨by linarith, h1⟩

def replacementConstant (ν η : CoordinateLaw) : ℝ :=
  Real.exp 1 * (cubicExpMoment ν + cubicExpMoment η) / 6

/-- A genuine coordinate-law replacement.  In particular `η = standardGaussian`
is the paper's one-step relative Lindeberg estimate, with its exact constant. -/
theorem one_coordinate_relative_lindeberg (ν η : CoordinateLaw)
    (Γ : I → I → ℝ) (z a : I → ℝ) (G b : ℝ)
    (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b)
    (ha : ∀ i, |a i| ≤ b) (hsmall : 2 * G * b ≤ 1) :
    |Real.log (∫ t, expPotential Γ z a t ∂ν.law) -
        Real.log (∫ t, expPotential Γ z a t ∂η.law)| ≤
      replacementConstant ν η * lindebergPolynomial G * b ^ 3 := by
  let u := ∫ t, expPotential Γ z a t ∂ν.law
  let v := ∫ t, expPotential Γ z a t ∂η.law
  let q := quadraticCenter Γ z a
  let f0 := expPotential Γ z a 0
  let C := lindebergPolynomial G * b ^ 3 / 6
  have hν := expPotential_expectation_error ν Γ z a G b hG hΓ hb ha hsmall
  have hη := expPotential_expectation_error η Γ z a G b hG hΓ hb ha hsmall
  have habs : |u - v| ≤ C * (cubicExpMoment ν + cubicExpMoment η) * f0 := by
    have htri : |u - v| ≤ |u - q| + |v - q| := by
      calc
        _ = |(u - q) + (-(v - q))| := by congr 1; ring
        _ ≤ |u - q| + |-(v - q)| := abs_add_le _ _
        _ = _ := by rw [abs_neg]
    change |u - q| ≤ C * cubicExpMoment ν * f0 at hν
    change |v - q| ≤ C * cubicExpMoment η * f0 at hη
    nlinarith
  have hf0 : 0 < f0 := Real.exp_pos _
  have hbase : 0 < Real.exp (-1) * f0 := mul_pos (Real.exp_pos _) hf0
  have hlog := abs_log_sub_le hbase
    (expPotential_expectation_lower ν Γ z a G b hG hΓ hb ha hsmall)
    (expPotential_expectation_lower η Γ z a G b hG hΓ hb ha hsmall)
  refine hlog.trans ((div_le_div_of_nonneg_right habs hbase.le).trans_eq ?_)
  dsimp [replacementConstant, C]
  rw [Real.exp_neg]
  field_simp [hf0.ne', (Real.exp_pos 1).ne']

end NeuralGeneralization.BatchTwoNonGaussian
