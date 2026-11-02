import NeuralGeneralization.PointwiseRobustCompression
import NeuralGeneralization.RobustCompressionLargeWidthProof

/-! The proved large-width construction and the small-width branch instantiated
at the main theorem's common polynomial resources, without global stability. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.RobustMainProofs
open ConcreteModel RobustCompressionInput RobustMainAssembly

abbrev PointwiseCode (d C r : ℕ) (c ε : ℝ) :=
  let p := mainCompressionResources d C r c ε
  RobustOutputCode p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError

def pointwiseCandidate (d C r : ℕ) (c ε : ℝ) : PointwiseCode d C r c ε → Cube d → ℝ :=
  let p := mainCompressionResources d C r c ε
  robustGridOutput p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError Real.tanh

theorem pointwise_main_compression {d C N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {c ε σ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal ((digitalMassPolynomial d C r c+1)/σ^2))
    (hrad : ∀ᵐ w ∂Q,mainCompressionRadius d C r c ε ≤ robustRadius c w) :
    ∃ Γ : Measure (PointwiseCode d C r c ε),IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube d,RobustStatistics.ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (RobustStatistics.scoreFailure (fun w => networkOutput Real.tanh w x)
            (fun h => pointwiseCandidate d C r c ε h x)) ≤
          ε/12+Q.real {w | ¬ stableAt Real.tanh c w x} := by
  let p := mainCompressionResources d C r c ε
  obtain ⟨hL,hK,hAf,hR,hKreal,hfailure,hradius⟩ := mainResources_valid d C r hc hε hε1
  let t := Real.sqrt ((N:ℝ)*σ^2)
  have ht : 0 < t := Real.sqrt_pos.mpr (by positivity)
  have htdef : t^2 = (N:ℝ)*σ^2 := Real.sq_sqrt (by positivity)
  have ht1 : t^2 ≤ 1 := htdef.le.trans hscale
  have hKLp : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (N*(p.energy:ℝ)/t^2) := by
    refine hKL.trans (ENNReal.ofReal_le_ofReal ?_)
    rw [htdef]
    calc
      (digitalMassPolynomial d C r c+1)/σ^2 ≤ (p.energy:ℝ)/σ^2 :=
        div_le_div_of_nonneg_right hKreal (sq_nonneg σ)
      _ = (N:ℝ)*p.energy/((N:ℝ)*σ^2) := by
        have hNR : (N:ℝ) ≠ 0 := by positivity
        field_simp
  have hrad' : ∀ᵐ w ∂Q,1/(p.inverseRadius:ℝ) ≤ robustRadius c w :=
    hrad.mono (fun w hw => hradius.trans hw)
  haveI : IsProbabilityMeasure (Q : Measure (Weights p.dimension N (p.depth-2))) :=
    inferInstanceAs (IsProbabilityMeasure (Q : Measure (Weights d N r)))
  obtain ⟨Γ,hΓ,π,hfail⟩ := p.pointwise_finite_grid_of_large_width_raw hd hN hAf hR
    hc ht ht1 htdef Q hKLp Real.tanh tanh_admissible hrad' (fun hlarge =>
      largeWidthRawCompression p hd hL hK hAf hR N hlarge σ t hσ ht ht1 htdef Q inferInstance hKLp)
  refine ⟨Γ,hΓ,π,?_⟩
  intro x
  change 1/(p.inverseFailure:ℝ) ≤ ε/12 at hfailure
  exact (hfail x).trans (add_le_add hfailure le_rfl)

end NeuralGeneralization.RobustMainProofs
