import NeuralGeneralization.BatchTwoNeuralConverseRepair
import NeuralGeneralization.BatchTwoNeuralConverseAction

/-! The minimum-action potential for actual gain-restricted neural networks. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set
open ConcreteModel

def sqrtCosts {d : ℕ} (r : ℕ) (Λ U : ℝ) (f : BooleanFunction d) : Set ℝ :=
  {a | ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r,
    w ∈ functionSupport Λ U f ∧ a=Real.sqrt (weightedSquaredNorm w)}

def neuralSqrtAction {d : ℕ} (r : ℕ) (Λ U : ℝ) (f : BooleanFunction d) : ℝ :=
  sInf (sqrtCosts r Λ U f)

theorem sqrtCosts_bddBelow {d : ℕ} (r : ℕ) (Λ U : ℝ) (f : BooleanFunction d) :
    BddBelow (sqrtCosts r Λ U f) := by
  refine ⟨0,?_⟩
  rintro a ⟨N,hN,w,hw,rfl⟩
  exact Real.sqrt_nonneg _

theorem exists_supported_function {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) :
    ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r, w ∈ functionSupport Λ U f := by
  have aux (A : Finset (Cube d)) : ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r,
      w ∈ functionSupport Λ U (fun x => if x∈A then f x else false) := by
    induction A using Finset.induction with
    | empty =>
      refine ⟨1,by omega,constantWeights d r (labelReal false),?_⟩
      simpa using constant_mem_functionSupport d r false hΛ hU
    | @insert a A ha ih =>
      obtain ⟨N,hN,w,hw⟩ := ih
      obtain ⟨M,hM,u,hu,_⟩ := exists_repaired_network hd hΛ hU w hw a (f a) 1 (by norm_num)
      refine ⟨M,hM,u,?_⟩
      have he : Function.update (fun x => if x∈A then f x else false) a (f a) =
          (fun x => if x∈insert a A then f x else false) := by
        funext x
        by_cases hx : x=a
        · subst x; simp
        · simp [Function.update_of_ne hx,hx]
      simpa only [he] using hu
  simpa using aux Finset.univ

theorem sqrtCosts_nonempty {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) : (sqrtCosts r Λ U f).Nonempty := by
  obtain ⟨N,hN,w,hw⟩ := exists_supported_function hd r hΛ hU f
  exact ⟨Real.sqrt (weightedSquaredNorm w),N,hN,w,hw,rfl⟩

theorem neuralSqrtAction_nonneg {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) : 0≤neuralSqrtAction r Λ U f := by
  apply le_csInf (sqrtCosts_nonempty hd r hΛ hU f)
  rintro a ⟨N,hN,w,hw,rfl⟩
  exact Real.sqrt_nonneg _

theorem neuralSqrtAction_le {d N r : ℕ} {Λ U : ℝ} {f : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ functionSupport Λ U f) :
    neuralSqrtAction r Λ U f≤Real.sqrt (weightedSquaredNorm w) :=
  csInf_le (sqrtCosts_bddBelow r Λ U f) ⟨N,supported_width_pos w hw,w,hw,rfl⟩

theorem neuralSqrtAction_repair {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (g : BooleanFunction d) (a : Cube d) (y : Bool) :
    neuralSqrtAction r Λ U (Function.update g a y) ≤
      neuralSqrtAction r Λ U g+Real.sqrt (repairBudget d r U) := by
  suffices h : neuralSqrtAction r Λ U (Function.update g a y)-Real.sqrt (repairBudget d r U) ≤
      neuralSqrtAction r Λ U g by linarith
  apply le_csInf (sqrtCosts_nonempty hd r hΛ hU g)
  rintro c ⟨N,hN,w,hw,rfl⟩
  suffices hh : neuralSqrtAction r Λ U (Function.update g a y) ≤
      Real.sqrt (weightedSquaredNorm w)+Real.sqrt (repairBudget d r U) by linarith
  apply le_of_forall_pos_le_add
  intro ε hε
  obtain ⟨M,hM,u,hu,henergy⟩ := exists_repaired_network hd hΛ hU w hw a y ε hε
  exact (neuralSqrtAction_le u hu).trans henergy.le

theorem neuralSqrtAction_constant_le {d r : ℕ} {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (y : Bool) : neuralSqrtAction (d := d) r Λ U (fun _ => y) ≤ Real.sqrt (repairBudget d r U) := by
  have hw := constant_mem_functionSupport d r y hΛ hU
  apply (neuralSqrtAction_le _ hw).trans
  apply Real.sqrt_le_sqrt
  have hy : (labelReal y)^2=1 := by cases y <;> norm_num [labelReal]
  apply (constant_energy_bound d r (labelReal y) hy).trans
  have hQ : 0≤singletonReadoutBudget (r+1) := by unfold singletonReadoutBudget; positivity
  have hsq : (1 : ℝ)≤(U+1)^2 := by nlinarith
  have hm := mul_le_mul_of_nonneg_left hsq hQ
  unfold repairBudget
  linarith

theorem neuralSqrtAction_initial_le {d : ℕ} (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) :
    minAction (neuralSqrtAction r Λ U) f ∅≤Real.sqrt (repairBudget d r U) := by
  apply (minAction_le (neuralSqrtAction r Λ U) f (fun _ => false) ∅ (by simp [Fits])).trans
  exact neuralSqrtAction_constant_le hΛ hU false

/-- Actual supported-network action after complete revelation is polynomial in
the number of mistakes, with unrestricted ties among minimum-action functions. -/
theorem neural_action_mistake_bound {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d)
    (query : ℕ → Cube d) (error : ℕ → Bool)
    (hsuccess : SuccessHasMinimizer (neuralSqrtAction r Λ U) f query error)
    (t : ℕ) (hcover : observed query t=Finset.univ) :
    neuralSqrtAction r Λ U f ≤ Real.sqrt (repairBudget d r U)*(errorCount error t+1 : ℝ) := by
  have h := minimum_action_complete (X := Cube d)
    (b := Real.sqrt (repairBudget d r U)) (a₀ := Real.sqrt (repairBudget d r U))
    (neuralSqrtAction (d := d) r Λ U) f query error
    (fun g a y => by
      have hh := neuralSqrtAction_repair hd r hΛ hU g a y
      have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b) =
          (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
      rw [hdec] at hh
      exact hh) hsuccess (neuralSqrtAction_initial_le r hΛ hU f) t hcover
  nlinarith

end
end NeuralGeneralization.BatchTwoNeuralConverse
