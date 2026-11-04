import NeuralGeneralization.RobustTargetAllWidths

/-! The original all-width target-mass polynomial for the stronger event
that every calibrated noisy output has correct signed raw margin above one. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.ConcreteModel
variable {d C N r : ℕ}

def uniformNoisyMargin (c : ℝ) (f : BooleanFunction d) : Set (Weights d N r) :=
  {w | ∀ x : Cube d,∀ η : NetworkDisturbance N r,
    noiseBudgetSq η ≤ (robustRadius c w)^2 →
      1 < labelReal (f x)*noisyNetworkOutput Real.tanh w x η}

theorem uniform_noisy_margin_target_mass (hd : 0 < d)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real
        (uniformNoisyMargin c B.computes) := by
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
    (digitalGain C r) (digitalReadout C c)
  have ha : 0 ≤ digitalReadout C c := le_trans (by norm_num) (digitalReadout_ge_four C hc.le)
  have hteacher := B.saturatedClone_energy_le e hN hk hwidth (digitalGain_pos C r).le ha
  change weightedSquaredNorm (B.saturatedClone e (digitalGain C r) (digitalReadout C c)) ≤
    digitalTeacherCost d C r c at hteacher
  have hcontain := robustCoordinateCylinder_noisy_margin hd hN hk hwidth B e b J
    (digitalGain_pos C r) ha (digitalError_pos C).le (digitalError_le_one C)
    (digitalNoise_pos C).le (digitalCylinderRadius_pos d C).le
    (digitalRadius_le_half_readout d C hc.le) (digitalRadius_input_bound d C r)
    (digital_group_error C) (digital_first_contraction C r)
    (digital_internal_contraction d C r) (digital_noisy_readout_margin d C hc.le)
    hc (digital_calibration_bound C hc.le) hσ hscale hJ hrows hideal
  have hm := robustCoordinateCylinder_mass hd hN
    (B.saturatedClone e (digitalGain C r) (digitalReadout C c)) b J
    (digitalCylinderRadius_pos d C) hσ hscale
    (show (J.card:ℝ) ≤ (C:ℝ)+1 by exact_mod_cast hJ) hteacher
  apply le_trans _ (hm.trans (measureReal_mono hcontain))
  apply Real.exp_le_exp.mpr
  have hh := div_le_div_of_nonneg_right (digitalCylinderCost_le_massPolynomial d C r c)
    (sq_nonneg σ)
  simpa only [neg_div] using neg_le_neg hh

end NeuralGeneralization.ConcreteModel
