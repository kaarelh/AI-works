import NeuralGeneralization.BatchTwoImprovedSelectedCost

/-! The measurable error integrand of the actual sharp bank. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace Classical
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustEntropy RobustGaussianGeometry RobustCompressionLayerGaussian
variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}
namespace SharpBankData

def squaredError (b : SharpBankData A N N m q) (φ : ℝ → ℝ) (t BH BG : ℝ)
    (θ : A) (z : (Fin N → ℝ) × (Fin N → Fin m → ℝ)) : ℝ :=
  ∑ i, (φ (⟪b.active θ i,activeCoordinateVector (b.basis θ) (normalizedFeature (b.feature θ))⟫+
    Real.sqrt ((b.sharpParameters t BH).idealVariance θ i:ℝ)*z.1 i)-
      φ ((b.sharpParameters t BH).clippedFiniteObservable BG (θ,z.2) i))^2

theorem measurable_squaredError (b : SharpBankData A N N m q)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (t BH BG : ℝ) :
    Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) =>
      b.squaredError φ t BH BG z.1 z.2) := by
  have hH := b.active_measurable.comp
    (measurable_fst : Measurable (Prod.fst : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) → A))
  have hcoord : Measurable (fun θ => activeCoordinateVector (b.basis θ)
      (normalizedFeature (b.feature θ))) := by
    apply (WithLp.measurable_toLp 2 (Fin q → ℝ)).comp
    apply measurable_pi_lambda
    intro k
    exact continuous_inner.measurable.comp
      (((measurable_gramSchmidtNormed k).comp b.basis_measurable).prodMk
        (measurable_normalizedFeature.comp b.feature_measurable))
  have hpsi := hcoord.comp
    (measurable_fst : Measurable (Prod.fst : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) → A))
  have hv := (b.sharpParameters t BH).idealVariance_measurable.comp
    (measurable_fst : Measurable (Prod.fst : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) → A))
  have hf := ((b.sharpParameters t BH).clippedFiniteObservable_measurable BG).comp
    (show Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) => (z.1,z.2.2)) by fun_prop)
  unfold squaredError
  apply Finset.measurable_sum
  intro i hi
  have ha : Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) =>
      ⟪b.active z.1 i,activeCoordinateVector (b.basis z.1) (normalizedFeature (b.feature z.1))⟫) :=
    continuous_inner.measurable.comp (((measurable_pi_apply i).comp hH).prodMk hpsi)
  have hvar := ((measurable_pi_apply i).comp hv).coe_nnreal_real.sqrt
  exact ((hφ.measurable.comp (ha.add (hvar.mul (by fun_prop)))).sub
    (hφ.measurable.comp ((measurable_pi_apply i).comp hf))).pow_const 2

theorem squaredError_nonneg (b : SharpBankData A N N m q)
    (φ : ℝ → ℝ) (t BH BG : ℝ) (θ : A) (z : (Fin N → ℝ) × (Fin N → Fin m → ℝ)) :
    0 ≤ b.squaredError φ t BH BG θ z := Finset.sum_nonneg fun i _ => sq_nonneg _

end SharpBankData
end NeuralGeneralization.BatchTwoImprovedWeightedSampling
