import Mathlib.Analysis.Convex.Deriv
import Mathlib.Analysis.Calculus.Deriv.Pow

/-! Quantitative local optimization with a uniformly negative second derivative. -/
noncomputable section
open Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma concave_tangent_upper {D:Set ℝ} {f:ℝ→ℝ} (hf:ConcaveOn ℝ D f)
    {c x p:ℝ} (hc:c∈D) (hx:x∈D) (hd:HasDerivAt f p c) :
    f x≤f c+p*(x-c) := by
  have hneg:ConvexOn ℝ D (-f) := hf.neg
  rcases lt_trichotomy c x with h|h|h
  · have hh:=hneg.le_slope_of_hasDerivAt hc hx h hd.neg
    rw [slope_def_field] at hh
    change -p≤(-f x- -f c)/(x-c) at hh
    nlinarith [(le_div_iff₀ (sub_pos.mpr h)).mp hh]
  · subst x; simp
  · have hh:=hneg.slope_le_of_hasDerivAt hx hc h hd.neg
    rw [slope_def_field] at hh
    change (-f c- -f x)/(c-x)≤-p at hh
    nlinarith [(div_le_iff₀ (sub_pos.mpr h)).mp hh]

lemma strongly_concave_derivative_antitone {D:Set ℝ} (hD:Convex ℝ D)
    (f' f'':ℝ→ℝ) (κ c:ℝ)
    (hd:∀x∈D,HasDerivAt f' (f'' x) x) (hb:∀x∈D,f'' x≤-κ) :
    AntitoneOn (fun x=>f' x+κ*(x-c)) D := by
  have hder (x:ℝ) (hx:x∈D) :
      HasDerivAt (fun y=>f' y+κ*(y-c)) (f'' x+κ) x := by
    convert! (hd x hx).add (((hasDerivAt_id x).sub_const c).const_mul κ) using 1 <;> simp
  apply antitoneOn_of_hasDerivWithinAt_nonpos hD
    (fun x hx=>(hder x hx).continuousAt.continuousWithinAt)
    (fun x hx=>(hder x (interior_subset hx)).hasDerivWithinAt)
  intro x hx
  linarith [hb x (interior_subset hx)]

/-- A literal quadratic upper support bound on any convex real domain. -/
theorem strongly_concave_quadratic_upper {D:Set ℝ} (hD:Convex ℝ D)
    (f f' f'':ℝ→ℝ) (κ:ℝ)
    (h1:∀x∈D,HasDerivAt f (f' x) x)
    (h2:∀x∈D,HasDerivAt f' (f'' x) x)
    (hb:∀x∈D,f'' x≤-κ) {c x:ℝ} (hc:c∈D) (hx:x∈D) :
    f x≤f c+f' c*(x-c)-κ/2*(x-c)^2 := by
  let g:ℝ→ℝ:=fun y=>f y+κ/2*(y-c)^2
  have hg (y:ℝ) (hy:y∈D) : HasDerivAt g (f' y+κ*(y-c)) y := by
    convert! (h1 y hy).add ((((hasDerivAt_id y).sub_const c).pow 2).const_mul (κ/2)) using 1 <;> dsimp [g] <;> ring
  have hanti:=strongly_concave_derivative_antitone hD f' f'' κ c h2 hb
  have hgconc:ConcaveOn ℝ D g := by
    apply AntitoneOn.concaveOn_of_deriv hD
      (fun y hy=>(hg y hy).continuousAt.continuousWithinAt)
      (fun y hy=>(hg y (interior_subset hy)).differentiableAt.differentiableWithinAt)
    intro u hu v hv huv
    rw [(hg u (interior_subset hu)).deriv,(hg v (interior_subset hv)).deriv]
    exact hanti (interior_subset hu) (interior_subset hv) huv
  have ht:=concave_tangent_upper hgconc hc hx (hg c hc)
  dsimp [g] at ht
  nlinarith

/-- An O(ε) derivative perturbation yields only O(ε²) improvement in the
optimized value. This is the estimate needed after the periodic peak losses. -/
theorem strongly_concave_value_improvement {D:Set ℝ} (hD:Convex ℝ D)
    (f f' f'':ℝ→ℝ) (κ ε:ℝ) (hκ:0<κ) (hε:0≤ε)
    (h1:∀x∈D,HasDerivAt f (f' x) x)
    (h2:∀x∈D,HasDerivAt f' (f'' x) x)
    (hb:∀x∈D,f'' x≤-κ) {c x:ℝ} (hc:c∈D) (hx:x∈D)
    (hsmall:|f' c|≤ε) : f x≤f c+ε^2/(2*κ) := by
  have ht:=strongly_concave_quadratic_upper hD f f' f'' κ h1 h2 hb hc hx
  have hp:(f' c)^2≤ε^2 := by
    nlinarith [mul_self_le_mul_self (abs_nonneg (f' c)) hsmall,sq_abs (f' c)]
  have hquad:f' c*(x-c)-κ/2*(x-c)^2≤ε^2/(2*κ) := by
    apply (le_div_iff₀ (by positivity : 0<2*κ)).mpr
    nlinarith [sq_nonneg (κ*(x-c)-f' c)]
  linarith

/-- Every stationary point stays within ε/κ of the reference peak. -/
theorem strongly_concave_stationary_distance {D:Set ℝ} (hD:Convex ℝ D)
    (f' f'':ℝ→ℝ) (κ ε:ℝ) (hκ:0<κ)
    (h2:∀x∈D,HasDerivAt f' (f'' x) x)
    (hb:∀x∈D,f'' x≤-κ) {c x:ℝ} (hc:c∈D) (hx:x∈D)
    (hsmall:|f' c|≤ε) (hstat:f' x=0) : |x-c|≤ε/κ := by
  have hanti:=strongly_concave_derivative_antitone hD f' f'' κ c h2 hb
  apply (le_div_iff₀ hκ).mpr
  rcases le_total c x with h|h
  · have hh:=hanti hc hx h
    dsimp only at hh
    rw [hstat] at hh
    rw [abs_of_nonneg (sub_nonneg.mpr h)]
    nlinarith [(le_abs_self (f' c)).trans hsmall]
  · have hh:=hanti hx hc h
    dsimp only at hh
    rw [hstat] at hh
    rw [abs_of_nonpos (sub_nonpos.mpr h)]
    nlinarith [(neg_le_abs (f' c)).trans hsmall]

end NeuralGeneralization.OnlineLowerTanh
