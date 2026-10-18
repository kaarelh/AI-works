import NeuralGeneralization.Activation
import NeuralGeneralization.RobustCompressionLayerBound
import NeuralGeneralization.RobustCompressionLayerParametersTotalization
import NeuralGeneralization.RobustCouplingTwoScaleSubprobability

/-! # Averaged actual layer error on the successful restricted law -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace ENNReal
set_option maxHeartbeats 600000
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompressionLayerGaussian RobustCompressionLayerParameters
open RobustCompressionSourceBank RobustCompressionClipping RobustCoupling

variable {A X : Type*} [MeasurableSpace A] [Fintype X] {N m q : ℕ}

theorem bank_idealVariance_sqrt_le [NeZero N]
    (b : BankLayerData A X N m q) (a T BH : ℝ) {t : ℝ} (ht : 0 ≤ t)
    (x : X) (θ : A) (i : Fin N)
    (hh : ∀ i, |b.feature θ x i| ≤ 1)
    (hu : ∀ v, (∑ i, ⟪b.source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2) :
    Real.sqrt ((b.totalizedParameters a t T BH x).idealVariance θ i : ℝ) ≤ t := by
  have hdiag : b.idealDiagonal x θ ≤ 1 := by
    change (∑ i, b.feature θ x i^2)/(N : ℝ) ≤ 1
    apply (div_le_one (by exact_mod_cast NeZero.pos N : (0:ℝ)<N)).mpr
    have hterm (i : Fin N) : b.feature θ x i^2 ≤ 1 := by
      nlinarith [abs_le.mp (hh i)]
    simpa using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hterm i)
  have he := b.idealVariance_eq a t T BH x θ hu i
  change ((b.totalizedParameters a t T BH x).idealVariance θ i : ℝ) = _ at he
  have hvar : ((b.totalizedParameters a t T BH x).idealVariance θ i : ℝ) ≤ t^2 := by
    rw [he]
    nlinarith [sq_nonneg t, sq_nonneg (‖b.idealFeature x θ‖),
      mul_nonneg (sq_nonneg t) (sq_nonneg (‖b.idealFeature x θ‖))]
  have hsq := Real.sq_sqrt (show 0 ≤ ((b.totalizedParameters a t T BH x).idealVariance θ i : ℝ) from
    NNReal.coe_nonneg _)
  nlinarith [Real.sqrt_nonneg ((b.totalizedParameters a t T BH x).idealVariance θ i : ℝ)]

/-- Every analytic term is derived inside one actual comparison kernel.
The successful law can be a restriction of the full source/active law; only
its genuine entropy and active-energy budgets are supplied. -/
theorem successful_layer_cost [NeZero N] [NeZero m]
    (μ : Measure A) [IsFiniteMeasure μ] (hmass : μ Set.univ ≤ 1)
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (b : BankLayerData A X N m q)
    {a t T BH BG δ : ℝ} (ha : 0 ≤ a) (ht : 0 < t) (ht1 : t ≤ 1)
    (hT : 0 < T) (hBH : 0 < BH) (hBG : 0 < BG) (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (hbounded : ∀ θ x i, |b.feature θ x i| ≤ 1)
    (hquad : ∀ θ v, (∑ i, ⟪b.source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (htrace : ∀ θ, (∑ i, ‖b.source θ i‖^2)/(N : ℝ) ≤ q)
    (hgood : ∀ᵐ θ ∂μ, sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ))
    {EH : ℝ≥0∞}
    (henergy : (∫⁻ θ, ENNReal.ofReal (∑ i, ‖b.active θ i‖^2) ∂μ) ≤ EH)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector N) ∂μ) ≤
      ENNReal.ofReal (N*δ^3/t^2)) (x : X) :
    let p := b.totalizedParameters a t T BH x
    (∫⁻ θ, ∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (Real.tanh (⟪b.active θ i,b.idealFeature x θ⟫+
          Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        Real.tanh (p.clippedFiniteObservable BG (θ,z.2) i))^2)
      ∂layerJointKernel P p θ ∂μ) ≤
      4*(ENNReal.ofReal (4/BH^2)*EH + ENNReal.ofReal (14*N*δ) +
        ENNReal.ofReal ((N : ℝ)*(BH^2*((q : ℝ)/T+2*a)^2 +
          t^2*(a+2*((q : ℝ)/T+2*a)))) + ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  let p := b.totalizedParameters a t T BH x
  have hp : p.Contractive := b.totalizedParameters_contractive ha x hquad
  have hφ : LipschitzWith 1 Real.tanh := ConcreteModel.tanh_lipschitzWith
  have hφb : ∀ z, |Real.tanh z| ≤ 1 := fun z => (Real.abs_tanh_lt_one z).le
  have hres : (∫⁻ θ, ∫⁻ z, ENNReal.ofReal (∑ i,
      (Real.tanh (p.idealObservable (θ,z.1) i)-Real.tanh (p.idealObservable (θ,z.2) i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) N P θ ∂μ) ≤ ENNReal.ofReal (14*N*δ) := by
    apply finiteCouplingKernel_two_scale_averaged_subprobability μ hmass N P hδ hδ1 ht
      (fun θ i z => Real.tanh (p.idealMean θ i + Real.sqrt (p.idealVariance θ i : ℝ)*z))
    · intro i
      exact hφ.continuous.measurable.comp
        (((measurable_pi_apply i).comp p.idealMean_measurable).comp measurable_fst |>.add
          ((((measurable_pi_apply i).comp p.idealVariance_measurable).coe_nnreal_real.sqrt.comp measurable_fst).mul measurable_snd))
    · exact Filter.Eventually.of_forall (fun _ _ z => hφb _)
    · exact Filter.Eventually.of_forall (fun θ i u v => by
        have hs := bank_idealVariance_sqrt_le b a T BH ht.le x θ i (hbounded θ x) (hquad θ)
        have h := hφ.dist_le_mul
          (p.idealMean θ i+Real.sqrt (p.idealVariance θ i : ℝ)*u)
          (p.idealMean θ i+Real.sqrt (p.idealVariance θ i : ℝ)*v)
        simp only [Real.dist_eq,NNReal.coe_one,one_mul] at h
        calc
          _ ≤ |Real.sqrt (p.idealVariance θ i : ℝ)*(u-v)| := by
            convert h using 1
            congr 1
            ring
          _ = Real.sqrt (p.idealVariance θ i : ℝ)*|u-v| := by
            rw [abs_mul,abs_of_nonneg (Real.sqrt_nonneg _)]
          _ ≤ t*|u-v| := mul_le_mul_of_nonneg_right hs (abs_nonneg _))
    · exact hbudget
  have hmean : ∀ᵐ θ ∂μ, ∀ i, (p.idealMean θ i-p.finiteMean θ i)^2 ≤
      BH^2*((q : ℝ)/T+2*a)^2 := by
    filter_upwards [hgood] with θ hg
    exact (b.parameters_error_bounds (t:=t) ha hT hBH.le x θ
      (hbounded θ) (hquad θ) (htrace θ) hg).1
  have hvariance : ∀ᵐ θ ∂μ, ∀ i,
      |(p.idealVariance θ i : ℝ)-p.finiteVariance θ i| ≤ t^2*(a+2*((q : ℝ)/T+2*a)) := by
    filter_upwards [hgood] with θ hg
    have he := b.totalizedParameters_finiteVariance_of_good a t T BH x θ hg
    change p.finiteVariance θ = _ at he
    rw [he]
    exact (b.parameters_error_bounds (t:=t) ha hT hBH.le x θ
      (hbounded θ) (hquad θ) (htrace θ) hg).2
  exact layerJointKernel_total_cost_averaged_ae μ hmass P p hp Real.tanh hφ hφb
    b.active b.active_measurable (b.idealFeature x) hBH hBG (fun _ _ => rfl)
    (fun θ j => hbounded θ x (b.indices θ j))
    (by simpa [p,BankLayerData.totalizedParameters,BankLayerData.parameters,abs_of_pos ht] using ht1)
    (NeZero.pos m) hmean hvariance henergy hres

end NeuralGeneralization.RobustCompressionLayerComparison
