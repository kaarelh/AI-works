import NeuralGeneralization.BatchTwoOnlineSampledTail

/-!
# Main theorem for the finite random-order protocol

This endpoint uses the manuscript's hypotheses `target ∈ A`, `log |A| ≤ h`
and the relative prior-tail bound. It combines the actual posterior, its
actual product sampling law, and the exact expectation and tail constants.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {H : Type*} [Fintype H] [DecidableEq H]

def expectationBudget (m : ℕ) (h β : ℝ) : ℝ :=
  1+2*(h+1)*harmonicSum (m-1)+m*β

def highProbabilityBudget (m : ℕ) (h β δ : ℝ) : ℝ :=
  (Real.exp 1-1)*(1+2*(h+Real.log (2*m/δ))*harmonicSum (m-1)+m*β)+Real.log (2/δ)

/-- All claims of the principal statistical theorem for the uniform
permutation protocol. The expectation equality is between the two actual
finite laws, and the two tail bounds are separate probability statements. -/
theorem random_order_cumulative_errors (m : ℕ) (hm : 2 ≤ m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (hA : target∈A) (h β : ℝ) (hlog : Real.log (A.card : ℝ) ≤ h)
    (hβ : 0 ≤ β) (_hβ1 : β < 1)
    (htail : (∑ g∈Finset.univ \ A, w g)/w target ≤ β) :
    finiteMean (fun π => ∑ draw,
      permutationDrawWeight w good π draw*sampledMistakes good π draw) =
      finiteMean (permutationTotal w good) ∧
    finiteMean (permutationTotal w good) ≤ expectationBudget m h β ∧
    ∀ δ : ℝ, 0 < δ → δ < 1 →
      finiteEvent (fun π => highProbabilityBudget m h β δ < permutationTotal w good π) ≤ δ ∧
      finiteMean (fun π => ∑ draw, if highProbabilityBudget m h β δ < sampledMistakes good π draw
        then permutationDrawWeight w good π draw else 0) ≤ δ := by
  have hApos : 0 < A.card := Finset.card_pos.mpr ⟨target,hA⟩
  have hAreal : (0 : ℝ) < A.card := by exact_mod_cast hApos
  have hh : 0 ≤ h := (Real.log_nonneg (by exact_mod_cast hApos)).trans hlog
  have hcard : (A.card : ℝ) ≤ Real.exp h := by
    calc
      _ = Real.exp (Real.log (A.card : ℝ)) := (Real.exp_log hAreal).symm
      _ ≤ _ := Real.exp_le_exp.mpr hlog
  refine ⟨?_, ?_, ?_⟩
  · congr 1
    funext π
    exact expected_sampledMistakes_eq w hw good target htarget hwt π
  · exact expected_permutationTotal_le_general m (by omega) w hw good target htarget hwt A h β hh hcard htail
  · intro δ hδ hδ1
    obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (show m≠0 by omega)
    constructor
    · simpa only [highProbabilityBudget, Nat.succ_eq_add_one, Nat.add_sub_cancel] using
        permutationTotal_high_probability k w hw good target htarget hwt A h β δ hh hβ hδ hδ1 hcard htail
    · simpa only [highProbabilityBudget, Nat.succ_eq_add_one, Nat.add_sub_cancel] using
        sampledMistakes_high_probability k w hw good target htarget hwt A h β δ hh hβ hδ hδ1 hcard htail

/-- A query sequence extending a complete finite permutation. After the
first pass its only additional input is already known. -/
def permutationQuery (m : ℕ) (hm : 0 < m) (π : Equiv.Perm (Fin m)) (n : ℕ) : Fin m :=
  if hn : n<m then π ⟨n,hn⟩ else π ⟨0,hm⟩

lemma permutationTotal_eq_cumulativeError (m : ℕ) (hm : 0 < m)
    (w : H → ℝ) (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m)) :
    permutationTotal w good π = cumulativeError w good (permutationQuery m hm π) m := by
  have hh (i : Fin m) : history good (permutationQuery m hm π) i.val = prefixKeep good π i.val := by
    funext g
    apply propext
    constructor
    · intro hk j hj
      have h := hk j.val hj
      simpa only [permutationQuery, dif_pos j.isLt] using h
    · intro hk j hj
      have hjm : j<m := hj.trans i.isLt
      simpa only [permutationQuery, dif_pos hjm] using hk ⟨j,hjm⟩ hj
  have he (i : Fin m) : permutationRound w good π i = onlineError w good (permutationQuery m hm π) i.val := by
    unfold permutationRound onlineError onlinePosterior
    simp only [hh i]
    simp only [permutationQuery, dif_pos i.isLt]
    apply Finset.sum_congr rfl
    intro g _
    unfold pointLoss
    split_ifs <;> simp
  unfold permutationTotal
  simp_rw [he]
  exact Fin.sum_univ_eq_sum_range (onlineError w good (permutationQuery m hm π)) m

/-- The direct prior-cost branch is deterministic for each entire permutation. -/
theorem permutationTotal_le_prior_cost (m : ℕ) (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (hwsum : ∑ g,w g ≤ 1)
    (good : H → Fin m → Prop) (target : H) (htarget : ∀ x, good target x)
    (hwt : 0 < w target) (π : Equiv.Perm (Fin m)) :
    permutationTotal w good π ≤ -Real.log (w target) := by
  rw [permutationTotal_eq_cumulativeError m hm]
  exact cumulativeError_le_neg_log w good _ hw target htarget hwt hwsum m

end NeuralGeneralization.BatchTwoOnline
