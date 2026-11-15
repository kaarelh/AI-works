import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringError
import NeuralGeneralization.OnlineLowerTanhRestoringCertificate

/-! Literal restoring-curvature inequality on the paper's gain interval.

The finite rational Bernstein certificate and the strict analytic truncation
bound certify the actual Fourier response, with explicit positive parameters.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma restoringMu_pos : 0<restoringMu := by norm_num [restoringMu]

lemma restoringMu_lt_three_quarters : restoringMu<(3:ℝ)/4 := by norm_num [restoringMu]

lemma restoringSeries_pos {q x : ℝ} (hqlo : (1:ℝ)/256≤q) (hqhi : q≤17/200)
    (hx : x∈Set.Icc (-1:ℝ) 1) : 0<restoringSeries q x := by
  have hq0 : 0≤q := by linarith
  have hp := restoringPolynomial_gt_margin hqlo hqhi hx.1 hx.2
  have he := (abs_lt.mp (restoringSeries_polynomial_error hq0 hqhi hx)).1
  linarith

lemma periodicRestoringAmplitude_pos {a : ℝ} (ha : 0<a) :
    0<periodicFrequency a^2*restoringAmplitude (periodicRatio a) :=
  mul_pos (sq_pos_of_pos (periodicFrequency_pos ha))
    (restoringAmplitude_pos (periodicRatio_mem ha).1.le)

/-- The paper's restoring-curvature bound, with strict certified slack. -/
theorem periodic_restoring_pointwise_eighty_strict {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2)
    (b : ℝ) :
    periodicFourierSecond a b <
      (periodicFrequency a^2*restoringAmplitude (periodicRatio a))*
        (restoringMu/2*periodicFourierMaximum a-
          (1-restoringMu/2)*periodicFourierResponse a b) := by
  have ha : 0<a := by linarith
  have hq := periodicRatio_mem_restoring_interval ha1 ha2
  have hx : Real.cos (periodicFrequency a*(b-a))∈Set.Icc (-1:ℝ) 1 :=
    ⟨Real.neg_one_le_cos _,Real.cos_le_one _⟩
  have hG := restoringSeries_pos hq.1 hq.2 hx
  have hpos := mul_pos
    (mul_pos (sq_pos_of_pos (periodicFrequency_pos ha)) (periodicCoefficient_pos ha 0)) hG
  rw [restoringSeries_curvature_identity ha] at hpos
  rw [show a+(b-a)=b by ring] at hpos
  nlinarith

/-- Pointwise form used to integrate against arbitrary probability measures. -/
theorem periodic_restoring_pointwise_eighty {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2)
    (b : ℝ) :
    periodicFourierSecond a b ≤
      (periodicFrequency a^2*restoringAmplitude (periodicRatio a))*
        (restoringMu/2*periodicFourierMaximum a-
          (1-restoringMu/2)*periodicFourierResponse a b) :=
  (periodic_restoring_pointwise_eighty_strict ha1 ha2 b).le

/-- Literal existential pointwise assertion of Lemma 22. The shifted response
is `U z = periodicFourierResponse a (a+z)`. -/
theorem periodic_restoring_parameters {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2) :
    ∃ A μ : ℝ, 0<A ∧ 0<μ ∧ μ<3/4 ∧ ∀ z : ℝ,
      periodicFourierSecond a (a+z) ≤
        -A*(1-μ)*periodicFourierMaximum a+
          A*(1-μ/2)*(periodicFourierMaximum a-periodicFourierResponse a (a+z)) := by
  refine ⟨periodicFrequency a^2*restoringAmplitude (periodicRatio a),restoringMu,
    periodicRestoringAmplitude_pos (by linarith),restoringMu_pos,
    restoringMu_lt_three_quarters,?_⟩
  intro z
  have h := periodic_restoring_pointwise_eighty ha1 ha2 (a+z)
  nlinarith

/-- The same assertion with ordinary second derivatives of the paired tanh
    periodization, rather than the auxiliary Fourier curvature notation. -/
theorem pairedPeriodic_restoring_parameters {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2) :
    ∃ A μ : ℝ, 0<A ∧ 0<μ ∧ μ<3/4 ∧ ∀ z : ℝ,
      deriv (deriv (fun y : ℝ => pairedPeriodicResponse a (a+y))) z ≤
        -A*(1-μ)*pairedPeriodicResponse a a+
          A*(1-μ/2)*(pairedPeriodicResponse a a-pairedPeriodicResponse a (a+z)) := by
  have ha : 0<a := by linarith
  obtain ⟨A,μ,hA,hμ,hμ3,hpoint⟩ := periodic_restoring_parameters ha1 ha2
  refine ⟨A,μ,hA,hμ,hμ3,?_⟩
  intro z
  rw [pairedPeriodicResponse_centered_second_deriv ha,
    ←periodicFourierResponse_eq_paired ha,←periodicFourierResponse_eq_paired ha]
  exact hpoint z

end NeuralGeneralization.OnlineLowerTanh
