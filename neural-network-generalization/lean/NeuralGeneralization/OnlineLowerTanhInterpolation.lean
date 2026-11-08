import NeuralGeneralization.OnlineLowerTanhHolomorphicAnalytic
import NeuralGeneralization.OnlineLowerTanhConcavity
import Mathlib.Analysis.Normed.Group.Tannery

/-! The holomorphic interpolation agrees with the actual finite Boolean coefficient. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Complex Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma hammingRatio_odd_zero (r j:ℕ) (hj:r<j) :
    hammingRatio j ((2*r+1:ℕ):ℂ)=0 := by
  unfold hammingRatio
  apply Finset.prod_eq_zero (Finset.mem_range.mpr hj)
  push_cast
  simp

lemma centered_choose_prefactored (r j:ℕ) (hj:j≤r) :
    (((2*r+1).choose (r-j):ℕ):ℂ)=
      2*(Nat.centralBinom r:ℂ)*prefactoredRatio j ((2*r+1:ℕ):ℂ) := by
  induction j with
  | zero =>
    have hc:=Nat.choose_mul_succ_eq (2*r) r
    have hr:2*r+1-r=r+1 := by omega
    rw [hr] at hc
    have hc' : (Nat.centralBinom r:ℂ)*(2*(r:ℂ)+1)=
        ((2*r+1).choose r:ℂ)*((r:ℂ)+1) := by
      exact_mod_cast hc
    simp only [Nat.sub_zero,prefactoredRatio,hammingRatio,Finset.range_zero,
      Finset.prod_empty,mul_one]
    push_cast
    have hn:(2*(r:ℂ)+1)+1≠0 := by
      exact_mod_cast (show 2*r+1+1≠0 by omega)
    rw [←mul_div_assoc]
    apply (eq_div_iff hn).mpr
    linear_combination -2*hc'
  | succ j ih =>
    have hjr:j<r := by omega
    have ih:=ih (by omega)
    have hc:=Nat.choose_succ_right_eq (2*r+1) (r-(j+1))
    have hs:r-(j+1)+1=r-j := by omega
    have ht:2*r+1-(r-(j+1))=r+j+2 := by omega
    rw [hs,ht] at hc
    have hc' : ((2*r+1).choose (r-j):ℂ)*((r:ℂ)-(j:ℂ))=
        ((2*r+1).choose (r-(j+1)):ℂ)*((r:ℂ)+(j:ℂ)+2) := by
      have hh:=congrArg (fun n:ℕ=>(n:ℂ)) hc
      push_cast [Nat.cast_sub (show j≤r by omega)] at hh
      exact hh
    have hd:((2*r+1:ℕ):ℂ)+(2*(j:ℂ)+3)≠0 :=
      hamming_den_ne_zero _ j (by simp only [Complex.natCast_re]; positivity)
    simp only [prefactoredRatio,hammingRatio_succ]
    rw [show (2:ℂ)*(Nat.centralBinom r:ℂ)*
      (((2*r+1:ℕ):ℂ)/(((2*r+1:ℕ):ℂ)+1)*
       (hammingRatio j ((2*r+1:ℕ):ℂ)*
       ((((2*r+1:ℕ):ℂ)-(2*(j:ℂ)+1))/(((2*r+1:ℕ):ℂ)+(2*(j:ℂ)+3)))))=
      (2*(Nat.centralBinom r:ℂ)*prefactoredRatio j ((2*r+1:ℕ):ℂ))*
       ((((2*r+1:ℕ):ℂ)-(2*(j:ℂ)+1))/(((2*r+1:ℕ):ℂ)+(2*(j:ℂ)+3))) by
        unfold prefactoredRatio; ring]
    rw [←ih]
    rw [←mul_div_assoc]
    apply (eq_div_iff hd).mpr
    push_cast
    linear_combination -2*hc'

/-- Exact identification, including the truncation of the infinite interpolation
series at every positive odd integer. -/
theorem complexF_odd_eq_balanced (r:ℕ) (a:ℝ) :
    complexF ((2*r+1:ℕ):ℂ) (a:ℂ)=(balancedParity r a/oddParityKappa r:ℝ) := by
  have ht : (∑'j:ℕ,(-1:ℂ)^j*prefactoredRatio j ((2*r+1:ℕ):ℂ)*complexLogistic j (a:ℂ))=
      ∑j∈Finset.range (r+1),(-1:ℂ)^j*prefactoredRatio j ((2*r+1:ℕ):ℂ)*complexLogistic j (a:ℂ) := by
    apply tsum_eq_sum
    intro j hj
    have hr:r<j := by
      have h:¬j<r+1 := by simpa only [Finset.mem_range] using hj
      omega
    simp only [prefactoredRatio,hammingRatio_odd_zero r j hr,mul_zero,zero_mul]
  have hk:(Nat.centralBinom r:ℂ)≠0 := by
    exact_mod_cast (Nat.centralBinom_pos r).ne'
  have hc:(4:ℂ)^r≠0 := pow_ne_zero _ (by norm_num)
  unfold complexF
  rw [ht,balancedParity_logistic]
  push_cast
  unfold oddParityKappa
  push_cast
  have he : (∑j∈Finset.range (r+1),(-1:ℂ)^j*((2*r+1).choose (r-j):ℂ)*(logisticTail j a:ℂ))=
      2*(Nat.centralBinom r:ℂ)*
       ∑j∈Finset.range (r+1),(-1:ℂ)^j*prefactoredRatio j ((2*r+1:ℕ):ℂ)*complexLogistic j (a:ℂ) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    rw [centered_choose_prefactored r j (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)),
      complexLogistic_ofReal]
    ring
  rw [he]
  field_simp
  norm_num [Nat.cast_add,Nat.cast_mul]

end NeuralGeneralization.OnlineLowerTanh
