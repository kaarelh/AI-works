import NeuralGeneralization.OnlineLowerModel
import NeuralGeneralization.NetworkGaussianRate

/-!
# Actual Gaussian posterior consequences of a strict neural energy gap

The first theorem is a reusable implication, not the online construction:
one consistent, representable comparator must have strictly smaller *actual
finite-width neural energy* than every consistent function correct at the
queried input.  The conclusion concerns the complete Gaussian posterior,
including all ties and all parameter realizations.  Gaussian asymptotics are
proved in `NetworkGaussianRate`; no posterior concentration is postulated.

The concrete ReLU construction in `OnlineLowerReluMain` supplies these
energy gaps at every sufficiently large width. This module keeps the
posterior implication separate from that construction.
-/

noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- A strict infimum-energy separation from one consistent comparator forces
the *actual* correct-label posterior probability to zero. Empty sign events
are treated as zero mass rather than assigned artificial finite rates. -/
theorem correctConfidence_tendsto_zero_of_energy_gap
    {d N n : ℕ} (hd : 0 < d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d)
    (g₀ : BooleanFunction d) (hkeep : consistent f sample g₀)
    (hne : (marginEvent (N := N) (r := 0) φ (1 / 2) g₀).Nonempty)
    (hgap : ∀ g : BooleanFunction d, consistent f sample g → g x = f x →
      (marginEvent (N := N) (r := 0) φ (1 / 2) g).Nonempty →
        networkEnergy (N := N) (r := 0) φ (1 / 2) g₀ <
          networkEnergy (N := N) (r := 0) φ (1 / 2) g) :
    Tendsto (fun σ : ℝ => correctConfidence f
      (networkPosterior φ (1 / 2) (smallPrior d N 0 σ) f sample) x)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
  classical
  have hbase := network_functionMass_hasExponentialRate hd hN hφ (1 / 2) g₀ hne
  have hterm (g : BooleanFunction d) :
      Tendsto (fun σ : ℝ => if g x = f x then
        networkPosterior φ (1 / 2) (smallPrior d N 0 σ) f sample g else 0)
        (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
    by_cases hcorrect : g x = f x
    · simp only [if_pos hcorrect]
      by_cases hgkeep : consistent f sample g
      · by_cases hgrep : (marginEvent (N := N) (r := 0) φ (1 / 2) g).Nonempty
        · have hrate := network_functionMass_hasExponentialRate hd hN hφ (1 / 2) g hgrep
          have hratio := hrate.ratio_tendsto_zero hbase
            (by simpa only [networkEnergy] using hgap g hgkeep hcorrect hgrep)
            tendsto_inverse_square_nhdsGT_zero_atTop
          apply squeeze_zero' _ _ hratio
          · filter_upwards [hbase.eventually_pos] with σ hσ
            exact NeuralGeneralization.posterior_nonneg
              (functionMass φ (1 / 2) (smallPrior d N 0 σ)) (consistent f sample)
              (functionMass_nonneg φ (1 / 2) (smallPrior d N 0 σ))
              g₀ hkeep hσ g
          · filter_upwards [hbase.eventually_pos] with σ hσ
            exact NeuralGeneralization.posterior_le_weight_ratio
              (functionMass φ (1 / 2) (smallPrior d N 0 σ)) (consistent f sample)
              (functionMass_nonneg φ (1 / 2) (smallPrior d N 0 σ))
              g₀ hkeep hσ g
        · have hempty : marginEvent (N := N) (r := 0) φ (1 / 2) g = ∅ :=
            Set.not_nonempty_iff_eq_empty.mp hgrep
          have hmass (σ : ℝ) : functionMass φ (1 / 2) (smallPrior d N 0 σ) g = 0 := by
            unfold functionMass
            rw [hempty]
            simp
          have hpost (σ : ℝ) : networkPosterior φ (1 / 2) (smallPrior d N 0 σ) f sample g = 0 := by
            unfold networkPosterior NeuralGeneralization.posterior
            rw [hmass]
            simp
          simpa only [hpost] using
            (tendsto_const_nhds :
              Tendsto (fun _ : ℝ => (0 : ℝ)) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)))
      · simpa [networkPosterior, NeuralGeneralization.posterior, hgkeep] using
          (tendsto_const_nhds :
            Tendsto (fun _ : ℝ => (0 : ℝ)) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)))
    · simpa only [if_neg hcorrect] using
        (tendsto_const_nhds :
          Tendsto (fun _ : ℝ => (0 : ℝ)) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)))
  simpa only [correctConfidence, Finset.sum_const_zero] using
    tendsto_finsetSum Finset.univ (fun g _ => hterm g)

/-- Specialization to the concrete permutation observedPrefix. -/
theorem correctAt_tendsto_zero_of_energy_gap
    {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hne : (marginEvent (N := N) (r := 0) φ (1 / 2) g₀).Nonempty)
    (hgap : ∀ g : BooleanFunction d, consistent f (observedPrefix π j) g →
      g (π j) = f (π j) →
      (marginEvent (N := N) (r := 0) φ (1 / 2) g).Nonempty →
        networkEnergy (N := N) (r := 0) φ (1 / 2) g₀ <
          networkEnergy (N := N) (r := 0) φ (1 / 2) g) :
    Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
  exact correctConfidence_tendsto_zero_of_energy_gap hd hN hφ f
    (observedPrefix π j) (π j) g₀ hkeep hne hgap

/-- An explicit finite-width witness below a uniform cost barrier gives the
strict infimum-energy gap needed above. No minimizer of an open margin event
is assumed to exist. -/
theorem networkEnergy_gap_of_cost_barrier
    {d N : ℕ} (φ : ℝ → ℝ) (g₀ g : BooleanFunction d)
    (w₀ : Weights d N 0) (hw₀ : w₀ ∈ marginEvent φ (1 / 2) g₀)
    (B : ℝ) (hcost : weightedSquaredNorm w₀ < B)
    (hne : (marginEvent (N := N) (r := 0) φ (1 / 2) g).Nonempty)
    (hbarrier : ∀ w : Weights d N 0, w ∈ marginEvent φ (1 / 2) g →
      B ≤ weightedSquaredNorm w) :
    networkEnergy (N := N) (r := 0) φ (1 / 2) g₀ <
      networkEnergy (N := N) (r := 0) φ (1 / 2) g := by
  have hup := networkEnergy_le_of_mem φ (1 / 2) g₀ w₀ hw₀
  have hlo : B ≤ sInf (weightedSquaredNorm ''
      marginEvent (N := N) (r := 0) φ (1 / 2) g) := by
    apply le_csInf (hne.image weightedSquaredNorm)
    rintro z ⟨w, hw, rfl⟩
    exact hbarrier w hw
  unfold networkEnergy at *
  linarith

/-- The deterministic construction obligation at one fixed width and round.
All energies here are infima over actual globally strict-margin neural
parameter events. This definition is not a claim that such a gap exists. -/
def HasStageEnergyGap {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (π : InputOrder d) (N : ℕ) (j : Fin (Fintype.card (Cube d))) : Prop :=
  ∃ g₀ : BooleanFunction d,
    consistent f (observedPrefix π j) g₀ ∧
    (marginEvent (N := N) (r := 0) φ (1 / 2) g₀).Nonempty ∧
    ∀ g : BooleanFunction d, consistent f (observedPrefix π j) g →
      g (π j) = f (π j) →
      (marginEvent (N := N) (r := 0) φ (1 / 2) g).Nonempty →
        networkEnergy (N := N) (r := 0) φ (1 / 2) g₀ <
          networkEnergy (N := N) (r := 0) φ (1 / 2) g

/-- Once a concrete finite-width construction proves its energy gaps, the
full all-large-width posterior conclusion follows, with positive conditioning
mass at every positive scale. This is a proved reduction, not the main
existence theorem for a target/order. -/
theorem allLargeWidthsFail_of_energy_gaps
    {d C N₀ : ℕ} (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    {f : BooleanFunction d} (hteacher : BoundedTeacher φ f C)
    (π : InputOrder d) (J : Finset (Fin (Fintype.card (Cube d))))
    (hCN₀ : C ≤ N₀) (hN₀ : 0 < N₀)
    (hgaps : ∀ N : ℕ, N₀ ≤ N → ∀ j ∈ J, HasStageEnergyGap φ f π N j) :
    AllLargeWidthsFail φ f C π J := by
  refine ⟨N₀, hCN₀, hN₀, ?_⟩
  intro N hN
  constructor
  · intro σ hσ j
    exact denominatorAt_pos hd hφ hteacher (hCN₀.trans hN) π hσ j
  · intro j hj
    obtain ⟨g₀, hkeep, hne, hgap⟩ := hgaps N hN j hj
    exact correctAt_tendsto_zero_of_energy_gap hd (hN₀.trans_le hN)
      hφ f π j g₀ hkeep hne hgap

/-- All finitely many designated confidence bounds hold at one positive
scale threshold. No width limit is interchanged with the scale limit. -/
theorem finite_designated_scale
    {d N : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (J : Finset (Fin (Fintype.card (Cube d))))
    (hlim : ∀ j ∈ J, Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
      (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)))
    (η : ℝ) (hη : 0 < η) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      ∀ j ∈ J, correctAt φ f π N σ j < η := by
  have he : ∀ᶠ σ in 𝓝[>] (0 : ℝ), ∀ j ∈ J, correctAt φ f π N σ j < η := by
    apply (Filter.eventually_all_finset J).mpr
    intro j hj
    exact (hlim j hj).eventually (gt_mem_nhds hη)
  obtain ⟨σ₀, hσ₀, hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  exact ⟨σ₀, hσ₀, fun σ hσ hσlt => hsub ⟨hσ, hσlt⟩⟩

end NeuralGeneralization.OnlineLower
