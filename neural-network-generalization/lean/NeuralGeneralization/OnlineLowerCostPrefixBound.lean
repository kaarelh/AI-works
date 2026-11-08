import NeuralGeneralization.OnlineLowerCostPrefix
import NeuralGeneralization.OnlineLowerPrefixEstimate

noncomputable section
open MeasureTheory Set
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

open OnlineLowerBernstein

theorem cost_abs_walshCharacter {m : ℕ} (S : Finset (Fin m)) (x : ClippingCube m) :
    |walshCharacter S x| = 1 := by
  nlinarith [walshCharacter_sq S x, sq_abs (walshCharacter S x), abs_nonneg (walshCharacter S x)]

theorem walshCoefficient_abs_le_uniform {m : ℕ} (F : ClippingCube m → ℝ)
    (S : Finset (Fin m)) (B : ℝ) (hF : ∀ x, |F x| ≤ B) :
    |walshCoefficients F S| ≤ B := by
  have hcard : (0 : ℝ) < Fintype.card (ClippingCube m) := Nat.cast_pos.mpr Fintype.card_pos
  unfold walshCoefficients uniformCubeMean
  rw [abs_div, abs_of_pos hcard]
  apply (div_le_iff₀ hcard).mpr
  calc
    _ ≤ ∑ x : ClippingCube m, |F x * walshCharacter S x| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ x : ClippingCube m, |F x| := by
      simp only [abs_mul, cost_abs_walshCharacter, mul_one]
    _ ≤ ∑ _x : ClippingCube m, B := Finset.sum_le_sum (fun x _ => hF x)
    _ = _ := by simp [mul_comm]

theorem fixedCandidateCost_exp_abs_le (n₀ t : ℝ) (ht : 0 ≤ t)
    (endpoint : Bool) (digits : List Bool) :
    |fixedCandidateCost n₀ (fun n => Real.exp (-n*t)) endpoint digits| ≤ Real.exp (-n₀*t) := by
  unfold fixedCandidateCost fixedPathCost
  apply walshCoefficient_abs_le_uniform
  intro s
  rw [abs_of_pos (Real.exp_pos _)]
  apply Real.exp_le_exp.mpr
  have h := fixedPathDegree_ge n₀ (2*(fixedParityBlocks endpoint digits).length) s
  nlinarith

theorem prefixLaplaceFactor_le (P : ℕ) {t : ℝ} (ht : 0 < t) :
    prefixLaplaceFactor P t ≤ (2*t)^P := by
  have he := Real.add_one_le_exp (-4*t)
  have hnon : 0 ≤ (1-Real.exp (-4*t))/2 := by
    have h := Real.exp_lt_one_iff.mpr (show -4*t<0 by linarith)
    positivity
  have hle : (1-Real.exp (-4*t))/2 ≤ 2*t := by linarith
  exact pow_le_pow_left₀ hnon hle P

def prefixBoundFactor (P : ℕ) (n₀ : ℝ) (endpoint : Bool) (digits : List Bool) (t : ℝ) : ℝ :=
  prefixLaplaceFactor P t * (Real.exp (n₀*t) *
    fixedCandidateCost n₀ (fun n => Real.exp (-n*t)) endpoint digits)

theorem prefixBoundFactor_abs_le (P : ℕ) (n₀ : ℝ) (endpoint : Bool)
    (digits : List Bool) (t : ℝ) (ht : 0 < t) :
    |prefixBoundFactor P n₀ endpoint digits t| ≤ (2*t)^P := by
  unfold prefixBoundFactor
  rw [abs_mul, abs_mul, abs_of_pos (prefixLaplaceFactor_pos P ht),
    abs_of_pos (Real.exp_pos _)]
  have h := mul_le_mul_of_nonneg_left
    (fixedCandidateCost_exp_abs_le n₀ t ht.le endpoint digits) (Real.exp_pos (n₀*t)).le
  have he : Real.exp (n₀*t) * Real.exp (-n₀*t) = 1 := by
    rw [← Real.exp_add, show n₀*t + -n₀*t = 0 by ring, Real.exp_zero]
  rw [he] at h
  calc
    _ ≤ prefixLaplaceFactor P t * 1 :=
      mul_le_mul_of_nonneg_left h (prefixLaplaceFactor_pos P ht).le
    _ ≤ _ := by simpa using prefixLaplaceFactor_le P ht

theorem prefixBoundFactor_integrand (P : ℕ) (n₀ : ℝ) (endpoint : Bool)
    (digits : List Bool) (t : ℝ) :
    Real.exp (-n₀*t)*reluCostDensity t*prefixBoundFactor P n₀ endpoint digits t =
      prefixLaplaceFactor P t * reluPathBaseIntegrand n₀ endpoint digits t := by
  unfold prefixBoundFactor
  rw [fixedCandidateCost_exp]
  have he : Real.exp (-n₀*t)*Real.exp (n₀*t)=1 := by
    rw [← Real.exp_add, show -n₀*t+n₀*t=0 by ring, Real.exp_zero]
  unfold reluPathBaseIntegrand
  calc
    _ = (Real.exp (-n₀*t)*Real.exp (n₀*t)) *
      (prefixLaplaceFactor P t * (reluCostDensity t * pathLaplacePrefactor n₀ t 4
        (@alternatingEdgeIncrement (2*(digits.length+1))) *
          candidatePathEnumerator (Real.exp (-2*t)) endpoint digits)) := by ring
    _ = _ := by rw [he]; ring

theorem reluPrefixedCost_abs_bound (P : ℕ) (n₀ : ℝ) (hn₀ : 1 < n₀)
    (endpoint : Bool) (digits : List Bool) (hlen : 2 ≤ digits.length) :
    |prefixedCandidateCost P n₀ gammaCost endpoint digits| ≤
      8*reluCostSlope*2^P*(P.factorial : ℝ)/(n₀-1)^(P+1) := by
  have hi := reluPrefixedIntegrand_integrable P n₀ hn₀ endpoint digits
  have hi' : IntegrableOn (fun t => Real.exp (-n₀*t)*reluCostDensity t*
      prefixBoundFactor P n₀ endpoint digits t) (Ioi 0) := by
    simpa only [prefixBoundFactor_integrand] using hi
  have hb := density_integral_prefix_bound P hn₀ (prefixBoundFactor P n₀ endpoint digits)
    hi' (prefixBoundFactor_abs_le P n₀ endpoint digits)
  rw [reluPrefixedCost_eq_integral P n₀ hn₀ endpoint digits hlen, abs_neg]
  simpa only [prefixBoundFactor_integrand] using hb

end NeuralGeneralization.OnlineLower
