import NeuralGeneralization.OnlineLowerCostPathColumns

/-! # Specialization to loop increments four and alternating edge increments six/two -/

noncomputable section

namespace NeuralGeneralization.OnlineLower

theorem pathBlockData_length (x : ℝ) (vs : List Bool) :
    (pathBlockData x vs).length = 2 * vs.length := by
  induction vs with
  | nil => rfl
  | cons v vs ih => simp [pathBlockData, ih]; omega

theorem pathBlockData_get_snd (x : ℝ) (vs : List Bool)
    (i : ℕ) (hi : i < (pathBlockData x vs).length) :
    ((pathBlockData x vs)[i]).2 =
      if i % 2 = 0 then pathEdgeSix x else pathEdgeTwo x := by
  induction vs generalizing i with
  | nil => simp [pathBlockData] at hi
  | cons v vs ih =>
    cases i with
    | zero => simp [pathBlockData]
    | succ i =>
      cases i with
      | zero => simp [pathBlockData]
      | succ i =>
        have hi' : i < (pathBlockData x vs).length := by simpa [pathBlockData] using hi
        have hm : (i + 1 + 1) % 2 = i % 2 := by omega
        simpa only [pathBlockData, List.getElem_cons_succ, hm] using ih i hi'

theorem pathLoop_exp (t : ℝ) :
    pathLoop (Real.exp (-2*t)) = columnLaplaceFugacity 4 t := by
  have h : Real.exp (-4*t) = Real.exp (-2*t)^2 := by
    rw [← Real.exp_nat_mul]
    congr 1
    norm_num
    ring
  unfold pathLoop columnLaplaceFugacity
  rw [h]

theorem pathEdgeSix_exp (t : ℝ) :
    pathEdgeSix (Real.exp (-2*t)) = columnLaplaceFugacity 6 t := by
  have h : Real.exp (-6*t) = Real.exp (-2*t)^3 := by
    rw [← Real.exp_nat_mul]
    congr 1
    norm_num
    ring
  unfold pathEdgeSix columnLaplaceFugacity
  rw [h]

theorem pathEdgeTwo_exp (t : ℝ) :
    pathEdgeTwo (Real.exp (-2*t)) = columnLaplaceFugacity 2 t := by
  rfl

def alternatingEdgeIncrement {n : ℕ} (j : Fin n) : ℝ :=
  if j.val % 2 = 0 then 6 else 2

theorem pathBlockData_get_fugacity (t : ℝ) (vs : List Bool)
    (j : Fin (pathBlockData (Real.exp (-2*t)) vs).length) :
    ((pathBlockData (Real.exp (-2*t)) vs).get j).2 =
      columnLaplaceFugacity (alternatingEdgeIncrement j) t := by
  rw [List.get_eq_getElem, pathBlockData_get_snd]
  unfold alternatingEdgeIncrement
  split_ifs
  · exact pathEdgeSix_exp t
  · exact pathEdgeTwo_exp t

theorem path_exp_fourier_explicit (n₀ t : ℝ) (vs : List Bool) (terminal : Bool) :
    let data := pathBlockData (Real.exp (-2*t)) vs
    walshCoefficients
      (fun s => Real.exp (-columnDegree n₀ (pathColumn data.length)
        (pathColumnIncrement 4 alternatingEdgeIncrement) s * t))
      (pathSyndromeSupport data terminal) =
      pathLaplacePrefactor n₀ t 4 (@alternatingEdgeIncrement data.length) *
        pathWalshSum (pathLoop (Real.exp (-2*t))) data terminal := by
  exact path_exp_degree_coefficient n₀ t 4 _ _ terminal _
    (pathLoop_exp t) (pathBlockData_get_fugacity t vs)

end NeuralGeneralization.OnlineLower
