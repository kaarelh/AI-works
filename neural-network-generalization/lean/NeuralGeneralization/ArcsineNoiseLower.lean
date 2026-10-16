import NeuralGeneralization.ArcsineNoiseTail
import NeuralGeneralization.FinitePaley
import Mathlib.Analysis.Real.Pi.Bounds

/-!
# Lower endpoint and noise estimates for the actual iterated arcsine kernel

The endpoint estimates use elementary trigonometry, and the noise moments
come from the exact finite product law. No composed-series asymptotic or
hypothesized spectral estimate is used.
-/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

theorem arcsineLink_endpoint_square_lower {t : ℝ} (ht : |t| ≤ 1) :
    1-t ≤ 2*(1-arcsineLink t)^2 := by
  have hc := Real.one_sub_sq_div_two_le_cos (x := Real.arccos t)
  rw [Real.cos_arccos (abs_le.mp ht).1 (abs_le.mp ht).2] at hc
  have he : Real.pi^2*(1-arcsineLink t)^2 = 4*Real.arccos t^2 := by
    unfold arcsineLink Real.arccos
    field_simp
    ring
  have hp : Real.pi^2 ≤ 16 := by nlinarith [Real.pi_lt_four,Real.pi_pos]
  have hm := mul_le_mul_of_nonneg_right hp (sq_nonneg (1-arcsineLink t))
  nlinarith

/-- Both sides involve the actual composition. The depth-dependent power is
exactly the reciprocal of its endpoint Hölder exponent. -/
theorem iteratedArcsine_endpoint_power_lower {t : ℝ} (ht : |t| ≤ 1) (k : ℕ) :
    2*(1-t) ≤ (2*(1-iteratedArcsine k t))^(2^k) := by
  induction k with
  | zero => simp [iteratedArcsine]
  | succ k ih =>
    have hr := arcsineLink_endpoint_square_lower (abs_iteratedArcsine_le_one ht k)
    have hm : 2*(1-iteratedArcsine k t) ≤
        (2*(1-iteratedArcsine (k+1) t))^2 := by
      change _ ≤ (2*(1-arcsineLink (iteratedArcsine k t)))^2
      nlinarith
    have h0 : 0 ≤ 2*(1-iteratedArcsine k t) := by
      have := (abs_le.mp (abs_iteratedArcsine_le_one ht k)).2
      linarith
    calc
      _ ≤ (2*(1-iteratedArcsine k t))^(2^k) := ih
      _ ≤ ((2*(1-iteratedArcsine (k+1) t))^2)^(2^k) :=
        pow_le_pow_left₀ h0 hm _
      _ = _ := by rw [← pow_mul,pow_succ]; congr 1; omega

theorem cubeNoiseMean_add {d : ℕ} (ρ : ℝ) (P Q : ClippingCube d → ℝ) :
    cubeNoiseMean ρ (fun x => P x+Q x) = cubeNoiseMean ρ P+cubeNoiseMean ρ Q := by
  simp [cubeNoiseMean,mul_add,Finset.sum_add_distrib]

theorem cubeNoiseMean_const_mul {d : ℕ} (ρ c : ℝ) (P : ClippingCube d → ℝ) :
    cubeNoiseMean ρ (fun x => c*P x) = c*cubeNoiseMean ρ P := by
  simp only [cubeNoiseMean,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x hx
  ring

theorem cubeNoiseMean_sum {d : ℕ} {ι : Type*} [Fintype ι]
    (ρ : ℝ) (P : ι → ClippingCube d → ℝ) :
    cubeNoiseMean ρ (fun x => ∑ i,P i x) = ∑ i,cubeNoiseMean ρ (P i) := by
  simp only [cubeNoiseMean,Finset.mul_sum]
  rw [Finset.sum_comm]

theorem cubeNoiseMean_coordinate {d : ℕ} (ρ : ℝ) (i : Fin d) :
    cubeNoiseMean ρ (fun x => cubeCoordinateSign (x i)) = ρ := by
  simpa [cubeNoiseMean,walshCharacter] using cubeNoiseWeight_walsh_moment d ρ {i}

theorem cubeNoiseMean_coordinate_product {d : ℕ} (ρ : ℝ) (i j : Fin d) :
    cubeNoiseMean ρ (fun x => cubeCoordinateSign (x i)*cubeCoordinateSign (x j)) =
      if i=j then 1 else ρ^2 := by
  classical
  by_cases h : i=j
  · subst j
    simp [← sq,cubeCoordinateSign_sq,cubeNoiseMean_const]
  · have hh := cubeNoiseWeight_walsh_moment d ρ {i,j}
    have hij : i ∉ ({j} : Finset (Fin d)) := by simpa using h
    simpa [cubeNoiseMean,walshCharacter,Finset.prod_insert,hij,h] using hh

theorem cubeNoiseMean_coordinateSum_square (d : ℕ) (ρ : ℝ) :
    cubeNoiseMean ρ (fun x : ClippingCube d => (∑ i,cubeCoordinateSign (x i))^2) =
      (d : ℝ)^2*ρ^2+(d : ℝ)*(1-ρ^2) := by
  classical
  have he (x : ClippingCube d) : (∑ i,cubeCoordinateSign (x i))^2 =
      ∑ i,∑ j,cubeCoordinateSign (x i)*cubeCoordinateSign (x j) := by
    rw [pow_two,Finset.sum_mul]
    simp_rw [Finset.mul_sum]
  simp_rw [he,cubeNoiseMean_sum,cubeNoiseMean_coordinate_product]
  have hrow (i : Fin d) : (∑ j : Fin d, if i=j then (1 : ℝ) else ρ^2) =
      1+((d : ℝ)-1)*ρ^2 := by
    have hite (j : Fin d) : (if i=j then (1 : ℝ) else ρ^2) =
        (if i=j then 1-ρ^2 else 0)+ρ^2 := by
      split_ifs <;> ring
    simp_rw [hite]
    simp [Finset.sum_add_distrib]
    ring
  simp_rw [hrow]
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  ring

/-- Exact second moment of the normalized Hamming distance under product
noise; it holds at every real correlation parameter as a polynomial identity. -/
theorem cubeNoiseMean_baseDeficit_square (d : ℕ) (ρ : ℝ) :
    cubeNoiseMean ρ (fun x : ClippingCube d => (1-biasedProfile id x)^2) =
      ((d : ℝ)*(1-ρ)/(d+1))^2+(d : ℝ)*(1-ρ^2)/(d+1)^2 := by
  have hden : (d+1 : ℝ) ≠ 0 := by positivity
  have he (x : ClippingCube d) : (1-biasedProfile id x)^2 =
      (1/(d+1 : ℝ)^2)*((d : ℝ)^2-2*(d : ℝ)*(∑ i,cubeCoordinateSign (x i))+
        (∑ i,cubeCoordinateSign (x i))^2) := by
    unfold biasedProfile
    dsimp only [id_eq]
    field_simp
    ring
  simp_rw [he,cubeNoiseMean_const_mul,cubeNoiseMean_add,cubeNoiseMean_sub]
  rw [cubeNoiseMean_const,cubeNoiseMean_const_mul,cubeNoiseMean_sum]
  simp_rw [cubeNoiseMean_coordinate]
  rw [cubeNoiseMean_coordinateSum_square]
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  field_simp
  ring

theorem cubeNoiseMean_baseDeficit (d : ℕ) (ρ : ℝ) :
    cubeNoiseMean ρ (fun x : ClippingCube d => 1-biasedProfile id x) =
      (d : ℝ)*(1-ρ)/(d+1) := by
  rw [cubeNoiseMean_sub,cubeNoiseMean_const,cubeNoiseMean_biasedProfile_id]
  field_simp
  ring

/-- At noise intensity large enough to change at least one coordinate on
average, the second moment is at most twice the squared mean. -/
theorem cubeNoiseMean_baseDeficit_square_le (d : ℕ) {ρ : ℝ}
    (hρ1 : ρ ≤ 1) (hmean : 2 ≤ (d : ℝ)*(1-ρ)) :
    cubeNoiseMean ρ (fun x : ClippingCube d => (1-biasedProfile id x)^2) ≤
      2*((d : ℝ)*(1-ρ)/(d+1))^2 := by
  have hm0 : 0 ≤ (d : ℝ)*(1-ρ) := by linarith
  have hm1 : 1+ρ ≤ (d : ℝ)*(1-ρ) := by linarith
  have hprod := mul_le_mul_of_nonneg_left hm1 hm0
  have hnum : (d : ℝ)*(1-ρ^2) ≤ ((d : ℝ)*(1-ρ))^2 := by nlinarith
  have hdiv := div_le_div_of_nonneg_right hnum (sq_nonneg ((d : ℝ)+1))
  rw [cubeNoiseMean_baseDeficit_square,div_pow]
  linarith

/-- A fixed positive amount of actual product-noise mass is at a fixed
fraction of its average distance from the positive vertex. -/
theorem cubeNoise_baseDeficit_probability_lower (d : ℕ) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (hmean : 2 ≤ (d : ℝ)*(1-ρ)) :
    (1 : ℝ)/8 ≤ ∑ x : ClippingCube d,
      if ((d : ℝ)*(1-ρ)/(d+1))/2 ≤ 1-biasedProfile id x then
        cubeNoiseWeight d ρ x else 0 := by
  apply finite_weighted_paley_zygmund_half
    (cubeNoiseWeight d ρ) (fun x => 1-biasedProfile id x) ((d : ℝ)*(1-ρ)/(d+1))
    (fun x => cubeNoiseWeight_nonneg d hρ0 hρ1 x) (cubeNoiseWeight_sum d ρ)
    (fun x => sub_nonneg.mpr (abs_le.mp (abs_biasedProfile_id_le_one x)).2)
  · exact div_pos (by linarith) (by positivity)
  · exact cubeNoiseMean_baseDeficit d ρ
  · exact cubeNoiseMean_baseDeficit_square_le d hρ1 hmean

/-- Actual mean noise deficit at every depth. The displayed power condition
is elementary arithmetic in the chosen noise intensity and proposed bound. -/
theorem arcsineNoiseGap_lower_of_power (d k : ℕ) {ρ b : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (hmean : 2 ≤ (d : ℝ)*(1-ρ))
    (hb0 : 0 ≤ b) (hb : (2*b)^(2^k) ≤ (d : ℝ)*(1-ρ)/(d+1)) :
    b/8 ≤ arcsineNoiseGap d k ρ := by
  classical
  let μ : ℝ := (d : ℝ)*(1-ρ)/(d+1)
  have hP := cubeNoise_baseDeficit_probability_lower d hρ0 hρ1 hmean
  have hpoint (x : ClippingCube d) :
      b*(if μ/2 ≤ 1-biasedProfile id x then cubeNoiseWeight d ρ x else 0) ≤
        cubeNoiseWeight d ρ x*(1-arcsineProfile d k x) := by
    have hweight := cubeNoiseWeight_nonneg d hρ0 hρ1 x
    have hgap : 0 ≤ 1-arcsineProfile d k x :=
      sub_nonneg.mpr (abs_le.mp (abs_arcsineProfile_le_one d k x)).2
    split_ifs with hx
    · have hp := iteratedArcsine_endpoint_power_lower (abs_biasedProfile_id_le_one x) k
      have hpower : (2*b)^(2^k) ≤ (2*(1-arcsineProfile d k x))^(2^k) := by
        change 2*(1-biasedProfile id x) ≤ (2*(1-arcsineProfile d k x))^(2^k) at hp
        change (2*b)^(2^k) ≤ μ at hb
        linarith
      have hbound := (pow_le_pow_iff_left₀ (by positivity : 0 ≤ 2*b)
        (by positivity : 0 ≤ 2*(1-arcsineProfile d k x))
        (pow_ne_zero k (by norm_num : (2 : ℕ) ≠ 0))).mp hpower
      have hbpoint : b ≤ 1-arcsineProfile d k x := by linarith
      simpa only [mul_comm] using mul_le_mul_of_nonneg_left hbpoint hweight
    · simp only [mul_zero]
      exact mul_nonneg hweight hgap
  have hsum := Finset.sum_le_sum (fun x (_hx : x ∈ Finset.univ) => hpoint x)
  rw [← Finset.mul_sum] at hsum
  have hm := mul_le_mul_of_nonneg_left hP hb0
  change b/8 ≤ _
  change _ ≤ arcsineNoiseGap d k ρ at hsum
  linarith

end NeuralGeneralization
