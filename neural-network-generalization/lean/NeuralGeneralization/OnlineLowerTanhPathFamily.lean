import NeuralGeneralization.OnlineLowerTanhDegree
import NeuralGeneralization.OnlineLowerTanhGeometryProtocol
import NeuralGeneralization.OnlineLowerCostCombined

/-! # Actual rectangle costs as shifted prefix/path costs

This finite identity applies to every scalar cost function. In particular it
requires neither an inverse Laplace transform nor any sign assumption.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

def scalarSupportWeight (R H k : ℕ) (cost : ℝ → ℝ)
    (s : Finset (Fin (logicalDim k))) : ℝ :=
  cost (carrierSupport (size R H k) (column R H k) s).card

theorem scalarSupportWeight_eq_column (R H k : ℕ) (cost : ℝ → ℝ)
    (s : Finset (Fin (logicalDim k))) :
    scalarSupportWeight R H k cost s =
      cost (columnDegree ((pairDim R H k : ℝ)*R+1) (column R H k)
        (fun i => (increment R H k i : ℝ)) (negativeBitsCube s)) := by
  unfold scalarSupportWeight
  rw [support_card_eq_columnDegree]

theorem scalarSupportWeight_transform (R H k : ℕ) (cost : ℝ → ℝ)
    (S : Finset (Fin (logicalDim k))) :
    rectangleWeightTransform (scalarSupportWeight R H k cost) (negativeBitsCube S) =
      walshCoefficients (fun x => cost (columnDegree ((pairDim R H k : ℝ)*R+1)
        (column R H k) (fun i => (increment R H k i : ℝ)) x)) S := by
  unfold rectangleWeightTransform walshExpansion
  simp_rw [scalarSupportWeight_eq_column]
  exact subset_weight_fourier_eq (fun x => cost
    (columnDegree ((pairDim R H k : ℝ)*R+1) (column R H k)
      (fun i => (increment R H k i : ℝ)) x)) S

def joinSupport (k : ℕ) (T : Finset (Fin (OldDim k))) (b : Bool) :
    Finset (Fin (logicalDim k)) :=
  Finset.univ.filter fun i => match (logicalIndex k).symm i with
    | .inl j => j ∈ T
    | .inr _ => b = true

theorem joinSupport_character (k : ℕ) (T : Finset (Fin (OldDim k))) (b : Bool)
    (z : ClippingCube (OldDim k)) (a : ClippingCube 2) :
    walshCharacter (joinSupport k T b) (joinPoint k z a) =
      walshCharacter T z * (if b then ∏ i, cubeCoordinateSign (a i) else 1) := by
  unfold walshCharacter joinSupport
  rw [Finset.prod_filter, ← (logicalIndex k).prod_comp, Fintype.prod_sum_type]
  simp only [Equiv.symm_apply_apply, joinPoint_old, joinPoint_distinguished]
  cases b <;> simp [joinPoint, oldLogical, logicalIndex]

theorem negativeBitsCube_joinSupport (k : ℕ) (T : Finset (Fin (OldDim k))) (b : Bool) :
    negativeBitsCube (joinSupport k T b) = extendPoint k (negativeBitsCube T) (!b) := by
  ext i
  obtain ⟨i, rfl⟩ := (logicalIndex k).surjective i
  cases i <;> cases b <;>
    simp [negativeBitsCube, joinSupport, extendPoint, joinPoint, oldLogical]

theorem shiftPoint_extendPoint (k : ℕ) (z : ClippingCube (OldDim k)) (b : Bool) :
    cubeTranslation (shiftPoint k) (extendPoint k z b) = extendPoint k z (!b) := by
  ext i
  obtain ⟨i, rfl⟩ := (logicalIndex k).surjective i
  cases i with
  | inl i => simp [shiftPoint, extendPoint, joinPoint, cubeTranslation, cubeOne]
  | inr i => cases b <;> simp [shiftPoint, extendPoint, joinPoint, cubeTranslation]

def joinPointEquiv (k : ℕ) :
    ClippingCube (OldDim k) × ClippingCube 2 ≃ ClippingCube (logicalDim k) where
  toFun z := joinPoint k z.1 z.2
  invFun z := (oldPoint k z, distinguishedPoint k z)
  left_inv z := by simp
  right_inv := joinPoint_parts k

theorem columnDegree_joinPoint (R H k : ℕ) (n₀ : ℝ)
    (z : ClippingCube (OldDim k)) (a : ClippingCube 2) :
    columnDegree n₀ (column R H k) (fun i => (increment R H k i : ℝ))
      (joinPoint k z a) =
      columnDegree n₀ (OnlineLowerRelu.Family.column k)
        (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z +
      (H : ℝ)/2*(1-cubeCoordinateSign (a 0)) +
      (H : ℝ)/2*(1-cubeCoordinateSign (a 1)) := by
  rw [columnDegree_effective]
  have hold : oldInput (joinPoint k z a) = z := by ext i; simp [oldInput]
  rw [hold]
  simp [Fin.sum_univ_two]
  ring

theorem distinguished_pair_sum (cost : ℝ → ℝ) (x H c : ℝ) :
    (∑ a : ClippingCube 2,
      cost (x + H/2*(1-cubeCoordinateSign (a 0)) +
        H/2*(1-cubeCoordinateSign (a 1))) *
      (c * (∏ i, cubeCoordinateSign (a i)) - c)) = -4*c*cost (x+H) := by
  rw [sum_bool_tuple_succ]
  rw [sum_bool_tuple_succ, sum_bool_tuple_succ]
  simp [Fin.prod_univ_two, cubeCoordinateSign]
  ring

/-- Eliminating the two distinguished loops gives exactly one negative
copy of the old Fourier coefficient, evaluated at the shifted baseline. -/
theorem rectangle_scalarSupportWeight_eq (R H k : ℕ) (cost : ℝ → ℝ)
    (T : Finset (Fin (OldDim k))) :
    rectangleEffectiveCost (scalarSupportWeight R H k cost) (shiftPoint k)
      (extendPoint k (negativeBitsCube T) false) =
      -walshCoefficients (fun z => cost
        (columnDegree ((pairDim R H k : ℝ)*R+1+H) (OnlineLowerRelu.Family.column k)
          (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z)) T := by
  rw [rectangleEffectiveCost, sub_div, shiftPoint_extendPoint]
  change rectangleWeightTransform _ (extendPoint k (negativeBitsCube T) false) -
    rectangleWeightTransform _ (extendPoint k (negativeBitsCube T) true) = _
  have ht := negativeBitsCube_joinSupport k T true
  have hf := negativeBitsCube_joinSupport k T false
  simp only [Bool.not_true] at ht
  simp only [Bool.not_false] at hf
  rw [← ht, ← hf,
    scalarSupportWeight_transform, scalarSupportWeight_transform]
  unfold walshCoefficients uniformCubeMean
  rw [← sub_div, ← Finset.sum_sub_distrib]
  rw [← (joinPointEquiv k).sum_comp, Fintype.sum_prod_type]
  simp only [joinPointEquiv, Equiv.coe_fn_mk, joinSupport_character,
    if_true, Bool.false_eq_true, if_false, mul_one, columnDegree_joinPoint]
  have hterm (z : ClippingCube (OldDim k)) :
      (∑ a : ClippingCube 2,
        (cost (columnDegree ((pairDim R H k : ℝ)*R+1) (OnlineLowerRelu.Family.column k)
          (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z +
          H/2*(1-cubeCoordinateSign (a 0)) + H/2*(1-cubeCoordinateSign (a 1))) *
          (walshCharacter T z * ∏ i, cubeCoordinateSign (a i)) -
        cost (columnDegree ((pairDim R H k : ℝ)*R+1) (OnlineLowerRelu.Family.column k)
          (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z +
          H/2*(1-cubeCoordinateSign (a 0)) + H/2*(1-cubeCoordinateSign (a 1))) *
          walshCharacter T z)) =
      -4 * (cost (columnDegree ((pairDim R H k : ℝ)*R+1+H)
        (OnlineLowerRelu.Family.column k)
        (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z) * walshCharacter T z) := by
    simp_rw [← mul_sub]
    rw [distinguished_pair_sum]
    have he : columnDegree ((pairDim R H k : ℝ)*R+1) (OnlineLowerRelu.Family.column k)
        (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z + H =
      columnDegree ((pairDim R H k : ℝ)*R+1+H) (OnlineLowerRelu.Family.column k)
        (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z := by
      unfold columnDegree
      ring
    rw [he]
    ring
  simp_rw [hterm]
  rw [← Finset.mul_sum]
  have hcard : (Fintype.card (ClippingCube (logicalDim k)) : ℝ) =
      4 * (Fintype.card (ClippingCube (OldDim k)) : ℝ) := by
    simp [ClippingCube, logicalDim, OldDim, pow_add]
    ring
  rw [hcard]
  ring

/-- The actual candidate rectangle cost is the negative of the already
defined literal prefix/path cost, with the common distinguished shift. -/
theorem candidate_rectangle_scalarSupportWeight_eq (R H k : ℕ) (hk : 1 ≤ k)
    (cost : ℝ → ℝ) (endpoint : Bool) (digits : CandidateDigits k) :
    rectangleEffectiveCost (scalarSupportWeight R H k cost) (shiftPoint k)
      (candidatePoint k hk endpoint digits) =
      -FamilyCost.candidateCost k hk ((pairDim R H k : ℝ)*R+1+H) cost endpoint digits := by
  exact rectangle_scalarSupportWeight_eq R H k cost _

end NeuralGeneralization.OnlineLowerTanh.Family
