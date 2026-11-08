import NeuralGeneralization.OnlineLowerTanhPeriodicCurvature
import NeuralGeneralization.OnlineLowerReluCosineProduct

/-! # Quantitative finite-cube stability of the periodic maxima -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma one_sub_exp_neg_lower {y : ℝ} (hy : 0 ≤ y) :
    (1/2)*min y 1 ≤ 1-Real.exp (-y) := by
  have he := Real.add_one_le_exp y
  have hp := Real.exp_pos y
  have hi : Real.exp (-y) ≤ 1/(1+y) := by
    rw [Real.exp_neg]
    simpa only [one_div] using one_div_le_one_div_of_le (by positivity : (0:ℝ)<1+y) (show 1+y ≤ Real.exp y by linarith)
  by_cases hy1 : y ≤ 1
  · rw [min_eq_left hy1]
    have hd : 0 < 1+y := by positivity
    have hfrac : y/2 ≤ 1-1/(1+y) := by
      have heq : 1-1/(1+y) = y/(1+y) := by field_simp; ring
      rw [heq]
      apply (le_div_iff₀ hd).mpr
      nlinarith
    linarith
  · have hy1' : 1 ≤ y := le_of_lt (lt_of_not_ge hy1)
    rw [min_eq_right hy1']
    have hfrac : 1/(1+y) ≤ (1/2 : ℝ) := by
      apply (div_le_iff₀ (by positivity : 0 < 1+y)).mpr
      linarith
    linarith

lemma cos_le_exp_square {x : ℝ} (hx : |x| ≤ Real.pi) :
    Real.cos x ≤ Real.exp (-(2/Real.pi^2*x^2)) := by
  have hc := Real.cos_le_one_sub_mul_cos_sq hx
  have he := Real.add_one_le_exp (-(2/Real.pi^2*x^2))
  linarith

lemma cosine_cube_mean {d : ℕ} (t : ℝ) (u : Fin d → ℝ) :
    uniformCubeMean (fun x => Real.cos (t*incomingLinear u x)) =
      ∏ i, Real.cos (t*u i) := by
  have h := OnlineLowerRelu.walsh_cosine_frequency_even
    (d := d) (r := 0) ∅ (by simp) t 0 u
  have hlabel (b : Bool) : cubeCoordinateSign b = ConcreteModel.labelReal b := by
    cases b <;> rfl
  simp only [walshCharacter, Finset.prod_empty, one_mul, mul_zero,
    Real.cos_zero, pow_zero, mul_one, OnlineLowerRelu.trigProduct,
    Finset.notMem_empty, if_false, OnlineLowerRelu.cubeAffine, zero_add] at h
  simp_rw [hlabel] at h
  unfold uniformCubeMean incomingLinear
  rw [h]
  simp [ClippingCube]

lemma periodic_signed_peak_deficit {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (z : ℝ) :
    periodicCoefficient a 0/100*(1+Real.cos (periodicFrequency a*z)) ≤
      periodicFourierMaximum a+periodicFourierResponse a (a+z) := by
  have h := periodic_peak_deficit ha ha2 (z+2*a)
  have hphase : periodicFrequency a*(z+2*a) = periodicFrequency a*z+Real.pi := by
    have hw := periodicFrequency_mul_gain ha.ne'
    nlinarith
  have harg : a+(z+2*a) = (a+z)+2*a := by ring
  rw [hphase, Real.cos_add_pi, harg, periodicFourierResponse_antiperiod ha] at h
  linarith

/-- Averaging cannot hide a phase deficit: the absolute mean response loses
at least a constant times the cosine-characteristic deficit. -/
lemma periodic_average_deficit {ι : Type*} [Fintype ι]
    {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (p z : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (hcos : 0 ≤ ∑ i, p i*Real.cos (periodicFrequency a*z i)) :
    periodicCoefficient a 0/100*(1-∑ i, p i*Real.cos (periodicFrequency a*z i)) ≤
      periodicFourierMaximum a - |∑ i, p i*periodicFourierResponse a (a+z i)| := by
  have hpos := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
    mul_le_mul_of_nonneg_left (periodic_peak_deficit ha ha2 (z i)) (hp i))
  have hneg := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
    mul_le_mul_of_nonneg_left (periodic_signed_peak_deficit ha ha2 (z i)) (hp i))
  have hreshape₁ : (∑ i, p i*(periodicCoefficient a 0/100*(1-Real.cos (periodicFrequency a*z i)))) =
      periodicCoefficient a 0/100*(1-∑ i, p i*Real.cos (periodicFrequency a*z i)) := by
    simp_rw [mul_sub, mul_one, ← mul_assoc]
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hsum, one_mul]
    rw [Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hreshape₂ : (∑ i, p i*(periodicCoefficient a 0/100*(1+Real.cos (periodicFrequency a*z i)))) =
      periodicCoefficient a 0/100*(1+∑ i, p i*Real.cos (periodicFrequency a*z i)) := by
    simp_rw [mul_add, mul_one, ← mul_assoc]
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, hsum, one_mul]
    rw [Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hreshape₁] at hpos
  rw [hreshape₂] at hneg
  simp_rw [mul_sub, mul_add, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    ← Finset.sum_mul, hsum, one_mul] at hpos hneg
  have hnon := periodicCoefficient_pos ha 0
  rcases le_total 0 (∑ i, p i*periodicFourierResponse a (a+z i)) with h | h
  · rw [abs_of_nonneg h]
    nlinarith [hpos]
  · rw [abs_of_nonpos h]
    nlinarith

lemma periodic_phase_cos_nonneg {a : ℝ} (ha : 0 < a) {z : ℝ} (hz : |z| ≤ a) :
    0 ≤ Real.cos (periodicFrequency a*z) := by
  have hw := periodicFrequency_pos ha
  have hb : |periodicFrequency a*z| ≤ Real.pi/2 := by
    rw [abs_mul, abs_of_pos hw]
    calc
      _ ≤ periodicFrequency a*a := mul_le_mul_of_nonneg_left hz hw.le
      _ = _ := periodicFrequency_mul_gain ha.ne'
  exact Real.cos_nonneg_of_mem_Icc (abs_le.mp hb)

lemma periodic_phase_product_bound {d : ℕ} {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (u : Fin d → ℝ) (hu : ∀ i, |u i| ≤ a) :
    (∏ i, Real.cos (periodicFrequency a*u i)) ≤ Real.exp (-incomingEnergy u/8) := by
  have hprod : (∏ i, Real.cos (periodicFrequency a*u i)) ≤
      ∏ i, Real.exp (-(2/Real.pi^2*(periodicFrequency a*u i)^2)) := by
    apply Finset.prod_le_prod
    · intro i _
      exact periodic_phase_cos_nonneg ha (hu i)
    · intro i _
      apply cos_le_exp_square
      have hw := periodicFrequency_pos ha
      rw [abs_mul, abs_of_pos hw]
      calc
        _ ≤ periodicFrequency a*a := mul_le_mul_of_nonneg_left (hu i) hw.le
        _ = Real.pi/2 := periodicFrequency_mul_gain ha.ne'
        _ ≤ Real.pi := by linarith [Real.pi_pos]
  rw [← Real.exp_sum] at hprod
  apply hprod.trans
  apply Real.exp_le_exp.mpr
  have he (i : Fin d) : 2/Real.pi^2*(periodicFrequency a*u i)^2 = (u i)^2/(2*a^2) := by
    unfold periodicFrequency
    field_simp
    <;> ring
  simp_rw [he]
  rw [Finset.sum_neg_distrib, ← Finset.sum_div]
  rw [neg_div]
  change -(incomingEnergy u/(2*a^2)) ≤ -(incomingEnergy u/8)
  have hE : 0 ≤ incomingEnergy u := Finset.sum_nonneg (fun i _ => sq_nonneg (u i))
  have haSq : 2*a^2 ≤ 8 := by nlinarith
  have hdiv := div_le_div_of_nonneg_left hE (by positivity : 0 < 2*a^2) haSq
  linarith

lemma periodic_phase_product_deficit {d : ℕ} {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (u : Fin d → ℝ) (hu : ∀ i, |u i| ≤ a) :
    (1/16)*min (incomingEnergy u) 1 ≤ 1-∏ i, Real.cos (periodicFrequency a*u i) := by
  have hE : 0 ≤ incomingEnergy u := Finset.sum_nonneg (fun i _ => sq_nonneg (u i))
  have h := one_sub_exp_neg_lower (show 0 ≤ incomingEnergy u/8 by positivity)
  have hp := periodic_phase_product_bound ha ha2 u hu
  rw [neg_div] at hp
  have hm : min (incomingEnergy u) 1 / 8 ≤ min (incomingEnergy u/8) 1 := by
    apply le_min
    · exact div_le_div_of_nonneg_right (min_le_left _ _) (by norm_num)
    · have hh := min_le_right (incomingEnergy u) 1
      linarith
  nlinarith

/-- An actual Rademacher phase perturbation loses a fixed fraction of its
variance (up to saturation), uniformly throughout the competitive gain range. -/
theorem periodic_cube_phase_stability {d : ℕ} {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (u : Fin d → ℝ) (hu : ∀ i, |u i| ≤ a) :
    periodicCoefficient a 0/1600*min (incomingEnergy u) 1 ≤
      periodicFourierMaximum a - |uniformCubeMean
        (fun x => periodicFourierResponse a (a+incomingLinear u x))| := by
  let p : ConcreteModel.Cube d → ℝ := fun _ => (Fintype.card (ConcreteModel.Cube d):ℝ)⁻¹
  have hc : (0:ℝ) < Fintype.card (ConcreteModel.Cube d) := by
    exact_mod_cast Fintype.card_pos
  have hsum : ∑ x, p x = 1 := by simp [p]
  have hm (f : ConcreteModel.Cube d → ℝ) : ∑ x, p x*f x = uniformCubeMean f := by
    unfold p uniformCubeMean
    rw [← Finset.mul_sum, div_eq_mul_inv]
    change _ = _ * (Fintype.card (ConcreteModel.Cube d):ℝ)⁻¹
    ring
  have hcos : 0 ≤ ∑ x, p x*Real.cos (periodicFrequency a*incomingLinear u x) := by
    rw [hm, cosine_cube_mean]
    exact Finset.prod_nonneg (fun i _ => periodic_phase_cos_nonneg ha (hu i))
  have h := periodic_average_deficit ha ha2 p (incomingLinear u)
    (fun _ => inv_nonneg.mpr hc.le) hsum hcos
  rw [hm, hm, cosine_cube_mean] at h
  have hh := mul_le_mul_of_nonneg_left (periodic_phase_product_deficit ha ha2 u hu)
    (show 0 ≤ periodicCoefficient a 0/100 from by positivity [periodicCoefficient_pos ha 0])
  calc
    _ = periodicCoefficient a 0/100*((1/16)*min (incomingEnergy u) 1) := by ring
    _ ≤ _ := hh.trans h

end NeuralGeneralization.OnlineLowerTanh
