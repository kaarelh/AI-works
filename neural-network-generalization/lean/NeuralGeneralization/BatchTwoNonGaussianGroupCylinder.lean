import NeuralGeneralization.BatchTwoNonGaussianSmallBall
import NeuralGeneralization.BatchTwoNonGaussianTranslation
import NeuralGeneralization.LayerGramConcentration

/-! Exact product probabilities for clone-group cylinders under the actual
non-Gaussian coordinates. Only coordinate permutations and grouping are used. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian

def coordinateBallConstant (ν : CoordinateLaw) : ℝ :=
  2*Real.exp (-ν.potential 0-ν.upperCurvature/2)/ν.normalizer

theorem coordinateBallConstant_pos (ν : CoordinateLaw) : 0 < coordinateBallConstant ν := by
  unfold coordinateBallConstant
  exact div_pos (mul_pos (by norm_num) (Real.exp_pos _)) ν.normalizer_pos

theorem coordinate_small_ball (ν : CoordinateLaw) {ρ : ℝ} (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1) :
    coordinateBallConstant ν*ρ ≤ ν.law.real (Icc (-ρ) ρ) := by
  let c := Real.exp (-ν.potential 0-ν.upperCurvature/2)/ν.normalizer
  have hc : 0 < c := div_pos (Real.exp_pos _) ν.normalizer_pos
  have hbound (x : ℝ) (hx : x ∈ Icc (-ρ) ρ) : c ≤ ν.density x := by
    have hab : |x| ≤ ρ := abs_le.mpr hx
    have hx2 : x^2 ≤ 1 := by
      simpa only [sq_abs, one_pow] using
        (sq_le_sq₀ (abs_nonneg x) (by norm_num : (0 : ℝ) ≤ 1)).mpr (hab.trans hρ1)
    have hv := (ν.quadratic_envelopes x).2
    have hM := ν.upperCurvature_pos
    apply div_le_div_of_nonneg_right _ ν.normalizer_pos.le
    apply Real.exp_le_exp.mpr
    nlinarith
  have hint := setIntegral_mono_on (integrableOn_const (C := c) isCompact_Icc.measure_lt_top.ne)
    ν.integrable_density.integrableOn measurableSet_Icc hbound
  rw [integral_const, Measure.real, Measure.restrict_apply_univ,
    ← Measure.real, Real.volume_real_Icc_of_le (by linarith : -ρ ≤ ρ)] at hint
  rw [Measure.real, ν.measure_eq_integral _ measurableSet_Icc,
    ENNReal.toReal_ofReal (integral_nonneg ν.density_nonneg)]
  change coordinateBallConstant ν*ρ ≤ _
  dsimp [coordinateBallConstant,c] at hint ⊢
  calc
    _ = (ρ - -ρ)*(Real.exp (-ν.potential 0-ν.upperCurvature/2)/ν.normalizer) := by ring
    _ ≤ _ := hint

def groupCoordinates {C k p N : ℕ} (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) :
    (Fin N → ℝ) ≃ᵐ ((Fin C → Fin k → ℝ) × (Fin p → ℝ)) :=
  ((MeasurableEquiv.piCongrLeft (fun _ : Fin N => ℝ) e).symm.trans
    (MeasurableEquiv.sumPiEquivProdPi (fun _ : (Fin C × Fin k) ⊕ Fin p => ℝ))).trans
      ((MeasurableEquiv.curry (Fin C) (Fin k) ℝ).prodCongr (MeasurableEquiv.refl _))

@[simp] theorem groupCoordinates_fst {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (x : Fin N → ℝ) (a : Fin C) (j : Fin k) :
    (groupCoordinates e x).1 a j = x (e (.inl (a,j))) := rfl

@[simp] theorem groupCoordinates_snd {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (x : Fin N → ℝ) (j : Fin p) :
    (groupCoordinates e x).2 j = x (e (.inr j)) := rfl

theorem measurePreserving_groupCoordinates (ν : CoordinateLaw) {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) :
    MeasurePreserving (groupCoordinates e) (Measure.pi fun _ : Fin N => ν.law)
      ((Measure.pi fun _ : Fin C => Measure.pi fun _ : Fin k => ν.law).prod
        (Measure.pi fun _ : Fin p => ν.law)) := by
  have h1 := (measurePreserving_piCongrLeft (fun _ : Fin N => ν.law) e).symm
  have h2 := measurePreserving_sumPiEquivProdPi (fun _ : (Fin C × Fin k) ⊕ Fin p => ν.law)
  have h3 := (LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin C) (_ : Fin k) => ν.law)).symm
  exact (h3.prod (MeasurePreserving.id _)).comp (h2.comp h1)

def groupCylinder {C k p N : ℕ} (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (ρ : ℝ) : Set (Fin N → ℝ) :=
  {x | ∀ a : Fin C, |normalizedSum k (fun j => x (e (.inl (a,j))))| ≤ ρ}

theorem measurable_groupCylinder {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ : ℝ) : MeasurableSet (groupCylinder e ρ) := by
  unfold groupCylinder
  simp only [setOf_forall]
  apply MeasurableSet.iInter
  intro a
  apply measurableSet_le _ measurable_const
  unfold normalizedSum
  fun_prop

theorem groupCylinder_probability (ν : CoordinateLaw) {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ : ℝ) :
    (Measure.pi fun _ : Fin N => ν.law).real (groupCylinder e ρ) =
      ((Measure.pi fun _ : Fin k => ν.law).real {x | |normalizedSum k x| ≤ ρ})^C := by
  let A : Set (Fin k → ℝ) := {x | |normalizedSum k x| ≤ ρ}
  have hA : MeasurableSet A := by
    apply measurableSet_le _ measurable_const
    unfold normalizedSum
    fun_prop
  have he : groupCylinder e ρ = groupCoordinates e ⁻¹' ((Set.pi Set.univ fun _ : Fin C => A) ×ˢ Set.univ) := by
    ext x
    simp only [Set.mem_preimage, Set.mem_prod, Set.mem_pi, Set.mem_univ, forall_true_left, and_true]
    rfl
  rw [he, Measure.real, ← MeasurableEquiv.map_apply,
    (measurePreserving_groupCoordinates ν e).map_eq, Measure.prod_prod, measure_univ, mul_one,
    Measure.pi_pi, Finset.prod_const, Finset.card_univ, Fintype.card_fin, ENNReal.toReal_pow]
  rfl

theorem groupCylinder_lower (ν : CoordinateLaw) {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) {ρ : ℝ} (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2)
    (hsize : 4*(smallBallTilt ρ)^2 ≤ (k : ℝ))
    (herr : (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ))^2 ≤ (k : ℝ)) :
    (ρ^2/1024)^C ≤ (Measure.pi fun _ : Fin N => ν.law).real (groupCylinder e ρ) := by
  rw [groupCylinder_probability]
  exact pow_le_pow_left₀ (by positivity) (normalized_sum_small_ball ν k hk hρ hρhalf hsize herr) C

end NeuralGeneralization.BatchTwoNonGaussian
