import NeuralGeneralization.KernelPoisson
import NeuralGeneralization.NeuralSpectrumMonotone

/-! Exact parity-restricted Poissonization for the actual biased kernel.
The extra bias coordinate accounts for the paired even/odd eigenvalues. -/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

/-- Negating the input multiplies a Walsh coefficient by its degree parity. -/
theorem walshCoefficients_negate {d : ℕ} (P : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => P (cubeNegate x)) S =
      (-1 : ℝ)^S.card * walshCoefficients P S := by
  have h := (cubeNegate (d := d)).sum_comp
    (fun x => P (cubeNegate x)*walshCharacter S x)
  have hinv (x : ClippingCube d) : cubeNegate (cubeNegate x) = x := by
    funext i
    simp [cubeNegate]
  simp_rw [hinv,walshCharacter_negate] at h
  unfold walshCoefficients uniformCubeMean
  rw [← h,← mul_div_assoc]
  congr 1
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x hx
  ring

/-- Scalar linearity of the actual normalized Walsh transform. -/
theorem walshCoefficients_const_mul {d : ℕ} (P : ClippingCube d → ℝ)
    (a : ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun x => a*P x) S = a*walshCoefficients P S := by
  unfold walshCoefficients uniformCubeMean
  simp_rw [mul_assoc]
  rw [← Finset.mul_sum]
  ring

theorem walshCoefficients_sub {d : ℕ} (P Q : ClippingCube d → ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (fun x => P x-Q x) S =
      walshCoefficients P S-walshCoefficients Q S := by
  unfold walshCoefficients uniformCubeMean
  simp_rw [sub_mul,Finset.sum_sub_distrib,sub_div]

/-- Reflecting the scalar kernel leaves one uncancelled bias factor. -/
theorem negative_exponential_biased_profile (d : ℕ) (u : ℝ) (x : ClippingCube d) :
    biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(-t-1))) x =
      Real.exp (-2*u)*
        biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(t-1))) (cubeNegate x) := by
  unfold biasedProfile
  dsimp only
  rw [← Real.exp_add]
  simp only [cubeNegate,Equiv.coe_fn_mk,cubeCoordinateSign_not,Finset.sum_neg_distrib]
  congr 1
  have hD : (d : ℝ)+1 ≠ 0 := by positivity
  field_simp
  ring

/-- The odd-clock transform has the exact extra factor supplied by the bias
coordinate; it is not the unrestricted reduced-cube Poisson law. -/
theorem poissonized_odd_biased_walk_coefficient (d : ℕ) (u : ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (biasedProfile (fun t =>
      (Real.exp (((d : ℝ)+1)*u*(t-1))-
        Real.exp (((d : ℝ)+1)*u*(-t-1)))/2)) S =
      (poissonFlipProbability u)^S.card*(1-poissonFlipProbability u)^(d-S.card)*
        (if Even S.card then poissonFlipProbability u else 1-poissonFlipProbability u) := by
  let P := biasedProfile (d := d) (fun t => Real.exp (((d : ℝ)+1)*u*(t-1)))
  have hprofile : biasedProfile (d := d) (fun t =>
      (Real.exp (((d : ℝ)+1)*u*(t-1))-
        Real.exp (((d : ℝ)+1)*u*(-t-1)))/2) =
      fun x => (1/2 : ℝ)*(P x-Real.exp (-2*u)*P (cubeNegate x)) := by
    funext x
    change (P x-biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(-t-1))) x)/2 = _
    rw [negative_exponential_biased_profile]
    ring
  rw [hprofile,walshCoefficients_const_mul,walshCoefficients_sub,
    walshCoefficients_const_mul,walshCoefficients_negate]
  have hP := poissonized_biased_walk_coefficient d u S
  change walshCoefficients P S = _ at hP
  rw [hP]
  by_cases he : Even S.card
  · rw [if_pos he,he.neg_one_pow]
    unfold poissonFlipProbability
    ring
  · have ho : Odd S.card := Nat.not_even_iff_odd.mp he
    rw [if_neg he,ho.neg_one_pow]
    unfold poissonFlipProbability
    ring

/-- Exact odd-time Poisson sum for the actual biased coordinate paths. -/
theorem poissonized_odd_biased_path_count_hasSum (d : ℕ) (u : ℝ)
    (S : Finset (Fin d)) :
    HasSum (fun m => if Odd m then
      Real.exp (-((d : ℝ)+1)*u)*(u^m/(m.factorial : ℝ))*(biasedPathCount m S : ℝ)
      else 0)
      ((poissonFlipProbability u)^S.card*(1-poissonFlipProbability u)^(d-S.card)*
        (if Even S.card then poissonFlipProbability u else 1-poissonFlipProbability u)) := by
  let P : ℕ → ClippingCube d → ℝ := fun m x =>
    (if Odd m then Real.exp (-((d : ℝ)+1)*u)*
      ((((d : ℝ)+1)*u)^m/(m.factorial : ℝ)) else 0)*(biasedProfile id x)^m
  let Q := biasedProfile (d := d) (fun t =>
    (Real.exp (((d : ℝ)+1)*u*(t-1))-Real.exp (((d : ℝ)+1)*u*(-t-1)))/2)
  have hs (x : ClippingCube d) : HasSum (fun m => P m x) (Q x) := by
    let z := ((d : ℝ)+1)*u*biasedProfile id x
    have hp := NormedSpace.expSeries_div_hasSum_exp z
    have hn := NormedSpace.expSeries_div_hasSum_exp (-z)
    have h := ((hp.sub hn).mul_left (Real.exp (-((d : ℝ)+1)*u))).div_const 2
    rw [← Real.exp_eq_exp_ℝ] at h
    convert h using 1 <;> try rfl
    · funext m
      dsimp [P]
      by_cases ho : Odd m
      · rw [if_pos ho,ho.neg_pow]
        dsimp [z]
        simp only [mul_pow]
        ring
      · have he : Even m := Nat.not_odd_iff_even.mp ho
        rw [if_neg ho,he.neg_pow]
        ring
    · dsimp [Q,z]
      unfold biasedProfile
      dsimp only [id_eq]
      conv_rhs => rw [mul_sub,← Real.exp_add,← Real.exp_add]
      congr 2 <;> congr 1 <;> ring
  have h := walshCoefficients_hasSum P Q hs S
  have hQ := poissonized_odd_biased_walk_coefficient d u S
  change walshCoefficients Q S = _ at hQ
  rw [hQ] at h
  convert h using 1
  funext m
  dsimp [P]
  rw [walshCoefficients_const_mul]
  by_cases ho : Odd m
  · simp only [if_pos ho]
    change _ = _*walshCoefficients (biasedProfile (fun t => t^m)) S
    rw [biasedDot_power_coefficient_walk,mul_pow]
    have hD : ((d : ℝ)+1)^m ≠ 0 := pow_ne_zero _ (by positivity)
    field_simp
  · simp [ho]

end NeuralGeneralization
