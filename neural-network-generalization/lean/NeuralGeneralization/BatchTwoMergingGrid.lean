import NeuralGeneralization.BatchTwoMergingStability
import NeuralGeneralization.FiniteParameterGrid

/-! # An explicit finite coefficient cover for unbounded-activation networks -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel ParameterGrid

abbrev NetworkGridCode (d Q r T : ℕ) := WeightIndex d Q r → GridInt T

def gridWeights (d Q r T : ℕ) (R : ℝ) (c : NetworkGridCode d Q r T) :
    Weights d Q r := fun i => R * decode T c i

def gridAmplification (d Q : ℕ) (R : ℝ) : ℝ := (d+1+Q)*(R+1)

def gridResolution (d Q r : ℕ) (R : ℝ) : ℕ :=
  ⌈32*R*(r+2)*gridAmplification d Q R^(r+2)⌉₊

theorem gridAmplification_bounds (d Q : ℕ) {R : ℝ} (hR : 1 ≤ R) :
    1 ≤ gridAmplification d Q R ∧
    (d+1 : ℝ)*R ≤ gridAmplification d Q R ∧
    (d+1 : ℝ) ≤ gridAmplification d Q R ∧
    (Q : ℝ)*R ≤ gridAmplification d Q R ∧
    (Q : ℝ) ≤ gridAmplification d Q R := by
  unfold gridAmplification
  have hd : (0 : ℝ) ≤ d := Nat.cast_nonneg _
  have hQ : (0 : ℝ) ≤ Q := Nat.cast_nonneg _
  have hQR : 0 ≤ (Q : ℝ)*R := mul_nonneg hQ (by linarith)
  have hdR : 0 ≤ (d : ℝ)*R := mul_nonneg hd (by linarith)
  constructor
  · nlinarith
  constructor
  · nlinarith
  constructor
  · nlinarith
  constructor <;> nlinarith

theorem gridResolution_pos (d Q r : ℕ) {R : ℝ} (hR : 1 ≤ R) :
    0 < gridResolution d Q r R := by
  apply Nat.ceil_pos.mpr
  have ha := (gridAmplification_bounds d Q hR).1
  positivity

theorem gridWeights_abs_le {d Q r T : ℕ} {R : ℝ} (hR : 0 ≤ R) (hT : 0 < T)
    (c : NetworkGridCode d Q r T) (i : WeightIndex d Q r) :
    |gridWeights d Q r T R c i| ≤ R := by
  rw [gridWeights, abs_mul, abs_of_nonneg hR]
  simpa using mul_le_mul_of_nonneg_left (decode_abs_le_one T hT c i) hR

/-- The cover contains only networks of the same activation, width and depth;
its cardinality is exactly the number of rounded coefficient arrays. -/
theorem networkGridCode_card (d Q r T : ℕ) :
    Fintype.card (NetworkGridCode d Q r T) =
      (2*T+1)^(Q*(d+2)+r*Q^2) := by
  rw [Fintype.card_fun, gridInt_card]
  congr 1
  simp only [WeightIndex, Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
  ring

theorem exists_gridWeights_close {d Q r T : ℕ} {R : ℝ} (hR : 0 < R) (hT : 0 < T)
    (w : Weights d Q r) (hw : ∀ i, |w i| ≤ R) :
    ∃ c : NetworkGridCode d Q r T, ∀ i, |w i-gridWeights d Q r T R c i| ≤ R/T := by
  obtain ⟨c,hc⟩ := exists_close_grid T hT (fun i => w i/R) (fun i => by
    rw [abs_div, abs_of_pos hR]
    exact (div_le_one hR).mpr (hw i))
  refine ⟨c,fun i => ?_⟩
  have hh := mul_le_mul_of_nonneg_left (hc i) hR.le
  calc
    _ = R*|w i/R-decode T c i| := by
      rw [← abs_of_pos hR, ← abs_mul]
      congr 1
      unfold gridWeights
      rw [abs_of_pos hR]
      field_simp
      <;> ring
    _ ≤ R*(1/(T : ℝ)) := hh
    _ = R/T := by ring

theorem exists_grid_output_cover {d Q r : ℕ} {φ : ℝ → ℝ}
    (hφ : LipschitzZero φ) {R : ℝ} (hR : 1 ≤ R)
    (w : Weights d Q r) (hw : ∀ i, |w i| ≤ R) :
    ∃ c : NetworkGridCode d Q r (gridResolution d Q r R), ∀ x,
      |networkOutput φ w x -
        networkOutput φ (gridWeights d Q r (gridResolution d Q r R) R c) x| ≤ 1/32 := by
  let T := gridResolution d Q r R
  let A := gridAmplification d Q R
  have hRp : 0 < R := by linarith
  have hT : 0 < T := gridResolution_pos d Q r hR
  obtain ⟨c,hc⟩ := exists_gridWeights_close hRp hT w hw
  refine ⟨c,fun x => ?_⟩
  obtain ⟨ha,hdR,hd,hQR,hQ⟩ := gridAmplification_bounds d Q hR
  have hout := networkOutput_difference_le_power hφ w (gridWeights d Q r T R c)
    hRp.le ha (div_nonneg hRp.le (Nat.cast_nonneg _)) hdR hd hQR hQ hw
    (gridWeights_abs_le hRp.le hT c) hc x
  have ht : (0 : ℝ) < T := by exact_mod_cast hT
  have hceil : 32*R*(r+2)*A^(r+2) ≤ (T : ℝ) := Nat.le_ceil _
  refine hout.trans ?_
  change R/(T : ℝ)*(r+2)*A^(r+2) ≤ 1/32
  rw [div_mul_eq_mul_div, div_mul_eq_mul_div]
  apply (div_le_iff₀ ht).mpr
  nlinarith

end NeuralGeneralization.BatchTwoMerging
