import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Algebra.Order.Round
import Mathlib.Tactic

noncomputable section
open Real
namespace NeuralGeneralization.OnlineLowerTanh

def phaseInteger (odd:Bool) (x:ℝ) : ℤ :=
  2*round ((x-(if odd then 1 else 0))/2)+(if odd then 1 else 0)
def phaseError (odd:Bool) (x:ℝ) : ℝ := x-(phaseInteger odd x:ℝ)
def phaseWave (odd:Bool) (x:ℝ) : ℝ :=
  if odd then |Real.sin (Real.pi*x/2)| else |Real.cos (Real.pi*x/2)|

lemma phaseInteger_even (x:ℝ) : Even (phaseInteger false x) := by
  simp [phaseInteger]
lemma phaseInteger_odd (x:ℝ) : Odd (phaseInteger true x) := by
  simp [phaseInteger]

lemma phaseError_abs_le_one (odd:Bool) (x:ℝ) : |phaseError odd x|≤1 := by
  have hh:=abs_sub_round ((x-(if odd then 1 else 0))/2)
  have he : phaseError odd x=2*((x-(if odd then 1 else 0))/2-
      (round ((x-(if odd then 1 else 0))/2):ℝ)) := by
    cases odd <;> simp [phaseError,phaseInteger] <;> ring
  rw [he,abs_mul,abs_of_pos (by norm_num : 0<(2:ℝ))]
  linarith

lemma phaseError_decompose (odd:Bool) (x:ℝ) :
    x=(phaseInteger odd x:ℝ)+phaseError odd x := by simp [phaseError]

lemma phase_cos_nonneg (odd:Bool) (x:ℝ) :
    0≤Real.cos (Real.pi*phaseError odd x/2) := by
  have hh:=abs_le.mp (phaseError_abs_le_one odd x)
  apply Real.cos_nonneg_of_neg_pi_div_two_le_of_le
  · nlinarith [Real.pi_pos]
  · nlinarith [Real.pi_pos]

lemma phaseWave_eq_cos_error (odd:Bool) (x:ℝ) :
    phaseWave odd x=Real.cos (Real.pi*phaseError odd x/2) := by
  cases odd
  · have he : Real.pi*x/2=Real.pi*phaseError false x/2+
        (round (x/2):ℝ)*Real.pi := by simp [phaseError,phaseInteger]; ring
    simp only [phaseWave,Bool.false_eq_true,↓reduceIte]
    rw [he,Real.cos_add_int_mul_pi,abs_mul,abs_zpow]
    simp only [abs_neg,abs_one,one_zpow,one_mul]
    exact abs_of_nonneg (phase_cos_nonneg false x)
  · have he : Real.pi*x/2=(Real.pi*phaseError true x/2+Real.pi/2)+
        (round ((x-1)/2):ℝ)*Real.pi := by simp [phaseError,phaseInteger]; ring
    simp only [phaseWave,↓reduceIte]
    rw [he,Real.sin_add_int_mul_pi,Real.sin_add_pi_div_two,abs_mul,abs_zpow]
    simp only [abs_neg,abs_one,one_zpow,one_mul]
    exact abs_of_nonneg (phase_cos_nonneg true x)

/-- Nearest even/odd lattice error controls the trigonometric factor by a Gaussian. -/
theorem phaseWave_le_exp_error (odd:Bool) (x:ℝ) :
    phaseWave odd x≤Real.exp (-(phaseError odd x)^2/2) := by
  rw [phaseWave_eq_cos_error]
  have habs : |Real.pi*phaseError odd x/2|≤Real.pi := by
    rw [abs_div,abs_mul,abs_of_pos Real.pi_pos,abs_of_pos (by norm_num : 0<(2:ℝ))]
    have hh:=phaseError_abs_le_one odd x
    nlinarith [Real.pi_pos]
  have hc:=Real.cos_le_one_sub_mul_cos_sq habs
  have he : 2/Real.pi^2*(Real.pi*phaseError odd x/2)^2=(phaseError odd x)^2/2 := by
    field_simp
  rw [he] at hc
  calc
    _ ≤ 1-(phaseError odd x)^2/2 := hc
    _ ≤ _ := by
      convert Real.add_one_le_exp (-(phaseError odd x)^2/2) using 1 <;> ring

lemma phaseWave_nonneg (odd:Bool) (x:ℝ) : 0≤phaseWave odd x := by
  cases odd <;> simp [phaseWave]

lemma prod_phaseWave_le_exp {ι:Type*} (s:Finset ι) (b:ι→Bool) (x:ι→ℝ) :
    ∏i∈s,phaseWave (b i) (x i) ≤
      Real.exp (-(∑i∈s,(phaseError (b i) (x i))^2)/2) := by
  calc
    _ ≤ ∏i∈s,Real.exp (-(phaseError (b i) (x i))^2/2) :=
      Finset.prod_le_prod (fun i _=>phaseWave_nonneg _ _) (fun i _=>phaseWave_le_exp_error _ _)
    _ = _ := by rw [←Real.exp_sum,←Finset.sum_div,Finset.sum_neg_distrib]

end NeuralGeneralization.OnlineLowerTanh
