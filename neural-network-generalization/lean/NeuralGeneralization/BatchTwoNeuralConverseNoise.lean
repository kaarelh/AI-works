import NeuralGeneralization.BatchTwoNeuralConverseModel
import NeuralGeneralization.RobustStatisticsCoupling

/-! Finite disturbances are controlled by the stated global slope certificate. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open ConcreteModel

variable {d N r : ℕ}

def cleanAfter (w : Weights d N r) (x : Cube d) (t : ℕ) : Fin N → ℝ :=
  ((List.finRange r).take t).foldl (hiddenStep Real.tanh w) (firstHidden Real.tanh w x)

def noisyAfter (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) (t : ℕ) : Fin N → ℝ :=
  ((List.finRange r).take t).foldl (noisyHiddenStep Real.tanh w η) (noisyFirstHidden Real.tanh w x η)

def differenceAfter (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r)
    (t : ℕ) (i : Fin N) : ℝ := noisyAfter w x η t i-cleanAfter w x t i

def realizedSlopes (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) : Slopes N r :=
  fun s i => tanhSlope
    (∑ j, w (Sum.inr (Sum.inl (s,i,j)))*noisyAfter w x η s.val j)
    (∑ j, w (Sum.inr (Sum.inl (s,i,j)))*cleanAfter w x s.val j)

theorem realizedSlopes_mem (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) :
    realizedSlopes w x η ∈ slopeCube N r := by
  exact ⟨fun s i => (tanhSlope_bounds _ _).1, fun s i => (tanhSlope_bounds _ _).2⟩

theorem cleanAfter_succ (w : Weights d N r) (x : Cube d) (s : Fin r) :
    cleanAfter w x (s.val+1) = hiddenStep Real.tanh w (cleanAfter w x s.val) s := by
  unfold cleanAfter
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt), List.foldl_append]
  simp only [List.foldl_cons, List.foldl_nil, List.getElem_finRange]
  rfl

theorem noisyAfter_succ (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) (s : Fin r) :
    noisyAfter w x η (s.val+1) = noisyHiddenStep Real.tanh w η (noisyAfter w x η s.val) s := by
  unfold noisyAfter
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt), List.foldl_append]
  simp only [List.foldl_cons, List.foldl_nil, List.getElem_finRange]
  rfl

theorem differenceAfter_zero (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) (i : Fin N) :
    differenceAfter w x η 0 i = η.1 0 i := by
  simp [differenceAfter, cleanAfter, noisyAfter, noisyFirstHidden]

theorem differenceAfter_succ (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r)
    (s : Fin r) (i : Fin N) :
    differenceAfter w x η (s.val+1) i =
      realizedSlopes w x η s i *
        (∑ j, w (Sum.inr (Sum.inl (s,i,j)))*differenceAfter w x η s.val j)+η.1 s.succ i := by
  unfold differenceAfter
  rw [noisyAfter_succ, cleanAfter_succ]
  simp only [noisyHiddenStep, hiddenStep, mul_sub, Finset.sum_sub_distrib, realizedSlopes]
  rw [← mul_sub, tanhSlope_mul]
  ring

theorem pathRow_drop (w : Weights d N r) (D : Slopes N r) (s : Fin r) (j : Fin N) :
    pathRow w D ((List.finRange r).drop s.val) j =
      ∑ i, pathRow w D ((List.finRange r).drop (s.val+1)) i * D s i *
        w (Sum.inr (Sum.inl (s,i,j))) := by
  rw [List.drop_eq_getElem_cons (by simpa using s.isLt)]
  have hidx : (List.finRange r)[s.val]'(by simpa using s.isLt) = s := by
    apply Fin.ext
    simp
  rw [hidx]
  rfl

def propagatedPotential (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) (t : ℕ) : ℝ :=
  ∑ i, pathRow w (realizedSlopes w x η) ((List.finRange r).drop t) i * differenceAfter w x η t i

theorem propagatedPotential_step (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r)
    (s : Fin r) :
    propagatedPotential w x η (s.val+1)-propagatedPotential w x η s.val =
      ∑ i, pathRow w (realizedSlopes w x η) ((List.finRange r).drop (s.val+1)) i * η.1 s.succ i := by
  unfold propagatedPotential
  simp_rw [differenceAfter_succ w x η s, mul_add, Finset.sum_add_distrib]
  have he : (∑ i, pathRow w (realizedSlopes w x η) ((List.finRange r).drop (s.val+1)) i *
      (realizedSlopes w x η s i * ∑ j, w (Sum.inr (Sum.inl (s,i,j)))*differenceAfter w x η s.val j)) =
      ∑ j, pathRow w (realizedSlopes w x η) ((List.finRange r).drop s.val) j * differenceAfter w x η s.val j := by
    simp_rw [pathRow_drop w (realizedSlopes w x η) s, Finset.sum_mul, Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j _
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he]
  ring

theorem noisy_difference_expansion (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) :
    noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x =
      (∑ j : Fin (r+1), ∑ i, pathRow w (realizedSlopes w x η)
        ((List.finRange r).drop j.val) i*η.1 j i)+η.2 := by
  let F := propagatedPotential w x η
  have ht := Finset.sum_range_sub F r
  rw [← Fin.sum_univ_eq_sum_range] at ht
  have htel : (∑ s : Fin r, ∑ i, pathRow w (realizedSlopes w x η)
      ((List.finRange r).drop (s.val+1)) i*η.1 s.succ i) = F r-F 0 := by
    rw [← ht]
    apply Finset.sum_congr rfl
    intro s _
    exact (propagatedPotential_step w x η s).symm
  have htake : (List.finRange r).take r = List.finRange r := by
    simpa only [List.length_finRange] using (List.take_length (l := List.finRange r))
  have hdrop : (List.finRange r).drop r = [] := by
    simpa only [List.length_finRange] using (List.drop_length (l := List.finRange r))
  have hF : F r = noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x-η.2 := by
    dsimp [F, propagatedPotential, differenceAfter, noisyAfter, cleanAfter]
    rw [htake, hdrop]
    simp only [pathRow, mul_sub, Finset.sum_sub_distrib, noisyNetworkOutput, networkOutput,
      noisyFinalHidden, finalHidden]
    ring
  have hF0 : F 0 = ∑ i, pathRow w (realizedSlopes w x η) (List.finRange r) i*η.1 0 i := by
    simp [F, propagatedPotential, differenceAfter_zero]
  rw [Fin.sum_univ_succ]
  simp only [Fin.val_zero, List.drop_zero, Fin.val_succ]
  rw [htel, hF, hF0]
  ring

theorem noisy_difference_sq_le (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) :
    (noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x)^2 ≤
      (1+gainSq w)*noiseBudgetSq η := by
  let a : Fin (r+1) × Fin N → ℝ := fun p =>
    pathRow w (realizedSlopes w x η) ((List.finRange r).drop p.1.val) p.2
  let b : Fin (r+1) × Fin N → ℝ := fun p => η.1 p.1 p.2
  have hc := BatchTwoShallow.weighted_cauchy a b η.2 (Nat.cast_pos.mpr hN)
  simp only [Fintype.sum_prod_type, a, b] at hc
  rw [noisy_difference_expansion]
  have hg := gainEnergy_le_gainSq w (realizedSlopes w x η) (realizedSlopes_mem w x η)
  change (N : ℝ)*(∑ j : Fin (r+1), ∑ i, pathRow w (realizedSlopes w x η)
    ((List.finRange r).drop j.val) i^2) ≤ gainSq w at hg
  change _ ≤ (1+gainSq w)*((∑ j : Fin (r+1), ∑ i, (η.1 j i)^2)/(N : ℝ)+η.2^2)
  exact hc.trans (mul_le_mul_of_nonneg_right (by linarith) (noiseBudgetSq_nonneg η))

theorem certified_noise_sq_le (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) {Λ : ℝ} (hΛ : 1 < Λ)
    (hgain : gainSq w < Λ^2*((r : ℝ)+1)*readoutEnergy w) :
    (noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x)^2 ≤
      Λ^2*(1+((r : ℝ)+1)*readoutEnergy w)*noiseBudgetSq η := by
  apply (noisy_difference_sq_le hN w x η).trans
  apply mul_le_mul_of_nonneg_right _ (noiseBudgetSq_nonneg η)
  nlinarith

/-- The stated global gain condition certifies the original finite-disturbance
restriction with c=1/(16Λ), not merely a derivative at the clean trajectory. -/
theorem gain_support_subset_robust (hN : 0 < N) {Λ U : ℝ} (hΛ : 1 < Λ) :
    gainSupport (d := d) (N := N) (r := r) Λ U ⊆
      robustEvent Real.tanh (1/(16*Λ)) := by
  intro w hw x η hη
  have hden : 0 < 1+((r : ℝ)+1)*readoutEnergy w := by
    have hn := readoutEnergy_nonneg w
    positivity
  have hraw := certified_noise_sq_le hN w x η hΛ hw.2
  have hmul := mul_le_mul_of_nonneg_left hη
    (show 0 ≤ Λ^2*(1+((r : ℝ)+1)*readoutEnergy w) by positivity)
  have he : Λ^2*(1+((r : ℝ)+1)*readoutEnergy w)*
      (robustRadius (1/(16*Λ)) w)^2 = (1/16 : ℝ)^2 := by
    unfold robustRadius
    rw [div_pow, Real.sq_sqrt hden.le]
    have hΛ0 : Λ ≠ 0 := by linarith
    field_simp
  rw [he] at hmul
  have hab : |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤ (1 : ℝ)/16 := by
    apply (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1/16)).mp
    rw [sq_abs]
    exact hraw.trans hmul
  exact (RobustStatistics.clippedScore_lipschitz _ _).trans hab

end
end NeuralGeneralization.BatchTwoNeuralConverse
