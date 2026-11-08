import NeuralGeneralization.OnlineLowerPosterior
import NeuralGeneralization.OnlineLowerStrictWitness
import NeuralGeneralization.OnlineLowerCompactBridge
import NeuralGeneralization.OnlineLowerOrbitSynthesis

/-!
# The concrete finite-width and posterior bridge

A closed-margin finite atomic witness, with strict allocation slack, and a
uniform correct-score cost barrier produce the actual strict neural energy
gaps at every sufficiently large width. A finite family of rounds admits
one common width threshold. Gaussian posterior convergence is then supplied
by the proved actual-model rate theorem, not assumed here.
-/

noncomputable section
open scoped BigOperators Topology
open Filter

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- A consistent strict sign event lies in the closed feasible set used by
the deterministic output-space argument. -/
theorem closedOnlineFeasible_of_consistent_margin {d n N : ℕ}
    (φ : ℝ → ℝ) (f g : BooleanFunction d) (sample : Fin n → Cube d)
    (hkeep : consistent f sample g) (w : Weights d N 0)
    (hw : w ∈ marginEvent φ (1 / 2) g) : ClosedOnlineFeasible φ f sample w := by
  constructor
  · intro x
    exact (marginEvent_subset_global φ (1 / 2) g hw x).le
  · intro i
    simpa only [hkeep i] using (hw (sample i)).le

/-- All large widths inherit a strict gap from a finite atomic wrong witness
and an actual-network correct-score barrier. -/
theorem eventual_stage_gap_of_atomic_witness
    {d q : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d) (π : InputOrder d)
    (j : Fin (Fintype.card (Cube d)))
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ)
    (ha : ∀ i, 0 < incomingAtomCost (a i)) (hc : ∀ i, c i ≠ 0)
    (hslack : atomicAllocationMass a c < 1) (g₀ : BooleanFunction d)
    (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g₀ x) * atomicScore φ a c x)
    (δ : ℝ) (hδ : 0 < δ)
    (hbarrier : ∀ N : ℕ, 0 < N → ∀ w : Weights d N 0,
      ClosedOnlineFeasible φ f (observedPrefix π j) w →
      (1 / 2 : ℝ) ≤ labelReal (f (π j)) * networkOutput φ w (π j) →
        atomicWeightedCost a c + δ ≤ weightedSquaredNorm w) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N → HasStageEnergyGap φ f π N j := by
  obtain ⟨N₀, hN₀, hlarge⟩ := closed_atomic_score_strict_witness_all_large
    φ a c ha hc hslack g₀ hmargin (atomicWeightedCost a c + δ) (by linarith)
  refine ⟨N₀, hN₀, ?_⟩
  intro N hN
  obtain ⟨w₀, hw₀, hcost⟩ := hlarge N hN
  refine ⟨g₀, hkeep, ⟨w₀, hw₀⟩, ?_⟩
  intro g hgkeep hgcorrect hgne
  apply networkEnergy_gap_of_cost_barrier φ g₀ g w₀ hw₀
    (atomicWeightedCost a c + δ) hcost hgne
  intro w hw
  apply hbarrier N (hN₀.trans_le hN) w
    (closedOnlineFeasible_of_consistent_margin φ f g (observedPrefix π j) hgkeep w hw)
  simpa only [hgcorrect] using (hw (π j)).le

/-- A finite designated family permits one common width threshold. This
preserves the order: construct the target/permutation, choose the width
threshold, fix any larger width, and only then send the Gaussian scale to zero. -/
theorem allLargeWidthsFail_of_eventual_stage_gaps
    {d C : ℕ} (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    {f : BooleanFunction d} (hteacher : BoundedTeacher φ f C)
    (π : InputOrder d) (J : Finset (Fin (Fintype.card (Cube d))))
    (hstage : ∀ j ∈ J, ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N → HasStageEnergyGap φ f π N j) :
    AllLargeWidthsFail φ f C π J := by
  have he : ∀ᶠ N : ℕ in atTop, ∀ j ∈ J, HasStageEnergyGap φ f π N j := by
    apply (Filter.eventually_all_finset J).mpr
    intro j hj
    obtain ⟨N₀, hN₀⟩ := hstage j hj
    exact (eventually_ge_atTop N₀).mono (fun N hN => hN₀ N hN)
  obtain ⟨M, hM⟩ := eventually_atTop.mp he
  let N₀ := max M (max C 1)
  have hCN₀ : C ≤ N₀ := (le_max_left C 1).trans (le_max_right M (max C 1))
  have hN₀ : 0 < N₀ := lt_of_lt_of_le (by norm_num : (0 : ℕ) < 1)
    ((le_max_right C 1).trans (le_max_right M (max C 1)))
  apply allLargeWidthsFail_of_energy_gaps hd hφ hteacher π J hCN₀ hN₀
  intro N hN j hj
  exact hM N ((le_max_left M (max C 1)).trans hN) j hj

/-- A finite Fourier wrong score with the explicitly calculated orbit cost
supplies every large-width gap for a homogeneous activation. This formulation
requires neither an assumed neural realization nor an allocation-mass bound. -/
theorem eventual_stage_gap_of_homogeneous_fourier_witness
    {d r : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (f : BooleanFunction d) (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ i, walshCoefficients (atomOutput φ (a i)) (S i) ≠ 0)
    (ha : ∀ i, 0 < incomingAtomCost (a i)) (hv : ∀ i, v i ≠ 0)
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g₀ x) *
      (∑ i, v i * walshCharacter (S i) x))
    (δ : ℝ) (hδ : 0 < δ)
    (hbarrier : ∀ N : ℕ, 0 < N → ∀ w : Weights d N 0,
      ClosedOnlineFeasible φ f (observedPrefix π j) w →
      (1 / 2 : ℝ) ≤ labelReal (f (π j)) * networkOutput φ w (π j) →
        (∑ i, 2 * |v i| * Real.sqrt (incomingAtomCost (a i)) /
          |walshCoefficients (atomOutput φ (a i)) (S i)|) + δ ≤ weightedSquaredNorm w) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N → HasStageEnergyGap φ f π N j := by
  obtain ⟨A, c, hA, hc, hscore, hcost⟩ := finite_orbit_synthesis φ S a v hq ha hv
  obtain ⟨A', c', hA', hc', hslack, hcost', hscore'⟩ :=
    homogeneous_atomic_representation_with_slack φ hφ A c hA hc
  apply eventual_stage_gap_of_atomic_witness φ f π j A' c' hA' hc' hslack g₀ hkeep
  · intro x
    simpa only [hscore' x, hscore x] using hmargin x
  · exact hδ
  · intro N hN w hw hcorrect
    simpa only [hcost', hcost] using hbarrier N hN w hw hcorrect

/-- Explicit finite-width version: one neuron per orbit atom suffices,
independently of the size of the strict correct-score gap. -/
theorem stage_gap_of_homogeneous_fourier_witness_at_width
    {d r N : ℕ} (φ : ℝ → ℝ)
    (hφ : ∀ scale : ℝ, 0 < scale → ∀ t, φ (scale * t) = scale * φ t)
    (f : BooleanFunction d) (π : InputOrder d) (j : Fin (Fintype.card (Cube d)))
    (S : Fin r → Finset (Fin d)) (a : Fin r → Fin (d + 1) → ℝ) (v : Fin r → ℝ)
    (hq : ∀ i, walshCoefficients (atomOutput φ (a i)) (S i) ≠ 0)
    (ha : ∀ i, 0 < incomingAtomCost (a i)) (hv : ∀ i, v i ≠ 0)
    (g₀ : BooleanFunction d) (hkeep : consistent f (observedPrefix π j) g₀)
    (hmargin : ∀ x, (1 / 2 : ℝ) ≤ labelReal (g₀ x) *
      (∑ i, v i * walshCharacter (S i) x))
    (δ : ℝ) (hδ : 0 < δ)
    (hbarrier : ∀ w : Weights d N 0,
      ClosedOnlineFeasible φ f (observedPrefix π j) w →
      (1 / 2 : ℝ) ≤ labelReal (f (π j)) * networkOutput φ w (π j) →
        (∑ i, 2 * |v i| * Real.sqrt (incomingAtomCost (a i)) /
          |walshCoefficients (atomOutput φ (a i)) (S i)|) + δ ≤ weightedSquaredNorm w)
    (hN : 0 < N) (hwidth : r * Fintype.card (Cube d) ≤ N) :
    HasStageEnergyGap φ f π N j := by
  let B := (∑ i, 2 * |v i| * Real.sqrt (incomingAtomCost (a i)) /
    |walshCoefficients (atomOutput φ (a i)) (S i)|) + δ
  obtain ⟨w₀, hw₀, hcost⟩ := homogeneous_fourier_score_strict_witness_at_width
    φ hφ S a v hq ha hv g₀ hmargin B (by dsimp [B]; linarith) hN hwidth
  refine ⟨g₀, hkeep, ⟨w₀, hw₀⟩, ?_⟩
  intro g hgkeep hgcorrect hgne
  apply networkEnergy_gap_of_cost_barrier φ g₀ g w₀ hw₀ B hcost hgne
  intro w hw
  apply hbarrier w
    (closedOnlineFeasible_of_consistent_margin φ f g (observedPrefix π j) hgkeep w hw)
  simpa only [hgcorrect] using (hw (π j)).le

end NeuralGeneralization.OnlineLower
