import NeuralGeneralization.OnlineLowerTanhPairVariation
import NeuralGeneralization.OnlineLowerTanhLocalization
import NeuralGeneralization.OnlineLowerTanhScalarBounds
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.Topology.Order.Compact

/-! # Actual intrinsic tanh gain and existence of global maximizers -/
noncomputable section
open scoped BigOperators Topology
open Filter Set Metric
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

def intrinsicGain {n : ℕ} (u : Fin n → ℝ) : ℝ :=
  |parityCorrelation u 0|/Real.sqrt (incomingEnergy u)

def IsIntrinsicMaximizer {n : ℕ} (u : Fin n → ℝ) : Prop :=
  ∀v : Fin n → ℝ,intrinsicGain v≤ intrinsicGain u

@[simp] theorem intrinsicGain_zero (n : ℕ) : intrinsicGain (0 : Fin n → ℝ)=0 := by
  simp [intrinsicGain,incomingEnergy]

theorem intrinsicGain_nonneg {n : ℕ} (u : Fin n → ℝ) : 0≤ intrinsicGain u := by
  unfold intrinsicGain
  positivity

theorem parityCorrelation_abs_le_one {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    |parityCorrelation u b|≤1 := by
  rw [parityCorrelation_eq_cubeMean]
  apply (abs_cubeMean_le _).trans
  have h := cubeMean_mono
    (fun x=>|paritySign x*Real.tanh (b+incomingLinear u x)|) (fun _=>1)
    (fun x=>by rw [abs_mul,abs_paritySign,one_mul]; exact (Real.abs_tanh_lt_one _).le)
  simpa only [cubeMean_const] using h

theorem coordinate_abs_le_sqrt_energy {n : ℕ} (u : Fin n → ℝ) (i : Fin n) :
    |u i|≤ Real.sqrt (incomingEnergy u) := by
  have h := coordinate_sq_le_energy u i
  have hs := Real.sq_sqrt (incomingEnergy_nonneg u)
  have ha := sq_abs (u i)
  nlinarith [abs_nonneg (u i),Real.sqrt_nonneg (incomingEnergy u)]

theorem pi_norm_le_sqrt_energy {n : ℕ} (u : Fin n → ℝ) :
    ‖u‖≤ Real.sqrt (incomingEnergy u) := by
  apply (pi_norm_le_iff_of_nonneg (Real.sqrt_nonneg _)).mpr
  intro i
  simpa only [Real.norm_eq_abs] using coordinate_abs_le_sqrt_energy u i

theorem continuous_incomingEnergy (n : ℕ) : Continuous (incomingEnergy (n:=n)) := by
  unfold incomingEnergy
  fun_prop

theorem continuous_parityCorrelation (n : ℕ) (b : ℝ) :
    Continuous (fun u : Fin n → ℝ => parityCorrelation u b) := by
  unfold parityCorrelation incomingLinear
  fun_prop

/-- The actual high-order finite-difference bound makes gain continuous
at the zero incoming vector in every degree at least two. -/
theorem intrinsicGain_origin_bound {n : ℕ} (hn : 1≤ n) (u : Fin n → ℝ) :
    intrinsicGain u≤(n.factorial:ℝ)*Real.sqrt (incomingEnergy u)^(n-1) := by
  by_cases hu : u=0
  · subst u
    rw [intrinsicGain_zero]
    positivity
  have hE := incomingEnergy_pos_of_ne_zero u hu
  have hs : 0< Real.sqrt (incomingEnergy u) := Real.sqrt_pos.mpr hE
  have hcoeff := tanh_ridgeParity_abs_le_factorial_product u 0
  rw [ridgeParity_tanh] at hcoeff
  have hprod : (∏i,|u i|)≤ Real.sqrt (incomingEnergy u)^n := by
    calc
      _ ≤ ∏_i : Fin n,Real.sqrt (incomingEnergy u) :=
        Finset.prod_le_prod (fun i _=>abs_nonneg _) (fun i _=>coordinate_abs_le_sqrt_energy u i)
      _ = _ := by simp
  unfold intrinsicGain
  apply (div_le_iff₀ hs).mpr
  have hh := hcoeff.trans (mul_le_mul_of_nonneg_left hprod (Nat.cast_nonneg _))
  have hexp : n=(n-1)+1 := by omega
  calc
    _ ≤ (n.factorial:ℝ)*Real.sqrt (incomingEnergy u)^n := hh
    _ = _ := by rw [mul_assoc,←pow_succ,Nat.sub_add_cancel hn]

theorem continuous_intrinsicGain {n : ℕ} (hn : 2≤ n) : Continuous (intrinsicGain (n:=n)) := by
  apply continuous_iff_continuousAt.mpr
  intro u
  by_cases hu : u=0
  · subst u
    rw [ContinuousAt,intrinsicGain_zero]
    have hbound : Tendsto (fun v : Fin n → ℝ => (n.factorial:ℝ)*Real.sqrt (incomingEnergy v)^(n-1))
        (𝓝 0) (𝓝 0) := by
      have h := (((continuous_incomingEnergy n).sqrt.pow (n-1)).const_mul (n.factorial:ℝ)).continuousAt (x:=0)
      simpa only [incomingEnergy,Pi.zero_apply,zero_pow (by norm_num : (2:ℕ)≠0),Finset.sum_const_zero,
        Real.sqrt_zero,Pi.pow_apply,Pi.mul_apply,zero_pow (by omega : n-1≠0),mul_zero] using h.tendsto
    exact squeeze_zero' (Filter.Eventually.of_forall intrinsicGain_nonneg)
      (Filter.Eventually.of_forall (intrinsicGain_origin_bound (by omega : 1≤ n))) hbound
  · exact (continuous_parityCorrelation n 0).abs.continuousAt.div
      (continuous_incomingEnergy n).sqrt.continuousAt
      (ne_of_gt (Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero u hu)))

/-- Any positive witness forces the continuous gain to attain a positive
maximum on an explicit compact ball. -/
theorem exists_intrinsic_maximizer_of_witness {n : ℕ} (hn : 2≤ n)
    (w : Fin n → ℝ) (hw : 0< intrinsicGain w) :
    ∃u : Fin n → ℝ,u≠0 ∧ IsIntrinsicMaximizer u := by
  let R := ‖w‖+2/intrinsicGain w+1
  have hR : 0< R := by dsimp [R]; positivity
  have hwR : ‖w‖≤ R := by
    dsimp [R]
    have h := div_pos (by norm_num : (0:ℝ)<2) hw
    linarith
  have hRgain : 1< R*intrinsicGain w := by
    have hcancel : (2/intrinsicGain w)*intrinsicGain w=2 := div_mul_cancel₀ _ hw.ne'
    have hn0 := mul_nonneg (norm_nonneg w) hw.le
    dsimp [R]
    nlinarith
  obtain ⟨u,hu,hmax⟩ := (isCompact_closedBall (0 : Fin n → ℝ) R).exists_isMaxOn
    ⟨w,by simpa only [mem_closedBall,dist_zero_right] using hwR⟩
    (continuous_intrinsicGain hn).continuousOn
  have hwmax : intrinsicGain w≤ intrinsicGain u :=
    hmax (by simpa only [mem_closedBall,dist_zero_right] using hwR)
  have hunon : u≠0 := by intro he; rw [he,intrinsicGain_zero] at hwmax; linarith
  refine ⟨u,hunon,?_⟩
  intro v
  by_cases hv : v∈closedBall (0 : Fin n → ℝ) R
  · exact hmax hv
  · have hvR : R<‖v‖ := by simpa only [mem_closedBall,dist_zero_right,not_le] using hv
    have hvE := pi_norm_le_sqrt_energy v
    have hvroot : 0< Real.sqrt (incomingEnergy v) := hR.trans (hvR.trans_le hvE)
    have hsmall : intrinsicGain v< intrinsicGain w := by
      change |parityCorrelation v 0|/Real.sqrt (incomingEnergy v) < intrinsicGain w
      apply (div_lt_iff₀ hvroot).mpr
      have hcoeff := parityCorrelation_abs_le_one v 0
      have hprod := mul_lt_mul_of_pos_right (hvR.trans_le hvE) hw
      nlinarith only [hcoeff,hprod,hRgain]
    exact hsmall.le.trans hwmax

theorem balancedParity_gain_abs (r : ℕ) :
    |parityCorrelation (fun _ : Fin (2*r+1)=>balancedGain r) 0| =
      balancedParity r (balancedGain r) := by
  have h := abs_of_pos (balancedParity_gain_pos r)
  simpa only [balancedParity,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul] using h

theorem intrinsicGain_balanced (r : ℕ) :
    intrinsicGain (fun _ : Fin (2*r+1)=>balancedGain r)=1/balancedCost r := by
  unfold intrinsicGain
  rw [balancedParity_gain_abs]
  have hE : incomingEnergy (fun _ : Fin (2*r+1)=>balancedGain r) =
      (2*r+1:ℕ)*(balancedGain r)^2 := by simp [incomingEnergy]
  rw [hE,Real.sqrt_mul (by positivity),Real.sqrt_sq (balancedGain_pos r).le]
  unfold balancedCost
  field_simp

theorem intrinsicGain_balanced_pos (r : ℕ) :
    0 < intrinsicGain (fun _ : Fin (2*r+1)=>balancedGain r) := by
  rw [intrinsicGain_balanced]
  exact div_pos (by norm_num) (balancedCost_pos r)

/-- Actual global maximizers exist in every odd degree at least three. -/
theorem exists_intrinsic_maximizer (r : ℕ) (hr : 1≤r) :
    ∃u : Fin (2*r+1) → ℝ,u≠0 ∧ IsIntrinsicMaximizer u :=
  exists_intrinsic_maximizer_of_witness (by omega)
    (fun _=>balancedGain r) (intrinsicGain_balanced_pos r)

/-- Every global maximizer has a fixed dimension-normalized gain lower
bound, so the already proved global lattice theorem applies uniformly. -/
theorem IsIntrinsicMaximizer_competitive (r : ℕ) (u : Fin (2*r+1) → ℝ)
    (hu : IsIntrinsicMaximizer u) :
    u≠0 ∧ (1/4:ℝ)*Real.sqrt (incomingEnergy u) ≤ (2*r+1:ℕ)*|parityCorrelation u 0| := by
  have hw := hu (fun _=>balancedGain r)
  have hpos := (intrinsicGain_balanced_pos r).trans_le hw
  have hnon : u≠0 := by intro he; rw [he,intrinsicGain_zero] at hpos; exact (lt_irrefl 0) hpos
  have hroot := Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero u hnon)
  rw [intrinsicGain_balanced] at hw
  have hcost := balancedCost_le_four_degree r
  have hlow : 1/(4*(2*r+1:ℕ):ℝ) ≤ 1/balancedCost r :=
    div_le_div_of_nonneg_left (by norm_num) (balancedCost_pos r) hcost
  have h := hlow.trans hw
  unfold intrinsicGain at h
  have hh := (div_le_div_iff₀ (show (0:ℝ)<4*(2*r+1:ℕ) by positivity) hroot).mp h
  refine ⟨hnon,?_⟩
  nlinarith only [hh]

@[simp] theorem intrinsicGain_abs_weights {n : ℕ} (u : Fin n → ℝ) :
    intrinsicGain (fun i=>|u i|)=intrinsicGain u := by
  unfold intrinsicGain
  rw [incomingEnergy_abs,←parityCorrelation_abs_weights u 0]

theorem IsIntrinsicMaximizer_abs_weights {n : ℕ} (u : Fin n → ℝ)
    (hu : IsIntrinsicMaximizer u) : IsIntrinsicMaximizer (fun i=>|u i|) := by
  intro v
  rw [intrinsicGain_abs_weights]
  exact hu v

end NeuralGeneralization.OnlineLowerTanh
