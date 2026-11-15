import NeuralGeneralization.BatchTwoManuscriptAllWidths

/-! The first use of the stability support: literal-J numerical compression
implies an actual clipped-score coupling at every input. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel RobustStatistics
variable {p : Input} {N : ℕ}

def scoreCoupling {Q : Measure (Weights p.dimension N (p.depth-2))} {Γ : Measure (GridCode p)}
    (π : NoisyGridCoupling Q Γ) : ProbabilityCoupling Q Γ where
  joint := π.joint.map (fun z=>(z.1,z.2.1))
  probability := Measure.isProbabilityMeasure_map (by fun_prop)
  left := by
    rw [Measure.map_map measurable_fst (by fun_prop)]
    exact π.original
  right := by
    rw [Measure.map_map measurable_snd (by fun_prop)]
    exact π.code

theorem scoreCoupling_failure {φ : ℝ→ℝ} (hφ : Continuous φ) {c : ℝ}
    {Q : Measure (Weights p.dimension N (p.depth-2))} {Γ : Measure (GridCode p)}
    (π : NoisyGridCoupling Q Γ) (x : Cube p.dimension) (hr : p.radius≤1/6)
    (hrob : ∀ᵐw ∂Q,w∈robustEvent φ c) (hrad : ∀ᵐw ∂Q,p.radius≤robustRadius c w)
    (hfail : π.joint.real (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/16))≤p.failure) :
    (scoreCoupling π).joint.real (scoreFailure (fun w=>networkOutput φ w x) (fun q=>gridOutput p φ q x))≤p.failure := by
  have hmap : Measurable (fun z : NoisyGridState p.dimension N (p.depth-2) (GridCode p)=>(z.1,z.2.1)) := by fun_prop
  have hs := measurable_scoreFailure (fun w : Weights p.dimension N (p.depth-2)=>networkOutput φ w x)
    (fun q : GridCode p=>gridOutput p φ q x) (continuous_networkOutput hφ x).measurable (measurable_of_countable _)
  change (π.joint.map _).real _≤_
  rw [measureReal_def,Measure.map_apply hmap hs]
  have ha : ∀ᵐz ∂π.joint,z.1∈robustEvent φ c :=
    ae_of_ae_map measurable_fst.aemeasurable (by rw [π.original]; exact hrob)
  have hb : ∀ᵐz ∂π.joint,p.radius≤robustRadius c z.1 :=
    ae_of_ae_map measurable_fst.aemeasurable (by rw [π.original]; exact hrad)
  apply (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono_ae ?_)).trans hfail
  filter_upwards [ha,hb] with z hz hzr
  intro hbad
  by_contra hn
  have hg : noiseBudgetSq z.2.2<(p.radius/2)^2 ∧
      |gridOutput p φ z.2.1 x-noisyNetworkOutput φ z.1 x z.2.2|≤p.radius/16 := by
    change ¬((p.radius/2)^2≤noiseBudgetSq z.2.2 ∨
      p.radius/16 < |gridOutput p φ z.2.1 x-noisyNetworkOutput φ z.1 x z.2.2|) at hn
    exact ⟨lt_of_not_ge (not_or.mp hn).1,le_of_not_gt (not_or.mp hn).2⟩
  have hc := robust_score_close_of_noisy_compression φ c z.1 x z.2.2 (gridOutput p φ z.2.1 x)
    p.radius hz p.radius_pos.le hr hzr hg.1.le (hg.2.trans (by have := p.radius_pos; linarith))
  exact not_lt_of_ge hc hbad

theorem all_width_score_compression (p : Input) {N : ℕ} (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : admissibleActivation φ) {t c : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : InformationTheory.klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) (hr : p.radius≤1/6)
    (hrob : ∀ᵐw ∂Q,w∈robustEvent φ c) (hrad : ∀ᵐw ∂Q,p.radius≤robustRadius c w) :
    ∃Γ : Measure (GridCode p),IsProbabilityMeasure Γ ∧
      ∃π : ∀x : Cube p.dimension,ProbabilityCoupling Q Γ,
        ∀x,(π x).joint.real (scoreFailure (fun w=>networkOutput φ w x) (fun q=>gridOutput p φ q x))≤p.failure := by
  classical
  obtain ⟨Γ,hΓ,hcouple⟩ := all_width_noisy_compression p hN hφ ht ht1 Q hQ
  choose π hπ using hcouple
  exact ⟨Γ,hΓ,fun x=>scoreCoupling (π x),fun x=>scoreCoupling_failure
    (admissibleActivation_continuous hφ) (π x) x hr hrob hrad (hπ x)⟩

end NeuralGeneralization.BatchTwoManuscriptResources
