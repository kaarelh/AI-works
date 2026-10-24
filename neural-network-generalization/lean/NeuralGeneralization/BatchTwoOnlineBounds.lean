import NeuralGeneralization.BatchTwoOnlineFiniteMain

/-! # A common all-width online bound and the direct-cost splice -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

/-- The two expectation claims and separate high-probability claims under
the actual random-order and posterior-draw laws. -/
def RandomOrderBounds (w : H → ℝ) (good : H → Fin m → Prop) (h β : ℝ) : Prop :=
  finiteMean (permutationTotal w good) ≤ expectationBudget m h β ∧
  finiteMean (fun π => ∑ draw, permutationDrawWeight w good π draw*sampledMistakes good π draw) ≤
    expectationBudget m h β ∧
  ∀ δ : ℝ, 0 < δ → δ < 1 →
    finiteEvent (fun π => highProbabilityBudget m h β δ < permutationTotal w good π) ≤ δ ∧
    finiteMean (fun π => ∑ draw, if highProbabilityBudget m h β δ < sampledMistakes good π draw
      then permutationDrawWeight w good π draw else 0) ≤ δ

theorem bounds_of_relevant_class (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β) : RandomOrderBounds w good h β := by
  refine ⟨expected_permutationTotal_le_general m hm w hw good target htarget hwt A h β hh hcard htail,
    expected_sampledMistakes_le m hm w hw good target htarget hwt A h β hh hcard htail, ?_⟩
  intro δ hδ hδ1
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt hm)
  constructor
  · simpa only [highProbabilityBudget, Nat.succ_eq_add_one, Nat.add_sub_cancel] using
      permutationTotal_high_probability k w hw good target htarget hwt A h β δ hh hβ hδ hδ1 hcard htail
  · simpa only [highProbabilityBudget, Nat.succ_eq_add_one, Nat.add_sub_cancel] using
      sampledMistakes_high_probability k w hw good target htarget hwt A h β δ hh hβ hδ hδ1 hcard htail

lemma harmonicSum_nonneg (n : ℕ) : 0 ≤ harmonicSum n :=
  Finset.sum_nonneg fun i _ => by positivity

lemma harmonicSum_ge_one (n : ℕ) (hn : 0 < n) : 1 ≤ harmonicSum n := by
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt hn)
  unfold harmonicSum
  rw [Fin.sum_univ_succ]
  simp only [Fin.val_zero, Nat.cast_zero, zero_add, div_one]
  have hs : 0 ≤ ∑ i : Fin k, 1/((i.succ.val : ℝ)+1) := Finset.sum_nonneg fun i _ => by positivity
  linarith

lemma prior_cost_le_expectationBudget (hm : 2 ≤ m) (h β : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β) :
    h ≤ expectationBudget m h β := by
  have hH := harmonicSum_ge_one (m-1) (by omega)
  have hmβ := mul_nonneg (Nat.cast_nonneg m (α := ℝ)) hβ
  unfold expectationBudget
  nlinarith

lemma prior_tail_le_highProbabilityBudget (hm : 2 ≤ m) (h β δ : ℝ)
    (hh : 0 ≤ h) (hβ : 0 ≤ β) (hδ : 0 < δ) (hδ1 : δ < 1) :
    (Real.exp 1-1)*h+Real.log (1/δ) ≤ highProbabilityBudget m h β δ := by
  have hc : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have hH := harmonicSum_ge_one (m-1) (by omega)
  have hmR : (2 : ℝ) ≤ m := by exact_mod_cast hm
  have hmβ := mul_nonneg (Nat.cast_nonneg m (α := ℝ)) hβ
  have hlog : 0 ≤ Real.log (2*m/δ) :=
    Real.log_nonneg ((one_le_div hδ).mpr (by nlinarith))
  have hB : h ≤ 1+2*(h+Real.log (2*m/δ))*harmonicSum (m-1)+m*β := by nlinarith
  have hlogs : Real.log (1/δ) ≤ Real.log (2/δ) :=
    Real.log_le_log (one_div_pos.mpr hδ) (div_le_div_of_nonneg_right (by norm_num) hδ.le)
  exact add_le_add (mul_le_mul_of_nonneg_left hB hc) hlogs

theorem bounds_of_prior_mass (hm : 2 ≤ m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (hwsum : ∑ g,w g ≤ 1)
    (good : H → Fin m → Prop) (target : H) (htarget : ∀ x, good target x)
    (h β : ℝ) (hh : 0 ≤ h) (hβ : 0 ≤ β) (hmass : Real.exp (-h) ≤ w target) :
    RandomOrderBounds w good h β := by
  have hwt : 0 < w target := (Real.exp_pos _).trans_le hmass
  have hcost : -Real.log (w target) ≤ h := by
    have hl := Real.log_le_log (Real.exp_pos _) hmass
    rw [Real.log_exp] at hl
    linarith
  have htotal (π) : permutationTotal w good π ≤ h :=
    (permutationTotal_le_prior_cost m (by omega) w hw hwsum good target htarget hwt π).trans hcost
  have hmean : finiteMean (permutationTotal w good) ≤ h := by
    calc
      _ ≤ finiteMean (fun _π : Equiv.Perm (Fin m) => h) := finiteMean_mono htotal
      _ = _ := finiteMean_const _
  have hE := hmean.trans (prior_cost_le_expectationBudget hm h β hh hβ)
  refine ⟨hE, ?_, ?_⟩
  · simpa only [expected_sampledMistakes_eq w hw good target htarget hwt] using hE
  · intro δ hδ hδ1
    have hU := prior_tail_le_highProbabilityBudget hm h β δ hh hβ hδ hδ1
    have hc : 1 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
    have hlog : 0 ≤ Real.log (1/δ) := Real.log_nonneg ((one_le_div hδ).mpr hδ1.le)
    have hUb : h ≤ highProbabilityBudget m h β δ := by nlinarith
    constructor
    · have hnone (π) : ¬highProbabilityBudget m h β δ < permutationTotal w good π :=
        not_lt_of_ge ((htotal π).trans hUb)
      simp only [finiteEvent, hnone, if_false, finiteMean_const]
      exact hδ.le
    · have hp (π : Equiv.Perm (Fin m)) (draw) : 0 ≤ permutationDrawWeight w good π draw :=
        independentWeight_nonneg _ (fun i g => posterior_nonneg w _ hw target
          (fun j _ => htarget (π j)) hwt g) draw
      have hmgf : finiteMean (fun π => ∑ draw, permutationDrawWeight w good π draw*
          Real.exp (sampledMistakes good π draw)) ≤ Real.exp ((Real.exp 1-1)*h) := by
        calc
          _ ≤ finiteMean (fun _π : Equiv.Perm (Fin m) => Real.exp ((Real.exp 1-1)*h)) := by
            apply finiteMean_mono
            intro π
            have hb := independent_exp_sum_le
              (fun i : Fin m => posterior w (prefixKeep good π i.val))
              (fun i g => posterior_nonneg w _ hw target (fun j _ => htarget (π j)) hwt g)
              (fun i => posterior_sum w _ hw target (fun j _ => htarget (π j)) hwt)
              (fun i g => pointLoss good g (π i))
              (fun i g => ⟨pointLoss_nonneg good g _, pointLoss_le_one good g _⟩)
            apply hb.trans
            exact Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (htotal π) (by linarith))
          _ = _ := finiteMean_const _
      have hb := mixed_exponential_tail_of_moment (permutationDrawWeight w good)
        (sampledMistakes good) hp ((Real.exp 1-1)*h) δ hδ hmgf
      apply le_trans _ hb
      apply finiteMean_mono
      intro π
      apply Finset.sum_le_sum
      intro draw _
      by_cases he : highProbabilityBudget m h β δ < sampledMistakes good π draw
      · simp only [if_pos he, if_pos (lt_of_le_of_lt hU he)]
        exact le_rfl
      · simp only [he, if_false]
        split_ifs
        · exact hp π draw
        · exact le_rfl

end NeuralGeneralization.BatchTwoOnline
