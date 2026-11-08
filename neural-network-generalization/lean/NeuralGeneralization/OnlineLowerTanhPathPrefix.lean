import NeuralGeneralization.OnlineLowerTanhPathWalsh
import NeuralGeneralization.OnlineLowerCostPrefix
import NeuralGeneralization.OnlineLowerGeometryProjection

/-! # Prefix extraction by actual fourth-step backward differences -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerGeometry

theorem prefixDegree_cons (P : ℕ) (b : Bool) (s : ClippingCube P) :
    prefixDegree (P+1) (Fin.cons b s) = 2*(1-cubeCoordinateSign b)+prefixDegree P s := by
  simp [prefixDegree, Fin.sum_univ_succ]

theorem prefixParity_cons (P : ℕ) (b : Bool) (s : ClippingCube P) :
    prefixParity (P+1) (Fin.cons b s) = cubeCoordinateSign b*prefixParity P s := by
  simp [prefixParity, Fin.prod_univ_succ]

/-- The compulsory all-negative prefix extracts the exact high-order
backward difference of every scalar profile. -/
theorem prefix_sum_eq_difference (P : ℕ) (cost : ℝ → ℝ) (n : ℝ) :
    (∑ s : ClippingCube P, prefixParity P s * cost (n+prefixDegree P s)) =
      mixedBackwardDifference (List.replicate P 4) cost n := by
  induction P generalizing n with
  | zero => simp [prefixParity, prefixDegree, mixedBackwardDifference, ClippingCube]
  | succ P ih =>
    rw [sum_bool_tuple_succ]
    simp only [prefixParity_cons, prefixDegree_cons, cubeCoordinateSign,
      Bool.false_eq_true, if_false, if_true]
    norm_num
    simp_rw [show ∀ x : ℝ, n+(4+x)=(n+4)+x by intro x; ring]
    rw [ih, ih]
    simp only [List.replicate_succ, mixedBackwardDifference]
    ring

theorem mixedBackwardDifference_append (hs ks : List ℝ) (f : ℝ → ℝ) :
    mixedBackwardDifference (hs++ks) f =
      mixedBackwardDifference hs (mixedBackwardDifference ks f) := by
  induction hs with
  | nil => rfl
  | cons h hs ih => ext x; simp only [List.cons_append, mixedBackwardDifference, ih]

theorem mixedBackwardDifference_replicate_add (P k : ℕ) (f : ℝ → ℝ) :
    mixedBackwardDifference (List.replicate k 4)
      (mixedBackwardDifference (List.replicate P 4) f) =
      mixedBackwardDifference (List.replicate (P+k) 4) f := by
  rw [← mixedBackwardDifference_append, ← List.replicate_add, Nat.add_comm k P]

theorem walshCoefficients_mixedDifference {m : ℕ} (hs : List ℝ)
    (F : ℝ → ClippingCube m → ℝ) (T : Finset (Fin m)) (n : ℝ) :
    mixedBackwardDifference hs (fun x => walshCoefficients (F x) T) n =
      walshCoefficients (fun z => mixedBackwardDifference hs (fun x => F x z) n) T := by
  induction hs generalizing n with
  | nil => rfl
  | cons h hs ih =>
    simp only [mixedBackwardDifference]
    rw [ih, ih, ← walshCoefficients_sub]

theorem fixedPathDegree_baseline (n : ℝ) (V : ℕ) (s : ClippingCube (V+1)) :
    fixedPathDegree n V s = n + fixedPathDegree 0 V s := by
  simp [fixedPathDegree, columnDegree]

theorem fixedPathCost_mixedDifference (hs : List ℝ) (cost : ℝ → ℝ)
    (vs : List Bool) (terminal : Bool) (n : ℝ) :
    mixedBackwardDifference hs (fun x => fixedPathCost x cost vs terminal) n =
      fixedPathCost n (mixedBackwardDifference hs cost) vs terminal := by
  unfold fixedPathCost
  rw [walshCoefficients_mixedDifference]
  congr 1
  funext s
  have he : (fun x => cost (fixedPathDegree x (2*vs.length) s)) =
      scalarShift (fixedPathDegree 0 (2*vs.length) s) cost := by
    funext x
    exact congrArg cost (fixedPathDegree_baseline x (2*vs.length) s)
  rw [he, fixedPathDegree_baseline n (2*vs.length) s]
  exact congrFun (scalarShift_mixedBackwardDifference (fixedPathDegree 0 (2*vs.length) s) hs cost).symm n

theorem prefixedCandidateCost_eq_difference (P : ℕ) (cost : ℝ → ℝ)
    (endpoint : Bool) (digits : List Bool) (n : ℝ) :
    prefixedCandidateCost P n cost endpoint digits =
      fixedCandidateCost n (mixedBackwardDifference (List.replicate P 4) cost)
        endpoint digits / (2 : ℝ)^P := by
  unfold prefixedCandidateCost fixedCandidateCost
  rw [prefix_sum_eq_difference P (fun x => fixedPathCost x cost
    (fixedParityBlocks endpoint digits) false) n, fixedPathCost_mixedDifference]

theorem triangularShiftBlocks_difference (vs : List Bool) (hs : List ℝ)
    (z : (ℝ → ℝ) × (ℝ → ℝ)) :
    triangularShiftBlocks vs (pairDifference hs z) =
      pairDifference hs (triangularShiftBlocks vs z) := by
  induction vs with
  | nil => rfl
  | cons v vs ih =>
    rw [triangularShiftBlocks, ih, triangularShiftBlock_difference]
    rfl

theorem fixedPathCost_eq_triangular_differences (vs : List Bool) (cost : ℝ → ℝ) (n : ℝ) :
    let f := mixedBackwardDifference (List.replicate vs.length 4) cost
    fixedPathCost n cost vs false =
      ((triangularShiftBlocks vs (f, scalarShift 4 f)).1 n +
        (triangularShiftBlocks vs (f, scalarShift 4 f)).2 n) / (2 : ℝ)^(2*vs.length+1) := by
  dsimp only
  rw [fixedPathCost_eq_shift_transfer, scalarPathBlocks_cancel,
    ← triangularShiftBlocks_difference]
  simp only [pairDifference, scalarShift_mixedBackwardDifference]

/-- Complete finite prefix/path cancellation, at the actual scalar cost.
The remaining triangular digit formula acts on one positive decreasing
profile supplied by the scalar mixed-difference theorem. -/
theorem prefixedCandidateCost_eq_triangular (P : ℕ) (cost : ℝ → ℝ)
    (endpoint : Bool) (digits : List Bool) (n : ℝ) :
    let vs := fixedParityBlocks endpoint digits
    let f := mixedBackwardDifference (List.replicate (P+vs.length) 4) cost
    prefixedCandidateCost P n cost endpoint digits =
      ((triangularShiftBlocks vs (f, scalarShift 4 f)).1 n +
        (triangularShiftBlocks vs (f, scalarShift 4 f)).2 n) /
          (2 : ℝ)^(P+2*vs.length+1) := by
  dsimp only
  rw [prefixedCandidateCost_eq_difference, fixedCandidateCost,
    fixedPathCost_eq_triangular_differences]
  rw [mixedBackwardDifference_replicate_add, div_div, ← pow_add]
  congr 1
  congr 1
  omega

end NeuralGeneralization.OnlineLowerTanh
