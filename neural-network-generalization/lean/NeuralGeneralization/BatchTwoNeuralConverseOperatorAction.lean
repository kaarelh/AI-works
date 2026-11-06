import NeuralGeneralization.BatchTwoNeuralConverseOperatorRepair
import NeuralGeneralization.BatchTwoNeuralConverseCounts

/-! Minimum action for the strict spectral learner uses its own infima. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ConcreteModel

theorem operator_supported_width_pos {d N r : ℕ} {U : ℝ} {f : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ operatorFunctionSupport U f) : 0 < N :=
  supported_width_pos w (operatorFunctionSupport_subset (by norm_num : (1:ℝ)<2) f hw)

def operator_sqrtCosts {d : ℕ} (r : ℕ) (U : ℝ) (f : BooleanFunction d) : Set ℝ :=
  {a | ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r,
    w ∈ operatorFunctionSupport U f ∧ a=Real.sqrt (weightedSquaredNorm w)}

def operator_neuralSqrtAction {d : ℕ} (r : ℕ) (U : ℝ) (f : BooleanFunction d) : ℝ :=
  sInf (operator_sqrtCosts r U f)

theorem operator_sqrtCosts_bddBelow {d : ℕ} (r : ℕ) (U : ℝ) (f : BooleanFunction d) :
    BddBelow (operator_sqrtCosts r U f) := by
  refine ⟨0,?_⟩
  rintro a ⟨N,hN,w,hw,rfl⟩
  exact Real.sqrt_nonneg _

theorem operator_exists_supported_function {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) :
    ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r, w ∈ operatorFunctionSupport U f := by
  have aux (A : Finset (Cube d)) : ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r,
      w ∈ operatorFunctionSupport U (fun x => if x∈A then f x else false) := by
    induction A using Finset.induction with
    | empty =>
      refine ⟨1,by omega,constantWeights d r (labelReal false),?_⟩
      simpa using constant_mem_operatorFunctionSupport d r false hU
    | @insert a A ha ih =>
      obtain ⟨N,hN,w,hw⟩ := ih
      obtain ⟨M,hM,u,hu,_⟩ := exists_repaired_operator_network hd hU w hw a (f a) 1 (by norm_num)
      refine ⟨M,hM,u,?_⟩
      have he : Function.update (fun x => if x∈A then f x else false) a (f a) =
          (fun x => if x∈insert a A then f x else false) := by
        funext x
        by_cases hx : x=a
        · subst x; simp
        · simp [Function.update_of_ne hx,hx]
      simpa only [he] using hu
  simpa using aux Finset.univ

theorem operator_sqrtCosts_nonempty {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) : (operator_sqrtCosts r U f).Nonempty := by
  obtain ⟨N,hN,w,hw⟩ := operator_exists_supported_function hd r hU f
  exact ⟨Real.sqrt (weightedSquaredNorm w),N,hN,w,hw,rfl⟩

theorem operator_neuralSqrtAction_nonneg {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) : 0≤operator_neuralSqrtAction r U f := by
  apply le_csInf (operator_sqrtCosts_nonempty hd r hU f)
  rintro a ⟨N,hN,w,hw,rfl⟩
  exact Real.sqrt_nonneg _

theorem operator_neuralSqrtAction_le {d N r : ℕ} {U : ℝ} {f : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ operatorFunctionSupport U f) :
    operator_neuralSqrtAction r U f≤Real.sqrt (weightedSquaredNorm w) :=
  csInf_le (operator_sqrtCosts_bddBelow r U f) ⟨N,operator_supported_width_pos w hw,w,hw,rfl⟩

theorem operator_neuralSqrtAction_repair {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (g : BooleanFunction d) (a : Cube d) (y : Bool) :
    operator_neuralSqrtAction r U (Function.update g a y) ≤
      operator_neuralSqrtAction r U g+Real.sqrt (repairBudget d r U) := by
  suffices h : operator_neuralSqrtAction r U (Function.update g a y)-Real.sqrt (repairBudget d r U) ≤
      operator_neuralSqrtAction r U g by linarith
  apply le_csInf (operator_sqrtCosts_nonempty hd r hU g)
  rintro c ⟨N,hN,w,hw,rfl⟩
  suffices hh : operator_neuralSqrtAction r U (Function.update g a y) ≤
      Real.sqrt (weightedSquaredNorm w)+Real.sqrt (repairBudget d r U) by linarith
  apply le_of_forall_pos_le_add
  intro ε hε
  obtain ⟨M,hM,u,hu,henergy⟩ := exists_repaired_operator_network hd hU w hw a y ε hε
  exact (operator_neuralSqrtAction_le u hu).trans henergy.le

theorem operator_neuralSqrtAction_constant_le {d r : ℕ} {U : ℝ} (hU : 1<U)
    (y : Bool) : operator_neuralSqrtAction (d := d) r U (fun _ => y) ≤ Real.sqrt (repairBudget d r U) := by
  have hw := constant_mem_operatorFunctionSupport d r y hU
  apply (operator_neuralSqrtAction_le _ hw).trans
  apply Real.sqrt_le_sqrt
  have hy : (labelReal y)^2=1 := by cases y <;> norm_num [labelReal]
  apply (constant_energy_bound d r (labelReal y) hy).trans
  have hQ : 0≤singletonReadoutBudget (r+1) := by unfold singletonReadoutBudget; positivity
  have hsq : (1 : ℝ)≤(U+1)^2 := by nlinarith
  have hm := mul_le_mul_of_nonneg_left hsq hQ
  unfold repairBudget
  linarith

theorem operator_neuralSqrtAction_initial_le {d : ℕ} (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) :
    minAction (operator_neuralSqrtAction r U) f ∅≤Real.sqrt (repairBudget d r U) := by
  apply (minAction_le (operator_neuralSqrtAction r U) f (fun _ => false) ∅ (by simp [Fits])).trans
  exact operator_neuralSqrtAction_constant_le hU false

/-- Actual supported-network action after complete revelation is polynomial in
the number of mistakes, with unrestricted ties among minimum-action functions. -/
theorem operator_neural_action_mistake_bound {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d)
    (query : ℕ → Cube d) (error : ℕ → Bool)
    (hsuccess : SuccessHasMinimizer (operator_neuralSqrtAction r U) f query error)
    (t : ℕ) (hcover : observed query t=Finset.univ) :
    operator_neuralSqrtAction r U f ≤ Real.sqrt (repairBudget d r U)*(errorCount error t+1 : ℝ) := by
  have h := minimum_action_complete (X := Cube d)
    (b := Real.sqrt (repairBudget d r U)) (a₀ := Real.sqrt (repairBudget d r U))
    (operator_neuralSqrtAction (d := d) r U) f query error
    (fun g a y => by
      have hh := operator_neuralSqrtAction_repair hd r hU g a y
      have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b) =
          (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
      rw [hdec] at hh
      exact hh) hsuccess (operator_neuralSqrtAction_initial_le r hU f) t hcover
  nlinarith


theorem operator_exists_supported_energy_of_action_bound {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d) {m : ℝ} (hm : 0≤m)
    (hbound : operator_neuralSqrtAction r U f≤Real.sqrt (repairBudget d r U)*(m+1)) :
    ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r, w ∈ operatorFunctionSupport U f ∧
      weightedSquaredNorm w<1+repairBudget d r U*(m+1)^2 := by
  have hP := repairBudget_pos d r U
  have hK : 0<1+repairBudget d r U*(m+1)^2 := by positivity
  have hroot : Real.sqrt (repairBudget d r U)*(m+1)<Real.sqrt (1+repairBudget d r U*(m+1)^2) := by
    have h1 := Real.sq_sqrt hP.le
    have h2 := Real.sq_sqrt hK.le
    have hn := Real.sqrt_nonneg (repairBudget d r U)
    have hk := Real.sqrt_nonneg (1+repairBudget d r U*(m+1)^2)
    nlinarith [sq_nonneg (m+1)]
  obtain ⟨c,hc,hlt⟩ := (csInf_lt_iff (operator_sqrtCosts_bddBelow r U f)
    (operator_sqrtCosts_nonempty hd r hU f)).mp (hbound.trans_lt hroot)
  obtain ⟨N,hN,w,hw,rfl⟩ := hc
  refine ⟨N,hN,w,hw,?_⟩
  have h1 := Real.sq_sqrt (weightedSquaredNorm_nonneg w)
  have h2 := Real.sq_sqrt hK.le
  nlinarith [Real.sqrt_nonneg (weightedSquaredNorm w)]


theorem operator_expected_neural_action {d : ℕ} (hd : 0<d) (r : ℕ) {U : ℝ}
    (hU : 1<U) (f : BooleanFunction d)
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (query : Ω → ℕ → Cube d) (error : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ, SuccessHasMinimizer (operator_neuralSqrtAction r U) f (query ω) (error ω))
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hcover : ∀ᵐ ω ∂μ, observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (error ω) (stop ω):ℝ)) μ) :
    operator_neuralSqrtAction r U f≤Real.sqrt (repairBudget d r U)*
      ((∫ ω,(errorCount (error ω) (stop ω):ℝ) ∂μ)+1) := by
  have hb := expected_action_bound (X:=Cube d) μ (operator_neuralSqrtAction r U) f query error stop
    (b:=Real.sqrt (repairBudget d r U)) (a₀:=Real.sqrt (repairBudget d r U))
    (fun g a y => by
      have hh := operator_neuralSqrtAction_repair hd r hU g a y
      have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b)=
          (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
      rw [hdec] at hh
      exact hh)
    hs hcover (operator_neuralSqrtAction_initial_le r hU f)
    (fresh_count_integrable μ query error stop hfresh hmeas)
  nlinarith


end
end NeuralGeneralization.BatchTwoNeuralConverse
