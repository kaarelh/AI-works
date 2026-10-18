import NeuralGeneralization.RobustTargetAllWidths
import NeuralGeneralization.RobustStatements

/-!
# One sample event for the actual robust posteriors at every width and scale

The target probability is fully instantiated from the constructive circuit
proof. This module isolates only the finite score-coupling construction,
which is supplied by the separate compression argument. In particular this
is not advertised as a proof of `RobustPolynomialDepthGeneralization` until
that construction and its universal polynomial resource bound are connected.
-/
noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustMainAssembly
open ConcreteModel RobustPosterior RobustConfidence RobustStatistics

/-- Readout truncation level used in the final theorem. -/
def mainReadoutCap (d C r : ℕ) (c ε : ℝ) : ℝ :=
  8+4*(digitalMassPolynomial d C r c-Real.log (ε/12))

theorem mainReadoutCap_ge_eight (d C r : ℕ) (c : ℝ)
    {ε : ℝ} (hε : 0 < ε) (hε1 : ε < 1) : 8 ≤ mainReadoutCap d C r c ε := by
  have hp : 0 ≤ ε/12 := by positivity
  have hle : ε/12 ≤ 1 := by linarith
  have hlog := Real.log_nonpos hp hle
  have hd := digitalMassPolynomial_nonneg d C r c
  unfold mainReadoutCap
  linarith

theorem mainReadoutCap_budget (d C r : ℕ) (c ε : ℝ) :
    4*(digitalMassPolynomial d C r c-Real.log (ε/12)) ≤ mainReadoutCap d C r c ε := by
  unfold mainReadoutCap
  linarith

variable {d C r n : ℕ} {H : Type*}
  [Fintype H] [Nonempty H] [MeasurableSpace H] [MeasurableSingletonClass H]

/-- All-width statistical assembly. The same finite candidate class and
same measurable sample event serve every `N ≥ C` and every allowed scale. -/
theorem actual_target_learning_from_finite_couplings
    (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    {c ε δ Ent : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (candidate : H → Cube d → ℝ) (hn : 0 < n)
    (hcount : Real.log (Fintype.card H : ℝ) ≤ Ent)
    (hbudget : 2*(Ent+Real.log (2/δ)) ≤ (n:ℝ)*(ε/12)^2)
    (hcompression : ∀ (sample : Fin n → Cube d) (N : ℕ), C ≤ N →
      ∀ σ : ℝ, 0 < σ → (N:ℝ)*σ^2 ≤ 1 →
      ∃ Γ : Measure H, IsProbabilityMeasure Γ ∧
        ∃ π : ∀ x : Cube d, ProbabilityCoupling
          (retainedPosterior (N:=N) (r:=r) Real.tanh c σ
            (mainReadoutCap d C r c ε) B.computes sample) Γ,
          ∀ x, (π x).joint.real
            (scoreFailure (fun w => networkOutput Real.tanh w x) (fun h => candidate h x)) ≤ ε/12) :
    ∃ E : Set (Fin n → Cube d), MeasurableSet E ∧
      1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
      ∀ sample ∈ E, ∀ N : ℕ, C ≤ N →
      ∀ σ : ℝ, 0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        0 < (smallPrior d N r σ).real
          (robustPosteriorEvent Real.tanh c B.computes sample) ∧
        gibbsMarginRisk D
          (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε/3 ∧
        D.real {x | correctConfidence
          (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ ε := by
  let E := generalizationEvent D (candidateLoss B.computes candidate) n (ε/12)
  have hevent := common_sample_event_probability D B.computes candidate n hn
    (by positivity : 0 ≤ ε/12) hδ hcount hbudget
  refine ⟨E,hevent.1,hevent.2,?_⟩
  intro sample hs N hCN σ hσ hscale
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN : 0 < N := lt_of_lt_of_le hC hCN
  have htarget := robust_boolean_target_mass hd B hCN hc hσ hscale
  have hpos := (Real.exp_pos _).trans_le
    (posterior_event_mass_lower Real.tanh c σ B.computes sample htarget)
  obtain ⟨Γ,hΓ,π,hfail⟩ := hcompression sample N hCN σ hσ hscale
  letI : IsProbabilityMeasure Γ := hΓ
  have hβ : 0 < ε/12 := by positivity
  have hβhalf : ε/12 ≤ (1/2:ℝ) := by linarith
  have hcap := mainReadoutCap_ge_eight d C r c hε hε1
  have hcapbudget := mainReadoutCap_budget d C r c ε
  have hrisk := robust_network_learning_from_score_couplings tanh_continuous hd hN D
    B.computes candidate sample hn hc hσ hscale hβ hβhalf hcap hcapbudget htarget hs Γ π hfail
  have hconf := robust_network_confidence_from_score_couplings tanh_continuous hd hN D
    B.computes candidate sample hn hc hσ hscale hβ hβhalf hcap hcapbudget
    (by norm_num : (2/3:ℝ)<1) htarget hs Γ π hfail
  refine ⟨hpos,?_,?_⟩
  · nlinarith
  · convert hconf using 1 <;> ring

end NeuralGeneralization.RobustMainAssembly
