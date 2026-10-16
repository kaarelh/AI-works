import NeuralGeneralization.LocalizedCubeBump
import NeuralGeneralization.KernelPoissonOdd
import NeuralGeneralization.BinomialBetaIntegral

/-! # Exact averaged-bump spectrum and its uniform binomial estimate -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
variable {d : ℕ}

lemma walshCoefficients_intervalIntegral (F : ℝ → ClippingCube d → ℝ)
    (hF : ∀ x, Continuous (fun p => F p x)) (a b : ℝ) (S : Finset (Fin d)) :
    walshCoefficients (fun x => ∫ p in a..b, F p x) S =
      ∫ p in a..b, walshCoefficients (F p) S := by
  unfold walshCoefficients uniformCubeMean
  rw [intervalIntegral.integral_div]
  congr 1
  rw [intervalIntegral.integral_finsetSum
    (f:=fun x p => F p x*walshCharacter S x) (s:=Finset.univ)
    (fun x _ => ((hF x).mul continuous_const).intervalIntegrable _ _)]
  apply Finset.sum_congr rfl
  intro x hx
  rw [intervalIntegral.integral_mul_const]

/-- The averaged spatial bump has precisely the advertised degreewise
coefficients; Fourier and interval integration are actually interchanged. -/
theorem bump_walsh (z : ClippingCube d) (S : Finset (Fin d)) :
    walshCoefficients (bump z) S = coefficient d S.card*walshCharacter S z := by
  unfold bump
  rw [walshCoefficients_const_mul,
    walshCoefficients_intervalIntegral (fun p x => raw p z x) (fun x => continuous_raw z x)]
  simp_rw [raw_walsh]
  rw [intervalIntegral.integral_mul_const]
  unfold coefficient
  ring

lemma coefficient_nonneg (d j : ℕ) : 0 ≤ coefficient d j := by
  unfold coefficient
  apply mul_nonneg (by norm_num)
  apply intervalIntegral.integral_nonneg (by norm_num)
  intro p hp
  exact mul_nonneg (pow_nonneg (by linarith [hp.1]) _) (pow_nonneg (by linarith [hp.2]) _)

/-- The complete integer beta integral gives a uniform `1/d` level bound,
including the extreme levels. -/
theorem choose_mul_coefficient_le {d j : ℕ} (hj : j ≤ d) :
    (d.choose j : ℝ)*coefficient d j ≤ 200/(d+1:ℝ) := by
  have hi : (∫ p in (2/5:ℝ)..(81/200:ℝ), p^j*(1-p)^(d-j)) ≤
      ∫ p in (0:ℝ)..1, p^j*(1-p)^(d-j) := by
    apply intervalIntegral.integral_mono_interval (by norm_num) (by norm_num) (by norm_num)
    · apply ae_restrict_of_forall_mem measurableSet_Ioc
      intro p hp
      exact mul_nonneg (pow_nonneg hp.1.le _) (pow_nonneg (by linarith [hp.2]) _)
    · exact (by fun_prop : Continuous (fun p : ℝ => p^j*(1-p)^(d-j))).intervalIntegrable _ _
  have hh := mul_le_mul_of_nonneg_left hi
    (by positivity : 0 ≤ 200*(d.choose j : ℝ))
  have hb := binomial_beta_integral hj
  simp only [mul_assoc] at hh
  rw [hb] at hh
  unfold coefficient
  convert! hh using 1 <;> ring

/-- Each individual Fourier coefficient is exponentially small. -/
theorem coefficient_le_three_fifths {d j : ℕ} (hj : j ≤ d) :
    coefficient d j ≤ (3/5:ℝ)^d := by
  have hpoint (p : ℝ) (hp : p ∈ Set.Icc (2/5:ℝ) (81/200:ℝ)) :
      p^j*(1-p)^(d-j) ≤ (3/5:ℝ)^d := by
    have hp0 : 0 ≤ p := by linarith [hp.1]
    have hp1 : p ≤ 3/5 := by linarith [hp.2]
    have hq0 : 0 ≤ 1-p := by linarith [hp.2]
    have hq1 : 1-p ≤ 3/5 := by linarith [hp.1]
    calc
      _ ≤ (3/5:ℝ)^j*(3/5:ℝ)^(d-j) :=
        mul_le_mul (pow_le_pow_left₀ hp0 hp1 _) (pow_le_pow_left₀ hq0 hq1 _)
          (pow_nonneg hq0 _) (by positivity)
      _ = _ := by rw [← pow_add, Nat.add_sub_of_le hj]
  have hi := intervalIntegral.integral_mono_on (μ:=volume) (by norm_num : (2/5:ℝ) ≤ 81/200)
    ((by fun_prop : Continuous (fun p : ℝ => p^j*(1-p)^(d-j))).intervalIntegrable _ _)
    (continuous_const.intervalIntegrable _ _) hpoint
  rw [intervalIntegral.integral_const] at hi
  have hh := mul_le_mul_of_nonneg_left hi (by norm_num : (0:ℝ) ≤ 200)
  calc
    coefficient d j ≤ 200*((81/200-2/5:ℝ)*(3/5:ℝ)^d) := hh
    _ = _ := by ring

/-- The narrower averaging interval also gives a sharper high-degree bound. -/
theorem coefficient_le_endpoint_powers (d j : ℕ) :
    coefficient d j ≤ (81/200:ℝ)^j*(3/5:ℝ)^(d-j) := by
  have hpoint (p : ℝ) (hp : p ∈ Set.Icc (2/5:ℝ) (81/200:ℝ)) :
      p^j*(1-p)^(d-j) ≤ (81/200:ℝ)^j*(3/5:ℝ)^(d-j) := by
    have hp0 : 0 ≤ p := by linarith [hp.1]
    have hq0 : 0 ≤ 1-p := by linarith [hp.2]
    exact mul_le_mul (pow_le_pow_left₀ hp0 hp.2 _)
      (pow_le_pow_left₀ hq0 (by linarith [hp.1]) _) (pow_nonneg hq0 _) (by positivity)
  have hi := intervalIntegral.integral_mono_on (μ:=volume) (by norm_num : (2/5:ℝ) ≤ 81/200)
    ((by fun_prop : Continuous (fun p : ℝ => p^j*(1-p)^(d-j))).intervalIntegrable _ _)
    (continuous_const.intervalIntegrable _ _) hpoint
  rw [intervalIntegral.integral_const] at hi
  have hh := mul_le_mul_of_nonneg_left hi (by norm_num : (0:ℝ) ≤ 200)
  calc
    coefficient d j ≤ 200*((81/200-2/5:ℝ)*((81/200:ℝ)^j*(3/5:ℝ)^(d-j))) := hh
    _ = _ := by ring

end NeuralGeneralization.LocalizedCubeBump
