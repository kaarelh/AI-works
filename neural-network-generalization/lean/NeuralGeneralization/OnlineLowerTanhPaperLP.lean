import NeuralGeneralization.OnlineLowerTanhPaperLPNormalize

/-! # Literal point-positive optimizer theorem from the tanh paper

For arbitrary positive Walsh costs with cheapest constant coefficient, the
full-margin cell positive at one point admits a minimizer with anchor value
one half, negative constant coefficient, and nonnegative other coefficients.
When the constant is strictly cheaper, every optimizer has this form.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

/-- A global optimizer over the complete point-positive sign cell. -/
def PointPositiveMinimum {m : ℕ} (w : Finset (Fin m) → ℝ)
    (g : ClippingCube m → ℝ) : Prop :=
  PointPositive g ∧ ∀ q, PointPositive q → weightedWalshCost w g ≤ weightedWalshCost w q

private theorem weighted_cost_expansion {m : ℕ} (w c : Finset (Fin m) → ℝ) :
    weightedWalshCost w (walshExpansion c) = weightedL1 w c := by
  unfold weightedWalshCost weightedL1
  simp_rw [walshCoefficients_expansion]

private theorem expansion_original {m : ℕ} (g : ClippingCube m → ℝ) :
    walshExpansion (walshCoefficients g) = g := funext (walshExpansion_coefficients g)

private theorem isClosed_pointPositive (m : ℕ) :
    IsClosed {g : ClippingCube m → ℝ | PointPositive g} := by
  have heq : {g : ClippingCube m → ℝ | PointPositive g} =
      {g | (1:ℝ)/2 ≤ g (cubeOne m)} ∩
      ⋂ (x : ClippingCube m), ⋂ (_ : x ≠ cubeOne m), {g | g x ≤ -(1:ℝ)/2} := by
    ext g
    simp only [PointPositive, Set.mem_setOf_eq, Set.mem_inter_iff, Set.mem_iInter]
  rw [heq]
  exact (isClosed_le continuous_const (continuous_apply _)).inter
    (isClosed_iInter (fun x => isClosed_iInter (fun _ =>
      isClosed_le (continuous_apply x) continuous_const)))

theorem pointPositive_exists_minimum {m : ℕ} (w : Finset (Fin m) → ℝ)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s) :
    ∃ g, PointPositiveMinimum w g := by
  let base : ClippingCube m → ℝ := reluReference
  have hbase : PointPositive base := by
    constructor
    · norm_num [base, reluReference, pointIndicator]
    · intro x hx
      simp [base, reluReference, pointIndicator, hx]
  let B := weightedWalshCost w base
  let R := B / w ∅
  let box : Set (ClippingCube m → ℝ) := Set.Icc (fun _ => -R) (fun _ => R)
  let K := box ∩ {g | PointPositive g}
  have hbox (g : ClippingCube m → ℝ) (hg : weightedWalshCost w g ≤ B) : g ∈ box := by
    constructor <;> intro x
    · have h := weightedWalshCost_point_bound w hw0 hw g x
      have hb := div_le_div_of_nonneg_right hg hw0.le
      exact (abs_le.mp (h.trans hb)).1
    · have h := weightedWalshCost_point_bound w hw0 hw g x
      have hb := div_le_div_of_nonneg_right hg hw0.le
      exact (abs_le.mp (h.trans hb)).2
  have hK : IsCompact K :=
    (isCompact_Icc : IsCompact box).inter_right (isClosed_pointPositive m)
  have hne : K.Nonempty := ⟨base, hbox base le_rfl, hbase⟩
  have hc : Continuous (fun g : ClippingCube m → ℝ => weightedWalshCost w g) :=
    continuous_weighted_walsh_cost w _ (fun x => continuous_apply x)
  obtain ⟨g, hg, hmin⟩ := hK.exists_isMinOn hne hc.continuousOn
  refine ⟨g, hg.2, ?_⟩
  intro q hq
  by_cases hqb : weightedWalshCost w q ≤ B
  · exact hmin ⟨hbox q hqb, hq⟩
  · have hgb : weightedWalshCost w g ≤ B := hmin ⟨hbox base le_rfl, hbase⟩
    exact hgb.trans (le_of_not_ge hqb)

/-- The exact existence clause of the paper's point-positive margin lemma. -/
theorem pointPositive_minimum_normal_form {m : ℕ}
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (w : Finset (Fin m) → ℝ)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s) :
    ∃ g, PointPositiveMinimum w g ∧ g (cubeOne m) = 1/2 ∧
      walshCoefficients g ∅ < 0 ∧ ∀ s, s ≠ ∅ → 0 ≤ walshCoefficients g s := by
  obtain ⟨g, hg⟩ := pointPositive_exists_minimum w hw0 hw
  let c := pointClippedCoefficients (walshCoefficients g)
  have hc : PointPositive (walshExpansion c) := by
    apply pointClipped_preserves_margin
    rw [expansion_original]
    exact hg.1
  have hcn (s : Finset (Fin m)) (hs : s ≠ ∅) : 0 ≤ c s := by
    simp only [c, pointClippedCoefficients, if_neg hs]
    exact le_max_right _ _
  let lam := 1/(walshExpansion c (cubeOne m)+1/2)
  let f := walshExpansion (pointNormalizedCoefficients lam c)
  obtain ⟨hf, hfone⟩ := pointNormalized_feasible c hc
  have hfcost : weightedWalshCost w f ≤ weightedWalshCost w g := by
    rw [show f = walshExpansion (pointNormalizedCoefficients lam c) from rfl,
      weighted_cost_expansion]
    exact (pointNormalized_cost_le hM w c hw0 hw hc hcn).trans
      (pointClipped_cost_le w (walshCoefficients g) hw0.le hw)
  refine ⟨f, ⟨hf, fun q hq => hfcost.trans (hg.2 q hq)⟩, hfone,
    pointPositive_empty_coefficient_neg hM f hf hfone, ?_⟩
  intro s hs
  rw [show f = walshExpansion (pointNormalizedCoefficients lam c) from rfl,
    walshCoefficients_expansion, pointNormalizedCoefficients, if_neg hs]
  have hlam : 0 ≤ lam := by dsimp [lam]; have := hc.1; positivity
  exact mul_nonneg hlam (hcn s hs)

/-- The exact every-optimizer clause: strict nonconstant weight inequalities
rule out every negative nonconstant coefficient and every anchor overshoot. -/
theorem pointPositive_every_minimum_normal_form {m : ℕ}
    (hM : 4 ≤ Fintype.card (ClippingCube m)) (w : Finset (Fin m) → ℝ)
    (hw0 : 0 < w ∅) (hw : ∀ s, s ≠ ∅ → w ∅ < w s)
    (g : ClippingCube m → ℝ) (hg : PointPositiveMinimum w g) :
    g (cubeOne m) = 1/2 ∧ walshCoefficients g ∅ < 0 ∧
      ∀ s, s ≠ ∅ → 0 ≤ walshCoefficients g s := by
  have hwle (s : Finset (Fin m)) : w ∅ ≤ w s := by
    by_cases hs : s = ∅
    · rw [hs]
    · exact (hw s hs).le
  have hc : PointPositive (walshExpansion (walshCoefficients g)) := by
    rw [expansion_original]
    exact hg.1
  have hcn (s : Finset (Fin m)) (hs : s ≠ ∅) : 0 ≤ walshCoefficients g s := by
    by_contra hn
    have hf := pointClipped_preserves_margin (walshCoefficients g) hc
    have hmin := hg.2 _ hf
    rw [weighted_cost_expansion] at hmin
    exact (not_lt_of_ge hmin) (pointClipped_cost_lt_of_negative w
      (walshCoefficients g) hw0.le hw s hs (lt_of_not_ge hn))
  have hone : g (cubeOne m) = 1/2 := by
    by_contra hn
    have hh : 1/2 < g (cubeOne m) := lt_of_le_of_ne hg.1.1 (Ne.symm hn)
    have hf := (pointNormalized_feasible (walshCoefficients g) hc).1
    have hmin := hg.2 _ hf
    rw [weighted_cost_expansion] at hmin
    have hlt := pointNormalized_cost_lt hM w (walshCoefficients g) hw0 hwle hc hcn
      (by rwa [walshExpansion_coefficients])
    exact (not_lt_of_ge hmin) hlt
  exact ⟨hone, pointPositive_empty_coefficient_neg hM g hg.1 hone, hcn⟩

end NeuralGeneralization.OnlineLowerGeometry
