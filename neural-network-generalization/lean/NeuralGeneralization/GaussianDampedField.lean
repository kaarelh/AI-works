import NeuralGeneralization.GaussianDiagonalComparison
import NeuralGeneralization.GaussianStripPacking
import NeuralGeneralization.GaussianFieldCovariance

/-! # Actual damped field laws and comparator denominator bounds -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal ENNReal
namespace NeuralGeneralization.GaussianDiagonalComparison
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt
open GaussianTranslatePacking
variable {X I : Type*} [Fintype X] [Fintype I]

theorem standard_map_diagonal (v : I → ℝ≥0) :
    (standardLaw I).map (fun z i => Real.sqrt (v i : ℝ)*z i) =
      Measure.pi (fun i => gaussianReal 0 (v i)) := by
  unfold standardLaw
  rw [Measure.pi_map_pi (f:=fun i (x:ℝ) => Real.sqrt (v i : ℝ)*x)
    (fun i => (measurable_const.mul measurable_id).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul, mul_zero, mul_one]
  congr 1
  ext
  exact Real.sq_sqrt (v i).coe_nonneg

theorem damped_fieldLaw_eq_map (A : X → I → ℝ) (v : I → ℝ≥0) :
    fieldLaw (fun x i => A x i*Real.sqrt (v i : ℝ)) =
      (Measure.pi (fun i => gaussianReal 0 (v i))).map (fieldLinear A) := by
  rw [← standard_map_diagonal v, Measure.map_map (fieldLinear A).continuous.measurable
    (by fun_prop)]
  unfold fieldLaw
  congr 1
  funext z x
  simp [fieldLinear_apply, mul_assoc]

/-- Damping arbitrary feature variances gives the actual comparison used for
the conditioning denominator. -/
theorem damped_field_measure_le (A : X → I → ℝ) (v : I → ℝ≥0)
    (hv : ∀ i, 0 < v i) (hv1 : ∀ i, v i ≤ 1) :
    ENNReal.ofReal (∏ i, Real.sqrt (v i : ℝ)) •
      fieldLaw (fun x i => A x i*Real.sqrt (v i : ℝ)) ≤ fieldLaw A := by
  have hm := Measure.map_mono (damped_gaussian_measure_le v hv hv1)
    (fieldLinear A).continuous.measurable
  rw [Measure.map_smul, ← damped_fieldLaw_eq_map] at hm
  exact hm

/-- A comparator with a uniform buffer yields a quantitative probability lower
bound for the exact event under the actual Gaussian field. -/
theorem field_comparator_mass (A : X → I → ℝ) (c : I → ℝ)
    (V t R : ℝ) (hV : 0 < V) (ht : 0 ≤ t)
    (hvar : ∀ x, (∑ i, A x i^2) ≤ V)
    (hsize : 4*(Fintype.card X : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (henergy : (∑ i, c i^2) ≤ R)
    (E : Set (X → ℝ)) (hE : MeasurableSet E)
    (hbuffer : ∀ z : X → ℝ, (∀ x, |z x-fieldLinear A c x| < t) → z ∈ E) :
    Real.exp (-R/2)/2 ≤ (fieldLaw A).real E := by
  have hhalf := gaussian_rowStrip_halfmass A V t hV ht hvar hsize
  have hshift := gaussian_translate_lower c (rowStrip A t) (measurableSet_rowStrip A t)
    (rowStrip_symmetric A t)
  have hsub : translateSet c (rowStrip A t) ⊆ (fieldLinear A) ⁻¹' E := by
    intro z hz
    apply hbuffer
    intro x
    have hx := hz x
    change |rowForm (A x) (z-c)| < t at hx
    change |∑ i, A x i*(z i-c i)| < t at hx
    simpa only [mul_sub, Finset.sum_sub_distrib, fieldLinear_apply] using hx
  have he : Real.exp (-R/2) ≤ Real.exp (-(∑ i, c i^2)/2) :=
    Real.exp_le_exp.mpr (by linarith)
  have hbase : Real.exp (-R/2)/2 ≤
      (standardGaussian (I:=I)).real (translateSet c (rowStrip A t)) := by
    have hh := mul_le_mul he hhalf (by norm_num : (0:ℝ) ≤ 1/2) (Real.exp_pos _).le
    apply le_trans _ hshift
    simpa only [div_eq_mul_inv, one_mul] using hh
  have hm : (standardGaussian (I:=I)).real ((fieldLinear A) ⁻¹' E) = (fieldLaw A).real E := by
    unfold fieldLaw Measure.real
    rw [Measure.map_apply (fieldLinear A).continuous.measurable hE]
    rfl
  exact hbase.trans ((measureReal_mono hsub).trans_eq hm)

/-- Combining the two actual Gaussian inequalities gives the denominator lower
bound with its determinant prefactor and comparator energy explicit. -/
theorem damped_comparator_mass (A : X → I → ℝ) (v : I → ℝ≥0)
    (hv : ∀ i, 0 < v i) (hv1 : ∀ i, v i ≤ 1) (c : I → ℝ)
    (V t R : ℝ) (hV : 0 < V) (ht : 0 ≤ t)
    (hvar : ∀ x, (∑ i, (A x i*Real.sqrt (v i : ℝ))^2) ≤ V)
    (hsize : 4*(Fintype.card X : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (henergy : (∑ i, c i^2) ≤ R)
    (E : Set (X → ℝ)) (hE : MeasurableSet E)
    (hbuffer : ∀ z : X → ℝ,
      (∀ x, |z x-fieldLinear (fun x i => A x i*Real.sqrt (v i : ℝ)) c x| < t) → z ∈ E) :
    (∏ i, Real.sqrt (v i : ℝ))*Real.exp (-R/2)/2 ≤ (fieldLaw A).real E := by
  have hcomp := field_comparator_mass (fun x i => A x i*Real.sqrt (v i : ℝ)) c
    V t R hV ht hvar hsize henergy E hE hbuffer
  have hm := damped_field_measure_le A v hv hv1
  have hr := ENNReal.toReal_mono (measure_ne_top (fieldLaw A) E) (hm E)
  simp only [Measure.smul_apply, smul_eq_mul, ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (Finset.prod_nonneg fun _ _ => Real.sqrt_nonneg _)] at hr
  have hprod : 0 ≤ ∏ i, Real.sqrt (v i : ℝ) :=
    Finset.prod_nonneg fun _ _ => Real.sqrt_nonneg _
  have hp := mul_le_mul_of_nonneg_left hcomp hprod
  change (∏ i, Real.sqrt (v i : ℝ))*
    (fieldLaw (fun x i => A x i*Real.sqrt (v i : ℝ))).real E ≤ (fieldLaw A).real E at hr
  apply le_trans _ hr
  simpa only [mul_div_assoc] using hp


/-- Converting the literal comparator mass lower bound to conditioning cost. -/
lemma log_inverse_le_of_comparator (p c R : ℝ) (hc : 0 < c)
    (hmass : c*Real.exp (-R/2)/2 ≤ p) :
    Real.log (1/p) ≤ Real.log 2+R/2-Real.log c := by
  have hl : 0 < c*Real.exp (-R/2)/2 := by positivity
  have hp : 0 < p := hl.trans_le hmass
  have hh := Real.log_le_log hl hmass
  rw [Real.log_div (mul_pos hc (Real.exp_pos _)).ne' (by norm_num),
    Real.log_mul hc.ne' (Real.exp_ne_zero _), Real.log_exp] at hh
  rw [Real.log_div one_ne_zero hp.ne', Real.log_one]
  linarith

/-- The exact original Gaussian event has at most the comparator's quadratic
cost plus the damping determinant cost and the strip halfmass constant. -/
theorem damped_comparator_cost (A : X → I → ℝ) (v : I → ℝ≥0)
    (hv : ∀ i, 0 < v i) (hv1 : ∀ i, v i ≤ 1) (c : I → ℝ)
    (V t R : ℝ) (hV : 0 < V) (ht : 0 ≤ t)
    (hvar : ∀ x, (∑ i, (A x i*Real.sqrt (v i : ℝ))^2) ≤ V)
    (hsize : 4*(Fintype.card X : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (henergy : (∑ i, c i^2) ≤ R)
    (E : Set (X → ℝ)) (hE : MeasurableSet E)
    (hbuffer : ∀ z : X → ℝ,
      (∀ x, |z x-fieldLinear (fun x i => A x i*Real.sqrt (v i : ℝ)) c x| < t) → z ∈ E) :
    Real.log (1/(fieldLaw A).real E) ≤
      Real.log 2+R/2-Real.log (∏ i, Real.sqrt (v i : ℝ)) := by
  apply log_inverse_le_of_comparator
  · exact Finset.prod_pos fun i _ => Real.sqrt_pos.mpr (hv i)
  · exact damped_comparator_mass A v hv hv1 c V t R hV ht hvar hsize henergy E hE hbuffer

end NeuralGeneralization.GaussianDiagonalComparison
