import GainClippedGrid

noncomputable section
open scoped RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {E:Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem radialClip_variational {s:ℝ} (hs:0<s) (x y:E) (hy:‖y‖≤s) :
    inner ℝ (x-radialClip s x) (y-radialClip s x)≤0 := by
  by_cases hx:‖x‖≤s
  · rw [radialClip_eq_self hs hx,sub_self,inner_zero_left]
  · have hxs:s<‖x‖ := lt_of_not_ge hx
    have hxn:0<‖x‖ := hs.trans hxs
    have hcoef:0≤1-s/‖x‖ := sub_nonneg.mpr ((div_le_one hxn).mpr hxs.le)
    have hi:inner ℝ x y≤s*‖x‖ :=
      (real_inner_le_norm x y).trans (by nlinarith [norm_nonneg x])
    have he:x-radialClip s x=(1-s/‖x‖) • x := by
      rw [radialClip,max_eq_right hxs.le,sub_smul,one_smul]
    rw [he,real_inner_smul_left,inner_sub_right,radialClip,max_eq_right hxs.le,
      real_inner_smul_right,real_inner_self_eq_norm_sq]
    have hcancel:(s/‖x‖)*‖x‖^2=s*‖x‖ := by field_simp
    rw [hcancel]
    exact mul_nonpos_of_nonneg_of_nonpos hcoef (sub_nonpos.mpr hi)

theorem radialClip_hilbert_contraction {s:ℝ} (hs:0<s) (x y:E) :
    ‖radialClip s x-radialClip s y‖≤‖x-y‖ := by
  let p:=radialClip s x
  let q:=radialClip s y
  have hx:=radialClip_variational hs x q (radialClip_norm_le hs y)
  have hy:=radialClip_variational hs y p (radialClip_norm_le hs x)
  change inner ℝ (x-p) (q-p)≤0 at hx
  change inner ℝ (y-q) (p-q)≤0 at hy
  have he:inner ℝ (x-y) (p-q)=‖p-q‖^2-
      inner ℝ (x-p) (q-p)-inner ℝ (y-q) (p-q) := by
    rw [←real_inner_self_eq_norm_sq]
    simp only [inner_sub_left,inner_sub_right]
    rw [real_inner_comm q p]
    ring
  have hi:=real_inner_le_norm (x-y) (p-q)
  rw [he] at hi
  change ‖p-q‖≤‖x-y‖
  by_cases hpq:‖p-q‖=0
  · rw [hpq];positivity
  · have hpqpos:0<‖p-q‖ := lt_of_le_of_ne (norm_nonneg _) (Ne.symm hpq)
    nlinarith

#print axioms radialClip_hilbert_contraction
end ConditionalNonpolynomial.Analytic
