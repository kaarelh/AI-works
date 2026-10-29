import ScalarChannelErrorBudget
import ActualUniformChannelMass

/-! Explicit width budgets for the actual finite channel construction.
The displayed expression is polynomial in H, B, exp S, 1/v, 1/κ and 1/τ,
and linear in the size M of the finite input set. -/
noncomputable section
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def channelFailureAllocation (H : ℕ) (κ : ℝ) : ℝ := κ/(2*((H:ℝ)+1))

def finiteChannelWidthBudget (M : ℝ) (H : ℕ) (B S v κ τ : ℝ) : ℝ :=
  1+2*64^4*((H:ℝ)+1)^5*(1+2*M)*B^4*(Real.exp S)^4/(κ^5*v^2)+
    64*M/κ^3+4*Real.log 2/τ

theorem channelFailureAllocation_pos (H : ℕ) {κ : ℝ} (hκ : 0<κ) :
    0<channelFailureAllocation H κ := by unfold channelFailureAllocation; positivity

theorem channelFailureAllocation_le_one (H : ℕ) {κ : ℝ} (hκ : κ≤1) :
    channelFailureAllocation H κ≤1 := by
  unfold channelFailureAllocation
  apply (div_le_iff₀ (by positivity : 0<2*((H:ℝ)+1))).mpr
  nlinarith [Nat.cast_nonneg (α:=ℝ) H]

theorem channelFailureAllocation_total (H : ℕ) (κ : ℝ) :
    channelFailureAllocation H κ+(∑_j : Fin H,channelFailureAllocation H κ)=κ/2 := by
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,channelFailureAllocation]
  have hh : (H:ℝ)+1≠0 := by positivity
  field_simp
  ring

theorem channelMomentPrecision_le_quarter (H : ℕ) {S v κ : ℝ}
    (hS : 0≤S) (hv : 0≤v) (hv1 : v≤1) (hκ : 0≤κ) (hκ1 : κ≤1) :
    channelMomentPrecision H S v κ≤1/4 := by
  have he : 1≤Real.exp S := Real.one_le_exp hS
  have hs : Real.sqrt v≤1 := (Real.sqrt_le_one).mpr hv1
  have hnum : κ*Real.sqrt v≤1 := by nlinarith [Real.sqrt_nonneg v]
  have hH : 1≤(H:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) H]
  have hden : 64≤64*((H:ℝ)+1)*Real.exp S := by nlinarith
  have hh : κ*Real.sqrt v/(64*((H:ℝ)+1)*Real.exp S)≤1/2 := by
    apply (div_le_iff₀ (by positivity : 0<64*((H:ℝ)+1)*Real.exp S)).mpr
    nlinarith
  have hh0 : 0≤κ*Real.sqrt v/(64*((H:ℝ)+1)*Real.exp S) := by positivity
  unfold channelMomentPrecision
  nlinarith

theorem finiteChannelWidthBudget_ge_one {M B v κ τ : ℝ} (H : ℕ) (S : ℝ)
    (hM : 0≤M) (hv : 0<v) (hκ : 0<κ) (hτ : 0<τ) :
    1≤finiteChannelWidthBudget M H B S v κ τ := by
  unfold finiteChannelWidthBudget
  have hlog : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  have h0 : 0≤2*64^4*((H:ℝ)+1)^5*(1+2*M)*B^4*(Real.exp S)^4/(κ^5*v^2) := by positivity
  have h1 : 0≤64*M/κ^3 := by positivity
  have h2 : 0≤4*Real.log 2/τ := by positivity
  linarith

/-- All stochastic error and entropy-transfer width conditions follow from
one explicit polynomial expression. -/
theorem finiteChannelWidthBudget_conditions {M B S v κ τ : ℝ} {H N : ℕ}
    (hM : 0≤M) (hS : 0≤S) (hv : 0<v) (hv1 : v≤1)
    (hκ : 0<κ) (hκ1 : κ≤1) (hτ : 0<τ)
    (hN : finiteChannelWidthBudget M H B S v κ τ≤(N:ℝ)) :
    0<N ∧ channelMomentPrecision H S v κ≤1/4 ∧
    (1+2*M)*B^4≤channelFailureAllocation H κ*((N:ℝ)*(channelMomentPrecision H S v κ)^2) ∧
    64*M≤(N:ℝ)*κ^3 ∧ Real.log 2≤(N:ℝ)*τ/4 := by
  have hlog : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  let K := 2*64^4*((H:ℝ)+1)^5*(1+2*M)*B^4*(Real.exp S)^4/(κ^5*v^2)
  have hK : 0≤K := by dsimp [K]; positivity
  have hread : 0≤64*M/κ^3 := by positivity
  have hll : 0≤4*Real.log 2/τ := by positivity
  have hsum : 1+K+64*M/κ^3+4*Real.log 2/τ≤(N:ℝ) := hN
  have hn : 0<(N:ℝ) := by linarith
  refine ⟨by exact_mod_cast hn,channelMomentPrecision_le_quarter H hS hv.le hv1 hκ.le hκ1,?_,?_,?_⟩
  · have hkN : K≤(N:ℝ) := by linarith
    have hm := mul_le_mul_of_nonneg_right hkN
      (show 0≤channelFailureAllocation H κ*(channelMomentPrecision H S v κ)^2 by
        exact mul_nonneg (channelFailureAllocation_pos H hκ).le (sq_nonneg _))
    have he : K*(channelFailureAllocation H κ*(channelMomentPrecision H S v κ)^2)=(1+2*M)*B^4 := by
      dsimp [K,channelFailureAllocation,channelMomentPrecision]
      have hs : Real.sqrt v^4=v^2 := by rw [show (4:ℕ)=2*2 by norm_num,pow_mul,Real.sq_sqrt hv.le]
      have hh : (H:ℝ)+1≠0 := by positivity
      have hex : Real.exp S≠0 := (Real.exp_pos S).ne'
      field_simp
      rw [hs]
    rw [he] at hm
    nlinarith
  · have hh : 64*M/κ^3≤(N:ℝ) := by linarith
    exact (div_le_iff₀ (by positivity : 0<κ^3)).mp hh
  · have hh : 4*Real.log 2/τ≤(N:ℝ) := by linarith
    have hm := (div_le_iff₀ hτ).mp hh
    linarith

#print axioms finiteChannelWidthBudget_conditions
end ConditionalNonpolynomial.Analytic
