import NeuralGeneralization.OnlineLowerTanhPathCap
import NeuralGeneralization.OnlineLowerTanhCostDifferences

/-! # The actual distinguished Fourier coefficient as a second difference -/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

theorem distinguished_second_sum (cost : ℝ → ℝ) (x H : ℝ) :
    (∑ a : ClippingCube 2,
      cost (x+H/2*(1-cubeCoordinateSign (a 0))+H/2*(1-cubeCoordinateSign (a 1))) *
        ∏ i, cubeCoordinateSign (a i)) = mixedBackwardDifference [H,H] cost x := by
  rw [sum_bool_tuple_succ, sum_bool_tuple_succ, sum_bool_tuple_succ]
  simp [Fin.prod_univ_two, cubeCoordinateSign, mixedBackwardDifference]
  ring_nf

/-- Splitting distinguished physical columns does not change the exact
second-difference formula for their logical Fourier coefficient. -/
theorem scalarSupportWeight_distinguished_transform (R H k : ℕ) (cost : ℝ → ℝ) :
    rectangleWeightTransform (scalarSupportWeight R H k cost) (shiftPoint k) =
      uniformCubeMean (fun z : ClippingCube (OldDim k) =>
        mixedBackwardDifference [(H : ℝ),H] cost
          (columnDegree ((pairDim R H k : ℝ)*R+1) (OnlineLowerRelu.Family.column k)
            (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z)) / 4 := by
  have hshift : shiftPoint k=negativeBitsCube (joinSupport k ∅ true) := by
    rw [negativeBitsCube_joinSupport]
    congr 1
  rw [hshift, scalarSupportWeight_transform]
  unfold walshCoefficients uniformCubeMean
  rw [← (joinPointEquiv k).sum_comp, Fintype.sum_prod_type]
  simp only [joinPointEquiv, Equiv.coe_fn_mk, joinSupport_character,
    if_true, columnDegree_joinPoint]
  simp only [walshCharacter, Finset.prod_empty, one_mul]
  simp_rw [distinguished_second_sum]
  have hcard : (Fintype.card (ClippingCube (logicalDim k)) : ℝ)=
      4*(Fintype.card (ClippingCube (OldDim k)) : ℝ) := by
    simp [ClippingCube, logicalDim, OldDim, pow_add]
    ring
  rw [hcard]
  ring

theorem columnDegree_dimension_bounds (R H k : ℕ) (x : ClippingCube (logicalDim k)) :
    (pairDim R H k : ℝ)*R+1≤
      columnDegree ((pairDim R H k : ℝ)*R+1) (column R H k)
        (fun i => (increment R H k i : ℝ)) x ∧
    columnDegree ((pairDim R H k : ℝ)*R+1) (column R H k)
        (fun i => (increment R H k i : ℝ)) x≤(dimension R H k : ℝ) := by
  obtain ⟨S,rfl⟩ := (negativeBitsEquiv (logicalDim k)).surjective x
  change _≤columnDegree _ _ _ (negativeBitsCube S) ∧ columnDegree _ _ _ (negativeBitsCube S)≤_
  rw [← support_card_eq_columnDegree]
  constructor
  · have h := support_card_lower R H k S
    exact_mod_cast h
  · have h : (carrierSupport (size R H k) (column R H k) S).card≤dimension R H k := by
      simpa only [Fintype.card_fin] using Finset.card_le_univ
        (carrierSupport (size R H k) (column R H k) S)
    exact_mod_cast h

theorem oldDegree_dimension_bounds (R H k : ℕ) (x : ClippingCube (OldDim k)) :
    let n := columnDegree ((pairDim R H k : ℝ)*R+1) (OnlineLowerRelu.Family.column k)
      (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) x
    (pairDim R H k : ℝ)*R+1≤n ∧ n+2*H≤(dimension R H k : ℝ) := by
  dsimp only
  have hlo := (columnDegree_dimension_bounds R H k (joinPoint k x (fun _ => true))).1
  have hhi := (columnDegree_dimension_bounds R H k (joinPoint k x (fun _ => false))).2
  rw [columnDegree_joinPoint] at hlo hhi
  simp only [show cubeCoordinateSign true=(1 : ℝ) from rfl, sub_self, mul_zero, add_zero] at hlo
  simp only [show cubeCoordinateSign false=(-1 : ℝ) from rfl,
    show (H : ℝ)/2*(1-(-1))=H by ring] at hhi
  exact ⟨hlo, by linarith⟩

theorem scalarSupportWeight_distinguished_bounds (b : ActualGainBranch) :
    ∃S : ℝ, 0<S ∧ ∀R H k : ℕ, 0<H →
      3*S≤(pairDim R H k : ℝ)*R+1 →
      optimizedCostCurvature*(H : ℝ)^2/(4*(dimension R H k : ℝ)^3)≤
        rectangleWeightTransform (scalarSupportWeight R H k (optimizedRealCost b)) (shiftPoint k) ∧
      rectangleWeightTransform (scalarSupportWeight R H k (optimizedRealCost b)) (shiftPoint k)≤
        3*optimizedCostCurvature*(H : ℝ)^2/(4*((pairDim R H k : ℝ)*R+1)^3) := by
  obtain ⟨S,hS,hD⟩ := optimizedRealCost_mixed_differences b
  refine ⟨S,hS,?_⟩
  intro R H k hH hbase
  let n₀ : ℝ := (pairDim R H k : ℝ)*R+1
  let d : ℝ := dimension R H k
  let hs : List ℝ := [H,H]
  let F : ClippingCube (OldDim k) → ℝ := fun z =>
    mixedBackwardDifference hs (optimizedRealCost b)
      (columnDegree n₀ (OnlineLowerRelu.Family.column k)
        (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z)
  have hH0 : (0 : ℝ)<H := by exact_mod_cast hH
  have hn0 : 0<n₀ := by dsimp [n₀]; positivity
  have hd0 : 0<d := by dsimp [d]; exact_mod_cast (Nat.succ_pos (OnlineLowerRelu.railDimension (size R H k)))
  have hC := optimizedCostCurvature_pos
  have hsteps : ∀h∈hs, 0<h := by
    intro h hh
    have he : h=(H : ℝ) := by simpa [hs] using hh
    simpa only [he] using hH0
  have hdiff := hD hs hsteps (by simp [hs])
  have hpoint (z : ClippingCube (OldDim k)) :
      optimizedCostCurvature*(H : ℝ)^2/d^3≤F z ∧
        F z≤3*optimizedCostCurvature*(H : ℝ)^2/n₀^3 := by
    let x := columnDegree n₀ (OnlineLowerRelu.Family.column k)
      (fun i => (OnlineLowerRelu.Family.increment k i : ℝ)) z
    have hxrange : n₀≤x ∧ x+2*H≤d := oldDegree_dimension_bounds R H k z
    have hx0 : 0<x := hn0.trans_le hxrange.1
    have hxshift : 0<x+2*H := by positivity
    have hxthreshold : S*(hs.length+1 : ℕ)≤x := by
      simp only [hs, List.length_cons, List.length_nil, Nat.reduceAdd, Nat.cast_ofNat]
      change 3*S≤n₀ at hbase
      linarith [hxrange.1]
    have hxD := hdiff.1 x hxthreshold
    have hlo : optimizedCostCurvature*(H : ℝ)^2/(x+2*H)^3≤F z := by
      convert hxD.2.1 using 1 <;> simp [hs, F, x] <;> ring
    have hhi : F z≤3*optimizedCostCurvature*(H : ℝ)^2/x^3 := by
      convert hxD.2.2 using 1 <;> simp [hs, F, x] <;> ring
    constructor
    · exact (div_le_div_of_nonneg_left (by positivity) (pow_pos hxshift 3)
        (pow_le_pow_left₀ hxshift.le hxrange.2 3)).trans hlo
    · exact hhi.trans (div_le_div_of_nonneg_left (by positivity) (pow_pos hn0 3)
        (pow_le_pow_left₀ hn0.le hxrange.1 3))
  have hlo := uniformCubeMean_mono
    (fun _ : ClippingCube (OldDim k) => optimizedCostCurvature*(H : ℝ)^2/d^3) F
    (fun z => (hpoint z).1)
  have hhi := uniformCubeMean_mono F
    (fun _ : ClippingCube (OldDim k) => 3*optimizedCostCurvature*(H : ℝ)^2/n₀^3)
    (fun z => (hpoint z).2)
  simp only [uniformCubeMean_const] at hlo hhi
  rw [scalarSupportWeight_distinguished_transform]
  change optimizedCostCurvature*(H : ℝ)^2/(4*d^3)≤uniformCubeMean F/4 ∧
    uniformCubeMean F/4≤3*optimizedCostCurvature*(H : ℝ)^2/(4*n₀^3)
  constructor
  · simpa only [div_div, mul_comm (d^3) 4] using
      div_le_div_of_nonneg_right hlo (by norm_num : (0 : ℝ)≤4)
  · simpa only [div_div, mul_comm (n₀^3) 4] using
      div_le_div_of_nonneg_right hhi (by norm_num : (0 : ℝ)≤4)

/-- The direct lower bound keeps the useful `H²` factor, and also gives
the polynomial reciprocal bound needed by the physical rounding step. -/
theorem codeBalancedCost_distinguished_bounds (b : ActualGainBranch) :
    ∃S : ℝ, 0<S ∧ ∀R H k : ℕ, ∀hR : 0<R, ∀hH : 0<H,
      Even R → Even H →
      b.threshold<((pairDim R H k*R+1 : ℕ) : ℝ) →
      3*S≤(pairDim R H k : ℝ)*R+1 →
      let W := rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)
      optimizedCostCurvature*(H : ℝ)^2/(4*(dimension R H k : ℝ)^3)≤W ∧
      W≤3*optimizedCostCurvature*(H : ℝ)^2/(4*((pairDim R H k : ℝ)*R+1)^3) ∧
      0<W ∧ 1/W≤(4/optimizedCostCurvature)*(dimension R H k : ℝ)^3 := by
  obtain ⟨S,hS,hbounds⟩ := scalarSupportWeight_distinguished_bounds b
  refine ⟨S,hS,?_⟩
  intro R H k hR hH hRe hHe hbranch hbase
  dsimp only
  rw [codeBalancedCost_eq_scalarSupportWeight b R H k hR hH hRe hHe hbranch]
  obtain ⟨hlo,hhi⟩ := hbounds R H k hH hbase
  let d : ℝ := dimension R H k
  let W := rectangleWeightTransform (scalarSupportWeight R H k (optimizedRealCost b)) (shiftPoint k)
  have hd0 : 0<d := by dsimp [d]; exact_mod_cast (Nat.succ_pos (OnlineLowerRelu.railDimension (size R H k)))
  have hH1 : (1 : ℝ)≤H := by exact_mod_cast (show 1≤H by omega)
  have hC := optimizedCostCurvature_pos
  have hweak : optimizedCostCurvature/(4*d^3)≤W := by
    have hnum : optimizedCostCurvature≤optimizedCostCurvature*(H : ℝ)^2 := by
      have hsq : (1 : ℝ)≤(H : ℝ)^2 := by nlinarith
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hsq hC.le
    exact (div_le_div_of_nonneg_right hnum (by positivity)).trans hlo
  have hW : 0<W := (by positivity : 0<optimizedCostCurvature/(4*d^3)).trans_le hweak
  refine ⟨hlo,hhi,hW,?_⟩
  apply (div_le_iff₀ hW).mpr
  have hmul := (div_le_iff₀ (by positivity : 0<4*d^3)).mp hweak
  have hone : (1 : ℝ)≤W*(4*d^3)/optimizedCostCurvature :=
    (le_div_iff₀ hC).mpr (by simpa only [one_mul] using hmul)
  change 1≤(4/optimizedCostCurvature)*d^3*W
  convert hone using 1 <;> ring

end NeuralGeneralization.OnlineLowerTanh.Family
