import NeuralGeneralization.OnlineLowerTanhEqualBulkMax

/-! # Equality and maximizer locations for the all-bias equal-bulk theorem -/
noncomputable section
open scoped BigOperators Topology Classical
open Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Quantitative strictness at an exactly stationary central peak. -/
theorem signedBalancedBias_local_stationary_unique (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀c:ℝ,|c|+periodicLocalRadius≤L →
      s*periodicFourierResponse a (c+(n%2:ℕ)*a)=periodicFourierMaximum a →
      parityBiasFirst (fun _:Fin n=>a) c=0 →
      ∀B:ℝ,|B-c|≤periodicLocalRadius →
      signedBalancedBias n a s c≤signedBalancedBias n a s B → B=c := by
  obtain ⟨N,hN,hcur⟩:=signedBalancedBias_local_curvature L hL
  refine ⟨N,hN,?_⟩
  intro n hn a ha ha2 s hs c hc hpeak hstat B hB hcomp
  have hrad:=periodicLocalRadius_pos.le
  have hb:∀x∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius),
      signedBalancedBiasSecond n a s x≤-balancedBiasLocalCurvature:=by
    intro x hx
    exact hcur n hn a ha ha2 s hs c hc hpeak x
      (abs_le.mpr ⟨by linarith [hx.1],by linarith [hx.2]⟩)
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
  have hsq:(B-c)^2=0:=by nlinarith [balancedBiasLocalCurvature_pos,sq_nonneg (B-c)]
  nlinarith [hsq]

/-- Odd equal-bulk parity has a unique absolute maximizing bias, zero. The
threshold is uniform over every gain in `[1,2]`. -/
theorem odd_equalBulk_unique_maximizing_bias :
    ∃N₀:ℕ,0<N₀ ∧ ∀r:ℕ,N₀≤2*r+1 → ∀a:ℝ,1≤a → a≤2 → ∀B:ℝ,
      |parityCorrelation (fun _:Fin (2*r+1)=>a) B|=balancedParity r a ↔ B=0 := by
  let L:=naturalPeakCompactRadius 0
  have hL:0≤L:=(naturalPeakCompactRadius_pos 0).le
  obtain ⟨N₁,hN₁,hnear⟩:=equalBulk_competitive_central_neighborhood
  obtain ⟨N₂,hN₂,hunique⟩:=signedBalancedBias_local_stationary_unique L hL
  obtain ⟨N₃,hN₃,hpositive⟩:=signedBalancedBias_local_positive L hL
  refine ⟨max (N₁+1) (max N₂ N₃),by omega,?_⟩
  intro r hr a ha ha2 B
  constructor
  · intro heq
    have hn1:N₁≤2*r:=by omega
    have hn2:N₂≤2*r+1:=by omega
    have hn3:N₃≤2*r+1:=by omega
    have hc:|(0:ℝ)|+periodicLocalRadius≤L:=by
      simpa [bulkPeakCenter] using bulkPeakCenter_compact ha ha2 (2*r+1) (show 0≤(0:ℕ) by omega)
    have hp:1*periodicFourierResponse a (0+((2*r+1)%2:ℕ)*a)=periodicFourierMaximum a:=by
      simp [periodicFourierMaximum]
    have hs:|(1:ℝ)|=1:=by norm_num
    have hcoeff:|parityCorrelation (fun _:Fin (2*r+1)=>a) (|B|)|=balancedParity r a:=by
      simpa only [abs_parityCorrelation_abs_bias] using heq
    have hdist:abs (|B|-0)≤periodicLocalRadius:=by
      simpa using (hnear r hn1 a ha ha2).1 |B| (abs_nonneg B) hcoeff.ge
    have hzdist:|(0:ℝ)-0|≤periodicLocalRadius:=by simpa using periodicLocalRadius_pos.le
    have hposB:=hpositive _ hn3 a ha ha2 1 hs 0 hc hp |B| hdist
    have hpos0:=hpositive _ hn3 a ha ha2 1 hs 0 hc hp 0 hzdist
    have hcomp:signedBalancedBias (2*r+1) a 1 0≤signedBalancedBias (2*r+1) a 1 |B|:=by
      rw [signedBalancedBias_eq_abs a 1 0 hs hpos0.le,
        signedBalancedBias_eq_abs a 1 |B| hs hposB.le,hcoeff,odd_central_abs_eq_balancedParity r ha]
    have he:=hunique _ hn2 a ha ha2 1 hs 0 hc hp
      (parityBiasFirst_zero_of_odd (show Odd (2*r+1) from ⟨r,by omega⟩) _) |B| hdist hcomp
    exact abs_eq_zero.mp he
  · rintro rfl
    exact odd_central_abs_eq_balancedParity r ha

/-- A coefficient competitive with a periodic central candidate must be
within a uniform `O(1/n)` distance of that candidate, not merely in a fixed
neighborhood. This stronger conclusion includes every maximizing bias. -/
theorem signedBalancedBias_competitive_distance (L:ℝ) (hL:0≤L) :
    ∃N:ℕ,0<N ∧ ∀n:ℕ,N≤n → ∀a:ℝ,1≤a → a≤2 →
      ∀s:ℝ,|s|=1 → ∀c:ℝ,|c|+periodicLocalRadius≤L →
      s*periodicFourierResponse a (c+(n%2:ℕ)*a)=periodicFourierMaximum a →
      periodicFourierDerivative a (c+(n%2:ℕ)*a)=0 →
      ∀B:ℝ,|B-c|≤periodicLocalRadius →
      signedBalancedBias n a s c≤signedBalancedBias n a s B →
      |B-c|≤(2*balancedMomentCompactConstant L/balancedBiasLocalCurvature)/(n:ℝ) := by
  obtain ⟨N₁,hN₁,hcur⟩:=signedBalancedBias_local_curvature L hL
  obtain ⟨N₂,hN₂,herr⟩:=signedBalancedBias_derivative_errors L hL
  refine ⟨max N₁ N₂,by omega,?_⟩
  intro n hn a ha ha2 s hs c hc hpeak hstat B hB hcomp
  have hnR:(0:ℝ)<n:=by exact_mod_cast (show 0<n by omega)
  have hrad:=periodicLocalRadius_pos.le
  have hfirst:|signedBalancedBiasFirst n a s c|≤balancedMomentCompactConstant L/(n:ℝ):=by
    have hh:=(herr n (by omega) a ha ha2 s hs c (by linarith)).1
    simpa only [hstat,mul_zero,sub_zero] using hh
  have hb:∀x∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius),
      signedBalancedBiasSecond n a s x≤-balancedBiasLocalCurvature:=by
    intro x hx
    exact hcur n (by omega) a ha ha2 s hs c hc hpeak x
      (abs_le.mpr ⟨by linarith [hx.1],by linarith [hx.2]⟩)
  have hcD:c∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius):=⟨by linarith,by linarith⟩
  have hBD:B∈Icc (c-periodicLocalRadius) (c+periodicLocalRadius):=by
    obtain ⟨hl,hu⟩:=abs_le.mp hB
    exact ⟨by linarith,by linarith⟩
  have hh:=strongly_concave_quadratic_upper (convex_Icc _ _)
    (signedBalancedBias n a s) (signedBalancedBiasFirst n a s) (signedBalancedBiasSecond n a s)
    balancedBiasLocalCurvature
    (fun x _=>signedBalancedBias_hasDerivAt n a s x)
    (fun x _=>signedBalancedBiasFirst_hasDerivAt n a s x) hb hcD hBD
  have hprod:signedBalancedBiasFirst n a s c*(B-c)≤
      (balancedMomentCompactConstant L/(n:ℝ))*|B-c|:=
    (le_abs_self _).trans (by rw [abs_mul]; exact mul_le_mul_of_nonneg_right hfirst (abs_nonneg _))
  have hsq:(B-c)^2=|B-c|^2:=by rw [sq_abs]
  rw [hsq] at hh
  by_cases hz:|B-c|=0
  · rw [hz]; positivity [balancedMomentCompactConstant_pos hL,balancedBiasLocalCurvature_pos]
  have hp : 0 < |B-c| :=lt_of_le_of_ne (abs_nonneg _) (Ne.symm hz)
  have hdist:|B-c|≤2*(balancedMomentCompactConstant L/(n:ℝ))/balancedBiasLocalCurvature:=by
    apply (le_div_iff₀ balancedBiasLocalCurvature_pos).mpr
    apply (mul_le_mul_iff_right₀ hp).mp
    nlinarith [hh,hprod,hsq]
  convert hdist using 1 <;> ring

/-- Every even-bulk maximizing bias lies at `a+O(1/n)` or `-a+O(1/n)`,
uniformly in gain. In fact the statement holds for every bias whose absolute
coefficient is at least that of the central candidate. -/
theorem even_equalBulk_maximizer_location :
    ∃K:ℝ,0<K ∧ ∃N₀:ℕ,0<N₀ ∧ ∀r:ℕ,N₀≤2*r → ∀a:ℝ,1≤a → a≤2 →
      ∀B:ℝ,balancedParity r a≤|parityCorrelation (fun _:Fin (2*r)=>a) B| →
      abs (|B|-a)≤K/(2*(r:ℝ)) := by
  let L:=naturalPeakCompactRadius 0
  have hL:0≤L:=(naturalPeakCompactRadius_pos 0).le
  obtain ⟨N₁,hN₁,hnear⟩:=equalBulk_competitive_central_neighborhood
  obtain ⟨N₂,hN₂,hdist⟩:=signedBalancedBias_competitive_distance L hL
  obtain ⟨N₃,hN₃,hpositive⟩:=signedBalancedBias_local_positive L hL
  refine ⟨2*balancedMomentCompactConstant L/balancedBiasLocalCurvature,
    by positivity [balancedMomentCompactConstant_pos hL,balancedBiasLocalCurvature_pos],
    max N₁ (max N₂ N₃),by omega,?_⟩
  intro r hr a ha ha2 B hcomp
  have hcenter:bulkPeakCenter (2*r) 0 a=a:=by simp [bulkPeakCenter]
  have hc:|a|+periodicLocalRadius≤L:=by
    simpa only [hcenter] using bulkPeakCenter_compact ha ha2 (2*r) (show 0≤(0:ℕ) by omega)
  have hp:1*periodicFourierResponse a (a+((2*r)%2:ℕ)*a)=periodicFourierMaximum a:=by
    simp [periodicFourierMaximum]
  have hs:|(1:ℝ)|=1:=by norm_num
  have hstat:periodicFourierDerivative a (a+((2*r)%2:ℕ)*a)=0:=by
    simpa only [hcenter,pow_zero] using bulkPeakCenter_periodic_stationary (by linarith : 0<a) (2*r) 0
  have hcomp':balancedParity r a≤|parityCorrelation (fun _:Fin (2*r)=>a) (|B|)|:=by
    simpa only [abs_parityCorrelation_abs_bias] using hcomp
  have hnearB:abs (|B|-a)≤periodicLocalRadius:=(hnear r (by omega) a ha ha2).2 |B| (abs_nonneg B) hcomp'
  have hposB:=hpositive (2*r) (by omega) a ha ha2 1 hs a hc hp |B| hnearB
  have hposC:=hpositive (2*r) (by omega) a ha ha2 1 hs a hc hp a
    (by simpa using periodicLocalRadius_pos.le)
  have hcompS:signedBalancedBias (2*r) a 1 a≤signedBalancedBias (2*r) a 1 |B|:=by
    rw [signedBalancedBias_eq_abs a 1 a hs hposC.le,
      signedBalancedBias_eq_abs a 1 |B| hs hposB.le,even_central_abs_eq_balancedParity r ha]
    exact mul_le_mul_of_nonneg_left hcomp' (Real.sqrt_nonneg _)
  simpa only [Nat.cast_mul,Nat.cast_ofNat] using
    hdist (2*r) (by omega) a ha ha2 1 hs a hc hp hstat |B| hnearB hcompS

end NeuralGeneralization.OnlineLowerTanh
