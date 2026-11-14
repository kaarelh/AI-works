import NeuralGeneralization.OnlineLowerTanhFiniteParityHessian

/-! Uniform quadratic loss of the selected coefficient around its balanced point. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

lemma uniform_quadratic_tangent {E:Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [ProperSpace E] (g g' g'':E→ℝ→ℝ)
    (hd:∀v t,HasDerivAt (g v) (g' v t) t)
    (hdd:∀v t,HasDerivAt (g' v) (g'' v t) t)
    (hc:Continuous (fun p:ℝ×E=>g'' p.2 p.1))
    (hneg:∀v,‖v‖=1 → g'' v 0<0) :
    ∃c>0,∃ε>0,∀v,‖v‖=1 → ∀t,0<t → t<ε →
      g v t≤g v 0+t*g' v 0-c*t^2 := by
  have hev:∀ᶠ c in 𝓝 (0:ℝ),∀v∈Metric.sphere (0:E) 1,g'' v 0+2*c<0:=by
    apply (isCompact_sphere (0:E) 1).eventually_forall_of_forall_eventually
    intro v hv
    have hv':‖v‖=1:=by simpa only [Metric.mem_sphere,dist_zero_right] using hv
    have hcont:Continuous (fun p:ℝ×E=>g'' p.2 0+2*p.1):=
      (hc.comp (continuous_const.prodMk continuous_snd)).add (continuous_fst.const_mul 2)
    exact (isOpen_Iio.preimage hcont).mem_nhds (by simpa using hneg v hv')
  obtain ⟨δ,hδ,hball⟩:=Metric.mem_nhds_iff.mp hev
  let c:=δ/2
  have hcpos:0<c:=by dsimp [c];positivity
  have hcneg (v:E) (hv:‖v‖=1):g'' v 0+2*c<0:=by
    apply hball (show c∈Metric.ball (0:ℝ) δ by
      simp only [Metric.mem_ball,dist_zero_right,Real.norm_eq_abs,abs_of_pos hcpos]
      dsimp [c];linarith) v
    simpa only [Metric.mem_sphere,dist_zero_right] using hv
  obtain ⟨ε,hε,hε'⟩:=uniform_strict_tangent
    (fun v t=>g v t+c*t^2) (fun v t=>g' v t+2*c*t) (fun v t=>g'' v t+2*c)
    (fun v t=>by convert (hd v t).add (((hasDerivAt_id t).pow 2).const_mul c) using 1 <;> (try rfl);simp;ring)
    (fun v t=>by convert (hdd v t).add ((hasDerivAt_id t).const_mul (2*c)) using 1 <;> (try rfl);simp)
    (hc.add continuous_const) hcneg
  refine ⟨c,hcpos,ε,hε,?_⟩
  intro v hv t ht htε
  have hh:=hε' v hv t ht htε
  simp only [zero_pow (by norm_num : (2:ℕ)≠0),mul_zero,add_zero] at hh
  linarith

lemma sum_sq_le_card_norm_sq {n:ℕ} (z:Fin n→ℝ) :
    (∑i,z i^2)≤(n:ℝ)*‖z‖^2 := by
  calc
    _ ≤ ∑i:Fin n,‖z‖^2 := by
      apply Finset.sum_le_sum
      intro i _
      have h:=norm_le_pi_norm z i
      rw [Real.norm_eq_abs] at h
      nlinarith [sq_abs (z i),abs_nonneg (z i),norm_nonneg z]
    _ = _ := by simp

theorem signedAffineCoefficient_quadratic_tangent (r:ℕ) (hr:2≤r) :
    ∃c>0,∀ᶠ z in 𝓝 (balancedAffinePoint r (balancedGain r)),
      (-1:ℝ)^r*affineParityCoefficient (2*r+1) z≤
        balancedParity r (balancedGain r)/((2*r+1:ℕ)*balancedGain r)*
          (∑i:Fin (2*r+1),z i.succ)-c*‖z-balancedAffinePoint r (balancedGain r)‖^2 := by
  let a:=balancedGain r
  let x:=balancedAffinePoint r a
  let C:=balancedParity r a/((2*r+1:ℕ)*a)
  have ha:0<a:=balancedGain_pos r
  have hn:((2*r+1:ℕ):ℝ)≠0:=by positivity
  have hs:balancedParityFirst r a/(2*r+1:ℕ)=C:=by
    have hz:a*balancedParityFirst r a-balancedParity r a=0:=
      (balancedGain_interior_and_stationary r hr).2
    dsimp [C]
    field_simp
    nlinarith only [hz]
  obtain ⟨c,hc,ε,hε,hε'⟩:=uniform_quadratic_tangent
    (fun v:Fin ((2*r+1)+1)→ℝ=>signedAffineNumeratorLine ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ))
    (fun v=>signedAffineNumeratorLineFirst ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ))
    (fun v=>signedAffineNumeratorLineSecond ((-1:ℝ)^r) a (v 0) (fun i=>v i.succ))
    (fun v t=>hasDerivAt_signedAffineNumeratorLine _ _ _ _ t)
    (fun v t=>hasDerivAt_signedAffineNumeratorLineFirst _ _ _ _ t)
    (by unfold signedAffineNumeratorLineSecond cubeMean finiteLineTanhSecond tanhSecond tanhFirst incomingLinear;fun_prop)
    (fun v hv=>signedAffineNumeratorLineSecond_negative r (by omega) a (balancedGain_mem r).1 _ _ (affine_direction_nonzero v hv))
  refine ⟨c,hc,?_⟩
  filter_upwards [Metric.ball_mem_nhds x hε] with z hz
  by_cases hne:z=x
  · subst z
    change (-1:ℝ)^r*affineParityCoefficient (2*r+1) x≤C*(∑i:Fin (2*r+1),x i.succ)-c*‖x-x‖^2
    simp only [sub_self,norm_zero,zero_pow (by norm_num : (2:ℕ)≠0),mul_zero,sub_zero]
    rw [affineParityCoefficient_balanced]
    simp only [x,balancedAffinePoint,Fin.cases_succ,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
    exact le_of_eq (div_mul_cancel₀ _ (mul_ne_zero hn ha.ne')).symm
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
  have hb:‖d‖*v 0=z 0:=by rw [hvcoord];simp [x,balancedAffinePoint]
  have ht:‖d‖<ε:=by simpa only [Metric.mem_ball,dist_eq_norm] using hz
  have hh:=hε' v hv ‖d‖ hnorm ht
  rw [signedAffineNumeratorLine_eq_actual,signedAffineNumeratorLine_eq_actual,
    signedAffineNumeratorLineFirst_zero,hs] at hh
  simp only [zero_mul,add_zero] at hh
  simp_rw [hzv] at hh
  rw [hb] at hh
  have hsum:‖d‖*(∑i:Fin (2*r+1),v i.succ)=
      (∑i:Fin (2*r+1),z i.succ)-((2*r+1:ℕ):ℝ)*a:=by
    rw [Finset.mul_sum]
    simp_rw [hvcoord]
    simp [x,balancedAffinePoint,Finset.sum_sub_distrib]
  have hca:C*(((2*r+1:ℕ):ℝ)*a)=balancedParity r a:=div_mul_cancel₀ _ (mul_ne_zero hn ha.ne')
  change (-1:ℝ)^r*affineParityCoefficient (2*r+1) z≤C*(∑i:Fin (2*r+1),z i.succ)-c*‖d‖^2
  change (-1:ℝ)^r*affineParityCoefficient (2*r+1) z≤balancedParity r a+‖d‖*(C*(∑i:Fin (2*r+1),v i.succ))-c*‖d‖^2 at hh
  have he:balancedParity r a+‖d‖*(C*(∑i:Fin (2*r+1),v i.succ))=C*(∑i:Fin (2*r+1),z i.succ):=by
    rw [show ‖d‖*(C*(∑i:Fin (2*r+1),v i.succ))=C*(‖d‖*(∑i:Fin (2*r+1),v i.succ)) by ring,hsum]
    nlinarith only [hca]
  rwa [he] at hh

theorem signedAffineCoefficient_energy_tangent (r:ℕ) (hr:2≤r) :
    ∃c>0,∀ᶠ z in 𝓝 (balancedAffinePoint r (balancedGain r)),
      (-1:ℝ)^r*affineParityCoefficient (2*r+1) z≤
        balancedParity r (balancedGain r)/((2*r+1:ℕ)*balancedGain r)*
          (∑i:Fin (2*r+1),z i.succ)-c*(∑i,(z i-balancedAffinePoint r (balancedGain r) i)^2) := by
  obtain ⟨c,hc,hev⟩:=signedAffineCoefficient_quadratic_tangent r hr
  refine ⟨c/((2*r+1)+1:ℕ),by positivity,?_⟩
  filter_upwards [hev] with z hz
  have hh:=sum_sq_le_card_norm_sq (z-balancedAffinePoint r (balancedGain r))
  have hn:(0:ℝ)<((2*r+1)+1:ℕ):=by positivity
  have hmul:=mul_le_mul_of_nonneg_left hh (show 0≤c/((2*r+1)+1:ℕ) by positivity)
  have he:(c/((2*r+1)+1:ℕ))*(((2*r+1)+1:ℕ):ℝ)=c:=div_mul_cancel₀ c hn.ne'
  rw [←mul_assoc,he] at hmul
  exact hz.trans (sub_le_sub_left hmul _)

theorem signedAffineCoefficient_energy_tangent_odd (n:ℕ) (hn:5≤n) (hodd:Odd n) :
    ∃c>0,∀ᶠ z:Fin (n+1)→ℝ in 𝓝 (Fin.cases 0 (fun _:Fin n=>balancedGain (n/2))),
      (-1:ℝ)^(n/2)*affineParityCoefficient n z≤
        balancedParity (n/2) (balancedGain (n/2))/((n:ℝ)*balancedGain (n/2))*
          (∑i:Fin n,z i.succ)-c*(∑i,(z i-(Fin.cases 0 (fun _:Fin n=>balancedGain (n/2)) i))^2) := by
  obtain ⟨r,hr⟩:=hodd
  have he:n=2*r+1:=by omega
  subst n
  have hd:(2*r+1)/2=r:=by omega
  rw [hd]
  exact signedAffineCoefficient_energy_tangent r (by omega)

end NeuralGeneralization.OnlineLowerTanh
