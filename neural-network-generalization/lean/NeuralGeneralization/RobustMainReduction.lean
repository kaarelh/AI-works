import NeuralGeneralization.RobustCompressionParametersMain
import NeuralGeneralization.RobustCouplingAllWidths

/-!
# Main theorem reduced only to the actual large-width raw-path construction

All target mass, posterior normalization, finite rounding, small-width cases,
statistical learning, and universal polynomial bookkeeping are instantiated.
The remaining hypothesis is explicitly a probability coupling of original
weights, compact weights and a virtual hidden path with bounded noise cost.
This reduction is not the unconditional main theorem.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory

namespace NeuralGeneralization.RobustMainProofs
open ConcreteModel RobustCompressionInput RobustMainAssembly RobustMainStatements
open RobustPosterior RobustStatistics

/-- The sole analytic premise still to be supplied by the large-width
construction. There is no prior-mass, statistical, or score-coupling premise. -/
def LargeWidthRawCompression : Prop :=
  ∀ p : RobustCompressionInput, 0 < p.dimension → 2 ≤ p.depth → 1 ≤ p.energy →
    0 < p.inverseFailure → 6 ≤ p.inverseRadius →
    ∀ N : ℕ, p.widthBound < N →
    ∀ σ t : ℝ, 0 < σ → 0 < t → t^2 ≤ 1 → t^2 = N*σ^2 →
    ∀ Q : Measure (Weights p.dimension N (p.depth-2)), IsProbabilityMeasure Q →
      klDiv Q (smallPrior p.dimension N (p.depth-2) σ) ≤
        ENNReal.ofReal (N*(p.energy : ℝ)/t^2) →
      ∃ Γ : Measure (Weights p.dimension p.bankSize (p.depth-2)),
        IsProbabilityMeasure Γ ∧ RawPathCompression Real.tanh Q Γ p.weightBound
          (1/(p.inverseRadius : ℝ)) (1/(p.inverseFailure : ℝ))

theorem mainResources_valid (d C r : ℕ) {c ε : ℝ}
    (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) :
    let p := mainCompressionResources d C r c ε
    2 ≤ p.depth ∧ 1 ≤ p.energy ∧ 0 < p.inverseFailure ∧ 6 ≤ p.inverseRadius ∧
      digitalMassPolynomial d C r c+1 ≤ (p.energy : ℝ) ∧
      1/(p.inverseFailure : ℝ) ≤ ε/12 ∧
      1/(p.inverseRadius : ℝ) ≤ mainCompressionRadius d C r c ε := by
  let ρ := mainCompressionRadius d C r c ε
  have hρ : 0 < ρ := mainCompressionRadius_pos d C r hc hε hε1
  have hρ6 : ρ ≤ 1/6 := mainCompressionRadius_le_sixth d C r c ε
  have hK : 1 ≤ digitalMassPolynomial d C r c+1 := by
    have := digitalMassPolynomial_nonneg d C r c
    linarith
  have hKceil := Nat.le_ceil (digitalMassPolynomial d C r c+1)
  have hAc : (ε/12)⁻¹ ≤ (⌈(ε/12)⁻¹⌉₊ : ℝ) := Nat.le_ceil _
  have hRc : ρ⁻¹ ≤ (⌈ρ⁻¹⌉₊ : ℝ) := Nat.le_ceil _
  have hR6 : (6 : ℝ) ≤ ρ⁻¹ := by
    have h := one_div_le_one_div_of_le hρ hρ6
    norm_num only [one_div_div,div_one,one_div] at h
    exact h
  have hAi : 1/(⌈(ε/12)⁻¹⌉₊ : ℝ) ≤ ε/12 := by
    have h := one_div_le_one_div_of_le (inv_pos.mpr (by positivity : 0 < ε/12)) hAc
    simpa only [one_div,inv_inv] using h
  have hRi : 1/(⌈ρ⁻¹⌉₊ : ℝ) ≤ ρ := by
    have h := one_div_le_one_div_of_le (inv_pos.mpr hρ) hRc
    simpa only [one_div,inv_inv] using h
  dsimp [mainCompressionResources,ofRealParameters]
  refine ⟨by omega,?_,Nat.ceil_pos.mpr (by positivity),?_,hKceil,hAi,hRi⟩
  · exact_mod_cast hK.trans hKceil
  · exact_mod_cast hR6.trans hRc

/-- The universal-depth main result follows from the actual raw-path theorem.
The final unconditional theorem must instantiate this premise, not retain it. -/
theorem robustPolynomialDepth_of_largeWidthRawCompression
    (hraw : LargeWidthRawCompression) : RobustPolynomialDepthGeneralization := by
  obtain ⟨A,hA,m,hpoly⟩ := mainCompressionSampleBudget_polynomial
  refine ⟨A,hA,m,?_⟩
  intro d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  letI : IsProbabilityMeasure D := hD
  let p := mainCompressionResources d C r c ε
  obtain ⟨hL,hK,hAf,hR,hKreal,hfailure,hradius⟩ := mainResources_valid d C r hc hε hε1
  have hRp : 0 < p.inverseRadius := by change 0 < (mainCompressionResources d C r c ε).inverseRadius; omega
  let H := RobustOutputCode p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError
  letI : Nonempty H := ⟨fun _ => ⟨0,by apply Finset.mem_Icc.mpr; constructor <;> omega⟩⟩
  let candidate : H → Cube d → ℝ :=
    robustGridOutput p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError Real.tanh
  have hcount : Real.log (Fintype.card H : ℝ) ≤ (p.entropyBudget : ℝ) :=
    p.log_code_card_le_entropyBudget hRp
  have hbase := (mainPolynomialBase_bounds d C r hc hε hδ hδ1).1
  have hpos : 0 < depthPolynomialEnvelope A m d C r c ε δ := by
    change 0 < A*(mainPolynomialBase d C r c ε δ)^m
    positivity
  have hnpos : 0 < n := by exact_mod_cast hpos.trans_le hn
  have hbudget : 2*((p.entropyBudget : ℝ)+Real.log (2/δ)) ≤ (n : ℝ)*(ε/12)^2 := by
    apply (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    exact (hpoly d C r c ε δ hc hε hε1 hδ hδ1).trans hn
  apply actual_target_learning_from_finite_couplings hd B hc hε hε1 hδ D
    candidate hnpos hcount hbudget
  intro sample N hCN σ hσ hscale
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using B.constant.isLt)
  have hN : 0 < N := lt_of_lt_of_le hC hCN
  let Q := retainedPosterior (N := N) (r := r) Real.tanh c σ
    (mainReadoutCap d C r c ε) B.computes sample
  obtain ⟨hQ,hKL,hsupport⟩ := actual_retained_compression_inputs hd B hCN hc hε hε1 hσ hscale sample
  letI : IsProbabilityMeasure Q := hQ
  let t := Real.sqrt ((N : ℝ)*σ^2)
  have ht : 0 < t := Real.sqrt_pos.mpr (by positivity)
  have htdef : t^2 = (N : ℝ)*σ^2 := Real.sq_sqrt (by positivity)
  have ht1 : t^2 ≤ 1 := htdef.le.trans hscale
  have hKLp : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (N*(p.energy : ℝ)/t^2) := by
    refine hKL.trans (ENNReal.ofReal_le_ofReal ?_)
    rw [htdef]
    calc
      (digitalMassPolynomial d C r c+1)/σ^2 ≤ (p.energy : ℝ)/σ^2 :=
        div_le_div_of_nonneg_right hKreal (sq_nonneg σ)
      _ = (N : ℝ)*p.energy/((N : ℝ)*σ^2) := by
        have hNR : (N : ℝ) ≠ 0 := by positivity
        field_simp
  have hrob : ∀ᵐ w ∂Q, w ∈ robustEvent Real.tanh c := hsupport.mono (fun w hw => hw.1)
  have hrad : ∀ᵐ w ∂Q, 1/(p.inverseRadius : ℝ) ≤ robustRadius c w :=
    hsupport.mono (fun w hw => hradius.trans hw.2.2)
  haveI hQp : IsProbabilityMeasure
      (Q : Measure (Weights p.dimension N (p.depth-2))) := hQ
  obtain ⟨Γ,hΓ,π,hfail⟩ := @RobustCompressionInput.finite_grid_compression_of_large_width_raw
    p N hd hN hAf hR σ t c ht ht1 htdef Q hQp hKLp Real.tanh tanh_admissible hrob hrad (fun hlarge =>
      hraw p hd hL hK hAf hR N hlarge σ t hσ ht ht1 htdef Q hQ hKLp)
  refine ⟨Γ,hΓ,π,fun x => (hfail x).trans hfailure⟩

end NeuralGeneralization.RobustMainProofs
