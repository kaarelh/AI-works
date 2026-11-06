import NeuralGeneralization.BatchTwoNeuralConverseOperatorModel
import NeuralGeneralization.BatchTwoNeuralConverseParallel
import NeuralGeneralization.BatchTwoNeuralConverseWidthLimit

/-! Strict spectral support is preserved by actual cloning and direct sums. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical ConcreteModel

variable {d C N r k p : ℕ}

def cloneAverage (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (x : Fin N → ℝ) : Fin C → ℝ :=
  fun a => (∑ c : Fin k, x (e (Sum.inl (a,c))))/(k:ℝ)

lemma cloneAverage_energy (hk : 0 < k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (x : Fin N → ℝ) : (k:ℝ)*(∑ a, (cloneAverage e x a)^2) ≤ ∑ i, (x i)^2 := by
  have hkR : (0:ℝ) < k := by exact_mod_cast hk
  have hrow (a : Fin C) : (k:ℝ)*(cloneAverage e x a)^2 ≤ ∑ c, (x (e (Sum.inl (a,c))))^2 := by
    have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun _ : Fin k => (1:ℝ)) (fun c => x (e (Sum.inl (a,c))))
    simp only [one_mul,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one] at hc
    have he : (k:ℝ)*(cloneAverage e x a)^2=(∑ c, x (e (Sum.inl (a,c))))^2/(k:ℝ) := by
      unfold cloneAverage
      field_simp
    rw [he]
    exact (div_le_iff₀ hkR).mpr (by nlinarith)
  rw [Finset.mul_sum]
  apply (Finset.sum_le_sum fun a _ => hrow a).trans
  have he : (∑ i, (x i)^2) =
      (∑ a, ∑ c, (x (e (Sum.inl (a,c))))^2)+(∑ b, (x (e (Sum.inr b)))^2) := by
    rw [← e.sum_comp (fun i => (x i)^2)]
    simp only [Fintype.sum_sum_type,Fintype.sum_prod_type]
  rw [he]
  exact le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _)

lemma cloned_internal_action (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) (x : Fin N → ℝ) (i : Fin N) :
    (∑ j, clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))*x j) =
      match e.symm i with
      | Sum.inl (a,_) => ∑ b, w (Sum.inr (Sum.inl (s,a,b)))*cloneAverage e x b
      | Sum.inr _ => 0 := by
  cases hi : e.symm i with
  | inr b => simp [clonedWeights,hi]
  | inl ac =>
    have he : (∑ j, clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))*x j) =
        ∑ b, ∑ c, (w (Sum.inr (Sum.inl (s,ac.1,b)))/(k:ℝ))*x (e (Sum.inl (b,c))) := by
      rw [← e.sum_comp (fun j => clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))*x j)]
      simp [clonedWeights,hi,Fintype.sum_prod_type]
    rw [he]
    apply Finset.sum_congr rfl
    intro b _
    simp only [cloneAverage,← Finset.mul_sum]
    ring

/-- The usual divide-outgoing-weights cloning cannot increase any internal
Euclidean operator norm, including when disconnected padding is present. -/
theorem internalOperator_cloned_le (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) (s : Fin r) :
    ‖internalOperator (clonedWeights e w) s‖ ≤ ‖internalOperator w s‖ := by
  apply (matrixOperator_norm_le_iff _ (norm_nonneg (internalOperator w s))).mpr
  intro x
  have he : (∑ i, (∑ j, clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))*x j)^2) =
      (k:ℝ)*∑ a, (∑ b, w (Sum.inr (Sum.inl (s,a,b)))*cloneAverage e x b)^2 := by
    simp_rw [cloned_internal_action]
    convert sum_copies e (fun a => (∑ b, w (Sum.inr (Sum.inl (s,a,b)))*cloneAverage e x b)^2) using 1
    apply Finset.sum_congr rfl
    intro i _
    cases hi : e.symm i <;> simp [hi]
  rw [he]
  have hw := coordinateMatrix_action_squared_le
    (fun ab : Fin C × Fin C => w (Sum.inr (Sum.inl (s,ab.1,ab.2))))
    ‖internalOperator w s‖ (norm_nonneg _) le_rfl (cloneAverage e x)
  calc
    _ ≤ (k:ℝ)*(‖internalOperator w s‖^2*∑ a, (cloneAverage e x a)^2) :=
      mul_le_mul_of_nonneg_left hw (Nat.cast_nonneg _)
    _ = ‖internalOperator w s‖^2*((k:ℝ)*∑ a, (cloneAverage e x a)^2) := by ring
    _ ≤ _ := mul_le_mul_of_nonneg_left (cloneAverage_energy hk e x) (sq_nonneg _)

theorem operatorContractive_cloned (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r)
    (hw : operatorContractive w) : operatorContractive (clonedWeights e w) :=
  fun s => (internalOperator_cloned_le hk e w s).trans_lt (hw s)

theorem operatorFunctionSupport_cloned (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r)
    {U : ℝ} {f : BooleanFunction d} (hw : w ∈ operatorFunctionSupport U f) :
    clonedWeights e w ∈ operatorFunctionSupport U f := by
  refine ⟨⟨?_,operatorContractive_cloned hk e w hw.1.2⟩,?_⟩
  · intro x
    simpa only [networkOutput_cloned hk] using hw.1.1 x
  · exact (marginEvent_cloned_iff hk Real.tanh e w (1/2) f).mpr hw.2

theorem operator_paddedClone_supported (hC : 0 < C) (hCN : C ≤ N) (w : Weights d C r)
    {U : ℝ} {f : BooleanFunction d} (hw : w ∈ operatorFunctionSupport U f) :
    paddedClone hC N w ∈ operatorFunctionSupport U f :=
  operatorFunctionSupport_cloned (Nat.div_pos hCN hC) (paddedCloneEquiv C N hC) w hw

variable {n m : ℕ}

lemma direct_internal_action (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (s : Fin r) (x : Fin N → ℝ) :
    (fun i => ∑ j, directWeights e w v (Sum.inr (Sum.inl (s,i,j)))*x j) =
      directVector e
        (fun a => ∑ b, w (Sum.inr (Sum.inl (s,a,b)))*x (e (Sum.inl b)))
        (fun a => ∑ b, v (Sum.inr (Sum.inl (s,a,b)))*x (e (Sum.inr b))) := by
  have hx : x = directVector e (fun a => x (e (Sum.inl a))) (fun a => x (e (Sum.inr a))) := by
    funext i
    have hei := e.apply_symm_apply i
    cases hi : e.symm i <;> simp only [hi] at hei <;> simp [directVector,hi,hei]
  have he := hiddenStep_direct (fun z : ℝ => z) e w v
    (fun a => x (e (Sum.inl a))) (fun a => x (e (Sum.inr a))) s
  rw [← hx] at he
  exact he

/-- A block diagonal parallel network has the maximum of its branch norms
as an upper bound, so the strict support is closed under parallel repair. -/
theorem internalOperator_direct_le (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r) (s : Fin r) :
    ‖internalOperator (directWeights e w v) s‖ ≤
      max ‖internalOperator w s‖ ‖internalOperator v s‖ := by
  let B := max ‖internalOperator w s‖ ‖internalOperator v s‖
  have hB : 0 ≤ B := le_trans (norm_nonneg _) (le_max_left _ _)
  apply (matrixOperator_norm_le_iff _ hB).mpr
  intro x
  have he := congrArg (fun z : Fin N → ℝ => ∑ i, (z i)^2) (direct_internal_action e w v s x)
  have hs (a : Fin n → ℝ) (b : Fin m → ℝ) :
      (∑ i, (directVector e a b i)^2)=(∑ i, (a i)^2)+(∑ i, (b i)^2) := by
    have hf : (fun i => (directVector e a b i)^2) = directVector e (fun i => (a i)^2) (fun i => (b i)^2) := by
      funext i
      cases hi : e.symm i <;> simp [directVector,hi]
    rw [hf,sum_direct]
  rw [he,hs]
  have hw := coordinateMatrix_action_squared_le
    (fun ab : Fin n × Fin n => w (Sum.inr (Sum.inl (s,ab.1,ab.2)))) B hB (le_max_left _ _)
    (fun a => x (e (Sum.inl a)))
  have hv := coordinateMatrix_action_squared_le
    (fun ab : Fin m × Fin m => v (Sum.inr (Sum.inl (s,ab.1,ab.2)))) B hB (le_max_right _ _)
    (fun a => x (e (Sum.inr a)))
  have hx : (∑ i, (x i)^2) = (∑ a, (x (e (Sum.inl a)))^2)+(∑ a, (x (e (Sum.inr a)))^2) := by
    rw [← e.sum_comp (fun i => (x i)^2),Fintype.sum_sum_type]
  rw [hx,mul_add]
  exact add_le_add hw hv

theorem operatorContractive_direct (e : (Fin n ⊕ Fin m) ≃ Fin N)
    (w : Weights d n r) (v : Weights d m r)
    (hw : operatorContractive w) (hv : operatorContractive v) :
    operatorContractive (directWeights e w v) :=
  fun s => (internalOperator_direct_le e w v s).trans_lt (max_lt (hw s) (hv s))

end
end NeuralGeneralization.BatchTwoNeuralConverse
