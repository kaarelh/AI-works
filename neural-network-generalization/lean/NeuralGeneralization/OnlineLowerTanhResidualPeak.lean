import NeuralGeneralization.OnlineLowerTanhResidualWindow
import NeuralGeneralization.OnlineLowerTanhCodeKernelGeneral

/-! # Exact odd-lattice phases in the residual saddle expansion -/
noncomputable section
open scoped BigOperators Topology
namespace NeuralGeneralization.OnlineLowerTanh

def residualPeak (A : ℝ) (l : ℕ) : ℝ := (2*(l : ℝ)+1)*periodicFrequency A

lemma residual_peak_sine {A : ℝ} (hA : A ≠ 0) (h l : ℕ) (d x : ℝ) :
    Real.sin ((A*(2*(h : ℝ)+1)+d)*(residualPeak A l+x)) =
      (-1:ℝ)^(h+l)*Real.cos (A*(2*(h : ℝ)+1)*x+d*(residualPeak A l+x)) := by
  have he : (A*(2*(h : ℝ)+1)+d)*(residualPeak A l+x) =
      (A*(2*(h : ℝ)+1)*x+d*(residualPeak A l+x))+Real.pi/2+
        ((h+l+2*h*l : ℕ):ℝ)*Real.pi := by
    unfold residualPeak periodicFrequency
    push_cast
    field_simp
    <;> ring
  rw [he, Real.sin_add_nat_mul_pi, Real.sin_add_pi_div_two, pow_add]
  have hp : (-1:ℝ)^(2*h*l) = 1 := by rw [pow_mul, pow_mul]; norm_num
  rw [hp,mul_one]

/-- All peak signs are exact; the residual does not enter their value. -/
theorem residual_peak_product {n : ℕ} {A : ℝ} (hA : A ≠ 0)
    (h : Fin n → ℕ) (d : Fin n → ℝ) (l : ℕ) (x : ℝ) :
    (∏ i, Real.sin ((A*(2*(h i : ℝ)+1)+d i)*(residualPeak A l+x))) =
      (-1:ℝ)^((∑ i, h i)+n*l)*
        ∏ i, Real.cos (A*(2*(h i : ℝ)+1)*x+d i*(residualPeak A l+x)) := by
  simp_rw [residual_peak_sine hA]
  rw [Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum]
  simp only [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  norm_cast

lemma residual_peak_pos {A : ℝ} (hA : 0 < A) (l : ℕ) : 0 < residualPeak A l := by
  unfold residualPeak
  exact mul_pos (by positivity) (periodicFrequency_pos hA)

lemma odd_nat_double_half {q : ℕ} (hq : Odd q) : 2*((q-1)/2)+1 = q := by
  rcases hq with ⟨h,hh⟩
  omega

lemma residual_peak_product_odd {n : ℕ} {A : ℝ} (hA : A ≠ 0)
    (q : Fin n → ℕ) (hq : ∀ i, Odd (q i)) (d : Fin n → ℝ) (l : ℕ) (x : ℝ) :
    (∏ i, Real.sin ((A*(q i:ℝ)+d i)*(residualPeak A l+x))) =
      (-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*
        ∏ i, Real.cos (A*(q i:ℝ)*x+d i*(residualPeak A l+x)) := by
  have hp := residual_peak_product hA (fun i => (q i-1)/2) d l x
  have he (i : Fin n) : 2*((((q i-1)/2):ℕ):ℝ)+1 = (q i:ℝ) := by
    exact_mod_cast odd_nat_double_half (hq i)
  simpa only [he] using hp

lemma residual_peak_product_abs {n : ℕ} {A : ℝ} (hA : A ≠ 0)
    (q : Fin n → ℕ) (hq : ∀ i, Odd (q i)) (d : Fin n → ℝ) (l : ℕ) (x : ℝ) :
    |∏ i, Real.sin ((A*(q i:ℝ)+d i)*(residualPeak A l+x))| =
      |∏ i, Real.cos (A*(q i:ℝ)*x+d i*(residualPeak A l+x))| := by
  have hp := congrArg abs (residual_peak_product hA (fun i => (q i-1)/2) d l x)
  have he (i : Fin n) : 2*((((q i-1)/2):ℕ):ℝ)+1 = (q i:ℝ) := by
    exact_mod_cast odd_nat_double_half (hq i)
  simp_rw [he] at hp
  simpa only [abs_mul,abs_neg_one_pow,one_mul] using hp

end NeuralGeneralization.OnlineLowerTanh
