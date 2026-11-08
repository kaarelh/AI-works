import NeuralGeneralization.OnlineLowerPosterior
import NeuralGeneralization.OnlineLowerReluSynthesisZero
import NeuralGeneralization.OnlineLowerGapBridge

/-! # Posterior failure at an explicit finite-width threshold -/

noncomputable section
open scoped BigOperators Topology
open Filter

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu

/-- The supplied width threshold is preserved exactly. There is no
additional unspecified width limit in the Gaussian-posterior step. -/
theorem fixed_threshold_limits_of_energy_gaps
    {d C N₀ : ℕ} (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    {f : BooleanFunction d} (hteacher : BoundedTeacher φ f C)
    (π : InputOrder d) (J : Finset (Fin (Fintype.card (Cube d))))
    (hCN₀ : C ≤ N₀) (hN₀ : 0 < N₀)
    (hgaps : ∀ N : ℕ, N₀ ≤ N → ∀ j ∈ J, HasStageEnergyGap φ f π N j) :
    ∀ N : ℕ, N₀ ≤ N →
      (∀ σ : ℝ, 0 < σ → ∀ j, 0 < denominatorAt φ f π N σ j) ∧
      (∀ j ∈ J, Tendsto (fun σ : ℝ => correctAt φ f π N σ j)
        (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ))) := by
  intro N hN
  constructor
  · intro σ hσ j
    exact denominatorAt_pos hd hφ hteacher (hCN₀.trans hN) π hσ j
  · intro j hj
    obtain ⟨g₀, hkeep, hne, hgap⟩ := hgaps N hN j hj
    exact correctAt_tendsto_zero_of_energy_gap hd (hN₀.trans_le hN)
      hφ f π j g₀ hkeep hne hgap

/-- A full finite Walsh score, including its zero coefficients, gives the
actual stage gap at every width above its literal orbit count. -/
theorem relu_stage_gap_of_fourier_witness_at_width
    {d N : ℕ} {ι : Type*} [Fintype ι] (hd : 0 < d)
    (f : BooleanFunction d) (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (S : ι → Finset (Fin d)) (r : ι → ℕ) (v : ι → ℝ)
    (hcard : ∀ i, (S i).card = 2 * r i + 2)
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g₀ x) * ∑ i, v i * walshCharacter (S i) x)
    (δ : ℝ) (hδ : 0 < δ)
    (hbarrier : ∀ w : Weights d N 0,
      ClosedOnlineFeasible (fun t => max 0 t) f (observedPrefix π j) w →
      (1 / 2 : ℝ) ≤ labelReal (f (π j)) * networkOutput (fun t => max 0 t) w (π j) →
        2 * Real.sqrt (d : ℝ) * (∑ i, |v i| * evenReluCost (r i)) + δ ≤ weightedSquaredNorm w)
    (hN : 0 < N) (hwidth : Fintype.card ι * Fintype.card (Cube d) ≤ N) :
    HasStageEnergyGap (fun t => max 0 t) f π N j := by
  let B := 2 * Real.sqrt (d : ℝ) * (∑ i, |v i| * evenReluCost (r i)) + δ
  obtain ⟨w₀, hw₀, hcost⟩ := relu_fourier_strict_witness_at_width hd S r v hcard
    g₀ hmargin B (by dsimp [B]; linarith) hN hwidth
  refine ⟨g₀, hkeep, ⟨w₀, hw₀⟩, ?_⟩
  intro g hgkeep hgcorrect hgne
  apply networkEnergy_gap_of_cost_barrier (fun t => max 0 t) g₀ g w₀ hw₀ B hcost hgne
  intro w hw
  apply hbarrier w
    (closedOnlineFeasible_of_consistent_margin (fun t => max 0 t) f g (observedPrefix π j) hgkeep w hw)
  simpa only [hgcorrect] using (hw (π j)).le

end NeuralGeneralization.OnlineLower
