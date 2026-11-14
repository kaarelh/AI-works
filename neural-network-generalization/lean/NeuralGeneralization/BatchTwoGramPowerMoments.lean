import NeuralGeneralization.BatchTwoImprovedGramProbability
import Mathlib.Analysis.Matrix.PosDef
import Mathlib.Analysis.Matrix.Normed
import Mathlib.Analysis.Calculus.Deriv.Pow

/-! Polynomial-potential moments for the sharp empirical Gram lower tail. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

theorem weighted_power_product (w lam : ι→ℝ) (hw : ∀i,0≤w i) (hlam : ∀i,0≤lam i) (p q : ℕ) :
    (∑i,w i*lam i^p)*(∑i,w i*lam i^q)≤(∑i,w i)*(∑i,w i*lam i^(p+q)) := by
  have hpq (i j : ι) : 0≤(lam i^p-lam j^p)*(lam i^q-lam j^q) := by
    rcases le_total (lam i) (lam j) with h | h
    · exact mul_nonneg_of_nonpos_of_nonpos (sub_nonpos.mpr (pow_le_pow_left₀ (hlam i) h p))
        (sub_nonpos.mpr (pow_le_pow_left₀ (hlam i) h q))
    · exact mul_nonneg (sub_nonneg.mpr (pow_le_pow_left₀ (hlam j) h p))
        (sub_nonneg.mpr (pow_le_pow_left₀ (hlam j) h q))
  have hh : (∑i,∑j,((w i*lam i^p)*(w j*lam j^q)+(w i*lam i^q)*(w j*lam j^p)))≤
      ∑i,∑j,((w i*lam i^(p+q))*w j+w i*(w j*lam j^(p+q))) := by
    apply Finset.sum_le_sum
    intro i _
    apply Finset.sum_le_sum
    intro j _
    have ht := mul_nonneg (mul_nonneg (hw i) (hw j)) (hpq i j)
    simp only [pow_add]
    nlinarith only [ht]
  simp only [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.sum_mul] at hh
  nlinarith only [hh]

def powerMoment (A : Matrix ι ι ℝ) (u : ι→ℝ) (p : ℕ) : ℝ := u ⬝ᵥ (A^p *ᵥ u)

theorem powerMoment_spectral (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (u : ι→ℝ) (p : ℕ) :
    powerMoment A u p=∑i,((star (hA.eigenvectorUnitary : Matrix ι ι ℝ))*ᵥ u) i^2*hA.eigenvalues i^p := by
  have hp : A^p=Unitary.conjStarAlgAut ℝ _ hA.eigenvectorUnitary
      (Matrix.diagonal (fun i=>hA.eigenvalues i^p)) := by
    calc
      A^p=(Unitary.conjStarAlgAut ℝ _ hA.eigenvectorUnitary
        (Matrix.diagonal (RCLike.ofReal ∘ hA.eigenvalues)))^p := congrArg (fun M=>M^p) hA.spectral_theorem
      _ = _ := by rw [←map_pow,Matrix.diagonal_pow]; rfl
  unfold powerMoment
  rw [hp,Unitary.conjStarAlgAut_apply]
  simp only [Matrix.star_eq_conjTranspose,Matrix.conjTranspose_eq_transpose_of_trivial]
  rw [←Matrix.mulVec_mulVec,←Matrix.mulVec_mulVec,Matrix.dotProduct_mulVec,←Matrix.mulVec_transpose]
  simp only [dotProduct,Matrix.mulVec_diagonal]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem powerMoment_nonneg (A : Matrix ι ι ℝ) (hA : A.PosSemidef) (u : ι→ℝ) (p : ℕ) :
    0≤powerMoment A u p := by
  rw [powerMoment_spectral A hA.1]
  exact Finset.sum_nonneg fun i _=>mul_nonneg (sq_nonneg _) (pow_nonneg (hA.eigenvalues_nonneg i) _)

theorem powerMoment_zero (A : Matrix ι ι ℝ) (u : ι→ℝ) : powerMoment A u 0=∑i,u i^2 := by
  simp [powerMoment,dotProduct,pow_two]

theorem powerMoment_product (A : Matrix ι ι ℝ) (hA : A.PosSemidef) (u : ι→ℝ) (p q : ℕ) :
    powerMoment A u p*powerMoment A u q≤(∑i,u i^2)*powerMoment A u (p+q) := by
  rw [←powerMoment_zero A u]
  simp_rw [powerMoment_spectral A hA.1]
  simpa only [pow_zero,mul_one] using weighted_power_product
    (fun i=>((star (hA.1.eigenvectorUnitary : Matrix ι ι ℝ))*ᵥ u) i^2)
    hA.1.eigenvalues (fun _=>sq_nonneg _) hA.eigenvalues_nonneg p q

theorem powerMoment_lower_shift (A : Matrix ι ι ℝ) (hA : A.PosSemidef) (u : ι→ℝ)
    {b : ℝ} (hb : ∀i,b≤hA.1.eigenvalues i) (p : ℕ) :
    b*powerMoment A u p≤powerMoment A u (p+1) := by
  simp_rw [powerMoment_spectral A hA.1]
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have hh := mul_le_mul_of_nonneg_right (hb i)
    (mul_nonneg (sq_nonneg (((star (hA.1.eigenvectorUnitary : Matrix ι ι ℝ))*ᵥ u) i))
      (pow_nonneg (hA.eigenvalues_nonneg i) p))
  rw [pow_succ]
  convert hh using 1 <;> ring

end NeuralGeneralization.BatchTwoGramPower
