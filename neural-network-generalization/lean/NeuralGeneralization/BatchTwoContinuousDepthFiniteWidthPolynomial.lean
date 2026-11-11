import NeuralGeneralization.BatchTwoContinuousDepthFiniteGrowthBounds

/-! A single polynomial majorant for the literal manuscript width threshold. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
set_option maxHeartbeats 1800000
set_option backward.isDefEq.respectTransparency false

def finiteWidthCoefficient : ℝ := 216*(289+2*Real.exp 19)

def finiteWidthExponent (ζ : ℝ) : ℕ := ⌈1/ζ⌉₊

def finiteResource (d M L : ℕ) (T h β : ℝ) : ℝ :=
  (d : ℝ)+(M : ℝ)+(L : ℝ)+T+1/h+Real.log (1/β)+2

theorem inverse_radius_resource_bound {L : ℕ} (hL : 3 ≤ L) {T h S : ℝ}
    (hT : 1 ≤ T) (hh : 0 < h) (hS : 1 ≤ S) (hLS : (L : ℝ) ≤ S)
    (hTS : T ≤ S) (hhS : 1/h ≤ S) :
    1/(approximationRadius L (energyBudget L T) h)^2 ≤ (289+2*Real.exp 19)*S^5 := by
  have hK := energyBudget_nonneg (L:=L) hT
  have hInv := approximationRadius_inverse_square (by omega : 2 ≤ L) hK hh
  have hE := energyBudget_linear_product hL hT
  have hA := approximationAmplification_square hL hT
  have hT0 : 0 ≤ T := by linarith
  have hS0 : 0 ≤ S := by linarith
  have hprod : (L : ℝ)^2*T ≤ S^3 := by
    calc
      _ ≤ S^2*S := by gcongr
      _ = _ := by ring
  have hprod' : (L : ℝ)^2*T*(1/h)^2 ≤ S^5 := by
    calc
      _ ≤ S^2*S*S^2 := by gcongr
      _ = _ := by ring
  have hfirst : 16*(L : ℝ)*(energyBudget L T+1) ≤ 288*S^3 := by
    calc
      _ ≤ 16*(L : ℝ)*(18*(L : ℝ)*T) := mul_le_mul_of_nonneg_left hE (by positivity)
      _ = 288*((L : ℝ)^2*T) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hprod (by norm_num)
  have hsecond : 2*(L : ℝ)^2*(approximationAmplification L (energyBudget L T))^2/h^2 ≤
      2*Real.exp 19*S^5 := by
    calc
      _ ≤ 2*(L : ℝ)^2*(Real.exp 19*T)/h^2 :=
        div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hA (by positivity)) (sq_nonneg h)
      _ = 2*Real.exp 19*((L : ℝ)^2*T*(1/h)^2) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hprod' (by positivity)
  have h35 : S^3 ≤ S^5 := pow_le_pow_right₀ hS (by omega)
  have h5 : 1 ≤ S^5 := one_le_pow₀ hS
  nlinarith only [hInv,hfirst,hsecond,h35,h5]

theorem noise_radius_resource_bound (d : ℕ) {L : ℕ} (hL : 1 ≤ L) {S : ℝ}
    (hS : 1 ≤ S) (hdS : (d : ℝ) ≤ S) (hLS : (L : ℝ) ≤ S) :
    (noiseRadius d L)^2 ≤ 216*S := by
  have he : (noiseRadius d L)^2=noiseSquared d L :=
    Real.sq_sqrt (zero_le_one.trans (noiseSquared_ge_one d L))
  rw [he]
  have hh := noiseSquared_polynomial_bound d hL
  nlinarith

theorem radius_ratio_resource_bound (d : ℕ) {L : ℕ} (hL : 3 ≤ L) {T h S : ℝ}
    (hT : 1 ≤ T) (hh : 0 < h) (hS : 1 ≤ S) (hdS : (d : ℝ) ≤ S)
    (hLS : (L : ℝ) ≤ S) (hTS : T ≤ S) (hhS : 1/h ≤ S) :
    (noiseRadius d L/approximationRadius L (energyBudget L T) h)^2 ≤ finiteWidthCoefficient*S^6 := by
  have hi := inverse_radius_resource_bound hL hT hh hS hLS hTS hhS
  have hn := noise_radius_resource_bound d (by omega : 1 ≤ L) hS hdS hLS
  have hS0 : 0 ≤ S := by linarith
  calc
    _ = (noiseRadius d L)^2*(1/(approximationRadius L (energyBudget L T) h)^2) := by ring
    _ ≤ (216*S)*((289+2*Real.exp 19)*S^5) :=
      mul_le_mul hn hi (by positivity) (by positivity)
    _ = finiteWidthCoefficient*S^6 := by unfold finiteWidthCoefficient;ring

theorem finiteResource_bounds (d M L : ℕ) {T h β : ℝ}
    (hT : 1 ≤ T) (hh : 0 < h) (hβ : 0 < β) (hβ1 : β < 1) :
    2 ≤ finiteResource d M L T h β ∧ (d : ℝ) ≤ finiteResource d M L T h β ∧
    (M : ℝ) ≤ finiteResource d M L T h β ∧ (L : ℝ) ≤ finiteResource d M L T h β ∧
    T ≤ finiteResource d M L T h β ∧ 1/h ≤ finiteResource d M L T h β ∧
    2*Real.log (2/β) ≤ 2*finiteResource d M L T h β := by
  have hd : 0 ≤ (d : ℝ) := Nat.cast_nonneg d
  have hM : 0 ≤ (M : ℝ) := Nat.cast_nonneg M
  have hL : 0 ≤ (L : ℝ) := Nat.cast_nonneg L
  have hh0 : 0 ≤ 1/h := by positivity
  have hlog : 0 ≤ Real.log (1/β) := Real.log_nonneg ((one_le_div hβ).mpr hβ1.le)
  have h2 : Real.log 2 ≤ 1 := by linarith only [Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)]
  have he : Real.log (2/β)=Real.log 2+Real.log (1/β) := by
    rw [show 2/β=2*(1/β) by ring,Real.log_mul (by norm_num) (one_div_ne_zero hβ.ne')]
  unfold finiteResource
  rw [he]
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor
  · linarith
  constructor <;> linarith

/-- For every fixed zeta, the manuscript's exact threshold has a polynomial
majorant in d, M, T, L, 1/h and log(1/beta). Its exponent is explicit. -/
theorem approximationWidth_polynomial {ζ : ℝ} (hζ : 0 < ζ)
    (d M : ℕ) {L : ℕ} (hL : 3 ≤ L) {T h β : ℝ}
    (hT : 1 ≤ T) (hh : 0 < h) (hβ : 0 < β) (hβ1 : β < 1) :
    (approximationWidth d M L (energyBudget L T) h ζ β : ℝ) ≤
      (3*finiteWidthCoefficient^finiteWidthExponent ζ)*
        (finiteResource d M L T h β)^(6*finiteWidthExponent ζ) := by
  let S := finiteResource d M L T h β
  let q := finiteWidthExponent ζ
  let R := finiteWidthCoefficient^q*S^(6*q)
  have hB := finiteResource_bounds d M L hT hh hβ hβ1
  have hS : 1 ≤ S := by dsimp [S];linarith only [hB.1]
  have hS2 : 2 ≤ S := hB.1
  have hS0 : 0 ≤ S := by linarith
  have hqR : 1/ζ ≤ (q : ℝ) := Nat.le_ceil _
  have hq : 1 ≤ q := by
    have hpos : (0 : ℝ) < q := (one_div_pos.mpr hζ).trans_le hqR
    have hposN : 0 < q := by exact_mod_cast hpos
    omega
  have hC : 1 ≤ finiteWidthCoefficient := by
    unfold finiteWidthCoefficient
    nlinarith [Real.exp_nonneg (19 : ℝ)]
  have hR1 : 1 ≤ R := by
    dsimp only [R]
    simpa only [one_mul] using mul_le_mul (show 1 ≤ finiteWidthCoefficient^q from one_le_pow₀ hC)
      (show 1 ≤ S^(6*q) from one_le_pow₀ hS) (by norm_num) (by positivity)
  have hSR : S ≤ R := by
    have hp : S ≤ S^(6*q) := by simpa using pow_le_pow_right₀ hS (show 1 ≤ 6*q by omega)
    have hCq : 1 ≤ finiteWidthCoefficient^q := one_le_pow₀ hC
    exact hp.trans (by dsimp [R];nlinarith [pow_nonneg hS0 (6*q)])
  have hratio := radius_ratio_resource_bound d hL hT hh hS hB.2.1 hB.2.2.2.1
    hB.2.2.2.2.1 hB.2.2.2.2.2.1
  have hbase : 1 ≤ finiteWidthCoefficient*S^6 := by
    simpa only [one_mul] using mul_le_mul hC (show 1 ≤ S^6 from one_le_pow₀ hS)
      (by norm_num) (by positivity)
  have hη := approximationRadius_pos (by omega : 2 ≤ L) (energyBudget_nonneg (L:=L) hT) hh
  have hb := noiseRadius_pos d L
  have hp : (noiseRadius d L/approximationRadius L (energyBudget L T) h)^(2/ζ) ≤ R := by
    calc
      _ = ((noiseRadius d L/approximationRadius L (energyBudget L T) h)^2)^(1/ζ) := by
        rw [← Real.rpow_natCast,← Real.rpow_mul (by positivity)]
        congr 1
        norm_num only [Nat.cast_ofNat]
        ring
      _ ≤ (finiteWidthCoefficient*S^6)^(1/ζ) := Real.rpow_le_rpow (sq_nonneg _) hratio (by positivity)
      _ ≤ (finiteWidthCoefficient*S^6)^(q : ℝ) := Real.rpow_le_rpow_of_exponent_le hbase hqR
      _ = R := by rw [Real.rpow_natCast,mul_pow,← pow_mul]
  have hm : (M : ℝ) ≤ R := hB.2.2.1.trans hSR
  have hn : (2 : ℝ) ≤ R := hS2.trans hSR
  have ht : 2*Real.log (2/β) ≤ 2*R := hB.2.2.2.2.2.2.trans (by nlinarith only [hSR])
  let V := max (M : ℝ) (max 2 (max ((noiseRadius d L/approximationRadius L (energyBudget L T) h)^(2/ζ))
    (2*Real.log (2/β))))
  have hV : V ≤ 2*R := max_le (by linarith only [hm,hR1])
    (max_le (by linarith only [hn,hR1]) (max_le (by linarith only [hp,hR1]) ht))
  have hV0 : 0 ≤ V := (Nat.cast_nonneg M).trans (le_max_left _ _)
  have hc := Nat.ceil_lt_add_one hV0
  change (⌈V⌉₊ : ℝ) ≤ _
  have hresult : (⌈V⌉₊ : ℝ) ≤ 3*R := by linarith
  exact hresult.trans_eq (by dsimp [R,q,S];ring)

end NeuralGeneralization.BatchTwoContinuousDepthPaper
