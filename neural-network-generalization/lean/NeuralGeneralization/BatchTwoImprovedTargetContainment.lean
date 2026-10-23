import NeuralGeneralization.BatchTwoImprovedTargetEnergy
import NeuralGeneralization.RobustCircuitContainment

/-! Exact finite-disturbance robustness with exponential gate saturation. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p:ℕ}

theorem saturated_readoutEnergy_lower (hN:0<N) (hC:0<C) (hk:0<k) (hbelow:C*k≤N)
    (B:LayeredBooleanCircuit d C r) (e:((Fin C×Fin k)⊕Fin p)≃Fin N)
    (w:Weights d N r) {A a ρ:ℝ} (ha:0≤a) (hρ:0≤ρ) (hρa:ρ≤a/2)
    (herr:∀i,|w (.inr (.inr i))-B.saturatedClone e A a (.inr (.inr i))|≤ρ/N):
    a^2*C/4≤readoutEnergy w := by
  have hkr:(0:ℝ)<k := by exact_mod_cast hk
  have hC1:(1:ℝ)≤C := by exact_mod_cast hC
  have hb:(C:ℝ)*k≤N := by exact_mod_cast hbelow
  have hv:a^2*C≤readoutEnergy (B.saturatedClone e A a) := by
    rw [B.saturatedClone_readout_energy_eq e hk A a]
    apply (le_div_iff₀ hkr).mpr
    have hh:=mul_le_mul_of_nonneg_right hb (sq_nonneg a)
    nlinarith
  have he:=NeuralGeneralization.BatchTwoMerging.readoutEnergy_compare_of_coordinate_error hN w
    (B.saturatedClone e A a) hρ herr
  have hρsq:ρ^2≤a^2/4 := by nlinarith
  have hCa:=mul_le_mul_of_nonneg_right hC1 (sq_nonneg a)
  nlinarith

theorem robustRadius_le_of_width_readoutEnergy (w:Weights d N r) {a c τ:ℝ}
    (ha:0≤a) (hτ:0≤τ) (henergy:a^2*C/4≤readoutEnergy w)
    (hcal:2*c≤τ*a*Real.sqrt C):robustRadius c w≤τ := by
  have hpos:0<1+((r:ℝ)+1)*readoutEnergy w := by
    have hh:=readoutEnergy_nonneg w
    positivity
  have hs:a*Real.sqrt C/2≤Real.sqrt (1+((r:ℝ)+1)*readoutEnergy w) := by
    apply (Real.le_sqrt (by positivity) hpos.le).mpr
    have hh:=readoutEnergy_nonneg w
    have hr:0≤(r:ℝ)*readoutEnergy w := mul_nonneg (Nat.cast_nonneg r) hh
    have hc:=Real.sq_sqrt (Nat.cast_nonneg C : (0:ℝ)≤C)
    nlinarith
  unfold robustRadius
  apply (div_le_iff₀ (Real.sqrt_pos.mpr hpos)).mpr
  have hh:=mul_le_mul_of_nonneg_left hs hτ
  nlinarith

structure ExponentialCylinderConditions (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d N r)
    (A a ε τ ρ G β : ℝ) where
  R : Fin r → Fin N → Fin N → ℝ
  E : Fin r → Fin N → Fin N → ℝ
  gain_pos : 0 < A
  readout_nonneg : 0 ≤ a
  error_nonneg : 0 ≤ ε
  error_le_one : ε ≤ 1
  noise_nonneg : 0 ≤ τ
  radius_nonneg : 0 ≤ ρ
  readout_radius : ρ ≤ a/2
  first_error : ∀ i j, |w (.inl (i,j))-B.saturatedClone e A a (.inl (i,j))| ≤ ρ
  first_small : ((d:ℝ)+1)*ρ ≤ A/2
  readout_error : ∀ i, |w (.inr (.inr i))-B.saturatedClone e A a (.inr (.inr i))| ≤ ρ/(N:ℝ)
  decomp : ∀ s i j,w (.inr (.inl (s,i,j)))=
    B.saturatedClone e A a (.inr (.inl (s,i,j)))+R s i j+E s i j
  projected_bound : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G
  free_bound : ∀ s,matrixActionBound (E s) β
  free_kills : ∀ (b : Fin C → Bool) s i,(∑ j,E s i j*saturatedCloneBits e b j)=0
  group_small : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2
  init_bound : 3*((2*Real.exp (-A/2))^2+τ^2) ≤ ε^2
  step_bound : 3*((2*Real.exp (-A/2))^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2) ≤ ε^2
  output_margin : 1 < 15*a/16-2*ρ-τ

namespace ExponentialCylinderConditions

variable {B : LayeredBooleanCircuit d C r}
  {e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

theorem noisy_final_error (H : ExponentialCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    (x : Cube d) (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ τ^2) :
    (∑ i,(noisyFinalHidden Real.tanh w x η i-saturatedCloneBits e (B.finalBits x) i)^2) ≤
      (N:ℝ)*ε^2 := by
  have hfold (ss : List (Fin r)) (h : Fin N → ℝ) (b : Fin C → Bool)
      (hc : b B.constant = true)
      (hh : (∑ i,(h i-saturatedCloneBits e b i)^2) ≤ (N:ℝ)*ε^2) :
      (∑ i,(ss.foldl (noisyHiddenStep Real.tanh w η) h i-
        saturatedCloneBits e (ss.foldl B.stepBits b) i)^2) ≤ (N:ℝ)*ε^2 := by
    induction ss generalizing h b with
    | nil => exact hh
    | cons s ss ih =>
      apply ih
      · simpa only [LayeredBooleanCircuit.stepBits_constant] using hc
      · exact B.internal_noisy_state_error_exp e hk hwidth w H.R H.E H.gain_pos H.decomp
          H.projected_bound H.free_bound H.group_small H.step_bound h b hc hh s η
          (noiseBudgetSq_hidden hN η hη s.succ) (H.free_kills b s)
  exact hfold (List.finRange r) (noisyFirstHidden Real.tanh w x η) (B.firstBits x)
    (B.firstBits_constant x)
    (B.first_noisy_state_error_exp e w H.gain_pos H.radius_nonneg H.first_error H.first_small
      H.init_bound x η (noiseBudgetSq_hidden hN η hη 0))

end ExponentialCylinderConditions

namespace ExponentialCylinderConditions
variable {B : LayeredBooleanCircuit d C r}
  {e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

/-- Every allowed perturbation retains a strict signed raw margin greater
than one, uniformly over all inputs. -/
theorem noisy_margin (H : ExponentialCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    (x : Cube d) (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ τ^2) :
    1 < labelReal (B.computes x)*noisyNetworkOutput Real.tanh w x η := by
  let h := noisyFinalHidden Real.tanh w x η
  have hstate := H.noisy_final_error hN hk hwidth x η hη
  have hnorm : (∑ i,h i^2) ≤ 4*(N:ℝ) := squared_norm_le_of_boolean_error h
    (saturatedCloneBits e (B.finalBits x)) H.error_nonneg H.error_le_one
    (fun i => (abs_saturatedCloneBits e (B.finalBits x) i).le) hstate
  have hdiff := readout_coordinate_error_rms hN w (B.saturatedClone e A a) H.radius_nonneg
    H.readout_error h hnorm
  have hout := noiseBudgetSq_output η H.noise_nonneg hη
  have hmean := cloneMean_error_le hk hwidth e h (B.finalBits x) (by norm_num)
    H.group_small hstate B.output
  have hteacher : 15*a/16 ≤ labelReal (B.computes x) *
      (∑ i,B.saturatedClone e A a (.inr (.inr i))*h i) := by
    rw [B.saturatedClone_readout_eq e A a h]
    change 15*a/16 ≤ labelReal (B.finalBits x B.output)*(a*cloneMean e h B.output)
    have hmean' := abs_le.mp hmean
    cases hb : B.finalBits x B.output <;>
      simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hmean' ⊢ <;>
      nlinarith [H.readout_nonneg]
  have he : |noisyNetworkOutput Real.tanh w x η-
      (∑ i,B.saturatedClone e A a (.inr (.inr i))*h i)| ≤ 2*ρ+τ := by
    have hh := abs_add_le ((∑ i,w (.inr (.inr i))*h i)-
      (∑ i,B.saturatedClone e A a (.inr (.inr i))*h i)) η.2
    have heq : noisyNetworkOutput Real.tanh w x η-
        (∑ i,B.saturatedClone e A a (.inr (.inr i))*h i) =
        ((∑ i,w (.inr (.inr i))*h i)-
          (∑ i,B.saturatedClone e A a (.inr (.inr i))*h i))+η.2 := by
      unfold noisyNetworkOutput
      dsimp [h]
      ring
    rw [heq]
    linarith
  have he' := abs_le.mp he
  have hm := H.output_margin
  cases hb : B.computes x <;>
    simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hteacher ⊢ <;>
    linarith

/-- Concrete cylinder containment once deterministic coordinate bounds are
instantiated. The original all-input clean margin also holds. -/
theorem robust_and_target (H : ExponentialCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k) (hbelow:C*k≤N)
    {c : ℝ} (hc : 0 < c) (hcal : 2*c ≤ τ*a*Real.sqrt C) :
    w ∈ robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
  have hC:0<C := Nat.pos_of_ne_zero (fun hz=>by simpa [hz] using B.constant.isLt)
  have henergy:=saturated_readoutEnergy_lower hN hC hk hbelow B e w H.readout_nonneg
    H.radius_nonneg H.readout_radius H.readout_error
  have hr:=robustRadius_le_of_width_readoutEnergy w H.readout_nonneg H.noise_nonneg henergy hcal
  have hr0 := (robustRadius_pos hc w).le
  have hball (η : NetworkDisturbance N r)
      (hη : noiseBudgetSq η ≤ (robustRadius c w)^2) : noiseBudgetSq η ≤ τ^2 :=
    hη.trans ((sq_le_sq₀ hr0 H.noise_nonneg).mpr hr)
  constructor
  · apply mem_robustEvent_of_uniform_noisy_margin Real.tanh c w B.computes
    intro x η hη
    exact le_of_lt (lt_trans (by norm_num : (1/2:ℝ)<1)
      (H.noisy_margin hN hk hwidth x η (hball η hη)))
  · intro x
    have hh := H.noisy_margin hN hk hwidth x 0 (by simp only [noiseBudgetSq_zero]; positivity)
    rw [noisyNetworkOutput_zero] at hh
    linarith

end ExponentialCylinderConditions
end NeuralGeneralization.ConcreteModel
