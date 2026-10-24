import NeuralGeneralization.BatchTwoShallowCylinder
import NeuralGeneralization.RobustModel
import NeuralGeneralization.MarginRescaling

/-! Exact shallow perturbation and cloned-center geometry. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling

def readoutL1 {d N : ℕ} (w : Weights d N 0) : ℝ :=
  ∑ i, |w (Sum.inr (Sum.inr i))|

theorem shallow_output (φ : ℝ → ℝ) {d N : ℕ} (w : Weights d N 0) (x : Cube d) :
    networkOutput φ w x = ∑ i, w (Sum.inr (Sum.inr i)) *
      φ (∑ j, w (Sum.inl (i,j)) * inputVector x j) := by
  simp [networkOutput, finalHidden, firstHidden]

theorem abs_input (d : ℕ) (x : Cube d) (j : Fin (d+1)) : |inputVector x j| = 1 := by
  refine Fin.cases ?_ (fun i => ?_) j
  · simp [inputVector]
  · simp [inputVector]

theorem shallow_output_stability {d N : ℕ} (hN : 0 < N) (w v : Weights d N 0)
    {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hfirst : ∀ i j, |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ a)
    (hread : ∀ i, |w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤ b/N)
    (x : Cube d) :
    |networkOutput Real.tanh w x-networkOutput Real.tanh v x| ≤
      b+readoutL1 v*((d : ℝ)+1)*a := by
  have hN0 : (N : ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  let u := fun i => ∑ j, w (Sum.inl (i,j))*inputVector x j
  let t := fun i => ∑ j, v (Sum.inl (i,j))*inputVector x j
  have hhidden (i : Fin N) : |Real.tanh (u i)-Real.tanh (t i)| ≤ ((d : ℝ)+1)*a := by
    apply (tanh_admissible.2 _ _).trans
    calc
      _ = |∑ j, (w (Sum.inl (i,j))-v (Sum.inl (i,j)))*inputVector x j| := by
        dsimp [u,t]; rw [← Finset.sum_sub_distrib]; congr 1; apply Finset.sum_congr rfl
        intro j _; ring
      _ ≤ ∑ j, |(w (Sum.inl (i,j))-v (Sum.inl (i,j)))*inputVector x j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j : Fin (d+1), a := by
        apply Finset.sum_le_sum
        intro j _
        simpa only [abs_mul, abs_input, mul_one] using hfirst i j
      _ = _ := by simp
  have hsplit : networkOutput Real.tanh w x-networkOutput Real.tanh v x =
      (∑ i, (w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*Real.tanh (u i)) +
      ∑ i, v (Sum.inr (Sum.inr i))*(Real.tanh (u i)-Real.tanh (t i)) := by
    rw [shallow_output, shallow_output, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    dsimp [u,t]
    ring
  rw [hsplit]
  apply (abs_add_le _ _).trans
  have hleft : |∑ i, (w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*Real.tanh (u i)| ≤ b := by
    calc
      _ ≤ ∑ i, |(w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*Real.tanh (u i)| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin N, b/N := by
        apply Finset.sum_le_sum
        intro i _
        rw [abs_mul]
        exact (mul_le_mul_of_nonneg_left (tanh_admissible.1 _) (abs_nonneg _)).trans
          (by simpa using hread i)
      _ = b := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
          nsmul_eq_mul]; exact mul_div_cancel₀ _ hN0
  have hright : |∑ i, v (Sum.inr (Sum.inr i))*(Real.tanh (u i)-Real.tanh (t i))| ≤
      readoutL1 v*((d : ℝ)+1)*a := by
    calc
      _ ≤ ∑ i, |v (Sum.inr (Sum.inr i))*(Real.tanh (u i)-Real.tanh (t i))| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, |v (Sum.inr (Sum.inr i))| * (((d : ℝ)+1)*a) := by
        apply Finset.sum_le_sum
        intro i _
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (hhidden i) (abs_nonneg _)
      _ = _ := by rw [← Finset.sum_mul]; unfold readoutL1; ring
  exact add_le_add hleft hright

theorem coordinateCylinder_output_stability {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (w v : Weights d N 0) {ρ σ : ℝ} (hρ : 0 ≤ ρ) (hσ : 0 ≤ σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) (hw : w ∈ coordinateCylinder v ρ σ) (x : Cube d) :
    |networkOutput Real.tanh w x-networkOutput Real.tanh v x| ≤
      ρ+readoutL1 v*((d : ℝ)+1)*ρ/Real.sqrt d := by
  have h := shallow_output_stability hN w v (div_nonneg hρ (Real.sqrt_nonneg _)) hρ
    (fun i j => input_error_sharp hd hN hσ hρ hscale w v i j (hw _))
    (fun i => readout_error_of_whitened hd hN hσ hρ hscale w v i (hw _)) x
  simpa only [mul_div_assoc] using h

theorem readoutL1_cloned {d C N k p : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C 0) :
    readoutL1 (clonedWeights e w) = readoutL1 w := by
  classical
  have hkR : 0 < (k : ℝ) := by exact_mod_cast hk
  unfold readoutL1
  have he : (∑ i, |clonedWeights e w (Sum.inr (Sum.inr i))|) =
      ∑ i, match e.symm i with
        | Sum.inl (j,_) => |w (Sum.inr (Sum.inr j))|/(k : ℝ)
        | Sum.inr _ => 0 := by
    apply Finset.sum_congr rfl
    intro i _
    cases hi : e.symm i <;> simp [clonedWeights, hi, abs_div, abs_of_pos hkR]
  rw [he]
  have hc := sum_copies e (fun j => |w (Sum.inr (Sum.inr j))|/(k : ℝ))
  have he' : (∑ i, match e.symm i with
        | Sum.inl (j,_) => |w (Sum.inr (Sum.inr j))|/(k : ℝ)
        | Sum.inr _ => 0) = (k : ℝ)*∑ j, |w (Sum.inr (Sum.inr j))|/(k : ℝ) := by
    convert hc using 1
    apply Finset.sum_congr rfl
    intro i _
    cases hi : e.symm i with
    | inl jk => rcases jk with ⟨j,l⟩; rfl
    | inr z => rfl
  rw [he', ← Finset.sum_div]
  exact mul_div_cancel₀ _ hkR.ne'

theorem readoutL1_rescale {d N : ℕ} {s : ℝ} (hs : 0 ≤ s) (w : Weights d N 0) :
    readoutL1 (rescaleReadout s w) = s*readoutL1 w := by
  simp [readoutL1, rescaleReadout, abs_mul, abs_of_nonneg hs, Finset.mul_sum]

end NeuralGeneralization.BatchTwoShallow
