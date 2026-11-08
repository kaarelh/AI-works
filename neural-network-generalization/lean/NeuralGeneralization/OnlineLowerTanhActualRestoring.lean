import NeuralGeneralization.OnlineLowerTanhConditioningMixture

/-! # Restoring curvature for actual physical parity coefficients

The external mixture in the residual theorem is fully instantiated by the
uniform outside input cube, its parity sign, and its actual linear shift.
-/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh
namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

/-- A literal selected bulk with negligible outside energy transfers the
pair-difference restoring theorem to the actual full physical coefficient. -/
theorem actual_subset_pair_restoring (M : ℕ → ℕ) (v : (k : ℕ) → Fin (M k) → ℝ)
    (A : (k : ℕ) → Finset (Fin (M k)))
    (e : (k : ℕ) → Fin (S.N k) ≃ Fin (A k).card)
    (hin : ∀ k,S.incoming k=(fun i => subsetWeights (A k) (v k) (e k i)))
    (houtside : Tendsto (fun k => incomingEnergy (subsetWeights (A k)ᶜ (v k))/
      residualVariance (S.alphabet k)) atTop (𝓝 0))
    (σ μ h : ℕ → ℝ) (hσ : ∀ k,|σ k| ≤ 1) (hhi2 : S.hi ≤ 2)
    (hh : Tendsto h atTop (𝓝 0)) {D : ℝ} (hD : 0 < D)
    (hμ : ∀ᶠ k in atTop,|2*μ k| ≤ D)
    (hnear : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*((parityCorrelation (v k) (2*μ k)-
          parityCorrelation (v k) (2*h k))/2)) :
    ∃ δ c : ℝ,0 < δ ∧ 0 < c ∧ ∀ᶠ k in atTop,∀ b : ℝ,|b| ≤ δ →
      (-σ k)*S.normalization k*parityBiasSecond (v k) b ≤ -c := by
  let P := fun k => outsideMixtureSize (A k)
  let p := fun k => outsideMixtureProbability (A k)
  let ν := fun k => outsideMixtureSign (A k)
  let β := fun k => outsideMixtureShift (A k) (v k)
  have hν : ∀ k i,|ν k i| ≤ 1 := fun k i => (outsideMixtureSign_abs (A k) i).le
  have hp : ∀ k i,0 ≤ p k i := fun k i => outsideMixtureProbability_nonneg (A k) i
  have hsum : ∀ k,∑ i,p k i=1 := fun k => outsideMixtureProbability_sum (A k)
  have hcor (k : ℕ) (b : ℝ) :
      S.externalCorrelation k (p k) (β k) (ν k) b=parityCorrelation (v k) b := by
    unfold externalCorrelation
    simp_rw [hin k,parityCorrelation_equiv]
    exact outsideMixture_parityCorrelation (A k) (v k) b
  have hsec (k : ℕ) (b : ℝ) :
      (∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b)))=
        parityBiasSecond (v k) b := by
    simp_rw [hin k,parityBiasSecond_equiv]
    exact outsideMixture_parityBiasSecond (A k) (v k) b
  have hmoment : Tendsto (fun k => (residualScale (S.A k) (S.alphabet k))^2*
      (∑ i,p k i*(β k i)^2)) atTop (𝓝 0) := by
    have ht := S.scaled_external_moment_of_variance
      (fun k => incomingEnergy (subsetWeights (A k)ᶜ (v k))) houtside
    simpa only [p,β,outsideMixtureShift_secondMoment] using ht
  have hnear' : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*((S.externalCorrelation k (p k) (β k) (ν k) (2*μ k)-
          S.externalCorrelation k (p k) (β k) (ν k) (2*h k))/2) := by
    simpa only [hcor] using hnear
  obtain ⟨δ,c,hδ,hc,hevent⟩ := S.pair_difference_eventual_restoring P p β ν hν σ μ h hσ hp hsum
    hmoment hhi2 hh hD hμ hnear'
  refine ⟨δ,c,hδ,hc,?_⟩
  filter_upwards [hevent] with k hk b hb
  have hk' := hk b hb
  change (-σ k)*S.normalization k*(∑ i,p k i*(ν k i*parityBiasSecond (S.incoming k) (β k i+b))) ≤ -c at hk'
  rw [hsec k b] at hk'
  exact hk'

/-- The same actual conclusion with a physical correlation orientation. The
residual phase cancels, leaving strict negativity of the unscaled derivative. -/
theorem actual_subset_pair_strict_curvature (M : ℕ → ℕ) (v : (k : ℕ) → Fin (M k) → ℝ)
    (A : (k : ℕ) → Finset (Fin (M k)))
    (e : (k : ℕ) → Fin (S.N k) ≃ Fin (A k).card)
    (hin : ∀ k,S.incoming k=(fun i => subsetWeights (A k) (v k) (e k i)))
    (houtside : Tendsto (fun k => incomingEnergy (subsetWeights (A k)ᶜ (v k))/
      residualVariance (S.alphabet k)) atTop (𝓝 0))
    (s μ h : ℕ → ℝ) (hs : ∀ k,|s k| ≤ 1) (hhi2 : S.hi ≤ 2)
    (hh : Tendsto h atTop (𝓝 0)) {D : ℝ} (hD : 0 < D)
    (hμ : ∀ᶠ k in atTop,|2*μ k| ≤ D)
    (hnear : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        s k*Real.sqrt (residualVariance (S.alphabet k))*
          ((parityCorrelation (v k) (2*μ k)-parityCorrelation (v k) (2*h k))/2)) :
    ∃ δ : ℝ,0 < δ ∧ ∀ᶠ k in atTop,∀ b : ℝ,|b| ≤ δ →
      -s k*parityBiasSecond (v k) b < 0 := by
  let σ := fun k => s k*residualPhaseSign (S.alphabet k)
  have hσ : ∀ k,|σ k| ≤ 1 := by
    intro k
    simpa only [σ,abs_mul,residualPhaseSign_abs,mul_one] using hs k
  have hnorm (k : ℕ) : σ k*S.normalization k=s k*Real.sqrt (residualVariance (S.alphabet k)) := by
    dsimp [σ,normalization]
    calc
      _=s k*(residualPhaseSign (S.alphabet k)*residualPhaseSign (S.alphabet k))*
        Real.sqrt (residualVariance (S.alphabet k)) := by ring
      _=_ := by rw [residualPhaseSign_sq,mul_one]
  have hnear' : ∀ ε > 0, ∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (S.A k)-ε ≤
        σ k*S.normalization k*((parityCorrelation (v k) (2*μ k)-
          parityCorrelation (v k) (2*h k))/2) := by
    simpa only [hnorm] using hnear
  obtain ⟨δ,c,hδ,hc,hev⟩ := S.actual_subset_pair_restoring M v A e hin houtside σ μ h hσ hhi2 hh hD hμ hnear'
  refine ⟨δ,hδ,?_⟩
  filter_upwards [hev] with k hk b hb
  have hh' := hk b hb
  rw [neg_mul,hnorm] at hh'
  have he : -(s k*Real.sqrt (residualVariance (S.alphabet k)))*parityBiasSecond (v k) b=
      Real.sqrt (residualVariance (S.alphabet k))*(-s k*parityBiasSecond (v k) b) := by ring
  rw [he] at hh'
  have hn : 0 ≤ Real.sqrt (residualVariance (S.alphabet k)) := Real.sqrt_nonneg _
  by_contra hbad
  have hp := mul_nonneg hn (le_of_not_gt hbad)
  linarith

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
