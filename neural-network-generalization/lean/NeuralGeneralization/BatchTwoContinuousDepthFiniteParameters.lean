import NeuralGeneralization.BatchTwoContinuousDepthPaperCeiling
import NeuralGeneralization.BatchTwoContinuousDepthFiniteGaussian

/-! The finite-scale lemma's literal radius and width threshold. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

def approximationAmplification (L : ℕ) (K : ℝ) : ℝ :=
  ((K+2)/((L : ℝ)-1))^(((L : ℝ)-1)/2)

def approximationRadius (L : ℕ) (K h : ℝ) : ℝ :=
  min 1 (min (1/(4*Real.sqrt ((L : ℝ)*(K+1))))
    (h/(Real.sqrt 2*(L : ℝ)*approximationAmplification L K)))

def approximationWidth (d M L : ℕ) (K h ζ β : ℝ) : ℕ :=
  ⌈max (M : ℝ) (max 2 (max ((noiseRadius d L/approximationRadius L K h)^(2/ζ))
    (2*Real.log (2/β))))⌉₊

theorem approximationAmplification_pos {L : ℕ} (hL : 2 ≤ L) {K : ℝ} (hK : 0 ≤ K) :
    0 < approximationAmplification L K := by
  have hLR : (2 : ℝ) ≤ L := by exact_mod_cast hL
  apply Real.rpow_pos_of_pos
  apply div_pos <;> linarith

theorem approximationRadius_pos {L : ℕ} (hL : 2 ≤ L) {K h : ℝ} (hK : 0 ≤ K)
    (hh : 0 < h) : 0 < approximationRadius L K h := by
  have hLR : (0 : ℝ) < L := by exact_mod_cast (show 0 < L by omega)
  have hA := approximationAmplification_pos hL hK
  unfold approximationRadius
  positivity

theorem approximationRadius_le_one (L : ℕ) (K h : ℝ) : approximationRadius L K h ≤ 1 :=
  min_le_left _ _

theorem approximationRadius_energy {L : ℕ} (hL : 2 ≤ L) {K h : ℝ} (hK : 0 ≤ K)
    (hh : 0 < h) :
    approximationRadius L K h*Real.sqrt ((L : ℝ)*(K+1)) ≤ 1/4 ∧
    (approximationRadius L K h)^2*(L : ℝ)*(K+1) ≤ 1/16 ∧
    K+1+2*approximationRadius L K h*Real.sqrt ((L : ℝ)*(K+1))+
      (L : ℝ)*(approximationRadius L K h)^2 ≤ K+2 := by
  have hLR : (2 : ℝ) ≤ L := by exact_mod_cast hL
  have hp : 0 < (L : ℝ)*(K+1) := by positivity
  have hs : 0 < Real.sqrt ((L : ℝ)*(K+1)) := Real.sqrt_pos.2 hp
  have he : approximationRadius L K h ≤ 1/(4*Real.sqrt ((L : ℝ)*(K+1))) :=
    (min_le_right _ _).trans (min_le_left _ _)
  have ha : 0 < approximationRadius L K h := approximationRadius_pos hL hK hh
  have hc : approximationRadius L K h*Real.sqrt ((L : ℝ)*(K+1)) ≤ 1/4 := by
    have hh := (le_div_iff₀ (by positivity : 0 < 4*Real.sqrt ((L : ℝ)*(K+1)))).mp he
    linarith
  have hsq := (sq_le_sq₀ (by positivity) (by norm_num : (0 : ℝ) ≤ 1/4)).mpr hc
  rw [mul_pow,Real.sq_sqrt hp.le] at hsq
  have hnon : 0 ≤ (L : ℝ)*(approximationRadius L K h)^2*K := by positivity
  refine ⟨hc,by nlinarith,?_⟩
  nlinarith

theorem approximationRadius_output {L : ℕ} (hL : 2 ≤ L) {K h : ℝ} (hK : 0 ≤ K) :
    Real.sqrt 2*(L : ℝ)*approximationRadius L K h*approximationAmplification L K ≤ h := by
  have hLR : (0 : ℝ) < L := by exact_mod_cast (show 0 < L by omega)
  have hA := approximationAmplification_pos hL hK
  have he : approximationRadius L K h ≤ h/(Real.sqrt 2*(L : ℝ)*approximationAmplification L K) :=
    (min_le_right _ _).trans (min_le_right _ _)
  have hx := (le_div_iff₀ (by positivity : 0 < Real.sqrt 2*(L : ℝ)*approximationAmplification L K)).mp he
  nlinarith only [hx]

theorem noiseSquared_ge_one (d L : ℕ) : 1 ≤ noiseSquared d L := by
  have h2 : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  have h8 := Real.one_sub_inv_le_log_of_pos (by norm_num : (0 : ℝ) < 8)
  have hf : 1 ≤ firstNoiseSquared d := by
    unfold firstNoiseSquared
    have h : 0 ≤ 2*((d : ℝ)+1)*Real.log 2 := by positivity
    norm_num at h8
    linarith
  exact hf.trans (le_max_left _ _)

theorem noiseRadius_ge_one (d L : ℕ) : 1 ≤ noiseRadius d L := by
  have hh := Real.sq_sqrt ((zero_le_one.trans (noiseSquared_ge_one d L)))
  have hp := noiseRadius_pos d L
  change 1 ≤ Real.sqrt (noiseSquared d L)
  nlinarith [noiseSquared_ge_one d L,Real.sqrt_nonneg (noiseSquared d L)]

/-- The nonintegral exponent in the displayed width condition gives the exact
small-block scale; no larger surrogate threshold is substituted. -/
theorem power_width_noise_scale {N : ℕ} {b η ζ σ : ℝ} (hN : 1 ≤ N)
    (hb : 0 < b) (hη : 0 < η) (hζ : 0 < ζ)
    (hwidth : (b/η)^(2/ζ) ≤ (N : ℝ)) (hscale : σ^2 ≤ (N : ℝ)^(-(1+ζ))) :
    (N : ℝ)*σ^2*b^2 ≤ η^2 := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast (show 0 < N by omega)
  have hp : (b/η)^2 ≤ (N : ℝ)^ζ := by
    have hh := Real.rpow_le_rpow (by positivity) hwidth hζ.le
    rw [← Real.rpow_mul (by positivity : 0 ≤ b/η),div_mul_cancel₀ _ hζ.ne',Real.rpow_two] at hh
    exact hh
  have hpow : (N : ℝ)^ζ > 0 := Real.rpow_pos_of_pos hNR _
  have he : (N : ℝ)*(N : ℝ)^(-(1+ζ))=1/(N : ℝ)^ζ := by
    rw [show -(1+ζ)=(-1 : ℝ)-ζ by ring,Real.rpow_sub hNR,Real.rpow_neg_one]
    field_simp
  have ht := mul_le_mul_of_nonneg_left hscale hNR.le
  rw [he] at ht
  calc
    _ ≤ (1/(N : ℝ)^ζ)*b^2 := mul_le_mul_of_nonneg_right ht (sq_nonneg b)
    _ ≤ η^2 := by
      rw [one_div_mul_eq_div]
      apply (div_le_iff₀ hpow).mpr
      rw [div_pow] at hp
      have hh := (div_le_iff₀ (sq_pos_of_pos hη)).mp hp
      nlinarith only [hh]

theorem approximationWidth_properties {d M L N : ℕ} {K h ζ β σ : ℝ}
    (hL : 2 ≤ L) (hK : 0 ≤ K) (hh : 0 < h) (hζ : 0 < ζ)
    (hN : approximationWidth d M L K h ζ β ≤ N)
    (hscale : σ^2 ≤ (N : ℝ)^(-(1+ζ))) :
    M ≤ N ∧ 2 ≤ N ∧ 2*Real.log (2/β) ≤ (N : ℝ) ∧
    (N : ℝ)*σ^2*(noiseRadius d L)^2 ≤ (approximationRadius L K h)^2 ∧
    (N : ℝ)*σ^2*(K+1) ≤ 1/16 := by
  have hw : max (M : ℝ) (max 2 (max ((noiseRadius d L/approximationRadius L K h)^(2/ζ))
      (2*Real.log (2/β)))) ≤ (N : ℝ) :=
    (Nat.le_ceil _).trans (by exact_mod_cast hN)
  have hm : (M : ℝ) ≤ N := (le_max_left _ _).trans hw
  have hn : (2 : ℝ) ≤ N := (le_max_left _ _).trans ((le_max_right _ _).trans hw)
  have hnN : 2 ≤ N := by exact_mod_cast hn
  have htail := (le_max_right _ _).trans ((le_max_right _ _).trans ((le_max_right _ _).trans hw))
  have hwidth := (le_max_left _ _).trans ((le_max_right _ _).trans ((le_max_right _ _).trans hw))
  have hη := approximationRadius_pos hL hK hh
  have hb := noiseRadius_pos d L
  have hs := power_width_noise_scale (by omega : 1 ≤ N) hb hη hζ hwidth hscale
  have hb1 := noiseRadius_ge_one d L
  have hb2 : 1 ≤ (noiseRadius d L)^2 := by nlinarith
  have hηE := (approximationRadius_energy hL hK hh).2.1
  have hLR : (2 : ℝ) ≤ L := by exact_mod_cast hL
  have hNs : 0 ≤ (N : ℝ)*σ^2 := by positivity
  have hx : (N : ℝ)*σ^2 ≤ (approximationRadius L K h)^2 := by
    nlinarith [mul_le_mul_of_nonneg_left hb2 hNs]
  have hxK := mul_le_mul_of_nonneg_right hx (show 0 ≤ K+1 by linarith)
  have hηK : (approximationRadius L K h)^2*(K+1) ≤ 1/16 := by
    have hh : 0 ≤ (approximationRadius L K h)^2*(K+1) := by positivity
    nlinarith
  exact ⟨by exact_mod_cast hm,hnN,htail,hs,hxK.trans hηK⟩

end NeuralGeneralization.BatchTwoContinuousDepthPaper
