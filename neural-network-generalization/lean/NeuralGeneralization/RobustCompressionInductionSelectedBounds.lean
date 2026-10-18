import NeuralGeneralization.RobustCompressionInductionSelected
import NeuralGeneralization.RobustCompressionCanonicalLayerBounds

/-! # Coefficient support under a complete selected canonical transition -/
noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustCompressionCanonicalLayer

variable {d N m s r q M : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)] [MeasurableSingletonClass (QueryMessage (Fin M) q)]

theorem canonicalStepLaw_bounded {J : Type*} [MeasurableSpace J]
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (message : Kernel ((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r) J)
    [IsMarkovKernel message]
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) × J)
      (ActivePrefix d N m (s+1))) [IsMarkovKernel reconstruct]
    (B : ℝ) (hQ : ∀ᵐ z ∂Q, activePrefixBounded B z.1)
    (hstep : ∀ z, activePrefixBounded B z.1.1 →
      ∀ᵐ p ∂reconstruct z, activePrefixBounded B p) :
    ∀ᵐ z ∂canonicalStepLaw Q message reconstruct, activePrefixBounded B z.1 := by
  have hinput : ∀ᵐ z ∂Q.map (canonicalInput N r), activePrefixBounded B z.1.1 := by
    apply (ae_map_iff (measurable_canonicalInput N r).aemeasurable
      ((measurableSet_activePrefixBounded B).preimage (by fun_prop))).mpr
    exact hQ
  have hmsg : ∀ᵐ z ∂(Q.map (canonicalInput N r)) ⊗ₘ message,
      activePrefixBounded B z.1.1.1 :=
    Measure.ae_compProd_of_ae_fst message
      ((measurableSet_activePrefixBounded B).preimage (by fun_prop)) hinput
  unfold canonicalStepLaw
  apply Measure.ae_comp_of_ae_ae ((measurableSet_activePrefixBounded B).preimage measurable_fst)
  filter_upwards [hmsg] with z hz
  have hs := hstep (z.1.1,z.2) hz
  rw [messagePrefixChannel,Kernel.comap_apply,Kernel.parallelComp_apply,Kernel.id_apply]
  apply (ae_map_iff measurable_fst.aemeasurable (measurableSet_activePrefixBounded B)).mp
  simpa only [Measure.map_fst_prod,measure_univ,one_smul,messageReorder] using hs

theorem selectedTransition_next_bounded {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    {a t T BH BG B : ℝ} (hm : 0 < m) (ha : 0 ≤ a) (ht : |t| ≤ 1)
    (hT : 0 ≤ T) (hBH : 0 ≤ BH) (hBG : 0 ≤ BG) (hB : 0 ≤ B)
    (hbound : BH*T+BG ≤ B)
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J)
    (Q : CanonicalStateLaw d N m s (r+1))
    (hQ : ∀ᵐ z ∂Q.law, activePrefixBounded B z.1) :
    ∀ᵐ z ∂(CanonicalTransition.next d N m (QueryMessage (Fin M) q)
      (selectedTransition hφ b hb a t T BH BG J hJ) Q).law,
      activePrefixBounded B z.1 := by
  apply canonicalStepLaw_bounded Q.law _ _ B hQ
  intro z hz
  exact canonicalLayerKernel_bounded hφ b hb hm ha ht hT hBH hBG hB hbound z hz

end NeuralGeneralization.RobustCompressionInduction
