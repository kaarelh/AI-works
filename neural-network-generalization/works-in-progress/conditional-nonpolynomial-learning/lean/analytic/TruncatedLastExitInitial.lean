import TruncatedLastExit

/-! The last-exit argument never uses drift on the very first transition:
each block drops its first transition before estimating length. Consequently
the original input variance may exceed one without an added entropy charge. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
theorem lastExit_block_sqrt_bound_after_first (H s t : ℕ) (q e : ℕ → ℝ) {u K : ℝ}
    (hst : s<t) (htH : t≤H) (hu : 0<u) (hu1 : u≤1) (hK : 0≤K)
    (he : ∀j<H,0≤e j)
    (hstates : ∀j, s<j → j≤t → u≤q j)
    (hd : ∀j<H,1≤j → q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hcost : (∑j ∈ Finset.range t,e j)≤K*u) :
    (∑j ∈ Finset.range (t-s),Real.sqrt (e (s+j)))≤
      Real.sqrt (((K/driftRate+1)/driftDissipation+1)*K) := by
  let n := t-(s+1)
  have hn : s+1+n=t := by dsimp [n]; omega
  have hlen := interval_length_bound n (fun j => q (s+1+j)) (fun j => e (s+1+j)) hu
    (fun j hj => hstates (s+1+j) (by omega) (by omega))
    (fun j hj => he (s+1+j) (by omega))
    (fun j hj => by simpa only [Nat.add_assoc] using hd (s+1+j) (by omega) (by omega))
  have hcostn : (∑j ∈ Finset.range n,e (s+1+j))≤K*u := by
    have hh := sum_segment_le_prefix e (show s+1≤t by omega) (fun j hj => he j (by omega))
    exact hh.trans hcost
  have hlen' : driftDissipation*(n:ℝ)*u≤K/driftRate+1 := by
    have hc := div_le_div_of_nonneg_right hcostn (mul_nonneg driftRate_pos.le (sq_nonneg u))
    have hh := mul_le_mul_of_nonneg_right (hlen.trans (add_le_add hc le_rfl)) hu.le
    have hid : (K*u/(driftRate*u^2)+1/u)*u=K/driftRate+1 := by field_simp
    rw [hid] at hh
    exact hh
  have hnn : t-s=n+1 := by dsimp [n]; omega
  have hncast : (t-s:ℕ)=(n+1:ℕ) := hnn
  have hm : ((t-s:ℕ):ℝ)*u≤(K/driftRate+1)/driftDissipation+1 := by
    have hh : (n:ℝ)*u≤(K/driftRate+1)/driftDissipation :=
      (le_div_iff₀ driftDissipation_pos).mpr (by nlinarith [hlen'])
    rw [hncast,Nat.cast_add,Nat.cast_one]
    nlinarith
  have hseg := (sum_segment_le_prefix e (Nat.le_of_lt hst) (fun j hj => he j (by omega))).trans hcost
  have hs := sum_sqrt_sq_le (t-s) (fun j => e (s+j)) (fun j hj => he (s+j) (by omega))
  have hp := mul_le_mul_of_nonneg_left hseg (Nat.cast_nonneg (t-s) : (0:ℝ)≤(t-s:ℕ))
  have hkm := mul_le_mul_of_nonneg_right hm hK
  apply Real.le_sqrt_of_sq_le
  nlinarith


theorem truncated_lastExit_sqrt_entropy_after_first
    (H J : ℕ) (q e : ℕ → ℝ) (hH : 1≤H) {ε C a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (ha : 0<a) (hreach : 1≤(2:ℝ)^J*a)
    (hq1 : ∀j≤H,1≤j → q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,1≤j → q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀i≤H,(∑j∈Finset.range i,e j)≤ε+C*q i) :
    (∑j∈Finset.range H,Real.sqrt (e j))-
      (∑j∈Finset.range (lastExit q H a),Real.sqrt (e j))≤
      lastExitLinearConstant*((1+2*C)*(J:ℝ)+2*ε/a) := by
  let u : ℕ → ℝ := fun j => (2:ℝ)^j*a
  let τ : ℕ → ℕ := fun j => lastExit q H (u j)
  let S : ℕ → ℝ := fun n => ∑j∈Finset.range n,Real.sqrt (e j)
  have hu (j : ℕ) : 0<u j := by dsimp [u]; positivity
  have husucc (j : ℕ) : u (j+1)=2*u j := by dsimp [u]; rw [pow_succ]; ring
  have humono (j : ℕ) : u j≤u (j+1) := by rw [husucc]; linarith [hu j]
  have htmono (j : ℕ) : τ j≤τ (j+1) := lastExit_mono (humono j)
  have htH (j : ℕ) : τ j≤H := lastExit_le q H (u j)
  have hstep (j : ℕ) : S (τ (j+1))-S (τ j)≤
      lastExitLinearConstant*(1+2*C+ε/u j) := by
    by_cases hh : τ j=τ (j+1)
    · rw [← hh,sub_self]
      exact mul_nonneg lastExitLinearConstant_nonneg (by positivity)
    · have hst : τ j<τ (j+1) := lt_of_le_of_ne (htmono j) hh
      have hu1 : u j≤1 :=
        (after_lastExit (htH (j+1)) hst).le.trans (hq1 (τ (j+1)) (htH (j+1)) (by omega))
      have hcost : (∑k∈Finset.range (τ (j+1)),e k)≤(ε/u j+2*C)*u j := by
        have hstate := lastExit_state (show 0<τ (j+1) by omega)
        change q (τ (j+1))≤u (j+1) at hstate
        rw [husucc] at hstate
        have hpre := hprefix (τ (j+1)) (htH (j+1))
        have hc := mul_le_mul_of_nonneg_left hstate hC
        have heq : (ε/u j+2*C)*u j=ε+2*C*u j := by field_simp [(hu j).ne']
        rw [heq]
        linarith
      have hK : 0≤ε/u j+2*C := by positivity
      have hb := (lastExit_block_sqrt_bound_after_first H (τ j) (τ (j+1)) q e hst (htH (j+1))
        (hu j) hu1 hK he
        (fun k hk hkt => (after_lastExit (hkt.trans (htH (j+1))) hk).le) hd hcost).trans
        (lastExit_radical_linear hK)
      rw [sum_segment_eq (fun k => Real.sqrt (e k)) (htmono j)] at hb
      change S (τ (j+1))-S (τ j)≤_
      simpa only [show ε/u j+2*C+1=1+2*C+ε/u j by ring] using hb
  have hsum (j : ℕ) : S (τ j)-S (τ 0)≤lastExitLinearConstant*
      ((1+2*C)*(j:ℝ)+2*ε/a-2*ε/u j) := by
    induction j with
    | zero => simp [u]
    | succ j ih =>
      have hs := hstep j
      have htel : ε/u j = 2*ε/u j-2*ε/u (j+1) := by
        rw [husucc]
        field_simp
        <;> ring
      rw [Nat.cast_succ]
      have htel' := congrArg (fun z : ℝ => lastExitLinearConstant*z) htel
      nlinarith
  have hfinal : τ J=H := lastExit_eq_end ((hq1 H le_rfl hH).trans hreach)
  have hzero : τ 0=lastExit q H a := by simp [τ,u]
  have hh := hsum J
  rw [hfinal,hzero] at hh
  have hnon := mul_nonneg lastExitLinearConstant_nonneg
    (show 0≤2*ε/u J by positivity)
  change S H-S (lastExit q H a)≤_
  linarith


theorem truncated_lastExit_gain_after_first
    (H J : ℕ) (q e g : ℕ → ℝ) (hH : 1≤H) {ε C a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (ha : 0<a) (hreach : 1≤(2:ℝ)^J*a)
    (hq : ∀j≤H,0<q j) (hq1 : ∀j≤H,1≤j → q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,1≤j → q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀i≤H,(∑j∈Finset.range i,e j)≤ε+C*q i)
    (hgain : ∀j<H,g j≤2*Real.sqrt (e j))
    (htangent : ∀j<H,g j≤(Real.log (q (j+1))-Real.log (q j))/2+e j/a) :
    (∑j∈Finset.range H,g j)≤
      max 0 ((Real.log a-Real.log (q 0))/2)+ε/a+C+
      2*lastExitLinearConstant*((1+2*C)*(J:ℝ)+2*ε/a) := by
  let τ := lastExit q H a
  have hτ : τ≤H := lastExit_le q H a
  have hfirst : (∑j∈Finset.range τ,g j)≤
      max 0 ((Real.log a-Real.log (q 0))/2)+ε/a+C := by
    by_cases hp : 0<τ
    · have hs : q τ≤a := lastExit_state hp
      have hl := Real.log_le_log (hq τ hτ) hs
      have hm := le_max_right (0:ℝ) ((Real.log a-Real.log (q 0))/2)
      have hg := tangent_gain_prefix τ q e g a (fun j hj => htangent j (by omega))
      have hc := hprefix τ hτ
      have hc' : (∑j∈Finset.range τ,e j)/a≤ε/a+C := by
        apply (div_le_iff₀ ha).mpr
        have hh := mul_le_mul_of_nonneg_left hs hC
        have hid : (ε/a+C)*a=ε+C*a := by field_simp [ha.ne']
        rw [hid]
        linarith
      linarith
    · have hz : τ=0 := by omega
      rw [hz]
      simp only [Finset.range_zero,Finset.sum_empty]
      positivity
  have htail : (∑j∈Finset.range H,g j)-(∑j∈Finset.range τ,g j)≤
      2*((∑j∈Finset.range H,Real.sqrt (e j))-
        (∑j∈Finset.range τ,Real.sqrt (e j))) := by
    rw [← sum_segment_eq g hτ,← sum_segment_eq (fun j => Real.sqrt (e j)) hτ,
      Finset.mul_sum]
    exact Finset.sum_le_sum fun j hj => hgain (τ+j) (by have := Finset.mem_range.mp hj; omega)
  have hsqrt := truncated_lastExit_sqrt_entropy_after_first H J q e hH hε hC ha hreach hq1 he hd hprefix
  change (∑j∈Finset.range H,Real.sqrt (e j))-
    (∑j∈Finset.range τ,Real.sqrt (e j))≤_ at hsqrt
  linarith


#print axioms truncated_lastExit_gain_after_first
end ConditionalNonpolynomial.Analytic
