import FeatureGramGluing
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

noncomputable section
open scoped BigOperators InnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {ι E F : Type*} [Fintype ι]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]

/-- Transport any readout through an exact finite Gram identification.
Projection onto the represented span can only decrease its norm. -/
theorem transport_readout_of_equal_gram (u : ι → E) (v : ι → F)
    (hgram : ∀ i j, inner ℝ (v i) (v j)=inner ℝ (u i) (u j)) (b : E) :
    ∃ c : F, ‖c‖ ≤ ‖b‖ ∧ ∀ i, inner ℝ c (v i)=inner ℝ b (u i) := by
  classical
  let f := Fintype.linearCombination ℝ u
  let g := Fintype.linearCombination ℝ v
  have hh := linearCombination_inner_of_gram_eq u v hgram
  let T := gramRangeIsometry f g hh
  refine ⟨T (f.range.orthogonalProjectionOnto b),?_,?_⟩
  · rw [T.norm_map]
    exact f.range.norm_orthogonalProjectionOnto_apply_le b
  · intro i
    let x : ι → ℝ := Pi.single i 1
    have hfx : f x=u i := by simp [f,x]
    have hgx : g x=v i := by simp [g,x]
    have hT : T ⟨f x,LinearMap.mem_range_self f x⟩=v i := by
      exact (gramRangeIsometry_image f g hh x).trans hgx
    rw [← hT,T.inner_map_map,
      Submodule.inner_orthogonalProjectionOnto_eq_of_mem_right]
    exact congrArg (inner ℝ b) hfx

/-- A readout transported from the empirical terminal Gram to the repaired
features incurs only readout norm times feature error. -/
theorem transport_readout_with_error (u : ι → E) (v w : ι → F)
    (hgram : ∀ i j, inner ℝ (v i) (v j)=inner ℝ (u i) (u j))
    (b : E) (ε : ℝ) (hvw : ∀ i, ‖v i-w i‖ ≤ ε) :
    ∃ c : F, ‖c‖ ≤ ‖b‖ ∧
      (∀ i, inner ℝ c (v i)=inner ℝ b (u i)) ∧
      ∀ i, |inner ℝ c (w i)-inner ℝ b (u i)| ≤ ‖b‖*ε := by
  obtain ⟨c,hc,hout⟩ := transport_readout_of_equal_gram u v hgram b
  refine ⟨c,hc,hout,?_⟩
  intro i
  rw [← hout i,← inner_sub_right]
  calc
    |inner ℝ c (w i-v i)| ≤ ‖c‖*‖w i-v i‖ := abs_real_inner_le_norm _ _
    _ ≤ ‖b‖*ε := by
      rw [norm_sub_rev]
      exact mul_le_mul hc (hvw i) (norm_nonneg _) (norm_nonneg _)

omit [Fintype ι] in
/-- A small uniform prediction defect is corrected by scaling the readout.
This restores the original closed margin with an explicit norm cost. -/
theorem readout_margin_repair (v : ι → F) (b : F) (f : ι → ℝ)
    (a ρ : ℝ) (ha : 0 < a) (hρa : ρ < a)
    (hmargin : ∀ i, a-ρ ≤ f i*inner ℝ b (v i)) :
    (∀ i, a ≤ f i*inner ℝ ((a/(a-ρ)) • b) (v i)) ∧
    ‖(a/(a-ρ)) • b‖^2=(a/(a-ρ))^2*‖b‖^2 := by
  have hd : 0 < a-ρ := sub_pos.mpr hρa
  constructor
  · intro i
    rw [real_inner_smul_left]
    have h := mul_le_mul_of_nonneg_left (hmargin i) (le_of_lt (div_pos ha hd))
    have hid : (a/(a-ρ))*(a-ρ)=a := div_mul_cancel₀ _ hd.ne'
    rw [hid] at h
    nlinarith
  · rw [norm_smul,Real.norm_eq_abs,abs_of_pos (div_pos ha hd),mul_pow]

/-- Scaling by the exact half-margin correction costs only a linear relative
increase when the prediction defect is at most one eighth. -/
lemma half_margin_scaling_cost (ρ : ℝ) (hρ : 0 ≤ ρ) (hρ8 : ρ ≤ 1/8) :
    (1/(1-2*ρ))^2 ≤ 1+16*ρ := by
  have hd : 0 < 1-2*ρ := by linarith
  rw [div_pow]
  apply (div_le_iff₀ (sq_pos_of_pos hd)).mpr
  have hpoly : 0 ≤ ρ*(1-8*ρ) := mul_nonneg hρ (by linarith)
  nlinarith [mul_nonneg hρ (sq_nonneg ρ)]

end ConditionalNonpolynomial.Analytic
