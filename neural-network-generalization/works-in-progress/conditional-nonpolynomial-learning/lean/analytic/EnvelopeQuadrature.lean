import CanonicalImportanceLaw

/-! Actual importance quadrature from an integrable envelope. No second moment
of the original density is required: the dominating envelope needs only a
finite first integral under the actual controlled row law. -/

noncomputable section
open MeasureTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic

section DensityHelpers
variable {Ω E : Type*} [MeasurableSpace Ω] [NormedAddCommGroup E] [NormedSpace ℝ E]

def positiveDensityLaw (μ : Measure Ω) (p : Ω → ℝ) : Measure Ω :=
  μ.withDensity (fun x => ENNReal.ofReal (p x))

lemma positiveDensityLaw_probability (μ : Measure Ω) (p : Ω → ℝ)
    (hp : Integrable p μ) (hp0 : ∀ x, 0 < p x) (hpmass : ∫ x, p x ∂μ = 1) :
    IsProbabilityMeasure (positiveDensityLaw μ p) := by
  constructor
  rw [positiveDensityLaw, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ,
    ← ofReal_integral_eq_lintegral_ofReal hp (Filter.Eventually.of_forall fun x => (hp0 x).le),
    hpmass, ENNReal.ofReal_one]

lemma integrable_positiveDensityLaw_iff (μ : Measure Ω) (p : Ω → ℝ)
    (hp : Measurable p) (hp0 : ∀ x, 0 < p x) (f : Ω → E) :
    Integrable f (positiveDensityLaw μ p) ↔ Integrable (fun x => p x • f x) μ := by
  let r : Ω → ℝ≥0 := fun x => ⟨p x,(hp0 x).le⟩
  have hr : Measurable r := hp.subtype_mk
  have heq : positiveDensityLaw μ p = μ.withDensity (fun x => (r x : ℝ≥0∞)) := by
    unfold positiveDensityLaw
    congr 1
    funext x
    exact ENNReal.ofReal_eq_coe_nnreal (hp0 x).le
  rw [heq]
  have hcoe (x : Ω) : (r x : ℝ) = p x := rfl
  simpa only [NNReal.smul_def, hcoe] using (integrable_withDensity_iff_integrable_smul hr (g:=f))

lemma positiveDensityLaw_reweight_integrable (μ : Measure Ω) (p : Ω → ℝ)
    (hp : Measurable p) (hp0 : ∀ x, 0 < p x) (f : Ω → E) (hf : Integrable f μ) :
    Integrable (fun x => (p x)⁻¹ • f x) (positiveDensityLaw μ p) := by
  rw [integrable_positiveDensityLaw_iff μ p hp hp0]
  simpa only [smul_smul, mul_inv_cancel₀ (hp0 _).ne', one_smul] using hf

lemma positiveDensityLaw_reweight_integral (μ : Measure Ω) (p : Ω → ℝ)
    (hp : Measurable p) (hp0 : ∀ x, 0 < p x) (f : Ω → E) :
    (∫ x, (p x)⁻¹ • f x ∂positiveDensityLaw μ p) = ∫ x, f x ∂μ := by
  rw [positiveDensityLaw, integral_withDensity_eq_integral_toReal_smul hp.ennreal_ofReal
    (Filter.Eventually.of_forall fun _ => ENNReal.ofReal_lt_top)]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall fun x => by
    dsimp only
    rw [ENNReal.toReal_ofReal (hp0 x).le, smul_smul, mul_inv_cancel₀ (hp0 x).ne', one_smul]

lemma envelope_integral_pos (μ : Measure Ω) [IsProbabilityMeasure μ]
    (H : Ω → ℝ) (hH : Integrable H μ) (hHone : ∀ x, 1 ≤ H x) :
    0 < ∫ x, H x ∂μ := by
  have hh := integral_mono (integrable_const (1:ℝ)) hH hHone
  simp only [integral_const, probReal_univ, smul_eq_mul, mul_one] at hh
  linarith

end DensityHelpers

variable {Ω E : Type*} [MeasurableSpace Ω] [NormedAddCommGroup E]
/-- Uniform quadrature of an unbounded family from a common integrable
amplitude/Lipschitz envelope. The finite approximant uses actual nodes and
explicit weights Z/H(node), where Z is the envelope's genuine integral. -/
theorem envelope_cube_quadrature
    {ι : Type*} [Fintype ι] [InnerProductSpace ℝ E] [CompleteSpace E]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (H : Ω → ℝ) (hHmeas : Measurable H) (hHInt : Integrable H μ)
    (hHone : ∀ x, 1 ≤ H x)
    (U : ℝ) (hU : 0 < U) (T : ℕ) (hT : 0 < T)
    (f : ParameterCube ι U → Ω → E) (hfInt : ∀ t, Integrable (f t) μ)
    (J L ε : ℝ) (hJ : 0 < J) (hL : 0 ≤ L) (hε : 0 < ε)
    (hf : ∀ t x, ‖f t x‖ ≤ H x*J)
    (hLip : ∀ t u x, ‖f t x-f u x‖ ≤ H x*(L*dist t u))
    (m : ℕ) (hm : 0 < m)
    (hmesh : 4*((∫ x, H x ∂μ)*L)*U ≤ (T:ℝ)*ε)
    (hbudget : 1024*((∫ x, H x ∂μ)*J)^2*
      (1+(Fintype.card ι:ℝ)*Real.log (2*(T:ℝ)+1)) ≤ (m:ℝ)*ε^2) :
    ∃ s : Fin m → Ω, ∀ t,
      ‖(m:ℝ)⁻¹ • (∑ j, ((∫ x, H x ∂μ)/H (s j)) • f t (s j)) -
        ∫ x, f t x ∂μ‖ < ε := by
  let Z := ∫ x, H x ∂μ
  have hZ : 0 < Z := envelope_integral_pos μ H hHInt hHone
  have hHpos (x : Ω) : 0 < H x := by linarith [hHone x]
  let p : Ω → ℝ := fun x => H x/Z
  have hpmeas : Measurable p := hHmeas.div_const Z
  have hpInt : Integrable p μ := hHInt.div_const Z
  have hppos (x : Ω) : 0 < p x := div_pos (hHpos x) hZ
  have hpmass : ∫ x, p x ∂μ = 1 := by
    dsimp only [p]
    rw [integral_div]
    exact div_self hZ.ne'
  let ν := positiveDensityLaw μ p
  letI : IsProbabilityMeasure ν := positiveDensityLaw_probability μ p hpInt hppos hpmass
  let v : ParameterCube ι U → Ω → E := fun t x => (p x)⁻¹ • f t x
  have hvInt (t : ParameterCube ι U) : Integrable (v t) ν :=
    positiveDensityLaw_reweight_integrable μ p hpmeas hppos (f t) (hfInt t)
  have hweight (x : Ω) : (p x)⁻¹ * H x = Z := by
    dsimp only [p]
    field_simp [(hHpos x).ne', hZ.ne']
  have hv (t : ParameterCube ι U) (x : Ω) : ‖v t x‖ ≤ Z*J := by
    dsimp only [v]
    rw [norm_smul, Real.norm_eq_abs, abs_of_pos (inv_pos.mpr (hppos x))]
    calc
      (p x)⁻¹ * ‖f t x‖ ≤ (p x)⁻¹ * (H x*J) :=
        mul_le_mul_of_nonneg_left (hf t x) (inv_nonneg.mpr (hppos x).le)
      _ = Z*J := by rw [← mul_assoc, hweight]
  have hvLip (t u : ParameterCube ι U) (x : Ω) :
      ‖v t x-v u x‖ ≤ (Z*L)*dist t u := by
    dsimp only [v]
    rw [← smul_sub, norm_smul, Real.norm_eq_abs, abs_of_pos (inv_pos.mpr (hppos x))]
    calc
      (p x)⁻¹ * ‖f t x-f u x‖ ≤ (p x)⁻¹ * (H x*(L*dist t u)) :=
        mul_le_mul_of_nonneg_left (hLip t u x) (inv_nonneg.mpr (hppos x).le)
      _ = (Z*L)*dist t u := by rw [← mul_assoc, hweight, mul_assoc]
  obtain ⟨s,hs⟩ := measure_cube_quadrature_accuracy ν U hU T hT v hvInt
    (Z*J) (Z*L) ε (mul_pos hZ hJ) (mul_nonneg hZ.le hL) hε hv hvLip m hm hmesh hbudget
  refine ⟨s,fun t => ?_⟩
  have hmean : (∫ x, v t x ∂ν) = ∫ x, f t x ∂μ :=
    positiveDensityLaw_reweight_integral μ p hpmeas hppos (f t)
  have hst := hs t
  rw [hmean] at hst
  simpa only [v, p, inv_div] using hst

#print axioms envelope_cube_quadrature
end ConditionalNonpolynomial.Analytic
