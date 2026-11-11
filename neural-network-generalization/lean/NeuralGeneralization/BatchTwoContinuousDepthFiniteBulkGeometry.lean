import NeuralGeneralization.BatchTwoContinuousDepthFiniteGaussian
import NeuralGeneralization.BatchTwoActivationConvexProjection
import NeuralGeneralization.BatchTwoNonGaussianSpectralLaw

/-! The actual closed, convex, centrally symmetric Gaussian block body. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

abbrev EnergySpace (d N r : ℕ) := EuclideanSpace ℝ (WeightIndex d N r)

def firstBlockProjection (d N r : ℕ) : EnergySpace d N r →ₗ[ℝ]
    EuclideanSpace ℝ (Fin N × Fin (d+1)) where
  toFun u := WithLp.toLp 2 (fun ij => u (Sum.inl ij))
  map_add' := by intro u v;ext ij;simp
  map_smul' := by intro c u;ext ij;simp

def readoutBlockProjection (d N r : ℕ) : EnergySpace d N r →ₗ[ℝ] EuclideanSpace ℝ (Fin N) where
  toFun u := WithLp.toLp 2 (fun i => u (Sum.inr (Sum.inr i)))
  map_add' := by intro u v;ext i;simp
  map_smul' := by intro c u;ext i;simp

def internalBlockProjection (d N r : ℕ) (s : Fin r) : EnergySpace d N r →ₗ[ℝ]
    (EuclideanSpace ℝ (Fin N) →L[ℝ] EuclideanSpace ℝ (Fin N)) where
  toFun u := coordinateMatrixOperator (fun ij => u (Sum.inr (Sum.inl (s,ij))))
  map_add' := by
    intro u v
    ext x i
    simp [coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,add_mul,Finset.sum_add_distrib]
  map_smul' := by
    intro c u
    ext x i
    simp [coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,mul_assoc,Finset.mul_sum]

def boundaryNoiseRadius (d N : ℕ) : ℝ := Real.sqrt (N : ℝ)*Real.sqrt (firstNoiseSquared d)

def internalNoiseRadius (N L : ℕ) : ℝ := Real.sqrt (N : ℝ)*Real.sqrt (internalNoiseSquared L)

def typicalBody (d N r : ℕ) : Set (EnergySpace d N r) :=
  (firstBlockProjection d N r) ⁻¹' Metric.closedBall 0 (boundaryNoiseRadius d N) ∩
  (readoutBlockProjection d N r) ⁻¹' Metric.closedBall 0 (boundaryNoiseRadius d N) ∩
  ⋂ s, (internalBlockProjection d N r s) ⁻¹' Metric.closedBall 0 (internalNoiseRadius N (r+2))

theorem mem_typicalBody {d N r : ℕ} (u : EnergySpace d N r) :
    u ∈ typicalBody d N r ↔
      ‖firstBlockProjection d N r u‖ ≤ boundaryNoiseRadius d N ∧
      ‖readoutBlockProjection d N r u‖ ≤ boundaryNoiseRadius d N ∧
      ∀ s,‖internalBlockProjection d N r s u‖ ≤ internalNoiseRadius N (r+2) := by
  simp only [typicalBody,Set.mem_inter_iff,Set.mem_preimage,Metric.mem_closedBall,
    dist_zero_right,Set.mem_iInter]
  tauto

theorem typicalBody_closed (d N r : ℕ) : IsClosed (typicalBody d N r) :=
  ((Metric.isClosed_closedBall.preimage (firstBlockProjection d N r).continuous_of_finiteDimensional).inter
    (Metric.isClosed_closedBall.preimage (readoutBlockProjection d N r).continuous_of_finiteDimensional)).inter
      (isClosed_iInter fun s => Metric.isClosed_closedBall.preimage
        (internalBlockProjection d N r s).continuous_of_finiteDimensional)

theorem typicalBody_convex (d N r : ℕ) : Convex ℝ (typicalBody d N r) :=
  (((convex_closedBall (0 : EuclideanSpace ℝ (Fin N × Fin (d+1))) _).linear_preimage
    (firstBlockProjection d N r)).inter
    ((convex_closedBall (0 : EuclideanSpace ℝ (Fin N)) _).linear_preimage
      (readoutBlockProjection d N r))).inter
    (convex_iInter fun s => (convex_closedBall
      (0 : EuclideanSpace ℝ (Fin N) →L[ℝ] EuclideanSpace ℝ (Fin N)) _).linear_preimage
      (internalBlockProjection d N r s))

theorem typicalBody_zero (d N r : ℕ) : (0 : EnergySpace d N r) ∈ typicalBody d N r := by
  rw [mem_typicalBody]
  simp only [map_zero,norm_zero]
  unfold boundaryNoiseRadius internalNoiseRadius
  exact ⟨by positivity,by positivity,fun _ => by positivity⟩

theorem typicalBody_nonempty (d N r : ℕ) : (typicalBody d N r).Nonempty :=
  ⟨0,typicalBody_zero d N r⟩

theorem typicalBody_neg (d N r : ℕ) (u : EnergySpace d N r) :
    -u ∈ typicalBody d N r ↔ u ∈ typicalBody d N r := by
  simp only [mem_typicalBody,map_neg,norm_neg]

theorem typicalBody_first_squared {d N r : ℕ} {u : EnergySpace d N r}
    (hu : u ∈ typicalBody d N r) :
    ∑ ij : Fin N × Fin (d+1),u (Sum.inl ij)^2 ≤ (N : ℝ)*firstNoiseSquared d := by
  have hh := (mem_typicalBody u).mp hu |>.1
  have hs := pow_le_pow_left₀ (norm_nonneg _) hh 2
  simpa only [boundaryNoiseRadius,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N),
    Real.sq_sqrt (firstNoiseSquared_pos d).le,EuclideanSpace.real_norm_sq_eq,
    firstBlockProjection,LinearMap.coe_mk,AddHom.coe_mk,PiLp.toLp_apply] using hs

theorem typicalBody_readout_squared {d N r : ℕ} {u : EnergySpace d N r}
    (hu : u ∈ typicalBody d N r) :
    ∑ i : Fin N,u (Sum.inr (Sum.inr i))^2 ≤ (N : ℝ)*firstNoiseSquared d := by
  have hh := (mem_typicalBody u).mp hu |>.2.1
  have hs := pow_le_pow_left₀ (norm_nonneg _) hh 2
  simpa only [boundaryNoiseRadius,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N),
    Real.sq_sqrt (firstNoiseSquared_pos d).le,EuclideanSpace.real_norm_sq_eq,
    readoutBlockProjection,LinearMap.coe_mk,AddHom.coe_mk,PiLp.toLp_apply] using hs

end NeuralGeneralization.BatchTwoContinuousDepthPaper
