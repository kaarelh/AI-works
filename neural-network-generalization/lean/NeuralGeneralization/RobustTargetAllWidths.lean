import NeuralGeneralization.RobustTargetGeometry
import NeuralGeneralization.RobustTargetParameterFacts
import NeuralGeneralization.RobustTargetCost

/-!
# Fully constructive robust Boolean target mass at every width

The final theorems quantify over the actual Gaussian neural-network law,
the exact finite-noise support restriction, and a concrete NAND/copy/NOT
circuit. No teacher, cylinder, robustness, probability, or containment
hypothesis is supplied by the caller. The exponent cost is an explicit
universal polynomial in input dimension, circuit width, depth, and calibration.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.ConcreteModel
variable {d C N r : ℕ}

theorem digitalCylinderCost_le_massPolynomial (d C r : ℕ) (c : ℝ) :
    robustCylinderCost d r (digitalTeacherCost d C r c) ((C:ℝ)+1)
      (digitalCylinderRadius d C) ≤ digitalMassPolynomial d C r c := by
  have hh := robustCylinderCost_le_polynomial (d:=d) (r:=r) (K:=digitalTeacherCost d C r c)
    (G:=(C:ℝ)+1) (R:=4096*((d:ℝ)+1)*((C:ℝ)+1)^2)
    (by positivity) (digitalCylinderRadius_pos d C) (digitalRadius_le_one d C)
    (by simpa only [one_div] using (digitalRadius_inv d C).le)
  convert hh using 1
  unfold digitalMassPolynomial
  ring

/-- Actual robust target mass for every integer `N ≥ C` and every common
whitened Gaussian scale `σ` with `N σ² ≤ 1`. -/
theorem robust_boolean_target_mass (hd : 0 < d)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real
        (robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes) := by
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
  have hcontain := robustCoordinateCylinder_containment hd hN hk hwidth B e b J
    (digitalGain_pos C r) ha (digitalError_pos C).le (digitalError_le_one C)
    (digitalNoise_pos C).le (digitalCylinderRadius_pos d C).le
    (digitalRadius_le_half_readout d C hc.le) (digitalRadius_input_bound d C r)
    (digital_group_error C) (digital_first_contraction C r)
    (digital_internal_contraction d C r) (digital_noisy_readout_margin d C hc.le)
    hc (digital_calibration_bound C hc.le) hσ hscale hJ hrows hideal
  have hm := robust_target_mass_of_cylinder_containment hd hN
    (B.saturatedClone e (digitalGain C r) (digitalReadout C c)) b J
    (digitalCylinderRadius_pos d C) hσ hscale
    (show (J.card:ℝ) ≤ (C:ℝ)+1 by exact_mod_cast hJ) hteacher B.computes hcontain
  apply le_trans _ hm
  apply Real.exp_le_exp.mpr
  have hh := div_le_div_of_nonneg_right (digitalCylinderCost_le_massPolynomial d C r c)
    (sq_nonneg σ)
  simpa only [neg_div] using neg_le_neg hh

/-- The same mass lower bound survives the original all-input absolute
margin condition: the constructed cylinder already lies in that event. -/
theorem robust_boolean_target_mass_with_global_margin (hd : 0 < d)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real
        ((robustEvent Real.tanh c ∩ globalMarginEvent Real.tanh (1/2)) ∩
          marginEvent Real.tanh (1/2) B.computes) := by
  have hsub : robustEvent (N:=N) (r:=r) Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes ⊆
      ((robustEvent Real.tanh c ∩ globalMarginEvent Real.tanh (1/2)) ∩
        marginEvent Real.tanh (1/2) B.computes) := by
    intro w hw
    exact ⟨⟨hw.1,marginEvent_subset_global Real.tanh (1/2) B.computes hw.2⟩,hw.2⟩
  exact (robust_boolean_target_mass hd B hCN hc hσ hscale).trans
    (measureReal_mono hsub (measure_ne_top _ _))

/-- Restatement in the manuscript's scale `t`: input variance `t²/d`,
internal variance `t²/N`, and readout variance `t²/N²`. -/
theorem robust_boolean_target_mass_scale (hd : 0 < d)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c t : ℝ} (hc : 0 < c) (ht : 0 < t) (ht1 : t ≤ 1) :
    Real.exp (-(N:ℝ)*digitalMassPolynomial d C r c/t^2) ≤
      (smallPrior d N r (t/Real.sqrt N)).real
        (robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes) := by
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN : 0 < N := lt_of_lt_of_le hC hCN
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hsqrt : 0 < Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hNR
  have hσ : 0 < t/Real.sqrt (N:ℝ) := div_pos ht hsqrt
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2 ≤ 1 := by
    rw [div_pow,Real.sq_sqrt hNR.le]
    have heq : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [heq]
    nlinarith
  have hh := robust_boolean_target_mass hd B hCN hc hσ hscale
  have heq : -digitalMassPolynomial d C r c/(t/Real.sqrt (N:ℝ))^2 =
      -(N:ℝ)*digitalMassPolynomial d C r c/t^2 := by
    rw [div_pow,Real.sq_sqrt hNR.le]
    field_simp
  simpa only [heq] using hh

end NeuralGeneralization.ConcreteModel
