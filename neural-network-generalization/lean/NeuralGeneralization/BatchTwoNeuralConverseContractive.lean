import NeuralGeneralization.BatchTwoNeuralConverseNoise

/-! A concrete sufficient certificate for the singleton and constant constructions. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open ConcreteModel

theorem row_contraction_of_frobenius {N : ℕ} (W : Fin N → Fin N → ℝ)
    (a D : Fin N → ℝ) (hD : ∀ i, 0 ≤ D i ∧ D i ≤ 1)
    (hW : (∑ i, ∑ j, (W i j)^2) ≤ 1) :
    (∑ j, (∑ i, a i*D i*W i j)^2) ≤ ∑ i, (a i)^2 := by
  have hA : (∑ i, (a i*D i)^2) ≤ ∑ i, (a i)^2 := by
    apply Finset.sum_le_sum
    intro i _
    have hsq : (D i)^2 ≤ 1 := by nlinarith [(hD i).1, (hD i).2]
    have hm := mul_le_mul_of_nonneg_left hsq (sq_nonneg (a i))
    simpa only [mul_pow, mul_one] using hm
  calc
    _ ≤ ∑ j, (∑ i, (a i*D i)^2)*(∑ i, (W i j)^2) := by
      apply Finset.sum_le_sum
      intro j _
      exact Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun i => a i*D i) (fun i => W i j)
    _ = (∑ i, (a i*D i)^2)*(∑ i, ∑ j, (W i j)^2) := by
      rw [← Finset.mul_sum, Finset.sum_comm]
    _ ≤ (∑ i, (a i*D i)^2)*1 := mul_le_mul_of_nonneg_left hW (by positivity)
    _ ≤ _ := by simpa using hA

theorem pathRow_frobenius_bound {d N r : ℕ} (w : Weights d N r) (D : Slopes N r)
    (hD : D ∈ slopeCube N r)
    (hW : ∀ s : Fin r, (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2) ≤ 1)
    (ss : List (Fin r)) :
    (∑ i, (pathRow w D ss i)^2) ≤ ∑ i, w (Sum.inr (Sum.inr i))^2 := by
  induction ss with
  | nil => rfl
  | cons s ss ih =>
      apply (row_contraction_of_frobenius
        (fun i j => w (Sum.inr (Sum.inl (s,i,j)))) (pathRow w D ss) (D s)
        (fun i => ⟨hD.1 s i, hD.2 s i⟩) (hW s)).trans ih

theorem gainSq_frobenius_bound {d N r : ℕ} (w : Weights d N r)
    (hW : ∀ s : Fin r, (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2) ≤ 1) :
    gainSq w ≤ ((r : ℝ)+1)*readoutEnergy w := by
  unfold gainSq
  apply csSup_le ((slopeCube_nonempty N r).image _)
  rintro _ ⟨D,hD,rfl⟩
  unfold gainEnergy
  have hb := Finset.sum_le_sum (s := Finset.univ) (fun (j : Fin (r+1)) _ =>
    pathRow_frobenius_bound w D hD hW ((List.finRange r).drop j.val))
  have hm := mul_le_mul_of_nonneg_left hb (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
  simpa [readoutEnergy, mul_comm, mul_left_comm, mul_assoc] using hm

theorem mem_gainSupport_of_frobenius {d N r : ℕ} (w : Weights d N r)
    {Λ U : ℝ} (hΛ : 1 < Λ) (hv : 0 < readoutEnergy w)
    (hmargin : ∀ x : Cube d, (1 : ℝ)/2 < |networkOutput Real.tanh w x| ∧
      |networkOutput Real.tanh w x| < U)
    (hW : ∀ s : Fin r, (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2) ≤ 1) :
    w ∈ gainSupport Λ U := by
  refine ⟨hmargin, ?_⟩
  have hg := gainSq_frobenius_bound w hW
  have hH : 0 < ((r : ℝ)+1)*readoutEnergy w := by positivity
  have hsq : (1 : ℝ) < Λ^2 := by nlinarith
  have hm := mul_lt_mul_of_pos_right hsq hH
  nlinarith

end
end NeuralGeneralization.BatchTwoNeuralConverse
