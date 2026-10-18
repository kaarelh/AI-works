import NeuralGeneralization.RobustCompressionSampling
import NeuralGeneralization.RobustCompressionReconstructionGeometry
import NeuralGeneralization.RobustCompressionResourceAllocations

/-! # The literal shared source-bank good event and its probability -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionSourceBank
open RobustCompressionClipping RobustCompressionRows RobustCompressionSampling
open RobustCompressionActiveFeature RobustCompressionReconstruction CompressionSampling
variable {N m q : ℕ} {X : Type*}

/-- A single source sample simultaneously controls every clipped Gram entry,
every active feature coordinate, and every finite-input covariance. -/
def sourceBankGood (u : Fin N → EuclideanSpace ℝ (Fin q))
    (h : X → Fin N → ℝ) (a T : ℝ) (I : Fin m → Fin N) : Prop :=
  ∀ j : FeatureTest q X,
    |empiricalMean (featureBank (fun i k => wholeClip T (u i) k) h j) I -
      populationMean (featureBank (fun i k => wholeClip T (u i) k) h j)| ≤
        a / ((q : ℝ)+1)

/-- Each literal clipped-bank feature depends measurably on its source and
activation arrays. -/
theorem measurable_featureBank_clipped (T : ℝ) (j : FeatureTest q X) :
    Measurable (fun p : (Fin N → EuclideanSpace ℝ (Fin q)) × (X → Fin N → ℝ) =>
      featureBank (fun i k => wholeClip T (p.1 i) k) p.2 j) := by
  apply measurable_pi_lambda
  intro i
  have hc (k : Fin q) : Measurable (fun p :
      (Fin N → EuclideanSpace ℝ (Fin q)) × (X → Fin N → ℝ) =>
      wholeClip T (p.1 i) k) := by
    exact (EuclideanSpace.proj k : EuclideanSpace ℝ (Fin q) →L[ℝ] ℝ).measurable.comp
      ((measurable_wholeClip T).comp ((measurable_pi_apply i).comp measurable_fst))
  rcases j with ⟨j,k⟩ | (⟨j,x⟩ | ⟨x,y⟩)
  · exact (hc j).mul (hc k)
  · exact (hc j).mul (by fun_prop)
  · change Measurable (fun p : (Fin N → EuclideanSpace ℝ (Fin q)) ×
      (X → Fin N → ℝ) => p.2 x i * p.2 y i)
    fun_prop

/-- Joint measurability permits this very event to be used as the valid
parameter domain of the common layer reconstruction kernel. -/
theorem measurableSet_sourceBankGood [Fintype X] (a T : ℝ) :
    MeasurableSet {p : ((Fin N → EuclideanSpace ℝ (Fin q)) ×
      (X → Fin N → ℝ)) × (Fin m → Fin N) |
      sourceBankGood p.1.1 p.1.2 a T p.2} := by
  simp only [sourceBankGood, Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  have hb := measurable_featureBank_clipped (N := N) (q := q) (X := X) T j
  have hsample (i : Fin m) : Measurable (fun p :
      ((Fin N → EuclideanSpace ℝ (Fin q)) × (X → Fin N → ℝ)) × (Fin m → Fin N) =>
      featureBank (fun i k => wholeClip T (p.1.1 i) k) p.1.2 j (p.2 i)) :=
    measurable_finite_select _ _ (hb.comp measurable_fst)
      ((measurable_pi_apply i).comp measurable_snd)
  have hpop (i : Fin N) : Measurable (fun p :
      ((Fin N → EuclideanSpace ℝ (Fin q)) × (X → Fin N → ℝ)) × (Fin m → Fin N) =>
      featureBank (fun i k => wholeClip T (p.1.1 i) k) p.1.2 j i) :=
    (measurable_pi_apply i).comp (hb.comp measurable_fst)
  apply measurableSet_le _ measurable_const
  unfold empiricalMean populationMean
  exact (((Finset.measurable_sum _ (fun i _ => hsample i)).div_const _).sub
    ((Finset.measurable_sum _ (fun i _ => hpop i)).div_const _)).abs

theorem good_gram (u : Fin N → EuclideanSpace ℝ (Fin q))
    (h : X → Fin N → ℝ) {a T : ℝ} {I : Fin m → Fin N}
    (hg : sourceBankGood u h a T I) (j k : Fin q) :
    |(∑ i, wholeClip T (u (I i)) j * wholeClip T (u (I i)) k) / (m : ℝ) -
      (∑ i, wholeClip T (u i) j * wholeClip T (u i) k) / (N : ℝ)| ≤
        a / ((q : ℝ)+1) :=
  hg (Sum.inl (j,k))

theorem finiteAverage_coordinate {r : ℕ} (f : Fin r → EuclideanSpace ℝ (Fin q))
    (k : Fin q) : finiteAverage f k = (∑ i, f i k)/(r : ℝ) := by
  have hs : (∑ i, f i) k = ∑ i, f i k := by
    change (EuclideanSpace.proj k) (∑ i, f i) = _
    simp
  simp only [finiteAverage, PiLp.smul_apply, smul_eq_mul, hs, div_eq_mul_inv, mul_comm]

theorem good_mean (u : Fin N → EuclideanSpace ℝ (Fin q))
    (h : X → Fin N → ℝ) {a T : ℝ} {I : Fin m → Fin N}
    (hg : sourceBankGood u h a T I) (x : X) (k : Fin q) :
    |(finiteAverage (fun j => h x (I j) • wholeClip T (u (I j))) -
      finiteAverage (fun i => h x i • wholeClip T (u i))) k| ≤ a/((q : ℝ)+1) := by
  have hh := hg (Sum.inr (Sum.inl (k,x)))
  simpa only [empiricalMean, populationMean, featureBank, PiLp.sub_apply,
    finiteAverage_coordinate, PiLp.smul_apply, smul_eq_mul, mul_comm] using hh

theorem good_covariance (u : Fin N → EuclideanSpace ℝ (Fin q))
    (h : X → Fin N → ℝ) {a T : ℝ} {I : Fin m → Fin N}
    (ha : 0 ≤ a) (hg : sourceBankGood u h a T I) (x y : X) :
    |(∑ i, h x (I i)*h y (I i))/(m : ℝ) -
      (∑ i, h x i*h y i)/(N : ℝ)| ≤ a := by
  have hh := hg (Sum.inr (Sum.inr (x,y)))
  have hqa : a/((q : ℝ)+1) ≤ a := by
    apply (div_le_iff₀ (by positivity : 0 < (q : ℝ)+1)).mpr
    nlinarith [Nat.cast_nonneg (α := ℝ) q]
  exact hh.trans hqa

/-- All deterministic validity conclusions on the one shared good event. -/
theorem sourceBankGood_valid [NeZero m]
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (h : X → Fin N → ℝ)
    (hh : ∀ x i, |h x i| ≤ 1) {a T : ℝ} (ha : 0 ≤ a) (hT : 0 < T)
    (hu : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ i, ⟪u i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2)
    (htrace : (∑ i, ‖u i‖^2)/(N : ℝ) ≤ q)
    {I : Fin m → Fin N} (hg : sourceBankGood u h a T I) :
    (∀ v : Fin q → ℝ,
      ∑ i, (Matrix.of (sampledMatrix u I a T) *ᵥ v) i^2 ≤ ∑ j, v j^2) ∧
    (∀ x, ‖sampledActive (fun i => wholeClip T (u i)) I (h x) a‖ ≤ 1 ∧
      ‖sampledActive (fun i => wholeClip T (u i)) I (h x) a -
        finiteAverage (fun i => h x i • u i)‖ ≤ (q : ℝ)/T+2*a) ∧
    (∀ x y, |(∑ i, h x (I i)*h y (I i))/(m : ℝ) -
      (∑ i, h x i*h y i)/(N : ℝ)| ≤ a) := by
  refine ⟨sampledMatrix_contraction u I ha (NeZero.pos m) hu (good_gram u h hg), ?_,
    good_covariance u h ha hg⟩
  intro x
  exact sampledActive_bounds u I (h x) (hh x) ha hT hu htrace
    (good_gram u h hg) (good_mean u h hg x)

/-- The bad event has the literal Hoeffding union bound under independent
uniform source-index sampling, without a source-width prefactor. -/
theorem sourceBankGood_failure [Fintype X] [NeZero N]
    (hm : 0 < m) (u : Fin N → EuclideanSpace ℝ (Fin q))
    (h : X → Fin N → ℝ) (hh : ∀ x i, |h x i| ≤ 1)
    {a T : ℝ} (ha : 0 ≤ a) (hT : 1 ≤ T) :
    (iidSamples (uniformIndexLaw N) m).real {I | ¬sourceBankGood u h a T I} ≤
      ((q : ℝ)^2 + q*Fintype.card X + (Fintype.card X : ℝ)^2) *
        (2*Real.exp (-(m : ℝ)*(a/((q : ℝ)+1))^2/(2*T^4))) := by
  have hc : ∀ i k, |wholeClip T (u i) k| ≤ T := by
    intro i k
    have hcoord := PiLp.norm_apply_le (wholeClip T (u i)) k
    simpa only [Real.norm_eq_abs] using
      hcoord.trans (wholeClip_norm_le T (by linarith) (u i))
  have htail := featureBank_tail N m q hm (fun i k => wholeClip T (u i) k)
    h hT hc hh (show 0 ≤ a/((q : ℝ)+1) by positivity)
  apply (measureReal_mono (μ := iidSamples (uniformIndexLaw N) m) ?_).trans htail
  intro I hI
  simp only [Set.mem_setOf_eq, sourceBankGood, not_forall, not_le] at hI
  obtain ⟨j,hj⟩ := hI
  exact ⟨j,hj.le⟩

/-- With the declared literal resource formulas the preceding actual bad-event
probability is at most the layer's reciprocal failure budget. -/
theorem sourceBankGood_resource_failure (p : ConcreteModel.RobustCompressionInput)
    [NeZero N] (u : Fin N → EuclideanSpace ℝ (Fin p.activeRank))
    (h : ConcreteModel.Cube p.dimension → Fin N → ℝ)
    (hh : ∀ x i, |h x i| ≤ 1)
    (hE : 0 < p.inverseLayerError) (hη : 0 < p.inverseLayerFailure) :
    (iidSamples (uniformIndexLaw N) p.bankSize).real
      {I | ¬sourceBankGood u h (p.inverseKernelPrecision : ℝ)⁻¹ p.sourceClip I} ≤
        (p.inverseLayerFailure : ℝ)⁻¹ := by
  have hT : (1 : ℝ) ≤ p.sourceClip := by exact_mod_cast p.sourceClip_pos hE
  have hb := sourceBankGood_failure p.bankSize_pos u h hh
    (by positivity : 0 ≤ (p.inverseKernelPrecision : ℝ)⁻¹) hT
  have htail := p.source_sampling_failure hE hη
  apply hb.trans
  simpa only [ConcreteModel.Cube, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, Nat.cast_pow, Nat.cast_ofNat, neg_mul, neg_div] using htail

end NeuralGeneralization.RobustCompressionSourceBank
