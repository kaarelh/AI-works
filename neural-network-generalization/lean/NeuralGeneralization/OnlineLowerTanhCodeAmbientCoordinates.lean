import NeuralGeneralization.OnlineLowerTanhCodeCoverageEquality
import NeuralGeneralization.OnlineLowerReluDebt
import NeuralGeneralization.OnlineLowerReluProjectorExpansion

/-! Exact arbitrary-ambient-coordinate conditioning for carrier codes. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

def ambientSupport {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (S : Finset (Fin n)) : Finset (Fin d) :=
  S.map ⟨fun i=>e.symm (Sum.inl i), e.symm.injective.comp Sum.inl_injective⟩

def ambientCubeEquiv {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k) :
    Cube d ≃ Cube k × Cube n where
  toFun x := (fun j=>x (e.symm (Sum.inr j)),fun i=>x (e.symm (Sum.inl i)))
  invFun y i := Sum.elim y.2 y.1 (e i)
  left_inv x := by
    funext i
    change Sum.elim (fun i=>x (e.symm (Sum.inl i)))
      (fun j=>x (e.symm (Sum.inr j))) (e i)=x i
    generalize he : e i = z
    cases z with
    | inl j => simp only [Sum.elim_inl];rw [←he,e.symm_apply_apply]
    | inr j => simp only [Sum.elim_inr];rw [←he,e.symm_apply_apply]
  right_inv y := by apply Prod.ext <;> funext i <;> simp

def ambientActiveWeights {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) : Fin n→ℝ := fun i=>u (e.symm (Sum.inl i))

def ambientExtraWeights {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) : Fin k→ℝ := fun i=>u (e.symm (Sum.inr i))

lemma ambient_energy_split {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) : incomingEnergy u =
      incomingEnergy (ambientActiveWeights e u)+incomingEnergy (ambientExtraWeights e u) := by
  unfold incomingEnergy ambientActiveWeights ambientExtraWeights
  rw [←e.symm.sum_comp (fun i=>u i^2),Fintype.sum_sum_type]

lemma ambient_linear_join {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) (y : Cube k) (z : Cube n) :
    incomingLinear u ((ambientCubeEquiv e).symm (y,z)) =
      incomingLinear (ambientActiveWeights e u) z+incomingLinear (ambientExtraWeights e u) y := by
  unfold incomingLinear ambientActiveWeights ambientExtraWeights
  rw [←e.symm.sum_comp (fun i=>u i*labelReal ((ambientCubeEquiv e).symm (y,z) i)),
    Fintype.sum_sum_type]
  simp [ambientCubeEquiv]

lemma ambient_walsh_join {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (S : Finset (Fin n)) (y : Cube k) (z : Cube n) :
    walshCharacter (ambientSupport e S) ((ambientCubeEquiv e).symm (y,z)) =
      walshCharacter S z := by
  simp [walshCharacter,ambientSupport,ambientCubeEquiv]

lemma finiteAverage_prod {α β : Type*} [Fintype α] [Fintype β]
    (f : α×β→ℝ) : finiteAverage f = finiteAverage (fun a=>finiteAverage (fun b=>f (a,b))) := by
  simp only [finiteAverage,Fintype.sum_prod_type,Fintype.card_prod,Nat.cast_mul,
    ]
  rw [←Finset.sum_div]
  ring

lemma ambient_mean_join {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k) (f : Cube d→ℝ) :
    finiteAverage f=finiteAverage (fun y:Cube k=>finiteAverage (fun z:Cube n=>
      f ((ambientCubeEquiv e).symm (y,z)))) := by
  rw [←finiteAverage_equiv (ambientCubeEquiv e).symm f,finiteAverage_prod]

lemma ambient_coefficient_conditioned {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (S : Finset (Fin n)) (b : ℝ) (u : Fin d→ℝ) :
    walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) (ambientSupport e S)=
      finiteAverage (fun y:Cube k=>walshCoefficients (fun z=>Real.tanh
        ((b+incomingLinear (ambientExtraWeights e u) y)+incomingLinear (ambientActiveWeights e u) z)) S) := by
  change finiteAverage _ = _
  rw [ambient_mean_join e]
  apply congrArg finiteAverage
  funext y
  change finiteAverage _ = finiteAverage _
  apply congrArg finiteAverage
  funext z
  dsimp only
  rw [ambient_linear_join,ambient_walsh_join]
  congr 2
  ring

def ambientCarrierCodeMass {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (b : ℝ) (u : Fin d→ℝ) : ℝ :=
  ∑θ∈A,carrierBalancedCost size θ*|walshCoefficients
    (fun x=>Real.tanh (b+incomingLinear u x)) (ambientSupport e (carrierTransversal size θ))|

lemma ambient_codeMass_le_conditioned {p d k : ℕ} (size : Fin p→Bool→ℕ)
    (e : Fin d ≃ Fin (carrierDimension size) ⊕ Fin k)
    (A : Finset (Fin p→Bool)) (b : ℝ) (u : Fin d→ℝ) :
    ambientCarrierCodeMass size e A b u ≤ finiteAverage (fun y:Cube k=>
      carrierCodeMass size A (carrierBalancedCost size)
        (b+incomingLinear (ambientExtraWeights e u) y) (ambientActiveWeights e u)) := by
  unfold ambientCarrierCodeMass carrierCodeMass
  simp_rw [ambient_coefficient_conditioned]
  have ha (f : Cube k→ℝ) : |finiteAverage f|≤finiteAverage (fun y=>|f y|) := by
    unfold finiteAverage
    rw [abs_div,abs_of_nonneg (by positivity : 0≤(Fintype.card (Cube k):ℝ))]
    exact div_le_div_of_nonneg_right (Finset.abs_sum_le_sum_abs _ _) (by positivity)
  have hh:=Finset.sum_le_sum (s:=A) (fun θ _=>mul_le_mul_of_nonneg_left
    (ha (fun y=>walshCoefficients (fun z=>Real.tanh
      ((b+incomingLinear (ambientExtraWeights e u) y)+incomingLinear (ambientActiveWeights e u) z))
      (carrierTransversal size θ))) (carrierBalancedCost_pos size θ).le)
  refine hh.trans_eq ?_
  simp_rw [←finiteAverage_mul_left]
  unfold finiteAverage
  simp only [Finset.sum_div]
  rw [Finset.sum_comm]

lemma ambient_selected_energy {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) (S : Finset (Fin n)) :
    (∑i∈ambientSupport e S,u i^2)=∑i∈S,(ambientActiveWeights e u i)^2 := by
  simp [ambientSupport,ambientActiveWeights]

lemma ambient_outside_energy {d n k : ℕ} (e : Fin d ≃ Fin n ⊕ Fin k)
    (u : Fin d→ℝ) (S : Finset (Fin n)) :
    (∑i∈(ambientSupport e S)ᶜ,u i^2)=
      incomingEnergy (ambientExtraWeights e u)+∑i∈Sᶜ,(ambientActiveWeights e u i)^2 := by
  have h1:=Finset.sum_add_sum_compl (ambientSupport e S) (fun i=>u i^2)
  have h2:=Finset.sum_add_sum_compl S (fun i=>(ambientActiveWeights e u i)^2)
  rw [ambient_selected_energy] at h1
  change _=incomingEnergy u at h1
  rw [ambient_energy_split e] at h1
  change _=incomingEnergy (ambientActiveWeights e u) at h2
  linarith
end NeuralGeneralization.OnlineLowerTanh
