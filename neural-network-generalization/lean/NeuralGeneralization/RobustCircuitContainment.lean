import NeuralGeneralization.RobustCircuitInvariant
import NeuralGeneralization.RobustModelContinuity

/-! # Deterministic finite-radius containment of the digital cylinder -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

/-- All bounds here are deterministic consequences of coordinate constraints
and polynomial parameter choices. No probability bound is a field. -/
structure DigitalCylinderConditions (B : LayeredBooleanCircuit d C r)
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
  init_bound : 3*((4/A)^2+τ^2) ≤ ε^2
  step_bound : 3*((4/A)^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2) ≤ ε^2
  output_margin : 1 < 15*a/16-2*ρ-τ

namespace DigitalCylinderConditions

variable {B : LayeredBooleanCircuit d C r}
  {e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

theorem noisy_final_error (H : DigitalCylinderConditions B e w A a ε τ ρ G β)
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
      · exact B.internal_noisy_state_error e hk hwidth w H.R H.E H.gain_pos H.decomp
          H.projected_bound H.free_bound H.group_small H.step_bound h b hc hh s η
          (noiseBudgetSq_hidden hN η hη s.succ) (H.free_kills b s)
  exact hfold (List.finRange r) (noisyFirstHidden Real.tanh w x η) (B.firstBits x)
    (B.firstBits_constant x)
    (B.first_noisy_state_error e w H.gain_pos H.radius_nonneg H.first_error H.first_small
      H.init_bound x η (noiseBudgetSq_hidden hN η hη 0))

end DigitalCylinderConditions

theorem squared_norm_le_of_boolean_error (h b : Fin N → ℝ) {ε : ℝ}
    (hε : 0 ≤ ε) (hε1 : ε ≤ 1) (hb : ∀ i,|b i| ≤ 1)
    (hh : (∑ i,(h i-b i)^2) ≤ (N:ℝ)*ε^2) : (∑ i,h i^2) ≤ 4*(N:ℝ) := by
  have hbnorm : (∑ i,b i^2) ≤ (N:ℝ) := by
    simpa only [Fintype.card_fin, one_pow, mul_one] using
      finite_sum_sq_le_card_mul b (by norm_num : (0:ℝ)≤1) hb
  have he : ε^2 ≤ 1 := by nlinarith
  have hen := mul_le_mul_of_nonneg_left he (Nat.cast_nonneg N)
  calc
    _ ≤ ∑ i,2*((h i-b i)^2+(b i)^2) := Finset.sum_le_sum fun i _ => by
      nlinarith [sq_nonneg (h i-2*b i)]
    _ = 2*((∑ i,(h i-b i)^2)+∑ i,b i^2) := by
      simp only [← Finset.mul_sum, Finset.sum_add_distrib]
    _ ≤ _ := by nlinarith

theorem readout_coordinate_error_rms (hN : 0 < N)
    (w v : Weights d N r) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (herr : ∀ i,|w (.inr (.inr i))-v (.inr (.inr i))| ≤ ρ/(N:ℝ))
    (h : Fin N → ℝ) (hh : (∑ i,h i^2) ≤ 4*(N:ℝ)) :
    |(∑ i,w (.inr (.inr i))*h i)-(∑ i,v (.inr (.inr i))*h i)| ≤ 2*ρ := by
  have hNR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  let z : Fin N → ℝ := fun i => w (.inr (.inr i))-v (.inr (.inr i))
  have hz : (∑ i,z i^2) ≤ (N:ℝ)*(ρ/(N:ℝ))^2 := by
    simpa only [Fintype.card_fin] using finite_sum_sq_le_card_mul z (by positivity) herr
  have hc := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ) z h
  have hmul := mul_le_mul hz hh (Finset.sum_nonneg fun i _ => sq_nonneg (h i))
    (by positivity : 0 ≤ (N:ℝ)*(ρ/(N:ℝ))^2)
  have heq : ((N:ℝ)*(ρ/(N:ℝ))^2)*(4*(N:ℝ)) = (2*ρ)^2 := by field_simp; ring
  rw [heq] at hmul
  have hsum : (∑ i,w (.inr (.inr i))*h i)-(∑ i,v (.inr (.inr i))*h i) =
      ∑ i,z i*h i := by simp only [z,mul_sub,sub_mul,Finset.sum_sub_distrib]
  rw [hsum]
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
  rw [sq_abs]
  exact hc.trans hmul

namespace DigitalCylinderConditions
variable {B : LayeredBooleanCircuit d C r}
  {e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

/-- Every allowed perturbation retains a strict signed raw margin greater
than one, uniformly over all inputs. -/
theorem noisy_margin (H : DigitalCylinderConditions B e w A a ε τ ρ G β)
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
theorem robust_and_target (H : DigitalCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    {c : ℝ} (hc : 0 < c) (hcal : 2*c ≤ τ*a) :
    w ∈ robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
  have henergy := readoutEnergy_lower_of_sum hN w (B.saturatedClone e A a)
    H.radius_nonneg H.readout_radius (B.saturatedClone_sum_readout e hk A a) H.readout_error
  have hr := robustRadius_le_of_readoutEnergy w H.readout_nonneg H.noise_nonneg henergy hcal
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

end DigitalCylinderConditions
end NeuralGeneralization.ConcreteModel
