import NeuralGeneralization.OnlineLowerCircuits
import NeuralGeneralization.OnlineLowerReluRailCode

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLower
open BatchTwoCircuitConverse OnlineLowerRelu

/-- The literal target used by an affine parity code. -/
def physicalParityTarget {d m : ℕ} (base : Finset (Fin d))
    (column : Fin d → Finset (Fin m)) : ConcreteModel.Cube d → Bool :=
  parityAndTarget base (fun i => generatedSupport base (coordinateGenerator column) {i})

/-- Both complexity witnesses are explicit constructions. Private singleton
columns and weight-at-most-two physical columns are the combinatorial data. -/
theorem physicalParityTarget_resources {d m K : ℕ}
    (base : Finset (Fin d)) (column : Fin d → Finset (Fin m))
    (privateCoord : Fin m → Fin d)
    (hprivate : ∀ i, column (privateCoord i) = {i})
    (hcolumn : ∀ j, (column j).card ≤ 2)
    (hm : 1 ≤ m) (hd : d ≤ K*m) :
    BoundedTeacher relu (physicalParityTarget base column) (teacherWidth d m) ∧
    HasCircuitAtMost (physicalParityTarget base column) (17*d+5) ∧
    teacherWidth d m ≤ 6*(K+1)*m^2 := by
  apply parityAnd_concrete_resources base
    (fun i => generatedSupport base (coordinateGenerator column) {i})
    (coordinateGenerator column)
  · intro i x
    rw [generatedSupport_character]
    simp [walshCharacter,generatedSyndrome_sign]
  · exact hm
  · exact privateColumn_dimension_le column privateCoord hprivate
  · exact hd
  · exact coordinateGenerator_card_sum_le column hcolumn


theorem labelReal_decide_walsh {d : ℕ} (S : Finset (Fin d)) (x : ConcreteModel.Cube d) :
    ConcreteModel.labelReal (decide (walshCharacter S x=1)) = walshCharacter S x := by
  by_cases h:walshCharacter S x=1
  · simp [h,ConcreteModel.labelReal]
  · have hs := walshCharacter_sq S x
    have hp : (walshCharacter S x-1)*(walshCharacter S x+1)=0 := by nlinarith
    rcases mul_eq_zero.mp hp with hp | hp
    · exact (h (by linarith)).elim
    · have hn : walshCharacter S x = -1 := by linarith
      norm_num [hn,ConcreteModel.labelReal]

/-- The teacher target is exactly the base parity times the logical AND sign. -/
theorem physicalParityTarget_label {d m : ℕ} (base : Finset (Fin d))
    (column : Fin d → Finset (Fin m)) (x : ConcreteModel.Cube d) :
    ConcreteModel.labelReal (physicalParityTarget base column x) =
      walshCharacter base x *
        (if generatedSyndrome (coordinateGenerator column) x = (fun _ => true) then (1:ℝ) else -1) := by
  have hchar (i) (x) : walshCharacter (generatedSupport base (coordinateGenerator column) {i}) x =
      walshCharacter base x*walshCharacter (coordinateGenerator column i) x := by
    rw [generatedSupport_character]
    simp [walshCharacter,generatedSyndrome_sign]
  unfold physicalParityTarget
  rw [parityAndTarget_xnor _ _ _ hchar,labelReal_xnor,labelReal_decide_walsh]
  have he : (∀ i,walshCharacter (coordinateGenerator column i) x=1) ↔
      generatedSyndrome (coordinateGenerator column) x = (fun _ => true) := by
    simp [funext_iff,generatedSyndrome]
  simp only [ConcreteModel.labelReal,decide_eq_true_eq,he]

end NeuralGeneralization.OnlineLower
