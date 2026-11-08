import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Cotangent
import Mathlib.Tactic

/-! Exact scalar integral identities for the ordinary tanh activation. -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Complex
namespace NeuralGeneralization.OnlineLowerTanh

lemma laplace_sine (c a : ℝ) (hc : 0 < c) :
    (∫ t : ℝ in Set.Ioi 0, Real.exp (-c*t)*Real.sin (a*t)) = a/(c^2+a^2) := by
  let z : ℂ := - (c:ℂ) + (a:ℂ)*I
  have hz : z.re < 0 := by simp [z]; linarith
  have hi := congrArg Complex.im (integral_exp_mul_complex_Ioi hz 0)
  have hswap := integral_im (integrableOn_exp_mul_complex_Ioi hz 0)
  simp only [RCLike.im_to_complex] at hswap
  rw [←hswap] at hi
  simpa [z, Complex.exp_im, Complex.mul_re, Complex.mul_im, Complex.div_im,
    Complex.normSq_apply, pow_two, neg_div, neg_neg] using hi

lemma cot_half_imag (y : ℝ) :
    Complex.cot ((Real.pi:ℂ)*((1/2:ℂ)+(y:ℂ)*I)) =
      -(Real.tanh (Real.pi*y):ℂ)*I := by
  have harg : (Real.pi:ℂ)*((1/2:ℂ)+(y:ℂ)*I) =
      (Real.pi/2:ℂ) + ((Real.pi*y:ℝ):ℂ)*I := by push_cast; ring
  rw [harg, Complex.cot, Complex.cos_add, Complex.sin_add,
    Complex.cos_mul_I, Complex.sin_mul_I]
  simp only [Complex.cos_pi_div_two, Complex.sin_pi_div_two,
    zero_mul, one_mul, zero_add, sub_zero, add_zero, zero_sub]
  rw [←Complex.ofReal_cosh, ←Complex.ofReal_sinh,
    Real.tanh_eq_sinh_div_cosh]
  push_cast
  ring


def halfTerm (y : ℝ) (n : ℕ) : ℝ := y / (((n:ℝ)+1/2)^2+y^2)

lemma halfTerm_nonneg {y : ℝ} (hy : 0 ≤ y) (n : ℕ) : 0 ≤ halfTerm y n := by
  unfold halfTerm
  positivity

lemma halfTerm_tendsto_zero (y : ℝ) : Tendsto (halfTerm y) atTop (𝓝 0) := by
  have hn : Tendsto (fun n:ℕ => (n:ℝ)+(1/2:ℝ)) atTop atTop :=
    tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop
  have hd : Tendsto (fun n:ℕ => ((n:ℝ)+(1/2:ℝ))^2+y^2) atTop atTop :=
    tendsto_atTop_add_const_right _ _ ((tendsto_pow_atTop (by norm_num)).comp hn)
  exact tendsto_const_nhds.div_atTop hd

lemma halfTerm_cot (y : ℝ) (n : ℕ) :
    (cotTerm ((1/2:ℂ)+(y:ℂ)*I) n).im = -halfTerm y n - halfTerm y (n+1) := by
  simp [cotTerm, halfTerm, Complex.div_im, Complex.normSq_apply,
    Complex.mul_im, Complex.mul_re]
  congr 1 <;> congr 1 <;> ring

lemma halfTerm_cot_range (y : ℝ) (n : ℕ) :
    (∑ i ∈ Finset.range n, cotTerm ((1/2:ℂ)+(y:ℂ)*I) i).im =
      -2*(∑ i ∈ Finset.range n, halfTerm y i)+halfTerm y 0-halfTerm y n := by
  rw [Complex.im_sum]
  simp_rw [halfTerm_cot]
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ,Finset.sum_range_succ,ih]
    ring

lemma halfTerm_hasSum (y : ℝ) (hy : 0 < y) :
    HasSum (halfTerm y) (Real.pi * Real.tanh (Real.pi*y) / 2) := by
  have hz : (1/2:ℂ)+(y:ℂ)*I ∈ Complex.integerComplement := by
    rw [Complex.mem_integerComplement_iff]
    rintro ⟨n,hn⟩
    have hh:=congrArg Complex.im hn
    simp at hh
    linarith
  have hh := Complex.continuous_im.tendsto _ |>.comp (tendsto_logDeriv_euler_cot_sub hz)
  simp only [Function.comp_def] at hh
  simp_rw [halfTerm_cot_range] at hh
  have htarget :
      ((Real.pi:ℂ)*Complex.cot ((Real.pi:ℂ)*((1/2:ℂ)+(y:ℂ)*I)) -
        1/((1/2:ℂ)+(y:ℂ)*I)).im =
          -Real.pi*Real.tanh (Real.pi*y) + halfTerm y 0 := by
    rw [cot_half_imag]
    simp only [Complex.sub_im, Complex.mul_im, Complex.mul_re,
      Complex.ofReal_re, Complex.ofReal_im, Complex.neg_re, Complex.neg_im,
      Complex.I_re, Complex.I_im, Complex.div_im, Complex.normSq_apply,
      Complex.add_re, Complex.add_im, Complex.one_re, Complex.one_im,
      Complex.div_ofNat_re, Complex.div_ofNat_im]
    norm_num [halfTerm]
    ring
  rw [htarget] at hh
  have h := ((hh.add (halfTerm_tendsto_zero y)).sub_const (halfTerm y 0)).div_const (-2)
  have he : (fun n => (-2 * (∑ i ∈ Finset.range n, halfTerm y i) +
      halfTerm y 0 - halfTerm y n + halfTerm y n - halfTerm y 0) / (-2:ℝ)) =
      (fun n => ∑ i ∈ Finset.range n, halfTerm y i) := by funext n; ring
  rw [he] at h
  have ht : (-Real.pi*Real.tanh (Real.pi*y)+halfTerm y 0+0-halfTerm y 0)/(-2:ℝ) =
      Real.pi*Real.tanh (Real.pi*y)/2 := by ring
  rw [ht] at h
  exact (hasSum_iff_tendsto_nat_of_nonneg (fun n=>halfTerm_nonneg hy.le n) _).mpr h


lemma tanh_partial_fraction_pos (a : ℝ) (ha : 0 < a) :
    HasSum (fun n:ℕ => 2*a/((((n:ℝ)+1/2)*Real.pi)^2+a^2)) (Real.tanh a) := by
  have hp := Real.pi_pos
  have hh := (halfTerm_hasSum (a/Real.pi) (div_pos ha hp)).mul_left (2/Real.pi)
  convert! hh using 1
  · funext n
    unfold halfTerm
    field_simp
  · rw [mul_div_cancel₀ _ Real.pi_ne_zero]
    field_simp

lemma tanh_partial_fraction (a : ℝ) :
    HasSum (fun n:ℕ => 2*a/((((n:ℝ)+1/2)*Real.pi)^2+a^2)) (Real.tanh a) := by
  rcases lt_trichotomy 0 a with ha|ha|ha
  · exact tanh_partial_fraction_pos a ha
  · subst a; simpa using (hasSum_zero : HasSum (fun _:ℕ => (0:ℝ)) 0)
  · have h := (tanh_partial_fraction_pos (-a) (neg_pos.mpr ha)).neg
    simpa [neg_sq, neg_div] using h

end NeuralGeneralization.OnlineLowerTanh
