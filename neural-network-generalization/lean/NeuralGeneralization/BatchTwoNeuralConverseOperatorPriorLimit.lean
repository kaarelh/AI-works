import NeuralGeneralization.BatchTwoNeuralConverseOperatorInfimum
import NeuralGeneralization.BatchTwoNeuralConversePriorLimit
import NeuralGeneralization.BatchTwoParameterPriorRate

/-! Actual Gaussian strong-prior limits are supported on the minimum strict-spectral neural action. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Filter Set MeasureTheory
open ConcreteModel BatchTwoParameterPriorRate

variable {d N r : ℕ}

def operator_restrictedFunctionMass (N r : ℕ) (σ U : ℝ) (g : BooleanFunction d) : ℝ :=
  (smallPrior d N r σ).real (operatorFunctionSupport U g)

def operator_functionPosterior (N r : ℕ) (σ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d)) :
    BooleanFunction d → ℝ :=
  NeuralGeneralization.posterior (operator_restrictedFunctionMass N r σ U) (fun g => Fits g f A)

def operator_fixedFunctionEnergy (N r : ℕ) (U : ℝ) (g : BooleanFunction d) : ℝ :=
  eventEnergy (operatorFunctionSupport (N := N) (r := r) U g)

theorem operator_fixedFunctionEnergy_eq {U : ℝ} {g : BooleanFunction d}
    (hne : (operatorFunctionSupport (N := N) (r := r) U g).Nonempty) :
    operator_fixedFunctionEnergy N r U g=(operator_fixedSqrtAction N r U g)^2/2 := by
  rw [operator_fixedSqrtAction_eq_sqrt_inf hne]
  have hnonneg : 0≤sInf (weightedSquaredNorm '' operatorFunctionSupport (N := N) (r := r) U g) := by
    apply le_csInf (hne.image _)
    rintro _ ⟨w,hw,rfl⟩
    exact weightedSquaredNorm_nonneg w
  rw [Real.sq_sqrt hnonneg]
  rfl

theorem operator_functionMass_rate (hd : 0<d) (hN : 0<N) (U : ℝ) (g : BooleanFunction d)
    (hne : (operatorFunctionSupport (N := N) (r := r) U g).Nonempty) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1/σ^2)
      (fun σ => operator_restrictedFunctionMass N r σ U g) (operator_fixedFunctionEnergy N r U g) :=
  gaussian_open_rate hd hN _ (isOpen_operatorFunctionSupport U g) hne

theorem operator_posterior_vanishes_at_fixed_width (hd : 0<d) (hN : 0<N) (U : ℝ)
    (f : BooleanFunction d) (A : Finset (Cube d))
    (hne : ∀ g : BooleanFunction d, (operatorFunctionSupport (N := N) (r := r) U g).Nonempty)
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : operator_fixedSqrtAction N r U h<operator_fixedSqrtAction N r U g) :
    Tendsto (fun σ => operator_functionPosterior N r σ U f A g) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have hh0 : 0≤operator_fixedSqrtAction N r U h := by
    apply le_csInf ((hne h).image _)
    rintro _ ⟨w,hw,rfl⟩
    exact Real.sqrt_nonneg _
  have henergy : operator_fixedFunctionEnergy N r U h<operator_fixedFunctionEnergy N r U g := by
    rw [operator_fixedFunctionEnergy_eq (hne h),operator_fixedFunctionEnergy_eq (hne g)]
    nlinarith
  exact posterior_tendsto_zero_of_rate_gap _
    (fun σ => operator_restrictedFunctionMass N r σ U) (operator_fixedFunctionEnergy N r U)
    (fun h => Fits h f A) (fun σ h => measureReal_nonneg)
    tendsto_inverse_square_nhdsGT_zero_atTop (fun h => operator_functionMass_rate hd hN U h (hne h)) h g hh henergy

def operator_SmallPriorCluster (N r : ℕ) (U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : BooleanFunction d → ℝ) : Prop :=
  ∃ σ : ℕ → ℝ, Tendsto σ atTop (𝓝[>] (0 : ℝ)) ∧
    ∀ g, Tendsto (fun n => operator_functionPosterior N r (σ n) U f A g) atTop (𝓝 (q g))

theorem operator_smallPriorCluster_zero_of_gap (hd : 0<d) (hN : 0<N) {U : ℝ}
    {f : BooleanFunction d} {A : Finset (Cube d)} {q : BooleanFunction d → ℝ}
    (hq : operator_SmallPriorCluster N r U f A q)
    (hne : ∀ g : BooleanFunction d, (operatorFunctionSupport (N := N) (r := r) U g).Nonempty)
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : operator_fixedSqrtAction N r U h<operator_fixedSqrtAction N r U g) : q g=0 := by
  obtain ⟨σ,hσ,hq⟩ := hq
  exact tendsto_nhds_unique (hq g) ((operator_posterior_vanishes_at_fixed_width hd hN U f A hne g h hh hgap).comp hσ)

theorem operator_eventually_smallPriorCluster_zero (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : ℕ → BooleanFunction d → ℝ)
    (hq : ∀ᶠ N in atTop, operator_SmallPriorCluster N r U f A (q N))
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : operator_neuralSqrtAction r U h<operator_neuralSqrtAction r U g) :
    ∀ᶠ N in atTop, q N g=0 := by
  have hall : ∀ᶠ N in atTop, ∀ g, (operatorFunctionSupport (N := N) (r := r) U g).Nonempty :=
    Filter.eventually_all.mpr (fun g => operator_eventually_functionSupport_nonempty hd r hU g)
  have hstrict := (operator_fixedSqrtAction_tendsto hd r hU h).eventually_lt
    (operator_fixedSqrtAction_tendsto hd r hU g) hgap
  filter_upwards [hq,hall,hstrict,eventually_gt_atTop 0] with N hqN hne hgapN hN
  exact operator_smallPriorCluster_zero_of_gap hd hN hqN hne g h hh hgapN

/-- Any subsequent width limit (including any diverging width subsequence)
assigns zero probability to every nonminimal retained Boolean function. -/
theorem operator_iterated_limit_zero_of_gap (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : ℕ → BooleanFunction d → ℝ) (p : BooleanFunction d → ℝ)
    (hq : ∀ᶠ N in atTop, operator_SmallPriorCluster N r U f A (q N))
    (width : ℕ → ℕ) (hwidth : Tendsto width atTop atTop)
    (hp : ∀ g, Tendsto (fun n => q (width n) g) atTop (𝓝 (p g)))
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : operator_neuralSqrtAction r U h<operator_neuralSqrtAction r U g) : p g=0 := by
  have hz := operator_eventually_smallPriorCluster_zero hd r hU f A q hq g h hh hgap
  have hlim : Tendsto (fun n => q (width n) g) atTop (𝓝 (0 : ℝ)) := by
    apply tendsto_const_nhds.congr'
    filter_upwards [hwidth.eventually hz] with n hn
    exact hn.symm
  exact tendsto_nhds_unique (hp g) hlim


theorem operator_smallPriorCluster_zero_of_not_fits {U : ℝ} {f : BooleanFunction d}
    {A : Finset (Cube d)} {q : BooleanFunction d → ℝ} (hq : operator_SmallPriorCluster N r U f A q)
    (g : BooleanFunction d) (hg : ¬Fits g f A) : q g=0 := by
  obtain ⟨σ,hσ,hq⟩ := hq
  have hz : ∀ n, operator_functionPosterior N r (σ n) U f A g=0 := by
    intro n
    exact posterior_of_not_kept _ _ g hg
  exact tendsto_nhds_unique (hq g) (by simpa only [hz] using tendsto_const_nhds)

theorem operator_smallPriorCluster_probability (hd : 0<d) (hN : 0<N) {U : ℝ}
    {f : BooleanFunction d} {A : Finset (Cube d)} {q : BooleanFunction d → ℝ}
    (hq : operator_SmallPriorCluster N r U f A q)
    (hne : (operatorFunctionSupport (N := N) (r := r) U f).Nonempty) :
    (∀ g, 0≤q g) ∧ (∑ g,q g)=1 := by
  obtain ⟨σ,hσ,hq⟩ := hq
  have hpos := hσ.eventually (operator_functionMass_rate hd hN U f hne).eventually_pos
  have hfits : Fits f f A := fun _ _ => rfl
  constructor
  · intro g
    apply ge_of_tendsto (hq g)
    filter_upwards [hpos] with n hn
    exact posterior_nonneg _ _ (fun g => measureReal_nonneg) f hfits hn g
  · have hlim := tendsto_finsetSum Finset.univ (fun g _ => hq g)
    have hsum : Tendsto (fun n => ∑ g, operator_functionPosterior N r (σ n) U f A g) atTop (𝓝 (1 : ℝ)) := by
      apply tendsto_const_nhds.congr'
      filter_upwards [hpos] with n hn
      symm
      exact posterior_sum _ _ (fun g => measureReal_nonneg) f hfits hn
    exact tendsto_nhds_unique hlim hsum

/-- The actual Gaussian construction yields a probability distribution on
minimum-action functions; ties are retained without a uniqueness assumption. -/
theorem operator_iterated_limit_minimum_mixture (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : ℕ → BooleanFunction d → ℝ) (p : BooleanFunction d → ℝ)
    (hq : ∀ᶠ N in atTop, operator_SmallPriorCluster N r U f A (q N))
    (width : ℕ → ℕ) (hwidth : Tendsto width atTop atTop)
    (hp : ∀ g, Tendsto (fun n => q (width n) g) atTop (𝓝 (p g))) :
    IsMinimumMixture (X := Cube d) (operator_neuralSqrtAction (d := d) r U) f A p := by
  unfold IsMinimumMixture
  have hprob : ∀ᶠ N in atTop, (∀ g,0≤q N g) ∧ (∑ g,q N g)=1 := by
    filter_upwards [hq,eventually_gt_atTop 0,operator_eventually_functionSupport_nonempty hd r hU f]
      with N hqN hN hne
    exact operator_smallPriorCluster_probability hd hN hqN hne
  refine ⟨?_,?_,?_⟩
  · intro g
    apply ge_of_tendsto (hp g)
    filter_upwards [hwidth.eventually hprob] with n hn
    exact hn.1 g
  · have hs : ∀ᶠ n in atTop, (∑ g : BooleanFunction d,q (width n) g)=1 := by
      filter_upwards [hwidth.eventually hprob] with n hn
      exact hn.2
    have hsum := finite_probability_sum_limit (fun n => q (width n)) p hp hs
    have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b)=
        (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
    rw [hdec] at hsum
    exact hsum
  · intro g hpg
    have hfits : Fits g f A := by
      by_contra hbad
      have hz : ∀ᶠ n in atTop, q (width n) g=0 := by
        filter_upwards [hwidth.eventually hq] with n hn
        exact operator_smallPriorCluster_zero_of_not_fits hn g hbad
      have hzero : p g=0 := tendsto_nhds_unique (hp g) (tendsto_const_nhds.congr' (hz.mono (fun n hn => hn.symm)))
      exact hpg hzero
    refine ⟨hfits,?_⟩
    apply le_antisymm _ (minAction_le (operator_neuralSqrtAction r U) f g A hfits)
    by_contra hbad
    have hgap : operator_neuralSqrtAction r U (minimizer (operator_neuralSqrtAction r U) f A)<operator_neuralSqrtAction r U g :=
      lt_of_not_ge hbad
    exact hpg (operator_iterated_limit_zero_of_gap hd r hU f A q p hq width hwidth hp g
      (minimizer (operator_neuralSqrtAction r U) f A) (minimizer_fits _ f A) hgap)

end
end NeuralGeneralization.BatchTwoNeuralConverse
