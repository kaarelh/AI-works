import NeuralGeneralization.BatchTwoMergingGeluAnalytic

/-! Uniformly Lipschitz population-normalized GELU activations. Only positive
population scales are needed: padded zero neurons can use scale one, and the
finite grid rounds positive scales to positive grid points. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoMerging

def geluPerspective (r u : ℝ) : ℝ := r*gelu (u/r)

@[simp] theorem geluPerspective_zero (r : ℝ) : geluPerspective r 0=0 := by
  simp [geluPerspective]

theorem geluPerspective_abs_le {r : ℝ} (hr : 0<r) (u : ℝ) :
    |geluPerspective r u|≤|u| := by
  unfold geluPerspective
  rw [abs_mul,abs_of_pos hr]
  have h := mul_le_mul_of_nonneg_left (gelu_abs_le (u/r)) hr.le
  rw [abs_div,abs_of_pos hr] at h
  have he : r*(|u| /r)=|u| := by field_simp
  rw [he] at h
  exact h

theorem geluPerspective_input_lipschitz {r : ℝ} (hr : 0<r) (u v : ℝ) :
    |geluPerspective r u-geluPerspective r v|≤2*|u-v| := by
  have h := gelu_lipschitz.dist_le_mul (u/r) (v/r)
  simp only [Real.dist_eq,NNReal.coe_ofNat] at h
  have hh := mul_le_mul_of_nonneg_left h hr.le
  rw [←sub_div,abs_div,abs_of_pos hr] at hh
  unfold geluPerspective
  rw [←mul_sub,abs_mul,abs_of_pos hr]
  have he : r*(2*(|u-v| /r))=2*|u-v| := by field_simp
  exact hh.trans_eq he

theorem hasDerivAt_geluPerspective_scale {r : ℝ} (hr : r≠0) (u : ℝ) :
    HasDerivAt (fun t=>geluPerspective t u) (-(u/r)^2*normalPDF (u/r)) r := by
  have hi : HasDerivAt (fun t:ℝ=>u/t) (-u/r^2) r := by
    convert (hasDerivAt_const r u).div (hasDerivAt_id' r) hr using 1 <;> first | rfl | simp
  have hg := (hasDerivAt_gelu (u/r)).comp r hi
  have hh := (hasDerivAt_id' r).mul hg
  convert hh using 1 <;> try rfl
  simp only [geluPerspective,gelu,Pi.mul_apply,Function.comp_apply,one_mul]
  field_simp [hr]
  <;> ring

theorem geluPerspective_scale_lipschitz {r s : ℝ} (hr : 0<r) (hs : 0<s) (u : ℝ) :
    |geluPerspective r u-geluPerspective s u|≤|r-s| := by
  have hd (t : ℝ) (ht : t∈Ioi (0:ℝ)) : DifferentiableAt ℝ (fun t=>geluPerspective t u) t :=
    (hasDerivAt_geluPerspective_scale ht.ne' u).differentiableAt
  have hb (t : ℝ) (ht : t∈Ioi (0:ℝ)) :
      ‖deriv (fun t=>geluPerspective t u) t‖≤(1:ℝ) := by
    rw [(hasDerivAt_geluPerspective_scale ht.ne' u).deriv,Real.norm_eq_abs,
      abs_mul,abs_neg,abs_sq,abs_of_nonneg (show 0≤normalPDF (u/t) from gaussianPDFReal_nonneg 0 1 (u/t))]
    exact (normalPDF_monomial_bound (u/t)).2
  have h := (convex_Ioi (0:ℝ)).norm_image_sub_le_of_norm_deriv_le hd hb hs hr
  simpa only [Real.norm_eq_abs,one_mul] using h

theorem geluPerspective_joint_lipschitz {r s : ℝ} (hr : 0<r) (hs : 0<s)
    (u v : ℝ) :
    |geluPerspective r u-geluPerspective s v|≤2*|u-v|+|r-s| := by
  have h := abs_sub_le (geluPerspective r u) (geluPerspective r v) (geluPerspective s v)
  linarith [geluPerspective_input_lipschitz hr u v,geluPerspective_scale_lipschitz hr hs v]

end NeuralGeneralization.BatchTwoMerging
