import NeuralGeneralization.Network
import Mathlib.Combinatorics.SetFamily.Shatter
import Mathlib.LinearAlgebra.Dimension.Finrank
import Mathlib.LinearAlgebra.Dimension.Finite
import Mathlib.LinearAlgebra.Dimension.Constructions
import Mathlib.Data.Nat.Choose.Bounds
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

/-!
# Halfspace capacity for the shallow-network theorem

Halfspace patterns are defined by actual real coefficient vectors. Shattering
implies linear independence of the feature vectors; no VC-dimension estimate
is assumed. Sauer's lemma then gives the finite pattern count.
-/

noncomputable section
open scoped BigOperators
open Classical

namespace NeuralGeneralization.BatchTwoShallow

def dot {m : ℕ} (b u : Fin m → ℝ) : ℝ := ∑ j, b j * u j

theorem sum_dot_eq_zero {ι : Type*} [Fintype ι] {m : ℕ}
    (u : ι → Fin m → ℝ) (c : ι → ℝ) (b : Fin m → ℝ)
    (hc : ∑ i, c i • u i = 0) : ∑ i, c i * dot b (u i) = 0 := by
  have hj (j : Fin m) : ∑ i, c i * u i j = 0 := by
    have h := congrFun hc j
    simpa only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Pi.zero_apply] using h
  unfold dot
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  have he (j : Fin m) : (∑ i, c i * (b j * u i j)) = b j * ∑ i, c i * u i j := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  simp_rw [he, hj, mul_zero]
  simp

theorem linearIndependent_of_all_signs {ι : Type*} [Fintype ι] {m : ℕ}
    (u : ι → Fin m → ℝ)
    (hsign : ∀ A : Finset ι, ∃ b : Fin m → ℝ,
      ∀ i, 0 < dot b (u i) ↔ i ∈ A) : LinearIndependent ℝ u := by
  classical
  have hnonpos (c : ι → ℝ) (hc : ∑ i, c i • u i = 0) : ∀ i, c i ≤ 0 := by
    obtain ⟨b, hb⟩ := hsign (Finset.univ.filter (fun i => 0 < c i))
    have hs : ∑ i, c i * dot b (u i) = 0 := sum_dot_eq_zero u c b hc
    have hn (i : ι) : 0 ≤ c i * dot b (u i) := by
      by_cases hi : 0 < c i
      · have hd : 0 < dot b (u i) := (hb i).2 (by simp [hi])
        exact (mul_pos hi hd).le
      · have hd : dot b (u i) ≤ 0 := by
          by_contra hd
          have := (hb i).1 (lt_of_not_ge hd)
          simp [hi] at this
        exact mul_nonneg_of_nonpos_of_nonpos (le_of_not_gt hi) hd
    intro i
    by_contra hi
    have hci : 0 < c i := lt_of_not_ge hi
    have hd : 0 < dot b (u i) := (hb i).2 (by simp [hci])
    have hle := Finset.single_le_sum (s := Finset.univ) (fun j _ => hn j) (Finset.mem_univ i)
    rw [hs] at hle
    exact (not_le_of_gt (mul_pos hci hd)) hle
  apply Fintype.linearIndependent_iff.2
  intro c hc i
  have hp := hnonpos c hc i
  have hneg : ∑ j, (-c j) • u j = 0 := by
    simp only [neg_smul, Finset.sum_neg_distrib, hc, neg_zero]
  have hn := hnonpos (fun j => -c j) hneg i
  linarith

variable {X : Type*} [Fintype X] [DecidableEq X] {m : ℕ}

/-- All strict homogeneous halfspace patterns on the specified feature map.
An augmented constant feature makes these precisely affine halfspaces. -/
def halfspacePatterns (u : X → Fin m → ℝ) : Finset (Finset X) :=
  Finset.univ.filter (fun A => ∃ b : Fin m → ℝ, ∀ x, x ∈ A ↔ 0 < dot b (u x))

theorem shattered_linearIndependent (u : X → Fin m → ℝ) (S : Finset X)
    (hS : (halfspacePatterns u).Shatters S) :
    LinearIndependent ℝ (fun x : S => u x.val) := by
  classical
  apply linearIndependent_of_all_signs
  intro A
  let T : Finset X := A.image Subtype.val
  have hTS : T ⊆ S := by
    intro x hx
    obtain ⟨a, _, rfl⟩ := Finset.mem_image.mp hx
    exact a.property
  obtain ⟨P, hP, hSP⟩ := hS hTS
  obtain ⟨b, hb⟩ := (Finset.mem_filter.mp hP).2
  refine ⟨b, fun x => ?_⟩
  rw [← hb x.val]
  have he : x.val ∈ T ↔ x ∈ A := by
    simp only [T, Finset.mem_image]
    constructor
    · rintro ⟨a, ha, he⟩
      have hx : a = x := Subtype.ext he
      simpa [hx] using ha
    · intro hx
      exact ⟨x, hx, rfl⟩
  rw [← he, ← hSP]
  simp [x.property]

theorem shattered_card_le (u : X → Fin m → ℝ) (S : Finset X)
    (hS : (halfspacePatterns u).Shatters S) : S.card ≤ m := by
  have h := (shattered_linearIndependent u S hS).fintype_card_le_finrank
  simpa using h

theorem halfspace_vcDim_le (u : X → Fin m → ℝ) : (halfspacePatterns u).vcDim ≤ m := by
  unfold Finset.vcDim
  apply Finset.sup_le
  intro S hS
  exact shattered_card_le u S (Finset.mem_shatterer.mp hS)

theorem sum_powers_le (a m : ℕ) : ∑ k ∈ Finset.range (m + 1), a ^ k ≤ (a + 1) ^ m := by
  induction m with
  | zero => simp
  | succ m ih =>
    have he : ∑ k ∈ Finset.range (m + 1 + 1), a ^ k =
        1 + a * ∑ k ∈ Finset.range (m + 1), a ^ k := by
      rw [Finset.sum_range_succ']
      simp only [pow_zero, pow_succ', ← Finset.mul_sum]
      omega
    rw [he, pow_succ']
    have hpow : 1 ≤ (a + 1) ^ m := Nat.one_le_pow m (a + 1) (by omega)
    nlinarith [Nat.mul_le_mul_left a ih]

theorem halfspace_card_le (u : X → Fin m → ℝ) :
    (halfspacePatterns u).card ≤ (Fintype.card X + 1) ^ m := by
  have hvc := halfspace_vcDim_le u
  calc
    _ ≤ (halfspacePatterns u).shatterer.card := Finset.card_le_card_shatterer _
    _ ≤ ∑ k ∈ Finset.Iic (halfspacePatterns u).vcDim, (Fintype.card X).choose k :=
      Finset.card_shatterer_le_sum_vcDim
    _ ≤ ∑ k ∈ Finset.range (m + 1), (Fintype.card X) ^ k := by
      calc
        _ ≤ ∑ k ∈ Finset.Iic (halfspacePatterns u).vcDim, (Fintype.card X) ^ k :=
          Finset.sum_le_sum (fun k _ => Nat.choose_le_pow _ _)
        _ ≤ _ := by
          apply Finset.sum_le_sum_of_subset_of_nonneg
          · intro k hk
            exact Finset.mem_range.mpr (by have := Finset.mem_Iic.mp hk; omega)
          · intro k _ _
            exact Nat.zero_le _
    _ ≤ _ := sum_powers_le _ _

end NeuralGeneralization.BatchTwoShallow
