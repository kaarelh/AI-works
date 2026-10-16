import NeuralGeneralization.PoissonLevelUpper
import NeuralGeneralization.FirstLayerLevelLower

/-! Sharp paired-level upper bounds for the actual first arcsine kernel. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

/-- The actual first-layer paired level has its sharp `j^(-3/2)` upper
bound, uniformly below any fixed fraction less than one half. -/
theorem first_arcsine_paired_level_upper {d : ℕ} (S : Finset (Fin d))
    {ρ a : ℝ} (hρ0 : 0 < ρ) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a)
    (hjρ : (pairedWalshDegree S : ℝ) ≤ ((d : ℝ)+1)*ρ) :
    (pairedWalshDegree S : ℝ)^(3/2 : ℝ)*((d+1).choose (pairedWalshDegree S) : ℝ)*
        walshCoefficients (arcsineProfile d 1) S ≤
      4*(Real.exp (2*a)+a^(-(1/2 : ℝ))/((1/2 : ℝ)*(poissonFlipProbability a-ρ))) := by
  let j := pairedWalshDegree S
  have hj := pairedWalshDegree_bounds S
  have hjD : j < d+1 := by
    have hρ1 : ρ < 1 := hρp.trans ((poissonFlipProbability_lt_half a).trans (by norm_num))
    have hD : 0 < (d : ℝ)+1 := by positivity
    have hh := mul_lt_mul_of_pos_left hρ1 hD
    have hlt : (pairedWalshDegree S : ℝ) < (d : ℝ)+1 := by linarith
    exact_mod_cast hlt
  have h := poisson_level_normalized_upper hj.1 hjD
    (β := (1/2 : ℝ)) (by norm_num) (by norm_num) hρ0 ha hρp
    (by simpa only [Nat.cast_add,Nat.cast_one] using hjρ)
  have hc := (first_arcsine_poisson_integral_comparison d S).2
  have he : (fun u : ℝ => u^(-1-(1/2 : ℝ))*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(d+1-j)) =
      fun u : ℝ => u^(-(3/2 : ℝ))*oddPoissonEndpoint d u S := by
    funext u
    rw [oddPoissonEndpoint_eq_paired]
    dsimp [j]
    norm_num only
    ring
  rw [he] at h
  norm_num only [Nat.cast_add,Nat.cast_one] at h
  norm_num only at hc
  have hw : 0 ≤ (pairedWalshDegree S : ℝ)^(3/2 : ℝ)*
      ((d+1).choose (pairedWalshDegree S) : ℝ) := by positivity
  have hc' := mul_le_mul_of_nonneg_left hc hw
  exact hc'.trans (by convert h using 1 <;> first | rfl | ring)

end NeuralGeneralization
