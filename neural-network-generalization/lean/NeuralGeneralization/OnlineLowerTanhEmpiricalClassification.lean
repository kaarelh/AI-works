import NeuralGeneralization.OnlineLowerTanhEmpiricalGcd

/-! # Classification of odd empirical limits and positive-frequency extraction

The gcd and moment statements concern the actual coordinatewise empirical limit.
The possible loss of second moment is retained as a nonnegative escaped moment.
-/

noncomputable section
open scoped BigOperators Topology Classical
open Filter Set

namespace NeuralGeneralization.OnlineLowerTanh

lemma support_gcd_moment_pointwise (p : ℕ → ℝ) (g : ℕ)
    (hp : ∀ j, 0 ≤ p j) (hpositive : ∀ j, 0 < p j → 0 < j)
    (hdiv : ∀ j, 0 < p j → g ∣ j) (j : ℕ) :
    (g : ℝ)^2 * p j ≤ p j * (j : ℝ)^2 := by
  by_cases hj : p j = 0
  · simp [hj]
  · have hpj : 0 < p j := lt_of_le_of_ne (hp j) (Ne.symm hj)
    have hgj : g ≤ j := Nat.le_of_dvd (hpositive j hpj) (hdiv j hpj)
    have hgr : (g : ℝ) ≤ (j : ℝ) := by exact_mod_cast hgj
    have hsq : (g : ℝ)^2 ≤ (j : ℝ)^2 := by nlinarith [Nat.cast_nonneg (α := ℝ) g]
    nlinarith

lemma support_gcd_moment_lower (p : ℕ → ℝ) (g : ℕ)
    (hp : ∀ j, 0 ≤ p j) (hsum : HasSum p 1)
    (hmoment : Summable (fun j => p j * (j : ℝ)^2))
    (hpositive : ∀ j, 0 < p j → 0 < j)
    (hdiv : ∀ j, 0 < p j → g ∣ j) :
    (g : ℝ)^2 ≤ ∑' j, p j * (j : ℝ)^2 := by
  have hsumg : HasSum (fun j => (g : ℝ)^2 * p j) ((g : ℝ)^2) := by
    simpa only [mul_one] using hsum.mul_left ((g : ℝ)^2)
  rw [← hsumg.tsum_eq]
  exact Summable.tsum_le_tsum (support_gcd_moment_pointwise p g hp hpositive hdiv)
    hsumg.summable hmoment

/-- Equality at the gcd moment forces a point mass, including the mass at the gcd itself. -/
theorem support_gcd_moment_equality (p : ℕ → ℝ) (g : ℕ)
    (hp : ∀ j, 0 ≤ p j) (hsum : HasSum p 1)
    (hmoment : Summable (fun j => p j * (j : ℝ)^2))
    (hpositive : ∀ j, 0 < p j → 0 < j)
    (hdiv : ∀ j, 0 < p j → g ∣ j)
    (heq : ∑' j, p j * (j : ℝ)^2 = (g : ℝ)^2) :
    p = fun j => if j = g then 1 else 0 := by
  have hsumg : HasSum (fun j => (g : ℝ)^2 * p j) ((g : ℝ)^2) := by
    simpa only [mul_one] using hsum.mul_left ((g : ℝ)^2)
  have hoff (j : ℕ) (hj : j ≠ g) : p j = 0 := by
    by_contra hn
    have hpj : 0 < p j := lt_of_le_of_ne (hp j) (Ne.symm hn)
    have hgj : g < j := lt_of_le_of_ne
      (Nat.le_of_dvd (hpositive j hpj) (hdiv j hpj)) (Ne.symm hj)
    have hgr : (g : ℝ) < (j : ℝ) := by exact_mod_cast hgj
    have hsq : (g : ℝ)^2 < (j : ℝ)^2 := by nlinarith [Nat.cast_nonneg (α := ℝ) g]
    have hstrict : (g : ℝ)^2 * p j < p j * (j : ℝ)^2 := by nlinarith
    have hh := Summable.tsum_lt_tsum
      (support_gcd_moment_pointwise p g hp hpositive hdiv) hstrict
      hsumg.summable hmoment
    rw [hsumg.tsum_eq, heq] at hh
    exact lt_irrefl _ hh
  have hat : p g = 1 := by
    have hh : ∑' j, p j = p g := tsum_eq_single g hoff
    rw [hsum.tsum_eq] at hh
    exact hh.symm
  funext j
  by_cases hj : j = g
  · simp [hj, hat]
  · simp [hj, hoff j hj]

lemma normalized_support_positive_odd (j g : ℕ) (hj : 0 < j) (hodd : Odd j)
    (hg : 0 < g) (hdiv : g ∣ j) : 0 < j / g ∧ Odd (j / g) := by
  refine ⟨Nat.div_pos (Nat.le_of_dvd hj hdiv) hg, ?_⟩
  apply Nat.not_even_iff_odd.mp
  intro he
  have hjmul : g * (j / g) = j := Nat.mul_div_cancel' hdiv
  have hh : Even j := by rw [← hjmul]; exact he.mul_left g
  exact hodd.not_two_dvd_nat hh.two_dvd

/-- A finite collection of positive limiting types has a common positive
frequency in every sufficiently late literal coordinate array. -/
theorem empiricalLimit_finite_positive_frequencies
    (N : ℕ → ℕ) (hN : ∀ k, 0 < N k) (q : ∀ k, Fin (N k) → ℕ)
    (p : ℕ → ℝ)
    (hp : ∀ j, Tendsto (fun k => empiricalMass (q k) j) atTop (𝓝 (p j)))
    (S : Finset ℕ) (hS : ∀ j ∈ S, 0 < p j) :
    ∃ α : ℝ, 0 < α ∧ ∀ᶠ k in atTop, ∀ j ∈ S,
      α * (N k : ℝ) ≤ ((Finset.univ.filter (fun i => q k i = j)).card : ℝ) := by
  by_cases hne : S.Nonempty
  · let α := S.inf' hne p / 2
    have ha : 0 < α := by
      have hh : 0 < S.inf' hne p := (Finset.lt_inf'_iff _).2 hS
      dsimp [α]
      linarith
    have hal (j : ℕ) (hj : j ∈ S) : α < p j := by
      have hh : S.inf' hne p ≤ p j := Finset.inf'_le p hj
      dsimp [α] at ha ⊢
      linarith
    refine ⟨α, ha, (Filter.eventually_all_finset S).2 ?_⟩
    intro j hj
    have hev : ∀ᶠ k in atTop, α < empiricalMass (q k) j :=
      (hp j).eventually (lt_mem_nhds (hal j hj))
    filter_upwards [hev] with k hk
    have hNk : (0 : ℝ) < N k := by exact_mod_cast hN k
    have hcount : (∑ i : Fin (N k), if q k i = j then (1 : ℝ) else 0) =
        ((Finset.univ.filter (fun i => q k i = j)).card : ℝ) := by simp
    dsimp [empiricalMass] at hk
    rw [hcount] at hk
    have hh := (mul_lt_mul_of_pos_right hk hNk).le
    simpa [mul_assoc, mul_left_comm, mul_comm, ne_of_gt hNk] using hh
  · refine ⟨1, by norm_num, Filter.Eventually.of_forall ?_⟩
    intro k j hj
    exact (hne ⟨j, hj⟩).elim

/-- All empirical-limit conclusions used in the subsequent optimizer
classification, without assuming a probability law in advance. -/
theorem empiricalLimit_gcd_classification
    (N : ℕ → ℕ) (hN : ∀ k, 0 < N k) (q : ∀ k, Fin (N k) → ℕ)
    (p : ℕ → ℝ) (Q : ℝ)
    (hp : ∀ j, Tendsto (fun k => empiricalMass (q k) j) atTop (𝓝 (p j)))
    (hQ : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 Q))
    (hq : ∀ k i, 0 < q k i ∧ Odd (q k i)) :
    ∃ g J₀ : ℕ, 0 < g ∧ Odd g ∧ HasSum p 1 ∧
      supportPrefixGcd p J₀ = g ∧
      (∀ J, J₀ ≤ J → supportPrefixGcd p J = g) ∧
      (∀ j, 0 < p j → g ∣ j) ∧
      Summable (fun j => p j * (j : ℝ)^2) ∧
      (g : ℝ)^2 ≤ ∑' j, p j * (j : ℝ)^2 ∧
      0 ≤ Q - ∑' j, p j * (j : ℝ)^2 ∧
      ((∑' j, p j * (j : ℝ)^2) = (g : ℝ)^2 →
        p = fun j => if j = g then 1 else 0) := by
  have hnonneg := empiricalLimit_nonneg N hN q p Q hp hQ
  have hsum := empiricalLimit_hasSum_one N hN q p Q hp hQ
  have hmoment := empiricalLimit_moment_summable N hN q p Q hp hQ
  have hsupport := empiricalLimit_positive_odd_support N hN q p Q hp hQ hq
  have hne := positive_support_nonempty_of_hasSum_one p hnonneg hsum
  obtain ⟨g, J₀, hg, hG, hstable, hdiv⟩ := exists_stable_support_gcd p hne
    (fun j hj => (hsupport j hj).1)
  refine ⟨g, J₀, hg, support_gcd_odd p g hne (fun j hj => (hsupport j hj).2) hdiv,
    hsum, hG, hstable, hdiv, hmoment, ?_,
    empiricalLimit_escaped_moment_nonneg N hN q p Q hp hQ, ?_⟩
  · exact support_gcd_moment_lower p g hnonneg hsum hmoment
      (fun j hj => (hsupport j hj).1) hdiv
  · exact support_gcd_moment_equality p g hnonneg hsum hmoment
      (fun j hj => (hsupport j hj).1) hdiv

end NeuralGeneralization.OnlineLowerTanh
