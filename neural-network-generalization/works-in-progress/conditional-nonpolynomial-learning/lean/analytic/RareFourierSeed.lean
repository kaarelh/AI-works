import ActualFourierSeedLaw

/-! The rare-mixture tag used by the actual finite-width scalar channel. The
score's unit second moment gives a target component proportional to theta,
rather than theta squared. This module proves actual moment identities; the
entropy comparison of the tagged controlled and reference laws is separate. -/

noncomputable section
open scoped BigOperators
open MeasureTheory NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

def rareTagWeight (θ : ℝ) (b : Bool) : ℝ := if b then θ else 1-θ

theorem rareTagWeight_nonneg (θ : ℝ) (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) (b : Bool) :
    0 ≤ rareTagWeight θ b := by
  cases b <;> simp [rareTagWeight] <;> linarith

theorem rareTagWeight_sum (θ : ℝ) : (∑ b : Bool, rareTagWeight θ b) = 1 := by
  simp [rareTagWeight]

def taggedRowLaw (b : Bool) (μ : Measure (Option (Fin d) → ℝ)) :
    Measure (Bool × (Option (Fin d) → ℝ)) := μ.map (fun w => (b,w))

theorem measurable_taggedRowMap (b : Bool) :
    Measurable (fun w : Option (Fin d) → ℝ => (b,w)) :=
  measurable_const.prodMk measurable_id

theorem taggedRowLaw_integral (b : Bool) (μ : Measure (Option (Fin d) → ℝ))
    (F : Bool × (Option (Fin d) → ℝ) → ℝ) (hF : Measurable F) :
    (∫ p, F p ∂taggedRowLaw b μ) = ∫ w, F (b,w) ∂μ := by
  rw [taggedRowLaw, integral_map (measurable_taggedRowMap b).aemeasurable hF.aestronglyMeasurable]

instance taggedRowLaw_probability (b : Bool) (μ : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] : IsProbabilityMeasure (taggedRowLaw b μ) :=
  Measure.isProbabilityMeasure_map (measurable_taggedRowMap b).aemeasurable

def rareSeedLaw (θ : ℝ) (μ ν : Measure (Option (Fin d) → ℝ)) :
    Measure (Bool × (Option (Fin d) → ℝ)) :=
  finiteProbabilityMixture (rareTagWeight θ)
    (fun b => taggedRowLaw b (if b then ν else μ))

theorem rareSeedLaw_probability (θ : ℝ) (μ ν : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    IsProbabilityMeasure (rareSeedLaw θ μ ν) := by
  haveI (b : Bool) : IsProbabilityMeasure (if b then ν else μ) := by cases b <;> infer_instance
  exact finiteProbabilityMixture_isProbability _ _ (rareTagWeight_nonneg θ hθ0 hθ1)
    (rareTagWeight_sum θ)

def rareSeedScore (θ : ℝ) (p : Bool × (Option (Fin d) → ℝ)) : ℝ :=
  if p.1 then 1 / Real.sqrt θ else 0

theorem measurable_rareSeedScore (θ : ℝ) :
    Measurable (rareSeedScore (d := d) θ) :=
  (measurable_of_countable (fun b : Bool => if b then 1 / Real.sqrt θ else 0)).comp measurable_fst

theorem rareSeedScore_bound (θ : ℝ) (hθ : 0 < θ) (p : Bool × (Option (Fin d) → ℝ)) :
    |rareSeedScore θ p| ≤ 1 / Real.sqrt θ := by
  cases hb : p.1
  · simp only [rareSeedScore, hb, Bool.false_eq_true, if_false, abs_zero]
    positivity
  · simp only [rareSeedScore, hb, if_true]
    rw [abs_of_pos (one_div_pos.mpr (Real.sqrt_pos.mpr hθ))]

theorem rareSeedScore_square_integrable (θ : ℝ) (hθ : 0 < θ)
    (ρ : Measure (Bool × (Option (Fin d) → ℝ))) [IsProbabilityMeasure ρ] :
    Integrable (fun p => rareSeedScore θ p ^ 2) ρ := by
  apply Integrable.of_bound ((measurable_rareSeedScore θ).pow_const 2).aestronglyMeasurable
    ((1 / Real.sqrt θ)^2)
  apply ae_of_all
  intro p
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  have hh := pow_le_pow_left₀ (abs_nonneg _) (rareSeedScore_bound θ hθ p) 2
  simpa only [sq_abs] using hh

theorem rareSeedScore_feature_integrable (θ : ℝ) (hθ : 0 < θ)
    (ρ : Measure (Bool × (Option (Fin d) → ℝ))) [IsProbabilityMeasure ρ]
    (x : ClippingCube d) :
    Integrable (fun p => rareSeedScore θ p * tanhCubeFeature p.2 x) ρ := by
  apply Integrable.of_bound
    ((measurable_rareSeedScore θ).mul ((measurable_tanhCubeFeature x).comp measurable_snd)).aestronglyMeasurable
    (1 / Real.sqrt θ)
  apply ae_of_all
  intro p
  change |rareSeedScore θ p * tanhCubeFeature p.2 x| ≤ _
  rw [abs_mul]
  exact (mul_le_mul (rareSeedScore_bound θ hθ p) (tanhCubeFeature_abs_le_one p.2 x)
    (abs_nonneg _) (by positivity)).trans_eq (mul_one _)

/-- The latent rare-event score has second moment exactly one. -/
theorem rareSeedScore_secondMoment (θ : ℝ) (μ ν : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] (hθ0 : 0 < θ) (hθ1 : θ ≤ 1) :
    (∫ p, rareSeedScore θ p ^ 2 ∂rareSeedLaw θ μ ν) = 1 := by
  haveI (b : Bool) : IsProbabilityMeasure (if b then ν else μ) := by cases b <;> infer_instance
  rw [rareSeedLaw, finiteProbabilityMixture_integral _ _
    (rareTagWeight_nonneg θ hθ0.le hθ1) _
    (fun b => rareSeedScore_square_integrable θ hθ0 _)]
  simp only [Fintype.sum_bool, rareTagWeight, Bool.false_eq_true, if_false, if_true]
  have hfalse : (∫ p, rareSeedScore θ p ^ 2 ∂taggedRowLaw false μ) = 0 := by
    rw [taggedRowLaw_integral _ _ _ ((measurable_rareSeedScore θ).pow_const 2)]
    simp [rareSeedScore]
  have htrue : (∫ p, rareSeedScore θ p ^ 2 ∂taggedRowLaw true ν) = (1/Real.sqrt θ)^2 := by
    rw [taggedRowLaw_integral _ _ _ ((measurable_rareSeedScore θ).pow_const 2)]
    simp [rareSeedScore]
  rw [hfalse, htrue]
  rw [div_pow, Real.sq_sqrt hθ0.le]
  field_simp
  ring

theorem rareSeedScore_correlation (θ : ℝ) (μ ν : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] (hθ0 : 0 < θ) (hθ1 : θ ≤ 1)
    (x : ClippingCube d) :
    (∫ p, rareSeedScore θ p * tanhCubeFeature p.2 x ∂rareSeedLaw θ μ ν) =
      Real.sqrt θ * ∫ w, tanhCubeFeature w x ∂ν := by
  haveI (b : Bool) : IsProbabilityMeasure (if b then ν else μ) := by cases b <;> infer_instance
  rw [rareSeedLaw, finiteProbabilityMixture_integral _ _
    (rareTagWeight_nonneg θ hθ0.le hθ1) _
    (fun b => rareSeedScore_feature_integrable θ hθ0 _ x)]
  simp only [Fintype.sum_bool, rareTagWeight, Bool.false_eq_true, if_false, if_true]
  have hmeas : Measurable (fun p : Bool × (Option (Fin d) → ℝ) =>
      rareSeedScore θ p * tanhCubeFeature p.2 x) :=
    (measurable_rareSeedScore θ).mul ((measurable_tanhCubeFeature x).comp measurable_snd)
  have hfalse : (∫ p, rareSeedScore θ p * tanhCubeFeature p.2 x ∂taggedRowLaw false μ) = 0 := by
    rw [taggedRowLaw_integral _ _ _ hmeas]
    simp [rareSeedScore]
  have htrue : (∫ p, rareSeedScore θ p * tanhCubeFeature p.2 x ∂taggedRowLaw true ν) =
      (1/Real.sqrt θ) * ∫ w, tanhCubeFeature w x ∂ν := by
    rw [taggedRowLaw_integral _ _ _ hmeas]
    simp only [rareSeedScore, if_true, integral_const_mul]
  rw [hfalse, htrue]
  have hs : Real.sqrt θ ≠ 0 := (Real.sqrt_pos.mpr hθ0).ne'
  have hsq := Real.sq_sqrt hθ0.le
  field_simp
  rw [hsq]
  ring

/-- For the concrete Fourier law, the score correlation is sqrt(theta) f/Z. -/
theorem rareFourierSeed_correlation (f : ClippingCube d → ℝ) (σ θ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ]
    (hθ0 : 0 < θ) (hθ1 : θ ≤ 1) (x : ClippingCube d) :
    (∫ p, rareSeedScore θ p * tanhCubeFeature p.2 x
      ∂rareSeedLaw θ μ (actualFourierSeedLaw f σ)) =
      (Real.sqrt θ / fourierSeedNormalizer f σ) * f x := by
  letI := actualFourierSeedLaw_probability f σ hf hσ
  rw [rareSeedScore_correlation θ μ _ hθ0 hθ1, actualFourierSeedLaw_mean f σ hf hσ x]
  ring

theorem sampleMemorizer_nonzero {n : ℕ} (sample : Fin n → ClippingCube d)
    (f : ClippingCube d → Bool) :
    ∃ x, pointExceptionFunction (negativeSamplePoints sample f) x ≠ 0 := by
  refine ⟨fun _ => true, ?_⟩
  rcases pointExceptionFunction_boolean (negativeSamplePoints sample f) (fun _ => true) with h | h <;>
    rw [h] <;> norm_num

/-- The exact sample memorizer has a polynomial inverse-mean budget. -/
theorem sampleMemorizer_fourierSeedNormalizer_le {n : ℕ}
    (sample : Fin n → ClippingCube d) (f : ClippingCube d → Bool) (σ : ℝ)
    (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    fourierSeedNormalizer (pointExceptionFunction (negativeSamplePoints sample f)) σ ≤
      2*((d : ℝ)+1)*(1+2*(n : ℝ)) := by
  have h := fourierSeedNormalizer_le (pointExceptionFunction (negativeSamplePoints sample f)) σ hσ
  have hv := sampleMemorizer_walshVariation sample f
  exact h.trans (mul_le_mul_of_nonneg_left hv (by positivity))

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.rareSeedScore_secondMoment
#print axioms ConditionalNonpolynomial.Analytic.rareFourierSeed_correlation
#print axioms ConditionalNonpolynomial.Analytic.sampleMemorizer_fourierSeedNormalizer_le
