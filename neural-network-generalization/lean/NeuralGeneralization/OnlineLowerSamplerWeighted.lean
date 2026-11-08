import NeuralGeneralization.OnlineLowerSamplerOpposite
import NeuralGeneralization.OnlineLowerReluWeightedComparison
import NeuralGeneralization.OnlineLowerReluCostVariation
import NeuralGeneralization.OnlineLowerReluRayEnergy

/-! # The weighted projection inequality for literal even-rail ReLU atoms -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

def samplerPositiveIncrement {p : ℕ} (P r : Fin p → ℕ) (i : Fin p) : ℕ :=
  (r i + 2) - P i

def samplerTransversalCost {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p)) : ℝ :=
  evenReluCost (samplerHalfDegree P r τ - 1)

def samplerWeightedPotential {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ) : ℝ :=
  ∑ τ : Finset (Fin p), samplerTransversalCost P r τ *
    supportFourierPotential (samplerSupport P r τ) (samplerWeights P r a b)

theorem sampler_halfDegree_cost_bound {p : ℕ} (P r : Fin p → ℕ)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (n : ℕ) (hD : (∑ i, P i) = 2 * n + 2) (τ : Finset (Fin p)) :
    samplerTransversalCost P r τ ≤ evenReluCost n +
      3 * ∑ i ∈ τ, (samplerPositiveIncrement P r i : ℝ) := by
  have hδ (i : Fin p) : 2 * (samplerPositiveIncrement P r i / 2) =
      samplerPositiveIncrement P r i := by
    obtain ⟨u,hu⟩ := hP i
    obtain ⟨v,hv⟩ := hr i
    dsimp [samplerPositiveIncrement]
    omega
  have hbase : (∑ i, P i / 2) = n + 1 := by
    have he : 2 * (∑ i, P i / 2) = ∑ i, P i := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      obtain ⟨u,hu⟩ := hP i
      omega
    omega
  have hh : samplerHalfDegree P r τ ≤ (n + 1) + ∑ i ∈ τ, samplerPositiveIncrement P r i / 2 := by
    rw [← hbase, ← Finset.sum_ite_mem_eq τ (fun i => samplerPositiveIncrement P r i / 2),
      ← Finset.sum_add_distrib]
    unfold samplerHalfDegree
    apply Finset.sum_le_sum
    intro i _
    by_cases hi : i ∈ τ
    · simp only [if_pos hi]
      have := hδ i
      obtain ⟨u,hu⟩ := hP i
      obtain ⟨v,hv⟩ := hr i
      dsimp [samplerPositiveIncrement] at *
      omega
    · simp [hi]
  have hindex : samplerHalfDegree P r τ - 1 ≤ n + ∑ i ∈ τ, samplerPositiveIncrement P r i / 2 := by omega
  have hsum : 2 * (∑ i ∈ τ, samplerPositiveIncrement P r i / 2) =
      ∑ i ∈ τ, samplerPositiveIncrement P r i := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl (fun i _ => hδ i)
  have hsumR : 2 * (∑ i ∈ τ, (samplerPositiveIncrement P r i / 2 : ℕ) : ℝ) =
      ∑ i ∈ τ, (samplerPositiveIncrement P r i : ℝ) := by exact_mod_cast hsum
  calc
    _ ≤ evenReluCost (n + ∑ i ∈ τ, samplerPositiveIncrement P r i / 2) :=
      evenReluCost_monotone hindex
    _ ≤ evenReluCost n + 6 * (∑ i ∈ τ, samplerPositiveIncrement P r i / 2 : ℕ) :=
      evenReluCost_add_le _ _
    _ = _ := by push_cast; linarith

/-- The complete weighted potential is controlled by projection onto the
balanced dominant rail. This theorem has no unproved Fourier-mass premises. -/
theorem sampler_weighted_projection {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (n : ℕ) (hD : (∑ i, P i) = 2 * n + 2)
    (a b : Fin p → ℝ) (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i)
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ))
    (hinc : ∀ i, (samplerPositiveIncrement P r i : ℝ) ≤ Δ) :
    samplerWeightedPotential P r a b ≤
      (∑ i, (P i : ℝ) * a i) / Real.sqrt (2 * (n + 1 : ℝ)) := by
  letI : Nonempty (Fin p) := ⟨⟨0,by omega⟩⟩
  letI : Nontrivial (Fin p) := Fin.nontrivial_iff_two_le.mpr hp
  have hp0 : 0 < p := by omega
  have htotal := sampler_potential_mass_bound hp0 P r hPtwo hP hr (2 * n) hD a b hb hab
  rw [← evenReluKappa_eq_coefficient] at htotal
  apply weighted_atom_projection_bound (fun τ : Finset (Fin p) => τ)
    (fun τ => supportFourierPotential (samplerSupport P r τ) (samplerWeights P r a b))
    (samplerTransversalCost P r) (fun i => (samplerPositiveIncrement P r i : ℝ))
    (fun i => (P i : ℝ)) a b (evenReluCost n) (evenReluKappa n) Δ R
    (2 * (n + 1 : ℝ))
  · exact fun _ => supportFourierPotential_nonneg _ _
  · exact div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos n).le
  · exact hΔ
  · exact (evenReluKappa_pos n).le
  · exact fun _ => Nat.cast_nonneg _
  · exact hinc
  · exact div_mul_cancel₀ _ (ne_of_gt (evenReluKappa_pos n))
  · exact htotal
  · intro i hi
    have hiN : 0 < samplerPositiveIncrement P r i := by exact_mod_cast hi
    have hlong : P i ≤ r i + 2 := by dsimp [samplerPositiveIncrement] at hiN; omega
    exact sampler_opposite_mass_bound hp0 P r hPtwo hP hr n hD a b hb hab i hlong
  · exact sampler_halfDegree_cost_bound P r hP hr n hD
  · positivity
  · have h : (∑ i, (P i : ℝ)) = 2 * (n : ℝ) + 2 := by exact_mod_cast hD
    linarith
  · exact hPmin
  · exact hb
  · exact evenReluKappa_mul_sqrt_le_one n
  · exact hR

theorem samplerWeightedPotential_nonneg {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ) :
    0 ≤ samplerWeightedPotential P r a b := by
  apply Finset.sum_nonneg
  intro τ _
  apply mul_nonneg _ (supportFourierPotential_nonneg _ _)
  exact div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le

/-- Norm and squared-distance stability for an actual balanced ReLU neuron.
The potential uses all literal physical Walsh transversals; the only
restrictions are even rail lengths, a narrow length range, and dominance. -/
theorem sampler_weighted_norm_and_stability {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hP : ∀ i, Even (P i)) (hr : ∀ i, Even (r i))
    (n : ℕ) (hD : (∑ i, P i) = 2 * n + 2)
    (a b : Fin p → ℝ) (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i)
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ))
    (hinc : ∀ i, (samplerPositiveIncrement P r i : ℝ) ≤ Δ) :
    balancedRaySquaredDistance (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b
        (2 * (n + 1 : ℝ)) ≤
      weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b -
        samplerWeightedPotential P r a b ^ 2 ∧
    samplerWeightedPotential P r a b ^ 2 ≤
      weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b := by
  apply balancedRay_stability_of_projection
    (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ)) a b (2 * (n + 1 : ℝ))
    (samplerWeightedPotential P r a b)
    (fun _ => Nat.cast_nonneg _) (fun _ => by positivity) (by positivity)
  · have h : (∑ i, (P i : ℝ)) = 2 * (n : ℝ) + 2 := by exact_mod_cast hD
    linarith
  · exact samplerWeightedPotential_nonneg P r a b
  · exact sampler_weighted_projection hp P r hPtwo hP hr n hD a b hb hab R Δ hΔ hR hPmin hinc

end NeuralGeneralization.OnlineLowerRelu
