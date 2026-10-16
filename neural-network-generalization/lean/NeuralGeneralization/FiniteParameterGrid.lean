import Mathlib.Algebra.Order.Floor.Ring
import Mathlib.Data.Int.Interval
import Mathlib.Data.Fintype.Card
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-!
# A finite grid for bounded real parameters

Rounding downward on `[-1,1]` gives `(2T+1)^D` parameter vectors, each still
in that interval and within `1/T` in every coordinate. These are actual finite
sets used in the low-rank Gaussian covering argument.
-/

noncomputable section

namespace NeuralGeneralization.ParameterGrid

abbrev GridInt (T : ℕ) := ↥(Finset.Icc (-(T : ℤ)) (T : ℤ))

theorem gridInt_card (T : ℕ) : Fintype.card (GridInt T) = 2 * T + 1 := by
  rw [Fintype.card_coe, Int.card_Icc]
  omega

def decode {ι : Type*} (T : ℕ) (q : ι → GridInt T) : ι → ℝ :=
  fun i => (q i).val / (T : ℝ)

theorem decode_abs_le_one {ι : Type*} (T : ℕ) (hT : 0 < T)
    (q : ι → GridInt T) (i : ι) : |decode T q i| ≤ 1 := by
  have ht : (0 : ℝ) < T := by exact_mod_cast hT
  obtain ⟨hl, hu⟩ := Finset.mem_Icc.mp (q i).property
  have hlr : -(T : ℝ) ≤ ((q i).val : ℝ) := by exact_mod_cast hl
  have hur : ((q i).val : ℝ) ≤ (T : ℝ) := by exact_mod_cast hu
  change |((q i).val : ℝ) / T| ≤ 1
  rw [abs_div, abs_of_pos ht]
  exact (div_le_one ht).mpr (abs_le.mpr ⟨hlr, hur⟩)

theorem exists_close_grid {ι : Type*} (T : ℕ) (hT : 0 < T)
    (p : ι → ℝ) (hp : ∀ i, |p i| ≤ 1) :
    ∃ q : ι → GridInt T, ∀ i, |p i - decode T q i| ≤ 1 / (T : ℝ) := by
  classical
  have ht : (0 : ℝ) < T := by exact_mod_cast hT
  have hmem (i : ι) : ⌊(T : ℝ) * p i⌋ ∈ Finset.Icc (-(T : ℤ)) (T : ℤ) := by
    obtain ⟨hl, hu⟩ := abs_le.mp (hp i)
    apply Finset.mem_Icc.mpr
    constructor
    · apply Int.le_floor.mpr
      push_cast
      nlinarith
    · have hh := Int.floor_mono (mul_le_mul_of_nonneg_left hu ht.le)
      simpa using hh
  let q : ι → GridInt T := fun i => ⟨⌊(T : ℝ) * p i⌋, hmem i⟩
  refine ⟨q, ?_⟩
  intro i
  have hl := Int.floor_le ((T : ℝ) * p i)
  have hu := Int.lt_floor_add_one ((T : ℝ) * p i)
  change |p i - (⌊(T : ℝ) * p i⌋ : ℝ) / T| ≤ 1 / (T : ℝ)
  rw [abs_le]
  constructor
  · have hzero : 0 ≤ p i - (⌊(T : ℝ) * p i⌋ : ℝ) / T := by
      apply sub_nonneg.mpr
      apply (div_le_iff₀ ht).mpr
      nlinarith
    linarith [one_div_nonneg.mpr ht.le]
  · apply (le_div_iff₀ ht).mpr
    have heq : (p i - (⌊(T : ℝ) * p i⌋ : ℝ) / T) * T =
        (T : ℝ) * p i - ⌊(T : ℝ) * p i⌋ := by field_simp
    rw [heq]
    linarith

end NeuralGeneralization.ParameterGrid
