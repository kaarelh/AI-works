import NeuralGeneralization.BatchTwoNeuralConverseInfimum
import NeuralGeneralization.BatchTwoParameterPriorRate

/-! Actual Gaussian strong-prior limits are supported on the minimum neural action. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Filter Set MeasureTheory
open ConcreteModel BatchTwoParameterPriorRate

variable {d N r : ℕ}

def restrictedFunctionMass (N r : ℕ) (σ Λ U : ℝ) (g : BooleanFunction d) : ℝ :=
  (smallPrior d N r σ).real (functionSupport Λ U g)

def functionPosterior (N r : ℕ) (σ Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d)) :
    BooleanFunction d → ℝ :=
  NeuralGeneralization.posterior (restrictedFunctionMass N r σ Λ U) (fun g => Fits g f A)

def fixedFunctionEnergy (N r : ℕ) (Λ U : ℝ) (g : BooleanFunction d) : ℝ :=
  eventEnergy (functionSupport (N := N) (r := r) Λ U g)

theorem fixedFunctionEnergy_eq {Λ U : ℝ} {g : BooleanFunction d}
    (hne : (functionSupport (N := N) (r := r) Λ U g).Nonempty) :
    fixedFunctionEnergy N r Λ U g=(fixedSqrtAction N r Λ U g)^2/2 := by
  rw [fixedSqrtAction_eq_sqrt_inf hne]
  have hnonneg : 0≤sInf (weightedSquaredNorm '' functionSupport (N := N) (r := r) Λ U g) := by
    apply le_csInf (hne.image _)
    rintro _ ⟨w,hw,rfl⟩
    exact weightedSquaredNorm_nonneg w
  rw [Real.sq_sqrt hnonneg]
  rfl

theorem functionMass_rate (hd : 0<d) (hN : 0<N) (Λ U : ℝ) (g : BooleanFunction d)
    (hne : (functionSupport (N := N) (r := r) Λ U g).Nonempty) :
    HasExponentialRate (𝓝[>] (0 : ℝ)) (fun σ : ℝ => 1/σ^2)
      (fun σ => restrictedFunctionMass N r σ Λ U g) (fixedFunctionEnergy N r Λ U g) :=
  gaussian_open_rate hd hN _ (isOpen_functionSupport Λ U g) hne

theorem posterior_vanishes_at_fixed_width (hd : 0<d) (hN : 0<N) (Λ U : ℝ)
    (f : BooleanFunction d) (A : Finset (Cube d))
    (hne : ∀ g : BooleanFunction d, (functionSupport (N := N) (r := r) Λ U g).Nonempty)
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : fixedSqrtAction N r Λ U h<fixedSqrtAction N r Λ U g) :
    Tendsto (fun σ => functionPosterior N r σ Λ U f A g) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have hh0 : 0≤fixedSqrtAction N r Λ U h := by
    apply le_csInf ((hne h).image _)
    rintro _ ⟨w,hw,rfl⟩
    exact Real.sqrt_nonneg _
  have henergy : fixedFunctionEnergy N r Λ U h<fixedFunctionEnergy N r Λ U g := by
    rw [fixedFunctionEnergy_eq (hne h),fixedFunctionEnergy_eq (hne g)]
    nlinarith
  exact posterior_tendsto_zero_of_rate_gap _
    (fun σ => restrictedFunctionMass N r σ Λ U) (fixedFunctionEnergy N r Λ U)
    (fun h => Fits h f A) (fun σ h => measureReal_nonneg)
    tendsto_inverse_square_nhdsGT_zero_atTop (fun h => functionMass_rate hd hN Λ U h (hne h)) h g hh henergy

def SmallPriorCluster (N r : ℕ) (Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : BooleanFunction d → ℝ) : Prop :=
  ∃ σ : ℕ → ℝ, Tendsto σ atTop (𝓝[>] (0 : ℝ)) ∧
    ∀ g, Tendsto (fun n => functionPosterior N r (σ n) Λ U f A g) atTop (𝓝 (q g))

theorem smallPriorCluster_zero_of_gap (hd : 0<d) (hN : 0<N) {Λ U : ℝ}
    {f : BooleanFunction d} {A : Finset (Cube d)} {q : BooleanFunction d → ℝ}
    (hq : SmallPriorCluster N r Λ U f A q)
    (hne : ∀ g : BooleanFunction d, (functionSupport (N := N) (r := r) Λ U g).Nonempty)
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : fixedSqrtAction N r Λ U h<fixedSqrtAction N r Λ U g) : q g=0 := by
  obtain ⟨σ,hσ,hq⟩ := hq
  exact tendsto_nhds_unique (hq g) ((posterior_vanishes_at_fixed_width hd hN Λ U f A hne g h hh hgap).comp hσ)

theorem eventually_smallPriorCluster_zero (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : ℕ → BooleanFunction d → ℝ)
    (hq : ∀ᶠ N in atTop, SmallPriorCluster N r Λ U f A (q N))
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : neuralSqrtAction r Λ U h<neuralSqrtAction r Λ U g) :
    ∀ᶠ N in atTop, q N g=0 := by
  have hall : ∀ᶠ N in atTop, ∀ g, (functionSupport (N := N) (r := r) Λ U g).Nonempty :=
    Filter.eventually_all.mpr (fun g => eventually_functionSupport_nonempty hd r hΛ hU g)
  have hstrict := (fixedSqrtAction_tendsto hd r hΛ hU h).eventually_lt
    (fixedSqrtAction_tendsto hd r hΛ hU g) hgap
  filter_upwards [hq,hall,hstrict,eventually_gt_atTop 0] with N hqN hne hgapN hN
  exact smallPriorCluster_zero_of_gap hd hN hqN hne g h hh hgapN

/-- Any subsequent width limit (including any diverging width subsequence)
assigns zero probability to every nonminimal retained Boolean function. -/
theorem iterated_limit_zero_of_gap (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : ℕ → BooleanFunction d → ℝ) (p : BooleanFunction d → ℝ)
    (hq : ∀ᶠ N in atTop, SmallPriorCluster N r Λ U f A (q N))
    (width : ℕ → ℕ) (hwidth : Tendsto width atTop atTop)
    (hp : ∀ g, Tendsto (fun n => q (width n) g) atTop (𝓝 (p g)))
    (g h : BooleanFunction d) (hh : Fits h f A)
    (hgap : neuralSqrtAction r Λ U h<neuralSqrtAction r Λ U g) : p g=0 := by
  have hz := eventually_smallPriorCluster_zero hd r hΛ hU f A q hq g h hh hgap
  have hlim : Tendsto (fun n => q (width n) g) atTop (𝓝 (0 : ℝ)) := by
    apply tendsto_const_nhds.congr'
    filter_upwards [hwidth.eventually hz] with n hn
    exact hn.symm
  exact tendsto_nhds_unique (hp g) hlim


theorem smallPriorCluster_zero_of_not_fits {Λ U : ℝ} {f : BooleanFunction d}
    {A : Finset (Cube d)} {q : BooleanFunction d → ℝ} (hq : SmallPriorCluster N r Λ U f A q)
    (g : BooleanFunction d) (hg : ¬Fits g f A) : q g=0 := by
  obtain ⟨σ,hσ,hq⟩ := hq
  have hz : ∀ n, functionPosterior N r (σ n) Λ U f A g=0 := by
    intro n
    exact posterior_of_not_kept _ _ g hg
  exact tendsto_nhds_unique (hq g) (by simpa only [hz] using tendsto_const_nhds)

theorem smallPriorCluster_probability (hd : 0<d) (hN : 0<N) {Λ U : ℝ}
    {f : BooleanFunction d} {A : Finset (Cube d)} {q : BooleanFunction d → ℝ}
    (hq : SmallPriorCluster N r Λ U f A q)
    (hne : (functionSupport (N := N) (r := r) Λ U f).Nonempty) :
    (∀ g, 0≤q g) ∧ (∑ g,q g)=1 := by
  obtain ⟨σ,hσ,hq⟩ := hq
  have hpos := hσ.eventually (functionMass_rate hd hN Λ U f hne).eventually_pos
  have hfits : Fits f f A := fun _ _ => rfl
  constructor
  · intro g
    apply ge_of_tendsto (hq g)
    filter_upwards [hpos] with n hn
    exact posterior_nonneg _ _ (fun g => measureReal_nonneg) f hfits hn g
  · have hlim := tendsto_finsetSum Finset.univ (fun g _ => hq g)
    have hsum : Tendsto (fun n => ∑ g, functionPosterior N r (σ n) Λ U f A g) atTop (𝓝 (1 : ℝ)) := by
      apply tendsto_const_nhds.congr'
      filter_upwards [hpos] with n hn
      symm
      exact posterior_sum _ _ (fun g => measureReal_nonneg) f hfits hn
    exact tendsto_nhds_unique hlim hsum

theorem finite_probability_sum_limit {H : Type*} [Fintype H]
    (q : ℕ → H → ℝ) (p : H → ℝ) (hp : ∀ g,Tendsto (fun n => q n g) atTop (𝓝 (p g)))
    (hs : ∀ᶠ n in atTop, (∑ g,q n g)=1) : (∑ g,p g)=1 := by
  have hlim : Tendsto (fun n => ∑ g,q n g) atTop (𝓝 (∑ g,p g)) :=
    tendsto_finsetSum Finset.univ (fun g _ => hp g)
  have hsum : Tendsto (fun n => ∑ g,q n g) atTop (𝓝 (1 : ℝ)) := by
    apply tendsto_const_nhds.congr'
    filter_upwards [hs] with n hn
    exact hn.symm
  exact tendsto_nhds_unique hlim hsum

def IsMinimumMixture {X : Type*} [Fintype X] (R : (X → Bool) → ℝ)
    (f : X → Bool) (A : Finset X) (p : (X → Bool) → ℝ) : Prop :=
  (∀ g,0≤p g) ∧ (∑ g,p g)=1 ∧
    ∀ g, p g≠0 → Fits g f A ∧ R g=minAction R f A

/-- The actual Gaussian construction yields a probability distribution on
minimum-action functions; ties are retained without a uniqueness assumption. -/
theorem iterated_limit_minimum_mixture (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) (A : Finset (Cube d))
    (q : ℕ → BooleanFunction d → ℝ) (p : BooleanFunction d → ℝ)
    (hq : ∀ᶠ N in atTop, SmallPriorCluster N r Λ U f A (q N))
    (width : ℕ → ℕ) (hwidth : Tendsto width atTop atTop)
    (hp : ∀ g, Tendsto (fun n => q (width n) g) atTop (𝓝 (p g))) :
    IsMinimumMixture (X := Cube d) (neuralSqrtAction (d := d) r Λ U) f A p := by
  unfold IsMinimumMixture
  have hprob : ∀ᶠ N in atTop, (∀ g,0≤q N g) ∧ (∑ g,q N g)=1 := by
    filter_upwards [hq,eventually_gt_atTop 0,eventually_functionSupport_nonempty hd r hΛ hU f]
      with N hqN hN hne
    exact smallPriorCluster_probability hd hN hqN hne
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
        exact smallPriorCluster_zero_of_not_fits hn g hbad
      have hzero : p g=0 := tendsto_nhds_unique (hp g) (tendsto_const_nhds.congr' (hz.mono (fun n hn => hn.symm)))
      exact hpg hzero
    refine ⟨hfits,?_⟩
    apply le_antisymm _ (minAction_le (neuralSqrtAction r Λ U) f g A hfits)
    by_contra hbad
    have hgap : neuralSqrtAction r Λ U (minimizer (neuralSqrtAction r Λ U) f A)<neuralSqrtAction r Λ U g :=
      lt_of_not_ge hbad
    exact hpg (iterated_limit_zero_of_gap hd r hΛ hU f A q p hq width hwidth hp g
      (minimizer (neuralSqrtAction r Λ U) f A) (minimizer_fits _ f A) hgap)

end
end NeuralGeneralization.BatchTwoNeuralConverse
