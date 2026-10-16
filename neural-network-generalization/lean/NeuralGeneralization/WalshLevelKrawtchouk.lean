import NeuralGeneralization.KrawtchoukDecay
import NeuralGeneralization.WalshLaplacian
import Mathlib.Algebra.Polynomial.BigOperators
import Mathlib.InformationTheory.Hamming

/-! Exact generating polynomials for actual Walsh level kernels and their
far-pair exponential decay. -/

noncomputable section
namespace NeuralGeneralization.WalshLevelKrawtchouk
open Classical Polynomial KrawtchoukDecay
open scoped BigOperators
attribute [local instance] Classical.propDecidable

variable {d : ℕ}

def levelKernel (j : ℕ) (x y : ClippingCube d) : ℝ :=
  ∑ S ∈ Finset.univ.filter (fun S : Finset (Fin d) => S.card=j), walshCharacter S x*walshCharacter S y

def generatingPolynomial (x y : ClippingCube d) : ℝ[X] :=
  ∏ i : Fin d, (1+C (cubeCoordinateSign (x i)*cubeCoordinateSign (y i))*X)

theorem generating_coefficient (x y : ClippingCube d) (j : ℕ) :
    (generatingPolynomial x y).coeff j = levelKernel j x y := by
  have hprod (S : Finset (Fin d)) :
      (∏ i ∈ S, C (cubeCoordinateSign (x i)*cubeCoordinateSign (y i))*X) =
        C (walshCharacter S x*walshCharacter S y)*X^S.card := by
    rw [Finset.prod_mul_distrib, ← map_prod, Finset.prod_const]
    congr 2
    exact Finset.prod_mul_distrib
  unfold generatingPolynomial
  rw [Finset.prod_one_add, Finset.powerset_univ]
  simp_rw [hprod]
  rw [finsetSum_coeff]
  simp only [coeff_C_mul_X_pow]
  unfold levelKernel
  rw [Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro S _
  simp only [eq_comm]

theorem generating_factorization (x y : ClippingCube d) :
    generatingPolynomial x y = (1-X : ℝ[X])^(hammingDist x y)*(1+X)^(d-hammingDist x y) := by
  let A := Finset.univ.filter (fun i : Fin d => x i≠y i)
  let B := Finset.univ.filter (fun i : Fin d => ¬ x i≠y i)
  have hA : A.card=hammingDist x y := rfl
  have hB : B.card=d-hammingDist x y := by
    have hh := Finset.card_filter_add_card_filter_not
      (s:=Finset.univ) (fun i : Fin d => x i≠y i)
    change A.card+B.card=(Finset.univ : Finset (Fin d)).card at hh
    simp only [Finset.card_univ, Fintype.card_fin] at hh
    omega
  have hneg : (∏ i ∈ A, (1+C (cubeCoordinateSign (x i)*cubeCoordinateSign (y i))*X)) =
      (1-X : ℝ[X])^A.card := by
    rw [← Finset.prod_const]
    apply Finset.prod_congr rfl
    intro i hi
    have hi' := (Finset.mem_filter.mp hi).2
    cases hxi : x i <;> cases hyi : y i <;> simp [hxi, hyi, cubeCoordinateSign, sub_eq_add_neg] at hi' ⊢
  have hpos : (∏ i ∈ B, (1+C (cubeCoordinateSign (x i)*cubeCoordinateSign (y i))*X)) =
      (1+X : ℝ[X])^B.card := by
    rw [← Finset.prod_const]
    apply Finset.prod_congr rfl
    intro i hi
    have hi' : x i=y i := not_ne_iff.mp (Finset.mem_filter.mp hi).2
    rw [hi']
    cases hyi : y i <;> simp [cubeCoordinateSign]
  unfold generatingPolynomial
  rw [← Finset.prod_filter_mul_prod_filter_not Finset.univ (fun i : Fin d => x i≠y i)]
  change (∏ i ∈ A, _) * (∏ i ∈ B, _) = _
  rw [hneg, hpos, hA, hB]

theorem levelKernel_eq_krawtchouk (x y : ClippingCube d) (j : ℕ) :
    levelKernel j x y = krawtchouk (hammingDist x y) (d-hammingDist x y) j := by
  rw [← generating_coefficient, generating_factorization]
  rfl

theorem levelKernel_decay (x y : ClippingCube d) (b j : ℕ)
    (hb₁ : b ≤ hammingDist x y) (hb₂ : b ≤ d-hammingDist x y)
    (hj : 0 < j) (hjd : j < d) :
    |levelKernel j x y|/(d.choose j:ℝ) ≤
      (d+1:ℝ)*Real.exp (-(2*(b:ℝ)*j*(d-j:ℕ))/(d:ℝ)^2) := by
  have hd : hammingDist x y≤d := by simpa using hammingDist_le_card_fintype (x:=x) (y:=y)
  have he : hammingDist x y+(d-hammingDist x y)=d := Nat.add_sub_of_le hd
  have hh := coefficient_decay (hammingDist x y) (d-hammingDist x y) b j hb₁ hb₂ hj (by omega)
  rw [he, ← levelKernel_eq_krawtchouk] at hh
  simpa only [Nat.cast_add, Nat.cast_one] using hh

/-- A middle Hamming-distance pair has exponential level-kernel decay.
The polynomial prefactor is obtained from the elementary binomial mode bound. -/
theorem far_pair_levelKernel_bound (x y : ClippingCube d) (j : ℕ)
    (hj : 0 < j) (hjd : 2*j ≤ d)
    (hfar₁ : (d:ℝ)/4 ≤ hammingDist x y)
    (hfar₂ : (hammingDist x y:ℝ) ≤ 3*(d:ℝ)/4) :
    |levelKernel j x y|/(d.choose j:ℝ) ≤ (d+1:ℝ)*Real.exp (-(j:ℝ)/4) := by
  let b := min (hammingDist x y) (d-hammingDist x y)
  have hd : hammingDist x y≤d := by simpa using hammingDist_le_card_fintype (x:=x) (y:=y)
  have hbd : (d:ℝ)/4 ≤ b := by
    dsimp only [b]
    rw [Nat.cast_min, le_min_iff, Nat.cast_sub hd]
    constructor
    · exact hfar₁
    · linarith
  have hjd' : j<d := by omega
  have hh := levelKernel_decay x y b j (min_le_left _ _) (min_le_right _ _) hj hjd'
  apply hh.trans
  apply mul_le_mul_of_nonneg_left _ (by positivity : (0:ℝ)≤d+1)
  apply Real.exp_le_exp.mpr
  have hdpos : (0:ℝ)<d := by exact_mod_cast (hj.trans hjd')
  have hjpos : (0:ℝ)<j := by exact_mod_cast hj
  have hjdreal : (2:ℝ)*j≤d := by exact_mod_cast hjd
  have hmul := mul_le_mul_of_nonneg_right hbd (by positivity : (0:ℝ)≤2*(j:ℝ)*(d-j:ℕ))
  rw [Nat.cast_sub hjd'.le] at hmul ⊢
  have hm : (d:ℝ)^2*(j:ℝ)/4 ≤ 2*(b:ℝ)*j*((d:ℝ)-j) := by
    have hz := mul_nonneg (by positivity : (0:ℝ)≤(d:ℝ)*j) (sub_nonneg.mpr hjdreal)
    nlinarith only [hmul, hz]
  have hdiv : (j:ℝ)/4 ≤ (2*(b:ℝ)*j*((d:ℝ)-j))/(d:ℝ)^2 := by
    apply (le_div_iff₀ (sq_pos_of_pos hdpos)).mpr
    nlinarith only [hm]
  simpa only [neg_div] using neg_le_neg hdiv

theorem character_complement (S : Finset (Fin d)) (x : ClippingCube d) :
    walshCharacter Sᶜ x = fullParity x*walshCharacter S x := by
  have hh : walshCharacter S x*walshCharacter Sᶜ x=fullParity x :=
    Finset.prod_mul_prod_compl S (fun i => cubeCoordinateSign (x i))
  calc
    _ = walshCharacter S x^2*walshCharacter Sᶜ x := by rw [walshCharacter_sq, one_mul]
    _ = walshCharacter S x*(walshCharacter S x*walshCharacter Sᶜ x) := by ring
    _ = _ := by rw [hh]; ring

theorem levelKernel_reflection (x y : ClippingCube d) (j : ℕ) (hj : j ≤ d) :
    levelKernel (d-j) x y = fullParity x*fullParity y*levelKernel j x y := by
  let e : Finset (Fin d) ≃ Finset (Fin d) := Function.Involutive.toPerm (fun S => Sᶜ) compl_compl
  have he := e.sum_comp (fun S => if S.card=d-j then walshCharacter S x*walshCharacter S y else 0)
  change (∑ S, if Sᶜ.card=d-j then walshCharacter Sᶜ x*walshCharacter Sᶜ y else 0) = _ at he
  have hh (S : Finset (Fin d)) : Sᶜ.card=d-j ↔ S.card=j := by
    rw [Finset.card_compl, Fintype.card_fin]
    have hS : S.card≤d := by simpa using Finset.card_le_univ S
    omega
  simp_rw [hh, character_complement] at he
  unfold levelKernel
  rw [Finset.sum_filter, Finset.sum_filter, Finset.mul_sum]
  rw [← he]
  apply Finset.sum_congr rfl
  intro S _
  split_ifs <;> ring

theorem abs_levelKernel_reflection (x y : ClippingCube d) (j : ℕ) (hj : j ≤ d) :
    |levelKernel (d-j) x y| = |levelKernel j x y| := by
  rw [levelKernel_reflection x y j hj, abs_mul, abs_mul]
  have hx : |fullParity x|=1 := by rcases fullParity_sign x with h | h <;> simp [h]
  have hy : |fullParity y|=1 := by rcases fullParity_sign y with h | h <;> simp [h]
  rw [hx, hy, one_mul, one_mul]

theorem far_pair_levelKernel_bound_all (x y : ClippingCube d) (j : ℕ)
    (hj : 0 < j) (hjd : j < d)
    (hfar₁ : (d:ℝ)/4 ≤ hammingDist x y)
    (hfar₂ : (hammingDist x y:ℝ) ≤ 3*(d:ℝ)/4) :
    |levelKernel j x y|/(d.choose j:ℝ) ≤
      (d+1:ℝ)*Real.exp (-(min j (d-j):ℕ)/4) := by
  by_cases hh : 2*j ≤ d
  · rw [min_eq_left (by omega)]
    exact far_pair_levelKernel_bound x y j hj hh hfar₁ hfar₂
  · rw [min_eq_right (by omega)]
    have h := far_pair_levelKernel_bound x y (d-j) (by omega) (by omega) hfar₁ hfar₂
    rw [abs_levelKernel_reflection x y j hjd.le, Nat.choose_symm hjd.le] at h
    exact h

end NeuralGeneralization.WalshLevelKrawtchouk
