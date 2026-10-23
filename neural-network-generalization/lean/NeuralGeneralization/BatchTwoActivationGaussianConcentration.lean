import NeuralGeneralization.BatchTwoActivationGaussianTransport

/-!
# Gaussian concentration from actual conditional-law transport

For a unit Euclidean Lipschitz observable vanishing on a set of Gaussian
probability at least one half, the squared tail is at most `2 exp(-s/4)`.
The proof uses two applications of the proved T2 coupling, and therefore
requires neither Gaussian isoperimetry nor an unbounded exponential tilt.
The constants are looser than the manuscript's optimized Gaussian lemma.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoActivation
open RobustPosterior

theorem gaussian_zeroSet_secondMoment_le_log_two {n : ℕ}
    (F : (Fin n→ℝ)→ℝ) (hF : Measurable F) (hLip : SquareLipschitz F)
    (A : Set (Fin n→ℝ)) (hA : MeasurableSet A)
    (hmass : (1/2:ℝ)≤(standardGaussian n).real A) (hzero : ∀x∈A, F x=0) :
    (∫⁻ x, ENNReal.ofReal ((F x)^2) ∂standardGaussian n)≤
      ENNReal.ofReal (2*Real.log 2) := by
  have hpos : 0<(standardGaussian n).real A := by linarith
  have hA0 : standardGaussian n A≠0 := by
    intro h
    simp only [Measure.real, h, ENNReal.toReal_zero] at hpos
    linarith
  have h := gaussian_secondMoment_le_of_zeroSet F hF hLip A hA hA0 hzero
  have hlog : -Real.log ((standardGaussian n).real A)≤Real.log 2 := by
    have ht := Real.log_le_log (by norm_num : (0:ℝ)<1/2) hmass
    rw [Real.log_div (by norm_num) (by norm_num), Real.log_one] at ht
    linarith
  calc
    _ ≤ 2*ENNReal.ofReal (-Real.log ((standardGaussian n).real A)) := h
    _ ≤ 2*ENNReal.ofReal (Real.log 2) := mul_le_mul' le_rfl (ENNReal.ofReal_le_ofReal hlog)
    _ = _ := by rw [ENNReal.ofReal_mul (by norm_num : (0:ℝ)≤2)]; norm_num

/-- The dimension-free squared-tail estimate needed for Gaussian bulk/tail
projection. This includes dimension zero and requires no smoothness of `F`. -/
theorem gaussian_zeroSet_square_tail {n : ℕ}
    (F : (Fin n→ℝ)→ℝ) (hF : Measurable F) (hLip : SquareLipschitz F)
    (A : Set (Fin n→ℝ)) (hA : MeasurableSet A)
    (hmass : (1/2:ℝ)≤(standardGaussian n).real A) (hzero : ∀x∈A, F x=0)
    (s : ℝ) :
    (standardGaussian n).real {x | s≤(F x)^2} ≤ 2*Real.exp (-s/4) := by
  classical
  let B : Set (Fin n→ℝ) := {x | s≤(F x)^2}
  have hB : MeasurableSet B := measurableSet_le measurable_const (hF.pow_const 2)
  by_cases hpz : (standardGaussian n).real B=0
  · change (standardGaussian n).real B≤_
    rw [hpz]
    positivity
  have hp : 0<(standardGaussian n).real B :=
    lt_of_le_of_ne measureReal_nonneg (Ne.symm hpz)
  have hB0 : standardGaussian n B≠0 := by
    intro h
    simp only [Measure.real, h, ENNReal.toReal_zero] at hp
    linarith
  let Q := cond (standardGaussian n) B
  letI : IsProbabilityMeasure Q := cond_isProbabilityMeasure hB0
  have hlow : ENNReal.ofReal s≤∫⁻ x, ENNReal.ofReal ((F x)^2) ∂Q := by
    calc
      _ = ∫⁻ _x, ENNReal.ofReal s ∂Q := by simp
      _ ≤ _ := by
        apply lintegral_mono_ae
        filter_upwards [ae_cond_mem (μ := standardGaussian n) hB] with x hx
        exact ENNReal.ofReal_le_ofReal hx
  have hbase := gaussian_zeroSet_secondMoment_le_log_two F hF hLip A hA hmass hzero
  have htran := gaussian_secondMoment_transport F hF hLip Q
  have hkl : klDiv Q (standardGaussian n)=
      ENNReal.ofReal (-Real.log ((standardGaussian n).real B)) :=
    klDiv_cond_eq (standardGaussian n) B hB hB0
  rw [hkl] at htran
  have htotal : ENNReal.ofReal s≤
      2*ENNReal.ofReal (2*Real.log 2)+4*ENNReal.ofReal (-Real.log ((standardGaussian n).real B)) :=
    hlow.trans (htran.trans (add_le_add (mul_le_mul' le_rfl hbase) le_rfl))
  have hlogtwo : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  have hp1 : (standardGaussian n).real B≤1 :=
    (measureReal_mono (Set.subset_univ B)).trans_eq probReal_univ
  have hlogp : 0≤-Real.log ((standardGaussian n).real B) :=
    neg_nonneg.mpr (Real.log_nonpos hp.le hp1)
  have hrhs : 2*ENNReal.ofReal (2*Real.log 2)+4*ENNReal.ofReal (-Real.log ((standardGaussian n).real B)) =
      ENNReal.ofReal (4*Real.log 2+4*(-Real.log ((standardGaussian n).real B))) := by
    rw [ENNReal.ofReal_add (by positivity) (by positivity),
      ENNReal.ofReal_mul (by norm_num : (0:ℝ)≤4),
      ENNReal.ofReal_mul (by norm_num : (0:ℝ)≤4),
      ENNReal.ofReal_mul (by norm_num : (0:ℝ)≤2)]
    norm_num
    ring
  rw [hrhs] at htotal
  have hreal := (ENNReal.ofReal_le_ofReal_iff (by positivity :
    0≤4*Real.log 2+4*(-Real.log ((standardGaussian n).real B)))).mp htotal
  have hlog : Real.log ((standardGaussian n).real B)≤Real.log 2+(-s/4) := by linarith
  have he := Real.exp_le_exp.mpr hlog
  rw [Real.exp_log hp, Real.exp_add, Real.exp_log (by norm_num : (0:ℝ)<2)] at he
  exact he

end NeuralGeneralization.BatchTwoActivation
