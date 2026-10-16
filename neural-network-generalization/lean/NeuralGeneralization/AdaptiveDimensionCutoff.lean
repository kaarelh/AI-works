import NeuralGeneralization.ParitySquaredSampling
import NeuralGeneralization.RankOneGrowthConstants
import NeuralGeneralization.BinomialGeometricBounds
import Mathlib.Data.Nat.Choose.Bounds

/-! Actual low-degree dimension and an adaptive odd cutoff. The sampling
threshold uses log(8n), allowing its maximality to cancel exactly the
binomial denominator in the sharp spectral bounds. -/
noncomputable section
namespace NeuralGeneralization.AdaptiveCutoff
open scoped BigOperators
open SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

lemma lowDimension_eq_sum (d r : ℕ) :
    lowDimension d r = ∑ j ∈ Finset.range (r+1), d.choose j := degreeIndices_card d r

lemma lowDimension_succ (d r : ℕ) :
    lowDimension d (r+1) = lowDimension d r+d.choose (r+1) := by
  simp only [lowDimension_eq_sum, Finset.sum_range_succ]

lemma lowDimension_mono (d : ℕ) {r t : ℕ} (hrt : r ≤ t) :
    lowDimension d r ≤ lowDimension d t := by
  simp only [lowDimension_eq_sum]
  exact Finset.sum_le_sum_of_subset (Finset.range_mono (by omega))

lemma lowDimension_pow (d r : ℕ) : lowDimension d r ≤ (d+1)^r := by
  induction r with
  | zero => simp [lowDimension_eq_sum]
  | succ r ih =>
    rw [lowDimension_succ, pow_succ]
    have hc := Nat.choose_le_pow d (r+1)
    have hp := Nat.pow_le_pow_left (Nat.le_succ d) r
    rw [pow_succ] at hc
    nlinarith

lemma choose_le_lowDimension (d r : ℕ) : d.choose r ≤ lowDimension d r := by
  rw [lowDimension_eq_sum]
  exact Finset.single_le_sum (fun _ _ => Nat.zero_le _) (Finset.mem_range.mpr (by omega))

lemma lowDimension_two_pow {d r : ℕ} (hr : 3*r ≤ d) :
    2^r ≤ lowDimension d r := by
  have hh := BinomialGeometry.choose_growth (D:=d) (k:=0) (j:=r) (B:=r)
    (Nat.zero_le _) le_rfl hr
  simpa only [Nat.sub_zero, Nat.choose_zero_right, mul_one] using
    hh.trans (choose_le_lowDimension d r)

lemma lowDimension_le_twice_choose {d r : ℕ} (hr : 3*r ≤ d) :
    lowDimension d r ≤ 2*d.choose r := by
  rw [lowDimension_eq_sum]
  exact BinomialGeometry.choose_sum_range_le hr

lemma log_eight_sample_ge_one {n : ℕ} (hn : 0<n) :
    1 ≤ Real.log (8*(n:ℝ)) := by
  have hn' : (1:ℝ)≤n := by exact_mod_cast hn
  have hh : (1:ℝ)/2 ≤ Real.log 2 := by
    have h := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h ⊢
    exact h
  have hlog : Real.log (8:ℝ) ≤ Real.log (8*(n:ℝ)) :=
    Real.log_le_log (by norm_num) (by nlinarith only [hn'])
  have he : Real.log (8:ℝ) = 3*Real.log 2 := by
    rw [show (8:ℝ)=2^3 by norm_num, Real.log_pow]
    norm_num
  linarith only [hlog, he, hh]

/-- A single, explicit enlarged threshold discharges the full logarithmic
sampling budget, including the actual chaining dimension cutoff. -/
theorem samplingBudget_of_threshold {d r n : ℕ} {A : ℝ}
    (hn : 0<n) (hA : (2:ℝ)^79 ≤ A)
    (hthreshold : A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) ≤ n) :
    paritySquaredSamplingBudget d r n ≤ n := by
  have hL := log_eight_sample_ge_one hn
  have hD : (0:ℝ)<lowDimension d r := Nat.cast_pos.mpr (lowDimension_pos d r)
  have hA1 : 1≤A := by nlinarith only [hA]
  have hDn : (lowDimension d r:ℝ)≤n := by
    have hh := mul_le_mul_of_nonneg_left hL (mul_nonneg (by linarith : 0≤A) hD.le)
    nlinarith only [hthreshold, hh, hA1, hD.le]
  have hlogD : Real.log (lowDimension d r:ℝ) ≤ Real.log (8*(n:ℝ)) :=
    Real.log_le_log hD (by nlinarith only [hDn, (Nat.cast_nonneg n : (0:ℝ)≤n)])
  have hcut := dimensionCutoff_le_two_log (lowDimension d r)
  have hfactor : Real.log (8*(n:ℝ))+
      ((dimensionCutoff (lowDimension d r)+1:ℕ):ℝ) ≤ 8*Real.log (8*(n:ℝ)) := by
    push_cast
    linarith only [hcut, hlogD, hL]
  unfold paritySquaredSamplingBudget
  calc
    _ ≤ (2:ℝ)^76*(lowDimension d r:ℝ)*(8*Real.log (8*(n:ℝ))) :=
      mul_le_mul_of_nonneg_left hfactor (by positivity)
    _ = (2:ℝ)^79*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) := by ring
    _ ≤ A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) := by gcongr
    _ ≤ n := hthreshold

/-- Actual finite maximization gives an odd successful cutoff whose next
odd cutoff fails. No asymptotic or maximality premise is supplied. -/
theorem exists_odd_threshold_cutoff (d n t R : ℕ) (A : ℝ)
    (htR : t<R) (ht : Odd t) (hR : Odd R)
    (hgood : A*(lowDimension d t:ℝ)*Real.log (8*(n:ℝ)) ≤ n)
    (hbad : (n:ℝ)<A*(lowDimension d R:ℝ)*Real.log (8*(n:ℝ))) :
    ∃ r, t≤r ∧ r<R ∧ Odd r ∧
      A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) ≤ n ∧
      (n:ℝ)<A*(lowDimension d (r+2):ℝ)*Real.log (8*(n:ℝ)) := by
  let S := (Finset.range R).filter (fun r => Odd r ∧
    A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) ≤ n)
  have htS : t∈S := by simp only [S, Finset.mem_filter, Finset.mem_range]; exact ⟨htR,ht,hgood⟩
  have hS : S.Nonempty := ⟨t,htS⟩
  let r := S.max' hS
  have hrS : r∈S := Finset.max'_mem S hS
  have hr := Finset.mem_filter.mp hrS
  have hrR : r<R := Finset.mem_range.mp hr.1
  have htlow : t≤r := Finset.le_max' S t htS
  refine ⟨r,htlow,hrR,hr.2.1,hr.2.2,?_⟩
  have hnextodd : Odd (r+2) := by exact hr.2.1.add_even (by decide)
  have hnext : r+2≤R := by
    obtain ⟨a,ha⟩ := hr.2.1
    obtain ⟨b,hb⟩ := hR
    omega
  by_cases heq : r+2=R
  · simpa only [heq] using hbad
  · by_contra hh
    have hnextS : r+2∈S := by
      simp only [S, Finset.mem_filter, Finset.mem_range]
      exact ⟨by omega,hnextodd,le_of_not_gt hh⟩
    have hmax := Finset.le_max' S (r+2) hnextS
    omega

end NeuralGeneralization.AdaptiveCutoff
