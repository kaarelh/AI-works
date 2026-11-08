import NeuralGeneralization.OnlineLowerTanhPathPrefix
import NeuralGeneralization.OnlineLowerTanhPathDigits
import NeuralGeneralization.OnlineLowerTanhPathActualCost
import NeuralGeneralization.OnlineLowerTanhCostDifferences

/-! # Strict common order of the actual tanh rectangle costs -/

noncomputable section
open scoped BigOperators Classical
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerGeometry

theorem prefixedCandidateCost_strict_of_difference (P : ℕ) (cost : ℝ → ℝ)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length=ys.length)
    (a n : ℝ) (hn : a≤n)
    (hpos : ∀x∈Ici a, 0<mixedBackwardDifference (List.replicate (P+(xs.length+1)) 4) cost x)
    (hmono : AntitoneOn (mixedBackwardDifference (List.replicate (P+(xs.length+1)) 4) cost) (Ici a))
    (hlex : digitLexLt xs ys) :
    prefixedCandidateCost P n cost endpoint xs < prefixedCandidateCost P n cost endpoint ys := by
  let f := mixedBackwardDifference (List.replicate (P+(xs.length+1)) 4) cost
  let g := pathBridge (scalarShift 4 f)
  have hgp : ∀x∈Ici a, 0<g x := by
    intro x hx
    change 0 < f (x+2+4) + f (x+6+4)
    exact add_pos (hpos _ (by simp only [mem_Ici] at *; linarith))
      (hpos _ (by simp only [mem_Ici] at *; linarith))
  have hgm : AntitoneOn g (Ici a) := by
    intro x hx y hy hxy
    change f (y+2+4)+f (y+6+4) ≤ f (x+2+4)+f (x+6+4)
    exact add_le_add
      (hmono (by simp only [mem_Ici] at *; linarith)
        (by simp only [mem_Ici] at *; linarith) (by linarith))
      (hmono (by simp only [mem_Ici] at *; linarith)
        (by simp only [mem_Ici] at *; linarith) (by linarith))
  have hord := finiteDifference_path_strict_order_succ 4 a (n+8) g (xs.length-1)
    (by norm_num) (by linarith) hgp hgm hlen (by omega) hlex
  have hxs := prefixedCandidateCost_eq_triangular P cost endpoint xs n
  have hys := prefixedCandidateCost_eq_triangular P cost endpoint ys n
  dsimp only at hxs hys
  simp only [fixedParityBlocks_length] at hxs hys
  rw [← hlen] at hys
  rw [hxs, hys, triangularShiftBlocks_fixedParity, triangularShiftBlocks_fixedParity,
    triangularShiftBlocks_fixedParity_snd, triangularShiftBlocks_fixedParity_snd, ← hlen]
  apply (div_lt_div_iff_of_pos_right (by positivity : (0 : ℝ)<2^(P+2*(xs.length+1)+1))).mpr
  change (_ + _ + weightedSignedSeries (pathDifferenceWeight 4 g (xs.length-1) (n+8)) xs) + _ <
    (_ + _ + weightedSignedSeries (pathDifferenceWeight 4 g (xs.length-1) (n+8)) ys) + _
  linarith

/-- A single linear threshold in the total difference order gives the
same strict lexicographic order for every actual optimized tanh cost. -/
theorem optimizedRealCost_prefixed_strict (b : ActualGainBranch) :
    ∃S : ℝ, 0<S ∧ ∀P : ℕ, 1≤P → ∀endpoint : Bool, ∀xs ys : List Bool,
      xs.length=ys.length → ∀n : ℝ, S*(P+xs.length+2 : ℕ)≤n →
      digitLexLt xs ys →
      prefixedCandidateCost P n (optimizedRealCost b) endpoint xs <
        prefixedCandidateCost P n (optimizedRealCost b) endpoint ys := by
  obtain ⟨S,hS,hD⟩ := optimizedRealCost_mixed_differences b
  refine ⟨S,hS,?_⟩
  intro P hP endpoint xs ys hlen n hn hlex
  let hs : List ℝ := List.replicate (P+(xs.length+1)) 4
  have hsteps : ∀h∈hs, 0<h := by
    intro h hh
    have he : h=(4 : ℝ) := (List.mem_replicate.mp hh).2
    rw [he]
    norm_num
  have hN : 2≤hs.length := by simp [hs]; omega
  have hd := hD hs hsteps hN
  apply prefixedCandidateCost_strict_of_difference P (optimizedRealCost b) endpoint hlen
    (S*(hs.length+1 : ℕ)) n (by simpa [hs, Nat.add_assoc] using hn)
  · intro x hx
    exact (hd.1 x hx).1
  · exact hd.2
  · exact hlex

namespace Family

/-- The physical inverse balanced-gain costs of all candidate rectangles
are pairwise distinct. The only size restriction is an explicit linear
threshold in the prefix/path difference order. -/
theorem exists_candidate_rectangle_injective_threshold (b : ActualGainBranch) :
    ∃S : ℝ, 0<S ∧ ∀R H k : ℕ, ∀hR : 0<R, ∀hH : 0<H,
      Even R → Even H → ∀hk : 1≤k,
      b.threshold<((pairDim R H k*R+1 : ℕ) : ℝ) →
      S*(OnlineLowerRelu.Family.prefixDim k+k+1 : ℕ)≤
        (pairDim R H k : ℝ)*R+1+H → ∀endpoint : Bool,
      Function.Injective (fun digits : CandidateDigits k =>
        rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)
          (candidatePoint k hk endpoint digits)) := by
  obtain ⟨S,hS,hstrict⟩ := optimizedRealCost_prefixed_strict b
  refine ⟨S,hS,?_⟩
  intro R H k hR hH hRe hHe hk hbase hsize endpoint xs ys he
  have hEq : prefixedCandidateCost (OnlineLowerRelu.Family.prefixDim k)
      ((pairDim R H k : ℝ)*R+1+H) (optimizedRealCost b) endpoint (List.ofFn xs) =
    prefixedCandidateCost (OnlineLowerRelu.Family.prefixDim k)
      ((pairDim R H k : ℝ)*R+1+H) (optimizedRealCost b) endpoint (List.ofFn ys) := by
    simp only [candidate_rectangle_codeBalancedCost_eq b R H k hR hH hRe hHe hk hbase,
      FamilyCost.candidateCost_eq_prefixed, neg_inj] at he
    exact he
  have hlen : (List.ofFn xs).length=(List.ofFn ys).length := by simp
  have hlarge : S*(OnlineLowerRelu.Family.prefixDim k+(List.ofFn xs).length+2 : ℕ)≤
      (pairDim R H k : ℝ)*R+1+H := by
    simpa only [List.length_ofFn, show OnlineLowerRelu.Family.prefixDim k+(k-1)+2 =
      OnlineLowerRelu.Family.prefixDim k+k+1 by omega] using hsize
  have hP : 1≤OnlineLowerRelu.Family.prefixDim k := by unfold OnlineLowerRelu.Family.prefixDim; omega
  have hlisteq : List.ofFn xs=List.ofFn ys := by
    by_contra hn
    rcases digitLexLt_or_reverse hlen hn with h | h
    · exact (hstrict _ hP endpoint _ _ hlen _ hlarge h).ne hEq
    · exact (hstrict _ hP endpoint _ _ hlen.symm _ (by simpa using hlarge) h).ne hEq.symm
  exact List.ofFn_injective hlisteq

/-- The same reverse lexicographic order works for every admissible
baseline, distinguished increment, and physical split of the columns. -/
theorem exists_candidate_rectangle_lex_threshold (b : ActualGainBranch) :
    ∃S : ℝ, 0<S ∧ ∀R H k : ℕ, ∀hR : 0<R, ∀hH : 0<H,
      Even R → Even H → ∀hk : 1≤k,
      b.threshold<((pairDim R H k*R+1 : ℕ) : ℝ) →
      S*(OnlineLowerRelu.Family.prefixDim k+k+1 : ℕ)≤
        (pairDim R H k : ℝ)*R+1+H → ∀endpoint : Bool,
      ∀xs ys : CandidateDigits k, digitLexLt (List.ofFn xs) (List.ofFn ys) →
      rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)
          (candidatePoint k hk endpoint ys) <
        rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k)
          (candidatePoint k hk endpoint xs) := by
  obtain ⟨S,hS,hstrict⟩ := optimizedRealCost_prefixed_strict b
  refine ⟨S,hS,?_⟩
  intro R H k hR hH hRe hHe hk hbase hsize endpoint xs ys hlex
  simp only [candidate_rectangle_codeBalancedCost_eq b R H k hR hH hRe hHe hk hbase,
    FamilyCost.candidateCost_eq_prefixed, neg_lt_neg_iff]
  apply hstrict _ (by unfold OnlineLowerRelu.Family.prefixDim; omega) endpoint _ _ (by simp)
    _ _ hlex
  simpa only [List.length_ofFn, show OnlineLowerRelu.Family.prefixDim k+(k-1)+2 =
    OnlineLowerRelu.Family.prefixDim k+k+1 by omega] using hsize

end Family
end NeuralGeneralization.OnlineLowerTanh
