import NeuralGeneralization.BatchTwoActivationSourceTransport
import NeuralGeneralization.BatchTwoActivationWeightedFeatures

/-! Final readout reconstruction with no covariance eigenvalue assumption. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel
variable {I E : Type*} [Fintype I] [DecidableEq I]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem exists_energy_source_certificate (a : I → E) (u : E) {K η : ℝ}
    (hK : 0<K) (hη : 0<η) (hu : ‖u‖^2≤K) :
    ∃β : I → ℝ, (∑i,|β i|)≤K/(4*η) ∧
      ∀i, |(∑j,β j*sourceGram a i j)-inner ℝ (a i) u|≤η := by
  let R := Real.sqrt K
  have hR : 0<R := Real.sqrt_pos.mpr hK
  have hR2 : R^2=K := Real.sq_sqrt hK.le
  have huR : ‖u‖≤R := by nlinarith [norm_nonneg u]
  have hunit : ‖R⁻¹ • u‖≤1 := by
    rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hR]
    have hh := mul_le_mul_of_nonneg_left huR (inv_nonneg.mpr hR.le)
    simpa only [inv_mul_cancel₀ hR.ne'] using hh
  obtain ⟨β,hβ,hn,hcert⟩ := exists_source_l1_certificate a (R⁻¹ • u) hunit (div_pos hη hR)
  refine ⟨fun i => R*β i,?_,?_⟩
  · simp only [abs_mul,abs_of_pos hR,←Finset.mul_sum]
    have hh := mul_le_mul_of_nonneg_left hβ hR.le
    apply hh.trans_eq
    field_simp
    nlinarith
  · intro i
    have hh := hcert i
    simp only [inner_sum,real_inner_smul_right] at hh
    have hm := mul_le_mul_of_nonneg_left hh hR.le
    have he : (∑j,R*β j*sourceGram a i j)-inner ℝ (a i) u =
        R*((∑j,β j*inner ℝ (a i) (a j))-R⁻¹*inner ℝ (a i) u) := by
      simp only [Finset.mul_sum,sourceGram,mul_sub]
      have hi : R*(R⁻¹*inner ℝ (a i) u)=inner ℝ (a i) u := by field_simp
      rw [hi]
      congr 1
      apply Finset.sum_congr rfl
      intro j hj
      ring
    rw [he,abs_mul,abs_of_pos hR]
    apply hm.trans_eq
    field_simp

theorem exists_stable_energy_source_certificate (a : I → E) (u : E) {K η : ℝ}
    (hK : 0<K) (hη : 0<η) (hu : ‖u‖^2≤K) :
    ∃β : I → ℝ, (∑i,|β i|)≤K/(4*η) ∧
      ∀Q' : I → I → ℝ, ∀e : ℝ, 0≤e → (∀i j,|Q' i j-sourceGram a i j|≤e) →
        ∀i, |(∑j,β j*Q' i j)-inner ℝ (a i) u|≤η+e*K/(4*η) := by
  obtain ⟨β,hβ,hcert⟩ := exists_energy_source_certificate a u hK hη hu
  refine ⟨β,hβ,?_⟩
  intro Q' e he hQ i
  have hm := matrix_action_perturbation (sourceGram a) Q' β hQ i
  have ht := abs_sub_le (∑j,β j*Q' i j) (∑j,β j*sourceGram a i j) (inner ℝ (a i) u)
  have hb := mul_le_mul_of_nonneg_left hβ he
  have hc := hcert i
  apply (ht.trans (add_le_add (hm.trans hb) hc)).trans_eq
  ring

/-- A strict original half-margin remains strict after reconstructing the
readout and multiplying it by two. -/
theorem energy_certificate_preserves_margin (a : I → E) (u : E) {K η e : ℝ}
    (hK : 0<K) (hη : 0<η) (he : 0≤e) (hu : ‖u‖^2≤K)
    (f : I → Bool) (hf : ∀i,(1/2:ℝ)<labelReal (f i)*inner ℝ (a i) u)
    (hbudget : η+e*K/(4*η)≤1/4) :
    ∃β : I → ℝ, (∑i,|β i|)≤K/(4*η) ∧
      ∀Q' : I → I → ℝ, (∀i j,|Q' i j-sourceGram a i j|≤e) → ∀i,
        (1/2:ℝ)<labelReal (f i)*(2*(∑j,β j*Q' i j)) := by
  obtain ⟨β,hβ,hcert⟩ := exists_stable_energy_source_certificate a u hK hη hu
  refine ⟨β,hβ,?_⟩
  intro Q' hQ i
  have hh := (hcert Q' e he hQ i).trans hbudget
  have hi := hf i
  rcases abs_le.mp hh with ⟨hlo,hhi⟩
  cases hfi : f i <;> simp only [hfi,labelReal] at hi ⊢ <;> norm_num at hi ⊢ <;> linarith

end NeuralGeneralization.BatchTwoActivation
