import NeuralGeneralization.ArcsineNoiseLower
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Explicit two-sided endpoint cusps for the actual iterated arcsine link. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization

theorem iteratedArcsine_endpoint_power_upper {t : ℝ} (ht : |t| ≤ 1) (k : ℕ) :
    ((1-iteratedArcsine k t)/2)^(2^k) ≤ (1-t)/2 := by
  induction k with
  | zero => simp [iteratedArcsine]
  | succ k ih =>
    have hrec : ((1-iteratedArcsine (k+1) t)/2)^2 ≤ (1-iteratedArcsine k t)/2 := by
      have h := arcsineLink_endpoint_square (abs_iteratedArcsine_le_one ht k)
      change (1-arcsineLink (iteratedArcsine k t))^2 ≤ _ at h
      change ((1-arcsineLink (iteratedArcsine k t))/2)^2 ≤ _
      nlinarith
    calc
      _ = (((1-iteratedArcsine (k+1) t)/2)^2)^(2^k) := by
        rw [← pow_mul, pow_succ]
        congr 1
        omega
      _ ≤ ((1-iteratedArcsine k t)/2)^(2^k) := pow_le_pow_left₀ (sq_nonneg _) hrec _
      _ ≤ _ := ih

theorem nat_power_inverse_root (n : ℕ) (hn : 0 < n) {x : ℝ} (hx : 0 ≤ x) :
    (x^n)^((1 : ℝ)/n) = x := by
  rw [← Real.rpow_natCast x n, ← Real.rpow_mul hx]
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hn)
  rw [mul_one_div_cancel hn', Real.rpow_one]

theorem one_sub_exp_neg_bounds {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) :
    t*Real.exp (-1) ≤ 1-Real.exp (-t) ∧ 1-Real.exp (-t) ≤ t := by
  have he : Real.exp (-t)*Real.exp t = 1 := by rw [← Real.exp_add]; simp
  have hmul := mul_le_mul_of_nonneg_left (Real.add_one_le_exp t) (Real.exp_pos (-t)).le
  have helo : Real.exp (-1) ≤ Real.exp (-t) := Real.exp_le_exp.mpr (by linarith)
  have htl := mul_le_mul_of_nonneg_left helo ht
  constructor
  · nlinarith
  · linarith [Real.add_one_le_exp (-t)]

/-- The reciprocal natural power is the exact endpoint exponent. Both
constants are explicit and positive at every finite depth. -/
theorem iteratedArcsine_exp_cusp (k : ℕ) {t : ℝ} (ht : 0 < t) (ht1 : t ≤ 1) :
    (Real.exp (-1))^((1 : ℝ)/(2:ℝ)^k)/2 * t^((1 : ℝ)/(2:ℝ)^k) ≤
      1-iteratedArcsine k (Real.exp (-t)) ∧
    1-iteratedArcsine k (Real.exp (-t)) ≤ 2*t^((1 : ℝ)/(2:ℝ)^k) := by
  let q : ℕ := 2^k
  let β : ℝ := 1/(q : ℝ)
  have hq : 0 < q := by dsimp only [q]; positivity
  have hβ : 0 < β := by dsimp only [β]; positivity
  have hβeq : β = (1 : ℝ)/(2:ℝ)^k := by simp [β, q]
  have hz : |Real.exp (-t)| ≤ 1 := by
    rw [abs_of_pos (Real.exp_pos _)]
    exact Real.exp_le_one_iff.mpr (by linarith)
  let g := 1-iteratedArcsine k (Real.exp (-t))
  have hg : 0 ≤ g := sub_nonneg.mpr (abs_le.mp (abs_iteratedArcsine_le_one hz k)).2
  obtain ⟨hlo, hhi⟩ := one_sub_exp_neg_bounds ht.le ht1
  have hupper : (g/2)^q ≤ t := by
    have hh := iteratedArcsine_endpoint_power_upper hz k
    change (g/2)^q ≤ _ at hh
    linarith
  have hlower : t*Real.exp (-1) ≤ (2*g)^q := by
    have hh := iteratedArcsine_endpoint_power_lower hz k
    change _ ≤ (2*g)^q at hh
    have he : 0 ≤ 1-Real.exp (-t) := sub_nonneg.mpr (abs_le.mp hz).2
    linarith
  have hu := Real.rpow_le_rpow (pow_nonneg (by positivity : 0 ≤ g/2) q) hupper hβ.le
  rw [show ((g/2)^q)^β = g/2 from nat_power_inverse_root q hq (by positivity)] at hu
  have hl := Real.rpow_le_rpow (mul_nonneg ht.le (Real.exp_pos _).le) hlower hβ.le
  rw [Real.mul_rpow ht.le (Real.exp_pos _).le,
    show ((2*g)^q)^β = 2*g from nat_power_inverse_root q hq (by positivity)] at hl
  rw [← hβeq]
  constructor <;> dsimp only [g] at hu hl ⊢ <;> nlinarith

/-- A convenient quantified form for Tauberian coefficient estimates. -/
theorem exists_iteratedArcsine_exp_cusp (k : ℕ) :
    ∃ c C : ℝ, 0 < c ∧ 0 < C ∧ ∀ t : ℝ, 0 < t → t ≤ 1 →
      c*t^((1:ℝ)/(2:ℝ)^k) ≤ 1-iteratedArcsine k (Real.exp (-t)) ∧
      1-iteratedArcsine k (Real.exp (-t)) ≤ C*t^((1:ℝ)/(2:ℝ)^k) := by
  refine ⟨(Real.exp (-1))^((1:ℝ)/(2:ℝ)^k)/2, 2, by positivity, by norm_num, ?_⟩
  intro t ht ht1
  exact iteratedArcsine_exp_cusp k ht ht1

end NeuralGeneralization
