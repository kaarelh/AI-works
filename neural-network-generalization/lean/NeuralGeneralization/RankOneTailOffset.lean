import NeuralGeneralization.RankOneGridPacking
import Mathlib.Data.Nat.Log

/-!
# A bounded scalar correction for all growth levels

Below the logarithmic dimension cutoff the correction drops by a fixed
amount. Above it, the actual grid packing theorem bounds every possible
separated family, so a summable geometric correction supplies the full
growth inequality. Its initial size is bounded independently of dimension.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

def dimensionCutoff (D : ℕ) : ℕ := Nat.clog 2 D

theorem dimension_le_pow_cutoff (D : ℕ) : D ≤ 2^(dimensionCutoff D) :=
  Nat.le_pow_clog (by decide) D

def tailOffset (c V η : ℝ) (h₀ h : ℕ) : ℝ :=
  η*(h₀+1-h : ℕ) + 4*c*Real.sqrt V*(1/2:ℝ)^(max h (h₀+1))

theorem tailOffset_nonneg (c V η : ℝ) (hc : 0 ≤ c) (hη : 0 ≤ η) (h₀ h : ℕ) :
    0 ≤ tailOffset c V η h₀ h := by unfold tailOffset; positivity

theorem tailOffset_drop_head (c V η : ℝ) (h₀ h : ℕ) (hh : h ≤ h₀) :
    tailOffset c V η h₀ h - tailOffset c V η h₀ (h+1) = η := by
  have hsub : h₀+1-h = (h₀+1-(h+1))+1 := by omega
  unfold tailOffset
  rw [max_eq_right (by omega : h≤h₀+1), max_eq_right (by omega : h+1≤h₀+1), hsub]
  push_cast
  ring

theorem tailOffset_drop_tail (c V η : ℝ) (h₀ h : ℕ) (hh : h₀ < h) :
    tailOffset c V η h₀ h - tailOffset c V η h₀ (h+1) =
      2*c*Real.sqrt V*(1/2:ℝ)^h := by
  unfold tailOffset
  rw [Nat.sub_eq_zero_of_le (by omega : h₀+1≤h), Nat.sub_eq_zero_of_le (by omega : h₀+1≤h+1),
    max_eq_left (by omega : h₀+1≤h), max_eq_left (by omega : h₀+1≤h+1), pow_succ]
  norm_num
  ring

theorem tailOffset_antitone (c V η : ℝ) (hc : 0 ≤ c) (hη : 0 ≤ η) (h₀ : ℕ) :
    Antitone (tailOffset c V η h₀) := by
  apply antitone_nat_of_succ_le
  intro h
  by_cases hh : h ≤ h₀
  · have he := tailOffset_drop_head c V η h₀ h hh
    linarith
  · have he := tailOffset_drop_tail c V η h₀ h (lt_of_not_ge hh)
    have hp : 0 ≤ 2*c*Real.sqrt V*(1/2:ℝ)^h := by positivity
    linarith

theorem tailOffset_zero_le (c V η : ℝ) (hc : 0 ≤ c) (h₀ : ℕ) :
    tailOffset c V η h₀ 0 ≤ η*(h₀+1 : ℕ) + 4*c*Real.sqrt V := by
  unfold tailOffset
  simp only [Nat.sub_zero, Nat.zero_le, max_eq_right]
  have hp : (1/2:ℝ)^(h₀+1) ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
  have hh := mul_le_mul_of_nonneg_left hp (by positivity : 0≤4*c*Real.sqrt V)
  linarith

theorem tailOffset_zero_bounded (c V : ℝ) (hc : 0 ≤ c) (hsmall : c*Real.sqrt V ≤ 1/512)
    (h₀ : ℕ) : tailOffset c V (1/(h₀+1 : ℕ)) h₀ 0 ≤ 1+1/128 := by
  have hh := tailOffset_zero_le c V (1/(h₀+1 : ℕ)) hc h₀
  have hpos : (0:ℝ)<(h₀+1 : ℕ) := by positivity
  rw [one_div_mul_cancel (ne_of_gt hpos)] at hh
  linarith

/-- The scalar correction pays for every actual separated family above
the cutoff, with the same growth weight and constant used at coarse levels. -/
theorem tailOffset_pays_growth {m D h₀ h : ℕ}
    (a : Fin m → Fin D → ℝ) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V) (hD : D ≤ 2^h₀) (hh : h₀ < h)
    (p : Fin (GrowthTree.branching h) → Fin D → ℝ)
    (hp : ∀ l, ∑ j, p l j^2 ≤ 1)
    (hrow : ∀ l, ∑ i, linearEvaluation (a i) (p l)^2 ≤ 1)
    (s : ℝ) (hsep : ∀ l k, l≠k → s ≤ rankOneDistance a (p l) (p k))
    (c η : ℝ) (hc : 0 ≤ c) :
    c*s*(2:ℝ)^h ≤ tailOffset c V η h₀ h - tailOffset c V η h₀ (h+1) := by
  have hD' : D ≤ 2^h := hD.trans (Nat.pow_le_pow_right (by decide) hh.le)
  have hs := rankOne_tail_separation_bound a V hV ha hD' p hp hrow s hsep
  have hmul := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hs hc)
    (by positivity : (0:ℝ)≤2^h)
  rw [tailOffset_drop_tail c V η h₀ h hh]
  calc
    _ ≤ c*(2*Real.sqrt V*(1/4:ℝ)^h)*2^h := hmul
    _ = 2*c*Real.sqrt V*((1/4:ℝ)^h*2^h) := by ring
    _ = _ := by rw [← mul_pow]; norm_num

end NeuralGeneralization.SquaredSampling
