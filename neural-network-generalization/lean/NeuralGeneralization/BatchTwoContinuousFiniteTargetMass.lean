import NeuralGeneralization.BatchTwoContinuousFiniteTargetGeometry
import NeuralGeneralization.BatchTwoContinuousFiniteTargetCost
import NeuralGeneralization.BatchTwoContinuousPriorGeometry
import NeuralGeneralization.BatchTwoNonGaussianPowerScale

/-! Actual all-width continuous-regression target mass. Every constant below
is independent of learner width, and tolerance enters only through its log. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

def targetShrink (ν : CoordinateLaw) (d : ℕ) (ρ : ℝ) : ℝ :=
  radiusCap ν*min 1 ρ/((d : ℝ)+1)

def targetLogBudget (ν : CoordinateLaw) (d : ℕ) (ρ : ℝ) : ℝ :=
  |Real.log (radiusCap ν)|+((d : ℝ)+1)+Real.log (1/min 1 ρ)

def targetCost (ν : CoordinateLaw) (d C r : ℕ) (B ρ : ℝ) : ℝ :=
  ν.upperCurvature*teacherEnergyBound d C r B+
    polynomialNoiseCost ν d r C (4*teacherEnergyBound d C r B) (targetLogBudget ν d ρ)

theorem targetShrink_pos (ν : CoordinateLaw) (d : ℕ) {ρ : ℝ} (hρ : 0<ρ) :
    0<targetShrink ν d ρ := div_pos (mul_pos (radiusCap_pos ν) (lt_min zero_lt_one hρ)) (by positivity)

theorem targetShrink_le_cap (ν : CoordinateLaw) (d : ℕ) {ρ : ℝ} (hρ : 0<ρ) :
    targetShrink ν d ρ ≤ radiusCap ν := by
  have hc := radiusCap_pos ν
  have ht : 0≤min 1 ρ := (lt_min zero_lt_one hρ).le
  have hh := mul_le_mul_of_nonneg_left (min_le_left 1 ρ) hc.le
  unfold targetShrink
  apply (div_le_self (mul_nonneg hc.le ht) (by linarith [Nat.cast_nonneg d (α := ℝ)])).trans
  simpa only [mul_one] using hh

theorem targetLogBudget_nonneg (ν : CoordinateLaw) (d : ℕ) {ρ : ℝ} (hρ : 0<ρ) :
    0≤targetLogBudget ν d ρ := by
  have ht : 0<min 1 ρ := lt_min zero_lt_one hρ
  have hl : 0≤Real.log (1/min 1 ρ) := Real.log_nonneg ((one_le_div ht).mpr (min_le_left _ _))
  unfold targetLogBudget
  positivity

theorem targetLogBudget_bound (ν : CoordinateLaw) (d : ℕ) {ρ : ℝ} (hρ : 0<ρ) :
    Real.log (1/targetShrink ν d ρ)≤targetLogBudget ν d ρ := by
  have hc := radiusCap_pos ν
  have ht : 0<min 1 ρ := lt_min zero_lt_one hρ
  have hd : (0 : ℝ)<d+1 := by positivity
  have he : 1/targetShrink ν d ρ=((d : ℝ)+1)*(radiusCap ν)⁻¹*(1/min 1 ρ) := by
    unfold targetShrink
    field_simp
  rw [he,Real.log_mul (mul_pos hd (inv_pos.mpr hc)).ne' (one_div_pos.mpr ht).ne',
    Real.log_mul hd.ne' (inv_pos.mpr hc).ne',Real.log_inv]
  have hl := Real.log_le_sub_one_of_pos hd
  have ha := neg_le_abs (Real.log (radiusCap ν))
  unfold targetLogBudget
  linarith

theorem targetCost_nonneg (ν : CoordinateLaw) (d C r : ℕ) {B ρ : ℝ} (hρ : 0<ρ) :
    0≤targetCost ν d C r B ρ := by
  have hE : 0≤teacherEnergyBound d C r B := by unfold teacherEnergyBound; positivity
  exact add_nonneg (mul_nonneg ν.upperCurvature_pos.le hE)
    (polynomialNoiseCost_nonneg ν d r C (by positivity) (targetLogBudget_nonneg ν d hρ))

/-- The actual strict uniform tube has an exponential lower bound at every
width N≥C and every scale Nσ²≤1. The displayed cost contains no inverse power
of the training tolerance. -/
theorem smallPrior_uniformTube_mass (ν : CoordinateLaw) {d C N r : ℕ}
    (hd : 0<d) (hC : 0<C) (hCN : C≤N) {B ρ σ : ℝ} (hB : 0≤B) (hρ : 0<ρ) (hσ : 0<σ)
    (teacher : Weights d C r) (hteacher : boundedWeights B teacher)
    (X : Set (RealInput d)) (hX : IsCompact X) (hball : ∀ x ∈ X, ∑ j, x j^2≤1)
    (hscale : (N : ℝ)*σ^2≤1) :
    Real.exp (-targetCost ν d C r B ρ/σ^2) ≤
      (smallPrior ν d N r σ).real (uniformTube Real.tanh (output Real.tanh teacher) X ρ) := by
  classical
  obtain ⟨k,hk,hgroup,hbelow,habove⟩ := exists_admissible_clone_group hC hCN
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  let v := clonedWeights e teacher
  let K := 2*teacherEnergyBound d C r B
  let q := targetShrink ν d ρ
  let ℓ := targetLogBudget ν d ρ
  let b := noiseBound ν d r C (2*K) ℓ
  let η := q*cylinderRadius d r (2*K) C (2*(b+C+1))
  let P := polynomialNoiseCost ν d r C (2*K) ℓ
  have hN : 0<N := hC.trans_le hCN
  have hE : 0≤teacherEnergyBound d C r B := by unfold teacherEnergyBound; positivity
  have hK : 0≤K := by dsimp [K]; positivity
  have hv : weightedSquaredNorm v≤K :=
    (weightedSquaredNorm_cloned_le hC hk hbelow habove e teacher).trans
      (mul_le_mul_of_nonneg_left (bounded_teacher_energy hC hB teacher hteacher) (by norm_num))
  have hq : 0<q := targetShrink_pos ν d hρ
  have hqcap : q≤radiusCap ν := targetShrink_le_cap ν d hρ
  have hℓ : 0≤ℓ := targetLogBudget_nonneg ν d hρ
  have hlogq : Real.log (1/q)≤ℓ := targetLogBudget_bound ν d hρ
  have hb : 0<b := noiseBound_pos ν d r C (by positivity) hℓ
  have hη : 0<η := mul_pos hq (cylinderRadius_pos d r (by positivity) (Nat.cast_nonneg C))
  have hηcap : η≤radiusCap ν := by
    apply le_trans _ hqcap
    exact (mul_le_mul_of_nonneg_left (cylinderRadius_le_one d r (by positivity) (Nat.cast_nonneg C)) hq.le).trans_eq (mul_one q)
  have hrad : ((d : ℝ)+1)*η ≤ ρ*cylinderRadius d r (2*K) C (2*(b+C+1)) := by
    have hc := radiusCap_le_one ν
    have ht := min_le_right 1 ρ
    have hprod : radiusCap ν*min 1 ρ≤ρ :=
      ((mul_le_mul_of_nonneg_right hc (lt_min zero_lt_one hρ).le).trans_eq (one_mul _)).trans ht
    have he : ((d : ℝ)+1)*η=radiusCap ν*min 1 ρ*cylinderRadius d r (2*K) C (2*(b+C+1)) := by
      dsimp only [η,q,targetShrink]
      field_simp
      <;> ring
    rw [he]
    exact mul_le_mul_of_nonneg_right hprod (cylinderRadius_pos d r (by positivity) (Nat.cast_nonneg C)).le
  have hcontain : ∀ z ∈ noiseCylinder d e η b r,
      translatedNoise v σ z ∈ uniformTube Real.tanh (output Real.tanh teacher) X ρ := by
    intro z hz x hx
    have hh := cylinder_output_error hd hN hk e teacher hK hb.le hσ.le hη.le
      (hηcap.trans (radiusCap_le_one ν)) hρ.le hscale hv hrad z hz x (hball x hx)
    rw [output_clonedWeights hk] at hh
    exact hh.trans_lt (by linarith)
  have hmass := smallPrior_translated_event_mass ν hd hN hσ (noiseCylinder d e η b r)
    (uniformTube Real.tanh (output Real.tanh teacher) X ρ)
    (measurable_noiseCylinder d e η b r) (noiseCylinder_neg d e η b r)
    ((isOpen_uniformTube tanh_continuous (continuous_output_input tanh_continuous teacher) X hX ρ).measurableSet)
    v hcontain
  have hprob := noiseCylinder_exp_lower ν d r hN hgroup e hη hηcap hb.le
    (matrixCylinder_tail_budget ν C hN hη (noiseBound_budget ν d r C (by positivity) hq hℓ hlogq))
  have hcost := networkCylinderCost_le_polynomial ν d r C (by positivity : 0≤2*K) hq hℓ hlogq
  have hP : 0≤P := polynomialNoiseCost_nonneg ν d r C (by positivity) hℓ
  have hprob' : Real.exp (-(N : ℝ)*P)≤(rawPrior ν d N r).real (noiseCylinder d e η b r) :=
    (Real.exp_le_exp.mpr (by nlinarith [mul_le_mul_of_nonneg_left hcost (Nat.cast_nonneg N : (0 : ℝ)≤N)])).trans hprob
  have hNle : (N : ℝ)≤1/σ^2 := (le_div_iff₀ (sq_pos_of_pos hσ)).mpr hscale
  have hexp : Real.exp (-targetCost ν d C r B ρ/σ^2)≤
      Real.exp (-(N : ℝ)*P)*Real.exp (-(ν.upperCurvature/2*weightedSquaredNorm v/σ^2)) := by
    rw [←Real.exp_add]
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_right hNle hP
    have he := mul_le_mul_of_nonneg_left hv (div_nonneg ν.upperCurvature_pos.le (by norm_num : (0 : ℝ)≤2))
    have he' := div_le_div_of_nonneg_right he (sq_nonneg σ)
    have hcostEq : targetCost ν d C r B ρ=ν.upperCurvature*teacherEnergyBound d C r B+P := by
      unfold targetCost
      dsimp only [P,K,ℓ]
      congr 2
      ring
    rw [hcostEq]
    dsimp only [K] at he'
    simp only [neg_div,neg_mul] at *
    rw [add_div]
    ring_nf at hh he' ⊢
    linarith
  exact hexp.trans ((mul_le_mul_of_nonneg_right hprob' (Real.exp_nonneg _)).trans hmass)

end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
