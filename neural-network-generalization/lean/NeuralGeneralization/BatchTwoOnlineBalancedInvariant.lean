import NeuralGeneralization.BatchTwoImprovedTargetSaturation
import NeuralGeneralization.BatchTwoOnlineBalancedEnergy

/-! Finite-disturbance gate invariants with logarithmic gains. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {d C N r:ℕ} {k : Fin C→ℕ}
theorem first_noisy_state_error_exp (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b)) ≃ Fin N) (w : Weights d N r)
    {A a ρ ε τ : ℝ} (hA : 0 < A) (hρ : 0 ≤ ρ)
    (hfirst : ∀ i j, |w (.inl (i,j))-groupedWeights B e A a (.inl (i,j))| ≤ ρ)
    (hsmall : ((d:ℝ)+1)*ρ ≤ A/2)
    (hinit : 3*((2*Real.exp (-A/2))^2+τ^2) ≤ ε^2)
    (x : Cube d) (η : NetworkDisturbance N r)
    (hη : (∑ i,(η.1 0 i)^2) ≤ (N:ℝ)*τ^2) :
    (∑ i,(noisyFirstHidden Real.tanh w x η i-layoutBits e (B.firstBits x) i)^2) ≤
      (N:ℝ)*ε^2 := by
  let q : Fin N → ℝ := fun i => ∑ j,w (.inl (i,j))*inputVector x j
  have hq (i : Fin N) : A/2 ≤ labelReal ((B.firstBits x (layoutGroup e i)))*q i := by
    have hc := grouped_signed_first B e (a:=a) hA.le x i
    have he : |q i-(∑ j,groupedWeights B e A a (.inl (i,j))*inputVector x j)| ≤
        ((d:ℝ)+1)*ρ := by
      dsimp [q]
      rw [← Finset.sum_sub_distrib]
      calc
        _ ≤ ∑ j, |w (.inl (i,j))*inputVector x j-
            groupedWeights B e A a (.inl (i,j))*inputVector x j| :=
          Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _j : Fin (d+1),ρ := Finset.sum_le_sum fun j _ => by
          rw [← sub_mul, abs_mul, NeuralGeneralization.ConcreteModel.abs_inputVector, mul_one]
          exact hfirst i j
        _ = _ := by simp
    change A ≤ labelReal (B.firstBits x (layoutGroup e i)) * _ at hc
    cases hb : (B.firstBits x (layoutGroup e i)) <;>
      simp only [hb, labelReal_false, labelReal_true, neg_one_mul, one_mul] at hc ⊢ <;>
      have hh := abs_le.mp he <;> linarith
  have hs := saturation_squared_error_exp (fun i=>B.firstBits x (layoutGroup e i)) q
    (fun _=>0) (η.1 0) hA hq (by simp : (∑ _i : Fin N,(0:ℝ)^2) ≤ 0) hη
  simp only [zero_add, add_zero, mul_zero] at hs
  change (∑ i,(Real.tanh (q i)+η.1 0 i-layoutBits e (B.firstBits x) i)^2) ≤ _
  apply hs.trans
  have hh := mul_le_mul_of_nonneg_left hinit (Nat.cast_nonneg N)
  nlinarith

/-- One actual internal transition preserves the RMS invariant. -/
theorem internal_noisy_state_error_exp (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b)) ≃ Fin N) (hk : ∀b,0<k b) (hwidth : ∀b,N ≤ 2*C*k b)
    (w : Weights d N r) (R E : Fin r → Fin N → Fin N → ℝ)
    {A a ρ G β ε τ : ℝ} (hA : 0 < A)
    (hdecomp : ∀ s i j,w (.inr (.inl (s,i,j)))=
      groupedWeights B e A a (.inr (.inl (s,i,j)))+R s i j+E s i j)
    (hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G)
    (hE : ∀ s,matrixActionBound (E s) β)
    (hgroup : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2)
    (hcontract : 3*((2*Real.exp (-A/2))^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2) ≤ ε^2)
    (h : Fin N → ℝ) (b : Fin C → Bool) (s : Fin r) (hc : ∀ i j k, B.internal s i = .nand j k → b B.constant = true)
    (hstate : (∑ i,(h i-layoutBits e b i)^2) ≤ (N:ℝ)*ε^2)
    (η : NetworkDisturbance N r)
    (hη : (∑ i,(η.1 s.succ i)^2) ≤ (N:ℝ)*τ^2)
    (hkill : ∀ i,(∑ j,E s i j*layoutBits e b j)=0) :
    (∑ i,(noisyHiddenStep Real.tanh w η h s i-layoutBits e (B.stepBits b s) i)^2) ≤
      (N:ℝ)*ε^2 := by
  let q : Fin N → ℝ := fun i => ∑ j,groupedWeights B e A a (.inr (.inl (s,i,j)))*h j
  let u : Fin N → ℝ := fun i => (∑ j,R s i j*h j)+(∑ j,E s i j*h j)
  have hq (i : Fin N) : A/2 ≤ layoutBits e (B.stepBits b s) i*q i := by
    exact grouped_signed_internal B e hk hwidth hA.le hgroup h b s hc hstate i
  have hu := cylinder_perturbation_squared (R s) (E s) h (layoutBits e b)
    (hR s) (hE s) hkill hstate (fun i => (abs_layoutBits e b i).le)
  have hs := saturation_squared_error_exp (fun i => B.stepBits b s (layoutGroup e i))
    q u (η.1 s.succ) hA hq hu hη
  have heq (i : Fin N) : noisyHiddenStep Real.tanh w η h s i =
      Real.tanh (q i+u i)+η.1 s.succ i := by
    unfold noisyHiddenStep hiddenStep
    congr 2
    dsimp [q,u]
    simp only [hdecomp, add_mul, Finset.sum_add_distrib]
    ring
  change (∑ i,(Real.tanh (q i+u i)+η.1 s.succ i-layoutBits e (B.stepBits b s) i)^2) ≤ _ at hs
  simp_rw [heq]
  apply hs.trans
  have hh := mul_le_mul_of_nonneg_left hcontract (Nat.cast_nonneg N)
  nlinarith

end NeuralGeneralization.BatchTwoOnlineBalanced
