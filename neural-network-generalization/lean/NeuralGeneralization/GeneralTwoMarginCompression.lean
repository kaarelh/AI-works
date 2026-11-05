import NeuralGeneralization.GeneralTwoMarginSupport
import NeuralGeneralization.MonotoneScoreResources
import NeuralGeneralization.RobustComparisonCompression
import NeuralGeneralization.RobustConditionedCompression

/-! Actual Gaussian compression for arbitrary two-margin transport levels.
The common radius carries the additional dependence on the positive gap. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.GeneralTwoMargin
open ConcreteModel RobustStatistics RobustCompressionInduction RobustMainProofs
open ScoreTransform (resources resources_valid Code candidate)
variable {m u θ : ℝ}

lemma rounded_path_good (hF : Parameters m u θ) {d N W M r B R : ℕ}
    (hmM : W ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (v : Weights d W r) (x : Cube d) (h : HiddenPath N r)
    {c radius : ℝ} (hw : atInput m u θ φ c w x)
    (hr0 : 0 ≤ radius) (hrgap : radius ≤ 2*gap m u θ/3) (hr : radius ≤ robustRadius c w)
    (hB : 0 < B) (hR : 0 < R) (hv : boundedWeights B v)
    (hround : 1/(R:ℝ) ≤ radius/8)
    (hcost : reconstructionPathCost φ w v x h ≤ (radius/2)^2) :
    hF.rule.good (networkOutput φ w x)
      (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x) := by
  let η := pathDisturbance φ w x h (networkOutput φ v x)
  have hnoise : noiseBudgetSq η ≤ (robustRadius c w)^2 := by
    have hh : noiseBudgetSq η ≤ (radius/2)^2 := by
      rw [pathDisturbance_budget_eq_hiddenPathCost]
      exact hcost
    apply hh.trans
    have hr' : 0 ≤ robustRadius c w := hr0.trans hr
    nlinarith
  apply hF.good_of_noisy_comparison (fun b => ⟨fun hz => (hw b).1 hz η hnoise,fun hz => (hw b).2 hz η hnoise⟩) _ hrgap
  have he : |robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x-
      noisyNetworkOutput φ w x η| ≤ radius/8 := by
    rw [pathDisturbance_output,abs_sub_comm]
    exact (padAndRoundCode_output_close hmM φ hφ hB hR v hv x).trans hround
  exact he

/-- One common finite law, with failure charged only to the posterior mass
outside the transformed-score condition at the queried input. -/
theorem pointwise_compression (hF : Parameters m u θ) {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K c ε σ : ℝ} (hK0 : 0 ≤ K) (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal ((K+1)/σ^2))
    (hrad : ∀ᵐ w ∂Q,RobustConditioned.radius r K c ε ≤ robustRadius c w) :
    ∃ Γ : Measure (Code d r K c ε (gap m u θ)),IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube d,ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (hF.rule.failure (fun w => networkOutput Real.tanh w x)
            (fun h => candidate d r K c ε (gap m u θ) h x)) ≤
          ε/12+Q.real {w | ¬ atInput m u θ Real.tanh c w x} := by
  let p := resources d r K c ε (gap m u θ)
  obtain ⟨hL,hK,hAf,hR,hKreal,hfailure,hradius⟩ :=
    resources_valid d r hF.gap_pos hK0 hc hε hε1
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
    hrad.mono (fun w hw => hradius.trans ((min_le_right _ _).trans hw))
  have hRp : (0:ℝ) < p.inverseRadius := by exact_mod_cast (show 0 < p.inverseRadius by omega)
  have hRp6 : (6:ℝ) ≤ p.inverseRadius := by exact_mod_cast hR
  have hround : 1/(p.inverseOutputError:ℝ) ≤ (1/(p.inverseRadius:ℝ))/8 := by
    simp only [RobustCompressionInput.inverseOutputError,Nat.cast_mul,Nat.cast_ofNat]
    field_simp
    norm_num
  have hrgap : 1/(p.inverseRadius:ℝ) ≤ 2*gap m u θ/3 := hradius.trans (min_le_left _ _)
  have hsmallbound : 1/(p.inverseOutputError:ℝ) ≤ gap m u θ/3 := by
    have hg := hF.gap_pos
    change 0 < gap m u θ at hg
    linarith
  haveI : IsProbabilityMeasure (Q : Measure (Weights p.dimension N (p.depth-2))) :=
    inferInstanceAs (IsProbabilityMeasure (Q : Measure (Weights d N r)))
  obtain ⟨Γ,hΓ,π,hfail⟩ := pointwise_comparison_compression p hd hN hL hK hAf hR
    hσ ht ht1 htdef Q hKLp hF.rule (atInput m u θ Real.tanh c)
    (fun x => measurable_atInput m u θ tanh_continuous hc x) hrad'
    (fun _ _ _ hh => hF.good_of_raw_close (hh.trans hsmallbound))
    (fun hmM w v x h hw hr hv hcost => rounded_path_good hF hmM Real.tanh tanh_admissible
      w v x h hw (by positivity) hrgap
      hr p.weightBound_pos (by dsimp [RobustCompressionInput.inverseOutputError]; omega)
      hv hround hcost)
  refine ⟨Γ,hΓ,π,?_⟩
  intro x
  change 1/(p.inverseFailure:ℝ) ≤ ε/12 at hfailure
  exact (hfail x).trans (add_le_add hfailure le_rfl)

end NeuralGeneralization.GeneralTwoMargin
