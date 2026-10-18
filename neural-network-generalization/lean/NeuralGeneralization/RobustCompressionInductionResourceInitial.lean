import NeuralGeneralization.RobustCompressionInductionResources
import NeuralGeneralization.RobustCompressionCoefficientEnvelopes
import NeuralGeneralization.RobustCouplingActualCost

/-! # Resource-instantiated invariants at the literal first clipped layer -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustCompressionCanonicalLayer RobustCompressionBlockMoments

theorem initialCanonicalLaw_bounded {d N m r : ℕ} (hd : 0<d) (σ B B' : ℝ)
    (hB : 0≤B) (hBB : B≤B') (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    ∀ᵐ z ∂(initialCanonicalLaw m σ B Q).law,activePrefixBounded B' z.1 := by
  change ∀ᵐ z ∂Q.map (initialState m σ B),activePrefixBounded B' z.1
  apply (ae_map_iff (measurable_initialState d N m r σ B).aemeasurable
    ((measurableSet_activePrefixBounded B').preimage measurable_fst)).mpr
  exact Filter.Eventually.of_forall fun w =>
    activePrefixBounded_mono hBB _
      (initialPrefix_bounded hd σ B hB (splitFirst d N r (standardizedWeights σ w)).1)

theorem initialCanonicalLaw_alive {d N m r : ℕ} (σ B : ℝ)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    ∀ᵐ z ∂(initialCanonicalLaw m σ B Q).law,z.1.1=true := by
  change ∀ᵐ z ∂Q.map (initialState m σ B),z.1.1=true
  apply (ae_map_iff (measurable_initialState d N m r σ B).aemeasurable
    (measurableSet_eq_fun (measurable_fst.comp measurable_fst) measurable_const)).mpr
  exact Filter.Eventually.of_forall (fun w => rfl)

theorem initialCanonicalLaw_abort {d N m r : ℕ} (σ B : ℝ)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    (initialCanonicalLaw m σ B Q).law {z | z.1.1≠true}=0 :=
  (ae_iff.mp (initialCanonicalLaw_alive σ B Q))

theorem initialHistory_live_cost_le {d N m r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ K : ℝ} (hσ : 0<σ) (hK : 0≤K) (hscale : (N : ℝ)*σ^2≤1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : InformationTheory.klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K/σ^2))
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hbound : ∀ z,|φ z|≤1)
    (B : ℝ) (hB : 0<B) (x : Cube d) :
    (∫⁻ z,liveOriginalCost (Nat.zero_le r) φ x z
      ∂(initialHistory m σ B hφ x Q).joint) ≤
      ENNReal.ofReal (4*(4*K+2*((d : ℝ)+1))/B^2) := by
  refine (lintegral_mono (fun z => ?_)).trans
    (initialHistory_cost_le hd hN hσ hK hscale Q hKL hφ hbound B hB x)
  unfold liveOriginalCost
  split_ifs <;> simp

theorem initialHistory_resource_cost (p : RobustCompressionInput) {N r : ℕ}
    (hd : 0<p.dimension) (hN : 0<N) (hE : 0<p.inverseLayerError)
    {σ : ℝ} (hσ : 0<σ) (hscale : (N : ℝ)*σ^2≤1)
    (Q : Measure (Weights p.dimension N r)) [IsProbabilityMeasure Q]
    (hKL : InformationTheory.klDiv Q (smallPrior p.dimension N r σ) ≤
      ENNReal.ofReal ((p.energy : ℝ)/σ^2))
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hbound : ∀ z,|φ z|≤1)
    (x : Cube p.dimension) :
    (∫⁻ z,liveOriginalCost (Nat.zero_le r) φ x z
      ∂(initialHistory p.bankSize σ (Real.sqrt p.firstSquaredBound) hφ x Q).joint) ≤
      ENNReal.ofReal ((p.inverseLayerError : ℝ)⁻¹) := by
  have hfirst : 0<p.firstSquaredBound := by
    unfold RobustCompressionInput.firstSquaredBound
    positivity
  have hb : 0<Real.sqrt (p.firstSquaredBound : ℝ) := by positivity
  have h := initialHistory_live_cost_le (m:=p.bankSize) hd hN hσ (Nat.cast_nonneg p.energy) hscale
    Q hKL hφ hbound (Real.sqrt p.firstSquaredBound) hb x
  rw [Real.sq_sqrt (Nat.cast_nonneg p.firstSquaredBound),p.first_clipping_allocation hE] at h
  exact h

end NeuralGeneralization.RobustCompressionInduction
