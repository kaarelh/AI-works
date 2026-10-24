import NeuralGeneralization.TanhScalarJet
import NeuralGeneralization.TanhHessian
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

/-! Actual third-order derivatives for the tanh quadratic exponential observable
used by the relative Lindeberg argument. -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open TanhDifferential

def tanhThird (x : ℝ) : ℝ :=
  -2 * tanhFirst x ^ 2 - 2 * Real.tanh x * tanhSecond x

theorem hasDerivAt_tanhSecond (x : ℝ) :
    HasDerivAt tanhSecond (tanhThird x) x := by
  have h := (((hasDerivAt_tanh_first x).const_mul (-2)).mul (hasDerivAt_tanhFirst x))
  convert! h using 1 <;> (try dsimp [tanhSecond, tanhThird]) <;> ring

theorem abs_tanhThird_le_six (x : ℝ) : |tanhThird x| ≤ 6 := by
  have h1 := abs_tanhFirst_le_one x
  have h2 := abs_tanhSecond_le_two x
  have ht := (Real.abs_tanh_lt_one x).le
  calc
    |tanhThird x| ≤ |-2 * tanhFirst x ^ 2| + |2 * Real.tanh x * tanhSecond x| :=
      by simpa only [tanhThird, sub_eq_add_neg, abs_neg] using
        abs_add_le (-2 * tanhFirst x ^ 2) (-(2 * Real.tanh x * tanhSecond x))
    _ = 2 * |tanhFirst x| ^ 2 + 2 * |Real.tanh x| * |tanhSecond x| := by
      simp only [abs_mul, abs_pow]
      norm_num
    _ ≤ 6 := by nlinarith [abs_nonneg (tanhFirst x),
      mul_le_mul ht h2 (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)]

@[fun_prop] theorem continuous_tanhThird : Continuous tanhThird := by
  unfold tanhThird
  fun_prop

def lineTanh (z a t : ℝ) : ℝ := Real.tanh (z + a * t)
def lineTanhFirst (z a t : ℝ) : ℝ := a * tanhFirst (z + a * t)
def lineTanhSecond (z a t : ℝ) : ℝ := a ^ 2 * tanhSecond (z + a * t)
def lineTanhThird (z a t : ℝ) : ℝ := a ^ 3 * tanhThird (z + a * t)

theorem hasDerivAt_lineTanh (z a t : ℝ) :
    HasDerivAt (lineTanh z a) (lineTanhFirst z a t) t := by
  have h := (hasDerivAt_tanh_first (z + a * t)).comp t
    (((hasDerivAt_id t).const_mul a).const_add z)
  convert! h using 1 <;> (try dsimp [lineTanh, lineTanhFirst, Function.comp_def]) <;> ring

theorem hasDerivAt_lineTanhFirst (z a t : ℝ) :
    HasDerivAt (lineTanhFirst z a) (lineTanhSecond z a t) t := by
  have h := ((hasDerivAt_tanhFirst (z + a * t)).comp t
    (((hasDerivAt_id t).const_mul a).const_add z)).const_mul a
  convert! h using 1 <;> (try dsimp [lineTanhFirst, lineTanhSecond, Function.comp_def]) <;> ring

theorem hasDerivAt_lineTanhSecond (z a t : ℝ) :
    HasDerivAt (lineTanhSecond z a) (lineTanhThird z a t) t := by
  have h := ((hasDerivAt_tanhSecond (z + a * t)).comp t
    (((hasDerivAt_id t).const_mul a).const_add z)).const_mul (a ^ 2)
  convert! h using 1 <;> (try dsimp [lineTanhSecond, lineTanhThird, Function.comp_def]) <;> ring

theorem lineTanh_bounds (z a t b : ℝ) (hb : 0 ≤ b) (ha : |a| ≤ b) :
    |lineTanh z a t| ≤ 1 ∧ |lineTanhFirst z a t| ≤ b ∧
      |lineTanhSecond z a t| ≤ 2 * b ^ 2 ∧
      |lineTanhThird z a t| ≤ 6 * b ^ 3 := by
  refine ⟨(Real.abs_tanh_lt_one _).le, ?_, ?_, ?_⟩
  · unfold lineTanhFirst
    rw [abs_mul]
    exact (mul_le_mul ha (abs_tanhFirst_le_one _) (abs_nonneg _) hb).trans_eq (mul_one b)
  · unfold lineTanhSecond
    rw [abs_mul, abs_pow]
    have h := mul_le_mul (pow_le_pow_left₀ (abs_nonneg a) ha 2)
      (abs_tanhSecond_le_two (z + a * t)) (abs_nonneg _) (sq_nonneg b)
    nlinarith
  · unfold lineTanhThird
    rw [abs_mul, abs_pow]
    have h := mul_le_mul (pow_le_pow_left₀ (abs_nonneg a) ha 3)
      (abs_tanhThird_le_six (z + a * t)) (abs_nonneg _) (pow_nonneg hb 3)
    nlinarith

def pairLine (z a w b t : ℝ) : ℝ := lineTanh z a t * lineTanh w b t
def pairLineFirst (z a w b t : ℝ) : ℝ :=
  lineTanhFirst z a t * lineTanh w b t + lineTanh z a t * lineTanhFirst w b t
def pairLineSecond (z a w b t : ℝ) : ℝ :=
  lineTanhSecond z a t * lineTanh w b t +
    2 * lineTanhFirst z a t * lineTanhFirst w b t +
    lineTanh z a t * lineTanhSecond w b t
def pairLineThird (z a w b t : ℝ) : ℝ :=
  lineTanhThird z a t * lineTanh w b t +
    3 * lineTanhSecond z a t * lineTanhFirst w b t +
    3 * lineTanhFirst z a t * lineTanhSecond w b t +
    lineTanh z a t * lineTanhThird w b t

theorem hasDerivAt_pairLine (z a w b t : ℝ) :
    HasDerivAt (pairLine z a w b) (pairLineFirst z a w b t) t := by
  simpa [pairLine, pairLineFirst] using!
    (hasDerivAt_lineTanh z a t).mul (hasDerivAt_lineTanh w b t)

theorem hasDerivAt_pairLineFirst (z a w b t : ℝ) :
    HasDerivAt (pairLineFirst z a w b) (pairLineSecond z a w b t) t := by
  have h := ((hasDerivAt_lineTanhFirst z a t).mul (hasDerivAt_lineTanh w b t)).add
    ((hasDerivAt_lineTanh z a t).mul (hasDerivAt_lineTanhFirst w b t))
  convert! h using 1 <;> (try dsimp [pairLineFirst, pairLineSecond]) <;> ring

theorem hasDerivAt_pairLineSecond (z a w b t : ℝ) :
    HasDerivAt (pairLineSecond z a w b) (pairLineThird z a w b t) t := by
  have h := (((hasDerivAt_lineTanhSecond z a t).mul (hasDerivAt_lineTanh w b t)).add
    (((hasDerivAt_lineTanhFirst z a t).const_mul 2).mul (hasDerivAt_lineTanhFirst w b t))).add
      ((hasDerivAt_lineTanh z a t).mul (hasDerivAt_lineTanhSecond w b t))
  convert! h using 1 <;> (try dsimp [pairLineSecond, pairLineThird]) <;> ring

theorem pairLine_bounds (z a w b t c : ℝ) (hc : 0 ≤ c) (ha : |a| ≤ c) (hb : |b| ≤ c) :
    |pairLineFirst z a w b t| ≤ 2 * c ∧
      |pairLineSecond z a w b t| ≤ 6 * c ^ 2 ∧
      |pairLineThird z a w b t| ≤ 24 * c ^ 3 := by
  obtain ⟨hu0, hu1, hu2, hu3⟩ := lineTanh_bounds z a t c hc ha
  obtain ⟨hv0, hv1, hv2, hv3⟩ := lineTanh_bounds w b t c hc hb
  constructor
  · unfold pairLineFirst
    calc
      _ ≤ |lineTanhFirst z a t * lineTanh w b t| +
          |lineTanh z a t * lineTanhFirst w b t| := abs_add_le _ _
      _ ≤ c * 1 + 1 * c := by
        simp only [abs_mul]
        exact add_le_add (mul_le_mul hu1 hv0 (abs_nonneg _) hc)
          (mul_le_mul hu0 hv1 (abs_nonneg _) (by norm_num))
      _ = _ := by ring
  constructor
  · unfold pairLineSecond
    calc
      _ ≤ |lineTanhSecond z a t * lineTanh w b t| +
          |2 * lineTanhFirst z a t * lineTanhFirst w b t| +
          |lineTanh z a t * lineTanhSecond w b t| :=
        (abs_add_le _ _).trans (add_le_add (abs_add_le _ _) le_rfl)
      _ ≤ (2 * c ^ 2) * 1 + 2 * c * c + 1 * (2 * c ^ 2) := by
        simp only [abs_mul, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2)]
        gcongr
      _ = _ := by ring
  · unfold pairLineThird
    calc
      _ ≤ |lineTanhThird z a t * lineTanh w b t| +
          |3 * lineTanhSecond z a t * lineTanhFirst w b t| +
          |3 * lineTanhFirst z a t * lineTanhSecond w b t| +
          |lineTanh z a t * lineTanhThird w b t| :=
        (abs_add_le _ _).trans (add_le_add
          ((abs_add_le _ _).trans (add_le_add (abs_add_le _ _) le_rfl)) le_rfl)
      _ ≤ (6 * c ^ 3) * 1 + 3 * (2 * c ^ 2) * c +
          3 * c * (2 * c ^ 2) + 1 * (6 * c ^ 3) := by
        simp only [abs_mul, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 3)]
        gcongr
      _ = _ := by ring

section FiniteField
variable {I : Type*} [Fintype I]

def potentialLine (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairLine (z e.1) (a e.1) (z e.2) (a e.2) t
def potentialLineFirst (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairLineFirst (z e.1) (a e.1) (z e.2) (a e.2) t
def potentialLineSecond (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairLineSecond (z e.1) (a e.1) (z e.2) (a e.2) t
def potentialLineThird (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairLineThird (z e.1) (a e.1) (z e.2) (a e.2) t

theorem hasDerivAt_potentialLine (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) :
    HasDerivAt (potentialLine Γ z a) (potentialLineFirst Γ z a t) t := by
  exact HasDerivAt.fun_sum fun e _ =>
    (hasDerivAt_pairLine (z e.1) (a e.1) (z e.2) (a e.2) t).const_mul (Γ e.1 e.2)

theorem hasDerivAt_potentialLineFirst (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) :
    HasDerivAt (potentialLineFirst Γ z a) (potentialLineSecond Γ z a t) t := by
  exact HasDerivAt.fun_sum fun e _ =>
    (hasDerivAt_pairLineFirst (z e.1) (a e.1) (z e.2) (a e.2) t).const_mul (Γ e.1 e.2)

theorem hasDerivAt_potentialLineSecond (Γ : I → I → ℝ) (z a : I → ℝ) (t : ℝ) :
    HasDerivAt (potentialLineSecond Γ z a) (potentialLineThird Γ z a t) t := by
  exact HasDerivAt.fun_sum fun e _ =>
    (hasDerivAt_pairLineSecond (z e.1) (a e.1) (z e.2) (a e.2) t).const_mul (Γ e.1 e.2)

private theorem weighted_sum_bound {J : Type*} [Fintype J] (u v : J → ℝ)
    (B : ℝ) (hv : ∀ j, |v j| ≤ B) :
    |∑ j, u j * v j| ≤ (∑ j, |u j|) * B := by
  calc
    _ ≤ ∑ j, |u j * v j| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j, |u j| * B := Finset.sum_le_sum fun j _ => by
      rw [abs_mul]
      exact mul_le_mul_of_nonneg_left (hv j) (abs_nonneg _)
    _ = _ := (Finset.sum_mul _ _ _).symm

/-- The first three derivatives have no factor depending on the field dimension. -/
theorem potentialLine_bounds (Γ : I → I → ℝ) (z a : I → ℝ) (t G b : ℝ)
    (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b) (ha : ∀ i, |a i| ≤ b) :
    |potentialLineFirst Γ z a t| ≤ 2 * G * b ∧
      |potentialLineSecond Γ z a t| ≤ 6 * G * b ^ 2 ∧
      |potentialLineThird Γ z a t| ≤ 24 * G * b ^ 3 := by
  have hpair (e : I × I) := pairLine_bounds (z e.1) (a e.1) (z e.2) (a e.2) t b
    hb (ha e.1) (ha e.2)
  have h1 := weighted_sum_bound (fun e : I × I => Γ e.1 e.2)
    (fun e => pairLineFirst (z e.1) (a e.1) (z e.2) (a e.2) t) (2 * b) (fun e => (hpair e).1)
  have h2 := weighted_sum_bound (fun e : I × I => Γ e.1 e.2)
    (fun e => pairLineSecond (z e.1) (a e.1) (z e.2) (a e.2) t) (6 * b ^ 2)
    (fun e => (hpair e).2.1)
  have h3 := weighted_sum_bound (fun e : I × I => Γ e.1 e.2)
    (fun e => pairLineThird (z e.1) (a e.1) (z e.2) (a e.2) t) (24 * b ^ 3)
    (fun e => (hpair e).2.2)
  change |potentialLineFirst Γ z a t| ≤ couplingMass Γ * (2 * b) at h1
  change |potentialLineSecond Γ z a t| ≤ couplingMass Γ * (6 * b ^ 2) at h2
  change |potentialLineThird Γ z a t| ≤ couplingMass Γ * (24 * b ^ 3) at h3
  refine ⟨?_, ?_, ?_⟩
  · exact h1.trans (by nlinarith [mul_le_mul_of_nonneg_right hΓ hb])
  · exact h2.trans (by nlinarith [mul_le_mul_of_nonneg_right hΓ (sq_nonneg b)])
  · exact h3.trans (by nlinarith [mul_le_mul_of_nonneg_right hΓ (pow_nonneg hb 3)])

end FiniteField

end NeuralGeneralization.BatchTwoNonGaussian
