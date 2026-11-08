import NeuralGeneralization.OnlineLowerTanhParity
import Mathlib.Analysis.SpecificLimits.Normed
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Analysis.Real.Pi.Bounds

/-! # Elementary harmonic domination for the actual tanh periodic series

These estimates replace heat-kernel and Jacobi-function arguments: the
fundamental harmonic dominates the weighted higher-harmonic tail.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

theorem abs_sin_nat_mul_le (n : ℕ) (x : ℝ) :
    |Real.sin ((n : ℝ) * x)| ≤ (n : ℝ) * |Real.sin x| := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Nat.cast_add, Nat.cast_one, add_mul, one_mul, Real.sin_add]
      calc
        _ ≤ |Real.sin ((n : ℝ) * x) * Real.cos x| +
            |Real.cos ((n : ℝ) * x) * Real.sin x| := abs_add_le _ _
        _ ≤ |Real.sin ((n : ℝ) * x)| + |Real.sin x| := by
          simp only [abs_mul]
          have h1 := mul_le_mul_of_nonneg_left (Real.abs_cos_le_one x)
            (abs_nonneg (Real.sin ((n : ℝ) * x)))
          have h2 := mul_le_mul_of_nonneg_right (Real.abs_cos_le_one ((n : ℝ) * x))
            (abs_nonneg (Real.sin x))
          nlinarith
        _ ≤ ((n : ℝ) + 1) * |Real.sin x| := by nlinarith

theorem one_sub_cos_nat_mul_le (n : ℕ) (x : ℝ) :
    1 - Real.cos ((n : ℝ) * x) ≤ (n : ℝ)^2 * (1 - Real.cos x) := by
  have h := abs_sin_nat_mul_le n (x / 2)
  have hs := mul_self_le_mul_self (abs_nonneg _) h
  simp only [← pow_two, sq_abs, mul_pow] at hs
  have hx := Real.cos_two_mul (x/2)
  have hn := Real.cos_two_mul ((n : ℝ)*x/2)
  have hx' := Real.sin_sq_add_cos_sq (x/2)
  have hn' := Real.sin_sq_add_cos_sq ((n : ℝ)*x/2)
  rw [show 2*(x/2)=x by ring] at hx
  rw [show 2*((n : ℝ)*x/2)=(n : ℝ)*x by ring] at hn
  rw [show (n : ℝ)*(x/2)=(n : ℝ)*x/2 by ring] at hs
  nlinarith

/-- Every odd harmonic cosine is bounded by its degree times the
fundamental cosine inside its positive half-wave. -/
theorem abs_cos_odd_mul_le (j : ℕ) (x : ℝ) (hx : x ∈ Set.Icc (-Real.pi/2) (Real.pi/2)) :
    |Real.cos ((2*(j : ℝ)+1)*x)| ≤ (2*(j : ℝ)+1)*Real.cos x := by
  have h := abs_sin_nat_mul_le (2*j+1) (Real.pi/2-x)
  have hsin : Real.sin (((2*j+1 : ℕ) : ℝ) * (Real.pi/2-x)) =
      (-1 : ℝ)^j * Real.cos ((2*(j : ℝ)+1)*x) := by
    have he : (((2*j+1 : ℕ) : ℝ) * (Real.pi/2-x)) =
        (j : ℝ)*Real.pi + (Real.pi/2-(2*(j : ℝ)+1)*x) := by push_cast; ring
    rw [he, Real.sin_add, Real.sin_nat_mul_pi, Real.cos_nat_mul_pi]
    simp [Real.sin_pi_div_two_sub]
  have hcos : 0 ≤ Real.cos x := Real.cos_nonneg_of_mem_Icc (by simpa only [neg_div] using hx)
  rw [hsin, abs_mul, abs_neg_one_pow, one_mul, Real.sin_pi_div_two_sub,
    abs_of_nonneg hcos] at h
  simpa only [Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one] using h

/-- Polynomial tail bound in a form with nonnegative generating-function coefficients. -/
theorem odd_square_choose (j : ℕ) :
    (2*(j : ℝ)+3)^2 = 8*((j+2).choose 2 : ℝ)+1 := by
  have hn := Nat.descFactorial_eq_factorial_mul_choose (j+2) 2
  simp [Nat.descFactorial_succ] at hn
  have h : ((j : ℝ)+2)*((j : ℝ)+1) = 2*((j+2).choose 2 : ℝ) := by exact_mod_cast (by simpa only [Nat.mul_comm] using hn : (j+2)*(j+1)=2*(j+2).choose 2)
  nlinarith

theorem summable_odd_square_geometric {q : ℝ} (hq : |q| < 1) :
    Summable (fun j : ℕ => (2*(j : ℝ)+3)^2 * q^(j+1)) := by
  have h := ((summable_choose_mul_geometric_of_norm_lt_one 2 hq).mul_left (8 : ℝ)).add
    (summable_geometric_of_abs_lt_one hq)
  have hh := h.mul_right q
  apply hh.congr
  intro j
  rw [odd_square_choose, pow_succ]
  ring

theorem tsum_odd_square_geometric {q : ℝ} (hq : |q| < 1) :
    (∑' j : ℕ, (2*(j : ℝ)+3)^2 * q^(j+1)) =
      q * (8/(1-q)^3 + 1/(1-q)) := by
  have hchoose := hasSum_choose_mul_geometric_of_norm_lt_one 2 (r := q) hq
  have hgeom := hasSum_geometric_of_abs_lt_one hq
  have h := ((hchoose.mul_left (8 : ℝ)).add hgeom).mul_right q
  have he (j : ℕ) : (8 * ((j+2).choose 2 : ℝ) * q^j + q^j) * q =
      (2*(j : ℝ)+3)^2 * q^(j+1) := by rw [odd_square_choose, pow_succ]; ring
  calc
    _ = ∑' j : ℕ, (8 * (((j+2).choose 2 : ℝ) * q^j) + q^j) * q := by
      apply tsum_congr
      intro j
      rw [odd_square_choose, pow_succ]
      ring
    _ = _ := by rw [h.tsum_eq]; ring


theorem odd_square_tail_bound {q : ℝ} (hq0 : 0 ≤ q) (hq : q ≤ 17/200) :
    (∑' j : ℕ, (2*(j : ℝ)+3)^2 * q^(j+1)) ≤ 99/100 := by
  have hq1 : |q| < 1 := by rw [abs_of_nonneg hq0]; linarith
  have hsmall : |(17/200 : ℝ)| < 1 := by norm_num
  calc
    _ ≤ ∑' j : ℕ, (2*(j : ℝ)+3)^2 * (17/200 : ℝ)^(j+1) :=
      Summable.tsum_le_tsum (fun j => mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hq0 hq _) (sq_nonneg _))
        (summable_odd_square_geometric hq1) (summable_odd_square_geometric hsmall)
    _ ≤ _ := by rw [tsum_odd_square_geometric hsmall]; norm_num

theorem geometric_tail_sum {q : ℝ} (hq : |q| < 1) :
    (∑' j : ℕ, q^(j+1)) = q/(1-q) := by
  simp_rw [pow_succ]
  rw [(summable_geometric_of_abs_lt_one hq).tsum_mul_right,
    tsum_geometric_of_abs_lt_one hq]
  ring

theorem geometric_tail_bound {q : ℝ} (hq0 : 0 ≤ q) (hq : q ≤ 17/200) :
    (∑' j : ℕ, q^(j+1)) ≤ 1/10 := by
  have hq1 : |q| < 1 := by rw [abs_of_nonneg hq0]; linarith
  rw [geometric_tail_sum hq1]
  apply (div_le_iff₀ (by linarith : 0 < 1-q)).mpr
  linarith

theorem summable_excess_square_geometric {q : ℝ} (hq : |q| < 1) :
    Summable (fun j : ℕ => ((2*(j : ℝ)+3)^2-1)*q^(j+1)) := by
  have h := (summable_odd_square_geometric hq).sub
    ((summable_geometric_of_abs_lt_one hq).comp_injective Nat.succ_injective)
  apply h.congr
  intro j
  simp only [Function.comp_apply, Nat.succ_eq_add_one]
  ring

theorem excess_square_tail_sum {q : ℝ} (hq : |q| < 1) :
    (∑' j : ℕ, ((2*(j : ℝ)+3)^2-1)*q^(j+1)) = 8*q/(1-q)^3 := by
  have hs : Summable (fun j : ℕ => q^(j+1)) := by
    convert (summable_geometric_of_abs_lt_one hq).comp_injective Nat.succ_injective using 1 <;> rfl
  have he : (fun j : ℕ => ((2*(j : ℝ)+3)^2-1)*q^(j+1)) =
      (fun j : ℕ => (2*(j : ℝ)+3)^2*q^(j+1)-q^(j+1)) := by funext j; ring
  rw [he, (summable_odd_square_geometric hq).tsum_sub hs,
    tsum_odd_square_geometric hq, geometric_tail_sum hq]
  ring

theorem excess_square_tail_bound {q : ℝ} (hq0 : 0 ≤ q) (hq : q ≤ 17/200) :
    (∑' j : ℕ, ((2*(j : ℝ)+3)^2-1)*q^(j+1)) ≤ 89/100 := by
  have hq1 : |q| < 1 := by rw [abs_of_nonneg hq0]; linarith
  have hsmall : |(17/200 : ℝ)| < 1 := by norm_num
  calc
    _ ≤ ∑' j : ℕ, ((2*(j : ℝ)+3)^2-1)*(17/200 : ℝ)^(j+1) :=
      Summable.tsum_le_tsum (fun j => mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hq0 hq _)
        (by nlinarith [Nat.cast_nonneg (α := ℝ) j]))
        (summable_excess_square_geometric hq1) (summable_excess_square_geometric hsmall)
    _ ≤ _ := by rw [excess_square_tail_sum hsmall]; norm_num

def periodicFrequency (a : ℝ) : ℝ := Real.pi / (2*a)
def periodicDecay (a : ℝ) : ℝ := Real.pi^2 / (4*a)
def periodicRatio (a : ℝ) : ℝ := Real.exp (-2*periodicDecay a)
def periodicCoefficient (a : ℝ) (j : ℕ) : ℝ :=
  (Real.pi/a) / Real.sinh ((2*(j : ℝ)+1)*periodicDecay a)

/-- The actual nome-like decay ratio is uniformly small up to gain two. -/
theorem periodicRatio_bound {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) :
    0 < periodicRatio a ∧ periodicRatio a < 17/200 := by
  constructor
  · exact Real.exp_pos _
  · have hp : (2467/1000 : ℝ) ≤ Real.pi^2/4 := by nlinarith [Real.pi_gt_d4]
    have hα : (2467/1000 : ℝ) ≤ 2*periodicDecay a := by
      unfold periodicDecay
      rw [← mul_div_assoc]
      apply (le_div_iff₀ (by positivity : 0 < 4*a)).mpr
      nlinarith
    have hsum := Real.sum_le_exp_of_nonneg (by norm_num : (0 : ℝ) ≤ 2467/1000) 12
    have hnum : (200/17 : ℝ) < ∑ j ∈ Finset.range 12, (2467/1000 : ℝ)^j / j.factorial := by
      norm_num [Finset.sum_range_succ, Nat.factorial]
    have he : (200/17 : ℝ) < Real.exp (2*periodicDecay a) :=
      (hnum.trans_le hsum).trans_le (Real.exp_le_exp.mpr hα)
    unfold periodicRatio
    rw [show -2*periodicDecay a = -(2*periodicDecay a) by ring, Real.exp_neg]
    have hpos := Real.exp_pos (2*periodicDecay a)
    apply (inv_lt_iff_one_lt_mul₀ hpos).mpr
    nlinarith

end NeuralGeneralization.OnlineLowerTanh
