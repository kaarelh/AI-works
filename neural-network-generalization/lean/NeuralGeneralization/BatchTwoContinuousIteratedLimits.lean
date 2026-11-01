import NeuralGeneralization.BatchTwoContinuousWeakLimits

/-! The actual iterated Bayesian limit: first sigma goes to zero at fixed
positive tolerance, then the tolerance goes to zero. Existence and minimizer
support are derived, not assumed. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter Set
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel BatchTwoParameterPriorRate WeakLimitTools

/-- An outer subsequential weak limit of scale-first weak limits. This is
not a joint limit in sigma and rho. -/
def IsIteratedLimit {d N r n : ℕ} (φ : ℝ→ℝ) (f : RealInput d→ℝ)
    (s : Fin n→RealInput d) (Q : ProbabilityMeasure (Weights d N r)) : Prop :=
  ∃ ρ : ℕ→ℝ, (∀ j,0<ρ j) ∧ Tendsto ρ atTop (𝓝 0) ∧
    ∃ Qs : ℕ→ProbabilityMeasure (Weights d N r),
      (∀ j,IsSmallScaleLimit φ f s (ρ j) (Qs j)) ∧ Tendsto Qs atTop (𝓝 Q)

theorem trainingEvent_nonempty_of_exact {d N r n : ℕ} {φ : ℝ→ℝ}
    {f : RealInput d→ℝ} {s : Fin n→RealInput d} {ρ : ℝ} (hρ : 0<ρ)
    (hne : (exactInterpolants (N:=N) (r:=r) φ f s).Nonempty) :
    (trainingEvent (N:=N) (r:=r) φ f ρ s).Nonempty := by
  obtain ⟨v,hv⟩ := hne
  exact ⟨v,fun i => by rw [hv i,sub_self,abs_zero]; exact hρ⟩

/-- Every inner limit has energy no larger than any exact interpolant. -/
theorem smallScaleLimit_energy_le_exact {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    {ρ : ℝ} (hρ : 0<ρ) (v : Weights d N r) (hv : v∈exactInterpolants φ f s)
    (Q : ProbabilityMeasure (Weights d N r)) (hQ : IsSmallScaleLimit φ f s ρ Q) :
    ∀ᵐ w ∂(Q : Measure (Weights d N r)), weightedSquaredNorm w≤weightedSquaredNorm v := by
  have hvρ : v∈trainingEvent φ f ρ s := fun i => by rw [hv i,sub_self,abs_zero]; exact hρ
  have he := eventEnergy_le hvρ
  filter_upwards [(smallScaleLimit_support hd hN hφ f s ⟨v,hvρ⟩ Q hQ).2] with w hw
  linarith

/-- All iterated weak limits are supported on actual minimum-energy exact
interpolants. No uniqueness of the minimizer or the weak limit is required. -/
theorem iteratedLimit_support_minimizers {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    (hne : (exactInterpolants (N:=N) (r:=r) φ f s).Nonempty)
    (Q : ProbabilityMeasure (Weights d N r)) (hQ : IsIteratedLimit φ f s Q) :
    ∀ᵐ w ∂(Q : Measure (Weights d N r)), w∈energyMinimizers φ f s := by
  obtain ⟨ρ,hρ,hρlim,Qs,hQs,hlim⟩ := hQ
  obtain ⟨v,hv⟩ := energyMinimizers_nonempty hd hN hφ f s hne
  have henergy : ∀ᵐ w ∂(Q : Measure (Weights d N r)), weightedSquaredNorm w≤weightedSquaredNorm v :=
    ae_closed_of_tendsto hlim (isClosed_le continuous_weightedEnergy continuous_const)
      (Eventually.of_forall fun j => smallScaleLimit_energy_le_exact hd hN hφ f s
        (hρ j) v hv.1 (Qs j) (hQs j))
  have hsample (i : Fin n) : ∀ᵐ w ∂(Q : Measure (Weights d N r)), output φ w (s i)=f (s i) := by
    have hbound (b : ℝ) (hb : 0<b) :
        ∀ᵐ w ∂(Q : Measure (Weights d N r)), |output φ w (s i)-f (s i)|≤b := by
      apply ae_closed_of_tendsto hlim (isClosed_le
        ((continuous_output_weights hφ (s i)).sub continuous_const).abs continuous_const)
      filter_upwards [hρlim.eventually (gt_mem_nhds hb)] with j hj
      filter_upwards [(smallScaleLimit_support hd hN hφ f s
        (trainingEvent_nonempty_of_exact (hρ j) hne) (Qs j) (hQs j)).1] with w hw
      exact (hw i).trans hj.le
    have hz : ∀ᵐ w ∂(Q : Measure (Weights d N r)), |output φ w (s i)-f (s i)|≤0 := by
      apply (ae_le_const_iff_forall_gt_measure_zero _ _).mpr
      intro b hb
      have hm := hbound (b/2) (by linarith)
      apply measure_mono_null _ (ae_iff.mp hm)
      intro w hw
      change ¬ |output φ w (s i)-f (s i)|≤b/2
      change b≤|output φ w (s i)-f (s i)| at hw
      linarith
    exact hz.mono fun w hw => sub_eq_zero.mp (abs_eq_zero.mp (le_antisymm hw (abs_nonneg _)))
  filter_upwards [henergy,ae_all_iff.mpr hsample] with w hw hs
  exact ⟨hs,fun u hu => hw.trans (hv.2 u hu)⟩

/-- Any positive tolerance sequence tending to zero, and any choice of its
inner weak limits, has an outer weakly convergent subsequence. -/
theorem innerLimits_weak_subsequence {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    (hne : (exactInterpolants (N:=N) (r:=r) φ f s).Nonempty)
    (ρ : ℕ→ℝ) (hρ : ∀ j,0<ρ j)
    (Qs : ℕ→ProbabilityMeasure (Weights d N r)) (hQs : ∀ j,IsSmallScaleLimit φ f s (ρ j) (Qs j)) :
    ∃ Q : ProbabilityMeasure (Weights d N r), ∃ u : ℕ→ℕ,
      StrictMono u ∧ Tendsto (Qs ∘ u) atTop (𝓝 Q) := by
  obtain ⟨v,hv⟩ := hne
  apply exists_weak_subsequence Qs (isCompact_weightedEnergy_sublevel hd hN (weightedSquaredNorm v))
  have hz (j : ℕ) : (Qs j : Measure (Weights d N r)).real
      {w | weightedSquaredNorm w≤weightedSquaredNorm v}ᶜ=0 := by
    have he := smallScaleLimit_energy_le_exact hd hN hφ f s (hρ j) v hv (Qs j) (hQs j)
    have hnull : (Qs j : Measure (Weights d N r))
        {w | weightedSquaredNorm w≤weightedSquaredNorm v}ᶜ=0 := ae_iff.mp he
    simp only [Measure.real,hnull,ENNReal.toReal_zero]
  simpa only [hz] using (tendsto_const_nhds : Tendsto (fun _ : ℕ => (0:ℝ)) atTop (𝓝 0))

/-- Iterated weak limits exist whenever exact interpolation is feasible. -/
theorem iteratedLimit_exists {d N r n : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : RealInput d→ℝ) (s : Fin n→RealInput d)
    (hne : (exactInterpolants (N:=N) (r:=r) φ f s).Nonempty) :
    ∃ Q : ProbabilityMeasure (Weights d N r), IsIteratedLimit φ f s Q := by
  let ρ := fun j : ℕ => 1/((j:ℝ)+1)
  have hp : ∀ j,0<ρ j := fun j => by dsimp [ρ]; positivity
  have ht : Tendsto ρ atTop (𝓝 0) := tendsto_one_div_add_atTop_nhds_zero_nat
  have hi (j : ℕ) := smallScaleLimit_exists hd hN hφ f s (trainingEvent_nonempty_of_exact (hp j) hne)
  choose Qs hQs using hi
  obtain ⟨Q,u,hu,hlim⟩ := innerLimits_weak_subsequence hd hN hφ f s hne ρ hp Qs hQs
  exact ⟨Q,ρ ∘ u,fun j => hp (u j),ht.comp hu.tendsto_atTop,Qs ∘ u,fun j => hQs (u j),hlim⟩

#print axioms iteratedLimit_support_minimizers
#print axioms iteratedLimit_exists
end NeuralGeneralization.BatchTwoContinuous
