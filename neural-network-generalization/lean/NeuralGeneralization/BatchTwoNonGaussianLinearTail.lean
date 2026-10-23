import NeuralGeneralization.BatchTwoNonGaussianSubGaussian
import NeuralGeneralization.GaussianLinear

/-! Dimension-free independent-product linear-form concentration for the
actual non-Gaussian coordinate prior. -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoNonGaussian

def subGaussianVariance (ν : CoordinateLaw) : ℝ :=
  ν.comparisonFactor ν.lowerCurvature / ν.lowerCurvature

theorem subGaussianVariance_pos (ν : CoordinateLaw) : 0 < subGaussianVariance ν :=
  div_pos (ν.comparisonFactor_pos _ ν.lowerCurvature_pos) ν.lowerCurvature_pos

variable {J : Type*} [Fintype J]

theorem actual_linear_subGaussian (ν : CoordinateLaw) (c : J → ℝ) :
    HasSubgaussianMGF (fun x : J → ℝ => ∑ j, c j * x j)
      (∑ j, NNReal.mk (c j ^ 2) (sq_nonneg (c j)) * (subGaussianVariance ν).toNNReal)
      (Measure.pi fun _ : J => ν.law) := by
  have hInd := iIndepFun_pi (μ := fun _ : J => ν.law)
    (fun j => (show AEMeasurable (fun x : ℝ => c j * x) ν.law by fun_prop))
  apply HasSubgaussianMGF.sum_of_iIndepFun hInd
  intro j hj
  have hm : (Measure.pi fun _ : J => ν.law).map (fun x => x j) = ν.law :=
    (measurePreserving_eval (fun _ : J => ν.law) j).map_eq
  have hc : HasSubgaussianMGF (fun x : J → ℝ => x j) (subGaussianVariance ν).toNNReal
      (Measure.pi fun _ : J => ν.law) := by
    have hh : HasSubgaussianMGF (fun x : ℝ => x) (subGaussianVariance ν).toNNReal
        ((Measure.pi fun _ : J => ν.law).map (fun x => x j)) := by
      rw [hm]
      exact ν.hasSubgaussianMGF
    simpa only [Function.comp_def] using!
      HasSubgaussianMGF.of_map (μ := Measure.pi fun _ : J => ν.law)
        (Y := fun x : J → ℝ => x j) (measurable_pi_apply j).aemeasurable hh
  exact hc.const_mul (c j)

theorem actual_linear_mgf_le (ν : CoordinateLaw) (c : J → ℝ) (s : ℝ) :
    mgf (fun x : J → ℝ => ∑ j, c j * x j) (Measure.pi fun _ : J => ν.law) s ≤
      Real.exp (s ^ 2 * (subGaussianVariance ν * ∑ j, c j ^ 2) / 2) := by
  have h := (actual_linear_subGaussian ν c).mgf_le s
  simp only [NNReal.coe_sum, NNReal.coe_mul, NNReal.coe_mk,
    Real.coe_toNNReal _ (subGaussianVariance_pos ν).le] at h
  convert! h using 1
  congr 1
  rw [← Finset.sum_mul]
  ring

theorem actual_linear_upper_tail (ν : CoordinateLaw) (c : J → ℝ)
    (V u : ℝ) (hV : 0 < V) (hu : 0 ≤ u)
    (hvar : subGaussianVariance ν * (∑ j, c j ^ 2) ≤ V) :
    (Measure.pi fun _ : J => ν.law).real {x | u ≤ ∑ j, c j * x j} ≤
      Real.exp (-u ^ 2 / (2 * V)) := by
  have h := measure_ge_le_exp_mul_mgf u (div_nonneg hu hV.le)
    ((actual_linear_subGaussian ν c).integrable_exp_mul (u / V))
  have hmgf := actual_linear_mgf_le ν c (u / V)
  have hscaled := mul_le_mul_of_nonneg_left hmgf (Real.exp_pos (-(u / V) * u)).le
  apply (h.trans hscaled).trans
  rw [← Real.exp_add]
  apply Real.exp_le_exp.mpr
  calc
    _ ≤ -(u / V) * u + (u / V) ^ 2 * V / 2 := by
      have hh := mul_le_mul_of_nonneg_left hvar (sq_nonneg (u / V))
      linarith
    _ = _ := by field_simp; ring

theorem actual_linear_abs_tail (ν : CoordinateLaw) (c : J → ℝ)
    (V u : ℝ) (hV : 0 < V) (hu : 0 ≤ u)
    (hvar : subGaussianVariance ν * (∑ j, c j ^ 2) ≤ V) :
    (Measure.pi fun _ : J => ν.law).real {x | u ≤ |∑ j, c j * x j|} ≤
      2 * Real.exp (-u ^ 2 / (2 * V)) := by
  have hp := actual_linear_upper_tail ν c V u hV hu hvar
  have hn := actual_linear_upper_tail ν (fun j => -c j) V u hV hu
    (by simpa only [neg_sq] using hvar)
  simp only [neg_mul, Finset.sum_neg_distrib] at hn
  have hsub : {x : J → ℝ | u ≤ |∑ j, c j * x j|} ⊆
      {x | u ≤ ∑ j, c j * x j} ∪ {x | u ≤ -(∑ j, c j * x j)} := by
    intro x hx
    rcases le_total 0 (∑ j, c j * x j) with hs | hs
    · exact Or.inl (by simpa only [Set.mem_setOf_eq, abs_of_nonneg hs] using hx)
    · exact Or.inr (by simpa only [Set.mem_setOf_eq, abs_of_nonpos hs] using hx)
  have hm := (measureReal_mono hsub (measure_ne_top _ _)).trans
    (measureReal_union_le (μ := Measure.pi fun _ : J => ν.law) _ _)
  linarith

end NeuralGeneralization.BatchTwoNonGaussian
