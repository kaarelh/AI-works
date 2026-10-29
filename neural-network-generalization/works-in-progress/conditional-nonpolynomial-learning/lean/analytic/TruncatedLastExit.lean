import GaussianEntropyGain
import ScalarDyadicEntropy

/-! Last-exit bounds above an arbitrary cutoff. The excess need not be
smaller than the cutoff, which is essential near the critical boundary. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

def lastExitLinearConstant : ℝ :=
  Real.sqrt (1/(driftRate*driftDissipation)+1/driftDissipation+1)

lemma lastExitLinearConstant_nonneg : 0≤lastExitLinearConstant := Real.sqrt_nonneg _

lemma lastExit_radical_linear {K : ℝ} (hK : 0≤K) :
    Real.sqrt (((K/driftRate+1)/driftDissipation+1)*K)≤lastExitLinearConstant*(K+1) := by
  have hr := driftRate_pos
  have hd := driftDissipation_pos
  have hA : 0≤1/(driftRate*driftDissipation) := by positivity
  have hB : 0≤1/driftDissipation+1 := by positivity
  have h1 : K^2≤(K+1)^2 := by nlinarith
  have h2 : K≤(K+1)^2 := by nlinarith [sq_nonneg K]
  have h1' := mul_le_mul_of_nonneg_left h1 hA
  have h2' := mul_le_mul_of_nonneg_left h2 hB
  apply (Real.sqrt_le_iff).mpr
  constructor
  · exact mul_nonneg lastExitLinearConstant_nonneg (by linarith)
  · rw [mul_pow,lastExitLinearConstant,Real.sq_sqrt (by positivity)]
    have he : ((K/driftRate+1)/driftDissipation+1)*K =
        (1/(driftRate*driftDissipation))*K^2+(1/driftDissipation+1)*K := by ring
    rw [he]
    nlinarith

/-- The square-root entropy AFTER the last visit below a has a logarithmic
number of constant terms and a geometric excess term ε/a. -/
theorem truncated_lastExit_sqrt_entropy
    (H J : ℕ) (q e : ℕ → ℝ) {ε C a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (ha : 0<a) (hreach : 1≤(2:ℝ)^J*a)
    (hq1 : ∀j≤H,q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
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
        (after_lastExit (htH (j+1)) hst).le.trans (hq1 (τ (j+1)) (htH (j+1)))
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
      have hb := (lastExit_block_sqrt_bound H (τ j) (τ (j+1)) q e hst (htH (j+1))
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
  have hfinal : τ J=H := lastExit_eq_end ((hq1 H le_rfl).trans hreach)
  have hzero : τ 0=lastExit q H a := by simp [τ,u]
  have hh := hsum J
  rw [hfinal,hzero] at hh
  have hnon := mul_nonneg lastExitLinearConstant_nonneg
    (show 0≤2*ε/u J by positivity)
  change S H-S (lastExit q H a)≤_
  linarith

#print axioms truncated_lastExit_sqrt_entropy

theorem tangent_gain_prefix (m : ℕ) (q e g : ℕ → ℝ) (a : ℝ)
    (htangent : ∀j<m,g j≤(Real.log (q (j+1))-Real.log (q j))/2+e j/a) :
    (∑j∈Finset.range m,g j)≤(Real.log (q m)-Real.log (q 0))/2+
      (∑j∈Finset.range m,e j)/a := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hi := ih (fun j hj => htangent j (by omega))
    have hs := htangent m (by omega)
    rw [Finset.sum_range_succ,Finset.sum_range_succ,add_div]
    linarith

/-- Combining the tangent bound below the cutoff with the dyadic square-root
bound above it removes the bad sqrt(H ε) dependence in the long regime. -/
theorem truncated_lastExit_gain
    (H J : ℕ) (q e g : ℕ → ℝ) {ε C a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (ha : 0<a) (hreach : 1≤(2:ℝ)^J*a)
    (hq : ∀j≤H,0<q j) (hq1 : ∀j≤H,q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
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
  have hsqrt := truncated_lastExit_sqrt_entropy H J q e hε hC ha hreach hq1 he hd hprefix
  change (∑j∈Finset.range H,Real.sqrt (e j))-
    (∑j∈Finset.range τ,Real.sqrt (e j))≤_ at hsqrt
  linarith

#print axioms truncated_lastExit_gain
end ConditionalNonpolynomial.Analytic
