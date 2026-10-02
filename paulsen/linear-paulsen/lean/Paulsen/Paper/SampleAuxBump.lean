import Mathlib.Analysis.Calculus.ContDiff.Basic
import Mathlib.Analysis.Calculus.ContDiff.Deriv
import Mathlib.Analysis.Calculus.ContDiff.Operations
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-!
# Helpers for `ModerateSample`: a `C¹` bump for the small-ball count (S3)

`φ_h` is `C¹`, takes values in `[0,1]`, equals `1` on `[-h,h]`, vanishes outside `[-2h,2h]` and
has `|φ_h'| ≤ 2/h`.  It is built from the `C¹` smooth step
`s(y) = 2y₊² - 4(y-½)₊² + 2(y-1)₊²`.
-/

namespace Paulsen.Paper

open Filter Topology

noncomputable section

/-- `y ↦ (max y 0)²`. -/
def posSq (y : ℝ) : ℝ := (max y 0) ^ 2

theorem hasDerivAt_posSq (y : ℝ) : HasDerivAt posSq (2 * max y 0) y := by
  rcases lt_trichotomy y 0 with hy | hy | hy
  · have he : posSq =ᶠ[𝓝 y] fun _ => 0 := by
      filter_upwards [Iio_mem_nhds hy] with z hz
      simp [posSq, max_eq_right (le_of_lt (Set.mem_Iio.mp hz))]
    rw [max_eq_right hy.le, mul_zero]
    exact (hasDerivAt_const y (0 : ℝ)).congr_of_eventuallyEq he
  · subst hy
    simp only [max_self, mul_zero]
    rw [hasDerivAt_iff_isLittleO_nhds_zero]
    have he : (fun h : ℝ => posSq (0 + h) - posSq 0 - h • (0 : ℝ)) = fun h => posSq h := by
      ext h; simp [posSq]
    rw [he]
    have hO : (fun h : ℝ => posSq h) =O[𝓝 0] fun h : ℝ => h ^ 2 := by
      apply Asymptotics.IsBigO.of_bound 1
      filter_upwards with h
      simp only [posSq, norm_pow, Real.norm_eq_abs, one_mul]
      apply pow_le_pow_left₀ (abs_nonneg _)
      rcases le_total h 0 with hh | hh
      · rw [max_eq_right hh]; simp
      · rw [max_eq_left hh]
    exact hO.trans_isLittleO (Asymptotics.isLittleO_pow_id (by norm_num))
  · have he : posSq =ᶠ[𝓝 y] fun z => z ^ 2 := by
      filter_upwards [Ioi_mem_nhds hy] with z hz
      simp [posSq, max_eq_left (le_of_lt (Set.mem_Ioi.mp hz))]
    rw [max_eq_left hy.le]
    have h : HasDerivAt (fun z : ℝ => z ^ 2) (2 * y) y := by simpa using hasDerivAt_pow 2 y
    exact h.congr_of_eventuallyEq he

theorem contDiff_posSq : ContDiff ℝ 1 posSq := by
  rw [contDiff_one_iff_deriv]
  refine ⟨fun y => (hasDerivAt_posSq y).differentiableAt, ?_⟩
  have hd : deriv posSq = fun y => 2 * max y 0 := funext fun y => (hasDerivAt_posSq y).deriv
  rw [hd]
  exact continuous_const.mul (continuous_id.max continuous_const)

/-- The `C¹` smooth step. -/
def smoothStep (y : ℝ) : ℝ := 2 * posSq y - 4 * posSq (y - 1 / 2) + 2 * posSq (y - 1)

/-- Its derivative. -/
def smoothStepDeriv (y : ℝ) : ℝ :=
  4 * max y 0 - 8 * max (y - 1 / 2) 0 + 4 * max (y - 1) 0

theorem hasDerivAt_smoothStep (y : ℝ) : HasDerivAt smoothStep (smoothStepDeriv y) y := by
  have h1 := (hasDerivAt_posSq y).const_mul 2
  have h2 := (hasDerivAt_posSq (y - 1 / 2)).comp y ((hasDerivAt_id y).sub_const (1 / 2))
  have h3 := (hasDerivAt_posSq (y - 1)).comp y ((hasDerivAt_id y).sub_const 1)
  have h := (h1.sub (h2.const_mul 4)).add (h3.const_mul 2)
  have e : smoothStepDeriv y = 2 * (2 * max y 0) - 4 * (2 * max (y - 1 / 2) 0 * 1) +
      2 * (2 * max (y - 1) 0 * 1) := by unfold smoothStepDeriv; ring
  rw [e]
  exact h

theorem contDiff_smoothStep : ContDiff ℝ 1 smoothStep := by
  have h2 : ContDiff ℝ 1 fun y : ℝ => posSq (y - 1 / 2) :=
    contDiff_posSq.comp (ContDiff.sub contDiff_id contDiff_const)
  have h3 : ContDiff ℝ 1 fun y : ℝ => posSq (y - 1) :=
    contDiff_posSq.comp (ContDiff.sub contDiff_id contDiff_const)
  exact ContDiff.add (ContDiff.sub (ContDiff.mul contDiff_const contDiff_posSq)
    (ContDiff.mul contDiff_const h2)) (ContDiff.mul contDiff_const h3)

theorem smoothStep_of_nonpos {y : ℝ} (hy : y ≤ 0) : smoothStep y = 0 := by
  unfold smoothStep posSq
  rw [max_eq_right hy, max_eq_right (show y - 1 / 2 ≤ 0 by linarith),
    max_eq_right (show y - 1 ≤ 0 by linarith)]
  norm_num

theorem smoothStep_of_one_le {y : ℝ} (hy : 1 ≤ y) : smoothStep y = 1 := by
  simp only [smoothStep, posSq, max_eq_left (show 0 ≤ y by linarith),
    max_eq_left (show 0 ≤ y - 1 / 2 by linarith), max_eq_left (show 0 ≤ y - 1 by linarith)]
  ring

theorem smoothStep_mem (y : ℝ) : 0 ≤ smoothStep y ∧ smoothStep y ≤ 1 := by
  rcases le_total y 0 with h0 | h0
  · rw [smoothStep_of_nonpos h0]; norm_num
  rcases le_total y (1 / 2) with h1 | h1
  · simp only [smoothStep, posSq, max_eq_left h0, max_eq_right (show y - 1 / 2 ≤ 0 by linarith),
      max_eq_right (show y - 1 ≤ 0 by linarith)]
    constructor <;> nlinarith
  rcases le_total y 1 with h2 | h2
  · simp only [smoothStep, posSq, max_eq_left h0, max_eq_left (show 0 ≤ y - 1 / 2 by linarith),
      max_eq_right (show y - 1 ≤ 0 by linarith)]
    constructor <;> nlinarith
  · rw [smoothStep_of_one_le h2]; norm_num

theorem smoothStepDeriv_abs_le (y : ℝ) : |smoothStepDeriv y| ≤ 2 := by
  unfold smoothStepDeriv
  rcases le_total y 0 with h0 | h0
  · rw [max_eq_right h0, max_eq_right (show y - 1 / 2 ≤ 0 by linarith),
      max_eq_right (show y - 1 ≤ 0 by linarith)]
    norm_num
  rcases le_total y (1 / 2) with h1 | h1
  · rw [max_eq_left h0, max_eq_right (show y - 1 / 2 ≤ 0 by linarith),
      max_eq_right (show y - 1 ≤ 0 by linarith), abs_le]
    constructor <;> linarith
  rcases le_total y 1 with h2 | h2
  · rw [max_eq_left h0, max_eq_left (show 0 ≤ y - 1 / 2 by linarith),
      max_eq_right (show y - 1 ≤ 0 by linarith), abs_le]
    constructor <;> linarith
  · rw [max_eq_left h0, max_eq_left (show 0 ≤ y - 1 / 2 by linarith),
      max_eq_left (show 0 ≤ y - 1 by linarith), abs_le]
    constructor <;> linarith

theorem smoothStepDeriv_of_one_le {y : ℝ} (hy : 1 ≤ y) : smoothStepDeriv y = 0 := by
  unfold smoothStepDeriv
  rw [max_eq_left (show 0 ≤ y by linarith), max_eq_left (show 0 ≤ y - 1 / 2 by linarith),
    max_eq_left (show 0 ≤ y - 1 by linarith)]
  ring

/-- The bump `φ_h(x) = s(x/h + 2) s(2 - x/h)`. -/
def bump (h x : ℝ) : ℝ := smoothStep (x / h + 2) * smoothStep (2 - x / h)

theorem contDiff_bump (h : ℝ) : ContDiff ℝ 1 (bump h) := by
  have h1 : ContDiff ℝ 1 fun x : ℝ => smoothStep (x / h + 2) :=
    contDiff_smoothStep.comp (ContDiff.add (ContDiff.div_const contDiff_id h) contDiff_const)
  have h2 : ContDiff ℝ 1 fun x : ℝ => smoothStep (2 - x / h) :=
    contDiff_smoothStep.comp (ContDiff.sub contDiff_const (ContDiff.div_const contDiff_id h))
  exact ContDiff.mul h1 h2

theorem bump_mem (h x : ℝ) : 0 ≤ bump h x ∧ bump h x ≤ 1 := by
  obtain ⟨a0, a1⟩ := smoothStep_mem (x / h + 2)
  obtain ⟨b0, b1⟩ := smoothStep_mem (2 - x / h)
  unfold bump
  exact ⟨mul_nonneg a0 b0, mul_le_one₀ a1 b0 b1⟩

theorem bump_eq_one {h x : ℝ} (hh : 0 < h) (hx : |x| ≤ h) : bump h x = 1 := by
  have hx' : |x / h| ≤ 1 := by rw [abs_div, abs_of_pos hh, div_le_one hh]; exact hx
  obtain ⟨hl, hr⟩ := abs_le.mp hx'
  unfold bump
  rw [smoothStep_of_one_le (by linarith), smoothStep_of_one_le (by linarith), one_mul]

theorem bump_eq_zero {h x : ℝ} (hh : 0 < h) (hx : 2 * h < |x|) : bump h x = 0 := by
  unfold bump
  rcases le_total 0 x with h0 | h0
  · rw [abs_of_nonneg h0] at hx
    have : 2 < x / h := by rw [lt_div_iff₀ hh]; linarith
    rw [smoothStep_of_nonpos (show 2 - x / h ≤ 0 by linarith), mul_zero]
  · rw [abs_of_nonpos h0] at hx
    have : x / h < -2 := by rw [div_lt_iff₀ hh]; linarith
    rw [smoothStep_of_nonpos (show x / h + 2 ≤ 0 by linarith), zero_mul]

theorem hasDerivAt_bump {h : ℝ} (x : ℝ) :
    HasDerivAt (bump h) (smoothStepDeriv (x / h + 2) * (1 / h) * smoothStep (2 - x / h) +
      smoothStep (x / h + 2) * (smoothStepDeriv (2 - x / h) * (-(1 / h)))) x := by
  have ha : HasDerivAt (fun x : ℝ => x / h + 2) (1 / h) x := by
    simpa using ((hasDerivAt_id x).div_const h).add_const 2
  have hb : HasDerivAt (fun x : ℝ => 2 - x / h) (-(1 / h)) x := by
    simpa using ((hasDerivAt_id x).div_const h).const_sub 2
  have h1 := (hasDerivAt_smoothStep (x / h + 2)).comp x ha
  have h2 := (hasDerivAt_smoothStep (2 - x / h)).comp x hb
  exact h1.mul h2

theorem abs_deriv_bump_le {h : ℝ} (hh : 0 < h) (x : ℝ) : |deriv (bump h) x| ≤ 2 / h := by
  rw [(hasDerivAt_bump x).deriv]
  have hinv : 0 < 1 / h := by positivity
  rcases le_total 0 x with h0 | h0
  · have hx : 1 ≤ x / h + 2 := by have := div_nonneg h0 hh.le; linarith
    rw [smoothStepDeriv_of_one_le hx, smoothStep_of_one_le hx]
    simp only [zero_mul, zero_add, one_mul]
    rw [abs_mul, abs_neg, abs_of_pos hinv]
    calc |smoothStepDeriv (2 - x / h)| * (1 / h) ≤ 2 * (1 / h) :=
          mul_le_mul_of_nonneg_right (smoothStepDeriv_abs_le _) hinv.le
      _ = 2 / h := by ring
  · have hx : 1 ≤ 2 - x / h := by have := div_nonpos_of_nonpos_of_nonneg h0 hh.le; linarith
    rw [smoothStepDeriv_of_one_le hx, smoothStep_of_one_le hx]
    simp only [zero_mul, mul_zero, add_zero, mul_one]
    rw [abs_mul, abs_of_pos hinv]
    calc |smoothStepDeriv (x / h + 2)| * (1 / h) ≤ 2 * (1 / h) :=
          mul_le_mul_of_nonneg_right (smoothStepDeriv_abs_le _) hinv.le
      _ = 2 / h := by ring

end

end Paulsen.Paper
