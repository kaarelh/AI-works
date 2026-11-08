import NeuralGeneralization.OnlineLowerTanhResidualPeak
import NeuralGeneralization.OnlineLowerTanhResidualEnvelope

/-! # Gaussian domination on an entire odd-lattice cell -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma phaseError_shift_even_nat (x : ℝ) (l : ℕ) :
    phaseError true (x+2*(l:ℝ)) = phaseError true x := by
  unfold phaseError phaseInteger
  simp only [↓reduceIte]
  have he : (x+2*(l:ℝ)-1)/2 = (x-1)/2+(l:ℝ) := by ring
  rw [he,round_add_natCast]
  push_cast
  ring

lemma phaseError_centered_abs {e : ℝ} (he : |e| ≤ 1) :
    |phaseError true (1+e)| = |e| := by
  have heb := abs_le.mp he
  by_cases he1 : e = 1
  · subst e
    norm_num [phaseError,phaseInteger]
  · have heLt : e < 1 := lt_of_le_of_ne heb.2 he1
    have hr : round (e/2) = (0:ℤ) := round_eq_zero_iff.mpr ⟨by linarith,by linarith⟩
    unfold phaseError phaseInteger
    simp only [↓reduceIte]
    rw [show (1+e-1)/2=e/2 by ring,hr]
    norm_num

lemma phaseError_peak_cell {A x : ℝ} (hA : 0 < A) (l : ℕ)
    (hx : |x| ≤ Real.pi/(2*A)) :
    (phaseError true (2*A*(residualPeak A l+x)/Real.pi))^2 =
      (2*A*x/Real.pi)^2 := by
  have he : 2*A*(residualPeak A l+x)/Real.pi =
      (1+2*A*x/Real.pi)+2*(l:ℝ) := by
    unfold residualPeak periodicFrequency
    field_simp
    <;> ring
  rw [he,phaseError_shift_even_nat]
  have hsmall : |2*A*x/Real.pi| ≤ 1 := by
    rw [abs_div,abs_mul,abs_of_pos (mul_pos (by norm_num) hA),abs_of_pos Real.pi_pos]
    apply (div_le_iff₀ Real.pi_pos).mpr
    have hh := (le_div_iff₀ (mul_pos (by norm_num) hA)).mp hx
    nlinarith
  have hh := phaseError_centered_abs hsmall
  exact (sq_abs _).symm.trans ((congrArg (fun z : ℝ => z^2) hh).trans (sq_abs _))

lemma residual_variance_upper {n : ℕ} (q : Fin n → ℝ) {Q : ℝ}
    (hq : ∀ i, |q i| ≤ Q) : (∑ i, (q i)^2) ≤ (n:ℝ)*Q^2 := by
  calc
    _ ≤ ∑ _ : Fin n, Q^2 := by
      apply Finset.sum_le_sum
      intro i _
      have hp := (sq_le_sq₀ (abs_nonneg (q i)) ((abs_nonneg (q i)).trans (hq i))).mpr (hq i)
      simpa only [sq_abs] using hp
    _ = _ := by simp

/-- On the full cell around a peak, the normalized Gaussian majorant has
an explicit alphabet-dependent rate and no restriction to small angles. -/
theorem residual_cell_gaussian_bound {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (label : Fin n → ι) (q c : ι → ℤ)
    (hqOdd : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*q j = 1)
    {α Q A s K T : ℝ} (hα : 0 < α) (hQ : 0 < Q) (hA : 0 < A)
    (hK : 0 ≤ K) (hT : 0 ≤ T)
    (hfreq : ∀ j, α*(n:ℝ) ≤ ((Finset.univ.filter (fun i => label i=j)).card:ℝ))
    (hq : ∀ i, |(q (label i):ℝ)| ≤ Q)
    (d : Fin n → ℝ) (hE : (∑ i, (d i)^2) ≤ K)
    (hscale : A^2*(∑ i, (q (label i):ℝ)^2)*s^2 = 1)
    (l : ℕ) (y : ℝ) (hy : |y*s| ≤ Real.pi/(2*A))
    (ht : |residualPeak A l+y*s| ≤ T) :
    |∏ i, Real.sin ((A*(q (label i):ℝ)+d i)*(residualPeak A l+y*s))| ≤
      Real.exp (K*T^2/2)*Real.exp (-(α/((∑ j, (c j:ℝ)^2)*Real.pi^2*Q^2))*y^2) := by
  have hp := residual_alphabet_product_envelope label q c hqOdd hbezout hα.le hfreq d A
    (residualPeak A l+y*s)
  rw [phaseError_peak_cell hA l hy] at hp
  apply hp.trans
  rw [← Real.exp_add]
  apply Real.exp_le_exp.mpr
  have hC := bezout_energy_pos q c hbezout
  have hvar := residual_variance_upper (fun i => (q (label i):ℝ)) hq
  have hm := mul_le_mul_of_nonneg_left hvar (mul_nonneg (sq_nonneg A) (sq_nonneg s))
  have hscale' : (A^2*s^2)*(∑ i, (q (label i):ℝ)^2) = 1 := by nlinarith [hscale]
  rw [hscale'] at hm
  have hrate : 1/Q^2 ≤ (n:ℝ)*A^2*s^2 := by
    apply (div_le_iff₀ (sq_pos_of_pos hQ)).mpr
    nlinarith [hm]
  have hcoef : 0 ≤ α/((∑ j, (c j:ℝ)^2)*Real.pi^2)*y^2 := by positivity
  have hrate' := mul_le_mul_of_nonneg_left hrate hcoef
  have ht2 : (residualPeak A l+y*s)^2 ≤ T^2 := by
    have hh := (sq_le_sq₀ (abs_nonneg _) hT).mpr ht
    simpa only [sq_abs] using hh
  have henergy := mul_le_mul hE ht2 (sq_nonneg _) hK
  have he : -α*(n:ℝ)*(2*A*(y*s)/Real.pi)^2/(4*∑ j, (c j:ℝ)^2) =
      -(α/((∑ j, (c j:ℝ)^2)*Real.pi^2)*y^2)*((n:ℝ)*A^2*s^2) := by ring
  have he' : (α/((∑ j, (c j:ℝ)^2)*Real.pi^2)*y^2)*(1/Q^2) =
      (α/((∑ j, (c j:ℝ)^2)*Real.pi^2*Q^2))*y^2 := by ring
  rw [he'] at hrate'
  rw [he]
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
