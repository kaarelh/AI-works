import NeuralGeneralization.SquaredSamplingLawTransfer

/-! Uniform squared sampling for arbitrary measurable isotropic features.
The norm restriction holds almost surely; there is no finite support,
continuity, or feature/label independence hypothesis. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
universe u
variable {Ω : Type*} [MeasurableSpace Ω] {D n : ℕ}

/-- The response, its actual uniform empirical deviation, and the expected
bound are all well defined under an almost-sure feature bound. -/
theorem arbitrary_squared_sampling_aux (μ : Measure Ω) [IsProbabilityMeasure μ]
    (a : Ω → ProcessVector D) (ha : Measurable a) (hrow : ∀ᵐ x ∂μ,‖a x‖^2 ≤ D)
    (hiso : ∀ u : ProcessVector D,(∫ x,linearEvaluation (a x) u^2 ∂μ)=‖u‖^2)
    (ψ : C(ℝ,ℝ)) (hψ0 : ψ 0=0) (hψ : ∀ x y,|ψ x-ψ y| ≤ |x-y|)
    (hn : 0<n) (hD : 0<D) :
    Integrable (fun x => squaredFeature ψ (a x)) μ ∧
    Integrable (empiricalDeviation μ n (fun x => squaredFeature ψ (a x)))
      (Measure.pi (fun _ : Fin n => μ)) ∧
    (∫ s : Fin n → Ω,empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s
      ∂Measure.pi (fun _ => μ)) ≤
      squaredSamplingUniversalConstant*squaredSamplingScale n D*
        (1+squaredSamplingUniversalConstant*squaredSamplingScale n D) := by
  let b := fun x => boundFeature (a x)
  have hb : Measurable b := measurable_boundFeature.comp ha
  let ν := μ.map b
  haveI : IsProbabilityMeasure ν := Measure.isProbabilityMeasure_map hb.aemeasurable
  have hba : (fun x => (b x).val) =ᵐ[μ] a := boundFeature_eq_ae μ a hrow
  have hF : Continuous (fun z : BoundedFeature D => squaredFeature ψ z.val) :=
    (continuous_squaredFeature ψ).comp continuous_subtype_val
  have hi (u : ProcessVector D) :
      (∫ z : BoundedFeature D,linearEvaluation z.val u^2 ∂ν)=‖u‖^2 := by
    have hc : Continuous (fun z : BoundedFeature D => linearEvaluation z.val u^2) := by
      unfold linearEvaluation
      fun_prop
    rw [show ν=μ.map b from rfl,integral_map hb.aemeasurable hc.aestronglyMeasurable]
    apply (integral_congr_ae _).trans (hiso u)
    filter_upwards [hba] with x hx
    rw [hx]
  have hbound := squared_sampling_integral ν (fun z : BoundedFeature D => z.val)
    continuous_subtype_val boundedFeature_sq_le hi ψ hψ0 hψ hn hD
  have hFae : (fun x => squaredFeature ψ (b x).val) =ᵐ[μ] (fun x => squaredFeature ψ (a x)) :=
    hba.fun_comp (squaredFeature ψ)
  have hdev := empiricalDeviation_congr_ae μ hFae n
  have hFI : Integrable (fun x => squaredFeature ψ (b x).val) μ :=
    (integrable_map_measure hF.aestronglyMeasurable hb.aemeasurable).mp (compact_integrable ν hF)
  have hDI := empiricalDeviation_integrable_pullback μ b hb
    (fun z : BoundedFeature D => squaredFeature ψ z.val) hF n
  refine ⟨hFI.congr hFae,hDI.congr hdev,?_⟩
  rw [← integral_congr_ae hdev,empiricalDeviation_integral_map μ b hb
    (fun z : BoundedFeature D => squaredFeature ψ z.val) hF n]
  exact hbound

/-- Literal equality to the paper's supremum over every unit vector. -/
theorem arbitrary_empiricalDeviation_eq_sup (μ : Measure Ω)
    (a : Ω → ProcessVector D) (ψ : C(ℝ,ℝ))
    (hI : Integrable (fun x => squaredFeature ψ (a x)) μ) (s : Fin n → Ω) :
    empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s =
      sSup ((fun u : ProcessVector D =>
        |(∑ i,ψ (linearEvaluation (a (s i)) u)^2)/(n:ℝ)-
          ∫ x,ψ (linearEvaluation (a x) u)^2 ∂μ|) '' Metric.closedBall 0 1) := by
  unfold empiricalDeviation
  rw [ContinuousMap.norm_eq_iSup_norm]
  unfold iSup
  congr 1
  have he (u : ProcessUnitBall D) :
      ‖((n:ℝ)⁻¹ • sampleSum (fun x => squaredFeature ψ (a x)) s-
        ∫ x,squaredFeature ψ (a x) ∂μ) u‖ =
        |(∑ i,ψ (linearEvaluation (a (s i)) u.val)^2)/(n:ℝ)-
          ∫ x,ψ (linearEvaluation (a x) u.val)^2 ∂μ| := by
    simp only [ContinuousMap.sub_apply,ContinuousMap.smul_apply,sampleSum,
      ContinuousMap.sum_apply,squaredFeature,ContinuousMap.coe_mk,smul_eq_mul,Real.norm_eq_abs]
    congr 2
    · ring
    · exact ContinuousMap.integral_apply hI u
  ext z
  constructor
  · rintro ⟨u,rfl⟩
    exact ⟨u.val,u.property,(he u).symm⟩
  · rintro ⟨u,hu,rfl⟩
    exact ⟨⟨u,hu⟩,he ⟨u,hu⟩⟩

/-- A single finite constant A_(epsilon,delta) works for every dimension,
feature law, response and sample count satisfying n ≥ A D log(2D). -/
theorem arbitrary_squared_sampling_probability {ε δ : ℝ} (hε : 0<ε) (hδ : 0<δ) :
    ∃ A : ℝ,0<A ∧ ∀ (D n : ℕ) (Ω : Type u) [MeasurableSpace Ω]
      (μ : Measure Ω),IsProbabilityMeasure μ →
      ∀ (a : Ω → ProcessVector D),Measurable a →
      (∀ᵐ x ∂μ,‖a x‖^2 ≤ D) →
      (∀ u : ProcessVector D,(∫ x,linearEvaluation (a x) u^2 ∂μ)=‖u‖^2) →
      ∀ (ψ : C(ℝ,ℝ)),ψ 0=0 → (∀ x y,|ψ x-ψ y| ≤ |x-y|) →
      0<D → A*(D:ℝ)*Real.log (2*(D:ℝ)) ≤ n →
      (Measure.pi (fun _ : Fin n => μ)).real
        {s | ε < empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s} ≤ δ := by
  obtain ⟨A,hA,hbudget⟩ := squared_sampling_budget_exists hε hδ
  refine ⟨A,hA,?_⟩
  intro D n Ω mΩ μ hμ a ha hrow hiso ψ hψ0 hψ hD hn
  letI := hμ
  have hd : (1:ℝ)≤D := by exact_mod_cast hD
  have hp : 0<A*(D:ℝ)*Real.log (2*(D:ℝ)) :=
    mul_pos (mul_pos hA (by positivity)) (Real.log_pos (by linarith))
  have hnpos : 0<n := by exact_mod_cast lt_of_lt_of_le hp hn
  obtain ⟨_,hint,hbound⟩ := arbitrary_squared_sampling_aux μ a ha hrow hiso ψ hψ0 hψ hnpos hD
  have hm := mul_meas_ge_le_integral_of_nonneg
    (Filter.Eventually.of_forall (fun s => norm_nonneg
      ((n:ℝ)⁻¹ • sampleSum (fun x => squaredFeature ψ (a x)) s-∫ x,squaredFeature ψ (a x) ∂μ)))
    hint ε
  have hr : (Measure.pi (fun _ : Fin n => μ)).real
      {s | ε ≤ empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s} ≤ δ := by
    have hh := hm.trans (hbound.trans (hbudget D n hD hn))
    have hc := (mul_le_mul_iff_right₀ hε).mp hh
    simpa only [empiricalDeviation] using hc
  apply (measureReal_mono (μ:=Measure.pi (fun _ : Fin n => μ)) ?_).trans hr
  intro s hs
  change ε < empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s at hs
  change ε ≤ empiricalDeviation μ n (fun x => squaredFeature ψ (a x)) s
  exact hs.le

end NeuralGeneralization.SquaredSampling
