import NeuralGeneralization.BatchTwoActivationUniformMain
import NeuralGeneralization.BatchTwoActivationSharpCapacityCount
import Mathlib.Analysis.Complex.ExponentialBounds

/-! Literal scalar formulas from the unbounded-activation manuscript.
The endpoint polynomials may be enlarged without changing the theorem. -/
noncomputable section
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def manuscriptCapacity (d r:ℕ) (ℓ K:ℝ) : ℕ :=
  ⌈(16*((r:ℝ)+1)*ℓ^(r+1)*Real.sqrt (((d:ℝ)+1)/d)*
    (K/((r:ℝ)+2))^(((r:ℝ)+2)/2))^3⌉₊

def manuscriptLogCapacity (d r:ℕ) (ℓ K:ℝ) : ℝ :=
  (manuscriptCapacity d r ℓ K:ℝ)*Real.log ((2:ℝ)^d+1)

/-- A sufficiently large energy budget dominates any prescribed nonnegative
log-capacity. This allows enlargement of the unspecified endpoint polynomial
without weakening the manuscript's displayed sample formula. -/
theorem manuscriptLogCapacity_dominates {d r:ℕ} (hd:1≤d) {ℓ K P:ℝ}
    (hℓ:1≤ℓ) (hP:0≤P) (hK:((r:ℝ)+2)*(P+1)≤K) :
    P≤manuscriptLogCapacity d r ℓ K := by
  have hd0:(0:ℝ)<d := Nat.cast_pos.mpr (by omega)
  have hr0:(0:ℝ)≤r := Nat.cast_nonneg _
  have hL:0<(r:ℝ)+2 := by positivity
  have hbase:P+1≤K/((r:ℝ)+2) := (le_div_iff₀ hL).mpr (by nlinarith)
  have hbase1:1≤K/((r:ℝ)+2) := by linarith
  have hp := Real.rpow_le_rpow_of_exponent_le hbase1 (by linarith : (1:ℝ)≤((r:ℝ)+2)/2)
  rw [Real.rpow_one] at hp
  have hpow:1≤ℓ^(r+1) := one_le_pow₀ hℓ
  have hsqrt:1≤Real.sqrt (((d:ℝ)+1)/d) := by
    apply Real.le_sqrt_of_sq_le
    apply (le_div_iff₀ hd0).mpr
    nlinarith
  have hprod : P+1≤16*((r:ℝ)+1)*ℓ^(r+1)*Real.sqrt (((d:ℝ)+1)/d)*
      (K/((r:ℝ)+2))^(((r:ℝ)+2)/2) := by
    have hh0:0≤(K/((r:ℝ)+2))^(((r:ℝ)+2)/2) := Real.rpow_nonneg (by linarith) _
    have hm : 1≤16*((r:ℝ)+1)*ℓ^(r+1)*Real.sqrt (((d:ℝ)+1)/d) := by
      have h1:=mul_le_mul (show (1:ℝ)≤16*((r:ℝ)+1) by linarith) hpow (by norm_num) (by positivity)
      have h2:=mul_le_mul h1 hsqrt (by norm_num) (by positivity)
      simpa only [one_mul] using h2
    exact (hbase.trans hp).trans (by nlinarith [mul_le_mul_of_nonneg_right hm hh0])
  have hc : (P+1)^3≤(manuscriptCapacity d r ℓ K:ℝ) := by
    exact (pow_le_pow_left₀ (by positivity) hprod 3).trans (Nat.le_ceil _)
  have hlog : (1:ℝ)≤Real.log ((2:ℝ)^d+1) := by
    have hp2 : (2:ℝ)≤2^d := by
      have hh := pow_le_pow_right₀ (by norm_num : (1:ℝ)≤2) hd
      simpa only [pow_one] using hh
    have hh:=Real.log_le_log (by norm_num : (0:ℝ)<3) (by linarith : (3:ℝ)≤(2:ℝ)^d+1)
    have hthree := Real.log_three_gt_d9
    linarith
  have hc0:(0:ℝ)≤manuscriptCapacity d r ℓ K := Nat.cast_nonneg _
  have hmul:=mul_le_mul_of_nonneg_left hlog hc0
  unfold manuscriptLogCapacity
  have hPP : P≤(P+1)^3 := by nlinarith [sq_nonneg P,mul_nonneg hP (sq_nonneg P)]
  nlinarith

def manuscriptTargetM (d C r:ℕ) (ℓ:ℝ) : ℝ :=
  ((d:ℝ)+1)*(ℓ*(C:ℝ)^2)^(r+1)
def manuscriptTargetB (C r:ℕ) (ℓ:ℝ) : ℝ :=
  2+ℓ*(Real.sqrt 2*(C:ℝ)^2+Real.sqrt C+2+Real.sqrt (2*Real.log (2*((r:ℝ)+2))))
def manuscriptTargetE (d C r:ℕ) (ℓ:ℝ) : ℝ :=
  ℓ*manuscriptTargetM d C r ℓ*(1+((r:ℝ)+2)*(C:ℝ))*(manuscriptTargetB C r ℓ)^r
def manuscriptTargetRadius (d C r:ℕ) (ℓ:ℝ) : ℝ :=
  (4*((3*Real.sqrt 2*(C:ℝ)^2+1)*manuscriptTargetE d C r ℓ+manuscriptTargetM d C r ℓ))⁻¹
def manuscriptTargetCost (d C r:ℕ) (ℓ:ℝ) : ℝ :=
  2*((d:ℝ)*((d:ℝ)+1)*(C:ℝ)^2+2*(r:ℝ)*(C:ℝ)^4+36*(C:ℝ)^4)+
    4*((d:ℝ)+2+(r:ℝ)*(C:ℝ))/manuscriptTargetRadius d C r ℓ+2

theorem manuscriptTargetCost_lower {d C r:ℕ} (hC:1≤C) {ℓ:ℝ} (hℓ:1≤ℓ) :
    (C:ℝ)+2≤manuscriptTargetCost d C r ℓ := by
  have hc1:(1:ℝ)≤C := by exact_mod_cast hC
  have hl0:0≤ℓ := by linarith
  have hrad:0≤manuscriptTargetRadius d C r ℓ := by
    unfold manuscriptTargetRadius manuscriptTargetE manuscriptTargetM manuscriptTargetB
    positivity
  have hfrac:0≤4*((d:ℝ)+2+(r:ℝ)*(C:ℝ))/manuscriptTargetRadius d C r ℓ := by positivity
  have hc4:(C:ℝ)≤(C:ℝ)^4 := by
    have hc2:(C:ℝ)≤(C:ℝ)^2 := by nlinarith [sq_nonneg ((C:ℝ)-1)]
    nlinarith [sq_nonneg ((C:ℝ)^2-1)]
  unfold manuscriptTargetCost
  have hother:0≤(d:ℝ)*((d:ℝ)+1)*(C:ℝ)^2+2*(r:ℝ)*(C:ℝ)^4 := by positivity
  nlinarith

def manuscriptSpectralRadius (r:ℕ) (ℓ K:ℝ) : ℝ :=
  (16*((r:ℝ)+2)*ℓ^(r+2)*(K+1)*(Real.sqrt K+1)^r)⁻¹

def manuscriptSmallScale (d r:ℕ) (ℓ K:ℝ) : ℝ :=
  min (manuscriptSpectralRadius r ℓ K/8) (1/Real.sqrt (8*((d:ℝ)+1)))

def manuscriptSpectralBudget (d C r:ℕ) (ℓ ε:ℝ) : ℝ :=
  4*manuscriptTargetCost d C r ℓ+8*Real.log (2*((r:ℝ)+2)/ε)

def manuscriptEndpointBudget (d C r:ℕ) (ℓ ε:ℝ) : ℝ :=
  2+manuscriptTargetCost d C r ℓ/(manuscriptSmallScale d r ℓ (manuscriptSpectralBudget d C r ℓ ε))^2+
    Real.log (2*(2*((r:ℝ)+1)+1)/ε)


theorem manuscriptSpectralBudget_pos {d C r:ℕ} (hC:1≤C) {ℓ ε:ℝ}
    (hℓ:1≤ℓ) (hε:0<ε) (hε1:ε<1) : 0<manuscriptSpectralBudget d C r ℓ ε := by
  have hA:=manuscriptTargetCost_lower (d:=d) (r:=r) hC hℓ
  have hlog:0≤Real.log (2*((r:ℝ)+2)/ε) := by
    apply Real.log_nonneg
    apply (one_le_div hε).mpr
    have hr:(0:ℝ)≤r:=Nat.cast_nonneg _
    linarith
  unfold manuscriptSpectralBudget
  have hc:(0:ℝ)≤C:=Nat.cast_nonneg _
  linarith

theorem manuscriptSmallScale_bounds {d r:ℕ} {ℓ K:ℝ} (hℓ:1≤ℓ) (hK:0≤K) :
    0<manuscriptSmallScale d r ℓ K ∧ manuscriptSmallScale d r ℓ K≤1 := by
  have hl:0<ℓ:=by linarith
  have hr:0<manuscriptSpectralRadius r ℓ K := by unfold manuscriptSpectralRadius;positivity
  have hs:0<Real.sqrt (8*((d:ℝ)+1)):=Real.sqrt_pos.mpr (by positivity)
  have hs1:1≤Real.sqrt (8*((d:ℝ)+1)) := by
    apply Real.le_sqrt_of_sq_le
    have hd:(0:ℝ)≤d:=Nat.cast_nonneg _
    nlinarith
  constructor
  · exact lt_min (by positivity) (by positivity)
  · apply (min_le_right _ _).trans
    exact (div_le_one hs).mpr hs1

theorem manuscriptEndpointBudget_lower {d C r:ℕ} (hC:1≤C) {ℓ ε:ℝ}
    (hℓ:1≤ℓ) (hε:0<ε) (hε1:ε<1) :
    (C:ℝ)+Real.log (1/ε)≤manuscriptEndpointBudget d C r ℓ ε := by
  have hA:=manuscriptTargetCost_lower (d:=d) (r:=r) hC hℓ
  have hA0:0≤manuscriptTargetCost d C r ℓ:=by have := Nat.cast_nonneg C (α:=ℝ);linarith
  obtain ⟨ht,ht1⟩:=manuscriptSmallScale_bounds (d:=d) hℓ (manuscriptSpectralBudget_pos hC hℓ hε hε1).le
  have ht2:0<(manuscriptSmallScale d r ℓ (manuscriptSpectralBudget d C r ℓ ε))^2:=sq_pos_of_pos ht
  have ht21:(manuscriptSmallScale d r ℓ (manuscriptSpectralBudget d C r ℓ ε))^2≤1:=by nlinarith
  have hdiv:manuscriptTargetCost d C r ℓ≤manuscriptTargetCost d C r ℓ/
      (manuscriptSmallScale d r ℓ (manuscriptSpectralBudget d C r ℓ ε))^2 := by
    apply (le_div_iff₀ ht2).mpr
    nlinarith [mul_le_mul_of_nonneg_left ht21 hA0]
  have hlog:Real.log (1/ε)≤Real.log (2*(2*((r:ℝ)+1)+1)/ε) := by
    apply Real.log_le_log (by positivity)
    apply div_le_div_of_nonneg_right _ hε.le
    have hr:(0:ℝ)≤r:=Nat.cast_nonneg _
    linarith
  unfold manuscriptEndpointBudget
  linarith

def manuscriptWidthBudget (P:ℝ→ℝ→ℝ) (d C r:ℕ) (ℓ ε:ℝ) : ℕ :=
  ⌈max 1 (P d (manuscriptEndpointBudget d C r ℓ ε))⌉₊

def manuscriptSmallWidthEnergy (P:ℝ→ℝ→ℝ) (d C r:ℕ) (ℓ ε:ℝ) : ℝ :=
  2*manuscriptTargetCost d C r ℓ+2*((d:ℝ)+2+(r:ℝ)*(manuscriptWidthBudget P d C r ℓ ε))*Real.log 2+
    4*Real.log (2/ε)

def manuscriptCombinedEnergy (P J:ℝ→ℝ→ℝ) (d C r:ℕ) (ℓ ε:ℝ) : ℝ :=
  ((r:ℝ)+5)*manuscriptSpectralBudget d C r ℓ ε+
    J d (manuscriptEndpointBudget d C r ℓ ε)+manuscriptSmallWidthEnergy P d C r ℓ ε

theorem manuscriptCombinedEnergy_ge (P J:ℝ→ℝ→ℝ) {d C r:ℕ} (hC:1≤C) {ℓ ε:ℝ}
    (hℓ:1≤ℓ) (hε:0<ε) (hε1:ε<1) :
    J d (manuscriptEndpointBudget d C r ℓ ε)≤manuscriptCombinedEnergy P J d C r ℓ ε := by
  have hA:=manuscriptTargetCost_lower (d:=d) (r:=r) hC hℓ
  have hA0:0≤manuscriptTargetCost d C r ℓ:=by have := Nat.cast_nonneg C (α:=ℝ);linarith
  have hKs:0≤manuscriptSpectralBudget d C r ℓ ε:=(manuscriptSpectralBudget_pos hC hℓ hε hε1).le
  have hl2:0≤Real.log 2:=Real.log_nonneg (by norm_num)
  have hle:0≤Real.log (2/ε):=Real.log_nonneg ((one_le_div hε).mpr (by linarith))
  have hD:0≤(d:ℝ)+2+(r:ℝ)*(manuscriptWidthBudget P d C r ℓ ε):=by positivity
  have hJ0:0≤manuscriptSmallWidthEnergy P d C r ℓ ε:=by
    unfold manuscriptSmallWidthEnergy
    positivity
  unfold manuscriptCombinedEnergy
  have hh:0≤((r:ℝ)+5)*manuscriptSpectralBudget d C r ℓ ε:=by positivity
  linarith

end NeuralGeneralization.BatchTwoActivation
