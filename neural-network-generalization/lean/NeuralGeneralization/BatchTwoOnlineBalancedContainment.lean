import NeuralGeneralization.BatchTwoOnlineBalancedInvariant
import NeuralGeneralization.RobustCircuitContainment

/-! Balanced Boolean cylinders preserve exact finite-noise robustness. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {d C N r:ℕ} {k : Fin C→ℕ}

structure GroupedCylinderConditions (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b)) ≃ Fin N) (w : Weights d N r)
    (A a ε τ ρ G β : ℝ) where
  R : Fin r → Fin N → Fin N → ℝ
  E : Fin r → Fin N → Fin N → ℝ
  gain_pos : 0 < A
  readout_nonneg : 0 ≤ a
  error_nonneg : 0 ≤ ε
  error_le_one : ε ≤ 1
  noise_nonneg : 0 ≤ τ
  radius_nonneg : 0 ≤ ρ
  readout_radius : ρ ≤ a/4
  first_error : ∀ i j, |w (.inl (i,j))-groupedWeights B e A a (.inl (i,j))| ≤ ρ
  first_small : ((d:ℝ)+1)*ρ ≤ A/2
  readout_error : ∀ i, |w (.inr (.inr i))-groupedWeights B e A a (.inr (.inr i))| ≤ ρ/(N:ℝ)
  decomp : ∀ s i j,w (.inr (.inl (s,i,j)))=
    groupedWeights B e A a (.inr (.inl (s,i,j)))+R s i j+E s i j
  projected_bound : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G
  free_bound : ∀ s,matrixActionBound (E s) β
  free_kills : ∀ (b : Fin C → Bool) s i,(∑ j,E s i j*layoutBits e b j)=0
  group_small : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2
  init_bound : 3*((2*Real.exp (-A/2))^2+τ^2) ≤ ε^2
  step_bound : 3*((2*Real.exp (-A/2))^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2) ≤ ε^2
  output_margin : 1 < 15*a/16-2*ρ-τ

namespace GroupedCylinderConditions

variable {B : LayeredBooleanCircuit d C r}
  {e : (Σb : Fin C,Fin (k b)) ≃ Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

theorem noisy_final_error (H : GroupedCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : ∀b,0<k b) (hwidth : ∀b,N ≤ 2*C*k b)
    (x : Cube d) (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ τ^2) :
    (∑ i,(noisyFinalHidden Real.tanh w x η i-layoutBits e (B.finalBits x) i)^2) ≤
      (N:ℝ)*ε^2 := by
  have hfold (ss pre : List (Fin r))
      (hlist : pre ++ ss = List.finRange r) (h : Fin N → ℝ)
      (hh : (∑ i,(h i-layoutBits e
        (pre.foldl B.stepBits (B.firstBits x)) i)^2) ≤ (N:ℝ)*ε^2) :
      (∑ i,(ss.foldl (noisyHiddenStep Real.tanh w η) h i-
        layoutBits e (B.finalBits x) i)^2) ≤ (N:ℝ)*ε^2 := by
    induction ss generalizing pre h with
    | nil =>
      have hp : pre = List.finRange r := by simpa using hlist
      simpa [hp, LayeredBooleanCircuit.finalBits] using hh
    | cons s ss ih =>
      apply ih (pre ++ [s]) (by simpa [List.append_assoc] using hlist)
      simpa only [List.foldl_append, List.foldl_cons, List.foldl_nil] using
        internal_noisy_state_error_exp B e hk hwidth w H.R H.E H.gain_pos H.decomp
          H.projected_bound H.free_bound H.group_small H.step_bound h
          (pre.foldl B.stepBits (B.firstBits x)) s
          (B.bias_available pre ss s x hlist) hh η
          (noiseBudgetSq_hidden hN η hη s.succ)
          (H.free_kills (pre.foldl B.stepBits (B.firstBits x)) s)
  exact hfold (List.finRange r) [] rfl (noisyFirstHidden Real.tanh w x η)
    (first_noisy_state_error_exp B e w H.gain_pos H.radius_nonneg H.first_error H.first_small
      H.init_bound x η (noiseBudgetSq_hidden hN η hη 0))

end GroupedCylinderConditions

namespace GroupedCylinderConditions
variable {B : LayeredBooleanCircuit d C r}
  {e : (Σb : Fin C,Fin (k b)) ≃ Fin N} {w : Weights d N r}
  {A a ε τ ρ G β : ℝ}

/-- Every allowed perturbation retains a strict signed raw margin greater
than one, uniformly over all inputs. -/
theorem noisy_margin (H : GroupedCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : ∀b,0<k b) (hwidth : ∀b,N ≤ 2*C*k b)
    (x : Cube d) (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ τ^2) :
    1 < labelReal (B.computes x)*noisyNetworkOutput Real.tanh w x η := by
  let h := noisyFinalHidden Real.tanh w x η
  have hstate := H.noisy_final_error hN hk hwidth x η hη
  have hnorm : (∑ i,h i^2) ≤ 4*(N:ℝ) := squared_norm_le_of_boolean_error h
    (layoutBits e (B.finalBits x)) H.error_nonneg H.error_le_one
    (fun i => (abs_layoutBits e (B.finalBits x) i).le) hstate
  have hdiff := readout_coordinate_error_rms hN w (groupedWeights B e A a) H.radius_nonneg
    H.readout_error h hnorm
  have hout := noiseBudgetSq_output η H.noise_nonneg hη
  have hmean := layoutMean_error_le e hk hwidth h (B.finalBits x) (by norm_num)
    H.group_small hstate B.output
  have hteacher : 15*a/16 ≤ labelReal (B.computes x) *
      (∑ i,groupedWeights B e A a (.inr (.inr i))*h i) := by
    rw [grouped_readout B e A a h]
    change 15*a/16 ≤ labelReal (B.finalBits x B.output)*(a*layoutMean e h B.output)
    have hmean' := abs_le.mp hmean
    cases hb : B.finalBits x B.output <;>
      simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hmean' ⊢ <;>
      nlinarith [H.readout_nonneg]
  have he : |noisyNetworkOutput Real.tanh w x η-
      (∑ i,groupedWeights B e A a (.inr (.inr i))*h i)| ≤ 2*ρ+τ := by
    have hh := abs_add_le ((∑ i,w (.inr (.inr i))*h i)-
      (∑ i,groupedWeights B e A a (.inr (.inr i))*h i)) η.2
    have heq : noisyNetworkOutput Real.tanh w x η-
        (∑ i,groupedWeights B e A a (.inr (.inr i))*h i) =
        ((∑ i,w (.inr (.inr i))*h i)-
          (∑ i,groupedWeights B e A a (.inr (.inr i))*h i))+η.2 := by
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
theorem robust_and_target (H : GroupedCylinderConditions B e w A a ε τ ρ G β)
    (hN : 0 < N) (hk : ∀b,0<k b) (hwidth : ∀b,N ≤ 2*C*k b) (hwidth' : ∀b,C*k b≤2*N)
    {c : ℝ} (hc : 0 < c) (hcal : 4*c ≤ τ*a*Real.sqrt C) :
    w ∈ robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes := by
  have hC:0<C := Nat.pos_of_ne_zero (fun hz=>by simpa [hz] using B.constant.isLt)
  have henergy:=grouped_perturbed_readout_lower B e hN hC hk hwidth hwidth' w H.readout_nonneg
    H.radius_nonneg H.readout_radius H.readout_error
  have hr:=grouped_robustRadius_le w H.readout_nonneg H.noise_nonneg henergy hcal
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

end GroupedCylinderConditions
end NeuralGeneralization.BatchTwoOnlineBalanced
