import ScalarOccupation
import TargetPolynomialFloor

/-! Occupation under arbitrary nonnegative forcing. A shifted logarithmic
potential gives a square-root dependence on total forcing, uniformly in its
placement along the trajectory. -/
noncomputable section
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

lemma shifted_log_drift {a b e c δ : ℝ} (ha : 0≤a) (hb : 0≤b)
    (he : 0≤e) (hc : 0<c) (hδ : 0<δ) (hd : b-a≤-c*a^2+e) :
    c*a≤c*δ+e/δ+Real.log (a+δ)-Real.log (b+δ) := by
  have haδ : 0<a+δ := by linarith
  have hbδ : 0<b+δ := by linarith
  have hl := Real.log_le_sub_one_of_pos (div_pos hbδ haδ)
  rw [Real.log_div hbδ.ne' haδ.ne'] at hl
  have hratio : (b+δ)/(a+δ)-1=(b-a)/(a+δ) := by field_simp; ring
  rw [hratio] at hl
  have hstep := div_le_div_of_nonneg_right hd haδ.le
  have hquad : a-δ≤a^2/(a+δ) := by
    apply (le_div_iff₀ haδ).mpr
    nlinarith [sq_nonneg δ]
  have hquadmul := mul_le_mul_of_nonneg_left hquad hc.le
  have hediv : e/(a+δ)≤e/δ := div_le_div_of_nonneg_left he hδ (by linarith)
  have hexpand : (-c*a^2+e)/(a+δ)= -c*(a^2/(a+δ))+e/(a+δ) := by ring
  rw [hexpand] at hstep
  linarith

theorem shifted_log_occupation (J : ℕ) (q e : ℕ→ℝ) {c δ : ℝ}
    (hc : 0<c) (hδ : 0<δ) (hq : ∀j≤J,0≤q j) (he : ∀j<J,0≤e j)
    (hd : ∀j<J,q (j+1)-q j≤-c*(q j)^2+e j) :
    c*(∑j∈Finset.range J,q j)≤c*(J:ℝ)*δ+(∑j∈Finset.range J,e j)/δ+
      Real.log (q 0+δ)-Real.log (q J+δ) := by
  induction J with
  | zero=>simp
  | succ J ih=>
    have hh := ih (fun j hj=>hq j (by omega)) (fun j hj=>he j (by omega))
      (fun j hj=>hd j (by omega))
    have hs := shifted_log_drift (hq J (by omega)) (hq (J+1) le_rfl)
      (he J (by omega)) hc hδ (hd J (by omega))
    rw [Finset.sum_range_succ,Finset.sum_range_succ,Nat.cast_add,Nat.cast_one,add_div]
    nlinarith

/-- A precise logarithmic occupation estimate for arbitrary forcing. Only the
initial state needs an upper bound; intermediate states need merely be
nonnegative. -/
theorem forced_cooling_occupation_precise (J : ℕ) (q e : ℕ→ℝ) {c : ℝ}
    (hc : 0<c) (hq : ∀j≤J,0≤q j) (hq0 : q 0≤1) (he : ∀j<J,0≤e j)
    (hd : ∀j<J,q (j+1)-q j≤-c*(q j)^2+e j) :
    c*(∑j∈Finset.range J,q j)≤c+(c+1)*Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,e j))+
      Real.log ((J:ℝ)+1) := by
  by_cases hJ : J=0
  · subst J
    simp
    exact hc.le
  have hJ0 : (0:ℝ)<J := by exact_mod_cast (Nat.pos_of_ne_zero hJ)
  let E := ∑j∈Finset.range J,e j
  have hE : 0≤E := Finset.sum_nonneg fun j hj=>he j (Finset.mem_range.mp hj)
  let s := Real.sqrt ((J:ℝ)*E)
  have hs : 0≤s := Real.sqrt_nonneg _
  have hs2 : s^2=(J:ℝ)*E := Real.sq_sqrt (mul_nonneg hJ0.le hE)
  let δ := (1+s)/(J:ℝ)
  have hδ : 0<δ := by dsimp [δ]; positivity
  have hδid : (J:ℝ)*δ=1+s := by dsimp [δ]; field_simp
  have hEd : E/δ≤s := by
    apply (div_le_iff₀ hδ).mpr
    have hh : E*(J:ℝ)≤s*(1+s) := by nlinarith
    have hh' := (le_div_iff₀ hJ0).mpr hh
    simpa only [δ,mul_div_assoc] using hh'
  have hInv : 1/δ≤(J:ℝ) := (div_le_iff₀ hδ).mpr (by linarith)
  have hqJ : 0≤q J := hq J le_rfl
  have hlog0 := Real.log_le_log (show 0<q 0+δ by linarith [hq 0 (by omega)])
    (show q 0+δ≤1+δ by linarith)
  have hlogJ := Real.log_le_log hδ (show δ≤q J+δ by linarith)
  have hratio : (1+δ)/δ≤(J:ℝ)+1 := by
    have hh : (1+δ)/δ=1+1/δ := by field_simp; ring
    rw [hh]
    linarith
  have hlogRatio := Real.log_le_log (div_pos (by linarith : 0<1+δ) hδ) hratio
  rw [Real.log_div (by positivity : 1+δ≠0) hδ.ne'] at hlogRatio
  have hbound := shifted_log_occupation J q e hc hδ hq he hd
  change c*(∑j∈Finset.range J,q j)≤c*(J:ℝ)*δ+E/δ+Real.log (q 0+δ)-Real.log (q J+δ) at hbound
  have hid : c*(J:ℝ)*δ=c*(1+s) := by rw [mul_assoc,hδid]
  rw [hid] at hbound
  change _≤c+(c+1)*s+Real.log ((J:ℝ)+1)
  nlinarith only [hbound,hEd,hlog0,hlogJ,hlogRatio]

/-- Universal square-root-forcing occupation bound, with a constant depending
only on the cooling coefficient and independent of total forcing. -/
theorem forced_cooling_occupation (J : ℕ) (q e : ℕ→ℝ) {c : ℝ}
    (hc : 0<c) (hq : ∀j≤J,0≤q j) (hq0 : q 0≤1) (he : ∀j<J,0≤e j)
    (hd : ∀j<J,q (j+1)-q j≤-c*(q j)^2+e j) :
    (∑j∈Finset.range J,q j)≤
      (2+1/c)*(Real.log ((J:ℝ)+2)+Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,e j))) := by
  have hh := forced_cooling_occupation_precise J q e hc hq hq0 he hd
  have hlog : 1/2≤Real.log ((J:ℝ)+2) := logarithm_half_le (by linarith [Nat.cast_nonneg (α:=ℝ) J])
  have hlogmono := Real.log_le_log (by positivity : 0<(J:ℝ)+1)
    (show (J:ℝ)+1≤(J:ℝ)+2 by linarith)
  have hs := Real.sqrt_nonneg ((J:ℝ)*(∑j∈Finset.range J,e j))
  apply (mul_le_mul_iff_right₀ hc).mp
  have hid : c*((2+1/c)*(Real.log ((J:ℝ)+2)+Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,e j))))=
      (2*c+1)*(Real.log ((J:ℝ)+2)+Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,e j))) := by
    field_simp
  rw [hid]
  nlinarith

#print axioms forced_cooling_occupation
end ConditionalNonpolynomial.Analytic
