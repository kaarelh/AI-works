import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedBumps
import NeuralGeneralization.BatchTwoContinuousModel

/-! The mean seed is built from literal standardized first-layer Gaussian
weight shifts, with a uniform quadratic cost bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuous

def firstRowCoefficient (x:RealInput 2) : Fin 3→ℝ := fun j=>augmentedInput x j/Real.sqrt 2

def seedShift (a δ center:ℝ) (y side:Bool) : Fin 3→ℝ :=
  ![labelReal y*labelReal side*Real.sqrt 2*a*(-center+labelReal side*δ/2),
    labelReal y*labelReal side*Real.sqrt 2*a,0]

theorem firstRowCoefficient_energy (x:RealInput 2) (hx:∑j,x j^2≤1) :
    ∑j,firstRowCoefficient x j^2≤1 := by
  simp only [firstRowCoefficient,augmentedInput,Fin.sum_univ_succ,Fin.cases_zero,Fin.cases_succ,
    Fin.sum_univ_zero,Fin.isValue,add_zero,div_pow,Real.sq_sqrt (by norm_num : (0:ℝ)≤2)]
  simp only [Fin.sum_univ_succ,Fin.sum_univ_zero,add_zero] at hx
  norm_num at hx ⊢
  linarith

theorem seedShift_dot (x:RealInput 2) (a δ center:ℝ) (y side:Bool) :
    (∑j,firstRowCoefficient x j*seedShift a δ center y side j)=
      labelReal y*labelReal side*a*(x 0-center+labelReal side*δ/2) := by
  have hs : Real.sqrt (2:ℝ)≠0 := by positivity
  simp only [firstRowCoefficient,augmentedInput,seedShift,Fin.sum_univ_succ,Fin.cases_zero,
    Fin.cases_succ,Fin.sum_univ_zero,Fin.isValue,Matrix.cons_val_zero,Matrix.cons_val_succ,Matrix.cons_val_one,
    Matrix.cons_val_two,add_zero,mul_zero]
  field_simp
  <;> ring

theorem seedShift_energy (a δ center:ℝ) (y side:Bool)
    (hc:|center|≤1) (hδ:0≤δ) (hδ1:δ≤1) :
    (∑j,seedShift a δ center y side j^2)≤10*a^2 := by
  have hsr : (Real.sqrt (2:ℝ))^2=2 := Real.sq_sqrt (by norm_num)
  have he : (∑j,seedShift a δ center y side j^2)=
      2*a^2*((-center+labelReal side*δ/2)^2+1) := by
    cases y <;> cases side <;>
      norm_num [seedShift,labelReal,Fin.sum_univ_succ,mul_pow,hsr] <;> ring
  rw [he]
  have hb : |-center+labelReal side*δ/2|≤3/2 := by
    have hh:=abs_add_le (-center) (labelReal side*δ/2)
    rw [abs_neg,abs_div,abs_mul,abs_labelReal,one_mul,abs_of_nonneg hδ,
      abs_of_pos (by norm_num : (0:ℝ)<2)] at hh
    linarith
  have hs := pow_le_pow_left₀ (abs_nonneg _) hb 2
  rw [sq_abs] at hs
  have hm:=mul_le_mul_of_nonneg_left hs (sq_nonneg a)
  nlinarith [sq_nonneg a]

theorem gaussianRowMean_label (c:Fin 3→ℝ) (m:ℝ) (y:Bool) :
    gaussianRowMean c (labelReal y*m)=labelReal y*gaussianRowMean c m := by
  cases y <;> simp only [labelReal_false,labelReal_true,neg_one_mul,one_mul,gaussianRowMean_odd]

theorem seedShift_pair_mean (x:RealInput 2) (a δ center:ℝ) (y:Bool) :
    (∑side:Bool,gaussianRowMean (firstRowCoefficient x)
      (∑j,firstRowCoefficient x j*seedShift a δ center y side j))=
        2*labelReal y*gaussianBumpMean (firstRowCoefficient x) a δ center (x 0) := by
  simp_rw [seedShift_dot]
  rw [Fintype.sum_bool]
  simp only [labelReal_false,labelReal_true,mul_one,mul_neg_one,one_mul,neg_one_mul]
  have hf : -(labelReal y)*a*(x 0-center+-δ/2)=labelReal y*(-(a*(x 0-center-δ/2))) := by ring
  rw [hf,gaussianRowMean_label,gaussianRowMean_odd]
  have ht : labelReal y*a*(x 0-center+δ/2)=labelReal y*(a*(x 0-center+δ/2)) := by ring
  rw [ht,gaussianRowMean_label]
  unfold gaussianBumpMean
  ring

theorem seedRows_signed_mean {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ)
    (x:Fin n→RealInput 2) (hx:∀i,∑j,x i j^2≤1)
    (hsep:∀i j,i≠j→δ≤|x i 0-x j 0|) (y:Fin n→Bool) (i:Fin n) :
    (7/(8*(n:ℝ)))≤labelReal (y i)*
      ((∑p:Fin n×Bool,gaussianRowMean (firstRowCoefficient (x i))
        (∑j,firstRowCoefficient (x i) j*seedShift (seedSlope n δ) δ (x p.1 0) (y p.1) p.2 j))/(2*(n:ℝ))) := by
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  have hs:=gaussianBumpMean_signed_seed hn hδ (fun i=>x i 0) hsep
    (fun i=>firstRowCoefficient (x i)) (fun i=>firstRowCoefficient_energy (x i) (hx i)) y i
  rw [Fintype.sum_prod_type]
  simp_rw [seedShift_pair_mean]
  have he : (∑j:Fin n,2*labelReal (y j)*gaussianBumpMean (firstRowCoefficient (x i)) (seedSlope n δ) δ (x j 0) (x i 0))=
      2*∑j:Fin n,labelReal (y j)*gaussianBumpMean (firstRowCoefficient (x i)) (seedSlope n δ) δ (x j 0) (x i 0) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he]
  have hid : labelReal (y i)*(2*(∑j:Fin n,labelReal (y j)*gaussianBumpMean (firstRowCoefficient (x i)) (seedSlope n δ) δ (x j 0) (x i 0))/(2*(n:ℝ)))=
      (labelReal (y i)*(∑j:Fin n,labelReal (y j)*gaussianBumpMean (firstRowCoefficient (x i)) (seedSlope n δ) δ (x j 0) (x i 0)))/(n:ℝ) := by ring
  rw [hid]
  convert! div_le_div_of_nonneg_right hs hnR.le using 1 <;> ring

end NeuralGeneralization.BatchTwoContinuousDepthCritical
