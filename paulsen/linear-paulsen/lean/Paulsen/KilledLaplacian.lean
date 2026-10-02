import Paulsen.SchurPoisson
import Mathlib.Algebra.Order.Chebyshev

/-!
# Coercive killed graph matrices

These finite-dimensional lemmas prove positivity and quantitative row-sum
bounds for the inverse of a matrix with nonpositive off-diagonal entries.
The hypothesis is an explicit quadratic coercivity estimate.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The elementary negative-part argument for a coercive Z-matrix. -/
theorem nonneg_of_coercive_mulVec_nonneg
    (D : Matrix ι ι ℝ) (δ : ℝ) (hδ : 0 < δ)
    (hoff : ∀ i j, i ≠ j → D i j ≤ 0)
    (hcoerce : ∀ x : ι → ℝ, δ * (∑ i, x i ^ 2) ≤ ∑ i, x i * (D *ᵥ x) i)
    (x : ι → ℝ) (hx : ∀ i, 0 ≤ (D *ᵥ x) i) :
    ∀ i, 0 ≤ x i := by
  let y : ι → ℝ := fun i => min (x i) 0
  let z : ι → ℝ := fun i => max (x i) 0
  have hsplit : x = y + z := by
    ext i
    change x i = min (x i) 0 + max (x i) 0
    simpa only [add_zero] using (min_add_max (x i) 0).symm
  have hcross : 0 ≤ ∑ i, y i * (D *ᵥ z) i := by
    apply Finset.sum_nonneg
    intro i _
    change 0 ≤ y i * ∑ j, D i j * z j
    rw [Finset.mul_sum]
    apply Finset.sum_nonneg
    intro j _
    by_cases hij : i = j
    · subst j
      dsimp only [y, z]
      by_cases hxi : 0 ≤ x i
      · rw [min_eq_right hxi]
        simp
      · have hxi' : x i ≤ 0 := le_of_not_ge hxi
        rw [max_eq_right hxi']
        simp
    · have hy : y i ≤ 0 := min_le_right _ _
      have hz : 0 ≤ z j := le_max_right _ _
      exact mul_nonneg_of_nonpos_of_nonpos hy (mul_nonpos_of_nonpos_of_nonneg (hoff i j hij) hz)
  have htotal : (∑ i, y i * (D *ᵥ x) i) ≤ 0 := by
    apply Finset.sum_nonpos
    intro i _
    exact mul_nonpos_of_nonpos_of_nonneg (min_le_right _ _) (hx i)
  have henergy := hcoerce y
  have hdecomp : (∑ i, y i * (D *ᵥ x) i) =
      (∑ i, y i * (D *ᵥ y) i) + ∑ i, y i * (D *ᵥ z) i := by
    rw [hsplit, Matrix.mulVec_add]
    simp only [Pi.add_apply, mul_add, Finset.sum_add_distrib]
  have hsum : (∑ i, y i ^ 2) ≤ 0 := by nlinarith
  intro i
  have hi : y i ^ 2 ≤ ∑ j, y j ^ 2 :=
    Finset.single_le_sum (fun j _ => sq_nonneg (y j)) (Finset.mem_univ i)
  have hyi : y i = 0 := by nlinarith [sq_nonneg (y i)]
  have : min (x i) 0 = 0 := hyi
  exact (min_eq_right_iff).mp this

/-- Coercivity gives the two-sided nonsingular inverse and its entrywise
nonnegativity. No spectral theorem is used. -/
theorem coercive_zMatrix_inverse
    (D : Matrix ι ι ℝ) (δ : ℝ) (hδ : 0 < δ)
    (hoff : ∀ i j, i ≠ j → D i j ≤ 0)
    (hcoerce : ∀ x : ι → ℝ, δ * (∑ i, x i ^ 2) ≤ ∑ i, x i * (D *ᵥ x) i) :
    D * D⁻¹ = 1 ∧ D⁻¹ * D = 1 ∧ (∀ i j, 0 ≤ D⁻¹ i j) := by
  have hker : ∀ x : ι → ℝ, D *ᵥ x = 0 → x = 0 := by
    intro x hx
    have he := hcoerce x
    simp only [hx, Pi.zero_apply, mul_zero, Finset.sum_const_zero] at he
    have hs : (∑ i, x i ^ 2) ≤ 0 := by nlinarith
    ext i
    have hi : x i ^ 2 ≤ ∑ j, x j ^ 2 :=
      Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)
    change x i = 0
    nlinarith [sq_nonneg (x i)]
  have hinj : Function.Injective D.mulVec := by
    intro x y hxy
    have hzero : D *ᵥ (x - y) = 0 := by rw [Matrix.mulVec_sub, hxy, sub_self]
    exact sub_eq_zero.mp (hker (x - y) hzero)
  have hu := Matrix.mulVec_injective_iff_isUnit.mp hinj
  have hdet := (Matrix.isUnit_iff_isUnit_det D).mp hu
  have hDR := Matrix.mul_nonsing_inv D hdet
  have hRD := Matrix.nonsing_inv_mul D hdet
  refine ⟨hDR, hRD, ?_⟩
  intro i j
  let x : ι → ℝ := fun k => D⁻¹ k j
  have hx : ∀ k, 0 ≤ (D *ᵥ x) k := by
    intro k
    change 0 ≤ (D * D⁻¹) k j
    rw [hDR]
    simp only [Matrix.one_apply]
    split_ifs <;> norm_num
  exact nonneg_of_coercive_mulVec_nonneg D δ hδ hoff hcoerce x hx i

/-- A deliberately nonoptimal entrywise inverse estimate. Its dependence on
the matrix size is harmless when the killed set has bounded cardinality. -/
theorem coercive_inverse_entry_bound
    (D : Matrix ι ι ℝ) (δ : ℝ) (hδ : 0 < δ)
    (hcoerce : ∀ x : ι → ℝ, δ * (∑ i, x i ^ 2) ≤ ∑ i, x i * (D *ᵥ x) i)
    (hDR : D * D⁻¹ = 1) (i j : ι) :
    |D⁻¹ i j| ≤ 1 / δ := by
  let x : ι → ℝ := fun k => D⁻¹ k j
  have hx : D *ᵥ x = fun k => if k = j then 1 else 0 := by
    ext k
    change (D * D⁻¹) k j = _
    rw [hDR, Matrix.one_apply]
  have he := hcoerce x
  rw [hx] at he
  simp only [mul_ite, mul_one, mul_zero, Finset.sum_ite_eq', Finset.mem_univ,
    if_true] at he
  have he' := mul_le_mul_of_nonneg_left he (le_of_lt hδ)
  have hi : x i ^ 2 ≤ ∑ k, x k ^ 2 :=
    Finset.single_le_sum (fun k _ => sq_nonneg (x k)) (Finset.mem_univ i)
  have hj : x j ^ 2 ≤ ∑ k, x k ^ 2 :=
    Finset.single_le_sum (fun k _ => sq_nonneg (x k)) (Finset.mem_univ j)
  have hδ2 : 0 ≤ δ ^ 2 := sq_nonneg δ
  have hi' := mul_le_mul_of_nonneg_left hi hδ2
  have hj' := mul_le_mul_of_nonneg_left hj hδ2
  have hj1 : δ * x j ≤ 1 := by nlinarith [sq_nonneg (δ * x j - 1)]
  have hib : |δ * x i| ≤ 1 := by
    rw [abs_le]
    constructor <;> nlinarith [sq_nonneg (δ * x i - 1), sq_nonneg (δ * x i + 1)]
  rw [abs_mul, abs_of_pos hδ] at hib
  change |x i| ≤ 1 / δ
  exact (le_div_iff₀ hδ).mpr (by nlinarith)

/-- Quantitative absolute row-sum estimate for the killed inverse. -/
theorem coercive_inverse_row_bound
    (D : Matrix ι ι ℝ) (δ : ℝ) (hδ : 0 < δ)
    (hcoerce : ∀ x : ι → ℝ, δ * (∑ i, x i ^ 2) ≤ ∑ i, x i * (D *ᵥ x) i)
    (hDR : D * D⁻¹ = 1) (i : ι) :
    (∑ j, |D⁻¹ i j|) ≤ (Fintype.card ι : ℝ) / δ := by
  calc
    _ ≤ ∑ j : ι, 1 / δ := Finset.sum_le_sum (fun j _ =>
      coercive_inverse_entry_bound D δ hδ hcoerce hDR i j)
    _ = _ := by simp [nsmul_eq_mul, div_eq_mul_inv]

omit [DecidableEq ι] in
/-- Restricting a spectral-gap inequality to a coordinate block gives a
coercive killed matrix. The loss is exactly the proportion of killed vertices. -/
theorem killed_coercivity_of_gap
    {κ : Type*} [Fintype κ] [DecidableEq κ]
    (L : Matrix (κ ⊕ ι) (κ ⊕ ι) ℝ) (lam : ℝ) (hlam : 0 ≤ lam)
    (hgap : ∀ x : (κ ⊕ ι) → ℝ,
      lam * ((∑ i, x i ^ 2) - (∑ i, x i) ^ 2 / (Fintype.card (κ ⊕ ι) : ℝ)) ≤
        ∑ i, x i * (L *ᵥ x) i)
    (x : ι → ℝ) :
    (lam * (1 - (Fintype.card ι : ℝ) / (Fintype.card (κ ⊕ ι) : ℝ))) *
      (∑ i, x i ^ 2) ≤
        ∑ i, x i * (L.submatrix Sum.inr Sum.inr *ᵥ x) i := by
  let y : (κ ⊕ ι) → ℝ := Sum.elim (fun _ => 0) x
  have hy2 : (∑ i, y i ^ 2) = ∑ i, x i ^ 2 := by simp [y, Fintype.sum_sum_type]
  have hy1 : (∑ i, y i) = ∑ i, x i := by simp [y, Fintype.sum_sum_type]
  have hyL : (∑ i, y i * (L *ᵥ y) i) =
      ∑ i, x i * (L.submatrix Sum.inr Sum.inr *ᵥ x) i := by
    simp [y, Matrix.mulVec, dotProduct, Fintype.sum_sum_type, Matrix.submatrix]
  have hg := hgap y
  rw [hy2, hy1, hyL] at hg
  have hc : (∑ i, x i) ^ 2 ≤ (Fintype.card ι : ℝ) * ∑ i, x i ^ 2 := by
    simpa only [Finset.card_univ] using
      (sq_sum_le_card_mul_sum_sq (s := Finset.univ) (f := x))
  have hdiv := div_le_div_of_nonneg_right hc
    (Nat.cast_nonneg (Fintype.card (κ ⊕ ι)) : (0 : ℝ) ≤ _)
  have hmul := mul_le_mul_of_nonneg_left hdiv hlam
  calc
    _ = lam * ((∑ i, x i ^ 2) -
        ((Fintype.card ι : ℝ) * ∑ i, x i ^ 2) / (Fintype.card (κ ⊕ ι) : ℝ)) := by ring
    _ ≤ lam * ((∑ i, x i ^ 2) -
        (∑ i, x i) ^ 2 / (Fintype.card (κ ⊕ ι) : ℝ)) := by linarith
    _ ≤ _ := hg

end Paulsen
