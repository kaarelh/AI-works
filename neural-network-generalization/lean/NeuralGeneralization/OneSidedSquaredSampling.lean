import NeuralGeneralization.ArbitrarySquaredSampling

/-! The literal one-sided squared sampling lemma: arbitrary dependent
feature/label pairs, the full Euclidean unit ball, and D log(2D) samples. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
universe u
variable {Ω : Type*} [MeasurableSpace Ω] {D n : ℕ}

def negativeResponse : C(ℝ,ℝ) := ⟨fun t => max 0 (-t),by fun_prop⟩
def signedFeature (Z : Ω → ProcessVector D) (Y : Ω → Bool) (x : Ω) : ProcessVector D :=
  cubeCoordinateSign (Y x) • Z x

lemma signedFeature_measurable {Z : Ω → ProcessVector D} {Y : Ω → Bool}
    (hZ : Measurable Z) (hY : Measurable Y) : Measurable (signedFeature Z Y) :=
  ((measurable_of_finite cubeCoordinateSign).comp hY).smul hZ

lemma linearEvaluation_signedFeature (Z : Ω → ProcessVector D) (Y : Ω → Bool)
    (x : Ω) (u : ProcessVector D) :
    linearEvaluation (signedFeature Z Y x) u = cubeCoordinateSign (Y x)*linearEvaluation (Z x) u := by
  simp [signedFeature,linearEvaluation,Finset.mul_sum,mul_assoc]

lemma signedFeature_sq_norm (Z : Ω → ProcessVector D) (Y : Ω → Bool) (x : Ω) :
    ‖signedFeature Z Y x‖^2 = ‖Z x‖^2 := by
  unfold signedFeature
  cases Y x <;> simp [cubeCoordinateSign]

lemma signedFeature_isotropic (μ : Measure Ω) (Z : Ω → ProcessVector D) (Y : Ω → Bool)
    (hiso : ∀ u : ProcessVector D,(∫ x,linearEvaluation (Z x) u^2 ∂μ)=‖u‖^2) :
    ∀ u : ProcessVector D,(∫ x,linearEvaluation (signedFeature Z Y x) u^2 ∂μ)=‖u‖^2 := by
  intro u
  apply (integral_congr_ae _).trans (hiso u)
  filter_upwards with x
  rw [linearEvaluation_signedFeature]
  cases Y x <;> simp [cubeCoordinateSign]

/-- Δ_n in the manuscript, using the actual joint feature/label law. -/
def oneSidedSquaredDeviation (μ : Measure Ω) (Z : Ω → ProcessVector D)
    (Y : Ω → Bool) (s : Fin n → Ω) : ℝ :=
  sSup ((fun u : ProcessVector D =>
    |(∑ i,(max 0 (-(cubeCoordinateSign (Y (s i))*linearEvaluation (Z (s i)) u)))^2)/(n:ℝ)-
      ∫ x,(max 0 (-(cubeCoordinateSign (Y x)*linearEvaluation (Z x) u)))^2 ∂μ|) '' Metric.closedBall 0 1)

lemma oneSidedSquaredDeviation_eq (μ : Measure Ω) (Z : Ω → ProcessVector D)
    (Y : Ω → Bool) (hI : Integrable (fun x => squaredFeature negativeResponse (signedFeature Z Y x)) μ)
    (s : Fin n → Ω) :
    empiricalDeviation μ n (fun x => squaredFeature negativeResponse (signedFeature Z Y x)) s =
      oneSidedSquaredDeviation μ Z Y s := by
  rw [arbitrary_empiricalDeviation_eq_sup μ (signedFeature Z Y) negativeResponse hI]
  simp only [oneSidedSquaredDeviation,negativeResponse,ContinuousMap.coe_mk,linearEvaluation_signedFeature]

/-- Universal expected bound, with no independence assumption between Y and Z.
The quadratic isotropy identity is E ZZᵀ=I_D written as quadratic forms. -/
theorem one_sided_squared_sampling_expectation (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Z : Ω → ProcessVector D) (Y : Ω → Bool) (hZ : Measurable Z) (hY : Measurable Y)
    (hrow : ∀ᵐ x ∂μ,‖Z x‖^2 ≤ D)
    (hiso : ∀ u : ProcessVector D,(∫ x,linearEvaluation (Z x) u^2 ∂μ)=‖u‖^2)
    (hn : 0<n) (hD : 0<D) :
    (∫ s : Fin n → Ω,oneSidedSquaredDeviation μ Z Y s ∂Measure.pi (fun _ => μ)) ≤
      squaredSamplingUniversalConstant*squaredSamplingScale n D*
        (1+squaredSamplingUniversalConstant*squaredSamplingScale n D) := by
  have hrow' : ∀ᵐ x ∂μ,‖signedFeature Z Y x‖^2 ≤ D := by
    simpa only [signedFeature_sq_norm] using hrow
  obtain ⟨hI,_,hh⟩ := arbitrary_squared_sampling_aux μ (signedFeature Z Y)
    (signedFeature_measurable hZ hY) hrow' (signedFeature_isotropic μ Z Y hiso)
    negativeResponse (by norm_num [negativeResponse]) negativePart_lipschitz hn hD
  simpa only [oneSidedSquaredDeviation_eq μ Z Y hI] using hh

/-- The printed probability statement, with A chosen before D, n and the
entire joint distribution of the features and labels. -/
theorem one_sided_squared_sampling_probability {ε δ : ℝ} (hε : 0<ε) (hδ : 0<δ) :
    ∃ A : ℝ,0<A ∧ ∀ (D n : ℕ) (Ω : Type u) [MeasurableSpace Ω]
      (μ : Measure Ω),IsProbabilityMeasure μ →
      ∀ (Z : Ω → ProcessVector D) (Y : Ω → Bool),Measurable Z → Measurable Y →
      (∀ᵐ x ∂μ,‖Z x‖^2 ≤ D) →
      (∀ u : ProcessVector D,(∫ x,linearEvaluation (Z x) u^2 ∂μ)=‖u‖^2) →
      0<D → A*(D:ℝ)*Real.log (2*(D:ℝ)) ≤ n →
      (Measure.pi (fun _ : Fin n => μ)).real {s | ε < oneSidedSquaredDeviation μ Z Y s} ≤ δ := by
  obtain ⟨A,hA,hbudget⟩ := arbitrary_squared_sampling_probability hε hδ
  refine ⟨A,hA,?_⟩
  intro D n Ω mΩ μ hμ Z Y hZ hY hrow hiso hD hn
  letI := hμ
  have hrow' : ∀ᵐ x ∂μ,‖signedFeature Z Y x‖^2 ≤ D := by
    simpa only [signedFeature_sq_norm] using hrow
  have hd : (1:ℝ)≤D := by exact_mod_cast hD
  have hp : 0<A*(D:ℝ)*Real.log (2*(D:ℝ)) :=
    mul_pos (mul_pos hA (by positivity)) (Real.log_pos (by linarith))
  have hnpos : 0<n := by exact_mod_cast lt_of_lt_of_le hp hn
  have hi := arbitrary_squared_sampling_aux μ (signedFeature Z Y)
    (signedFeature_measurable hZ hY) hrow' (signedFeature_isotropic μ Z Y hiso)
    negativeResponse (by norm_num [negativeResponse]) negativePart_lipschitz hnpos hD
  have hh := hbudget D n Ω μ hμ (signedFeature Z Y) (signedFeature_measurable hZ hY)
    hrow' (signedFeature_isotropic μ Z Y hiso) negativeResponse
    (by norm_num [negativeResponse]) negativePart_lipschitz hD hn
  simpa only [oneSidedSquaredDeviation_eq μ Z Y hi.1] using hh

end NeuralGeneralization.SquaredSampling
