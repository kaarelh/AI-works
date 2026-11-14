import NeuralGeneralization.OnlineLowerTanhPaperLPPoint

/-! # Normalizing the point-positive Walsh optimization problem -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

private theorem split_constant {m : ℕ} (c : Finset (Fin m) → ℝ) :
    (∑ s, c s) = c ∅ + ∑ s ∈ Finset.univ.erase ∅, c s := by
  exact (Finset.add_sum_erase (Finset.univ : Finset (Finset (Fin m))) c
    (Finset.mem_univ ∅)).symm

theorem pointPositive_empty_coefficient_neg {m : ℕ}
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (g : ClippingCube m → ℝ)
    (hg : PointPositive g) (hone : g (cubeOne m) = 1/2) :
    walshCoefficients g ∅ < 0 := by
  have hpoint (x : ClippingCube m) : g x ≤ reluReference x := by
    by_cases hx : x = cubeOne m
    · subst x
      norm_num [reluReference, pointIndicator, hone]
    · simpa [reluReference, pointIndicator, hx] using hg.2 x hx
  have hsum := Finset.sum_le_sum (fun x (_ : x ∈ (Finset.univ : Finset (ClippingCube m))) => hpoint x)
  have hMpos : 0 < (Fintype.card (ClippingCube m) : ℝ) :=
    Nat.cast_pos.mpr Fintype.card_pos
  have hmean : walshCoefficients g ∅ ≤ walshCoefficients (reluReference : ClippingCube m → ℝ) ∅ := by
    simpa [walshCoefficients, walshCharacter, uniformCubeMean] using
      (div_le_div_of_nonneg_right hsum hMpos.le)
  have href : walshCoefficients (reluReference : ClippingCube m → ℝ) ∅ =
      -(1:ℝ)/2 + 1 / Fintype.card (ClippingCube m) := by
    rw [show (reluReference : ClippingCube m → ℝ) =
      (fun x => -(1:ℝ)/2 + pointIndicator (cubeOne m) x) from rfl,
      walshCoefficients_add, walshCoefficients_const, walshCoefficients_pointIndicator,
      walshCharacter_one]
    simp
  rw [href] at hmean
  have hMr : (4:ℝ) ≤ Fintype.card (ClippingCube m) := by exact_mod_cast hM
  have hi : (1:ℝ) / Fintype.card (ClippingCube m) ≤ 1/4 :=
    (div_le_iff₀ hMpos).mpr (by linarith)
  linarith

/-- The coefficient vector for the affine normalization fixing the anchor at one half. -/
def pointNormalizedCoefficients {m : ℕ} (lam : ℝ) (c : Finset (Fin m) → ℝ)
    (s : Finset (Fin m)) : ℝ :=
  if s = ∅ then lam * c ∅ + (lam-1)/2 else lam * c s

theorem pointNormalized_expansion {m : ℕ} (lam : ℝ) (c : Finset (Fin m) → ℝ)
    (x : ClippingCube m) :
    walshExpansion (pointNormalizedCoefficients lam c) x =
      lam * (walshExpansion c x + 1/2) - 1/2 := by
  unfold walshExpansion
  rw [split_constant, split_constant]
  simp only [pointNormalizedCoefficients, ite_true, walshCharacter, Finset.prod_empty, mul_one]
  have hsum : (∑ s ∈ Finset.univ.erase ∅,
      (if s = ∅ then lam*c ∅+(lam-1)/2 else lam*c s) *
        ∏ i ∈ s, cubeCoordinateSign (x i)) =
      lam * ∑ s ∈ Finset.univ.erase ∅, c s * ∏ i ∈ s, cubeCoordinateSign (x i) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro s hs
    rw [if_neg (Finset.ne_of_mem_erase hs)]
    ring
  rw [hsum]
  ring

theorem pointNormalized_feasible {m : ℕ} (c : Finset (Fin m) → ℝ)
    (hc : PointPositive (walshExpansion c)) :
    let lam := 1 / (walshExpansion c (cubeOne m) + 1/2)
    PointPositive (walshExpansion (pointNormalizedCoefficients lam c)) ∧
    walshExpansion (pointNormalizedCoefficients lam c) (cubeOne m) = 1/2 := by
  dsimp
  have hh := hc.1
  have hpos : 0 < walshExpansion c (cubeOne m) + 1/2 := by linarith
  have hlam : 0 ≤ 1 / (walshExpansion c (cubeOne m) + 1/2) := by positivity
  have hone : walshExpansion (pointNormalizedCoefficients
      (1/(walshExpansion c (cubeOne m)+1/2)) c) (cubeOne m) = 1/2 := by
    rw [pointNormalized_expansion, one_div_mul_cancel (ne_of_gt hpos)]
    norm_num
  refine ⟨⟨hone.ge, ?_⟩, hone⟩
  intro x hx
  rw [pointNormalized_expansion]
  have h := mul_nonpos_of_nonneg_of_nonpos hlam (show walshExpansion c x + 1/2 ≤ 0 by
    linarith [hc.2 x hx])
  linarith

theorem pointNormalized_cost_bound {m : ℕ}
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (w c : Finset (Fin m) → ℝ)
    (hw0 : 0 ≤ w ∅) (hc : PointPositive (walshExpansion c))
    (hcn : ∀ s, s ≠ ∅ → 0 ≤ c s) :
    let lam := 1 / (walshExpansion c (cubeOne m) + 1/2)
    weightedL1 w (pointNormalizedCoefficients lam c) ≤
      lam * weightedL1 w c + (1-lam) * w ∅ / 2 := by
  dsimp
  let lam := 1 / (walshExpansion c (cubeOne m) + 1/2)
  change weightedL1 w (pointNormalizedCoefficients lam c) ≤
    lam * weightedL1 w c + (1-lam)*w ∅/2
  have hlam : 0 ≤ lam := by dsimp [lam]; have := hc.1; positivity
  obtain ⟨hfeas, hone⟩ := pointNormalized_feasible c hc
  have hn := pointPositive_empty_coefficient_neg hM _ hfeas hone
  rw [walshCoefficients_expansion] at hn
  have hconstant : w ∅ * |pointNormalizedCoefficients lam c ∅| ≤
      lam * w ∅ * |c ∅| + (1-lam)*w ∅/2 := by
    rw [abs_of_neg hn]
    change w ∅ * -(lam*c ∅+(lam-1)/2) ≤ _
    have h := mul_nonneg (mul_nonneg hlam hw0) (show 0 ≤ |c ∅|+c ∅ by
      linarith [neg_abs_le (c ∅)])
    nlinarith
  unfold weightedL1
  rw [split_constant, split_constant]
  have hsum : (∑ s ∈ Finset.univ.erase ∅, w s * |pointNormalizedCoefficients lam c s|) =
      lam * ∑ s ∈ Finset.univ.erase ∅, w s * |c s| := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro s hs
    rw [pointNormalizedCoefficients, if_neg (Finset.ne_of_mem_erase hs), abs_mul,
      abs_of_nonneg hlam]
    ring
  rw [hsum]
  nlinarith

theorem weightedWalshCost_point_bound {m : ℕ} (w : Finset (Fin m) → ℝ)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s) (g : ClippingCube m → ℝ)
    (x : ClippingCube m) :
    |g x| ≤ weightedWalshCost w g / w ∅ := by
  calc
    |g x| = |walshExpansion (walshCoefficients g) x| := by rw [walshExpansion_coefficients]
    _ ≤ walshAlgebraNorm g := by
      unfold walshExpansion walshAlgebraNorm
      calc
        _ ≤ ∑ s, |walshCoefficients g s * walshCharacter s x| :=
          Finset.abs_sum_le_sum_abs _ _
        _ = _ := by simp_rw [abs_mul, abs_walshCharacter, mul_one]
    _ ≤ _ := walshAlgebraNorm_le_weighted w (w ∅) hw0 hw g

theorem pointNormalized_cost_le {m : ℕ}
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (w c : Finset (Fin m) → ℝ)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s)
    (hc : PointPositive (walshExpansion c)) (hcn : ∀ s, s ≠ ∅ → 0 ≤ c s) :
    weightedL1 w (pointNormalizedCoefficients
      (1/(walshExpansion c (cubeOne m)+1/2)) c) ≤ weightedL1 w c := by
  have hh := hc.1
  let lam := 1/(walshExpansion c (cubeOne m)+1/2)
  have hlam : 0 < lam := by dsimp [lam]; positivity
  have hlam1 : lam ≤ 1 := by
    dsimp [lam]
    apply (div_le_iff₀ (by linarith : 0 < walshExpansion c (cubeOne m)+1/2)).mpr
    linarith
  have hpoint := weightedWalshCost_point_bound w hw0 hw (walshExpansion c) (cubeOne m)
  simp only [weightedWalshCost, weightedL1, walshCoefficients_expansion] at hpoint
  change |walshExpansion c (cubeOne m)| ≤ weightedL1 w c / w ∅ at hpoint
  have hcost : w ∅ / 2 ≤ weightedL1 w c := by
    have hpc := (le_div_iff₀ hw0).mp ((le_abs_self _).trans hpoint)
    nlinarith
  have hb := pointNormalized_cost_bound hM w c hw0.le hc hcn
  change weightedL1 w (pointNormalizedCoefficients lam c) ≤ lam * weightedL1 w c + (1-lam)*w ∅/2 at hb
  have h := mul_nonneg (sub_nonneg.mpr hlam1) (sub_nonneg.mpr hcost)
  nlinarith

theorem pointNormalized_cost_lt {m : ℕ}
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (w c : Finset (Fin m) → ℝ)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s)
    (hc : PointPositive (walshExpansion c)) (hcn : ∀ s, s ≠ ∅ → 0 ≤ c s)
    (hh : 1/2 < walshExpansion c (cubeOne m)) :
    weightedL1 w (pointNormalizedCoefficients
      (1/(walshExpansion c (cubeOne m)+1/2)) c) < weightedL1 w c := by
  let lam := 1/(walshExpansion c (cubeOne m)+1/2)
  have hlam : 0 < lam := by dsimp [lam]; positivity
  have hlam1 : lam < 1 := by
    dsimp [lam]
    apply (div_lt_iff₀ (by linarith : 0 < walshExpansion c (cubeOne m)+1/2)).mpr
    linarith
  have hpoint := weightedWalshCost_point_bound w hw0 hw (walshExpansion c) (cubeOne m)
  simp only [weightedWalshCost, weightedL1, walshCoefficients_expansion] at hpoint
  change |walshExpansion c (cubeOne m)| ≤ weightedL1 w c / w ∅ at hpoint
  have hcost : w ∅ / 2 < weightedL1 w c := by
    have hpc := (le_div_iff₀ hw0).mp ((le_abs_self _).trans hpoint)
    nlinarith
  have hb := pointNormalized_cost_bound hM w c hw0.le hc hcn
  change weightedL1 w (pointNormalizedCoefficients lam c) ≤ lam * weightedL1 w c + (1-lam)*w ∅/2 at hb
  have h := mul_pos (sub_pos.mpr hlam1) (sub_pos.mpr hcost)
  nlinarith

end NeuralGeneralization.OnlineLowerGeometry
