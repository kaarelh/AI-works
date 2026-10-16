import NeuralGeneralization.GaussianSmallBall
import NeuralGeneralization.GaussianMatrixTail

/-!
# Gaussian cylinders with free matrix directions

This file proves genuine product-law probabilities, including independence
between constrained coordinates and the unconstrained Gaussian residual.
The interval radius scales with the standard deviation, so its prefactor
has no dependence on width or variance.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.GaussianTail

variable {ι : Type*} [Fintype ι]

/-- Splitting a finite coordinate set into constrained and free coordinates
preserves the product law, including for arbitrary (possibly unmeasurable)
events. The latter is justified by a measurable equivalence. -/
theorem gaussian_split_cylinder_measure (v : ℝ≥0) (p : ι → Prop)
    [DecidablePred p] (A : Set ({i // p i} → ℝ))
    (B : Set ({i // ¬p i} → ℝ)) :
    (Measure.pi fun _ : ι => gaussianReal 0 v)
      ((MeasurableEquiv.piEquivPiSubtypeProd (fun _ : ι => ℝ) p) ⁻¹' (A ×ˢ B)) =
    (Measure.pi fun _ : {i // p i} => gaussianReal 0 v) A *
      (Measure.pi fun _ : {i // ¬p i} => gaussianReal 0 v) B := by
  rw [← MeasurableEquiv.map_apply,
    (measurePreserving_piEquivPiSubtypeProd (fun _ : ι => gaussianReal 0 v) p).map_eq,
    Measure.prod_prod]

theorem gaussian_split_cylinder_real (v : ℝ≥0) (p : ι → Prop)
    [DecidablePred p] (A : Set ({i // p i} → ℝ))
    (B : Set ({i // ¬p i} → ℝ)) :
    (Measure.pi fun _ : ι => gaussianReal 0 v).real
      ((MeasurableEquiv.piEquivPiSubtypeProd (fun _ : ι => ℝ) p) ⁻¹' (A ×ˢ B)) =
    (Measure.pi fun _ : {i // p i} => gaussianReal 0 v).real A *
      (Measure.pi fun _ : {i // ¬p i} => gaussianReal 0 v).real B := by
  unfold Measure.real
  rw [gaussian_split_cylinder_measure, ENNReal.toReal_mul]

/-- Gaussian interval lower bound with radius proportional to its standard
deviation. The squared center enters with the natural inverse variance. -/
theorem gaussian_scaled_interval_mass_lower (a ρ σ : ℝ)
    (hρ : 0 ≤ ρ) (hσ : 0 < σ) :
    (2 * ρ / Real.sqrt (2 * Real.pi)) *
      Real.exp (-a ^ 2 / σ ^ 2 - ρ ^ 2) ≤
    (gaussianReal 0 (σ ^ 2).toNNReal).real
      (Set.Icc (a - ρ * σ) (a + ρ * σ)) := by
  have hv : (σ ^ 2).toNNReal ≠ 0 := by
    exact ne_of_gt (Real.toNNReal_pos.mpr (sq_pos_of_pos hσ))
  have h := gaussian_interval_mass_lower a (ρ * σ) (mul_nonneg hρ hσ.le)
    (σ ^ 2).toNNReal hv
  rw [Real.coe_toNNReal _ (sq_nonneg σ)] at h
  have hsqrt : Real.sqrt (2 * Real.pi * σ ^ 2) = Real.sqrt (2 * Real.pi) * σ := by
    rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hσ.le]
  rw [hsqrt] at h
  have hfactor : 2 * (ρ * σ) * (Real.sqrt (2 * Real.pi) * σ)⁻¹ =
      2 * ρ / Real.sqrt (2 * Real.pi) := by
    field_simp
  rw [hfactor] at h
  apply le_trans _ h
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Real.exp_le_exp.mpr
  have hsq : (|a| + ρ * σ) ^ 2 ≤ 2 * (a ^ 2 + (ρ * σ) ^ 2) := by
    nlinarith [sq_nonneg (|a| - ρ * σ), sq_abs a]
  have hden : 0 < σ ^ 2 := sq_pos_of_pos hσ
  field_simp
  nlinarith

/-- A constrained Gaussian rectangle pays its center energy and a cost per
constrained coordinate; no logarithm of the standard deviation is lost. -/
theorem gaussian_scaled_rectangle_mass_lower (a : ι → ℝ) (ρ σ : ℝ)
    (hρ : 0 ≤ ρ) (hσ : 0 < σ) :
    (2 * ρ / Real.sqrt (2 * Real.pi)) ^ Fintype.card ι *
      Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 - (Fintype.card ι : ℝ) * ρ ^ 2) ≤
    (Measure.pi fun _ : ι => gaussianReal 0 (σ ^ 2).toNNReal).real
      (Set.pi Set.univ fun i => Set.Icc (a i - ρ * σ) (a i + ρ * σ)) := by
  classical
  have hprod := Finset.prod_le_prod
    (s := Finset.univ)
    (f := fun i => (2 * ρ / Real.sqrt (2 * Real.pi)) *
      Real.exp (-(a i) ^ 2 / σ ^ 2 - ρ ^ 2))
    (g := fun i => (gaussianReal 0 (σ ^ 2).toNNReal).real
      (Set.Icc (a i - ρ * σ) (a i + ρ * σ)))
    (fun i _ => by positivity)
    (fun i _ => gaussian_scaled_interval_mass_lower (a i) ρ σ hρ hσ)
  have heq : (∏ i, (2 * ρ / Real.sqrt (2 * Real.pi)) *
      Real.exp (-(a i) ^ 2 / σ ^ 2 - ρ ^ 2)) =
    (2 * ρ / Real.sqrt (2 * Real.pi)) ^ Fintype.card ι *
      Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 - (Fintype.card ι : ℝ) * ρ ^ 2) := by
    rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ,
      ← Real.exp_sum]
    congr 1
    congr 1
    rw [Finset.sum_sub_distrib, ← Finset.sum_div, Finset.sum_neg_distrib,
      Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [heq] at hprod
  unfold Measure.real
  rw [Measure.pi_pi, ENNReal.toReal_prod]
  exact hprod

/-- A deliberately loose exponential prefactor avoids logarithms altogether.
For reciprocal-polynomial radii, its cost is itself polynomial. -/
theorem gaussian_radius_prefactor_lower (ρ : ℝ) (hρ : 0 < ρ) :
    Real.exp (-Real.sqrt (2 * Real.pi) / (2 * ρ)) ≤
      2 * ρ / Real.sqrt (2 * Real.pi) := by
  have hx : 0 < Real.sqrt (2 * Real.pi) / (2 * ρ) := by positivity
  have hexp : Real.sqrt (2 * Real.pi) / (2 * ρ) ≤
      Real.exp (Real.sqrt (2 * Real.pi) / (2 * ρ)) := by
    linarith [Real.add_one_le_exp (Real.sqrt (2 * Real.pi) / (2 * ρ))]
  have hinv := one_div_le_one_div_of_le hx hexp
  rw [one_div_div, one_div, ← Real.exp_neg] at hinv
  simpa only [neg_div] using hinv

/-- Pure exponential form of the constrained rectangle bound. -/
theorem gaussian_scaled_rectangle_exp_lower (a : ι → ℝ) (ρ σ : ℝ)
    (hρ : 0 < ρ) (hσ : 0 < σ) :
    Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 -
      (Fintype.card ι : ℝ) * (ρ ^ 2 + Real.sqrt (2 * Real.pi) / (2 * ρ))) ≤
    (Measure.pi fun _ : ι => gaussianReal 0 (σ ^ 2).toNNReal).real
      (Set.pi Set.univ fun i => Set.Icc (a i - ρ * σ) (a i + ρ * σ)) := by
  have hp := pow_le_pow_left₀ (Real.exp_nonneg _) (gaussian_radius_prefactor_lower ρ hρ)
    (Fintype.card ι)
  apply le_trans _ (gaussian_scaled_rectangle_mass_lower a ρ σ hρ.le hσ)
  calc
    _ = Real.exp (-Real.sqrt (2 * Real.pi) / (2 * ρ)) ^ Fintype.card ι *
        Real.exp (-(∑ i, a i ^ 2) / σ ^ 2 - (Fintype.card ι : ℝ) * ρ ^ 2) := by
      rw [← Real.exp_nat_mul, ← Real.exp_add]
      congr 1
      ring
    _ ≤ _ := mul_le_mul_of_nonneg_right hp (Real.exp_nonneg _)

/-- A free Gaussian matrix has positive mass in a norm ball whenever the
chosen scale dominates half the total matrix dimension. -/
theorem gaussian_matrix_good_mass_at_scale {m n : Type*} [Fintype m] [Fintype n]
    (M : ℕ) (hm : 1 ≤ M) (hn : Fintype.card m + Fintype.card n ≤ M + M)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (1 : ℝ) / 2 ≤ (Measure.pi fun _ : m × n => gaussianReal 0 v).real
      {z | ‖coordinateMatrixOperator z‖ ≤
        16 * Real.sqrt ((M : ℝ) * v)} := by
  have h := gaussian_matrix_operator_tail (m := m) (n := n) v hv
    (8 * Real.sqrt ((M : ℝ) * v)) (by positivity)
  have hsq : (8 * Real.sqrt ((M : ℝ) * v)) ^ 2 / (2 * (v : ℝ)) = 32 * M := by
    rw [mul_pow, Real.sq_sqrt (by positivity)]
    field_simp
    ring
  have hexp : -(8 * Real.sqrt ((M : ℝ) * v)) ^ 2 / (2 * (v : ℝ)) = -32 * M := by
    rw [neg_div, hsq]
    ring
  have hscale : 2 * (8 * Real.sqrt ((M : ℝ) * v)) =
      16 * Real.sqrt ((M : ℝ) * v) := by ring
  rw [hexp, hscale] at h
  have hpow : (9 : ℝ) ^ (Fintype.card m + Fintype.card n) ≤ 9 ^ (M + M) :=
    pow_le_pow_right₀ (by norm_num) hn
  have htail : (Measure.pi fun _ : m × n => gaussianReal 0 v).real
      {z | 16 * Real.sqrt ((M : ℝ) * v) < ‖coordinateMatrixOperator z‖} ≤ 1 / 2 := by
    apply h.trans
    apply le_trans _ (matrix_net_tail_le_half M hm)
    exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hpow (by norm_num))
      (Real.exp_nonneg _)
  let μ : Measure (m × n → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let R := 16 * Real.sqrt ((M : ℝ) * v)
  have hcover : {z | ‖coordinateMatrixOperator z‖ ≤ R} ∪
      {z : m × n → ℝ | R < ‖coordinateMatrixOperator z‖} = Set.univ := by
    ext z
    simp only [Set.mem_union, Set.mem_setOf_eq, Set.mem_univ, iff_true]
    exact le_or_gt _ _
  have hh := measureReal_union_le (μ := μ)
    {z | ‖coordinateMatrixOperator z‖ ≤ R} {z | R < ‖coordinateMatrixOperator z‖}
  rw [hcover, probReal_univ] at hh
  change μ.real {z | R < ‖coordinateMatrixOperator z‖} ≤ 1 / 2 at htail
  change 1 / 2 ≤ μ.real {z | ‖coordinateMatrixOperator z‖ ≤ R}
  linarith

/-- In particular the row count is a valid scale when columns do not outnumber rows. -/
theorem gaussian_rectangular_matrix_good_mass {m n : Type*} [Fintype m] [Fintype n]
    (hm : 1 ≤ Fintype.card m) (hn : Fintype.card n ≤ Fintype.card m)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (1 : ℝ) / 2 ≤ (Measure.pi fun _ : m × n => gaussianReal 0 v).real
      {z | ‖coordinateMatrixOperator z‖ ≤
        16 * Real.sqrt ((Fintype.card m : ℝ) * v)} :=
  gaussian_matrix_good_mass_at_scale (Fintype.card m) hm
    (Nat.add_le_add_left hn _) v hv

end NeuralGeneralization.GaussianTail
