import NeuralGeneralization.BatchTwoShallowHalfspaces
import NeuralGeneralization.BatchTwoImprovedQuantile
import Mathlib.Analysis.SpecialFunctions.Artanh
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Measure.Real

/-! An actual probability representation of a tanh ridge as affine halfspaces.
The only random seed is uniform on `(0,1)`; no mixture representation is assumed. -/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set

namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel BatchTwoImprovedQuantile

def ridgePattern {d : ℕ} (b : Fin (d + 1) → ℝ) (u : ℝ) : BooleanFunction d :=
  fun x => decide (u < (1 + Real.tanh (dot b (inputVector x))) / 2)

def patternSet {d : ℕ} (H : BooleanFunction d) : Finset (Cube d) :=
  Finset.univ.filter (fun x => H x = true)

theorem measurable_ridgePattern {d : ℕ} (b : Fin (d + 1) → ℝ) :
    Measurable (ridgePattern b) := by
  apply measurable_pi_lambda
  intro x
  have he : (fun u => ridgePattern b u x) =
      (fun u : ℝ => if u < (1 + Real.tanh (dot b (inputVector x))) / 2 then true else false) := by
    funext u
    simp only [ridgePattern, Bool.decide_eq_true]
    split_ifs <;> simp_all
  rw [he]
  exact Measurable.ite (measurableSet_lt measurable_id measurable_const)
    measurable_const measurable_const

theorem dot_input_shift {d : ℕ} (b : Fin (d + 1) → ℝ) (t : ℝ) (x : Cube d) :
    dot (Fin.cases (b 0 - t) (fun i => b i.succ)) (inputVector x) =
      dot b (inputVector x) - t := by
  simp only [dot, Fin.sum_univ_succ, inputVector, Fin.cases_zero, Fin.cases_succ, mul_one]
  ring

theorem ridgePattern_is_halfspace {d : ℕ} (b : Fin (d + 1) → ℝ)
    {u : ℝ} (hu : u ∈ Ioo 0 1) :
    patternSet (ridgePattern b u) ∈ halfspacePatterns (inputVector (d := d)) := by
  classical
  let t := Real.artanh (2 * u - 1)
  refine Finset.mem_filter.mpr ⟨Finset.mem_univ _,
    Fin.cases (b 0 - t) (fun i => b i.succ), ?_⟩
  intro x
  have hu' : 2 * u - 1 ∈ Ioo (-1 : ℝ) 1 := by constructor <;> linarith [hu.1, hu.2]
  have hx : Real.tanh (dot b (inputVector x)) ∈ Ioo (-1 : ℝ) 1 :=
    ⟨Real.neg_one_lt_tanh _, Real.tanh_lt_one _⟩
  have ht := Real.artanh_lt_artanh_iff hu' hx
  rw [Real.artanh_tanh] at ht
  simp only [patternSet, Finset.mem_filter, Finset.mem_univ, true_and,
    ridgePattern, decide_eq_true_eq]
  rw [dot_input_shift]
  dsimp only [t]
  constructor
  · intro h
    have h' : 2 * u - 1 < Real.tanh (dot b (inputVector x)) := by linarith
    have := ht.mpr h'
    linarith
  · intro h
    have h' : Real.artanh (2 * u - 1) < dot b (inputVector x) := by linarith
    have := ht.mp h'
    linarith

theorem uniformSeed_Iio {q : ℝ} (hq0 : 0 ≤ q) (hq1 : q ≤ 1) :
    uniformSeed.real (Iio q) = q := by
  have hset : Iio q ∩ Ioo (0 : ℝ) 1 = Ioo 0 q := by
    ext u
    simp only [mem_inter_iff, mem_Iio, mem_Ioo]
    constructor
    · rintro ⟨h, h0, _⟩
      exact ⟨h0, h⟩
    · rintro ⟨h0, hq⟩
      exact ⟨hq, h0, hq.trans_le hq1⟩
  rw [Measure.real, uniformSeed, Measure.restrict_apply measurableSet_Iio,
    hset, Real.volume_Ioo, sub_zero, ENNReal.toReal_ofReal hq0]

theorem ridgePattern_positive_probability {d : ℕ} (b : Fin (d + 1) → ℝ)
    (x : Cube d) :
    uniformSeed.real {u | ridgePattern b u x = true} =
      (1 + Real.tanh (dot b (inputVector x))) / 2 := by
  have h0 : 0 ≤ (1 + Real.tanh (dot b (inputVector x))) / 2 := by
    linarith [Real.neg_one_lt_tanh (dot b (inputVector x))]
  have h1 : (1 + Real.tanh (dot b (inputVector x))) / 2 ≤ 1 := by
    linarith [Real.tanh_lt_one (dot b (inputVector x))]
  convert uniformSeed_Iio h0 h1 using 1
  congr 1
  ext u
  simp [ridgePattern]

/-- The exact mean label of the explicitly sampled halfspace equals the tanh
ridge output. -/
theorem ridgePattern_mean {d : ℕ} (b : Fin (d + 1) → ℝ) (x : Cube d) :
    (∫ u, labelReal (ridgePattern b u x) ∂uniformSeed) =
      Real.tanh (dot b (inputVector x)) := by
  classical
  let q := (1 + Real.tanh (dot b (inputVector x))) / 2
  have hq0 : 0 ≤ q := by dsimp [q]; linarith [Real.neg_one_lt_tanh (dot b (inputVector x))]
  have hq1 : q ≤ 1 := by dsimp [q]; linarith [Real.tanh_lt_one (dot b (inputVector x))]
  have he : (fun u => labelReal (ridgePattern b u x)) =
      (fun u => 2 * (Iio q).indicator (fun _ => (1 : ℝ)) u - 1) := by
    funext u
    by_cases hu : u < q <;> simp [ridgePattern, labelReal, q, Set.indicator, hu] at * <;> norm_num
  rw [he, integral_sub]
  · rw [integral_const_mul, integral_indicator measurableSet_Iio]
    simp only [integral_const, Measure.restrict_apply_univ, Measure.real, smul_eq_mul,
      mul_one, measure_univ, ENNReal.toReal_one]
    have hprob := uniformSeed_Iio hq0 hq1
    change (uniformSeed (Iio q)).toReal = q at hprob
    rw [hprob]
    dsimp [q]
    ring
  · exact ((integrable_const (1 : ℝ)).indicator measurableSet_Iio).const_mul 2
  · exact integrable_const 1

end NeuralGeneralization.BatchTwoShallow
