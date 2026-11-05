import NeuralGeneralization.RobustTargetAllWidths

/-! Actual all-width Gaussian target mass for arbitrary nonnegative training
margins. The readout coefficient grows polynomially with the margin. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.GeneralMargin
open ConcreteModel
variable {d C N r : ℕ}

def uniformNoisyMargin (m c : ℝ) (f : BooleanFunction d) : Set (Weights d N r) :=
  {w | ∀ x : Cube d,∀ η : NetworkDisturbance N r,
    noiseBudgetSq η ≤ (robustRadius c w)^2 →
      m < labelReal (f x)*noisyNetworkOutput Real.tanh w x η}

theorem uniform_noisy_margin_target_mass {m : ℝ} (hm : 0 ≤ m) (hd : 0 < d)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r (c+m+1)/σ^2) ≤
      (smallPrior d N r σ).real
        (uniformNoisyMargin m c B.computes) := by
  classical
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN : 0 < N := lt_of_lt_of_le hC hCN
  let k := N/C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hmod : N%C < C := Nat.mod_lt _ hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hbelow : C*k ≤ N := by omega
  have hCk : C ≤ C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have hwidth : N ≤ 2*C*k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N :=
    Fintype.equivOfCardEq (by
      simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
      omega)
  obtain ⟨b,J,hJ,hrows,hideal⟩ := exists_adapted_saturated_clone B e
    (digitalGain C r) (digitalReadout C (c+m+1))
  have ha : 0 ≤ digitalReadout C (c+m+1) := le_trans (by norm_num) (digitalReadout_ge_four C (by linarith))
  have hteacher := B.saturatedClone_energy_le e hN hk hwidth (digitalGain_pos C r).le ha
  change weightedSquaredNorm (B.saturatedClone e (digitalGain C r) (digitalReadout C (c+m+1))) ≤
    digitalTeacherCost d C r (c+m+1) at hteacher
  have hcal : 2*c ≤ digitalNoise C*digitalReadout C (c+m+1) := by
    have hh := digital_calibration_bound C (show 0 ≤ c+m+1 by linarith)
    linarith
  have hmargin : m < 15*digitalReadout C (c+m+1)/16-
      2*digitalCylinderRadius d C-digitalNoise C := by
    have he := digitalError_le C
    have hr := digitalRadius_le_error d C
    have hlarge : 4+4096*m ≤ digitalReadout C (c+m+1) := by
      unfold digitalReadout
      have hC := Nat.cast_nonneg (α := ℝ) C
      nlinarith [mul_nonneg (show 0 ≤ c+m+1 by linarith) hC]
    unfold digitalNoise
    linarith
  have hcontain : robustCoordinateCylinder
      (B.saturatedClone e (digitalGain C r) (digitalReadout C (c+m+1))) b J
      (digitalCylinderRadius d C) σ ⊆ uniformNoisyMargin m c B.computes := by
    intro w hw
    obtain ⟨H⟩ := robustCoordinateCylinder_conditions hd hN hk hwidth B e b J
      (digitalGain_pos C r) ha (digitalError_pos C).le (digitalError_le_one C)
      (digitalNoise_pos C).le (digitalCylinderRadius_pos d C).le
      (digitalRadius_le_half_readout d C (show 0 ≤ c+m+1 by linarith)) (digitalRadius_input_bound d C r)
      (digital_group_error C) (digital_first_contraction C r)
      (digital_internal_contraction d C r) (digital_noisy_readout_margin d C (show 0 ≤ c+m+1 by linarith))
      hc hcal hσ hscale hJ hrows hideal w hw
    intro x η hη
    exact hmargin.trans_le (H.calibrated_noisy_margin_lower hN hk hwidth hc hcal x η hη)
  have hm := robustCoordinateCylinder_mass hd hN
    (B.saturatedClone e (digitalGain C r) (digitalReadout C (c+m+1))) b J
    (digitalCylinderRadius_pos d C) hσ hscale
    (show (J.card:ℝ) ≤ (C:ℝ)+1 by exact_mod_cast hJ) hteacher
  apply le_trans _ (hm.trans (measureReal_mono hcontain))
  apply Real.exp_le_exp.mpr
  have hh := div_le_div_of_nonneg_right (digitalCylinderCost_le_massPolynomial d C r (c+m+1))
    (sq_nonneg σ)
  simpa only [neg_div] using neg_le_neg hh

end NeuralGeneralization.GeneralMargin
