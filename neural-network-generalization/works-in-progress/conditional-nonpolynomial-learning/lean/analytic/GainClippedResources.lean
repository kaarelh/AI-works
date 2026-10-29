import GainClippedExistence
import CanonicalQuadratureResources

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup

theorem gainQuadratureError_inverse_resource {R τ:ℝ} {d:ℕ}
    (hR:2≤R) (hd:(d:ℝ)≤R) (hτ:0<τ) (hi:τ⁻¹≤R) :
    (gainQuadratureError d τ)⁻¹≤R^18 := by
  have h2:(2:ℝ)≤R^1 := by simpa using hR
  have h4:(4:ℝ)≤R^2 := by nlinarith
  have h8:(8:ℝ)≤R^3 := by nlinarith [sq_nonneg (R-2)]
  have hd1:(d:ℝ)+1≤R^2 := by simpa using resource_add_one hR (a:=1) (by simpa using hd)
  have hg:4*((d:ℝ)+1)+1≤R^5 :=
    resource_add_one hR (resource_mul hR h4 hd1 (by positivity))
  have hnum:8*(4*((d:ℝ)+1)+1)≤R^8 := resource_mul hR h8 hg (by positivity)
  have hratio:8*(4*((d:ℝ)+1)+1)*τ⁻¹≤R^9 :=
    resource_mul hR hnum (b:=1) (by simpa using hi) (inv_nonneg.mpr hτ.le)
  have he:(gainQuadratureError d τ)⁻¹=(8*(4*((d:ℝ)+1)+1)*τ⁻¹)^2 := by
    unfold gainQuadratureError
    field_simp
  rw [he]
  exact resource_pow hR hratio (by positivity) 2

namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

theorem gain_primitive_resources (M:CanonicalLayerModel (J:=J) anchors D)
    {R α τ:ℝ} (hR:2≤R) (hd:(Fintype.card I:ℝ)≤R) (hm:(M.gainRank:ℝ)≤R)
    (hτ:0<τ) (hi:τ⁻¹≤R)
    (hαgain:Real.sqrt (gaussianEntropyGain ((klDiv M.law
      (NeuralGeneralization.GaussianAngularFields.standardLaw I)).toReal))≤α) :
    (M.gainCoefficientBudget:ℝ)≤R^6 ∧
      (M.gainQuadratureCount α τ:ℝ)≤R^972 := by
  have hR0:0≤R := by linarith
  have hR2:R≤R^2 := by nlinarith
  have h4:(4:ℝ)≤R^2 := by nlinarith
  have hbudget:3+(M.gainRank:ℝ)+2*(Fintype.card I:ℝ)≤R^4 := by
    have hh:R^2*R^2≥4*R^2 := mul_le_mul_of_nonneg_right h4 (sq_nonneg R)
    nlinarith [sq_nonneg R]
  refine ⟨resource_ceil_add_one hR (by positivity) hbudget,?_⟩
  have hZ:M.gainNormalizer α≤R^4 :=
    (gainDominatedNormalizer_bound M.law (actualCanonicalSpan M.law M.finiteKL anchors)
      (Fintype.equivFin I).symm M.finiteKL α hαgain).trans hbudget
  have hiδ:=gainQuadratureError_inverse_resource hR hd hτ hi
  have hbase:2≤R^18 := hR.trans (by simpa using resource_pow_mono hR (show 1≤18 by omega))
  have hd':(Fintype.card I:ℝ)≤R^18 := hd.trans
    (by simpa using resource_pow_mono hR (show 1≤18 by omega))
  have hZ':M.gainNormalizer α≤R^18 := hZ.trans (resource_pow_mono hR (by omega))
  have hδ:0<gainQuadratureError (Fintype.card I) τ := by unfold gainQuadratureError;positivity
  have hh:=canonicalQuadrature_resources hbase hd' (canonicalNormalizer_pos _ _ _).le hZ' hδ hiδ
  simpa only [gainQuadratureCount, gainNormalizer, ←pow_mul, show 18*54=972 by norm_num] using hh.2

theorem gain_primitive_dimension_resource (M:CanonicalLayerModel (J:=J) anchors D)
    {R α τ:ℝ} (hR:2≤R) (hd:(Fintype.card I:ℝ)≤R) (ho:(Fintype.card J:ℝ)≤R)
    (hm:(M.gainRank:ℝ)≤R) (hτ:0<τ) (hi:τ⁻¹≤R)
    (hαgain:Real.sqrt (gaussianEntropyGain ((klDiv M.law
      (NeuralGeneralization.GaussianAngularFields.standardLaw I)).toReal))≤α) :
    ((5*Fintype.card I+Fintype.card J+2*M.gainQuadratureCount α τ+2*M.gainRank+4:ℕ):ℝ)≤R^1000 := by
  have hcount:=(M.gain_primitive_resources hR hd hm hτ hi hαgain).2
  have h2:(2:ℝ)≤R^1 := by simpa using hR
  have h4:(4:ℝ)≤R^2 := by nlinarith
  have h5:(5:ℝ)≤R^3 := by nlinarith [sq_nonneg (R-2)]
  have hd5:5*(Fintype.card I:ℝ)≤R^4 := resource_mul hR h5 (b:=1) (by simpa using hd) (by positivity)
  have hdo:5*(Fintype.card I:ℝ)+(Fintype.card J:ℝ)≤R^5 := resource_add_same hR hd5
    (ho.trans (by simpa using resource_pow_mono hR (show 1≤4 by omega)))
  have hn:2*(M.gainQuadratureCount α τ:ℝ)≤R^973 := resource_mul hR h2 hcount (by positivity)
  have hm2:2*(M.gainRank:ℝ)≤R^2 := resource_mul hR h2 (b:=1) (by simpa using hm) (by positivity)
  have hnm:2*(M.gainQuadratureCount α τ:ℝ)+2*(M.gainRank:ℝ)≤R^974 :=
    resource_add_same hR hn (hm2.trans (resource_pow_mono hR (by omega)))
  have hsum:5*(Fintype.card I:ℝ)+(Fintype.card J:ℝ)+
      (2*(M.gainQuadratureCount α τ:ℝ)+2*(M.gainRank:ℝ))≤R^975 :=
    resource_add_same hR (hdo.trans (resource_pow_mono hR (by omega))) hnm
  have hfinal:=resource_add_same hR hsum (h4.trans (resource_pow_mono hR (show 2≤975 by omega)))
  have hh:=hfinal.trans (resource_pow_mono hR (show 976≤1000 by omega))
  push_cast
  nlinarith only [hh]

#print axioms gain_primitive_resources
#print axioms gain_primitive_dimension_resource
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
