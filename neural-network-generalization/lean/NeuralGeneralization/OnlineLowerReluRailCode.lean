import NeuralGeneralization.WalshLaplacian
import Mathlib.Data.Finset.SymmDiff
import Mathlib.Data.Finset.Fold
import Mathlib.Tactic.Linarith

/-!
# Concrete affine Walsh codes from physical support generators

Every support is a finite symmetric difference of actual coordinate sets.
The syndrome is an actual Boolean map on the physical cube. No Fourier
factorization, injectivity, or uniform-fiber assertion is postulated.
-/

noncomputable section
open scoped BigOperators symmDiff

namespace NeuralGeneralization.OnlineLowerRelu

theorem walshCharacter_symmDiff {d : ℕ} (S T : Finset (Fin d))
    (x : ClippingCube d) :
    walshCharacter (S ∆ T) x = walshCharacter S x * walshCharacter T x := by
  classical
  have hprod (U : Finset (Fin d)) : walshCharacter U x =
      ∏ j : Fin d, if j ∈ U then cubeCoordinateSign (x j) else 1 := by
    simp [walshCharacter]
  simp only [hprod, ← Finset.prod_mul_distrib]
  apply Finset.prod_congr rfl
  intro j _
  by_cases hS : j ∈ S <;> by_cases hT : j ∈ T <;>
    simp [Finset.mem_symmDiff, hS, hT, ← pow_two, cubeCoordinateSign_sq]

/-- The support obtained by toggling the generator sets indexed by `s`. -/
def generatedSupport {d m : ℕ} (base : Finset (Fin d))
    (generator : Fin m → Finset (Fin d)) (s : Finset (Fin m)) : Finset (Fin d) :=
  s.fold (· ∆ ·) base generator

@[simp] theorem generatedSupport_empty {d m : ℕ} (base : Finset (Fin d))
    (generator : Fin m → Finset (Fin d)) :
    generatedSupport base generator ∅ = base := by
  simp [generatedSupport]

theorem generatedSupport_insert {d m : ℕ} (base : Finset (Fin d))
    (generator : Fin m → Finset (Fin d)) (s : Finset (Fin m))
    (i : Fin m) (hi : i ∉ s) :
    generatedSupport base generator (insert i s) =
      generator i ∆ generatedSupport base generator s := by
  simp [generatedSupport, hi]

/-- The physical syndrome bit is chosen to have the generator's Walsh sign. -/
def generatedSyndrome {d m : ℕ} (generator : Fin m → Finset (Fin d))
    (x : ClippingCube d) : ClippingCube m :=
  fun i => decide (walshCharacter (generator i) x = 1)

theorem generatedSyndrome_sign {d m : ℕ}
    (generator : Fin m → Finset (Fin d)) (x : ClippingCube d) (i : Fin m) :
    cubeCoordinateSign (generatedSyndrome generator x i) =
      walshCharacter (generator i) x := by
  classical
  by_cases h : walshCharacter (generator i) x = 1
  · simp [generatedSyndrome, cubeCoordinateSign, h]
  · have hn : walshCharacter (generator i) x = -1 := by
      have hs := walshCharacter_sq (generator i) x
      have hp : (walshCharacter (generator i) x - 1) *
          (walshCharacter (generator i) x + 1) = 0 := by nlinarith
      rcases mul_eq_zero.mp hp with hp | hp
      · exact False.elim (h (by linarith))
      · linarith
    norm_num [generatedSyndrome, cubeCoordinateSign, hn]

/-- Exact factorization for every actual physical input and logical support. -/
theorem generatedSupport_character {d m : ℕ} (base : Finset (Fin d))
    (generator : Fin m → Finset (Fin d)) (s : Finset (Fin m))
    (x : ClippingCube d) :
    walshCharacter (generatedSupport base generator s) x =
      walshCharacter base x * walshCharacter s (generatedSyndrome generator x) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [walshCharacter]
  | @insert i s hi ih =>
      rw [generatedSupport_insert base generator s i hi, walshCharacter_symmDiff, ih]
      simp only [walshCharacter, Finset.prod_insert hi, generatedSyndrome_sign]
      ring

/-- A private coordinate records whether its unique generator was toggled. -/
theorem generatedSupport_private_coordinate {d m : ℕ} (base : Finset (Fin d))
    (generator : Fin m → Finset (Fin d)) (i : Fin m) (j : Fin d)
    (hj : ∀ k, j ∈ generator k ↔ k = i) (s : Finset (Fin m)) :
    j ∈ generatedSupport base generator s ↔
      (j ∈ base ∧ i ∉ s) ∨ (j ∉ base ∧ i ∈ s) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert k s hk ih =>
      rw [generatedSupport_insert base generator s k hk, Finset.mem_symmDiff, hj, ih]
      by_cases hki : k = i
      · subst k
        simp [hk]
      · by_cases hb : j ∈ base <;> by_cases his : i ∈ s <;>
          simp [hki, Ne.symm hki, hb, his]

/-- Loop columns supply private coordinates and hence injective code supports. -/
theorem generatedSupport_injective {d m : ℕ} (base : Finset (Fin d))
    (generator : Fin m → Finset (Fin d)) (privateCoord : Fin m → Fin d)
    (hprivate : ∀ i k, privateCoord i ∈ generator k ↔ k = i) :
    Function.Injective (generatedSupport base generator) := by
  intro s t hst
  ext i
  have hmem : privateCoord i ∈ generatedSupport base generator s ↔
      privateCoord i ∈ generatedSupport base generator t := by rw [hst]
  rw [generatedSupport_private_coordinate base generator i (privateCoord i) (hprivate i),
    generatedSupport_private_coordinate base generator i (privateCoord i) (hprivate i)] at hmem
  by_cases hb : privateCoord i ∈ base
  · simp only [hb, true_and, not_true_eq_false, false_and, or_false] at hmem
    exact not_iff_not.mp hmem
  · simpa [hb] using hmem

/-- A coordinate's column lists exactly the logical generator supports
which contain that physical coordinate. -/
def coordinateGenerator {d m : ℕ} (column : Fin d → Finset (Fin m))
    (i : Fin m) : Finset (Fin d) := Finset.univ.filter (fun j => i ∈ column j)

@[simp] theorem mem_coordinateGenerator {d m : ℕ}
    (column : Fin d → Finset (Fin m)) (i : Fin m) (j : Fin d) :
    j ∈ coordinateGenerator column i ↔ i ∈ column j := by
  simp [coordinateGenerator]

/-- Exact double counting of all physical syndrome-support sizes. -/
theorem coordinateGenerator_card_sum {d m : ℕ} (column : Fin d → Finset (Fin m)) :
    (∑ i, (coordinateGenerator column i).card) = ∑ j, (column j).card := by
  classical
  calc
    _ = ∑ i : Fin m, ∑ j : Fin d, if i ∈ column j then 1 else 0 := by
      simp only [coordinateGenerator, Finset.card_eq_sum_ones, Finset.sum_filter]
    _ = ∑ j : Fin d, ∑ i : Fin m, if i ∈ column j then 1 else 0 := Finset.sum_comm
    _ = _ := by simp

/-- Weight-at-most-two columns give the linear physical circuit budget. -/
theorem coordinateGenerator_card_sum_le {d m k : ℕ}
    (column : Fin d → Finset (Fin m)) (hcolumn : ∀ j, (column j).card ≤ k) :
    (∑ i, (coordinateGenerator column i).card) ≤ k * d := by
  rw [coordinateGenerator_card_sum]
  calc
    _ ≤ ∑ _ : Fin d, k := Finset.sum_le_sum (fun j _ => hcolumn j)
    _ = k * d := by simp [Nat.mul_comm]

/-- A singleton column is the required private coordinate for injectivity. -/
theorem coordinateGenerator_private {d m : ℕ} (column : Fin d → Finset (Fin m))
    (privateCoord : Fin m → Fin d) (hcolumn : ∀ i, column (privateCoord i) = {i}) :
    ∀ i k, privateCoord i ∈ coordinateGenerator column k ↔ k = i := by
  intro i k
  simp [hcolumn]

theorem privateColumn_dimension_le {d m : ℕ} (column : Fin d → Finset (Fin m))
    (privateCoord : Fin m → Fin d) (hcolumn : ∀ i, column (privateCoord i) = {i}) :
    m ≤ d := by
  have hinj : Function.Injective privateCoord := by
    intro i k hik
    have hc := congrArg column hik
    simpa only [hcolumn, Finset.singleton_inj] using hc
  simpa using Fintype.card_le_of_injective privateCoord hinj

end NeuralGeneralization.OnlineLowerRelu
