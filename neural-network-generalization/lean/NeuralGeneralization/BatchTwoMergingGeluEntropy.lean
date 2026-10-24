import NeuralGeneralization.BatchTwoMergingGeluBudgetBounds

/-! Explicit quadratic-width, degree-nine entropy envelope. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem geluMainGridRadius_le {d C r : ℕ} {S ε : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (2*C:ℝ)≤2*S) (hlogε : -Real.log (ε/4)≤S)
    (hε : 0<ε) (hε1 : ε≤1) :
    1+Real.sqrt (geluMainEnergyBound d C r ε)≤40000000000*(C:ℝ)*S^4 := by
  have hJ := geluMainEnergyBound_le hC hS hd hr hlogC hlogε hε hε1
  have hJ0 := geluMainEnergyBound_nonneg (d:=d) (C:=C) (r:=r) hε hε1
  have hs := Real.sq_sqrt hJ0
  have hs0 := Real.sqrt_nonneg (geluMainEnergyBound d C r ε)
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS4 : 1≤S^4 := one_le_pow₀ (by linarith : 1≤S)
  have hCS := mul_le_mul_of_nonneg_left hS4 (Nat.cast_nonneg C : (0:ℝ)≤C)
  nlinarith [sq_nonneg (Real.sqrt (geluMainEnergyBound d C r ε)-1)]

theorem geluGrid_log_card_le {d Q r : ℕ} {R S : ℝ}
    (hR : 1≤R) (hS : 2≤S) (hr : (r:ℝ)+2≤S)
    (hlR : Real.log R≤60000000000*S)
    (hlA : Real.log (geluGridAmplification d Q R)≤80000000000*S) :
    Real.log ((2*geluGridResolution d Q r R+1:ℕ):ℝ)≤200000000000*S^2 := by
  let A := geluGridAmplification d Q R
  let T := 64*R*(r+2)*A^(r+2)
  have hA : 1≤A := (geluGridAmplification_bounds d Q hR).1
  have hRp : 0<R := by linarith
  have hAp : 0<A := by linarith
  have hrp : (0:ℝ)<r+2 := by positivity
  have hT1 : 1≤T := by
    have hp := one_le_pow₀ hA (n:=r+2)
    have hm := one_le_mul_of_one_le_of_one_le hR hp
    dsimp [T]
    nlinarith [(Nat.cast_nonneg r : (0:ℝ)≤r)]
  have hceil := Nat.ceil_lt_add_one (by linarith : 0≤T)
  have hcount : ((2*geluGridResolution d Q r R+1:ℕ):ℝ)≤5*T := by
    unfold geluGridResolution
    change ((2*⌈T⌉₊+1:ℕ):ℝ)≤_
    push_cast
    linarith
  have hpos : (0:ℝ)<(2*geluGridResolution d Q r R+1:ℕ) := by positivity
  have hlog := Real.log_le_log hpos hcount
  have hid : Real.log (5*T)=Real.log 320+Real.log R+Real.log ((r:ℝ)+2)+
      (r+2:ℕ)*Real.log A := by
    have he : 5*T=(320*R*((r:ℝ)+2))*A^(r+2) := by dsimp [T]; ring
    rw [he,Real.log_mul (by positivity) (pow_ne_zero _ hAp.ne'),
      Real.log_mul (by positivity) hrp.ne',Real.log_mul (by norm_num) hRp.ne',Real.log_pow]
  rw [hid] at hlog
  have hl160 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<320)
  have hlr := Real.log_le_sub_one_of_pos hrp
  have hla0 : 0≤Real.log A := Real.log_nonneg hA
  have hmul := mul_le_mul hr hlA hla0 (by linarith : 0≤S)
  change Real.log A≤80000000000*S at hlA
  change ((r:ℝ)+2)*Real.log A≤S*(80000000000*S) at hmul
  push_cast at hlog ⊢
  nlinarith [sq_nonneg (S-1)]

theorem geluMainGrid_log_card_le {d C r : ℕ} {S ε : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (2*C:ℝ)≤2*S) (hlogε : -Real.log (ε/4)≤S)
    (hε : 0<ε) (hε1 : ε≤1) :
    Real.log (Fintype.card (GeluMainGridCode d C r ε):ℝ)≤
      10000000000000000000000000000*(C:ℝ)^2*S^9 := by
  let Q := geluMainPopulationBound d C r ε
  let R := 1+Real.sqrt (geluMainEnergyBound d C r ε)
  have hR : 1≤R := by dsimp [R]; linarith [Real.sqrt_nonneg (geluMainEnergyBound d C r ε)]
  have hRp : 0<R := by linarith
  have hQ := geluMainPopulationBound_le hC hS hd hr hlogC hlogε hε hε1
  have hRR := geluMainGridRadius_le hC hS hd hr hlogC hlogε hε hε1
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hC0 : (0:ℝ)≤C := Nat.cast_nonneg _
  have hS1 : 1≤S := by linarith
  have hS0 : 0≤S := by linarith
  have hS3 : S≤S^3 := by simpa using power_mono_in_exponent hS1 (show 1≤3 by omega)
  have hCS3 := mul_le_mul_of_nonneg_right hC1 (pow_nonneg hS0 3)
  have hCS4 := mul_le_mul_of_nonneg_right hC1 (pow_nonneg hS0 4)
  have hS4 : 1≤S^4 := one_le_pow₀ hS1
  have hfirst : (d:ℝ)+1+Q≤60000000*(C:ℝ)*S^3 := by
    change (Q:ℝ)≤40000000*(C:ℝ)*S^3 at hQ
    nlinarith
  have hsecond : R+1≤60000000000*(C:ℝ)*S^4 := by
    change R≤40000000000*(C:ℝ)*S^4 at hRR
    nlinarith
  have hlogCsmall : Real.log (C:ℝ)≤2*S :=
    (Real.log_le_log (by exact_mod_cast hC : (0:ℝ)<C) (by nlinarith : (C:ℝ)≤2*C)).trans hlogC
  have hlR0 := log_le_of_monomial_bound 4 hRp (by norm_num : (1:ℝ)≤40000000000)
    hC1 hS1 hlogCsmall hRR
  have hlR : Real.log R≤60000000000*S := by norm_num only [Nat.cast_ofNat] at hlR0; nlinarith
  have hlfirst := log_le_of_monomial_bound 3 (by positivity : (0:ℝ)<d+1+Q)
    (by norm_num : (1:ℝ)≤60000000) hC1 hS1 hlogCsmall hfirst
  have hlsecond := log_le_of_monomial_bound 4 (by linarith : 0<R+1)
    (by norm_num : (1:ℝ)≤60000000000) hC1 hS1 hlogCsmall hsecond
  have hlA : Real.log (geluGridAmplification d Q R)≤80000000000*S := by
    unfold geluGridAmplification
    rw [Real.log_mul (by positivity : (4*(d+1+Q):ℝ)≠0) (by linarith : R+1≠0),
      Real.log_mul (by norm_num : (4:ℝ)≠0) (by positivity : (d+1+Q:ℝ)≠0)]
    have hl4 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<4)
    norm_num only [Nat.cast_ofNat] at hlfirst hlsecond
    linarith
  have hloggrid := geluGrid_log_card_le hR hS hr hlR hlA
  have hP : ((Q*(d+2)+r*Q^2+(r+1)*Q:ℕ):ℝ)≤3000000000000000*(C:ℝ)^2*S^7 := by
    have hQ0 : (0:ℝ)≤Q := Nat.cast_nonneg _
    have hQsq : (Q:ℝ)^2≤(40000000*(C:ℝ)*S^3)^2 :=
      pow_le_pow_left₀ hQ0 hQ 2
    have hfirstmul := mul_le_mul hQ hd (by positivity : (0:ℝ)≤d+2)
      (by positivity : 0≤40000000*(C:ℝ)*S^3)
    have hsecondmul := mul_le_mul (show (r:ℝ)≤S by linarith) hQsq
      (sq_nonneg (Q:ℝ)) hS0
    have hthirdmul := mul_le_mul (show (r:ℝ)+1≤S by linarith) hQ
      hQ0 hS0
    have hC2 : (C:ℝ)≤(C:ℝ)^2 := by nlinarith
    have hS47 : S^4≤S^7 := power_mono_in_exponent hS1 (by omega)
    have hCS47 := mul_le_mul hC2 hS47 (pow_nonneg hS0 4) (sq_nonneg (C:ℝ))
    push_cast
    nlinarith
  change Real.log (Fintype.card (GeluGridCode d Q r (geluGridResolution d Q r R)):ℝ)≤_
  rw [geluGridCode_card, Nat.cast_pow, Real.log_pow]
  have hP0 : (0:ℝ)≤(Q*(d+2)+r*Q^2+(r+1)*Q:ℕ) := Nat.cast_nonneg _
  have hlog0 : 0≤Real.log ((2*geluGridResolution d Q r R+1:ℕ):ℝ) :=
    Real.log_nonneg (by exact_mod_cast (show 1≤2*geluGridResolution d Q r R+1 by omega))
  have hmul := mul_le_mul hP hloggrid hlog0 (by positivity : 0≤3000000000000000*(C:ℝ)^2*S^7)
  nlinarith [mul_nonneg (sq_nonneg (C:ℝ)) (pow_nonneg hS0 9)]

end NeuralGeneralization.BatchTwoMerging
