import NeuralGeneralization.RobustMainAssembly

/-! # Actual retained-posterior inputs to the compression construction

This module discharges target mass, normalization, relative entropy, and
uniform noise-radius assumptions directly for the concrete robust network
posterior. No compression or learning conclusion is assumed here.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.RobustMainAssembly
open ConcreteModel RobustPosterior

/-- A uniform compression scale, also small enough for score quantization. -/
def mainCompressionRadius (d C r : ℕ) (c ε : ℝ) : ℝ :=
  min (1/6) (c / Real.sqrt (1+((r:ℝ)+1)*mainReadoutCap d C r c ε))

theorem mainCompressionRadius_pos (d C r : ℕ) {c ε : ℝ}
    (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) :
    0 < mainCompressionRadius d C r c ε := by
  have hcap := mainReadoutCap_ge_eight d C r c hε hε1
  unfold mainCompressionRadius
  apply lt_min (by norm_num)
  apply div_pos hc
  apply Real.sqrt_pos.mpr
  have hr : (0:ℝ) ≤ r := Nat.cast_nonneg _
  nlinarith

theorem mainCompressionRadius_le_sixth (d C r : ℕ) (c ε : ℝ) :
    mainCompressionRadius d C r c ε ≤ 1/6 := min_le_left _ _

theorem mainCompressionRadius_le_actual {d C N r : ℕ} {c ε : ℝ}
    (hc : 0 < c) (w : Weights d N r)
    (hread : readoutEnergy w ≤ mainReadoutCap d C r c ε) :
    mainCompressionRadius d C r c ε ≤ robustRadius c w :=
  (min_le_right _ _).trans (calibrated_radius_lower hc w hread)

/-- Concrete normalized retained law, exact KL budget, and robust support
with a radius independent of width and Gaussian scale. -/
theorem actual_retained_compression_inputs {d C N r n : ℕ}
    (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c ε σ : ℝ} (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (sample : Fin n → Cube d) :
    IsProbabilityMeasure (retainedPosterior (N:=N) (r:=r) Real.tanh c σ
      (mainReadoutCap d C r c ε) B.computes sample) ∧
    klDiv (retainedPosterior (N:=N) (r:=r) Real.tanh c σ
      (mainReadoutCap d C r c ε) B.computes sample) (smallPrior d N r σ) ≤
      ENNReal.ofReal ((digitalMassPolynomial d C r c+1)/σ^2) ∧
    ∀ᵐ w ∂retainedPosterior (N:=N) (r:=r) Real.tanh c σ
      (mainReadoutCap d C r c ε) B.computes sample,
      w ∈ robustEvent Real.tanh c ∧
      readoutEnergy w ≤ mainReadoutCap d C r c ε ∧
      mainCompressionRadius d C r c ε ≤ robustRadius c w := by
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN : 0 < N := lt_of_lt_of_le hC hCN
  have hN1 : (1:ℝ) ≤ N := by exact_mod_cast hN
  have hσ1 : σ^2 ≤ 1 := by nlinarith [sq_nonneg σ]
  have htarget := robust_boolean_target_mass hd B hCN hc hσ hscale
  have hβ : 0 < ε/12 := by positivity
  have hβ1 : ε/12 ≤ 1 := by linarith
  have hβhalf : ε/12 ≤ (1/2:ℝ) := by linarith
  have htail := robustPosterior_readout_tail tanh_continuous hd hN hc hσ hscale
    hβ hβ1 (mainReadoutCap_ge_eight d C r c hε hε1)
    (mainReadoutCap_budget d C r c ε) B.computes sample htarget
  refine ⟨retainedPosterior_isProbability tanh_continuous hc hσ hσ1 hβhalf
    B.computes sample htarget htail,
    retainedPosterior_klDiv_bound tanh_continuous hc hσ hσ1 hβhalf
      B.computes sample htarget htail, ?_⟩
  filter_upwards [retained_supported tanh_continuous hc σ
    (mainReadoutCap d C r c ε) B.computes sample] with w hw
  exact ⟨hw.1,hw.2,mainCompressionRadius_le_actual hc w hw.2⟩

end NeuralGeneralization.RobustMainAssembly
