import NeuralGeneralization.OnlineLowerTanhConditioningCap
import Mathlib.Analysis.Convex.Deriv

/-! # Exact two-coordinate variations of an actual tanh parity atom -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

lemma cubeMean_div_const {n : ℕ} (f : Cube n → ℝ) (c : ℝ) :
    cubeMean (fun x=>f x/c)=cubeMean f/c := by
  simp only [div_eq_mul_inv,mul_comm _ c⁻¹]
  exact cubeMean_const_mul c⁻¹ f

theorem ridgeParity_centeredDifference {n : ℕ} (f : ℝ → ℝ)
    (u : Fin n → ℝ) (a b : ℝ) :
    ridgeParity (centeredDifference f a) u b =
      (ridgeParity f u (b+a)-ridgeParity f u (b-a))/2 := by
  unfold ridgeParity centeredDifference
  have hpoint (x : Cube n) :
      paritySign x*((f (b+incomingLinear u x+a)-f (b+incomingLinear u x-a))/2) =
        (paritySign x*f (b+a+incomingLinear u x)-paritySign x*f (b-a+incomingLinear u x))/2 := by
    rw [show b+incomingLinear u x+a=b+a+incomingLinear u x by ring,
      show b+incomingLinear u x-a=b-a+incomingLinear u x by ring]
    ring
  simp_rw [hpoint]
  rw [cubeMean_div_const,cubeMean_sub]

theorem parityCorrelation_prepend {n : ℕ} (u : Fin n → ℝ) (a b : ℝ) :
    parityCorrelation (Fin.cases a u) b =
      (parityCorrelation u (b+a)-parityCorrelation u (b-a))/2 := by
  rw [←ridgeParity_tanh,ridgeParity_succ]
  simp only [Fin.cases_zero,Fin.cases_succ]
  rw [ridgeParity_centeredDifference,ridgeParity_tanh,ridgeParity_tanh]

def pairIncoming {n : ℕ} (u : Fin n → ℝ) (μ h : ℝ) : Fin (n+2) → ℝ :=
  Fin.cases (μ+h) (Fin.cases (μ-h) u)

theorem incomingEnergy_pair {n : ℕ} (u : Fin n → ℝ) (μ h : ℝ) :
    incomingEnergy (pairIncoming u μ h)=incomingEnergy u+2*μ^2+2*h^2 := by
  unfold incomingEnergy pairIncoming
  rw [Fin.sum_univ_succ,Fin.sum_univ_succ]
  simp only [Fin.cases_zero,Fin.cases_succ]
  ring

/-- For odd remaining degree, pair imbalance enters only through the
external-bias response at twice that imbalance. -/
theorem parityCorrelation_pair {n : ℕ} (hn : Odd n)
    (u : Fin n → ℝ) (μ h : ℝ) :
    parityCorrelation (pairIncoming u μ h) 0 =
      (parityCorrelation u (2*μ)-parityCorrelation u (2*h))/2 := by
  unfold pairIncoming
  rw [parityCorrelation_prepend,parityCorrelation_prepend,parityCorrelation_prepend]
  have h1 : 0+(μ+h)+(μ-h)=2*μ := by ring
  have h2 : 0+(μ+h)-(μ-h)=2*h := by ring
  have h3 : 0-(μ+h)+(μ-h)=-(2*h) := by ring
  have h4 : 0-(μ+h)-(μ-h)=-(2*μ) := by ring
  rw [h1,h2,h3,h4,parityCorrelation_bias_neg hn,parityCorrelation_bias_neg hn]
  ring

/-- Pair averaging preserves the common mean and decreases exact incoming
squared norm by twice the squared imbalance. -/
theorem incomingEnergy_pair_balance {n : ℕ} (u : Fin n → ℝ) (μ h : ℝ) :
    incomingEnergy (pairIncoming u μ 0)+2*h^2=incomingEnergy (pairIncoming u μ h) := by
  rw [incomingEnergy_pair,incomingEnergy_pair]
  ring

/-- Strict concavity and evenness make the central response strictly
larger than every noncentral response in the same symmetric interval. -/
lemma even_strictConcave_peak (H : ℝ → ℝ) (δ x : ℝ)
    (hconc : StrictConcaveOn ℝ (Set.Icc (-δ) δ) H)
    (heven : ∀t,H (-t)=H t) (hx : |x|≤δ) (hx0 : x≠0) : H x<H 0 := by
  have hmem : x∈Set.Icc (-δ) δ := abs_le.mp hx
  have hneg : -x∈Set.Icc (-δ) δ := by constructor <;> linarith [hmem.1,hmem.2]
  have hne : x≠-x := by intro he; apply hx0; linarith
  have hh := hconc.2 hmem hneg hne
    (by norm_num : (0:ℝ)<1/2) (by norm_num : (0:ℝ)<1/2) (by norm_num)
  rw [heven] at hh
  norm_num [smul_eq_mul] at hh
  simpa only [show (1/2:ℝ)*x+(1/2)*-x=0 by ring,
    show (1/2:ℝ)*H x+(1/2)*H x=H x by ring] using hh

/-- The exact pair variation rules out a nonzero imbalance whenever the
signed remaining parity response has restoring concavity. The conclusion
compares actual normalized tanh parity gains. -/
theorem pair_balance_strictly_improves {n : ℕ} (hn : Odd n)
    (u : Fin n → ℝ) (μ h δ s : ℝ) (hs : |s|=1)
    (hconc : StrictConcaveOn ℝ (Set.Icc (-δ) δ) (fun b=>-s*parityCorrelation u b))
    (hh : |2*h|≤δ) (hh0 : h≠0)
    (hscore : 0<s*parityCorrelation (pairIncoming u μ h) 0)
    (henergy : 0 < incomingEnergy (pairIncoming u μ 0)) :
    |parityCorrelation (pairIncoming u μ h) 0| / Real.sqrt (incomingEnergy (pairIncoming u μ h)) <
      |parityCorrelation (pairIncoming u μ 0) 0| / Real.sqrt (incomingEnergy (pairIncoming u μ 0)) := by
  have hH := even_strictConcave_peak (fun b=>-s*parityCorrelation u b) δ (2*h) hconc
    (fun b=>by rw [parityCorrelation_bias_neg hn]) hh (mul_ne_zero (by norm_num) hh0)
  have hgain : s*parityCorrelation (pairIncoming u μ h) 0 <
      s*parityCorrelation (pairIncoming u μ 0) 0 := by
    rw [parityCorrelation_pair hn,parityCorrelation_pair hn]
    norm_num
    nlinarith only [hH]
  have habs (x : ℝ) (hx : 0<s*x) : |x|=s*x := by
    have hh := abs_of_pos hx
    rw [abs_mul,hs,one_mul] at hh
    exact hh
  rw [habs _ hscore,habs _ (hscore.trans hgain)]
  have henergy_le : incomingEnergy (pairIncoming u μ 0) ≤ incomingEnergy (pairIncoming u μ h) := by
    rw [←incomingEnergy_pair_balance u μ h]
    linarith [sq_nonneg h]
  have hroot := Real.sqrt_pos.mpr henergy
  have hrootle := Real.sqrt_le_sqrt henergy_le
  calc
    _ ≤ (s*parityCorrelation (pairIncoming u μ h) 0)/Real.sqrt (incomingEnergy (pairIncoming u μ 0)) :=
      div_le_div_of_nonneg_left hscore.le hroot hrootle
    _ < _ := (div_lt_div_iff_of_pos_right hroot).mpr hgain

end NeuralGeneralization.OnlineLowerTanh
