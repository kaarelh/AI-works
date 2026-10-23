import NeuralGeneralization.BatchTwoImprovedSourceResidual
import NeuralGeneralization.BatchTwoImprovedFiniteLaw

/-! Measurable, input-independent importance sampling from the actual source
bank. Rank changes are handled in a fixed coordinate type. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set InnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry BatchTwoImprovedActiveGeometry Classical
variable {N q m : ℕ}

theorem measurable_finiteLaw {Θ α : Type*} [MeasurableSpace Θ] [Fintype α]
    [MeasurableSpace α] [MeasurableSingletonClass α]
    (p : Θ → α → ℝ) (hp : Measurable p)
    (hpos : ∀ θ i, 0 ≤ p θ i) (hmass : ∀ θ, ∑ i, p θ i=1) :
    Measurable (fun θ => finiteLaw (p θ) (hpos θ) (hmass θ)) := by
  apply Measure.measurable_of_measurable_coe
  intro S hS
  have he (θ : Θ) : finiteLaw (p θ) (hpos θ) (hmass θ) S =
      ∑ i, if i ∈ S then ENNReal.ofReal (p θ i) else 0 := by
    unfold finiteLaw
    rw [PMF.toMeasure_apply_fintype]
    apply Finset.sum_congr rfl
    intro i _
    simp only [Set.indicator_apply,PMF.ofFintype_apply]
  simp_rw [he]
  apply Finset.measurable_sum
  intro i _
  by_cases hi : i ∈ S
  · simp only [if_pos hi]
    exact ((measurable_pi_apply i).comp hp).ennreal_ofReal
  · simp only [if_neg hi]
    exact measurable_const

@[fun_prop] theorem measurable_sourceProbability :
    Measurable (sourceProbability (N:=N) (q:=q)) := by
  unfold sourceProbability sourceDenominator rowEnergy
  fun_prop

@[fun_prop] theorem measurable_sourceMultiplier :
    Measurable (sourceMultiplier (N:=N) (q:=q)) := by
  unfold sourceMultiplier sourceDenominator rowEnergy
  fun_prop

def sourceIndexKernel (hN : 0 < N) (hq : 0 < q) :
    Kernel (Fin N → Fin q → ℝ) (Fin N) where
  toFun := fun u => finiteLaw (sourceProbability u)
    (fun j => (sourceProbability_pos hN hq u j).le) (sourceProbability_mass hN hq u)
  measurable' := measurable_finiteLaw sourceProbability measurable_sourceProbability
    (fun u j => (sourceProbability_pos hN hq u j).le) (sourceProbability_mass hN hq)

instance sourceIndexKernel_markov (hN : 0 < N) (hq : 0 < q) :
    IsMarkovKernel (sourceIndexKernel hN hq) where
  isProbabilityMeasure u := by
    change IsProbabilityMeasure (finiteLaw (sourceProbability u)
      (fun j => (sourceProbability_pos hN hq u j).le) (sourceProbability_mass hN hq u))
    infer_instance

def sourceIndicesKernel (hN : 0 < N) (hq : 0 < q) (m : ℕ) :
    Kernel (Fin N → Fin q → ℝ) (Fin m → Fin N) where
  toFun := fun u => finiteLaw (iidWeight (sourceProbability u) m)
    (iidWeight_nonneg _ (fun j => (sourceProbability_pos hN hq u j).le) m)
    (iidWeight_mass _ (sourceProbability_mass hN hq u) m)
  measurable' := by
    apply measurable_finiteLaw
    unfold iidWeight
    apply measurable_pi_lambda
    intro s
    apply Finset.measurable_prod
    intro j _
    exact (measurable_pi_apply (s j)).comp measurable_sourceProbability

instance sourceIndicesKernel_markov (hN : 0 < N) (hq : 0 < q) (m : ℕ) :
    IsMarkovKernel (sourceIndicesKernel hN hq m) where
  isProbabilityMeasure u := by
    change IsProbabilityMeasure (finiteLaw (iidWeight (sourceProbability u) m)
      (iidWeight_nonneg _ (fun j => (sourceProbability_pos hN hq u j).le) m)
      (iidWeight_mass _ (sourceProbability_mass hN hq u) m))
    infer_instance

theorem sourceIndicesKernel_eq_pi (hN : 0 < N) (hq : 0 < q) (m : ℕ)
    (u : Fin N → Fin q → ℝ) :
    sourceIndicesKernel hN hq m u = Measure.pi (fun _ : Fin m => sourceIndexKernel hN hq u) := by
  apply Measure.ext_of_singleton
  intro s
  change finiteLaw (iidWeight (sourceProbability u) m)
    (iidWeight_nonneg _ (fun j => (sourceProbability_pos hN hq u j).le) m)
    (iidWeight_mass _ (sourceProbability_mass hN hq u) m) {s} = _
  rw [finiteLaw_singleton,Measure.pi_singleton]
  change ENNReal.ofReal (∏ j, sourceProbability u (s j)) = _
  rw [ENNReal.ofReal_prod_of_nonneg (fun j _ => (sourceProbability_pos hN hq u (s j)).le)]
  apply Finset.prod_congr rfl
  intro j _
  exact (finiteLaw_singleton (sourceProbability u)
    (fun j => (sourceProbability_pos hN hq u j).le) (sourceProbability_mass hN hq u) (s j)).symm

/-- For fixed active slots, bad Gram matrices form an open set: an arbitrary
real witness is an open union, not an illicit uncountable measurable union. -/
theorem isOpen_badGramOn (T : (Fin q → ℝ) → Prop) (s : Fin m → Fin N) :
    IsOpen {a : Fin N → Fin q → ℝ | badGramOn a T s} := by
  have he : {a : Fin N → Fin q → ℝ | badGramOn a T s} =
      ⋃ v : {v : Fin q → ℝ // T v ∧ (∑ k, (v k)^2)=1},
        {a | (∑ i, (linearEvaluation (a (s i)) v.val)^2) < (m:ℝ)/2} := by
    ext a
    simp only [badGramOn,mem_setOf_eq,mem_iUnion]
    constructor
    · rintro ⟨v,hT,hu,hb⟩
      exact ⟨⟨v,hT,hu⟩,hb⟩
    · rintro ⟨v,hb⟩
      exact ⟨v.val,v.property.1,v.property.2,hb⟩
  rw [he]
  apply isOpen_iUnion
  intro v
  apply isOpen_lt _ continuous_const
  unfold linearEvaluation
  fun_prop

theorem measurable_activeSlots :
    Measurable (activeSlots (N:=N) (q:=q)) := by
  apply measurable_to_countable'
  intro S
  have he : activeSlots ⁻¹' {S} =
      ⋂ k : Fin q, {b : Fin q → EuclideanSpace ℝ (Fin N) |
        (k ∈ S ↔ gramSchmidtNormed ℝ b k ≠ 0)} := by
    ext b
    simp only [mem_preimage,mem_singleton_iff,mem_iInter,mem_setOf_eq]
    rw [Finset.ext_iff]
    simp only [activeSlots,Finset.mem_filter,Finset.mem_univ,true_and]
    exact forall_congr' (fun k => iff_comm)
  rw [he]
  apply MeasurableSet.iInter
  intro k
  by_cases hk : k ∈ S
  · simp only [hk,true_iff]
    exact (measurableSet_eq_fun (measurable_gramSchmidtNormed k) measurable_const).compl
  · simp only [hk,false_iff,not_not]
    exact measurableSet_eq_fun (measurable_gramSchmidtNormed k) measurable_const

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
