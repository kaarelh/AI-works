import NeuralGeneralization.OnlineLowerTanhFiniteParityGradient
import Mathlib.Analysis.Normed.Module.FiniteDimension

/-! A full affine neighborhood of strict optimality at every finite odd degree. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

/-- Compactness of the direction sphere turns strict second derivatives into
a single neighborhood, uniformly over all directions. -/
lemma uniform_strict_tangent {E:Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [ProperSpace E] (g g' g'':E→ℝ→ℝ)
    (hd:∀v t,HasDerivAt (g v) (g' v t) t)
    (hdd:∀v t,HasDerivAt (g' v) (g'' v t) t)
    (hc:Continuous (fun p:ℝ×E=>g'' p.2 p.1))
    (hneg:∀v,‖v‖=1 → g'' v 0<0) :
    ∃ε>0,∀v,‖v‖=1 → ∀t,0<t → t<ε → g v t<g v 0+t*g' v 0 := by
  have hev:∀ᶠ t in 𝓝 (0:ℝ),∀v∈Metric.sphere (0:E) 1,g'' v t<0:=by
    apply (isCompact_sphere (0:E) 1).eventually_forall_of_forall_eventually
    intro v hv
    have hv':‖v‖=1:=by simpa only [Metric.mem_sphere,dist_zero_right] using hv
    exact (isOpen_Iio.preimage hc).mem_nhds (hneg v hv')
  obtain ⟨ε,hε,hball⟩:=Metric.mem_nhds_iff.mp hev
  refine ⟨ε,hε,?_⟩
  intro v hv t ht htε
  have hsec (x:ℝ) (hx:x∈Icc 0 t):g'' v x<0:=by
    apply hball (show x∈Metric.ball (0:ℝ) ε by
      simpa only [Metric.mem_ball,dist_zero_right,Real.norm_eq_abs,abs_of_nonneg hx.1] using hx.2.trans_lt htε)
      v
    simpa only [Metric.mem_sphere,dist_zero_right] using hv
  have hanti:StrictAntiOn (g' v) (Icc 0 t):=by
    apply strictAntiOn_of_deriv_neg (convex_Icc _ _)
      (fun x _=>(hdd v x).continuousAt.continuousWithinAt)
    intro x hx
    rw [(hdd v x).deriv]
    exact hsec x (interior_subset hx)
  obtain ⟨c,hc,hc'⟩:=exists_deriv_eq_slope (g v) ht
    (fun x _=>(hd v x).continuousAt.continuousWithinAt)
    (fun x _=>(hd v x).differentiableAt.differentiableWithinAt)
  have hlt:=hanti (show (0:ℝ)∈Icc 0 t from ⟨le_rfl,ht.le⟩)
    ⟨hc.1.le,hc.2.le⟩ hc.1
  rw [←(hd v c).deriv,hc',sub_zero] at hlt
  have hh: g v t-g v 0<t*g' v 0:=by
    have hh:=(div_lt_iff₀ ht).mp hlt
    nlinarith only [hh]
  linarith

lemma signedAffineNumeratorLineSecond_negative (r:ℕ) (hr:1≤r) (a:ℝ) (ha:1≤a)
    (b:ℝ) (v:Fin (2*r+1)→ℝ) (hnon:b≠0 ∨ v≠0) :
    signedAffineNumeratorLineSecond ((-1:ℝ)^r) a b v 0<0 := by
  rw [signedAffineNumeratorLineSecond_zero]
  cases r with
  | zero => omega
  | succ r =>
    revert v
    rw [show 2*(r+1)+1=2*r+3 by omega]
    intro v hnon
    exact signedCurvatureKernel_affine_negative r a ha b v hnon

lemma affine_direction_nonzero {n:ℕ} (v:Fin (n+1)→ℝ) (hv:‖v‖=1) :
    v 0≠0 ∨ (fun i:Fin n=>v i.succ)≠0 := by
  by_contra h
  push_neg at h
  have he:v=0:=by
    funext i
    refine Fin.cases ?_ (fun j=>?_) i
    · exact h.1
    · exact congrFun h.2 j
  simp [he] at hv

theorem signedAffineNumerator_uniform_strict_tangent (r:ℕ) (hr:1≤r) (a:ℝ) (ha:1≤a) :
    ∃ε>0,∀v:Fin ((2*r+1)+1)→ℝ,‖v‖=1 → ∀t,0<t → t<ε →
      (-1:ℝ)^r*parityCorrelation (fun i=>a+t*v i.succ) (t*v 0)<
        balancedParity r a+t*(balancedParityFirst r a/(2*r+1:ℕ)*(∑i:Fin (2*r+1),v i.succ)) := by
  obtain ⟨ε,hε,h⟩:=uniform_strict_tangent
    (fun v:Fin ((2*r+1)+1)→ℝ=>signedAffineNumeratorLine ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ))
    (fun v=>signedAffineNumeratorLineFirst ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ))
    (fun v=>signedAffineNumeratorLineSecond ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ))
    (fun v t=>hasDerivAt_signedAffineNumeratorLine _ _ _ _ t)
    (fun v t=>hasDerivAt_signedAffineNumeratorLineFirst _ _ _ _ t)
    (by unfold signedAffineNumeratorLineSecond cubeMean finiteLineTanhSecond tanhSecond tanhFirst incomingLinear;fun_prop)
    (fun v hv=>signedAffineNumeratorLineSecond_negative r hr a ha _ _ (affine_direction_nonzero v hv))
  refine ⟨ε,hε,?_⟩
  intro v hv t ht htε
  have hh:=h v hv t ht htε
  rw [signedAffineNumeratorLine_eq_actual,signedAffineNumeratorLine_eq_actual,
    signedAffineNumeratorLineFirst_zero] at hh
  simpa only [zero_mul,add_zero,balancedParity] using hh

lemma balancedAffinePoint_energy (r:ℕ) (a:ℝ) :
    (∑i,(balancedAffinePoint r a i)^2)=((2*r+1:ℕ):ℝ)*a^2 := by
  simp [balancedAffinePoint,Fin.sum_univ_succ]

/-- Strict supporting hyperplane inequality on a full affine neighborhood. -/
theorem signedAffineCoefficient_strict_tangent (r:ℕ) (hr:2≤r) :
    ∀ᶠ z in 𝓝 (balancedAffinePoint r (balancedGain r)),
      z≠balancedAffinePoint r (balancedGain r) →
      (-1:ℝ)^r*affineParityCoefficient (2*r+1) z<
        balancedParity r (balancedGain r)/((2*r+1:ℕ)*balancedGain r)*
          (∑i:Fin (2*r+1),z i.succ) := by
  let a:=balancedGain r
  let x:=balancedAffinePoint r a
  let c:=balancedParity r a/((2*r+1:ℕ)*a)
  have ha:0<a:=balancedGain_pos r
  have hn:((2*r+1:ℕ):ℝ)≠0:=by positivity
  have hs:balancedParityFirst r a/(2*r+1:ℕ)=c:=by
    have hz:a*balancedParityFirst r a-balancedParity r a=0:=
      (balancedGain_interior_and_stationary r hr).2
    dsimp [c]
    field_simp
    nlinarith only [hz]
  obtain ⟨ε,hε,hε'⟩:=signedAffineNumerator_uniform_strict_tangent r (by omega) a
    (balancedGain_mem r).1
  filter_upwards [Metric.ball_mem_nhds x hε] with z hz hne
  let d:=z-x
  have hd:d≠0:=sub_ne_zero.mpr hne
  have hnorm:0<‖d‖:=norm_pos_iff.mpr hd
  let v:=‖d‖⁻¹ • d
  have hv:‖v‖=1:=by
    rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hnorm,inv_mul_cancel₀ hnorm.ne']
  have hvcoord (i:Fin ((2*r+1)+1)):‖d‖*v i=z i-x i:=by
    change ‖d‖*(‖d‖⁻¹*(z i-x i))=_
    rw [←mul_assoc,mul_inv_cancel₀ hnorm.ne',one_mul]
  have hzv (i:Fin (2*r+1)):a+‖d‖*v i.succ=z i.succ:=by
    rw [hvcoord]
    simp only [x,balancedAffinePoint,Fin.cases_succ]
    ring
  have hb:‖d‖*v 0=z 0:=by
    rw [hvcoord]
    simp [x,balancedAffinePoint]
  have ht:‖d‖<ε:=by simpa only [Metric.mem_ball,dist_eq_norm] using hz
  have hh:=hε' v hv ‖d‖ hnorm ht
  simp_rw [hzv] at hh
  rw [hb,hs] at hh
  change (-1:ℝ)^r*affineParityCoefficient (2*r+1) z<_ at hh
  change (-1:ℝ)^r*affineParityCoefficient (2*r+1) z<c*(∑i:Fin (2*r+1),z i.succ)
  have hsum:‖d‖*(∑i:Fin (2*r+1),v i.succ)=
      (∑i:Fin (2*r+1),z i.succ)-((2*r+1:ℕ):ℝ)*a:=by
    rw [Finset.mul_sum]
    simp_rw [hvcoord]
    simp [x,balancedAffinePoint,Finset.sum_sub_distrib]
  have hca:c*(((2*r+1:ℕ):ℝ)*a)=balancedParity r a:=by
    dsimp [c]
    exact div_mul_cancel₀ _ (mul_ne_zero hn ha.ne')
  have he:balancedParity r a+‖d‖*(c*(∑i:Fin (2*r+1),v i.succ))=
      c*(∑i:Fin (2*r+1),z i.succ):=by
    rw [show ‖d‖*(c*(∑i:Fin (2*r+1),v i.succ))=c*(‖d‖*(∑i:Fin (2*r+1),v i.succ)) by ring,
      hsum]
    nlinarith only [hca]
  exact hh.trans_eq he

lemma affine_sum_le_radial {n:ℕ} (hn:0<n) (z:Fin (n+1)→ℝ) :
    (∑i:Fin n,z i.succ)≤Real.sqrt (n:ℝ)*Real.sqrt (∑i,z i^2) := by
  have hvar:=incomingVariance_nonneg hn (fun i=>z i.succ)
  have hnp:(0:ℝ)<n:=Nat.cast_pos.mpr hn
  have hs:0≤∑i:Fin (n+1),z i^2:=Finset.sum_nonneg (fun i _=>sq_nonneg _)
  have hsqrt:=Real.sq_sqrt hs
  have hnroot:=Real.sq_sqrt hnp.le
  have he:(∑i:Fin (n+1),z i^2)=(z 0)^2+incomingEnergy (fun i:Fin n=>z i.succ):=by
    simp [Fin.sum_univ_succ,incomingEnergy]
  have hv:(∑i:Fin n,z i.succ)^2≤(n:ℝ)*incomingEnergy (fun i:Fin n=>z i.succ):=by
    have hv:((∑i:Fin n,z i.succ)^2)/(n:ℝ) ≤ incomingEnergy (fun i=>z i.succ):=by linarith
    exact (div_le_iff₀ hnp).mp hv |>.trans_eq (mul_comm _ _)
  have hp:0≤Real.sqrt (n:ℝ)*Real.sqrt (∑i,z i^2):=by positivity
  have heq:(Real.sqrt (n:ℝ)*Real.sqrt (∑i,z i^2))^2=(n:ℝ)*(∑i,z i^2):=by
    rw [mul_pow,hnroot,hsqrt]
  nlinarith [sq_nonneg (z 0)]

/-- Every odd degree at least five has a strict local maximum in the full
bias and weight space, expressed as a punctured-neighborhood inequality. -/
theorem signedAffineParityRatio_strict_local_maximum (r:ℕ) (hr:2≤r) :
    ∀ᶠ z in 𝓝 (balancedAffinePoint r (balancedGain r)),
      z≠balancedAffinePoint r (balancedGain r) →
      signedAffineParityRatio r z<
        signedAffineParityRatio r (balancedAffinePoint r (balancedGain r)) := by
  let a:=balancedGain r
  let q:=balancedParity r a
  let n:ℝ:=(2*r+1:ℕ)
  have ha:0<a:=balancedGain_pos r
  have hq:0<q:=balancedParity_gain_pos r
  have hn:0<n:=by dsimp [n];positivity
  have hrn:0<Real.sqrt n:=Real.sqrt_pos.mpr hn
  have hbase:(∑i,(balancedAffinePoint r a i)^2)=n*a^2:=balancedAffinePoint_energy r a
  have hevent:∀ᶠ z:Fin ((2*r+1)+1)→ℝ in 𝓝 (balancedAffinePoint r a),0<∑i,z i^2:=by
    have hc:Continuous (fun z:Fin ((2*r+1)+1)→ℝ=>∑i,z i^2):=by fun_prop
    apply (isOpen_Ioi.preimage hc).mem_nhds
    change 0<∑i,(balancedAffinePoint r a i)^2
    rw [hbase]
    positivity
  filter_upwards [signedAffineCoefficient_strict_tangent r hr,hevent] with z hz he hne
  have hrad:0<Real.sqrt (∑i,z i^2):=Real.sqrt_pos.mpr he
  have hsum:=affine_sum_le_radial (by omega : 0<2*r+1) z
  have hc:0<q/(n*a):=by positivity
  have hlt:(-1:ℝ)^r*affineParityCoefficient (2*r+1) z<
      (q/(n*a))*(Real.sqrt n*Real.sqrt (∑i,z i^2)):=
    (hz hne).trans_le (mul_le_mul_of_nonneg_left hsum hc.le)
  have hsqrt:Real.sqrt (n*a^2)=Real.sqrt n*a:=by
    rw [Real.sqrt_mul hn.le,Real.sqrt_sq_eq_abs,abs_of_pos ha]
  have hscale:q/(n*a)*Real.sqrt n=q/Real.sqrt (n*a^2):=by
    rw [hsqrt]
    have hsq:=Real.sq_sqrt hn.le
    field_simp
    nlinarith only [hsq]
  change ((-1:ℝ)^r*affineParityCoefficient (2*r+1) z)/Real.sqrt (∑i,z i^2)<_
  rw [signedAffineParityRatio,affineParityCoefficient_balanced,hbase]
  apply (div_lt_iff₀ hrad).mpr
  change (-1:ℝ)^r*affineParityCoefficient (2*r+1) z<q/Real.sqrt (n*a^2)*Real.sqrt (∑i,z i^2)
  rwa [←mul_assoc,hscale] at hlt

theorem absoluteAffineParityRatio_strict_local_maximum (r:ℕ) (hr:2≤r) :
    ∀ᶠ z in 𝓝 (balancedAffinePoint r (balancedGain r)),
      z≠balancedAffinePoint r (balancedGain r) →
      absoluteAffineParityRatio r z<
        absoluteAffineParityRatio r (balancedAffinePoint r (balancedGain r)) := by
  have he:=absoluteAffineParityRatio_eventually_eq r
  have hpoint:=he.self_of_nhds
  filter_upwards [he,signedAffineParityRatio_strict_local_maximum r hr] with z hz hmax hne
  rw [hz,hpoint]
  exact hmax hne

end NeuralGeneralization.OnlineLowerTanh
