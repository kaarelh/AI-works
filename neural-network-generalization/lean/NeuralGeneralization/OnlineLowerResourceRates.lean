import NeuralGeneralization.OnlineLowerStatements
import NeuralGeneralization.OnlineLowerTeacherPadding
import NeuralGeneralization.OnlineLowerResourceBounds

/-!
# Translating actual construction resources into width-rate statements

These are implications between the literal theorem targets. They do not
prove that a construction with the required resources exists. Exact padding
of the bounded teacher makes its specified width arbitrarily large while
retaining the same target and input permutation.
-/

noncomputable section
open scoped Topology

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- Quadratic teacher width and exponentially many rounds give the claimed
square-root exponential lower bound in specified teacher width. -/
theorem polynomial_quadratic_resources_imply_square_root
    (φ : ℝ → ℝ) (a : ℕ) (hfamily : PolynomialResourceFamily φ a 2) :
    WidthExponentLowerBound φ (1 / 2 : ℝ) := by
  obtain ⟨K, hK, c, hc, k₀, hk₀, hfamily⟩ := hfamily
  let c' := c / (Real.sqrt K + 1)
  have hrootK : 0 ≤ Real.sqrt (K : ℝ) := Real.sqrt_nonneg _
  have hden : 0 < Real.sqrt (K : ℝ) + 1 := by linarith
  refine ⟨c', div_pos hc hden, ?_⟩
  intro Cmin
  let k := max k₀ (max Cmin 1)
  have hk : k₀ ≤ k := le_max_left _ _
  have hkone : 1 ≤ k := (le_max_right Cmin 1).trans (le_max_right k₀ _)
  have hkC : Cmin ≤ k := (le_max_left Cmin 1).trans (le_max_right k₀ _)
  obtain ⟨d, C, f, π, J, hd, hC, hdl, hdu, hCu, hteacher, hcircuit, hT, hfail⟩ :=
    hfamily k hk
  let C' := K * k ^ 2
  have hKC : k ≤ C' := by
    dsimp [C']
    have hkpow : k ≤ k ^ 2 := by nlinarith
    exact hkpow.trans (Nat.le_mul_of_pos_left _ hK)
  have hCC' : C ≤ C' := hCu
  refine ⟨d, C', f, π, J, hd, hkC.trans hKC,
    hteacher.mono_width hCC', ?_, hfail.withTeacherWidth C'⟩
  have hroot : (C' : ℝ) ^ (1 / 2 : ℝ) = Real.sqrt (K : ℝ) * (k : ℝ) :=
    sqrt_quadratic_width K k
  have hcoef : c' * Real.sqrt (K : ℝ) ≤ c := by
    dsimp [c']
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hden).mpr
    nlinarith
  have hexponent : c' * (C' : ℝ) ^ (1 / 2 : ℝ) ≤ c * (k : ℝ) := by
    rw [hroot, ← mul_assoc]
    exact mul_le_mul_of_nonneg_right hcoef (Nat.cast_nonneg k)
  exact (Real.exp_le_exp.mpr hexponent).trans hT

/-- A quadratic teacher bound with two logarithmic factors gives the
square-root rate with one logarithmic denominator. This establishes the
resource interpretation of the improved tanh target without asserting its
analytic construction. -/
theorem polylog_quadratic_resources_imply_square_root_log_loss
    (φ : ℝ → ℝ) (a : ℕ) (hfamily : PolylogResourceFamily φ a 2 2) :
    WidthRateLowerBound φ
      (fun C => (C : ℝ) ^ (1 / 2 : ℝ) / Real.log (C + 2 : ℝ)) := by
  obtain ⟨K, hK, c, hc, k₀, hk₀, hfamily⟩ := hfamily
  let R := Real.sqrt (2 * (K : ℝ))
  let c' := c / (R + 1)
  have hR : 0 ≤ R := Real.sqrt_nonneg _
  have hden : 0 < R + 1 := by linarith
  have hc' : 0 < c' := div_pos hc hden
  refine ⟨c', hc', ?_⟩
  intro Cmin
  let k := max k₀ (max Cmin (⌈Real.exp 1⌉₊ + 1))
  have hk : k₀ ≤ k := le_max_left _ _
  have hkC : Cmin ≤ k := (le_max_left _ _).trans (le_max_right _ _)
  have hkceil : ⌈Real.exp 1⌉₊ ≤ k :=
    (Nat.le_succ _).trans ((le_max_right _ _).trans (le_max_right _ _))
  have hkone : (1 : ℝ) ≤ k := by exact_mod_cast (show 1 ≤ k by omega)
  have hkpos : (0 : ℝ) < k := by linarith
  have hexp : Real.exp 1 ≤ (k : ℝ) :=
    (Nat.le_ceil _).trans (by exact_mod_cast hkceil)
  have hlog : (1 : ℝ) ≤ Real.log k := (Real.le_log_iff_exp_le hkpos).mpr hexp
  have hlogpos : 0 < Real.log k := by linarith
  have hKR : (1 : ℝ) ≤ K := by exact_mod_cast hK
  let A := (K : ℝ) * (k : ℝ) ^ 2 * Real.log k ^ 2
  let C' := ⌈A⌉₊
  have hbounds := rounded_quadratic_log_width_bounds K k hKR hkone hlog
  have hC'lower : (k : ℝ) ≤ (C' : ℝ) := hbounds.1
  have hrate : (C' : ℝ) ^ (1 / 2 : ℝ) / Real.log (C' + 2 : ℝ) ≤ R * (k : ℝ) :=
    hbounds.2.2
  obtain ⟨d, C, f, π, J, hd, hC, hdl, hdu, hCu, hteacher, hcircuit, hT, hfail⟩ :=
    hfamily k hk
  have hCC' : C ≤ C' := by
    exact_mod_cast hCu.trans (Nat.le_ceil A)
  have hCmin : Cmin ≤ C' := hkC.trans (by exact_mod_cast hC'lower)
  refine ⟨d, C', f, π, J, hd, hCmin,
    hteacher.mono_width hCC', ?_, hfail.withTeacherWidth C'⟩
  have hcoef : c' * R ≤ c := by
    dsimp [c']
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hden).mpr
    nlinarith
  have hmain : c' * ((C' : ℝ) ^ (1 / 2 : ℝ) / Real.log (C' + 2 : ℝ)) ≤
      c * (k : ℝ) := by
    calc
      _ ≤ c' * (R * (k : ℝ)) := mul_le_mul_of_nonneg_left hrate hc'.le
      _ = (c' * R) * (k : ℝ) := by ring
      _ ≤ c * (k : ℝ) := mul_le_mul_of_nonneg_right hcoef hkpos.le
  exact (Real.exp_le_exp.mpr hmain).trans hT

end NeuralGeneralization.OnlineLower
