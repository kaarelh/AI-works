import NeuralGeneralization.MonotoneScorePolynomial
import NeuralGeneralization.MonotoneScoreLocalizedPolynomial
import NeuralGeneralization.MarginBandMinimality

/-! Exact specialization to the margin-band score. Its positive gap is 1/4,
so the common compressor and literal finite-class budget are unchanged. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.ScoreTransform
open ConcreteModel

lemma marginBand_gap : gap MarginBand.score = 1/4 := by
  norm_num [gap,MarginBand.score,Real.sign]

lemma marginBand_atInput (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) :
    atInput MarginBand.score φ c w x ↔ MarginBand.atInput φ c w x := by
  simp only [atInput,MarginBand.atInput,marginBand_gap]
  norm_num

lemma marginBand_support (φ : ℝ → ℝ) (c : ℝ) :
    support (d := d) (N := N) (r := r) MarginBand.score φ c = MarginBand.support φ c := by
  ext w
  simp only [support,MarginBand.support,Set.mem_setOf_eq,marginBand_atInput]

lemma resources_quarter (d r : ℕ) (K c ε : ℝ) :
    resources d r K c ε (1/4) = RobustConditioned.resources d r K c ε := by
  unfold resources RobustConditioned.resources
  congr 1
  unfold radius
  norm_num only [show 2*(1/4:ℝ)/3 = 1/6 by norm_num]
  exact min_eq_right (min_le_left _ _)

/-- Full-gap minimality for the actual support predicates. -/
theorem full_gap_support_subset {F : ℝ → ℝ} (hF : Admissible F) (hfull : gap F = 1/4)
    (φ : ℝ → ℝ) (c : ℝ) :
    support (d := d) (N := N) (r := r) F φ c ⊆ MarginBand.support φ c := by
  intro w hw x η hη
  have hh := (hF.full_gap_contraction hfull (noisyNetworkOutput φ w x η) (networkOutput φ w x)).trans (hw x η hη)
  simpa only [hfull,show (1/4:ℝ)/4 = 1/16 by norm_num] using hh

end NeuralGeneralization.ScoreTransform
namespace NeuralGeneralization.MarginBand
open ConcreteModel RobustStatistics RobustConfidence RobustMainAssembly
variable {d C r : ℕ}

/-- The exact original entropy budget applies to U; no new parameter or
weakened training likelihood is introduced in this specialization. -/
theorem learning (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    {c ε δ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (n : ℕ) (hn : 0 < n)
    (hbudget : 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (2/δ)) ≤
      (n:ℝ)*(ε/12)^2) :
    ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
      1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
      ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
      ∀ globalMargin : Bool,
        0 < (smallPrior d N r σ).real (ScoreTransform.posteriorEvent score c globalMargin B.computes S) ∧
        gibbsMarginRisk D (ScoreTransform.posterior (N := N) (r := r) score c σ globalMargin B.computes S)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε/3 ∧
        D.real {x | correctConfidence (ScoreTransform.posterior (N := N) (r := r) score c σ globalMargin B.computes S)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ ε := by
  apply ScoreTransform.learning ScoreTransform.marginBand_admissible hd B hc hε hε1 hδ D n hn
  rw [ScoreTransform.marginBand_gap,ScoreTransform.resources_quarter]
  change 2*((mainCompressionResources d C r c ε).entropyBudget+Real.log (2/δ)) ≤ (n:ℝ)*(ε/12)^2
  exact hbudget

end NeuralGeneralization.MarginBand
