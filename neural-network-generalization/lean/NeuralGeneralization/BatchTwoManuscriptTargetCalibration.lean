import NeuralGeneralization.BatchTwoOnlineBalancedContainment

/-! Exact squared calibration, avoiding an unnecessary square-root relaxation. -/
noncomputable section
set_option autoImplicit false
namespace NeuralGeneralization.BatchTwoManuscriptTarget
open ConcreteModel BatchTwoMerging BatchTwoOnlineBalanced
variable {d C N r : ℕ} {k : Fin C→ℕ}

theorem grouped_robustRadius_le_sq (w : Weights d N r) {a c τ : ℝ}
    (hτ : 0≤τ) (henergy : a^2*(C:ℝ)/8≤readoutEnergy w)
    (hcal : 8*c^2≤τ^2*a^2*(C:ℝ)) : robustRadius c w≤τ := by
  have he := readoutEnergy_nonneg w
  have hp : 0<1+((r:ℝ)+1)*readoutEnergy w := by positivity
  have hmul := mul_le_mul_of_nonneg_left henergy (sq_nonneg τ)
  have hr := mul_nonneg (Nat.cast_nonneg r : (0:ℝ)≤r) he
  have hm := mul_le_mul_of_nonneg_left hr (sq_nonneg τ)
  have hs := Real.sq_sqrt hp.le
  have ht : 0≤τ*Real.sqrt (1+((r:ℝ)+1)*readoutEnergy w) := by positivity
  have hc : c≤τ*Real.sqrt (1+((r:ℝ)+1)*readoutEnergy w) := by
    nlinarith only [hcal,hmul,hm,hs,sq_nonneg τ,ht]
  exact (div_le_iff₀ (Real.sqrt_pos.mpr hp)).mpr hc

variable {B : LayeredBooleanCircuit d C r}
  {e : (Σb : Fin C,Fin (k b))≃Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

theorem grouped_conditions_robust_and_target_sq
    (H : GroupedCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0<N) (hk : ∀b,0<k b) (hwidth : ∀b,N≤2*C*k b) (hwidth' : ∀b,C*k b≤2*N)
    {c : ℝ} (hc : 0<c) (hcal : 8*c^2≤τ^2*a^2*(C:ℝ)) :
    w∈robustEvent Real.tanh c ∩ marginEvent Real.tanh 1 B.computes := by
  have hC : 0<C := Nat.pos_of_ne_zero (fun hz=>by simpa [hz] using B.constant.isLt)
  have henergy := grouped_perturbed_readout_lower B e hN hC hk hwidth hwidth' w
    H.readout_nonneg H.radius_nonneg H.readout_radius H.readout_error
  have hr := grouped_robustRadius_le_sq w H.noise_nonneg henergy hcal
  have hr0 := (robustRadius_pos hc w).le
  have hball (η : NetworkDisturbance N r)
      (hη : noiseBudgetSq η≤(robustRadius c w)^2) : noiseBudgetSq η≤τ^2 :=
    hη.trans ((sq_le_sq₀ hr0 H.noise_nonneg).mpr hr)
  constructor
  · apply mem_robustEvent_of_uniform_noisy_margin Real.tanh c w B.computes
    intro x η hη
    exact le_of_lt (lt_trans (by norm_num : (1/2:ℝ)<1)
      (H.noisy_margin hN hk hwidth x η (hball η hη)))
  · intro x
    have hh := H.noisy_margin hN hk hwidth x 0 (by simp only [noiseBudgetSq_zero]; positivity)
    simpa only [noisyNetworkOutput_zero] using hh

end NeuralGeneralization.BatchTwoManuscriptTarget
