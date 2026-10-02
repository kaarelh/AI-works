import Paulsen.TangentSeed
import Paulsen.Graph
import Paulsen.Energy

/-!
# Bounding the exact tangent remainder using only fourth moments

The elementary inequality 2|uv| ≤ u²+v² avoids fractional noise moments.
Only the sums of rᵢ and rᵢ² are needed; no maximum over noise rows appears.
-/

namespace Paulsen

open scoped BigOperators

theorem tangent_remainder_scalar_bound (u v a r t N : ℝ)
    (_ha : 0 ≤ a) (hr : 0 ≤ r) (_hN : 0 ≤ N)
    (hu : u ^ 2 ≤ a * N) (hv : v ^ 2 ≤ a * r * N) :
    |-(t ^ 3) * (r / (1 + t ^ 2 * r)) * (2 * u * v) -
      t ^ 4 * (r / (1 + t ^ 2 * r)) * (v ^ 2 - r * u ^ 2)| ≤
      (a * |t| ^ 3 * (r + r ^ 2) + 2 * a * t ^ 4 * r ^ 2) * N := by
  let c := r / (1 + t ^ 2 * r)
  have hden : 0 < 1 + t ^ 2 * r := by nlinarith [sq_nonneg t]
  have hc : 0 ≤ c := div_nonneg hr hden.le
  have hcr : c ≤ r := by
    apply (div_le_iff₀ hden).mpr
    nlinarith [mul_nonneg (sq_nonneg t) (sq_nonneg r)]
  have hcross : |2 * u * v| ≤ a * (1 + r) * N := by
    apply abs_le.mpr
    constructor <;> nlinarith [sq_nonneg (u - v), sq_nonneg (u + v)]
  have hquad : |v ^ 2 - r * u ^ 2| ≤ 2 * a * r * N := by
    have hur := mul_le_mul_of_nonneg_left hu hr
    apply abs_le.mpr
    constructor <;> nlinarith [sq_nonneg v, mul_nonneg hr (sq_nonneg u)]
  have ht4 : 0 ≤ t ^ 4 := by positivity
  calc
    _ ≤ |-(t ^ 3) * c * (2 * u * v)| + |t ^ 4 * c * (v ^ 2 - r * u ^ 2)| :=
      abs_sub _ _
    _ = |t| ^ 3 * (c * |2 * u * v|) + t ^ 4 * (c * |v ^ 2 - r * u ^ 2|) := by
      simp only [abs_mul, abs_neg, abs_pow, abs_of_nonneg hc,
        abs_of_nonneg ht4, mul_assoc]
    _ ≤ |t| ^ 3 * (r * (a * (1 + r) * N)) +
        t ^ 4 * (r * (2 * a * r * N)) := by
      apply add_le_add
      · exact mul_le_mul_of_nonneg_left
          (mul_le_mul hcr hcross (abs_nonneg _) (by positivity)) (by positivity)
      · exact mul_le_mul_of_nonneg_left
          (mul_le_mul hcr hquad (abs_nonneg _) (by positivity)) ht4
    _ = _ := by ring

theorem matrixQuadratic_row_product {d : ℕ} (u v x : Fin d → ℝ) :
    matrixQuadratic (Matrix.of fun j k => u j * v k) x =
      (∑ j, u j * x j) * (∑ k, v k * x k) := by
  unfold matrixQuadratic
  simp only [Matrix.of_apply]
  rw [Finset.sum_mul]
  simp_rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  ring

theorem matrixQuadratic_add {d : ℕ} (A B : Matrix (Fin d) (Fin d) ℝ)
    (x : Fin d → ℝ) :
    matrixQuadratic (A + B) x = matrixQuadratic A x + matrixQuadratic B x := by
  simp [matrixQuadratic, mul_add, add_mul, Finset.sum_add_distrib]

theorem matrixQuadratic_smul {d : ℕ} (c : ℝ) (A : Matrix (Fin d) (Fin d) ℝ)
    (x : Fin d → ℝ) :
    matrixQuadratic (c • A) x = c * matrixQuadratic A x := by
  simp only [matrixQuadratic, Matrix.smul_apply, smul_eq_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  ring

theorem matrixQuadratic_sum {b d : ℕ} (A : Fin b → Matrix (Fin d) (Fin d) ℝ)
    (x : Fin d → ℝ) :
    matrixQuadratic (∑ i, A i) x = ∑ i, matrixQuadratic (A i) x := by
  simp only [matrixQuadratic, Matrix.sum_apply, Finset.mul_sum, Finset.sum_mul]
  calc
    _ = ∑ j : Fin d, ∑ i : Fin b, ∑ k : Fin d, x j * A i j k * x k := by
      apply Finset.sum_congr rfl
      intro j _
      exact Finset.sum_comm
    _ = _ := Finset.sum_comm

theorem tangentRemainder_quadratic {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (x : Fin d → ℝ) :
    matrixQuadratic (tangentRemainder X Z a t) x =
      ∑ i : Fin n, (-(t ^ 3) * (tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i)) *
        (2 * (∑ j, X i j * x j) * (∑ j, Z i j * x j)) -
        t ^ 4 * (tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i)) *
        ((∑ j, Z i j * x j) ^ 2 - tangentRatio a Z i * (∑ j, X i j * x j) ^ 2)) := by
  let C (i : Fin n) : Matrix (Fin d) (Fin d) ℝ :=
    (-(t ^ 3) * (tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i))) •
      (Matrix.of (fun j k => X i j * Z i k) + Matrix.of (fun j k => Z i j * X i k)) -
    (t ^ 4 * (tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i))) •
      (Matrix.of (fun j k => Z i j * Z i k) -
        tangentRatio a Z i • Matrix.of (fun j k => X i j * X i k))
  have hR : tangentRemainder X Z a t = ∑ i, C i := by
    ext j k
    simp only [tangentRemainder, Matrix.of_apply, Matrix.sum_apply, C,
      Matrix.sub_apply, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
      Finset.sum_sub_distrib, Finset.mul_sum]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro i _ <;> ring
  rw [hR, matrixQuadratic_sum]
  apply Finset.sum_congr rfl
  intro i _
  simp only [C, matrixQuadratic_sub, matrixQuadratic_smul, matrixQuadratic_add,
    matrixQuadratic_row_product]
  ring

/-- A uniform quadratic-form bound for the exact nonlinear remainder.
The right side involves at most fourth powers of the noise coordinates. -/
theorem tangentRemainder_quadratic_bound {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (ha : 0 < a) (hx : ∀ i, rowNormSq X i = a)
    (x : Fin d → ℝ) :
    |matrixQuadratic (tangentRemainder X Z a t) x| ≤
      (a * |t| ^ 3 * (∑ i : Fin n, (tangentRatio a Z i + (tangentRatio a Z i) ^ 2)) +
        2 * a * t ^ 4 * (∑ i : Fin n, (tangentRatio a Z i) ^ 2)) * vectorNormSq x := by
  rw [tangentRemainder_quadratic]
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ (Finset.univ : Finset (Fin n))) =>
    tangent_remainder_scalar_bound (∑ j, X i j * x j) (∑ j, Z i j * x j)
      a (tangentRatio a Z i) t (vectorNormSq x) ha.le
      (tangentRatio_nonneg a ha Z i) (vectorNormSq_nonneg x)
      (by
        have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (X i) x
        change _ ≤ rowNormSq X i * vectorNormSq x at h
        rwa [hx] at h)
      (by
        have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (Z i) x
        change _ ≤ rowNormSq Z i * vectorNormSq x at h
        have heq : a * tangentRatio a Z i = rowNormSq Z i := by
          unfold tangentRatio
          field_simp
        rwa [heq]))
  convert hsum using 1
  simp only [Finset.sum_mul, Finset.mul_sum, Finset.sum_add_distrib, add_mul, mul_add]

theorem frameEnergy_eq_matrixQuadratic {n d : ℕ} (X : Frame n d)
    (x : Fin d → ℝ) :
    frameEnergy X x = matrixQuadratic (X.transpose * X) x := by
  rw [frameEnergy_eq_sum_gram]
  simp only [matrixQuadratic, Matrix.mul_apply, Matrix.transpose_apply]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  ring

/-- The exact expansion converts quadratic-noise and moment bounds into
the spectral error needed before final balancing. -/
theorem tangentSeed_isNearlyParseval_of_quadratic_bound {n d : ℕ}
    (X Z : Frame n d) (a t η q ρ : ℝ) (ha : 0 < a)
    (hx : ∀ i, rowNormSq X i = a) (hX : IsNearlyParseval η X)
    (hglobal : X.transpose * Z + Z.transpose * X = 0)
    (hQ : ∀ x, |matrixQuadratic (tangentQuadratic X Z a) x| ≤ q * vectorNormSq x)
    (hρ : a * |t| ^ 3 * (∑ i : Fin n, (tangentRatio a Z i + (tangentRatio a Z i) ^ 2)) +
      2 * a * t ^ 4 * (∑ i : Fin n, (tangentRatio a Z i) ^ 2) ≤ ρ) :
    IsNearlyParseval (η + t ^ 2 * q + ρ) (tangentSeed X Z a t) := by
  intro x
  have hR := (tangentRemainder_quadratic_bound X Z a t ha hx x).trans
    (mul_le_mul_of_nonneg_right hρ (vectorNormSq_nonneg x))
  have hQt := mul_le_mul_of_nonneg_left (hQ x) (sq_nonneg t)
  have hform : frameEnergy (tangentSeed X Z a t) x =
      frameEnergy X x + t ^ 2 * matrixQuadratic (tangentQuadratic X Z a) x +
        matrixQuadratic (tangentRemainder X Z a t) x := by
    rw [frameEnergy_eq_matrixQuadratic,
      tangentSeed_frameOperator_expansion X Z a t ha hglobal,
      matrixQuadratic_add, matrixQuadratic_add, matrixQuadratic_smul,
      ← frameEnergy_eq_matrixQuadratic]
  obtain ⟨hl, hu⟩ := hX x
  obtain ⟨hrl, hru⟩ := abs_le.mp hR
  have hql := mul_le_mul_of_nonneg_left (neg_abs_le
    (matrixQuadratic (tangentQuadratic X Z a) x)) (sq_nonneg t)
  have hqu := mul_le_mul_of_nonneg_left (le_abs_self
    (matrixQuadratic (tangentQuadratic X Z a) x)) (sq_nonneg t)
  rw [hform]
  constructor <;> nlinarith

end Paulsen
