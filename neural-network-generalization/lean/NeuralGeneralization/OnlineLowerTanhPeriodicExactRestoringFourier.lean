import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringCoefficients
import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringPolynomial

/-! Exact normalized Chebyshev representation of the restoring curvature. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

/-- The Fourier coefficient divided by its first coefficient. -/
def restoringExactRatio (q : ℝ) (j : ℕ) : ℝ :=
  q^j*(1-q)/(1-q^(2*j+1))

/-- The common multiplier used for both exact and finite coefficient sums. -/
def restoringWeight (q x : ℝ) (j : ℕ) : ℝ :=
  (-1:ℝ)^j * (restoringAmplitude q*restoringMu/2 +
    (((2*j+1:ℕ):ℝ)^2-restoringAmplitude q*(1-restoringMu/2))*
      (Polynomial.Chebyshev.T ℝ (2*j+1)).eval x)

def restoringSeries (q x : ℝ) : ℝ :=
  ∑' j : ℕ, restoringExactRatio q j*restoringWeight q x j

lemma restoringExactRatio_zero {q : ℝ} (hq : q<1) : restoringExactRatio q 0=1 := by
  simp [restoringExactRatio, ne_of_gt (sub_pos.mpr hq)]

lemma restoringExactRatio_nonneg {q : ℝ} (hq0 : 0≤q) (hq1 : q<1) (j : ℕ) :
    0≤restoringExactRatio q j := by
  unfold restoringExactRatio
  apply div_nonneg (mul_nonneg (pow_nonneg hq0 _) (by linarith))
  have := pow_le_one₀ hq0 hq1.le (n:=2*j+1)
  linarith

lemma restoringExactRatio_le_pow {q : ℝ} (hq0 : 0≤q) (hq1 : q<1) (j : ℕ) :
    restoringExactRatio q j≤q^j := by
  have hd : 0<1-q^(2*j+1) := by
    have := pow_lt_one₀ hq0 hq1 (by omega : 2*j+1≠0)
    linarith
  have hp : q^(2*j+1)≤q := by
    calc
      q^(2*j+1)=q^(2*j)*q := by rw [pow_succ]
      _≤1*q := mul_le_mul_of_nonneg_right (pow_le_one₀ hq0 hq1.le) hq0
      _=q := one_mul _
  apply (div_le_iff₀ hd).mpr
  nlinarith [pow_nonneg hq0 j]

lemma restoringChebyshev_abs_le {x : ℝ} (hx : x∈Set.Icc (-1:ℝ) 1) (j : ℕ) :
    |(Polynomial.Chebyshev.T ℝ (2*j+1)).eval x|≤1 := by
  rw [←Real.cos_arccos hx.1 hx.2, Polynomial.Chebyshev.T_real_cos]
  exact Real.abs_cos_le_one _

lemma restoringChebyshev_cos (θ : ℝ) (j : ℕ) :
    (Polynomial.Chebyshev.T ℝ (2*j+1)).eval (Real.cos θ)=
      Real.cos ((2*(j:ℝ)+1)*θ) := by
  rw [Polynomial.Chebyshev.T_real_cos]
  congr 1
  push_cast
  rfl

lemma periodicCoefficient_eq_restoringExactRatio {a : ℝ} (ha : 0<a) (j : ℕ) :
    periodicCoefficient a j = periodicCoefficient a 0*restoringExactRatio (periodicRatio a) j :=
  periodicCoefficient_relative_exact ha j

lemma restoringExactRatio_summable {q : ℝ} (hq0 : 0≤q) (hq1 : q<1) :
    Summable (restoringExactRatio q) := by
  apply (summable_geometric_of_abs_lt_one (by rwa [abs_of_nonneg hq0])).of_nonneg_of_le
    (restoringExactRatio_nonneg hq0 hq1)
  exact restoringExactRatio_le_pow hq0 hq1

lemma restoringExactRatio_square_summable {q : ℝ} (hq0 : 0≤q) (hq1 : q<1) :
    Summable (fun j : ℕ => restoringExactRatio q j*((2*j+1:ℕ):ℝ)^2) := by
  have hq : |q|<1 := by rwa [abs_of_nonneg hq0]
  have h0 := summable_geometric_of_abs_lt_one hq
  have h1 := summable_pow_mul_geometric_of_norm_lt_one 1 (r:=q) hq
  have h2 := summable_pow_mul_geometric_of_norm_lt_one 2 (r:=q) hq
  have hs : Summable (fun j : ℕ => q^j*((2*j+1:ℕ):ℝ)^2) := by
    apply (((h2.mul_left 4).add (h1.mul_left 4)).add h0).congr
    intro j
    push_cast
    ring
  apply hs.of_nonneg_of_le
    (fun j => mul_nonneg (restoringExactRatio_nonneg hq0 hq1 j) (sq_nonneg _))
  intro j
  exact mul_le_mul_of_nonneg_right (restoringExactRatio_le_pow hq0 hq1 j) (sq_nonneg _)

lemma restoringSeries_summable {q x : ℝ} (hq0 : 0≤q) (hq1 : q<1)
    (hx : x∈Set.Icc (-1:ℝ) 1) :
    Summable (fun j : ℕ => restoringExactRatio q j*restoringWeight q x j) := by
  let C := |restoringAmplitude q*restoringMu/2|+|restoringAmplitude q*(1-restoringMu/2)|
  have hs := (restoringExactRatio_square_summable hq0 hq1).add
    ((restoringExactRatio_summable hq0 hq1).mul_right C)
  apply hs.of_norm_bounded
  intro j
  rw [Real.norm_eq_abs,abs_mul,abs_of_nonneg (restoringExactRatio_nonneg hq0 hq1 j)]
  have hb : |restoringWeight q x j|≤((2*j+1:ℕ):ℝ)^2+C := by
    unfold restoringWeight
    rw [abs_mul,abs_neg_one_pow,one_mul]
    calc
      _≤|restoringAmplitude q*restoringMu/2|+
          |(((2*j+1:ℕ):ℝ)^2-restoringAmplitude q*(1-restoringMu/2))*
            (Polynomial.Chebyshev.T ℝ (2*j+1)).eval x| := abs_add_le _ _
      _≤|restoringAmplitude q*restoringMu/2|+
          |((2*j+1:ℕ):ℝ)^2-restoringAmplitude q*(1-restoringMu/2)| := by
        rw [abs_mul]
        exact add_le_add le_rfl (mul_le_of_le_one_right (abs_nonneg _) (restoringChebyshev_abs_le hx j))
      _≤_ := by
        have h := abs_sub (((2*j+1:ℕ):ℝ)^2) (restoringAmplitude q*(1-restoringMu/2))
        simp only [abs_sq] at h
        dsimp [C]
        linarith
  have h := mul_le_mul_of_nonneg_left hb (restoringExactRatio_nonneg hq0 hq1 j)
  nlinarith

lemma restoringPolynomial_eq_sum (q x : ℝ) :
    restoringPolynomial q x=∑j∈Finset.range 6,restoringRatioPolynomial q j*restoringWeight q x j := by
  unfold restoringPolynomial restoringWeight
  rw [Finset.mul_sum,←Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

lemma restoringAmplitude_pos {q : ℝ} (hq0 : 0≤q) : 0<restoringAmplitude q := by
  unfold restoringAmplitude
  positivity

lemma restoringAmplitude_lt_two {q : ℝ} (hq0 : 0≤q) (hq : q≤17/200) :
    restoringAmplitude q<2 := by
  have h4 := pow_le_pow_left₀ hq0 hq 4
  have hbase : 1+2*q+2*q^4≤1+2*(17/200:ℝ)+2*(17/200:ℝ)^4 := by linarith
  have hp := pow_le_pow_left₀ (by positivity : 0≤1+2*q+2*q^4) hbase 4
  exact hp.trans_lt (by norm_num)

lemma restoringWeight_bound {q x : ℝ} (hq0 : 0≤q) (hq : q≤17/200)
    (hx : x∈Set.Icc (-1:ℝ) 1) {j : ℕ} (hj : 1≤j) :
    |restoringWeight q x j|≤((2*j+1:ℕ):ℝ)^2+2 := by
  have hA0 := (restoringAmplitude_pos hq0).le
  have hA2 := (restoringAmplitude_lt_two hq0 hq).le
  have hn : (3:ℝ)≤((2*j+1:ℕ):ℝ) := by exact_mod_cast (by omega : 3≤2*j+1)
  have hmu : 0≤restoringMu ∧ restoringMu≤1 := by norm_num [restoringMu]
  have ha : 0≤restoringAmplitude q*restoringMu/2 := div_nonneg (mul_nonneg hA0 hmu.1) (by norm_num)
  have hb : 0≤restoringAmplitude q*(1-restoringMu/2) := mul_nonneg hA0 (by linarith)
  have hb2 : restoringAmplitude q*(1-restoringMu/2)≤2 := by nlinarith
  have hc : 0≤((2*j+1:ℕ):ℝ)^2-restoringAmplitude q*(1-restoringMu/2) := by nlinarith
  unfold restoringWeight
  rw [abs_mul,abs_neg_one_pow,one_mul]
  calc
    _≤|restoringAmplitude q*restoringMu/2|+
      |(((2*j+1:ℕ):ℝ)^2-restoringAmplitude q*(1-restoringMu/2))*
        (Polynomial.Chebyshev.T ℝ (2*j+1)).eval x| := abs_add_le _ _
    _≤restoringAmplitude q*restoringMu/2+
      (((2*j+1:ℕ):ℝ)^2-restoringAmplitude q*(1-restoringMu/2)) := by
      rw [abs_of_nonneg ha,abs_mul,abs_of_nonneg hc]
      exact add_le_add le_rfl (mul_le_of_le_one_right hc (restoringChebyshev_abs_le hx j))
    _≤_ := by nlinarith

/-- The full normalized series is exactly the pointwise curvature deficit of
    the actual periodic tanh response. -/
lemma restoringSeries_curvature_identity {a : ℝ} (ha : 0<a) (z : ℝ) :
    periodicFrequency a^2*periodicCoefficient a 0*
        restoringSeries (periodicRatio a) (Real.cos (periodicFrequency a*z)) =
      (periodicFrequency a^2*restoringAmplitude (periodicRatio a))*restoringMu/2*
        periodicFourierMaximum a -
      (periodicFrequency a^2*restoringAmplitude (periodicRatio a))*(1-restoringMu/2)*
        periodicFourierResponse a (a+z) - periodicFourierSecond a (a+z) := by
  have hq := periodicRatio_mem ha
  have hx : Real.cos (periodicFrequency a*z)∈Set.Icc (-1:ℝ) 1 :=
    ⟨Real.neg_one_le_cos _,Real.cos_le_one _⟩
  have hs := restoringSeries_summable hq.1.le hq.2 hx
  have hF := periodicCenteredTerm_summable ha 0
  have hU := periodicCenteredTerm_summable ha z
  have hS := periodic_second_summable ha (a+z)
  have hmax : periodicFourierMaximum a=∑'j,periodicCenteredTerm a 0 j := by
    simpa only [add_zero,periodicFourierMaximum] using periodicFourierResponse_centered ha 0
  rw [restoringSeries,←hs.tsum_mul_left,hmax,periodicFourierResponse_centered ha,
    periodicFourierSecond,←hF.tsum_mul_left,←hU.tsum_mul_left,
    ←(hF.mul_left _).tsum_sub (hU.mul_left _),
    ←((hF.mul_left _).sub (hU.mul_left _)).tsum_sub hS]
  apply tsum_congr
  intro j
  rw [periodic_shifted_sine ha.ne']
  simp only [restoringWeight,restoringChebyshev_cos,periodicCenteredTerm,mul_zero,
    Real.cos_zero,mul_one]
  rw [periodicCoefficient_eq_restoringExactRatio ha j]
  push_cast
  ring

lemma periodicFourierSecond_abs_bound {a : ℝ} (ha : 0<a) (b : ℝ) :
    |periodicFourierSecond a b|≤periodicFrequency a^2*
      (∑'j : ℕ, periodicCoefficient a j*(2*(j:ℝ)+1)^2) := by
  let f := fun j : ℕ => -(periodicCoefficient a j*((2*(j:ℝ)+1)*periodicFrequency a)^2)*
    Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b)
  let g := fun j : ℕ => periodicFrequency a^2*(periodicCoefficient a j*(2*(j:ℝ)+1)^2)
  have hf : Summable f := periodic_second_summable ha b
  have hg : Summable g := (periodicCoefficient_square_summable ha).mul_left _
  have hpoint (j : ℕ) : |f j|≤g j := by
    dsimp [f,g]
    rw [abs_mul,abs_neg,abs_of_nonneg (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg _))]
    have h := mul_le_mul_of_nonneg_left (Real.abs_sin_le_one ((2*(j:ℝ)+1)*periodicFrequency a*b))
      (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg ((2*(j:ℝ)+1)*periodicFrequency a)))
    nlinarith
  have hsum : |∑'j,f j|≤∑'j,g j := by
    apply abs_le.mpr
    constructor
    · rw [←tsum_neg]
      exact Summable.tsum_le_tsum (fun j => (abs_le.mp (hpoint j)).1) hg.neg hf
    · exact Summable.tsum_le_tsum (fun j => (abs_le.mp (hpoint j)).2) hf hg
  simpa only [f,g,periodicFourierSecond,(periodicCoefficient_square_summable ha).tsum_mul_left] using hsum

lemma periodicCenteredResponse_deriv {a : ℝ} (ha : 0<a) (z : ℝ) :
    deriv (fun y : ℝ => periodicFourierResponse a (a+y)) z =
      periodicFourierDerivative a (a+z) := by
  have h := (periodicFourierResponse_hasDerivAt ha (a+z)).comp z
    ((hasDerivAt_id z).const_add a)
  simpa only [Function.comp_def,mul_one] using h.deriv

/-- The Fourier curvature is literally the ordinary second derivative of the
    shifted actual periodic response used in the paper. -/
lemma periodicCenteredResponse_second_deriv {a : ℝ} (ha : 0<a) (z : ℝ) :
    deriv (deriv (fun y : ℝ => periodicFourierResponse a (a+y))) z =
      periodicFourierSecond a (a+z) := by
  have hd : deriv (fun y : ℝ => periodicFourierResponse a (a+y)) =
      fun y => periodicFourierDerivative a (a+y) :=
    funext (periodicCenteredResponse_deriv ha)
  rw [hd]
  have h := (periodicFourierDerivative_hasDerivAt ha (a+z)).comp z
    ((hasDerivAt_id z).const_add a)
  simpa only [Function.comp_def,mul_one] using h.deriv

lemma pairedPeriodicResponse_centered_second_deriv {a : ℝ} (ha : 0<a) (z : ℝ) :
    deriv (deriv (fun y : ℝ => pairedPeriodicResponse a (a+y))) z =
      periodicFourierSecond a (a+z) := by
  have he : (fun y : ℝ => pairedPeriodicResponse a (a+y))=
      fun y => periodicFourierResponse a (a+y) := by
    funext y
    exact (periodicFourierResponse_eq_paired ha (a+y)).symm
  rw [he]
  exact periodicCenteredResponse_second_deriv ha z

lemma periodicFourierSecond_continuous {a : ℝ} (ha : 0<a) :
    Continuous (periodicFourierSecond a) := by
  unfold periodicFourierSecond
  apply continuous_tsum (u:=fun j : ℕ =>
    periodicCoefficient a j*(2*(j:ℝ)+1)^2*periodicFrequency a^2)
    (fun j => by fun_prop)
    ((periodicCoefficient_square_summable ha).mul_right (periodicFrequency a^2))
  intro j b
  rw [Real.norm_eq_abs,abs_mul,abs_neg,
    abs_of_nonneg (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg _))]
  have h := mul_le_mul_of_nonneg_left (Real.abs_sin_le_one ((2*(j:ℝ)+1)*periodicFrequency a*b))
    (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg ((2*(j:ℝ)+1)*periodicFrequency a)))
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
