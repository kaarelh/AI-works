import NeuralGeneralization.BatchTwoContinuousModel
import NeuralGeneralization.CompressionSampling

/-! Pointwise transfer of the existing actual neuron-sampling construction to
real inputs. Freezing a real input into the first constant coordinate commutes
with pruning and sampling; no Boolean assumption enters those estimates. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

def freezeInput {d N r : ℕ} (x : RealInput d) (w : Weights d N r) : Weights d N r
  | Sum.inl (i,j) => Fin.cases (∑ k, w (Sum.inl (i,k))*augmentedInput x k) (fun _ => 0) j
  | Sum.inr a => w (Sum.inr a)

@[simp] theorem firstHidden_freeze {d N r : ℕ} (φ : ℝ → ℝ) (x : RealInput d)
    (w : Weights d N r) (y : Cube d) :
    ConcreteModel.firstHidden φ (freezeInput x w) y = firstHidden φ w x := by
  funext i
  simp [ConcreteModel.firstHidden, firstHidden, freezeInput, inputVector,
    Fin.sum_univ_succ]

@[simp] theorem hiddenStep_freeze {d N r : ℕ} (φ : ℝ → ℝ) (x : RealInput d)
    (w : Weights d N r) : hiddenStep φ (freezeInput x w) = hiddenStep φ w := rfl

@[simp] theorem finalHidden_freeze {d N r : ℕ} (φ : ℝ → ℝ) (x : RealInput d)
    (w : Weights d N r) (y : Cube d) :
    ConcreteModel.finalHidden φ (freezeInput x w) y = finalHidden φ w x := by
  simp only [ConcreteModel.finalHidden, hiddenStep_freeze, firstHidden_freeze, finalHidden]

@[simp] theorem output_freeze {d N r : ℕ} (φ : ℝ → ℝ) (x : RealInput d)
    (w : Weights d N r) (y : Cube d) :
    networkOutput φ (freezeInput x w) y = output φ w x := by
  simp only [networkOutput, finalHidden_freeze, freezeInput, output]

@[simp] theorem internalRowNorm_freeze {d N r : ℕ} (x : RealInput d)
    (w : Weights d N r) (s : Fin r) (i : Fin N) :
    internalRowNorm (freezeInput x w) s i = internalRowNorm w s i := rfl

@[simp] theorem outputRowNorm_freeze {d N r : ℕ} (x : RealInput d)
    (w : Weights d N r) : outputRowNorm (freezeInput x w) = outputRowNorm w := rfl

@[simp] theorem freeze_prunedWeights {d N r : ℕ} (x : RealInput d)
    (w : Weights d N r) (ρ q : ℝ) :
    freezeInput x (prunedWeights ρ q w) = prunedWeights ρ q (freezeInput x w) := by
  funext a
  cases a with
  | inl a => rcases a with ⟨i,j⟩; rfl
  | inr a => cases a <;> rfl

@[simp] theorem freeze_sampledWeights {d N r M : ℕ} (x : RealInput d)
    (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N) :
    freezeInput x (sampledWeights w I) = sampledWeights (freezeInput x w) I := by
  funext a
  cases a with
  | inl a => rcases a with ⟨i,j⟩; rfl
  | inr a => cases a <;> rfl

@[simp] theorem retainedRowMass_freeze {d N r M : ℕ} (x : RealInput d)
    (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N) :
    retainedRowMass (freezeInput x w) I = retainedRowMass w I := rfl

theorem augmentedInput_sq_sum {d : ℕ} (x : RealInput d) :
    (∑ j, augmentedInput x j^2)=1+∑ i, x i^2 := by
  simp [augmentedInput, Fin.sum_univ_succ]

theorem freeze_row_energy {d N r : ℕ} (x : RealInput d) (w : Weights d N r) (i : Fin N) :
    (∑ j, freezeInput x w (Sum.inl (i,j))^2) ≤
      (1+∑ j, x j^2)*(∑ j, w (Sum.inl (i,j))^2) := by
  simp only [freezeInput, Fin.sum_univ_succ, Fin.cases_zero, Fin.cases_succ, zero_pow (by omega : 2 ≠ 0),
    Finset.sum_const_zero, add_zero]
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun j => w (Sum.inl (i,j))) (augmentedInput x)
  rw [augmentedInput_sq_sum] at h
  simpa only [mul_comm, Fin.sum_univ_succ] using h

theorem energy_freeze {d N r : ℕ} (x : RealInput d) (w : Weights d N r) :
    weightedSquaredNorm (freezeInput x w) ≤ (1+∑ j, x j^2)*weightedSquaredNorm w := by
  have hfirst : (∑ i, ∑ j, freezeInput x w (Sum.inl (i,j))^2) ≤
      (1+∑ j, x j^2)*(∑ i, ∑ j, w (Sum.inl (i,j))^2) := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => freeze_row_energy x w i
  have hmul := mul_le_mul_of_nonneg_left hfirst (show 0 ≤ (d : ℝ)/N by positivity)
  have hsum : 0 ≤ ∑ j, x j^2 := Finset.sum_nonneg fun _ _ => sq_nonneg _
  have hi : 0 ≤ ∑ s : Fin r, ∑ i : Fin N, ∑ j : Fin N, w (Sum.inr (Sum.inl (s,i,j)))^2 := by positivity
  have ho : 0 ≤ (N : ℝ)*∑ j : Fin N, w (Sum.inr (Sum.inr j))^2 := by positivity
  unfold weightedSquaredNorm
  change (d : ℝ)/N*(∑ i, ∑ j, freezeInput x w (Sum.inl (i,j))^2)+
    (∑ s : Fin r, ∑ i : Fin N, ∑ j : Fin N, w (Sum.inr (Sum.inl (s,i,j)))^2)+
    (N : ℝ)*(∑ j : Fin N, w (Sum.inr (Sum.inr j))^2) ≤ _
  nlinarith

theorem energy_freeze_unit_ball {d N r : ℕ} (x : RealInput d)
    (hx : ∑ j, x j^2 ≤ 1) (w : Weights d N r) :
    weightedSquaredNorm (freezeInput x w) ≤ 2*weightedSquaredNorm w := by
  apply (energy_freeze x w).trans
  exact mul_le_mul_of_nonneg_right (by linarith) (weightedSquaredNorm_nonneg w)

end NeuralGeneralization.BatchTwoContinuous
