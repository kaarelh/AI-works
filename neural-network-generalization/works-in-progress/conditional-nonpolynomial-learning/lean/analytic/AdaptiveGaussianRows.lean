import GaussianDirectionSplit

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields

variable {I J : Type*} [Fintype I] [DecidableEq I] [Fintype J]

/-- All incoming rows at a stage use the same history-dependent direction,
but independent scalar controls and independent orthogonal Gaussian noises. -/
def directionSplitRows {Ω : Type*} (Z : Ω→ℝ) (u : I→ℝ)
    (w : J→Ω×(I→ℝ)) : J→I→ℝ := fun j=>directionSplit u (Z (w j).1) (w j).2

omit [DecidableEq I] [Fintype J] in
theorem directionSplitRows_measurable {Ω : Type*} [MeasurableSpace Ω]
    (Z : Ω→ℝ) (hZ : Measurable Z) (u : I→ℝ) :
    Measurable (directionSplitRows (J:=J) Z u) := by
  unfold directionSplitRows directionSplit
  fun_prop

theorem directionSplitRows_reference {Ω : Type*} [MeasurableSpace Ω]
    (P : Measure Ω) [IsProbabilityMeasure P]
    (Z : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1)
    (u : I→ℝ) (hu : ∑i,u i^2=1) :
    (Measure.pi (fun _ : J=>P.prod (standardLaw I))).map (directionSplitRows (J:=J) Z u)=
      Measure.pi (fun _ : J=>standardLaw I) := by
  let F : Ω×(I→ℝ)→I→ℝ := fun p=>directionSplit u (Z p.1) p.2
  have hF : Measurable F := by unfold F directionSplit; fun_prop
  haveI : IsProbabilityMeasure ((P.prod (standardLaw I)).map F) :=
    Measure.isProbabilityMeasure_map hF.aemeasurable
  have h := Measure.pi_map_pi (μ:=fun _ : J=>P.prod (standardLaw I))
    (f:=fun _=>F) (fun _=>hF.aemeasurable)
  change (Measure.pi (fun _ : J=>P.prod (standardLaw I))).map (fun w j=>F (w j))=_
  rw [h]
  congr 1
  funext j
  exact directionSplit_reference P Z hZ hP u hu

/-- The reference measure is unchanged even when the unit direction is chosen
measurably from all previously sampled control variables. This is an actual
pushforward-law identity, not a conditional-Gaussian assumption. -/
theorem adaptive_gaussian_rows_reference
    {Ω H Y : Type*} [MeasurableSpace Ω] [MeasurableSpace H] [MeasurableSpace Y]
    (P : Measure Ω) [IsProbabilityMeasure P]
    (μ : Measure H) [IsProbabilityMeasure μ] (ν : Measure Y)
    (Z : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1)
    (F : H→Y) (hF : MeasurePreserving F μ ν)
    (u : H→I→ℝ) (hu : Measurable u) (hnorm : ∀a,∑i,(u a i)^2=1) :
    MeasurePreserving
      (fun p : H×(J→Ω×(I→ℝ)) => (F p.1,directionSplitRows (J:=J) Z (u p.1) p.2))
      (μ.prod (Measure.pi (fun _ : J=>P.prod (standardLaw I))))
      (ν.prod (Measure.pi (fun _ : J=>standardLaw I))) := by
  apply hF.skew_product (g:=fun a=>directionSplitRows (J:=J) Z (u a))
  · unfold directionSplitRows directionSplit Function.uncurry
    fun_prop
  · exact ae_of_all _ fun a=>directionSplitRows_reference P Z hZ hP (u a) (hnorm a)

end ConditionalNonpolynomial.Analytic
