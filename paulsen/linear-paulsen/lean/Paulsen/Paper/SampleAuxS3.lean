import Paulsen.Paper.SampleAuxS2

/-!
# Helpers for `ModerateSample`: variance bookkeeping for (S3)
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- `E Y_{ik}² ` is the library's retained entry variance. -/
theorem integral_sq_tangentY_eq {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i k : Fin n) :
    ∫ g, tangentY U (moderateNoise U ρ g) i k ^ 2 ∂gaussAmb n d =
      Resolvent.retainedTangentEntryVariance U ρ i k := by
  simp_rw [tangentY_moderateNoise_apply]
  exact integral_sq_gaussianCoordinate_eq_covariance (tangentF U ρ) (i, k)

/-- The residual row loss `ℓ_i` is the library's `positiveResidualRowLoss`. -/
theorem residualRowLoss_formula_eq {n d : ℕ} (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ)
    (i : Fin n) :
    (1 / (n : ℝ)) * ∑ j ∈ highNormalizedModes U 0,
      Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) *
        rowNormSq (tangentY U (normalizedNormalFrame U j)) i =
      Resolvent.positiveResidualRowLoss U ρ i := by
  unfold Resolvent.positiveResidualRowLoss
  simp_rw [Resolvent.positiveResidualEntryLoss_formula, max_eq_right hρ.le, ← Finset.mul_sum]
  congr 1
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  rw [rowNormSq, Finset.mul_sum]
  rfl

/-- The base variance removed from row `i`. -/
theorem baseVariance_row_sum {n d : ℕ} (U : Frame n d) (hs : ModerateStanding U) (i : Fin n) :
    ∑ k, baseNormalTangentVariance U i k = (1 / (n : ℝ)) *
      ∑ j, rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i / rowNormSq U j := by
  have hd : (0 : ℝ) < d := Nat.cast_pos.mpr hs.pos
  have hn : (0 : ℝ) < n := by
    have h1 := hs.density
    have h2 := hs.pos
    exact_mod_cast (by omega : 0 < n)
  have hp : ∀ i, 0 < rowNormSq U i := fun i =>
    lt_of_lt_of_le (by positivity) (hs.rows i).1
  have hT := (lem_expected_graph_losses U hs (by norm_num : (0 : ℝ) < 1) 0).1
  simp only [baseNormalTangentVariance, Matrix.of_apply, ← Finset.mul_sum]
  congr 1
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  have hj : baseNormalTangent U j = tangentY U (baseNormalDirection U j) := rfl
  have hr : rowNormSq (tangentY U (ambientNormal U (Pi.single j 1))) i =
      ∑ k, (tangentY U (ambientNormal U (Pi.single j 1)) i k) ^ 2 := rfl
  rw [hj, hT j, hr, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro k _
  rw [Matrix.smul_apply, smul_eq_mul, mul_pow, inv_pow, Real.sq_sqrt (hp j).le]
  ring

/-- Markov counting: few indices carry a large share of a nonnegative budget. -/
theorem card_filter_lt_le {ι : Type*} [Fintype ι] (f : ι → ℝ) (hf : ∀ k, 0 ≤ f k) {c S : ℝ}
    (hc : 0 < c) (hS : ∑ k, f k ≤ S) :
    ((Finset.univ.filter fun k => c < f k).card : ℝ) ≤ S / c := by
  rw [le_div_iff₀ hc]
  calc
    _ = ∑ _k ∈ Finset.univ.filter (fun k => c < f k), c := by simp
    _ ≤ ∑ k ∈ Finset.univ.filter (fun k => c < f k), f k :=
      Finset.sum_le_sum fun k hk => (Finset.mem_filter.mp hk).2.le
    _ ≤ ∑ k, f k := Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun k _ _ => hf k)
    _ ≤ S := hS

/-- Complement counting in `ℝ`. -/
theorem card_filter_ge_of_compl {n : ℕ} (P : Fin n → Prop) [DecidablePred P]
    (X : Finset (Fin n)) (hX : ∀ k, k ∉ X → P k) :
    (n : ℝ) - X.card ≤ ((Finset.univ.filter P).card : ℝ) := by
  have hsub : Xᶜ ⊆ Finset.univ.filter P := by
    intro k hk
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, hX k (Finset.mem_compl.mp hk)⟩
  have h1 := Finset.card_le_card hsub
  have h2 := Finset.card_add_card_compl X
  simp only [Fintype.card_fin] at h2
  have h3 : ((X.card : ℕ) : ℝ) + ((Xᶜ.card : ℕ) : ℝ) = n := by exact_mod_cast h2
  have h4 : ((Xᶜ.card : ℕ) : ℝ) ≤ ((Finset.univ.filter P).card : ℕ) := by exact_mod_cast h1
  linarith

end

end Paulsen.Paper
