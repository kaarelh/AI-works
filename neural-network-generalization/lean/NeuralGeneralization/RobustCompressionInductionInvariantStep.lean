import NeuralGeneralization.RobustCompressionInductionInvariant
import NeuralGeneralization.RobustCompressionSelectedAbort

/-! # The actual selected transition preserves the canonical resource invariant -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy

variable (p : RobustCompressionInput) {N s k : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube p.dimension))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube p.dimension))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
  [hMsgB : StandardBorelSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]

 theorem selectedNext_resourceInvariant {σ : ℝ} (hσ : 0<σ)
    (hscale : (N : ℝ)*σ^2≤1) (hE : 0<p.inverseLayerError) (hH : 0<p.inverseLayerFailure)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hφbound : ∀ z,|φ z|≤1)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s (k+1))
    (S : ActualPrefixSelection Γ φ hφ p.activeRank (σ*Real.sqrt (N : ℝ))
      ((p.inverseSelectionError : ℝ)⁻¹) ((p.inverseLayerFailure : ℝ)⁻¹))
    (hΓ : ResourceInvariant p σ s (k+1) Γ) :
    ResourceInvariant p σ (s+1) k
      (selectedNext (q:=p.activeRank) hφ (p.inverseKernelPrecision : ℝ)⁻¹
        (σ*Real.sqrt (N : ℝ)) p.sourceClip (Real.sqrt p.activeSquaredBound)
        (Real.sqrt p.gaussianSquaredBound) (p.inverseSelectionError : ℝ)⁻¹
        (p.inverseLayerFailure : ℝ)⁻¹ Γ S) := by
  let next := selectedNext (q:=p.activeRank) hφ (p.inverseKernelPrecision : ℝ)⁻¹
    (σ*Real.sqrt (N : ℝ)) p.sourceClip (Real.sqrt p.activeSquaredBound)
    (Real.sqrt p.gaussianSquaredBound) (p.inverseSelectionError : ℝ)⁻¹
    (p.inverseLayerFailure : ℝ)⁻¹ Γ S
  have ht : |σ*Real.sqrt (N : ℝ)|≤1 := by
    have he := physicalScale_sq (N:=N) σ
    have hn : 0≤σ*Real.sqrt (N : ℝ) := by positivity
    rw [abs_of_nonneg hn]
    nlinarith [hscale]
  constructor
  · have he := canonicalStepLaw_futureEntropy_le Γ.law
      (selectedMessageKernel (q:=p.activeRank) S.queries S.measurable_queries)
      (RobustCompressionCanonicalLayer.canonicalLayerKernel hφ (indexedPrefixQueries φ)
        (measurable_indexedPrefixQueries hφ) (p.inverseKernelPrecision : ℝ)⁻¹
        (σ*Real.sqrt (N : ℝ)) p.sourceClip (Real.sqrt p.activeSquaredBound)
        (Real.sqrt p.gaussianSquaredBound))
    refine he.trans ?_
    calc
      _ ≤ (ENNReal.ofReal ((p.energy : ℝ)/σ^2)+s • ENNReal.ofReal
        (Real.log (Fintype.card (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank))))+
          ENNReal.ofReal (Real.log (Fintype.card
            (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank))) :=
        add_le_add hΓ.1 le_rfl
      _ = _ := by rw [add_nsmul,one_nsmul]; ac_rfl
  constructor
  · exact selectedNext_bounded hφ p.bankSize_pos (by positivity) ht (by positivity)
      (Real.sqrt_nonneg _) (Real.sqrt_nonneg _) (by positivity)
      p.internal_le_largeWeightBound Γ S hΓ.2.1
  · have ha := selectedStep_abort_resource_le p Γ.law hφ hφbound
      (indexedPrefixQueries φ) (measurable_indexedPrefixQueries hφ)
      (σ*Real.sqrt (N : ℝ)) S.queries S.measurable_queries hE hH S.abort_bound
    have har := ENNReal.toReal_mono (by finiteness) ha
    have hf : {z : ActivePrefix p.dimension N p.bankSize s × FutureWeights N (k+1) |
        z.1.1=false}={z | z.1.1≠true} := by ext z; simp
    have hf' : {z : ActivePrefix p.dimension N p.bankSize (s+1) × FutureWeights N k |
        z.1.1=false}={z | z.1.1≠true} := by ext z; simp
    rw [hf,hf'] at har
    change next.law.real {z | z.1.1≠true} ≤ _
    calc
      _ ≤ Γ.law.real {z | z.1.1≠true}+2*(p.inverseLayerFailure : ℝ)⁻¹ := by
        rw [ENNReal.toReal_add (measure_ne_top _ _) (by finiteness)] at har
        simpa only [Measure.real,ENNReal.toReal_mul,ENNReal.toReal_ofNat,
          ENNReal.toReal_ofReal (inv_nonneg.mpr (Nat.cast_nonneg (α:=ℝ) p.inverseLayerFailure)),
          ENNReal.toReal_inv,ENNReal.toReal_natCast,
          next,selectedNext,CanonicalTransition.next,selectedTransition] using har
      _ ≤ 2*(s : ℝ)/(p.inverseLayerFailure : ℝ)+2*(p.inverseLayerFailure : ℝ)⁻¹ :=
        add_le_add hΓ.2.2 le_rfl
      _ = 2*((s+1 : ℕ) : ℝ)/(p.inverseLayerFailure : ℝ) := by push_cast; ring

end NeuralGeneralization.RobustCompressionInduction
