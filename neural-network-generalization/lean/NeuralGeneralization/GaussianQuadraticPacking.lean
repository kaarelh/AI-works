import NeuralGeneralization.GaussianStripPacking
import NeuralGeneralization.GaussianConeRadial

/-! Actual Gaussian quadratic moments and the ellipsoid packing estimate. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianTranslatePacking

variable {I J : Type*} [Fintype I] [Fintype J]

lemma memLp_rowForm (a : I → ℝ) : MemLp (rowForm a) 2 (standardGaussian (I := I)) := by
  have h := memLp_finsetSum' Finset.univ
    (fun i (_ : i ∈ Finset.univ) => (GaussianConeRadial.memLp_eval i).const_mul (a i))
  have heq : (∑ i, (fun y : I → ℝ => a i*y i)) = rowForm a := by
    ext y
    simp only [Finset.sum_apply, rowForm]
  rw [heq] at h
  exact h

lemma integral_rowForm (a : I → ℝ) :
    (∫ y, rowForm a y ∂standardGaussian (I := I)) = 0 := by
  unfold rowForm standardGaussian
  rw [integral_finsetSum _ (fun i _ =>
    ((GaussianConeRadial.memLp_eval i).integrable (by norm_num)).const_mul (a i))]
  have hi (i : I) : (∫ y : I → ℝ, a i*y i ∂Measure.pi (fun _ : I => gaussianReal 0 1)) = 0 := by
    rw [integral_const_mul, integral_comp_eval (μ := fun _ : I => gaussianReal 0 1)
      (i := i) (f := fun y : ℝ => y) (by fun_prop)]
    simp
  simp only [hi, Finset.sum_const_zero]

theorem integral_rowForm_square (a : I → ℝ) :
    (∫ y, rowForm a y ^ 2 ∂standardGaussian (I := I)) = ∑ i, a i^2 := by
  have hvar := variance_sum_pi (μ := fun _ : I => gaussianReal 0 1)
    (X := fun i => fun x : ℝ => a i*x)
    (fun i => (memLp_id_gaussianReal (μ := 0) (v := 1) 2).const_mul (a i))
  have heq : (∑ i, (fun y : I → ℝ => a i*y i)) = rowForm a := by
    ext y
    simp only [Finset.sum_apply, rowForm]
  rw [heq] at hvar
  change variance (rowForm a) (standardGaussian (I := I)) = _ at hvar
  rw [variance_eq_sub (memLp_rowForm a), integral_rowForm] at hvar
  simp only [zero_pow (by decide : 2 ≠ 0), sub_zero, Pi.pow_apply] at hvar
  rw [hvar]
  apply Finset.sum_congr rfl
  intro i _
  change variance (fun x : ℝ => a i*id x) (gaussianReal 0 1) = _
  rw [variance_const_mul, variance_id_gaussianReal]
  norm_num

def squaredImageNorm (a : J → I → ℝ) (y : I → ℝ) : ℝ :=
  ∑ j, rowForm (a j) y ^ 2

lemma squaredImageNorm_smul (a : J → I → ℝ) (y : I → ℝ) (s : ℝ) :
    squaredImageNorm a (s • y) = s^2*squaredImageNorm a y := by
  simp only [squaredImageNorm, rowForm_smul, mul_pow, Finset.mul_sum]

lemma squaredImageNorm_nonneg (a : J → I → ℝ) (y : I → ℝ) :
    0 ≤ squaredImageNorm a y := Finset.sum_nonneg (fun _ _ => sq_nonneg _)

lemma integrable_squaredImageNorm (a : J → I → ℝ) :
    Integrable (squaredImageNorm a) (standardGaussian (I := I)) := by
  unfold squaredImageNorm
  apply integrable_finsetSum
  intro j _
  exact (memLp_rowForm (a j)).integrable_sq

theorem integral_squaredImageNorm (a : J → I → ℝ) :
    (∫ y, squaredImageNorm a y ∂standardGaussian (I := I)) = ∑ j, ∑ i, a j i^2 := by
  unfold squaredImageNorm
  rw [integral_finsetSum _ (fun j _ => (memLp_rowForm (a j)).integrable_sq)]
  simp_rw [integral_rowForm_square]

def quadraticBall (a : J → I → ℝ) (t : ℝ) : Set (I → ℝ) :=
  {y | squaredImageNorm a y < t}

lemma measurableSet_quadraticBall (a : J → I → ℝ) (t : ℝ) : MeasurableSet (quadraticBall a t) := by
  unfold quadraticBall squaredImageNorm rowForm
  exact measurableSet_lt (by fun_prop) measurable_const

lemma quadraticBall_symmetric (a : J → I → ℝ) (t : ℝ) (y : I → ℝ) :
    -y ∈ quadraticBall a t ↔ y ∈ quadraticBall a t := by
  simp only [quadraticBall, Set.mem_setOf_eq, squaredImageNorm, rowForm_neg, neg_sq]

theorem gaussian_quadraticBall_halfmass (a : J → I → ℝ) (V : ℝ) (hV : 0 < V)
    (htrace : (∑ j, ∑ i, a j i^2) ≤ V) :
    (1:ℝ)/2 ≤ (standardGaussian (I := I)).real (quadraticBall a (2*V)) := by
  have hm := mul_meas_ge_le_integral_of_nonneg
    (ae_of_all _ (squaredImageNorm_nonneg a)) (integrable_squaredImageNorm a) (2*V)
  rw [integral_squaredImageNorm] at hm
  have hc : {y | 2*V ≤ squaredImageNorm a y} = (quadraticBall a (2*V))ᶜ := by
    ext y
    simp only [quadraticBall, Set.mem_compl_iff, Set.mem_setOf_eq, not_lt]
  rw [hc, probReal_compl_eq_one_sub (measurableSet_quadraticBall a (2*V))] at hm
  nlinarith only [hm, htrace, hV]

theorem quadraticBall_translates_disjoint (a : J → I → ℝ) (V : ℝ) (x y : I → ℝ)
    (hsep : 8*V ≤ squaredImageNorm a (x-y)) :
    Disjoint (translateSet x (quadraticBall a (2*V)))
      (translateSet y (quadraticBall a (2*V))) := by
  rw [Set.disjoint_left]
  intro z hx hy
  have hx' : squaredImageNorm a (z-x) < 2*V := hx
  have hy' : squaredImageNorm a (z-y) < 2*V := hy
  have hpoint (j : J) : rowForm (a j) (x-y)^2 ≤
      2*(rowForm (a j) (z-x)^2+rowForm (a j) (z-y)^2) := by
    simp only [rowForm_sub]
    nlinarith only [sq_nonneg (2*rowForm (a j) z-rowForm (a j) x-rowForm (a j) y)]
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hpoint j)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hsum
  change squaredImageNorm a (x-y) ≤ 2*(squaredImageNorm a (z-x)+squaredImageNorm a (z-y)) at hsum
  linarith

/-- The Euclidean-image counterpart to the strip packing estimate. The
right side depends on the actual trace, with no logarithm in row count. -/
theorem gaussian_quadratic_packing {K : Type*} [Fintype K]
    (a : J → I → ℝ) (x : K → I → ℝ) (V R : ℝ) (hV : 0 < V)
    (htrace : (∑ j, ∑ i, a j i^2) ≤ V)
    (hsep : ∀ i j, i ≠ j → 8*V ≤ squaredImageNorm a (x i-x j))
    (hR : ∀ j, (∑ i, x j i^2) ≤ R) :
    (Fintype.card K : ℝ) ≤ 2*Real.exp (R/2) :=
  gaussian_translate_packing x (quadraticBall a (2*V)) (measurableSet_quadraticBall a (2*V))
    (quadraticBall_symmetric a (2*V)) (gaussian_quadraticBall_halfmass a V hV htrace)
    (fun _ _ hij => quadraticBall_translates_disjoint a V _ _ (hsep _ _ hij)) R hR

theorem gaussian_quadratic_packing_scaled {K : Type*} [Fintype K]
    (a : J → I → ℝ) (x : K → I → ℝ) (V R s : ℝ) (hV : 0 < V)
    (htrace : (∑ j, ∑ i, a j i^2) ≤ V)
    (hsep : ∀ i j, i ≠ j → 8*V ≤ s^2*squaredImageNorm a (x i-x j))
    (hR : ∀ j, (∑ i, x j i^2) ≤ R) :
    (Fintype.card K : ℝ) ≤ 2*Real.exp (s^2*R/2) := by
  apply gaussian_quadratic_packing a (fun j => s • x j) V (s^2*R) hV htrace
  · intro i j hij
    rw [← smul_sub, squaredImageNorm_smul]
    exact hsep i j hij
  · intro j
    simp only [Pi.smul_apply, smul_eq_mul, mul_pow, ← Finset.mul_sum]
    exact mul_le_mul_of_nonneg_left (hR j) (sq_nonneg s)

/-- Explicit dual-Sudakov bound for an actual Euclidean image seminorm.
The trace of its row Gram matrix supplies the Gaussian parameter. -/
theorem euclidean_image_packing_bound {K : Type*} [Fintype K]
    (a : J → I → ℝ) (x : K → I → ℝ) (V R ε : ℝ) (hV : 0 < V) (hε : 0 < ε)
    (htrace : (∑ j, ∑ i, a j i^2) ≤ V)
    (hsep : ∀ i j, i ≠ j → ε^2 ≤ squaredImageNorm a (x i-x j))
    (hR : ∀ j, (∑ i, x j i^2) ≤ R) :
    (Fintype.card K : ℝ) ≤ 2*Real.exp (4*R*V/ε^2) := by
  let s := Real.sqrt (8*V)/ε
  have hs2 : s^2 = 8*V/ε^2 := by
    dsimp only [s]
    rw [div_pow, Real.sq_sqrt (by positivity)]
  have h := gaussian_quadratic_packing_scaled a x V R s hV htrace
    (fun i j hij => by
      have hh := mul_le_mul_of_nonneg_left (hsep i j hij) (sq_nonneg s)
      have he : s^2*ε^2 = 8*V := by rw [hs2]; field_simp
      rwa [he] at hh) hR
  have he : s^2*R/2 = 4*R*V/ε^2 := by rw [hs2]; ring
  rwa [he] at h

end NeuralGeneralization.GaussianTranslatePacking
