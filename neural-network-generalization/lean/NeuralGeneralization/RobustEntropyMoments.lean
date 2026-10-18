import Mathlib.InformationTheory.KullbackLeibler.Basic
import NeuralGeneralization.GaussianTail

/-!
# Exponential moments under an arbitrary finite-KL change of Gaussian law

These are measure-theoretic inequalities for the actual Mathlib divergence.
No transport or entropy inequality is assumed. The scalar convex-duality
inequality is proved directly from `1 + x ≤ exp x`.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal

namespace NeuralGeneralization.RobustEntropyMoments

theorem mul_le_klFun_add_exp {u : ℝ} (hu : 0 ≤ u) (v : ℝ) :
    u * v ≤ klFun u + Real.exp v - 1 := by
  rcases eq_or_lt_of_le hu with rfl | hu
  · simp only [zero_mul, klFun, Real.log_zero, sub_zero]
    linarith [Real.exp_pos v]
  · have h := mul_le_mul_of_nonneg_left (Real.add_one_le_exp (v - Real.log u)) hu.le
    have he : u * Real.exp (v - Real.log u) = Real.exp v := by
      rw [Real.exp_sub, Real.exp_log hu]
      field_simp
    rw [he] at h
    unfold klFun
    nlinarith

theorem integrable_of_exp_integrable_finite_kl
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) (f : Ω → ℝ)
    (hf : Measurable f) (hf0 : ∀ x, 0 ≤ f x)
    (he : Integrable (fun x => Real.exp (f x)) G) : Integrable f Q := by
  obtain ⟨hac, hllr⟩ := klDiv_ne_top_iff.mp hKL
  have hk : Integrable (fun x => klFun (Q.rnDeriv G x).toReal) G :=
    (integrable_klFun_rnDeriv_iff hac).2 hllr
  have hw : Integrable (fun x => (Q.rnDeriv G x).toReal * f x) G := by
    apply (hk.add he).mono' (by fun_prop)
    exact Filter.Eventually.of_forall fun x => by
      rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg ENNReal.toReal_nonneg (hf0 x))]
      have h := mul_le_klFun_add_exp (u := (Q.rnDeriv G x).toReal)
        ENNReal.toReal_nonneg (f x)
      simp only [Pi.add_apply]
      linarith
  exact (integrable_toReal_rnDeriv_mul_iff hac).mp hw

theorem integral_le_kl_add_exponential_bound
    {Ω : Type*} [MeasurableSpace Ω] (Q G : Measure Ω)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) (f : Ω → ℝ)
    (hf : Measurable f) (hf0 : ∀ x, 0 ≤ f x)
    (he : Integrable (fun x => Real.exp (f x)) G)
    (B : ℝ) (hB : (∫ x, Real.exp (f x) ∂G) ≤ Real.exp B) :
    (∫ x, f x ∂Q) ≤ (klDiv Q G).toReal + B := by
  obtain ⟨hac, hllr⟩ := klDiv_ne_top_iff.mp hKL
  have hfi := integrable_of_exp_integrable_finite_kl Q G hKL f hf hf0 he
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
    (fun x => mul_le_klFun_add_exp (u := (Q.rnDeriv G x).toReal)
      ENNReal.toReal_nonneg (f x - B))
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
  rw [hchange, integral_sub hsum (integrable_const 1),
    integral_add hk he'] at hh
  rw [← toReal_klDiv_eq_integral_klFun hac] at hh
  simp only [integral_const, probReal_univ, one_smul] at hh
  linarith

theorem standard_gaussian_entropy_second_moment
    {I : Type*} [Fintype I] (Q : Measure (I → ℝ))
    [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    Integrable (fun x : I → ℝ => ∑ i, x i ^ 2) Q ∧
      (∫ x : I → ℝ, (∑ i, x i ^ 2) ∂Q) ≤
        4 * (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal +
          2 * Fintype.card I := by
  let G : Measure (I → ℝ) := Measure.pi fun _ => gaussianReal 0 1
  let f : (I → ℝ) → ℝ := fun x => (1 / 4 : ℝ) * ∑ i, x i ^ 2
  let g : (I → ℝ) → ℝ := fun x => (1 / 4 : ℝ) * ∑ i, (x i ^ 2 - 1)
  have hfg (x : I → ℝ) : f x = g x + (Fintype.card I : ℝ) / 4 := by
    dsimp [f, g]
    simp only [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul, mul_one]
    ring
  have heq : (fun x => Real.exp (f x)) =
      (fun x => Real.exp ((Fintype.card I : ℝ) / 4) * Real.exp (g x)) := by
    funext x
    rw [hfg, Real.exp_add, mul_comm]
  have heg : Integrable (fun x => Real.exp (g x)) G := by
    simpa [g, G] using GaussianTail.integrable_exp_sum_centered_gaussian_squares
      (fun _ : I => (1 : ℝ≥0)) (fun _ => (1 : ℝ)) (1 / 4)
      (fun _ => by norm_num)
  have he : Integrable (fun x => Real.exp (f x)) G := by
    rw [heq]
    exact heg.const_mul _
  have hmg : (∫ x, Real.exp (g x) ∂G) ≤
      Real.exp ((Fintype.card I : ℝ) / 4) := by
    have h := GaussianTail.mgf_sum_centered_gaussian_squares_le
      (fun _ : I => (1 : ℝ≥0)) (fun _ => (1 : ℝ)) (1 / 4)
      (fun _ => by norm_num)
    norm_num [mgf, g, G, div_eq_mul_inv] at h ⊢
    convert h using 1 <;> congr 1 <;> ring
  have hm : (∫ x, Real.exp (f x) ∂G) ≤
      Real.exp ((Fintype.card I : ℝ) / 2) := by
    rw [heq, integral_const_mul]
    calc
      _ ≤ Real.exp ((Fintype.card I : ℝ) / 4) *
          Real.exp ((Fintype.card I : ℝ) / 4) :=
        mul_le_mul_of_nonneg_left hmg (Real.exp_pos _).le
      _ = _ := by rw [← Real.exp_add]; congr 1; ring
  have hf : Measurable f := by dsimp [f]; fun_prop
  have hf0 : ∀ x, 0 ≤ f x := by
    intro x
    dsimp [f]
    exact mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ => sq_nonneg (x i))
  have hfi := integrable_of_exp_integrable_finite_kl Q G hKL f hf hf0 he
  have hei : Integrable (fun x : I → ℝ => ∑ i, x i ^ 2) Q := by
    convert hfi.const_mul 4 using 1
    ext x
    dsimp [f]
    ring
  refine ⟨hei, ?_⟩
  have hb := integral_le_kl_add_exponential_bound Q G hKL f hf hf0 he
    ((Fintype.card I : ℝ) / 2) hm
  dsimp [f] at hb
  rw [integral_const_mul] at hb
  change _ ≤ 4 * (klDiv Q G).toReal + _
  linarith

/-- The active Gram--Schmidt coordinates may include zero columns. This version
allows every reference variance between zero and one, so no ambient-width term
is introduced by extending a rank-deficient active basis. -/
theorem bounded_variance_gaussian_entropy_second_moment
    {I : Type*} [Fintype I] (v : I → ℝ≥0) (hv : ∀ i, v i ≤ 1)
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun i => gaussianReal 0 (v i)) ≠ ∞) :
    Integrable (fun x : I → ℝ => ∑ i, x i ^ 2) Q ∧
      (∫ x : I → ℝ, (∑ i, x i ^ 2) ∂Q) ≤
        4 * (klDiv Q (Measure.pi fun i => gaussianReal 0 (v i))).toReal +
          2 * Fintype.card I := by
  let G : Measure (I → ℝ) := Measure.pi fun i => gaussianReal 0 (v i)
  let f : (I → ℝ) → ℝ := fun x => (1/4:ℝ)*∑ i, x i^2
  let g : (I → ℝ) → ℝ := fun x => (1/4:ℝ)*∑ i, (x i^2-(v i:ℝ))
  have hvR (i : I) : (v i : ℝ) ≤ 1 := by exact_mod_cast hv i
  have hsum : (∑ i, (v i:ℝ)) ≤ (Fintype.card I:ℝ) := by
    simpa using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hvR i)
  have hsum2 : (∑ i, (v i:ℝ)^2) ≤ (Fintype.card I:ℝ) := by
    have hp (i : I) : (v i:ℝ)^2 ≤ 1 := by nlinarith [(v i).coe_nonneg, hvR i]
    simpa using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hp i)
  have heg : Integrable (fun x => Real.exp (g x)) G := by
    simpa only [g, G, one_mul] using GaussianTail.integrable_exp_sum_centered_gaussian_squares v
      (fun _ => 1) (1/4) (fun i => by nlinarith [hvR i])
  have hfg (x : I → ℝ) : f x = g x+(∑ i, (v i:ℝ))/4 := by
    dsimp [f,g]
    simp only [Finset.sum_sub_distrib]
    ring
  have heq : (fun x => Real.exp (f x)) =
      (fun x => Real.exp ((∑ i, (v i:ℝ))/4)*Real.exp (g x)) := by
    funext x
    rw [hfg, Real.exp_add, mul_comm]
  have he : Integrable (fun x => Real.exp (f x)) G := by
    rw [heq]
    exact heg.const_mul _
  have hmg : (∫ x, Real.exp (g x) ∂G) ≤
      Real.exp ((Fintype.card I:ℝ)/4) := by
    have h := GaussianTail.mgf_sum_centered_gaussian_squares_le v
      (fun _ => 1) (1/4) (fun i => by nlinarith [hvR i])
    simp only [mgf, one_mul, one_pow] at h
    change (∫ x, Real.exp (g x) ∂G) ≤ _ at h
    apply h.trans
    apply Real.exp_le_exp.mpr
    norm_num only
    linarith
  have hm : (∫ x, Real.exp (f x) ∂G) ≤ Real.exp ((Fintype.card I:ℝ)/2) := by
    rw [heq, integral_const_mul]
    calc
      _ ≤ Real.exp ((∑ i, (v i:ℝ))/4)*Real.exp ((Fintype.card I:ℝ)/4) :=
        mul_le_mul_of_nonneg_left hmg (Real.exp_pos _).le
      _ = Real.exp ((∑ i, (v i:ℝ))/4+(Fintype.card I:ℝ)/4) := (Real.exp_add _ _).symm
      _ ≤ _ := Real.exp_le_exp.mpr (by linarith)
  have hf : Measurable f := by dsimp [f]; fun_prop
  have hf0 : ∀ x, 0 ≤ f x := by
    intro x
    dsimp [f]
    positivity
  have hfi := integrable_of_exp_integrable_finite_kl Q G hKL f hf hf0 he
  have hei : Integrable (fun x : I → ℝ => ∑ i, x i^2) Q := by
    convert hfi.const_mul 4 using 1
    ext x
    dsimp [f]
    ring
  refine ⟨hei, ?_⟩
  have hb := integral_le_kl_add_exponential_bound Q G hKL f hf hf0 he
    ((Fintype.card I:ℝ)/2) hm
  dsimp [f] at hb
  rw [integral_const_mul] at hb
  change _ ≤ 4*(klDiv Q G).toReal+_
  linarith

end NeuralGeneralization.RobustEntropyMoments
