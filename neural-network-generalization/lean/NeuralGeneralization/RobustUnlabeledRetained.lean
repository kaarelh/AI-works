import NeuralGeneralization.RobustUnlabeledPosterior
import NeuralGeneralization.RobustMainPosterior

/-! Exact Gaussian readout truncation for the input-adapted posterior. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustUnlabeled
open ConcreteModel RobustPosterior RobustMainAssembly
variable {d C N r m n : ℕ}

def retained (c σ cap : ℝ) (globalMargin : Bool) (f : BooleanFunction d)
    (U : Fin m → Cube d) (S : Fin n → Cube d) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (posteriorEvent c globalMargin f U S ∩ readoutCap cap)

lemma retained_eq_cond {c : ℝ} (hc : 0 < c) (σ cap : ℝ) (globalMargin : Bool)
    (f : BooleanFunction d) (U : Fin m → Cube d) (S : Fin n → Cube d) :
    retained (N := N) (r := r) c σ cap globalMargin f U S =
      cond (posterior c σ globalMargin f U S) (readoutCap cap) :=
  (cond_cond_eq_cond_inter (measurable_posteriorEvent hc globalMargin f U S)
    (measurable_readoutCap cap) _).symm

/-- All inputs to compression and loss restoration are derived from the actual
conditioned Gaussian. The final domination controls posterior instability. -/
theorem retained_inputs (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ ε : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hε : 0 < ε) (hε1 : ε < 1) (globalMargin : Bool)
    (U : Fin m → Cube d) (S : Fin n → Cube d) :
    let Q := posterior (N := N) (r := r) c σ globalMargin B.computes U S
    let Q' := retained (N := N) (r := r) c σ (mainReadoutCap d C r c ε) globalMargin B.computes U S
    IsProbabilityMeasure Q ∧ IsProbabilityMeasure Q' ∧
    klDiv Q' (smallPrior d N r σ) ≤ ENNReal.ofReal ((digitalMassPolynomial d C r c+1)/σ^2) ∧
    (∀ᵐ w ∂Q',w ∈ posteriorEvent c globalMargin B.computes U S ∧
      readoutEnergy w ≤ mainReadoutCap d C r c ε ∧
      mainCompressionRadius d C r c ε ≤ robustRadius c w) ∧
    (∀ A : Set (Weights d N r),Q.real A ≤ ε/12+Q'.real A) ∧
    (∀ A : Set (Weights d N r),Q'.real A ≤ 2*Q.real A) := by
  let F := posteriorEvent (N := N) (r := r) c globalMargin B.computes U S
  let cap := mainReadoutCap d C r c ε
  let Q := posterior (N := N) (r := r) c σ globalMargin B.computes U S
  let Q' := retained (N := N) (r := r) c σ cap globalMargin B.computes U S
  have hF : MeasurableSet F := measurable_posteriorEvent hc globalMargin B.computes U S
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN := hC.trans_le hCN
  have hN1 : (1:ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ^2 ≤ 1 := by nlinarith [sq_nonneg σ]
  have hβ : 0 < ε/12 := by positivity
  have hβ1 : ε/12 ≤ 1 := by linarith
  have hβhalf : ε/12 ≤ (1/2:ℝ) := by linarith
  have hmass := target_mass hd B hCN hc hσ hscale globalMargin U S
  have hcap := mainReadoutCap_ge_eight d C r c hε hε1
  have htail : Q.real (readoutCap cap)ᶜ ≤ ε/12 := by
    apply conditional_tail_of_exponential_bounds (smallPrior d N r σ) F (readoutCap cap)ᶜ hF
      (sq_pos_of_pos hσ) hs1 hβ hβ1 hmass _ (mainReadoutCap_budget d C r c ε)
    have heq : (readoutCap (d := d) (N := N) (r := r) cap)ᶜ = {w | cap < readoutEnergy w} := by
      ext w
      simp [readoutCap]
    rw [heq]
    exact smallPrior_readout_tail hd hN hσ (by dsimp [cap]; nlinarith)
  letI : IsProbabilityMeasure Q := posterior_probability hd B hCN hc hσ hscale globalMargin U S
  have hretmass := retained_exponential_mass (smallPrior d N r σ) F (readoutCap cap) hF
    (measurable_readoutCap cap) (sq_pos_of_pos hσ) hs1 hβhalf hmass htail
  have hretne : smallPrior d N r σ (F ∩ readoutCap cap) ≠ 0 := by
    have hp := (Real.exp_pos _).trans_le hretmass
    intro hz
    simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
    exact (lt_irrefl 0) hp
  letI : IsProbabilityMeasure Q' := cond_isProbabilityMeasure hretne
  have hhalf : (1/2:ℝ) ≤ Q.real (readoutCap cap) := by
    rw [probReal_compl_eq_one_sub (measurable_readoutCap cap)] at htail
    linarith
  have heq : Q' = cond Q (readoutCap cap) := retained_eq_cond hc σ cap globalMargin B.computes U S
  refine ⟨inferInstance,inferInstance,?_,?_,?_,?_⟩
  · exact retained_klDiv_bound (smallPrior d N r σ) F (readoutCap cap) hF
      (measurable_readoutCap cap) (sq_pos_of_pos hσ) hs1 hβhalf hmass htail
  · have hh := ae_cond_mem (μ := smallPrior d N r σ) (hF.inter (measurable_readoutCap cap))
    filter_upwards [hh] with w hw
    exact ⟨hw.1,hw.2,mainCompressionRadius_le_actual hc w hw.2⟩
  · intro A
    rw [show retained (N := N) (r := r) c σ (mainReadoutCap d C r c ε) globalMargin B.computes U S = Q' from rfl,heq]
    exact retained_restore_of_tail Q (readoutCap cap) A (measurable_readoutCap cap) (by linarith) htail
  · intro A
    change Q'.real A ≤ 2*Q.real A
    rw [heq]
    apply (cond_real_le_ratio Q (readoutCap cap) A (measurable_readoutCap cap)).trans
    apply (div_le_iff₀ (by linarith : 0 < Q.real (readoutCap cap))).mpr
    nlinarith [measureReal_nonneg (μ := Q) (s := A)]

end NeuralGeneralization.RobustUnlabeled
