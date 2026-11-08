import NeuralGeneralization.OnlineLowerTanhMomentPeriodic
import NeuralGeneralization.OnlineLowerTanhPeakLocalization
import NeuralGeneralization.OnlineLowerTanhPeriodicCurvature
import NeuralGeneralization.OnlineLowerLocalMaximum

/-! Uniform local optimization at the literal periodic bias peaks. -/
noncomputable section
open scoped BigOperators Topology Classical
open Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

def periodicDerivativeUniformBound : ℝ :=
  1+Real.sqrt (2*Real.pi)*residualMomentSum/Real.sqrt (2/Real.pi)

lemma periodicDerivativeUniformBound_pos : 0<periodicDerivativeUniformBound := by
  unfold periodicDerivativeUniformBound
  positivity [residualMomentSum_nonneg]

lemma periodic_derivative_uniform_bound {a:ℝ} (ha:1≤a) (ha2:a≤2) (B:ℝ) :
    |periodicFourierDerivative a B|≤periodicDerivativeUniformBound := by
  have ha0:0<a:=by linarith
  have h:=balancedMomentLeading_abs 1 (by decide) 2 ha ha2 B ((2:ℝ)*Real.pi/2+Real.pi/2)
  have hid:=balancedMomentLeading_first 2 ha0 B
  norm_num only [Nat.reduceDiv,Nat.reduceMod,Nat.cast_zero,Nat.cast_ofNat,zero_mul,add_zero,pow_one] at hid
  rw [hid] at h
  rw [abs_mul,abs_mul,abs_neg,abs_one,one_mul,
    abs_of_pos (by positivity : 0<Real.sqrt (2/Real.pi))] at h
  have hh:|periodicFourierDerivative a B|≤
      Real.sqrt (2*Real.pi)*residualMomentSum/Real.sqrt (2/Real.pi):=
    (le_div_iff₀ (by positivity : 0<Real.sqrt (2/Real.pi))).mpr (by nlinarith)
  unfold periodicDerivativeUniformBound
  linarith

lemma periodic_response_lipschitz {a:ℝ} (ha:1≤a) (ha2:a≤2) (x y:ℝ) :
    |periodicFourierResponse a x-periodicFourierResponse a y|≤
      periodicDerivativeUniformBound*|x-y| := by
  have ha0:0<a:=by linarith
  have h:=(convex_univ:Convex ℝ (univ:Set ℝ)).norm_image_sub_le_of_norm_hasDerivWithin_le
    (fun z _=>(periodicFourierResponse_hasDerivAt ha0 z).hasDerivWithinAt)
    (fun z _=>by simpa only [Real.norm_eq_abs] using periodic_derivative_uniform_bound ha ha2 z)
    (mem_univ y) (mem_univ x)
  simpa only [Real.norm_eq_abs] using h

lemma periodicFourierSecond_odd (a b:ℝ) :
    periodicFourierSecond a (-b)= -periodicFourierSecond a b := by
  simp only [periodicFourierSecond,mul_neg,Real.sin_neg,tsum_neg]

lemma periodic_restoring_signed {a:ℝ} (ha:0<a) (ha2:a≤2) (b s:ℝ) (hs:|s|=1) :
    s*periodicFourierSecond a b≤
      -periodicFrequency a^2*(s*periodicFourierResponse a b)+
        (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
  rcases (abs_eq (by norm_num : (0:ℝ)≤1)).mp hs with h|h
  · subst s
    simpa only [one_mul] using periodic_restoring_pointwise ha ha2 b
  · subst s
    have hh:=periodic_restoring_pointwise ha ha2 (-b)
    rw [periodicFourierSecond_odd,periodicFourierResponse_odd] at hh
    simpa only [neg_one_mul] using hh

def periodicLocalRadius : ℝ :=
  periodicPeakFloor/(1000*(periodicDerivativeUniformBound+1))

def periodicLocalCurvature : ℝ :=
  (1/1000)*(Real.pi/4)^2*periodicPeakFloor

lemma periodicLocalRadius_pos : 0<periodicLocalRadius := by
  unfold periodicLocalRadius
  positivity [periodicPeakFloor_pos,periodicDerivativeUniformBound_pos]

lemma periodicLocalCurvature_pos : 0<periodicLocalCurvature := by
  unfold periodicLocalCurvature
  positivity [periodicPeakFloor_pos]

/-- A common positive radius and curvature work around every signed
periodic peak, uniformly in the physical gain `[1,2]`. -/
theorem periodic_signed_local_curvature {a c x s:ℝ}
    (ha:1≤a) (ha2:a≤2) (hs:|s|=1)
    (hpeak:s*periodicFourierResponse a c=periodicFourierMaximum a)
    (hx:|x-c|≤periodicLocalRadius) :
    s*periodicFourierSecond a x≤-periodicLocalCurvature := by
  have ha0:0<a:=by linarith
  have hL:=periodic_response_lipschitz ha ha2 x c
  have hsigned:|s*periodicFourierResponse a x-periodicFourierMaximum a|≤
      periodicDerivativeUniformBound*periodicLocalRadius:=by
    rw [←hpeak,←mul_sub,abs_mul,hs,one_mul]
    exact hL.trans (mul_le_mul_of_nonneg_left hx periodicDerivativeUniformBound_pos.le)
  have hrad:periodicDerivativeUniformBound*periodicLocalRadius≤periodicPeakFloor/1000:=by
    unfold periodicLocalRadius
    have hd:0<periodicDerivativeUniformBound+1:=by positivity [periodicDerivativeUniformBound_pos]
    calc
      _=(periodicDerivativeUniformBound/(periodicDerivativeUniformBound+1))*(periodicPeakFloor/1000):=by field_simp
      _≤1*(periodicPeakFloor/1000):=mul_le_mul_of_nonneg_right
        ((div_le_one hd).mpr (by linarith)) (by positivity [periodicPeakFloor_pos])
      _=periodicPeakFloor/1000:=by ring

  have hfloor:=periodicCoefficient_zero_floor ha ha2
  have hmax:=periodicFourierMaximum_lower ha0 ha2
  have hnear:(899/1000)*periodicCoefficient a 0≤s*periodicFourierResponse a x:=by
    linarith [(abs_le.mp hsigned).1]
  have hrest:=periodic_restoring_signed ha0 ha2 x s hs
  have hmul:=mul_le_mul_of_nonneg_left hnear (sq_nonneg (periodicFrequency a))
  have hcur:s*periodicFourierSecond a x≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0:=by
    nlinarith [mul_nonneg (sq_nonneg (periodicFrequency a)) (periodicCoefficient_pos ha0 0).le]
  have hfreq:Real.pi/4≤periodicFrequency a:=by
    unfold periodicFrequency
    apply (le_div_iff₀ (by positivity : 0<2*a)).mpr
    nlinarith [Real.pi_pos]
  have hsq:(Real.pi/4)^2≤periodicFrequency a^2:=by
    nlinarith [Real.pi_pos]
  have hp:=mul_le_mul hsq hfloor periodicPeakFloor_pos.le (sq_nonneg (periodicFrequency a))
  unfold periodicLocalCurvature
  linarith

def signedBalancedBias (n:ℕ) (a s B:ℝ) : ℝ :=
  s*(-1:ℝ)^(n/2)*Real.sqrt (n:ℝ)*parityCorrelation (fun _:Fin n=>a) B

def signedBalancedBiasFirst (n:ℕ) (a s B:ℝ) : ℝ :=
  s*(-1:ℝ)^(n/2)*Real.sqrt (n:ℝ)*parityBiasFirst (fun _:Fin n=>a) B

def signedBalancedBiasSecond (n:ℕ) (a s B:ℝ) : ℝ :=
  s*(-1:ℝ)^(n/2)*Real.sqrt (n:ℝ)*parityBiasSecond (fun _:Fin n=>a) B

lemma signedBalancedBias_hasDerivAt (n:ℕ) (a s B:ℝ) :
    HasDerivAt (signedBalancedBias n a s) (signedBalancedBiasFirst n a s B) B :=
  (hasDerivAt_parityCorrelation (fun _:Fin n=>a) B).const_mul _

lemma signedBalancedBiasFirst_hasDerivAt (n:ℕ) (a s B:ℝ) :
    HasDerivAt (signedBalancedBiasFirst n a s) (signedBalancedBiasSecond n a s B) B :=
  (hasDerivAt_parityBiasFirst (fun _:Fin n=>a) B).const_mul _

lemma sign_square_nat (n:ℕ) : ((-1:ℝ)^n)^2=1 := by
  rw [←pow_mul,mul_comm n 2,pow_mul]
  norm_num

/-- Both derivative comparisons use one common finite dimension threshold. -/
theorem signedBalancedBias_derivative_errors (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀B:ℝ,|B|≤L →
      |signedBalancedBiasFirst n a s B-s*Real.sqrt (2/Real.pi)*
        periodicFourierDerivative a (B+(n%2:ℕ)*a)|≤balancedMomentCompactConstant L/(n:ℝ) ∧
      |signedBalancedBiasSecond n a s B-s*Real.sqrt (2/Real.pi)*
        periodicFourierSecond a (B+(n%2:ℕ)*a)|≤balancedMomentCompactConstant L/(n:ℝ) := by
  obtain ⟨N1,hN1,h1⟩:=balancedBiasFirst_compact_error L hL
  obtain ⟨N2,hN2,h2⟩:=balancedBiasSecond_compact_error L hL
  refine ⟨max N1 N2,lt_of_lt_of_le hN1 (le_max_left _ _),?_⟩
  intro n hn a ha ha2 s hs B hB
  have ha0:0<a:=by linarith
  have hfirst:=h1 n (le_trans (le_max_left _ _) hn) a ha ha2 B hB
  rw [balancedMomentLeading_first n ha0 B] at hfirst
  have hsecond:=h2 n (le_trans (le_max_right _ _) hn) a ha ha2 B hB
  have he:=balancedMomentLeading_second n ha0 B
  have hs2:=sign_square_nat (n/2)
  have hfactor:|s*(-1:ℝ)^(n/2)|=1:=by rw [abs_mul,hs,abs_neg_one_pow,one_mul]
  constructor
  · have hh:=mul_le_mul_of_nonneg_left hfirst (abs_nonneg (s*(-1:ℝ)^(n/2)))
    rw [hfactor,one_mul,one_mul] at hh
    have harg:s*(-1:ℝ)^(n/2)*(Real.sqrt (n:ℝ)*parityBiasFirst (fun _:Fin n=>a) B-
        (-1:ℝ)^(n/2)*Real.sqrt (2/Real.pi)*periodicFourierDerivative a (B+(n%2:ℕ)*a))=
        signedBalancedBiasFirst n a s B-s*Real.sqrt (2/Real.pi)*
          periodicFourierDerivative a (B+(n%2:ℕ)*a):=by
      unfold signedBalancedBiasFirst
      linear_combination -s*Real.sqrt (2/Real.pi)*periodicFourierDerivative a (B+(n%2:ℕ)*a)*hs2
    rw [←harg,abs_mul,hfactor,one_mul]
    exact hh
  · have hh:=mul_le_mul_of_nonneg_left hsecond (abs_nonneg (s*(-1:ℝ)^(n/2)))
    rw [hfactor,one_mul,one_mul] at hh
    have harg:s*(-1:ℝ)^(n/2)*(Real.sqrt (n:ℝ)*parityBiasSecond (fun _:Fin n=>a) B+
        balancedMomentLeading n 2 a B ((n:ℝ)*Real.pi/2))=
        signedBalancedBiasSecond n a s B-s*Real.sqrt (2/Real.pi)*
          periodicFourierSecond a (B+(n%2:ℕ)*a):=by
      have hneg:balancedMomentLeading n 2 a B ((n:ℝ)*Real.pi/2)=
          -((-1:ℝ)^(n/2)*Real.sqrt (2/Real.pi)*periodicFourierSecond a (B+(n%2:ℕ)*a)):=by linarith
      rw [hneg]
      unfold signedBalancedBiasSecond
      linear_combination -s*Real.sqrt (2/Real.pi)*periodicFourierSecond a (B+(n%2:ℕ)*a)*hs2
    rw [←harg,abs_mul,hfactor,one_mul]
    exact hh


def balancedBiasLocalCurvature : ℝ :=
  Real.sqrt (2/Real.pi)*periodicLocalCurvature/2

lemma balancedBiasLocalCurvature_pos : 0<balancedBiasLocalCurvature := by
  unfold balancedBiasLocalCurvature
  positivity [periodicLocalCurvature_pos]

def balancedBiasImprovementConstant (L:ℝ) : ℝ :=
  (balancedMomentCompactConstant L)^2/(2*balancedBiasLocalCurvature)

lemma balancedBiasImprovementConstant_pos {L:ℝ} (hL:0≤L) :
    0<balancedBiasImprovementConstant L := by
  unfold balancedBiasImprovementConstant
  positivity [balancedMomentCompactConstant_pos hL,balancedBiasLocalCurvature_pos]

/-- The actual signed finite-cube response has a common negative second
derivative throughout a fixed neighborhood of every periodic peak. -/
theorem signedBalancedBias_local_curvature (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀c:ℝ,|c|+periodicLocalRadius≤L →
      s*periodicFourierResponse a (c+(n%2:ℕ)*a)=periodicFourierMaximum a →
      ∀B:ℝ,|B-c|≤periodicLocalRadius →
      signedBalancedBiasSecond n a s B≤-balancedBiasLocalCurvature := by
  obtain ⟨N1,hN1,herr⟩:=signedBalancedBias_derivative_errors L hL
  obtain ⟨N2,hN2⟩:=exists_nat_gt (balancedMomentCompactConstant L/balancedBiasLocalCurvature)
  refine ⟨max N1 N2,lt_of_lt_of_le hN1 (le_max_left _ _),?_⟩
  intro n hn a ha ha2 s hs c hc hpeak B hB
  have hn0:0<n:=lt_of_lt_of_le hN1 (le_trans (le_max_left _ _) hn)
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn0
  have hnn:(N2:ℝ)≤n:=by exact_mod_cast le_trans (le_max_right N1 N2) hn
  have hlarge:balancedMomentCompactConstant L/(n:ℝ)≤balancedBiasLocalCurvature:=by
    apply (div_le_iff₀ hnR).mpr
    have ht:balancedMomentCompactConstant L/balancedBiasLocalCurvature<(n:ℝ):=lt_of_lt_of_le hN2 hnn
    have ht':=(div_lt_iff₀ balancedBiasLocalCurvature_pos).mp ht
    nlinarith
  have hcompact:|B|≤L:=by
    have hh:=abs_add_le (B-c) c
    rw [sub_add_cancel] at hh
    linarith
  have he:=(herr n (le_trans (le_max_left _ _) hn) a ha ha2 s hs B hcompact).2
  have hcur:=periodic_signed_local_curvature ha ha2 hs hpeak
    (show |(B+(n%2:ℕ)*a)-(c+(n%2:ℕ)*a)|≤periodicLocalRadius by simpa only [add_sub_add_right_eq_sub] using hB)
  have hmul:=mul_le_mul_of_nonneg_left hcur (Real.sqrt_nonneg (2/Real.pi))
  have hh:=(abs_le.mp he).2
  unfold balancedBiasLocalCurvature at *
  nlinarith

/-- Optimizing an actual response within a periodic peak neighborhood can
raise its normalized value by at most a uniform constant times `n⁻²`. -/
theorem signedBalancedBias_local_improvement (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀c:ℝ,|c|+periodicLocalRadius≤L →
      s*periodicFourierResponse a (c+(n%2:ℕ)*a)=periodicFourierMaximum a →
      periodicFourierDerivative a (c+(n%2:ℕ)*a)=0 →
      ∀B:ℝ,|B-c|≤periodicLocalRadius →
      signedBalancedBias n a s B≤signedBalancedBias n a s c+
        balancedBiasImprovementConstant L/(n:ℝ)^2 := by
  obtain ⟨N1,hN1,hcur⟩:=signedBalancedBias_local_curvature L hL
  obtain ⟨N2,hN2,herr⟩:=signedBalancedBias_derivative_errors L hL
  refine ⟨max N1 N2,lt_of_lt_of_le hN1 (le_max_left _ _),?_⟩
  intro n hn a ha ha2 s hs c hc hpeak hstat B hB
  have hn0:0<n:=lt_of_lt_of_le hN1 (le_trans (le_max_left _ _) hn)
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn0
  have hrad:=periodicLocalRadius_pos.le
  have hccompact:|c|≤L:=by linarith
  have hfirst:=(herr n (le_trans (le_max_right _ _) hn) a ha ha2 s hs c hccompact).1
  rw [hstat,mul_zero,sub_zero] at hfirst
  have hb:∀x∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius),
      signedBalancedBiasSecond n a s x≤-balancedBiasLocalCurvature:=by
    intro x hx
    apply hcur n (le_trans (le_max_left _ _) hn) a ha ha2 s hs c hc hpeak x
    exact abs_le.mpr ⟨by linarith [hx.1],by linarith [hx.2]⟩
  have hcD:c∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius):=⟨by linarith,by linarith⟩
  have hBD:B∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius):=by
    obtain ⟨hl,hu⟩:=abs_le.mp hB
    exact ⟨by linarith,by linarith⟩
  have hh:=strongly_concave_value_improvement (convex_Icc _ _)
    (signedBalancedBias n a s) (signedBalancedBiasFirst n a s) (signedBalancedBiasSecond n a s)
    balancedBiasLocalCurvature (balancedMomentCompactConstant L/(n:ℝ)) balancedBiasLocalCurvature_pos
    (by positivity [balancedMomentCompactConstant_pos hL])
    (fun x _=>signedBalancedBias_hasDerivAt n a s x)
    (fun x _=>signedBalancedBiasFirst_hasDerivAt n a s x) hb hcD hBD hfirst
  convert hh using 1
  unfold balancedBiasImprovementConstant
  ring

theorem signedBalancedBias_compact_error (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀B:ℝ,|B|≤L →
      |signedBalancedBias n a s B-s*Real.sqrt (2/Real.pi)*
        periodicFourierResponse a (B+(n%2:ℕ)*a)|≤balancedMomentCompactConstant L/(n:ℝ) := by
  obtain ⟨N,hN,h⟩:=balancedMoment_compact_error L hL
  refine ⟨N,hN,?_⟩
  intro n hn a ha ha2 s hs B hB
  have ha0:0<a:=by linarith
  have hh:=h n hn 0 (by decide) a ha ha2 B ((n:ℝ)*Real.pi/2) hB
  rw [←residualRawKernel_parity,balancedMomentLeading_zero n ha0 B] at hh
  have hs2:=sign_square_nat (n/2)
  have hfactor:|s*(-1:ℝ)^(n/2)|=1:=by rw [abs_mul,hs,abs_neg_one_pow,one_mul]
  have harg:s*(-1:ℝ)^(n/2)*(Real.sqrt (n:ℝ)*parityCorrelation (fun _:Fin n=>a) B-
      (-1:ℝ)^(n/2)*Real.sqrt (2/Real.pi)*periodicFourierResponse a (B+(n%2:ℕ)*a))=
      signedBalancedBias n a s B-s*Real.sqrt (2/Real.pi)*
        periodicFourierResponse a (B+(n%2:ℕ)*a):=by
    unfold signedBalancedBias
    linear_combination -s*Real.sqrt (2/Real.pi)*periodicFourierResponse a (B+(n%2:ℕ)*a)*hs2
  rw [←harg,abs_mul,hfactor,one_mul]
  exact hh

lemma periodic_signed_local_value {a c x s:ℝ}
    (ha:1≤a) (ha2:a≤2) (hs:|s|=1)
    (hpeak:s*periodicFourierResponse a c=periodicFourierMaximum a)
    (hx:|x-c|≤periodicLocalRadius) :
    (899/1000)*periodicPeakFloor≤s*periodicFourierResponse a x := by
  have ha0:0<a:=by linarith
  have hL:=periodic_response_lipschitz ha ha2 x c
  have hsigned:|s*periodicFourierResponse a x-periodicFourierMaximum a|≤
      periodicDerivativeUniformBound*periodicLocalRadius:=by
    rw [←hpeak,←mul_sub,abs_mul,hs,one_mul]
    exact hL.trans (mul_le_mul_of_nonneg_left hx periodicDerivativeUniformBound_pos.le)
  have hrad:periodicDerivativeUniformBound*periodicLocalRadius≤periodicPeakFloor/1000:=by
    unfold periodicLocalRadius
    have hd:0<periodicDerivativeUniformBound+1:=by positivity [periodicDerivativeUniformBound_pos]
    calc
      _=(periodicDerivativeUniformBound/(periodicDerivativeUniformBound+1))*(periodicPeakFloor/1000):=by field_simp
      _≤1*(periodicPeakFloor/1000):=mul_le_mul_of_nonneg_right
        ((div_le_one hd).mpr (by linarith)) (by positivity [periodicPeakFloor_pos])
      _=periodicPeakFloor/1000:=by ring
  have hfloor:=periodicCoefficient_zero_floor ha ha2
  have hmax:=periodicFourierMaximum_lower ha0 ha2
  linarith [(abs_le.mp hsigned).1]

/-- The sign attached to a periodic peak is the actual response sign
throughout its fixed neighborhood, for all sufficiently large dimensions. -/
theorem signedBalancedBias_local_positive (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀c:ℝ,|c|+periodicLocalRadius≤L →
      s*periodicFourierResponse a (c+(n%2:ℕ)*a)=periodicFourierMaximum a →
      ∀B:ℝ,|B-c|≤periodicLocalRadius →0<signedBalancedBias n a s B := by
  obtain ⟨N1,hN1,herr⟩:=signedBalancedBias_compact_error L hL
  let v:ℝ:=Real.sqrt (2/Real.pi)*periodicPeakFloor/2
  have hv:0<v:=by dsimp [v];positivity [periodicPeakFloor_pos]
  obtain ⟨N2,hN2⟩:=exists_nat_gt (balancedMomentCompactConstant L/v)
  refine ⟨max N1 N2,lt_of_lt_of_le hN1 (le_max_left _ _),?_⟩
  intro n hn a ha ha2 s hs c hc hpeak B hB
  have hn0:0<n:=lt_of_lt_of_le hN1 (le_trans (le_max_left _ _) hn)
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn0
  have hnn:(N2:ℝ)≤n:=by exact_mod_cast le_trans (le_max_right N1 N2) hn
  have hlarge:balancedMomentCompactConstant L/(n:ℝ)≤v:=by
    apply (div_le_iff₀ hnR).mpr
    have ht:balancedMomentCompactConstant L/v<(n:ℝ):=lt_of_lt_of_le hN2 hnn
    nlinarith [(div_lt_iff₀ hv).mp ht]
  have hcompact:|B|≤L:=by
    have hh:=abs_add_le (B-c) c
    rw [sub_add_cancel] at hh
    linarith
  have he:=herr n (le_trans (le_max_left _ _) hn) a ha ha2 s hs B hcompact
  have hval:=periodic_signed_local_value ha ha2 hs hpeak
    (show |(B+(n%2:ℕ)*a)-(c+(n%2:ℕ)*a)|≤periodicLocalRadius by simpa only [add_sub_add_right_eq_sub] using hB)
  have hmul:=mul_le_mul_of_nonneg_left hval (Real.sqrt_nonneg (2/Real.pi))
  have hh:=(abs_le.mp he).1
  dsimp [v] at *
  nlinarith [mul_pos (by positivity : 0<Real.sqrt (2/Real.pi)) periodicPeakFloor_pos]

/-- Exact stationarity removes the quadratic optimization error entirely. -/
theorem signedBalancedBias_local_stationary_max (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀c:ℝ,|c|+periodicLocalRadius≤L →
      s*periodicFourierResponse a (c+(n%2:ℕ)*a)=periodicFourierMaximum a →
      parityBiasFirst (fun _:Fin n=>a) c=0 →
      ∀B:ℝ,|B-c|≤periodicLocalRadius →
      signedBalancedBias n a s B≤signedBalancedBias n a s c := by
  obtain ⟨N,hN,hcur⟩:=signedBalancedBias_local_curvature L hL
  refine ⟨N,hN,?_⟩
  intro n hn a ha ha2 s hs c hc hpeak hstat B hB
  have hrad:=periodicLocalRadius_pos.le
  have hb:∀x∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius),
      signedBalancedBiasSecond n a s x≤-balancedBiasLocalCurvature:=by
    intro x hx
    apply hcur n hn a ha ha2 s hs c hc hpeak x
    exact abs_le.mpr ⟨by linarith [hx.1],by linarith [hx.2]⟩
  have hcD:c∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius):=⟨by linarith,by linarith⟩
  have hBD:B∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius):=by
    obtain ⟨hl,hu⟩:=abs_le.mp hB
    exact ⟨by linarith,by linarith⟩
  have hh:=strongly_concave_quadratic_upper (convex_Icc _ _)
    (signedBalancedBias n a s) (signedBalancedBiasFirst n a s) (signedBalancedBiasSecond n a s)
    balancedBiasLocalCurvature
    (fun x _=>signedBalancedBias_hasDerivAt n a s x)
    (fun x _=>signedBalancedBiasFirst_hasDerivAt n a s x) hb hcD hBD
  have hzero:signedBalancedBiasFirst n a s c=0:=by simp [signedBalancedBiasFirst,hstat]
  rw [hzero,zero_mul,add_zero] at hh
  nlinarith [mul_nonneg balancedBiasLocalCurvature_pos.le (sq_nonneg (B-c))]


end NeuralGeneralization.OnlineLowerTanh

