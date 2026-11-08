import NeuralGeneralization.OnlineLowerTanhEmpiricalCompact

/-! # Finite positive alphabets approximating the empirical limit -/

noncomputable section
open scoped BigOperators Topology Classical
open Filter Set

namespace NeuralGeneralization.OnlineLowerTanh

lemma positiveSupportPrefix_sum (p : ℕ → ℝ) (hp : ∀ j, 0 ≤ p j) (J : ℕ) :
    ∑ j ∈ positiveSupportPrefix p J, p j = ∑ j ∈ Finset.range J, p j := by
  rw [positiveSupportPrefix, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : 0 < p j
  · simp [hj]
  · have hz : p j = 0 := le_antisymm (le_of_not_gt hj) (hp j)
    simp [hz]

lemma positiveSupportPrefix_moment_sum (p : ℕ → ℝ) (hp : ∀ j, 0 ≤ p j) (J : ℕ) :
    ∑ j ∈ positiveSupportPrefix p J, p j * (j : ℝ)^2 =
      ∑ j ∈ Finset.range J, p j * (j : ℝ)^2 := by
  rw [positiveSupportPrefix, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : 0 < p j
  · simp [hj]
  · have hz : p j = 0 := le_antisymm (le_of_not_gt hj) (hp j)
    simp [hz]

/-- An alphabet can simultaneously approximate the whole limiting probability
law and its retained second moment while already realizing the stable gcd. -/
theorem exists_positive_alphabet_approximation
    (p : ℕ → ℝ) (hp : ∀ j, 0 ≤ p j) (hsum : HasSum p 1)
    (hmoment : Summable (fun j => p j * (j : ℝ)^2))
    (g J₀ : ℕ) (hg : 0 < g)
    (hstable : ∀ J, J₀ ≤ J → supportPrefixGcd p J = g)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ J : ℕ, J₀ ≤ J ∧ supportPrefixGcd p J = g ∧
      1 - ε < ∑ j ∈ positiveSupportPrefix p J, p j ∧
      (∑' j, p j * (j : ℝ)^2) - ε <
        ∑ j ∈ positiveSupportPrefix p J, p j * (j : ℝ)^2 ∧
      ∃ c : ℕ → ℤ, ∑ j ∈ positiveSupportPrefix p J, c j * ((j / g : ℕ) : ℤ) = 1 := by
  have hmass : ∀ᶠ J : ℕ in atTop, 1 - ε < ∑ j ∈ Finset.range J, p j :=
    hsum.tendsto_sum_nat.eventually (lt_mem_nhds (by linarith))
  have hmom : ∀ᶠ J : ℕ in atTop,
      (∑' j, p j * (j : ℝ)^2) - ε < ∑ j ∈ Finset.range J, p j * (j : ℝ)^2 :=
    hmoment.hasSum.tendsto_sum_nat.eventually (lt_mem_nhds (by linarith))
  obtain ⟨J, hJ, hmassJ, hmomJ⟩ := (eventually_ge_atTop J₀ |>.and (hmass.and hmom)).exists
  refine ⟨J, hJ, hstable J hJ, ?_, ?_, normalized_prefix_bezout p J g hg (hstable J hJ)⟩
  · rwa [positiveSupportPrefix_sum p hp]
  · rwa [positiveSupportPrefix_moment_sum p hp]

/-- The normalized finite positive alphabet is a literal finite family of
positive odd integers with a Bezout vector, ready for common-peak coercivity. -/
theorem normalized_positive_prefix_alphabet
    (p : ℕ → ℝ) (J g : ℕ) (hg : 0 < g)
    (hG : supportPrefixGcd p J = g)
    (hodd : ∀ j, 0 < p j → 0 < j ∧ Odd j) :
    (∀ j ∈ positiveSupportPrefix p J, 0 < j / g ∧ Odd (j / g)) ∧
      ∃ c : ℕ → ℤ, ∑ j ∈ positiveSupportPrefix p J, c j * ((j / g : ℕ) : ℤ) = 1 := by
  refine ⟨?_, normalized_prefix_bezout p J g hg hG⟩
  intro j hj
  have hjp : 0 < p j := (Finset.mem_filter.mp hj).2
  have hdiv : g ∣ j := by
    rw [← hG]
    exact Finset.gcd_dvd (f := id) hj
  exact normalized_support_positive_odd j g (hodd j hjp).1 (hodd j hjp).2 hg hdiv

end NeuralGeneralization.OnlineLowerTanh
