import RareSeedCalibration
import ScalarScoreGeometry

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

variable {d : ℕ}

theorem tagged_feature_square_integrable (ρ : Measure (Bool×(Option (Fin d)→ℝ)))
    [IsProbabilityMeasure ρ] (x : ClippingCube d) :
    Integrable (fun p => tanhCubeFeature p.2 x ^ 2) ρ := by
  apply Integrable.of_bound
    (((measurable_tanhCubeFeature x).comp measurable_snd).pow_const 2).aestronglyMeasurable 1
  filter_upwards [] with p
  rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
  exact (sq_le_one_iff_abs_le_one _).mpr (tanhCubeFeature_abs_le_one p.2 x)

theorem rareSeed_feature_secondMoment (θ : ℝ) (μ ν : Measure (Option (Fin d)→ℝ))
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1)
    (x : ClippingCube d) :
    (∫ p, tanhCubeFeature p.2 x ^ 2 ∂rareSeedLaw θ μ ν)=
      (1-θ)*(∫ w,tanhCubeFeature w x ^ 2 ∂μ)+θ*(∫ w,tanhCubeFeature w x ^ 2 ∂ν) := by
  haveI (b : Bool) : IsProbabilityMeasure (if b then ν else μ) := by cases b <;> infer_instance
  rw [rareSeedLaw,finiteProbabilityMixture_integral _ _
    (rareTagWeight_nonneg θ hθ0 hθ1) _ (fun b => tagged_feature_square_integrable _ x)]
  simp only [Fintype.sum_bool,rareTagWeight,Bool.false_eq_true,if_false,if_true]
  have hm : Measurable (fun p : Bool×(Option (Fin d)→ℝ) => tanhCubeFeature p.2 x ^ 2) :=
    (((measurable_tanhCubeFeature x).comp measurable_snd).pow_const 2)
  rw [taggedRowLaw_integral true ν (fun p => tanhCubeFeature p.2 x ^ 2) hm,
    taggedRowLaw_integral false μ (fun p => tanhCubeFeature p.2 x ^ 2) hm]
  ring

theorem rareFourierSeed_constant_diagonal (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) (x y : ClippingCube d) :
    (∫ p,tanhCubeFeature p.2 x ^ 2 ∂rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ))=
      ∫ p,tanhCubeFeature p.2 y ^ 2 ∂rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ) := by
  letI := actualFourierSeedLaw_probability f σ hf hσ
  rw [rareSeed_feature_secondMoment θ _ _ hθ0 hθ1 x,
    rareSeed_feature_secondMoment θ _ _ hθ0 hθ1 y,
    actualFourierSeedLaw_constant_diagonal f σ hf hσ x y]
  have hraw : (∫ w,tanhCubeFeature w x ^ 2 ∂seedGaussianReference σ)=
      ∫ w,tanhCubeFeature w y ^ 2 ∂seedGaussianReference σ :=
    gaussianReference_tanh_constant_diagonal _ x y
  rw [hraw]

def rareSeedDiagonal (f : ClippingCube d→ℝ) (σ θ : ℝ) : ℝ :=
  ∫ p,tanhCubeFeature p.2 (fun _ => true) ^ 2
    ∂rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ)

theorem rareSeedDiagonal_bounds (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) : 0 ≤ rareSeedDiagonal f σ θ ∧ rareSeedDiagonal f σ θ ≤ 1 := by
  letI := actualFourierSeedLaw_probability f σ hf hσ
  letI := rareSeedLaw_probability θ (seedGaussianReference σ) (actualFourierSeedLaw f σ) hθ0 hθ1
  refine ⟨integral_nonneg (fun _ => sq_nonneg _),?_⟩
  have hh := integral_mono (tagged_feature_square_integrable
    (rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ)) (fun _ => true))
    (integrable_const (1 : ℝ)) (fun z =>
      (sq_le_one_iff_abs_le_one _).mpr (tanhCubeFeature_abs_le_one z.2 (fun _ => true)))
  simpa only [rareSeedDiagonal,integral_const,probReal_univ,smul_eq_mul,mul_one,one_mul] using hh

theorem rareSeedScore_memLp (θ : ℝ) (hθ : 0 < θ)
    (ρ : Measure (Bool×(Option (Fin d)→ℝ))) [IsProbabilityMeasure ρ] :
    MemLp (rareSeedScore θ) 2 ρ := by
  apply MemLp.of_bound (measurable_rareSeedScore θ).aestronglyMeasurable (1/Real.sqrt θ)
  filter_upwards [] with z
  exact rareSeedScore_bound θ hθ z

/-- Unit-score projection proves that the actual remaining feature variance is
nonnegative; it is not assumed as part of a seed certificate. -/
theorem rareSeedDiagonal_signal_le (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hbool : ∀ x,(f x)^2=1) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 < θ) (hθ1 : θ ≤ 1) :
    θ/(fourierSeedNormalizer f σ)^2 ≤ rareSeedDiagonal f σ θ := by
  letI := actualFourierSeedLaw_probability f σ hf hσ
  let Q := rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ)
  letI : IsProbabilityMeasure Q := rareSeedLaw_probability θ _ _ hθ0.le hθ1
  let b := rareSeedScore (d := d) θ
  let h := fun z : Bool×(Option (Fin d)→ℝ) => tanhCubeFeature z.2 (fun _ => true)
  have hb := rareSeedScore_memLp θ hθ0 Q
  have hu := rareSeedScore_secondMoment θ (seedGaussianReference σ) (actualFourierSeedLaw f σ) hθ0 hθ1
  have hm : Measurable h := (measurable_tanhCubeFeature (fun _ => true)).comp measurable_snd
  have hbound (z : Bool×(Option (Fin d)→ℝ)) : |h z| ≤ 1 := tanhCubeFeature_abs_le_one _ _
  have hunit := scalarScoreL2_unit Q b hb hu
  have hh := sq_nonneg ‖scalarScoreResidual (scalarScoreL2 Q b hb) (boundedL2Feature Q h hm hbound)‖
  rw [scalarScoreResidual_norm_sq _ _ hunit,boundedL2Feature_norm_sq,
    scalarScoreL2_inner] at hh
  have hcorr := rareFourierSeed_correlation f σ θ hf hσ (seedGaussianReference σ) hθ0 hθ1 (fun _ => true)
  change 0 ≤ rareSeedDiagonal f σ θ - (∫ z,b z*h z ∂Q)^2 at hh
  change (∫ z,b z*h z ∂Q)=(Real.sqrt θ/fourierSeedNormalizer f σ)*f (fun _ => true) at hcorr
  rw [hcorr,mul_pow,div_pow,Real.sq_sqrt hθ0.le,hbool,mul_one] at hh
  linarith

#print axioms rareSeedDiagonal_signal_le
end ConditionalNonpolynomial.Analytic
