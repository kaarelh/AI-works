import NeuralGeneralization.CompactSquaredSampling

/-! The squared-sampling estimate in the manuscript's normalized form. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
variable {X E : Type*} [MeasurableSpace X]
variable [NormedAddCommGroup E] [NormedSpace ℝ E]

def empiricalDeviation (μ : Measure X) (n : ℕ) (F : X → E) (s : Fin n → X) : ℝ :=
  ‖(n:ℝ)⁻¹ • sampleSum F s-∫ x,F x ∂μ‖

lemma empiricalDeviation_eq_div (μ : Measure X) {n : ℕ} (hn : 0<n)
    (F : X → E) (s : Fin n → X) :
    empiricalDeviation μ n F s = ‖sampleSum F s-(n:ℝ) • ∫ x,F x ∂μ‖/(n:ℝ) := by
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  have he : (n:ℝ)⁻¹ • sampleSum F s-∫ x,F x ∂μ =
      (n:ℝ)⁻¹ • (sampleSum F s-(n:ℝ) • ∫ x,F x ∂μ) := by
    rw [smul_sub,smul_smul,inv_mul_cancel₀ hnR.ne',one_smul]
  rw [empiricalDeviation,he,norm_smul,Real.norm_eq_abs,abs_of_nonneg (inv_nonneg.mpr hnR.le)]
  ring

def squaredSamplingScale (n D : ℕ) : ℝ :=
  Real.sqrt ((D:ℝ)*Real.log (2*((n:ℝ)+D))/(n:ℝ))

def squaredSamplingUniversalConstant : ℝ := 2147483648

lemma squared_sampling_normalization {n D : ℕ} (hn : 0<n) (hD : 0<D) :
    (4*(squaredProcessCoefficient n D)^2+2*squaredProcessCoefficient n D*Real.sqrt (n:ℝ))/(n:ℝ) =
      squaredSamplingUniversalConstant*squaredSamplingScale n D*
        (1+squaredSamplingUniversalConstant*squaredSamplingScale n D) := by
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  have hlog : 0≤Real.log (2*((n:ℝ)+D)) := Real.log_nonneg (by have hDR : (0:ℝ) ≤ D := Nat.cast_nonneg D; linarith)
  have hnroot := Real.sq_sqrt hnR.le
  have hnrootpos := Real.sqrt_pos.mpr hnR
  have he : squaredSamplingScale n D =
      Real.sqrt (D:ℝ)*Real.sqrt (Real.log (2*((n:ℝ)+D)))/Real.sqrt (n:ℝ) := by
    rw [squaredSamplingScale,Real.sqrt_div (mul_nonneg (Nat.cast_nonneg D) hlog),
      Real.sqrt_mul (Nat.cast_nonneg D)]
  rw [he]
  unfold squaredSamplingUniversalConstant squaredProcessCoefficient
  field_simp
  simp only [hnroot]
  ring

variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable [BorelSpace X] [SecondCountableTopology X]

lemma continuous_empiricalDeviation [CompleteSpace E] (μ : Measure X) (n : ℕ) {F : X → E} (hF : Continuous F) :
    Continuous (empiricalDeviation μ n F) :=
  ((continuous_sampleSum hF).const_smul _ |>.sub continuous_const).norm

/-- This is exactly the uncountable supremum appearing in the paper, not a
finite net or a surrogate loss. -/
theorem empiricalDeviation_eq_sup {D n : ℕ} (μ : Measure X)
    [IsProbabilityMeasure μ] (a : X → ProcessVector D) (ha : Continuous a)
    (ψ : C(ℝ,ℝ)) (s : Fin n → X) :
    empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s =
      sSup ((fun u : ProcessVector D =>
        |(∑ i,ψ (linearEvaluation (a (s i)) u)^2)/(n:ℝ)-
          ∫ x,ψ (linearEvaluation (a x) u)^2 ∂μ|) '' Metric.closedBall 0 1) := by
  unfold empiricalDeviation
  rw [ContinuousMap.norm_eq_iSup_norm]
  unfold iSup
  congr 1
  have hint : Integrable (fun x => squaredFeature ψ (a x)) μ :=
    compact_integrable μ ((continuous_squaredFeature ψ).comp ha)
  have he (u : ProcessUnitBall D) :
      ‖((n:ℝ)⁻¹ • sampleSum (fun x => squaredFeature ψ (a x)) s-
        ∫ x,squaredFeature ψ (a x) ∂μ) u‖ =
        |(∑ i,ψ (linearEvaluation (a (s i)) u.val)^2)/(n:ℝ)-
          ∫ x,ψ (linearEvaluation (a x) u.val)^2 ∂μ| := by
    simp only [ContinuousMap.sub_apply,ContinuousMap.smul_apply,
      ContinuousMap.integral_apply hint,sampleSum,ContinuousMap.sum_apply,
      squaredFeature,ContinuousMap.coe_mk,smul_eq_mul,Real.norm_eq_abs]
    congr 2
    · ring
    · exact ContinuousMap.integral_apply hint u
  ext z
  constructor
  · rintro ⟨u,rfl⟩
    exact ⟨u.val,u.property,(he u).symm⟩
  · rintro ⟨u,hu,rfl⟩
    exact ⟨⟨u,hu⟩,he ⟨u,hu⟩⟩

/-- The printed C h_n (1+C h_n) bound with one universal constant, for
arbitrary probability laws and every zero-at-zero 1-Lipschitz response. -/
theorem squared_sampling_integral {D n : ℕ} (μ : Measure X) [IsProbabilityMeasure μ]
    (a : X → ProcessVector D) (ha : Continuous a) (hrow : ∀ x,‖a x‖^2 ≤ D)
    (hiso : ∀ u : ProcessVector D,(∫ x,linearEvaluation (a x) u^2 ∂μ)=‖u‖^2)
    (ψ : C(ℝ,ℝ)) (hψ0 : ψ 0=0) (hψ : ∀ x y,|ψ x-ψ y| ≤ |x-y|)
    (hn : 0<n) (hD : 0<D) :
    (∫ s : Fin n → X,empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s
      ∂Measure.pi (fun _ => μ)) ≤
      squaredSamplingUniversalConstant*squaredSamplingScale n D*
        (1+squaredSamplingUniversalConstant*squaredSamplingScale n D) := by
  simp_rw [empiricalDeviation_eq_div μ hn]
  rw [integral_div]
  apply (div_le_div_of_nonneg_right
    (compact_squared_sampling μ a ha hrow hiso ψ hψ0 hψ hn hD) (Nat.cast_nonneg n)).trans_eq
  exact squared_sampling_normalization hn hD

end NeuralGeneralization.SquaredSampling
