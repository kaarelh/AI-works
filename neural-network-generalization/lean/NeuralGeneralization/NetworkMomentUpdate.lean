import NeuralGeneralization.GaussianMomentLimits
import NeuralGeneralization.LayerGramConcentration
import NeuralGeneralization.NeuralKernelSpectrum
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-!
# The actual subcritical hidden-layer covariance update

Normalizing the incoming columns by the square root of width gives an exact
Gaussian identity. Uniform saturation then applies to every incoming feature
matrix in a small neighborhood of the limiting Gram matrix.
-/

noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped Topology BigOperators NNReal

namespace NeuralGeneralization.NetworkMomentUpdate
open GaussianPairMoments GaussianTanhSaturation GaussianMomentLimits

variable {I : Type*} [Fintype I]

theorem normalized_square_sum (c : I → ℝ) {a : ℝ} (ha : 0 < a) :
    (∑ i, (c i / Real.sqrt a) ^ 2) = (∑ i, c i ^ 2) / a := by
  simp only [div_pow, Real.sq_sqrt ha.le, Finset.sum_div]

theorem normalized_pair_sum (c d : I → ℝ) {a : ℝ} (ha : 0 < a) :
    (∑ i, (c i / Real.sqrt a) * (d i / Real.sqrt a)) =
      (∑ i, c i * d i) / a := by
  simp only [div_mul_div_comm, ← pow_two, Real.sq_sqrt ha.le, Finset.sum_div]

/-- Exact rescaling, before any limiting operation. -/
theorem pairMoment_normalize (c d : I → ℝ) (v : ℝ≥0) {a : ℝ} (ha : 0 < a) :
    pairMoment Real.tanh v c d =
      tanhCovariance 1 (Real.sqrt (a * v))
        (fun i => c i / Real.sqrt a) (fun i => d i / Real.sqrt a) := by
  have hav : 0 ≤ a * (v : ℝ) := mul_nonneg ha.le v.coe_nonneg
  calc
    _ = pairMoment Real.tanh (a * (v : ℝ)).toNNReal
        (fun i => c i / Real.sqrt a) (fun i => d i / Real.sqrt a) := by
      apply pairMoment_eq_of_scaled_gram ConcreteModel.tanh_lipschitzWith.continuous.measurable
      · simp only [Real.toNNReal_of_nonneg hav, NNReal.coe_mk, normalized_square_sum _ ha]
        field_simp
      · simp only [Real.toNNReal_of_nonneg hav, NNReal.coe_mk, normalized_square_sum _ ha]
        field_simp
      · simp only [Real.toNNReal_of_nonneg hav, NNReal.coe_mk, normalized_pair_sum _ _ ha]
        field_simp
    _ = _ := by
      simpa only [Real.toNNReal_of_nonneg hav, NNReal.coe_mk] using
        tanh_pairMoment_standardize (fun i => c i / Real.sqrt a)
          (fun i => d i / Real.sqrt a) (a * (v : ℝ)).toNNReal

/-- The scalar saturation scale of an internal layer diverges for every
real exponent strictly below one, including the nonpositive regimes. -/
theorem subcritical_scale_tendsto {γ : ℝ} (hγ : γ < 1) :
    Tendsto (fun N : ℕ => Real.sqrt ((N : ℝ) * (N : ℝ) ^ (-γ))) atTop atTop := by
  have hp : 0 < (1 - γ) / 2 := by linarith
  have ht := (tendsto_rpow_atTop hp).comp tendsto_natCast_atTop_atTop
  apply ht.congr'
  filter_upwards [eventually_gt_atTop (0 : ℕ)] with N hN
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  have heq : (N : ℝ) * (N : ℝ) ^ (-γ) = (N : ℝ) ^ (1 - γ) := by
    calc
      _ = (N : ℝ) ^ (1 : ℝ) * (N : ℝ) ^ (-γ) := by rw [Real.rpow_one]
      _ = _ := by rw [← Real.rpow_add hNp]; congr 1
  simp only [Function.comp_def]
  rw [heq, Real.sqrt_eq_rpow, ← Real.rpow_mul hNp.le]
  congr 1
  ring

/-- Uniform update of a normalized Gram entry near a unit-diagonal limit. -/
theorem uniform_layer_covariance {C ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ T : ℝ, ∀ N : ℕ, 0 < N →
      ∀ c d : Fin N → ℝ, ∀ v : ℝ≥0, T ≤ Real.sqrt ((N : ℝ) * v) →
      |(∑ i, c i ^ 2) / N - 1| < δ →
      |(∑ i, d i ^ 2) / N - 1| < δ →
      |(∑ i, c i * d i) / N - C| < δ →
      |pairMoment Real.tanh v c d - arcsineLink C| < ε := by
  obtain ⟨δ, hδ, T, hT⟩ := uniform_tanhCovariance_gram_neighborhood
    (A := 1) (B := 1) (C := C) (by norm_num) (by norm_num) hε
  refine ⟨δ, hδ, T, fun N hN c d v hs hc hd hcd => ?_⟩
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  rw [pairMoment_normalize c d v hNp]
  have h := hT N (fun i => c i / Real.sqrt N) (fun i => d i / Real.sqrt N)
    (Real.sqrt ((N : ℝ) * v)) hs
    (by simpa only [normalized_square_sum c hNp] using hc)
    (by simpa only [normalized_square_sum d hNp] using hd)
    (by simpa only [normalized_pair_sum c d hNp] using hcd)
  simpa only [Real.sqrt_one, one_mul, div_one, arcsineLink] using h

/-- Simultaneous covariance update on a finite input space. -/
theorem uniform_layer_covariance_matrix {X : Type*} [Fintype X] [Nonempty X]
    (K : X → X → ℝ) (hdiag : ∀ x, K x x = 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ T : ℝ, ∀ N : ℕ, 0 < N →
      ∀ H : Fin N → X → ℝ, ∀ v : ℝ≥0, T ≤ Real.sqrt ((N : ℝ) * v) →
      (∀ x y, |(∑ i, H i x * H i y) / N - K x y| < δ) →
      ∀ x y, |LayerGramConcentration.covariance Real.tanh H v x y -
        arcsineLink (K x y)| < ε := by
  classical
  choose δ hδ T hT using fun p : X × X => uniform_layer_covariance (C := K p.1 p.2) hε
  let δ₀ := Finset.univ.inf' Finset.univ_nonempty δ
  let T₀ := Finset.univ.sup' Finset.univ_nonempty T
  refine ⟨δ₀, ?_, T₀, fun N hN H v hs hnear x y => ?_⟩
  · exact (Finset.lt_inf'_iff Finset.univ_nonempty).mpr (fun p _ => hδ p)
  · have hδle : δ₀ ≤ δ (x,y) := Finset.inf'_le δ (Finset.mem_univ (x,y))
    have hTle : T (x,y) ≤ T₀ := Finset.le_sup' T (Finset.mem_univ (x,y))
    have h := hT (x,y) N hN (fun i => H i x) (fun i => H i y) v
      (hTle.trans hs)
      (by simpa only [hdiag, ← pow_two] using (hnear x x).trans_le hδle)
      (by simpa only [hdiag, ← pow_two] using (hnear y y).trans_le hδle)
      ((hnear x y).trans_le hδle)
    simpa only [pairMoment, LayerGramConcentration.covariance,
      LayerGramConcentration.rowFeature, mul_comm] using h

end NeuralGeneralization.NetworkMomentUpdate
