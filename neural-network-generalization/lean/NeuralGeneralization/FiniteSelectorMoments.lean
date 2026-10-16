import NeuralGeneralization.FiniteSubsetSampling
import NeuralGeneralization.FiniteIndependentMoments

/-! Exact selector-count moments and a quantitative size event. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable
variable {V α : Type*} [Fintype V] [DecidableEq V] [Fintype α] [Nonempty α]

def selectorProbability (choose : α → Bool) : ℝ :=
  finiteMean (fun x => if choose x=true then 1 else 0)

lemma selectorProbability_nonneg (choose : α → Bool) : 0 ≤ selectorProbability choose := by
  apply finiteMean_nonneg
  intro x
  split_ifs <;> norm_num

lemma selectorProbability_le_one (choose : α → Bool) : selectorProbability choose ≤ 1 := by
  unfold selectorProbability
  have h := finiteMean_mono (fun x : α => show (if choose x=true then (1:ℝ) else 0) ≤ 1 by split_ifs <;> norm_num)
  simpa only [finiteMean_const] using h

lemma selectedSet_card_sum (choose : α → Bool) (ω : V → α) :
    ((selectedSet choose ω).card:ℝ) = ∑ v, if choose (ω v)=true then (1:ℝ) else 0 := by
  simp only [selectedSet, Finset.card_filter]
  push_cast
  rfl

lemma selectedSet_card_mean (choose : α → Bool) :
    finiteMean (fun ω : V → α => ((selectedSet choose ω).card:ℝ)) =
      (Fintype.card V:ℝ)*selectorProbability choose := by
  simp_rw [selectedSet_card_sum]
  exact finiteMean_product_sum (I := V) (fun x : α => if choose x=true then (1:ℝ) else 0)

lemma selectedSet_card_variance (choose : α → Bool) :
    finiteMean (fun ω : V → α => (((selectedSet choose ω).card:ℝ)-
      (Fintype.card V:ℝ)*selectorProbability choose)^2) =
      (Fintype.card V:ℝ)*(selectorProbability choose-(selectorProbability choose)^2) := by
  simp_rw [selectedSet_card_sum]
  have h := finiteMean_product_sum_variance (I := V) (fun x => if choose x=true then (1:ℝ) else 0)
  have he (x : α) : (if choose x=true then (1:ℝ) else 0)^2 = (if choose x=true then 1 else 0) := by
    split_ifs <;> norm_num
  simp_rw [he] at h
  exact h

/-- The selector keeps at least n vertices with probability at least one
half when its expected count is 2n and n≥4. -/
theorem selector_count_good_probability (choose : α → Bool) (n : ℕ) (hn : 4 ≤ n)
    (hmean : (Fintype.card V:ℝ)*selectorProbability choose=2*(n:ℝ)) :
    (1:ℝ)/2 ≤ finiteEvent (fun ω : V → α => n ≤ (selectedSet choose ω).card) := by
  have hN : (4:ℝ)≤n := by exact_mod_cast hn
  have hNpos : (0:ℝ)<n := by linarith only [hN]
  have hv := selectedSet_card_variance (V := V) choose
  rw [hmean] at hv
  have hvar : finiteMean (fun ω : V → α => (((selectedSet choose ω).card:ℝ)-2*(n:ℝ))^2) ≤ 2*(n:ℝ) := by
    rw [hv]
    have hq := mul_nonneg (Nat.cast_nonneg (Fintype.card V) : (0:ℝ)≤Fintype.card V)
      (sq_nonneg (selectorProbability choose))
    nlinarith only [hmean, hq]
  have hpoint (ω : V → α) :
      (n:ℝ)^2*(if (selectedSet choose ω).card<n then (1:ℝ) else 0) ≤
        (((selectedSet choose ω).card:ℝ)-2*(n:ℝ))^2 := by
    by_cases hh : (selectedSet choose ω).card<n
    · rw [if_pos hh, mul_one]
      have hh' : ((selectedSet choose ω).card:ℝ)<n := by exact_mod_cast hh
      have hprod := mul_nonneg_of_nonpos_of_nonpos
        (show ((selectedSet choose ω).card:ℝ)-(n:ℝ)≤0 by linarith only [hh'])
        (show ((selectedSet choose ω).card:ℝ)-3*(n:ℝ)≤0 by linarith only [hh', hNpos])
      nlinarith only [hprod]
    · rw [if_neg hh, mul_zero]
      exact sq_nonneg _
  have hmarkov := (finiteMean_mono hpoint).trans hvar
  rw [finiteMean_mul] at hmarkov
  have hevent : finiteMean (fun ω : V → α => if (selectedSet choose ω).card<n then (1:ℝ) else 0) =
      finiteEvent (fun ω : V → α => (selectedSet choose ω).card<n) := by
    unfold finiteEvent
    congr 1
    funext ω
    split_ifs <;> rfl
  rw [hevent] at hmarkov
  have hbad : finiteEvent (fun ω : V → α => (selectedSet choose ω).card<n) ≤ (1:ℝ)/2 := by
    have hh : finiteEvent (fun ω : V → α => (selectedSet choose ω).card<n) ≤ 2/(n:ℝ) := by
      apply (le_div_iff₀ hNpos).2
      have htmp : (n:ℝ)*(finiteEvent (fun ω : V → α => (selectedSet choose ω).card<n)*(n:ℝ)) ≤ (n:ℝ)*2 := by
        nlinarith only [hmarkov]
      exact (mul_le_mul_iff_right₀ hNpos).mp htmp
    apply hh.trans
    exact (div_le_iff₀ hNpos).2 (by linarith only [hN])
  have he : finiteEvent (fun ω : V → α => n ≤ (selectedSet choose ω).card) =
      1-finiteEvent (fun ω : V → α => (selectedSet choose ω).card<n) := by
    simpa only [not_lt] using finiteEvent_compl (fun ω : V → α => (selectedSet choose ω).card<n)
  rw [he]
  linarith only [hbad]

end NeuralGeneralization.SquaredSampling
