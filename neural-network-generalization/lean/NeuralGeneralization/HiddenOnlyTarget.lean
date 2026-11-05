import NeuralGeneralization.HiddenOnlySupport
import NeuralGeneralization.RobustTargetNoisyMargin

/-! The same digital cylinder satisfies the larger hidden-only calibrated
ball. Its raw Gaussian mass polynomial is unchanged. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel
variable {d C N r k p : ℕ}

lemma radius_le_of_readoutEnergy (w : Weights d N r)
    {a c τ : ℝ} (ha : 0 < a) (hτ : 0 ≤ τ)
    (henergy : a^2/4 ≤ readoutEnergy w) (hcal : 2*c ≤ τ*a) : radius c w ≤ τ := by
  have he : 0 < readoutEnergy w := (by positivity : (0:ℝ)<a^2/4).trans_le henergy
  have hpos : 0 < ((r:ℝ)+1)*readoutEnergy w := by positivity
  have hs : a/2 ≤ Real.sqrt (((r:ℝ)+1)*readoutEnergy w) := by
    apply (Real.le_sqrt (by positivity) hpos.le).mpr
    have hr : 0 ≤ (r:ℝ)*readoutEnergy w := mul_nonneg (Nat.cast_nonneg r) he.le
    nlinarith
  unfold radius
  apply (div_le_iff₀ (Real.sqrt_pos.mpr hpos)).mpr
  nlinarith [mul_le_mul_of_nonneg_left hs hτ]

lemma conditions_support {B : LayeredBooleanCircuit d C r}
    {e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N} {w : Weights d N r}
    {A a ε τ ρ G β c : ℝ}
    (H : DigitalCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    (hc : 0 < c) (hcal : 2*c ≤ τ*a) :
    w ∈ support Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
  have ha : 0 < a := by
    by_contra hn
    have hh := mul_nonpos_of_nonneg_of_nonpos H.noise_nonneg (le_of_not_gt hn)
    linarith
  have henergy := readoutEnergy_lower_of_sum hN w (B.saturatedClone e A a)
    H.radius_nonneg H.readout_radius (B.saturatedClone_sum_readout e hk A a) H.readout_error
  have he : 0 < readoutEnergy w := (by positivity : (0:ℝ)<a^2/4).trans_le henergy
  have hr := radius_le_of_readoutEnergy w ha H.noise_nonneg henergy hcal
  have hr0 := (radius_pos hc he).le
  have hclean (x : Cube d) : (1/2:ℝ) < labelReal (B.computes x)*networkOutput Real.tanh w x := by
    have hh := H.noisy_margin hN hk hwidth x 0 (by simp only [noiseBudgetSq_zero]; positivity)
    rw [noisyNetworkOutput_zero] at hh
    linarith
  refine ⟨fun x => Or.inr ?_,hclean⟩
  intro η hη _
  have hnoise : noiseBudgetSq η ≤ τ^2 := hη.trans ((sq_le_sq₀ hr0 H.noise_nonneg).mpr hr)
  have hm := H.noisy_margin hN hk hwidth x η hnoise
  rw [clippedScore_eq_label_of_margin (B.computes x) _ (by linarith),
    clippedScore_eq_label_of_margin (B.computes x) _ (hclean x).le,sub_self,abs_zero]
  norm_num

/-- The original all-width Gaussian target-mass bound for hidden-only support. -/
theorem target_mass (hd : 0 < d)
    (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real
        (support Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes) := by
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
  have hconditions := robustCoordinateCylinder_conditions hd hN hk hwidth B e b J
    (digitalGain_pos C r) ha (digitalError_pos C).le (digitalError_le_one C)
    (digitalNoise_pos C).le (digitalCylinderRadius_pos d C).le
    (digitalRadius_le_half_readout d C hc.le) (digitalRadius_input_bound d C r)
    (digital_group_error C) (digital_first_contraction C r)
    (digital_internal_contraction d C r) (digital_noisy_readout_margin d C hc.le)
    hc (digital_calibration_bound C hc.le) hσ hscale hJ hrows hideal
  have hcontain : robustCoordinateCylinder
      (B.saturatedClone e (digitalGain C r) (digitalReadout C c)) b J
      (digitalCylinderRadius d C) σ ⊆
      support Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
    intro w hw
    obtain ⟨H⟩ := hconditions w hw
    exact conditions_support H hN hk hwidth hc (digital_calibration_bound C hc.le)
  have hm := robustCoordinateCylinder_mass hd hN
    (B.saturatedClone e (digitalGain C r) (digitalReadout C c)) b J
    (digitalCylinderRadius_pos d C) hσ hscale
    (show (J.card:ℝ) ≤ (C:ℝ)+1 by exact_mod_cast hJ) hteacher
  apply le_trans _ (hm.trans (measureReal_mono hcontain))
  apply Real.exp_le_exp.mpr
  have hh := div_le_div_of_nonneg_right (digitalCylinderCost_le_massPolynomial d C r c)
    (sq_nonneg σ)
  simpa only [neg_div] using neg_le_neg hh


end NeuralGeneralization.HiddenOnly
