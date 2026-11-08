import NeuralGeneralization.OnlineLowerTanhPathOrder
import NeuralGeneralization.OnlineLowerMixedDifference
import NeuralGeneralization.OnlineLowerCostFixedFamily

/-! # Finite shift transfer for the triangular path

The two-step cancellation acts on arbitrary scalar functions. It is a
finite identity, and uses no integral representation of those functions.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower

def scalarShift (a : ℝ) (f : ℝ → ℝ) : ℝ → ℝ := fun x => f (x+a)

@[simp] theorem scalarShift_apply (a : ℝ) (f : ℝ → ℝ) (x : ℝ) :
    scalarShift a f x = f (x+a) := rfl

theorem scalarShift_comm (a b : ℝ) (f : ℝ → ℝ) :
    scalarShift a (scalarShift b f) = scalarShift b (scalarShift a f) := by
  ext x
  simp only [scalarShift]
  congr 1
  ring

theorem scalarShift_mixedBackwardDifference (a : ℝ) (hs : List ℝ) (f : ℝ → ℝ) :
    scalarShift a (mixedBackwardDifference hs f) =
      mixedBackwardDifference hs (scalarShift a f) := by
  induction hs with
  | nil => rfl
  | cons h hs ih =>
    ext x
    change mixedBackwardDifference hs f (x+a) - mixedBackwardDifference hs f (x+a+h) =
      mixedBackwardDifference hs (scalarShift a f) x -
      mixedBackwardDifference hs (scalarShift a f) (x+h)
    rw [← ih]
    simp only [scalarShift]
    congr 2
    ring

theorem mixedBackwardDifference_add (hs : List ℝ) (f g : ℝ → ℝ) :
    mixedBackwardDifference hs (fun x => f x + g x) =
      fun x => mixedBackwardDifference hs f x + mixedBackwardDifference hs g x := by
  induction hs with
  | nil => rfl
  | cons h hs ih => ext x; simp only [mixedBackwardDifference, ih]; ring

theorem mixedBackwardDifference_mul (hs : List ℝ) (c : ℝ) (f : ℝ → ℝ) :
    mixedBackwardDifference hs (fun x => c*f x) =
      fun x => c*mixedBackwardDifference hs f x := by
  induction hs with
  | nil => rfl
  | cons h hs ih => ext x; simp only [mixedBackwardDifference, ih]; ring

def scalarPathStep (edge : ℝ) (v : Bool) (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    (ℝ → ℝ) × (ℝ → ℝ) :=
  (fun x => z.1 x + z.2 (x+edge),
   fun x => (if v then (-1 : ℝ) else 1) * (z.1 (x+4+edge) + z.2 (x+4)))

def scalarPathBlock (v : Bool) (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    (ℝ → ℝ) × (ℝ → ℝ) := scalarPathStep 6 v (scalarPathStep 2 true z)

def triangularShiftBlock (v : Bool) (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    (ℝ → ℝ) × (ℝ → ℝ) :=
  (fun x => tripleShift 4 z.1 x + z.2 (x+2) + z.2 (x+6),
   fun x => digitSign v * z.2 (x+8))

def pairDifference (hs : List ℝ) (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    (ℝ → ℝ) × (ℝ → ℝ) :=
  (mixedBackwardDifference hs z.1, mixedBackwardDifference hs z.2)

/-- Cancellation of a six/two edge block with its fixed middle syndrome.
Every block contributes one genuine fourth-step backward difference. -/
theorem scalarPathBlock_cancel (v : Bool) (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    scalarPathBlock v z = pairDifference [4] (triangularShiftBlock v z) := by
  cases v <;> apply Prod.ext <;> ext x <;>
    simp only [scalarPathBlock, scalarPathStep, triangularShiftBlock,
      pairDifference, mixedBackwardDifference, tripleShift, digitSign,
      Bool.false_eq_true, if_false, if_true]
  all_goals norm_num <;> ring_nf

theorem triangularShiftBlock_difference (v : Bool) (hs : List ℝ)
    (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    triangularShiftBlock v (pairDifference hs z) =
      pairDifference hs (triangularShiftBlock v z) := by
  apply Prod.ext
  · simp only [triangularShiftBlock, pairDifference, tripleShift]
    norm_num
    change (fun x => mixedBackwardDifference hs z.1 x +
        scalarShift 4 (mixedBackwardDifference hs z.1) x +
        scalarShift 8 (mixedBackwardDifference hs z.1) x +
        scalarShift 2 (mixedBackwardDifference hs z.2) x +
        scalarShift 6 (mixedBackwardDifference hs z.2) x) = _
    simp_rw [scalarShift_mixedBackwardDifference]
    simp only [mixedBackwardDifference_add, scalarShift]
    rfl
  · change (fun x => digitSign v * scalarShift 8 (mixedBackwardDifference hs z.2) x) = _
    rw [scalarShift_mixedBackwardDifference]
    simp only [pairDifference, triangularShiftBlock, mixedBackwardDifference_mul, scalarShift]
    rfl

def scalarPathBlocks : List Bool → ((ℝ → ℝ) × (ℝ → ℝ)) → ((ℝ → ℝ) × (ℝ → ℝ))
  | [], z => z
  | v::vs, z => scalarPathBlock v (scalarPathBlocks vs z)

def triangularShiftBlocks : List Bool → ((ℝ → ℝ) × (ℝ → ℝ)) → ((ℝ → ℝ) × (ℝ → ℝ))
  | [], z => z
  | v::vs, z => triangularShiftBlock v (triangularShiftBlocks vs z)

theorem scalarPathBlocks_cancel (vs : List Bool) (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    scalarPathBlocks vs z =
      pairDifference (List.replicate vs.length 4) (triangularShiftBlocks vs z) := by
  induction vs with
  | nil => rfl
  | cons v vs ih =>
    rw [scalarPathBlocks, ih, scalarPathBlock_cancel, triangularShiftBlock_difference]
    rfl

end NeuralGeneralization.OnlineLowerTanh
