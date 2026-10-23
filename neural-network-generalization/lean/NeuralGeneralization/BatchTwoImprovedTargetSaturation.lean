import NeuralGeneralization.RobustCircuitInvariant
import NeuralGeneralization.BatchTwoMergingSharpMass

/-! Exponential saturation preserves logarithmic Boolean gate gain. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel

theorem tanh_positive_saturation_exp {q:ℝ} (_hq:0≤q):
    |Real.tanh q-1|≤2*Real.exp (-2*q) := by
  have ht:Real.tanh q≤1 := (le_abs_self _).trans (Real.abs_tanh_lt_one q).le
  rw [abs_of_nonpos (by linarith),neg_sub,one_sub_tanh_eq]
  calc
    _ ≤ 2/Real.exp (2*q) := div_le_div_of_nonneg_left (by norm_num) (Real.exp_pos _) (by linarith [Real.exp_pos (2*q)])
    _ = _ := by rw [div_eq_mul_inv,←Real.exp_neg];congr 2;ring

theorem tanh_global_secant_exp_positive {A q u : ℝ}
    (hA : 0 < A) (hq : A / 2 ≤ q) :
    |Real.tanh (q + u) - 1| ≤ 2 * Real.exp (-A/2) + 8 * |u| / A := by
  by_cases hu : |u| ≤ A / 4
  · have hp : A/4 ≤ q+u := by
      have := (abs_le.mp hu).1
      linarith
    have hp0 : 0 < q+u := lt_of_lt_of_le (by positivity) hp
    have hh:=tanh_positive_saturation_exp hp0.le
    have he:Real.exp (-2*(q+u))≤Real.exp (-A/2) := Real.exp_le_exp.mpr (by linarith)
    have hbound:=hh.trans (mul_le_mul_of_nonneg_left he (by norm_num : (0:ℝ)≤2))
    have hnonneg : 0 ≤ 8*|u|/A := by positivity
    linarith
  · have hu' : A/4 ≤ |u| := le_of_lt (lt_of_not_ge hu)
    have hh : |Real.tanh (q+u)-1| ≤ 2 := by
      calc
        _ ≤ |Real.tanh (q+u)| + |(1:ℝ)| := abs_sub _ _
        _ ≤ 2 := by have := (Real.abs_tanh_lt_one (q+u)).le; norm_num at *; linarith
    have hbig : 2 ≤ 8*|u|/A := by
      apply (le_div_iff₀ hA).mpr
      linarith
    have hnonneg : 0 ≤ 2*Real.exp (-A/2) := by positivity
    linarith

/-- The signed global secant estimate used in each Boolean gate. -/
theorem tanh_global_secant_exp (b : Bool) {A q u : ℝ}
    (hA : 0 < A) (hq : A / 2 ≤ labelReal b * q) :
    |Real.tanh (q + u) - labelReal b| ≤ 2 * Real.exp (-A/2) + 8 * |u| / A := by
  cases b
  · simp only [labelReal_false, neg_one_mul] at hq ⊢
    have hh := tanh_global_secant_exp_positive (u := -u) hA hq
    rw [show -q + -u = -(q+u) by ring, Real.tanh_neg, abs_neg] at hh
    rw [show -Real.tanh (q+u)-1 = -(Real.tanh (q+u)+1) by ring, abs_neg] at hh
    simpa only [sub_neg_eq_add] using hh
  · simpa only [labelReal_true, one_mul] using tanh_global_secant_exp_positive (u := u) hA
      (by simpa only [labelReal_true, one_mul] using hq)

variable {N:ℕ}

theorem saturation_squared_error_exp
    (b : Fin N → Bool) (q u η : Fin N → ℝ) {A U V : ℝ}
    (hA : 0 < A) (hq : ∀ i, A/2 ≤ labelReal (b i)*q i)
    (hu : (∑ i, u i^2) ≤ U) (hη : (∑ i, η i^2) ≤ V) :
    (∑ i, (Real.tanh (q i+u i)+η i-labelReal (b i))^2) ≤
      3*((N:ℝ)*(2*Real.exp (-A/2))^2+(8/A)^2*U+V) := by
  have hpoint (i : Fin N) :
      (Real.tanh (q i+u i)+η i-labelReal (b i))^2 ≤
        3*((2*Real.exp (-A/2))^2+(8/A)^2*(u i)^2+(η i)^2) := by
    have hs := tanh_global_secant_exp (b i) (u := u i) hA (hq i)
    have htri : |Real.tanh (q i+u i)+η i-labelReal (b i)| ≤
        2*Real.exp (-A/2)+8*|u i|/A+|η i| := by
      have hh := abs_add_le (Real.tanh (q i+u i)-labelReal (b i)) (η i)
      rw [show Real.tanh (q i+u i)-labelReal (b i)+η i =
        Real.tanh (q i+u i)+η i-labelReal (b i) by ring] at hh
      linarith
    have hright : 0 ≤ 2*Real.exp (-A/2)+8*|u i|/A+|η i| := by positivity
    have hsq := (sq_le_sq₀ (abs_nonneg _) hright).mpr htri
    rw [sq_abs] at hsq
    have hthree (x y z : ℝ) : (x+y+z)^2 ≤ 3*(x^2+y^2+z^2) := by
      nlinarith [sq_nonneg (x-y), sq_nonneg (x-z), sq_nonneg (y-z)]
    have hh := hsq.trans (hthree (2*Real.exp (-A/2)) (8*|u i|/A) |η i|)
    have hterm : (8*|u i|/A)^2 = (8/A)^2*(u i)^2 := by
      rw [div_pow, mul_pow, sq_abs, div_pow]
      ring
    simpa only [hterm, sq_abs] using hh

  calc
    _ ≤ ∑ i, 3*((2*Real.exp (-A/2))^2+(8/A)^2*(u i)^2+(η i)^2) :=
      Finset.sum_le_sum fun i _ => hpoint i
    _ = 3*((N:ℝ)*(2*Real.exp (-A/2))^2+(8/A)^2*(∑ i, (u i)^2)+∑ i, (η i)^2) := by
      simp only [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_const,
        Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    _ ≤ _ := by
      have hh := mul_le_mul_of_nonneg_left hu (sq_nonneg (8/A))
      linarith


end NeuralGeneralization.ConcreteModel
