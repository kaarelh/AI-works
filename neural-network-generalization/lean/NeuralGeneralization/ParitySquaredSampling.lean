import NeuralGeneralization.SquaredSamplingBound
import NeuralGeneralization.ParityLowFeatures

/-!
# Simultaneous one-sided sampling for actual low-degree Walsh polynomials

The finite IID cube probability, the parity labels, and the low-degree
Walsh class are all literal. The logarithmic sample budget follows from
the fully proved rank-one chaining and empirical bootstrap chain.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization
open SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

def paritySquaredSamplingBudget (d r n : ℕ) : ℝ :=
  (2:ℝ)^76*(lowDimension d r:ℝ)*
    (Real.log (8*(n:ℝ))+(dimensionCutoff (lowDimension d r)+1 : ℕ))

lemma paritySquaredSamplingBudget_eq (d r n : ℕ) (hn : 0 < n) :
    paritySquaredSamplingBudget d r n =
      1048576*(squaredSamplingConstant n (lowDimension d r) (lowDimension d r:ℝ))^2 := by
  have hlog := rankGrowth_log_nonneg n hn
  have hnonneg : 0 ≤ (lowDimension d r:ℝ)*
      (Real.log (8*(n:ℝ))+(dimensionCutoff (lowDimension d r)+1 : ℕ)) := by positivity
  unfold paritySquaredSamplingBudget squaredSamplingConstant
  rw [mul_pow, Real.sq_sqrt hnonneg]
  ring

/-- With the explicit `D(log n + log D)` sample budget, all low-degree
polynomials simultaneously have empirical wrong-label square at least
one quarter of their population squared norm, with probability `15/16`. -/
theorem parity_squared_coercivity_probability {d r n : ℕ}
    (hd : 0 < d) (hr : 64*r ≤ d) (hn : 0 < n)
    (hbudget : paritySquaredSamplingBudget d r n ≤ (n:ℝ)) :
    (15:ℝ)/16 ≤ ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s =>
      ∀ c : Finset (Fin d) → ℝ, (∀ S, c S ≠ 0 → S.card ≤ r) →
        (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion c x^2) ≤
          (∑ i, (max 0 (-fullParity (s i)*walshExpansion c (s i)))^2)/(n:ℝ)) := by
  let A := squaredSamplingConstant n (lowDimension d r) (lowDimension d r:ℝ)
  have hV : (0:ℝ)<lowDimension d r := Nat.cast_pos.mpr (lowDimension_pos d r)
  have hp := all_vector_squared_coercivity_probability n (parityLowFeatures d r)
    (lowDimension d r:ℝ) (3/8) (1/4) hn hV (by norm_num)
    (fun x => (parityLowFeatures_row_norm d r x).le) parityLowFeatures_isometry
    (fun t => max 0 (-t)) (by norm_num) negativePart_lipschitz
    (fun t ht x => negativePart_homogeneous t x ht)
    (parityLowFeatures_population_coercivity hd hr)
  have hlarge : 1048576*A^2 ≤ (n:ℝ) := by
    change 1048576*(squaredSamplingConstant n (lowDimension d r) (lowDimension d r:ℝ))^2 ≤ _
    rw [← paritySquaredSamplingBudget_eq d r n hn]
    exact hbudget
  have herr := squared_sampling_error_small A (n:ℝ)
    (squaredSamplingConstant_nonneg _ _ _) (by exact_mod_cast hn) hlarge
  have he : (n:ℝ)*((3/8:ℝ)-1/4) = (n:ℝ)/8 := by ring
  rw [he] at hp
  have hcoord : (15:ℝ)/16 ≤ finiteMean (fun s : Fin n → ClippingCube d => if
      (∀ c : Fin (lowDimension d r) → ℝ,
        (1/4:ℝ)*(∑ j, c j^2) ≤
          (∑ i, squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c (s i))/(n:ℝ))
      then 1 else 0) := by
    dsimp only [A] at herr
    linarith only [hp, herr]
  rw [sampleProbability_uniform_eq_finiteMean]
  apply hcoord.trans
  apply finiteMean_mono
  intro s
  split_ifs with hc hw
  · exact le_rfl
  · exact False.elim (hw (parityLowFeatures_coercivity_walsh s (1/4) hc))
  · norm_num
  · exact le_rfl

end NeuralGeneralization
