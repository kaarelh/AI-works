import NeuralGeneralization.BatchTwoContinuousDepthResources

noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

def interpolationDepthThreshold : ℕ := ⌈4*Real.log (16*(10 : ℝ)^25)⌉₊

theorem interpolation_channel_energy_small {n r : ℕ} (hn : 0 < n)
    (hr : interpolationDepthThreshold ≤ r)
    (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    16*(interpolationWidth n : ℝ)*(n : ℝ)^2*((3/4 : ℝ)^(r+1))^2 ≤ 1 := by
  have hpoly := interpolationWidth_times_square_polynomial hn
  have hn0 : (0 : ℝ)≤n := Nat.cast_nonneg n
  have hexpn : (n : ℝ)^25 ≤ Real.exp (((r : ℝ)+2)/4) := by
    have h := pow_le_pow_left₀ hn0 hnr 25
    rw [← Real.exp_nat_mul] at h
    convert h using 1 <;> congr 1 <;> ring
  have hdec : (3/4 : ℝ) ≤ Real.exp (-1/4) := by
    linarith only [Real.add_one_le_exp (-1/4)]
  have hdecay : ((3/4 : ℝ)^(r+1))^2 ≤ Real.exp (-((r : ℝ)+1)/2) := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤3/4) hdec (r+1)
    have h2 := pow_le_pow_left₀ (by positivity : (0 : ℝ)≤(3/4 : ℝ)^(r+1)) h 2
    rw [← Real.exp_nat_mul,← Real.exp_nat_mul] at h2
    convert h2 using 1 <;> congr 1 <;> push_cast <;> ring
  have hrR : (interpolationDepthThreshold : ℝ) ≤ r := by exact_mod_cast hr
  have hthreshold : 4*Real.log (16*(10 : ℝ)^25) ≤ (r : ℝ) :=
    (Nat.le_ceil (4*Real.log (16*(10 : ℝ)^25))).trans hrR
  have hlast : 16*(10 : ℝ)^25*Real.exp (-(r : ℝ)/4) ≤ 1 := by
    have h : Real.exp (Real.log (16*(10 : ℝ)^25)-(r : ℝ)/4) ≤ 1 :=
      Real.exp_le_one_iff.mpr (by
        apply sub_nonpos.mpr
        apply (le_div_iff₀ (by norm_num : (0 : ℝ)<4)).mpr
        simpa only [mul_comm] using hthreshold)
    rw [Real.exp_sub,Real.exp_log (by positivity),div_eq_mul_inv,← Real.exp_neg] at h
    simpa only [neg_div] using h
  calc
    _ ≤ 16*((10 : ℝ)^25*(n : ℝ)^25)*((3/4 : ℝ)^(r+1))^2 := by
      have h := mul_le_mul_of_nonneg_left hpoly (show (0 : ℝ)≤16 by norm_num)
      have hh := mul_le_mul_of_nonneg_right h (sq_nonneg ((3/4 : ℝ)^(r+1)))
      nlinarith only [hh]
    _ ≤ 16*((10 : ℝ)^25*Real.exp (((r : ℝ)+2)/4))*Real.exp (-((r : ℝ)+1)/2) := by
      gcongr
    _ = 16*(10 : ℝ)^25*Real.exp (-(r : ℝ)/4) := by
      have hh : Real.exp (((r : ℝ)+2)/4)*Real.exp (-((r : ℝ)+1)/2)=Real.exp (-(r : ℝ)/4) := by
        rw [← Real.exp_add]
        congr 1
        ring
      calc
        _ = 16*(10 : ℝ)^25*(Real.exp (((r : ℝ)+2)/4)*Real.exp (-((r : ℝ)+1)/2)) := by ring
        _ = _ := by rw [hh]
    _ ≤ 1 := hlast

theorem eventually_interpolation_channel_energy_small :
    ∃ r₀ : ℕ, ∀ r ≥ r₀, ∀ n : ℕ, 0 < n →
      (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100) →
      16*(interpolationWidth n : ℝ)*(n : ℝ)^2*((3/4 : ℝ)^(r+1))^2 ≤ 1 :=
  ⟨interpolationDepthThreshold,fun _ hr _ hn hnr => interpolation_channel_energy_small hn hr hnr⟩

theorem channel_lipschitz_below_teacher_expansion {r : ℕ} (hr : 6 ≤ r) :
    (2 : ℝ)^(r+3) ≤ (3 : ℝ)^(r+2)/10 := by
  obtain ⟨k,rfl⟩ := Nat.exists_eq_add_of_le hr
  induction k with
  | zero => norm_num
  | succ k ih =>
    have ih := ih (by omega)
    have h2 : 2^((6+k+1)+3)=(2 : ℝ)^(6+k+3)*2 := by
      rw [show (6+k+1)+3=(6+k+3)+1 by omega,pow_succ]
    have h3 : 3^((6+k+1)+2)=(3 : ℝ)^(6+k+2)*3 := by
      rw [show (6+k+1)+2=(6+k+2)+1 by omega,pow_succ]
    change (2 : ℝ)^((6+k+1)+3)≤(3 : ℝ)^((6+k+1)+2)/10
    rw [h2,h3]
    nlinarith only [ih,pow_nonneg (by norm_num : (0 : ℝ)≤3) (6+k+2)]

#print axioms eventually_interpolation_channel_energy_small

end NeuralGeneralization.BatchTwoContinuousDepthLower
