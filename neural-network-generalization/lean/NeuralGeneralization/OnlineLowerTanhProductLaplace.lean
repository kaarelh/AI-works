import NeuralGeneralization.OnlineLowerTanhLaplaceWindow
import NeuralGeneralization.OnlineLowerTanhLocalizationCore
import NeuralGeneralization.OnlineLowerFiniteHolder

/-! # Global exponential moments of full sine products -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma exponential_split_pow (n : ℕ) (hn : 0<n) (x : ℝ) :
    Real.exp (x/n)^n = Real.exp x := by
  rw [← Real.exp_nat_mul]
  congr 1
  field_simp

/-- The full product has a dimension-sharp exponential moment uniformly
in every individual incoming frequency. -/
theorem paritySineProduct_laplace {n : ℕ} (hn : 0<n) (u : Fin n → ℝ)
    (c : ℝ) (hc : 0<c) :
    IntegrableOn (fun t => Real.exp (-c*t)*paritySineProduct u t) (Ioi 0) ∧
      Real.sqrt (n:ℝ)*(∫t : ℝ in Ioi 0, Real.exp (-c*t)*paritySineProduct u t) ≤ Real.pi/c := by
  let f : Fin n → ℝ → ℝ := fun i t => Real.exp ((-c*t)/n)*|Real.sin (t*u i)|
  have hpow (i : Fin n) (t : ℝ) : f i t^n = Real.exp (-c*t)*|Real.sin (u i*t)|^n := by
    dsimp [f]
    rw [mul_pow,exponential_split_pow n hn,mul_comm t (u i)]
  have hprod (t : ℝ) : (∏ i, f i t)=Real.exp (-c*t)*paritySineProduct u t := by
    simp only [f,Finset.prod_mul_distrib,Finset.prod_const,Finset.card_univ,Fintype.card_fin,
      exponential_split_pow n hn,paritySineProduct]
  have hroot : 0<Real.sqrt (n:ℝ) := Real.sqrt_pos.mpr (by positivity)
  obtain ⟨hi,hb⟩ := OnlineLower.integrable_prod_and_integral_prod_le_of_uniform
    (volume.restrict (Ioi (0:ℝ))) (by simpa using hn) f
    (fun i t => mul_nonneg (Real.exp_pos _).le (abs_nonneg _))
    (fun i => (by fun_prop : Continuous (f i)).aestronglyMeasurable)
    (fun i => by simpa only [Fintype.card_fin,hpow,IntegrableOn] using integrable_laplace_absSinePower n c (u i) hc)
    ((Real.pi/c)/Real.sqrt (n:ℝ)) (by positivity)
    (fun i => by
      simp only [Fintype.card_fin,hpow]
      exact (le_div_iff₀ hroot).mpr (by
        simpa only [laplaceAbsSinePower,mul_comm] using laplace_abs_sqrt_bound n hn c (u i) hc))
  simp_rw [hprod] at hi hb
  refine ⟨hi,?_⟩
  simpa only [mul_comm] using (le_div_iff₀ hroot).mp hb

/-- The square root of an even-dimensional sine product has the same
uniform exponential estimate, with the half-degree normalization. -/
theorem sqrt_paritySineProduct_laplace_even (r : ℕ) (hr : 0<r)
    (u : Fin (2*r) → ℝ) (c : ℝ) (hc : 0<c) :
    IntegrableOn (fun t => Real.exp (-c*t)*Real.sqrt (paritySineProduct u t)) (Ioi 0) ∧
      Real.sqrt (r:ℝ)*(∫t : ℝ in Ioi 0, Real.exp (-c*t)*Real.sqrt (paritySineProduct u t)) ≤ Real.pi/c := by
  let f : Fin (2*r) → ℝ → ℝ := fun i t =>
    Real.exp ((-c*t)/(2*r:ℕ))*Real.sqrt |Real.sin (t*u i)|
  have hn : 0<2*r := by omega
  have hpow (i : Fin (2*r)) (t : ℝ) :
      f i t^(2*r) = Real.exp (-c*t)*|Real.sin (u i*t)|^r := by
    dsimp [f]
    rw [mul_pow,exponential_split_pow (2*r) hn,pow_mul,Real.sq_sqrt (abs_nonneg _),mul_comm t (u i)]
  have hprod (t : ℝ) : (∏ i, f i t)=Real.exp (-c*t)*Real.sqrt (paritySineProduct u t) := by
    simp only [f,Finset.prod_mul_distrib,Finset.prod_const,Finset.card_univ,Fintype.card_fin,
      exponential_split_pow (2*r) hn,paritySineProduct]
    rw [Real.sqrt_prod _ (fun i _ => abs_nonneg _)]
  have hroot : 0<Real.sqrt (r:ℝ) := Real.sqrt_pos.mpr (by positivity)
  obtain ⟨hi,hb⟩ := OnlineLower.integrable_prod_and_integral_prod_le_of_uniform
    (volume.restrict (Ioi (0:ℝ))) (by simpa using hn) f
    (fun i t => mul_nonneg (Real.exp_pos _).le (Real.sqrt_nonneg _))
    (fun i => (by fun_prop : Continuous (f i)).aestronglyMeasurable)
    (fun i => by simpa only [Fintype.card_fin,hpow,IntegrableOn] using integrable_laplace_absSinePower r c (u i) hc)
    ((Real.pi/c)/Real.sqrt (r:ℝ)) (by positivity)
    (fun i => by
      simp only [Fintype.card_fin,hpow]
      exact (le_div_iff₀ hroot).mpr (by
        simpa only [laplaceAbsSinePower,mul_comm] using laplace_abs_sqrt_bound r hr c (u i) hc))
  simp_rw [hprod] at hi hb
  refine ⟨hi,?_⟩
  simpa only [mul_comm] using (le_div_iff₀ hroot).mp hb

/-- Dropping a single factor handles odd degree without fractional sine
powers in the scalar moment theorem. -/
theorem sqrt_paritySineProduct_laplace (r : ℕ) (hr : 0<r)
    (u : Fin (2*r+1) → ℝ) (c : ℝ) (hc : 0<c) :
    IntegrableOn (fun t => Real.exp (-c*t)*Real.sqrt (paritySineProduct u t)) (Ioi 0) ∧
      Real.sqrt (2*r+1:ℕ)*(∫t : ℝ in Ioi 0, Real.exp (-c*t)*Real.sqrt (paritySineProduct u t)) ≤ 2*Real.pi/c := by
  let v : Fin (2*r) → ℝ := fun i => u i.succ
  have hpoint (t : ℝ) : Real.sqrt (paritySineProduct u t) ≤ Real.sqrt (paritySineProduct v t) := by
    apply Real.sqrt_le_sqrt
    change (∏i,|Real.sin (t*u i)|) ≤ ∏i,|Real.sin (t*v i)|
    rw [Fin.prod_univ_succ]
    exact mul_le_of_le_one_left (paritySineProduct_nonneg v t) (Real.abs_sin_le_one _)
  obtain ⟨hvi,hvb⟩ := sqrt_paritySineProduct_laplace_even r hr v c hc
  have hui : IntegrableOn (fun t => Real.exp (-c*t)*Real.sqrt (paritySineProduct u t)) (Ioi 0) := by
    apply hvi.mono'
    · exact ((continuous_paritySineProduct u).sqrt.mul (by fun_prop)).aestronglyMeasurable.congr
        (Filter.Eventually.of_forall (fun t => mul_comm _ _))
    · filter_upwards [] with t
      rw [Real.norm_eq_abs,abs_of_nonneg (by positivity)]
      exact mul_le_mul_of_nonneg_left (hpoint t) (Real.exp_pos _).le
  have hle := integral_mono hui hvi
    (fun t => mul_le_mul_of_nonneg_left (hpoint t) (Real.exp_pos _).le)
  have hnroot : Real.sqrt (2*r+1:ℕ) ≤ 2*Real.sqrt (r:ℝ) := by
    have h1 := Real.sq_sqrt (show (0:ℝ)≤(2*r+1:ℕ) by positivity)
    have h2 := Real.sq_sqrt (show (0:ℝ)≤r by positivity)
    have h3 : (1:ℝ)≤r := by exact_mod_cast hr
    have hpos := Real.sqrt_nonneg (r:ℝ)
    push_cast at h1 ⊢
    nlinarith [Real.sqrt_nonneg (2*r+1:ℕ)]
  have hIntNonneg : 0 ≤ ∫t : ℝ in Ioi 0,Real.exp (-c*t)*Real.sqrt (paritySineProduct u t) :=
    integral_nonneg (fun t => by positivity)
  refine ⟨hui,?_⟩
  have hh := mul_le_mul hnroot hle hIntNonneg (by positivity)
  calc
    _ ≤ 2*(Real.sqrt (r:ℝ)*(∫t : ℝ in Ioi 0,Real.exp (-c*t)*Real.sqrt (paritySineProduct v t))) := by
      nlinarith only [hh]
    _ ≤ 2*(Real.pi/c) := mul_le_mul_of_nonneg_left hvb (by norm_num)
    _ = 2*Real.pi/c := by ring

end NeuralGeneralization.OnlineLowerTanh
