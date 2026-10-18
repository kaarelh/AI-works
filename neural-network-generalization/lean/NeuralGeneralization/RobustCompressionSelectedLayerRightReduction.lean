import NeuralGeneralization.RobustCompressionSelectedLayerCoupling

/-! # Integrating the pointwise new-state identity

This reduction has one explicitly named fiber-identity premise. It is used
only after the genuine active-coordinate and shared-abort identities establish
that premise for the actual layer comparison.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction

section Generic
variable {A U V Z : Type*} [MeasurableSpace A] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace Z]

theorem map_compProd_eq_of_fiber_identity
    (μ : Measure A) [SFinite μ]
    (κ : Kernel A U) [IsMarkovKernel κ]
    (η : Kernel A V) [IsMarkovKernel η]
    (τ : Kernel (A × V) Z) [IsMarkovKernel τ]
    (f : A × U → Z) (hf : Measurable f)
    (hpoint : ∀ a, (κ a).map (fun u => f (a,u)) = (Kernel.sectR τ a) ∘ₘ η a) :
    (μ ⊗ₘ κ).map f = τ ∘ₘ (μ ⊗ₘ η) := by
  ext S hS
  rw [Measure.map_apply hf hS,Measure.compProd_apply (hf hS),
    Measure.bind_apply hS τ.aemeasurable,
    Measure.lintegral_compProd (Kernel.measurable_coe τ hS)]
  apply lintegral_congr
  intro a
  have h := congrArg (fun ν : Measure Z => ν S) (hpoint a)
  have hfa : Measurable (fun u : U => f (a,u)) :=
    hf.comp (measurable_const.prodMk measurable_id)
  rw [Measure.map_apply hfa hS,
    Measure.bind_apply hS (Kernel.sectR τ a).aemeasurable] at h
  exact h
end Generic

variable {d N m s r M q : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "P" => ActivePrefix d N m s
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E
local notation "Base" => P × FutureWeights N r
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ
local notation "Raw" => Base × ((Rows × (Fin N → ℝ)) × (S × R))

/-- Exact right marginal, reduced only to the pointwise identity proved by
the active-coordinate and canonical-abort calculation. -/
theorem selectedLayerJoint_right_of_fiber_identity
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (b : P → Fin M → E) (hb : Measurable b)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    (h : P → Fin M → Fin N → ℝ) (hh : Measurable h)
    (a t T BH BG : ℝ) (i : Fin M)
    (hpoint : ∀ θ,
      (actualSelectedLayerKernel (q:=q) Q b hb J hJ h hh a t T BH i θ).map
        (fun z => (selectedStateFromH φ b J a t T BH BG θ
          (actualActiveH (selectedMessageBasis (q:=q) b J θ) t z.1.1,z.2),θ.2)) =
      (Kernel.sectR (directSelectedRowKernel (q:=q) J hJ
        (canonicalLayerKernel hφ b hb a t T BH BG)) θ) ∘ₘ
        (currentRowJoint (prefixCurrentLaw Q)).condKernel θ) :
    (selectedLayerJoint (q:=q) Q φ b hb J hJ h hh a t T BH BG i).map Prod.snd =
      canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ)
        (canonicalLayerKernel hφ b hb a t T BH BG) := by
  rw [selectedLayerJoint,Measure.map_map measurable_snd
    (measurable_selectedStatePair hφ b hb J hJ a t T BH BG),
    canonicalLayerStep_eq_disintegrated_rows]
  apply map_compProd_eq_of_fiber_identity _ _ _ _ _
    (measurable_snd.comp (measurable_selectedStatePair hφ b hb J hJ a t T BH BG))
  exact hpoint

end NeuralGeneralization.RobustCompressionCanonicalLayer
