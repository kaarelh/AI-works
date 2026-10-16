import NeuralGeneralization.GaussianReadout
import NeuralGeneralization.TanhSaturation
import Mathlib.Topology.Sequences

/-!
# Gaussian covariance saturation under varying linear couplings

The Gaussian laws here are concrete products. Scalar null boundaries are
proved from their actual distributions, rather than imposed as hypotheses.
The limiting two-coordinate covariance may be singular.
-/

noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped Topology BigOperators NNReal

namespace NeuralGeneralization.GaussianTanhSaturation

variable {I : Type*} [Fintype I]

def signCovariance (v : ℝ≥0) (c d : I → ℝ) : ℝ :=
  ∫ w, Real.sign (∑ i, c i * w i) * Real.sign (∑ i, d i * w i)
    ∂Measure.pi (fun _ : I => gaussianReal 0 v)

def tanhCovariance (v : ℝ≥0) (s : ℝ) (c d : I → ℝ) : ℝ :=
  ∫ w, Real.tanh (s * ∑ i, c i * w i) * Real.tanh (s * ∑ i, d i * w i)
    ∂Measure.pi (fun _ : I => gaussianReal 0 v)

/-- This is the sequential covariance convergence needed in the compactness
argument for uniform kernel freezing. The two coefficient vectors may vary
with width and become collinear in the limit. -/
theorem tendsto_covariance (v : ℝ≥0) {s : ℕ → ℝ}
    {c d : ℕ → I → ℝ} {c₀ d₀ : I → ℝ}
    (hs : Tendsto s atTop atTop)
    (hc : ∀ i, Tendsto (fun n => c n i) atTop (𝓝 (c₀ i)))
    (hd : ∀ i, Tendsto (fun n => d n i) atTop (𝓝 (d₀ i)))
    (hcvar : 0 < (v : ℝ) * ∑ i, c₀ i ^ 2)
    (hdvar : 0 < (v : ℝ) * ∑ i, d₀ i ^ 2) :
    Tendsto (fun n => tanhCovariance v (s n) (c n) (d n)) atTop
      (𝓝 (signCovariance v c₀ d₀)) := by
  apply TanhSaturation.tendsto_tanh_product_integral
    (Measure.pi fun _ : I => gaussianReal 0 v) hs
  · intro n
    exact (continuous_finsetSum _ (fun i _ => continuous_const.mul (continuous_apply i))).measurable
  · intro n
    exact (continuous_finsetSum _ (fun i _ => continuous_const.mul (continuous_apply i))).measurable
  · apply ae_of_all
    intro w
    exact tendsto_finsetSum _ (fun i _ => (hc i).mul_const (w i))
  · apply ae_of_all
    intro w
    exact tendsto_finsetSum _ (fun i _ => (hd i).mul_const (w i))
  · rw [ae_iff]
    simp only [ne_eq, not_not]
    exact GaussianReadout.scalar_linear_boundary_null c₀ v hcvar 0
  · rw [ae_iff]
    simp only [ne_eq, not_not]
    exact GaussianReadout.scalar_linear_boundary_null d₀ v hdvar 0

theorem tendsto_sign_covariance (v : ℝ≥0)
    {c d : ℕ → I → ℝ} {c₀ d₀ : I → ℝ}
    (hc : ∀ i, Tendsto (fun n => c n i) atTop (𝓝 (c₀ i)))
    (hd : ∀ i, Tendsto (fun n => d n i) atTop (𝓝 (d₀ i)))
    (hcvar : 0 < (v : ℝ) * ∑ i, c₀ i ^ 2)
    (hdvar : 0 < (v : ℝ) * ∑ i, d₀ i ^ 2) :
    Tendsto (fun n => signCovariance v (c n) (d n)) atTop
      (𝓝 (signCovariance v c₀ d₀)) := by
  apply TanhSaturation.tendsto_sign_product_integral
    (Measure.pi fun _ : I => gaussianReal 0 v)
  · intro n
    exact (continuous_finsetSum _ (fun i _ => continuous_const.mul (continuous_apply i))).measurable
  · intro n
    exact (continuous_finsetSum _ (fun i _ => continuous_const.mul (continuous_apply i))).measurable
  · apply ae_of_all
    intro w
    exact tendsto_finsetSum _ (fun i _ => (hc i).mul_const (w i))
  · apply ae_of_all
    intro w
    exact tendsto_finsetSum _ (fun i _ => (hd i).mul_const (w i))
  · rw [ae_iff]
    simp only [ne_eq, not_not]
    exact GaussianReadout.scalar_linear_boundary_null c₀ v hcvar 0
  · rw [ae_iff]
    simp only [ne_eq, not_not]
    exact GaussianReadout.scalar_linear_boundary_null d₀ v hdvar 0

/-- Uniform saturation on every compact family whose scalar variances stay
positive. The joint covariance is allowed to be singular throughout. This
proves, rather than assumes, the compactness step used in kernel freezing. -/
theorem uniform_covariance_saturation (v : ℝ≥0)
    (K : Set ((I → ℝ) × (I → ℝ))) (hK : IsCompact K)
    (hvar : ∀ p ∈ K, 0 < (v : ℝ) * ∑ i, p.1 i ^ 2 ∧
      0 < (v : ℝ) * ∑ i, p.2 i ^ 2)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ T : ℝ, ∀ s : ℝ, T ≤ s → ∀ p ∈ K,
      |tanhCovariance v s p.1 p.2 - signCovariance v p.1 p.2| < ε := by
  classical
  by_contra hnot
  push Not at hnot
  choose s hs p hp herr using fun n : ℕ => hnot (n : ℝ)
  obtain ⟨p₀, hp₀, k, hk, hpk⟩ := hK.tendsto_subseq hp
  have hsTop : Tendsto s atTop atTop :=
    tendsto_atTop_mono hs tendsto_natCast_atTop_atTop
  have hc : ∀ i, Tendsto (fun n => (p (k n)).1 i) atTop (𝓝 (p₀.1 i)) :=
    fun i => ((continuous_apply i).tendsto p₀.1).comp
      ((continuous_fst.tendsto p₀).comp hpk)
  have hd : ∀ i, Tendsto (fun n => (p (k n)).2 i) atTop (𝓝 (p₀.2 i)) :=
    fun i => ((continuous_apply i).tendsto p₀.2).comp
      ((continuous_snd.tendsto p₀).comp hpk)
  have ht := tendsto_covariance v (hsTop.comp hk.tendsto_atTop) hc hd
    (hvar p₀ hp₀).1 (hvar p₀ hp₀).2
  have hsign := tendsto_sign_covariance v hc hd (hvar p₀ hp₀).1 (hvar p₀ hp₀).2
  have hzero : Tendsto (fun n =>
      |tanhCovariance v (s (k n)) (p (k n)).1 (p (k n)).2 -
        signCovariance v (p (k n)).1 (p (k n)).2|) atTop (𝓝 (0 : ℝ)) := by
    simpa only [sub_self, abs_zero, Function.comp_def] using (ht.sub hsign).abs
  obtain ⟨n, hn⟩ := (hzero.eventually (Iio_mem_nhds hε)).exists
  exact (not_lt_of_ge (herr (k n))) hn

end NeuralGeneralization.GaussianTanhSaturation
