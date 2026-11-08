import NeuralGeneralization.OnlineLowerTanhFamily
import NeuralGeneralization.OnlineLowerCostRailBridge

/-! # Exact degree of the physical tanh support and effective loop splitting -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerRelu ConcreteModel

/-- The scalar degree is the actual number of physical coordinates,
including the shared carrier. -/
theorem support_card_eq_columnDegree (R H k : ℕ) (s : Finset (Fin (logicalDim k))) :
    ((carrierSupport (size R H k) (column R H k) s).card : ℝ) =
      columnDegree ((pairDim R H k:ℝ)*R+1) (column R H k)
        (fun i => (increment R H k i:ℝ)) (negativeBitsCube s) := by
  rw [carrierSupport_card, columnDegree_railOrientation]
  push_cast
  have he (i : Fin (pairDim R H k)) :
      (size R H k i (railOrientation (column R H k) s i):ℝ) =
        R + (if railOrientation (column R H k) s i then (increment R H k i:ℝ) else 0) := by
    cases railOrientation (column R H k) s i <;> simp
  simp_rw [he]
  rw [Finset.sum_add_distrib]
  simp
  ring

def oldInput {k : ℕ} (x : ClippingCube (logicalDim k)) :
    ClippingCube (OnlineLowerRelu.Family.logicalDim k) := fun i => x (oldLogical k i)

theorem walsh_oldLogical {k : ℕ} (s : Finset (Fin (OnlineLowerRelu.Family.logicalDim k)))
    (x : ClippingCube (logicalDim k)) :
    walshCharacter (s.map (oldLogical k)) x = walshCharacter s (oldInput x) := by
  simp [walshCharacter,oldInput]

/-- Repeating a distinguished column preserves exactly its effective
increment H; this is an equality of the actual degree functions. -/
theorem columnDegree_effective (R H k : ℕ) (n0 : ℝ) (x : ClippingCube (logicalDim k)) :
    columnDegree n0 (column R H k) (fun i => (increment R H k i:ℝ)) x =
      columnDegree n0 (OnlineLowerRelu.Family.column k)
        (fun i => (OnlineLowerRelu.Family.increment k i:ℝ)) (oldInput x) +
      ∑ b : Fin 2, (H:ℝ)/2*(1-cubeCoordinateSign (x (logicalIndex k (.inr b)))) := by
  unfold columnDegree
  rw [← (pairIndex R H k).sum_comp]
  rw [Fintype.sum_sum_type,Fintype.sum_prod_type]
  simp only [column_old,column_distinguished,increment_old,increment_distinguished]
  simp_rw [walsh_oldLogical]
  simp only [walshCharacter,Finset.prod_singleton]
  have he (b : Fin 2) :
      (∑ j : Fin (splitCount H R), (splitIncrement H R j:ℝ)/2 *
        (1-cubeCoordinateSign (x (logicalIndex k (.inr b))))) =
      (H:ℝ)/2*(1-cubeCoordinateSign (x (logicalIndex k (.inr b)))) := by
    rw [←Finset.sum_mul, ←Finset.sum_div, ←Nat.cast_sum, splitIncrement_sum]
  simp_rw [he]
  ring

end NeuralGeneralization.OnlineLowerTanh.Family
