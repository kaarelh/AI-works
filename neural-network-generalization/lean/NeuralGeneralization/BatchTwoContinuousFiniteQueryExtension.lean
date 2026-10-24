import NeuralGeneralization.BatchTwoContinuousFiniteQueryCompression
import NeuralGeneralization.BatchTwoContinuousInputNet
import NeuralGeneralization.BatchTwoContinuousParameterGrid
import Mathlib.MeasureTheory.MeasurableSpace.Constructions
import Mathlib.Data.Fin.Embedding

/-! Measurable finite-query extension and genuine finite network codes. A
nearest query is selected measurably; only the original network's input
Lipschitz bound is needed, avoiding any circular mesh requirement. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel

variable {d q : ℕ}

def nthQuery (xs : Cube q → RealInput d) (n : ℕ) : RealInput d :=
  if h : n<Fintype.card (Cube q) then xs ((Fintype.equivFin (Cube q)).symm ⟨n,h⟩) else xs (fun _ => false)

def queryNear (xs : Cube q → RealInput d) (η : ℝ) (n : ℕ) (x : RealInput d) : Prop :=
  n<Fintype.card (Cube q) → ∀ j,|x j-nthQuery xs n j|≤η

theorem exists_queryNear (xs : Cube q → RealInput d) (η : ℝ) (x : RealInput d) :
    ∃ n,queryNear xs η n x := ⟨Fintype.card (Cube q),fun h => (Nat.lt_irrefl _ h).elim⟩

def selectedPoint (xs : Cube q → RealInput d) (η : ℝ) (x : RealInput d) : RealInput d := by
  classical
  exact nthQuery xs (Nat.find (exists_queryNear xs η x))

theorem measurable_selectedPoint (xs : Cube q → RealInput d) (η : ℝ) :
    Measurable (selectedPoint xs η) := by
  classical
  apply Measurable.find (fun _ => measurable_const) _ (exists_queryNear xs η)
  intro n
  by_cases hn : n<Fintype.card (Cube q)
  · simp only [queryNear,hn,true_implies,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro j
    exact measurableSet_le ((measurable_pi_apply j).sub_const _).abs measurable_const
  · simpa only [queryNear,hn,false_implies,Set.setOf_true] using MeasurableSet.univ

theorem selectedPoint_spec (xs : Cube q → RealInput d) (η : ℝ) (x : RealInput d)
    (hx : ∃ y,∀ j,|x j-xs y j|≤η) :
    ∃ y,selectedPoint xs η x=xs y ∧ ∀ j,|x j-xs y j|≤η := by
  classical
  obtain ⟨y,hy⟩ := hx
  let n := (Fintype.equivFin (Cube q) y).val
  have hn : n<Fintype.card (Cube q) := (Fintype.equivFin (Cube q) y).isLt
  have hq : nthQuery xs n=xs y := by
    simp only [nthQuery,dif_pos hn]
    change xs ((Fintype.equivFin (Cube q)).symm (Fintype.equivFin (Cube q) y))=xs y
    rw [Equiv.symm_apply_apply]
  have hp : queryNear xs η n x := by intro _; rw[hq]; exact hy
  have hfind : Nat.find (exists_queryNear xs η x)≤n := Nat.find_le hp
  have hf : Nat.find (exists_queryNear xs η x)<Fintype.card (Cube q) := hfind.trans_lt hn
  refine ⟨(Fintype.equivFin (Cube q)).symm ⟨Nat.find (exists_queryNear xs η x),hf⟩,?_,?_⟩
  · simp only [selectedPoint,nthQuery,dif_pos hf]
  · have hh := Nat.find_spec (exists_queryNear xs η x) hf
    simpa only [nthQuery,dif_pos hf] using hh

def extensionOutput {r M B R : ℕ} (xs : Cube q → RealInput d) (η : ℝ)
    (c : RealOutputCode d M r B R) : RealInput d → ℝ :=
  fun x => output Real.tanh (realGridWeights c) (selectedPoint xs η x)

theorem measurable_extensionOutput {r M B R : ℕ} (xs : Cube q → RealInput d) (η : ℝ)
    (c : RealOutputCode d M r B R) : Measurable (extensionOutput xs η c) :=
  (continuous_output_input tanh_continuous _).measurable.comp (measurable_selectedPoint xs η)

theorem exists_cube_surjection {I : Type*} [Fintype I] [Nonempty I] (q : ℕ)
    (hc : Fintype.card I≤Fintype.card (Cube q)) : ∃ f : Cube q → I,Function.Surjective f := by
  let e : I ↪ Cube q := (Fintype.equivFin I).toEmbedding |>.trans
    ((Fin.castLEEmb hc).trans (Fintype.equivFin (Cube q)).symm.toEmbedding)
  exact ⟨Function.invFun e,fun y => ⟨e y,Function.leftInverse_invFun e.injective y⟩⟩

theorem exists_cube_input_net (d T : ℕ) (hT : 0<T) (X : Set (RealInput d)) (hX : X.Nonempty)
    (hball : ∀ x∈X,∑ j,x j^2≤1) :
    ∃ xs : Cube (d+d*(2*T+1)+1) → RealInput d,
      (∀ y,xs y∈X) ∧ ∀ x∈X,∃ y,∀ j,|x j-xs y j|≤2/(T : ℝ) := by
  classical
  letI : Nonempty (InputCode d T) := ⟨fun _ => ⟨0,by simp⟩⟩
  have hc : Fintype.card (InputCode d T)≤Fintype.card (Cube (d+d*(2*T+1)+1)) := by
    rw [inputCode_card]
    simp only [Cube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin]
    calc
      (2*T+1)^d≤(2^(2*T+1))^d := Nat.pow_le_pow_left (Nat.le_of_lt Nat.lt_two_pow_self) _
      _ = 2^(d*(2*T+1)) := by rw[←Nat.pow_mul,Nat.mul_comm]
      _ ≤ _ := Nat.pow_le_pow_right (by omega : 0<2) (by omega)
  obtain ⟨e,he⟩ := exists_cube_surjection _ hc
  refine ⟨fun y => inputRepresentative X hX (e y),fun y => inputRepresentative_mem X hX (e y),?_⟩
  intro x hx
  obtain ⟨a,ha⟩ := inputRepresentative_close hT X hX hball x hx
  obtain ⟨y,hy⟩ := he a
  exact ⟨y,by simpa only [hy] using ha⟩

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
