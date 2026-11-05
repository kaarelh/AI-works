import NeuralGeneralization.HiddenOnlySupport
import NeuralGeneralization.MonotoneScoreCompression

/-! Removing scalar injection from a reconstruction path leaves exactly the
hidden disturbance permitted by the support. Scalar reconstruction error and
finite-grid rounding use the remaining comparison budget. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel RobustStatistics RobustCompressionInduction RobustMainProofs
variable {d N r : ℕ}

def hiddenPart (η : NetworkDisturbance N r) : NetworkDisturbance N r := (η.1,0)

lemma hiddenPart_budget (η : NetworkDisturbance N r) :
    noiseBudgetSq (hiddenPart η) ≤ noiseBudgetSq η := by
  simp only [noiseBudgetSq,hiddenPart,zero_pow (by decide : 2 ≠ 0),add_zero]
  exact le_add_of_nonneg_right (sq_nonneg _)

lemma output_split (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) :
    noisyNetworkOutput φ w x η = noisyNetworkOutput φ w x (hiddenPart η)+η.2 := by
  have he : noisyFinalHidden φ w x (hiddenPart η)=noisyFinalHidden φ w x η := rfl
  unfold noisyNetworkOutput
  rw [he]
  simp only [hiddenPart,add_zero]

lemma readout_zero_of_energy (hN : 0 < N) (w : Weights d N r)
    (hw : readoutEnergy w=0) (i : Fin N) : w (Sum.inr (Sum.inr i))=0 := by
  have hs : ∑ j, w (Sum.inr (Sum.inr j))^2=0 := by
    exact (mul_eq_zero.mp hw).resolve_left (by exact_mod_cast hN.ne')
  have hi := Finset.single_le_sum (fun j _ => sq_nonneg (w (Sum.inr (Sum.inr j)))) (Finset.mem_univ i)
  rw [hs] at hi
  nlinarith [sq_nonneg (w (Sum.inr (Sum.inr i)))]

lemma hidden_score_close_zero (hN : 0 < N) (φ : ℝ → ℝ) (w : Weights d N r)
    (hw : readoutEnergy w=0) (x : Cube d) (η : NetworkDisturbance N r) :
    clippedScore (noisyNetworkOutput φ w x (hiddenPart η))=clippedScore (networkOutput φ w x) := by
  simp only [noisyNetworkOutput,networkOutput,readout_zero_of_energy hN w hw,
    zero_mul,Finset.sum_const_zero,hiddenPart,add_zero]

lemma robustRadius_le_radius {c : ℝ} (hc : 0 < c) {w : Weights d N r}
    (hw : 0 < readoutEnergy w) : robustRadius c w ≤ radius c w := by
  apply div_le_div_of_nonneg_left hc.le (Real.sqrt_pos.mpr (by positivity))
  exact Real.sqrt_le_sqrt (by linarith)

lemma good_of_hidden_comparison (hN : 0 < N) (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    {c R a : ℝ} (hc : 0 < c) (hw : atInput φ c w x)
    (hR : 0 ≤ R) (hR30 : R ≤ 1/30) (hr : R ≤ robustRadius c w)
    (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ (R/2)^2)
    (ha : |a-noisyNetworkOutput φ w x η| ≤ R/8) :
    TwoMarginTransport.good (networkOutput φ w x) a := by
  have hhidden : |clippedScore (noisyNetworkOutput φ w x (hiddenPart η))-
      clippedScore (networkOutput φ w x)| ≤ 1/16 := by
    by_cases he : readoutEnergy w=0
    · rw [hidden_score_close_zero hN φ w he x η,sub_self,abs_zero]
      norm_num
    · have hepos : 0 < readoutEnergy w := lt_of_le_of_ne (readoutEnergy_nonneg w) (Ne.symm he)
      have hrad := hr.trans (robustRadius_le_radius hc hepos)
      have hs : (R/2)^2 ≤ (radius c w)^2 := by nlinarith [radius_pos hc hepos]
      exact (hw.resolve_left he) (hiddenPart η) ((hiddenPart_budget η).trans (hη.trans hs)) rfl
  have hout := noiseBudgetSq_output η (by positivity : 0 ≤ R/2) hη
  have houtclose : |clippedScore (noisyNetworkOutput φ w x η)-
      clippedScore (noisyNetworkOutput φ w x (hiddenPart η))| ≤ R/2 := by
    apply (clippedScore_lipschitz _ _).trans
    simpa only [output_split φ w x η,add_sub_cancel_left] using hout
  apply TwoMarginTransport.good_of_score_close
  calc
    |clippedScore a-clippedScore (networkOutput φ w x)| ≤
        |clippedScore a-clippedScore (noisyNetworkOutput φ w x η)|+
        |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| := abs_sub_le _ _ _
    _ ≤ R/8+(R/2+1/16) := add_le_add ((clippedScore_lipschitz _ _).trans ha)
      ((abs_sub_le _ (clippedScore (noisyNetworkOutput φ w x (hiddenPart η))) _).trans
        (add_le_add houtclose hhidden))
    _ ≤ 1/12 := by linarith

lemma rounded_path_good {m M B R : ℕ} (hN : 0 < N)
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (v : Weights d m r) (x : Cube d) (h : HiddenPath N r)
    {c ρ : ℝ} (hc : 0 < c) (hw : atInput φ c w x)
    (hr0 : 0 ≤ ρ) (hr30 : ρ ≤ 1/30) (hr : ρ ≤ robustRadius c w)
    (hB : 0 < B) (hR : 0 < R) (hv : boundedWeights B v)
    (hround : 1/(R:ℝ) ≤ ρ/8)
    (hcost : reconstructionPathCost φ w v x h ≤ (ρ/2)^2) :
    TwoMarginTransport.rule.good (networkOutput φ w x)
      (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x) := by
  let η := pathDisturbance φ w x h (networkOutput φ v x)
  apply good_of_hidden_comparison hN φ w x hc hw hr0 hr30 hr η
  · rw [pathDisturbance_budget_eq_hiddenPathCost]
    exact hcost
  · rw [pathDisturbance_output,abs_sub_comm]
    exact (padAndRoundCode_output_close hmM φ hφ hB hR v hv x).trans hround

end NeuralGeneralization.HiddenOnly
