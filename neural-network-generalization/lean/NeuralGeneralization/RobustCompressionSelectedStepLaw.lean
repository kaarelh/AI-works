import NeuralGeneralization.RobustCompressionInductionSelected

/-! # Exact direct-row form of the selected canonical transition

The original current rows remain in the joint law. Reassembling their actual
conditional law, flattening them back, and attaching the deterministic finite
message gives exactly the canonical state transition. No equality between
versions of conditional kernels is assumed.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy RobustCompressionCanonicalLayer ConcreteModel
set_option maxHeartbeats 300000

section Generic
variable {A B C J : Type*} [MeasurableSpace A] [MeasurableSpace B]
  [MeasurableSpace C] [MeasurableSpace J]

/-- Moving a deterministic input map from a measure to a kernel. -/
theorem kernel_comp_map_eq (μ : Measure A) (κ : Kernel B C)
    (f : A → B) (hf : Measurable f) :
    κ ∘ₘ μ.map f = κ.comap f hf ∘ₘ μ := by
  rw [← Measure.deterministic_comp_eq_map hf, Measure.comp_assoc,
    Kernel.comp_deterministic_eq_comap]

/-- A deterministic message can be attached directly to the input. -/
theorem deterministic_message_collapse (μ : Measure A) [SFinite μ]
    (message : A → J) (hm : Measurable message) (κ : Kernel (A × J) C) :
    κ ∘ₘ (μ ⊗ₘ Kernel.deterministic message hm) =
      κ.comap (fun a => (a,message a)) (measurable_id.prodMk hm) ∘ₘ μ := by
  rw [Measure.compProd_deterministic]
  exact kernel_comp_map_eq μ κ _ (measurable_id.prodMk hm)
end Generic

variable {d N m s r q M : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]

abbrev DirectRowState (d N m s r : ℕ) :=
  (ActivePrefix d N m s × FutureWeights N r) ×
    (Fin N → EuclideanSpace ℝ (Fin N))

/-- Recover the canonical exposed input from conditioning variables and rows. -/
def flattenCurrentRowState (z : DirectRowState d N m s r) :
    (ActivePrefix d N m s × InternalBlock N) × FutureWeights N r :=
  ((z.1.1,flattenRows N z.2),z.1.2)

omit [NeZero N] in
theorem measurable_flattenCurrentRowState :
    Measurable (flattenCurrentRowState (d:=d) (N:=N) (m:=m) (s:=s) (r:=r)) :=
  (measurable_fst.fst.prodMk ((measurable_flattenRows N).comp measurable_snd)).prodMk
    measurable_fst.snd

/-- Reassembly is an identity of the actual laws, not only their marginals. -/
theorem currentRowJoint_flatten
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) :
    (currentRowJoint (prefixCurrentLaw Q)).map flattenCurrentRowState =
      Q.map (canonicalInput N r) := by
  unfold currentRowJoint prefixCurrentLaw
  rw [Measure.map_map measurable_currentGivenFuture (measurable_splitRowsState N r),
    Measure.map_map measurable_flattenCurrentRowState
      (measurable_currentGivenFuture.comp (measurable_splitRowsState N r))]
  rfl

def directSelectedRowInput
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (z : DirectRowState d N m s r) :
    (((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r) ×
      QueryMessage (Fin M) q) :=
  (flattenCurrentRowState z,abortQueryMessage q (J z.1))

omit [MeasurableSingletonClass (QueryMessage (Fin M) q)] in
theorem measurable_directSelectedRowInput
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J) : Measurable (directSelectedRowInput (q:=q) J) :=
  measurable_flattenCurrentRowState.prodMk
    ((measurable_abortQueryMessage J hJ).comp measurable_fst)

/-- The concrete retained-row channel: reconstruct from the original block
and finite message, and copy the untouched future. -/
def directSelectedRowKernel
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J)
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) ×
      QueryMessage (Fin M) q) (ActivePrefix d N m (s+1))) :
    Kernel (DirectRowState d N m s r) (ActivePrefix d N m (s+1) × FutureWeights N r) :=
  (messagePrefixChannel reconstruct).comap (directSelectedRowInput J)
    (measurable_directSelectedRowInput J hJ)

instance directSelectedRowKernel_markov
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J)
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) ×
      QueryMessage (Fin M) q) (ActivePrefix d N m (s+1))) [IsMarkovKernel reconstruct] :
    IsMarkovKernel (directSelectedRowKernel J hJ reconstruct) := by
  unfold directSelectedRowKernel
  infer_instance

/-- Pointwise law: only the reconstructed prefix changes; the future is copied. -/
theorem directSelectedRowKernel_apply
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J)
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) ×
      QueryMessage (Fin M) q) (ActivePrefix d N m (s+1))) [IsSFiniteKernel reconstruct]
    (z : DirectRowState d N m s r) :
    directSelectedRowKernel J hJ reconstruct z =
      (reconstruct ((z.1.1,flattenRows N z.2),abortQueryMessage q (J z.1))).map
        (fun next => (next,z.1.2)) := by
  rw [directSelectedRowKernel,Kernel.comap_apply,messagePrefixChannel,
    Kernel.comap_apply,Kernel.parallelComp_apply,Kernel.id_apply,Measure.prod_dirac]
  rfl

/-- Exact next-state law in retained-row coordinates. -/
theorem canonicalStepLaw_eq_direct_rows
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J)
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) ×
      QueryMessage (Fin M) q) (ActivePrefix d N m (s+1))) :
    canonicalStepLaw Q (selectedMessageKernel J hJ) reconstruct =
      directSelectedRowKernel J hJ reconstruct ∘ₘ currentRowJoint (prefixCurrentLaw Q) := by
  let attach := fun z : (ActivePrefix d N m s × InternalBlock N) × FutureWeights N r =>
    (z,abortQueryMessage q (J (z.1.1,z.2)))
  have hatt : Measurable attach := measurable_id.prodMk
    ((measurable_abortQueryMessage J hJ).comp (by fun_prop))
  letI : IsProbabilityMeasure (Q.map (canonicalInput N r)) :=
    Measure.isProbabilityMeasure_map (measurable_canonicalInput N r).aemeasurable
  unfold canonicalStepLaw selectedMessageKernel
  rw [Measure.compProd_deterministic]
  change (messagePrefixChannel reconstruct) ∘ₘ (Q.map (canonicalInput N r)).map attach = _
  rw [← currentRowJoint_flatten Q,
    Measure.map_map hatt measurable_flattenCurrentRowState]
  exact kernel_comp_map_eq _ _ _ (hatt.comp measurable_flattenCurrentRowState)

/-- The actual conditional-current disintegration gives the same state law.
This identity retains both conditioning coordinates and all original rows. -/
theorem canonicalStepLaw_eq_disintegrated_rows
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J)
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) ×
      QueryMessage (Fin M) q) (ActivePrefix d N m (s+1))) :
    canonicalStepLaw Q (selectedMessageKernel J hJ) reconstruct =
      directSelectedRowKernel J hJ reconstruct ∘ₘ
        ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
          (currentRowJoint (prefixCurrentLaw Q)).condKernel) := by
  rw [Measure.disintegrate]
  exact canonicalStepLaw_eq_direct_rows Q J hJ reconstruct

/-- Specialization to the actual source-bank/Gaussian canonical layer. -/
theorem canonicalLayerStep_eq_disintegrated_rows
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ)
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J) :
    canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ)
      (canonicalLayerKernel hφ b hb a t T BH BG) =
      directSelectedRowKernel (q:=q) J hJ (canonicalLayerKernel hφ b hb a t T BH BG) ∘ₘ
        ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
          (currentRowJoint (prefixCurrentLaw Q)).condKernel) :=
  canonicalStepLaw_eq_disintegrated_rows Q J hJ _

end NeuralGeneralization.RobustCompressionInduction
