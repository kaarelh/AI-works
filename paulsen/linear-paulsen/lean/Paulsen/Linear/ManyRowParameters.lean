import Paulsen.Linear.ManyRowSample

/-!
# Explicit numerical parameters for the many-row seed

The amplitude is `t = √(K η)` with `K = 10¹⁴`. Unlike the old huge-row
parameters, the spectral cap `η ≤ 10⁻⁶⁰` does not depend on `d`: the centred
remainder is `O(t³)` with an absolute constant.
-/

namespace Paulsen.Linear

open Paulsen

noncomputable section

/-- Small-ball parameter of the dense reference graph. -/
def manyRowH : ℝ := 1 / 2000
/-- Amplitude factor: `t² = K η`. -/
def manyRowK : ℝ := 10 ^ 14
/-- Row-count factor: `n ≥ B d²`. -/
def manyRowB : ℝ := 10 ^ 40
/-- Absolute cap on the spectral error. -/
def manyRowC : ℝ := 1 / 10 ^ 60
/-- Final cost constant. -/
def manyRowCost : ℝ := 1000 * manyRowK
/-- Square of the net bound `128` on `‖Z‖`, `‖Z₀‖`. -/
def manyRowQ : ℝ := 128 ^ 2

theorem manyRowB_pos : 0 < manyRowB := by norm_num [manyRowB]
theorem manyRowC_pos : 0 < manyRowC := by norm_num [manyRowC]
theorem manyRowCost_nonneg : 0 ≤ manyRowCost := by norm_num [manyRowCost, manyRowK]

def manyRowDelta (t : ℝ) : ℝ := t ^ 2 / 10 ^ 12

def manyRowGamma (n d : ℕ) (t : ℝ) : ℝ := rowSeedThreshold n d t manyRowH

def manyRowRho (n d : ℕ) (t : ℝ) : ℝ := manyRowGamma n d t / 100

def manyRowCoupling (n d : ℕ) : ℝ := 100 * ((d : ℝ) ^ 2 / n)

def manyRowFluctuation (n d : ℕ) : ℝ := Real.sqrt (800 * (d : ℝ) ^ 2 / n)

def manyRowMoment (n d : ℕ) : ℝ := 100 * (12 * (1 + (d : ℝ) ^ 2 / n) + 120024)

def manyRowRemainder (n d : ℕ) (η t : ℝ) : ℝ :=
  2 * |t| ^ 3 * (Real.sqrt (1 + η) * Real.sqrt (manyRowMoment n d)) +
    t ^ 4 * (manyRowQ + Real.sqrt manyRowQ * Real.sqrt (manyRowMoment n d) + (1 + η) +
      Real.sqrt (1 + η) * Real.sqrt (manyRowMoment n d))

def manyRowGramError (n d : ℕ) (η t : ℝ) : ℝ :=
  2 * (2 * (1 + η) + 2 * t ^ 2 * manyRowQ + 1 + manyRowDelta t) * t ^ 2 * manyRowCoupling n d

/-- Every numerical hypothesis used by the deterministic many-row assembly. -/
structure ManyRowScalarBounds (n d : ℕ) (η t : ℝ) : Prop where
  n_ge : 200 ≤ n
  d_le_n : d ≤ n
  t_pos : 0 < t
  t_le : t ≤ 1 / 100
  small_ball : manyRowH ≤ 1 / (400 * Real.exp 1)
  covariance : η + t ^ 2 * (η + (d : ℝ) ^ 2 / n + manyRowFluctuation n d) +
    manyRowRemainder n d η t ≤ manyRowDelta t
  delta_pos : 0 < manyRowDelta t
  delta_half : manyRowDelta t ≤ 1 / 2
  gamma_pos : 0 < manyRowGamma n d t
  gamma_le : manyRowGamma n d t ≤ (d : ℝ) / n
  rho_pos : 0 < manyRowRho n d t
  row : 12 * ((d : ℝ) / n) * (manyRowDelta t) ^ 2 + 2 * manyRowRho n d t ≤
    manyRowGamma n d t / 20
  count : 10 * manyRowGramError n d η t ≤ manyRowRho n d t * n
  leverage : (2 * ((d : ℝ) / n) / manyRowRho n d t) * manyRowGramError n d η t ≤ 1 / 4
  small : 224 * manyRowDelta t * ((d : ℝ) / n) ≤ manyRowGamma n d t
  cost : 2 * t ^ 2 * (100 * (d : ℝ)) + 4 * (manyRowDelta t) ^ 2 * d +
    64 * manyRowDelta t * d ≤ manyRowCost * η * d

theorem manyRowGamma_eq (n d : ℕ) (t : ℝ) :
    manyRowGamma n d t = t ^ 2 * ((d : ℝ) / n) / 16000000 := by
  unfold manyRowGamma rowSeedThreshold manyRowH
  ring

set_option maxHeartbeats 1000000 in
/-- The chosen parameters satisfy all scalar budgets at `t = √(K η)`. -/
theorem manyRowScalarBounds {n d : ℕ} (hd : 0 < d) {η : ℝ}
    (hη : 0 < η) (hηmax : η ≤ manyRowC)
    (hnlarge : manyRowB * (d : ℝ) ^ 2 ≤ n) :
    ManyRowScalarBounds n d η (Real.sqrt (manyRowK * η)) := by
  set t := Real.sqrt (manyRowK * η) with ht_def
  let D : ℝ := d
  let N : ℝ := n
  let T : ℝ := t ^ 2
  let q : ℝ := D ^ 2 / N
  let a : ℝ := D / N
  have hK : 0 < manyRowK := by norm_num [manyRowK]
  have ht : 0 < t := Real.sqrt_pos.mpr (mul_pos hK hη)
  have hTeq : T = 10 ^ 14 * η := by
    dsimp [T]; rw [ht_def, Real.sq_sqrt (mul_pos hK hη).le]; rfl
  have hD : 1 ≤ D := by dsimp [D]; exact_mod_cast hd
  have hDpos : 0 < D := by linarith only [hD]
  have hDsq : 1 ≤ D ^ 2 := by nlinarith only [hD]
  have hDsqD : D ≤ D ^ 2 := by nlinarith only [hD]
  have hn200 : 200 ≤ n := two_hundred_le_of_huge_rows hd manyRowB (by norm_num [manyRowB]) hnlarge
  have hN : 0 < N := by dsimp [N]; exact_mod_cast (by omega : 0 < n)
  have hηtiny : η ≤ 1 / (10 : ℝ) ^ 60 := hηmax
  have hq : q ≤ 1 / (10 : ℝ) ^ 40 := by
    apply (div_le_iff₀ hN).mpr
    change D ^ 2 ≤ _
    have : (10 : ℝ) ^ 40 * D ^ 2 ≤ N := hnlarge
    nlinarith only [this]
  have hq0 : 0 ≤ q := by dsimp [q]; positivity
  have hNlarge : 10 ^ 40 * D ^ 2 ≤ N := hnlarge
  have hDN : D ≤ N := by nlinarith only [hNlarge, hDsqD, hD]
  have hdn : d ≤ n := by dsimp [D, N] at hDN; exact_mod_cast hDN
  have hTpos : 0 < T := sq_pos_of_pos ht
  have hT : T ≤ 1 / (10 : ℝ) ^ 46 := by rw [hTeq]; nlinarith only [hηtiny]
  have httiny : t ≤ 1 / (10 : ℝ) ^ 23 := by
    by_contra hc
    push Not at hc
    have : (1 / (10 : ℝ) ^ 23) ^ 2 < T := by
      dsimp [T]; exact pow_lt_pow_left₀ hc (by positivity) (by norm_num)
    norm_num at this hT
    linarith
  have hT1 : T ≤ 1 := by norm_num at hT ⊢; linarith only [hT]
  have hηT : η = T / (10 : ℝ) ^ 14 := by rw [hTeq]; ring
  have hb : manyRowFluctuation n d ≤ 1 / (10 : ℝ) ^ 18 := by
    have hsq : (manyRowFluctuation n d) ^ 2 = 800 * q := by
      unfold manyRowFluctuation
      rw [Real.sq_sqrt (by positivity)]
      dsimp [q, D, N]
      ring
    have hpos : 0 ≤ manyRowFluctuation n d := Real.sqrt_nonneg _
    nlinarith only [hsq, hpos, hq]
  -- the centred remainder is O(t³) with an absolute constant
  have hsqrtη : Real.sqrt (1 + η) ≤ 2 := by
    rw [Real.sqrt_le_left (by norm_num)]; linarith only [hηtiny]
  have hsqrtη0 : 0 ≤ Real.sqrt (1 + η) := Real.sqrt_nonneg _
  have hM : manyRowMoment n d ≤ 5000 ^ 2 := by
    unfold manyRowMoment
    change 100 * (12 * (1 + q) + 120024) ≤ _
    nlinarith only [hq]
  have hsqrtM : Real.sqrt (manyRowMoment n d) ≤ 5000 := by
    rw [Real.sqrt_le_left (by norm_num)]; exact hM
  have hsqrtM0 : 0 ≤ Real.sqrt (manyRowMoment n d) := Real.sqrt_nonneg _
  have hsqrtQ : Real.sqrt manyRowQ = 128 := by
    unfold manyRowQ; exact Real.sqrt_sq (by norm_num)
  have hr : manyRowRemainder n d η t ≤ T / (10 : ℝ) ^ 16 := by
    unfold manyRowRemainder
    rw [abs_of_pos ht, hsqrtQ]
    have hA : Real.sqrt (1 + η) * Real.sqrt (manyRowMoment n d) ≤ 10000 := by
      nlinarith only [hsqrtη, hsqrtη0, hsqrtM, hsqrtM0]
    have hA0 : 0 ≤ Real.sqrt (1 + η) * Real.sqrt (manyRowMoment n d) := by positivity
    have hBm : manyRowQ + 128 * Real.sqrt (manyRowMoment n d) + (1 + η) +
        Real.sqrt (1 + η) * Real.sqrt (manyRowMoment n d) ≤ 10 ^ 6 := by
      unfold manyRowQ
      nlinarith only [hA, hsqrtM, hηtiny]
    have hBm0 : 0 ≤ manyRowQ + 128 * Real.sqrt (manyRowMoment n d) + (1 + η) +
        Real.sqrt (1 + η) * Real.sqrt (manyRowMoment n d) := by
      unfold manyRowQ; positivity
    have h3 : t ^ 3 ≤ T / (10 : ℝ) ^ 23 := by
      dsimp [T]
      have := mul_le_mul_of_nonneg_left httiny (sq_nonneg t)
      nlinarith only [this]
    have h4 : t ^ 4 ≤ T / (10 : ℝ) ^ 46 := by
      dsimp [T] at hT ⊢
      have := mul_le_mul_of_nonneg_left hT (sq_nonneg t)
      nlinarith only [this]
    have ht3 : 0 ≤ t ^ 3 := by positivity
    have ht4 : 0 ≤ t ^ 4 := by positivity
    have e1 := mul_le_mul h3 hA hA0 (by positivity)
    have e2 := mul_le_mul h4 hBm hBm0 (by positivity)
    nlinarith only [e1, e2, hTpos]
  have hδ : manyRowDelta t = T / (10 : ℝ) ^ 12 := rfl
  have ha : 0 < a := div_pos hDpos hN
  have hδ0 : 0 < manyRowDelta t := by rw [hδ]; positivity
  have hδ1 : manyRowDelta t ≤ 1 / 2 := by rw [hδ]; nlinarith only [hT1]
  have hγ : manyRowGamma n d t = T * a / 16000000 := manyRowGamma_eq n d t
  have hρ : manyRowRho n d t = T * a / 1600000000 := by
    rw [manyRowRho, hγ]
    ring
  have hTq : T * q ≤ 1 / (10 : ℝ) ^ 40 := by
    have h := mul_le_mul_of_nonneg_right hT1 hq0
    nlinarith only [h, hq]
  have hfactor : 2 * (1 + η) + 2 * T * manyRowQ + 1 + manyRowDelta t ≤ 10 := by
    unfold manyRowQ
    nlinarith only [hηtiny, hT, hδ1]
  have hBerr : manyRowGramError n d η t ≤ 2000 * T * q := by
    have hform : manyRowGramError n d η t =
        2 * (2 * (1 + η) + 2 * T * manyRowQ + 1 + manyRowDelta t) * T * (100 * q) := by
      unfold manyRowGramError manyRowCoupling
      dsimp [T, D, N, q]
    rw [hform]
    nlinarith only [mul_nonneg (sub_nonneg.mpr hfactor) (mul_nonneg hTpos.le hq0)]
  have hT2 : T ^ 2 ≤ T := by nlinarith only [hT1, hTpos]
  have hTa2 := mul_le_mul_of_nonneg_right hT2 ha.le
  refine ⟨hn200, hdn, ht, ?_, ?_, ?_, hδ0, hδ1, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · nlinarith only [httiny]
  · apply (le_div_iff₀ (show 0 < 400 * Real.exp (1 : ℝ) by positivity)).mpr
    unfold manyRowH
    nlinarith only [Real.exp_one_lt_three]
  · have hsum : η + q + manyRowFluctuation n d ≤ 2 / (10 : ℝ) ^ 18 := by
      nlinarith only [hηtiny, hq, hb]
    have hprod := mul_le_mul_of_nonneg_left hsum hTpos.le
    change η + T * (η + q + manyRowFluctuation n d) + manyRowRemainder n d η t ≤ _
    rw [hδ]
    have hη14 : η ≤ T / (10 : ℝ) ^ 14 := hηT.le
    nlinarith only [hprod, hr, hη14, hTpos]
  · rw [hγ]
    positivity
  · rw [hγ]
    change T * a / 16000000 ≤ a
    nlinarith only [mul_nonneg (sub_nonneg.mpr hT1) ha.le, ha]
  · rw [hρ]
    positivity
  · rw [hδ, hγ, hρ]
    change 12 * a * (T / (10 : ℝ) ^ 12) ^ 2 + 2 * (T * a / 1600000000) ≤ T * a / 16000000 / 20
    nlinarith only [mul_pos hTpos ha, hTa2]
  · have haN : a * N = D := by dsimp [a]; exact div_mul_cancel₀ _ hN.ne'
    have hqD : 20000 * q ≤ D / 1600000000 := by nlinarith only [hq, hD]
    have hp := mul_le_mul_of_nonneg_left hqD hTpos.le
    rw [hρ]
    change 10 * manyRowGramError n d η t ≤ T * a / 1600000000 * N
    have heq : T * a / 1600000000 * N = T * D / 1600000000 := by
      calc
        _ = T * (a * N) / 1600000000 := by ring
        _ = _ := by rw [haN]
    rw [heq]
    nlinarith only [hp, hBerr]
  · rw [hρ]
    change (2 * a / (T * a / 1600000000)) * manyRowGramError n d η t ≤ 1 / 4
    have hmult := mul_le_mul_of_nonneg_left hBerr
      (show 0 ≤ 2 * a / (T * a / 1600000000) by positivity)
    have heq : (2 * a / (T * a / 1600000000)) * (2000 * T * q) = 6400000000000 * q := by
      field_simp [hTpos.ne', ha.ne']
      ring
    rw [heq] at hmult
    nlinarith only [hmult, hq]
  · rw [hδ, hγ]
    change 224 * (T / (10 : ℝ) ^ 12) * a ≤ T * a / 16000000
    nlinarith only [mul_nonneg hTpos.le ha.le]
  · have hδ2 : (manyRowDelta t) ^ 2 ≤ manyRowDelta t := by nlinarith only [hδ0, hδ1]
    have hcost : 2 * t ^ 2 * (100 * (d : ℝ)) + 4 * (manyRowDelta t) ^ 2 * d +
        64 * manyRowDelta t * d ≤ 201 * T * D := by
      have h := mul_le_mul_of_nonneg_right hδ2 hDpos.le
      rw [hδ] at h
      change 2 * T * (100 * D) + 4 * (manyRowDelta t) ^ 2 * D + 64 * manyRowDelta t * D ≤ _
      rw [hδ]
      nlinarith only [h, mul_nonneg hTpos.le hDpos.le]
    unfold manyRowCost manyRowK
    change _ ≤ 1000 * 10 ^ 14 * η * D
    rw [hTeq] at hcost
    nlinarith only [hcost, mul_pos hη hDpos]

end

end Paulsen.Linear
