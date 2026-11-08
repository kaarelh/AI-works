import NeuralGeneralization.OnlineLowerTanhEmpiricalClassification

/-! # Simultaneous empirical compactness and residual-energy bounds -/

noncomputable section
open scoped BigOperators Topology Classical
open Filter Set

namespace NeuralGeneralization.OnlineLowerTanh

/-- Pointwise empirical frequencies, the full second moment, and the lattice
spacing can be extracted along one common subsequence. -/
theorem empirical_spacing_moment_subsequence
    (N : ℕ → ℕ) (hN : ∀ k, 0 < N k) (q : ∀ k, Fin (N k) → ℕ)
    (a : ℕ → ℝ) (aMin aMax M : ℝ)
    (ha : ∀ k, a k ∈ Icc aMin aMax)
    (hM : ∀ k, empiricalSecondMoment (q k) ≤ M) :
    ∃ p : ℕ → ℝ, ∃ a₀ Q : ℝ, ∃ φ : ℕ → ℕ,
      StrictMono φ ∧ a₀ ∈ Icc aMin aMax ∧ Q ∈ Icc 0 M ∧
      (∀ j, p j ∈ Icc (0 : ℝ) 1) ∧
      Tendsto (fun k => a (φ k)) atTop (𝓝 a₀) ∧
      Tendsto (fun k => empiricalSecondMoment (q (φ k))) atTop (𝓝 Q) ∧
      ∀ j, Tendsto (fun k => empiricalMass (q (φ k)) j) atTop (𝓝 (p j)) := by
  obtain ⟨p, hp, ψ, hψ, hmass⟩ := empiricalMass_subsequence N hN q
  have hc : IsCompact (Icc aMin aMax ×ˢ Icc (0 : ℝ) M) :=
    isCompact_Icc.prod isCompact_Icc
  have hmem (k : ℕ) : (a (ψ k), empiricalSecondMoment (q (ψ k))) ∈
      Icc aMin aMax ×ˢ Icc (0 : ℝ) M :=
    ⟨ha (ψ k), empiricalSecondMoment_nonneg _, hM (ψ k)⟩
  obtain ⟨v, hv, θ, hθ, hconv⟩ := hc.tendsto_subseq hmem
  refine ⟨p, v.1, v.2, ψ ∘ θ, hψ.comp hθ, hv.1, hv.2, hp, ?_, ?_, ?_⟩
  · exact continuous_fst.continuousAt.tendsto.comp hconv
  · exact continuous_snd.continuousAt.tendsto.comp hconv
  · intro j
    exact (hmass j).comp hθ.tendsto_atTop

/-- The localized integer labels have bounded second moment directly from
incoming energy and the squared residual; no convergence premise is used. -/
lemma integer_lattice_energy_bound {n : ℕ} (u : Fin n → ℝ) (q : Fin n → ℕ)
    (a : ℝ) :
    a^2 * (∑ i, (q i : ℝ)^2) ≤
      2 * (∑ i, (u i)^2) + 2 * ∑ i, (|u i| - a * (q i : ℝ))^2 := by
  calc
    _ = ∑ i, a^2 * (q i : ℝ)^2 := by rw [Finset.mul_sum]
    _ ≤ ∑ i, (2 * (u i)^2 + 2 * (|u i| - a * (q i : ℝ))^2) := by
      apply Finset.sum_le_sum
      intro i _
      have habs : |u i|^2 = (u i)^2 := sq_abs (u i)
      nlinarith [sq_nonneg (2 * |u i| - a * (q i : ℝ))]
    _ = _ := by rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]

lemma empiricalSecondMoment_le_of_energy_residual {n : ℕ} (hn : 0 < n)
    (u : Fin n → ℝ) (q : Fin n → ℕ) (a aMin E K : ℝ)
    (haMin : 0 < aMin) (ha : aMin ≤ a)
    (henergy : ∑ i, (u i)^2 ≤ E * n)
    (hresidual : ∑ i, (|u i| - a * (q i : ℝ))^2 ≤ K * n) :
    empiricalSecondMoment q ≤ (2 * E + 2 * K) / aMin^2 := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hasq : aMin^2 ≤ a^2 := by nlinarith
  have hraw := integer_lattice_energy_bound u q a
  have hsum : 0 ≤ ∑ i, (q i : ℝ)^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hbound : aMin^2 * (∑ i, (q i : ℝ)^2) ≤ (2 * E + 2 * K) * n := by
    nlinarith
  apply (le_div_iff₀ (sq_pos_of_pos haMin)).mpr
  dsimp [empiricalSecondMoment]
  have hh := mul_le_mul_of_nonneg_left hbound (inv_nonneg.mpr hnR.le)
  have hcancel : (n : ℝ)⁻¹ * ((2 * E + 2 * K) * n) = 2 * E + 2 * K := by
    field_simp
  rw [hcancel] at hh
  nlinarith only [hh]

/-- Uniform residual energy is in particular bounded by the same constant
per coordinate, since the dimensions are positive. -/
lemma empiricalSecondMoment_le_of_uniform_residual {n : ℕ} (hn : 0 < n)
    (u : Fin n → ℝ) (q : Fin n → ℕ) (a aMin E K : ℝ)
    (haMin : 0 < aMin) (ha : aMin ≤ a)
    (henergy : ∑ i, (u i)^2 ≤ E * n)
    (hresidual : ∑ i, (|u i| - a * (q i : ℝ))^2 ≤ K) :
    empiricalSecondMoment q ≤ (2 * E + 2 * K) / aMin^2 := by
  have hK : 0 ≤ K := le_trans (Finset.sum_nonneg (fun _ _ => sq_nonneg _)) hresidual
  have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
  apply empiricalSecondMoment_le_of_energy_residual hn u q a aMin E K haMin ha henergy
  exact hresidual.trans (by nlinarith)

/-- When the limiting total moment is already the gcd lower bound, the
escaped moment vanishes and the probability law is concentrated at the gcd. -/
lemma support_gcd_total_moment_equality (p : ℕ → ℝ) (g : ℕ) (Q : ℝ)
    (hp : ∀ j, 0 ≤ p j) (hsum : HasSum p 1)
    (hmoment : Summable (fun j => p j * (j : ℝ)^2))
    (hpositive : ∀ j, 0 < p j → 0 < j)
    (hdiv : ∀ j, 0 < p j → g ∣ j)
    (hescape : 0 ≤ Q - ∑' j, p j * (j : ℝ)^2)
    (heq : Q = (g : ℝ)^2) :
    Q - (∑' j, p j * (j : ℝ)^2) = 0 ∧
      p = fun j => if j = g then 1 else 0 := by
  have hlower := support_gcd_moment_lower p g hp hsum hmoment hpositive hdiv
  have hmomentEq : (∑' j, p j * (j : ℝ)^2) = (g : ℝ)^2 := by linarith
  refine ⟨by linarith, support_gcd_moment_equality p g hp hsum hmoment hpositive hdiv hmomentEq⟩

end NeuralGeneralization.OnlineLowerTanh
