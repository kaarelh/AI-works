import NeuralGeneralization.BatchTwoActivationProductNormalizationEnergy

/-! Exact finite positive layer balancing, with no optimization premise. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

/-- Positive factors of product one equalize all squared layer norms at
the geometric mean, including the dimension-one case. -/
theorem exists_balancing_factors {ι : Type*} [Fintype ι] [Nonempty ι]
    (e : ι→ℝ) (he : ∀i,0<e i) :
    ∃b : ι→ℝ,(∀i,0<b i) ∧ (∏i,b i)=1 ∧
      ∀i,(b i)^2*e i=(∏j,e j)^((Fintype.card ι:ℝ)⁻¹) := by
  classical
  let g := (∏j,e j)^((Fintype.card ι:ℝ)⁻¹)
  have hep : 0<∏j,e j := Finset.prod_pos (fun i _=>he i)
  have hg : 0<g := Real.rpow_pos_of_pos hep _
  let b : ι→ℝ := fun i=>Real.sqrt (g/e i)
  have hb : ∀i,0<b i := fun i=>Real.sqrt_pos.mpr (div_pos hg (he i))
  have hb2 (i : ι) : (b i)^2=g/e i := Real.sq_sqrt (div_nonneg hg.le (he i).le)
  have hprod2 : (∏i,b i)^2=1 := by
    rw [←Finset.prod_pow]
    simp_rw [hb2]
    rw [Finset.prod_div_distrib,Finset.prod_const,Finset.card_univ]
    rw [show g^Fintype.card ι=∏j,e j from
      Real.rpow_inv_natCast_pow hep.le Fintype.card_ne_zero]
    exact div_self hep.ne'
  have hp : 0<∏i,b i := Finset.prod_pos (fun i _=>hb i)
  refine ⟨b,hb,by nlinarith,?_⟩
  intro i
  rw [hb2,div_mul_cancel₀ _ (he i).ne']

end NeuralGeneralization.BatchTwoActivation
