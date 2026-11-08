import NeuralGeneralization.OnlineLowerTanhOptimizer
import NeuralGeneralization.OnlineLowerTanhLimitingMaximum
import NeuralGeneralization.OnlineLowerCentralBinomialLimit

/-! # The asymptotic lower efficiency of every actual global maximizer -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def limitingParityEfficiency : ℝ :=
  Real.sqrt (2/Real.pi)*scalarF0 limitingGain/limitingGain

def intrinsicEfficiency {n : ℕ} (u : Fin n → ℝ) : ℝ := (n:ℝ)*intrinsicGain u

lemma limitingParityEfficiency_pos : 0 < limitingParityEfficiency := by
  unfold limitingParityEfficiency
  positivity [scalarF0_limitingGain_pos,limitingGain_pos,Real.pi_pos]

lemma scalarF0_one_lower : (1/2:ℝ) ≤ scalarF0 1 := by
  apply ge_of_tendsto (balancedParity_normalized_tendsto 1 (by norm_num))
  exact Eventually.of_forall (fun r => by
    apply (le_div_iff₀ (oddParityKappa_pos r)).mpr
    linarith [balancedParity_one_lower r])

lemma limitingParityEfficiency_gt_half : Real.sqrt (2/Real.pi)/2 < limitingParityEfficiency := by
  have h := scalarRatio_global_strict_max 1 (by norm_num) (by linarith [limitingGain_mem.1])
  simp only [div_one] at h
  have hs := scalarF0_one_lower.trans_lt h
  have hp : 0 < Real.sqrt (2/Real.pi) := by positivity [Real.pi_pos]
  have hm := mul_lt_mul_of_pos_left hs hp
  unfold limitingParityEfficiency
  simpa only [mul_one_div,mul_div_assoc] using hm

lemma balancedParity_abs_of_one_le (r : ℕ) (a : ℝ) (ha : 1 ≤ a) :
    |parityCorrelation (fun _ : Fin (2*r+1) => a) 0|=balancedParity r a := by
  have ht := scalar_tanh_monotone ha
  have ht1 := tanh_one_gt_three_quarters
  have hp : 0 < balancedParity r a := by
    have hlow := balancedParity_lower r a (by linarith)
    have hk := oddParityKappa_pos r
    have hprod := mul_pos hk (show 0 < 2*Real.tanh a-1 by linarith)
    linarith
  have h := abs_of_pos hp
  simpa only [balancedParity,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul] using h

lemma intrinsicEfficiency_balanced (r : ℕ) (a : ℝ) (ha : 1 ≤ a) :
    intrinsicEfficiency (fun _ : Fin (2*r+1) => a)=
      Real.sqrt (2*r+1:ℕ)*balancedParity r a/a := by
  have hap : 0 < a := by linarith
  have hroot : 0 < Real.sqrt (2*r+1:ℕ) := by positivity
  have hE : incomingEnergy (fun _ : Fin (2*r+1) => a)=(2*r+1:ℕ)*a^2 := by simp [incomingEnergy]
  unfold intrinsicEfficiency intrinsicGain
  rw [balancedParity_abs_of_one_le r a ha,hE,Real.sqrt_mul (by positivity),Real.sqrt_sq hap.le]
  field_simp
  rw [Real.sq_sqrt (by positivity)]
  ring

lemma balanced_efficiency_tendsto (a : ℝ) (ha : 1 ≤ a) :
    Tendsto (fun r => intrinsicEfficiency (fun _ : Fin (2*r+1) => a)) atTop
      (𝓝 (Real.sqrt (2/Real.pi)*scalarF0 a/a)) := by
  have h := (scaled_oddParityKappa_tendsto.mul
    (balancedParity_normalized_tendsto a (by linarith))).div_const a
  apply h.congr'
  exact Eventually.of_forall (fun r => by
    dsimp only
    rw [intrinsicEfficiency_balanced r a ha]
    push_cast
    field_simp [(oddParityKappa_pos r).ne'])

/-- This is a lower bound for every actual maximizer, not a presupposed
convergence of the maximum value. -/
theorem maximizer_efficiency_eventual_lower (r : ℕ → ℕ) (hr : Tendsto r atTop atTop)
    (u : ∀ k,Fin (2*r k+1) → ℝ) (hu : ∀ k,IsIntrinsicMaximizer (u k)) :
    ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k) := by
  intro ε hε
  have ht := (balanced_efficiency_tendsto limitingGain (by linarith [limitingGain_mem.1])).comp hr
  filter_upwards [ht.eventually (lt_mem_nhds (by
    change limitingParityEfficiency-ε < limitingParityEfficiency
    linarith))] with k hk
  have hm := mul_le_mul_of_nonneg_left (hu k (fun _ => limitingGain))
    (show (0:ℝ) ≤ (2*r k+1:ℕ) by positivity)
  exact hk.le.trans hm

lemma eventual_efficiency_bounds_compare (f : ℕ → ℝ) (L U : ℝ)
    (hL : ∀ ε > 0,∀ᶠ k in atTop,L-ε ≤ f k)
    (hU : ∀ ε > 0,∀ᶠ k in atTop,f k ≤ U+ε) : L ≤ U := by
  by_contra h
  have hgap : 0 < (L-U)/3 := by linarith
  obtain ⟨k,hkL,hkU⟩ := ((hL _ hgap).and (hU _ hgap)).exists
  linarith

end NeuralGeneralization.OnlineLowerTanh
