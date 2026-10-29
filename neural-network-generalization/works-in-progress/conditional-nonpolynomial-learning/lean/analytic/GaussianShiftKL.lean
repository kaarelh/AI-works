import GaussianVarianceKL
import NeuralGeneralization.GaussianProductDensity
import NeuralGeneralization.RobustEntropyChain

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalAnalytic
open ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I]

def gaussianMeanDensity (a : I → ℝ) (v : ℝ≥0) (x : I → ℝ) : ℝ :=
  ∏ i,gaussianPDFReal (a i) v (x i)

@[fun_prop] lemma measurable_gaussianMeanDensity (a : I → ℝ) (v : ℝ≥0) :
    Measurable (gaussianMeanDensity a v) := by
  unfold gaussianMeanDensity
  apply Finset.measurable_prod
  intro i hi
  exact (measurable_gaussianPDFReal (a i) v).comp (measurable_pi_apply i)

lemma gaussianMeanDensity_pos (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) (x : I → ℝ) :
    0<gaussianMeanDensity a v x :=
  Finset.prod_pos (fun i _ => gaussianPDFReal_pos (a i) v (x i) hv)

lemma gaussianMeanDensity_integrable (a : I → ℝ) (v : ℝ≥0) :
    Integrable (gaussianMeanDensity a v) volume :=
  Integrable.fintype_prod (fun i => integrable_gaussianPDFReal (a i) v)

lemma gaussianMeanPi_density (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    (Measure.pi fun i => gaussianReal (a i) v) =
      (volume : Measure (I → ℝ)).withDensity (fun x => ENNReal.ofReal (gaussianMeanDensity a v x)) := by
  apply Measure.pi_eq
  intro s hs
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  rw [← ofReal_integral_eq_lintegral_ofReal (gaussianMeanDensity_integrable a v).restrict
    (ae_of_all _ (fun x => (gaussianMeanDensity_pos a v hv x).le))]
  change ENNReal.ofReal (∫ x,gaussianMeanDensity a v x
    ∂(Measure.pi fun _ : I => (volume : Measure ℝ)).restrict (Set.univ.pi s)) = _
  rw [Measure.restrict_pi_pi]
  change ENNReal.ofReal (∫ x,∏ i,gaussianPDFReal (a i) v (x i)
    ∂Measure.pi fun i => (volume : Measure ℝ).restrict (s i)) = _
  rw [integral_fintype_prod_eq_prod]
  simp_rw [gaussianReal_apply_eq_integral _ hv]
  exact ENNReal.ofReal_prod_of_nonneg (fun i _ => integral_nonneg (gaussianPDFReal_nonneg _ _))

lemma gaussianMeanPi_ac_volume (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    (Measure.pi fun i => gaussianReal (a i) v) ≪ volume := by
  rw [gaussianMeanPi_density a v hv]
  exact withDensity_absolutelyContinuous _ _

lemma volume_ac_gaussianMeanPi (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    (volume : Measure (I → ℝ)) ≪ (Measure.pi fun i => gaussianReal (a i) v) := by
  rw [gaussianMeanPi_density a v hv]
  exact withDensity_absolutelyContinuous' (measurable_gaussianMeanDensity a v).ennreal_ofReal.aemeasurable
    (ae_of_all _ (fun x => (ENNReal.ofReal_pos.mpr (gaussianMeanDensity_pos a v hv x)).ne'))

lemma gaussianMeanPi_rnDeriv (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    (Measure.pi fun i => gaussianReal (a i) v).rnDeriv volume =ᵐ[volume]
      fun x => ENNReal.ofReal (gaussianMeanDensity a v x) := by
  rw [gaussianMeanPi_density a v hv]
  exact Measure.rnDeriv_withDensity _ (measurable_gaussianMeanDensity a v).ennreal_ofReal

lemma gaussianMeanDensity_log (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) (x : I → ℝ) :
    Real.log (gaussianMeanDensity a v x) =
      ∑ i, (-(Real.log (2*Real.pi)+Real.log (v:ℝ))/2-(x i-a i)^2/(2*v)) := by
  rw [gaussianMeanDensity,Real.log_prod (fun i _ => (gaussianPDFReal_pos (a i) v (x i) hv).ne')]
  apply Finset.sum_congr rfl
  intro i hi
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  rw [gaussianPDFReal,Real.log_mul (by positivity) (Real.exp_ne_zero _),
    Real.log_inv,Real.log_sqrt (by positivity),Real.log_mul (by positivity) hvp.ne',Real.log_exp]
  ring

lemma gaussianMeanPi_llr (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    llr (Measure.pi fun i => gaussianReal (a i) v) (Measure.pi fun _ : I => gaussianReal 0 v)
      =ᵐ[Measure.pi fun i => gaussianReal (a i) v]
        fun x => ∑ i,(a i*x i/v-(a i)^2/(2*v)) := by
  let Q := Measure.pi fun i => gaussianReal (a i) v
  let G := Measure.pi fun _ : I => gaussianReal 0 v
  have hQV := gaussianMeanPi_ac_volume a v hv
  have hGV := gaussianMeanPi_ac_volume (fun _ : I => 0) v hv
  have hQG : Q≪G := hQV.trans (volume_ac_gaussianMeanPi (fun _ : I => 0) v hv)
  have hratio := Measure.rnDeriv_eq_div hQV hGV
  filter_upwards [hQG hratio,hQV (gaussianMeanPi_rnDeriv a v hv),
    hQV (gaussianMeanPi_rnDeriv (fun _ : I => 0) v hv)] with x hx hqx hgx
  rw [llr,hx,hqx,hgx,ENNReal.toReal_div,
    ENNReal.toReal_ofReal (gaussianMeanDensity_pos a v hv x).le,
    ENNReal.toReal_ofReal (gaussianMeanDensity_pos (fun _ : I => 0) v hv x).le,
    Real.log_div (gaussianMeanDensity_pos a v hv x).ne'
      (gaussianMeanDensity_pos (fun _ : I => 0) v hv x).ne',
    gaussianMeanDensity_log a v hv,gaussianMeanDensity_log (fun _ : I => 0) v hv,
    ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  ring

lemma gaussianMeanPi_llr_integrable (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    Integrable (llr (Measure.pi fun i => gaussianReal (a i) v)
      (Measure.pi fun _ : I => gaussianReal 0 v)) (Measure.pi fun i => gaussianReal (a i) v) := by
  apply Integrable.congr _ (gaussianMeanPi_llr a v hv).symm
  apply integrable_finsetSum
  intro i hi
  have hcoord : Integrable (fun x : I → ℝ => x i)
      (Measure.pi fun i => gaussianReal (a i) v) :=
    integrable_comp_eval (μ := fun i => gaussianReal (a i) v) (i := i)
      (memLp_one_iff_integrable.mp (memLp_id_gaussianReal (μ := a i) (v := v) 1))
  exact ((hcoord.const_mul (a i)).div_const v).sub (integrable_const _)

theorem gaussianMeanPi_kl_ne_top (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    klDiv (Measure.pi fun i => gaussianReal (a i) v)
      (Measure.pi fun _ : I => gaussianReal 0 v) ≠ ∞ :=
  klDiv_ne_top ((gaussianMeanPi_ac_volume a v hv).trans
    (volume_ac_gaussianMeanPi (fun _ : I => 0) v hv)) (gaussianMeanPi_llr_integrable a v hv)

theorem gaussianMeanPi_kl_toReal (a : I → ℝ) (v : ℝ≥0) (hv : v≠0) :
    (klDiv (Measure.pi fun i => gaussianReal (a i) v)
      (Measure.pi fun _ : I => gaussianReal 0 v)).toReal = (∑ i,(a i)^2)/(2*v) := by
  rw [toReal_klDiv ((gaussianMeanPi_ac_volume a v hv).trans
    (volume_ac_gaussianMeanPi (fun _ : I => 0) v hv)) (gaussianMeanPi_llr_integrable a v hv),
    integral_congr_ae (gaussianMeanPi_llr a v hv)]
  have hcoord (i : I) : Integrable (fun x : I → ℝ => x i)
      (Measure.pi fun i => gaussianReal (a i) v) :=
    integrable_comp_eval (μ := fun i => gaussianReal (a i) v) (i := i)
      (memLp_one_iff_integrable.mp (memLp_id_gaussianReal (μ := a i) (v := v) 1))
  have hs (i : I) : Integrable (fun x : I → ℝ => a i*x i/v-(a i)^2/(2*v))
      (Measure.pi fun i => gaussianReal (a i) v) :=
    (((hcoord i).const_mul (a i)).div_const v).sub (integrable_const _)
  rw [integral_finsetSum _ (fun i _ => hs i),Finset.sum_div]
  simp only [probReal_univ,add_sub_cancel_right]
  apply Finset.sum_congr rfl
  intro i hi
  rw [integral_sub (((hcoord i).const_mul (a i)).div_const v) (integrable_const _),
    integral_div,integral_const_mul,integral_comp_eval (μ := fun i => gaussianReal (a i) v)
      (i := i) (f := fun x : ℝ => x) measurable_id.aestronglyMeasurable,integral_id_gaussianReal]
  simp only [integral_const,probReal_univ,one_smul]
  ring

#print axioms gaussianMeanPi_kl_toReal
#print axioms gaussianMeanPi_kl_ne_top
#print axioms gaussianMeanPi_llr
end ConditionalAnalytic
