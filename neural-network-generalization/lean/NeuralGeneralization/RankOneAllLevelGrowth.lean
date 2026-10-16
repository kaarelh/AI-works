import NeuralGeneralization.RankOneGrowth
import NeuralGeneralization.RankOneTailOffset

/-!
# A bounded growth functional for the actual rank-one process

The coarse levels use the proved local packing inequality for convex-hull
energy minimizers. The fine levels use the actual finite coordinate grid.
The resulting functional satisfies the growth condition at every level,
including the four-level lookahead needed by the greedy chaining tree.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open Classical
open scoped BigOperators
attribute [local instance] Classical.propDecidable

variable {m D : ℕ} {U : Type*} [DecidableEq U]

def rankGrowthEta (D : ℕ) : ℝ := 1/(dimensionCutoff D+1 : ℕ)

def rankGrowthConstant (m D : ℕ) (V : ℝ) : ℝ :=
  1/(512*Real.sqrt (V*(Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ))))

def rankGrowthOffset (m D : ℕ) (V : ℝ) (h : ℕ) : ℝ :=
  tailOffset (rankGrowthConstant m D V) V (rankGrowthEta D) (dimensionCutoff D) h

def rankGrowthFunctional (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V : ℝ) (h : ℕ) : Finset U → ℝ := rankPotential a p (rankGrowthOffset m D V h)

theorem rankGrowthEta_pos (D : ℕ) : 0 < rankGrowthEta D := by
  unfold rankGrowthEta
  positivity

theorem rankGrowth_log_nonneg (m : ℕ) (hm : 0 < m) : 0 ≤ Real.log (8*(m:ℝ)) := by
  have hm' : (1:ℝ)≤m := by exact_mod_cast hm
  exact Real.log_nonneg (by linarith)

theorem rankGrowthConstant_pos (m D : ℕ) (V : ℝ) (hm : 0 < m) (hV : 0 < V) :
    0 < rankGrowthConstant m D V := by
  have hL := rankGrowth_log_nonneg m hm
  unfold rankGrowthConstant
  positivity

theorem rankGrowthConstant_scaled_le (m D : ℕ) (V : ℝ) (hm : 0 < m) (hV : 0 < V) :
    rankGrowthConstant m D V * Real.sqrt V ≤ 1/512 := by
  let L : ℝ := Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ)
  have hL : 1 ≤ L := by
    have hh := rankGrowth_log_nonneg m hm
    have hz : (0:ℝ)≤dimensionCutoff D := Nat.cast_nonneg _
    dsimp only [L]
    push_cast
    linarith
  have hmul : V ≤ V*L := by nlinarith only [mul_nonneg hV.le (sub_nonneg.mpr hL)]
  have hs := Real.sqrt_le_sqrt hmul
  have hpos : 0 < 512*Real.sqrt (V*L) := by positivity
  change (1/(512*Real.sqrt (V*L)))*Real.sqrt V ≤ 1/512
  rw [one_div_mul_eq_div]
  apply (div_le_iff₀ hpos).mpr
  nlinarith only [hs]

theorem rankGrowthOffset_nonneg (m D : ℕ) (V : ℝ) (hm : 0 < m) (hV : 0 < V) (h : ℕ) :
    0 ≤ rankGrowthOffset m D V h := tailOffset_nonneg _ _ _
  (rankGrowthConstant_pos m D V hm hV).le (rankGrowthEta_pos D).le _ _

theorem rankGrowthOffset_antitone (m D : ℕ) (V : ℝ) (hm : 0 < m) (hV : 0 < V) :
    Antitone (rankGrowthOffset m D V) := tailOffset_antitone _ _ _
  (rankGrowthConstant_pos m D V hm hV).le (rankGrowthEta_pos D).le _

theorem rankGrowthOffset_zero_le (m D : ℕ) (V : ℝ) (hm : 0 < m) (hV : 0 < V) :
    rankGrowthOffset m D V 0 ≤ 1+1/128 := tailOffset_zero_bounded _ _
  (rankGrowthConstant_pos m D V hm hV).le (rankGrowthConstant_scaled_le m D V hm hV) _

theorem rankGrowthFunctional_nonneg (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V)
    (hp : ∀ x, ∑ j, p x j^2 ≤ 1) (hrow : ∀ x, ∑ i, linearEvaluation (a i) (p x)^2 ≤ 1)
    (h : ℕ) (S : Finset U) : 0 ≤ rankGrowthFunctional a p V h S := by
  apply rankPotential_nonneg a p _ (rankGrowthOffset_nonneg m D V hm hV h) _ S
  intro x
  simpa only [rankOneEnergy, show (1:ℝ)+1=2 by norm_num] using add_le_add (hp x) (hrow x)

theorem rankGrowthFunctional_mono (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V)
    (hp : ∀ x, ∑ j, p x j^2 ≤ 1) (hrow : ∀ x, ∑ i, linearEvaluation (a i) (p x)^2 ≤ 1)
    (h : ℕ) : Monotone (rankGrowthFunctional a p V h) := by
  apply rankPotential_mono a p _ (rankGrowthOffset_nonneg m D V hm hV h)
  intro x
  simpa only [rankOneEnergy, show (1:ℝ)+1=2 by norm_num] using add_le_add (hp x) (hrow x)

theorem rankGrowthFunctional_antitone (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V) (S : Finset U) :
    Antitone (fun h => rankGrowthFunctional a p V h S) := by
  intro h k hk
  have hh := rankGrowthOffset_antitone m D V hm hV hk
  unfold rankGrowthFunctional rankPotential
  split_ifs <;> linarith

theorem rankGrowthFunctional_zero_le (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V) (S : Finset U) :
    rankGrowthFunctional a p V 0 S ≤ 4 := by
  have hh := rankPotential_le a p _ (rankGrowthOffset_nonneg m D V hm hV 0) S
  have ho := rankGrowthOffset_zero_le m D V hm hV
  change rankGrowthFunctional a p V 0 S ≤ _ at hh
  linarith

/-- Every level has the actual finite growth property, with no eventual
cutoff or analytic certificate left as an assumption. -/
theorem rankGrowthFunctional_growthAt (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V)
    (hp : ∀ x, ∑ j, p x j^2 ≤ 1) (hrow : ∀ x, ∑ i, linearEvaluation (a i) (p x)^2 ≤ 1)
    (h : ℕ) :
    GrowthCover.GrowthAt (fun x y => rankOneDistance a (p x) (p y))
      (rankGrowthFunctional a p V (h+1)) (rankGrowthFunctional a p V h)
      (GrowthTree.branching h) (rankGrowthConstant m D V) ((2:ℝ)^h) := by
  by_cases hh : h ≤ dimensionCutoff D
  · have hoff : rankGrowthOffset m D V (h+1)+rankGrowthEta D = rankGrowthOffset m D V h := by
      have he := tailOffset_drop_head (rankGrowthConstant m D V) V (rankGrowthEta D)
        (dimensionCutoff D) h hh
      change rankGrowthOffset m D V h - rankGrowthOffset m D V (h+1) = rankGrowthEta D at he
      linarith
    have hg := rankPotential_growthAt a p V (rankGrowthEta D) (rankGrowthOffset m D V (h+1)) h
      hm hV (rankGrowthEta_pos D) (rankGrowthOffset_nonneg m D V hm hV (h+1)) ha hrow
    rw [hoff] at hg
    simpa only [rankGrowthFunctional, rankGrowthConstant, rankGrowthEta, one_div_one_div,
      GrowthTree.branching] using hg
  · intro C s hs x H hmem hsub hball hsep t ht
    have htail := tailOffset_pays_growth a V hV.le ha (dimension_le_pow_cutoff D) (lt_of_not_ge hh)
      (fun l => p (x l)) (fun l => hp (x l)) (fun l => hrow (x l)) s
      (fun l k hlk => (hsep l k hlk).1) (rankGrowthConstant m D V) (rankGrowthEta D)
      (rankGrowthConstant_pos m D V hm hV).le
    let i₀ : Fin (GrowthTree.branching h) := ⟨0, GrowthTree.branching_pos h⟩
    have hH : (H i₀).Nonempty := ⟨x i₀, hmem i₀⟩
    have hC := hH.mono (hsub i₀)
    have henergy := energyMinimum_antitone a p hH (hsub i₀)
    have ht' := ht i₀
    change rankGrowthConstant m D V*s*2^h ≤
      rankGrowthOffset m D V h-rankGrowthOffset m D V (h+1) at htail
    simp only [rankGrowthFunctional, rankPotential, if_pos hH, if_pos hC] at ht' ⊢
    linarith

end NeuralGeneralization.SquaredSampling
