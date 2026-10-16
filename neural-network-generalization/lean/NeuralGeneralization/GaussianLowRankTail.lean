import NeuralGeneralization.LowRankGrid
import NeuralGeneralization.GaussianLinear
import Mathlib.MeasureTheory.Measure.Real

/-!
# A Gaussian tail for actual bounded low-rank witnesses

On a crude Frobenius ball, every unit low-rank factor witness with large
Gaussian alignment has a nearby member of the explicit finite grid with
half as much alignment. Scalar Gaussian Chernoff bounds and a finite union
give the probability estimate. No matrix concentration theorem is assumed.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.LowRankGrid

def alignment {ι : Type*} [Fintype ι] (G B : ι → ℝ) : ℝ := ∑ i, B i * G i

theorem alignment_approximation {N : ℕ} (hN : 0 < N)
    (G B Z : Fin N × Fin N → ℝ) (hG : squaredSum G ≤ (N : ℝ) ^ 2)
    (hclose : squaredSum (fun ij => B ij - Z ij) ≤ 1 / (4 * (N : ℝ) ^ 2)) :
    |alignment G B - alignment G Z| ≤ 1 / 2 := by
  have hn : (0 : ℝ) < N := by exact_mod_cast hN
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun ij => B ij - Z ij) G
  have hs : (∑ ij, (B ij - Z ij) * G ij) ^ 2 ≤ (1 / 4 : ℝ) := by
    calc
      _ ≤ squaredSum (fun ij => B ij - Z ij) * squaredSum G := hcs
      _ ≤ (1 / (4 * (N : ℝ) ^ 2)) * (N : ℝ) ^ 2 :=
        mul_le_mul hclose hG (squaredSum_nonneg _) (by positivity)
      _ = _ := by field_simp
  have hid : alignment G B - alignment G Z = ∑ ij, (B ij - Z ij) * G ij := by
    unfold alignment
    simp_rw [sub_mul]
    rw [Finset.sum_sub_distrib]
  rw [hid]
  have habs := sq_abs (∑ ij, (B ij - Z ij) * G ij)
  nlinarith [abs_nonneg (∑ ij, (B ij - Z ij) * G ij)]

def witnessEvent (N R : ℕ) (b : ℝ) : Set (Fin N × Fin N → ℝ) :=
  {G | squaredSum G ≤ (N : ℝ) ^ 2 ∧
    ∃ p : FactorIndex N R → ℝ, (∀ i, |p i| ≤ 1) ∧
      squaredSum (factorMatrix p) ≤ 1 ∧ b ≤ alignment G (factorMatrix p)}

theorem witnessEvent_subset_grid {N R : ℕ} (hN : 0 < N) (hR : R ≤ N)
    (b : ℝ) (hb : 1 ≤ b) :
    witnessEvent N R b ⊆ ⋃ Z ∈ candidates N R, {G | b / 2 ≤ alignment G Z} := by
  classical
  rintro G ⟨hG, p, hp, henergy, halign⟩
  obtain ⟨Z, hZ, hclose⟩ := exists_candidate_close hN hR p hp henergy
  refine Set.mem_iUnion₂.mpr ⟨Z, hZ, ?_⟩
  have he := alignment_approximation hN G (factorMatrix p) Z hG hclose
  have he' := (abs_le.mp he).2
  change b / 2 ≤ alignment G Z
  linarith

theorem gaussian_candidate_alignment_tail {N R : ℕ}
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) (b : ℝ) (hb : 0 ≤ b)
    (Z : Fin N × Fin N → ℝ) (hZ : Z ∈ candidates N R) :
    (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      {G | b / 2 ≤ alignment G Z} ≤ Real.exp (-b ^ 2 / (32 * (v : ℝ))) := by
  have hvar : (∑ ij, Z ij ^ 2 * (v : ℝ)) ≤ 4 * (v : ℝ) := by
    rw [← Finset.sum_mul]
    exact mul_le_mul_of_nonneg_right (candidates_squaredSum_le N R Z hZ) hv.le
  have hh := GaussianTail.gaussian_linear_form_upper_tail
    (fun _ : Fin N × Fin N => v) Z (4 * (v : ℝ)) (b / 2)
    (by positivity) (by positivity) hvar
  have he : -(b / 2) ^ 2 / (2 * (4 * (v : ℝ))) = -b ^ 2 / (32 * (v : ℝ)) := by ring
  simpa only [he, alignment] using hh

/-- Actual Gaussian mass of a low-rank witness event, with explicit finite
grid entropy and no assumption of measurable witness selection. -/
theorem gaussian_lowRank_witness_tail {N R : ℕ} (hN : 0 < N) (hR : R ≤ N)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) (b : ℝ) (hb : 1 ≤ b) :
    (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      (witnessEvent N R b) ≤
      ((2 * gridMesh N + 1) ^ (R * (2 * N + 1)) : ℕ) *
        Real.exp (-b ^ 2 / (32 * (v : ℝ))) := by
  classical
  let μ : Measure (Fin N × Fin N → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  calc
    _ ≤ μ.real (⋃ Z ∈ candidates N R, {G | b / 2 ≤ alignment G Z}) :=
      measureReal_mono (witnessEvent_subset_grid hN hR b hb) (measure_ne_top μ _)
    _ ≤ ∑ Z ∈ candidates N R, μ.real {G | b / 2 ≤ alignment G Z} :=
      measureReal_biUnion_finset_le _ _
    _ ≤ ∑ _Z ∈ candidates N R, Real.exp (-b ^ 2 / (32 * (v : ℝ))) := by
      apply Finset.sum_le_sum
      intro Z hZ
      exact gaussian_candidate_alignment_tail v hv b (by linarith) Z hZ
    _ = (candidates N R).card * Real.exp (-b ^ 2 / (32 * (v : ℝ))) := by
      rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ _ := by
      apply mul_le_mul_of_nonneg_right _ (Real.exp_pos _).le
      exact_mod_cast candidates_card N R

end NeuralGeneralization.LowRankGrid
