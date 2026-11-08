import NeuralGeneralization.OnlineLowerNetworkNorm
import NeuralGeneralization.OnlineLowerReluCosineProduct

/-! # Literal row and Fourier interfaces for the shallow network

The analytic affine neuron and the concrete Gaussian-network row are exactly
the same function, including the constant input coordinate. The retained
physical Fourier mass is exactly the cost of the logical projection.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu OnlineLowerGeometry

def incomingBias {d N : ℕ} (w : Weights d N 0) (j : Fin N) : ℝ :=
  incomingAtoms w j 0

def incomingPhysical {d N : ℕ} (w : Weights d N 0) (j : Fin N) : Fin d → ℝ :=
  fun i => incomingAtoms w j i.succ

theorem incoming_sum_eq_cubeAffine {d N : ℕ} (w : Weights d N 0)
    (j : Fin N) (x : Cube d) :
    (∑ i, incomingAtoms w j i * inputVector x i) =
      cubeAffine (incomingBias w j) (incomingPhysical w j) x := by
  rw [Fin.sum_univ_succ]
  simp only [inputVector, Fin.cases_zero, Fin.cases_succ, mul_one]
  rfl

/-- Equality for every activation; the ReLU specialization therefore uses
exactly the model's `max 0` of the same affine input. -/
theorem firstHidden_eq_cubeAffine {d N : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N 0) (x : Cube d) (j : Fin N) :
    firstHidden φ w x j = φ (cubeAffine (incomingBias w j) (incomingPhysical w j) x) := by
  change φ (∑ i, incomingAtoms w j i * inputVector x i) = _
  rw [incoming_sum_eq_cubeAffine]

theorem incomingEuclideanNorm_sq {d N : ℕ} (w : Weights d N 0) (j : Fin N) :
    incomingEuclideanNorm w j ^ 2 =
      incomingBias w j ^ 2 + ∑ i, incomingPhysical w j i ^ 2 := by
  unfold incomingEuclideanNorm
  rw [Real.sq_sqrt (Finset.sum_nonneg (fun i _ => sq_nonneg _)), Fin.sum_univ_succ]
  rfl

theorem incomingEuclideanNorm_eq_sqrt {d N : ℕ} (w : Weights d N 0) (j : Fin N) :
    incomingEuclideanNorm w j =
      Real.sqrt (incomingBias w j ^ 2 + ∑ i, incomingPhysical w j i ^ 2) := by
  unfold incomingEuclideanNorm
  rw [Fin.sum_univ_succ]
  rfl

theorem logicalProjection_walshCoefficient {d m : ℕ} (C : WalshCodeMap d m)
    (F : ClippingCube d → ℝ) (S : Finset (Fin m)) :
    walshCoefficients (C.logicalProjection F) S = walshCoefficients F (C.support S) := by
  exact walshCoefficients_expansion _ _

/-- The actual retained physical coefficient mass is the existing logical
weighted Walsh cost; no replacement coefficient model is used. -/
theorem retainedFourierMass_eq_logicalCost {d m : ℕ} (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (F : ClippingCube d → ℝ) :
    retainedFourierMass C.support weight F = weightedWalshCost weight (C.logicalProjection F) := by
  unfold retainedFourierMass weightedWalshCost weightedL1
  simp only [logicalProjection_walshCoefficient]

/-- Retaining an injectively indexed subfamily can only decrease a
nonnegative weighted Fourier mass. -/
theorem retainedFourierMass_subfamily {d : ℕ} {ι κ : Type*}
    [Fintype ι] [Fintype κ] [DecidableEq κ]
    (small : ι → Finset (Fin d)) (full : κ → Finset (Fin d))
    (smallWeight : ι → ℝ) (fullWeight : κ → ℝ)
    (index : ι → κ) (hinj : Function.Injective index)
    (hsupport : ∀ i, small i = full (index i))
    (hweight : ∀ i, smallWeight i = fullWeight (index i))
    (hfull : ∀ k, 0 ≤ fullWeight k) (F : ClippingCube d → ℝ) :
    retainedFourierMass small smallWeight F ≤ retainedFourierMass full fullWeight F := by
  classical
  unfold retainedFourierMass
  simp_rw [hsupport, hweight]
  calc
    _ = ∑ k ∈ Finset.univ.image index, fullWeight k * |walshCoefficients F (full k)| := by
      rw [Finset.sum_image]
      exact fun i _ j _ h => hinj h
    _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      (fun k _ _ => mul_nonneg (hfull k) (abs_nonneg _))

/-- Convenience form of the actual network deficit theorem, with analytic
row hypotheses stated directly in the physical affine-neuron notation. -/
theorem network_logical_cost_and_deficit {d m N : ℕ}
    (hd : 0 < d) (hN : 0 < N) (C : WalshCodeMap d m)
    (weight : Finset (Fin m) → ℝ) (hw : ∀ S, 0 ≤ weight S)
    (D : Finset (Finset (Fin d))) (φ : ℝ → ℝ) (w : Weights d N 0)
    (K : ℝ) (hK : 0 ≤ K)
    (hmass : ∀ j, retainedFourierMass C.support weight
      (fun x => φ (cubeAffine (incomingBias w j) (incomingPhysical w j) x)) ≤
        Real.sqrt (incomingBias w j ^ 2 + ∑ i, incomingPhysical w j i ^ 2))
    (herror : ∀ j, uniformCubeMean (fun x =>
      (φ (cubeAffine (incomingBias w j) (incomingPhysical w j) x) - fourierProject D
        (fun x => φ (cubeAffine (incomingBias w j) (incomingPhysical w j) x)) x) ^ 2) ≤
        K * Real.sqrt (incomingBias w j ^ 2 + ∑ i, incomingPhysical w j i ^ 2) *
          (Real.sqrt (incomingBias w j ^ 2 + ∑ i, incomingPhysical w j i ^ 2) -
            retainedFourierMass C.support weight
              (fun x => φ (cubeAffine (incomingBias w j) (incomingPhysical w j) x)))) :
    weightedWalshCost weight (C.logicalProjection (networkOutput φ w)) ≤ networkVariationBudget w ∧
    uniformCubeMean (fun x => (networkOutput φ w x - fourierProject D (networkOutput φ w) x) ^ 2) ≤
      K * networkVariationBudget w *
        (networkVariationBudget w - weightedWalshCost weight (C.logicalProjection (networkOutput φ w))) := by
  have h := actual_network_fourier_deficit hd hN C.support weight hw D φ w K hK
    (fun j => by simpa only [firstHidden_eq_cubeAffine, incomingEuclideanNorm_eq_sqrt] using hmass j)
    (fun j => by simpa only [firstHidden_eq_cubeAffine, incomingEuclideanNorm_eq_sqrt] using herror j)
  simpa only [retainedFourierMass_eq_logicalCost] using h

end NeuralGeneralization.OnlineLower
