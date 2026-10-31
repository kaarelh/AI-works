import NeuralGeneralization.BatchTwoNonGaussianScaleComparison

/-! The broader strong-prior model from the non-Gaussian paper. Coordinate
densities may differ, be asymmetric, and fail log-concavity. The common
quadratic exponents are a/2 and b/2; prefactors may depend on the coordinate
and width. No curvature, variance-one, smoothness, or analytic rate theorem
is assumed. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.QuadraticEnvelope
open ConcreteModel BatchTwoNonGaussian

structure Coordinate (a b : ℝ) where
  law : Measure ℝ
  probability : IsProbabilityMeasure law
  density : ℝ→ℝ
  measurable_density : Measurable density
  integrable_density : Integrable density
  density_nonneg : ∀x,0≤density x
  density_eq : law=volume.withDensity (fun x=>ENNReal.ofReal (density x))
  lowerFactor : ℝ
  upperFactor : ℝ
  lowerFactor_pos : 0<lowerFactor
  upperFactor_pos : 0<upperFactor
  lower : ∀x,lowerFactor*Real.exp (-(b/2)*x^2)≤density x
  upper : ∀x,density x≤upperFactor*Real.exp (-(a/2)*x^2)

attribute [instance] Coordinate.probability

def gaussianFactor (c k : ℝ) : ℝ := k*Real.sqrt (2*Real.pi/c)

theorem gaussianFactor_pos {c k : ℝ} (hc : 0<c) (hk : 0<k) :
    0<gaussianFactor c k := by unfold gaussianFactor; positivity

theorem gaussianFactor_pdf {c : ℝ} (hc : 0<c) (k x : ℝ) :
    gaussianFactor c k*gaussianPDFReal 0 (1/c).toNNReal x=
      k*Real.exp (-(c/2)*x^2) := by
  have hs : Real.sqrt (2*Real.pi/c)≠0 := (Real.sqrt_pos.mpr (by positivity)).ne'
  have he : -x^2/(2*(1/c))=-(c/2)*x^2 := by field_simp
  unfold gaussianFactor gaussianPDFReal
  rw [Real.coe_toNNReal _ (div_nonneg zero_le_one hc.le)]
  simp only [sub_zero]
  rw [he,show 2*Real.pi*(1/c)=2*Real.pi/c by ring]
  field_simp

variable {a b : ℝ} {I : Type*} [Fintype I]

def productDensity (ν : I→Coordinate a b) (x : I→ℝ) : ℝ := ∏i,(ν i).density (x i)

theorem productDensity_nonneg (ν : I→Coordinate a b) (x : I→ℝ) :
    0≤productDensity ν x := Finset.prod_nonneg (fun i _=>(ν i).density_nonneg _)

theorem measurable_productDensity (ν : I→Coordinate a b) :
    Measurable (productDensity ν) := by
  unfold productDensity
  exact Finset.measurable_prod _ (fun i _=>(ν i).measurable_density.comp (measurable_pi_apply i))

theorem integrable_productDensity (ν : I→Coordinate a b) :
    Integrable (productDensity ν) := Integrable.fintype_prod (fun i=>(ν i).integrable_density)

theorem measure_eq_integral (ν : Coordinate a b) (s : Set ℝ) (hs : MeasurableSet s) :
    ν.law s=ENNReal.ofReal (∫x in s,ν.density x) := by
  rw [ν.density_eq,withDensity_apply _ hs]
  exact (ofReal_integral_eq_lintegral_ofReal ν.integrable_density.restrict
    (ae_of_all _ ν.density_nonneg)).symm

theorem product_eq_withDensity (ν : I→Coordinate a b) :
    (Measure.pi fun i=>(ν i).law)=
      (volume : Measure (I→ℝ)).withDensity (fun x=>ENNReal.ofReal (productDensity ν x)) := by
  apply Measure.pi_eq
  intro s hs
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  rw [←ofReal_integral_eq_lintegral_ofReal (integrable_productDensity ν).restrict
    (ae_of_all _ (productDensity_nonneg ν))]
  change ENNReal.ofReal (∫x,productDensity ν x
    ∂(Measure.pi fun _ : I=>(volume : Measure ℝ)).restrict (Set.univ.pi s))=_
  rw [Measure.restrict_pi_pi]
  change ENNReal.ofReal (∫x,∏i,(ν i).density (x i)
    ∂Measure.pi fun i=>(volume : Measure ℝ).restrict (s i))=_
  rw [integral_fintype_prod_eq_prod]
  simp_rw [measure_eq_integral _ _ (hs _)]
  exact ENNReal.ofReal_prod_of_nonneg (fun i _=>integral_nonneg (ν i).density_nonneg)

def lowerProduct (ν : I→Coordinate a b) : ℝ := ∏i,gaussianFactor b (ν i).lowerFactor
def upperProduct (ν : I→Coordinate a b) : ℝ := ∏i,gaussianFactor a (ν i).upperFactor

theorem lowerProduct_pos (ν : I→Coordinate a b) (hb : 0<b) : 0<lowerProduct ν :=
  Finset.prod_pos (fun i _=>gaussianFactor_pos hb (ν i).lowerFactor_pos)
theorem upperProduct_pos (ν : I→Coordinate a b) (ha : 0<a) : 0<upperProduct ν :=
  Finset.prod_pos (fun i _=>gaussianFactor_pos ha (ν i).upperFactor_pos)

theorem product_gaussian_lower (ν : I→Coordinate a b) (hb : 0<b) :
    ENNReal.ofReal (lowerProduct ν) •
      (Measure.pi fun _ : I=>gaussianReal 0 (1/b).toNNReal)≤Measure.pi (fun i=>(ν i).law) := by
  have hv : (1/b).toNNReal≠0 := ne_of_gt (Real.toNNReal_pos.mpr (div_pos zero_lt_one hb))
  rw [product_eq_withDensity,GaussianProductDensity.gaussianPi_eq_withDensity _ hv,
    ←withDensity_smul _ (GaussianProductDensity.measurable_density _).ennreal_ofReal]
  apply withDensity_mono
  filter_upwards [] with x
  rw [Pi.smul_apply,smul_eq_mul,←ENNReal.ofReal_mul (lowerProduct_pos ν hb).le]
  apply ENNReal.ofReal_le_ofReal
  unfold lowerProduct GaussianProductDensity.density productDensity
  rw [←Finset.prod_mul_distrib]
  apply Finset.prod_le_prod
  · intro i _
    exact mul_nonneg (gaussianFactor_pos hb (ν i).lowerFactor_pos).le (gaussianPDFReal_nonneg _ _ _)
  · intro i _
    rw [gaussianFactor_pdf hb]
    exact (ν i).lower _

theorem product_gaussian_upper (ν : I→Coordinate a b) (ha : 0<a) :
    Measure.pi (fun i=>(ν i).law)≤ENNReal.ofReal (upperProduct ν) •
      (Measure.pi fun _ : I=>gaussianReal 0 (1/a).toNNReal) := by
  have hv : (1/a).toNNReal≠0 := ne_of_gt (Real.toNNReal_pos.mpr (div_pos zero_lt_one ha))
  rw [product_eq_withDensity,GaussianProductDensity.gaussianPi_eq_withDensity _ hv,
    ←withDensity_smul _ (GaussianProductDensity.measurable_density _).ennreal_ofReal]
  apply withDensity_mono
  filter_upwards [] with x
  rw [Pi.smul_apply,smul_eq_mul,←ENNReal.ofReal_mul (upperProduct_pos ν ha).le]
  apply ENNReal.ofReal_le_ofReal
  unfold upperProduct GaussianProductDensity.density productDensity
  rw [←Finset.prod_mul_distrib]
  apply Finset.prod_le_prod (fun i _=>(ν i).density_nonneg _)
  intro i _
  rw [gaussianFactor_pdf ha]
  exact (ν i).upper _

def smallPrior {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b) (σ : ℝ) :
    Measure (Weights d N r) :=
  (Measure.pi fun i=>(ν i).law).map (fun u i=>smallScale d N r σ i*u i)

instance smallPrior_probability {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b) (σ : ℝ) :
    IsProbabilityMeasure (smallPrior ν σ) :=
  Measure.isProbabilityMeasure_map
    (show Measurable (fun (u : Weights d N r) i=>smallScale d N r σ i*u i) by fun_prop).aemeasurable

theorem smallPrior_gaussian_lower {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (hN : 0<N) (hb : 0<b) (σ : ℝ) :
    ENNReal.ofReal (lowerProduct ν) • ConcreteModel.smallPrior d N r (σ/Real.sqrt b)≤smallPrior ν σ := by
  have h := Measure.map_mono (product_gaussian_lower ν hb)
    (show Measurable (fun u i=>smallScale d N r σ i*u i) by fun_prop)
  rw [Measure.map_smul,map_gaussian_smallScale hd hN σ b hb] at h
  exact h

theorem smallPrior_gaussian_upper {d N r : ℕ} (ν : WeightIndex d N r→Coordinate a b)
    (hd : 0<d) (hN : 0<N) (ha : 0<a) (σ : ℝ) :
    smallPrior ν σ≤ENNReal.ofReal (upperProduct ν) • ConcreteModel.smallPrior d N r (σ/Real.sqrt a) := by
  have h := Measure.map_mono (product_gaussian_upper ν ha)
    (show Measurable (fun u i=>smallScale d N r σ i*u i) by fun_prop)
  rw [Measure.map_smul,map_gaussian_smallScale hd hN σ a ha] at h
  exact h

end NeuralGeneralization.QuadraticEnvelope
