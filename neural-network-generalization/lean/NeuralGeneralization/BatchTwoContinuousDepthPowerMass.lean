import NeuralGeneralization.BatchTwoContinuousFiniteTargetMass
import NeuralGeneralization.BatchTwoNonGaussianGaussianPrior
import NeuralGeneralization.BatchTwoContinuousDepthPowerBudget

/-! Sharp translated-cylinder denominator. Unlike a rate-only estimate, this
retains the Gaussian energy coefficient one half and the lower-order N cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoContinuous.FiniteTarget BatchTwoNonGaussian

/-- Cloning preserves internal energy. Only the readout can cost an extra copy. -/
theorem cloned_energy_add_readout {d C N r k p : ℕ} (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    weightedSquaredNorm (clonedWeights e w) ≤ weightedSquaredNorm w+
      (C : ℝ)*∑ i, w (Sum.inr (Sum.inr i))^2 := by
  have hN : 0<N := (Nat.mul_pos hC hk).trans_le hbelow
  have hCR : (0 : ℝ)<C := by exact_mod_cast hC
  have hkR : (0 : ℝ)<k := by exact_mod_cast hk
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have hbelowR : (C : ℝ)*k≤N := by exact_mod_cast hbelow
  have haboveR : (N : ℝ)≤2*C*k := by exact_mod_cast habove
  have hf : (d : ℝ)*k/N≤(d : ℝ)/C := by
    apply (div_le_div_iff₀ hNR hCR).2
    nlinarith [mul_le_mul_of_nonneg_left hbelowR (Nat.cast_nonneg d : (0 : ℝ)≤d)]
  have ho : (N : ℝ)/k≤2*C := (div_le_iff₀ hkR).2 haboveR
  rw [weightedSquaredNorm_cloned hk]
  unfold weightedSquaredNorm
  have hfirst : 0≤∑ i : Fin C, ∑ j : Fin (d+1), w (Sum.inl (i,j))^2 := by positivity
  have hout : 0≤∑ i : Fin C, w (Sum.inr (Sum.inr i))^2 := by positivity
  nlinarith [mul_le_mul_of_nonneg_right hf hfirst,mul_le_mul_of_nonneg_right ho hout]

def sharpNoiseCost (ν : CoordinateLaw) (d C r : ℕ) (K ρ : ℝ) : ℝ :=
  powerPolynomialNoiseCost ν d r C (2*K) (targetLogBudget ν d ρ)

/-- No weightwise teacher bound or change in the energy coefficient is used. -/
theorem coordinate_uniformTube_sharp_mass (ν : CoordinateLaw) {d C N r : ℕ}
    (hd : 0<d) (hC : 0<C) (hCN : C≤N) {K ρ σ : ℝ} (hK : 0≤K)
    (hρ : 0<ρ) (hσ : 0<σ) (teacher : Weights d C r)
    (henergy : weightedSquaredNorm teacher+
      (C : ℝ)*∑ i, teacher (Sum.inr (Sum.inr i))^2≤K)
    (X : Set (RealInput d)) (hX : IsCompact X) (hball : ∀ x ∈ X, ∑ j, x j^2≤1)
    (hscale : (N : ℝ)*σ^2≤1) :
    Real.exp (-(ν.upperCurvature/2*K/σ^2)-(N : ℝ)*sharpNoiseCost ν d C r K ρ) ≤
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real
        (uniformTube Real.tanh (output Real.tanh teacher) X ρ) := by
  classical
  obtain ⟨k,hk,hgroup,hbelow,habove⟩ := exists_admissible_clone_group hC hCN
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  let v := clonedWeights e teacher
  let q := targetShrink ν d ρ
  let ℓ := targetLogBudget ν d ρ
  let b := powerNoiseBound ν d r C (2*K) ℓ
  let η := q*cylinderRadius d r (2*K) C (2*(b+C+1))
  let P := sharpNoiseCost ν d C r K ρ
  have hN : 0<N := hC.trans_le hCN
  have hv : weightedSquaredNorm v≤K := (cloned_energy_add_readout hC hk hbelow habove e teacher).trans henergy
  have hq : 0<q := targetShrink_pos ν d hρ
  have hqcap : q≤radiusCap ν := targetShrink_le_cap ν d hρ
  have hℓ : 0≤ℓ := targetLogBudget_nonneg ν d hρ
  have hlogq : Real.log (1/q)≤ℓ := targetLogBudget_bound ν d hρ
  have hb : 0<b := powerNoiseBound_pos ν d r C (by positivity) hℓ
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
    (matrixCylinder_tail_budget ν C hN hη (powerNoiseBound_budget ν d r C (by positivity) hq hℓ hlogq))
  have hcost := networkCylinderCost_le_powerPolynomial ν d r C (by positivity : 0≤2*K) hq hℓ hlogq
  change networkCylinderCost ν d C r η≤P at hcost
  have hprob' : Real.exp (-(N : ℝ)*P)≤(rawPrior ν d N r).real (noiseCylinder d e η b r) :=
    (Real.exp_le_exp.mpr (by nlinarith [mul_le_mul_of_nonneg_left hcost (Nat.cast_nonneg N : (0 : ℝ)≤N)])).trans hprob
  have henergy' : ν.upperCurvature/2*weightedSquaredNorm v/σ^2≤ν.upperCurvature/2*K/σ^2 :=
    div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hv (div_nonneg ν.upperCurvature_pos.le (by norm_num))) (sq_nonneg σ)
  calc
    Real.exp (-(ν.upperCurvature/2*K/σ^2)-(N : ℝ)*P) ≤
        Real.exp (-(N : ℝ)*P)*Real.exp (-(ν.upperCurvature/2*weightedSquaredNorm v/σ^2)) := by
      rw [←Real.exp_add]
      apply Real.exp_le_exp.mpr
      linarith
    _ ≤ _ := (mul_le_mul_of_nonneg_right hprob' (Real.exp_nonneg _)).trans hmass

/-- The original Gaussian learner retains the sharp 1/(2σ²) energy rate. -/
theorem gaussian_uniformTube_sharp_mass {d C N r : ℕ}
    (hd : 0<d) (hC : 0<C) (hCN : C≤N) {K ρ σ : ℝ} (hK : 0≤K)
    (hρ : 0<ρ) (hσ : 0<σ) (teacher : Weights d C r)
    (henergy : weightedSquaredNorm teacher+
      (C : ℝ)*∑ i, teacher (Sum.inr (Sum.inr i))^2≤K)
    (X : Set (RealInput d)) (hX : IsCompact X) (hball : ∀ x ∈ X, ∑ j, x j^2≤1)
    (hscale : (N : ℝ)*σ^2≤1) :
    Real.exp (-K/(2*σ^2)-(N : ℝ)*sharpNoiseCost standardGaussian d C r K ρ) ≤
      (ConcreteModel.smallPrior d N r σ).real
        (uniformTube Real.tanh (output Real.tanh teacher) X ρ) := by
  have hh := coordinate_uniformTube_sharp_mass standardGaussian hd hC hCN hK hρ hσ
    teacher henergy X hX hball hscale
  rw [standardGaussian_smallPrior hd (hC.trans_le hCN)] at hh
  convert hh using 1 <;> dsimp [standardGaussian] <;> congr 2 <;> ring

/-- The same sharp denominator for an actual finite interpolation event. -/
theorem gaussian_training_sharp_mass {d C N r n : ℕ}
    (hd : 0<d) (hC : 0<C) (hCN : C≤N) {K ρ σ : ℝ} (hK : 0≤K)
    (hρ : 0<ρ) (hσ : 0<σ) (teacher : Weights d C r)
    (henergy : weightedSquaredNorm teacher+
      (C : ℝ)*∑ i, teacher (Sum.inr (Sum.inr i))^2≤K)
    (f : RealInput d → ℝ) (s : Fin n → RealInput d)
    (hfit : ∀ i, output Real.tanh teacher (s i)=f (s i))
    (hball : ∀ i, ∑ j, s i j^2≤1) (hscale : (N : ℝ)*σ^2≤1) :
    Real.exp (-K/(2*σ^2)-(N : ℝ)*sharpNoiseCost standardGaussian d C r K ρ) ≤
      (ConcreteModel.smallPrior d N r σ).real (trainingEvent Real.tanh f ρ s) := by
  have hh := gaussian_uniformTube_sharp_mass hd hC hCN hK hρ hσ teacher henergy
    (Set.range s) (Set.finite_range s).isCompact (by rintro x ⟨i,rfl⟩; exact hball i) hscale
  apply hh.trans
  apply measureReal_mono ?_ (measure_ne_top _ _)
  intro w hw i
  have hi := hw (s i) (Set.mem_range_self i)
  simpa only [hfit i] using hi

end NeuralGeneralization.BatchTwoContinuousDepthPower
