import NeuralGeneralization.OnlineLowerTanhPathShift

/-! # Literal Walsh sums and the finite path shift transfer -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower

def pathCostDegree (n : ℝ) (data : List (Bool × ℝ))
    (s : ClippingCube (data.length+1)) : ℝ :=
  columnDegree n (pathColumn data.length)
    (pathColumnIncrement 4 (fun j => (data.get j).2)) s

theorem pathCostDegree_cons (n : ℝ) (v : Bool) (e : ℝ) (data : List (Bool × ℝ))
    (s : ClippingCube (((v,e)::data).length+1)) :
    pathCostDegree n ((v,e)::data) s =
      pathCostDegree (n + 2*(1-cubeCoordinateSign (s 0)) +
        e/2*(1-cubeCoordinateSign (s 0)*cubeCoordinateSign (s 1)))
        data (fun i => s i.succ) := by
  unfold pathCostDegree columnDegree
  rw [Fintype.sum_sum_type, Fintype.sum_sum_type]
  simp only [pathColumnIncrement, walshCharacter_pathColumn_loop,
    walshCharacter_pathColumn_edge]
  simp only [List.length_cons, Fin.sum_univ_succ, List.get_eq_getElem,
    Fin.val_zero, Fin.val_succ, List.getElem_cons_zero, List.getElem_cons_succ,
    Fin.castSucc_zero, Fin.castSucc_succ]
  have he : (Fin.succ (0 : Fin (data.length+1))) = (1 : Fin (data.length+1+1)) := rfl
  rw [he]
  ring

theorem pathCostDegree_nil (n : ℝ) (s : ClippingCube 1) :
    pathCostDegree n [] s = n+2*(1-cubeCoordinateSign (s 0)) := by
  norm_num [pathCostDegree, columnDegree, Fintype.sum_sum_type, pathColumnIncrement,
    walshCharacter_pathColumn_loop, Fin.sum_univ_one]
  ring_nf
  exact Fin.sum_univ_one _

theorem pathSyndromeSupport_character_cons (v : Bool) (e : ℝ)
    (data : List (Bool × ℝ)) (terminal b : Bool) (tail : ClippingCube (data.length+1)) :
    walshCharacter (pathSyndromeSupport ((v,e)::data) terminal) (Fin.cons b tail) =
      (if v then cubeCoordinateSign b else 1) *
        walshCharacter (pathSyndromeSupport data terminal) tail := by
  unfold walshCharacter pathSyndromeSupport
  rw [Finset.prod_filter, Finset.prod_filter]
  simp only [List.length_cons, Fin.prod_univ_succ, pathSyndrome,
    Fin.cons_zero, Fin.cons_succ]

def partialPathCost (cost : ℝ → ℝ) (data : List (Bool × ℝ))
    (terminal b : Bool) (n : ℝ) : ℝ :=
  ∑ tail : ClippingCube data.length,
    cost (pathCostDegree n data (Fin.cons b tail)) *
      walshCharacter (pathSyndromeSupport data terminal) (Fin.cons b tail)

theorem partialPathCost_cons (cost : ℝ → ℝ) (v : Bool) (e : ℝ)
    (data : List (Bool × ℝ)) (terminal b : Bool) (n : ℝ) :
    partialPathCost cost ((v,e)::data) terminal b n =
      (if v then cubeCoordinateSign b else 1) *
        (partialPathCost cost data terminal false
            (n+2*(1-cubeCoordinateSign b)+e/2*(1+cubeCoordinateSign b)) +
          partialPathCost cost data terminal true
            (n+2*(1-cubeCoordinateSign b)+e/2*(1-cubeCoordinateSign b))) := by
  unfold partialPathCost
  simp only [List.length_cons]
  rw [sum_bool_tuple_succ]
  simp only [pathCostDegree_cons, Fin.cons_zero, Fin.cons_succ, Fin.cons_one,
    pathSyndromeSupport_character_cons, cubeCoordinateSign,
    Bool.false_eq_true, if_false, if_true]
  rw [mul_add, Finset.mul_sum, Finset.mul_sum]
  congr 1 <;> apply Finset.sum_congr rfl <;> intro s hs <;>
    ring_nf

def scalarPathMessage (cost : ℝ → ℝ) : List (Bool × ℝ) → Bool →
    ((ℝ → ℝ) × (ℝ → ℝ))
  | [], terminal => (cost, fun n => (if terminal then -1 else 1)*cost (n+4))
  | (v,e)::data, terminal => scalarPathStep e v (scalarPathMessage cost data terminal)

theorem pathSyndromeSupport_nil (terminal : Bool) :
    pathSyndromeSupport [] terminal = if terminal then ({0} : Finset (Fin 1)) else ∅ := by
  cases terminal <;> ext i <;> fin_cases i <;>
    simp [pathSyndromeSupport, pathSyndrome]

theorem scalarPathMessage_partial (cost : ℝ → ℝ) (data : List (Bool × ℝ))
    (terminal : Bool) (n : ℝ) :
    (scalarPathMessage cost data terminal).1 n = partialPathCost cost data terminal true n ∧
      (scalarPathMessage cost data terminal).2 n = partialPathCost cost data terminal false n := by
  induction data generalizing n with
  | nil =>
    cases terminal <;>
      norm_num [scalarPathMessage, partialPathCost, pathCostDegree_nil, pathSyndromeSupport_nil,
        walshCharacter, cubeCoordinateSign, ClippingCube]
  | cons ve data ih =>
    obtain ⟨v,e⟩ := ve
    constructor
    · rw [partialPathCost_cons]
      simp only [scalarPathMessage, scalarPathStep]
      rw [(ih n).1, (ih (n+e)).2]
      simp [cubeCoordinateSign]
      ring
    · rw [partialPathCost_cons]
      simp only [scalarPathMessage, scalarPathStep]
      rw [(ih (n+4+e)).1, (ih (n+4)).2]
      simp [cubeCoordinateSign]
      ring

theorem pathCostDegree_coefficient (cost : ℝ → ℝ) (data : List (Bool × ℝ))
    (terminal : Bool) (n : ℝ) :
    walshCoefficients (fun s => cost (pathCostDegree n data s))
      (pathSyndromeSupport data terminal) =
      ((scalarPathMessage cost data terminal).1 n +
        (scalarPathMessage cost data terminal).2 n) / (2 : ℝ)^(data.length+1) := by
  unfold walshCoefficients uniformCubeMean
  rw [sum_bool_tuple_succ]
  rw [(scalarPathMessage_partial cost data terminal n).1,
    (scalarPathMessage_partial cost data terminal n).2]
  simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, Nat.cast_pow, Nat.cast_ofNat, partialPathCost]
  rw [add_comm]

def pathIncrementData : List Bool → List (Bool × ℝ)
  | [] => []
  | v::vs => (v,6)::(true,2)::pathIncrementData vs

theorem pathIncrementData_length (vs : List Bool) :
    (pathIncrementData vs).length = 2*vs.length := by
  induction vs with
  | nil => rfl
  | cons v vs ih => simp [pathIncrementData, ih]; omega

theorem pathIncrementData_get (vs : List Bool) (i : ℕ)
    (hi : i < (pathIncrementData vs).length) :
    ((pathIncrementData vs)[i]).2 = if i%2=0 then 6 else 2 := by
  induction vs generalizing i with
  | nil => simp [pathIncrementData] at hi
  | cons v vs ih =>
    cases i with
    | zero => simp [pathIncrementData]
    | succ i =>
      cases i with
      | zero => simp [pathIncrementData]
      | succ i =>
        have hi' : i < (pathIncrementData vs).length := by simpa [pathIncrementData] using hi
        have hm : (i+1+1)%2=i%2 := by omega
        simpa only [pathIncrementData, List.getElem_cons_succ, hm] using ih i hi'

theorem pathCostDegree_incrementData (vs : List Bool) (n : ℝ)
    (s : ClippingCube ((pathIncrementData vs).length+1)) :
    pathCostDegree n (pathIncrementData vs) s =
      fixedPathDegree n (pathIncrementData vs).length s := by
  unfold pathCostDegree fixedPathDegree
  have he : (fun j : Fin (pathIncrementData vs).length => ((pathIncrementData vs).get j).2) =
      alternatingEdgeIncrement := by
    funext j
    exact pathIncrementData_get vs j.val j.isLt
  rw [he]

theorem pathSyndrome_incrementData (vs : List Bool) (terminal : Bool)
    (i : Fin ((pathIncrementData vs).length+1)) :
    pathSyndrome (pathIncrementData vs) terminal i =
      blockSyndrome vs terminal (Fin.cast (by rw [pathIncrementData_length]) i) := by
  induction vs with
  | nil => simp [pathIncrementData, pathSyndrome, blockSyndrome]
  | cons v vs ih =>
    simp only [pathIncrementData, pathSyndrome, blockSyndrome]
    refine Fin.cases ?_ (fun j => ?_) i
    · rfl
    · refine Fin.cases ?_ (fun j => ?_) j
      · rfl
      · exact ih j

theorem pathSyndromeSupport_incrementData (vs : List Bool) (terminal : Bool) :
    (pathSyndromeSupport (pathIncrementData vs) terminal).map
      (costFinCastEmbedding (by rw [pathIncrementData_length])) =
        blockSyndromeSupport vs terminal := by
  ext j
  simp only [Finset.mem_map, pathSyndromeSupport, blockSyndromeSupport,
    Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, hi, rfl⟩
    simpa only [costFinCastEmbedding, Function.Embedding.coeFn_mk,
      ← pathSyndrome_incrementData] using hi
  · intro hj
    let h : (pathIncrementData vs).length+1=2*vs.length+1 := by rw [pathIncrementData_length]
    refine ⟨Fin.cast h.symm j, ?_, ?_⟩
    · rw [pathSyndrome_incrementData]
      simpa using hj
    · apply Fin.ext
      rfl

theorem scalarPathMessage_incrementData (vs : List Bool) (cost : ℝ → ℝ) :
    scalarPathMessage cost (pathIncrementData vs) false =
      scalarPathBlocks vs (cost, scalarShift 4 cost) := by
  induction vs with
  | nil => ext x <;> simp [scalarPathMessage, pathIncrementData, scalarPathBlocks, scalarShift]
  | cons v vs ih =>
    simp only [scalarPathMessage, pathIncrementData, scalarPathBlocks, scalarPathBlock, ih]

/-- The repository's actual path Fourier coefficient is exactly the
finite shift transfer, including its Boolean-cube normalization. -/
theorem fixedPathCost_eq_shift_transfer (vs : List Bool) (cost : ℝ → ℝ) (n : ℝ) :
    fixedPathCost n cost vs false =
      ((scalarPathBlocks vs (cost, scalarShift 4 cost)).1 n +
        (scalarPathBlocks vs (cost, scalarShift 4 cost)).2 n) / (2 : ℝ)^(2*vs.length+1) := by
  have h := pathCostDegree_coefficient cost (pathIncrementData vs) false n
  simp only [pathCostDegree_incrementData, scalarPathMessage_incrementData,
    pathIncrementData_length] at h
  rw [walshCoefficients_cast (by rw [pathIncrementData_length]),
    pathSyndromeSupport_incrementData] at h
  simp_rw [fixedPathDegree_cast n (pathIncrementData_length vs)] at h
  exact h

/-- The full literal Fourier cost has one fourth-step backward difference
for every triangular path block. -/
theorem fixedPathCost_eq_differences (vs : List Bool) (cost : ℝ → ℝ) (n : ℝ) :
    fixedPathCost n cost vs false =
      (mixedBackwardDifference (List.replicate vs.length 4)
        (fun x => (triangularShiftBlocks vs (cost, scalarShift 4 cost)).1 x +
          (triangularShiftBlocks vs (cost, scalarShift 4 cost)).2 x) n) /
        (2 : ℝ)^(2*vs.length+1) := by
  rw [fixedPathCost_eq_shift_transfer, scalarPathBlocks_cancel]
  simp only [pairDifference, mixedBackwardDifference_add]

end NeuralGeneralization.OnlineLowerTanh
