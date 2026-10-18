import NeuralGeneralization.RobustCircuitStep
import NeuralGeneralization.RobustCircuitReadout

/-! # The actual noisy hidden-state invariant for the digital cylinder -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

def saturatedCloneBool (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (b : Fin C → Bool) (i : Fin N) : Bool :=
  match e.symm i with
  | .inl (a,_) => b a
  | .inr _ => true

@[simp] theorem labelReal_saturatedCloneBool
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (b : Fin C → Bool) (i : Fin N) :
    labelReal (saturatedCloneBool e b i) = saturatedCloneBits e b i := by
  cases hi : e.symm i <;> simp [saturatedCloneBool, saturatedCloneBits, hi]

theorem inputVector_eq_labelBits (x : Cube d) :
    inputVector x = fun j => labelReal (Fin.cases true x j) := by
  funext j
  refine Fin.cases ?_ (fun i => ?_) j <;> rfl

namespace LayeredBooleanCircuit

theorem cloneGate_eval_first (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (x : Cube d) (i : Fin N) :
    (B.cloneInputGate e i).eval (Fin.cases true x) = saturatedCloneBool e (B.firstBits x) i := by
  cases hi : e.symm i with
  | inl ab => simp [cloneInputGate, saturatedCloneBool, firstBits, hi]
  | inr z => simp [cloneInputGate, saturatedCloneBool, DigitalGate.eval, hi]

theorem saturatedClone_signed_first (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {A a : ℝ} (hA : 0 ≤ A) (x : Cube d) (i : Fin N) :
    A ≤ saturatedCloneBits e (B.firstBits x) i *
      (∑ j, B.saturatedClone e A a (.inl (i,j))*inputVector x j) := by
  rw [saturatedClone_first_preactivation, ← labelReal_saturatedCloneBool,
    ← B.cloneGate_eval_first]
  have hh := (B.cloneInputGate e i).signed_linear_margin (Fin.cases true x)
  rw [← inputVector_eq_labelBits] at hh
  have hm := mul_le_mul_of_nonneg_left hh hA
  nlinarith

/-- Initialize the actual noisy state using coordinate constraints on the
first matrix. The reference is an ideal Boolean vector, not a clean network. -/
theorem first_noisy_state_error (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d N r)
    {A a ρ ε τ : ℝ} (hA : 0 < A) (hρ : 0 ≤ ρ)
    (hfirst : ∀ i j, |w (.inl (i,j))-B.saturatedClone e A a (.inl (i,j))| ≤ ρ)
    (hsmall : ((d:ℝ)+1)*ρ ≤ A/2)
    (hinit : 3*((4/A)^2+τ^2) ≤ ε^2)
    (x : Cube d) (η : NetworkDisturbance N r)
    (hη : (∑ i,(η.1 0 i)^2) ≤ (N:ℝ)*τ^2) :
    (∑ i,(noisyFirstHidden Real.tanh w x η i-saturatedCloneBits e (B.firstBits x) i)^2) ≤
      (N:ℝ)*ε^2 := by
  let q : Fin N → ℝ := fun i => ∑ j,w (.inl (i,j))*inputVector x j
  have hq (i : Fin N) : A/2 ≤ labelReal (saturatedCloneBool e (B.firstBits x) i)*q i := by
    have hc := B.saturatedClone_signed_first e (a:=a) hA.le x i
    have he : |q i-(∑ j,B.saturatedClone e A a (.inl (i,j))*inputVector x j)| ≤
        ((d:ℝ)+1)*ρ := by
      dsimp [q]
      rw [← Finset.sum_sub_distrib]
      calc
        _ ≤ ∑ j, |w (.inl (i,j))*inputVector x j-
            B.saturatedClone e A a (.inl (i,j))*inputVector x j| :=
          Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _j : Fin (d+1),ρ := Finset.sum_le_sum fun j _ => by
          rw [← sub_mul, abs_mul, NeuralGeneralization.ConcreteModel.abs_inputVector, mul_one]
          exact hfirst i j
        _ = _ := by simp
    rw [← labelReal_saturatedCloneBool] at hc
    cases hb : saturatedCloneBool e (B.firstBits x) i <;>
      simp only [hb, labelReal_false, labelReal_true, neg_one_mul, one_mul] at hc ⊢ <;>
      have hh := abs_le.mp he <;> linarith
  have hs := saturation_squared_error (saturatedCloneBool e (B.firstBits x)) q
    (fun _=>0) (η.1 0) hA hq (by simp : (∑ _i : Fin N,(0:ℝ)^2) ≤ 0) hη
  simp only [zero_add, add_zero, mul_zero, labelReal_saturatedCloneBool] at hs
  change (∑ i,(Real.tanh (q i)+η.1 0 i-saturatedCloneBits e (B.firstBits x) i)^2) ≤ _
  apply hs.trans
  have hh := mul_le_mul_of_nonneg_left hinit (Nat.cast_nonneg N)
  nlinarith

/-- One actual internal transition preserves the RMS invariant. -/
theorem internal_noisy_state_error (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (hk : 0 < k) (hwidth : N ≤ 2*C*k)
    (w : Weights d N r) (R E : Fin r → Fin N → Fin N → ℝ)
    {A a ρ G β ε τ : ℝ} (hA : 0 < A)
    (hdecomp : ∀ s i j,w (.inr (.inl (s,i,j)))=
      B.saturatedClone e A a (.inr (.inl (s,i,j)))+R s i j+E s i j)
    (hR : ∀ s,(∑ i,∑ j,R s i j^2) ≤ ρ^2*G)
    (hE : ∀ s,matrixActionBound (E s) β)
    (hgroup : 2*(C:ℝ)*ε^2 ≤ (1/16:ℝ)^2)
    (hcontract : 3*((4/A)^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2) ≤ ε^2)
    (h : Fin N → ℝ) (b : Fin C → Bool) (hc : b B.constant = true)
    (hstate : (∑ i,(h i-saturatedCloneBits e b i)^2) ≤ (N:ℝ)*ε^2)
    (s : Fin r) (η : NetworkDisturbance N r)
    (hη : (∑ i,(η.1 s.succ i)^2) ≤ (N:ℝ)*τ^2)
    (hkill : ∀ i,(∑ j,E s i j*saturatedCloneBits e b j)=0) :
    (∑ i,(noisyHiddenStep Real.tanh w η h s i-saturatedCloneBits e (B.stepBits b s) i)^2) ≤
      (N:ℝ)*ε^2 := by
  let q : Fin N → ℝ := fun i => ∑ j,B.saturatedClone e A a (.inr (.inl (s,i,j)))*h j
  let u : Fin N → ℝ := fun i => (∑ j,R s i j*h j)+(∑ j,E s i j*h j)
  have hq (i : Fin N) : A/2 ≤ labelReal ((B.cloneInternalGate e s i).eval b)*q i := by
    rw [B.cloneGate_eval_step e b hc]
    exact B.saturatedClone_signed_internal e hk hwidth hA.le hgroup h b hc hstate s i
  have hu := cylinder_perturbation_squared (R s) (E s) h (saturatedCloneBits e b)
    (hR s) (hE s) hkill hstate (fun i => (abs_saturatedCloneBits e b i).le)
  have hs := saturation_squared_error (fun i => (B.cloneInternalGate e s i).eval b)
    q u (η.1 s.succ) hA hq hu hη
  have heq (i : Fin N) : noisyHiddenStep Real.tanh w η h s i =
      Real.tanh (q i+u i)+η.1 s.succ i := by
    unfold noisyHiddenStep hiddenStep
    congr 2
    dsimp [q,u]
    simp only [hdecomp, add_mul, Finset.sum_add_distrib]
    ring
  simp_rw [B.cloneGate_eval_step e b hc] at hs
  simp_rw [heq]
  apply hs.trans
  have hh := mul_le_mul_of_nonneg_left hcontract (Nat.cast_nonneg N)
  nlinarith

end LayeredBooleanCircuit
end NeuralGeneralization.ConcreteModel
