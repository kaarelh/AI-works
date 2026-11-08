import NeuralGeneralization.OnlineLowerReluScalar
import Mathlib.Logic.Equiv.Fintype
import Mathlib.Data.Fintype.Fin
import Mathlib.Data.Fintype.Perm
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Tactic.Positivity.Basic

/-!
# The sharp top-parity bound for monotone Boolean-cube functions

Permutation symmetrization reduces the claim to an increasing sequence of
Hamming-layer values. No antichain or probabilistic representation is assumed.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

/-- Sum over coordinate permutations, without normalization. -/
def permutationSum {n : ℕ} (f : Finset (Fin n) → ℝ) (S : Finset (Fin n)) : ℝ :=
  ∑ π : Equiv.Perm (Fin n), f (S.image π)

/-- Coordinate symmetrization depends only on the cardinality of the input. -/
theorem permutationSum_same_card {n : ℕ} (f : Finset (Fin n) → ℝ)
    (S T : Finset (Fin n)) (hcard : S.card = T.card) :
    permutationSum f S = permutationSum f T := by
  classical
  obtain ⟨σ, hσ⟩ := Equiv.Perm.exists_map_finset_eq S T hcard
  have hσ' : S.image σ = T := by simpa [Finset.map_eq_image] using hσ
  have he (π : Equiv.Perm (Fin n)) : S.image (π * σ) = T.image π := by
    rw [← hσ', Finset.image_image]
    rfl
  have h := Equiv.sum_comp (Equiv.mulRight σ)
    (fun π : Equiv.Perm (Fin n) => f (S.image π))
  change (∑ π : Equiv.Perm (Fin n), f (S.image (π * σ))) = _ at h
  simp_rw [he] at h
  exact h.symm

theorem permutationSum_mono {n : ℕ} {f : Finset (Fin n) → ℝ}
    (hf : Monotone f) : Monotone (permutationSum f) := by
  classical
  intro S T hST
  apply Finset.sum_le_sum
  intro π _
  exact hf (Finset.image_subset_image hST)

theorem permutationSum_nonneg {n : ℕ} {f : Finset (Fin n) → ℝ}
    (hf : ∀ S, 0 ≤ f S) (S : Finset (Fin n)) : 0 ≤ permutationSum f S := by
  classical
  exact Finset.sum_nonneg (fun π _ => hf _)

theorem permutationSum_le_card {n : ℕ} {f : Finset (Fin n) → ℝ}
    (hf : ∀ S, f S ≤ 1) (S : Finset (Fin n)) :
    permutationSum f S ≤ (Fintype.card (Equiv.Perm (Fin n)) : ℝ) := by
  classical
  calc
    permutationSum f S ≤ ∑ _π : Equiv.Perm (Fin n), (1 : ℝ) :=
      Finset.sum_le_sum (fun π _ => hf _)
    _ = _ := by simp

/-- The parity sum is invariant under a coordinate permutation. -/
theorem parity_sum_permute {n : ℕ} (f : Finset (Fin n) → ℝ)
    (π : Equiv.Perm (Fin n)) :
    (∑ S : Finset (Fin n), (-1 : ℝ) ^ S.card * f (S.image π)) =
      ∑ S : Finset (Fin n), (-1 : ℝ) ^ S.card * f S := by
  classical
  have h := π.finsetCongr.sum_comp
    (fun S : Finset (Fin n) => (-1 : ℝ) ^ S.card * f S)
  simpa [Equiv.finsetCongr_apply, Finset.map_eq_image,
    Finset.card_image_of_injective _ π.injective] using h

/-- Summing over permutations multiplies the parity sum by the group size. -/
theorem parity_sum_permutationSum {n : ℕ} (f : Finset (Fin n) → ℝ) :
    (∑ S : Finset (Fin n), (-1 : ℝ) ^ S.card * permutationSum f S) =
      (Fintype.card (Equiv.Perm (Fin n)) : ℝ) *
        ∑ S : Finset (Fin n), (-1 : ℝ) ^ S.card * f S := by
  classical
  unfold permutationSum
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  simp_rw [parity_sum_permute]
  simp [Finset.mul_sum]

/-- The first `k` coordinates, truncated at the ambient dimension. -/
def initialCoordinates (n k : ℕ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => i.val < k)

theorem initialCoordinates_mono (n : ℕ) : Monotone (initialCoordinates n) := by
  intro j k hjk i hi
  simp only [initialCoordinates, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  exact lt_of_lt_of_le hi hjk

theorem initialCoordinates_card (n k : ℕ) (hk : k ≤ n) :
    (initialCoordinates n k).card = k := by
  simp [initialCoordinates, Fin.card_filter_val_lt, Nat.min_eq_right hk]

/-- Sharp unnormalized top-parity bound for an arbitrary monotone function
on a nonempty Boolean cube with values in `[0,1]`. -/
theorem monotone_subset_parity_bound (n : ℕ) (f : Finset (Fin (n + 1)) → ℝ)
    (hmono : Monotone f) (hzero : ∀ S, 0 ≤ f S) (hone : ∀ S, f S ≤ 1) :
    |∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f S| ≤
      (n.choose (n / 2) : ℝ) := by
  classical
  let P : ℝ := Fintype.card (Equiv.Perm (Fin (n + 1)))
  let h : ℕ → ℝ := fun k => permutationSum f (initialCoordinates (n + 1) k)
  have hP : 0 < P := by
    dsimp [P]
    exact_mod_cast Fintype.card_pos
  have hmono' : ∀ k < n + 1, h k ≤ h (k + 1) := by
    intro k _
    exact permutationSum_mono hmono (initialCoordinates_mono _ (Nat.le_succ k))
  have hnonneg : 0 ≤ h 0 := permutationSum_nonneg hzero _
  have hupper : h (n + 1) ≤ P := permutationSum_le_card hone _
  have heq (S : Finset (Fin (n + 1))) : permutationSum f S = h S.card := by
    apply permutationSum_same_card
    rw [initialCoordinates_card]
    simpa only [Fintype.card_fin] using Finset.card_le_univ S
  have hsum : (∑ S : Finset (Fin (n + 1)),
      (-1 : ℝ) ^ S.card * permutationSum f S) = alternatingBinomial (n + 1) h := by
    simp_rw [heq]
    exact subset_parity_sum_eq_alternatingBinomial _ _
  have hbound := alternatingBinomial_abs_le_middle n h hmono'
  rw [← hsum, parity_sum_permutationSum, abs_mul, abs_of_pos hP] at hbound
  have hcentral : (0 : ℝ) ≤ (n.choose (n / 2) : ℝ) := Nat.cast_nonneg _
  change P * |∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f S| ≤
    (n.choose (n / 2) : ℝ) * (h (n + 1) - h 0) at hbound
  nlinarith

/-- The same sharp estimate on an arbitrary finite coordinate type. -/
theorem monotone_fintype_subset_parity_bound {ι : Type*} [Fintype ι] [DecidableEq ι]
    (n : ℕ) (hcard : Fintype.card ι = n + 1) (f : Finset ι → ℝ)
    (hmono : Monotone f) (hzero : ∀ S, 0 ≤ f S) (hone : ∀ S, f S ≤ 1) :
    |∑ S : Finset ι, (-1 : ℝ) ^ S.card * f S| ≤ (n.choose (n / 2) : ℝ) := by
  classical
  let e : ι ≃ Fin (n + 1) := Fintype.equivOfCardEq (by simpa using hcard)
  let g : Finset (Fin (n + 1)) → ℝ := fun S => f (S.image e.symm)
  have hg : Monotone g := fun _ _ h => hmono (Finset.image_subset_image h)
  have hbound := monotone_subset_parity_bound n g hg (fun S => hzero _) (fun S => hone _)
  have hsum := Equiv.sum_comp e.symm.finsetCongr
    (fun S : Finset ι => (-1 : ℝ) ^ S.card * f S)
  simp only [Equiv.finsetCongr_apply, Finset.map_eq_image] at hsum
  change (∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ (S.image e.symm).card *
    f (S.image e.symm)) = _ at hsum
  simp_rw [Finset.card_image_of_injective _ e.symm.injective] at hsum
  change |∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f (S.image e.symm)| ≤ _ at hbound
  rwa [hsum] at hbound

/-- A positive-weight affine score, with a subset denoting its positive signs.
The constant term absorbs the contribution of the negative signs. -/
def affineSubsetScore {n : ℕ} (c : ℝ) (w : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  c + 2 * ∑ i ∈ S, w i

theorem affineSubsetScore_mono {n : ℕ} (c : ℝ) (w : Fin n → ℝ)
    (hw : ∀ i, 0 ≤ w i) : Monotone (affineSubsetScore c w) := by
  classical
  intro S T hST
  unfold affineSubsetScore
  have hsum : (∑ i ∈ S, w i) ≤ ∑ i ∈ T, w i :=
    Finset.sum_le_sum_of_subset_of_nonneg hST (fun i _ _ => hw i)
  linarith

/-- A ReLU parity coefficient after conditioning its distinguished sign.
This is the literal finite sum over the remaining Boolean cube. -/
def differenceParity (n : ℕ) (a c : ℝ) (w : Fin (n + 1) → ℝ) : ℝ :=
  (∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card *
    reluDifference a (affineSubsetScore c w S)) / (2 : ℝ) ^ (n + 2)

/-- The parity estimate depends on monotonicity of the remaining score,
not on that score being affine. This is used for parity-conditioned rails. -/
theorem monotone_score_difference_parity_bound (n : ℕ) (a : ℝ)
    (score : Finset (Fin (n + 1)) → ℝ) (ha : 0 ≤ a)
    (hscore : Monotone score) :
    |(∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card *
        reluDifference a (score S)) / (2 : ℝ) ^ (n + 2)| ≤
      a * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
  classical
  rcases ha.eq_or_lt with h | h
  · subst a
    simp [reluDifference]
  let f : Finset (Fin (n + 1)) → ℝ := fun S => reluDifference a (score S) / (2 * a)
  obtain ⟨hmono, hrange⟩ := normalized_reluDifference_properties h
  have hcoef := monotone_subset_parity_bound n f (hmono.comp hscore)
    (fun S => (hrange _).1) (fun S => (hrange _).2)
  have hfactor : (∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card *
      reluDifference a (score S)) =
      (2 * a) * ∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f S := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S _
    dsimp [f]
    field_simp [h.ne']
  rw [hfactor, abs_div, abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 2 * a),
    abs_of_pos (by positivity : (0 : ℝ) < 2 ^ (n + 2))]
  calc
    (2 * a) * |∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f S| /
        (2 : ℝ) ^ (n + 2) ≤
      (2 * a) * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 2) := by
      exact div_le_div_of_nonneg_right
        (mul_le_mul_of_nonneg_left hcoef (by positivity)) (by positivity)
    _ = _ := by
      rw [show n + 2 = (n + 1) + 1 by omega, pow_succ]
      field_simp

/-- The sharp minimum-coordinate estimate at a positive distinguished weight.
For an even total degree `n+2`, its coefficient is exactly the paper's κ.
Remaining coordinate signs can subsequently be changed by cube symmetries. -/
theorem differenceParity_abs_le (n : ℕ) (a c : ℝ) (w : Fin (n + 1) → ℝ)
    (ha : 0 < a) (hw : ∀ i, 0 ≤ w i) :
    |differenceParity n a c w| ≤
      a * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
  classical
  let f : Finset (Fin (n + 1)) → ℝ := fun S =>
    reluDifference a (affineSubsetScore c w S) / (2 * a)
  obtain ⟨hmono, hrange⟩ := normalized_reluDifference_properties ha
  have hfmono : Monotone f := hmono.comp (affineSubsetScore_mono c w hw)
  have hcoef := monotone_subset_parity_bound n f hfmono
    (fun S => (hrange _).1) (fun S => (hrange _).2)
  have hfactor : (∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card *
      reluDifference a (affineSubsetScore c w S)) =
      (2 * a) * ∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f S := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S _
    dsimp [f]
    field_simp [ha.ne']
  unfold differenceParity
  rw [hfactor, abs_div, abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 2 * a),
    abs_of_pos (by positivity : (0 : ℝ) < 2 ^ (n + 2))]
  calc
    (2 * a) * |∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card * f S| /
        (2 : ℝ) ^ (n + 2) ≤
      (2 * a) * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 2) := by
        exact div_le_div_of_nonneg_right
          (mul_le_mul_of_nonneg_left hcoef (by positivity)) (by positivity)
    _ = a * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
      rw [show n + 2 = (n + 1) + 1 by omega, pow_succ]
      field_simp

/-- The same estimate includes a zero distinguished weight: its conditional
difference, and hence its top parity coefficient, then vanish exactly. -/
theorem differenceParity_abs_le_nonneg (n : ℕ) (a c : ℝ)
    (w : Fin (n + 1) → ℝ) (ha : 0 ≤ a) (hw : ∀ i, 0 ≤ w i) :
    |differenceParity n a c w| ≤
      a * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
  rcases ha.eq_or_lt with h | h
  · subst a
    simp [differenceParity, reluDifference]
  · exact differenceParity_abs_le n a c w h hw

end NeuralGeneralization.OnlineLowerRelu
