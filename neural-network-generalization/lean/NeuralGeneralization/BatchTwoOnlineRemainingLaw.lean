import NeuralGeneralization.BatchTwoOnlineRawPosteriorControl

/-! The exact uniform measure on the remaining positions of a permutation. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {m : ℕ}

def remainingWeight (i j : Fin m) : ℝ := if i.val≤j.val then 1/(m-i.val : ℕ) else 0

theorem remainingWeight_nonneg (i j : Fin m) : 0 ≤ remainingWeight i j := by
  unfold remainingWeight
  split_ifs <;> positivity

theorem remainingWeight_sum (i : Fin m) : ∑ j,remainingWeight i j=1 := by
  have hm : ((m-i.val : ℕ) : ℝ)≠0 := by exact_mod_cast (Nat.sub_pos_of_lt i.isLt).ne'
  have he : (∑ j,remainingWeight i j)=(∑ j : Fin m,if i.val≤j.val then (1 : ℝ) else 0)/(m-i.val : ℕ) := by
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro j _
    unfold remainingWeight
    split_ifs <;> simp
  rw [he,remaining_count i.val i.isLt.le,div_self hm]

def remainingLaw (i : Fin m) : Measure (Fin m) :=
  finiteWeightLaw (remainingWeight i) (remainingWeight_nonneg i) (remainingWeight_sum i)

instance remainingLaw_probability (i : Fin m) : IsProbabilityMeasure (remainingLaw i) :=
  finiteWeightLaw_probability _ _ _

theorem remainingLaw_integral (i : Fin m) (F : Fin m → ℝ) :
    (∫ j,F j ∂remainingLaw i)=(∑ j : Fin m,if i.val≤j.val then F j else 0)/(m-i.val : ℕ) := by
  rw [integral_fintype (RobustStatistics.integrable_finite_domain (remainingLaw i) F),Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  change (finiteWeightLaw (remainingWeight i) (remainingWeight_nonneg i) (remainingWeight_sum i)).real {j}*F j=_
  rw [Measure.real,finiteWeightLaw_singleton,ENNReal.toReal_ofReal (remainingWeight_nonneg i j)]
  unfold remainingWeight
  split_ifs <;> simp <;> ring

variable {H : Type*} [Fintype H]

theorem remainingLaw_comparison_integral (i : Fin m) (π : Equiv.Perm (Fin m))
    (f : Fin m → Bool) (g : H → Fin m → ℝ) (c : H) :
    (∫ j,BatchTwoMerging.comparisonLoss (f ∘ π) (fun c => g c ∘ π) c j ∂remainingLaw i)=
      remainingLoss (fun c x => 11/32 < ConcreteModel.labelReal (f x)*ConcreteModel.clippedScore (g c x))
        π i.val c := by
  rw [remainingLaw_integral]
  unfold remainingLoss
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  by_cases hj : i.val≤j.val
  · simp only [if_pos hj,BatchTwoMerging.comparisonLoss,pointLoss,Function.comp_def]
    split_ifs <;> simp_all <;> linarith
  · simp [hj]

end NeuralGeneralization.BatchTwoOnlineRaw
