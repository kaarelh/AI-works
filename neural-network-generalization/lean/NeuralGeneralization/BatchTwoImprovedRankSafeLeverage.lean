import NeuralGeneralization.BatchTwoImprovedLeverage
import NeuralGeneralization.BatchTwoImprovedGramSubspace

/-! # Leverage sampling with dependent or zero active slots

Normalizing the uniform-plus-leverage weights by their actual trace avoids
rank-dependent coordinate types. The same constants hold when the trace is
below the slot count, and rank zero gives exactly uniform sampling.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling Classical
variable {N q : ℕ}

def sourceDenominator (u : Fin N → Fin q → ℝ) : ℝ := (N:ℝ)*q+∑ j, rowEnergy u j
def sourceProbability (u : Fin N → Fin q → ℝ) (j : Fin N) : ℝ :=
  ((q:ℝ)+rowEnergy u j)/sourceDenominator u
def sourceMultiplier (u : Fin N → Fin q → ℝ) (j : Fin N) : ℝ :=
  sourceDenominator u/((N:ℝ)*((q:ℝ)+rowEnergy u j))
def sourceSampleRow (u : Fin N → Fin q → ℝ) (j : Fin N) (k : Fin q) : ℝ :=
  Real.sqrt (sourceMultiplier u j)*u j k

theorem sourceDenominator_pos (hN : 0 < N) (hq : 0 < q) (u : Fin N → Fin q → ℝ) :
    0 < sourceDenominator u := by
  have hn : (0:ℝ) < N := by exact_mod_cast hN
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  unfold sourceDenominator
  exact add_pos_of_pos_of_nonneg (mul_pos hn hq') (Finset.sum_nonneg (fun _ _ => rowEnergy_nonneg _ _))

theorem sourceProbability_pos (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) : 0 < sourceProbability u j := by
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  exact div_pos (add_pos_of_pos_of_nonneg hq' (rowEnergy_nonneg _ _)) (sourceDenominator_pos hN hq u)

theorem sourceProbability_mass (hN : 0 < N) (hq : 0 < q) (u : Fin N → Fin q → ℝ) :
    ∑ j, sourceProbability u j = 1 := by
  have hd := (sourceDenominator_pos hN hq u).ne'
  simp only [sourceProbability, ← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  exact div_self hd

theorem sourceMultiplier_pos (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) : 0 < sourceMultiplier u j := by
  have hn : (0:ℝ) < N := by exact_mod_cast hN
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  exact div_pos (sourceDenominator_pos hN hq u)
    (mul_pos hn (add_pos_of_pos_of_nonneg hq' (rowEnergy_nonneg _ _)))

theorem sourceMultiplier_le_two (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j ≤ (N:ℝ)*q) (j : Fin N) :
    sourceMultiplier u j ≤ 2 := by
  have hn : (0:ℝ) < N := by exact_mod_cast hN
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  unfold sourceMultiplier
  apply (div_le_iff₀ (mul_pos hn (add_pos_of_pos_of_nonneg hq' (rowEnergy_nonneg _ _)))).mpr
  dsimp [sourceDenominator]
  nlinarith [rowEnergy_nonneg u j]

theorem sourceMultiplier_energy_le (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j ≤ (N:ℝ)*q) (j : Fin N) :
    sourceMultiplier u j*rowEnergy u j ≤ 2*q := by
  have hn : (0:ℝ) < N := by exact_mod_cast hN
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  unfold sourceMultiplier
  rw [div_mul_eq_mul_div]
  apply (div_le_iff₀ (mul_pos hn (add_pos_of_pos_of_nonneg hq' (rowEnergy_nonneg _ _)))).mpr
  have he := rowEnergy_nonneg u j
  have hh := mul_le_mul_of_nonneg_right htrace he
  dsimp [sourceDenominator]
  nlinarith [mul_nonneg hn.le (sq_nonneg (q:ℝ))]

theorem sourceProbability_mul_multiplier (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) :
    sourceProbability u j*sourceMultiplier u j = 1/(N:ℝ) := by
  have hd := (sourceDenominator_pos hN hq u).ne'
  have hn : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  have hq' : (0:ℝ) < q := by exact_mod_cast hq
  have he : (q:ℝ)+rowEnergy u j ≠ 0 := (add_pos_of_pos_of_nonneg hq' (rowEnergy_nonneg _ _)).ne'
  unfold sourceProbability sourceMultiplier
  field_simp

theorem sourceSampleRow_energy_le (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j ≤ (N:ℝ)*q) (j : Fin N) :
    ∑ k, (sourceSampleRow u j k)^2 ≤ 2*q := by
  simp only [sourceSampleRow, mul_pow, Real.sq_sqrt (sourceMultiplier_pos hN hq u j).le,
    ← Finset.mul_sum]
  exact sourceMultiplier_energy_le hN hq u htrace j

theorem sourceSampleRow_evaluation (u : Fin N → Fin q → ℝ) (j : Fin N) (v : Fin q → ℝ) :
    linearEvaluation (sourceSampleRow u j) v =
      Real.sqrt (sourceMultiplier u j)*linearEvaluation (u j) v := by
  simp [linearEvaluation, sourceSampleRow, Finset.mul_sum, mul_assoc]

theorem sourceSampleRow_covariance (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (v : Fin q → ℝ) :
    mean (sourceProbability u) (fun j => (linearEvaluation (sourceSampleRow u j) v)^2) =
      (∑ j, (linearEvaluation (u j) v)^2)/(N:ℝ) := by
  unfold mean
  simp_rw [sourceSampleRow_evaluation, mul_pow,
    Real.sq_sqrt (sourceMultiplier_pos hN hq u _).le, ← mul_assoc,
    sourceProbability_mul_multiplier hN hq]
  rw [← Finset.mul_sum]
  ring

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
