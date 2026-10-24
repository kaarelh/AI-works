import NeuralGeneralization.BatchTwoNeuralConversePointFeatures
import NeuralGeneralization.BatchTwoNeuralConverseAllocation
import NeuralGeneralization.BatchTwoNeuralConverseRelays
import NeuralGeneralization.BatchTwoNeuralConverseContractive

/-! An actual finite-width, same-depth exact singleton network. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical
open ConcreteModel

def singletonWeights {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ) (r : ℕ) (t : ℝ) :
    Weights d (allocationWidth b) r
  | Sum.inl (i,j) => pointFeatureWeights a (allocationLabel b i) j
  | Sum.inr (Sum.inl (s,i,j)) => if s.val=0 then
      b (allocationLabel b j)/(8*(featureCopies b (allocationLabel b j) : ℝ))
    else relayFactor (r+1)/(allocationWidth b : ℝ)
  | Sum.inr (Sum.inr i) => if r=0 then
      t*b (allocationLabel b i)/(featureCopies b (allocationLabel b i) : ℝ)
    else t/((allocationWidth b : ℝ)*relayAmplitude (r+1) (r-1))

theorem singleton_firstHidden {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (r : ℕ) (t : ℝ) (x : Cube d) (i : Fin (allocationWidth b)) :
    firstHidden Real.tanh (singletonWeights a b r t) x i =
      shellFeature (shellIndex a x) (allocationLabel b i) := by
  exact pointFeature_value a x (allocationLabel b i)

theorem singleton_first_internal {d r : ℕ} (hr : 0 < r) (a : Cube d)
    (b : Fin (d+1) → ℝ) (t : ℝ)
    (hb : ∀ x : Cube d, (∑ j, b j*shellFeature (shellIndex a x) j) = if x=a then 1 else 0)
    (x : Cube d) (i : Fin (allocationWidth b)) :
    cleanAfter (singletonWeights a b r t) x 1 i =
      if x=a then relayAmplitude (r+1) 0 else 0 := by
  rw [cleanAfter_succ (singletonWeights a b r t) x (⟨0,hr⟩ : Fin r)]
  simp only [hiddenStep, singletonWeights, ↓reduceIte, cleanAfter, List.take_zero,
    List.foldl_nil, singleton_firstHidden]
  have he : (∑ j : Fin (allocationWidth b),
      b (allocationLabel b j)/(8*(featureCopies b (allocationLabel b j) : ℝ))*
        shellFeature (shellIndex a x) (allocationLabel b j)) =
      (∑ j : Fin (d+1), b j*shellFeature (shellIndex a x) j)/8 := by
    rw [← allocated_linear_identity b (shellFeature (shellIndex a x)), Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he, hb x]
  by_cases hx : x=a <;> simp [hx, relayAmplitude]

theorem singleton_later_internal {d r : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (t z : ℝ) (s : Fin r) (hs : s.val ≠ 0) (i : Fin (allocationWidth b)) :
    hiddenStep Real.tanh (singletonWeights a b r t) (fun _ => z) s i =
      Real.tanh (relayFactor (r+1)*z) := by
  have hN : (allocationWidth b : ℝ) ≠ 0 := by exact_mod_cast (allocationWidth_pos b).ne'
  simp only [hiddenStep, singletonWeights, hs, ↓reduceIte, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  congr 1
  field_simp

theorem singleton_cleanAfter {d r : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ) (t : ℝ)
    (hb : ∀ x : Cube d, (∑ j, b j*shellFeature (shellIndex a x) j) = if x=a then 1 else 0)
    (x : Cube d) (n : ℕ) (hn : n<r) (i : Fin (allocationWidth b)) :
    cleanAfter (singletonWeights a b r t) x (n+1) i =
      if x=a then relayAmplitude (r+1) n else 0 := by
  induction n generalizing i with
  | zero => exact singleton_first_internal (by omega) a b t hb x i
  | succ n ih =>
      have hs : n+1<r := hn
      rw [show n+1+1=(⟨n+1,hs⟩ : Fin r).val+1 by rfl, cleanAfter_succ]
      have hstate : cleanAfter (singletonWeights a b r t) x (n+1) =
          fun _ => if x=a then relayAmplitude (r+1) n else 0 := by
        funext j
        exact ih (by omega) j
      rw [hstate, singleton_later_internal a b t _ _ (by simp)]
      by_cases hx : x=a <;> simp [hx, relayAmplitude]

theorem singleton_output {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ) (r : ℕ) (t : ℝ)
    (hb : ∀ x : Cube d, (∑ j, b j*shellFeature (shellIndex a x) j) = if x=a then 1 else 0)
    (x : Cube d) :
    networkOutput Real.tanh (singletonWeights a b r t) x = if x=a then t else 0 := by
  have hN : (allocationWidth b : ℝ) ≠ 0 := by exact_mod_cast (allocationWidth_pos b).ne'
  by_cases hr : r=0
  · subst r
    unfold networkOutput finalHidden
    simp only [List.finRange_zero, List.foldl_nil, singleton_firstHidden, singletonWeights, ↓reduceIte]
    have he : (∑ i : Fin (allocationWidth b),
        t*b (allocationLabel b i)/(featureCopies b (allocationLabel b i) : ℝ)*
          shellFeature (shellIndex a x) (allocationLabel b i)) =
        t*(∑ j : Fin (d+1), b j*shellFeature (shellIndex a x) j) := by
      rw [← allocated_linear_identity b (shellFeature (shellIndex a x)), Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [he, hb x]
    by_cases hx : x=a <;> simp [hx]
  · have hrp : 0<r := Nat.pos_of_ne_zero hr
    have htake : (List.finRange r).take r = List.finRange r := by
      simpa only [List.length_finRange] using (List.take_length (l := List.finRange r))
    have hstate (i : Fin (allocationWidth b)) :
        finalHidden Real.tanh (singletonWeights a b r t) x i =
          if x=a then relayAmplitude (r+1) (r-1) else 0 := by
      have h := singleton_cleanAfter (r := r) a b t hb x (r-1) (by omega) i
      have he : r-1+1=r := by omega
      simpa only [he, cleanAfter, htake, finalHidden] using h
    unfold networkOutput
    simp_rw [hstate]
    simp only [singletonWeights, hr, ↓reduceIte, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    have ha : relayAmplitude (r+1) (r-1) ≠ 0 := (relayAmplitude_pos (Nat.succ_pos _) _).ne'
    by_cases hx : x=a <;> simp only [hx, ↓reduceIte, mul_zero]
    field_simp


theorem singleton_first_energy {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (r : ℕ) (t : ℝ) :
    (d : ℝ)/(allocationWidth b : ℝ)*(∑ i, ∑ j,
      (singletonWeights a b r t (Sum.inl (i,j)))^2) ≤ d*firstFeatureBudget d := by
  have hN : (allocationWidth b : ℝ) ≠ 0 := by exact_mod_cast (allocationWidth_pos b).ne'
  have hrows := Finset.sum_le_sum (s := Finset.univ) (fun (i : Fin (allocationWidth b)) _ =>
    pointFeature_row_bound a (allocationLabel b i))
  have hm := mul_le_mul_of_nonneg_left hrows
    (show 0 ≤ (d : ℝ)/(allocationWidth b : ℝ) by positivity)
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at hm
  change (d : ℝ)/(allocationWidth b : ℝ)*(∑ i, ∑ j,
    (pointFeatureWeights a (allocationLabel b i) j)^2) ≤ _
  calc
    _ ≤ (d : ℝ)/(allocationWidth b : ℝ)*((allocationWidth b : ℝ)*firstFeatureBudget d) := hm
    _ = _ := by field_simp

theorem singleton_internal_frobenius {d r : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (t : ℝ) (hb : vectorL1 b ≤ 4) (s : Fin r) :
    (∑ i, ∑ j, (singletonWeights a b r t (Sum.inr (Sum.inl (s,i,j))))^2) ≤ 1 := by
  have hN : (allocationWidth b : ℝ) ≠ 0 := by exact_mod_cast (allocationWidth_pos b).ne'
  by_cases hs : s.val=0
  · simp only [singletonWeights, hs, ↓reduceIte, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have he : (∑ j : Fin (allocationWidth b),
        (b (allocationLabel b j)/(8*(featureCopies b (allocationLabel b j) : ℝ)))^2) =
        (∑ i : Fin (d+1), (b i)^2/(featureCopies b i : ℝ))/64 := by
      rw [← allocated_square_identity b, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [he]
    have h := allocated_energy_le_seventeen b hb
    linarith
  · simp only [singletonWeights, hs, ↓reduceIte, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have he : (allocationWidth b : ℝ)*((allocationWidth b : ℝ)*
        (relayFactor (r+1)/(allocationWidth b : ℝ))^2) = (relayFactor (r+1))^2 := by
      field_simp
    rw [he]
    have h := relayFactor_bounds (Nat.succ_pos r)
    nlinarith

def singletonReadoutBudget (H : ℕ) : ℝ := 4*(H+65 : ℝ)
def singletonBaseBudget (d H : ℕ) : ℝ := d*firstFeatureBudget d+H

theorem singleton_readout_bound {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (r : ℕ) (t : ℝ) (hb : vectorL1 b ≤ 4) :
    readoutEnergy (singletonWeights a b r t) ≤ singletonReadoutBudget (r+1)*t^2 := by
  have hN : (allocationWidth b : ℝ) ≠ 0 := by exact_mod_cast (allocationWidth_pos b).ne'
  by_cases hr : r=0
  · subst r
    unfold readoutEnergy
    simp only [singletonWeights, ↓reduceIte]
    have he : (∑ i : Fin (allocationWidth b),
        (t*b (allocationLabel b i)/(featureCopies b (allocationLabel b i) : ℝ))^2) =
        t^2*(∑ i : Fin (d+1), (b i)^2/(featureCopies b i : ℝ)) := by
      rw [← allocated_square_identity b, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [he]
    have hm := mul_le_mul_of_nonneg_right (allocated_energy_le_seventeen b hb) (sq_nonneg t)
    norm_num [singletonReadoutBudget]
    nlinarith [sq_nonneg t]
  · unfold readoutEnergy
    simp only [singletonWeights, hr, ↓reduceIte, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    have he : (allocationWidth b : ℝ)*((allocationWidth b : ℝ)*
        (t/((allocationWidth b : ℝ)*relayAmplitude (r+1) (r-1)))^2) =
        t^2*(1/(relayAmplitude (r+1) (r-1))^2) := by field_simp
    rw [he]
    have h := relayAmplitude_inverse_bound (Nat.succ_pos r) (show r-1 ≤ r+1 by omega)
    have hm := mul_le_mul_of_nonneg_left h (sq_nonneg t)
    simpa [singletonReadoutBudget, mul_comm, add_comm] using hm

theorem singleton_energy_bound {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (r : ℕ) (t : ℝ) (hb : vectorL1 b ≤ 4) :
    weightedSquaredNorm (singletonWeights a b r t) ≤
      singletonBaseBudget d (r+1)+singletonReadoutBudget (r+1)*t^2 := by
  have hfirst := singleton_first_energy a b r t
  have hinternal := Finset.sum_le_sum (s := Finset.univ) (fun (s : Fin r) _ =>
    singleton_internal_frobenius a b t hb s)
  have hlast := singleton_readout_bound a b r t hb
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one] at hinternal
  unfold weightedSquaredNorm singletonBaseBudget
  unfold readoutEnergy at hlast
  push_cast
  linarith


theorem readoutEnergy_pos_of_output_ne_zero {d N r : ℕ} (w : Weights d N r)
    (x : Cube d) (hx : networkOutput Real.tanh w x ≠ 0) : 0 < readoutEnergy w := by
  by_contra hn
  have hz : readoutEnergy w=0 := le_antisymm (le_of_not_gt hn) (readoutEnergy_nonneg w)
  by_cases hN : N=0
  · subst N
    exact hx (by simp [networkOutput])
  have hNp : (0 : ℝ)<N := by exact_mod_cast Nat.pos_of_ne_zero hN
  have hsum : (∑ i, w (Sum.inr (Sum.inr i))^2)=0 :=
    (mul_eq_zero.mp hz).resolve_left hNp.ne'
  have hw (i : Fin N) : w (Sum.inr (Sum.inr i))=0 := by
    have hs := Finset.single_le_sum (fun j (_ : j ∈ (Finset.univ : Finset (Fin N))) =>
      sq_nonneg (w (Sum.inr (Sum.inr j)))) (Finset.mem_univ i)
    rw [hsum] at hs
    nlinarith [sq_nonneg (w (Sum.inr (Sum.inr i)))]
  exact hx (by simp [networkOutput, hw])

theorem singleton_gain_strict {d : ℕ} (a : Cube d) (b : Fin (d+1) → ℝ)
    (r : ℕ) (t Λ : ℝ) (ht : t ≠ 0) (hΛ : 1<Λ) (hb : vectorL1 b ≤ 4)
    (hinterp : ∀ x : Cube d, (∑ j, b j*shellFeature (shellIndex a x) j) = if x=a then 1 else 0) :
    gainSq (singletonWeights a b r t) <
      Λ^2*((r : ℝ)+1)*readoutEnergy (singletonWeights a b r t) := by
  have ho : networkOutput Real.tanh (singletonWeights a b r t) a ≠ 0 := by
    simpa [singleton_output a b r t hinterp] using ht
  have hv := readoutEnergy_pos_of_output_ne_zero (singletonWeights a b r t) a ho
  have hg := gainSq_frobenius_bound (singletonWeights a b r t)
    (singleton_internal_frobenius a b t hb)
  have hH : 0<((r : ℝ)+1)*readoutEnergy (singletonWeights a b r t) := by positivity
  have hsq : (1 : ℝ)<Λ^2 := by nlinarith
  have hm := mul_lt_mul_of_pos_right hsq hH
  nlinarith

/-- Exact finite-width singleton repair with the paper's polynomial energy budget. -/
theorem exists_singleton_network {d : ℕ} (hd : 0<d) (a : Cube d) (r : ℕ)
    (t Λ : ℝ) (ht : t ≠ 0) (hΛ : 1<Λ) :
    ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r,
      (∀ x, networkOutput Real.tanh w x = if x=a then t else 0) ∧
      weightedSquaredNorm w ≤ singletonBaseBudget d (r+1)+singletonReadoutBudget (r+1)*t^2 ∧
      gainSq w < Λ^2*((r : ℝ)+1)*readoutEnergy w := by
  obtain ⟨b,hb,hinterp⟩ := exists_exact_shell_indicator d hd
  have hi (x : Cube d) : (∑ j, b j*shellFeature (shellIndex a x) j) = if x=a then 1 else 0 := by
    rw [hinterp]
    simp only [shellIndex_eq_zero]
  exact ⟨allocationWidth b,allocationWidth_pos b,singletonWeights a b r t,
    singleton_output a b r t hi,singleton_energy_bound a b r t hb,
    singleton_gain_strict a b r t Λ ht hΛ hb hi⟩

end
end NeuralGeneralization.BatchTwoNeuralConverse
