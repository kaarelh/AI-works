import NeuralGeneralization.ArcsineCoefficients
import NeuralGeneralization.PolynomialThresholdParity
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Elementary binomial anti-concentration and a quantitative lower median tail. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

lemma binomial_probability_le_arcsineDerivative (d j : ℕ) :
    (d.choose j : ℝ)/(2:ℝ)^d ≤ arcsineDerivativeCoefficient (d/2) := by
  have hmid : (d.choose j : ℝ) ≤ d.choose (d/2) := by
    exact_mod_cast Nat.choose_le_middle j d
  apply (div_le_div_of_nonneg_right hmid (by positivity)).trans
  obtain h | h := Nat.mod_two_eq_zero_or_one d
  · have hd : d=2*(d/2) := by omega
    have hpow : (2:ℝ)^d=4^(d/2) := by
      conv_lhs => rw [hd]
      rw [pow_mul]
      norm_num
    have hc : d.choose (d/2)=Nat.centralBinom (d/2) := by
      conv_lhs => lhs; rw [hd]
      rfl
    rw [hc,hpow,arcsineDerivativeCoefficient_eq_centralBinom]
  · let m := d/2
    have hd : d=2*m+1 := by dsimp [m]; omega
    have hc : (2*m+1).choose m ≤ 2*(2*m).choose m := by
      cases m with
      | zero => norm_num
      | succ m =>
        rw [Nat.choose_succ_succ']
        have hh := Nat.choose_le_middle m (2*(m+1))
        simp only [Nat.mul_div_cancel_left _ (by decide : 0 < 2)] at hh
        omega
    have hcR : ((2*m+1).choose m : ℝ) ≤ 2*((2*m).choose m : ℝ) := by
      exact_mod_cast hc
    change (d.choose m : ℝ)/(2:ℝ)^d ≤ arcsineDerivativeCoefficient m
    rw [hd, arcsineDerivativeCoefficient_eq_centralBinom, Nat.centralBinom,
      pow_succ,pow_mul]
    norm_num only [show (2:ℝ)^2=4 by norm_num]
    apply (div_le_iff₀ (by positivity : 0 < (4:ℝ)^m*2)).mpr
    have hfour : (4:ℝ)^m ≠ 0 := by positivity
    convert hcR using 1 <;> first | rfl | (field_simp [hfour])

/-- A universal square-root bound on every atom of the symmetric binomial law. -/
theorem binomial_probability_le_two_div_sqrt (d j : ℕ) :
    (d.choose j : ℝ)/(2:ℝ)^d ≤ 2/Real.sqrt ((d:ℝ)+1) := by
  have hprob := binomial_probability_le_arcsineDerivative d j
  apply hprob.trans
  have ha := arcsineDerivativeCoefficient_pos (d/2)
  have hwall := arcsineDerivativeCoefficient_square_upper (d/2)
  have hd : (d:ℝ)+1 ≤ 4*(3*(d/2:ℕ)+1:ℕ) := by
    exact_mod_cast (show d+1 ≤ 4*(3*(d/2)+1) by omega)
  have hs := Real.sq_sqrt (show 0 ≤ (d:ℝ)+1 by positivity)
  have hsq : (arcsineDerivativeCoefficient (d/2)*Real.sqrt ((d:ℝ)+1))^2 ≤ 4 := by
    rw [mul_pow,hs]
    have hm := mul_le_mul_of_nonneg_left hd (sq_nonneg (arcsineDerivativeCoefficient (d/2)))
    push_cast at hm
    nlinarith [hwall]
  apply (le_div_iff₀ (Real.sqrt_pos.2 (by positivity : 0 < (d:ℝ)+1))).mpr
  nlinarith [mul_nonneg ha.le (Real.sqrt_nonneg ((d:ℝ)+1))]

/-- At least half the binomial mass lies at or below the central index. -/
lemma binomial_twice_median_sum (d : ℕ) :
    2^d ≤ 2*∑ j ∈ Finset.range (d/2+1), d.choose j := by
  have href : (∑ j ∈ Finset.Ico (d/2+1) (d+1), d.choose j) =
      ∑ j ∈ Finset.range (d-d/2), d.choose j := by
    calc
      _ = ∑ j ∈ Finset.Ico (d/2+1) (d+1), d.choose (d-j) := by
        apply Finset.sum_congr rfl
        intro j hj
        rw [Nat.choose_symm (by have := (Finset.mem_Ico.mp hj).2; omega)]
      _ = _ := by
        rw [Finset.sum_Ico_reflect _ _ (by omega : d+1 ≤ d+1)]
        simp only [Nat.sub_self, Nat.Ico_zero_eq_range]
        congr 2
        omega
  have hle : (∑ j ∈ Finset.range (d-d/2), d.choose j) ≤
      ∑ j ∈ Finset.range (d/2+1), d.choose j := by
    apply Finset.sum_le_sum_of_subset
    apply Finset.range_mono
    omega
  have hsum := Finset.sum_range_add_sum_Ico (fun j => d.choose j)
    (show d/2+1 ≤ d+1 by omega)
  rw [Nat.sum_range_choose, href] at hsum
  omega

/-- Moving the cutoff below the median loses at most one maximal atom per level. -/
lemma binomial_cdf_lower (d t : ℕ) (ht : t ≤ d/2) :
    (1:ℝ)/2 - ((d/2-t:ℕ):ℝ)*2/Real.sqrt ((d:ℝ)+1) ≤
      (∑ j ∈ Finset.range (t+1), (d.choose j:ℝ))/(2:ℝ)^d := by
  have hmed : (2:ℝ)^d ≤ 2*∑ j ∈ Finset.range (d/2+1), (d.choose j:ℝ) := by
    exact_mod_cast binomial_twice_median_sum d
  have hsplit := Finset.sum_range_add_sum_Ico (fun j => (d.choose j:ℝ))
    (show t+1 ≤ d/2+1 by omega)
  have hsmall : (∑ j ∈ Finset.Ico (t+1) (d/2+1), (d.choose j:ℝ))/(2:ℝ)^d ≤
      ((d/2-t:ℕ):ℝ)*2/Real.sqrt ((d:ℝ)+1) := by
    rw [Finset.sum_div]
    calc
      _ ≤ ∑ j ∈ Finset.Ico (t+1) (d/2+1), 2/Real.sqrt ((d:ℝ)+1) := by
        apply Finset.sum_le_sum
        intro j _
        exact binomial_probability_le_two_div_sqrt d j
      _ = _ := by
        simp only [Finset.sum_const, nsmul_eq_mul, Nat.card_Ico]
        rw [show d/2+1-(t+1)=d/2-t by omega]
        ring
  have hpow : (0:ℝ)<2^d := by positivity
  have hmed' : (1:ℝ)/2 ≤ (∑ j ∈ Finset.range (d/2+1), (d.choose j:ℝ))/(2:ℝ)^d := by
    apply (le_div_iff₀ hpow).mpr
    linarith
  rw [←hsplit,add_div] at hmed'
  linarith

/-- The low-degree dimension used in the polynomial-threshold parity bound is
asymptotically one half whenever the degree cutoff is within `o(sqrt d)` of
half the dimension. -/
theorem degreeIndices_fraction_lower (d s : ℕ) (hs : s < d) :
    (1:ℝ)/2 - 2*((s:ℝ)+2)/Real.sqrt ((d:ℝ)+1) ≤
      (Fintype.card (DegreeIndices d ((d-s-1)/2)):ℝ) /
        Fintype.card (ClippingCube d) := by
  have ht : (d-s-1)/2 ≤ d/2 := by omega
  have hc := binomial_cdf_lower d ((d-s-1)/2) ht
  have hdiff : d/2-(d-s-1)/2 ≤ s+2 := by omega
  have hdiffR : ((d/2-(d-s-1)/2:ℕ):ℝ) ≤ (s:ℝ)+2 := by exact_mod_cast hdiff
  have herror : ((d/2-(d-s-1)/2:ℕ):ℝ)*2/Real.sqrt ((d:ℝ)+1) ≤
      2*((s:ℝ)+2)/Real.sqrt ((d:ℝ)+1) := by
    apply div_le_div_of_nonneg_right _ (Real.sqrt_nonneg _)
    linarith
  have hcard : (Fintype.card (ClippingCube d):ℝ)=(2:ℝ)^d := by
    simp [ClippingCube]
  rw [hcard,degreeIndices_card]
  push_cast
  linarith

end NeuralGeneralization
