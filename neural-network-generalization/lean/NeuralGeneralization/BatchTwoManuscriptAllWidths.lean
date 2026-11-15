import NeuralGeneralization.BatchTwoManuscriptNoisyGrid

/-! Literal-J, all-width, all-scale compression before any stability assumption. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel RobustCompressionInduction

theorem bankSize_le_widthBound (p : Input) : bankSize p≤widthBound p :=
  (le_max_left _ _).trans (le_max_left _ _)

theorem all_width_noisy_compression (p : Input) {N : ℕ} (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : admissibleActivation φ) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) :
    ∃Γ : Measure (GridCode p),IsProbabilityMeasure Γ ∧
      ∀x : Cube p.dimension,∃π : NoisyGridCoupling Q Γ,
        π.joint.real (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/16))≤p.failure := by
  by_cases hsmall : N≤widthBound p
  · let Γ := Q.map (padRoundCode p hsmall)
    haveI : IsProbabilityMeasure Γ := Measure.isProbabilityMeasure_map (measurable_padRoundCode p hsmall).aemeasurable
    refine ⟨Γ,inferInstance,small_noisy_grid p Q hsmall hφ ?_⟩
    exact (small_width_weight_tail p hN hsmall ht ht1 Q hQ).trans (by have := p.failure_pos; linarith)
  · have hφl : LipschitzWith 1 φ := LipschitzWith.mk_one (fun x y=>by simpa only [Real.dist_eq] using hφ.2 x y)
    obtain ⟨Γ,hΓ,hraw⟩ := exists_large_width_raw_compression p (Nat.le_of_lt (Nat.lt_of_not_ge hsmall)) hφl hφ.1 ht ht1 Q hQ
    letI : IsProbabilityMeasure Γ := hΓ
    let Γgrid := Γ.map (padRoundCode p (bankSize_le_widthBound p))
    haveI : IsProbabilityMeasure Γgrid := Measure.isProbabilityMeasure_map
      (measurable_padRoundCode p (bankSize_le_widthBound p)).aemeasurable
    exact ⟨Γgrid,inferInstance,raw_noisy_grid p (bankSize_le_widthBound p) hφ hraw⟩

/-- The displayed J bounds one explicit finite class, common to all widths and
all scales. Every admissible law has an actual code law and exact original
marginal, with disturbances strictly below the chosen radius outside failure. -/
theorem literal_J_compression (p : Input) {φ : ℝ→ℝ} (hφ : admissibleActivation φ) :
    Real.log (Fintype.card (GridCode p):ℝ)≤gridEntropy p ∧
    ∀N : ℕ,0<N→∀t : ℝ,0<t→t≤1→
      ∀Q : Measure (Weights p.dimension N (p.depth-2)),IsProbabilityMeasure Q→
        klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
          ENNReal.ofReal ((N:ℝ)*p.energy/t^2)→
        ∃Γ : Measure (GridCode p),IsProbabilityMeasure Γ ∧
          ∀x : Cube p.dimension,∃π : NoisyGridCoupling Q Γ,
            π.joint.real (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/16))≤p.failure := by
  refine ⟨gridCode_log_card_le p,?_⟩
  intro N hN t ht ht1 Q hprob hQ
  letI : IsProbabilityMeasure Q := hprob
  exact all_width_noisy_compression p hN hφ ht ht1 Q hQ

end NeuralGeneralization.BatchTwoManuscriptResources
