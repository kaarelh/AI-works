import NeuralGeneralization.SquaredSamplingIntegral
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-! The sample threshold has exactly D log(2D), uniformly in dimension;
its multiplicative constant is chosen before the dimension and sample size. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Filter
open scoped Topology
namespace NeuralGeneralization.SquaredSampling

lemma squaredSamplingScale_small {b : ℝ} (hb : 0<b) :
    ∃ A : ℝ,0<A ∧ ∀ D n : ℕ,0<D →
      A*(D:ℝ)*Real.log (2*(D:ℝ)) ≤ n → squaredSamplingScale n D ≤ b := by
  have ht : Tendsto (fun t : ℝ => Real.log (1+t)/t) atTop (𝓝 0) := by
    have hh := (Real.tendsto_pow_log_div_mul_add_atTop 1 (-1) 1 one_ne_zero).comp
      (tendsto_atTop_add_const_right atTop 1 tendsto_id)
    simpa [Function.comp_def,add_comm] using hh
  have hev : ∀ᶠ t : ℝ in atTop,Real.log (1+t)/t < b^2/2 :=
    ht.eventually (gt_mem_nhds (by positivity : (0:ℝ)<b^2/2))
  obtain ⟨T,hT⟩ := eventually_atTop.1 hev
  let A := 1+max (2*max T 0) (2/b^2)
  have hA : 0<A := by dsimp [A]; have hh:=le_max_left (2*max T 0) (2/b^2); positivity
  have hAT : 2*T ≤ A := by dsimp [A]; linarith [le_max_left T 0,le_max_left (2*max T 0) (2/b^2)]
  have hAb : 2/b^2 ≤ A := by dsimp [A]; linarith [le_max_right (2*max T 0) (2/b^2)]
  refine ⟨A,hA,?_⟩
  intro D n hD hn
  have hd : (0:ℝ)<D := by exact_mod_cast hD
  have hd1 : (1:ℝ)≤D := by exact_mod_cast hD
  have hl : (1:ℝ)/2 ≤ Real.log (2*(D:ℝ)) := by
    have hlog2 : (1:ℝ)/2 ≤ Real.log 2 := by
      have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
      norm_num at hh
      exact hh
    exact hlog2.trans (Real.log_le_log (by norm_num) (by linarith))
  have hnR : (0:ℝ)<n := lt_of_lt_of_le (mul_pos (mul_pos hA hd) (by linarith)) hn
  let t : ℝ := (n:ℝ)/(D:ℝ)
  have htp : 0<t := div_pos hnR hd
  have htl : A*Real.log (2*(D:ℝ)) ≤ t := by
    apply (le_div_iff₀ hd).mpr
    nlinarith only [hn]
  have hta : A/2 ≤ t := by
    have hh := mul_le_mul_of_nonneg_left hl hA.le
    linarith
  have htT : T ≤ t := by linarith
  have hlogt := hT t htT
  have hfirst : Real.log (2*(D:ℝ))/t ≤ b^2/2 := by
    have h1 : Real.log (2*(D:ℝ))/t ≤ 1/A := by
      apply (div_le_div_iff₀ htp hA).mpr
      nlinarith only [htl]
    have h2 : 1/A ≤ b^2/2 := by
      apply (div_le_iff₀ hA).mpr
      have hh := (div_le_iff₀ (sq_pos_of_pos hb)).mp hAb
      nlinarith only [hh]
    exact h1.trans h2
  have he : (D:ℝ)*Real.log (2*((n:ℝ)+D))/(n:ℝ) =
      Real.log (2*(D:ℝ))/t+Real.log (1+t)/t := by
    have harg : 2*((n:ℝ)+D) = (2*(D:ℝ))*(1+t) := by dsimp [t]; field_simp; ring
    rw [harg,Real.log_mul (by positivity : (2*(D:ℝ))≠0) (by positivity : 1+t≠0)]
    dsimp [t]
    field_simp
  unfold squaredSamplingScale
  apply (Real.sqrt_le_left hb.le).mpr
  rw [he]
  linarith

lemma squared_sampling_budget_exists {ε δ : ℝ} (hε : 0<ε) (hδ : 0<δ) :
    ∃ A : ℝ,0<A ∧ ∀ D n : ℕ,0<D →
      A*(D:ℝ)*Real.log (2*(D:ℝ)) ≤ n →
      squaredSamplingUniversalConstant*squaredSamplingScale n D*
        (1+squaredSamplingUniversalConstant*squaredSamplingScale n D) ≤ ε*δ := by
  let C := squaredSamplingUniversalConstant
  have hC : 0<C := by norm_num [C,squaredSamplingUniversalConstant]
  let b := min 1 (ε*δ/(C*(1+C)))
  have hb : 0<b := lt_min (by norm_num) (by positivity)
  obtain ⟨A,hA,hbudget⟩ := squaredSamplingScale_small hb
  refine ⟨A,hA,?_⟩
  intro D n hD hn
  have hs := hbudget D n hD hn
  have hs0 : 0 ≤ squaredSamplingScale n D := Real.sqrt_nonneg _
  have hb1 : b ≤ 1 := min_le_left _ _
  have hb2 : b ≤ ε*δ/(C*(1+C)) := min_le_right _ _
  have hh := (le_div_iff₀ (mul_pos hC (by linarith))).mp hb2
  change C*squaredSamplingScale n D*(1+C*squaredSamplingScale n D) ≤ ε*δ
  calc
    _ ≤ C*b*(1+C*b) := by gcongr
    _ ≤ C*b*(1+C) := by
      apply mul_le_mul_of_nonneg_left _ (mul_nonneg hC.le hb.le)
      have hh := mul_le_mul_of_nonneg_left hb1 hC.le
      linarith
    _ ≤ ε*δ := by nlinarith only [hh]

end NeuralGeneralization.SquaredSampling
