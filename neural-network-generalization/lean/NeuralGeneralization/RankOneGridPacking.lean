import NeuralGeneralization.RankOneQuasimetric
import NeuralGeneralization.GreedyGrowthTree
import Mathlib.Algebra.Order.Floor.Ring

/-!
# An actual finite grid for the rank-one quasimetric

Quantizing each coordinate gives a finite code. Equal codes force close
rank-one evaluations by Cauchy--Schwarz and the actual empirical row
energy bounds. The resulting packing bound supplies all sufficiently
fine growth levels without an entropy or covering-number assumption.
-/

noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators

theorem coordinate_abs_le_one {D : ℕ} (u : Fin D → ℝ)
    (hu : ∑ j, u j^2 ≤ 1) (j : Fin D) : |u j| ≤ 1 := by
  have hh : u j^2 ≤ ∑ k, u k^2 :=
    Finset.single_le_sum (fun k _ => sq_nonneg (u k)) (Finset.mem_univ j)
  nlinarith only [hh, hu, sq_abs (u j), abs_nonneg (u j)]

def coordinateCode {D : ℕ} (q : ℕ) (u : Fin D → ℝ)
    (hu : ∑ j, u j^2 ≤ 1) (j : Fin D) : Fin (2*q+1) :=
  ⟨⌊(q:ℝ)*(u j+1)⌋₊, by
    have hh := (abs_le.mp (coordinate_abs_le_one u hu j)).2
    have hle : (q:ℝ)*(u j+1) ≤ ((2*q:ℕ):ℝ) := by push_cast; nlinarith
    have hf := Nat.floor_mono hle
    rw [Nat.floor_natCast] at hf
    omega⟩

theorem same_coordinateCode_close {D : ℕ} (q : ℕ) (hq : 0 < q)
    (u v : Fin D → ℝ) (hu : ∑ j, u j^2 ≤ 1) (hv : ∑ j, v j^2 ≤ 1)
    (hcode : coordinateCode q u hu = coordinateCode q v hv) (j : Fin D) :
    |u j-v j| ≤ 1/(q:ℝ) := by
  have hq' : (0:ℝ)<q := by exact_mod_cast hq
  have huj := (abs_le.mp (coordinate_abs_le_one u hu j)).1
  have hvj := (abs_le.mp (coordinate_abs_le_one v hv j)).1
  have heq : ⌊(q:ℝ)*(u j+1)⌋₊ = ⌊(q:ℝ)*(v j+1)⌋₊ :=
    congrArg Fin.val (congrFun hcode j)
  have hlu := Nat.floor_le (show (0:ℝ)≤q*(u j+1) by exact mul_nonneg hq'.le (by linarith))
  have hlv := Nat.floor_le (show (0:ℝ)≤q*(v j+1) by exact mul_nonneg hq'.le (by linarith))
  have htu := Nat.lt_floor_add_one ((q:ℝ)*(u j+1))
  have htv := Nat.lt_floor_add_one ((q:ℝ)*(v j+1))
  rw [heq] at hlu htu
  apply abs_le.mpr
  constructor
  · rw [← neg_div]
    apply (div_le_iff₀ hq').mpr
    nlinarith only [hlu, htv]
  · apply (le_div_iff₀ hq').mpr
    nlinarith only [hlv, htu]

theorem rankOneMetricSquared_euclidean_bound {m D : ℕ}
    (a : Fin m → Fin D → ℝ) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V) (u v : Fin D → ℝ)
    (hu : ∑ i, linearEvaluation (a i) u^2 ≤ 1)
    (hv : ∑ i, linearEvaluation (a i) v^2 ≤ 1) :
    rankOneMetricSquared a u v ≤ 2*V*(∑ j, (u j-v j)^2) := by
  have hrow (i : Fin m) : (linearEvaluation (a i) u-linearEvaluation (a i) v)^2 ≤
      V*(∑ j, (u j-v j)^2) := by
    rw [← linearEvaluation_sub]
    exact (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (a i) (fun j => u j-v j)).trans
      (mul_le_mul_of_nonneg_right (ha i) (Finset.sum_nonneg (fun j _ => sq_nonneg _)))
  calc
    _ ≤ ∑ i, (V*(∑ j, (u j-v j)^2)) *
        (linearEvaluation (a i) u^2+linearEvaluation (a i) v^2) :=
      Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_right (hrow i)
        (add_nonneg (sq_nonneg _) (sq_nonneg _)))
    _ = (V*(∑ j, (u j-v j)^2)) *
        ((∑ i, linearEvaluation (a i) u^2)+(∑ i, linearEvaluation (a i) v^2)) := by
      rw [← Finset.mul_sum, Finset.sum_add_distrib]
    _ ≤ (V*(∑ j, (u j-v j)^2))*2 := mul_le_mul_of_nonneg_left
      (by linarith) (mul_nonneg hV (Finset.sum_nonneg (fun j _ => sq_nonneg _)))
    _ = _ := by ring

theorem rankOneDistance_same_code {m D : ℕ}
    (a : Fin m → Fin D → ℝ) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V) (q : ℕ) (hq : 0 < q)
    (u v : Fin D → ℝ) (hu : ∑ j, u j^2 ≤ 1) (hv : ∑ j, v j^2 ≤ 1)
    (hrowu : ∑ i, linearEvaluation (a i) u^2 ≤ 1)
    (hrowv : ∑ i, linearEvaluation (a i) v^2 ≤ 1)
    (hcode : coordinateCode q u hu = coordinateCode q v hv)
    (B : ℝ) (hB : 0 ≤ B) (hVB : 2*V*D ≤ B^2) :
    rankOneDistance a u v ≤ B/(q:ℝ) := by
  have hq' : (0:ℝ)<q := by exact_mod_cast hq
  have he : (∑ j, (u j-v j)^2) ≤ (D:ℝ)*(1/(q:ℝ))^2 := by
    have hh := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) =>
      (sq_le_sq₀ (abs_nonneg _) (by positivity : (0:ℝ)≤1/(q:ℝ))).mpr
        (same_coordinateCode_close q hq u v hu hv hcode j))
    simpa only [sq_abs, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] using hh
  have hg := (rankOneMetricSquared_euclidean_bound a V hV ha u v hrowu hrowv).trans
    (mul_le_mul_of_nonneg_left he (by positivity : 0≤2*V))
  have hlast := mul_le_mul_of_nonneg_right hVB (sq_nonneg (1/(q:ℝ)))
  apply (sq_le_sq₀ (rankOneDistance_nonneg a u v) (by positivity : 0≤B/(q:ℝ))).mp
  rw [rankOneDistance_sq]
  calc
    _ ≤ 2*V*((D:ℝ)*(1/(q:ℝ))^2) := hg
    _ = (2*V*D)*(1/(q:ℝ))^2 := by ring
    _ ≤ B^2*(1/(q:ℝ))^2 := hlast
    _ = (B/(q:ℝ))^2 := by ring

/-- A separated actual family injects into its coordinate grid. -/
theorem rankOne_grid_packing {m D M : ℕ}
    (a : Fin m → Fin D → ℝ) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V) (q : ℕ) (hq : 0 < q)
    (p : Fin M → Fin D → ℝ) (hp : ∀ l, ∑ j, p l j^2 ≤ 1)
    (hrow : ∀ l, ∑ i, linearEvaluation (a i) (p l)^2 ≤ 1)
    (B : ℝ) (hB : 0 ≤ B) (hVB : 2*V*D ≤ B^2)
    (hsep : ∀ l k, l≠k → B/(q:ℝ) < rankOneDistance a (p l) (p k)) :
    M ≤ (2*q+1)^D := by
  have hinj : Function.Injective (fun l => coordinateCode q (p l) (hp l)) := by
    intro l k hcode
    by_contra hne
    exact (not_lt_of_ge (rankOneDistance_same_code a V hV ha q hq (p l) (p k)
      (hp l) (hp k) (hrow l) (hrow k) hcode B hB hVB)) (hsep l k hne)
  have hh := Fintype.card_le_of_injective _ hinj
  simpa only [Fintype.card_fin, Fintype.card_fun] using hh

theorem grid_exponent_lt (h : ℕ) : 3*h+2 < 4*2^h := by
  induction h with
  | zero => norm_num
  | succ h ih =>
    have hp : 1 ≤ 2^h := Nat.one_le_pow _ _ (by decide)
    rw [pow_succ]
    omega

theorem tail_grid_card_lt {D h : ℕ} (hD : D ≤ 2^h) :
    (2*(2^(3*h))+1)^D < GrowthTree.branching h := by
  have hb : 2*(2^(3*h))+1 ≤ 2^(3*h+2) := by
    have hp : 1 ≤ 2^(3*h) := Nat.one_le_pow _ _ (by decide)
    rw [pow_add]
    norm_num
    omega
  calc
    _ ≤ (2^(3*h+2))^D := Nat.pow_le_pow_left hb D
    _ = 2^((3*h+2)*D) := (pow_mul _ _ _).symm
    _ < 2^(4^(h+1)) := by
      apply Nat.pow_lt_pow_right (by decide)
      have hh := grid_exponent_lt h
      have hmul := Nat.mul_le_mul_left (3*h+2) hD
      have hp : 0 < 2^h := by positivity
      have h4 : (4:ℕ)^h = 2^h*2^h := by rw [← mul_pow]; norm_num
      rw [pow_succ, h4]
      nlinarith
    _ = _ := rfl

/-- Beyond a logarithmic dimension cutoff, a family of the prescribed
growth cardinality must have very small separation. The bound retains
the actual row variance factor `sqrt V`. -/
theorem rankOne_tail_separation_bound {m D h : ℕ}
    (a : Fin m → Fin D → ℝ) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, ∑ j, a i j^2 ≤ V) (hD : D ≤ 2^h)
    (p : Fin (GrowthTree.branching h) → Fin D → ℝ)
    (hp : ∀ l, ∑ j, p l j^2 ≤ 1)
    (hrow : ∀ l, ∑ i, linearEvaluation (a i) (p l)^2 ≤ 1)
    (s : ℝ) (hsep : ∀ l k, l≠k → s ≤ rankOneDistance a (p l) (p k)) :
    s ≤ 2*Real.sqrt V*(1/4:ℝ)^h := by
  let q : ℕ := 2^(3*h)
  let B : ℝ := 2*Real.sqrt V*(2:ℝ)^h
  have hq : 0 < q := by unfold q; positivity
  have hB : 0 ≤ B := by unfold B; positivity
  have hp2 : (1:ℝ) ≤ 2^h := one_le_pow₀ (by norm_num)
  have hD' : (D:ℝ) ≤ (2:ℝ)^h := by exact_mod_cast hD
  have hVB : 2*V*D ≤ B^2 := by
    dsimp only [B]
    rw [mul_pow, mul_pow, Real.sq_sqrt hV]
    have hmul := mul_le_mul_of_nonneg_left hD' (by positivity : 0≤2*V)
    have hh : (2:ℝ)^h ≤ 2*((2:ℝ)^h)^2 := by nlinarith
    have hh' := mul_le_mul_of_nonneg_left hh (by positivity : 0≤2*V)
    nlinarith only [hmul, hh']
  have hratio : B/(q:ℝ) = 2*Real.sqrt V*(1/4:ℝ)^h := by
    dsimp only [B, q]
    rw [Nat.cast_pow, Nat.cast_ofNat, show 3*h=h+2*h by omega, pow_add]
    have h4 : (4:ℝ)^h = (2:ℝ)^(2*h) := by rw [pow_mul]; norm_num
    rw [← h4, div_pow, one_pow]
    field_simp
  by_contra hn
  have hsmall := rankOne_grid_packing a V hV ha q hq p hp hrow B hB hVB
    (fun l k hlk => by rw [hratio]; exact (lt_of_not_ge hn).trans_le (hsep l k hlk))
  exact (not_le_of_gt (tail_grid_card_lt hD)) hsmall

end NeuralGeneralization.SquaredSampling
