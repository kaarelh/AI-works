import NeuralGeneralization.OnlineLowerTanhFiniteParityCurvature
import NeuralGeneralization.OnlineLowerTanhBiasSymmetry

/-! Literal second derivatives of normalized affine slices at finite odd degree. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators Topology
namespace NeuralGeneralization.OnlineLowerTanh
open TanhDifferential

def inverseRadialNorm (E t:ℝ) : ℝ := (Real.sqrt (E+t^2))⁻¹
def inverseRadialSlope (E t:ℝ) : ℝ := -t/(Real.sqrt (E+t^2))^3

lemma hasDerivAt_inverseRadialNorm {E:ℝ} (hE:0<E) (t:ℝ) :
    HasDerivAt (inverseRadialNorm E) (inverseRadialSlope E t) t := by
  have he:0<E+t^2:=by positivity
  have hs:0<Real.sqrt (E+t^2):=Real.sqrt_pos.mpr he
  have h:=((((hasDerivAt_id t).pow 2).const_add E).sqrt he.ne').inv hs.ne'
  convert h using 1 <;> (try rfl)
  simp only [inverseRadialSlope,Nat.cast_ofNat,Nat.reduceSub,pow_one,id_eq,Pi.pow_apply,mul_one]
  field_simp
  <;> ring

lemma hasDerivAt_inverseRadialSlope_zero {E:ℝ} (hE:0<E) :
    HasDerivAt (inverseRadialSlope E) (-(1/(Real.sqrt E)^3)) 0 := by
  have hs:0<Real.sqrt E:=Real.sqrt_pos.mpr hE
  have he:0<E+(0:ℝ)^2:=by simpa using hE
  have h:=((hasDerivAt_id (0:ℝ)).neg).div
    (((((hasDerivAt_id (0:ℝ)).pow 2).const_add E).sqrt he.ne').pow 3) (by simpa only [Pi.pow_apply,id_eq,zero_pow (by norm_num : (2:ℕ)≠0),add_zero] using pow_ne_zero 3 hs.ne')
  convert h using 1 <;> (try rfl)
  simp only [Pi.pow_apply,Pi.neg_apply,id_eq,inverseRadialSlope,zero_pow (by norm_num : (2:ℕ)≠0),add_zero,
    mul_zero,zero_mul,zero_div,sub_zero,zpow_neg,zpow_natCast,neg_div]
  field_simp [hs.ne'] <;> ring

/-- Second derivative at the center of an actual scalar quotient by the
Euclidean affine norm. This lemma is applied to explicit finite tanh sums. -/
lemma hasDerivAt_deriv_normalized_zero {E:ℝ} (hE:0<E) (f f':ℝ→ℝ) (fpp:ℝ)
    (hf:∀t,HasDerivAt f (f' t) t) (hf':HasDerivAt f' fpp 0) :
    HasDerivAt (deriv (fun t=>f t/Real.sqrt (E+t^2)))
      (fpp/Real.sqrt E-f 0/(Real.sqrt E)^3) 0 := by
  have hfirst (t:ℝ):HasDerivAt (fun t=>f t/Real.sqrt (E+t^2))
      (f' t*inverseRadialNorm E t+f t*inverseRadialSlope E t) t:=by
    convert (hf t).mul (hasDerivAt_inverseRadialNorm hE t) using 1 <;> (try rfl)
  have heq:deriv (fun t=>f t/Real.sqrt (E+t^2))=
      (fun t=>f' t*inverseRadialNorm E t+f t*inverseRadialSlope E t):=funext (fun t=>(hfirst t).deriv)
  rw [heq]
  have h:=(hf'.mul (hasDerivAt_inverseRadialNorm hE 0)).add
    ((hf 0).mul (hasDerivAt_inverseRadialSlope_zero hE))
  convert h using 1 <;> (try rfl)
  simp only [inverseRadialNorm,inverseRadialSlope,zero_pow (by norm_num : (2:ℕ)≠0),
    add_zero,neg_zero,zero_div,mul_zero,zero_add,add_zero,zpow_neg,zpow_natCast]
  ring

def balancedAffineBiasSlice (r:ℕ) (a b:ℝ) : ℝ :=
  ((-1:ℝ)^r*parityCorrelation (fun _:Fin (2*r+1)=>a) b)/
    Real.sqrt ((2*r+1:ℕ)*a^2+b^2)

/-- The paper's exact normalized bias eigenvalue is an actual second
one-dimensional derivative of the displayed affine quotient. -/
theorem balancedAffineBiasSlice_second (r:ℕ) (a:ℝ) (ha:0<a) :
    HasDerivAt (deriv (balancedAffineBiasSlice r a))
      (balancedBiasCurvature r a/Real.sqrt ((2*r+1:ℕ)*a^2)-
        balancedParity r a/(Real.sqrt ((2*r+1:ℕ)*a^2))^3) 0 := by
  exact hasDerivAt_deriv_normalized_zero (by positivity)
    (fun b=>(-1:ℝ)^r*parityCorrelation (fun _:Fin (2*r+1)=>a) b)
    (fun b=>(-1:ℝ)^r*parityBiasFirst (fun _:Fin (2*r+1)=>a) b)
    (balancedBiasCurvature r a)
    (fun b=>(hasDerivAt_parityCorrelation _ b).const_mul _)
    ((hasDerivAt_parityBiasFirst _ 0).const_mul _)

/-- Every finite odd degree has a strictly negative normalized bias curvature
at every gain at least one. In particular this applies to the unique optimizer. -/
theorem balancedAffineBiasSlice_second_neg (r:ℕ) (a:ℝ) (ha:1≤a) :
    deriv (deriv (balancedAffineBiasSlice r a)) 0<0 := by
  rw [(balancedAffineBiasSlice_second r a (by linarith)).deriv]
  have hs:0<Real.sqrt ((2*r+1:ℕ)*a^2):=by positivity
  have hcurv:=balancedBiasCurvature_neg r a ha
  have hq:0<balancedParity r a:=by
    have hh:=balancedParity_lower r a (by linarith)
    have ht:3/4<Real.tanh a:=tanh_one_gt_three_quarters.trans_le (scalar_tanh_monotone ha)
    exact lt_of_lt_of_le (mul_pos (oddParityKappa_pos r) (by linarith)) hh
  exact sub_neg.mpr ((div_neg_of_neg_of_pos hcurv hs).trans (div_pos hq (by positivity)))


/-- Actual second derivative along the balanced-gain line, at its unique
finite-degree optimum. -/
theorem balancedRatio_second_at_gain (r:ℕ) (hr:2≤r) :
    HasDerivAt (deriv (balancedRatio r))
      (balancedParitySecond r (balancedGain r)/balancedGain r) (balancedGain r) := by
  let a:=balancedGain r
  have ha:0<a:=balancedGain_pos r
  have hz:balancedStationary r a=0:=(balancedGain_interior_and_stationary r hr).2
  have hh:= (hasDerivAt_balancedStationary r a).div ((hasDerivAt_id a).pow 2) (pow_ne_zero _ ha.ne')
  have hd:HasDerivAt (fun x=>balancedStationary r x/x^2)
      (balancedParitySecond r a/a) a:=by
    convert hh using 1 <;> (try rfl)
    simp only [hz,zero_mul,sub_zero,id_eq,Pi.pow_apply]
    field_simp
  have he:deriv (balancedRatio r) =ᶠ[𝓝 a] (fun x=>balancedStationary r x/x^2):=by
    filter_upwards [isOpen_Ioi.mem_nhds ha] with x hx
    exact (hasDerivAt_balancedRatio r x hx.ne').deriv
  exact hd.congr_of_eventuallyEq he

/-- The radial scalar curvature is strictly negative at every odd degree at
least five, without an eventual-degree restriction. -/
theorem balancedRatio_second_at_gain_neg (r:ℕ) (hr:2≤r) :
    deriv (deriv (balancedRatio r)) (balancedGain r)<0 := by
  rw [(balancedRatio_second_at_gain r hr).deriv]
  exact div_neg_of_neg_of_pos
    (balancedParitySecond_neg r (balancedGain r) (balancedGain_mem r).1) (balancedGain_pos r)

end NeuralGeneralization.OnlineLowerTanh
