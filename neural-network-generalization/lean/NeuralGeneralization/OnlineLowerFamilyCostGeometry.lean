import NeuralGeneralization.OnlineLowerReluFamilyWeights
import NeuralGeneralization.OnlineLowerGeometryCandidate
import NeuralGeneralization.OnlineLowerCostUniversalPrefix
import NeuralGeneralization.OnlineLowerReluAbsorption

/-! # Actual family weights on the whole calibration coset

The prefix estimate applies to every point of the calibration coset, rather
than only to the specially ordered candidates. All weights below are the
inverse costs of the actual physical ReLU supports.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLower.FamilyCost OnlineLowerGeometry OnlineLowerBernstein

theorem weight_eq_subsetWeight (R k : ℕ) :
    weight R k = subsetWeight k ((pairDim k * R : ℕ) : ℝ) gammaCost := by
  funext s
  exact weight_eq_columnCost R k s

theorem weightExpansion_eq_coefficient (R k : ℕ)
    (S : Finset (Fin (logicalDim k))) :
    walshExpansion (weight R k) (negativeBitsCube S) /
        Fintype.card (ClippingCube (logicalDim k)) =
      walshCoefficients (fun z => gammaCost
        (columnDegree ((pairDim k * R : ℕ) : ℝ) (column k)
          (fun j => (increment k j : ℝ)) z)) S := by
  rw [weight_eq_subsetWeight]
  exact subset_weight_fourier_eq (fun z => gammaCost
    (columnDegree ((pairDim k * R : ℕ) : ℝ) (column k)
      (fun j => (increment k j : ℝ)) z)) S

def pathSupportOfPoint (k : ℕ) (z : ClippingCube (logicalDim k)) :
    Finset (Fin (pathDim k)) :=
  Finset.univ.filter (fun j => z (logicalIndex k (.inr j)) = false)

theorem prefix_point_representation (k : ℕ) (z : ClippingCube (logicalDim k))
    (hz : ∀ i : Fin (prefixDim k), z (logicalIndex k (.inl i)) = false) :
    negativeBitsCube (joinedSyndromeSupport (prefixDim k) (pathDim k)
      (pathSupportOfPoint k z)) = z := by
  rw [negativeBitsCube_joined]
  funext i
  obtain ⟨j,rfl⟩ := (logicalIndex k).surjective i
  cases j with
  | inl j => simpa only [logicalIndex, costCubeJoin_inl] using (hz j).symm
  | inr j =>
    simp only [logicalIndex, costCubeJoin_inr]
    cases h : z (logicalIndex k (.inr j)) <;>
      simp [negativeBitsCube, pathSupportOfPoint, logicalIndex] at h ⊢

theorem weightExpansion_eq_scalarCost (R k : ℕ) (z : ClippingCube (logicalDim k))
    (hz : ∀ i : Fin (prefixDim k), z (logicalIndex k (.inl i)) = false) :
    walshExpansion (weight R k) z / Fintype.card (ClippingCube (logicalDim k)) =
      scalarCost k ((pairDim k * R : ℕ) : ℝ) gammaCost (pathSupportOfPoint k z) := by
  nth_rw 1 [← prefix_point_representation k z hz]
  exact weightExpansion_eq_coefficient R k _

theorem calibration_weightExpansion_abs_bound (R k : ℕ) (hR : 2 ≤ R)
    (endpoint : Bool) (z : ClippingCube (logicalDim k))
    (hz : z ∈ calibrationCoset (fixedCoordinates k) (referencePoint k endpoint)) :
    |walshExpansion (weight R k) z / Fintype.card (ClippingCube (logicalDim k))| ≤
      reluPrefixEnvelope R reluCostSlope k := by
  have hp : 1 ≤ pairDim k := by rw [pairDim_eq]; omega
  have hn : 1 < ((pairDim k * R : ℕ) : ℝ) := by
    exact_mod_cast (show 1 < pairDim k * R by nlinarith)
  rw [weightExpansion_eq_scalarCost R k z (calibration_prefix_bits k endpoint z hz)]
  apply (scalarCost_universal_prefix_bound k _ hn _).trans
  have hP : prefixDim k ≤ pairDim k := by unfold prefixDim; rw [pairDim_eq]; omega
  have h := factorial_prefix_geometric_bound (prefixDim k) (pairDim k) R reluCostSlope
    hp hP (by exact_mod_cast hR) reluCostSlope_pos.le
  simpa only [Nat.cast_mul, reluPrefixEnvelope] using h

theorem weightExpansion_nonconstant_neg (R k : ℕ) (hR : 2 ≤ R)
    (z : ClippingCube (logicalDim k)) (hz : z ≠ cubeOne (logicalDim k)) :
    walshExpansion (weight R k) z / Fintype.card (ClippingCube (logicalDim k)) < 0 := by
  obtain ⟨S,rfl⟩ := (negativeBitsEquiv (logicalDim k)).surjective z
  have hS : S ≠ ∅ := by
    intro h
    apply hz
    funext i
    simp [negativeBitsEquiv, negativeBitsCube, h, cubeOne]
  have hp : 1 ≤ pairDim k := by rw [pairDim_eq]; omega
  have hn : 1 < ((pairDim k * R : ℕ) : ℝ) := by
    exact_mod_cast (show 1 < pairDim k * R by nlinarith)
  change walshExpansion (weight R k) (negativeBitsCube S) / _ < 0
  rw [weightExpansion_eq_coefficient]
  exact actual_family_cost_nonconstant_neg k _ hn S hS

theorem calibration_weightExpansion_neg (R k : ℕ) (hR : 2 ≤ R)
    (endpoint : Bool) (z : ClippingCube (logicalDim k))
    (hz : z ∈ calibrationCoset (fixedCoordinates k) (referencePoint k endpoint)) :
    walshExpansion (weight R k) z / Fintype.card (ClippingCube (logicalDim k)) < 0 := by
  apply weightExpansion_nonconstant_neg R k hR z
  intro he
  have h := calibration_prefix_bits k endpoint z hz ⟨0, by unfold prefixDim; omega⟩
  rw [he] at h
  simp [cubeOne] at h

theorem candidateCost_eq_actualWeightExpansion (R k : ℕ) (hk : 1 ≤ k)
    (endpoint : Bool) (digits : Fin (k-1) → Bool) :
    candidateCost k hk ((pairDim k * R : ℕ) : ℝ) gammaCost endpoint digits =
      walshExpansion (weight R k) (candidatePoint k hk endpoint digits) /
        Fintype.card (ClippingCube (logicalDim k)) := by
  rw [weight_eq_subsetWeight]
  exact candidateCost_eq_weightExpansion k hk _ gammaCost endpoint digits

theorem candidate_weightExpansion_injective (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k)
    (endpoint : Bool) :
    Function.Injective (fun digits : Fin (k-1) → Bool =>
      walshExpansion (weight R k) (candidatePoint k (by omega) endpoint digits) /
        Fintype.card (ClippingCube (logicalDim k))) := by
  have hp : 1 ≤ pairDim k := by rw [pairDim_eq]; omega
  have hn : 1 < ((pairDim k * R : ℕ) : ℝ) := by
    exact_mod_cast (show 1 < pairDim k * R by nlinarith)
  simpa only [← candidateCost_eq_actualWeightExpansion] using
    candidateCost_injective k hk _ hn endpoint

theorem candidate_weightExpansion_injOn (R k : ℕ) (hR : 2 ≤ R) (hk : 3 ≤ k)
    (endpoint : Bool) :
    Set.InjOn (fun z => walshExpansion (weight R k) z /
      Fintype.card (ClippingCube (logicalDim k)))
      (Set.range (candidatePoint k (by omega) endpoint)) := by
  rintro _ ⟨xs,rfl⟩ _ ⟨ys,rfl⟩ h
  exact congrArg (candidatePoint k (by omega) endpoint)
    (candidate_weightExpansion_injective R k hR hk endpoint h)

end NeuralGeneralization.OnlineLowerRelu.Family
