import NeuralGeneralization.RankOneRademacherBound
import NeuralGeneralization.RankOneGrowthConstants
import NeuralGeneralization.SquaredResponseScaling

/-! Row-dependent squared Lipschitz processes. The responses need not be
homogeneous and may differ at every observed row. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
variable {m D : ℕ}

theorem finite_row_squared_rademacher_normalized {U : Type*} [Fintype U] [Nonempty U]
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀ = 0)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V)
    (hp : ∀ u, ∑ j, p u j^2 ≤ 1)
    (hrow : ∀ u, ∑ i, linearEvaluation (a i) (p u)^2 ≤ 1)
    (ψ : Fin m → ℝ → ℝ) (hψ0 : ∀ i,ψ i 0 = 0)
    (hψ : ∀ i x y, |ψ i x-ψ i y| ≤ |x-y|) :
    finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
      ∑ i, cubeCoordinateSign (ε i) * ψ i (linearEvaluation (a i) (p u))^2)) ≤
      268435456 * Real.sqrt (V*(Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ))) := by
  classical
  let coeff := fun u : U => fun i : Fin m => ψ i (linearEvaluation (a i) (p u))^2
  let δ := fun u v : U => rankOneDistance a (p u) (p v)
  have hcoeff : ∀ u v, (∑ i, (coeff u i-coeff v i)^2) ≤ 2*δ u v^2 := by
    intro u v
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
      squared_lipschitz_increment (ψ i) (hψ0 i) (hψ i) (linearEvaluation (a i) (p u)) (linearEvaluation (a i) (p v)))
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


/-- Normalize the rows and the responses together. Unlike scaling only the
rows, this works for arbitrary Lipschitz responses fixing zero. -/
theorem finite_row_squared_rademacher {U : Type*} [Fintype U] [Nonempty U]
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀ = 0)
    {R V : ℝ} (hm : 0 < m) (hR : 0 < R) (hV : 0 < V)
    (ha : ∀ i,∑ j,a i j^2 ≤ R^2) (hp : ∀ u,∑ j,p u j^2 ≤ 1)
    (hrow : ∀ u,∑ i,linearEvaluation (a i) (p u)^2 ≤ V^2)
    (ψ : Fin m → ℝ → ℝ) (hψ0 : ∀ i,ψ i 0=0)
    (hψ : ∀ i x y,|ψ i x-ψ i y| ≤ |x-y|) :
    finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
      ∑ i,cubeCoordinateSign (ε i)*ψ i (linearEvaluation (a i) (p u))^2)) ≤
      268435456*R*Real.sqrt (Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ))*V := by
  let b : Fin m → Fin D → ℝ := fun i j => a i j/V
  let θ : Fin m → ℝ → ℝ := fun i t => ψ i (V*t)/V
  have hθ0 (i) : θ i 0 = 0 := by simp [θ,hψ0]
  have hθ (i) (x y : ℝ) : |θ i x-θ i y| ≤ |x-y| := by
    dsimp [θ]
    rw [← sub_div, abs_div, abs_of_pos hV]
    have hh := div_le_div_of_nonneg_right (hψ i (V*x) (V*y)) hV.le
    apply hh.trans_eq
    rw [← mul_sub, abs_mul, abs_of_pos hV]
    field_simp
  have hb (i) : (∑ j,b i j^2) ≤ R^2/V^2 := by
    simp only [b, div_pow, ← Finset.sum_div]
    exact div_le_div_of_nonneg_right (ha i) (sq_nonneg V)
  have hbrow (u) : (∑ i,linearEvaluation (b i) (p u)^2) ≤ 1 := by
    simp only [b, linearEvaluation_row_div, div_pow, ← Finset.sum_div]
    exact (div_le_one (sq_pos_of_pos hV)).mpr (hrow u)
  have hh := finite_row_squared_rademacher_normalized b p u₀ hroot (R^2/V^2)
    hm (by positivity) hb hp hbrow θ hθ0 hθ
  have he (i) (u) : θ i (linearEvaluation (b i) (p u)) =
      ψ i (linearEvaluation (a i) (p u))/V := by
    dsimp [θ,b]
    rw [linearEvaluation_row_div]
    congr 2
    field_simp
  have hpull (ε : Fin m → Bool) (u : U) :
      (∑ i,cubeCoordinateSign (ε i)*ψ i (linearEvaluation (a i) (p u))^2) =
      V^2*∑ i,cubeCoordinateSign (ε i)*θ i (linearEvaluation (b i) (p u))^2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    rw [he]
    field_simp
  simp_rw [hpull, envelope_const_mul _ _ (sq_nonneg V)]
  rw [finiteMean_mul]
  apply (mul_le_mul_of_nonneg_left hh (sq_nonneg V)).trans_eq
  rw [Real.sqrt_mul (div_nonneg (sq_nonneg R) (sq_nonneg V)),
    Real.sqrt_div (sq_nonneg R), Real.sqrt_sq hR.le, Real.sqrt_sq hV.le]
  field_simp
  <;> ring

theorem squared_process_log_budget (hm : 0 < m) (hD : 0 < D) :
    Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ) ≤
      16*Real.log (2*((m:ℝ)+D)) := by
  have hmR : 0 < (m:ℝ) := Nat.cast_pos.mpr hm
  have hDR : 0 < (D:ℝ) := Nat.cast_pos.mpr hD
  have hcut := dimensionCutoff_le_two_log D
  have hlog2 : (1:ℝ)/2 ≤ Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ) < 2)
    norm_num at hh ⊢
    exact hh
  have hmle := Real.log_le_log hmR (show (m:ℝ) ≤ m+D by linarith)
  have hDle := Real.log_le_log hDR (show (D:ℝ) ≤ m+D by linarith)
  have hsum : 0 ≤ Real.log ((m:ℝ)+D) := Real.log_nonneg (by
    have hh : (1:ℝ) ≤ m := by exact_mod_cast hm
    linarith)
  have h8 : Real.log (8:ℝ) = 3*Real.log 2 := by
    rw [show (8:ℝ) = 2^3 by norm_num,Real.log_pow]
    norm_num
  rw [Real.log_mul (by norm_num) hmR.ne',h8,
    Real.log_mul (by norm_num) (by positivity : (m:ℝ)+D ≠ 0)]
  push_cast
  linarith

end NeuralGeneralization.SquaredSampling
