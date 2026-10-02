import Paulsen.GaussianTangentCoupling
import Paulsen.ConditionedSeedBounds
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Fourth moments of Gaussian quadratic forms

For a symmetric matrix `A` with `‖A‖_F² ≤ V`, the centred Gaussian quadratic
form `ξ = gᵀAg - tr A` satisfies `E ξ⁴ ≤ 40000 V²`. The proof uses
`ξ⁴ ≤ 24 s⁻⁴ (e^{sξ} + e^{-sξ})` with `s = 1/(4√V)` and the dimension-free
moment generating function bound.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen.Linear

open Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

theorem pow_four_le_exp_add (x : ℝ) : x ^ 4 ≤ 24 * (Real.exp x + Real.exp (-x)) := by
  have h := Real.pow_div_factorial_le_exp _ (abs_nonneg x) 4
  have h4 : (Nat.factorial 4 : ℝ) = 24 := by norm_num [Nat.factorial]
  rw [h4] at h
  have habs : |x| ^ 4 = x ^ 4 := by
    rw [show (4 : ℕ) = 2 * 2 from rfl, pow_mul, sq_abs, ← pow_mul]
  rw [habs] at h
  have hex : Real.exp |x| ≤ Real.exp x + Real.exp (-x) := by
    rcases abs_cases x with ⟨hx, _⟩ | ⟨hx, _⟩
    · rw [hx]; linarith [Real.exp_pos (-x)]
    · rw [hx]; linarith [Real.exp_pos x]
  have := (div_le_iff₀ (by norm_num : (0 : ℝ) < 24)).mp h
  linarith

theorem mgf_euclideanQuadratic_le (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (s : ℝ) (hs : ∀ i, 2 * s * hA.eigenvalues i ≤ 1 / 2) :
    mgf (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace)
      (stdGaussian (EuclideanSpace ℝ ι)) s ≤
      Real.exp (4 * s ^ 2 * ∑ i, (hA.eigenvalues i) ^ 2) := by
  have hg : Measurable (fun x : ι → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis,
    mgf_map hg.aemeasurable (by unfold euclideanQuadratic; fun_prop)]
  have hfun : (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace) ∘
      (fun y : ι → ℝ => ∑ i, y i • hA.eigenvectorBasis i) =
      fun y : ι → ℝ => ∑ i, hA.eigenvalues i * ((y i) ^ 2 - 1) := by
    ext y
    exact centered_euclideanQuadratic_eigenbasis A hA y
  rw [hfun]
  simpa only [NNReal.coe_one, mul_one, one_pow] using
    mgf_sum_centered_gaussian_squares_le (fun _ : ι => (1 : ℝ≥0)) hA.eigenvalues s
      (by simpa only [NNReal.coe_one, mul_one] using hs)

theorem abs_eigenvalue_le_sqrt_frobenius (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (V : ℝ) (hAF : (∑ i, ∑ j, (A i j) ^ 2) ≤ V) (i : ι) :
    |hA.eigenvalues i| ≤ Real.sqrt V := by
  apply Real.abs_le_sqrt
  rw [← eigenvalues_sq_sum_eq_entry_sq_sum A hA] at hAF
  exact (Finset.single_le_sum (f := fun j => (hA.eigenvalues j) ^ 2)
    (fun j _ => sq_nonneg _) (Finset.mem_univ i)).trans hAF

/-- Fourth moment of a centred Gaussian quadratic form, with integrability. -/
theorem centered_euclideanQuadratic_four (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (V : ℝ) (hV : 0 < V) (hAF : (∑ i, ∑ j, (A i j) ^ 2) ≤ V) :
    Integrable (fun x : EuclideanSpace ℝ ι => (euclideanQuadratic A x - A.trace) ^ 4)
      (stdGaussian (EuclideanSpace ℝ ι)) ∧
    (∫ x, (euclideanQuadratic A x - A.trace) ^ 4 ∂stdGaussian (EuclideanSpace ℝ ι)) ≤
      40000 * V ^ 2 := by
  set μ := stdGaussian (EuclideanSpace ℝ ι)
  set ξ : EuclideanSpace ℝ ι → ℝ := fun x => euclideanQuadratic A x - A.trace with hξ
  have hsV : 0 < Real.sqrt V := Real.sqrt_pos.mpr hV
  set s : ℝ := 1 / (4 * Real.sqrt V) with hsdef
  have hs0 : 0 < s := by positivity
  have hsl (i : ι) : 2 * s * |hA.eigenvalues i| ≤ 1 / 2 := by
    have h := abs_eigenvalue_le_sqrt_frobenius A hA V hAF i
    have : 2 * s * |hA.eigenvalues i| ≤ 2 * s * Real.sqrt V :=
      mul_le_mul_of_nonneg_left h (by positivity)
    have heq : 2 * s * Real.sqrt V = 1 / 2 := by
      rw [hsdef]; field_simp; ring
    linarith
  have hpos : ∀ i, 2 * s * hA.eigenvalues i ≤ 1 / 2 := fun i =>
    le_trans (mul_le_mul_of_nonneg_left (le_abs_self _) (by positivity)) (hsl i)
  have hneg : ∀ i, 2 * (-s) * hA.eigenvalues i ≤ 1 / 2 := by
    intro i
    have := mul_le_mul_of_nonneg_left (neg_abs_le (hA.eigenvalues i))
      (show (0 : ℝ) ≤ 2 * s by positivity)
    nlinarith [hsl i]
  have heig : (∑ i, (hA.eigenvalues i) ^ 2) ≤ V := by
    rwa [eigenvalues_sq_sum_eq_entry_sq_sum A hA]
  have hexpbound (t : ℝ) (ht : t ^ 2 = s ^ 2) :
      Real.exp (4 * t ^ 2 * ∑ i, (hA.eigenvalues i) ^ 2) ≤ 3 := by
    have h1 : 4 * t ^ 2 * ∑ i, (hA.eigenvalues i) ^ 2 ≤ 1 := by
      rw [ht]
      have hss : s ^ 2 * V = 1 / 16 := by
        rw [hsdef, div_pow, mul_pow, Real.sq_sqrt hV.le]; field_simp; ring
      nlinarith [mul_le_mul_of_nonneg_left heig (sq_nonneg s)]
    calc _ ≤ Real.exp 1 := Real.exp_le_exp.mpr h1
      _ ≤ 3 := Real.exp_one_lt_three.le
  have hint (t : ℝ) (ht : ∀ i, 2 * t * hA.eigenvalues i ≤ 1 / 2) :
      Integrable (fun x => Real.exp (t * ξ x)) μ :=
    integrable_exp_euclideanQuadratic_stdGaussian A hA t (fun i => by linarith [ht i])
  have hip := hint s hpos
  have hin := hint (-s) hneg
  have hmp := (mgf_euclideanQuadratic_le A hA s hpos).trans (hexpbound s rfl)
  have hmn := (mgf_euclideanQuadratic_le A hA (-s) hneg).trans (hexpbound (-s) (by ring))
  -- pointwise domination
  have hdom (x : EuclideanSpace ℝ ι) : ξ x ^ 4 ≤
      (24 / s ^ 4) * (Real.exp (s * ξ x) + Real.exp (-s * ξ x)) := by
    have h := pow_four_le_exp_add (s * ξ x)
    have hs4 : 0 < s ^ 4 := by positivity
    rw [div_mul_eq_mul_div, le_div_iff₀ hs4]
    have : (s * ξ x) ^ 4 = ξ x ^ 4 * s ^ 4 := by ring
    rw [this] at h
    simpa only [neg_mul] using h
  have hG : Integrable (fun x => (24 / s ^ 4) * (Real.exp (s * ξ x) + Real.exp (-s * ξ x))) μ :=
    (hip.add hin).const_mul _
  have hmeas : AEStronglyMeasurable (fun x => ξ x ^ 4) μ := by
    apply Continuous.aestronglyMeasurable
    simp only [hξ]
    unfold euclideanQuadratic
    fun_prop
  have hI : Integrable (fun x => ξ x ^ 4) μ := by
    refine hG.mono' hmeas (Filter.Eventually.of_forall fun x => ?_)
    rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
    exact hdom x
  refine ⟨hI, ?_⟩
  calc (∫ x, ξ x ^ 4 ∂μ) ≤ ∫ x, (24 / s ^ 4) * (Real.exp (s * ξ x) + Real.exp (-s * ξ x)) ∂μ :=
        integral_mono hI hG hdom
    _ = (24 / s ^ 4) * (mgf ξ μ s + mgf ξ μ (-s)) := by
        rw [integral_const_mul, integral_add hip hin]; rfl
    _ ≤ (24 / s ^ 4) * (3 + 3) := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        exact add_le_add hmp hmn
    _ = 144 * 256 * V ^ 2 := by
        rw [hsdef]
        have h4 : (Real.sqrt V) ^ 4 = V ^ 2 := by
          rw [show (4 : ℕ) = 2 * 2 from rfl, pow_mul, Real.sq_sqrt hV.le]
        field_simp
        rw [h4]; ring
    _ ≤ 40000 * V ^ 2 := by nlinarith [sq_nonneg V]


/-! ## Rows of a Gaussian linear image -/

/-- Coordinate selector of the `i`-th row block. -/
def rowSelector {n d : ℕ} (i : Fin n) : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.diagonal (fun p => if p.1 = i then 1 else 0)

theorem rowSelector_isHermitian {n d : ℕ} (i : Fin n) :
    (rowSelector (d := d) i).IsHermitian := by
  unfold rowSelector
  exact Matrix.isHermitian_diagonal_of_self_adjoint _ (by
    ext p; simp [star_trivial])

theorem rowSelector_sq_sum {n d : ℕ} (i : Fin n) :
    (∑ p, ∑ q, (rowSelector (d := d) i p q) ^ 2) = d := by
  classical
  simp only [rowSelector, Matrix.diagonal_apply]
  have h (p : Fin n × Fin d) : (∑ q, (if p = q then (if p.1 = i then (1 : ℝ) else 0) else 0) ^ 2)
      = if p.1 = i then 1 else 0 := by
    rw [Finset.sum_eq_single p]
    · split_ifs <;> simp_all
    · intro q _ hq; simp [Ne.symm hq]
    · simp
  simp only [h, Fintype.sum_prod_type, if_true,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
  rw [Finset.sum_comm]
  simp

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

theorem rowNormSq_gaussianImage_eq {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (g : EuclideanSpace ℝ κ) (i : Fin n) :
    rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i =
      euclideanQuadratic (C.transpose * rowSelector i * C) g := by
  classical
  rw [← euclideanQuadratic_linear_image, euclideanQuadratic_eq_matrixQuadratic]
  simp only [matrixQuadratic, rowSelector, Matrix.diagonal_apply, rowNormSq, frameOfVector]
  rw [Fintype.sum_prod_type]
  simp only [mul_ite, mul_zero, ite_mul, zero_mul, Finset.sum_ite_eq, Finset.mem_univ, if_true]
  rw [Finset.sum_eq_single i]
  · apply Finset.sum_congr rfl
    intro k _
    simp [pow_two]
  · intro b _ hb
    apply Finset.sum_eq_zero
    intro k _
    simp [hb]
  · simp

theorem rowGram_sq_sum_le {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ)) (i : Fin n) :
    (∑ p, ∑ q, ((C.transpose * (rowSelector (d := d) i) * C : Matrix κ κ ℝ) p q) ^ 2) ≤
      (d : ℝ) / (n : ℝ) ^ 2 := by
  have h := entry_sq_sum_quadratic_pullback_le (rowSelector (d := d) i) C
  rw [rowSelector_sq_sum] at h
  have h4 : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 4 ≤ (1 / (n : ℝ)) ^ 2 := by
    rw [show (4 : ℕ) = 2 * 2 from rfl, pow_mul]
    exact pow_le_pow_left₀ (sq_nonneg _) hC 2
  calc _ ≤ _ := h
    _ ≤ (1 / (n : ℝ)) ^ 2 * d := mul_le_mul_of_nonneg_right h4 (Nat.cast_nonneg d)
    _ = _ := by ring

/-- Elementary scalar inequality behind the row-moment estimate. -/
theorem row_deviation_scalar (a m ρ : ℝ) (ha : 0 < a) (hm0 : 0 ≤ m) (hma : m ≤ a) :
    a * ((ρ / a) ^ 2 - 1) ^ 2 ≤
      12 * (a - m) + 12 * (ρ - m) ^ 2 / a + 3 * (ρ - m) ^ 4 / a ^ 3 := by
  set μ := m / a with hμ
  set ξ := (ρ - m) / a with hξ
  have hμ0 : 0 ≤ μ := div_nonneg hm0 ha.le
  have hμ1 : μ ≤ 1 := (div_le_one ha).mpr hma
  have hr : ρ / a = μ + ξ := by rw [hμ, hξ]; field_simp; try ring
  have hkey : ((μ + ξ) ^ 2 - 1) ^ 2 ≤ 12 * (1 - μ) + 12 * ξ ^ 2 + 3 * ξ ^ 4 := by
    have h1 : ((μ + ξ) ^ 2 - 1) ^ 2 ≤
        3 * (μ ^ 2 - 1) ^ 2 + 3 * (2 * μ * ξ) ^ 2 + 3 * (ξ ^ 2) ^ 2 := by
      have : (μ + ξ) ^ 2 - 1 = (μ ^ 2 - 1) + 2 * μ * ξ + ξ ^ 2 := by ring
      rw [this]
      nlinarith [sq_nonneg ((μ ^ 2 - 1) - 2 * μ * ξ), sq_nonneg ((μ ^ 2 - 1) - ξ ^ 2),
        sq_nonneg (2 * μ * ξ - ξ ^ 2)]
    have h2 : 3 * (μ ^ 2 - 1) ^ 2 ≤ 12 * (1 - μ) := by
      have : (μ ^ 2 - 1) ^ 2 = (1 - μ) * ((1 - μ) * (1 + μ) ^ 2) := by ring
      rw [this]
      have hb : (1 - μ) * (1 + μ) ^ 2 ≤ 4 := by nlinarith
      nlinarith [mul_le_mul_of_nonneg_left hb (sub_nonneg.mpr hμ1)]
    have h3 : 3 * (2 * μ * ξ) ^ 2 ≤ 12 * ξ ^ 2 := by
      have : μ ^ 2 ≤ 1 := by nlinarith
      nlinarith [mul_le_mul_of_nonneg_right this (sq_nonneg ξ)]
    nlinarith
  rw [hr]
  have hrhs : 12 * (a - m) + 12 * (ρ - m) ^ 2 / a + 3 * (ρ - m) ^ 4 / a ^ 3 =
      a * (12 * (1 - μ) + 12 * ξ ^ 2 + 3 * ξ ^ 4) := by
    rw [hμ, hξ]; field_simp; try ring
  rw [hrhs]
  exact mul_le_mul_of_nonneg_left hkey ha.le

/-- The normalised fourth-order row deviation `a ∑ᵢ (rᵢ² - 1)²`. -/
def rowFourthDeviation {n d : ℕ} (a : ℝ) (Z : Frame n d) : ℝ :=
  a * ∑ i, ((tangentRatio a Z i) ^ 2 - 1) ^ 2

theorem rowFourthDeviation_nonneg {n d : ℕ} (a : ℝ) (ha : 0 ≤ a) (Z : Frame n d) :
    0 ≤ rowFourthDeviation a Z :=
  mul_nonneg ha (Finset.sum_nonneg fun _ _ => sq_nonneg _)

/-- Row-moment lemma for a Gaussian linear image with covariance at most `I/n`. -/
theorem integral_rowFourthDeviation_le {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (hn : 0 < n) (hd : 0 < d)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (S : ℝ) (hS : (∑ i, ((d : ℝ) / n - ∫ g, rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ))) ≤ S) :
    Integrable (fun g => rowFourthDeviation ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin C g)))
      (stdGaussian (EuclideanSpace ℝ κ)) ∧
    (∫ g, rowFourthDeviation ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin C g))
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ 12 * S + 24 + 120000 := by
  set μ := stdGaussian (EuclideanSpace ℝ κ)
  set a : ℝ := (d : ℝ) / n with ha_def
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have ha : 0 < a := div_pos hdR hnR
  set B : Fin n → Matrix κ κ ℝ := fun i => C.transpose * rowSelector i * C
  have hB (i : Fin n) : (B i).IsHermitian :=
    isHermitian_quadratic_pullback _ (rowSelector_isHermitian i) C
  set ρ : Fin n → EuclideanSpace ℝ κ → ℝ := fun i g =>
    rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i
  have hρ (i : Fin n) (g) : ρ i g = euclideanQuadratic (B i) g :=
    rowNormSq_gaussianImage_eq C g i
  set m : Fin n → ℝ := fun i => (B i).trace
  have hm (i : Fin n) : (∫ g, ρ i g ∂μ) = m i := by
    simp_rw [hρ]
    exact integral_euclideanQuadratic_stdGaussian _ (hB i)
  have hma (i : Fin n) : m i ≤ a := by
    rw [← hm i]; exact integral_rowNormSq_gaussianImage_le C hC i
  have hm0 (i : Fin n) : 0 ≤ m i := by
    rw [← hm i]; exact integral_nonneg fun g => rowNormSq_nonneg _ i
  set V : ℝ := (d : ℝ) / (n : ℝ) ^ 2 with hV
  have hVpos : 0 < V := by positivity
  have hF (i : Fin n) := rowGram_sq_sum_le C hC i
  have h4 (i : Fin n) := centered_euclideanQuadratic_four (B i) (hB i) V hVpos (hF i)
  have h2int (i : Fin n) : Integrable (fun g => (euclideanQuadratic (B i) g - (B i).trace) ^ 2) μ :=
    (memLp_centered_euclideanQuadratic_stdGaussian _ (hB i)).integrable_sq
  have h2 (i : Fin n) : (∫ g, (euclideanQuadratic (B i) g - (B i).trace) ^ 2 ∂μ) ≤ 2 * V := by
    rw [integral_sq_centered_euclideanQuadratic_stdGaussian _ (hB i)]
    linarith [hF i]
  set G : EuclideanSpace ℝ κ → ℝ := fun g => ∑ i, (12 * (a - m i) +
    12 * (euclideanQuadratic (B i) g - (B i).trace) ^ 2 / a +
    3 * (euclideanQuadratic (B i) g - (B i).trace) ^ 4 / a ^ 3)
  have hterm (i : Fin n) : Integrable (fun g => 12 * (a - m i) +
      12 * (euclideanQuadratic (B i) g - (B i).trace) ^ 2 / a +
      3 * (euclideanQuadratic (B i) g - (B i).trace) ^ 4 / a ^ 3) μ :=
    ((integrable_const _).add (((h2int i).const_mul 12).div_const a)).add
      (((h4 i).1.const_mul 3).div_const _)
  have hGint : Integrable G μ := integrable_finsetSum _ (fun i _ => hterm i)
  have hdom (g : EuclideanSpace ℝ κ) :
      rowFourthDeviation a (frameOfVector (Matrix.toEuclideanLin C g)) ≤ G g := by
    unfold rowFourthDeviation
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have := row_deviation_scalar a (m i) (ρ i g) ha (hm0 i) (hma i)
    simpa only [tangentRatio, ρ, hρ, m] using this
  have hmeas : AEStronglyMeasurable
      (fun g => rowFourthDeviation a (frameOfVector (Matrix.toEuclideanLin C g))) μ := by
    apply Continuous.aestronglyMeasurable
    have : (fun g => rowFourthDeviation a (frameOfVector (Matrix.toEuclideanLin C g))) =
        fun g => a * ∑ i, ((euclideanQuadratic (B i) g / a) ^ 2 - 1) ^ 2 := by
      funext g
      simp only [rowFourthDeviation, tangentRatio]
      congr 1
      apply Finset.sum_congr rfl
      intro i _
      rw [← hρ]
    rw [this]
    unfold euclideanQuadratic
    fun_prop
  have hI : Integrable
      (fun g => rowFourthDeviation a (frameOfVector (Matrix.toEuclideanLin C g))) μ := by
    refine hGint.mono' hmeas (Filter.Eventually.of_forall fun g => ?_)
    rw [Real.norm_eq_abs, abs_of_nonneg (rowFourthDeviation_nonneg a ha.le _)]
    exact hdom g
  refine ⟨hI, ?_⟩
  have hSm : (∑ i, (a - m i)) ≤ S := by
    have : (∑ i, (a - m i)) = ∑ i, ((d : ℝ) / n - ∫ g, ρ i g ∂μ) := by
      apply Finset.sum_congr rfl; intro i _; rw [hm i]
    rw [this]; exact hS
  calc _ ≤ ∫ g, G g ∂μ := integral_mono hI hGint hdom
    _ = ∑ i, (12 * (a - m i) +
          12 * (∫ g, (euclideanQuadratic (B i) g - (B i).trace) ^ 2 ∂μ) / a +
          3 * (∫ g, (euclideanQuadratic (B i) g - (B i).trace) ^ 4 ∂μ) / a ^ 3) := by
        change (∫ g, ∑ i, (12 * (a - m i) +
          12 * (euclideanQuadratic (B i) g - (B i).trace) ^ 2 / a +
          3 * (euclideanQuadratic (B i) g - (B i).trace) ^ 4 / a ^ 3) ∂μ) = _
        rw [integral_finsetSum _ (fun i _ => hterm i)]
        apply Finset.sum_congr rfl
        intro i _
        have i0 : Integrable (fun g => 12 * (euclideanQuadratic (B i) g - (B i).trace) ^ 2 / a) μ :=
          ((h2int i).const_mul 12).div_const a
        have i1 : Integrable (fun g => 12 * (a - m i) +
            12 * (euclideanQuadratic (B i) g - (B i).trace) ^ 2 / a) μ :=
          (integrable_const _).add i0
        have i2 : Integrable (fun g => 3 * (euclideanQuadratic (B i) g - (B i).trace) ^ 4 / a ^ 3) μ :=
          ((h4 i).1.const_mul 3).div_const _
        rw [integral_add i1 i2, integral_add (integrable_const _) i0,
          integral_const, integral_div, integral_div, integral_const_mul, integral_const_mul]
        simp
    _ ≤ ∑ _i : Fin n, (12 * (a - m _i) + 12 * (2 * V) / a + 3 * (40000 * V ^ 2) / a ^ 3) := by
        apply Finset.sum_le_sum
        intro i _
        have e2 := h2 i
        have e4 := (h4 i).2
        have t2 : 12 * (∫ g, (euclideanQuadratic (B i) g - (B i).trace) ^ 2 ∂μ) / a ≤
            12 * (2 * V) / a := by
          apply div_le_div_of_nonneg_right _ ha.le; linarith
        have t4 : 3 * (∫ g, (euclideanQuadratic (B i) g - (B i).trace) ^ 4 ∂μ) / a ^ 3 ≤
            3 * (40000 * V ^ 2) / a ^ 3 := by
          apply div_le_div_of_nonneg_right _ (by positivity); linarith
        linarith
    _ = 12 * (∑ i, (a - m i)) + 24 + 120000 / d := by
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum]
        simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        rw [hV, ha_def]
        field_simp
        ring
    _ ≤ 12 * S + 24 + 120000 := by
        have : 120000 / (d : ℝ) ≤ 120000 := by
          rw [div_le_iff₀ hdR]
          have : (1 : ℝ) ≤ d := by exact_mod_cast hd
          nlinarith
        linarith


/-! ## The constrained tangent noise -/

theorem rowTangentSpace_finrank {n d : ℕ} (X : Frame n d) (hn : 0 < n) (hd : 0 < d)
    (hX : IsEqualNorm X) :
    (Module.finrank ℝ (rowTangentSpace X) : ℝ) = (n : ℝ) * ((d : ℝ) - 1) := by
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn)
  rw [← subspaceProjectionMatrix_trace]
  simp only [Matrix.trace, Matrix.diag_apply, Fintype.sum_prod_type]
  simp_rw [rowTangentProjectionMatrix_block_trace X ha hX]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

theorem globalTangentSpace_finrank_ge {n d : ℕ} (X : Frame n d) (hn : 0 < n) (hd : 0 < d)
    (hX : IsEqualNorm X) :
    (n : ℝ) * ((d : ℝ) - 1) - (d : ℝ) ^ 2 ≤ (Module.finrank ℝ (globalTangentSpace X) : ℝ) := by
  have h := tangent_codimension_le X
  have h' : Module.finrank ℝ (rowTangentSpace X) ≤
      Module.finrank ℝ (globalTangentSpace X) + d ^ 2 := by omega
  have h'' : (Module.finrank ℝ (rowTangentSpace X) : ℝ) ≤
      (Module.finrank ℝ (globalTangentSpace X) : ℝ) + (d : ℝ) ^ 2 := by exact_mod_cast h'
  rw [rowTangentSpace_finrank X hn hd hX] at h''
  linarith

/-- Row moments (`lem:rowmoments`) for the actual constrained noise `Z = Π_F g / √n`:
`E[a ∑ᵢ (rᵢ² - 1)²] ≤ 12 (1 + d²/n) + 120024`. -/
theorem integral_rowFourthDeviation_conditioned {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X) :
    Integrable (fun g => rowFourthDeviation ((d : ℝ) / n) (conditionedNoise X g))
      (stdGaussian (FrameVector n d)) ∧
    (∫ g, rowFourthDeviation ((d : ℝ) / n) (conditionedNoise X g)
      ∂stdGaussian (FrameVector n d)) ≤ 12 * (1 + (d : ℝ) ^ 2 / n) + 120024 := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  set C := tangentNoiseFactor X
  have hC := tangentNoiseFactor_operator_norm_sq_le X hn
  have hS : (∑ i, ((d : ℝ) / n - ∫ g, rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (FrameVector n d))) ≤ 1 + (d : ℝ) ^ 2 / n := by
    rw [Finset.sum_sub_distrib, ← integral_finsetSum _ (fun i _ =>
      (memLp_rowNormSq_gaussianImage C i).integrable (by norm_num))]
    simp_rw [totalEnergy_frameOfVector]
    rw [integral_tangentNoise_norm_sq]
    have hf := globalTangentSpace_finrank_ge X hn hd hX
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have h1 : (n : ℝ) * ((d : ℝ) / n) = d := by field_simp
    rw [h1]
    have h2 : (d : ℝ) - 1 - (d : ℝ) ^ 2 / n ≤
        (Module.finrank ℝ (globalTangentSpace X) : ℝ) / n := by
      rw [le_div_iff₀ hnR]
      have : ((d : ℝ) - 1 - (d : ℝ) ^ 2 / n) * n = n * ((d : ℝ) - 1) - (d : ℝ) ^ 2 := by
        field_simp
      linarith
    linarith
  have h := integral_rowFourthDeviation_le C hn hd hC _ hS
  have h2 := h.2
  simp only [C] at h2
  exact ⟨h.1, by unfold conditionedNoise; linarith⟩

end Paulsen.Linear
