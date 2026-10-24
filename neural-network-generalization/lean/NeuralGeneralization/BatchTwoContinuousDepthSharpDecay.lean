import NeuralGeneralization.BatchTwoContinuousDepthResources

noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

def sharpInterpolationDepthThreshold : ℕ := ⌈28*Real.log (16*(10 : ℝ)^25)+6⌉₊

theorem sharp_interpolation_channel_energy_small {n r : ℕ} (hn : 0 < n)
    (hr : sharpInterpolationDepthThreshold ≤ r)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    16*(interpolationWidth n : ℝ)*(n : ℝ)^2*((6/7 : ℝ)^(r+1))^2 ≤ 1 := by
  have hpoly := interpolationWidth_times_square_polynomial hn
  have hn0 : (0 : ℝ)≤n := Nat.cast_nonneg n
  have hexpn : (n : ℝ)^25 ≤ Real.exp (((r : ℝ)+2)/4) := by
    have h := pow_le_pow_left₀ hn0 hnr 25
    rw [← Real.exp_nat_mul] at h
    convert h using 1 <;> congr 1 <;> ring
  have hdec : (6/7 : ℝ) ≤ Real.exp (-1/7) := by
    linarith only [Real.add_one_le_exp (-1/7)]
  have hdecay : ((6/7 : ℝ)^(r+1))^2 ≤ Real.exp (-2*((r : ℝ)+1)/7) := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤6/7) hdec (r+1)
    have h2 := pow_le_pow_left₀ (by positivity : (0 : ℝ)≤(6/7 : ℝ)^(r+1)) h 2
    rw [← Real.exp_nat_mul,← Real.exp_nat_mul] at h2
    convert h2 using 1 <;> congr 1 <;> push_cast <;> ring
  have hrR : (sharpInterpolationDepthThreshold : ℝ) ≤ r := by exact_mod_cast hr
  have hthreshold : 28*Real.log (16*(10 : ℝ)^25)+6 ≤ (r : ℝ) :=
    (Nat.le_ceil (28*Real.log (16*(10 : ℝ)^25)+6)).trans hrR
  have hlast : 16*(10 : ℝ)^25*Real.exp (-(r : ℝ)/28+3/14) ≤ 1 := by
    have h : Real.exp (Real.log (16*(10 : ℝ)^25)-(r : ℝ)/28+3/14) ≤ 1 :=
      Real.exp_le_one_iff.mpr (by
        have he : Real.log (16*(10 : ℝ)^25)-(r : ℝ)/28+3/14 =
            (28*Real.log (16*(10 : ℝ)^25)+6-r)/28 := by ring
        rw [he]
        exact div_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr hthreshold) (by norm_num))
    have he : Real.log (16*(10 : ℝ)^25)-(r : ℝ)/28+3/14 =
        Real.log (16*(10 : ℝ)^25) + (-(r : ℝ)/28+3/14) := by ring
    rw [he,Real.exp_add,Real.exp_log (by positivity)] at h
    exact h
  calc
    _ ≤ 16*((10 : ℝ)^25*(n : ℝ)^25)*((6/7 : ℝ)^(r+1))^2 := by
      have h := mul_le_mul_of_nonneg_left hpoly (show (0 : ℝ)≤16 by norm_num)
      have hh := mul_le_mul_of_nonneg_right h (sq_nonneg ((6/7 : ℝ)^(r+1)))
      nlinarith only [hh]
    _ ≤ 16*((10 : ℝ)^25*Real.exp (((r : ℝ)+2)/4))*Real.exp (-2*((r : ℝ)+1)/7) := by
      gcongr
    _ = 16*(10 : ℝ)^25*Real.exp (-(r : ℝ)/28+3/14) := by
      have hh : Real.exp (((r : ℝ)+2)/4)*Real.exp (-2*((r : ℝ)+1)/7)=Real.exp (-(r : ℝ)/28+3/14) := by
        rw [← Real.exp_add]
        congr 1
        ring
      calc
        _ = 16*(10 : ℝ)^25*(Real.exp (((r : ℝ)+2)/4)*Real.exp (-2*((r : ℝ)+1)/7)) := by ring
        _ = _ := by rw [hh]
    _ ≤ 1 := hlast

theorem eventually_sharp_interpolation_channel_energy_small :
    ∃ r₀ : ℕ, ∀ r ≥ r₀, ∀ n : ℕ, 0 < n →
      (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100) →
      16*(interpolationWidth n : ℝ)*(n : ℝ)^2*((6/7 : ℝ)^(r+1))^2 ≤ 1 :=
  ⟨sharpInterpolationDepthThreshold,fun _ hr _ hn hnr => sharp_interpolation_channel_energy_small hn hr hnr⟩


end NeuralGeneralization.BatchTwoContinuousDepthLower
