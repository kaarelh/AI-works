import NeuralGeneralization.RobustCompressionSuccessfulLayer

/-! # The literal nonnegative source-bank layer discrepancy -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionLayerParameters
open RobustCompressionLayerGaussian
variable {A X : Type*} [MeasurableSpace A] [Fintype X] {N m q : ℕ}

def bankSquaredError (b : BankLayerData A X N m q)
    (a t T BH BG : ℝ) (x : X) (θ : A)
    (z : (Fin N → ℝ) × (Fin N → Fin m → ℝ)) : ℝ :=
  let p := b.totalizedParameters a t T BH x
  ∑ i, (Real.tanh (⟪b.active θ i,b.idealFeature x θ⟫ +
      Real.sqrt (p.idealVariance θ i : ℝ)*z.1 i) -
    Real.tanh (p.clippedFiniteObservable BG (θ,z.2) i))^2

theorem bankSquaredError_nonneg (b : BankLayerData A X N m q)
    (a t T BH BG : ℝ) (x : X) (θ : A)
    (z : (Fin N → ℝ) × (Fin N → Fin m → ℝ)) :
    0 ≤ bankSquaredError b a t T BH BG x θ z :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

theorem measurable_bankSquaredError (b : BankLayerData A X N m q)
    (a t T BH BG : ℝ) (x : X) :
    Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) =>
      bankSquaredError b a t T BH BG x z.1 z.2) := by
  let p := b.totalizedParameters a t T BH x
  have htanh := ConcreteModel.tanh_lipschitzWith.continuous.measurable
  have hnew : Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) =>
      p.clippedFiniteObservable BG (z.1,z.2.2)) :=
    (p.clippedFiniteObservable_measurable BG).comp (by fun_prop)
  apply Finset.measurable_sum
  intro i hi
  have ha : Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) =>
      ⟪b.active z.1 i,b.idealFeature x z.1⟫) :=
    continuous_inner.measurable.comp
      ((((measurable_pi_apply i).comp b.active_measurable).comp measurable_fst).prodMk
        ((b.idealFeature_measurable x).comp measurable_fst))
  have hv : Measurable (fun z : A × ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) =>
      Real.sqrt (p.idealVariance z.1 i : ℝ)) :=
    (((measurable_pi_apply i).comp p.idealVariance_measurable).coe_nnreal_real.sqrt).comp measurable_fst
  exact ((htanh.comp (ha.add (hv.mul (by fun_prop)))).sub
    (htanh.comp ((measurable_pi_apply i).comp hnew))).pow_const 2

end NeuralGeneralization.RobustCompressionLayerParameters
