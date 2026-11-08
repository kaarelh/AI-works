import Mathlib.MeasureTheory.Integral.MeanInequalities
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Tactic

/-! # Finite Hölder inequalities on arbitrary measure spaces

The measure need not be finite. The real formulation includes product
integrability, which is useful for weighted sine integrals near the origin.
-/

noncomputable section
open scoped BigOperators ENNReal
open MeasureTheory
namespace NeuralGeneralization.OnlineLower

/-- Equal-exponent finite Hölder in extended nonnegative reals. -/
theorem lintegral_prod_le_prod_lintegral_pow
    {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (hn : 0 < Fintype.card ι)
    (f : ι → α → ℝ≥0∞) (hf : ∀ i, AEMeasurable (f i) μ) :
    (∫⁻ x, ∏ i, f i x ∂μ) ≤
      ∏ i, (∫⁻ x, f i x ^ Fintype.card ι ∂μ) ^ (1 / (Fintype.card ι : ℝ)) := by
  have hn0 : (Fintype.card ι : ℝ) ≠ 0 := by positivity
  have h := ENNReal.lintegral_prod_norm_pow_le Finset.univ
    (f := fun i x => f i x ^ Fintype.card ι)
    (p := fun _ => 1 / (Fintype.card ι : ℝ))
    (fun i _ => (hf i).pow_const _) (by simp [hn0]) (by intro i hi; positivity)
  simpa only [one_div, ENNReal.pow_rpow_inv_natCast (Nat.ne_of_gt hn)] using h

/-- Real finite Hölder, together with integrability of its product. -/
theorem integrable_prod_and_integral_prod_le
    {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (hn : 0 < Fintype.card ι)
    (f : ι → α → ℝ) (hf0 : ∀ i x, 0 ≤ f i x)
    (hfm : ∀ i, AEStronglyMeasurable (f i) μ)
    (hfi : ∀ i, Integrable (fun x => f i x ^ Fintype.card ι) μ) :
    Integrable (fun x => ∏ i, f i x) μ ∧
      (∫ x, ∏ i, f i x ∂μ) ≤
        ∏ i, (∫ x, f i x ^ Fintype.card ι ∂μ) ^ (1 / (Fintype.card ι : ℝ)) := by
  classical
  have hp0 (x : α) : 0 ≤ ∏ i, f i x := Finset.prod_nonneg (fun i _ => hf0 i x)
  have hpm : AEStronglyMeasurable (fun x => ∏ i, f i x) μ :=
    Finset.aestronglyMeasurable_fun_prod _ (fun i _ => hfm i)
  have hpow0 (i : ι) : 0 ≤ᵐ[μ] (fun x => f i x ^ Fintype.card ι) :=
    Filter.Eventually.of_forall (fun x => pow_nonneg (hf0 i x) _)
  have h := lintegral_prod_le_prod_lintegral_pow μ hn
    (fun i x => ENNReal.ofReal (f i x))
    (fun i => (hfm i).aemeasurable.ennreal_ofReal)
  have hprod (x : α) : (∏ i, ENNReal.ofReal (f i x)) = ENNReal.ofReal (∏ i, f i x) :=
    (ENNReal.ofReal_prod_of_nonneg (fun i _ => hf0 i x)).symm
  have hpow (i : ι) :
      (∫⁻ x, ENNReal.ofReal (f i x) ^ Fintype.card ι ∂μ) =
        ENNReal.ofReal (∫ x, f i x ^ Fintype.card ι ∂μ) := by
    rw [ofReal_integral_eq_lintegral_ofReal (hfi i) (hpow0 i)]
    congr 1
    funext x
    exact (ENNReal.ofReal_pow (hf0 i x) _).symm
  simp_rw [hprod, hpow] at h
  have hright : (∏ i, ENNReal.ofReal (∫ x, f i x ^ Fintype.card ι ∂μ) ^
      (1 / (Fintype.card ι : ℝ))) ≠ ⊤ := by
    apply ENNReal.prod_ne_top
    intro i hi
    exact ENNReal.rpow_ne_top_of_nonneg (by positivity) ENNReal.ofReal_ne_top
  have hleft : (∫⁻ x, ENNReal.ofReal (∏ i, f i x) ∂μ) ≠ ⊤ :=
    ne_top_of_le_ne_top hright h
  have hInt : Integrable (fun x => ∏ i, f i x) μ :=
    (lintegral_ofReal_ne_top_iff_integrable hpm
      (Filter.Eventually.of_forall hp0)).mp hleft
  refine ⟨hInt, ?_⟩
  have hr := ENNReal.toReal_mono hright h
  rw [← ofReal_integral_eq_lintegral_ofReal hInt (Filter.Eventually.of_forall hp0)] at hr
  simpa only [ENNReal.toReal_prod, ← ENNReal.toReal_rpow,
    ENNReal.toReal_ofReal (integral_nonneg hp0),
    ENNReal.toReal_ofReal (integral_nonneg (fun x => pow_nonneg (hf0 _ x) _))] using hr

/-- Uniform moment bounds give the same bound on the product integral. -/
theorem integrable_prod_and_integral_prod_le_of_uniform
    {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (hn : 0 < Fintype.card ι)
    (f : ι → α → ℝ) (hf0 : ∀ i x, 0 ≤ f i x)
    (hfm : ∀ i, AEStronglyMeasurable (f i) μ)
    (hfi : ∀ i, Integrable (fun x => f i x ^ Fintype.card ι) μ)
    (K : ℝ) (hK : 0 ≤ K)
    (hbound : ∀ i, (∫ x, f i x ^ Fintype.card ι ∂μ) ≤ K) :
    Integrable (fun x => ∏ i, f i x) μ ∧ (∫ x, ∏ i, f i x ∂μ) ≤ K := by
  obtain ⟨hint,hineq⟩ := integrable_prod_and_integral_prod_le μ hn f hf0 hfm hfi
  refine ⟨hint,hineq.trans ?_⟩
  calc
    _ ≤ ∏ _i : ι, K ^ (1/(Fintype.card ι : ℝ)) := by
      apply Finset.prod_le_prod
      · intro i hi
        exact Real.rpow_nonneg (integral_nonneg (fun x => pow_nonneg (hf0 i x) _)) _
      · intro i hi
        exact Real.rpow_le_rpow (integral_nonneg (fun x => pow_nonneg (hf0 i x) _))
          (hbound i) (by positivity)
    _ = K := by
      simp only [Finset.prod_const,Finset.card_univ,one_div]
      exact Real.rpow_inv_natCast_pow hK (Nat.ne_of_gt hn)

end NeuralGeneralization.OnlineLower
