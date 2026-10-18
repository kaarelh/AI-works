import NeuralGeneralization.RobustCompressionCanonicalLayer
import NeuralGeneralization.RobustCompressionLayerParametersTotalization

/-! # The common abort erases any covariance fallback on bad source banks

The equality below concerns the actual updated candidate state. It does not
assert equality of raw coefficient laws on failed source samples.
-/
noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionReconstruction
open RobustGaussianGeometry RobustCompressionSourceBank

variable {d N m s q : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

/-- Arbitrary probability laws have the same pushforward under a constant
map; agreement on the successful branch is therefore enough. -/
theorem map_eq_of_good_or_constant {Ω Z : Type*} [MeasurableSpace Ω] [MeasurableSpace Z]
    (μ ν : Measure Ω) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (good : Prop) (f : Ω → Z) (z : Z)
    (hgood : good → μ=ν) (hbad : ¬good → ∀ω, f ω=z) : μ.map f = ν.map f := by
  by_cases h : good
  · rw [hgood h]
  · have hf : f = fun _ => z := funext (hbad h)
    rw [hf]
    simp

def canonicalFixedStateDraw (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (a T : ℝ) (z : CanonicalLayerInput d N m s q I) (indices : Fin m → Fin N)
    (rows : Fin N → Fin m → ℝ) : ActivePrefix d N m (s+1) :=
  stepActive z.1.1 (indices,rows) (canonicalLayerSuccess φ b a T z (indices,rows))

theorem canonicalFixedStateDraw_of_bad (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (a T : ℝ) (z : CanonicalLayerInput d N m s q I) (indices : Fin m → Fin N)
    (hbad : ¬sourceBankGood (sourceRows (canonicalBasis b z))
      (activeHidden φ z.1.1) a T indices) (rows : Fin N → Fin m → ℝ) :
    canonicalFixedStateDraw φ b a T z indices rows = (false,zeroPayload d N m (s+1)) := by
  simp [canonicalFixedStateDraw,canonicalLayerSuccess,hbad]

/-- The literal shared-abort update has the same law for any two probability
coefficient laws agreeing on good source banks. -/
theorem canonical_state_map_eq_of_good (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (a T : ℝ) (z : CanonicalLayerInput d N m s q I) (indices : Fin m → Fin N)
    (μ ν : Measure (Fin N → Fin m → ℝ)) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hgood : sourceBankGood (sourceRows (canonicalBasis b z))
      (activeHidden φ z.1.1) a T indices → μ=ν) :
    μ.map (canonicalFixedStateDraw φ b a T z indices) =
      ν.map (canonicalFixedStateDraw φ b a T z indices) :=
  map_eq_of_good_or_constant μ ν _ _ (false,zeroPayload d N m (s+1)) hgood
    (fun hbad rows => canonicalFixedStateDraw_of_bad φ b a T z indices hbad rows)

/-- The same identity before literal clipping/reconstruction of the residual
rows. This is the form used with totalized Gaussian coefficient kernels. -/
theorem canonical_residual_state_map_eq_of_good (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (a t T BH BG : ℝ) (z : CanonicalLayerInput d N m s q I) (indices : Fin m → Fin N)
    (μ ν : Measure (Fin N → Fin m → ℝ)) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hgood : sourceBankGood (sourceRows (canonicalBasis b z))
      (activeHidden φ z.1.1) a T indices → μ=ν) :
    μ.map (fun ξ => canonicalFixedStateDraw φ b a T z indices
      (fixedSourceRowsDraw a t T BH BG (canonicalReconstructionInput b t z,indices) ξ)) =
    ν.map (fun ξ => canonicalFixedStateDraw φ b a T z indices
      (fixedSourceRowsDraw a t T BH BG (canonicalReconstructionInput b t z,indices) ξ)) :=
  map_eq_of_good_or_constant μ ν _ _ (false,zeroPayload d N m (s+1)) hgood
    (fun hbad ξ => canonicalFixedStateDraw_of_bad φ b a T z indices hbad _)

/-- Apply the preceding identity to the actual zero-matrix covariance fallback.
Only the displayed source/feature/index identifications are needed. -/
theorem canonical_totalized_state_map
    {A : Type*} [MeasurableSpace A]
    (data : RobustCompressionLayerParameters.BankLayerData A (Cube d) N m q)
    (φ : ℝ → ℝ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N))
    (a t T BH BG : ℝ) (x : Cube d) (θ : A)
    (z : CanonicalLayerInput d N m s q I) (indices : Fin m → Fin N)
    (hsource : data.source θ = sourceRows (canonicalBasis b z))
    (hfeature : data.feature θ = activeHidden φ z.1.1)
    (hindices : data.indices θ = indices) :
    ((data.totalizedParameters a t T BH x).coefficientKernel θ).map
      (fun ξ => canonicalFixedStateDraw φ b a T z indices
        (fixedSourceRowsDraw a t T BH BG (canonicalReconstructionInput b t z,indices) ξ)) =
    ((data.parameters a t T BH x).coefficientKernel θ).map
      (fun ξ => canonicalFixedStateDraw φ b a T z indices
        (fixedSourceRowsDraw a t T BH BG (canonicalReconstructionInput b t z,indices) ξ)) := by
  apply canonical_residual_state_map_eq_of_good
  intro hgood
  apply data.totalizedParameters_coefficientKernel_of_good a t T BH x θ
  simpa only [hsource,hfeature,hindices] using hgood

end NeuralGeneralization.RobustCompressionCanonicalLayer
