import NeuralGeneralization.OnlineLowerFiniteHolder

/-! # Weighted finite-product Hölder for tanh frequency integrals -/

noncomputable section
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.OnlineLowerTanh

/-- Weighted Hölder on an arbitrary measure. This includes integrability
of the weighted product and applies directly to the exponential and csch
frequency weights used in localization. -/
theorem weighted_holder_product
    {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (hn : 0<Fintype.card ι)
    (w : α→ℝ) (hw : ∀ x,0≤w x) (hwm : AEStronglyMeasurable w μ)
    (f : ι→α→ℝ) (hf : ∀ i x,0≤f i x)
    (hfm : ∀ i,AEStronglyMeasurable (f i) μ)
    (hfi : ∀ i,Integrable (fun x => w x*f i x^Fintype.card ι) μ) :
    Integrable (fun x => w x*∏ i,f i x) μ ∧
      (∫ x,w x*∏ i,f i x ∂μ) ≤
        ∏ i,(∫ x,w x*f i x^Fintype.card ι ∂μ)^(1/(Fintype.card ι:ℝ)) := by
  classical
  let q : ℝ := 1/(Fintype.card ι:ℝ)
  let g : ι→α→ℝ := fun i x => (w x)^q*f i x
  have hn0 : (Fintype.card ι:ℝ) ≠ 0 := by positivity
  have hroot (x : α) : ((w x)^q)^Fintype.card ι=w x := by
    rw [← Real.rpow_mul_natCast (hw x)]
    dsimp [q]
    rw [one_div_mul_cancel hn0,Real.rpow_one]
  have hpow (i : ι) (x : α) : g i x^Fintype.card ι=w x*f i x^Fintype.card ι := by
    dsimp [g]
    rw [mul_pow,hroot]
  have hprod (x : α) : (∏ i,g i x)=w x*∏ i,f i x := by
    dsimp [g]
    rw [Finset.prod_mul_distrib]
    simp only [Finset.prod_const,Finset.card_univ,hroot]
  have hgm (i : ι) : AEStronglyMeasurable (g i) μ :=
    ((hwm.aemeasurable.pow_const q).aestronglyMeasurable).mul (hfm i)
  have hgi (i : ι) : Integrable (fun x => g i x^Fintype.card ι) μ := by
    simpa only [hpow] using hfi i
  have hh := OnlineLower.integrable_prod_and_integral_prod_le μ hn g
    (fun i x => mul_nonneg (Real.rpow_nonneg (hw x) _) (hf i x)) hgm hgi
  simpa only [hprod,hpow,q] using hh

end NeuralGeneralization.OnlineLowerTanh
