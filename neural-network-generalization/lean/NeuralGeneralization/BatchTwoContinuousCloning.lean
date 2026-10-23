import NeuralGeneralization.BatchTwoContinuousFreeze
import NeuralGeneralization.Cloning

/-! Exact output-preserving teacher cloning for every real input. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

theorem freeze_clonedWeights {d C N r k p : ℕ} (x : RealInput d)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    freezeInput x (clonedWeights e w)=clonedWeights e (freezeInput x w) := by
  funext a
  rcases a with ⟨i,j⟩ | a
  · rcases he : e.symm i with ⟨b,t⟩ | t
    · refine Fin.cases ?_ (fun j => ?_) j
      · simp [freezeInput,clonedWeights,he]
      · simp [freezeInput,clonedWeights,he]
    · refine Fin.cases ?_ (fun j => ?_) j <;> simp [freezeInput,clonedWeights,he]
  · cases a <;> rfl

theorem output_clonedWeights {d C N r k p : ℕ} (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) (x : RealInput d) :
    output φ (clonedWeights e w) x=output φ w x := by
  have h := networkOutput_cloned hk φ e (freezeInput x w) (fun _ => false)
  rw [← freeze_clonedWeights,output_freeze,output_freeze] at h
  exact h

theorem exists_real_clone_at_every_width {d C N r : ℕ} (hC : 0 < C) (hCN : C ≤ N)
    (φ : ℝ → ℝ) (w : Weights d C r) :
    ∃ v : Weights d N r, (∀ x : RealInput d, output φ v x=output φ w x) ∧
      weightedSquaredNorm v ≤ 2*weightedSquaredNorm w := by
  classical
  let k := N/C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hmod : N%C < C := Nat.mod_lt _ hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hbelow : C*k ≤ N := by omega
  have hCk : C ≤ C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N ≤ 2*C*k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact ⟨clonedWeights e w,output_clonedWeights hk φ e w,
    weightedSquaredNorm_cloned_le hC hk hbelow habove e w⟩

end NeuralGeneralization.BatchTwoContinuous
