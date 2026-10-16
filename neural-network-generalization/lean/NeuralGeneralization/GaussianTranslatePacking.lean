import NeuralGeneralization.GaussianProductDensity
import NeuralGeneralization.RankOneGeometry

/-!
# Translation lower bounds for the actual finite Gaussian product

The density calculation underlying dual Sudakov packing is proved for
the actual product of standard Gaussian measures. No Gaussian-shift or
packing estimate is assumed.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianTranslatePacking
open GaussianProductDensity
variable {I : Type*} [Fintype I]

def standardGaussian : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1

instance : IsProbabilityMeasure (standardGaussian (I := I)) := by
  unfold standardGaussian
  infer_instance

def translateSet (x : I → ℝ) (B : Set (I → ℝ)) : Set (I → ℝ) :=
  {y | y-x ∈ B}

omit [Fintype I] in
lemma measurableSet_translateSet (x : I → ℝ) {B : Set (I → ℝ)} (hB : MeasurableSet B) :
    MeasurableSet (translateSet x B) := hB.preimage (measurable_id.sub measurable_const)

lemma gaussian_real_set_eq_density_integral (B : Set (I → ℝ)) (hB : MeasurableSet B) :
    (standardGaussian (I := I)).real B = ∫ y in B, density 1 y := by
  have h := integral_gaussianPi (I := I) 1 (by norm_num) (B.indicator (fun _ => (1 : ℝ)))
  rw [integral_indicator hB, integral_const] at h
  simp only [Measure.real, Measure.restrict_apply_univ, smul_eq_mul, mul_one] at h
  rw [← integral_indicator hB]
  apply h.trans
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun y => by
    by_cases hy : y ∈ B <;> simp [hy])

lemma gaussian_translate_integral_density (x : I → ℝ) (B : Set (I → ℝ)) (hB : MeasurableSet B) :
    (standardGaussian (I := I)).real (translateSet x B) = ∫ y in B, density 1 (x+y) := by
  rw [gaussian_real_set_eq_density_integral _ (measurableSet_translateSet x hB),
    ← integral_indicator (measurableSet_translateSet x hB)]
  rw [← integral_add_left_eq_self
    (f := (translateSet x B).indicator (density (I := I) 1)) x]
  rw [← integral_indicator hB]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall (fun y => by
    have heq : x+y-x = y := by abel
    by_cases hy : y ∈ B <;> simp [translateSet, heq, hy])

/-- Averaging opposite translates cancels the linear Gaussian exponent. -/
theorem standard_density_opposite_translates (x y : I → ℝ) :
    2 * Real.exp (-(∑ i, x i ^ 2) / 2) * density 1 y ≤
      density 1 (x+y) + density 1 (x-y) := by
  let A := ∑ i, x i^2
  let B := ∑ i, y i^2
  let C := ∑ i, x i*y i
  have hp : (∑ i, (x+y) i^2) = A+B+2*C := by
    simp only [Pi.add_apply, add_sq, Finset.sum_add_distrib]
    dsimp only [A, B, C]
    rw [Finset.mul_sum]
    have heq : (∑ i, 2*x i*y i) = ∑ i, 2*(x i*y i) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [heq]
    ring
  have hm : (∑ i, (x-y) i^2) = A+B-2*C := by
    simp only [Pi.sub_apply, sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib]
    dsimp only [A, B, C]
    rw [Finset.mul_sum]
    have heq : (∑ i, 2*x i*y i) = ∑ i, 2*(x i*y i) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [heq]
    ring
  have hsym : 2 ≤ Real.exp C + Real.exp (-C) := by
    linarith [Real.add_one_le_exp C, Real.add_one_le_exp (-C)]
  have hexp₁ : Real.exp (-(A+B+2*C)/2) = Real.exp (-A/2) * Real.exp (-B/2) * Real.exp (-C) := by
    rw [← Real.exp_add, ← Real.exp_add]
    congr 1
    ring
  have hexp₂ : Real.exp (-(A+B-2*C)/2) = Real.exp (-A/2) * Real.exp (-B/2) * Real.exp C := by
    rw [← Real.exp_add, ← Real.exp_add]
    congr 1
    ring
  simp only [standard_density_eq, hp, hm, hexp₁, hexp₂]
  change 2*Real.exp (-A/2)*((Real.sqrt (2*Real.pi))⁻¹^Fintype.card I*Real.exp (-B/2)) ≤ _
  have h := mul_le_mul_of_nonneg_left hsym
    (show 0 ≤ (Real.sqrt (2*Real.pi))⁻¹^Fintype.card I * Real.exp (-A/2)*Real.exp (-B/2) by positivity)
  nlinarith only [h]

/-- Every symmetric measurable set has a quantitative Gaussian translate
lower bound. Convexity of the set is not needed for this step. -/
theorem gaussian_translate_lower (x : I → ℝ) (B : Set (I → ℝ)) (hB : MeasurableSet B)
    (hsym : ∀ y, -y ∈ B ↔ y ∈ B) :
    Real.exp (-(∑ i, x i ^ 2) / 2) * (standardGaussian (I := I)).real B ≤
      (standardGaussian (I := I)).real (translateSet x B) := by
  have hplus : Integrable (fun y : I → ℝ => density 1 (x+y)) volume :=
    (measurePreserving_add_left volume x).integrable_comp_of_integrable (integrable_density 1)
  have hminus : Integrable (fun y : I → ℝ => density 1 (x-y)) volume := by
    simpa only [sub_eq_add_neg] using hplus.comp_neg
  have hneg : (∫ y in B, density 1 (x-y)) = ∫ y in B, density 1 (x+y) := by
    rw [← integral_indicator hB, ← integral_indicator hB]
    have hp (y : I → ℝ) :
        B.indicator (fun y => density 1 (x-y)) y =
          B.indicator (fun y => density 1 (x+y)) (-y) := by
      by_cases hy : y ∈ B
      · simp only [Set.indicator_of_mem hy, Set.indicator_of_mem ((hsym y).2 hy), sub_eq_add_neg]
      · simp only [Set.indicator_of_notMem hy,
          Set.indicator_of_notMem (fun hny => hy ((hsym y).1 hny))]
    simp_rw [hp]
    exact integral_neg_eq_self _ volume
  have hineq := integral_mono (μ := (volume : Measure (I → ℝ)).restrict B)
    ((integrable_density 1).const_mul (2*Real.exp (-(∑ i, x i^2)/2))).restrict
    (hplus.add hminus).restrict (standard_density_opposite_translates x)
  simp only [Pi.add_apply] at hineq
  rw [integral_const_mul, integral_add hplus.restrict hminus.restrict, hneg] at hineq
  rw [gaussian_real_set_eq_density_integral B hB, gaussian_translate_integral_density x B hB]
  linarith

/-- Disjoint translates of a symmetric set with Gaussian mass at least
one half obey an explicit packing bound. This is the finite Gaussian
packing step in the dual-Sudakov argument. -/
theorem gaussian_translate_packing {J : Type*} [Fintype J]
    (x : J → I → ℝ) (B : Set (I → ℝ)) (hB : MeasurableSet B)
    (hsym : ∀ y, -y ∈ B ↔ y ∈ B)
    (hmass : (1:ℝ)/2 ≤ (standardGaussian (I := I)).real B)
    (hdisj : Pairwise (fun i j => Disjoint (translateSet (x i) B) (translateSet (x j) B)))
    (R : ℝ) (hR : ∀ j, (∑ i, x j i ^ 2) ≤ R) :
    (Fintype.card J : ℝ) ≤ 2 * Real.exp (R/2) := by
  classical
  have hpoint (j : J) : Real.exp (-R/2)/2 ≤
      (standardGaussian (I := I)).real (translateSet (x j) B) := by
    have he : Real.exp (-R/2) ≤ Real.exp (-(∑ i, x j i^2)/2) := by
      apply Real.exp_le_exp.mpr
      linarith [hR j]
    have hmul := mul_le_mul he hmass (by norm_num : (0:ℝ) ≤ 1/2)
      (Real.exp_pos _).le
    apply le_trans _ (gaussian_translate_lower (x j) B hB hsym)
    simpa only [div_eq_mul_inv, one_mul] using hmul
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hpoint j)
  have hunion := sum_measureReal_le_measureReal_univ
    (μ := standardGaussian (I := I)) (s := (Finset.univ : Finset J))
    (t := fun j => translateSet (x j) B)
    (fun j _ => measurableSet_translateSet (x j) hB)
    (fun i _ j _ hij => hdisj hij)
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hsum
  rw [probReal_univ] at hunion
  have hbound := hsum.trans hunion
  have hscaled := mul_le_mul_of_nonneg_right hbound (Real.exp_pos (R/2)).le
  have he : Real.exp (-R/2) * Real.exp (R/2) = 1 := by
    rw [← Real.exp_add]
    ring_nf
    exact Real.exp_zero
  have halg : (Fintype.card J : ℝ)*(Real.exp (-R/2)/2)*Real.exp (R/2) =
      (Fintype.card J : ℝ)/2 := by
    calc
      _ = (Fintype.card J : ℝ)/2*(Real.exp (-R/2)*Real.exp (R/2)) := by ring
      _ = _ := by rw [he, mul_one]
  rw [halg, one_mul] at hscaled
  linarith

end NeuralGeneralization.GaussianTranslatePacking
