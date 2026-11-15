import NeuralGeneralization.BatchTwoManuscriptAllWidths

/-! The appendix statement with its literal J and strict RMS disturbance. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel

theorem finite_compression_before_stability (p : Input) {N : ℕ} (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : admissibleActivation φ) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) :
    Real.log (Fintype.card (GridCode p):ℝ)≤gridEntropy p ∧
    ∃Γ : Measure (GridCode p),IsProbabilityMeasure Γ ∧
      ∀x : Cube p.dimension,∃π : NoisyGridCoupling Q Γ,
        1-p.failure≤π.joint.real {z | Real.sqrt (noiseBudgetSq z.2.2)<p.radius/2 ∧
          |gridOutput p φ z.2.1 x-noisyNetworkOutput φ z.1 x z.2.2|≤p.radius/8} := by
  obtain ⟨Γ,hΓ,hcouple⟩ := all_width_noisy_compression p hN hφ ht ht1 Q hQ
  refine ⟨gridCode_log_card_le p,Γ,hΓ,?_⟩
  intro x
  obtain ⟨π,hπ⟩ := hcouple x
  refine ⟨π,?_⟩
  have hb : π.joint.real (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/8))≤p.failure := by
    apply (measureReal_mono (μ:=π.joint) ?_).trans hπ
    intro z hz
    rcases hz with hn|ho
    · exact Or.inl hn
    · exact Or.inr ((by have := p.radius_pos; linarith : p.radius/16≤p.radius/8).trans_lt ho)
  have hs := measurable_noisyGridFailure (N:=N) (r:=p.depth-2) φ (admissibleActivation_continuous hφ)
    (gridOutput p φ) (fun _=>measurable_of_countable _) x (p.radius/2) (p.radius/8)
  have hc := measureReal_compl (μ:=π.joint) hs
  have he : (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/8))ᶜ=
      {z : NoisyGridState p.dimension N (p.depth-2) (GridCode p) |
        Real.sqrt (noiseBudgetSq z.2.2)<p.radius/2 ∧
        |gridOutput p φ z.2.1 x-noisyNetworkOutput φ z.1 x z.2.2|≤p.radius/8} := by
    ext z
    simp only [noisyGridFailure,Set.mem_compl_iff,Set.mem_setOf_eq,not_or,not_le,not_lt]
    rw [Real.sqrt_lt (noiseBudgetSq_nonneg _) (by have := p.radius_pos; positivity : 0≤p.radius/2)]
  rw [he,probReal_univ] at hc
  linarith

end NeuralGeneralization.BatchTwoManuscriptResources
