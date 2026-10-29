import StrictCausalPicard
import Mathlib.Algebra.Order.Group.MinMax
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

noncomputable section
namespace ConditionalNonpolynomial.Analytic
variable {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
variable [NormedAddCommGroup F]

def radialClip (s : ℝ) (x : E) : E := (s/max s ‖x‖) • x

theorem radialClip_norm_le {s : ℝ} (hs : 0<s) (x : E) : ‖radialClip s x‖≤s := by
  have hd : 0<max s ‖x‖ := hs.trans_le (le_max_left _ _)
  rw [radialClip,norm_smul,Real.norm_eq_abs,abs_of_pos (div_pos hs hd)]
  calc
    _ ≤ (s/max s ‖x‖)*max s ‖x‖ :=
      mul_le_mul_of_nonneg_left (le_max_right _ _) (div_nonneg hs.le hd.le)
    _ = s := div_mul_cancel₀ _ hd.ne'

theorem radialClip_eq_self {s : ℝ} (hs : 0<s) {x : E} (hx : ‖x‖≤s) :
    radialClip s x=x := by
  rw [radialClip,max_eq_left hx,div_self hs.ne',one_smul]

theorem radialClip_zero {s : ℝ} : radialClip s (0:E)=0 := by simp [radialClip]

lemma radialClip_distance_ordered {s : ℝ} (hs : 0<s) (x y : E) (hxy : ‖x‖≤‖y‖) :
    ‖radialClip s x-radialClip s y‖≤2*‖x-y‖ := by
  let A := max s ‖x‖
  let B := max s ‖y‖
  let a := s/A
  let b := s/B
  have hA : 0<A := hs.trans_le (le_max_left _ _)
  have hB : 0<B := hs.trans_le (le_max_left _ _)
  have hAB : A≤B := max_le_max le_rfl hxy
  have hab : b≤a := div_le_div_of_nonneg_left hs.le hA hAB
  have hb : 0≤b := div_nonneg hs.le hB.le
  have hb1 : b≤1 := (div_le_one hB).mpr (le_max_left _ _)
  have hdiff : 0≤a-b := sub_nonneg.mpr hab
  have hscale : (a-b)*A=b*(B-A) := by
    dsimp [a,b]
    field_simp
  have hterm : (a-b)*‖x‖≤B-A := by
    calc
      _ ≤ (a-b)*A := mul_le_mul_of_nonneg_left (le_max_right _ _) hdiff
      _ = b*(B-A) := hscale
      _ ≤ 1*(B-A) := mul_le_mul_of_nonneg_right hb1 (sub_nonneg.mpr hAB)
      _ = B-A := one_mul _
  have hgap : B-A≤‖x-y‖ := by
    have hm := max_sub_max_le_max s ‖y‖ s ‖x‖
    rw [sub_self,max_eq_right (sub_nonneg.mpr hxy)] at hm
    exact hm.trans (by simpa only [norm_sub_rev] using norm_sub_norm_le y x)
  have he : radialClip s x-radialClip s y=(a-b) • x+b • (x-y) := by
    change a • x-b • y=(a-b) • x+b • (x-y)
    rw [sub_smul,smul_sub]
    abel
  rw [he]
  calc
    _ ≤ ‖(a-b) • x‖+‖b • (x-y)‖ := norm_add_le _ _
    _ = (a-b)*‖x‖+b*‖x-y‖ := by
      rw [norm_smul,norm_smul,Real.norm_eq_abs,Real.norm_eq_abs,
        abs_of_nonneg hdiff,abs_of_nonneg hb]
    _ ≤ (B-A)+‖x-y‖ := add_le_add hterm
      (by simpa only [one_mul] using mul_le_mul_of_nonneg_right hb1 (norm_nonneg (x-y)))
    _ ≤ 2*‖x-y‖ := by linarith

/-- A dimension-independent global bound; factor two is sufficient for the
logarithmic nonlinear budget used in the parallel computation. -/
theorem radialClip_distance {s : ℝ} (hs : 0<s) (x y : E) :
    ‖radialClip s x-radialClip s y‖≤2*‖x-y‖ := by
  rcases le_total ‖x‖ ‖y‖ with h | h
  · exact radialClip_distance_ordered hs x y h
  · simpa only [norm_sub_rev] using radialClip_distance_ordered hs y x h

theorem radial_residual_lipschitz (N : E → F) {s ℓ : ℝ} (hs : 0<s) (hℓ : 0≤ℓ)
    (hN : ∀x y,‖x‖≤s → ‖y‖≤s → ‖N x-N y‖≤ℓ*‖x-y‖) (x y : E) :
    ‖N (radialClip s x)-N (radialClip s y)‖≤(2*ℓ)*‖x-y‖ := by
  have hh := hN _ _ (radialClip_norm_le hs x) (radialClip_norm_le hs y)
  exact hh.trans (by nlinarith [mul_le_mul_of_nonneg_left (radialClip_distance hs x y) hℓ])

theorem radial_residual_range (N : E → F) {s ℓ : ℝ} (hs : 0<s) (hℓ : 0≤ℓ)
    (hzero : N 0=0)
    (hN : ∀x y,‖x‖≤s → ‖y‖≤s → ‖N x-N y‖≤ℓ*‖x-y‖) (x : E) :
    ‖N (radialClip s x)‖≤ℓ*s := by
  have hh := hN (radialClip s x) 0 (radialClip_norm_le hs x) (by simpa using hs.le)
  rw [hzero,sub_zero,sub_zero] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left (radialClip_norm_le hs x) hℓ)

#print axioms radialClip_distance
#print axioms radial_residual_range
end ConditionalNonpolynomial.Analytic
