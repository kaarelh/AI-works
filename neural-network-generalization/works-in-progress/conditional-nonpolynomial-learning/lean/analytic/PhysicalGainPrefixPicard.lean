import PhysicalGainPrefixDynamics

noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def affineBase (M : GainPrefixDynamics P S states J) (x : Cube d) (j : ℕ) :=
  propagation M.linear j 0 (M.state x 0)
def propagator (M : GainPrefixDynamics P S states J) (j i : ℕ) := propagation M.linear j (i+1)
def iterate (M : GainPrefixDynamics P S states J) (x : Cube d) :=
  picard (M.affineBase x) M.propagator M.residual

lemma propagator_contracts (M : GainPrefixDynamics P S states J) (j i : ℕ) :
    ‖M.propagator j i‖≤1 := propagation_contracts _ M.linear_contracts j (i+1)

lemma state_volterra (M : GainPrefixDynamics P S states J) (x : Cube d) (j : ℕ) :
    M.state x j=volterra (M.affineBase x) M.propagator M.residual (M.state x) j :=
  sequential_eq_volterra _ _ _ (M.recursion x) j

lemma normalized_feature_norm (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d) (j : ℕ) (hj : j≤J) :
    ‖(physicalGainProduct P j)⁻¹ • (states j).feature x‖≤2 := by
  classical
  induction j with
  | zero => simpa only [physicalGainProduct_zero,inv_one,one_smul] using hinit x
  | succ j ih =>
    have hjlt : j<J := by omega
    rw [M.normalized_feature_recursion j hjlt x]
    let L := M.model.layer ⟨j,lt_of_lt_of_le hjlt M.length_le⟩
    have hh := L.gainValue_lipschitz (M.inputScale_pos j)
      ((physicalGainProduct P j)⁻¹ • (states j).feature x) 0
    rw [L.gainValue_zero,sub_zero,sub_zero] at hh
    exact hh.trans (ih (by omega))

lemma state_norm_le (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d) (j : ℕ) : ‖M.state x j‖≤2 := by
  unfold state
  split_ifs with hj
  · rw [LinearIsometry.norm_map]
    exact M.normalized_feature_norm hinit x j hj
  · norm_num

lemma affineBase_norm_le (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d) (j : ℕ) : ‖M.affineBase x j‖≤2 := by
  have hh := (propagation M.linear j 0).le_opNorm (M.state x 0)
  exact hh.trans ((mul_le_mul (propagation_contracts _ M.linear_contracts j 0)
    (M.state_norm_le hinit x 0) (norm_nonneg _) (by norm_num)).trans_eq (one_mul _))

lemma affineBase_error (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d) (j : ℕ) :
    ‖M.affineBase x j-M.state x j‖≤4 := by
  have hh := (norm_sub_le _ _).trans (add_le_add (M.affineBase_norm_le hinit x j) (M.state_norm_le hinit x j))
  norm_num at hh ⊢
  exact hh

lemma iterate_error (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d) (k : ℕ) :
    ‖M.iterate x k J-M.state x J‖≤4*M.nonlinearBudget^k/(k.factorial:ℝ) := by
  exact picard_factorial_error (M.affineBase x) M.propagator M.residual M.nonlinearGain
    M.nonlinearGain_nonneg (fun j i _=>M.propagator_contracts j i) M.residual_lipschitz
    (M.state x) (M.state_volterra x) (by norm_num) (M.affineBase_error hinit x) k J

lemma rounded_iterate_error (M : GainPrefixDynamics P S states J)
    (hinit : ∀x,‖(states 0).feature x‖≤2) (x : Cube d)
    (u : ℕ→ℕ→PrefixAmbient states J) {δ : ℝ} (hδ : 0≤δ)
    (hzero : ∀j≤J,‖u 0 j-M.affineBase x j‖≤δ)
    (hupdate : ∀k j,j≤J→‖u (k+1) j-volterra (M.affineBase x) M.propagator M.residual (u k) j‖≤δ)
    (k : ℕ) : ‖u k J-M.state x J‖≤
      4*M.nonlinearBudget^k/(k.factorial:ℝ)+δ*Real.exp M.nonlinearBudget := by
  exact inexact_picard_factorial_error_rounded_finite J (M.affineBase x) M.propagator M.residual
    M.nonlinearGain M.nonlinearGain_nonneg (fun j i _=>M.propagator_contracts j i)
    M.residual_lipschitz (M.state x) (fun j _=>M.state_volterra x j)
    (by norm_num) hδ (fun j _=>M.affineBase_error hinit x j) u hzero hupdate k J le_rfl

lemma initial_norm_from_gram (hd : 1≤d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) :
    ∀x,‖(states 0).feature x‖≤2 := by
  intro x
  have hh := hzero x x
  simp only [real_inner_self_eq_norm_sq] at hh
  have hb := normalizedInputFeature_norm_sq_le_two hd x
  nlinarith [norm_nonneg ((states 0).feature x)]

lemma initial_linear_map (M : GainPrefixDynamics P S states J)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) :
    ∃T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]PrefixAmbient states J,
      ‖T‖≤1 ∧ ∀x,T (normalizedInputFeature d x)=M.state x 0 := by
  obtain ⟨T,hT,he⟩ := equal_gram_contraction (normalizedInputFeature d) (states 0).feature hzero
  let emb := blockEmbedding (fun k:Fin (J+1)=>EuclideanSpace ℝ (states k).Index) ⟨0,by omega⟩
  refine ⟨emb.toContinuousLinearMap.comp T,?_,?_⟩
  · apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
    intro v
    change ‖emb (T v)‖≤1*‖v‖
    rw [emb.norm_map]
    exact (T.le_opNorm v).trans (mul_le_mul_of_nonneg_right hT (norm_nonneg _))
  · intro x
    simp only [ContinuousLinearMap.comp_apply,LinearIsometry.coe_toContinuousLinearMap,he]
    simp only [state,dif_pos (Nat.zero_le J),physicalGainProduct_zero,inv_one,one_smul]
    rfl

#print axioms rounded_iterate_error
#print axioms initial_linear_map
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
