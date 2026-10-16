import NeuralGeneralization.KernelWalk
import NeuralGeneralization.KernelPowerSeries
import Mathlib.Analysis.SpecialFunctions.Exponential

/-!
# Exact Poissonized coordinate-walk spectrum

The transform is evaluated from the actual finite cube and its product
structure. This is the kernel identity behind the paper's Poissonization.
-/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

theorem walshCoefficients_coordinate_product {d : ℕ}
    (f : Fin d → Bool → ℝ) (S : Finset (Fin d)) :
    (Fintype.card (ClippingCube d) : ℝ)*
      walshCoefficients (fun x => ∏ i,f i (x i)) S =
      ∏ i, (f i true+(if i ∈ S then -f i false else f i false)) := by
  classical
  have hχ (x : ClippingCube d) : walshCharacter S x =
      ∏ i : Fin d, if i ∈ S then cubeCoordinateSign (x i) else 1 := by
    simp [walshCharacter]
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshCoefficients uniformCubeMean
  rw [mul_div_cancel₀ _ hM]
  simp_rw [hχ,← Finset.prod_mul_distrib]
  rw [← Fintype.prod_sum (fun (i : Fin d) (b : Bool) =>
    f i b*(if i ∈ S then cubeCoordinateSign b else 1))]
  apply Finset.prod_congr rfl
  intro i hi
  by_cases h : i ∈ S <;> simp [h,cubeCoordinateSign,add_comm]

def poissonFlipProbability (u : ℝ) : ℝ := (1-Real.exp (-2*u))/2

theorem poissonFlipProbability_nonneg {u : ℝ} (hu : 0 ≤ u) :
    0 ≤ poissonFlipProbability u := by
  have hh : Real.exp (-2*u) ≤ 1 := by
    simpa using Real.exp_le_exp.mpr (show -2*u ≤ 0 by linarith)
  unfold poissonFlipProbability
  linarith

theorem poissonFlipProbability_lt_half (u : ℝ) : poissonFlipProbability u < 1/2 := by
  unfold poissonFlipProbability
  linarith [Real.exp_pos (-2*u)]

theorem exponential_biased_profile_product (d : ℕ) (u : ℝ) (x : ClippingCube d) :
    biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(t-1))) x =
      ∏ i, Real.exp (u*(cubeCoordinateSign (x i)-1)) := by
  unfold biasedProfile
  dsimp only
  rw [← Real.exp_sum]
  apply congrArg Real.exp
  have hden : (d+1 : ℝ) ≠ 0 := by positivity
  simp only [mul_sub,mul_one,Finset.sum_sub_distrib,← Finset.mul_sum,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  field_simp
  ring

/-- The normalized Walsh eigenvalue of the actual Poissonized walk is the
probability of one specified independent-parity configuration. -/
theorem poissonized_biased_walk_coefficient (d : ℕ) (u : ℝ)
    (S : Finset (Fin d)) :
    walshCoefficients (biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(t-1)))) S =
      (poissonFlipProbability u)^S.card*
        (1-poissonFlipProbability u)^(d-S.card) := by
  classical
  have hproduct := walshCoefficients_coordinate_product
    (fun _i : Fin d => fun b => Real.exp (u*(cubeCoordinateSign b-1))) S
  have hprofile : (fun x : ClippingCube d => ∏ i,Real.exp (u*(cubeCoordinateSign (x i)-1))) =
      biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(t-1))) := by
    funext x
    exact (exponential_biased_profile_product d u x).symm
  rw [hprofile] at hproduct
  simp only [cubeCoordinateSign,if_true,sub_self,mul_zero,Real.exp_zero,
    Bool.false_eq_true,if_false] at hproduct
  have hexp : u*((-1 : ℝ)-1) = -2*u := by ring
  rw [hexp] at hproduct
  have hfactor (i : Fin d) :
      1+(if i ∈ S then -Real.exp (-2*u) else Real.exp (-2*u)) =
        2*(if i ∈ S then poissonFlipProbability u else 1-poissonFlipProbability u) := by
    split_ifs <;> unfold poissonFlipProbability <;> ring
  simp_rw [hfactor] at hproduct
  rw [Finset.prod_mul_distrib] at hproduct
  have hshape : (∏ i : Fin d,
      if i ∈ S then poissonFlipProbability u else 1-poissonFlipProbability u) =
      (poissonFlipProbability u)^S.card*(1-poissonFlipProbability u)^(d-S.card) := by
    have hcardcomp : (Finset.univ \ S).card = d-S.card := by
      rw [Finset.card_sdiff]
      simp
    rw [Finset.prod_ite]
    simp only [Finset.filter_mem_eq_inter,Finset.univ_inter]
    simp [Finset.filter_not,hcardcomp]
  rw [hshape] at hproduct
  have hcard : (Fintype.card (ClippingCube d) : ℝ) = 2^d := by simp [ClippingCube]
  rw [hcard] at hproduct
  simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin] at hproduct
  exact (mul_left_cancel₀ (pow_ne_zero d (by norm_num : (2 : ℝ) ≠ 0))) hproduct

/-- Walsh coefficients commute with a convergent series on a finite cube. -/
theorem walshCoefficients_hasSum {d : ℕ} (P : ℕ → ClippingCube d → ℝ)
    (Q : ClippingCube d → ℝ) (h : ∀ x, HasSum (fun n => P n x) (Q x))
    (S : Finset (Fin d)) :
    HasSum (fun n => walshCoefficients (P n) S) (walshCoefficients Q S) := by
  unfold walshCoefficients uniformCubeMean
  apply HasSum.div_const
  apply hasSum_sum
  intro x hx
  exact HasSum.mul_right _ (h x)

/-- Exact Poisson transform of the actual discrete path counts.  In particular,
no walk-distribution or Poissonization identity is assumed as an input. -/
theorem poissonized_biased_path_count_hasSum (d : ℕ) (u : ℝ)
    (S : Finset (Fin d)) :
    HasSum (fun m => Real.exp (-((d : ℝ)+1)*u) *
      (u^m / (m.factorial : ℝ)) * (biasedPathCount m S : ℝ))
      ((poissonFlipProbability u)^S.card *
        (1-poissonFlipProbability u)^(d-S.card)) := by
  have hs (x : ClippingCube d) :
      HasSum (fun m => Real.exp (-((d : ℝ)+1)*u) *
          ((((d : ℝ)+1)*u)^m / (m.factorial : ℝ)) * (biasedProfile id x)^m)
        (biasedProfile (fun t => Real.exp (((d : ℝ)+1)*u*(t-1))) x) := by
    have h := (NormedSpace.expSeries_div_hasSum_exp
      (((d : ℝ)+1)*u*biasedProfile id x)).mul_left (Real.exp (-((d : ℝ)+1)*u))
    rw [← Real.exp_eq_exp_ℝ, ← Real.exp_add] at h
    convert h using 1 <;> try rfl
    · funext m
      simp only [mul_pow]
      ring
    · unfold biasedProfile
      dsimp only [id_eq]
      congr 1
      ring
  have h := walshCoefficients_hasSum _ _ hs S
  rw [poissonized_biased_walk_coefficient] at h
  convert h using 1
  funext m
  have hscalar (a : ℝ) :
      walshCoefficients (fun x : ClippingCube d => a*(biasedProfile id x)^m) S =
        a*walshCoefficients (biasedProfile (fun t => t^m)) S := by
    unfold walshCoefficients uniformCubeMean biasedProfile
    simp only [id_eq]
    simp_rw [mul_assoc]
    rw [← Finset.mul_sum]
    ring
  rw [hscalar,biasedDot_power_coefficient_walk]
  have hD : ((d : ℝ)+1)^m ≠ 0 := pow_ne_zero _ (by positivity)
  rw [mul_pow]
  field_simp

end NeuralGeneralization
