import ScalarLastExit

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

def dyadicBlockConstant (C : ℝ) : ℝ :=
  Real.sqrt ((((1+2*C)/driftRate+1)/driftDissipation+1)*(1+2*C))

/-- Last-exit assembly. The assumptions are precisely local drift and the
prefix entropy inequalities proved from the scalar Bellman suffix bound. -/
theorem dyadic_sqrt_entropy (H J : ℕ) (q e : ℕ → ℝ) {ε C a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (ha : 0<a) (hεa : ε≤a)
    (hreach : 1≤(2:ℝ)^J*a)
    (hq1 : ∀j≤H,q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀i≤H,(∑j ∈ Finset.range i,e j)≤ε+C*q i) :
    (∑j ∈ Finset.range H,Real.sqrt (e j))≤
      Real.sqrt ((H:ℝ)*(ε+C*a))+(J:ℝ)*dyadicBlockConstant C := by
  let u : ℕ → ℝ := fun j => (2:ℝ)^j*a
  let τ : ℕ → ℕ := fun j => lastExit q H (u j)
  let S : ℕ → ℝ := fun n => ∑j ∈ Finset.range n,Real.sqrt (e j)
  have hu (j:ℕ) : 0<u j := by dsimp [u]; positivity
  have hueps (j:ℕ) : ε≤u j := by
    have hp : (1:ℝ)≤2^j := one_le_pow₀ (by norm_num)
    have hm := mul_le_mul_of_nonneg_right hp ha.le
    dsimp [u]
    linarith
  have husucc (j:ℕ) : u (j+1)=2*u j := by dsimp [u]; rw [pow_succ]; ring
  have humono (j:ℕ) : u j≤u (j+1) := by rw [husucc]; linarith [hu j]
  have htmono (j:ℕ) : τ j≤τ (j+1) := lastExit_mono (humono j)
  have htH (j:ℕ) : τ j≤H := lastExit_le q H (u j)
  have hstartcost : (∑j ∈ Finset.range (τ 0),e j)≤ε+C*a := by
    by_cases hp : 0<τ 0
    · have hh := lastExit_state hp
      change q (τ 0)≤u 0 at hh
      have hu0 : u 0=a := by simp [u]
      rw [hu0] at hh
      have hpre := hprefix (τ 0) (htH 0)
      nlinarith
    · have hz : τ 0=0 := by omega
      rw [hz]
      simp only [Finset.range_zero,Finset.sum_empty]
      positivity
  have hstart : S (τ 0)≤Real.sqrt ((H:ℝ)*(ε+C*a)) := by
    have hs := sum_sqrt_sq_le (τ 0) e (fun j hj => he j (lt_of_lt_of_le hj (htH 0)))
    have hp := mul_le_mul_of_nonneg_left hstartcost (Nat.cast_nonneg (τ 0) : (0:ℝ)≤τ 0)
    have hcard : (τ 0:ℝ)≤H := by exact_mod_cast htH 0
    have hm := mul_le_mul_of_nonneg_right hcard (show 0≤ε+C*a by positivity)
    apply Real.le_sqrt_of_sq_le
    exact hs.trans (hp.trans hm)
  have hstep (j:ℕ) : S (τ (j+1))≤S (τ j)+dyadicBlockConstant C := by
    by_cases hh : τ j=τ (j+1)
    · rw [← hh]
      have hb : 0≤dyadicBlockConstant C := Real.sqrt_nonneg _
      linarith
    · have hst : τ j<τ (j+1) := lt_of_le_of_ne (htmono j) hh
      have hu1 : u j≤1 := by
        have hq := after_lastExit (htH (j+1)) hst
        exact hq.le.trans (hq1 (τ (j+1)) (htH (j+1)))
      have hcost : (∑k ∈ Finset.range (τ (j+1)),e k)≤(1+2*C)*u j := by
        have hstate := lastExit_state (show 0<τ (j+1) by omega)
        change q (τ (j+1))≤u (j+1) at hstate
        rw [husucc] at hstate
        have hpre := hprefix (τ (j+1)) (htH (j+1))
        have heps := hueps j
        nlinarith
      have hb := lastExit_block_sqrt_bound H (τ j) (τ (j+1)) q e hst (htH (j+1))
        (hu j) hu1 (show 0≤1+2*C by positivity) he
        (fun k hk hkt => (after_lastExit (hkt.trans (htH (j+1))) hk).le) hd hcost
      rw [sum_segment_eq (fun k => Real.sqrt (e k)) (htmono j)] at hb
      change S (τ (j+1))-S (τ j)≤dyadicBlockConstant C at hb
      linarith
  have hsum (j:ℕ) : S (τ j)≤S (τ 0)+(j:ℝ)*dyadicBlockConstant C := by
    induction j with
    | zero => simp
    | succ j ih =>
      have hs := hstep j
      push_cast
      linarith
  have hfinal : τ J=H := lastExit_eq_end ((hq1 H le_rfl).trans hreach)
  have hh := hsum J
  rw [hfinal] at hh
  change S H≤_
  linarith

/-- An explicit logarithmic-in-H number of dyadic scales suffices. The error
term is the required square root of H times the excess over baseline. -/
theorem logarithmic_sqrt_entropy (H : ℕ) (q e : ℕ → ℝ) {ε C : ℝ}
    (hε : 0≤ε) (hC : 0≤C)
    (hq1 : ∀j≤H,q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀i≤H,(∑j ∈ Finset.range i,e j)≤ε+C*q i) :
    (∑j ∈ Finset.range H,Real.sqrt (e j))≤
      Real.sqrt (((C+1)*(H:ℝ)*ε)+C)+
      ((Nat.log2 (H+1)+1:ℕ):ℝ)*dyadicBlockConstant C := by
  let a : ℝ := max ε (1/((H:ℝ)+1))
  have ha : 0<a := lt_of_lt_of_le (by positivity : (0:ℝ)<1/((H:ℝ)+1)) (le_max_right _ _)
  have hea : ε≤a := le_max_left _ _
  have hpow : H+1<2^(Nat.log2 (H+1)+1) :=
    (Nat.log2_lt (by omega : H+1≠0)).mp (by omega)
  have hp : (H:ℝ)+1≤(2:ℝ)^(Nat.log2 (H+1)+1) := by exact_mod_cast hpow.le
  have hr : 1≤(2:ℝ)^(Nat.log2 (H+1)+1)*a := by
    have hh := mul_le_mul_of_nonneg_right hp ha.le
    have ha' : 1/((H:ℝ)+1)≤a := le_max_right _ _
    have hh' := (div_le_iff₀ (by positivity : (0:ℝ)<(H:ℝ)+1)).mp ha'
    nlinarith
  have hh := dyadic_sqrt_entropy H (Nat.log2 (H+1)+1) q e hε hC ha hea hr hq1 he hd hprefix
  have haub : a≤ε+1/((H:ℝ)+1) := by
    apply max_le
    · have hz : (0:ℝ)≤1/((H:ℝ)+1) := by positivity
      linarith
    · linarith
  have hH : (H:ℝ)/((H:ℝ)+1)≤1 := (div_le_one (by positivity)).mpr (by linarith)
  have hn : (H:ℝ)*(ε+C*a)≤(C+1)*(H:ℝ)*ε+C := by
    have hm := mul_le_mul_of_nonneg_left haub (mul_nonneg (Nat.cast_nonneg H) hC)
    have hm' := mul_le_mul_of_nonneg_left hH hC
    have hid : (H:ℝ)*C*(ε+1/((H:ℝ)+1))=(H:ℝ)*C*ε+C*((H:ℝ)/((H:ℝ)+1)) := by ring
    nlinarith
  have hs := Real.sqrt_le_sqrt hn
  linarith

#print axioms dyadic_sqrt_entropy
#print axioms logarithmic_sqrt_entropy
end ConditionalNonpolynomial.Analytic
