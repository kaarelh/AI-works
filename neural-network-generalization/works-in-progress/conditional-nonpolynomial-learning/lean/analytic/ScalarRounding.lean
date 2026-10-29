import NormalizedTanh
import Mathlib.Algebra.Order.Round
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-! Actual uniform-grid rounding and perturbation bounds. Integer numerators
remain polynomially bounded when the real range and mesh denominator are. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def gridRound (Q : ℕ) (x : ℝ) : ℝ := (round ((Q:ℝ)*x):ℝ)/Q

theorem gridRound_error (Q : ℕ) (hQ : 0 < Q) (x : ℝ) :
    |x-gridRound Q x| ≤ 1/(2*(Q:ℝ)) := by
  have hQpos : 0 < (Q:ℝ) := Nat.cast_pos.mpr hQ
  have h := abs_sub_round ((Q:ℝ)*x)
  have heq : |x-gridRound Q x| = |(Q:ℝ)*x-(round ((Q:ℝ)*x):ℝ)|/(Q:ℝ) := by
    calc
      |x-gridRound Q x| = |((Q:ℝ)*x-(round ((Q:ℝ)*x):ℝ))/(Q:ℝ)| := by
        congr 1
        unfold gridRound
        field_simp
      _ = _ := by rw [abs_div, abs_of_pos hQpos]
  rw [heq]
  have hh := div_le_div_of_nonneg_right h hQpos.le
  calc
    _ ≤ (1/2)/(Q:ℝ) := hh
    _ = 1/(2*(Q:ℝ)) := by ring

theorem gridRound_numerator_bound (Q : ℕ) (x B : ℝ) (hx : |x| ≤ B) :
    |(round ((Q:ℝ)*x):ℝ)| ≤ (Q:ℝ)*B+1/2 := by
  have h := abs_sub_round ((Q:ℝ)*x)
  have htri := abs_sub_le (round ((Q:ℝ)*x):ℝ) ((Q:ℝ)*x) 0
  simp only [sub_zero, abs_sub_comm (round ((Q:ℝ)*x):ℝ),
    abs_mul, abs_of_nonneg (Nat.cast_nonneg Q : (0:ℝ) ≤ Q)] at htri
  have hh := mul_le_mul_of_nonneg_left hx (Nat.cast_nonneg Q : (0:ℝ) ≤ Q)
  linarith

/-- Errors in a coefficient and scalar input cost only a polynomial factor. -/
theorem product_perturbation (a a' x x' A U δ : ℝ)
    (hA : 0 ≤ A) (hU : 0 ≤ U) (hδ : 0 ≤ δ)
    (ha : |a| ≤ A) (hx : |x| ≤ U) (hea : |a-a'| ≤ δ) (hex : |x-x'| ≤ δ) :
    |a*x-a'*x'| ≤ δ*(A+U+δ) := by
  have hx' : |x'| ≤ U+δ := by
    have hh := abs_sub_le x' x 0
    simp only [sub_zero, abs_sub_comm x' x] at hh
    linarith
  have hid : a*x-a'*x' = a*(x-x')+(a-a')*x' := by ring
  rw [hid]
  have htri := abs_add_le (a*(x-x')) ((a-a')*x')
  rw [abs_mul, abs_mul] at htri
  have h0 := mul_le_mul ha hex (abs_nonneg _) hA
  have h1 := mul_le_mul hea hx' (abs_nonneg _) hδ
  nlinarith

theorem affine_perturbation {ι : Type*} [Fintype ι]
    (a a' x x' : ι → ℝ) (A U δ : ℝ)
    (hA : 0 ≤ A) (hU : 0 ≤ U) (hδ : 0 ≤ δ)
    (ha : ∀ i, |a i| ≤ A) (hx : ∀ i, |x i| ≤ U)
    (hea : ∀ i, |a i-a' i| ≤ δ) (hex : ∀ i, |x i-x' i| ≤ δ) :
    |(∑ i, a i*x i)-(∑ i, a' i*x' i)| ≤ (Fintype.card ι:ℝ)*δ*(A+U+δ) := by
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ i, |a i*x i-a' i*x' i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : ι, δ*(A+U+δ) := Finset.sum_le_sum fun i _ =>
      product_perturbation _ _ _ _ A U δ hA hU hδ (ha i) (hx i) (hea i) (hex i)
    _ = (Fintype.card ι:ℝ)*δ*(A+U+δ) := by simp; ring

/-- Rounding before and after an arbitrary normalized tanh retains a uniform
error bound independent of its possibly enormous scalar scale. -/
theorem normalizedTanh_rounding (a s s' : ℝ) (Q : ℕ) (hQ : 0 < Q) (η : ℝ)
    (hs : |s-s'| ≤ η) :
    |normalizedTanh a s-gridRound Q (normalizedTanh a s')| ≤ η+1/(2*(Q:ℝ)) := by
  have h0 := normalizedTanh_lipschitz a s s'
  have h1 := gridRound_error Q hQ (normalizedTanh a s')
  have ht := abs_sub_le (normalizedTanh a s) (normalizedTanh a s')
    (gridRound Q (normalizedTanh a s'))
  linarith

#print axioms gridRound_error
#print axioms affine_perturbation
#print axioms normalizedTanh_rounding
end ConditionalNonpolynomial.Analytic
