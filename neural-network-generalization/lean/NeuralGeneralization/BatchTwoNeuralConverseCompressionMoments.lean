import NeuralGeneralization.PrunedNetwork
import NeuralGeneralization.SamplingLaw
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.MeasureTheory.Function.L2Space

/-! Actual finite-source vector moments for the forward compressor. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory
open ConcreteModel CompressionSampling Compression

variable {Ω E : Type*} [Fintype Ω] [MeasurableSpace Ω] [MeasurableSingletonClass Ω]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

theorem finite_centered_mean (μ : Measure Ω) [IsProbabilityMeasure μ] (Y : Ω → E) :
    (∫ j,Y j-(∫ i,Y i ∂μ) ∂μ)=0 := by
  rw [integral_sub Integrable.of_finite Integrable.of_finite, integral_const]
  simp

theorem finite_centered_second_moment (μ : Measure Ω) [IsProbabilityMeasure μ] (Y : Ω → E) :
    (∫ j,‖Y j-(∫ i,Y i ∂μ)‖^2 ∂μ)≤∫ j,‖Y j‖^2 ∂μ := by
  simp only [norm_sub_sq_real]
  have he (j : Ω) : inner ℝ (Y j) (∫ i,Y i ∂μ)=inner ℝ (∫ i,Y i ∂μ) (Y j) := real_inner_comm _ _
  simp_rw [he]
  rw [integral_add Integrable.of_finite Integrable.of_finite,
    integral_sub Integrable.of_finite Integrable.of_finite,integral_const_mul,
    integral_inner Integrable.of_finite, real_inner_self_eq_norm_sq,integral_const]
  simp only [probReal_univ,one_smul]
  nlinarith [sq_nonneg ‖∫ i,Y i ∂μ‖]

theorem finite_centered_norm (μ : Measure Ω) [IsProbabilityMeasure μ] (Y : Ω → E)
    {b : ℝ} (hb : ∀ j,‖Y j‖≤b) (j : Ω) :
    ‖Y j-(∫ i,Y i ∂μ)‖≤2*b := by
  have hm : ‖∫ i,Y i ∂μ‖≤b := by
    simpa using norm_integral_le_of_norm_le_const (μ := μ) (ae_of_all _ hb)
  exact (norm_sub_le _ _).trans (by linarith [hb j])

theorem uniformIndex_vector_integral (N : ℕ) [NeZero N] (Y : Fin N → E) :
    (∫ j,Y j ∂uniformIndexLaw N)=((N : ℝ)⁻¹) • ∑ j,Y j := by
  unfold uniformIndexLaw
  rw [PMF.integral_eq_sum]
  simp only [PMF.uniformOfFintype_apply,Fintype.card_fin,ENNReal.toReal_inv,
    ENNReal.toReal_natCast,Finset.smul_sum]

variable {D N : ℕ}

def matrixSummand (A : Fin D → Fin N → ℝ) (h : Fin N → ℝ) (j : Fin N) :
    EuclideanSpace ℝ (Fin D) := WithLp.toLp 2 (fun i => (N : ℝ)*A i j*h j)

def matrixMean (A : Fin D → Fin N → ℝ) (h : Fin N → ℝ) :
    EuclideanSpace ℝ (Fin D) := WithLp.toLp 2 (fun i => ∑ j,A i j*h j)

@[simp] theorem matrixSummand_apply (A : Fin D → Fin N → ℝ) (h : Fin N → ℝ) (j : Fin N) (i : Fin D) :
    matrixSummand A h j i=(N : ℝ)*A i j*h j := rfl

@[simp] theorem matrixMean_apply (A : Fin D → Fin N → ℝ) (h : Fin N → ℝ) (i : Fin D) :
    matrixMean A h i=∑ j,A i j*h j := rfl

theorem matrixSummand_mean (hN : 0<N) (A : Fin D → Fin N → ℝ) (h : Fin N → ℝ) :
    letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
    (∫ j,matrixSummand A h j ∂uniformIndexLaw N)=matrixMean A h := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  rw [uniformIndex_vector_integral]
  ext i
  simp only [PiLp.smul_apply,smul_eq_mul,matrixMean_apply]
  have he : (∑ j,matrixSummand A h j) i=∑ j,(N : ℝ)*A i j*h j := by
    change (EuclideanSpace.proj i) (∑ j,matrixSummand A h j)=_
    rw [map_sum]
    rfl
  rw [he]
  simp_rw [mul_assoc]
  rw [←Finset.mul_sum,inv_mul_cancel_left₀ (by exact_mod_cast Nat.ne_of_gt hN)]

theorem matrixSummand_second_moment (hN : 0<N)
    (A W : Fin D → Fin N → ℝ) (h : Fin N → ℝ) (hh : ∀ j,|h j|≤1)
    (hAW : ∀ i j,(A i j)^2≤(W i j)^2) :
    letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
    (∫ j,‖matrixSummand A h j‖^2 ∂uniformIndexLaw N)≤(N : ℝ)*∑ i,∑ j,(W i j)^2 := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  rw [uniformIndex_integral]
  have hrow (j : Fin N) : ‖matrixSummand A h j‖^2≤(N : ℝ)^2*∑ i,(W i j)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq,Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    rw [matrixSummand_apply,mul_pow,mul_pow]
    have hh2 : (h j)^2≤1 := by nlinarith [sq_abs (h j),sq_nonneg (|h j|-1),hh j,abs_nonneg (h j)]
    calc
      _ ≤ (N : ℝ)^2*(A i j)^2*1 := mul_le_mul_of_nonneg_left hh2 (by positivity)
      _ ≤ _ := by simpa only [mul_one] using mul_le_mul_of_nonneg_left (hAW i j) (sq_nonneg (N:ℝ))
  have hs := Finset.sum_le_sum (fun j (_ : j∈Finset.univ) => hrow j)
  have hNR : (0:ℝ)<N := by exact_mod_cast hN
  apply (div_le_iff₀ hNR).mpr
  calc
    _ ≤ ∑ j,(N : ℝ)^2*∑ i,(W i j)^2 := hs
    _ = _ := by rw [←Finset.mul_sum,Finset.sum_comm]; ring

theorem matrixSummand_norm_le (A : Fin D → Fin N → ℝ) (h : Fin N → ℝ)
    (hh : ∀ j,|h j|≤1) (a : Fin D → ℝ) (ha : ∀ i,0≤a i)
    {τ : ℝ} (hτ : 0≤τ) (hA : ∀ i j,|A i j|≤τ*a i) (j : Fin N) :
    ‖matrixSummand A h j‖≤(N : ℝ)*τ*Real.sqrt (∑ i,(a i)^2) := by
  have hs : ‖matrixSummand A h j‖^2≤((N : ℝ)*τ)^2*∑ i,(a i)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq,Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have ha' : |(N : ℝ)*A i j*h j|≤(N : ℝ)*τ*a i := by
      rw [abs_mul,abs_mul,abs_of_nonneg (Nat.cast_nonneg N)]
      calc
        _ ≤ (N : ℝ)*|A i j| * 1 := mul_le_mul_of_nonneg_left (hh j) (by positivity)
        _ ≤ _ := by simpa only [mul_one,mul_assoc] using mul_le_mul_of_nonneg_left (hA i j) (Nat.cast_nonneg N)
    have ht := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (mul_nonneg (Nat.cast_nonneg N) hτ) (ha i))).mpr ha'
    simpa only [sq_abs,matrixSummand_apply,mul_pow,mul_assoc] using ht
  have hsum : 0≤∑ i,(a i)^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hsq := Real.sq_sqrt hsum
  have hpos : 0≤(N : ℝ)*τ*Real.sqrt (∑ i,(a i)^2) := by positivity
  apply (sq_le_sq₀ (norm_nonneg _) hpos).mp
  nlinarith [hs]

end
end NeuralGeneralization.BatchTwoNeuralConverse
