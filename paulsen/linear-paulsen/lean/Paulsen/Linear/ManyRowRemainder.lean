import Paulsen.Linear.ManyRowMoments

/-!
# The centred remainder estimate (`lem:remainder`)

Because `XᵀZ + ZᵀX = 0`, the constant part `c̄ = 1/(1+t²)` of the weights
`cᵢ = rᵢ/(1+t²rᵢ)` drops out of the cubic remainder. The fluctuating parts
`γᵢ = cᵢ - c̄` and `λᵢ = cᵢrᵢ - c̄` are controlled by the row deviation
`M = a ∑ᵢ (rᵢ² - 1)²`, which has bounded expectation.
-/

namespace Paulsen.Linear

open Paulsen
open scoped BigOperators

/-- Cauchy–Schwarz in the scaled form used below. -/
theorem abs_sum_mul_le_of_sq_sums {n : ℕ} (f g : Fin n → ℝ) (P M N : ℝ)
    (hP : 0 ≤ P) (hM : 0 ≤ M) (hN : 0 ≤ N)
    (hf : (∑ i, f i ^ 2) ≤ P * N) (hg : (∑ i, g i ^ 2) ≤ M * N) :
    |∑ i, f i * g i| ≤ Real.sqrt P * Real.sqrt M * N := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ f g
  have hf0 : 0 ≤ ∑ i, f i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  have hg0 : 0 ≤ ∑ i, g i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  have hprod : (∑ i, f i * g i) ^ 2 ≤ (Real.sqrt P * Real.sqrt M * N) ^ 2 := by
    calc _ ≤ (∑ i, f i ^ 2) * (∑ i, g i ^ 2) := hcs
      _ ≤ (P * N) * (M * N) := mul_le_mul hf hg hg0 (by positivity)
      _ = _ := by
        rw [mul_pow, mul_pow, Real.sq_sqrt hP, Real.sq_sqrt hM]; ring
  exact abs_le_of_sq_le_sq' hprod (by positivity) |> fun h => abs_le.mpr h

theorem centred_weight_sq_le (r t : ℝ) (hr : 0 ≤ r) :
    (r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2)) ^ 2 * r ≤ (r ^ 2 - 1) ^ 2 := by
  have hD1 : 1 ≤ 1 + t ^ 2 * r := by nlinarith [sq_nonneg t, mul_nonneg (sq_nonneg t) hr]
  have hD2 : 1 ≤ 1 + t ^ 2 := by nlinarith [sq_nonneg t]
  have heq : r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2) =
      (r - 1) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) := by
    field_simp; ring
  rw [heq, div_pow]
  have hD : 1 ≤ ((1 + t ^ 2 * r) * (1 + t ^ 2)) ^ 2 := by
    have := mul_le_mul hD1 hD2 (by norm_num) (by linarith)
    nlinarith
  have h1 : (r - 1) ^ 2 / ((1 + t ^ 2 * r) * (1 + t ^ 2)) ^ 2 ≤ (r - 1) ^ 2 :=
    div_le_self (sq_nonneg _) hD
  have h2 : r ≤ (r + 1) ^ 2 := by nlinarith
  calc _ ≤ (r - 1) ^ 2 * r := mul_le_mul_of_nonneg_right h1 hr
    _ ≤ (r - 1) ^ 2 * (r + 1) ^ 2 := mul_le_mul_of_nonneg_left h2 (sq_nonneg _)
    _ = _ := by ring

theorem centred_leverage_weight_sq_le (r t : ℝ) (hr : 0 ≤ r) :
    (r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2)) ^ 2 ≤ (r ^ 2 - 1) ^ 2 := by
  have hD1 : 1 ≤ 1 + t ^ 2 * r := by nlinarith [sq_nonneg t, mul_nonneg (sq_nonneg t) hr]
  have hD2 : 1 ≤ 1 + t ^ 2 := by nlinarith [sq_nonneg t]
  have heq : r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2) =
      ((r - 1) * (r + 1)) * ((1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + r) * (1 + t ^ 2))) := by
    field_simp; ring
  rw [heq, mul_pow]
  have hq0 : 0 ≤ (1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + r) * (1 + t ^ 2)) := by
    apply div_nonneg <;> positivity
  have hq1 : (1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + r) * (1 + t ^ 2)) ≤ 1 := by
    rw [div_le_one (by positivity)]
    nlinarith [mul_nonneg (mul_nonneg (sq_nonneg t) hr) hr, sq_nonneg t,
      mul_nonneg (sq_nonneg t) hr, mul_nonneg (mul_nonneg (sq_nonneg t) hr) (sq_nonneg t),
      mul_nonneg (mul_nonneg (mul_nonneg (sq_nonneg t) hr) (sq_nonneg t)) hr]
  have hsq : ((1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + r) * (1 + t ^ 2))) ^ 2 ≤ 1 := by
    nlinarith
  have : ((r - 1) * (r + 1)) ^ 2 = (r ^ 2 - 1) ^ 2 := by ring
  rw [this]
  calc _ ≤ (r ^ 2 - 1) ^ 2 * 1 := mul_le_mul_of_nonneg_left hsq (sq_nonneg _)
    _ = _ := by ring

theorem sum_row_products_eq_zero {n d : ℕ} (X Z : Frame n d)
    (hglobal : X.transpose * Z + Z.transpose * X = 0) (x : Fin d → ℝ) :
    (∑ i, (∑ j, X i j * x j) * (∑ j, Z i j * x j)) = 0 := by
  have hgram : (X + Z).transpose * (X + Z) = X.transpose * X + Z.transpose * Z := by
    have : (X + Z).transpose * (X + Z) =
        X.transpose * X + Z.transpose * Z + (X.transpose * Z + Z.transpose * X) := by
      simp only [Matrix.transpose_add, Matrix.add_mul, Matrix.mul_add]; abel
    rw [this, hglobal, add_zero]
  have hE : frameEnergy (X + Z) x = frameEnergy X x + frameEnergy Z x := by
    rw [frameEnergy_eq_matrixQuadratic, hgram, matrixQuadratic_add,
      ← frameEnergy_eq_matrixQuadratic, ← frameEnergy_eq_matrixQuadratic]
  have hexp : frameEnergy (X + Z) x = frameEnergy X x + frameEnergy Z x +
      2 * ∑ i, (∑ j, X i j * x j) * (∑ j, Z i j * x j) := by
    have hrow (i : Fin n) : (∑ j, (X + Z) i j * x j) =
        (∑ j, X i j * x j) + (∑ j, Z i j * x j) := by
      simp only [Matrix.add_apply, add_mul, Finset.sum_add_distrib]
    unfold frameEnergy
    simp_rw [hrow]
    rw [Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    ring
  linarith

/-- The centred remainder bound in quadratic-form language. -/
theorem tangentRemainder_centred_bound {n d : ℕ} (X Z : Frame n d)
    (a t PX QZ M : ℝ) (ha : 0 < a) (hPX : 0 ≤ PX) (hQZ : 0 ≤ QZ) (hM0 : 0 ≤ M)
    (hx : ∀ i, rowNormSq X i = a)
    (hXe : ∀ x, frameEnergy X x ≤ PX * vectorNormSq x)
    (hZe : ∀ x, frameEnergy Z x ≤ QZ * vectorNormSq x)
    (hglobal : X.transpose * Z + Z.transpose * X = 0)
    (hM : rowFourthDeviation a Z ≤ M) (x : Fin d → ℝ) :
    |matrixQuadratic (tangentRemainder X Z a t) x| ≤
      (2 * |t| ^ 3 * (Real.sqrt PX * Real.sqrt M) +
        t ^ 4 * (QZ + Real.sqrt QZ * Real.sqrt M + PX + Real.sqrt PX * Real.sqrt M)) *
        vectorNormSq x := by
  set N := vectorNormSq x
  have hN : 0 ≤ N := vectorNormSq_nonneg x
  set u : Fin n → ℝ := fun i => ∑ j, X i j * x j
  set v : Fin n → ℝ := fun i => ∑ j, Z i j * x j
  set r : Fin n → ℝ := fun i => tangentRatio a Z i
  set cb : ℝ := 1 / (1 + t ^ 2)
  set γ : Fin n → ℝ := fun i => r i / (1 + t ^ 2 * r i) - cb
  set lam : Fin n → ℝ := fun i => r i / (1 + t ^ 2 * r i) * r i - cb
  have hr0 (i : Fin n) : 0 ≤ r i := tangentRatio_nonneg a ha Z i
  have hu2 : (∑ i, u i ^ 2) ≤ PX * N := hXe x
  have hv2 : (∑ i, v i ^ 2) ≤ QZ * N := hZe x
  have huv : (∑ i, u i * v i) = 0 := sum_row_products_eq_zero X Z hglobal x
  have hui (i : Fin n) : u i ^ 2 ≤ a * N := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (X i) x
    change _ ≤ rowNormSq X i * vectorNormSq x at h
    rwa [hx] at h
  have hvi (i : Fin n) : v i ^ 2 ≤ a * r i * N := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (Z i) x
    change _ ≤ rowNormSq Z i * vectorNormSq x at h
    have heq : a * r i = rowNormSq Z i := by
      simp only [r, tangentRatio]; field_simp
    rwa [heq]
  have hMsum : a * ∑ i, ((r i) ^ 2 - 1) ^ 2 ≤ M := hM
  have hγv : (∑ i, (γ i * v i) ^ 2) ≤ M * N := by
    calc (∑ i, (γ i * v i) ^ 2) ≤ ∑ i, (γ i) ^ 2 * (a * r i * N) := by
          apply Finset.sum_le_sum; intro i _
          rw [mul_pow]; exact mul_le_mul_of_nonneg_left (hvi i) (sq_nonneg _)
      _ = (a * ∑ i, (γ i) ^ 2 * r i) * N := by
          rw [Finset.mul_sum, Finset.sum_mul]; apply Finset.sum_congr rfl; intro i _; ring
      _ ≤ (a * ∑ i, ((r i) ^ 2 - 1) ^ 2) * N := by
          apply mul_le_mul_of_nonneg_right _ hN
          apply mul_le_mul_of_nonneg_left _ ha.le
          exact Finset.sum_le_sum fun i _ => centred_weight_sq_le (r i) t (hr0 i)
      _ ≤ M * N := mul_le_mul_of_nonneg_right hMsum hN
  have hlu : (∑ i, (lam i * u i) ^ 2) ≤ M * N := by
    calc (∑ i, (lam i * u i) ^ 2) ≤ ∑ i, (lam i) ^ 2 * (a * N) := by
          apply Finset.sum_le_sum; intro i _
          rw [mul_pow]; exact mul_le_mul_of_nonneg_left (hui i) (sq_nonneg _)
      _ = (a * ∑ i, (lam i) ^ 2) * N := by
          rw [Finset.mul_sum, Finset.sum_mul]; apply Finset.sum_congr rfl; intro i _; ring
      _ ≤ (a * ∑ i, ((r i) ^ 2 - 1) ^ 2) * N := by
          apply mul_le_mul_of_nonneg_right _ hN
          apply mul_le_mul_of_nonneg_left _ ha.le
          exact Finset.sum_le_sum fun i _ => centred_leverage_weight_sq_le (r i) t (hr0 i)
      _ ≤ M * N := mul_le_mul_of_nonneg_right hMsum hN
  -- the three centred sums
  have hA : |∑ i, u i * (γ i * v i)| ≤ Real.sqrt PX * Real.sqrt M * N :=
    abs_sum_mul_le_of_sq_sums u (fun i => γ i * v i) PX M N hPX hM0 hN hu2 hγv
  have hB : |∑ i, (γ i * v i) * v i| ≤ Real.sqrt M * Real.sqrt QZ * N :=
    abs_sum_mul_le_of_sq_sums (fun i => γ i * v i) v M QZ N hM0 hQZ hN hγv hv2
  have hC : |∑ i, (lam i * u i) * u i| ≤ Real.sqrt M * Real.sqrt PX * N :=
    abs_sum_mul_le_of_sq_sums (fun i => lam i * u i) u M PX N hM0 hPX hN hlu hu2
  have hcb0 : 0 ≤ cb := by positivity
  have hcb1 : cb ≤ 1 := by
    simp only [cb]; rw [div_le_one (by positivity)]; nlinarith [sq_nonneg t]
  have hv0 : 0 ≤ ∑ i, v i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  have hu0 : 0 ≤ ∑ i, u i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  -- exact rewriting of the remainder
  have hform : matrixQuadratic (tangentRemainder X Z a t) x =
      -(2 * t ^ 3) * (∑ i, u i * (γ i * v i)) -
        t ^ 4 * (cb * (∑ i, v i ^ 2) + (∑ i, (γ i * v i) * v i) -
          cb * (∑ i, u i ^ 2) - (∑ i, (lam i * u i) * u i)) := by
    rw [tangentRemainder_quadratic]
    set A : Fin n → ℝ := fun i => -(2 * t ^ 3) * (u i * (γ i * v i)) -
      t ^ 4 * (cb * v i ^ 2 + (γ i * v i) * v i - cb * u i ^ 2 - (lam i * u i) * u i) with hAdef
    have hRHS : -(2 * t ^ 3) * (∑ i, u i * (γ i * v i)) -
        t ^ 4 * (cb * (∑ i, v i ^ 2) + (∑ i, (γ i * v i) * v i) -
          cb * (∑ i, u i ^ 2) - (∑ i, (lam i * u i) * u i)) = ∑ i, A i := by
      simp only [hAdef, Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [hRHS]
    calc _ = ∑ i, (A i + (-(2 * t ^ 3) * cb) * (u i * v i)) := by
          apply Finset.sum_congr rfl; intro i _
          simp only [hAdef, γ, lam, u, v, r]
          ring
      _ = (∑ i, A i) + (-(2 * t ^ 3) * cb) * ∑ i, u i * v i := by
          rw [Finset.sum_add_distrib, Finset.mul_sum]
      _ = ∑ i, A i := by rw [huv]; ring
  rw [hform]
  have ht3 : 0 ≤ |t| ^ 3 := by positivity
  have ht4 : 0 ≤ t ^ 4 := by positivity
  have hcube : |-(2 * t ^ 3) * (∑ i, u i * (γ i * v i))| ≤
      2 * |t| ^ 3 * (Real.sqrt PX * Real.sqrt M * N) := by
    rw [abs_mul, abs_neg, abs_mul, abs_pow, abs_two]
    exact mul_le_mul_of_nonneg_left hA (by positivity)
  have hinner : |cb * (∑ i, v i ^ 2) + (∑ i, (γ i * v i) * v i) -
        cb * (∑ i, u i ^ 2) - (∑ i, (lam i * u i) * u i)| ≤
      QZ * N + Real.sqrt M * Real.sqrt QZ * N + PX * N + Real.sqrt M * Real.sqrt PX * N := by
    have h1 : cb * (∑ i, v i ^ 2) ≤ QZ * N := by nlinarith
    have h2 : cb * (∑ i, u i ^ 2) ≤ PX * N := by nlinarith
    have h1' : 0 ≤ cb * (∑ i, v i ^ 2) := mul_nonneg hcb0 hv0
    have h2' : 0 ≤ cb * (∑ i, u i ^ 2) := mul_nonneg hcb0 hu0
    obtain ⟨hB1, hB2⟩ := abs_le.mp hB
    obtain ⟨hC1, hC2⟩ := abs_le.mp hC
    apply abs_le.mpr
    constructor <;> nlinarith [mul_nonneg (mul_nonneg (Real.sqrt_nonneg M) (Real.sqrt_nonneg QZ)) hN,
      mul_nonneg (mul_nonneg (Real.sqrt_nonneg M) (Real.sqrt_nonneg PX)) hN,
      mul_nonneg hQZ hN, mul_nonneg hPX hN]
  have hquart : |t ^ 4 * (cb * (∑ i, v i ^ 2) + (∑ i, (γ i * v i) * v i) -
        cb * (∑ i, u i ^ 2) - (∑ i, (lam i * u i) * u i))| ≤
      t ^ 4 * (QZ * N + Real.sqrt M * Real.sqrt QZ * N + PX * N +
        Real.sqrt M * Real.sqrt PX * N) := by
    rw [abs_mul, abs_of_nonneg ht4]
    exact mul_le_mul_of_nonneg_left hinner ht4
  calc _ ≤ |-(2 * t ^ 3) * (∑ i, u i * (γ i * v i))| +
        |t ^ 4 * (cb * (∑ i, v i ^ 2) + (∑ i, (γ i * v i) * v i) -
          cb * (∑ i, u i ^ 2) - (∑ i, (lam i * u i) * u i))| := abs_sub _ _
    _ ≤ 2 * |t| ^ 3 * (Real.sqrt PX * Real.sqrt M * N) +
        t ^ 4 * (QZ * N + Real.sqrt M * Real.sqrt QZ * N + PX * N +
          Real.sqrt M * Real.sqrt PX * N) := add_le_add hcube hquart
    _ = _ := by ring

/-- Near-Parseval property of the row-normalised seed from the centred remainder. -/
theorem tangentSeed_isNearlyParseval_centred {n d : ℕ}
    (X Z : Frame n d) (a t η q QZ M : ℝ) (ha : 0 < a) (hη : 0 ≤ η)
    (hQZ : 0 ≤ QZ) (hM0 : 0 ≤ M)
    (hx : ∀ i, rowNormSq X i = a) (hX : IsNearlyParseval η X)
    (hglobal : X.transpose * Z + Z.transpose * X = 0)
    (hQ : ∀ x, |matrixQuadratic (tangentQuadratic X Z a) x| ≤ q * vectorNormSq x)
    (hZe : ∀ x, frameEnergy Z x ≤ QZ * vectorNormSq x)
    (hM : rowFourthDeviation a Z ≤ M) :
    IsNearlyParseval (η + t ^ 2 * q +
      (2 * |t| ^ 3 * (Real.sqrt (1 + η) * Real.sqrt M) +
        t ^ 4 * (QZ + Real.sqrt QZ * Real.sqrt M + (1 + η) +
          Real.sqrt (1 + η) * Real.sqrt M))) (tangentSeed X Z a t) := by
  intro x
  have hR := tangentRemainder_centred_bound X Z a t (1 + η) QZ M ha (by linarith) hQZ hM0 hx
    (fun x => (hX x).2) hZe hglobal hM x
  have hQt := mul_le_mul_of_nonneg_left (hQ x) (sq_nonneg t)
  have hform : frameEnergy (tangentSeed X Z a t) x =
      frameEnergy X x + t ^ 2 * matrixQuadratic (tangentQuadratic X Z a) x +
        matrixQuadratic (tangentRemainder X Z a t) x := by
    rw [frameEnergy_eq_matrixQuadratic,
      tangentSeed_frameOperator_expansion X Z a t ha hglobal,
      matrixQuadratic_add, matrixQuadratic_add, matrixQuadratic_smul,
      ← frameEnergy_eq_matrixQuadratic]
  obtain ⟨hl, hu⟩ := hX x
  obtain ⟨hrl, hru⟩ := abs_le.mp hR
  have hql := mul_le_mul_of_nonneg_left (neg_abs_le
    (matrixQuadratic (tangentQuadratic X Z a) x)) (sq_nonneg t)
  have hqu := mul_le_mul_of_nonneg_left (le_abs_self
    (matrixQuadratic (tangentQuadratic X Z a) x)) (sq_nonneg t)
  rw [hform]
  constructor <;> nlinarith

/-- The centred spectral estimate for the actual conditioned seed. -/
theorem conditionedSeed_nearParseval_centred {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (hX : IsEqualNorm X)
    (η t b QZ M : ℝ) (hη : 0 ≤ η) (hQZ : 0 ≤ QZ) (hM0 : 0 ≤ M)
    (hXp : IsNearlyParseval η X) (g : FrameVector n d)
    (hb : ‖conditionedFluctuation X g‖ ≤ b)
    (hZe : ∀ x, frameEnergy (conditionedNoise X g) x ≤ QZ * vectorNormSq x)
    (hM : rowFourthDeviation ((d : ℝ) / n) (conditionedNoise X g) ≤ M) :
    IsEqualNorm (conditionedSeed X t g) ∧
      IsNearlyParseval (η + t ^ 2 * (η + (d : ℝ) ^ 2 / n + b) +
      (2 * |t| ^ 3 * (Real.sqrt (1 + η) * Real.sqrt M) +
        t ^ 4 * (QZ + Real.sqrt QZ * Real.sqrt M + (1 + η) +
          Real.sqrt (1 + η) * Real.sqrt M))) (conditionedSeed X t g) := by
  have ha : 0 < (d : ℝ) / n := by positivity
  have hc := tangentNoiseFactor_constraints X g
  refine ⟨tangentSeed_isEqualNorm X _ t ha hX hc.1, ?_⟩
  exact tangentSeed_isNearlyParseval_centred X _ _ t η _ QZ M ha hη hQZ hM0 hX hXp hc.2
    (conditionedQuadratic_bound X hn hd hX η b hXp g hb) hZe hM

end Paulsen.Linear
