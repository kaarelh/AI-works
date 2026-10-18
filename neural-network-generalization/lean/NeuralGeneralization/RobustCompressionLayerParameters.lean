import NeuralGeneralization.RobustCompressionLayerClipping
import NeuralGeneralization.RobustCompressionSourceBankGoodEvent

/-!
# Literal sampled-bank parameters for the Gaussian layer comparison

The Gaussian means and variances here are calculated from actual source rows,
active coordinates and sampled indices. Good-bank hypotheses are deterministic
sampling conclusions, not assumed Gaussian laws or transport certificates.
-/
noncomputable section
set_option maxHeartbeats 800000
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionLayerParameters
open RobustCompressionClipping RobustCompressionRows RobustCompressionCovariance
open RobustCompressionReconstruction RobustCompressionSourceBank
open RobustCompressionLayerGaussian RobustGaussianGeometry

variable {A X : Type*} [MeasurableSpace A] {N m q : ℕ}

/-- The active-feature squared norm is bounded by the actual kernel diagonal,
including when the source covariance is singular. -/
theorem feature_mean_norm_sq_le_energy [NeZero N]
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (h : Fin N → ℝ)
    (hu : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ i, ⟪u i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2) :
    ‖finiteAverage (fun i => h i • u i)‖^2 ≤ (∑ i, h i^2)/(N : ℝ) := by
  let v := finiteAverage (fun i => h i • u i)
  have hN : (0 : ℝ) < N := by exact_mod_cast NeZero.pos N
  have hv : ‖v‖^2 = (∑ i, h i * ⟪u i, v⟫)/(N : ℝ) := by
    rw [← real_inner_self_eq_norm_sq]
    conv_lhs => lhs; unfold v finiteAverage
    simp only [real_inner_smul_left, sum_inner]
    ring
  have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ h (fun i => ⟪u i, v⟫)
  have hq : (∑ i, ⟪u i, v⟫^2) ≤ ‖v‖^2 * (N : ℝ) :=
    (div_le_iff₀ hN).mp (hu v)
  have hs := mul_le_mul_of_nonneg_left hq
    (show 0 ≤ ∑ i, h i^2 from Finset.sum_nonneg (fun i _ => sq_nonneg (h i)))
  have hid : (∑ i, h i * ⟪u i, v⟫) = ‖v‖^2 * (N : ℝ) :=
    ((eq_div_iff hN.ne').mp hv).symm
  rw [hid] at hc
  change ‖v‖^2 ≤ _
  apply (le_div_iff₀ hN).mpr
  by_cases hz : ‖v‖^2 = 0
  · rw [hz, zero_mul]
    positivity
  · have hv0 : 0 < ‖v‖^2 := lt_of_le_of_ne (sq_nonneg _) (Ne.symm hz)
    have hprod : (‖v‖^2 * (N : ℝ)) * (‖v‖^2 * (N : ℝ)) ≤
        (∑ i, h i^2) * (‖v‖^2 * (N : ℝ)) := by
      simpa only [pow_two] using hc.trans hs
    exact (mul_le_mul_iff_left₀ (mul_pos hv0 hN)).mp hprod

structure BankLayerData (A : Type*) [MeasurableSpace A] (X : Type*) (N m q : ℕ) where
  source : A → Fin N → EuclideanSpace ℝ (Fin q)
  active : A → Fin N → EuclideanSpace ℝ (Fin q)
  indices : A → Fin m → Fin N
  feature : A → X → Fin N → ℝ
  source_measurable : Measurable source
  active_measurable : Measurable active
  indices_measurable : Measurable indices
  feature_measurable : Measurable feature

namespace BankLayerData

def idealFeature (b : BankLayerData A X N m q) (x : X) (θ : A) :
    EuclideanSpace ℝ (Fin q) := finiteAverage (fun i => b.feature θ x i • b.source θ i)

def finiteFeature (b : BankLayerData A X N m q) (a T : ℝ) (x : X) (θ : A) :
    EuclideanSpace ℝ (Fin q) := sampledActive (fun i => wholeClip T (b.source θ i))
      (b.indices θ) (b.feature θ x) a

def idealDiagonal (b : BankLayerData A X N m q) (x : X) (θ : A) : ℝ :=
  (∑ i, b.feature θ x i ^ 2)/(N : ℝ)

def finiteDiagonal (b : BankLayerData A X N m q) (x : X) (θ : A) : ℝ :=
  (∑ i, b.feature θ x (b.indices θ i) ^ 2)/(m : ℝ)

theorem idealFeature_measurable (b : BankLayerData A X N m q) (x : X) :
    Measurable (b.idealFeature x) := by
  have hu := b.source_measurable
  have hh := b.feature_measurable
  unfold idealFeature finiteAverage
  fun_prop

theorem finiteFeature_measurable (b : BankLayerData A X N m q) (a T : ℝ) (x : X) :
    Measurable (b.finiteFeature a T x) := by
  have hs (j : Fin m) : Measurable (fun θ => b.source θ (b.indices θ j)) :=
    measurable_finite_select _ _ b.source_measurable
      ((measurable_pi_apply j).comp b.indices_measurable)
  have hh (j : Fin m) : Measurable (fun θ => b.feature θ x (b.indices θ j)) :=
    measurable_finite_select _ _ ((measurable_pi_apply x).comp b.feature_measurable)
      ((measurable_pi_apply j).comp b.indices_measurable)
  have hc (j : Fin m) := (measurable_wholeClip T).comp (hs j)
  unfold finiteFeature sampledActive finiteAverage
  exact ((Finset.measurable_sum _ (fun j _ => (hh j).smul (hc j))).const_smul
    ((m : ℝ)⁻¹)).const_smul ((Real.sqrt (1+a))⁻¹)

theorem idealDiagonal_measurable (b : BankLayerData A X N m q) (x : X) :
    Measurable (b.idealDiagonal x) := by
  have hh := b.feature_measurable
  unfold idealDiagonal
  fun_prop

theorem finiteDiagonal_measurable (b : BankLayerData A X N m q) (x : X) :
    Measurable (b.finiteDiagonal x) := by
  unfold finiteDiagonal
  apply Measurable.div_const
  exact Finset.measurable_sum _ (fun j _ =>
    (measurable_finite_select _ _ ((measurable_pi_apply x).comp b.feature_measurable)
      ((measurable_pi_apply j).comp b.indices_measurable)).pow_const 2)

/-- The literal actual-source construction. Restriction to a good-data subtype
makes its contraction assertion global without altering any law on that domain. -/
def parameters (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) :
    GaussianLayerParameters A N m q where
  idealMean := fun θ i => ⟪wholeClip BH (b.active θ i), b.idealFeature x θ⟫
  finiteMean := fun θ i => ⟪wholeClip BH (b.active θ i), b.finiteFeature a T x θ⟫
  idealVariance := fun θ _ => (t^2 * (b.idealDiagonal x θ - ‖b.idealFeature x θ‖^2)).toNNReal
  sourceMatrix := fun θ => sampledMatrix (b.source θ) (b.indices θ) a T
  sourceFeature := fun θ j => b.feature θ x (b.indices θ j)
  scale := t
  idealMean_measurable := by
    apply measurable_pi_lambda
    intro i
    exact continuous_inner.measurable.comp
      (((measurable_wholeClip BH).comp ((measurable_pi_apply i).comp b.active_measurable)).prodMk
        (b.idealFeature_measurable x))
  finiteMean_measurable := by
    apply measurable_pi_lambda
    intro i
    exact continuous_inner.measurable.comp
      (((measurable_wholeClip BH).comp ((measurable_pi_apply i).comp b.active_measurable)).prodMk
        (b.finiteFeature_measurable a T x))
  idealVariance_measurable := measurable_pi_lambda _ (fun _ =>
    (((b.idealDiagonal_measurable x).sub
      ((b.idealFeature_measurable x).norm.pow_const 2)).const_mul (t^2)).real_toNNReal)
  sourceMatrix_measurable := by
    have hcomp := (measurable_sampledMatrix (N := N) (m := m) (q := q) a T).comp
      (show Measurable (fun θ : A => (b.source θ, b.indices θ)) from
        b.source_measurable.prodMk b.indices_measurable)
    simpa only [Function.comp_def] using hcomp
  sourceFeature_measurable := measurable_pi_lambda _ (fun j =>
    measurable_finite_select _ _ ((measurable_pi_apply x).comp b.feature_measurable)
      ((measurable_pi_apply j).comp b.indices_measurable))

theorem finiteObservable_eq_rows (b : BankLayerData A X N m q)
    (a t T BH : ℝ) (x : X) (θ : A) (ξ : Fin N → Fin m → ℝ) (i : Fin N) :
    (b.parameters a t T BH x).finiteObservable (θ,ξ) i =
      ∑ j, reconstructedRow (wholeClip BH (b.active θ i))
        (fun k => wholeClip T (b.source θ k)) (b.indices θ) a t (ξ i) j *
          b.feature θ x (b.indices θ j) := by
  rw [reconstructedRow_evaluation]
  change _ + _ = _ + _
  congr 1
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  exact mul_comm _ _

theorem clippedFiniteObservable_eq_rows (b : BankLayerData A X N m q)
    (a t T BH BG : ℝ) (x : X) (θ : A) (ξ : Fin N → Fin m → ℝ) (i : Fin N) :
    (b.parameters a t T BH x).clippedFiniteObservable BG (θ,ξ) i =
      ∑ j, reconstructedRow (wholeClip BH (b.active θ i))
        (fun k => wholeClip T (b.source θ k)) (b.indices θ) a t
        (fun j => RobustCompressionGaussian.gaussianClip BG (ξ i j)) j *
          b.feature θ x (b.indices θ j) := by
  rw [reconstructedRow_evaluation]
  change _ + _ = _ + _
  congr 1
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  exact mul_comm _ _

theorem parameters_contractive [NeZero m] (b : BankLayerData A X N m q)
    {a t T BH : ℝ} (ha : 0 ≤ a) (x : X)
    (hu : ∀ θ v, (∑ i, ⟪b.source θ i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (hg : ∀ θ, sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ)) :
    (b.parameters a t T BH x).Contractive := by
  intro θ v
  exact sampledMatrix_contraction (b.source θ) (b.indices θ) ha (NeZero.pos m)
    (hu θ) (good_gram _ _ (hg θ)) v

theorem finiteVariance_eq [NeZero m] (b : BankLayerData A X N m q)
    {a t T BH : ℝ} (ha : 0 ≤ a) (x : X) (θ : A)
    (hD : ∀ u : Fin q → ℝ,
      ∑ i, (Matrix.of (sampledMatrix (b.source θ) (b.indices θ) a T) *ᵥ u) i^2 ≤ ∑ j, u j^2)
    (i : Fin N) :
    ((b.parameters a t T BH x).finiteVariance θ i : ℝ) =
      t^2 * (b.finiteDiagonal x θ - ‖b.finiteFeature a T x θ‖^2) := by
  have hV := sourceResidualVariance_nonneg _ hD
    (fun j => b.feature θ x (b.indices θ j))
  change ((((t / Real.sqrt (m : ℝ))^2).toNNReal *
    (sourceResidualVariance (sampledMatrix (b.source θ) (b.indices θ) a T)
      (fun j => b.feature θ x (b.indices θ j))).toNNReal : ℝ≥0) : ℝ) = _
  rw [NNReal.coe_mul, Real.coe_toNNReal _ (sq_nonneg _), Real.coe_toNNReal _ hV]
  have he := sampledMatrix_active_energy (b.source θ) (b.indices θ) (b.feature θ x)
    ha (NeZero.pos m) (T := T)
  unfold finiteFeature finiteDiagonal
  rw [← he]
  simp_rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg m), ← Finset.sum_div]
  unfold sourceResidualVariance
  ring

theorem idealVariance_eq [NeZero N] (b : BankLayerData A X N m q)
    (a t T BH : ℝ) (x : X) (θ : A)
    (hu : ∀ v, (∑ i, ⟪b.source θ i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (i : Fin N) :
    ((b.parameters a t T BH x).idealVariance θ i : ℝ) =
      t^2 * (b.idealDiagonal x θ - ‖b.idealFeature x θ‖^2) := by
  apply Real.coe_toNNReal
  exact mul_nonneg (sq_nonneg t) (sub_nonneg.mpr
    (feature_mean_norm_sq_le_energy (b.source θ) (b.feature θ x) hu))

theorem idealFeature_norm_le_one [NeZero N] (b : BankLayerData A X N m q)
    (x : X) (θ : A) (hh : ∀ i, |b.feature θ x i| ≤ 1)
    (hu : ∀ v, (∑ i, ⟪b.source θ i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2) :
    ‖b.idealFeature x θ‖ ≤ 1 := by
  have hn := feature_mean_norm_sq_le (b.source θ) (b.feature θ x) hh
    (show 0 ≤ (1 : ℝ) by norm_num) (by simpa using hu)
  change ‖b.idealFeature x θ‖^2 ≤ 1 at hn
  nlinarith [norm_nonneg (b.idealFeature x θ)]

/-- Good-bank errors control the literal means and nonnegative variances. -/
theorem parameters_error_bounds [NeZero N] [NeZero m]
    (b : BankLayerData A X N m q) {a t T BH : ℝ}
    (ha : 0 ≤ a) (hT : 0 < T) (hBH : 0 ≤ BH) (x : X) (θ : A)
    (hh : ∀ y i, |b.feature θ y i| ≤ 1)
    (hu : ∀ v, (∑ i, ⟪b.source θ i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (htrace : (∑ i, ‖b.source θ i‖^2)/(N : ℝ) ≤ q)
    (hg : sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ)) :
    (∀ i, ((b.parameters a t T BH x).idealMean θ i -
      (b.parameters a t T BH x).finiteMean θ i)^2 ≤ BH^2 * ((q : ℝ)/T+2*a)^2) ∧
    (∀ i, |((b.parameters a t T BH x).idealVariance θ i : ℝ) -
      (b.parameters a t T BH x).finiteVariance θ i| ≤ t^2 * (a+2*((q : ℝ)/T+2*a))) := by
  obtain ⟨hD,hfeat,hcov⟩ := sourceBankGood_valid (b.source θ) (b.feature θ)
    hh ha hT hu htrace hg
  have hsampleNorm : ‖b.finiteFeature a T x θ‖ ≤ 1 := (hfeat x).1
  have hdiff : ‖b.idealFeature x θ - b.finiteFeature a T x θ‖ ≤ (q : ℝ)/T+2*a := by
    rw [norm_sub_rev]
    exact (hfeat x).2
  have hidealNorm := b.idealFeature_norm_le_one x θ (hh x) hu
  have hζ : 0 ≤ (q : ℝ)/T+2*a := by positivity
  constructor
  · intro i
    change (⟪wholeClip BH (b.active θ i), b.idealFeature x θ⟫ -
      ⟪wholeClip BH (b.active θ i), b.finiteFeature a T x θ⟫)^2 ≤ _
    rw [← inner_sub_right]
    have hb := (abs_real_inner_le_norm (wholeClip BH (b.active θ i))
      (b.idealFeature x θ-b.finiteFeature a T x θ)).trans
      (mul_le_mul (wholeClip_norm_le BH hBH _) hdiff (norm_nonneg _) hBH)
    have hs := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg hBH hζ)).mpr hb
    simpa only [sq_abs, mul_pow] using hs
  · intro i
    rw [b.idealVariance_eq a t T BH x θ hu i, b.finiteVariance_eq ha x θ hD i,
      ← mul_sub, abs_mul, abs_of_nonneg (sq_nonneg t)]
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg t)
    have hK : |b.idealDiagonal x θ-b.finiteDiagonal x θ| ≤ a := by
      rw [abs_sub_comm]
      simpa only [idealDiagonal,finiteDiagonal,pow_two] using hcov x x
    have he := residual_covariance_error hK hdiff hdiff hsampleNorm hidealNorm
    simpa only [real_inner_self_eq_norm_sq] using he

/-- Instantiated full-field comparison, with all Gaussian laws supplied by
construction and all approximation terms derived from the one source-bank event. -/
theorem parameters_activation_error [NeZero N] [NeZero m]
    (b : BankLayerData A X N m q) {a t T BH : ℝ}
    (ha : 0 ≤ a) (hT : 0 < T) (hBH : 0 ≤ BH) (x : X)
    (hh : ∀ θ y i, |b.feature θ y i| ≤ 1)
    (hu : ∀ θ v, (∑ i, ⟪b.source θ i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (htrace : ∀ θ, (∑ i, ‖b.source θ i‖^2)/(N : ℝ) ≤ q)
    (hg : ∀ θ, sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ))
    (θ : A) (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫ z, ∑ i, (φ ((b.parameters a t T BH x).idealObservable (θ,z.1) i) -
      φ ((b.parameters a t T BH x).finiteObservable (θ,z.2) i))^2
        ∂(b.parameters a t T BH x).fullCoupling θ) ≤
      (N : ℝ) * (BH^2*((q : ℝ)/T+2*a)^2 + t^2*(a+2*((q : ℝ)/T+2*a))) := by
  obtain ⟨hmean,hvariance⟩ := b.parameters_error_bounds ha hT hBH x θ
    (hh θ) (hu θ) (htrace θ) (hg θ)
  exact (b.parameters a t T BH x).fullCoupling_activation_error_uniform
    (b.parameters_contractive ha x hu hg) θ φ hφ hmean hvariance

end BankLayerData
end NeuralGeneralization.RobustCompressionLayerParameters
