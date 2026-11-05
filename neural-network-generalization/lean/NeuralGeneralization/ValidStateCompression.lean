import NeuralGeneralization.ValidStateMeasurability
import NeuralGeneralization.TwoMarginComparison
import NeuralGeneralization.ValidStateComparisonCompression
import NeuralGeneralization.RobustConditionedCompression

/-! Actual Gaussian compression for the literal valid-hidden-state support. The
candidate law and its polynomial resources are the original robust ones. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.ValidState
open ConcreteModel RobustStatistics RobustCompressionInduction RobustMainProofs

lemma rounded_path_good {d N m M r B R : ℕ}
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (v : Weights d m r) (x : Cube d) (h : HiddenPath N r)
    {c radius : ℝ} (hvalid : validHiddenPath h) (hw : atInput φ c w x)
    (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1/6) (hr : radius ≤ robustRadius c w)
    (hB : 0 < B) (hR : 0 < R) (hv : boundedWeights B v)
    (hround : 1/(R:ℝ) ≤ radius/8)
    (hcost : reconstructionPathCost φ w v x h ≤ (radius/2)^2) :
    TwoMarginTransport.good (networkOutput φ w x)
      (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x) := by
  let η := pathDisturbance φ w x h (networkOutput φ v x)
  have hnoise : noiseBudgetSq η ≤ (robustRadius c w)^2 := by
    have hh : noiseBudgetSq η ≤ (radius/2)^2 := by
      rw [pathDisturbance_budget_eq_hiddenPathCost]
      exact hcost
    apply hh.trans
    have hr' : 0 ≤ robustRadius c w := hr0.trans hr
    nlinarith
  have hs := (atInput_iff_path φ c w x).mp hw h hvalid (networkOutput φ v x) hnoise
  have he : |robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x-
      networkOutput φ v x| ≤ radius/8 := by
    rw [abs_sub_comm]
    exact (padAndRoundCode_output_close hmM φ hφ hB hR v hv x).trans hround
  apply TwoMarginTransport.good_of_score_close
  calc
    _ ≤ |clippedScore (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x)-
        clippedScore (networkOutput φ v x)|+
        |clippedScore (networkOutput φ v x)-clippedScore (networkOutput φ w x)| := abs_sub_le _ _ _
    _ ≤ radius/8+1/16 := add_le_add ((clippedScore_lipschitz _ _).trans he) hs
    _ ≤ 1/12 := by linarith

/-- One common finite law, with failure charged only to the posterior mass
outside the valid-hidden-state condition at the queried input. -/
theorem pointwise_compression {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K c ε σ : ℝ} (hK0 : 0 ≤ K) (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal ((K+1)/σ^2))
    (hrad : ∀ᵐ w ∂Q,RobustConditioned.radius r K c ε ≤ robustRadius c w) :
    ∃ Γ : Measure (RobustConditioned.Code d r K c ε),IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube d,ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (TwoMarginTransport.rule.failure (fun w => networkOutput Real.tanh w x)
            (fun h => RobustConditioned.candidate d r K c ε h x)) ≤
          ε/12+Q.real {w | ¬ atInput Real.tanh c w x} := by
  let p := RobustConditioned.resources d r K c ε
  obtain ⟨hL,hK,hAf,hR,hKreal,hfailure,hradius⟩ :=
    RobustConditioned.resources_valid d r hK0 hc hε hε1
  change 6 ≤ p.inverseRadius at hR
  let t := Real.sqrt ((N:ℝ)*σ^2)
  have ht : 0 < t := Real.sqrt_pos.mpr (by positivity)
  have htdef : t^2 = (N:ℝ)*σ^2 := Real.sq_sqrt (by positivity)
  have ht1 : t^2 ≤ 1 := htdef.le.trans hscale
  have hKLp : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (N*(p.energy:ℝ)/t^2) := by
    refine hKL.trans (ENNReal.ofReal_le_ofReal ?_)
    rw [htdef]
    calc
      (K+1)/σ^2 ≤ (p.energy:ℝ)/σ^2 := div_le_div_of_nonneg_right hKreal (sq_nonneg σ)
      _ = (N:ℝ)*p.energy/((N:ℝ)*σ^2) := by
        have hNR : (N:ℝ) ≠ 0 := by positivity
        field_simp
  have hrad' : ∀ᵐ w ∂Q,1/(p.inverseRadius:ℝ) ≤ robustRadius c w :=
    hrad.mono (fun w hw => hradius.trans hw)
  have hRp : (0:ℝ) < p.inverseRadius := by exact_mod_cast (show 0 < p.inverseRadius by omega)
  have hRp6 : (6:ℝ) ≤ p.inverseRadius := by exact_mod_cast hR
  have hsmallbound : 1/(p.inverseOutputError:ℝ) ≤ (1/12:ℝ) := by
    apply one_div_le_one_div_of_le (by norm_num)
    simp only [RobustCompressionInput.inverseOutputError,Nat.cast_mul,Nat.cast_ofNat]
    linarith
  have hround : 1/(p.inverseOutputError:ℝ) ≤ (1/(p.inverseRadius:ℝ))/8 := by
    simp only [RobustCompressionInput.inverseOutputError,Nat.cast_mul,Nat.cast_ofNat]
    field_simp
    norm_num
  haveI : IsProbabilityMeasure (Q : Measure (Weights p.dimension N (p.depth-2))) :=
    inferInstanceAs (IsProbabilityMeasure (Q : Measure (Weights d N r)))
  obtain ⟨Γ,hΓ,π,hfail⟩ := pointwise_valid_comparison_compression p hd hN hL hK hAf hR
    hσ ht ht1 htdef Q hKLp TwoMarginTransport.rule (atInput Real.tanh c)
    (measurable_atInput tanh_continuous hc) hrad'
    (fun _ _ _ hh => TwoMarginTransport.good_of_raw_close (hh.trans hsmallbound))
    (fun hmM w v x h hvalid hw hr hv hcost => rounded_path_good hmM Real.tanh tanh_admissible
      w v x h hvalid hw (by positivity) (one_div_le_one_div_of_le (by norm_num) hRp6)
      hr p.weightBound_pos (by dsimp [RobustCompressionInput.inverseOutputError]; omega)
      hv hround hcost)
  refine ⟨Γ,hΓ,π,?_⟩
  intro x
  change 1/(p.inverseFailure:ℝ) ≤ ε/12 at hfailure
  exact (hfail x).trans (add_le_add hfailure le_rfl)

end NeuralGeneralization.ValidState
