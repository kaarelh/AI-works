import AdaptiveGaussianRows
import IndependentControlEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields

/-- A planted hidden layer consumes exactly N scalar-control entropies before
auxiliary variables are discarded, regardless of the past-dependent direction. -/
theorem adaptive_gaussian_rows_kl
    {I Ω H Y : Type*} [Fintype I] [DecidableEq I]
    [MeasurableSpace Ω] [MeasurableSpace H] [MeasurableSpace Y]
    [StandardBorelSpace Ω] [StandardBorelSpace H] [StandardBorelSpace Y]
    [Nonempty Ω] [Nonempty H]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (μQ μP : Measure H) [IsProbabilityMeasure μQ] [IsProbabilityMeasure μP]
    (ν : Measure Y) (N : ℕ)
    (Z : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1)
    (F : H→Y) (hF : MeasurePreserving F μP ν)
    (u : H→I→ℝ) (hu : Measurable u) (hnorm : ∀a,∑i,(u a i)^2=1) :
    klDiv
      ((μQ.prod (Measure.pi (fun _ : Fin N=>Q.prod (standardLaw I)))).map
        (fun p => (F p.1,directionSplitRows (J:=Fin N) Z (u p.1) p.2)))
      (ν.prod (Measure.pi (fun _ : Fin N=>standardLaw I)))
      ≤ klDiv μQ μP + N*klDiv Q P := by
  have href := adaptive_gaussian_rows_reference (J:=Fin N) P μP ν Z hZ hP F hF u hu hnorm
  rw [←href.map_eq]
  have h := mapped_product_control_kl μQ μP
    (Measure.pi (fun _ : Fin N=>Q.prod (standardLaw I)))
    (Measure.pi (fun _ : Fin N=>P.prod (standardLaw I)))
    (fun p=> (F p.1,directionSplitRows (J:=Fin N) Z (u p.1) p.2)) href.measurable
  simpa only [iid_control_kl,product_control_kl,klDiv_self,add_zero] using h

end ConditionalNonpolynomial.Analytic
