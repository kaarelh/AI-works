import NeuralGeneralization.HiddenOnlyComparison

/-! Actual Gaussian compression for hidden-only support. A common radius at
most 1/30 leaves room for the separate scalar error and finite-grid rounding. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel RobustStatistics RobustCompressionInduction RobustMainProofs

/-- One common finite law, with failure charged only to the posterior mass
outside the hidden-only condition at the queried input. -/
theorem pointwise_compression {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K c ε σ : ℝ} (hK0 : 0 ≤ K) (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal ((K+1)/σ^2))
    (hrad : ∀ᵐ w ∂Q,RobustConditioned.radius r K c ε ≤ robustRadius c w) :
    ∃ Γ : Measure (ScoreTransform.Code d r K c ε (1/20)),IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube d,ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (TwoMarginTransport.rule.failure (fun w => networkOutput Real.tanh w x)
            (fun h => ScoreTransform.candidate d r K c ε (1/20) h x)) ≤
          ε/12+Q.real {w | ¬ atInput Real.tanh c w x} := by
  let p := ScoreTransform.resources d r K c ε (1/20)
  obtain ⟨hL,hK,hAf,hR,hKreal,hfailure,hradius⟩ :=
    ScoreTransform.resources_valid d r (by norm_num : (0:ℝ)<1/20) hK0 hc hε hε1
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
  have hr30 : 1/(p.inverseRadius:ℝ) ≤ 1/30 := by
    have hh := hradius.trans (min_le_left _ _)
    norm_num only at hh
    exact hh
  have hsmallbound : 1/(p.inverseOutputError:ℝ) ≤ 1/12 := by
    linarith
  haveI : IsProbabilityMeasure (Q : Measure (Weights p.dimension N (p.depth-2))) :=
    inferInstanceAs (IsProbabilityMeasure (Q : Measure (Weights d N r)))
  obtain ⟨Γ,hΓ,π,hfail⟩ := pointwise_comparison_compression p hd hN hL hK hAf hR
    hσ ht ht1 htdef Q hKLp TwoMarginTransport.rule (atInput Real.tanh c)
    (fun x => measurable_atInput tanh_continuous hc x) hrad'
    (fun _ _ _ hh => TwoMarginTransport.good_of_raw_close (hh.trans hsmallbound))
    (fun hmM w v x h hw hr hv hcost => rounded_path_good hN hmM Real.tanh tanh_admissible
      w v x h hc hw (by positivity) hr30
      hr p.weightBound_pos (by dsimp [RobustCompressionInput.inverseOutputError]; omega)
      hv hround hcost)
  refine ⟨Γ,hΓ,π,?_⟩
  intro x
  change 1/(p.inverseFailure:ℝ) ≤ ε/12 at hfailure
  exact (hfail x).trans (add_le_add hfailure le_rfl)


end NeuralGeneralization.HiddenOnly
