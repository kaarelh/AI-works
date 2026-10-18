import NeuralGeneralization.RobustCompressionSelectedBank
import NeuralGeneralization.RobustCompressionSourceBankReindex
import NeuralGeneralization.RobustCompressionSelectedStateFactor

/-! # Covariance totalization vanishes after the actual shared abort decoder -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped Classical
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionReconstruction RobustCompressionSourceBank
open RobustCompressionSelectedBank RobustCompressionLayerGaussian
variable {d N m s M q : ℕ} {Y : Type*} [MeasurableSpace Y]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]

/-- A failed actual source bank makes the next state constant, regardless of
which full correlated residual coefficient law was used. -/
theorem selectedStateFromH_of_bad (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N))
    (J : ActivePrefix d N m s × Y → Finset (Fin M))
    (a t T BH BG : ℝ) (θ : ActivePrefix d N m s × Y)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (hbad : ¬sourceBankGood (sourceRows (selectedMessageBasis (q := q) b J θ))
      (activeHidden φ θ.1) a T I) (ξ : Fin N → Fin m → ℝ) :
    selectedStateFromH φ b J a t T BH BG θ (H,(I,ξ)) =
      (false,zeroPayload d N m (s+1)) := by
  change stepActive θ.1 _ (decide (_ ∧ sourceBankGood
    (sourceRows (selectedMessageBasis (q := q) b J θ)) (activeHidden φ θ.1) a T I)) = _
  simp [hbad]

/-- The literal residual coefficient law of the selected-bank comparison is
the canonical coefficient law, independent of the exposed active coordinates
and of the queried input. -/
theorem selectedBank_coefficientKernel
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : ActivePrefix d N m s × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : ActivePrefix d N m s → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH : ℝ) (i : Fin M) (θ : ActivePrefix d N m s × Y)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N) :
    ((selectedBankData (m := m) (q := q) b hb J hJ h hh).parameters a t T BH i).coefficientKernel
      ((θ,H),I) = selectedSourceResidualKernel (q := q) b hb J hJ a T (θ,I) := by
  rw [GaussianLayerParameters.coefficientKernel,residualRowsKernel_apply,
    selectedSourceResidualKernel_apply]
  rfl

/-- After applying the common next-state decoder, the globally contractive
fallback gives exactly the literal canonical law. Equality is proved on good
banks; failed banks are absorbed before their different raw laws can matter. -/
theorem selectedBank_totalized_state_map
    (e : Fin M ≃ Cube d) (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : ActivePrefix d N m s × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : ActivePrefix d N m s → Fin M → Fin N → ℝ) (hh : Measurable h)
    (heq : ∀ p i, h p i = activeHidden φ p (e i))
    (a t T BH BG : ℝ) (i : Fin M) (θ : ActivePrefix d N m s × Y)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N) :
    (((selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters a t T BH i).coefficientKernel
      ((θ,H),I)).map (fun ξ => selectedStateFromH φ b J a t T BH BG θ (H,(I,ξ))) =
    (selectedSourceResidualKernel (q := q) b hb J hJ a T (θ,I)).map
      (fun ξ => selectedStateFromH φ b J a t T BH BG θ (H,(I,ξ))) := by
  apply map_eq_of_good_or_constant _ _
    (sourceBankGood (sourceRows (selectedMessageBasis (q := q) b J θ))
      (activeHidden φ θ.1) a T I) _ (false,zeroPayload d N m (s+1))
  · intro hg
    have hbank : sourceBankGood
        ((selectedBankData (m := m) (q := q) b hb J hJ h hh).source ((θ,H),I))
        ((selectedBankData (m := m) (q := q) b hb J hJ h hh).feature ((θ,H),I)) a T I := by
      change sourceBankGood (sourceRows (selectedMessageBasis (q := q) b J θ)) (h θ.1) a T I
      have hf : h θ.1 = fun i => activeHidden φ θ.1 (e i) := funext (heq θ.1)
      rw [hf,sourceBankGood_reindex]
      exact hg
    rw [(selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters_coefficientKernel_of_good
      a t T BH i ((θ,H),I) hbank]
    exact selectedBank_coefficientKernel b hb J hJ h hh a t T BH i θ H I
  · exact fun hbad ξ => selectedStateFromH_of_bad φ b J a t T BH BG θ H I hbad ξ

end NeuralGeneralization.RobustCompressionCanonicalLayer
