import NeuralGeneralization.KernelPoisson
import Mathlib.InformationTheory.Hamming
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic

/-! # Explicit localized cube bumps and their exact Fourier coefficients -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
variable {d : ℕ}

/-- An actual positive product bump centered at `z`. -/
def raw (p : ℝ) (z x : ClippingCube d) : ℝ :=
  ∏ i, ((1-p)+p*cubeCoordinateSign (z i)*cubeCoordinateSign (x i))

lemma raw_factor (p : ℝ) (z x : ClippingCube d) (i : Fin d) :
    (1-p)+p*cubeCoordinateSign (z i)*cubeCoordinateSign (x i) =
      if x i=z i then 1 else 1-2*p := by
  cases x i <;> cases z i <;> simp [cubeCoordinateSign] <;> ring

lemma raw_eq_distance (p : ℝ) (z x : ClippingCube d) :
    raw p z x = (1-2*p)^(hammingDist x z) := by
  classical
  unfold raw
  simp_rw [raw_factor]
  rw [Finset.prod_ite]
  simp only [Finset.prod_const_one, one_mul, Finset.prod_const]
  rfl

lemma raw_self (p : ℝ) (z : ClippingCube d) : raw p z z = 1 := by
  rw [raw_eq_distance, hammingDist_self, pow_zero]

lemma raw_nonneg (p : ℝ) (hp : p ≤ 1/2) (z x : ClippingCube d) : 0 ≤ raw p z x := by
  rw [raw_eq_distance]
  exact pow_nonneg (by linarith) _

lemma raw_le_distance (p : ℝ) (hp0 : 2/5 ≤ p) (hp1 : p ≤ 1/2) (z x : ClippingCube d) :
    raw p z x ≤ (1/5:ℝ)^(hammingDist x z) := by
  rw [raw_eq_distance]
  exact pow_le_pow_left₀ (by linarith) (by linarith) _

/-- The exact Walsh coefficients are binomial monomials times the center's
character. This identity is derived from the actual product function. -/
theorem raw_walsh (p : ℝ) (z : ClippingCube d) (S : Finset (Fin d)) :
    walshCoefficients (raw p z) S =
      p^S.card*(1-p)^(d-S.card)*walshCharacter S z := by
  classical
  have hproduct := walshCoefficients_coordinate_product
    (fun i => fun b => (1-p)+p*cubeCoordinateSign (z i)*cubeCoordinateSign b) S
  change (Fintype.card (ClippingCube d) : ℝ)*walshCoefficients (raw p z) S = _ at hproduct
  have hfactor (i : Fin d) :
      ((1-p)+p*cubeCoordinateSign (z i)*cubeCoordinateSign true)+
        (if i ∈ S then -((1-p)+p*cubeCoordinateSign (z i)*cubeCoordinateSign false)
         else ((1-p)+p*cubeCoordinateSign (z i)*cubeCoordinateSign false)) =
      2*(if i ∈ S then p*cubeCoordinateSign (z i) else 1-p) := by
    cases z i <;> split_ifs <;> simp [cubeCoordinateSign] <;> ring
  simp_rw [hfactor] at hproduct
  rw [Finset.prod_mul_distrib] at hproduct
  have hshape : (∏ i : Fin d, if i ∈ S then p*cubeCoordinateSign (z i) else 1-p) =
      p^S.card*(1-p)^(d-S.card)*walshCharacter S z := by
    have hcardcomp : (Finset.univ \ S).card = d-S.card := by
      rw [Finset.card_sdiff]
      simp
    rw [Finset.prod_ite]
    simp only [Finset.filter_mem_eq_inter,Finset.univ_inter]
    simp [Finset.filter_not,hcardcomp,Finset.prod_mul_distrib,walshCharacter]
    ring
  rw [hshape] at hproduct
  have hcard : (Fintype.card (ClippingCube d) : ℝ) = 2^d := by simp [ClippingCube]
  rw [hcard] at hproduct
  simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin] at hproduct
  exact (mul_left_cancel₀ (pow_ne_zero d (by norm_num : (2:ℝ) ≠ 0))) hproduct

/-- The averaged bump used by the localized comparator. -/
def bump (z x : ClippingCube d) : ℝ := 200*∫ p in (2/5:ℝ)..(81/200:ℝ), raw p z x

def coefficient (d j : ℕ) : ℝ := 200*∫ p in (2/5:ℝ)..(81/200:ℝ), p^j*(1-p)^(d-j)

@[fun_prop] lemma continuous_raw (z x : ClippingCube d) : Continuous (fun p => raw p z x) := by
  unfold raw
  fun_prop

lemma bump_self (z : ClippingCube d) : bump z z = 1 := by
  unfold bump
  simp_rw [raw_self]
  norm_num

lemma bump_nonneg (z x : ClippingCube d) : 0 ≤ bump z x := by
  apply mul_nonneg (by norm_num)
  apply intervalIntegral.integral_nonneg (by norm_num)
  intro p hp
  exact raw_nonneg p (by linarith [hp.2]) z x

lemma bump_le_distance (z x : ClippingCube d) :
    bump z x ≤ (1/5:ℝ)^(hammingDist x z) := by
  have hi := intervalIntegral.integral_mono_on (μ:=volume) (by norm_num : (2/5:ℝ) ≤ 81/200)
    ((continuous_raw z x).intervalIntegrable _ _) (continuous_const.intervalIntegrable _ _)
    (fun p hp => raw_le_distance p hp.1 (by linarith [hp.2]) z x)
  rw [intervalIntegral.integral_const] at hi
  have hh := mul_le_mul_of_nonneg_left hi (by norm_num : (0:ℝ) ≤ 200)
  calc
    bump z x ≤ 200*((81/200-2/5:ℝ)*(1/5:ℝ)^(hammingDist x z)) := hh
    _ = _ := by ring

end NeuralGeneralization.LocalizedCubeBump
