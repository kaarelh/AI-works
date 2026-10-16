import NeuralGeneralization.FiniteGrowthChaining
import NeuralGeneralization.RankOneAllLevelGrowth

/-!
# Actual uniform squared-row Rademacher bound

The process can use any one-Lipschitz response fixing zero. In particular
it includes both the square and the squared negative-part processes.
The right hand side has the sharp square root of the logarithmic loss;
all growth, covering, and Gaussian packing arguments are discharged.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling

variable {m D : ℕ}

theorem rankOneDistance_unit_bound (a : Fin m → Fin D → ℝ) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V) (u v : Fin D → ℝ)
    (hu : ∑ j, u j^2 ≤ 1) (hv : ∑ j, v j^2 ≤ 1)
    (hrowu : ∑ i, linearEvaluation (a i) u^2 ≤ 1)
    (hrowv : ∑ i, linearEvaluation (a i) v^2 ≤ 1) :
    rankOneDistance a u v ≤ 4 * Real.sqrt V := by
  have hdist : (∑ j, (u j-v j)^2) ≤ 4 := by
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun j _ =>
      show (u j-v j)^2 ≤ 2*u j^2+2*v j^2 by nlinarith only [sq_nonneg (u j+v j)])
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hh
    linarith
  have he := rankOneMetricSquared_euclidean_bound a V hV ha u v hrowu hrowv
  have hm := mul_le_mul_of_nonneg_left hdist (show 0 ≤ 2*V by positivity)
  have hs := Real.sq_sqrt hV
  apply (sq_le_sq₀ (rankOneDistance_nonneg a u v) (by positivity : 0 ≤ 4*Real.sqrt V)).mp
  rw [rankOneDistance_sq]
  nlinarith

/-- A finite class of actual squared row evaluations has the optimal
logarithmic Rademacher loss under its two actual quadratic bounds. -/
theorem finite_squared_response_rademacher {U : Type*} [Fintype U] [Nonempty U]
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀ = 0)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V)
    (hp : ∀ u, ∑ j, p u j^2 ≤ 1)
    (hrow : ∀ u, ∑ i, linearEvaluation (a i) (p u)^2 ≤ 1)
    (ψ : ℝ → ℝ) (hψ0 : ψ 0 = 0) (hψ : ∀ x y, |ψ x-ψ y| ≤ |x-y|) :
    finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
      ∑ i, cubeCoordinateSign (ε i) * ψ (linearEvaluation (a i) (p u))^2)) ≤
      268435456 * Real.sqrt (V*(Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ))) := by
  classical
  let coeff := fun u : U => fun i : Fin m => ψ (linearEvaluation (a i) (p u))^2
  let δ := fun u v : U => rankOneDistance a (p u) (p v)
  have hcoeff : ∀ u v, (∑ i, (coeff u i-coeff v i)^2) ≤ 2*δ u v^2 := by
    intro u v
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
      squared_lipschitz_increment ψ hψ0 hψ (linearEvaluation (a i) (p u)) (linearEvaluation (a i) (p v)))
    simpa only [coeff, δ, rankOneDistance_sq, rankOneMetricSquared, ← Finset.mul_sum, mul_assoc] using hh
  have hb := GrowthChaining.finite_rademacher_growth m coeff u₀
    (fun i => by simp [coeff, hroot, linearEvaluation, hψ0]) δ
    (fun u v => rankOneDistance_nonneg a (p u) (p v))
    (fun u => rankOneDistance_self a (p u))
    (fun u v => rankOneDistance_symm a (p u) (p v))
    (fun u v w => rankOneDistance_triangle a (p u) (p w) (p v)) hcoeff
    (rankGrowthFunctional a p V)
    (rankGrowthFunctional_mono a p V hm hV hp hrow)
    (rankGrowthFunctional_antitone a p V hm hV)
    (rankGrowthFunctional_nonneg a p V hm hV hp hrow)
    (rankGrowthConstant m D V) (rankGrowthConstant_pos m D V hm hV)
    (rankGrowthFunctional_growthAt a p V hm hV ha hp hrow)
    (4*Real.sqrt V) (by positivity)
    (fun u v => rankOneDistance_unit_bound a V hV.le ha (p u) (p v) (hp u) (hp v) (hrow u) (hrow v))
    4 (rankGrowthFunctional_zero_le a p V hm hV Finset.univ)
  let L : ℝ := Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ)
  have hL : 1 ≤ L := by
    have hlog := rankGrowth_log_nonneg m hm
    have hd : (0 : ℝ) ≤ dimensionCutoff D := Nat.cast_nonneg _
    dsimp only [L]
    push_cast
    linarith
  have hs : Real.sqrt V ≤ Real.sqrt (V*L) :=
    Real.sqrt_le_sqrt (by nlinarith [mul_nonneg hV.le (sub_nonneg.mpr hL)])
  have hpos : 0 ≤ Real.sqrt (V*L) := Real.sqrt_nonneg _
  change _ ≤ 268435456*Real.sqrt (V*L)
  change _ ≤ 65536*(4*Real.sqrt V+4/(rankGrowthConstant m D V)) at hb
  have hc : 4/(rankGrowthConstant m D V) = 2048*Real.sqrt (V*L) := by
    unfold rankGrowthConstant L
    rw [one_div, div_inv_eq_mul]
    ring
  rw [hc] at hb
  exact hb.trans (by nlinarith only [hs, hpos])

end NeuralGeneralization.SquaredSampling
