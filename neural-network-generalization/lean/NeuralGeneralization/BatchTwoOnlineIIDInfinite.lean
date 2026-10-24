import NeuralGeneralization.BatchTwoOnlineIIDMeasure
import NeuralGeneralization.BatchTwoOnlineMonotone

/-! # Infinite IID cumulative posterior errors -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

lemma onlinePosterior_eq_prefix (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (s : ℕ → Fin m) (n i : ℕ) (hi : i < n) :
    onlinePosterior w good s i =
      onlinePosterior w good (extendSample m hm (sequencePrefix n s)) i := by
  unfold onlinePosterior
  congr 1
  funext g
  apply propext
  unfold history
  constructor <;> intro h j hj
  all_goals
    have hjn := hj.trans hi
    simpa only [extendSample, dif_pos hjn, sequencePrefix] using h j hj

lemma onlineError_eq_prefix (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (s : ℕ → Fin m) (n i : ℕ) (hi : i < n) :
    onlineError w good s i =
      onlineError w good (extendSample m hm (sequencePrefix n s)) i := by
  unfold onlineError
  simp only [onlinePosterior_eq_prefix hm w good s n i hi, extendSample, dif_pos hi, sequencePrefix]

lemma cumulativeError_eq_iidTotal_prefix (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (s : ℕ → Fin m) (n : ℕ) :
    cumulativeError w good s n = iidTotal hm w good (sequencePrefix n s) := by
  unfold cumulativeError iidTotal
  apply Finset.sum_congr rfl
  intro i hi
  exact onlineError_eq_prefix hm w good s n i (Finset.mem_range.mp hi)

lemma measurable_onlineError (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop) (i : ℕ) :
    Measurable (fun s : ℕ → Fin m => onlineError w good s i) := by
  have he : (fun s : ℕ → Fin m => onlineError w good s i) =
      (fun t : Fin (i+1) → Fin m => onlineError w good (extendSample m hm t) i) ∘
        sequencePrefix (i+1) := by
    funext s
    exact onlineError_eq_prefix hm w good s (i+1) i (Nat.lt_succ_self i)
  rw [he]
  exact (measurable_of_finite _).comp (measurable_sequencePrefix (i+1))

variable [NeZero m]

/-- The actual infinite IID law satisfies the same expectation bound as the
complete uniform permutation, with no coupon-collector factor. -/
theorem iid_expected_totalError_le_permutation (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target) :
    (∫⁻ s,totalError w good s ∂iidQueryLaw (Fin m)) ≤
      ENNReal.ofReal (finiteMean (permutationTotal w good)) := by
  apply infinite_expectation_le_of_prefix (iidQueryLaw (Fin m))
    (fun i s => onlineError w good s i)
    (fun i s => onlineError_nonneg w good s hw target htarget hwt i)
    (measurable_onlineError hm w good)
  intro n
  have he : (fun s : ℕ → Fin m => ENNReal.ofReal (∑ i∈Finset.range n,onlineError w good s i)) =
      (fun s => ENNReal.ofReal (iidTotal hm w good (sequencePrefix n s))) := by
    funext s
    congr 1
    exact cumulativeError_eq_iidTotal_prefix hm w good s n
  have hn (s : Fin n → Fin m) : 0 ≤ iidTotal hm w good s := by
    unfold iidTotal cumulativeError
    exact Finset.sum_nonneg (fun i _ => onlineError_nonneg w good (extendSample m hm s) hw target htarget hwt i)
  rw [he, iidQueryLaw_prefix_lintegral n (iidTotal hm w good) hn]
  exact ENNReal.ofReal_le_ofReal (expected_iidTotal_le_permutation hm w hw good target htarget hwt n)

/-- The exact upper-tail domination also passes to the entire infinite IID
stream. The extended-real total counts all rounds, including nonterminating paths. -/
theorem iid_totalError_tail_le_permutation (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (U : ℝ) (hU : 0 ≤ U) :
    iidQueryLaw (Fin m) {s | ENNReal.ofReal U < totalError w good s} ≤
      ENNReal.ofReal (finiteEvent (fun π => U < permutationTotal w good π)) := by
  apply infinite_tail_le_of_prefix (iidQueryLaw (Fin m))
    (fun i s => onlineError w good s i)
    (fun i s => onlineError_nonneg w good s hw target htarget hwt i) U hU
  intro n
  have he : {s : ℕ → Fin m | U < ∑ i∈Finset.range n,onlineError w good s i} =
      {s | U < iidTotal hm w good (sequencePrefix n s)} := by
    ext s
    simp only [Set.mem_setOf_eq]
    rw [show (∑ i∈Finset.range n,onlineError w good s i)=iidTotal hm w good (sequencePrefix n s) from
      cumulativeError_eq_iidTotal_prefix hm w good s n]
  rw [he, iidQueryLaw_prefix_event n (fun t => U < iidTotal hm w good t)]
  exact ENNReal.ofReal_le_ofReal (iidTotal_tail_le_permutation hm w hw good target htarget hwt n U)

end NeuralGeneralization.BatchTwoOnline
