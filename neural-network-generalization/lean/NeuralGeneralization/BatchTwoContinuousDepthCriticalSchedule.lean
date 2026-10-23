import NeuralGeneralization.BatchTwoContinuousDepthCriticalPopulation
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlSeedBudget
import NeuralGeneralization.BatchTwoContinuousDepthResources

/-! A logarithmic recovery schedule fits inside the actual teacher depth and
has a strictly sublinear Gaussian change-of-mean cost. All constants are
universal; the seed is the explicit separated-sample control. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open Filter
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open BatchTwoContinuousDepthLower

theorem sample_seed_log_budget {n : ℕ} (hn : 0<n) :
    Real.log (1/dilutedSeedGain n (sampleSeparation n)) ≤ 1004+23*Real.log (n:ℝ) := by
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  have hδ := sampleSeparation_pos hn
  have hδ1 : sampleSeparation n≤1 := (sampleSeparation_le hn).trans (by norm_num)
  have hs := dilutedSeedGain_log_budget hn hδ hδ1
  have hi := Real.log_le_log (inv_pos.mpr hδ) (sampleSeparation_inverse_polynomial hn)
  rw [Real.log_mul (by norm_num) (by positivity),Real.log_pow,Real.log_pow] at hi
  have h100 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<100)
  simp only [one_div,Real.log_inv] at hs ⊢
  norm_num at hi h100
  linarith

def recoveryCount (n h : ℕ) : ℕ :=
  amplificationCount (retainedSignal n (seedDilution n (sampleSeparation n)) h)

def recoveryLogCoefficient : ℝ := 23/Real.log 2
def recoveryDepthCoefficient : ℝ := 1/(coolingConstant*derivativeFloor*Real.log 2)
def recoveryConstant : ℝ :=
  (1004+1/(coolingConstant*derivativeFloor)+Real.log 2)/Real.log 2+1

theorem recoveryCount_log_bound {n : ℕ} (hn : 0<n) (h : ℕ) :
    (recoveryCount n h : ℝ) ≤ recoveryLogCoefficient*Real.log (n:ℝ)+
      recoveryDepthCoefficient*Real.log ((h:ℝ)+1)+recoveryConstant := by
  let P := seedDilution n (sampleSeparation n)
  let g := dilutedSeedGain n (sampleSeparation n)
  let q := coolingConstant*derivativeFloor
  have hg : 0<g := dilutedSeedGain_pos hn _
  have hq : 0<q := mul_pos coolingConstant_pos derivativeFloor_pos
  have hp : 0<P := seedDilution_pos n _
  have hu := retainedSignal_pos hn hp h
  have hu1 := retainedSignal_le_one hn hp h
  have hcount := amplificationCount_bound hu hu1
  have heq : Real.log (1/retainedSignal n P h)=
      Real.log (1/g)+(1+Real.log ((h:ℝ)+1))/q+Real.log 2 := by
    unfold retainedSignal
    change Real.log (1/(g*Real.exp (-(1+Real.log ((h:ℝ)+1))/q)/2))=_
    rw [Real.log_div (by norm_num) (by positivity),Real.log_one,
      Real.log_div (by positivity) (by norm_num),
      Real.log_mul hg.ne' (Real.exp_pos _).ne',Real.log_exp,
      Real.log_div (by norm_num) hg.ne',Real.log_one]
    ring
  rw [heq] at hcount
  have hs := sample_seed_log_budget hn
  have hlog2 : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hb := div_le_div_of_nonneg_right
    (add_le_add_right (add_le_add_right hs ((1+Real.log ((h:ℝ)+1))/q)) (Real.log 2)) hlog2.le
  change (recoveryCount n h:ℝ)≤_ at hcount
  apply hcount.trans
  unfold recoveryLogCoefficient recoveryDepthCoefficient recoveryConstant
  calc
    _ ≤ (1004+23*Real.log (n:ℝ)+(1+Real.log ((h:ℝ)+1))/q+Real.log 2)/Real.log 2+1 := by
      simpa only [g,add_assoc,add_comm,add_left_comm] using add_le_add_right hb 1
    _ = _ := by dsimp [q]; field_simp; ring

/-- A general logarithmic schedule lemma. It is independent of the network
construction and can therefore be reused for any fixed recovery gains. -/
theorem logarithmic_schedule_fits {A B D E W : ℝ}
    (hA : 0≤A) (hB : 0≤B) (hD : 0≤D) (hE : 0≤E) (hW : 1≤W) :
    ∃ c : ℝ, 0<c ∧ ∃ h0 : ℕ, ∀ h : ℕ, h0≤h → ∀ n : ℕ, 0<n →
      (n:ℝ)≤Real.exp (c*(h:ℝ)) → ∀ m : ℕ,
      (m:ℝ)≤A*Real.log (n:ℝ)+B*Real.log ((h:ℝ)+1)+D →
      m+2≤h ∧ E+W*(m:ℝ)<(h:ℝ)/8 := by
  let κ : ℝ := 1/(32*(W+1))
  let c : ℝ := κ/(4*(A+1))
  have hκ : 0<κ := by dsimp [κ]; positivity
  have hc : 0<c := by dsimp [c]; positivity
  have hκsmall : κ≤1/64 := by
    dsimp [κ]
    exact one_div_le_one_div_of_le (by norm_num) (by linarith)
  have hWκ : W*κ≤1/32 := by
    dsimp [κ]
    rw [mul_one_div]
    apply (div_le_iff₀ (by positivity : 0<32*(W+1))).mpr
    linarith
  have hAc : A*c≤κ/4 := by
    dsimp [c]
    apply (le_div_iff₀ (by norm_num : (0:ℝ)<4)).mpr
    have ht : A/(A+1)≤1 := (div_le_one (by positivity)).mpr (by linarith)
    have hh := mul_le_mul_of_nonneg_left ht hκ.le
    convert hh using 1 <;> field_simp <;> ring
  have hnat : Tendsto (fun h:ℕ => (h:ℝ)) atTop atTop := tendsto_natCast_atTop_atTop
  have hlog := (Real.isLittleO_log_id_atTop.bound
    (show 0<κ/(8*(B+1)) by positivity)).filter_mono
      (show Filter.map (fun h:ℕ => (h:ℝ)+1) atTop ≤ atTop from
        tendsto_atTop_add_const_right atTop 1 hnat)
  have hlog' : ∀ᶠ h:ℕ in atTop,
      Real.log ((h:ℝ)+1)≤κ/(8*(B+1))*((h:ℝ)+1) := by
    filter_upwards [hlog] with h hh
    change |Real.log ((h:ℝ)+1)|≤κ/(8*(B+1))*|((h:ℝ)+1)| at hh
    simpa only [Function.id_def,Real.norm_eq_abs,
      abs_of_nonneg (Real.log_nonneg (by linarith [Nat.cast_nonneg (α:=ℝ) h] : (1:ℝ)≤(h:ℝ)+1)),
      abs_of_nonneg (by positivity : (0:ℝ)≤(h:ℝ)+1)] using hh
  have hD' : ∀ᶠ h:ℕ in atTop, D≤κ*(h:ℝ)/4 := by
    have ht := (hnat.const_mul_atTop (show 0<κ/4 by positivity)).eventually_ge_atTop D
    simpa only [div_mul_eq_mul_div] using ht
  have hE' : ∀ᶠ h:ℕ in atTop, E≤(h:ℝ)/32 := by
    have ht := (hnat.const_mul_atTop (by norm_num : (0:ℝ)<1/32)).eventually_ge_atTop E
    simpa only [one_div_mul_eq_div] using ht
  obtain ⟨h0,hh0⟩ := eventually_atTop.mp (hlog'.and (hD'.and (hE'.and (eventually_ge_atTop 4))))
  refine ⟨c,hc,h0,?_⟩
  intro h hh n hn hne m hm
  obtain ⟨hl,hD,hE,hh4⟩ := hh0 h hh
  have hhR : (4:ℝ)≤h := by exact_mod_cast hh4
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  have hln : Real.log (n:ℝ)≤c*(h:ℝ) := by
    simpa only [Real.log_exp] using Real.log_le_log hnR hne
  have hAln : A*Real.log (n:ℝ)≤κ*(h:ℝ)/4 := by
    calc
      _ ≤ A*(c*(h:ℝ)) := mul_le_mul_of_nonneg_left hln hA
      _ = (A*c)*(h:ℝ) := by ring
      _ ≤ (κ/4)*(h:ℝ) := mul_le_mul_of_nonneg_right hAc (by positivity)
      _ = _ := by ring
  have hBκ : B*(κ/(8*(B+1)))≤κ/8 := by
    have hdiv : B/(B+1)≤1 := (div_le_one (by positivity)).mpr (by linarith)
    have ht := mul_le_mul_of_nonneg_left hdiv (show 0≤κ/8 by positivity)
    calc
      _ = (κ/8)*(B/(B+1)) := by field_simp
      _ ≤ κ/8 := by simpa only [mul_one] using ht
  have hBln : B*Real.log ((h:ℝ)+1)≤κ*(h:ℝ)/4 := by
    calc
      _ ≤ B*(κ/(8*(B+1))*((h:ℝ)+1)) := mul_le_mul_of_nonneg_left hl hB
      _ = (B*(κ/(8*(B+1))))*((h:ℝ)+1) := by ring
      _ ≤ (κ/8)*((h:ℝ)+1) := mul_le_mul_of_nonneg_right hBκ (by positivity)
      _ ≤ _ := by nlinarith
  have hmκ : (m:ℝ)≤κ*(h:ℝ) := by linarith
  have hmh : (m:ℝ)≤(h:ℝ)/64 := by
    have ht := mul_le_mul_of_nonneg_right hκsmall (show (0:ℝ)≤h by positivity)
    nlinarith
  have hWm : W*(m:ℝ)≤(h:ℝ)/32 := by
    calc
      _ ≤ W*(κ*(h:ℝ)) := mul_le_mul_of_nonneg_left hmκ (by linarith)
      _ = (W*κ)*(h:ℝ) := by ring
      _ ≤ (1/32)*(h:ℝ) := mul_le_mul_of_nonneg_right hWκ (by positivity)
      _ = _ := by ring
  constructor
  · have hh : (m:ℝ)+2≤h := by linarith
    exact_mod_cast hh
  · linarith

/-- The exact recovery count for the actual separated-sample seed. -/
theorem exists_critical_recovery_schedule :
    ∃ c : ℝ, 0<c ∧ ∃ h0 : ℕ, ∀ h : ℕ, h0≤h → ∀ n : ℕ, 0<n →
      (n:ℝ)≤Real.exp (c*(h:ℝ)) →
      recoveryCount n h+2≤h ∧
      2+2*(recoveryCount n h:ℝ)*robustAmplificationGain^2+
        2*saturationGain^2+2*(3/5:ℝ)^2<(h:ℝ)/8 := by
  have hlog : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hq : 0<coolingConstant*derivativeFloor := mul_pos coolingConstant_pos derivativeFloor_pos
  obtain ⟨c,hc,h0,hh⟩ := logarithmic_schedule_fits
    (A:=recoveryLogCoefficient) (B:=recoveryDepthCoefficient) (D:=recoveryConstant)
    (E:=2+2*saturationGain^2+2*(3/5:ℝ)^2) (W:=1+2*robustAmplificationGain^2)
    (by unfold recoveryLogCoefficient; positivity)
    (by unfold recoveryDepthCoefficient; positivity)
    (by unfold recoveryConstant; positivity)
    (by positivity) (by nlinarith [sq_nonneg robustAmplificationGain])
  refine ⟨c,hc,h0,?_⟩
  intro h hh0 n hn hne
  obtain ⟨hs,he⟩ := hh h hh0 n hn hne (recoveryCount n h) (recoveryCount_log_bound hn h)
  refine ⟨hs,?_⟩
  have hm : (0:ℝ)≤recoveryCount n h := Nat.cast_nonneg _
  nlinarith only [he,hm]

#print axioms exists_critical_recovery_schedule
end NeuralGeneralization.BatchTwoContinuousDepthCritical
