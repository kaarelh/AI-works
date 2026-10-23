import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedMean
import NeuralGeneralization.BatchTwoContinuousDepthInterpolation

/-! Separated training inputs have a signed Gaussian feature-mean seed. The
construction uses two actual Gaussian shifts per point and requires no matrix
inverse or sorting of the training sample. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
variable {I:Type*} [Fintype I]

theorem gaussianRowMean_positive_error (c:I→ℝ) (hc:∑i,c i^2≤1) {m A:ℝ} (hm:A≤m) :
    |gaussianRowMean c m-1|≤2*Real.exp (-2*A+2) :=
  (gaussianRowMean_saturation c m hc).trans
    (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by linarith)) (by norm_num))

theorem gaussianRowMean_negative_error (c:I→ℝ) (hc:∑i,c i^2≤1) {m A:ℝ} (hm:m≤-A) :
    |gaussianRowMean c m+1|≤2*Real.exp (-2*A+2) := by
  have hh:=gaussianRowMean_positive_error c hc (m := -m) (by linarith : A≤-m)
  rw [gaussianRowMean_odd] at hh
  have he : -gaussianRowMean c m-1= -(gaussianRowMean c m+1) := by ring
  rwa [he,abs_neg] at hh

def gaussianBumpMean (c:I→ℝ) (a δ center t:ℝ) : ℝ :=
  (gaussianRowMean c (a*(t-center+δ/2))-gaussianRowMean c (a*(t-center-δ/2)))/2

theorem gaussianBumpMean_diagonal (c:I→ℝ) (hc:∑i,c i^2≤1) (a δ center:ℝ) :
    |gaussianBumpMean c a δ center center-1|≤2*Real.exp (-a*δ+2) := by
  have hp:=gaussianRowMean_positive_error c hc (m:=a*(center-center+δ/2)) (A:=a*δ/2) (by nlinarith)
  have hn:=gaussianRowMean_negative_error c hc (m:=a*(center-center-δ/2)) (A:=a*δ/2) (by nlinarith)
  have htri:=abs_sub (gaussianRowMean c (a*(center-center+δ/2))-1)
    (gaussianRowMean c (a*(center-center-δ/2))+1)
  have he : -2*(a*δ/2)+2= -a*δ+2 := by ring
  rw [he] at hp hn
  have hform : gaussianBumpMean c a δ center center-1=
    ((gaussianRowMean c (a*(center-center+δ/2))-1)-(gaussianRowMean c (a*(center-center-δ/2))+1))/2 := by
    unfold gaussianBumpMean
    ring
  rw [hform,abs_div]
  rw [abs_of_pos (by norm_num : (0:ℝ)<2)]
  linarith

theorem gaussianBumpMean_off_diagonal (c:I→ℝ) (hc:∑i,c i^2≤1)
    {a δ center t:ℝ} (ha:0≤a) (hδ:0≤δ) (hsep:δ≤|t-center|) :
    |gaussianBumpMean c a δ center t|≤2*Real.exp (-a*δ+2) := by
  have he : -2*(a*δ/2)+2= -a*δ+2 := by ring
  rcases le_or_gt center t with hct|hct
  · rw [abs_of_nonneg (sub_nonneg.mpr hct)] at hsep
    have hp:=gaussianRowMean_positive_error c hc (m:=a*(t-center+δ/2)) (A:=a*δ/2) (by nlinarith)
    have hn:=gaussianRowMean_positive_error c hc (m:=a*(t-center-δ/2)) (A:=a*δ/2) (by nlinarith)
    rw [he] at hp hn
    have ht:=abs_sub (gaussianRowMean c (a*(t-center+δ/2))-1) (gaussianRowMean c (a*(t-center-δ/2))-1)
    have hf : gaussianBumpMean c a δ center t=
      ((gaussianRowMean c (a*(t-center+δ/2))-1)-(gaussianRowMean c (a*(t-center-δ/2))-1))/2 := by unfold gaussianBumpMean;ring
    rw [hf,abs_div]
    rw [abs_of_pos (by norm_num : (0:ℝ)<2)]
    linarith
  · rw [abs_of_nonpos (sub_nonpos.mpr hct.le)] at hsep
    have hp:=gaussianRowMean_negative_error c hc (m:=a*(t-center+δ/2)) (A:=a*δ/2) (by nlinarith)
    have hn:=gaussianRowMean_negative_error c hc (m:=a*(t-center-δ/2)) (A:=a*δ/2) (by nlinarith)
    rw [he] at hp hn
    have ht:=abs_sub (gaussianRowMean c (a*(t-center+δ/2))+1) (gaussianRowMean c (a*(t-center-δ/2))+1)
    have hf : gaussianBumpMean c a δ center t=
      ((gaussianRowMean c (a*(t-center+δ/2))+1)-(gaussianRowMean c (a*(t-center-δ/2))+1))/2 := by unfold gaussianBumpMean;ring
    rw [hf,abs_div]
    rw [abs_of_pos (by norm_num : (0:ℝ)<2)]
    linarith

def seedSlope (n:ℕ) (δ:ℝ) : ℝ := (2+Real.log (16*(n:ℝ)))/δ

theorem seedSlope_pos {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ) : 0<seedSlope n δ := by
  have hnR : (1:ℝ)≤n := by exact_mod_cast hn
  unfold seedSlope
  exact div_pos (by have:=Real.log_nonneg (show (1:ℝ)≤16*(n:ℝ) by linarith);linarith) hδ

theorem seedSlope_error {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ) :
    2*Real.exp (-seedSlope n δ*δ+2)=1/(8*(n:ℝ)) := by
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  have he : -seedSlope n δ*δ+2= -Real.log (16*(n:ℝ)) := by unfold seedSlope;field_simp;ring
  rw [he,Real.exp_neg,Real.exp_log (by positivity)]
  field_simp
  <;> ring

theorem gaussianBumpMean_matrix_error {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ)
    (s:Fin n→ℝ) (hsep:∀i j,i≠j→δ≤|s i-s j|) (c:Fin n→I→ℝ)
    (hc:∀i,∑a,c i a^2≤1) (i j:Fin n) :
    |gaussianBumpMean (c i) (seedSlope n δ) δ (s j) (s i)-(if i=j then 1 else 0)|≤1/(8*(n:ℝ)) := by
  classical
  rw [←seedSlope_error hn hδ]
  by_cases hij:i=j
  · subst j
    simpa only [ite_true] using gaussianBumpMean_diagonal (c i) (hc i) (seedSlope n δ) δ (s i)
  · simpa only [if_neg hij,sub_zero] using gaussianBumpMean_off_diagonal (c i) (hc i)
      (seedSlope_pos hn hδ).le hδ.le (hsep i j hij)


theorem gaussianBumpMean_signed_seed {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ)
    (s:Fin n→ℝ) (hsep:∀i j,i≠j→δ≤|s i-s j|) (c:Fin n→I→ℝ)
    (hc:∀i,∑a,c i a^2≤1) (y:Fin n→Bool) (i:Fin n) :
    (7/8:ℝ)≤ConcreteModel.labelReal (y i)*
      (∑j,ConcreteModel.labelReal (y j)*gaussianBumpMean (c i) (seedSlope n δ) δ (s j) (s i)) := by
  classical
  let b:=fun j=>gaussianBumpMean (c i) (seedSlope n δ) δ (s j) (s i)
  have hsum : |(∑j,ConcreteModel.labelReal (y j)*b j)-ConcreteModel.labelReal (y i)|≤1/8 := by
    have he : (∑j,ConcreteModel.labelReal (y j)*b j)-ConcreteModel.labelReal (y i)=
        ∑j,ConcreteModel.labelReal (y j)*(b j-(if i=j then 1 else 0)) := by
      simp_rw [mul_sub]
      rw [Finset.sum_sub_distrib]
      simp
    rw [he]
    apply (Finset.abs_sum_le_sum_abs _ _).trans
    calc
      _ ≤ ∑_j:Fin n,1/(8*(n:ℝ)) := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul,ConcreteModel.abs_labelReal,one_mul]
        exact gaussianBumpMean_matrix_error hn hδ s hsep c hc i j
      _ = 1/8 := by
        have hnR : (n:ℝ)≠0 := by exact_mod_cast hn.ne'
        simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
        field_simp
  have hh:=abs_le.mp hsum
  cases hy:y i <;> simp only [hy,ConcreteModel.labelReal_false,ConcreteModel.labelReal_true,
    neg_one_mul,one_mul] at hh ⊢ <;> change _ at hh <;> linarith [hh.1,hh.2]

end NeuralGeneralization.BatchTwoContinuousDepthCritical
