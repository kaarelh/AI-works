import NeuralGeneralization.BatchTwoContinuousConditionedRate
import NeuralGeneralization.WeakLimitTools

/-! Existence and support of actual scale-first Gaussian posterior weak limits.
The tolerance is held fixed in the inner limit. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter Set
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel BatchTwoParameterPriorRate WeakLimitTools

/-- A subsequential limit of the actual normalized Gaussian posteriors as
sigma tends to zero through positive values, with tolerance held fixed. -/
def IsSmallScaleLimit {d N r n : ℕ} (φ : ℝ→ℝ) (f : RealInput d→ℝ)
    (s : Fin n→RealInput d) (ρ : ℝ) (Q : ProbabilityMeasure (Weights d N r)) : Prop :=
  ∃ σ : ℕ→ℝ, (∀ j, 0<σ j) ∧ Tendsto σ atTop (𝓝[>] 0) ∧
    ∃ Qs : ℕ→ProbabilityMeasure (Weights d N r),
      (∀ j, (Qs j : Measure (Weights d N r))=posterior φ (smallPrior d N r (σ j)) f ρ s) ∧
      Tendsto Qs atTop (𝓝 Q)

/-- Every weak inner limit is supported on the non-strict training constraints
and on the precise energy level given by the open training event. -/
theorem smallScaleLimit_support {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {ρ : ℝ} (hne : (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty)
    (Q : ProbabilityMeasure (Weights d N r)) (hQ : IsSmallScaleLimit φ f s ρ Q) :
    (∀ᵐ w ∂(Q : Measure (Weights d N r)), ∀ i, |output φ w (s i)-f (s i)|≤ρ) ∧
    (∀ᵐ w ∂(Q : Measure (Weights d N r)),
      weightedSquaredNorm w=2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)) := by
  obtain ⟨σ,hσ,hσlim,Qs,hQs,hlim⟩ := hQ
  have hV := isOpen_trainingEvent (N:=N) (r:=r) hφ f ρ s
  have htrain (j : ℕ) : ∀ᵐ w ∂(Qs j : Measure (Weights d N r)), w∈trainingEvent φ f ρ s := by
    rw [hQs j]
    exact ae_cond_mem hV.measurableSet
  have hlo : ∀ᵐ w ∂(Q : Measure (Weights d N r)),
      2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)≤weightedSquaredNorm w := by
    apply ae_closed_of_tendsto hlim
      (C := {w | 2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)≤weightedSquaredNorm w})
      (isClosed_le continuous_const continuous_weightedEnergy)
    exact Eventually.of_forall fun j => (htrain j).mono fun w hw => by
      have he := eventEnergy_le hw
      change 2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)≤weightedSquaredNorm w
      linarith
  have hhi : ∀ᵐ w ∂(Q : Measure (Weights d N r)),
      weightedSquaredNorm w≤2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s) := by
    apply (ae_le_const_iff_forall_gt_measure_zero _ _).mpr
    intro b hb
    let a := (2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)+b)/2
    have ha : 2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)<a := by dsimp [a]; linarith
    have htail := (posterior_energy_tail_tendsto_zero hd hN hφ f s hne ha).comp hσlim
    have ht : Tendsto (fun j => (Qs j : Measure (Weights d N r)).real {w | a<weightedSquaredNorm w})
        atTop (𝓝 0) := by simpa only [Function.comp_def,hQs] using htail
    have hz := open_null_of_tendsto hlim (isOpen_lt continuous_const continuous_weightedEnergy) ht
    apply measure_mono_null _ hz
    intro w hw
    change a<weightedSquaredNorm w
    dsimp [a]
    change b≤weightedSquaredNorm w at hw
    linarith
  refine ⟨?_, ?_⟩
  · apply ae_closed_of_tendsto hlim
      (C := {w | ∀ i, |output φ w (s i)-f (s i)|≤ρ})
    · simp only [Set.setOf_forall]
      exact isClosed_iInter fun i => isClosed_le
        ((continuous_output_weights hφ (s i)).sub continuous_const).abs continuous_const
    · exact Eventually.of_forall fun j => (htrain j).mono fun w hw i => (hw i).le
  · filter_upwards [hlo,hhi] with w hw1 hw2 using le_antisymm hw2 hw1

/-- Every positive-scale sequence converging to zero has a subsequence of
actual posteriors converging weakly. -/
theorem posterior_weak_subsequence {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {ρ : ℝ} (hne : (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty)
    (σ : ℕ→ℝ) (hσ : ∀ j, 0<σ j) (hσlim : Tendsto σ atTop (𝓝[>] 0)) :
    ∃ Q : ProbabilityMeasure (Weights d N r), ∃ u : ℕ→ℕ,
      StrictMono u ∧ Tendsto
        (fun j => posteriorProbability hd hN hφ f s (hσ (u j)) hne) atTop (𝓝 Q) := by
  let Qs j := posteriorProbability hd hN hφ f s (hσ j) hne
  let K := 2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)+1
  have htail := (posterior_energy_tail_tendsto_zero hd hN hφ f s hne
    (show 2*eventEnergy (trainingEvent (N:=N) (r:=r) φ f ρ s)<K by dsimp [K]; linarith)).comp hσlim
  have ht : Tendsto (fun j => (Qs j : Measure (Weights d N r)).real
      {w | weightedSquaredNorm w≤K}ᶜ) atTop (𝓝 0) := by
    simpa only [Function.comp_def,Qs,posteriorProbability,ProbabilityMeasure.coe_mk,Set.compl_setOf,not_le] using htail
  exact exists_weak_subsequence Qs (isCompact_weightedEnergy_sublevel hd hN K) ht

/-- A scale-first weak limit exists at every feasible positive tolerance. -/
theorem smallScaleLimit_exists {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {ρ : ℝ} (hne : (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty) :
    ∃ Q : ProbabilityMeasure (Weights d N r), IsSmallScaleLimit φ f s ρ Q := by
  let σ := fun j : ℕ => 1/((j:ℝ)+1)
  have hp : ∀ j,0<σ j := fun j => by dsimp [σ]; positivity
  have ht : Tendsto σ atTop (𝓝[>] 0) := tendsto_nhdsWithin_iff.mpr
    ⟨tendsto_one_div_add_atTop_nhds_zero_nat, Eventually.of_forall hp⟩
  obtain ⟨Q,u,hu,hlim⟩ := posterior_weak_subsequence hd hN hφ f s hne σ hp ht
  exact ⟨Q,σ ∘ u,fun j => hp (u j),ht.comp hu.tendsto_atTop,
    (fun j => posteriorProbability hd hN hφ f s (hp (u j)) hne),fun _ => rfl,hlim⟩

end NeuralGeneralization.BatchTwoContinuous
