import NeuralGeneralization.BatchTwoNeuralConverseShells
import NeuralGeneralization.BatchTwoContinuousDepthSeparation

/-! Exact interpolation by two tanh features per separated sample. A
quantitative Neumann inverse controls the actual readout coefficients. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoNeuralConverse

def softBump (a δ c t : ℝ) : ℝ :=
  (1+Real.tanh (a*(t-c+δ/2)))/2-(1+Real.tanh (a*(t-c-δ/2)))/2

theorem softBump_diagonal (a δ c : ℝ) :
    |softBump a δ c c-1| ≤ 2*Real.exp (-a*δ) := by
  have hp := logistic_positive_error (A := a*δ/2) (q := a*(c-c+δ/2)) (by nlinarith)
  have hn := logistic_negative_error (A := a*δ/2) (q := a*(c-c-δ/2)) (by nlinarith)
  have he : -2*(a*δ/2)=-a*δ := by ring
  rw [he] at hp hn
  have htri := abs_sub ((1+Real.tanh (a*(c-c+δ/2)))/2-1)
    ((1+Real.tanh (a*(c-c-δ/2)))/2)
  unfold softBump
  have hi : (1+Real.tanh (a*(c-c+δ/2)))/2-(1+Real.tanh (a*(c-c-δ/2)))/2-1 =
      ((1+Real.tanh (a*(c-c+δ/2)))/2-1)-(1+Real.tanh (a*(c-c-δ/2)))/2 := by ring
  rw [hi]
  linarith

theorem softBump_off_diagonal {a δ c t : ℝ} (ha : 0 ≤ a) (hδ : 0 ≤ δ)
    (hsep : δ ≤ |t-c|) : |softBump a δ c t| ≤ 2*Real.exp (-a*δ) := by
  have he : -2*(a*δ/2)=-a*δ := by ring
  rcases le_or_gt c t with hct|hct
  · rw [abs_of_nonneg (sub_nonneg.mpr hct)] at hsep
    have hp := logistic_positive_error (A := a*δ/2) (q := a*(t-c+δ/2)) (by nlinarith)
    have hn := logistic_positive_error (A := a*δ/2) (q := a*(t-c-δ/2)) (by nlinarith)
    rw [he] at hp hn
    have htri := abs_sub ((1+Real.tanh (a*(t-c+δ/2)))/2-1)
      ((1+Real.tanh (a*(t-c-δ/2)))/2-1)
    have hi : softBump a δ c t = ((1+Real.tanh (a*(t-c+δ/2)))/2-1)-
        ((1+Real.tanh (a*(t-c-δ/2)))/2-1) := by unfold softBump; ring
    rw [hi]
    linarith
  · rw [abs_of_nonpos (sub_nonpos.mpr hct.le)] at hsep
    have hp := logistic_negative_error (A := a*δ/2) (q := a*(t-c+δ/2)) (by nlinarith)
    have hn := logistic_negative_error (A := a*δ/2) (q := a*(t-c-δ/2)) (by nlinarith)
    rw [he] at hp hn
    have htri := abs_sub ((1+Real.tanh (a*(t-c+δ/2)))/2)
      ((1+Real.tanh (a*(t-c-δ/2)))/2)
    exact htri.trans (by linarith)

def interpolationSlope (n : ℕ) (δ : ℝ) : ℝ := δ⁻¹*Real.log (16*(n : ℝ))

theorem interpolationSlope_pos {n : ℕ} (hn : 0 < n) {δ : ℝ} (hδ : 0 < δ) :
    0 < interpolationSlope n δ := by
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  unfold interpolationSlope
  exact mul_pos (inv_pos.mpr hδ) (Real.log_pos (by linarith))

theorem interpolationSlope_exp {n : ℕ} (hn : 0 < n) {δ : ℝ} (hδ : 0 < δ) :
    2*Real.exp (-interpolationSlope n δ*δ)=1/(8*(n : ℝ)) := by
  have hnR : (0 : ℝ)<n := by exact_mod_cast hn
  have he : -interpolationSlope n δ*δ= -Real.log (16*(n : ℝ)) := by
    unfold interpolationSlope
    field_simp
  rw [he,Real.exp_neg,Real.exp_log (by positivity)]
  field_simp
  <;> ring

/-- The sample matrix is close to identity in actual column l1 norm. -/
theorem softBump_matrix_error {n : ℕ} (hn : 0 < n) {δ : ℝ} (hδ : 0 < δ)
    (s : Fin n → ℝ) (hsep : ∀ i j, i≠j → δ ≤ |s i-s j|) (i j : Fin n) :
    |softBump (interpolationSlope n δ) δ (s j) (s i)-(if i=j then 1 else 0)| ≤
      1/(8*(n : ℝ)) := by
  rw [← interpolationSlope_exp hn hδ]
  by_cases hij : i=j
  · subst j
    simpa only [ite_true] using softBump_diagonal (interpolationSlope n δ) δ (s i)
  · simpa only [if_neg hij,sub_zero] using
      softBump_off_diagonal (interpolationSlope_pos hn hδ).le hδ.le (hsep i j hij)

/-- Exact interpolation and a quantitative coefficient bound, with no
ordering hypothesis on the separated sample. -/
theorem exact_bump_coefficients {n : ℕ} (hn : 0 < n) {δ : ℝ} (hδ : 0 < δ)
    (s y : Fin n → ℝ) (hsep : ∀ i j, i≠j → δ ≤ |s i-s j|) :
    ∃ v : Fin n → ℝ, vectorL1 v ≤ 2*vectorL1 y ∧
      ∀ i, (∑ j, v j*softBump (interpolationSlope n δ) δ (s j) (s i))=y i := by
  classical
  let Q : Fin n → Fin n → ℝ := fun i j => softBump (interpolationSlope n δ) δ (s j) (s i)
  let A : Fin n → Fin n → ℝ := fun i j => (if i=j then 1 else 0)-Q i j
  have hA (j : Fin n) : (∑ i, |A i j|) ≤ 1/2 := by
    calc
      _ ≤ ∑ _i : Fin n, 1/(8*(n : ℝ)) := Finset.sum_le_sum (fun i _ => by
        simpa only [A,Q,abs_sub_comm] using softBump_matrix_error hn hδ s hsep i j)
      _ = 1/8 := by
        have hnR : (n : ℝ)≠0 := by exact_mod_cast hn.ne'
        simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
        field_simp
      _ ≤ 1/2 := by norm_num
  obtain ⟨v,hv,hbound⟩ := exists_neumann_solution A y hA
  refine ⟨v,hbound,?_⟩
  intro i
  have he := hv i
  have hAv : applyMatrix A v i = v i-applyMatrix Q v i := by
    simp [applyMatrix,A,sub_mul,Finset.sum_sub_distrib]
  rw [hAv] at he
  have hQ : applyMatrix Q v i=y i := by linarith
  simpa only [applyMatrix,Q,mul_comm] using hQ

end NeuralGeneralization.BatchTwoContinuousDepthLower
