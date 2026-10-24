import NeuralGeneralization.BatchTwoImprovedGramProbability

/-! # Half-uniform, half-leverage source sampling

The probabilities are the paper's literal probabilities. The importance
weights preserve every covariance entry and have dimension-linear row energy.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling Classical
variable {N q : ℕ}

def rowEnergy (u : Fin N → Fin q → ℝ) (j : Fin N) : ℝ := ∑ k, (u j k)^2
def leverageProbability (u : Fin N → Fin q → ℝ) (j : Fin N) : ℝ :=
  (1+rowEnergy u j/(q:ℝ))/(2*N)
def leverageMultiplier (u : Fin N → Fin q → ℝ) (j : Fin N) : ℝ :=
  1/((N:ℝ)*leverageProbability u j)
def leverageRow (u : Fin N → Fin q → ℝ) (j : Fin N) (k : Fin q) : ℝ :=
  Real.sqrt (leverageMultiplier u j)*u j k

theorem rowEnergy_nonneg (u : Fin N → Fin q → ℝ) (j : Fin N) : 0 ≤ rowEnergy u j :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

theorem leverageProbability_pos (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) : 0 < leverageProbability u j := by
  have hNr : (0:ℝ) < N := by exact_mod_cast hN
  have hqr : (0:ℝ) < q := by exact_mod_cast hq
  unfold leverageProbability
  exact div_pos (by have h := div_nonneg (rowEnergy_nonneg u j) hqr.le; linarith) (by positivity)

theorem leverageProbability_mass (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j = (N:ℝ)*q) :
    ∑ j, leverageProbability u j = 1 := by
  have hNr : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  have hqr : (q:ℝ) ≠ 0 := by exact_mod_cast hq.ne'
  simp only [leverageProbability, ← Finset.sum_div, Finset.sum_add_distrib,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one, htrace]
  field_simp
  norm_num

theorem leverageMultiplier_pos (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) : 0 < leverageMultiplier u j := by
  have hNr : (0:ℝ) < N := by exact_mod_cast hN
  exact one_div_pos.mpr (mul_pos hNr (leverageProbability_pos hN hq u j))

theorem leverageMultiplier_formula (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) :
    leverageMultiplier u j = 2*(q:ℝ)/((q:ℝ)+rowEnergy u j) := by
  have hNr : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  have hqr : (q:ℝ) ≠ 0 := by exact_mod_cast hq.ne'
  have hqpos : (0:ℝ) < q := by exact_mod_cast hq
  have hden : (q:ℝ)+rowEnergy u j ≠ 0 := by have h := rowEnergy_nonneg u j; positivity
  unfold leverageMultiplier leverageProbability
  field_simp

theorem leverageMultiplier_le_two (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) : leverageMultiplier u j ≤ 2 := by
  have hqpos : (0:ℝ) < q := by exact_mod_cast hq
  rw [leverageMultiplier_formula hN hq]
  apply (div_le_iff₀ (by have h := rowEnergy_nonneg u j; positivity)).mpr
  nlinarith [rowEnergy_nonneg u j]

theorem leverageMultiplier_energy_le (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) :
    leverageMultiplier u j*rowEnergy u j ≤ 2*q := by
  have hqpos : (0:ℝ) < q := by exact_mod_cast hq
  rw [leverageMultiplier_formula hN hq, div_mul_eq_mul_div]
  apply (div_le_iff₀ (by have h := rowEnergy_nonneg u j; positivity)).mpr
  nlinarith [sq_nonneg (q:ℝ)]

theorem leverageProbability_mul_multiplier (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) :
    leverageProbability u j*leverageMultiplier u j = 1/(N:ℝ) := by
  have hp := (leverageProbability_pos hN hq u j).ne'
  unfold leverageMultiplier
  field_simp

theorem leverageRow_energy_le (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (j : Fin N) : ∑ k, (leverageRow u j k)^2 ≤ 2*q := by
  simp only [leverageRow, mul_pow, Real.sq_sqrt (leverageMultiplier_pos hN hq u j).le,
    ← Finset.mul_sum]
  exact leverageMultiplier_energy_le hN hq u j

theorem leverageRow_evaluation (u : Fin N → Fin q → ℝ) (j : Fin N) (v : Fin q → ℝ) :
    linearEvaluation (leverageRow u j) v =
      Real.sqrt (leverageMultiplier u j)*linearEvaluation (u j) v := by
  simp [linearEvaluation, leverageRow, Finset.mul_sum, mul_assoc]

theorem leverageRow_isotropy (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ)
    (hiso : ∀ v : Fin q → ℝ,
      (∑ j, (linearEvaluation (u j) v)^2)/(N:ℝ) = ∑ k, (v k)^2)
    (v : Fin q → ℝ) :
    mean (leverageProbability u) (fun j => (linearEvaluation (leverageRow u j) v)^2) =
      ∑ k, (v k)^2 := by
  unfold mean
  simp_rw [leverageRow_evaluation, mul_pow,
    Real.sq_sqrt (leverageMultiplier_pos hN hq u _).le, ← mul_assoc,
    leverageProbability_mul_multiplier hN hq]
  rw [← Finset.mul_sum]
  convert hiso v using 1
  ring

/-- A good empirical Gram matrix under the exact source probabilities, with
a rank-linear sampling budget. No matrix concentration theorem is assumed. -/
theorem leverage_badGram_probability_le (hN : 0 < N) (hq : 0 < q)
    (u : Fin N → Fin q → ℝ) (htrace : ∑ j, rowEnergy u j = (N:ℝ)*q)
    (hiso : ∀ v : Fin q → ℝ,
      (∑ j, (linearEvaluation (u j) v)^2)/(N:ℝ) = ∑ k, (v k)^2)
    {m : ℕ} (hm : 0 < m) {η : ℝ} (hη : 0 < η) (hη1 : η ≤ 1)
    (hbudget : 512*(268435456:ℝ)^2*q*restrictionLog m q ≤ η^2*m) :
    mean (iidWeight (leverageProbability u) m)
      (fun s => if badGram (leverageRow u) s then (1:ℝ) else 0) ≤ η := by
  apply weighted_badGram_probability_le (leverageProbability u)
    (fun j => (leverageProbability_pos hN hq u j).le)
    (leverageProbability_mass hN hq u htrace) hm (leverageRow u) (2*q)
    (by positivity) (leverageRow_energy_le hN hq u)
    (leverageRow_isotropy hN hq u hiso) hη hη1
  nlinarith only [hbudget]

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
