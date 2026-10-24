import NeuralGeneralization.BatchTwoContinuousDepthInterpolation
import NeuralGeneralization.BatchTwoContinuousCloning

/-! Actual neural implementation of the separated-sample bump interpolant. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoNeuralConverse

/-- The two signs select the left and right edge of a soft interval. -/
def bumpCenter (δ c : ℝ) (b : Bool) : ℝ := if b then c-δ/2 else c+δ/2

def bumpWeights {n N p : ℕ} (e : ((Fin n × Bool) ⊕ Fin p) ≃ Fin N)
    (a δ : ℝ) (s v : Fin n → ℝ) : Weights 2 N 0
  | Sum.inl (i,j) => match e.symm i with
      | Sum.inl (k,b) => ![-a*bumpCenter δ (s k) b,a,0] j
      | Sum.inr _ => 0
  | Sum.inr (Sum.inl (z,_)) => Fin.elim0 z
  | Sum.inr (Sum.inr i) => match e.symm i with
      | Sum.inl (k,b) => if b then v k/2 else -v k/2
      | Sum.inr _ => 0

theorem bump_firstHidden {n N p : ℕ} (e : ((Fin n × Bool) ⊕ Fin p) ≃ Fin N)
    (a δ : ℝ) (s v : Fin n → ℝ) (x : RealInput 2) (i : Fin N) :
    BatchTwoContinuous.firstHidden Real.tanh (bumpWeights e a δ s v) x i =
      match e.symm i with
      | Sum.inl (k,b) => Real.tanh (a*(x 0-bumpCenter δ (s k) b))
      | Sum.inr _ => 0 := by
  rcases hi : e.symm i with ⟨k,b⟩|z
  · simp only [BatchTwoContinuous.firstHidden,bumpWeights,hi,Fin.sum_univ_succ,
      augmentedInput,Fin.cases_zero,Fin.cases_succ,Matrix.cons_val_zero,
      Matrix.cons_val_succ,Fin.sum_univ_zero,mul_one,zero_mul,add_zero]
    congr 1
    ring
  · simp [BatchTwoContinuous.firstHidden,bumpWeights,hi]

theorem bump_output {n N p : ℕ} (e : ((Fin n × Bool) ⊕ Fin p) ≃ Fin N)
    (a δ : ℝ) (s v : Fin n → ℝ) (x : RealInput 2) :
    output Real.tanh (bumpWeights e a δ s v) x =
      ∑ j, v j*softBump a δ (s j) (x 0) := by
  classical
  unfold output BatchTwoContinuous.finalHidden
  simp only [List.finRange_zero,List.foldl_nil]
  simp_rw [bump_firstHidden]
  let F : ((Fin n × Bool) ⊕ Fin p) → ℝ := fun z => match z with
    | Sum.inl (k,b) => (if b then v k/2 else -v k/2)*
        Real.tanh (a*(x 0-bumpCenter δ (s k) b))
    | Sum.inr _ => 0
  have he : (∑ i, bumpWeights e a δ s v (Sum.inr (Sum.inr i)) *
      (match e.symm i with
      | Sum.inl (k,b) => Real.tanh (a*(x 0-bumpCenter δ (s k) b))
      | Sum.inr _ => 0))=∑ i,F (e.symm i) := by
    apply Finset.sum_congr rfl
    intro i _
    cases hi : e.symm i <;> simp [F,bumpWeights,hi]
  rw [he,e.symm.sum_comp]
  simp only [F,Fintype.sum_sum_type,Fintype.sum_prod_type,Finset.sum_const_zero,add_zero,
    Fintype.sum_bool,Bool.false_eq_true,if_false,if_true,bumpCenter]
  apply Finset.sum_congr rfl
  intro j _
  unfold softBump
  have hleft : x 0-(s j-δ/2)=x 0-s j+δ/2 := by ring
  have hright : x 0-(s j+δ/2)=x 0-s j-δ/2 := by ring
  rw [hleft,hright]
  ring

theorem bump_readout_squared {n N p : ℕ} (e : ((Fin n × Bool) ⊕ Fin p) ≃ Fin N)
    (a δ : ℝ) (s v : Fin n → ℝ) :
    (∑ i, (bumpWeights e a δ s v (Sum.inr (Sum.inr i)))^2) =
      (∑ j, (v j)^2)/2 := by
  classical
  let F : ((Fin n × Bool) ⊕ Fin p) → ℝ := fun z => match z with
    | Sum.inl (k,b) => (if b then v k/2 else -v k/2)^2
    | Sum.inr _ => 0
  have he : (∑ i, (bumpWeights e a δ s v (Sum.inr (Sum.inr i)))^2)=∑ i,F (e.symm i) := by
    apply Finset.sum_congr rfl
    intro i _
    cases hi : e.symm i <;> simp [F,bumpWeights,hi]
  rw [he,e.symm.sum_comp,Finset.sum_div]
  simp only [F,Fintype.sum_sum_type,Fintype.sum_prod_type,Finset.sum_const_zero,add_zero,
    Fintype.sum_bool,Bool.false_eq_true,if_false,if_true]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem bump_first_squared {n N p : ℕ} (e : ((Fin n × Bool) ⊕ Fin p) ≃ Fin N)
    (a δ : ℝ) (s v : Fin n → ℝ) (hδ : |δ| ≤ 1) (hs : ∀ i, |s i| ≤ 1) :
    (∑ i, ∑ j, (bumpWeights e a δ s v (Sum.inl (i,j)))^2) ≤
      7*(n : ℝ)*a^2 := by
  classical
  let F : ((Fin n × Bool) ⊕ Fin p) → ℝ := fun z => match z with
    | Sum.inl (k,b) => (-a*bumpCenter δ (s k) b)^2+a^2
    | Sum.inr _ => 0
  have he : (∑ i, ∑ j, (bumpWeights e a δ s v (Sum.inl (i,j)))^2)=∑ i,F (e.symm i) := by
    apply Finset.sum_congr rfl
    intro i _
    rcases hi : e.symm i with ⟨k,b⟩|z
    · simp [F,bumpWeights,hi,Fin.sum_univ_succ]
    · simp [F,bumpWeights,hi]
  rw [he,e.symm.sum_comp]
  simp only [F,Fintype.sum_sum_type,Fintype.sum_prod_type,Finset.sum_const_zero,add_zero]
  calc
    _ ≤ ∑ _k : Fin n, (7 : ℝ)*a^2 := by
      apply Finset.sum_le_sum
      intro k _
      have hcenter (b : Bool) : |bumpCenter δ (s k) b| ≤ 3/2 := by
        cases b
        · simp only [bumpCenter,Bool.false_eq_true,if_false]
          have hh := abs_add_le (s k) (δ/2)
          rw [abs_div,abs_of_pos (by norm_num : (0 : ℝ)<2)] at hh
          linarith [hs k]
        · simp only [bumpCenter,if_true]
          have hh := abs_sub (s k) (δ/2)
          rw [abs_div,abs_of_pos (by norm_num : (0 : ℝ)<2)] at hh
          linarith [hs k]
      have hsq (b : Bool) : (bumpCenter δ (s k) b)^2 ≤ 9/4 := by
        have habs := abs_nonneg (bumpCenter δ (s k) b)
        nlinarith [sq_abs (bumpCenter δ (s k) b),hcenter b]
      simp only [Fintype.sum_bool]
      nlinarith [mul_le_mul_of_nonneg_left (hsq false) (sq_nonneg a),
        mul_le_mul_of_nonneg_left (hsq true) (sq_nonneg a)]
    _ = _ := by simp; ring

end NeuralGeneralization.BatchTwoContinuousDepthLower
