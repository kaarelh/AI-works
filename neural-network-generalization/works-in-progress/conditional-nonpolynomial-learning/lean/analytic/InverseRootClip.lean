import CanonicalCompletion

noncomputable section
namespace ConditionalNonpolynomial.Analytic

def inverseRootClip (s : ℝ) : ℝ := (Real.sqrt (max 1 s))⁻¹

lemma inverseRootClip_nonneg (s : ℝ) : 0 ≤ inverseRootClip s := by unfold inverseRootClip; positivity

lemma sqrt_max_one_ge (s : ℝ) : 1≤Real.sqrt (max 1 s) := by
  have hh := Real.sqrt_le_sqrt (le_max_left (1:ℝ) s)
  simpa only [Real.sqrt_one] using hh

lemma inverseRootClip_le_one (s : ℝ) : inverseRootClip s≤1 := by
  unfold inverseRootClip
  exact inv_le_one_of_one_le₀ (sqrt_max_one_ge s)

lemma inv_difference_le {a b : ℝ} (ha : 1≤a) (hb : 1≤b) :
    |a⁻¹-b⁻¹|≤|a-b| := by
  have hap : 0<a := by linarith
  have hbp : 0<b := by linarith
  have heq : a⁻¹-b⁻¹=(b-a)/(a*b) := by field_simp <;> ring
  rw [heq,abs_div,abs_of_pos (mul_pos hap hbp),abs_sub_comm b a]
  apply (div_le_iff₀ (mul_pos hap hbp)).mpr
  have hh : 1≤a*b := by nlinarith
  nlinarith [mul_nonneg (abs_nonneg (a-b)) (sub_nonneg.mpr hh)]

theorem inverseRootClip_modulus (s t : ℝ) :
    |inverseRootClip s-inverseRootClip t|≤Real.sqrt |s-t| := by
  have hi := inv_difference_le (sqrt_max_one_ge s) (sqrt_max_one_ge t)
  have hs := sqrt_difference_bound (show 0≤max 1 s by linarith [le_max_left (1:ℝ) s])
    (show 0≤max 1 t by linarith [le_max_left (1:ℝ) t])
  have hm : |max 1 s-max 1 t|≤|s-t| := by
    simpa only [max_comm s 1,max_comm t 1] using abs_max_sub_max_le_abs s t 1
  exact hi.trans (hs.trans (Real.sqrt_le_sqrt hm))

#print axioms inverseRootClip_modulus
end ConditionalNonpolynomial.Analytic
