import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.RobustEntropyChain
import NeuralGeneralization.GaussianOrthogonal
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

/-! Covariance control under an actual finite-relative-entropy Gaussian law.
The test function in the variational inequality is a signed quadratic form;
its exponential moment is computed exactly, rather than postulated. -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal

namespace ConditionalNonpolynomial.Analytic

theorem integral_le_kl_add_log_mgf
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) (f : Ω → ℝ)
    (hfi : Integrable f Q)
    (he : Integrable (fun x => Real.exp (f x)) G)
    (B : ℝ) (hB : (∫ x, Real.exp (f x) ∂G) ≤ Real.exp B) :
    (∫ x, f x ∂Q) ≤ (klDiv Q G).toReal + B := by
  obtain ⟨hac, hllr⟩ := klDiv_ne_top_iff.mp hKL
  have hk : Integrable (fun x => klFun (Q.rnDeriv G x).toReal) G :=
    (integrable_klFun_rnDeriv_iff hac).2 hllr
  have hshift : (fun x => Real.exp (f x - B)) =
      (fun x => Real.exp (-B) * Real.exp (f x)) := by
    funext x
    rw [← Real.exp_add]
    congr 1
    ring
  have he' : Integrable (fun x => Real.exp (f x - B)) G := by
    rw [hshift]
    exact he.const_mul _
  have hw : Integrable (fun x => (Q.rnDeriv G x).toReal * (f x - B)) G :=
    (integrable_toReal_rnDeriv_mul_iff hac).2 (hfi.sub (integrable_const B))
  have hh := integral_mono hw ((hk.add he').sub (integrable_const 1))
    (fun x => NeuralGeneralization.RobustEntropyMoments.mul_le_klFun_add_exp
      (u := (Q.rnDeriv G x).toReal) ENNReal.toReal_nonneg (f x - B))
  have hchange : (∫ x, (Q.rnDeriv G x).toReal * (f x - B) ∂G) =
      (∫ x, f x ∂Q) - B := by
    rw [integral_toReal_rnDeriv_mul hac, integral_sub hfi (integrable_const B)]
    simp
  have heBound : (∫ x, Real.exp (f x - B) ∂G) ≤ 1 := by
    rw [hshift, integral_const_mul]
    have h := mul_le_mul_of_nonneg_left hB (Real.exp_pos (-B)).le
    have hid : Real.exp (-B) * Real.exp B = 1 := by rw [← Real.exp_add]; simp
    rwa [hid] at h
  simp only [Pi.add_apply, Pi.sub_apply] at hh
  have hsum : Integrable (fun x => klFun (Q.rnDeriv G x).toReal +
      Real.exp (f x - B)) G := hk.add he'
  rw [hchange, integral_sub hsum (integrable_const 1), integral_add hk he'] at hh
  rw [← toReal_klDiv_eq_integral_klFun hac] at hh
  simp only [integral_const, probReal_univ, one_smul] at hh
  linarith

theorem sqrt_deviation_sq_le_gaussian_cost (v : ℝ) (hv : 0 < v) :
    (Real.sqrt v - 1)^2 ≤ v - 1 - Real.log v := by
  have hs : 0 < Real.sqrt v := Real.sqrt_pos.mpr hv
  have hlog := Real.log_le_sub_one_of_pos hs
  rw [Real.log_sqrt hv.le] at hlog
  have hsq := Real.sq_sqrt hv.le
  nlinarith

theorem gaussian_coordinate_second_moment_integrable
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) :
    Integrable (fun x : I → ℝ => x i ^ 2) Q := by
  classical
  have hi := (NeuralGeneralization.RobustEntropyMoments.standard_gaussian_entropy_second_moment
    Q hKL).1
  apply hi.mono' (((measurable_pi_apply i).pow_const 2).aestronglyMeasurable)
  filter_upwards [] with x
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)

theorem gaussian_coordinate_second_moment_pos
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) :
    0 < ∫ x : I → ℝ, x i ^ 2 ∂Q := by
  letI : NullSingletonClass (gaussianReal 0 1) := nullSingletonClass_gaussianReal (μ := 0) (by norm_num)
  have hnonneg : 0 ≤ ∫ x : I → ℝ, x i ^ 2 ∂Q :=
    integral_nonneg (fun x => sq_nonneg _)
  rcases hnonneg.eq_or_lt with heq | hpos
  · have hzero := (integral_eq_zero_iff_of_nonneg (fun x : I → ℝ => sq_nonneg (x i))
      (gaussian_coordinate_second_moment_integrable Q hKL i)).mp heq.symm
    have hne : ∀ᵐ x : I → ℝ ∂Q, x i ≠ 0 :=
      (klDiv_ne_top_iff.mp hKL).1 (Measure.ae_eval_ne (fun _ : I => gaussianReal 0 1) i 0)
    obtain ⟨x, hx, hnx⟩ := (hzero.and hne).exists
    exact False.elim (hnx (sq_eq_zero_iff.mp hx))
  · exact hpos

/-- The Gaussian covariance entropy cost is a genuine lower bound on the
relative entropy of any probability law with the prescribed positive diagonal
second moments. Off-diagonal covariances and means need not vanish. -/
theorem gaussian_diagonal_moment_entropy
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (v : I → ℝ) (hv : ∀ i, 0 < v i)
    (hm : ∀ i, ∫ x : I → ℝ, x i ^ 2 ∂Q = v i) :
    (∑ i, (v i - 1 - Real.log (v i))) / 2 ≤
      (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  classical
  let G : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1
  let c : I → ℝ := fun i => (1 - (v i)⁻¹) / 2
  let f : (I → ℝ) → ℝ := fun x => ∑ i, c i * ((x i)^2 - 1)
  let B : ℝ := ∑ i, (-c i + Real.log (v i) / 2)
  have hdom (i : I) : 0 < 1 - 2 * (1 : ℝ) * c i * (1 : ℝ≥0) := by
    change 0 < 1 - 2 * 1 * c i * 1
    dsimp [c]
    have := inv_pos.mpr (hv i)
    linarith
  have hi (i : I) : Integrable (fun x : I → ℝ => c i * ((x i)^2 - 1)) Q :=
    ((gaussian_coordinate_second_moment_integrable Q hKL i).sub (integrable_const 1)).const_mul _
  have hfi : Integrable f Q := integrable_finsetSum _ (fun i _ => hi i)
  have he : Integrable (fun x => Real.exp (f x)) G := by
    simpa only [one_mul, NNReal.coe_one, G, f] using
      NeuralGeneralization.GaussianTail.integrable_exp_sum_centered_gaussian_squares
        (fun _ : I => (1 : ℝ≥0)) c 1 hdom
  have hMGF : (∫ x, Real.exp (f x) ∂G) = Real.exp B := by
    have h := NeuralGeneralization.GaussianTail.mgf_sum_centered_gaussian_squares
      (fun _ : I => (1 : ℝ≥0)) c 1 hdom
    simp only [mgf, one_mul, NNReal.coe_one, mul_one] at h
    change (∫ x, Real.exp (f x) ∂G) = _ at h
    rw [h]
    dsimp only [B]
    rw [Real.exp_sum]
    apply Finset.prod_congr rfl
    intro i _
    have heq : 1 - 2 * c i = (v i)⁻¹ := by dsimp [c]; ring
    rw [heq]
    simp only [neg_mul, one_mul]
    have hp : 0 < Real.exp (-c i) / Real.sqrt ((v i)⁻¹) :=
      div_pos (Real.exp_pos _) (Real.sqrt_pos.mpr (inv_pos.mpr (hv i)))
    rw [← Real.exp_log hp, Real.log_div (Real.exp_ne_zero _)
      (Real.sqrt_pos.mpr (inv_pos.mpr (hv i))).ne', Real.log_exp,
      Real.log_sqrt (inv_nonneg.mpr (hv i).le), Real.log_inv]
    congr 1
    ring
  have hdual := integral_le_kl_add_log_mgf Q G hKL f hfi he B hMGF.le
  have hmean : (∫ x, f x ∂Q) = ∑ i, c i * (v i - 1) := by
    rw [show f = fun x => ∑ i, c i * ((x i)^2 - 1) from rfl,
      integral_finsetSum _ (fun i _ => hi i)]
    apply Finset.sum_congr rfl
    intro i _
    rw [integral_const_mul, integral_sub (gaussian_coordinate_second_moment_integrable Q hKL i)
      (integrable_const 1), hm i]
    simp
  rw [hmean] at hdual
  have hid : (∑ i, c i * (v i - 1)) - B =
      (∑ i, (v i - 1 - Real.log (v i))) / 2 := by
    dsimp only [B]
    rw [← Finset.sum_sub_distrib, Finset.sum_div]
    apply Finset.sum_congr rfl
    intro i _
    dsimp [c]
    field_simp [ne_of_gt (hv i)]
    ring
  change _ ≤ (klDiv Q G).toReal
  linarith

theorem gaussian_diagonal_polar_deviation
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (v : I → ℝ) (hv : ∀ i, 0 < v i)
    (hm : ∀ i, ∫ x : I → ℝ, x i ^ 2 ∂Q = v i) :
    (∑ i, (Real.sqrt (v i) - 1)^2) ≤
      2 * (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  have h1 := gaussian_diagonal_moment_entropy Q hKL v hv hm
  have h2 := Finset.sum_le_sum (s := Finset.univ)
    (fun i _ => sqrt_deviation_sq_le_gaussian_cost (v i) (hv i))
  linarith

#print axioms gaussian_diagonal_polar_deviation

/-- No positivity or finite-moment hypotheses need to be supplied: finite KL
itself forces every coordinate second moment to be positive and finite. -/
theorem gaussian_actual_polar_deviation
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    (∑ i, (Real.sqrt (∫ x : I → ℝ, x i ^ 2 ∂Q) - 1)^2) ≤
      2 * (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal :=
  gaussian_diagonal_polar_deviation Q hKL _
    (gaussian_coordinate_second_moment_pos Q hKL) (fun _ => rfl)

/-- The same actual entropy budget controls second moments in every orthogonal
coordinate system, in particular in an eigenbasis of the full second-moment
matrix. The law need not be centered. -/
theorem gaussian_orthogonal_polar_deviation
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (u : EuclideanSpace ℝ I ≃ₗᵢ[ℝ] EuclideanSpace ℝ I) :
    (∑ i, (Real.sqrt (∫ x : I → ℝ,
      (NeuralGeneralization.GaussianOrthogonal.coordinateMap u x i)^2 ∂Q) - 1)^2) ≤
      2 * (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  let G : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1
  let T := NeuralGeneralization.GaussianOrthogonal.coordinateMap u
  have hT : Measurable T :=
    NeuralGeneralization.GaussianOrthogonal.coordinateMap_measurable u
  have hG : G.map T = G :=
    NeuralGeneralization.GaussianOrthogonal.productGaussian_map_coordinateMap 1 u
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q G hT
  rw [hG] at hdata
  have hfinite : klDiv (Q.map T) G ≠ ∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  haveI : IsProbabilityMeasure (Q.map T) := Measure.isProbabilityMeasure_map hT.aemeasurable
  have h := gaussian_actual_polar_deviation (Q.map T) hfinite
  have hreal : (klDiv (Q.map T) G).toReal ≤ (klDiv Q G).toReal :=
    ENNReal.toReal_mono hKL hdata
  have hi (i : I) : (∫ x : I → ℝ, x i^2 ∂Q.map T) =
      ∫ x : I → ℝ, (T x i)^2 ∂Q :=
    integral_map hT.aemeasurable (((measurable_pi_apply i).pow_const 2).aestronglyMeasurable)
  simp_rw [hi] at h
  exact h.trans (mul_le_mul_of_nonneg_left hreal (by norm_num))

#print axioms gaussian_actual_polar_deviation
#print axioms gaussian_orthogonal_polar_deviation

end ConditionalNonpolynomial.Analytic
