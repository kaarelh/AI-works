import NeuralGeneralization.BatchTwoImprovedReconstruction

/-! Jointly measurable sharp layer parameters.  The Gaussian coefficient
matrix depends on the active bank and sampled indices alone. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 800000
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry RobustCompressionReconstruction
open RobustCompression RobustCompressionClipping RobustCompressionGaussian
open RobustCompressionLayerGaussian Classical
variable {A : Type*} [MeasurableSpace A] {N q m D : ℕ}

structure SharpBankData (A : Type*) [MeasurableSpace A] (N D m q : ℕ) where
  basis : A → Fin q → EuclideanSpace ℝ (Fin N)
  active : A → Fin D → EuclideanSpace ℝ (Fin q)
  feature : A → Fin N → ℝ
  indices : A → Fin m → Fin N
  basis_measurable : Measurable basis
  active_measurable : Measurable active
  feature_measurable : Measurable feature
  indices_measurable : Measurable indices

namespace SharpBankData

def sources (b : SharpBankData A N D m q) (θ : A) : Fin N → Fin q → ℝ :=
  fun j k => sourceRows (b.basis θ) j k

@[fun_prop] theorem sources_measurable (b : SharpBankData A N D m q) : Measurable b.sources := by
  apply measurable_pi_lambda
  intro j
  exact (WithLp.measurable_ofLp 2 (Fin q → ℝ)).comp
    ((measurable_pi_apply j).comp (measurable_sourceRows.comp b.basis_measurable))

def clippedActive (b : SharpBankData A N D m q) (BH : ℝ) (θ : A) : Fin D → Fin q → ℝ :=
  fun i k => wholeClip BH (b.active θ i) k

@[fun_prop] theorem clippedActive_measurable (b : SharpBankData A N D m q) (BH : ℝ) :
    Measurable (b.clippedActive BH) := by
  apply measurable_pi_lambda
  intro i
  exact (WithLp.measurable_ofLp 2 (Fin q → ℝ)).comp
    ((measurable_wholeClip BH).comp ((measurable_pi_apply i).comp b.active_measurable))

def sharpParameters (b : SharpBankData A N D m q) (t BH : ℝ) : GaussianLayerParameters A D m q where
  idealMean := fun θ i => (∑ j, linearEvaluation (b.sources θ j) (b.clippedActive BH θ i)*b.feature θ j)/(N:ℝ)
  finiteMean := fun θ i => sampleAverage (b.indices θ) (fun j =>
    sourceMultiplier (b.sources θ) j*linearEvaluation (b.sources θ j) (b.clippedActive BH θ i)*b.feature θ j)
  idealVariance := fun θ _ => (t^2*‖queryResidual (b.basis θ) (normalizedFeature (b.feature θ))‖^2).toNNReal
  sourceMatrix := fun θ => whitenedMatrix (sourceMultiplier (b.sources θ)) (b.indices θ) (b.sources θ)
  sourceFeature := fun θ => weightedFeature (sourceMultiplier (b.sources θ)) (b.indices θ) (b.feature θ)
  scale := t
  idealMean_measurable := by
    have hs := b.sources_measurable
    have hH := b.clippedActive_measurable BH
    have hf := b.feature_measurable
    unfold linearEvaluation
    fun_prop
  finiteMean_measurable := by
    apply measurable_pi_lambda
    intro i
    unfold sampleAverage
    apply Measurable.div_const
    apply Finset.measurable_sum
    intro k _
    have hs := (measurable_pi_apply k).comp b.indices_measurable
    have ha := measurable_finite_select _ _ (measurable_sourceMultiplier.comp b.sources_measurable) hs
    have hu := measurable_finite_select _ _ b.sources_measurable hs
    have hh := (measurable_pi_apply i).comp (b.clippedActive_measurable BH)
    have hf := measurable_finite_select _ _ b.feature_measurable hs
    exact (ha.mul (Finset.measurable_sum _ (fun j _ =>
      ((measurable_pi_apply j).comp hu).mul ((measurable_pi_apply j).comp hh)))).mul hf
  idealVariance_measurable := by
    have hr := measurable_queryResidual.comp (b.basis_measurable.prodMk
      (measurable_normalizedFeature.comp b.feature_measurable))
    exact measurable_pi_lambda _ (fun _ => (hr.norm.pow_const 2).const_mul (t^2) |>.real_toNNReal)
  sourceMatrix_measurable := by
    change Measurable (fun θ => sharpSourceMatrix ((b.sources θ,b.active θ),b.indices θ))
    exact (measurable_sharpSourceMatrix (N:=N) (D:=D) (m:=m) (q:=q)).comp
      ((b.sources_measurable.prodMk b.active_measurable).prodMk b.indices_measurable)
  sourceFeature_measurable := by
    apply measurable_pi_lambda
    intro j
    have hs := (measurable_pi_apply j).comp b.indices_measurable
    exact (measurable_finite_select _ _
      (measurable_sourceMultiplier.comp b.sources_measurable) hs).sqrt.mul
        (measurable_finite_select _ _ b.feature_measurable hs)

theorem sharpParameters_contractive (b : SharpBankData A N D m q) (t BH : ℝ) :
    (b.sharpParameters t BH).Contractive := by
  intro θ v
  exact whitenedMatrix_contractive _ _ _ _

theorem sharpParameters_idealObservable (b : SharpBankData A N D m q)
    {t : ℝ} (ht : 0 ≤ t) (BH : ℝ) (θ : A) (z : Fin D → ℝ) (i : Fin D) :
    (b.sharpParameters t BH).idealObservable (θ,z) i =
      (∑ j, linearEvaluation (b.sources θ j) (b.clippedActive BH θ i)*b.feature θ j)/(N:ℝ)+
      t*‖queryResidual (b.basis θ) (normalizedFeature (b.feature θ))‖*z i := by
  change _+Real.sqrt (((t^2*‖queryResidual (b.basis θ) (normalizedFeature (b.feature θ))‖^2).toNNReal):ℝ)*z i = _
  rw [Real.coe_toNNReal _ (mul_nonneg (sq_nonneg _) (sq_nonneg _)),← mul_pow,
    Real.sqrt_sq (mul_nonneg ht (norm_nonneg _))]
  rfl

theorem sharpParameters_clippedFiniteObservable (b : SharpBankData A N D m q)
    (t BH BG : ℝ) (θ : A) (ξ : Fin D → Fin m → ℝ) (i : Fin D) :
    (b.sharpParameters t BH).clippedFiniteObservable BG (θ,ξ) i =
      ∑ j, sharpSourceRowsDraw t BH BG ((b.sources θ,b.active θ),b.indices θ) ξ i j *
        b.feature θ (b.indices θ j) := by
  dsimp only [GaussianLayerParameters.clippedFiniteObservable,clippedResidualEvaluation,sharpParameters]
  unfold sampleAverage weightedFeature sharpSourceRowsDraw clippedActive
  simp only [add_mul,Finset.sum_add_distrib,Finset.mul_sum,← Finset.sum_div]
  congr 1
  · rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j _
    ring
  · apply Finset.sum_congr rfl
    intro j _
    ring

end SharpBankData
end NeuralGeneralization.BatchTwoImprovedWeightedSampling
